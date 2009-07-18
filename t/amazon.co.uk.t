
# $Id: amazon.co.uk.t,v 2.1 2009-07-18 23:33:07 Martin Exp $

use strict;
use warnings;

use blib;
use Test::More 'no_plan';

BEGIN
  {
  use_ok('WWW::Amazon::Wishlist', qw(get_list UK));
  }

my $sCode = '108ACFCI5OK8I';
# ok(get_list ($sCode, UK, 1), "Got any items from .co.uk");
my @arh = get_list($sCode, UK);
my $iCount = scalar(@arh);
diag(qq{$sCode\'s wishlist at .UK has $iCount items});
ok($iCount, 'not an empty list');
if (0)
  {
  use Data::Dumper;
  print STDERR Dumper(\@arh);
  } # if

pass('all done');

__END__
