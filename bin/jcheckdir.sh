#!/bin/sh
#
#	jcheckdir
#
#	Jake utility to quickly check that a 
#		computer/directory exists and is 
#		readable/writeable
#


if [ $# -lt 1 ]; then
        echo
        echo "Usage:    jcheckdir <directoryname>"
        echo "Example:  jcheckdir /net/hera"
        echo
        exit 1
fi 


if [ ! -d "$1" ]
then 
	echo "1"	#	failure
else
	echo "0"	#	success
fi



# still working on this
