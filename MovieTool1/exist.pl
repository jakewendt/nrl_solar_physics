#!/usr/bin/perl -w
#
#$| = 1;#	this line locks up Dad's cable modem??????
#

#$DIR="/export/home/apache/share/htdocs/lasco-www/MovieTool";
#$DIR="/export/home/apache/share/htdocs/lasco-www/MovieTool";
$DIR="/net/louis14/data/ftp/pub/outgoing/movie";
#$WEB="http://lasco-www.nrl.navy.mil/MovieTool";
$WEB="ftp://louis14.nrl.navy.mil/pub/outgoing/movie/";
$TSIZE=256;

#
# Interpret CGI
#
use CGI;  # load CGI routines 
$q = new CGI;  # create new CGI object 

print $q->header('text/html'),
	$q->start_html('Make movie from existing images');

open IN, "< html/body1"
	or die "Could not open body1";
while (<IN>) { print $_; }

open IN, "< html/existform"
	or die "Could not open existform";
while (<IN>) { print $_; }

chdir $DIR
	or die "Couldn't chdir $DIR";

@Imagelist = `/bin/ls -1r */*.ppm`
	or die "Can't get list of ppm's";

foreach ( @Imagelist ) {
	chomp;
	@path = split /\//, $_;
	@nums = split /\./, $path[1];
	$rootname = $nums[0];
	print "<INPUT TYPE=checkbox name=image value=$path[0]/$rootname.ppm>\n";
	print "<a href=\"$WEB/$path[0].$TSIZE/$rootname.$TSIZE.gif\">\n$path[0]/$rootname.gif</a><br>\n";
} 

open IN, "< html/footer"
	or die "Could not open footer";
while (<IN>) { print $_; }

print $q->end_html; # end the HTML

close IN;
