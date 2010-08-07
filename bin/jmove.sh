#! /bin/sh
#
#
#	begin script jmove
#
#	author:	the Jake
#	born:	000626
#
#	purpose:	to move files verbosely
#

DEST=`echo $* | gawk '{print $NF}'`

if [ $# -lt 2 ]
then
	echo
	echo "Usage:    jmove what where"
	echo "Example:  jmove HOME/test.* HOME/scripts"
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

echo
while [ $# -gt 1 ]
do
	if [ -f $1 ]
	then
		echo "  Moving  $1  to  $DEST"
		/bin/mv $1 $DEST
	else
		echo "  ERROR: Cannot find $1"
	fi
	shift
done
echo

#
#	end script jmove
#
