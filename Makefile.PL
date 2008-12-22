
# $Id: Makefile.PL,v 1.3 2008/12/22 02:26:59 Martin Exp $

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
