#! /bin/sh
#
#	function SizeToDo
#
#	originally inside CDMaker Software
#
#	020301 - Jake - Added so|SO option for making the RAW SO CDs
#
#	purpose:	called from DataStatus, CDMaker and RawLZCD Software
#
#	returns:	sum of file sizes available to be burnt to CD
#


case $1 in
	qq|ql|lz|eit|final)
		CDLGS=$CDMAKER/CDLOGS

		cd `jget $1.DATA`

#		LASTDATE=`cat $CDLGS/$1.log | gawk '{lastdate=$2} END {print lastdate}' \
#				| gawk -F/ '{print $1}'`
#		LASTCAM=`cat $CDLGS/$1.log | gawk '{lastcam=$2} END {print lastcam}' \
#				| gawk -F/ '{print $2}'`
		LASTDATE=`tail -1 $CDLGS/$1.log | gawk '{print $2}' | \
				gawk -F/ '{print $1}'`
		LASTCAM=`tail -1 $CDLGS/$1.log | gawk '{print $2}' | \
				gawk -F/ '{print $2}'`

		CAMS=`jget $1.CAMS`
		NUM=`/bin/ls -1d [0-8]*/$CAMS | /bin/grep -ns $LASTDATE/$LASTCAM | \
				gawk -F: '{print $1}'`
		/bin/du -k [0-8]*/$CAMS | tail +$NUM | gawk '{S+=$1} END {print S}'
		;;
	misclz|miscql)
		cd `jget $1.DATA`

		LASTDIR=`tail -1 $CDMAKER/CDLOGS/$1.log | gawk '{print $2}'`

		/bin/ls -1d [cdl]*/*/9* | sort -t / -k 3 > $CDMAKER/$1.list
		/bin/ls -1d [cdl]*/*/0* | sort -t / -k 3 >> $CDMAKER/$1.list
		NUM=`cat $CDMAKER/$1.list | grep -ns $LASTDIR | gawk -F: '{print $1}'`
		/bin/du -k `tail +$NUM $CDMAKER/$1.list` | gawk '{S+=$1} END {print S}'
		;;
	so|SO)
		LOG=$RAWLZCD/cdlog
		NEXTDAY=`tail -1 $LOG | gawk '{print $2}'`
		
		#NUM=`/bin/ls -1d $SOCDRAW/SO_ALL_LZ* | grep -n $NEXTDAY | gawk -F: '{print $1}'`
		#/bin/du -sk $SOCDRAW/SO_ALL_LZ* | tail +$NUM | gawk '{S+=$1} END {print S}'
		NUM=`/bin/ls -1d $SOCDRAW/200* | grep -n $NEXTDAY | gawk -F: '{print $1}'`
		/bin/du -sk $SOCDRAW/200* | tail +$NUM | gawk '{S+=$1} END {print S}'
		;;
	*)	exit 1
		;;
esac

#
#	end SizeToDo
#
