use Module::Build;

Module::Build->new (
	module_name => "Babble",
	license => "gpl",
	requires => {
		perl => '5.6.0',
		Date::Manip => 0
	  },
	recommends => {
		HTML::Template => 0,
		LWP::UserAgent => 0,
		XML::RSS => 0,
		Data::Dumper => 0,
		Template => 0
	  },
	PL_files => {
		'tools/install-theme.PL' => [
			'planet', 'advogato', 'sidebar', 'planet_ttk'
		]
	},
	scripts => [ 'babble.pl' ],
	dist_author => 'Gergely Nagy <algernon@bonehunter.rulez.org>',
	create_readme => 1,
	dist_version_from => "lib/Babble.pm",
	create_makefile_pl => 'passthrough'
)->create_build_script;

# arch-tag: 981be612-3aa1-4bc5-b398-fcca400a7fcd
