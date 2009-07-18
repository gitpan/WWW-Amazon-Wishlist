
# $Id: amazon.com.t,v 2.1 2009-07-18 23:33:08 Martin Exp $

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
cmp_ok(10, q{<}, $iCount, q{got at least 10 items}); # }); # Emacs bug
if (0)
  {
  use Data::Dumper;
  print STDERR Dumper(\@arh);
  } # if
# Gather up all the unique priorities we found:
my %hsi;
foreach my $rh (@arh)
  {
  $hsi{$rh->{priority}}++;
  } # foreach
foreach my $sRank (qw( highest high medium ))
  {
  ok($hsi{$sRank}, qq{got at least one $sRank priority item});
  } # foreach

# This is an empty wishlist:
$sCode = '3MGZN132X8XV1';
@arh = get_list($sCode, COM);
$iCount = scalar(@arh);
diag(qq{$sCode\'s wishlist at .COM has $iCount items});
is($iCount, 0, 'is an empty list');

pass('all done');

__END__
