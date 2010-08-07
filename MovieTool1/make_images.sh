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
#	-	getbkgimg
#	-	libpng/libmng
#	-	pnmtopng
#	-	png2mng.pl
#
#
#

echo Content-type: text/html
echo

###############################################################
#	DIRS
#LASCODIR=/export/home/apache/share/htdocs/lasco-www
CGIBIN=/export/home/apache/share/cgi-bin
DATE=`/usr/bin/date +%Y%m%d.%H%M%S`
FTPDIR=/net/louis14/data/ftp/pub/outgoing/movie/
#OUTROOT=/export/home/apache/share/htdocs/lasco-www/MovieTool
OUTROOT=$FTPDIR
OUTDIR=$OUTROOT/$DATE.$$
FTPURL="ftp://louis14.nrl.navy.mil/pub/outgoing/movie/"
WWWURL="http://lasco-www.nrl.navy.mil"
TSIZE=256		#	Thumbnail Image size

###############################################################
#	COMMANDS
ROOT=$CGIBIN/MovieTool
BIN=$ROOT/bin
GAWK=$BIN/gawk
FITSTOPGM=$BIN/fitstopgm
PNMFLIP="$BIN/pnmflip -tb "
PNMSCALE="$BIN/pnmscale -xysize "
TOGIF="$BIN/ppmtogif "
TOPNG="$BIN/pnmtopng "
TOJPG="$BIN/cjpeg -quality 90 "
MPEGENC=$BIN/mpeg_encode
WHIRLGIF=$BIN/whirlgif
GetValue="$BIN/modhead "


read form_args
#echo $form_args > /tmp/jake030731

LOG="/export/home/apache/share/htdocs/lasco-www/MovieTool.log"
date >> $LOG
echo $form_args >> $LOG
echo >> $LOG


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

COMMENTS=`echo $form_args | $GAWK -F\& '{for (i=1;i<=NF;i++) { split($i, a, "="); if ( a[1] == "comments" ) { print a[2]; next }}}'`
if [ "$COMMENTS" != "" ]
then 
	echo $COMMENTS | /usr/bin/sed 's/+/ /g'> /tmp/comment.$$
	/usr/ucb/mail -s "Movie Machine Comment" webmaster@louis14.nrl.navy.mil < /tmp/comment.$$
	/bin/rm /tmp/comment.$$
fi

cat $ROOT/html/head1


mkdir $OUTDIR			#	for full size PPM files
mkdir $OUTDIR.$OUTSIZE	#	for user chosen size and format files
mkdir $OUTDIR.$TSIZE	#	for thumbnail size GIF files

case $OUTTYPE in
	JPG)	FINAL=$TOJPG
		EXT='jpg'
		;;
	PNG|MNG)	FINAL=$TOPNG
		EXT='png'
		;;
	*)	FINAL=$TOGIF
		EXT='gif'
		;;
esac

case $OUTTYPE in
	JS) echo "<BODY OnLoad=javascript:window.open('$WWWURL/cgi-bin/MovieTool/jsmovie.pl\?dir=$OUTDIR.$OUTSIZE\&size=$OUTSIZE'); "
	;;
	JAVA) echo "<BODY OnLoad=javascript:window.open('$WWWURL/cgi-bin/MovieTool/jmeasure.pl\?dir=$OUTDIR.$OUTSIZE\&size=$OUTSIZE'); "
	;;
	AGIF|AGIFL) echo "<BODY OnLoad=javascript:window.open('$FTPURL/$DATE.$$.$OUTSIZE.gif'); "
	;;
	MPG1) echo "<BODY OnLoad=javascript:window.open('$FTPURL/$DATE.$$.$OUTSIZE.mpg'); "
	;;
	MNG) echo "<BODY OnLoad=javascript:window.open('$FTPURL/$DATE.$$.$OUTSIZE.mng'); "
	;;
	*) echo "<BODY "
	;;
esac

echo " onClick=javascript:window.open('$WWWURL/MovieTool/$DATE.$$.$OUTSIZE/');>\n"
echo "<h4><center>Click in this window to gain access to your images as they are created</center></h4><br>\n"

for each in $FILELIST
do
	OK="OK"

	DATEOBS=`$GetValue $each DATE-OBS | $GAWK -F\' '{print $2}' | $GAWK -F\/ 'BEGIN{OFS=""} {print $1,$2,$3}'`
	TIMEOBS=`$GetValue $each TIME-OBS | $GAWK -F\' '{print $2}' | $GAWK -F\: 'BEGIN{OFS=""} {print $1,$2}'`
	CAMERA=`$GetValue $each DETECTOR  | $GAWK -F\' '{print $2}' | $GAWK '{print $1}'`	# LAST GAWK REMOVES TRAILING SPACES
	PORT=`$GetValue $each READPORT    | $GAWK -F\' '{print $2}' | $GAWK '{print $1}'`
	FILTER=`$GetValue $each FILTER    | $GAWK -F\' '{print $2}' | $GAWK '{print $1}'`
	POLAR=`$GetValue $each POLAR      | $GAWK -F\' '{print $2}' | $GAWK '{print $1}'`
	SECTOR=`$GetValue $each SECTOR    | $GAWK -F\' '{print $2}' | $GAWK '{print $1}'`
	ROLL=`$GetValue $each CROTA1      | $GAWK -F\= '{print $2}' | $GAWK '{print $1}'`
	ROLL=${ROLL:-0}
	LEBPROG=`$GetValue $each LP_NUM   | $GAWK -F\' '{print $2}' | $GAWK '{print $1}'`	#	will remove PW from 'Seq PW' too
	SUMROW=`$GetValue $each SUMROW      | $GAWK '{print $3}'`
	SUMCOL=`$GetValue $each SUMCOL      | $GAWK '{print $3}'`
	BINSUM=`$BIN/jexpr $SUMROW \* $SUMCOL`
	









#	Should insert something to ensure that the LEB Program is Normal and not Seq PW
#	although user can choose this from database form











	echo "<TABLE>"

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


	echo "<TR><TD WIDTH=600>"
	echo "<br>\nProcessing ... $each ( $outroot )<br>\n"

	#	DO NOT USE $each PAST THIS POINT
	tempfits=$each

	/bin/rm /tmp/temp??.$$.fits


	if [ $LEVEL = "10" ]
	then
		#
		#	find current BIAS 
		#
		BIAS=`$ROOT/bin/offset_bias.sh $CAMERA $DATEOBS $PORT`


#	Does exposure time effect this value? (I don't think so)
#	Does binning, framing, resizing, ... effect this?  (I think so)


		#
		#	ensure image is 1024x1024
		#
		IMAGESIZE=`$BIN/modhead $tempfits naxis1 | $GAWK '{print $3}'`
		IMAGEY=`$BIN/modhead $tempfits naxis2 | $GAWK '{print $3}'`
		if [ $IMAGESIZE != "1024" ]
		then
			ZFACTOR=`$BIN/jexpr 1024 / $IMAGESIZE`
			echo "Image is $IMAGESIZE x $IMAGESIZE<br>\n"
			echo "Resizing by a factor of $ZFACTOR<br>\n"
			$BIN/fitszoom $tempfits $ZFACTOR /tmp/temp00.$$.fits
			tempfits="/tmp/temp00.$$.fits"
		else
			echo "Image is $IMAGESIZE x $IMAGEY<br>\n"
		fi

		#
		#	subtract offset BIAS
		#
		echo "Subtracting bias value of $BIAS. <br>\n"
		$BIN/constarith $tempfits - $BIAS /tmp/temp05.$$.fits
		tempfits="/tmp/temp05.$$.fits"

		if [ $CAMERA = "C2" -o $CAMERA = "C3" ]
		then
			#
			#	find monthly minimum
			#
			MODEL=`$BIN/getbkgimg $CAMERA $DATEOBS $FILTER $POLAR $ROLL`
			if [ "$MODEL" = "" -a "$CAMERA" = "C3" ]
			then
				MODEL=`$BIN/getbkgimg $CAMERA $DATEOBS Orange Clear $ROLL`
			elif [ "$MODEL" = "" -a "$CAMERA" = "C2" ]
			then
				MODEL=`$BIN/getbkgimg $CAMERA $DATEOBS Clear Clear $ROLL`
			fi

			if [ "$MODEL" = "" ]
               then
                    MODEL=`$BIN/getbkgimg $CAMERA $DATEOBS Orange Clear $ROLL`
			fi
               if [ "$MODEL" = "" ]
               then
                    MODEL=`$BIN/getbkgimg $CAMERA $DATEOBS Clear Clear $ROLL`
               fi


			if [ "$MODEL" = "" ]
			then
				echo "No model found.  I'm about to crash. Sorry. <br>\n"
			fi

			echo "Using $MODEL as model<br>\n"


	
			#
			#	ensure model is 1024x1024
			#
			MODELSIZE=`$BIN/modhead $MODEL naxis1 | $GAWK '{print $3}'`
			MODELY=`$BIN/modhead $MODEL naxis2 | $GAWK '{print $3}'`
			if [ $MODELSIZE != "1024" ]
			then
				ZFACTOR=`$BIN/jexpr 1024 / $MODELSIZE`
				echo "Model is $MODELSIZE x $MODELSIZE<br>\n"
				echo "Resizing by a factor of $ZFACTOR<br>\n"
				$BIN/fitszoom $MODEL $ZFACTOR /tmp/tempM0.$$.fits
				MODEL="/tmp/tempM0.$$.fits"
			else
				echo "Model is $MODELSIZE x $MODELY<br>\n"
			fi
	
			#
			#	divide model by exptime
			#
			EXPTIME=`$BIN/modhead $MODEL exptime | $GAWK '{print $3}'`
			echo "Dividing model by exposure time      : $EXPTIME <br>\n"
			$BIN/constarith $MODEL / $EXPTIME /tmp/tempM1.$$.fits
			MODEL="/tmp/tempM1.$$.fits"
	
			#
			#	divide out monthly minimum model
			#
			echo "Dividing out monthly model.<br>\n"
			$BIN/imagearith $tempfits / $MODEL /tmp/temp10.$$.fits
			tempfits="/tmp/temp10.$$.fits"
		elif [ $CAMERA = "EIT" ]
		then
			#
			#	degrid
			#
			WL=`echo $SECTOR | cut -c1-3`			
			if [ $FILTER = "CLEAR" ]
			then
				OFIL="clear"
			else 
				OFIL="al1"
			fi
			echo "Degriding EIT image with degrid_${WL}_${OFIL}.fits.<br>\n"
			$BIN/imagearith $tempfits \* masks/degrid_${WL}_${OFIL}.fits /tmp/temp15.$$.fits
			tempfits="/tmp/temp15.$$.fits"

			#
			#	flat field
			#
			echo "Flat-fielding EIT image with flat_${WL}.fits.<br>\n"
			$BIN/imagearith $tempfits \* masks/flat_${WL}.fits /tmp/temp20.$$.fits
			tempfits="/tmp/temp20.$$.fits"

		fi

		#
		#	divide image by exposure time to get DN/sec
		#
		EXPTIME=`$BIN/modhead $tempfits exptime | $GAWK '{print $3}'`
		echo "Dividing image by exposure time      : $EXPTIME <br>\n"
		$BIN/constarith $tempfits / $EXPTIME /tmp/temp25.$$.fits
		tempfits="/tmp/temp25.$$.fits"

		if [ ${BINSUM} -gt 0 ]
		then
			#
			#	image is binned, dividing by binsize
			#
			echo "Dividing image by binsize      : $BINSUM <br>\n"
			$BIN/constarith $tempfits / $BINSUM /tmp/temp27.$$.fits
			tempfits="/tmp/temp27.$$.fits"
		fi
			
		if [ $CAMERA = "EIT" ]
		then
			#
			#	filter factor
			#
			case $WL in
				171|195)	ffactor=0.49
					;;
				284)		ffactor=0.33
					;;
				304)		ffactor=0.29
					;;
			esac
			echo "Flux normalizing to clear filter with $ffactor.<br>\n"
			$BIN/constarith $tempfits / $ffactor /tmp/temp30.$$.fits
			tempfits="/tmp/temp30.$$.fits"

			#
			#	eit_norm_response
			#






		fi




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
			EIT)	MINI=`$BIN/jexpr 0 + $MINIMUM`		#	`$BIN/jexpr $MEDIAN - 0.3`
				MAXI=`$BIN/jexpr 100 + $MAXIMUM`		#	`$BIN/jexpr $MEDIAN + 0.2`
			;;
		esac
		echo "Pruning image minimum to             : $MINI<br>\n"
		echo "Pruning image maximum to             : $MAXI<br>\n"
		$BIN/pruneimage $tempfits $MAXI $MINI /tmp/temp35.$$.fits
		tempfits="/tmp/temp35.$$.fits"

		#
		#	zero it out (based on above's minimum)
		#
		echo "Shifting minimum value to zero.<br>\n"
		$BIN/constarith $tempfits - $MINI /tmp/temp40.$$.fits
		tempfits="/tmp/temp40.$$.fits"

		if [ $CAMERA = "C2" -o $CAMERA = "C3" ]
		then
			#
			#	apply mask
			#
			echo "Masking out inner and outer portions.<br>\n"
			$BIN/imagearith $tempfits \* masks/$CAMERA.mask.fts /tmp/temp45.$$.fits
			tempfits="/tmp/temp45.$$.fits"
		fi

		#
		#	stretch it out 
		#
		MAXVAL=16000
		SPREAD=`$BIN/jexpr $MAXI - $MINI`
		FACTOR=`$BIN/jexpr $MAXVAL / $SPREAD`
		echo "Stretching maximum value to $MAXVAL.<br>\n"
		$BIN/constarith $tempfits \* $FACTOR /tmp/temp50.$$.fits
		tempfits="/tmp/temp50.$$.fits"

		if [ $CAMERA = "C2" -o $CAMERA = "C3" ]
		then
			#
			#	draw solar limb on image
			#
			echo "Adding solar limb.<br>\n"
			$BIN/constarith masks/$CAMERA.limb.fts \* $MAXVAL /tmp/tempSL.$$.fits
			$BIN/imagearith $tempfits \> /tmp/tempSL.$$.fits /tmp/temp55.$$.fits
			tempfits="/tmp/temp55.$$.fits"
		fi

		#
		#	rotate image 180 degree if necessary
		#
		#orientation=`$BIN/orient.pl ${DATEOBS}${TIMEOBS}00`
		#if [ ${orientation} -eq 180 ]
		if [ ${ROLL} -eq 180 ]
		then
			echo "Rotating image.<br>\n"
			$BIN/fitscopy $tempfits\[-\*,-\*\] /tmp/temp57.$$.fits
			tempfits="/tmp/temp57.$$.fits"
		fi

		if [ $CAMERA = "C2" -o $CAMERA = "C3" ]
		then
			#
			#	draw LASCO logo on image
			#
			echo "Adding LASCO Logo.<br>\n"
			$BIN/constarith masks/lascologo.fts \* $MAXVAL /tmp/tempL0.$$.fits
			$BIN/imagearith $tempfits \> /tmp/tempL0.$$.fits /tmp/temp60.$$.fits
			tempfits="/tmp/temp60.$$.fits"
		fi

		#
		#	PBM conversions are based on DATAMIN and DATAMAX
		#	keywords if they exist 
		#	(and they do, so they need to be correct)
		#
		echo "<PRE>\n"
		$BIN/modhead $tempfits DATAMIN 0
		$BIN/modhead $tempfits DATAMAX $MAXVAL
		echo "</PRE>\n"
	fi	#	level_10 












#
#	Diffs are still a little funky
#	OK, diffs are still a lot funky
#
	#
	#	create Difference Image as necessary (NEEDS WORK)
	#	
	if [ "$IMGTYPE" = "diff" -a "$OK" ]
	then
		if [ -r /tmp/prev00.$$.fits -a -w /tmp/prev00.$$.fits ]
		then
			echo "Subtracting previous image from current image.<br>\n"
			$BIN/imagearith $tempfits - /tmp/prev00.$$.fits /tmp/temp65.$$.fits
			/bin/rm -f /tmp/prev00.$$.fits
			/bin/cp $tempfits /tmp/prev00.$$.fits
			/usr/bin/chmod 644 /tmp/prev00.$$.fits

			tempfits="/tmp/temp65.$$.fits"
			OK="OK"
		else
			echo "No previous image.<br>\n"
			/bin/cp $tempfits /tmp/prev00.$$.fits
			/usr/bin/chmod 644 /tmp/prev00.$$.fits
			OK=	
		fi
		#	/bin/cp $tempfits $OUTDIR.$OUTSIZE/$outroot.fits
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
		$BIN/tofitsbp16 $tempfits /tmp/temp75.$$.fits
		tempfits="/tmp/temp75.$$.fits"
	fi

	#
	#	Convert image to Full Size PPM and save
	#
	echo "Converting FITS to PPM.<br>\n"
	$FITSTOPGM $tempfits | $PNMFLIP  > $OUTDIR/$outroot.ppm

	#
	#	Convert PPM to final image size and format
	#		and thumbnail PNG
	#
	if [ "$OK" ]
	then
		echo "Converting PPM to $EXT.<br>\n"
		echo "</TD>"
		$PNMSCALE $OUTSIZE $OUTSIZE $OUTDIR/$outroot.ppm | $FINAL > $OUTDIR.$OUTSIZE/$outroot.$OUTSIZE.$EXT
		if [ "$OUTSIZE" != $TSIZE ]
		then
			$PNMSCALE $TSIZE $TSIZE $OUTDIR/$outroot.ppm | $FINAL > $OUTDIR.$TSIZE/$outroot.$TSIZE.$EXT
		fi
		echo "<TD WIDTH=150>"
		echo "<img src='$WWWURL/MovieTool/$DATE.$$.$TSIZE/$outroot.$TSIZE.$EXT'><BR>\n"
		echo "</TD>"
	else
		echo "Not creating image.<br>\n"
		echo "</TD><TD></TD>"
	fi
	echo "</TR>"
done
echo "</TABLE>"
#
#	Cleanup
#
/bin/rm /tmp/temp??.$$.fits
/bin/rm /tmp/prev??.$$.fits



#
#	Make still sequence everytime, ... because we can.
#
cd $OUTROOT
echo "<br><PRE>\n"
tar cvf $FTPDIR/$DATE.$$.$OUTSIZE.tar $DATE.$$.$OUTSIZE
/usr/bin/gzip -v9 $FTPDIR/$DATE.$$.$OUTSIZE.tar
echo "</PRE>\n"


echo "<br><br>\n"
echo "<a href=\"$FTPURL/$DATE.$$.$OUTSIZE.tar.gz\">\n"
echo "Your images are TAR'd and GZIP'd and ready for pickup.\n"
echo "</a>\n"


#
#	EVALUATE EMAIL ADDRESS BEFORE TRYING TO SEND
#
#echo "" > /tmp/email.$$.html
#echo "The individual LASCO/EIT images that you created are ready at ... " >> /tmp/email.$$.html
#echo "$WWWURL/MovieTool/$DATE.$$.$OUTSIZE.tar.gz" >> /tmp/email.$$.html
#echo "" >> /tmp/email.$$.html
#echo "ThanX for choosing LASCO/EIT for all your space weather needs." >> /tmp/email.$$.html
#echo "" >> /tmp/email.$$.html
#/usr/ucb/mail -s "LASCO/EIT images are ready." jakewendt@nrl.navy.mil < /tmp/email.$$.html
#/bin/rm /tmp/email.$$.html


#
#	Convert to final data format
#
cd $OUTDIR.$OUTSIZE
case $OUTTYPE in
	MPG1)
		$ROOT/bin/makempeg.sh $FTPDIR/$DATE.$$.$OUTSIZE.mpg $OUTDIR.$OUTSIZE
#		$ROOT/bin/sendemail.sh $DATE.$$.$OUTSIZE.mpg jakewendt@nrl.navy.mil
#		/usr/bin/gzip -v9 $FTPDIR/$DATE.$$.$OUTSIZE.mpg
		echo "<br><br>\n"
		echo "<a href=\"$FTPURL/$DATE.$$.$OUTSIZE.mpg\">\n"
		echo "Your mpeg ready for pickup.\n"
		echo "</a>\n"
		;;
	MNG) 
		PNGSIZE=`$ROOT/bin/pngsize $OUTDIR.$OUTSIZE/$outroot.$OUTSIZE.png`
		$ROOT/bin/png2mng.pl $OUTDIR.$OUTSIZE $PNGSIZE > $FTPDIR/$DATE.$$.$OUTSIZE.mng
		echo "<br><br>\n"
		echo "<a href=\"$FTPURL/$DATE.$$.$OUTSIZE.mng\">\n"
		echo "Your MNG ready for pickup.\n"
		echo "</a>\n"
		;;
	AGIF) 
		$WHIRLGIF -o $FTPDIR/$DATE.$$.$OUTSIZE.gif -loop 1 -time 5 *.gif
#		$ROOT/bin/sendemail.sh $FTPURL/$DATE.$$.$OUTSIZE.gif jakewendt@nrl.navy.mil
		;;
	AGIFL) 
		$WHIRLGIF -o $FTPDIR/$DATE.$$.$OUTSIZE.gif -loop -time 5 *.gif
#		$ROOT/bin/sendemail.sh $DATE.$$.$OUTSIZE.gif jakewendt@nrl.navy.mil
		;;
	*) 
		;;
esac


echo "</BODY>"


