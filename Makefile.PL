
# $Id: Makefile.PL,v 1.2 2008/12/22 01:52:56 Martin Exp $

use inc::Module::Install;

all_from('lib/WWW/Amazon/Wishlist.pm');

install_script('Programs/amazonwish');

requires('Carp');
requires('Getopt::Long');
requires('LWP');
test_requires('Test::More');

WriteAll;

__END__
