#!/usr/bin/perl -w
#
#
#	After get working, try to remove "system" and "`" (backquote) calls
#		thus making the code strictly Perl and not dependent on 
#		any particular OS.
#
#


#
# Interpret CGI
#
use CGI;  # load CGI routines 
$q = new CGI;  # create new CGI object 

$ImagePath = $q->param('dir');
$ImageSize = $q->param('size');

$wwwroot='/export/home/apache/share/htdocs/lasco-www';
$ROOT='/export/home/apache/share/cgi-bin/MovieTool';

$MAX_FRAMES=50;	#	Why 50???
$speed=3;		#	frames/sec

$WIDTH=$ImageSize;
$HEIGHT=$ImageSize;


#	REPLACE ME
$NUM=`/bin/ls $ImagePath/*.gif \| /usr/bin/tee /tmp/jsmoviepl.$$ \| /usr/bin/wc -l`;

print $q->header('text/html');


#	FIX ME
if ( $NUM > $MAX_FRAMES ) 
{
#	$NUM=$MAX_FRAMES;
	#$NUM=`expr $MAX_FRAMES + 0`;
#	print that this many frames may be too much
}


if ( $NUM > 0 )
{
	open IN, "$ROOT/movie_header.js";
	while (<IN>) { print $_; }

	print "var imax=$NUM;\n";
	print "var iwidth=$WIDTH;\n";
	print "var iheight=$HEIGHT;\n";
	print "var speed=$speed;\n";

	open IN, "$ROOT/movie_body1.js";
	while (<IN>) { print $_; }

	$FRAME1=`/usr/bin/head -1 /tmp/jsmoviepl.$$`;
	$FRAME1 =~ s:$wwwroot:: ;

	print "<img src = \"$FRAME1\" NAME=animation ALT=\"FRAME\" width=$WIDTH height=$HEIGHT>";

	open IN, "$ROOT/movie_body2.js";
	while (<IN>) { print $_; }

	$i=0;
	open IN, "/tmp/jsmoviepl.$$";
	while (<IN>)
	{
		s:$wwwroot::;
		chomp;
		print "urls[$i]=\"$_\"\n";
		$i++;
	}

	open IN, "$ROOT/movie_footer.js";
	while (<IN>) { print $_; }

	print "<p>More LASCO information:<p>\n";
	print "<A HREF=\"http://lasco-www.nrl.navy.mil\" TARGET=\"_blank\">LASCO Home Page</A>\n";
	print "<A HREF=\"http://lasco-www.nrl.navy.mil/rtmovies.html\" TARGET=\"_blank\">LASCO Real Time Movie Page</A>\n";
	print "<hr>\n";
	print "Created by Jake Wendt, LASCO/SOHO team, Interferometrics/Naval Research Lab, Washington DC - May 2003<br>\n";
	print $q->end_html; # end the HTML

	$output=`/bin/rm /tmp/jsmoviepl.$$`;
}

exit;

#
#	cat equivalent function
#
#	open IN, $filename
#	while (<IN>) print $_;
#
#

