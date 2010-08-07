#! /bin/sh
#
#
#	begin script jukeread_headers (special copy of read_headers)
#
#	author:	the Jake
#	born:	000620
#
#	010130 - the Jake - Jukebox full of EIT's.
#		EIT to be done individually from
#		local CDROM drive.
#	010302 - the Jake - Jukebox full of LZ'.
#		LZ and QL to be done from local CDROM
#



if [ $# -ne 2 ]
then
	echo
	echo "Usage:  read_headers CDTYPE 4-digit-CDNUM"
	echo
	echo "Example:  read_headers ql 0711"
	echo "Example:  read_headers eit 0271"
	echo "Example:  read_headers lz 0457"
	echo
	exit 1
fi

CDNUM=$2

case $1 in
#	lz)	if [ -d /jukepc/lz_05/$CDNUM ]
#		then
#			echo "CD located."
#			cd /jukepc/lz_05/$CDNUM/lasco_lz/level_05
#		else
#			echo "Unable to locate specified CD."
#			exit 1
#		fi
#		;;
#	ql)	if [ -d /cdrom/ql_05_$CDNUM ]
#		#	if [ -d /jukepc/ql_05/$CDNUM ]
#		then
#			echo "CD located."
#		#	cd /jukepc/ql_05/$CDNUM/lasco_ql/level_05
#			cd /cdrom/ql_05_$CDNUM/lasco_ql/level_05
#		else
#			echo "Unable to locate specified CD."
#			exit 1
#		fi
#		;;
	eit)#	if [ -d /cdrom/eit_05_$CDNUM ]
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
	lz|ql)
		DIR=`jget $1.DIR`
		CDROOT="/cdrom/"$1"_05_"$CDNUM
		#	CDROOT=`jget $1.CDDIR`
		#	CDROOT=$CDROOT/$CDNUM
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

for ftsfile in `ls -1 */*/*.fts`
do
	read_fits_hdr $ftsfile
done

#
#	end script jukeread_headers
#
