## Babble/Cache/Dumper.pm
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

package Babble::Cache::Dumper;

use strict;
use Carp;
use Data::Dumper;

sub cache_load ($$) {
	my ($self, $fn, $cdb) = @_;

	$$cdb = do $fn;
	carp $@ if $@;
}

sub cache_dump ($$) {
	my ($self, $fn, $cachedb) = @_;

	$Data::Dumper::Terse = 1;

	unless (open (OUTF, '>' . $fn)) {
		carp 'Error dumping cache to `' . $fn . '\': ' . $1;
		return;
	}
	print OUTF "# Automatically generated file. Edit carefully!\n";
	print OUTF Dumper ($$cachedb) . ";\n";
	close OUTF;
}

=pod

=head1 NAME

Babble::Cache::Dumper - Data::Dumper data storage for Babble::Cache

=head1 DESCRIPTION

This module implements a storage format for Babble::Cache that uses
Data::Dumper to store and retrieve the cache.

The main advantage is human readability, but the stored cache is slow
to load and save.

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Data::Dumper, Babble, Babble::Cache::Storable

=cut

1;

# arch-tag: b974429f-b379-4277-9126-2c29cc3dde22
