## Babble/DataSource/DBI.pm
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

package Babble::DataSource::DBI;

use strict;
use Carp;
use DBI;
use Date::Manip;

use Babble::DataSource;
use Babble::Document;
use Babble::Document::Collection;

use Exporter ();
use vars qw(@ISA);
@ISA = qw(Babble::DataSource);

=pod

=head1 NAME

Babble::DataSource::DBI - Babble data collector using DBI

=head1 SYNOPSIS

 use Babble;
 use Babble::DataSource::DBI;

 my $babble = Babble->new ();
 $babble->add_sources (
	Babble::DataSource::DBI->new (
		-location => "dbi:SQLite:dbname=babble.db",
	)
 );
 ...

=head1 DESCRIPTION

Babble::DataSource::DBI implements a Babble data source class that
fetches documents directly from whatever database DBI can fetch from.

=head1 METHODS

=over 4

=item I<new>(B<%params>)

This method creates a new object. The recognised parameters are:

=over 8

=item -location

The database to connect to, specified in a way DBI can
understand. This parameter is mandatory!

=item -db_user

Username to use to connect to the database.

=item -db_pw

Password to use to connect to the database.

=item -db_table

The table inthe database where posts are stored. When omitted,
defaults to B<posts>.

=back

=item collect

Collect data from our database. The table where we fetch fields from
must contain the following columns: I<title>, I<author>, I<subject>,
I<date>, I<id>, I<content>.

=cut

sub collect () {
	my ($self, $babble) = @_;
	my ($collection, %args);
	my $table = $self->{-db_table} || "posts";
	my $dbh = DBI->connect ($self->{-database} || $self->{-location},
				$self->{-db_user}, $self->{-db_pw},
				{PrintError => 0});

	unless ($dbh) {
		carp $DBI::errstr;
		return undef;
	}

	my $docs = $dbh->selectall_hashref ('SELECT * from ' . $table, 'id');

	unless ($docs) {
		carp $DBI::errstr;
		$dbh->disconnect;
		return undef;
	}

	$dbh->disconnect;

	foreach ("meta_title", "meta_desc", "meta_link", "meta_owner_email",
		 "meta_subject", "meta_feed_link", "meta_owner") {
		$args{$_} = $$babble->{Params}->{$_};

		$args{$_} = $self->{$_} if (defined $self->{$_});
		$args{$_} = "" if (!$args{$_});
	}

	$collection = Babble::Document::Collection->new (
		title => $args{meta_title},
		link => $args{meta_feed_link},
		id => $args{meta_link},
		author => $args{meta_owner} || $args{meta_owner_email},
		content => $args{meta_desc},
		date => ParseDate ("today"),
		subject => $args{meta_subject},
		name => $self->{-id} || $args{meta_owner} ||
			$args{meta_owner_email} || $args{meta_title},
	);

	foreach my $row (keys %{$docs}) {
		my $doc = Babble::Document->new (
			title => $docs->{$row}->{title},
			id => $docs->{$row}->{id},
			content => $docs->{$row}->{content},
			subject => $docs->{$row}->{subject},
			date => ParseDate ($docs->{$row}->{date}),
			author => $docs->{$row}->{author},
		);

		push (@{$collection->{documents}}, $doc);
	}

	return $collection;
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Babble::Document, Babble::Document::Collection,
Babble::DataSource, DBI

=cut

1;

# arch-tag: ef6645b0-43ce-4e56-9388-9a85b3952a4c
