## Babble/DataSource/OPML.pm
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

package Babble::DataSource::OPML;

use strict;
use Carp;

use Babble::DataSource;
use Babble::DataSource::RSS;
use Babble::Transport;

use XML::OPML;

use Exporter ();
use vars qw(@ISA);
@ISA = qw(Babble::DataSource);

=pod

=head1 NAME

Babble::DataSource::OPML - OPML source fetcher for Babble

=head1 SYNOPSIS

 use Babble;
 use Babble::DataSource::OPML;

 my $babble = Babble->new ();
 $babble->add_sources (
	Babble::DataSource::OPML->new (
		-id => "Planet Debian",
		-location => "http://planet.debian.net/opml.xml"
	)
 );
 ...

=head1 DESCRIPTION

Babble::DataSource::OPML implements an unordinary data source for
Babble. Instead of collecting data itself, this class parses an OPML
document, and passes the information to a set of
Babble::DataSource::RSS objects. For each outline, a new object is
created, and the new() method returns an array of
Babble::DataSource::RSS objects.

=head1 METHODS

=over 4

=cut

=pod

=item I<new>(%params)

Parses the OPML document specified in the I<-location> parameter, and
returns an array of Babble::DataSource::RSS objects.

=cut

sub new {
	my $type = shift;
	my %params = @_;
	my @sources;
	my $opml = XML::OPML->new ();

	$opml->parse (Babble::Transport->get (%params));
	foreach my $outline (@{$opml->outline}) {
		push (@sources, Babble::DataSource::RSS->new
			      (-id => $outline->{text},
			       -location => $outline->{xmlUrl}));
	}

	return @sources;
}

=pod

=item I<collect>()

Returns an error - this should not be called, ever.

=cut

sub collect () {
	carp "collect not supported by this source";
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Babble::DataSource::RSS, Babble::DataSource, Babble::Transport

=cut

1;

# arch-tag: 5088ef7b-ca76-48ae-97f9-ed332d8eb2cb
