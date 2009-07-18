
# $Id: Makefile.PL,v 2.1 2009-07-18 23:33:07 Martin Exp $

use inc::Module::Install;

all_from('lib/WWW/Amazon/Wishlist.pm');

install_script('Programs/amazonwish');

requires('Carp');
requires('Getopt::Long');
requires('HTML::TreeBuilder');
requires('LWP::UserAgent');
test_requires('Test::More');

WriteAll;

__END__
