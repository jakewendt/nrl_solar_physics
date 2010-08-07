#! /bin/sh -a
#
#
#	begin function FirstShift.sh
#
#	the Jake	-	this function set is to automate the
#		download and processing of the Quick Look data
#
#	030324 - jake - added some system checks

#	EXPLICIT QL VARIABLES
#	equivalent to reduce.env because can't
#	use "source" in bourne shell script
#	not entirely necessary if use
#		source reduce.env
#	before running the initial time.

QLROOT=/net/corona/ql						#	010918

export RAW; 		RAW=$QLROOT/raw
export LEB_IMG; 	LEB_IMG=$QLROOT/leb_img
export TMFILES; 	TMFILES=$QLROOT/tmfiles
export QL_TEMP; 	QL_TEMP=$QLROOT/ECS_YEST
export QL_ARCH; 	QL_ARCH=$QLROOT/ECS
export IMAGES; 		IMAGES=$QLROOT			#	010213
export LAST_IMG; 	LAST_IMG=$QLROOT		#	010213
export TMPCKTS;		TMPCKTS="~reduce/packets"
export FPS_PATH;	FPS_PATH="~reduce/fp_status"
export REDUCE_OPTS;	REDUCE_OPTS="transfer dbms level_05"
export REDUCE_LOG;	REDUCE_LOG=$QLROOT/reduce_log
export DSKPATH;		DSKPATH=$QLROOT

#	$FIRST_DIR is the directory containing FirstShift
#				It is set in my .tcshrc file.


if [ -f $FIRST_DIR/running.token ]
then
	/usr/ucb/mail -s "Another First Shift still running" $OPERATOR < /dev/null
	#	essentially stops automation indefinately
    #	allows for troubleshooting before restarting
    #	requires manual restart
else
	#
	#	Quick check to see if some dirs exist
	#
	if [ ! -d "$TMFILES" ]
	then 
		echo "TMFILES not available"
		exit
	fi
	if [ ! -d "$MVIS" ]
	then 
		echo "MVIS not available"
		exit
	fi
	if [ ! -d "$IDL_DIR" ]
	then 
		echo "IDL_DIR not available"
		exit
	fi

	ftpstatus=`printf "%b\n%b\n%s" "status" | ftp -v -T 10 soc.nascom.nasa.gov | grep "Connected"`
	if [ -z "$ftpstatus" ]
	then
		echo "FTP to soc.nascom.nasa.gov failed"
		exit
	fi


	#
	#	It appears most things are OK. Continue.
	#
	at -s 8:00 tomorrow < $FIRST_DIR/FirstShift.sh
	touch $FIRST_DIR/running.token
	/usr/ucb/mail -s "Beginning the First Shift" $OPERATOR < /dev/null
	$FIRST_DIR/GetNewQLData.sh
	/usr/ucb/mail -s "Ending the First Shift" $OPERATOR < /dev/null
	/bin/rm $FIRST_DIR/running.token
fi




#
#
#	end function FirstShift.sh
#


