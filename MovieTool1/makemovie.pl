#!/usr/bin/perl -w
$| = 1;
#
#


$wwwroot="/export/home/apache/share/htdocs/lasco-www";
#$OUTROOT="$wwwroot/MovieTool";
$ROOT="/export/home/apache/share/cgi-bin/MovieTool";
$FTPDIR="/net/louis14/data/ftp/pub/outgoing/movie";
$OUTROOT="$FTPDIR";
$FTPURL="ftp://louis14.nrl.navy.mil/pub/outgoing/movie";
$WWWURL="http://lasco-www.nrl.navy.mil/cgi-bin/MovieTool";
 
my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime;
$DATE = sprintf ( "%4d%02d%02d%s%02d%02d%02d", $year+1900, $mon+1, $day, '.', $hour, $min, $sec );
$WHIRLGIF="$ROOT/bin/whirlgif";
$PNMSCALE="$ROOT/bin/pnmscale -xysize ";
$TOGIF="$ROOT/bin/ppmtogif ";
$TOPNG="$ROOT/bin/pnmtopng ";
$TOJPG="$ROOT/bin/cjpeg -quality 90 ";



#
# Interpret CGI
#

use File::Copy;
use CGI;  # load CGI routines 
$q = new CGI;  # create new CGI object 
print $q->header('text/html');

@Imagelist = $q->param('image');				#	read params into array
$OUTSIZE = $q->param('outsize');
$OUTTYPE = $q->param('outtype');
$DID = "$DATE.$$";
$OUTDIR="$OUTROOT/$DID.$OUTSIZE";


mkdir "$OUTDIR", 0755
	or die "Cannot create $OUTDIR : $!";
chdir "$OUTROOT"
	or die "Cannot chdir $OUTROOT : $!";




#	CASE statement for final image format
if ( $OUTTYPE eq "JS" || $OUTTYPE eq "JAVA" || $OUTTYPE eq "AGIF" || $OUTTYPE eq "AGIFL" || $OUTTYPE eq "MPG1" || $OUTTYPE eq "GIF" ) {
	$FINAL = $TOGIF;
	$EXT = "gif";
} elsif ( $OUTTYPE eq "PNG" || $OUTTYPE eq "MNG" ) {
	$FINAL = $TOPNG;
	$EXT = "png";
} else {		#	Assuming $OUTTYPE eq "JPG" 
	$FINAL = $TOJPG;
	$EXT = "jpg";
}








foreach ( @Imagelist ) {
	@path = split /\//, $_;
	@nums = split /\./, $path[1];
	$rootname = $nums[0];

	#	convert PPM to resized GIF (for now) and put in $OUTDIR

#	!system ( "$PNMSCALE $OUTSIZE $OUTSIZE $_ | $TOGIF > $OUTDIR/$rootname.$OUTSIZE.gif")
	!system ( "$PNMSCALE $OUTSIZE $OUTSIZE $_ | $FINAL > $OUTDIR/$rootname.$OUTSIZE.$EXT")
		or die "Resize and conversion failed.";
} 


if ( $OUTTYPE eq "JS" ) {
	print "<BODY OnLoad=javascript:window.open('http://lasco-www.nrl.navy.mil/cgi-bin/MovieTool/jsmovie.pl\?dir=$OUTDIR\&size=$OUTSIZE');>\n";
} elsif ( $OUTTYPE eq "JAVA" ) {
	print "<BODY OnLoad=javascript:window.open('http://lasco-www.nrl.navy.mil/cgi-bin/MovieTool/jmeasure.pl\?dir=$OUTDIR\&size=$OUTSIZE');>\n";
} elsif ( $OUTTYPE eq "AGIF" || $OUTTYPE eq "AGIFL" ) {
	print "<BODY OnLoad=javascript:window.open('$FTPURL/$DID.gif');>\n";
} elsif ( $OUTTYPE eq "MPG1" ) {
	print "<BODY OnLoad=javascript:window.open('$FTPURL/$DID.mpg');>\n";
} elsif ( $OUTTYPE eq "MNG" ) {
	print "<BODY OnLoad=javascript:window.open('$FTPURL/$DID.mng');>\n";
} else  {
	print "<BODY>\n";
}


#
chdir "$OUTROOT"
	or die "Cannot chdir $OUTROOT : $!";
print "<PRE>\n"; 
!system ("tar", "cvf", "$FTPDIR/$DID.tar", "$DID.$OUTSIZE" )
	or die "Cannot tar files";

!system ("/usr/bin/gzip", "-v9", "$FTPDIR/$DID.tar")
	or die "Cannot gzip files";

print "</PRE>\n"; 
print "<br><br>\n";
print "<a href=\"$FTPURL/$DID.tar.gz\">\n";
print "Your images are TAR'd and GZIP'd and ready for pickup.\n";
print "</a><BR><BR>\n";




#
#       Convert to final data format
#
chdir "$OUTDIR"
	or die "Cannot chdir $OUTDIR : $!";

if ( $OUTTYPE eq "MPG1" ) {
	print "<PRE>\n";
	!system ( "$ROOT/bin/makempeg.sh", "$FTPDIR/$DID.mpg", "$OUTDIR" )
		or die "Could not make MPEG !?!?";
	print "</PRE>\n";
	#	$ROOT/bin/sendemail.sh $DID.mpg jakewendt@nrl.navy.mil`;
	#	/usr/bin/gzip -v9 $FTPDIR/$DID.mpg`;
	$MSG="$FTPURL/$DID.mpg";
} elsif ( $OUTTYPE eq "AGIF" ) {
	# for some reason this command fails if broken up like some say you should
	!system ("$WHIRLGIF -o $FTPDIR/$DID.gif -loop 1 -time 5 *.gif")
		or die "Could not run Whirlgif !?!?";
	#	`$WHIRLGIF -o $FTPDIR/$DID.gif -loop 1 -time 5 *.gif`;
	#	!system ("$WHIRLGIF", "-o $FTPDIR/$DID.gif", "-loop 1", "-time 5", "*.gif" )
	$MSG="$FTPURL/$DID.gif";
	#	$ROOT/bin/sendemail.sh $FTPURL/$DID.gif jakewendt@nrl.navy.mil`;
} elsif ( $OUTTYPE eq "AGIFL" ) {
	!system ("$WHIRLGIF -o $FTPDIR/$DID.gif -loop -time 5 *.gif")
		or die "Could not run Whirlgif !?!?";
	$MSG="$FTPURL/$DID.gif";
	#	$ROOT/bin/sendemail.sh $DID.gif jakewendt@nrl.navy.mil`;
} elsif ( $OUTTYPE eq "JS" ) {
	$MSG="$WWWURL/jsmovie.pl\?dir=$OUTDIR\&size=$OUTSIZE";
} elsif ( $OUTTYPE eq "JAVA" ) {
	$MSG="$WWWURL/jmeasure.pl\?dir=$OUTDIR\&size=$OUTSIZE";
} elsif ( $OUTTYPE eq "MNG" ) {
	$PNGSIZE=`$ROOT/bin/pngsize $OUTDIR/$rootname.$OUTSIZE.png`;
	#
	#	system command won't work correctly
	#	this seems to work, but I'd imagine there is a size
	#	limit on Perl variables and a big MNG might not work
	#
	$nothing=`$ROOT/bin/png2mng.pl $OUTDIR $PNGSIZE`;
	open OUT, "> $FTPDIR/$DID.mng";
	print OUT $nothing;
	close (OUT);
	#!system ("$ROOT/bin/png2mng.pl $OUTDIR $PNGSIZE > $FTPDIR/$DID.mng")
	#	or die "Could not run png2mng";
	$MSG="$FTPURL/$DID.mng";
}



print "<a href=$MSG>Product ready for pickup and viewing</a><BR>\n";

print $q->end_html; # end the HTML



#sub by_image_date {
#	@aa = split /\//, $a;
#	@bb = split /\//, $b;
#	$aa[-1] cmp $bb[-1];
#}


