#! /usr/bin/perl -w
use Babble;
use strict;

die "Usage: babble.pl CONFIG..." if ($#ARGV < 0);

foreach (@ARGV) {
	our %Babble = ();
	our @Feeds = [];
	our %Config = ();

	require $_;

	my $babble = Babble->new (%Config);

	$babble->add_params (%Babble);
	$babble->add_sources (@Feeds);
	$babble->collect_feeds ();
	$babble->split_items ();

	save ($Config{babble_outname_format}, "html",
	      $babble->output (-template => $Config{babble_template},
			       -type => "HTML"));
	save ($Config{babble_outname_format}, "xml",
	      $babble->output (-type => "RSS"));
}

sub save {
	my ($format, $ext, $output) = @_;
	my $fn = sprintf $format, $ext;

	open (OUTF, ">" . $fn);
	print OUTF $output;
	close (OUTF);
}

# arch-tag: 4536b9aa-775b-4c00-8932-b3416eb0540d
