package WWW::Amazon::Wishlist;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use LWP::UserAgent;
use Carp;

use constant COM => 0;
use constant UK  => 1;

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	
);

@EXPORT_OK = qw(
	get_list
        UK
        COM
);


$VERSION = '0.65';


=pod

=head1 NAME

WWW::Amazon::Wishlist - grab all the details from your Amazon wishlist

=head1 SYNOPSIS

  use WWW::Amazon::Wishlist qw(get_list COM UK);
  
  my @wishlist;
  
  @wishlist = get_list ($my_amazon_com_id);       # gets it from amazon.com
  @wishlist = get_list ($my_amazon_com_id,  COM); # same, explicitly
  @wishlist = get_list ($my_amazon_couk_id, UK);  # gets it from amazon.co.uk

  # or if you didn't import the COM and UK constants
  @wishlist = get_list ($my_amazon_couk_id, WWW::Amazon::Wishlist::UK);  
  


  # the elements of @wishlist are hashrefs that contain ...
  foreach my $book (@wishlist)
  {
  	print $book->{title},   # the, err, title
	      $book->{author},  # and the author(s) 
	      $book->{asin},    # the asin number, its unique id on Amazon
	      $book->{price},	# how much it will set you back
	      $book->{type};    # Hardcover/Paperback/CD/DVD etc
  
  }
 
=head1 DESCRIPTION

Goes to Amazon.(com|co.uk) and scrapes away your wishlist and returns it in a array of hashrefs so that you can fiddle with it until your hearts content.

=head1 GETTING YOUR AMAZON ID

The best way to do this is to search for your own wishlist in the search tools.

Searching for mine (simon@twoshortplanks.com) on amazon.com takes me to the URL

   http://www.amazon.com/exec/obidos/wishlist/2EAJG83WS7YZM/ 
 
there's some more cruft after that last string of numbers and letters but it's the

   2EAJG83WS7YZM
   
bit that's important.

Doing the same for amazon.co.uk is just as easy.

Apparently some people have had problems getting to their wishlist just after it gets set up. You may have to wait a while for it to become browseable.

=head1 SHOWING YOUR APPRECIATION

There was a thread on london.pm mailing list about working in a vacumn - that it was a bit depressing to keep writing
modules but never get any feedback. So, if you use and like this module then please send me an email and make my day. 

All it takes is a few little bytes.

Either that or you have the adress of my Amazon Wishlist, it's huge, buy something for me off it :)

=head1 BUGS

It doesn't parse other fields from the wishlist such as number wanted, date added, how long to ship and user comment.

I haven't ported my (broken) amazon wishlist totalling script from http://www.twoshortplanks.com/simon/stuff/amazon to use this instead.

I haven't been able to get a multi-paginated wishlist on amazon.co.uk so I can't test that it will go grab more than
one page.

It doesn't cope with anything apart from .co.uk and .com yet. Probably.

Lack of testing. It works for the pages I've tried it for but that's no guarantee.

=head1 COPYING

Copyright (c) 2001 Simon Wistow

Distributed under the same terms as Perl itself.

This software is under no warranty and will probably destroy your wish list, kill your friends, burn your house and bring about the apocalypse


=head1 AUTHOR

Simon Wistow <simon@thegestalt.org>

=head1 SEE ALSO

L<perl>, L<LWP::UserAgent>, L<amazonwish>

=cut

# does exactly what it says on the tin
sub get_list 
{
	my ($id, $uk) = @_;
	
	# bad bad bad
	unless (defined $id)
	{
		croak "No ID given to get_list function\n";
		return undef;
	}

	# note to self ... should we UC the id? Nahhhh. Not yet.

	# default is amazon.com	
	$uk |= 0;
	
	
	# fairly self explanatory
	my $domain = ($uk)? "co.uk" : "com";


	my $ua = new LWP::UserAgent;
	
	# for some reason we need to fake this *cough*
	# probably to explicitly stop screen scraping
	$ua->agent('Mozilla/5.0');


	# set up some variables
	my $page    = 1;
	my $oldpage = 0;
	my @books;
	
	# and awaaaaaaaaaaaaay we go ....
	while (1)
	{
        	

     

		 # this should be explanatory also 
		 my $url      =  "http://www.amazon.$domain/exec/obidos/wishlist/$id/?registry.page-number=$page";
		 my $request  =  HTTP::Request->new ( 'GET',$url );
        	 my $response =  $ua->request($request);
		 	
		 # also bad, let's just give up
		 if (!$response->is_success) {
		 	 croak "Couldn't get page '$url'\n";
			 return undef;
		 }


		# get the goods
		my $content = $response->content;
		push @books, extract_books ($content, $uk );

		$oldpage = $page;

		# check to see if there's another page to go to 
        	if ($content =~ /registry.page-number=(\d+).*button-more-results/) 
		{
			 $page = $1;
		} 

		
		# if not then get out of here
		last unless ($page > $oldpage);

	}

	return @books;
}




# does the extractering and stuff, like
sub extract_books
{
	my ($page, $uk) = @_;

	# default is .com. Shouldn't be needed but I'm paranoid
	$uk |= 0;
	
	my @books;
        my %seen;
	my $currency;	
		
	# set up some stuff to search for later
	if ($uk)
	{
		$currency      = '&pound;';
	} else {
		$currency      = '$';
	}
	
	my $currency_char = substr $currency, 0, 1;
	
	
	# i'd qr// this but I don't want to introduce unecessary dependencies
	while ($page =~ m!
			  <a\ href=/exec/obidos/ASIN/([^/]+)/[^>]+>  # ASIN
			  (.+=?)</a></i><br>\n\s*                    # title, then skip to the end
			  .+=?\n\s*				     # dump the cruft
			  ([^;]+);\n\s*(.+=?)<br>\n\s*		     # get the author and type	
			  [^$currency_char]+			     # more cruft skipping
			  \Q$currency\E				     # tiny bit more
			  ([\d,]+\.\d+)                               # now get the price

			 !mxgi
	 	)
	{
		my %book;	
		@book{qw(asin title author type price)}  
		  = ($1, $2, $3, $4, $5);

		$book{price}  =~ s/,//g;
		$book{author} =~ s/\s*(by|~)\s+//; # get rid of cruft
		$book{type}   =~ s/<[^>]*>//g;

		push @books, \%book unless $seen{$book{'asin'}}++;

	}	

	return @books;
}


# legacy code, should never get called
# left in here Just In Case [tm]
sub extract_books_uk
{
	my $page = shift;
	

	
	my @books;
		
	while ($page =~ m!
			  <i><a\ href=/exec/obidos/ASIN/([^/]+)/[^>]+>
			  (.+=?)</a></i><br>\n\s*
			  .+=?\n\s*
			  (.+=?);\n\s*(.+=?)<br>\n\s*
			  [^&]+&pound;(\d+.\d+)
			  !mxgi
	 	)
	{
		
	

		my %book;	
		$book{'asin'}   = $1;
		$book{'title'}  = $2;
		$book{'author'} = $3;
		$book{'type'}   = $4;
		$book{'price'}  = $5;


		
		


		push @books, \%book;
		
		
	
	}	

	return @books;
}

1;
__END__
