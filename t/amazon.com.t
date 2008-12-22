
# $Id: amazon.com.t,v 1.3 2008/12/22 02:44:55 Martin Exp $

use strict;
use warnings;

use blib;
use Test::More 'no_plan';

BEGIN
  {
  use_ok('WWW::Amazon::Wishlist', qw(get_list COM));
  }

# I think this is Simon's, it has at least 18 pages!!!:
my $sCode = '2EAJG83WS7YZM';
# This is Martin's, it has two pages:
$sCode = '2O4B95NPM1W3L';
# ok(get_list ($sCode, COM, 1), "Got any items from .com");
my @arh = get_list($sCode, COM);
my $iCount = scalar(@arh);
diag(qq{$sCode\'s wishlist at .COM has $iCount items});
ok($iCount, 'not an empty list');
if (0)
  {
  use Data::Dumper;
  print STDERR Dumper(\@arh);
  } # if

# This is an empty wishlist:
$sCode = '3MGZN132X8XV1';
@arh = get_list($sCode, COM);
$iCount = scalar(@arh);
diag(qq{$sCode\'s wishlist at .COM has $iCount items});
is($iCount, 0, 'is an empty list');

pass('all done');

__END__
