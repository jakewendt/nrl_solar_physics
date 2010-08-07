#!/bin/sh
#
#	make_images.sh
#
#	born May 2003
#	by Jake
#
#	Needs access to the following to work
#	-	Perl (for some pages)
#	-	gawk (for long strings)
#	-	PBMTools (to do image conversions)
#			www.acme.com/software/pbmplus
#	-	cjpeg/djpeg (to convert to jpeg)
#			????
#	-	cfitsio (search google)
#			modhead (to read fits headers)
#			imagearith (to reduce fits)
#			constarith
#			imagemedian
#			pruneimage
#			tofitsbp16
#	-	mpeg_encode 
#			UC Berkeley
#	-	whirlgif
#	-	jexpr (Floating point expressions)
#
#
#

echo Content-type: text/html
echo

###############################################################
#	DIRS
#LASCODIR=/export/home/apache/share/htdocs/lasco-www
CGIBIN=/export/home/apache/share/cgi-bin
ROOT=$CGIBIN/MovieTool
BIN=$ROOT/bin
OUTROOT=/export/home/apache/share/htdocs/lasco-www/MovieTool
DATE=`/usr/bin/date +%Y%m%d.%H%M%S`
OUTDIR=$OUTROOT/$DATE.$$
FTPDIR=/net/louis14/data/ftp/pub/outgoing/movie/
FTPURL=ftp://louis14.nrl.navy.mil/pub/outgoing/movie/

#	COMMANDS
GAWK=$BIN/gawk
FITSTOPGM=$BIN/fitstopgm
PNMFLIP="$BIN/pnmflip -tb "
PNMSCALE="$BIN/pnmscale -xysize "
PPMTOGIF="$BIN/ppmtogif "
MPEGENC=$BIN/mpeg_encode
WHIRLGIF=$BIN/whirlgif
GetValue="$BIN/modhead "

mkdir $OUTDIR

read form_args
#echo $form_args > /tmp/jake

NUMARGS=`echo $form_args | $GAWK -F\& '{print NF}'`

#
#	all values from checkboxes must be set to default values
#	because if they are not checked, no value is passed in argument string
#
EMAIL=`echo $form_args | $GAWK -F\& '{for (i=1;i<=NF;i++) { split($i, a, "="); if ( a[1] == "email" ) { print a[2]; next }}}'`
LEVEL=`echo $form_args | $GAWK -F\& '{for (i=1;i<=NF;i++) { split($i, a, "="); if ( a[1] == "level" ) { print a[2]; next }}}'`
OUTSIZE=`echo $form_args | $GAWK -F\& '{for (i=1;i<=NF;i++) { split($i, a, "="); if ( a[1] == "outsize" ) { print a[2]; next }}}'`
OUTTYPE=`echo $form_args | $GAWK -F\& '{for (i=1;i<=NF;i++) { split($i, a, "="); if ( a[1] == "outtype" ) { print a[2]; next }}}'`
MAXIMUM=`echo $form_args | $GAWK -F\& '{for (i=1;i<=NF;i++) { split($i, a, "="); if ( a[1] == "maximum" ) { print a[2]; next }}}' | $BIN/sed s/%2B/+/g`
MINIMUM=`echo $form_args | $GAWK -F\& '{for (i=1;i<=NF;i++) { split($i, a, "="); if ( a[1] == "minimum" ) { print a[2]; next }}}' | $BIN/sed s/%2B/+/g`
COLORTABLE=`echo $form_args | $GAWK -F\& '{for (i=1;i<=NF;i++) { split($i, a, "="); if ( a[1] == "colortable" ) { print a[2]; next }}}'`
IMGTYPE=`echo $form_args | $GAWK -F\& '{for (i=1;i<=NF;i++) { split($i, a, "="); if ( a[1] == "imgtype" ) { print a[2]; next }}}'`
FILELIST=`echo $form_args | $GAWK -F\& '{for (i=1;i<=NF;i++) { split($i, a, "="); if ( a[1] == "ffile" ) { print a[2] }}}' | /usr/bin/sed 's:%2F:/:g'` 



cat $ROOT/html1

case $OUTTYPE in
	JS) echo "<BODY OnLoad=Start('http://lasco-www.nrl.navy.mil/cgi-bin/MovieTool/jsmovie.pl\?dir=$OUTDIR\&size=$OUTSIZE');>"
	;;
	JAVA) echo "<BODY OnLoad=Start('http://lasco-www.nrl.navy.mil/cgi-bin/MovieTool/jmeasure.pl\?dir=$OUTDIR\&size=$OUTSIZE');>"
	;;
	AGIF|AGIFL) echo "<BODY OnLoad=Start('$FTPURL/$DATE.$$.gif');>"
	;;
	*) echo "<BODY>\n"
	;;
esac

for each in $FILELIST
do
	OK="OK"
	DATE_OBS=`$GetValue $each DATE-OBS`
	TIME_OBS=`$GetValue $each TIME-OBS`
	DETECTOR=`$GetValue $each DETECTOR`
	READPORT=`$GetValue $each READPORT`

	DATEOBS=`echo $DATE_OBS | $GAWK -F\' '{print $2}' | $GAWK -F\/ 'BEGIN{OFS=""} {print $1,$2,$3}'`
	TIMEOBS=`echo $TIME_OBS | $GAWK -F\' '{print $2}' | $GAWK -F\: 'BEGIN{OFS=""} {print $1,$2}'`
	CAMERA=`echo $DETECTOR | $GAWK -F\' '{print $2}' | $GAWK '{print $1}'`	# LAST GAWK REMOVES TRAILING SPACES
	PORT=`echo $READPORT | $GAWK -F\' '{print $2}' | $GAWK '{print $1}'`

	if [ $CAMERA = "EIT" -a $OUTTYPE = "JAVA" ] 
	then
		#
		#	This naming convention is ONLY for the MeasureImage/Julian java movie
		#
		#	FIX IT
		#
		outroot=$DATEOBS"_"$TIMEOBS"_XX"	#$CAMERA"_XXX"
	else
		outroot=$DATEOBS"_"$TIMEOBS"_"$CAMERA
	fi

	echo "<br>\nProcessing ... $each ( $outroot )<br>\n"

	#	DO NOT USE $each PAST THIS POINT
	tempfits=$each

	/bin/rm /tmp/temp??.$$.fits


	if [ $LEVEL = "10" -a $CAMERA != "EIT" ]
	then
		CAMNUM=`echo $CAMERA | /usr/bin/cut -c 2`






#
#
#
#
#
#	VERY IMPORTANT NOTE.
#	IMAGES MUST BE THE SAME SIZE IN ORDER FOR OPERATIONS TO WORK 
#
#
#
#	probably want to crop out middle and trim edges early on too
#
#
#
#
#











		#
		#	find current BIAS 
		#
		BIAS=`$ROOT/offset_bias.sh $CAMERA $DATEOBS $PORT`





#	Does exposure time effect this value? (I don't think so)
#	Does binning, framing, resizing, ... effect this?  (I think so)





		#
		#	subtract offset BIAS
		#	$BIN/imarith $tmpfits $bias sub __________
		#
		echo "Subtracting bias value of $BIAS. <br>\n"
		$BIN/constarith $tempfits - $BIAS /tmp/temp08.$$.fits
		tempfits="/tmp/temp08.$$.fits"

		#
		#	divide image by exposure time to get DN/sec
		#
		EXPTIME=`$BIN/modhead $tempfits exptime | $GAWK '{print $3}'`
		echo "Dividing image by exposure time      : $EXPTIME <br>\n"
		$BIN/constarith $tempfits / $EXPTIME /tmp/temp09.$$.fits
		tempfits="/tmp/temp09.$$.fits"




#
#	make this better
#
		#
		#	find monthly minimum
		#	format cam+'m'+levelchar+'_'+filpol+'*.fts' 
		#		ex. 2m_orcl_000204.fts (Apparently levelchar isn't used)
		#
		MONTHOBS=`echo $DATEOBS | cut -c3-6`
		case $CAMERA in
			C2)	FP="orcl"
				;;
			C3)	FP="clcl"
				;;
		esac

		MODEL=`/bin/ls -1 /net/corona/lasco/monthly/"$CAMNUM"m_"$FP"_"$MONTHOBS"??.fts | head -1`
		echo "Using $MODEL as model<br>\n"

		#
		#	divide model by exptime
		#
		EXPTIME=`$BIN/modhead $MODEL exptime | $GAWK '{print $3}'`
		echo "Dividing model by exposure time      : $EXPTIME <br>\n"
		$BIN/constarith $MODEL / $EXPTIME /tmp/temp-M.$$.fits
		MODEL="/tmp/temp-M.$$.fits"







#
#	ensure raw and model are 1024
#









		#
		#	divide out monthly minimum model
		#
		$BIN/imagearith $tempfits / $MODEL /tmp/temp10.$$.fits
		tempfits="/tmp/temp10.$$.fits"


#
#	determine the median of the good parts of the image
#	(can't really do this yet)
#	the imagemedian is actually the median of the median
#	in each row
#
		MEDIAN=`$BIN/imagemedian $tempfits`
		echo "Median of image after model removed  : $MEDIAN<br>\n"

		#
		#	grab a section (probably should base on median)
		#
		case $CAMERA in 
			C2)	MINI=`$BIN/jexpr 0.3 + $MINIMUM`		#	`$BIN/jexpr $MEDIAN - 0.9`
				MAXI=`$BIN/jexpr 1.9 + $MAXIMUM`		#	`$BIN/jexpr $MEDIAN + 0.9`
			;;
			C3)	MINI=`$BIN/jexpr 0.9 + $MINIMUM`		#	`$BIN/jexpr $MEDIAN - 0.3`
				MAXI=`$BIN/jexpr 1.2 + $MAXIMUM`		#	`$BIN/jexpr $MEDIAN + 0.2`
			;;
		esac
		echo "Pruning image minimum to             : $MINI<br>\n"
		echo "Pruning image maximum to             : $MAXI<br>\n"
		$BIN/pruneimage $tempfits $MAXI $MINI /tmp/temp20.$$.fits
		tempfits="/tmp/temp20.$$.fits"

		#
		#	zero it out (based on above's minimum)
		#
		echo "Shifting minimum value to zero.<br>\n"
		$BIN/constarith $tempfits - $MINI /tmp/temp25.$$.fits
		tempfits="/tmp/temp25.$$.fits"


		#
		#	apply mask
		#
		echo "Masking out inner and outer portions.<br>\n"
		$BIN/imagearith $tempfits \* $CAMERA.mask.fts /tmp/temp35.$$.fits
		tempfits="/tmp/temp35.$$.fits"

#
#	stretch it out (not real sure what the limits are yet)
#	13000 still too high for some C3
#
		MAXVAL=12000
		SPREAD=`$BIN/jexpr $MAXI - $MINI`
		FACTOR=`$BIN/jexpr $MAXVAL / $SPREAD`
		echo "Stretching maximum value to $MAXVAL.<br>\n"
		$BIN/constarith $tempfits \* $FACTOR /tmp/temp30.$$.fits
		tempfits="/tmp/temp30.$$.fits"


#
#	draw solar limb on image
#




	fi	#	level_10 -a !EIT


#
#	Diffs are still a little funky
#
	#
	#	create Difference Image as necessary (NEEDS WORK)
	#	
	if [ "$IMGTYPE" = "diff" -a "$OK" ]
	then
		if [ -r /tmp/prev00.$$.fits -a -w /tmp/prev00.$$.fits ]
		then
			echo "Subtracting previous image from current image.<br>\n"
			$BIN/imagearith $tempfits - /tmp/prev00.$$.fits /tmp/temp50.$$.fits
			/bin/rm -f /tmp/prev00.$$.fits
			/bin/cp $tempfits /tmp/prev00.$$.fits
			/usr/bin/chmod 644 /tmp/prev00.$$.fits

			tempfits="/tmp/temp50.$$.fits"
			OK="OK"
		else
			echo "No previous image.<br>\n"
			/bin/cp $tempfits /tmp/prev00.$$.fits
			/usr/bin/chmod 644 /tmp/prev00.$$.fits
			OK=	
		fi
		/bin/cp $tempfits $OUTDIR/$outroot.fits
	fi

#
#	add color as necessary
#






	###############################################################

	BITPIX=`$GetValue $tempfits BITPIX | $GAWK -F= '{print $2}' | $GAWK -F/ '{print $1}' | $GAWK '{print $1}'`
	#	last gawk strips out white space
	#	echo "BITPIX.$BITPIX.<br>\n"
	if [ "$BITPIX" != "16" -a "$OK" ]
	then
		#
		#	change to BITPIX = 16 so the fitstopgm can handle it
		#	make sure the values won't cause an overflow
		#
		echo "Converting image to FITS (BITPIX = 16).<br>\n"
#		$BIN/pruneimage $tempfits 100 -100 /tmp/temp39.$$.fits
#		tempfits="/tmp/temp39.$$.fits"

		$BIN/tofitsbp16 $tempfits /tmp/temp40.$$.fits
		tempfits="/tmp/temp40.$$.fits"
	fi

	#
	#	Convert to gifs
	#
	if [ "$OK" ]
	then
		echo "Converting FITS to GIF.<br>\n"
		$FITSTOPGM $tempfits | $PNMFLIP | $PNMSCALE $OUTSIZE $OUTSIZE | $PPMTOGIF > $OUTDIR/$outroot.gif
	fi
done
#
#	Cleanup
#
/bin/rm /tmp/temp??.$$.fits
/bin/rm /tmp/prev??.$$.fits



#
#	Make still sequence everytime, ... because we can.
#
cd $OUTROOT
tar cf $FTPDIR/$DATE.$$.tar $DATE.$$
/usr/bin/gzip -v9 $FTPDIR/$DATE.$$.tar

echo "<br><br>\n"
echo "<a href=\"$FTPURL/$DATE.$$.tar.gz\">\n"
echo "Your images are TAR'd and GZIP'd and ready for pickup.\n"
echo "</a>\n"


#
#	EVALUATE EMAIL ADDRESS BEFORE TRYING TO SEND
#
#echo "" > /tmp/email.$$.html
#echo "The individual LASCO/EIT images that you created are ready at ... " >> /tmp/email.$$.html
#echo "http://lasco-www.nrl.navy.mil/MovieTool/$DATE.$$.tar.gz" >> /tmp/email.$$.html
#echo "" >> /tmp/email.$$.html
#echo "ThanX for choosing LASCO/EIT for all your space weather needs." >> /tmp/email.$$.html
#echo "" >> /tmp/email.$$.html
#/usr/ucb/mail -s "LASCO/EIT images are ready." jakewendt@nrl.navy.mil < /tmp/email.$$.html
#/bin/rm /tmp/email.$$.html


#
#	Convert to final data format
#
cd $OUTDIR
case $OUTTYPE in
	MPG1)
		$ROOT/mpeg1.sh $FTPDIR/$DATE.$$.mpg $OUTDIR
#		$ROOT/sendemail.sh $DATE.$$.mpg jakewendt@nrl.navy.mil
		/usr/bin/gzip -v9 $FTPDIR/$DATE.$$.mpg
		echo "<br><br>\n"
		echo "<a href=\"$FTPURL/$DATE.$$.mpg.gz\">\n"
		echo "Your mpeg ready for pickup.\n"
		echo "</a>\n"
		;;
	MPG2) 
		;;
	AGIF) 
		$WHIRLGIF -o $FTPDIR/$DATE.$$.gif -loop 1 -time 5 *.gif
#		$ROOT/sendemail.sh $FTPURL/$DATE.$$.gif jakewendt@nrl.navy.mil
		;;
	AGIFL) 
		$WHIRLGIF -o $FTPDIR/$DATE.$$.gif -loop -time 5 *.gif
#		$ROOT/sendemail.sh $DATE.$$.gif jakewendt@nrl.navy.mil
		;;
	*) 
		;;
esac


echo "</BODY>"


