#! /bin/sh
#	Created: 10 Aug 1999 - D. Wang
#
#	Editted:	21 Dec 2001 -	Jake	-	Modified to include running difference images
#
#
#if [ $# -lt 3 ]; then
#echo "Purpose: Generate HTML with Java applet to show GIF images"
#echo "Usage: $0 file_type code speed frames"
#echo "Example: $0 eit_171 1 0"
#echo " "
#echo "File_type: jpg sgf tgf gif "
#echo "Types: eit_171 eit_195 eit_284 eit_304 c2 c3 dit_195 d2 d3"
#echo "Size : 0=tiny  1=small  2=large"
#exit
#fi

echo "Content-type: text/html"
echo 

#### Start Configure #####
 
# WWW root directory without a trailing slash
wwwroot='/data/local/apache/share/htdocs/lasco-www'
 
# Put the GIF directory here
gifroot="$wwwroot/javagif"
 
# Put the jumpURL here
jumpURL=http://lasco-www.nrl.navy.mil

#### End Configure #####


SZ=2
MAX_FRAMES=50
SIZE=80

file_type=$1
code=$2
speed=$3
MAX_FRAMES=$4

#echo $file_type $code $speed $MAX_FRAMES

case $file_type in
	'jpg') DIR='jpg24'
		SZ=2
		img_type='jpg' ;;
	'gif') DIR='gifs'
		SZ=2
		img_type='gif' ;;
	'sgf') DIR='gifs_small'
		SZ=1
		img_type='gif' ;;
	'tgf') DIR='gifs_tiny'
		SZ=0
		img_type='gif'
		MAX_FRAMES=70  ;;
esac

#	case $code in
#	'eit_171') TYPE='EIT 171A' ;;
#	'eit_195') TYPE='EIT 195A' ;;
#	'eit_284') TYPE='EIT 284A' ;;
#	'eit_304') TYPE='EIT 304A' ;;
#	'c2') TYPE='LASCO D2' ;;
#	'c3') TYPE='LASCO C3' ;;
#	esac

	case $SZ in
	'0') WIDTH=256 ; HEIGHT=256 ; MULT=1 ;;
	'1') WIDTH=512 ; HEIGHT=512 ; MULT=4 ;;
	'2') WIDTH=1024 ; HEIGHT=1024; MULT=18 ;;
	esac

#	case $code in
#	'eit_171') SIZE=53 ;;
#	'eit_195') SIZE=53 ;;
#	'eit_284') SIZE=53 ;;
#	'eit_304') SIZE=53 ;;
#	'c2') SIZE=45 ;;
#	'c3') SIZE=44 ;;
#	esac

#	if [ $file_type = 'jpg' ] ; then
#	MULT=1
#	case $code in
#	'eit_171') SIZE=82 ;;
#	'eit_195') SIZE=82 ;;
#	'eit_284') SIZE=82 ;;
#	'eit_304') SIZE=82 ;;
#	'c2') SIZE=75 ;;
#	'c3') SIZE=171;;
#	esac
#	fi

#echo "<p>$file_type $code $SIZE $DIR $MULT $TYPE"

NUM=`/bin/ls $gifroot/$DIR/*$code.$img_type | tee /tmp/$$slideshow | wc -l`
wait
sleep 1

if [ $NUM -gt $MAX_FRAMES ] ; then
	NUM=`expr $MAX_FRAMES + 0`
fi

if [ $NUM -gt 0 ]; then
	#echo $NUM $SIZE
	TOTAL_SIZE=`expr $NUM \* $SIZE`
	TOTAL_SIZE=`expr $TOTAL_SIZE \* $MULT`

	DATE=`/bin/date -u`

	cat movie_header.js
	echo "var imax=$NUM;"
	echo "var iwidth=$WIDTH;"
	echo "var iheight=$HEIGHT;"
	echo "var speed=$speed;"
	cat movie_body1.js

	sedcmd=`echo "sx"$wwwroot/"x""x"`
	FRAME1=`head -1 /tmp/$$slideshow`
	name=`echo $FRAME1 | sed $sedcmd`
	echo "<img src = \"../$name\" NAME=animation ALT=\"FRAME\" width=$WIDTH height=$HEIGHT>"

	cat movie_body2.js

	COUNT=0
	tail -$MAX_FRAMES /tmp/$$slideshow |
	while [ true ]
	do

		read name
		if [ $? -eq 1 ] ; then
			break
		fi
		# body of loop
		#echo $name $?

		name=`echo $name | sed $sedcmd`
		echo "urls[$COUNT]=\"../$name\""
		COUNT=`expr $COUNT + 1`
		# end body of loop

	done

	cat movie_footer.js

	echo "<p>"
	echo "More LASCO information:<p>"
	echo "<A HREF=\"http://lasco-www.nrl.navy.mil\" TARGET=\"_blank\">LASCO Home Page</A>"
	echo "<A HREF=\"http://lasco-www.nrl.navy.mil/rtmovies.html\" TARGET=\"_blank\">LASCO Real Time Movie Page</A>"
	echo "<hr>"
	echo "Created by Dennis Wang (Java and WWW Programming) & Nathan Rich (Data Reduction and Archiving), LASCO/SOHO team, Interferometrics/Naval Research Lab, Washington DC - May 1999<br>"
	echo "Editted by Jake Wendt, LASCO/SOHO team, Interferometrics/Naval Research Lab, Washington DC - December 2001<br>"

	echo "</BODY>"
	echo "</HTML>"
	/bin/rm /tmp/$$slideshow
fi
