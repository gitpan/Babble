## Babble/Output/HTML.pm
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

package Babble::Output::HTML;

use strict;
use File::Basename;
use HTML::Template;
use Date::Manip;

use Babble::Output;

use Exporter ();
use vars qw(@ISA);
@ISA = qw(Babble::Output);

=pod

=head1 NAME

Babble::Output::HTML - HTML output method for Babble

=head1 SYNOPSIS

 use Babble;

 my $babble = Babble->new ();
 ...
 print $babble->output (-type => "HTML",
			-template => "example.tmpl",
			meta_title => "Example Babble",
			meta_desc => "This is an example babble");

=head1 DESCRIPTION

This module implements the HTML output method for C<Babble>, thus, it
only has one method: output(), which generates HTML output from the
available items, using C<HTML::Template>.

=head1 METHODS

=over 4

=cut

=pod

=item I<output>(B<$babble>, B<%params>)

This output method recognises only the I<template> argument, which
will be passed to C<HTML::Template->new()>. All other arguments will
be made available for use in the template.

Along with the arguments passed to this method, the paramaters set up
with C<$babble->add_params()>, an array of channels, and an array of
dates will be made available for the template.

See the source of this module, C<HTML::Template> and any of the
example templates for details.

=cut

sub output {
	my $self = shift;
	my $babble = shift;
	my %params = @_;

	my $tmpl = HTML::Template->new
		(filename => $params{-template},
		 die_on_bad_params => 0, global_vars => 1,
		 path => dirname ($params{-template}));
	$tmpl->param (documents => $babble->{Documents});
	$tmpl->param (items => $babble->{Dates});
	$tmpl->param ($babble->{Params});
	$tmpl->param (\%params);
	$tmpl->param (last_update => UnixDate ("today", "%Y-%m-%d %H:%M:%S"));

	return $tmpl->output;
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://mantis.bonehunter.rulez.org/>.

=head1 SEE ALSO

Babble, HTML::Template, Babble::Output::RSS

=cut

1;

# arch-tag: 5b7e849c-9a09-4d30-a409-ce443b11a2b3
