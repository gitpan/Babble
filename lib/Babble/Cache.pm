## Babble/Cache.pm
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

package Babble::Cache;

use strict;
use Carp;

use vars qw($cachedb $cache_format);

BEGIN {
	our $cachedb = {};
	our $cache_format = "Dumper";
}

=pod

=head1 NAME

Babble::Cache - Global caching infrastructure for Babble

=head1 DESCRIPTION

This module implements a global cache, a hash that is used to store
stuff in; and a set of methods to update, query or otherwise
manipulate the cache. Including loading and saving it, of course.

=head1 METHODS

Babble::Cache provides the following methods:

=over 4

=item cache_load($fn)

Loads the file specified, if exists. The format of the database can
vary. By default, it is valid perl code, dumped out with Data::Dumper,
but it can be anything that the Babble::Cache:: sub-modules support.

=cut

sub cache_load ($) {
	my $fn = shift;

	return unless ($fn && -e $fn);

	eval "use Babble::Cache::$cache_format";
	if ($@) {
		carp $@;
		return;
	}
	"Babble::Cache::$cache_format"->cache_load ($fn, \$cachedb);
}

=pod

=item cache_frob($category, $id, $data [, $keys])

Frobnicate stuff in the cache. This is a quite complex method, which
does a few interesting things. First, it looks up if an entry named
I<$id> exists under the I<$category> in the cache. If it does, all the
keys listed in the I<$keys> arrayref will be copied over from the
cache. If the cache does not have the key yet, it will be updated.

If the entry is not found in the cache, the keys listed in I<$keys>
will be stored in it.

If I<$keys> is not defined, all keys of I<$data> will be used.

=cut

sub cache_frob ($$$;$) {
	my ($cat, $id, $data, $keys) = @_;
	@$keys = keys %$data unless $keys;

	if ($cachedb->{$cat}->{$id}) {
		foreach my $key (@$keys) {
			if (defined $cachedb->{$cat}->{$id}->{$key}) {
				$$data->{$key} =
					$cachedb->{$cat}->{$id}->{$key};
			} else {
				$cachedb->{$cat}->{$id}->{$key} =
					$$data->{$key};
			}
		}
	} else {
		foreach my $key (@$keys) {
			$cachedb->{$cat}->{$id}->{$key} = $$data->{$key};
		}
	}
}

=pod

=item cache_update($category, $id, $data, $key)

Update the cache with the values of I<$data> when its I<$key> key is
defined. Otherwise, return the contents of the appropriate entry of
the cache.

=cut

sub cache_update ($$$$) {
	my ($cat, $id, $data, $key) = @_;

	if ($data->{$key}) {
		$cachedb->{$cat}->{$id} = $data;
		return $data->{$key}
	} else {
		return $cachedb->{$cat}->{$id}->{$key};
	}
}

=pod

=item cache_get($category, $id, $key)

Retrieve the value of the I<$key> element in the I<$id> key in the
I<$category> category of the cache.

=cut

sub cache_get ($$$) {
	my ($cat, $id, $key) = @_;
	return $cachedb->{$cat}->{$id}->{$key};
}

=pod

=item cache_dump($fn)

Save the cache to the specified file.

=cut

sub cache_dump ($) {
	my $fn = shift;

	return unless $fn;

	eval "use Babble::Cache::$cache_format";
	if ($@) {
		carp $@;
		return;
	}
	"Babble::Cache::$cache_format"->cache_dump ($fn, \$cachedb);
}

=pod

=back

=head1 VARIABLES

=over 4

=item $Babble::Cache::cache_format

Determines the format of the cache. Values can be I<Dumper>
(Data::Dumper will be used to dump the database, and require to
restore it), or I<Storable> (Storable will be used to dump and
retrieve the data).

Defaults to I<Dumper>, because that is easier to edit by hand, if
needed.

=back

=head1 STORAGE FORMATS

Storage formats are implemented by Babble::Cache sub-modules. A
storage module needs to have two methods (both must be callble in an
OO fashion):

=over 4

=item cache_load

Takes two arguments: the filename to read from (already verified that
it exists), and a reference to a hashref, where the loaded data must
be stored.

=item cache_dump

Also takes two arguments: the filename to dump the cache to, and a
reference to a hashref, containing the data to store.

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Babble, Babble::Cache::Dumper, Babble::Cache::Storable

=cut

1;

# arch-tag: 0398d7e3-5725-4de8-ae74-fc3a277fb97d
