# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use WWW::Amazon::Wishlist qw (get_list);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# this has been commented out 'cos
# it's difficult to test this sort 
# of stuff

# .com
#my @books_com = get_list ("2EAJG83WS7YZM");
#print "ok 2\n";
#print_books (0, @books_com);


#my @books_uk  = get_list ("108ACFCI5OK8I", 1);
#print "ok 3\n";
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
		print '"'.$book{'title'}.'" by '.$book{'author'}." (".(($uk)?'£':'$').$book{'price'}.") [".$book{'type'}."]\n";
		$total += $book{'price'};
	}

	return $total;
}
