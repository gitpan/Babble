## Babble/Transport.pm
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

package Babble::Transport;

use strict;
use Babble::Cache;
use Babble::Transport::LWP;
use Date::Manip;

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

=item get

Return the contents of a given location (given in the I<-location>
argument) as a string scalar. If a I<-cache_db> argument is given,
this method will use the given file as a cache - to save successfully
retrieved feeds and to check the cache if it has an older version, in
case the feed couldn't be retrieved. Caching is done via
Babble::Cache.

If a I<-preprocessors> parameter is given, the result will be filtered
through the coderefs contained in this arrayref. The function should
take only one argument: a scalar reference, and operate on that
in-place.

=cut

sub get {
	my ($self, $params) = @_;
	our $cache = {};
	my $loc = \$params->{-location};

	$params->{-headers}->{'If-Modified-Since'} =
		Babble::Cache::cache_get ('Feeds', $$loc, 'time');

	my $result = Babble::Transport::LWP->get ($params);

	$result = Babble::Cache::cache_update (
		'Feeds', $$loc,
		{
			feed => $result,
			time => UnixDate ("now", "%a, %d %b %Y %H:%M:%S GMT")
		}, 'feed');

	foreach my $preproc (@{$params->{-preprocessors}}) {
		&$preproc (\$result);
	}

	return $result;
}

=pod

=back

=head1 AUTHOR

Gergely Nagy, algernon@bonehunter.rulez.org

Bugs should be reported at L<http://bugs.bonehunter.rulez.org/babble>.

=head1 SEE ALSO

Babble::Transport::LWP, Babble::Cache

=cut

1;

# arch-tag: 6a98845c-d7d5-463e-929a-90af7864c399
