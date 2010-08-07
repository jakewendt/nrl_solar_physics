#! /bin/sh
#
#
#	begin script copy_jpegs
#
#
#	010130 - the jake - Jukebox is full of EIT.
#		EIT's to be done individually
#		from the local CDROM drive.
#	010302 - the Jake - Jukebox full of LZ
#		LZ and QL to be done locally
#	030515 - jake - adding misclz and miscql stuff
#
#	purpose:	primarily called from CDMaker\VerifyCDFiles
#			copies all JPGs on a CD to the TRASH and then deletes them
#
#

#case $1 in
#	xfinal)		DIR=`jget $1.DIR`
#			CDROOT="/cdrom/fi_05_"$CDNUM
#
#			if [ -d $CDROOT ]
#			then
#				/usr/ucb/echo "CD located."
#				cd $CDROOT/$DIR/level_05
#			else
#				/usr/ucb/echo "Unable to locate specified CD."
#				exit 1
#			fi
#			;;
#	lz|eit|ql|final)
#			DIR=`jget $1.DIR`
#			#CDROOT="/cdrom/"$1"_05_"$CDNUM
#			CDID=`jget $1.cdid`
#			CDROOT="/cdrom/$CDID$CDNUM"
#
#			if [ -d $CDROOT ]
#			then
#				/usr/ucb/echo "CD located."
#				cd $CDROOT/$DIR/level_05
#			else
#				/usr/ucb/echo "Unable to locate specified CD."
#				exit 1
#			fi
#			;;
#	*)	/usr/ucb/echo
#			/usr/ucb/echo "Invalid CD type. (ql,eit or lz only)"
#			/usr/ucb/echo
#			exit 1
#	;;
#esac

case $TYPE in
	qq|lz|eit|ql|final)
		cd $CDROOT/$DIR	#/level_05
		;;
	misclz|miscql)
		cd $CDROOT/$DIR/misc
		;;
esac

pwd

for ftsfile in `ls -1 */*/*/*.jpg`
do
	/usr/ucb/echo -n "Copying $ftsfile ... "
	if `cp $ftsfile $trash`
	then
		/usr/ucb/echo -n "Copied ... "
	else
		/usr/ucb/echo
		/usr/ucb/echo
		/usr/ucb/echo "ERROR copying $ftsfile."
		/usr/ucb/echo
		read pause
	fi
	/usr/ucb/echo -n "Removing ... "
	ftsfile=`/usr/ucb/echo $ftsfile | awk -F/ '{print $NF}'`
	chmod u+w $trash/$ftsfile
	/bin/rm $trash/$ftsfile
	echo "Removed."
done

#
#	end script copy_jpegs
#
