## Babble/DataSource/HTTP.pm
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

package Babble::DataSource::HTTP;

use strict;
use Carp;

use Babble;
use Babble::DataSource;
use Babble::Document;
use Babble::Document::Collection;

use LWP::UserAgent;
use XML::RSS;
use Date::Manip;

use Exporter ();
use vars qw(@ISA);
@ISA = qw(Babble::DataSource);

=pod

=head1 NAME

Babble::DataSource::HTTP - HTTP source fetcher for Babble

=head1 SYNOPSIS

 use Babble;
 use Babble::DataSource::HTTP;

 my $babble = Babble->new ();
 $babble->add_sources (
	Babble::DataSource::HTTP->new (
		-id => "Gergely Nagy",
		-url => "http://midgard.debian.net/~algernon/blog/index.xml"
	)
 );
 ...

=head1 DESCRIPTION

Babble::DataSource::HTTP implements a Babble data source class that
reaches out onto the internet to fetch RSS feeds.

=head1 METHODS

=over 4

=cut

=pod

=item I<new>(B<%params>)

This method creates a new object. The recognised arguments include
I<-url>, which is a mandatory argument, and I<-user_agent>, which can
be used to change what User-Agent Babble::DataSource::HTTP will
identify itself as.

=cut

sub new {
	my $type = shift;
	my $class = ref ($type) || $type;
	my $self = $class->SUPER::new (@_);

	$self->{-user_agent} = "Babble/" . $Babble::VERSION
		unless $self->{-user_agent};

	croak "$type->new() called without -url argument" unless $self->{-url};

	bless $self, $type;
}

=pod

=item I<collect>()

This one does the bulk of the job, fetching the feed and parsing it,
then returning a Babble::Document::Collection object.

=cut

sub collect () {
	my $self = shift;
	my $rss = XML::RSS->new ();
	my $ua = LWP::UserAgent->new (agent =>
				      $self->{-user_agent});
	my $collection;
	my ($date, $subject, $creator);

	$rss->parse ($ua->get ($self->{-url})->content);

	if ($rss->channel ('dc')) {
		$date = $rss->channel ('dc')->{date};
		$date = $rss->channel ('dc')->{pubDate} unless $date;
		$subject = $rss->channel ('dc')->{subject};
		$creator = $rss->channel ('dc')->{creator};
	}
	$date = "today" unless $date;

	$collection = Babble::Document::Collection->new (
		author => $creator,
		title => $rss->channel ('title'),
		content => $rss->channel ('description'),
		subject => $subject,
		id => $rss->channel ('link'),
		link => $self->{-url},
		date => ParseDate ($date)
	);

	foreach (@{$rss->{items}}) {
		my ($date, $author, $subject, $item);

		if ($_->{dc}) {
			$date = $_->{dc}->{date};
			$author = $_->{dc}->{creator};
			$subject = $_->{dc}->{subject};
		}

		$date = $_->{pubDate} unless $date;
		$date = $_->{date} unless $date;

		$item = Babble::Document->new (
			author => $author,
			date => ParseDate ($date),
			content => $_->{description},
			title => $_->{title},
			id => $_->{link},
			subject => $subject
		);

		push (@{$collection->{documents}}, $item);
	}

	return $collection;
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Babble::Document, Babble::Document::Collection,
Babble::DataSource

=cut

1;

# arch-tag: 0009f92d-09c9-40b7-b651-62c586f529fc
