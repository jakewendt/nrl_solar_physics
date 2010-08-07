#!/usr/bin/perl -w
$| = 1;
#
#


$wwwroot="/export/home/apache/share/htdocs/lasco-www";
$OUTROOT="$wwwroot/MovieTool";
$ROOT="/export/home/apache/share/cgi-bin/MovieTool";
$FTPDIR="/net/louis14/data/ftp/pub/outgoing/movie/";
$FTPURL="ftp://louis14.nrl.navy.mil/pub/outgoing/movie/";
$WWWURL="http://lasco-www.nrl.navy.mil/cgi-bin/MovieTool";
 
my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime;
$DATE = sprintf ( "%4d%02d%02d%s%02d%02d%02d", $year+1900, $mon+1, $day, '.', $hour, $min, $sec );
$OUTDIR="$OUTROOT/$DATE.$$";
$WHIRLGIF="$ROOT/bin/whirlgif";


#
# Interpret CGI
#

use File::Copy;
use CGI;  # load CGI routines 
$q = new CGI;  # create new CGI object 
print $q->header('text/html');

@Imagelist = $q->param('image');				#	read params into array


mkdir "$OUTDIR", 0755
	or die "Cannot create $OUTDIR : $!";
chdir "$OUTROOT"
	or die "Cannot chdir $OUTROOT : $!";

foreach ( @Imagelist ) {
	copy ( $_,  "$OUTDIR" )
		or die "Can't copy $_ to $OUTDIR : $!";
} 








#	HOW TO FIND SIZE OF GIF???????
$OUTSIZE="512";










$OUTTYPE = $q->param('outtype');				#	read param

if ( $OUTTYPE eq "JS" ) {
	print "<BODY OnLoad=javascript:window.open('http://lasco-www.nrl.navy.mil/cgi-bin/MovieTool/jsmovie.pl\?dir=$OUTDIR\&size=$OUTSIZE');>\n";
} elsif ( $OUTTYPE eq "JAVA" ) {
	print "<BODY OnLoad=javascript:window.open('http://lasco-www.nrl.navy.mil/cgi-bin/MovieTool/jmeasure.pl\?dir=$OUTDIR\&size=$OUTSIZE');>\n";
} elsif ( $OUTTYPE eq "AGIF" || $OUTTYPE eq "AGIFL" ) {
	print "<BODY OnLoad=javascript:window.open('$FTPURL/$DATE.$$.gif');>\n";
} elsif ( $OUTTYPE eq "MPG1" ) {
	print "<BODY OnLoad=javascript:window.open('$FTPURL/$DATE.$$.mpg');>\n";
} else  {
	print "<BODY>\n";
}


#
chdir "$OUTROOT"
	or die "Cannot chdir $OUTDIR : $!";
print "<PRE>\n"; 
!system ("tar", "cvf", "$FTPDIR/$DATE.$$.tar", "$DATE.$$" )
	or die "Cannot tar files";

!system ("/usr/bin/gzip", "-v9", "$FTPDIR/$DATE.$$.tar")
	or die "Cannot gzip files";

print "</PRE>\n"; 
print "<br><br>\n";
print "<a href=\"$FTPURL/$DATE.$$.tar.gz\">\n";
print "Your images are TAR'd and GZIP'd and ready for pickup.\n";
print "</a><BR><BR>\n";




#
#       Convert to final data format
#
chdir "$OUTDIR"
	or die "Cannot chdir $OUTDIR : $!";

if ( $OUTTYPE eq "MPG1" ) {
	print "<PRE>\n";
	!system ( "$ROOT/bin/makempeg.sh", "$FTPDIR/$DATE.$$.mpg", "$OUTDIR" )
		or die "Could not make MPEG !?!?";
	print "</PRE>\n";
#               $ROOT/bin/sendemail.sh $DATE.$$.mpg jakewendt@nrl.navy.mil`;
#               /usr/bin/gzip -v9 $FTPDIR/$DATE.$$.mpg`;
	$MSG="$FTPURL/$DATE.$$.mpg";
} elsif ( $OUTTYPE eq "AGIF" ) {
	# for some reason this command fails if broken up like some say you should
	!system ("$WHIRLGIF -o $FTPDIR/$DATE.$$.gif -loop 1 -time 5 *.gif")
		or die "Could not run Whirlgif !?!?";
#	`$WHIRLGIF -o $FTPDIR/$DATE.$$.gif -loop 1 -time 5 *.gif`;
#	!system ("$WHIRLGIF", "-o $FTPDIR/$DATE.$$.gif", "-loop 1", "-time 5", "*.gif" )
	$MSG="$FTPURL/$DATE.$$.gif";
#               $ROOT/bin/sendemail.sh $FTPURL/$DATE.$$.gif jakewendt@nrl.navy.mil`;
} elsif ( $OUTTYPE eq "AGIFL" ) {
	!system ("$WHIRLGIF -o $FTPDIR/$DATE.$$.gif -loop -time 5 *.gif")
		or die "Could not run Whirlgif !?!?";
	$MSG="$FTPURL/$DATE.$$.gif";
#               $ROOT/bin/sendemail.sh $DATE.$$.gif jakewendt@nrl.navy.mil`;
} elsif ( $OUTTYPE eq "JS" ) {
	$MSG="$WWWURL/jsmovie.pl\?dir=$OUTDIR\&size=$OUTSIZE";
} elsif ( $OUTTYPE eq "JAVA" ) {
	$MSG="$WWWURL/jmeasure.pl\?dir=$OUTDIR\&size=$OUTSIZE";
}


print "<a href=$MSG>Product ready for pickup and viewing</a><BR>\n";

print $q->end_html; # end the HTML



sub by_image_date {
	@aa = split /\//, $a;
	@bb = split /\//, $b;
	$aa[-1] cmp $bb[-1];
}


