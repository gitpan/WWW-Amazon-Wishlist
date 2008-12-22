package WWW::Amazon::Wishlist;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use LWP::UserAgent;
use Carp;

use constant COM => 0;
use constant UK  => 1;

require Exporter;

@ISA = qw(Exporter);
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


$VERSION = '1.501';  # By Martin Thurn 2008-12-21


=pod

=head1 NAME

WWW::Amazon::Wishlist - grab all the details from your Amazon wishlist

=head1 SYNOPSIS

  use WWW::Amazon::Wishlist qw(get_list COM UK);

  my @wishlist;

  @wishlist = get_list($my_amazon_com_id);       # gets it from amazon.com
  @wishlist = get_list($my_amazon_com_id,  COM); # same, explicitly
  @wishlist = get_list($my_amazon_couk_id, UK);  # gets it from amazon.co.uk

  # Or, if you didn't import the COM and UK constants:
  @wishlist = get_list ($my_amazon_couk_id, WWW::Amazon::Wishlist::UK);

  # The elements of @wishlist are hashrefs that contain the following elements:
  foreach my $book (@wishlist)
    {
    print $book->{title}, # the, err, title
    $book->{author},      # and the author(s) 
    $book->{asin},        # the asin number, its unique id on Amazon
    $book->{price},       # how much it will set you back
    $book->{quantity},    # how many you said you want
    $book->{priority},    # how urgently you said you want it (1-5)
    $book->{type};        # Hardcover/Paperback/CD/DVD etc (not available in the US)
    } # foreach

=head1 DESCRIPTION

Goes to amazon.(com|co.uk), scrapes your wishlist, and returns it
in a array of hashrefs so that you can fiddle with it to your heart's
content.

=head1 GETTING YOUR AMAZON ID

The best way to do this is to search for your own wishlist in the search
tools.

Searching for mine (simon@twoshortplanks.com) on amazon.com takes me to
the URL something like

   http://www.amazon.com/exec/obidos/wishlist/2EAJG83WS7YZM/...

there's some more cruft after that last string of numbers and letters
but it's the

   2EAJG83WS7YZM

bit that's important.

Doing the same for amazon.co.uk is just as easy.

Apparently, some people have had problems getting to their wishlist right
after it gets set up.  You may have to wait a while for it to become
browseable.

=head1 SHOWING YOUR APPRECIATION

There was a thread on london.pm mailing list about working in a vacuum -
that it was a bit depressing to keep writing modules but never get any
feedback.  So, if you use and like this module then please send me an
email and make my day.

All it takes is a few little bytes.


=head1 BUGS

B<IMPORTANT>

C<WWW::Amazon::Wishlist> is a screen scraper and is there for
is vulnerable to any changes that Amazon make to their HTML.

If it starts returning no items then this is very likely the reason
and I will get roudn to fixing it as soon as possible.

You might want to look at the C<Net::Amazon> module instead.

It doesn't cope with anything apart from the UK and USA versions of Amazon.

I don't think it likes unavailable items - trying to work around this
breaks UK compatability.

The code has accumulated lots of cruft.

Lack of testing.  It works for the pages I've tried it for but that's
no guarantee.

=head1 LICENSE

Copyright (c) 2003 Simon Wistow

Distributed under the same terms as Perl itself.

This software is under no warranty and will probably destroy your wish
list, kill your friends, burn your house and bring about the apocalypse

=head1 AUTHOR

Simon Wistow <simon@thegestalt.org>

=head1 SEE ALSO

L<perl>, L<LWP::UserAgent>, L<amazonwish>

=cut

my $USER_AGENT = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';

sub get_list
{
    my ($id, $uk, $test) = @_;

    # bad bad bad
    unless (defined $id)
    {
        croak "No ID given to get_list function\n";
        return undef;
    }

    # note to self ... should we UC the id? Nahhhh. Not yet.

    # default is amazon.com
    $uk |= 0;

    $test |= 0;

    # fairly self explanatory
    my $domain = ($uk)? "co.uk" : "com";


    # set up some variables
    my $page    = 1;
    my @items;

    # and awaaaaaaaaaaaaay we go ....
    while (1)
    {

        # this should be explanatory also 
        my $url = ($uk) ? "http://www.amazon.co.uk/exec/obidos/registry/$id/?registry.page-number=$page" :
                          "http://www.amazon.com/gp/registry/wishlist/$id";
        # This is a typical complete .com URL as of 2008-12:
        # http://www.amazon.com/gp/registry/wishlist/2O4B95NPM1W3L

        # print STDERR " DDD fetching wishlist for $id...\n";
        my $content = _fetch_page($url, $domain);

        if (0)
          {
          use File::Slurp;
          write_file('PAGES/fetched.html', $content);
          exit 88;
          } # if
        my $iLen = length($content);
        # print STDERR " DDD fetched $iLen bytes.\n";
        return undef unless ($content);

        # print STDERR " DDD call _extract()\n";
        my $result = _extract($uk, $content);

        #use Data::Dumper;
        #print Dumper($result);
        last unless defined $result && $result->{items};

 ITEM:
        foreach my $item (@{$result->{items}})
        {
            $item->{'author'} =~ s!\n!!g;
            $item->{'author'} =~ s!^\s*by\s+!!g;
            $item->{'author'} =~ s!</span></b><br />\n*!!s;
            $item->{'quantity'} = $1 if ($item->{'priority'} =~ m!Desired:\s*</b>\s*(\d+)!i);
            $item->{'priority'} = $1 if ($item->{'priority'} =~ m!Priority:\s*</b>\s*(\d)!i);
            if ($uk && $item->{image} !~ m!^http:!) {
                $item->{image} = "http://images-eu.amazon.com/images/P/".$item->{image};
            } # if

            push @items, $item;
        } # foreach ITEM

        my ($next) = ($content =~  m!&page=(\d)+">Next!s);

        # for debug purposes
        last if $test;

         # UK doesn't seem to split up over pages
        # paranoia
        last unless defined $next;

        # more paranoia
        last unless $next > $page;

        # and update
        $page    = $next;

    } # while


    return @items;
} # get_list


sub _fetch_page
  {
    my ($url, $domain) = @_;
    if (0)
      {
      # For debugging USA site:
      use File::Slurp;
      return read_file('Pages/2008-12.htm');
      } # if 0
    # Setting up the UA here is slower but makes the code easier to read
    # really, the slow bit will not be setting up the UA each time

    # set up the UA
    my $ua = new LWP::UserAgent( keep_alive => 1, timeout => 30, agent => $USER_AGENT, );

    # setting it in the 'new' seems not to work sometimes
    $ua->agent($USER_AGENT);
    # for some reason this makes stuff work
    $ua->max_redirect( 0 );


    # make a full set of headers
    my $h = new HTTP::Headers(
                'Host'            => "www.amazon.$domain",
                'Referer'         => $url,
                'User-Agent'      => $USER_AGENT,
                'Accept'          => 'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1',
                'Accept-Language' => 'en-us,en;q=0.5',
                'Accept-Charset'  => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
                #'Accept-Encoding' => 'gzip,deflate',
                'Keep-Alive'      =>  '300',
                'Connection'      =>  'keep-alive',
    );
    $h->referer("$url");



    my $request  =  HTTP::Request->new ( 'GET', $url, $h );
    my $response;

    my $times = 0;

    # LWP should be able to do this but seemingly fails sometimes
    while ($times++<3) {
        $response =  $ua->request($request);
        last if $response->is_success;
        if ($response->is_redirect) {
               $url = $response->header("Location");
            #$h->header("Referer", $url); 
            $h->referer("$url");
            $request  =  HTTP::Request->new ( 'GET', $url, $h );
        }
    }

    if (!$response->is_success)     {
        croak "Failed to retrieve $url";
        return undef;
    }

    return $response->content;

} # _fetch_page

use constant DEBUG_HTML => 0;

# This is the HTML parsing version written by Martin Thurn:

sub _extract
  {
  # Required arg1 = whether we are parsing the UK site or not (Boolean):
  my $iUK = shift;
  # Required arg2 = the HTML contents of the webpage:
  my $s = shift || '';
  DEBUG_HTML && print STDERR " DDD start _extract()\n";
  my $rh;
  use HTML::TreeBuilder;
  my $oTree = new HTML::TreeBuilder;
  $oTree->parse($s);
  $oTree->eof;
  my @aoSPAN = $oTree->look_down(_tag => 'span',
                                 class => 'small',
                                );
 SPAN_TAG:
  foreach my $oSPAN (@aoSPAN)
    {
    next SPAN_TAG unless ref $oSPAN;
    DEBUG_HTML && print STDERR " DDD found TD...\n";
    my $oA = $oSPAN->look_down(_tag => 'a');
    next SPAN_TAG unless ref $oA;
    DEBUG_HTML && print STDERR " DDD   found A...\n";
    my $sTitle = $oA->as_text;
    # Strip leading whitespace:
    $sTitle =~ s!\A\s+!!;
    # Strip trailing whitespace:
    $sTitle =~ s!\s+\Z!!;
    next SPAN_TAG unless ($sTitle =~ m!\S!);
    DEBUG_HTML && print STDERR " DDD found item named '$sTitle'\n";
    my $sURL = $oA->attr('href');
    DEBUG_HTML && print STDERR " DDD   URL ==$sURL==\n";
    my $sASIN = '';
    if (
        ($sURL =~ m!/detail(?:/offer-listing)?/-/(.+?)/ref!)
        ||
        ($sURL =~ m!/gp/product/(.+?)/ref!)
        ||
        ($sURL =~ m!/dp/(.+?)/ref!)
       )
      {
      $sASIN = $1;
      } # if
    else
      {
      DEBUG_HTML && print STDERR " EEE   url does not contain asin\n";
      }
    DEBUG_HTML && print STDERR " DDD   ASIN ==$sASIN==\n";
    # Grab the smallest-containing ancestor of this item:
    my $oTable = $oSPAN->look_up(_tag => 'table');
    if (! ref $oTable)
      {
      DEBUG_HTML && print STDERR " WWW did not find ancestor table\n";
      next SPAN_TAG;
      } # if
    my $sTable = $oTable->as_text;
    # DEBUG_HTML && print STDERR " DDD   child sTable ==$sTable==\n";
    my $oParent = $oTable->look_up(_tag => 'tr');
    if (! ref $oParent)
      {
      DEBUG_HTML && print STDERR " WWW did not find ancestor TR\n";
      next SPAN_TAG;
      } # if
    my $sParent = $oParent->as_text;
    my $sParentHTML = $oParent->as_HTML;
    print STDERR " DDD   parent TR HTML ==$sParentHTML==\n" if (4 < DEBUG_HTML);
    print STDERR " DDD   parent TR ==$sParent==\n" if (4 < DEBUG_HTML);
    # Find the quantity desired, and the priority.  These are the defaults:
    my $iDesired = 1;
    my $sPriority = 'medium';
    my @aoSPAN = $oParent->look_down(_tag => 'span',
                                     class => 'wl-iter-heading',
                                    );
 SPAN_TAG:
    foreach my $oSPAN (@aoSPAN)
      {
      next SPAN_TAG unless ref $oSPAN;
      if ($oSPAN->as_text =~ m'DESIRED\s+(/d+)'i)
        {
        $iDesired = $1;
        } # if
      if ($oSPAN->as_text =~ m'PRIORITY\s+(/d+)'i)
        {
        $sPriority = $1;
        } # if
      } # foreach SPAN_TAG
    if (! $iDesired || ! $sPriority)
      {
      # See if they are encoded in a FORM:
      # Find the priority:
      if ($sParentHTML =~ m!<option selected="yes" value=([-0-9]+)>!)
        {
        $sPriority = $1;
        DEBUG_HTML && print STDERR " DDD   priority=$sPriority=\n";
        } # if
      else
        {
        DEBUG_HTML && print STDERR " WWW   did not find <option> for priority\n";
        }
      # Find the quantity desired:
      if ($sParentHTML =~ m!<input class="tiny" name="requestedQty.+?" size=\d+ type="text" value=(\d+)>!)
        {
        $iDesired = $1;
        DEBUG_HTML && print STDERR " DDD   desired=$iDesired=\n";
        } # if
      else
        {
        DEBUG_HTML && print STDERR " WWW   did not find <input> for desired-quantity\n";
        }
      } # if
    # Find the date added:
    my $sDate = '';
    if ($sParentHTML =~ m!>added\s+(.+?)<!)
      {
      $sDate = $1;
      DEBUG_HTML && print STDERR " DDD   date=$sDate=\n";
      } # if
    else
      {
      DEBUG_HTML && print STDERR " WWW   did not find text for date-added\n";
      }

    # Find the "author" of this item:
    my @aoTD = $oTable->look_down(_tag => 'td',
                                  class => 'small',
                                 );
    my $sAuthor = '';
 TD_TAG:
    foreach my $oTD (@aoTD)
      {
      next TD_TAG unless ref $oTD;
      $s = $oTD->as_text;
      if ($s =~ s!\A\s*by\s+!!)
        {
        $sAuthor = $s;
        last TD_TAG;
        } # if
      } # foreach TD_TAG
    DEBUG_HTML && print STDERR " DDD   author=$sAuthor=\n";
    # Find the price of this item:
    my $sPrice = '';
    my $oTDprice = $oTable->look_down(_tag => 'span',
                                      class => 'price',
                                     );
    if (! ref $oTDprice)
      {
      DEBUG_HTML && print STDERR " WWW did not find TD for price\n";
      next SPAN_TAG;
      } # if
    my $sTD = $oTDprice->as_text;
    # DEBUG_HTML && print STDERR " DDD   sTD==$sTD==\n";
    if ($sTD =~ m!Price:\s+(.+)\Z!)
      {
      $sPrice = $1;
      DEBUG_HTML && print STDERR " DDD   price=$sPrice=\n";
      } # if
    # Add this item to the result set:
    my %hsItem = (
                  asin => $sASIN,
                  author => $sAuthor,
                  # image => $sImageURL,
                  price => $sPrice,
                  priority => $sPriority,
                  quantity => $iDesired,
                  title => $sTitle,
                  # type => $sType,
                 );
    push @{$rh->{items}}, \%hsItem;
    # All done with this item:
    $oTable->detach;
    $oTable->delete;
    } # foreach SPAN_TAG
  return $rh;
  } # _extract

1;


__END__
