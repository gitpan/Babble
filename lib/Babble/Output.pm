## Babble/Output.pm
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

package Babble::Output;

use strict;
use Carp;

use Exporter ();
use vars qw(@ISA);
@ISA = qw(Exporter);

=pod

=head1 NAME

Babble::Output - Base output class for Babble

=head1 DESCRIPTION

Babble::Output is a base class, a class which should never ever
be used directly by applications (as it does nothing useful).

This class is merely provided to be a base to inherit from. All
descendants must implement at least the methods this class implements.

=head1 METHODS

=over 4

=cut

=pod

=item I<output>(B<$babble>, B<%params>)

This method takes the Babble object in its first argument, and all the
supplied parameters, and does whatever is necessary to return a
scalar, containing the output.

=cut

sub output {
	croak "output() unimplemented in this class!";
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://mantis.bonehunter.rulez.org/>.

=head1 SEE ALSO

Babble::Output::HTML, Babble::Output::RSS

=cut

1;

# arch-tag: be29e29a-cf35-4694-a21b-51553335fe4b
