use blib;
use Test::More tests => 3;

BEGIN { use_ok('WWW::Amazon::Wishlist', qw(get_list UK COM)) };

# .com
# ok(get_list ("2EAJG83WS7YZM", COM, 1), "Got items from .com");
my @books_com = get_list ("2EAJG83WS7YZM", COM);
use Data::Dumper;
print Dumper @books_com;
exit 0;

ok(get_list ("", UK, 1), "Got items from UK");
#my @books_uk  = get_list ("108ACFCI5OK8I", UK);
#use Data::Dumper;
#print STDERR Dumper @books_uk;

#print_books (1, @books_uk);


sub print_books
{
	my $uk = shift;
	$uk |= 0;
	
	my @books = @_;
	my $total = 0;
	foreach my $bookref (@books)
	{
		my %book = %{$bookref};
		#print '"'.$book{'title'}.'" by '.$book{'author'}." (".(($uk)?'£':'$').$book{'price'}.") [".$book{'type'}."]<br>\n";
		print "urk ",$book{'title'},"\n"  unless $book{'asin'};
		$total += $book{'price'};
	}

	return $total;
}
