use Module::Build;
Module::Build->new(
	module_name => 'WWW::Amazon::Wishlist',
    license     => 'perl',
	requires    => 	{
					'LWP' => 0,
					'Getopt::Long' => 0, 
					'Template::Extract' => 0, 
					'Carp' => 0
				},
	scripts     => [ 'bin/amazonwish' ],
	create_makefile_pl => 'traditional',
)->create_build_script;

