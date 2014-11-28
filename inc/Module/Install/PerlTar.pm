#line 1
package Module::Install::PerlTar;

use 5.006001;
use strict;
use warnings;
use Module::Install::Base ();

our @ISA     = qw(Module::Install::Base);
our $VERSION = '1.001';
$VERSION =~ s/_//ms;

sub use_ptar {
	my $self = shift;
        # warn " DDD start use_ptar(), WWW Module::Install::AUTHOR is =$Module::Install::AUTHOR=\n"; # Martin

	if (! $Module::Install::AUTHOR)
          {
          warn " WWW bailing because Module::Install::AUTHOR is not set\n"; # Martin
          return;
          }

	eval { require Archive::Tar; 1; } or warn "Cannot find Archive::Tar\n";
	eval { require IO::Compress::Gzip; 1; }
	  or warn "Cannot find IO::Compress::Gzip\n";

	my %args = (
		TAR      => 'ptar',
		TARFLAGS => 'cf',
		COMPRESS =>
q{perl -MIO::Compress::Gzip=gzip,:constants -e"my $$in = $$ARGV[0]; gzip($$in => qq($$in.gz), q(Level) => Z_BEST_COMPRESSION, q(BinModeIn) => 1) or die q(gzip failed); unlink $$in;"},
	);
        # use Data::Dumper; # Martin
        # warn " DDD adding the following to makemaker_args: ", Dumper(\%args); # Martin
	$self->makemaker_args( dist => \%args );

	return 1;
} ## end sub use_ptar

1;
__END__

=encoding utf-8

#line 75
