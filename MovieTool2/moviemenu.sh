
#!/bin/sh
#	
#	moviemenu.sh by jake
#

DIR="/export/home/apache/share/htdocs/lasco-www/MovieTool"

read form_args

echo Content-type: text/html
echo 

echo "<html> <head> <title> LASCO Movie Machine </title> </head>"

cat html/body1

cat html/moviemenuform

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

cat html/footer

