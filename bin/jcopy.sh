#! /bin/sh
#
#
#	begin script jcopy
#
#	by Jake
#
#	purpose:	copy files and their directory structure
#

START=`pwd`
DEST=`echo $* | gawk '{print $NF}'`

if [ $# -lt 2 ]
then
	echo
	echo "Usage:    jcopy what where"
	echo "Example:  jcopy HOME/test.* HOME/scripts"
	echo "Copies file with specified path to destination."
	echo "No quotes.  No wildcards in destination.  No rename."
	echo "Doesn't move hidden files unless specified (.*)"
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
	if [ -f $1 ]
	then
		cd $DEST
		echo "  Copying  $1  to  $DEST"
		DESTPATH=$DEST
		for EACHDIR in `echo $1 | gawk -F/ '{ for (i=1; i<NF; i++) print $i " "}'`
		do
			DESTPATH=$DESTPATH/$EACHDIR
			if [ ! -d $EACHDIR ]; then mkdir $EACHDIR; fi
			cd $EACHDIR
		done
		cd $START
		/bin/cp $1 $DESTPATH
	else
		echo "  ERROR: Cannot find $1"
	fi
        shift
done

#
#	end script jcopy
#
