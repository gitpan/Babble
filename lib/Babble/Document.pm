## Babble/Document.pm
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

package Babble::Document;

use strict;
use Date::Manip;

=pod

=head1 NAME

Babble::Document - Babble document container class

=head1 DESCRIPTION

A Babble::Document object represents one entry in the whole collection
a Babble is working with.

=head1 PROPERTIES

A Babble::Document object has the following basic properties:

=over 4

=item author

The author of the document.

=item title

Title of the document.

=item subject

Subject of the document.

=item date

Submission date of the document.

=item id

A unique ID of the document, usually a hyperlink.

=item content

The actual content of the document.

=back

Other properties might be present, but they are not standardised by
this class. However, preprocessors and DataSources are free to add
others.

=head1 METHODS

=over 4

=cut

=pod

=item new()

Creates a new Babble::Document object. Recognises the default
properties mentioned above as arguments.

=cut

sub new {
	my $type = shift;
	my %params = @_;

	my $self = bless {
		author => $params{author},
		content => $params{content},
		subject => $params{subject},
		title => $params{title},
		id => $params{id},
		date => $params{date},
	}, $type;

	return $self;
}

=pod

=item date()

Get or set the submission date of the document, depending on having an
argument or not.

=cut

sub date (;$) {
	my ($self, $nv) = @_;

	$self->{date} = ParseDate ($nv) if (defined $nv);
	return $self->{date};
}

=pod

=item date_iso()

Returns the submission date of the document in the
"YYYY-MM-DD HH:MM:SS" format.

=cut

sub date_iso () {
	my $self = shift;

	return UnixDate ($self->{date}, "%Y-%m-%d %H:%M:%S");
}

=pod

=item date_rss()

Returns the submission date of the document in a format suitable for
putting into an RSS item's dc:date field.

=cut

sub date_rss () {
	my $self = shift;

	return UnixDate ($self->{date}, "%Y-%m-%dT%H:%M:%S+00:00");
}

=pod

=item date_text()

Returns the submission date of the document in human readable format.

=cut

sub date_text () {
	my $self = shift;

	return UnixDate ($self->{date}, "%d %B, %Y %H:%M");
}

=pod

=item date_date()

Returns only the date part of the documents submission date.

=cut

sub date_date () {
	my $self = shift;

	return UnixDate ($self->{date}, "%Y-%m-%d");
}

=pod

=item search()

Given a list of filters (see later), checks if the document matches
all the criteria specified in them. If yes, returns an array
consisting of the Babble::Document object. Otherwise returns an empty
array.

The filters are simple hashrefs, with two mandatory keys: I<field> and
I<pattern>. The first one determines which field the search is
performed on (this can be any one of the available Babble::Document
properties), and I<pattern> is the pattern it should match.

Optional keys include I<inverse>, which reverses the check, and
I<transform>, which is a code reference, which will be applied to the
source filed before comparsion.

=cut

sub search {
	my ($self, @filters) = @_;
	my $match = 1;

	foreach my $filter (@filters) {
		my $source = $self->{$filter->{field}};

		if (!$source) {
			next if ($filter->{inverse});

			$match = 0;
			last;
		}

		$source = $filter->{transform} ($source)
			if ($filter->{transform});

		if ($filter->{inverse}) {
			if ($source =~ /$filter->{pattern}/) {
				$match = 0;
				last;
			}
		} else {
			if ($source !~ /$filter->{pattern}/) {
				$match = 0;
				last;
			}
		}
	}

	return ($self) if $match;
	return ();
}

=pod

=item all()

Return ourselves. This is mostly here so that
Babble::Document::Collection->all() can call $doc->all(), which in
turn makes it possible to have Babble::Document::Collections nested,
and still work.

=cut

sub all () {
	return ($_[0]);
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Babble, Babble::Document::Collection

=cut

1;

# arch-tag: ac55e89f-a93d-4b5f-87c7-b72f903352d7
