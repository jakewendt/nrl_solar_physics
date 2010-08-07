#! /bin/sh -a
#
#	begin script GetNewQLData.sh
#
#	author:	the Jake
#	born:	000626
#
#	001011 the Jake - Copying img_hdrs to solardata for backup
#	010831 the Jake - Adding lines to automate removal of
#			level_05 directory
#	0110   the Jake	- Removed lines to automate removal of
#			level_05 directory after dissaster
#
#	part of FirstShift
#
#	purpose:	Download and process the new QL data
#

YREL=`cat $FIRST_DIR/scripts/y_rel`
YQKL=`cat $FIRST_DIR/scripts/y_qkl`
LOG="$LG/QL_$YREL.log"

date >> $LOG
echo " --- BEGIN --- " >> $LOG

$FIRST_DIR/scripts/SetToday >> $LOG

echo "TESTING PURPOSES"
echo "IDL_PATH: $IDL_PATH"
echo "QL_ARCH : $QL_ARCH"
echo "QL_TEMP : $QL_TEMP"
echo "TMFILES : $TMFILES"
echo

#---------------------
#	Remove a day from QuickLook Level 05 Data
#firstday=`/bin/ls -1d $IMAGES/level_05/0* | head -1`
#echo "Removing $firstday"
#/bin/rm -rf $firstday/*/*
#/bin/rm -rf $firstday/*
#/bin/rm -rf $firstday
#---------------------

jmove $QL_TEMP/ELASC*L $QL_ARCH >> $LOG
jmove $TMFILES/ELASC*L $QL_TEMP >> $LOG

cd $TMFILES
jpull "soc.nascom.nasa.gov/tlm\_files/ELASCL/\*$YREL\_\*\.REL" >> $LOG
jpull "soc.nascom.nasa.gov/tlm\_files/ELASCH/\*$YREL\_\*\.REL" >> $LOG
$FIRST_DIR/scripts/GetQKL "$YQKL" >> $LOG

$FIRST_DIR/scripts/RemoveXFiles >> $LOG

$IDL_DIR/bin/idl -32 $FIRST_DIR/scripts/unpack.pro >> $LOG

$FIRST_DIR/scripts/Check4Dups >> $LOG
$FIRST_DIR/scripts/IDLScript "$YREL" >> $LOG

echo " ---- END ---- " >> $LOG
date >> $LOG

#
#	end script GetNewQLData.sh
#
