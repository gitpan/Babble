## Babble/DataSource/RSS.pm
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

package Babble::DataSource::RSS;

use strict;
use Encode;
use Carp;

use Babble::Encode;
use Babble::Cache;
use Babble::DataSource;
use Babble::Document;
use Babble::Document::Collection;
use Babble::Transport;

use XML::RSS;
use Date::Manip;

use Exporter ();
use vars qw(@ISA);
@ISA = qw(Babble::DataSource);

=pod

=head1 NAME

Babble::DataSource::RSS - RSS source fetcher for Babble

=head1 SYNOPSIS

 use Babble;
 use Babble::DataSource::RSS;

 my $babble = Babble->new ();
 $babble->add_sources (
	Babble::DataSource::RSS->new (
		-id => "Gergely Nagy",
		-location => "http://midgard.debian.net/~algernon/blog/index.xml"
	)
 );
 ...

=head1 DESCRIPTION

Babble::DataSource::RSS implements a Babble data source class that
parses an arbitary RSS feed.

=head1 METHODS

=over 4

=item I<collect>()

This one does the bulk of the job, fetching the feed and parsing it,
then returning a Babble::Document::Collection object.

If a I<-cache_parsed> option was set when creating the object, the
parsed data will be stored in the cache. This can speed up processing
considreably, yet it needs much more memory too.

=cut

sub collect () {
	my $self = shift;
	my $rss = XML::RSS->new ();
	my ($collection, $feed, $date, $subject, $creator, $image);

	$feed = Babble::Transport->get ($self);
	return undef unless $feed;

	if ($self->{-cache_parsed} &&
	    Date_Cmp (Babble::Cache::cache_get ('Feeds', $self->{-location},
						'time'),
		      Babble::Cache::cache_get ('Parsed', $self->{-location},
						'time')) < 0) {
		# We should use the cache...
		return Babble::Cache::cache_get ('Parsed',
						 $self->{-location},
						 'data');
	}

	$rss->parse ($feed);
	if ($@) {
		carp $@;
		return undef;
	}

	if ($rss->channel ('dc')) {
		$date = $rss->channel ('dc')->{date};
		$date = $rss->channel ('dc')->{pubDate} unless $date;
		$subject = $rss->channel ('dc')->{subject};
		$creator = $rss->channel ('dc')->{creator};
	}
	$date = "today" unless $date;
	if ($date =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):(\d{2})Z/) {
		$date = "$1 $2:00+$3:00";
	}
	$creator = $self->{-id} unless $creator;

	$image = {
		title => to_utf8 ($rss->image ('title')),
		url => $rss->image ('url'),
		link => $rss->image ('link'),
		width => $rss->image ('width'),
		height => $rss->image ('height'),
	} if $rss->image ('url');

	$collection = Babble::Document::Collection->new (
		author => to_utf8 ($creator),
		title => to_utf8 ($rss->channel ('title')),
		content => to_utf8 ($rss->channel ('description')),
		subject => to_utf8 ($subject),
		id => $rss->channel ('link'),
		link => $self->{-location},
		date => ParseDate ($date),
		name => to_utf8 ($self->{-id}),
		image => $image,
	);

	foreach (@{$rss->{items}}) {
		my ($date, $author, $subject, $item, $content);

		if ($_->{dc}) {
			$date = $_->{dc}->{date};
			$author = $_->{dc}->{creator};
			$subject = $_->{dc}->{subject};
		}

		$date = $_->{pubDate} unless $date;
		$date = $_->{date} unless $date;
		if ($date &&
		    $date =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):(\d{2})Z/) {
			$date = "$1 $2:00+$3:00";
		}
		$date = $collection->{date} unless $date;
		if ($date =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):(\d{2})Z/) {
			$date = "$1 $2:00+$3:00";
		}

		$author = $self->{-id} unless $author;

		$content = $_->{description} ||
			$_->{'http://purl.org/rss/1.0/modules/content/'}->{encoded};

		$item = Babble::Document->new (
			author => to_utf8 ($author),
			date => ParseDate ($date),
			content => to_utf8 ($content),
			title => to_utf8 ($_->{title}),
			id => $_->{link},
			subject => to_utf8 ($subject),
		);

		push (@{$collection->{documents}}, $item);
	}

	Babble::Cache::cache_update (
		'Parsed', $self->{-location},
		{
			time => UnixDate ("now", "%a, %d %b %Y %H:%M:%S GMT"),
			data => $collection
		}, 'data') if $self->{-cache_parsed};

	return $collection;
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Babble::Document, Babble::Document::Collection,
Babble::DataSource, Babble::Transport

=cut

1;

# arch-tag: 0009f92d-09c9-40b7-b651-62c586f529fc
