#!/bin/sh
DIR="/net/ares/export/home/ares/majordomo/majordomo-1.94.4/lists/"
echo "Content-type: text/html"
echo 

echo "<HTML>"
echo "<HEAD>"
echo "<TITLE>"
echo "SPACE WEATHER EMAIL "
echo "</TITLE>"
echo "</HEAD>"

echo "<BODY>"

echo "<center>"
echo "<h4>Space Weather Email</h4>"
echo "</center>"

echo "<ul>"

/usr/bin/awk -F\< '{print "<li><a href=\"mailto:"$0"\">"$1"</a>"}' $DIR/spaceweather


echo "</ul>"
echo "</HTML>"



