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
#	030515 - jake - added misclz and miscql stuff
#


#case $1 in
#	xfinal)
#		DIR=`jget $1.DIR`
#		CDROOT="/cdrom/fi_05_"$CDNUM
#		if [ -d $CDROOT ]
#		then
#			/usr/ucb/echo "CD located."
#			cd $CDROOT/$DIR/level_05
#		else
#			/usr/ucb/echo "Unable to locate specified CD."
#			exit 1
#		fi
#		;;
#	lz|eit|ql|final)
#		DIR=`jget $1.DIR`
#		CDID=`jget $1.cdid`
#		CDROOT="/cdrom/$CDID$CDNUM"
#		#CDROOT="/cdrom/"$1"_05_"$CDNUM
#		#	CDROOT=`jget $1.CDDIR`
#		#	CDROOT=$CDROOT/$CDNUM
#		if [ -d $CDROOT ]
#		then
#			/usr/ucb/echo "CD located."
#			cd $CDROOT/$DIR/level_05
#		else
#			/usr/ucb/echo "Unable to locate specified CD."
#			exit 1
#		fi
#		;;
#	*)	/usr/ucb/echo
#		/usr/ucb/echo "Invalid CD type. (ql,eit or lz only)"
#		/usr/ucb/echo
#		exit 1
#		;;
#esac



case $TYPE in
     qq|lz|eit|ql|final)
          cd $CDROOT/$DIR     #/level_05
          ;;
     misclz|miscql)
          cd $CDROOT/$DIR/misc
          ;;
esac


pwd

for ftsfile in `ls -1 */*/*/*.fts`
do
	read_fits_hdr $ftsfile
done

#
#	end script read_headers
#
