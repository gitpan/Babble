#! perl -w
use strict;
use Cwd;
use Date::Manip;
use Test::More tests => 13;

use_ok ("Babble::Document");

my $object = Babble::Document->new ();
isa_ok ($object, "Babble::Document");

# Do all members have the right value?
foreach (qw(author content subject title id date)) {
	is_deeply ($object->{$_}, undef,
		   "Constructor set \$object->{$_} OK");
}

# Test if setting date works as expected
$object->{date} = ParseDate ("2004-01-01 01:00:00");
ok ($object->date_date() eq "2004-01-01",
    "\$object->date_date() is OK");
ok ($object->date_rss() eq "2004-01-01T01:00:00+00:00",
    "\$object->date_rss() is OK");

# Test all
ok (eq_array ($object->all(), ($object)),
    "\$object->all() is OK");

# Test search
my @res = $object->search ({field => "title", pattern => "foo"});

ok ($#res == -1, "\$object->search() is OK");

# Test inverse search
ok (eq_array ($object->search
		      ({
			      field => "title",
			      pattern => "Foo",
			      inverse => 1,
		      }), ($object)),
    "inversed \$object->search() is OK");

# arch-tag: 8ce4598d-4750-4879-803b-eeb02cf9f672
