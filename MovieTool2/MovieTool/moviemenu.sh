#!/bin/sh
#	
#	moviemenu.sh
#
#
#	


read form_args

echo Content-type: text/html
echo 

cat << "EOF"
<HTML>
<HEAD>
<TITLE>
LASCO Movie Maker
</TITLE>
</HEAD>

<center>
<b>
<font size=8>LASCO Movie Maker</font>
</b>
</center>
<hr>


<br>
If you've created a list which includes multiple cameras and/or multiple filters etc., ...
Well, you get what you get.
<br>
<br>


<br><center>
<FORM METHOD="POST" ACTION="/cgi-bin/MovieTool/make_images.sh">
<INPUT TYPE="submit" VALUE="MAKE MOVIE">
<INPUT TYPE="reset" VALUE="Reset">
to clear entries.
</center>
<br>

<!--
<input type="text" NAME="email" size=34></textarea> 
email address for large job notification
<p>
-->


<p>Reduction Level
<SELECT NAME="level">
<OPTION VALUE="05" SELECTED> Level-0.5 (Default)
<OPTION VALUE="10"> Level-0.9
</SELECT>

<p>Movie Frame Size
<SELECT NAME="outsize">
<OPTION VALUE="128"> 128 x 128
<OPTION VALUE="256" SELECTED> 256 x 256
<OPTION VALUE="512"> 512 x 512
<OPTION VALUE="1024"> 1024 x 1024
</SELECT>

<p>Java Movies have a "jumptoURL" feature which has not been disabled.
After a period of time it will try to go to a new URL.
I'm working on this.


<p>Output Format 
<SELECT NAME="outtype">
<OPTION VALUE="JS" SELECTED> JavaScript Movie
<OPTION VALUE="JAVA"> Java Movie
<OPTION VALUE="MPG1"> MPEG-1
<OPTION VALUE="AGIF"> Animated GIF (Single Run)
<OPTION VALUE="AGIFL"> Animated GIF (Infinite Loop)
</SELECT>
(The GIF files will be available for all.)

<!-- Don't use the names min or max -->
<!-- Maybe use sliders or something here -->
<p>Scaling (relative to default) --
Max
<SELECT NAME="maximum">
<OPTION VALUE="+0.5"> +0.5
<OPTION VALUE="+0.4"> +0.4
<OPTION VALUE="+0.3"> +0.3
<OPTION VALUE="+0.2"> +0.2
<OPTION VALUE="+0.1"> +0.1
<OPTION VALUE="+0.0" SELECTED> 0
<OPTION VALUE="-0.1"> -0.1
<OPTION VALUE="-0.2"> -0.2
<OPTION VALUE="-0.3"> -0.3
<OPTION VALUE="-0.4"> -0.4
<OPTION VALUE="-0.5"> -0.5
</SELECT>
Min
<SELECT NAME="minimum">
<OPTION VALUE="+0.5"> +0.5
<OPTION VALUE="+0.4"> +0.4
<OPTION VALUE="+0.3"> +0.3
<OPTION VALUE="+0.2"> +0.2
<OPTION VALUE="+0.1"> +0.1
<OPTION VALUE="+0.0" SELECTED> 0
<OPTION VALUE="-0.1"> -0.1
<OPTION VALUE="-0.2"> -0.2
<OPTION VALUE="-0.3"> -0.3
<OPTION VALUE="-0.4"> -0.4
<OPTION VALUE="-0.5"> -0.5
</SELECT>

<br>
<br>
<br>
<hr>
<hr>
<hr>
<hr>


<p>Color Table
<SELECT NAME="colortable">
<OPTION VALUE="BW" SELECTED> 00_B-W LINEAR
<OPTION VALUE="BLUE"> 01_BLUE/WHITE
<OPTION VALUE="RED"> 03_RED TEMPERATURE
</SELECT>

<p>Image Types<br>
<INPUT TYPE="radio" NAME="imgtype" VALUE="norm" CHECKED>Regular Images<br>
<INPUT TYPE="radio" NAME="imgtype" VALUE="diff">Running Difference Images<br>


EOF
#########################################################################################

GAWK=/net/cronus/opt/gnu/bin/gawk

echo $form_args | $GAWK -F\& '{for (i=1;i<=NF;i++) print $i}' > /tmp/lasco0.$$
cat /tmp/lasco0.$$ | /usr/bin/sed 's:%2F:/:g' > /tmp/lasco1.$$ 		#	Replace %2F with /
cat /tmp/lasco1.$$ | $GAWK -F\+ '{print $1}' > /tmp/lasco2.$$		#	Remove file size
cat /tmp/lasco2.$$ | grep -vs Submit | grep -vs Option > /tmp/lasco3.$$		#	Remove Submit and Option

#	OPTION with equal either "all", "file", "rest"
#	"file"=Only Marked Files, "rest"=All But Marked Files, "all"=All Listed Files
#	A checked file will be on 2 lines named "file" and "all", unchecked will only be named "all"
#	kinda confuzin, but not my doin
OPTION=`cat /tmp/lasco2.$$ | grep Options | $GAWK -F\= '{print $2}'`

#
#	Determine which files in list to use
#
case $OPTION in
	file)		#	only files with "file" name
		cat /tmp/lasco3.$$ | grep "file=" | $GAWK -F\= '{print $2}' > /tmp/lasco4.$$
		;;
	rest)		#	only files listed once (assuming properly sorted)
		cat /tmp/lasco3.$$ | $GAWK -F\= '{print $2}' | uniq -u > /tmp/lasco4.$$
		;;
	all)			#	all files
		cat /tmp/lasco3.$$ | grep "all=" | $GAWK -F\= '{print $2}' > /tmp/lasco4.$$
		;;
esac

#	
#	Output data to 'form' so will be passed on down the line
#
cat /tmp/lasco4.$$ | $GAWK '{print "<INPUT TYPE=HIDDEN NAME=ffile VALUE="$1"\>"}'
/bin/rm -f /tmp/lasco?.$$


#########################################################################################
cat << "EOF"
<p>
<hr>
LASCO Online Movie Making Tool created by Jake Wendt, May 27, 2003<br>
</HTML>
EOF


