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


if [ $# -ne 2 ]
then
	echo
	echo "Usage:  copy_jpegs CDTYPE 4-digit-CDNUM"
	echo
	echo "Example:  copy_jpegs ql 0711"
	echo "Example:  copy_jpegs lz 0457"
	echo "Example:  copy_jpegs eit 0270"
	echo
	exit 1
fi

CDNUM=$2

case $1 in
#		lz)	if [ -d /jukepc/lz_05/$CDNUM ]
#			then
#				echo "CD located."
#				cd /jukepc/lz_05/$CDNUM/lasco_lz/level_05
#			else
#				echo "Unable to locate specified CD."
#				exit 1
#			fi
#			;;
#        ql)	if [ -d /cdrom/ql_05_$CDNUM ]
#			#     if [ -d /jukepc/ql_05/$CDNUM ]
#			then
#				echo "CD located."
#			#	cd /jukepc/ql_05/$CDNUM/lasco_ql/level_05
#				cd /cdrom/ql_05_$CDNUM/ql_05/level_05
#			else
#				echo "Unable to locate specified CD."
#				exit 1
#			fi
#			;;
	eit)	#	if [ -d /cdrom/eit_05_$CDNUM ]
			if [ -d /jukepc/lz_eit/$CDNUM ]
			then
				echo "CD located."
				cd /jukepc/lz_eit/$CDNUM/eit_lz/level_05
			#	cd /cdrom/eit_05_$CDNUM/eit_lz/level_05
			else
				echo "Unable to locate specified CD."
				exit 1
			fi
                ;;
	lz|ql)	#	LOCAL
			DIR=`jget $1.DIR`
			CDROOT="/cdrom/"$1"_05_"$CDNUM

			if [ -d $CDROOT ]
			then
				echo "CD located."
				cd $CDROOT/$DIR/level_05
			else
				echo "Unable to locate specified CD."
				exit 1
			fi
			;;
	*)	echo
                echo "Invalid CD type. (ql,eit or lz only)"
                echo
                exit 1
		;;
esac

pwd

for ftsfile in `ls -1 */*/*.jpg`
do
	echo -n "Copying $ftsfile ... "
	if `cp $ftsfile $trash`
	then
		echo -n "Copied ... "
	else
		echo
		echo
		echo "ERROR copying $ftsfile."
		echo
		read pause
	fi
	echo -n "Removing ... "
	ftsfile=`echo $ftsfile | awk -F/ '{print $3}'`
	chmod u+w $trash/$ftsfile
	/bin/rm $trash/$ftsfile
	echo "Removed."
done

#
#	end script copy_jpegs
#
