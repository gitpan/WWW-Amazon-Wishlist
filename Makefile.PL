use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	   => 'WWW::Amazon::Wishlist',
    'VERSION_FROM' => 'Wishlist.pm', # finds $VERSION
    'PREREQ_PM'    => { 'LWP' => 0 },
);
