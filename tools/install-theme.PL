#! /usr/bin/perl -w
use strict;
use File::Copy;
use File::Path;

foreach (@ARGV) {
	my $theme = $_;
	my @files = ( "banner.tmpl", "head.tmpl", "main_content.tmpl",
		      "sidebar.tmpl", $theme . ".tmpl", $theme . ".css" );

	mkpath ("blib/lib/Babble/Theme/" . $theme, 0, 0755);

	copy ("lib/Babble/Theme/" . $theme . "/" . $_,
	      "blib/lib/Babble/Theme/" . $theme . "/" . $_)
		foreach (@files);
}

# arch-tag: 3b57f8a7-0da7-42f4-95e2-ca7e54013964
