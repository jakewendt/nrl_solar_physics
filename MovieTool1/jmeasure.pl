#!/usr/bin/perl -w
#
#	Created: 13 May 1999 - D. Wang
#
#	030529 - jake - converted to Perl
#
#

#
# Interpret CGI
#
use CGI;  # load CGI routines 
$q = new CGI;  # create new CGI object 

print $q->header('text/html');

$ImagePath = $q->param('dir');
$ImageSize = $q->param('size');

$codebase='../../java';

#$wwwroot='/export/home/apache/share/htdocs/lasco-www';
$wwwroot='/net/louis14/data/ftp/pub/outgoing/movie';

#$urlroot='http://lasco-www.nrl.navy.mil';
$urlroot='ftp://louis14.nrl.navy.mil/pub/outgoing/movie';

$MAX_FRAMES=25;

$WIDTH=$ImageSize;
$HEIGHT=$ImageSize+35;


#	REPLACE ME
$NUM=`/bin/ls $ImagePath/*.gif \| /usr/bin/tee /tmp/jmoviepl.$$ \| /usr/bin/wc -l`;
$NUM=$NUM+0;



if ( $NUM > $MAX_FRAMES ) 
{
	$NUM=$MAX_FRAMES;

#	don't reset number, just let user know this may be too many
}



if ( $NUM > 0 )
{
	print "<center>\n";
	print "<applet codebase=$codebase code=MeasureImg.class width=$WIDTH height=$HEIGHT>\n";
	print "<param name=NumImages value=$NUM>\n";
	print "<param name=AutoPlay value=true>\n";
	print "<param name=Controls value=true>\n";

	#	# inputs for java_movie2.cgi
	#print "<param name=file_type value=gif>\n";
	#print "<param name=type_code value=eit_304>\n";
	#print "<param name=jumptoURL value=$urlroot>\n";


	$i=1;
	open IN, "/tmp/jmoviepl.$$";
	while (<IN>)
	{
		s:$wwwroot:$urlroot:;
		chomp;
		print "<param name=Image$i value=$_>\n";
		$i++;
	}

	print "<param name=DelayBetweenImages value=200>\n";

	print "</applet>\n";
	print "</center>\n";
	print "<p>\n";
	print "<h1>How To Measure Positions</h1>
		<p>
		a) For Netscape, open the Java Console (Communicator | Tools | Java Console).  
		For Internet Explorer go to (Internet Options | Advanced | Java Console) and 
		check the Java Console Enabled box under Microsoft VM, restart IE and click 
		(View | Java Console).
		<p>
		b) You will need to load the movie with the controls Enabled.  After the images
		load PAUSE the movie when you see a object or structure you want to measure.  
		Left click the position. You will see the position appear in the Java Console 
		window.
		<p>
		c) If you make a mistake, press SHIFT and left click anywhere on the image to 
		delete the last point.
		<p>
		d) Go on to the next frame, by pressing Next.  Left click to add the next point.
		<p>
		e) Repeat step d) for each frame until you have all the points you want. 
		Press 'G' with the cursor in the image to see the height-time fit.  
		The best linear fit is displayed in the Java Console window (km/s for the 
		velocity and km for the intercept).
		<p>
		f) This applet has been tested with Netscape 4.x and IE 5.  
		";
	print "<p>";
	print "<hr>";
	print "More LASCO information:<p>";
	print "<A HREF=\"http://lasco-www.nrl.navy.mil\" TARGET=\"_blank\">LASCO Home Page</A>";
	print "<A HREF=\"http://lasco-www.nrl.navy.mil/rtmovies.html\" TARGET=\"_blank\">LASCO Real Time Movie Page</A>";
	print "<hr>";
	print "Created by Dennis Wang (Java and WWW Programming) & Nathan Rich (Data Reduction and Archiving), LASCO/SOHO team, Interferometrics/Naval Research Lab, Washington DC<br>";
	print "Editted by Jake Wendt, LASCO/SOHO team, Interferometrics/Naval Research Lab, Washington DC<br>";

     print $q->end_html; # end the HTML

     $output=`/bin/rm /tmp/jmoviepl.$$`;
}

