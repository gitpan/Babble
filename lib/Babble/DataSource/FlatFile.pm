## Babble/DataSource.pm (C) 2004 Gergely Nagy <algernon@bonehunter.rulez.org>
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

package Babble::DataSource::FlatFile;

use strict;
use Carp;

use Babble::Document;
use Babble::Document::Collection;
use Babble::DataSource;

use File::Find;
use File::stat;
use File::Basename;
use Date::Manip;

use Exporter ();
use vars qw(@ISA);
@ISA = qw(Babble::DataSource);

my $permalink_blosxom = sub {
	my ($base, $file, $date, $ext) = @_;
	my $anchor = basename ($file);

	$anchor =~ s/$ext$//g;

	return $base . UnixDate (ParseDate ($date),
				 "%Y/%m/%d/#") . $anchor;
};

sub new {
	my $type = shift;
	my $class = ref ($type) || $type;
	my $self = $class->SUPER::new (@_);

	croak "$type->new() called without -data_dir argument"
		unless $self->{-data_dir};
	$self->{-extension} = "\.txt" unless $self->{-extension};
	$self->{-permalink_gen} = \&$permalink_blosxom
		unless $self->{-permalink_gen};

	bless $self, $type;
}

sub collect($) {
	my ($self, $babble) = @_;
	my @files = ();
	my $collection;
	my %args;

	foreach ("meta_title", "meta_desc", "meta_link", "meta_owner_email",
		 "meta_subject", "meta_feed_link") {
		$args{$_} = $babble->{Params}->{$_};

		$args{$_} = $self->{$_} if (defined $self->{$_});
		$args{$_} = "" if (!$args{$_});
	}

	find ({wanted => sub {
		       /$self->{-extension}$/ &&
		       push (@files, $File::Find::name);
	       }}, $self->{-data_dir});

	$collection = Babble::Document::Collection->new (
		title => $args{meta_title},
		link => $args{meta_feed_link},
		id => $args{meta_link},
		author => $args{meta_owner_email},
		content => $args{meta_desc},
		date => UnixDate ("today", "%Y-%m-%dT%H:%M:%S+00:00"),
		subject => $args{meta_subject}
	);

	foreach my $file (@files) {
		my ($title, $subject, $date, $link);
		my @content;
		my $doc;

		open (INF, "<" . $file);
		$title = <INF>;
		chomp ($title);
		@content = <INF>;
		close (INF);

		$subject = dirname ($file);
		$subject =~ s/^$self->{-data_dir}/./;
		$subject =~ s{^\./?}{};
		$subject = "main" unless $subject;

		$date = gmtime (stat ($file)->mtime);
		$link = $self->{-permalink_gen} ($self->{-permalink_base},
						 $file, $date,
						 $self->{-extension});

		$doc = Babble::Document->new (
			title => $title,
			id => $link,
			content => join ("", @content),
			subject => $subject,
			date => $date,
			author => getpwuid (stat ($file)->uid),
		);

		push (@{$collection->{documents}}, $doc);
	}

	return $collection;
}

1;

# arch-tag: 13b638e3-a4e5-4b81-a924-dc931cd25ded
