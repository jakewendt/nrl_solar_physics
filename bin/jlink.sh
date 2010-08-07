#! /bin/sh
#
#
#	begin script jlink
#
#	born 011115
#	by the jake
#
#	purpose:        create a directory tree and link the file verbosely
#


START=`pwd`
DEST=`echo $* | gawk '{print $NF}'`

if [ $# -lt 2 ]
then
	echo
	echo "Usage:    jlink what where"
	echo "Example:  jlink HOME/test.* HOME/scripts"
	echo "Links file with specified path to destination."
	echo "No quotes.  No wildcards in destination.  No rename."
	echo "Doesn't move hidden files unless specified (.*)"
	echo "Linking also depends on your current location."
	echo
	exit 1
fi

if [ ! -d $DEST ]
then
	echo
	echo "  Destination directory was not found."
	echo
	exit 1
fi

while [ $# -gt 1 ]
do
	if [ -f $1 -o -d $1 ]
	then
		cd $DEST
		echo "  Linking  $1  to  $DEST"
		DESTPATH=$DEST
		for EACHDIR in `echo $1 | gawk -F/ '{ for (i=1; i<NF; i++) print $i " "}'`
		do
			DESTPATH=$DESTPATH/$EACHDIR
			if [ ! -d $EACHDIR ]; then mkdir $EACHDIR; fi
			cd $EACHDIR
		done
		cd $START
		cd $DESTPATH
		/usr/ucb/ln -s $START/$1 $DESTPATH
	else
		echo "  ERROR: Cannot find $1"
	fi
        shift
done

#
#	end script jlink
#
