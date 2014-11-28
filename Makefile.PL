
# $Id: Makefile.PL,v 2.4 2014-11-28 15:27:19 Martin Exp $

use inc::Module::Install;

BEGIN { $Module::Install::AUTHOR = 1; }

all_from('lib/WWW/Amazon/Wishlist.pm');

install_script('Programs/amazonwish');

requires('Carp');
requires('Getopt::Long');
requires('HTML::TreeBuilder');
requires('LWP::UserAgent');
test_requires('Test::More');

use Env;
if ($ENV{MTHURN_PERL_DEV})
  {
  warn "DDD This is author's development environment\n";
  use_ptar();
  } # if

WriteAll;

if (0 && $ENV{MTHURN_PERL_DEV})
  {
  my $sFnameMakefile = q{Makefile};
  eval "use File::Slurp";
  my $s = read_file($sFnameMakefile);
  if ($s !~ s/(DIRFILESEP\s*=\s*).+$/$1\//m)
    {
    warn " EEE did not find DIRFILESEP in Makefile\n";
    } # if
  if ($s !~ s/(pm_to_blib\(){{\@ARGV}}/$1 . '{@ARGV}'/e)
    {
    warn " EEE did not find pm_to_blib@ARGV in Makefile\n";
    } # if
  if ($s !~ s/(from_to\s+=>\s+){{\@ARGV}}/$1 . '{@ARGV}'/e)
    {
    warn " EEE did not find from_to@ARGV in Makefile\n";
    } # if
  write_file($sFnameMakefile, $s);
  } # if

__END__
