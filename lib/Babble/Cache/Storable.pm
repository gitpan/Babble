## Babble/Cache/Storable.pm
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

package Babble::Cache::Storable;

use strict;
use Storable;

sub cache_load ($$) {
	my ($self, $fn, $cachedb) = @_;

	$$cachedb = Storable::retrieve $fn;
}

sub cache_dump ($$) {
	my ($self, $fn, $cachedb) = @_;

	Storable::store $$cachedb, $fn;
}

=pod

=head1 NAME

Babble::Cache::Storable - Storable data storage for Babble::Cache

=head1 DESCRIPTION

This module implements a storage format for Babble::Cache that uses
Storable to store and retrieve the cache.

The main advantage is speed, but the stored cache is not human
readable.

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Storable, Babble, Babble::Cache::Dumper

=cut

1;

# arch-tag: bbb35e90-13d8-480c-b700-f6a5603e2680
