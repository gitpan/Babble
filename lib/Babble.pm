## Babble.pm
## Copyright (C) 2004 Gergely Nagy <algernon@bonehunter.rulez.org>
##
## This file is part of Babble.
##
## Babble is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## Babble is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

package Babble;

use strict;
use Carp;

use Babble::Processors;

use Exporter ();
use vars qw($VERSION @ISA);

$VERSION = '0.01';
@ISA = qw(Exporter);

=pod

=head1 NAME

Babble - RSS Feed Aggregator and Blog engine

=head1 SYNOPSIS

 use Babble;
 use Babble::DataSource::HTTP;

 my $babble = Babble->new ();

 $babble->add_params (meta_title => "Example Babble");
 $babble->add_source (
	Babble::DataSource::HTTP->new (
		-id => "Gergely Nagy",
		-user_agent => "Babble/0.01 (Example)",
		-url => 'http://midgard.debian.net/~algernon/blog/index.xml');
 $babble->collect_feeds ();
 $babble->split_items ();

 print $babble->output (-type => "HTML",
		        -template = "themes/sidebar/sidebar.tmpl");

=head1 DESCRIPTION

C<Babble> is a system to collect, process and display RSS feeds. Designed in
a straightforward and extensible manner, C<Babble> provides near unlimited
flexibility. Even though it provides lots of functionality, the basic usage
is pretty simple, and only a few lines.

However, would one want to add new feed item processor functions, that is.
also trivial to accomplish.

In the default install, two output types are provided: HTML via
C<HTML::Template> and RSS via C<XML::RSS>. New formats are also trivial
to add.

=head1 METHODS

C<Babble> has a handful of methods, all of them will be enumerated here.

=over 4

=cut

=pod

=item I<new>()

Creates a new Babble object. Arguments to the I<new> method are listed
below, all of them are optional. All arguments passed to I<new> will
be stored without parsing, for later use by processors and other
extensions.

=over 4

=item -processors

An array of subroutines that Babble will run for each and every item it
processes. See the PROCESSORS section for more information about these
matters.

=back

=cut

sub new {
	my $type = shift;
	my $self = {
		Sources => [],
		Items => [],
		Documents => [],
		Dates => [],
		Param => {},
		Config => {
			-processors => [ \&Babble::Processors::default ]
		}
	};
	my %params = @_;

	push (@{$self->{Config}->{-processors}},
	      @{$params{-processors}}) if (defined $params{-processors});
	delete $params{-processors};

	map { $self->{Config}->{$_} = $params{$_} } keys %params;

	bless $self, $type;
}

=pod

=item I<add_params>(B<%params>)

Add custom paramaters to the Babble object, which might be usable for the
output generation routines.

See the documentation of the relevant output method for details.

=cut

sub add_params (%) {
	my $self = shift;
	my %params = @_;

	map { $self->{Params}->{$_} = $params{$_} } keys %params;
}

=pod

=item I<add_sources>(B<@sources>)

Adds multiple sources in one go.

=cut

sub add_sources (@) {
	my $self = shift;

	push (@{$self->{Sources}}, @_);
}

=pod

=item I<collect_feeds>()

Retrieve and process the feeds that were added to the Babble. All processor
routines will be run by this very method.

Please note that this must be called before the I<output> method, and
even before I<sort_items>, as neither will automatically call it.

=cut

sub collect_feeds () {
	my $self = shift;

	foreach my $source (@{$self->{Sources}}) {
		my $collection = $source->collect ($self);

		push (@{$self->{Documents}}, $collection);

		foreach my $item (@{$collection->{documents}}) {
			next unless defined($item->{'id'});

			map { &$_ ($item, $collection, $source, $self) }
				@{$self->{Config}->{-processors}};

			push (@{$self->{Items}}, $item) if $item->{id};
		}
	}

	@{$self->{Items}} =
		sort { $b->date_iso cmp $a->date_iso } @{$self->{Items}};
}

=pod

=item I<split_items>()

Split the retrieved feed items into an array of dates. So items
submitted on the same date will be kept near each other. The structure
of the resulting hash (C<$self->{Dates}>) is something like this:

  $self->{Dates} = {
	"2004-02-01" => {
		date => "2004-02-01",
		items => @list_of_items
	}
  };

This resulting hash is required by most the output methods.

=cut

sub split_items () {
	my $self = shift;
	my $titem = ();

	foreach (@{$self->{Items}}) {
		if (defined ($titem->{date})) {
			if ($titem->{date} ne $_->date_date) {
				push (@{$self->{Dates}}, $titem);
				$titem = ();
			}
		}
		$titem->{date} = $_->date_date;
		push (@{$titem->{items}}, $_);
	}
	push (@{$self->{Dates}}, $titem);
}

=pod

=item I<output>(B<%params>)

Generate the output. This methods recognises two arguments: C<type>,
which determines what output method will be used for the actual output
itself, and C<theme>, which overrides this, and uses a theme engine
instead. (A theme engine is simply a wrapper around a specific output
method, with some paramaters pre-filled.)

The called module needs to be named C<Babble::Output::$type> or
C<Babble::Theme::$theme>, and must be a Babble::Output descendant.

=cut

sub output ($;) {
	my $self = shift;
	my %params = @_;
	my $type = $params{-type};
	my $theme = $params{-theme};
	our $output;

	$type = "HTML" if (!defined $type);

	if ($theme) {
		my $req = $theme;
		$req =~ s,::,\/,g;
		eval {
			require "Babble/Theme/$req.pm";
			$output = "Babble::Theme::$theme"->output (
				$self, %params
			);
		};
		carp $@ if $@;
	} else {
		my $req = $type;
		$req =~ s,::,\/,g;
		eval {
			require "Babble/Output/$req.pm";
			$output = "Babble::Output::$type"->output (
				$self, %params
			);
		};
		carp $@ if $@;
	}

	return $output;
}

=pod

=back

=head1 PROCESSORS

Processors are subroutines that take four arguments: An I<item>, a
I<channel>, a I<source>, and a C<Babble> object (the caller).

An I<item> is a Babble::Document object, I<channel> is a
Babble::Document::Collection object, and I<source> is a
Babble::DataSource object.

Preprocessors operate on I<item> in-place, doing whatever they want with
it, being it adding new fields, modifying others or anything one might
come up with.

A default set of preprocessors, which are always run first (unless
special hackery is in the works), are provided in the C<Babble::Processors>
module. Since they are automatically used, one does not need to
add them explicitly.

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://mantis.bonehunter.rulez.org/>.

=head1 SEE ALSO

Babble::DataSource, Babble::Document, Babble::Document::Collection,
Babble::Output, Babble::Theme, Babble::Processors

=cut

1;

# arch-tag: 9713288b-3724-4f59-ad22-4a3aa06ebf89
