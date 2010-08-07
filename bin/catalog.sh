#! /bin/sh
#
#
#	begin script catalog
#
#	purpose:  to catalog to contents of the $RAW
#		directory in $1_RAW.contents and $1_RAW.sizes
#		and destroy the data to free up disk space.
#
#	author: the Jake
#	born:	000621
#	
#	modifications
#	000629 - the Jake - set to require parameter to specify QL or LZ
#	000720 - the Jake - changed limit to 1 full month instead of 2
#

case $1 in
	LZ|lz|Lz|lZ)	PRE="LZ_RAW"
		RAW=/net/calliope/data2/lz/raw
		;;
	QL|ql|Ql|qL)	PRE="QL_RAW"
		RAW=/net/calliope/data1/ql/raw
		;;
	*)	echo "Invalid parameter.  (lz or ql only)"
		exit;;
esac

cd $RAW

#	count of dirs that contain the first day of the month.
COUNT=`ls -1dr *01 | grep -c 01`

if [ $COUNT -lt 2 ]
then 
	echo "Please wait until a full month is completed"
	echo "before destroying any data."
	exit
fi

MONTH=`ls -1d *01 | cut -c1-4 | head -1`

echo "Appending $MONTH data to $PRE RAW files."
ls -l $MONTH* >> $PRE.contents
du -k $MONTH* >> $PRE.sizes

echo "Copying new files for backup."
if [ ! -d $LG/.backup ]; then mkdir $LG/.backup; fi
/bin/mv $LG/$PRE.* $LG/.backup/
/bin/cp $PRE.* $LG

if [ $# -ge 2 ]
then
	if [ $2 = NOASK ]; then /usr/xpg4/bin/rm -r $MONTH*; fi
else
	echo "About to destroy $RAW/$MONTH*  "
	echo -n "Do you wish to continue? (yes/no)  "
	read pause
	if [ $pause = "yes" ]
	then
		echo "Destroying the directories $RAW/$MONTH* "
		/usr/xpg4/bin/rm -r $MONTH*
	else
		echo "Having mercy, ehh?  Fine, I won't destroy the enemy."
	fi
fi


#
#	end script catalog
#
