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
#
#	purpose:	primarily called from CDMaker\VerifyCDFiles
#			copies all JPGs on a CD to the TRASH and then deletes them
#
#


if [ $# -ne 2 ]
then
	/usr/ucb/echo
	/usr/ucb/echo "Usage:  copy_jpegs CDTYPE 4-digit-CDNUM"
	/usr/ucb/echo
	/usr/ucb/echo "Example:  copy_jpegs ql 0711"
	/usr/ucb/echo "Example:  copy_jpegs lz 0457"
	/usr/ucb/echo "Example:  copy_jpegs eit 0270"
	/usr/ucb/echo
	exit 1
fi

CDNUM=$2

case $1 in
#		lz)	if [ -d /jukepc/lz_05/$CDNUM ]
#			then
#				/usr/ucb/echo "CD located."
#				cd /jukepc/lz_05/$CDNUM/lasco_lz/level_05
#			else
#				/usr/ucb/echo "Unable to locate specified CD."
#				exit 1
#			fi
#			;;
#        ql)	if [ -d /cdrom/ql_05_$CDNUM ]
#			#     if [ -d /jukepc/ql_05/$CDNUM ]
#			then
#				/usr/ucb/echo "CD located."
#			#	cd /jukepc/ql_05/$CDNUM/lasco_ql/level_05
#				cd /cdrom/ql_05_$CDNUM/ql_05/level_05
#			else
#				/usr/ucb/echo "Unable to locate specified CD."
#				exit 1
#			fi
#			;;
#       eit)	if [ -d /cdrom/eit_05_$CDNUM ]
#			#	if [ -d /jukepc/lz_eit/$CDNUM ]
#			then
#				/usr/ucb/echo "CD located."
#			#	cd /jukepc/lz_eit/$CDNUM/eit_lz/level_05
#				cd /cdrom/eit_05_$CDNUM/eit_lz/level_05
#			else
#				/usr/ucb/echo "Unable to locate specified CD."
#				exit 1
#			fi
#                ;;

	xfinal)		DIR=`jget $1.DIR`
			CDROOT="/cdrom/fi_05_"$CDNUM

			if [ -d $CDROOT ]
			then
				/usr/ucb/echo "CD located."
				cd $CDROOT/$DIR/level_05
			else
				/usr/ucb/echo "Unable to locate specified CD."
				exit 1
			fi
			;;
	lz|eit|ql|final)
			DIR=`jget $1.DIR`
			#CDROOT="/cdrom/"$1"_05_"$CDNUM
			CDID=`jget $1.cdid`
			CDROOT="/cdrom/$CDID$CDNUM"

			if [ -d $CDROOT ]
			then
				/usr/ucb/echo "CD located."
				cd $CDROOT/$DIR/level_05
			else
				/usr/ucb/echo "Unable to locate specified CD."
				exit 1
			fi
			;;
	*)	/usr/ucb/echo
                /usr/ucb/echo "Invalid CD type. (ql,eit or lz only)"
                /usr/ucb/echo
                exit 1
		;;
esac

pwd

for ftsfile in `ls -1 */*/*.jpg`
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
	ftsfile=`/usr/ucb/echo $ftsfile | awk -F/ '{print $3}'`
	chmod u+w $trash/$ftsfile
	/bin/rm $trash/$ftsfile
	echo "Removed."
done

#
#	end script copy_jpegs
#
