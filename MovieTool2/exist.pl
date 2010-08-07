#!/usr/bin/perl -w
#
#$| = 1;#	this line locks up Dad's cable modem??????
#
#

$DIR="/export/home/apache/share/htdocs/lasco-www/MovieTool";
$WEB="http://lasco-www.nrl.navy.mil/MovieTool";

#
# Interpret CGI
#
use CGI;  # load CGI routines 
$q = new CGI;  # create new CGI object 

print $q->header('text/html'),
	$q->start_html('Make movie from existing gifs');

open IN, "< html/body1"
	or die "Could not open body1";
while (<IN>) { print $_; }

open IN, "< html/existform"
	or die "Could not open existform";
while (<IN>) { print $_; }

chdir $DIR
	or die "Couldn't chdir $DIR";

@Imagelist = `/bin/ls -1r */*.gif`
	or die "Can't get list of gifs";

foreach ( @Imagelist ) {
	chomp;
	print "<INPUT TYPE=checkbox name=image value=$_>\n";
	print "<a href=\"$WEB/$_\">\n$_</a><br>\n";
} 

open IN, "< html/footer"
	or die "Could not open footer";
while (<IN>) { print $_; }

print $q->end_html; # end the HTML

