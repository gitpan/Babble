## Babble/Transport.pm
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

package Babble::Transport;

use strict;
use Babble::Transport::LWP;

=pod

=head1 NAME

Babble::Transport - Transport abstraction layer for Babble

=head1 DESCRIPTION

This module implements a layer that is transport agnostic. That is,
one can pass a file, an HTTP URL or the like to this module, and it
will delegate the job to an appropriate sub-module. Very useful for
fetching feeds, as with Babble::Transport, the feed can be either
remote or local, and can be fetched from anywhere Babble::Transport
supports, and when one writes new DataSources, the code is reusable.

However, this should not be used outside of Babble::DataSource
classes.

=head1 METHODS

=over 4

=cut

=pod

=item get

Return the contents of a given location (given in the I<-location>
argument) as a string scalar. Only the I<-location> argument is
recognised by this method, all others, and even I<-location> will be
passed on to the relevant sub-module's B<get> method.

=cut

sub get {
	my ($self, $params) = @_;

	return Babble::Transport::LWP->get ($params);
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Babble::Transport::LWP

=cut

1;

# arch-tag: 6a98845c-d7d5-463e-929a-90af7864c399
