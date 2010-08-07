#!/bin/sh -v
#
#
#	fitstogif linear scale converter
#

imin=`imagemin $1`
echo "Min : $imin"

if [ ${imin} -ne 0 ]
then 
	constarith $1 / $imin /tmp/$$.A.$1					#	Minimum = 1
	constarith /tmp/$$.A.$1 - 1 /tmp/$$.B.$1			#	Minimum = 0
else 
	cp $1 /tmp/$$.B.$1
fi

imax=`imagemax /tmp/$$.B.$1`
echo "Max : $imax"
factor=`jexpr $imax / 16000`
echo "Factor: $factor"

constarith /tmp/$$.B.$1 / $factor /tmp/$$.C.$1			#	Maximum = 16000

pruneimage /tmp/$$.C.$1 16000 0 /tmp/$$.D.$1			#	Sets Datamin and Datamax keywords

tofitsbp16 /tmp/$$.D.$1 /tmp/$$.E.$1

fitstopgm /tmp/$$.E.$1 | pnmflip -tb | pnmscale -xysize 1024 1024 | ppmtogif > $1.gif

/bin/rm /tmp/$$.?.$1

