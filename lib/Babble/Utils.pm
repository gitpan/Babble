## Babble/Utils.pm
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

package Babble::Utils;
use strict;

=pod

=head1 NAME

Babble - RSS Feed Aggregator

=head1 SYNOPSIS

 use Babble::Utils;

 my $babble = Babble->new (-limit_max => 20);

 ...
 $babble->collect_feeds ();
 $babble->force_limits ()
 ...

=head1 DESCRIPTION

C<Babble::Utils> provides non-essential extensions to a Babble
object. All methods herein fall under the Babble namespace, and are
available with every Babble instance one makes, when this module is in
use.

=head1 METHODS

Babble::Utils provides the following methods:

=over 4

=cut

=pod

=item I<force_limits>()

Enforce prespecified limits. That is, when one created a babble with a
I<-limit_max> argument set to a non-zero value, only that many items
will be displayed in the resulting output, all others are deleted.

=cut

sub Babble::force_limits () {
	my $self = shift;
	my $limit = $self->{Config}->{-limit_max};

	return unless $limit;

	delete @{$self->{Items}}[$limit..$#{$self->{Items}}];
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

# arch-tag: 10f0e287-88a5-4c94-8e4d-439f9d7fcc40
