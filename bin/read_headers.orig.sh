#! /bin/sh
#
#
#	begin script read_headers
#
#	author:	the Jake
#	born:	000620
#
#	purpose:	primarily called from CDMaker/VerifyCDFiles
#			tries to read the headers on all FITS files on CD
#
#	010130 - the Jake - Jukebox full of EIT's.
#		EIT to be done individually from
#		local CDROM drive.
#	010302 - the Jake - Jukebox full of LZ'.
#		LZ and QL to be done from local CDROM
#



if [ $# -ne 2 ]
then
	/usr/ucb/echo
	/usr/ucb/echo "Usage:  read_headers CDTYPE 4-digit-CDNUM"
	/usr/ucb/echo
	/usr/ucb/echo "Example:  read_headers ql 0711"
	/usr/ucb/echo "Example:  read_headers eit 0271"
	/usr/ucb/echo "Example:  read_headers lz 0457"
	/usr/ucb/echo
	exit 1
fi

CDNUM=$2

case $1 in
#	lz)	if [ -d /jukepc/lz_05/$CDNUM ]
#		then
#			/usr/ucb/echo "CD located."
#			cd /jukepc/lz_05/$CDNUM/lasco_lz/level_05
#		else
#			/usr/ucb/echo "Unable to locate specified CD."
#			exit 1
#		fi
#		;;
#	ql)	if [ -d /cdrom/ql_05_$CDNUM ]
#		#	if [ -d /jukepc/ql_05/$CDNUM ]
#		then
#			/usr/ucb/echo "CD located."
#		#	cd /jukepc/ql_05/$CDNUM/lasco_ql/level_05
#			cd /cdrom/ql_05_$CDNUM/lasco_ql/level_05
#		else
#			/usr/ucb/echo "Unable to locate specified CD."
#			exit 1
#		fi
#		;;
#	eit)	if [ -d /cdrom/eit_05_$CDNUM ]
#		#	if [ -d /jukepc/lz_eit/$CDNUM ]
#		then
#			/usr/ucb/echo "CD located."
#		#	cd /jukepc/lz_eit/$CDNUM/eit_lz/level_05
#			cd /cdrom/eit_05_$CDNUM/eit_lz/level_05
#		else
#			/usr/ucb/echo "Unable to locate specified CD."
#			exit 1
#		fi
#		;;
	xfinal)
		DIR=`jget $1.DIR`
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
		CDID=`jget $1.cdid`
		CDROOT="/cdrom/$CDID$CDNUM"
		#CDROOT="/cdrom/"$1"_05_"$CDNUM
		#	CDROOT=`jget $1.CDDIR`
		#	CDROOT=$CDROOT/$CDNUM
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

for ftsfile in `ls -1 */*/*.fts`
do
	read_fits_hdr $ftsfile
done

#
#	end script read_headers
#
