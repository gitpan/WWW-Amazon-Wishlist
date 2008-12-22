
# $Id: amazon.co.uk.t,v 1.2 2008/12/22 01:51:48 Martin Exp $

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
TODO:
  {
  local $TODO = 'need to fix the UK parser';
  ok($iCount, 'not an empty list');
  } # end of TODO block
if (0)
  {
  use Data::Dumper;
  print STDERR Dumper(\@arh);
  } # if

pass('all done');

__END__
