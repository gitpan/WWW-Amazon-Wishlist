package WWW::Amazon::Wishlist;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $UK_TEMPLATE $US_TEMPLATE $OLD_US_TEMPLATE);
use LWP::UserAgent;
use Template::Extract;
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


$VERSION = '1.0';


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
		$book->{price},# how much it will set you back
      	$book->{type};    # Hardcover/Paperback/CD/DVD etc (not available in the US)
  
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

=head1 BUGS

It doesn't parse other fields from the wishlist such as number wanted, how long to ship and user comment.

It doesn't cope with anything apart from .co.uk and .com yet. Probably.

I don't think it likes unavailable items.

The code has accumulated lots of cruft.

Lack of testing. It works for the pages I've tried it for but that's no guarantee.

=head1 COPYING

Copyright (c) 2003 Simon Wistow

Distributed under the same terms as Perl itself.

This software is under no warranty and will probably destroy your wish list, kill your friends, burn your house and bring about the apocalypse


=head1 AUTHOR

Simon Wistow <simon@thegestalt.org>

=head1 SEE ALSO

L<perl>, L<LWP::UserAgent>, L<amazonwish>

=cut


my $USER_AGENT = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';



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


	# set up some variables
	my $page    = 1;
	my @items;

	my $obj      = Template::Extract->new();
	# see below for definitions of templates
	my $template = ($uk)? $UK_TEMPLATE : $US_TEMPLATE; 

	# and awaaaaaaaaaaaaay we go ....
	while (1)
	{

        # this should be explanatory also 
        my $url = ($uk) ? "http://www.amazon.co.uk/exec/obidos/wishlist/$id/?registry.page-number=$page" :
	    			      "http://www.amazon.com/gp/registry/registry.html/?id=$id&page=$page";


		my $content = _fetch_page($url, $domain);

		return undef unless ($content);
   

		my $result = $obj->extract($template, $content);

        last unless defined $result->{items};

		foreach my $item (@{$result->{items}}) 
		{
			$item->{'author'} =~ s!</span></b><br />\n*!!s;
			push @items, $item;
		}

		
		my ($next) = ($content =~  m!&page=(\d)+">Next!s);

 		# UK doens't seem to split up over pages
		# paranoia
        last unless defined $next;
		
		# more paranoia		
        last unless $next > $page;

		# and update
        $page    = $next;

	}


	return @items;
}


sub _fetch_page {
	my ($url, $domain) = @_;

	# setting up the UA here is slower but makes the code easier to read
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

}


$UK_TEMPLATE = <<'EOT';
[% ... %]
[%- FOREACH items -%]
<tr><td valign="top">[% ... %]
<a href=/exec/obidos/ASIN/[% asin %]/[% ... %]>
<img src="[% image %]" width=[% ... %] height=[% ... %] border=0 align=top></a>
[% ... %]
<i><a href=[% ... %]>[% name %]</a></i><br>[% ... %]
<font face=verdana,arial,helvetica size=-1>


[%- author -%];

[% type %]<br>[% ... %]</font>[% ... %]
&pound;[% price %]


[% ... %]
<b>Date added:</b> [% date %]<br>
[% ... %]
[%- END -%]</table>[% ... %]</form>
EOT


$US_TEMPLATE = <<'EOT'; 
<table border=0 cellpadding=0 cellspacing=0 width="100%">
[% ... %]
[%- FOREACH items -%] 
<td width=15 align=right class="small"><b>[% number %].</b><br />[% ... %]
<td width=65 align=center class="small"><img src="[% image %]" [% ... %]
<a href="/o/ASIN/[% asin %]/[% ... %]">[% title %]</a>[% ... %]
by [% author %]<br />

<span [% ... %]
Date Added: [% date %]<br />[% ... %]
<span style="color:#000000">Price:</span> [% price %]<br />[% ... %]
[%- END -%]</tr></table>
EOT


$OLD_US_TEMPLATE = <<'EOT'; 
&page=[% next_page %]">Next[% ... %]
<form method="post" action="/gp/registry/registry.html/[% ... %]?%5Fencoding=UTF8&id=[% ... %]">
<table border=0 cellpadding=0 cellspacing=0 width="100%">
[% ... %]
[%- FOREACH items -%] 
<td width=15 align=right class="small"><b>[% number %].</b><br />

</td>
<td width=1></td>
<td width=65 align=center class="small"><img src="[% image %]" [% ... %]
<a href="/o/ASIN/[% asin %]/[% ... %]">[% title %]</a>[% ... %]
by [% author %]<br />

<span>[% ... %]
Date Added: [% date %]<br />[% ... %]
<span style="color:#000000">Price:</span> [% price %]<br />[% ... %]
[%- END -%]</tr></table>
</form>
</td></tr>
<tr><td height="10"><img src="http://g-images.amazon.com/images/G/01/misc/transparent-pixel.gif" height="10" border="0" width="1" /
></td></tr>
<tr><td class="small">
EOT

1;


__END__
