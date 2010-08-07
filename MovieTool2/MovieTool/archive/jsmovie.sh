#!/bin/sh


echo Content-type: text/html
echo

echo $#

read formargs
echo $formargs


exit

# WWW root directory without a trailing slash
wwwroot='/export/home/apache/share/htdocs/lasco-www'
 
# Put the jumpURL here	Why am I jumping???????
#jumpURL=http://lasco-www.nrl.navy.mil

MAX_FRAMES=50	#	Why 50???
speed=3		#	frames/sec

WIDTH=$OUTSIZE
HEIGHT=$OUTSIZE

NUM=`/bin/ls $OUTDIR/*.gif | tee /tmp/$$slideshow | wc -l`

#wait	#	for what?
#sleep 1	#	I'm not tired

if [ $NUM -gt $MAX_FRAMES ] ; then
	NUM=`expr $MAX_FRAMES + 0`
fi

if [ $NUM -gt 0 ]; then
	DATE=`/bin/date -u`

	cat $ROOT/movie_header.js
	echo "var imax=$NUM;"
	echo "var iwidth=$WIDTH;"
	echo "var iheight=$HEIGHT;"
	echo "var speed=$speed;"
	cat $ROOT/movie_body1.js

	sedcmd="s:$wwwroot::"
	FRAME1=`head -1 /tmp/$$slideshow`
	name=`echo $FRAME1 | sed $sedcmd`
	name=`echo $FRAME1`
	echo "<img src = \"$name\" NAME=animation ALT=\"FRAME\" width=$WIDTH height=$HEIGHT>"

	cat $ROOT/movie_body2.js

	COUNT=0
	tail -$MAX_FRAMES /tmp/$$slideshow |
	while [ true ]
	do
		read name
		if [ $? -eq 1 ] ; then
			break
		fi

		name=`echo $name | sed $sedcmd`
		echo "urls[$COUNT]=\"$name\""
		COUNT=`expr $COUNT + 1`
	done

	cat $ROOT/movie_footer.js

	echo "<p>"
	echo "More LASCO information:<p>"
	echo "<A HREF=\"http://lasco-www.nrl.navy.mil\" TARGET=\"_blank\">LASCO Home Page</A>"
	echo "<A HREF=\"http://lasco-www.nrl.navy.mil/rtmovies.html\" TARGET=\"_blank\">LASCO Real Time Movie Page</A>"
	echo "<hr>"
	echo "Created by Jake Wendt, LASCO/SOHO team, Interferometrics/Naval Research Lab, Washington DC - May 2003<br>"

	echo "</BODY>"
	echo "</HTML>"
	/bin/rm /tmp/$$slideshow
fi


