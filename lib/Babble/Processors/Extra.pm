## Babble/Processors/Extra.pm
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

package Babble::Processors::Extra;

use strict;
use Date::Manip;
use Data::Dumper;

=pod

=head1 NAME

Babble::Processors::Extra - Extra processors for Babble

=head1 SYNOPSIS

 use Babble;
 use Babble::Processors::Extra;

 my $babble = Babble->new
    (Processors => [ \&Babble::Processors::Extra::datecache ],
     datecache_file => "/var/cache/babble/datecache.db");

=head1 DESCRIPTION

C<Babble::Processors::Extra> is a collection of optional, yet useful
processors for Babble. In some circumstances, one might wish to use
them. However, none of these are enabled by default, since they
usually require some configuration.

=head1 METHODS

=over 4

=cut

=pod

=item datecache()

This processor makes one able to approximate the submission date of
items which lack such a field in the feed. It does so, by keeping a
cache of items, and upon the first time it sees an undated item, it
uses the current date for the missing field. Next time it sees the
same undated item, it gets the date from the cache.

For the cache to be persistent, it needs to be kept between runs,
therefore it is saved to disc. One can - and has to - configurte the
location of this item, by passing a I<datecache_file> argument to the
C<Babble>'s constructor.

=cut

sub datecache {
	my ($item, $channel, $source, $babble) = @_;
	our $cache = {};
	my $date;

	return unless ($babble->{Config}->{datecache_file});

	if (-e $babble->{Config}->{datecache_file}) {
		require $babble->{Config}->{datecache_file};
	}

	if ($item->{date}) {
		$date = $item->{date};
	} else {
		$date = UnixDate ("today", "%Y-%m-%d %H:%M:%S");
	}

	if (!$cache->{$channel->{title}}) {
		$cache->{$channel->{title}} = {
		       $item->{id} => $date
		};
	} else {
		if ($cache->{$channel->{title}}->{$item->{id}} &&
		    !$item->{date}) {
			$item->{date} =
			  $cache->{$channel->{title}}->{$item->{id}};
		} else {
			$cache->{$channel->{title}}->{$item->{id}} = $date;
		}
	}

	$Data::Dumper::Terse = 1;

	open (OUTF, ">" . $babble->{Config}->{datecache_file});
	print OUTF "# Automatically generated file. Edit carefully!\n";
	print OUTF '$cache = ' . Dumper ($cache) . ";\n1;\n";
	close OUTF;
}

=pod

=item creator_map()

This processor takes the B<-creator_map> field of the I<source> and if
an items creator matches a key of it, adds all the keys from the hash
pointed to by the source's key to the item.

=cut

sub creator_map {
	my ($item, $channel, $source, undef) = @_;

	return unless defined $source->{-creator_map}->{$item->{author}};

	map {
		$item->{$_} = $source->{-creator_map}->{$item->{author}}->{$_}
	} keys (%{$source->{-creator_map}->{$item->{author}}});
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://mantis.bonehunter.rulez.org/>.

=head1 SEE ALSO

Babble, Babble::Processors

=cut

1;

# arch-tag: 11829b85-9461-43b2-86b3-436a3a84eb35
