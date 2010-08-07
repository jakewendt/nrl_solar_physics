#! /bin/sh
# Created: 13 May 1999 - D. Wang
#if [ $# -lt 3 ]; then
#echo "Purpose: Generate HTML with Java applet to show GIF images"
#echo "Usage: $0 file_type autoplay code num_images delay"
#echo "Example: $0 eit_171 1 0"
#echo " "
#echo "Types: eit_171 eit_195 eit_284 eit_304 c2 c3 dit_195 d2 d3"
#echo "Autoplay: 0=no controls or autoplay 1=autoplay 2=controls 3 = controls + autoplay"
#echo "Size : 0=tiny  1=small  2=large 3=controls"
#exit
#fi

echo "Content-type: text/html"
echo

#### Start Configure #####
codebase='../java'

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
AUTO=$2
code=$3
delay=$5

#read form_arg
#echo "Input arg: $form_arg"

#echo $file_type $AUTO $code

# 60 tiny gifs make my P90, 16Mb swap to disk with IE

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

case $code in
'eit_171') TYPE='EIT 171A' ;;
'eit_195') TYPE='EIT 195A' ;;
'eit_284') TYPE='EIT 284A' ;;
'eit_304') TYPE='EIT 304A' ;;
'c2') TYPE='LASCO C2' ;;
'c3') TYPE='LASCO C3' ;;
'dit_195') TYPE='EIT 195A DIFF' ;;
'd2') TYPE='LASCO C2 DIFF' ;;
'd3') TYPE='LASCO C3 DIFF' ;;
esac

case $SZ in
'0') WIDTH=256 ; HEIGHT=256 ; MULT=1 ;;
'1') WIDTH=512 ; HEIGHT=512 ; MULT=4 ;;
'2') WIDTH=1024 ; HEIGHT=1024 MULT=18 ;;
esac

case $code in
'eit_171') SIZE=53 ;;
'eit_195') SIZE=53 ;;
'eit_284') SIZE=53 ;;
'eit_304') SIZE=53 ;;
'c2') SIZE=45 ;;
'c3') SIZE=44 ;;
'dit_195') SIZE=53 ;;
'd2') SIZE=45 ;;
'd3') SIZE=44 ;;
esac

if [ $file_type = 'jpg' ] ; then
MULT=1
case $code in
'eit_171') SIZE=82 ;;
'eit_195') SIZE=82 ;;
'eit_284') SIZE=82 ;;
'eit_304') SIZE=82 ;;
'c2') SIZE=75 ;;
'c3') SIZE=171;;
'dit_195') SIZE=82 ;;
'd2') SIZE=75 ;;
'd3') SIZE=171;;
esac
fi

#echo "<p>$file_type $AUTO $code $SIZE $DIR $MULT $TYPE"

# Always add 35 pixels for Captions
if [ $AUTO -eq 1 -o $AUTO -eq 3 ]; then
HEIGHT=`expr $HEIGHT + 35`
fi

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
echo "<h1>SOHO $TYPE</h1>    "
echo "Latest $NUM $file_type Images (approx. $TOTAL_SIZE kb) as of $DATE <p>"
#echo " "
echo "<applet codebase=$codebase code=MeasureImg.class width=$WIDTH height=$HEIGHT>"

echo "<param name=NumImages value=$NUM>"

if [ $AUTO -eq 1 -o $AUTO -eq 3 ]; then
echo "<param name=AutoPlay value=true>"
else
echo "<param name=AutoPlay value=false>"
fi

if [ $AUTO -ge 2 ]; then
echo "<param name=Controls value=true>"
else
echo "<param name=Controls value=false>"
fi

# inputs for java_movie2.cgi

echo "<param name=file_type value=$file_type>"
echo "<param name=type_code value=$code>"
echo "<param name=jumptoURL value=$jumpURL>"

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

sedcmd=`echo "sx"$wwwroot"x"$jumpURL"x"`

name=`echo $name | sed $sedcmd`
COUNT=`expr $COUNT + 1`
echo "<param name=Image$COUNT value=$name>"
# end body of loop

done

echo "<param name=DelayBetweenImages value=$delay>"

echo "</applet>"
echo "<p>"
echo "<h1>How To Measure Positions</h1>
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
"
echo "<p>"
echo "<hr>"
echo "More LASCO information:<p>"
echo "<A HREF=\"http://lasco-www.nrl.navy.mil\" TARGET=\"_blank\">LASCO Home Page</A>"
echo "<A HREF=\"http://lasco-www.nrl.navy.mil/rtmovies.html\" TARGET=\"_blank\">LASCO Real Time Movie Page</A>"
echo "<hr>"
echo "Created by Dennis Wang (Java and WWW Programming) & Nathan Rich (Data Reduction and Archiving), LASCO/SOHO team, Interferometrics/Naval Research Lab, Washington DC<br>"
echo "Editted by Jake Wendt, LASCO/SOHO team, Interferometrics/Naval Research Lab, Washington DC<br>"

/bin/rm /tmp/$$slideshow
fi
