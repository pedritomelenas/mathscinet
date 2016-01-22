#!/usr/bin/perl -w

# mathscinet.PL - automates getting bibtex references from MathSciNet
#
# Author:       Michael Tweedale <m.tweedale@bristol.ac.uk>
# Version:      0.1
# Licence:      GPL

use LWP::UserAgent;
use URI::URL;
use URI::Escape;
use Getopt::Long;

$VERSION='0.1';
$curbox=4; # MathSciNet form has boxes for search terms numbered 4...7
$search="";
$ua=new LWP::UserAgent;
$hdrs=new HTTP::Headers(Accept => 'text/html',
  User_Agent => "mathscinet.PL $VERSION");

sub version()
{
  print STDERR << "EOF";
mathscinet $VERSION
This is free software. You may redistribute copies of it under the terms of
the GNU General Public License <http://www.gnu.org/licenses/gpl.html>.
There is NO WARRANTY, to the extent permitted by law.

Written by Michael Tweedale <m.tweedale\@bristol.ac.uk>.
EOF
}

sub usage()
{
  print STDERR << "EOF";
Usage: $0 SEARCH...
Gets references from MathSciNet in bibtex format.

-i, --authorid MR author ID
-t, --title    phrase from the title of the article or book
-a, --author   name of one of the authors
-j, --journal  journal the article appeared in
-s, --series   series the book appeared in
-m, --MR       Math Reviews number
    --help     display this help and exit
    --version  output version information and exit

Example 1: $0 -t "free+groups" -t trees -a bestvina
Example 2: $0 -a serre -j annals
Example 3: $0 -a brown -s "graduate+texts"
EOF
}

sub addterm($$)
{
  $curbox<=7 || die("cannot use more than 4 search terms");
  $search .= "&pg$curbox=" . uri_escape($_[0]) . "&s$curbox="
  . uri_escape($_[1]) . "&co$curbox=AND";
  $curbox++;
}

GetOptions('title|t=s' => sub { addterm("TI",$_[1]); },
  'author|a=s' => sub { addterm("AUCN",$_[1]); },
  'authorid|i=s' => sub { addterm("INDI",$_[1]); },
  'journal|j=s' => sub { addterm("JOUR",$_[1]); },
  'series|s=s' => sub { addterm("SE",$_[1]); },
  'MR|m=s' => sub { addterm("MR",$_[1]); },
  'help|h' => sub { usage(); exit 0; },
  'version|v' => sub { version(); exit 0; });

$search ne "" || usage() && die("no search terms found");
$url=new URI::URL(
    "http://www.ams.org/mathscinet/search/publications.html?fmt=bibtex$search" . "&r=1&extend=1");
$req=new HTTP::Request(GET, $url, $hdrs);
$resp=$ua->request($req);

$resp->is_success ||
  print STDERR $resp->message . "\n" &&
  die("failed to get search results from MathSciNet");
$resp->as_string =~ /No publications results/ &&
  die("no results for this search");

map {
  print $_, (( $_=~ '^}') ? "\n\n" : "\n")
    if ((/^\s*<pre>/ .. /^\s*<\/pre>/) && ! m{^\s*</?pre>})
} split "\n", $resp->as_string;
