## Babble/Theme/sidebar.pm
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

package Babble::Theme::sidebar;

use strict;
use Babble::Theme;
use Babble::Output::HTML;

use Exporter ();
use vars qw(@ISA);
@ISA = qw(Babble::Theme);

=pod

=head1 NAME

Babble::Theme::sidebar - A theme for the Mozilla sidebar

=head1 DESCRIPTION

This theme is intended to serve as a base for generating a layout for
the Mozilla sidebar. It displays only a minimal set of information,
since the space is quite narrow.

=head1 TEMPLATE VARIABLES

The following variables are used by the template (variables coming
from Babble::Document or Babble::Document::Collection sources are not
listed here!)

=over 4

=item meta_title

The title of the Babble

=item meta_refresh

The number of seconds to wait before the document is reloaded.

=back

=cut

sub output {
	my ($self, $babble, %params) = @_;

	$self->_merge_params
		($babble, \%params,
		 {
			 -template => $self->_find_template ('advogato'),
			 meta_css_link => "advogato.css"
		 }
	 );


	return Babble::Output::HTML->output ($babble, %params);
}

=pod

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://mantis.bonehunter.rulez.org/>.

=head1 SEE ALSO

Babble::Theme

=cut

1;

# arch-tag: 5c42c57d-8396-4458-805c-007ea2cbd2c7
