## Babble/Transport/LWP.pm
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

package Babble::Transport::LWP;

use strict;
use Carp;
use LWP::UserAgent;

=pod

=head1 NAME

Babble::Transport::LWP - LWP based transport layer for Babble

=head1 DESCRIPTION

This module is the basic transport layer for Babble. It supports
fetching documents via any protocol LWP supports.

=head1 METHODS

=over 4

=cut

=pod

=item get

Returns the contents of the given location as a string scalar, or
B<carp>s upon error. The hash in the I<-lwp> key will be passed down to
LWP::UserAgent's new() method.

=cut

sub get {
	my ($self, $params) = @_;

	$params->{-lwp}->{agent} = "Babble/" . $Babble::VERSION
		unless defined $params->{-lwp}->{agent};

	my $ua = LWP::UserAgent->new (%{$params->{-lwp}});
	my $res = $ua->get ($params->{-location});

	return $res->content if ($res->is_success);

	carp $res->status_line;
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Babble::Transport, LWP, LWP::UserAgent

=cut

1;

# arch-tag: 54fa2d72-04c1-44fc-adfe-4aa1223b5b09
