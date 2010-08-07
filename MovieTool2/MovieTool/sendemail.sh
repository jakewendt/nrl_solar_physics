#!/bin/sh


echo "" > /tmp/email.$$.html
echo "The LASCO/EIT animated gif that you created is ready at ... " >> /tmp/email.$$.html
echo "http://lasco-www.nrl.navy.mil/MovieTool/$1" >> /tmp/email.$$.html
echo "" >> /tmp/email.$$.html
echo "ThanX for choosing LASCO/EIT for all your space weather needs." >> /tmp/email.$$.html
echo "" >> /tmp/email.$$.html
/usr/ucb/mail -s "LASCO/EIT animated gif is ready." jakewendt@nrl.navy.mil < /tmp/email.$$.html
/bin/rm /tmp/email.$$.html

