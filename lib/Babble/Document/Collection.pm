## Babble/Document/Collection.pm
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

package Babble::Document::Collection;

use strict;
use Babble::Document;

=pod

=head1 NAME

Babble::Document::Collection - Babble document collector class

=head1 DESCRIPTION

Babble::Document::Collection is a meta-class. One, that's sole purpose
is to collect Babble::Document objects, and group them together with a
little meta-info about them.

=head1 PROPERTIES

=over 4

=item author

The author of this collection

=item subject

The subject of the collection.

=item title

The title of the collection.

=item id

A unique ID for the collection, usually a hyperlink to the source
homepage.

=item link

A link to the source of this collection (for example, to an RSS feed).

=item date

The creation date of this version of the collection.

=item content

A brief description of the collection

=back

=head1 METHODS

=over 4

=cut

=pod

=item new()

Creates a new, empty Babble::Document::Collection object. All the
properties mentioned above are recognised as paramaters.

To add documents to the collection, simply push them to
C<@{$collection-E<gt>{documents}}>.

=cut

sub new {
	my $type = shift;
	my %params = @_;

	my $self = bless {
		author => $params{author},
		subject => $params{subject},
		title => $params{title},
		id => $params{id},
		link => $params{link},
		date => $params{date},
		content => $params{content},

		documents => []
	}, $type;

	return $self;
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://mantis.bonehunter.rulez.org/>.

=head1 SEE ALSO

Babble, Babble::Document

=cut

1;

# arch-tag: 5ac2ff9a-3c8b-4fa7-9b40-33b7e5270eff
