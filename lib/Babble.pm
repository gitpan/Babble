## Babble.pm
## Copyright (C) 2004 Gergely Nagy <algernon@bonehunter.rulez.org>
##
## This file is part of Babble.
##
## Babble is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; version 2 dated June, 1991.
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

use Babble::Document::Collection;
use Babble::Processors;

use Exporter ();
use vars qw($VERSION @ISA);

$VERSION = '0.05';
@ISA = qw(Exporter);

=pod

=head1 NAME

Babble - RSS Feed Aggregator and Blog engine

=head1 SYNOPSIS

 use Babble;
 use Babble::DataSource::RSS;

 my $babble = Babble->new ();

 $babble->add_params (meta_title => "Example Babble");
 $babble->add_sources (
	Babble::DataSource::RSS->new (
		-id => "Gergely Nagy",
		-location => 'http://bonehunter.rulez.org/~algernon/blog/index.xml',
		-lwp => {
			agent => "Babble/" . $Babble::VERSION . " (Example)"
		}
        )
 );
 $babble->collect_feeds ();

 print $babble->output (-theme => "sidebar");

=head1 DESCRIPTION

C<Babble> is a system to collect, process and display RSS feeds. Designed in
a straightforward and extensible manner, C<Babble> provides near unlimited
flexibility. Even though it provides lots of functionality, the basic usage
is pretty simple, and only a few lines.

However, would one want to add new feed item processor functions, that is.
also trivial to accomplish.

=head1 METHODS

C<Babble> has a handful of methods, all of them will be enumerated here.

=over 4

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

=item -limit_max

The maximum number of items in the collection. This will be used by
the top-level Babble::Document::Collection object, see the
documentation of that class for further details.

=item -callbacks_collect_start

An array of subroutines that Babble will run for each and every
datasource when collecting feeds. The routine must take only one
argument: a reference to a Babble::DataSource object.

Calling happens before the collect itself starts.

=item -callbacks_collect_end

An array of subroutines that Babble will run for each and every
datasource when collecting feeds. The routine must take only one
argument: a reference to a Babble::DataSource object.

Calling happens after the collect itself ended.

=back

=cut

sub new {
	my $type = shift;
	my %params = @_;
	my $self = {
		Sources => [],
		Collection => Babble::Document::Collection->new
			(-limit_max => $params{-limit_max}),
		Param => {},
		Config => {
			-processors => [ \&Babble::Processors::default ],
			-callbacks_collect_start => [],
			-callbacks_collect_end => [],
		}
	};

	foreach (qw(-processors -callbacks_collect_start
		    -callbacks_collect_stop)) {
		push (@{$self->{Config}->{$_}}, @{$params{$_}})
			      if (defined $params{$_});
		delete $params{$_};
	}
	delete $params{-limit_max};

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

Retrieve and process the feeds that were added to the Babble. All
processor routines will be run by this very method. Also, if there
were any collect callbacks specified when the object was created, they
will be run too.

Please note that this must be called before the I<output> method!

=cut

sub collect_feeds () {
	my $self = shift;

	foreach my $source (@{$self->{Sources}}) {
		foreach (@{$self->{Config}->{-callbacks_collect_start}}) {
			&$_ (\$source);
		}
		my $collection = $source->collect (\$self);

		next unless $collection;

		foreach my $item (@{$collection->{documents}}) {
			next unless defined($item->{'id'});

			map { &$_ (\$item, \$collection, \$source, \$self) }
				@{$self->{Config}->{-processors}};
		}

		push (@{$self->{Collection}->{documents}}, $collection);

		foreach (@{$self->{Config}->{-callbacks_collect_stop}}) {
			&$_ (\$source);
		}
	}
}

=pod

=item sort([$params])

Sort all the elements in an aggregation by date, and return the sorted
array of items. Leaves the work to
Babble::Document::Collection->sort().

=cut

sub sort (;$) {
	my ($self, $params) = @_;

	return $self->{Collection}->sort ($params);
}

=pod

=item all([$params])

Return all items in an aggregation as an array.

=cut

sub all (;$) {
	my ($self, $params) = @_;

	return $self->{Collection}->all ($params);
}

=pod

=item output(%params)

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
	my $class;

	$type = "HTML" if (!defined $type);

	if ($theme) {
		$class = "Babble::Theme::$theme";
	} else {
		$class = "Babble::Output::$type";
	}

	eval "use $class";
	if ($@) {
		carp $@;
		return undef;
	}
	return $class->output (\$self, \%params);
}

=pod

=item search()

Dispatch everything to Babble::Document::Collection->search().

=cut

sub search {
	my ($self, $filters) = @_;
	return $self->{Collection}->search ($filters);
}

=pod

=back

=head1 PROCESSORS

Processors are subroutines that take four arguments: An I<item>, a
I<channel>, a I<source>, and a C<Babble> object (the caller). All of
them are references.

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

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Babble::DataSource, Babble::Document, Babble::Document::Collection,
Babble::Output, Babble::Theme, Babble::Processors

=cut

1;

# arch-tag: 9713288b-3724-4f59-ad22-4a3aa06ebf89
