#!/bin/sh 
#
#	jcheckftp
#
#	Jake utility to quickly check that a 
#		computer exists and is 
#		ftp'able
#


if [ $# -lt 1 ]; then
        echo
        echo "Usage:    jcheckftp <computername>"
        echo "Example:  jcheckftp soc.nascom.nasa.gov"
        echo
        exit 1
fi 

ftpstatus=`printf "%b\n%b\n%s\n%s" "status" "quit" | ftp -v -T 10 $1 | grep "Connected"`
#echo $ftpstatus

if [ -z "$ftpstatus" ]
then
	echo "1"	#	failure
else
	echo "0"	#	success
fi


# still working on this
