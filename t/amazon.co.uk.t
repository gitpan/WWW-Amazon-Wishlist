
# $Id: amazon.co.uk.t,v 1.3 2008/12/22 02:44:43 Martin Exp $

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
