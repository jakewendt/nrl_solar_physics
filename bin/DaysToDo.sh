#! /bin/sh
#
#	DaysToDo
#
#	from CDMaker Software
#	by Jake
#
#	purpose:	returns number of Days available to be burnt to CDROM
#
#	030115 - jake - added so
#	030513 - jake - began adding misclz, miscql

case $1 in
	qq|ql|lz|eit|final)
		cd `jget $1.DATA`

		LASTDATE=`tail -1 $CDMAKER/CDLOGS/$1.log | gawk '{print $2}' \
				| gawk -F/ '{print $1}'`

		/bin/ls -1dr [0-8]* | /bin/grep -ns $LASTDATE | gawk -F: '{print $1}'

		;;
	miscql|misclz)
		#	REALLY DIRS TO DO IN THIS CASE
		cd `jget $1.DATA`

		LASTDIR=`tail -1 $CDMAKER/CDLOGS/$1.log | gawk '{print $2}'`

		/bin/ls -1d [cdl]*/*/0* | sort -r -t / -k 3 > $CDMAKER/$1.list
		/bin/ls -1d [cdl]*/*/9* | sort -r -t / -k 3 >> $CDMAKER/$1.list
		cat $CDMAKER/$1.list | grep -ns $LASTDIR | gawk -F: '{print $1}' 
		;;
	so)
		cd `jget $1.DATA`
		LASTDATE=`tail -1 $RAWLZCD/cdlog | gawk '{print $2}'` 
		/bin/ls -1dr 200* | /bin/grep -ns $LASTDATE | gawk -F: '{print $1}'
		;;
	*)	exit 1
		;;
esac



#
#	end DaysToDo
#
