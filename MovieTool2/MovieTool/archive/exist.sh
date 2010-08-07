#!/bin/sh

echo Content-type: text/html
echo

DIR="/export/home/apache/share/htdocs/lasco-www/MovieTool"
WEB="http://lasco-www.nrl.navy.mil/MovieTool"

#begin a form here with checkboxes by each image
# download
# js movie
# java movie
# anim gifs
# mpeg

echo "<html> <head> <title> Make movie from existing gifs </title> </head>"

cat $DIR.source/body1
cat $DIR.source/existform


cd $DIR

for each in `/bin/ls -1r */*.gif`
do
	echo "<INPUT TYPE=checkbox name=image value=$each>"
	echo "<a href=\"$WEB/$each\">$each</a><br>\n"
done

cat $DIR.source/footer 

