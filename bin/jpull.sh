#! /bin/sh
#
#
#	begin script jpull
#
#
#	author: the jake
#	born: 	000622
#
#	purpose: pull over file from computer/pathlisting/filename via ftp
#
#	requires .netrc to have the necessary settings for computer
#
#

if [ `echo $1 | awk -F/ '{print NF}'` -lt 2 ]
then
	echo
	echo "Usage:    jpull 'computer/pathlisting/filename'"
	echo "Example:  jpull 'soc.nascom.nasa.gov/tlm\_files/ELASCL/\*000622\_\*\.REL'"
	echo
	exit 1
fi

echo
COMPNAME=`echo $1 | awk -F/ '{print $1}'`
echo "COMPNAME = $COMPNAME"

PATHNAME=`echo $1 | awk -F/ '{ for (i=2; i<NF; i++) printf $i"/" }'`
echo "PATHNAME = $PATHNAME"

FILENAME=`echo $1 | awk -F/ '{print $NF}'`
echo "FILENAME = $FILENAME"

echo
printf "%b\n%b\n%s\n%s\n%s\n%s\n%s\n%s\n" "prompt" "bin" "cd $PATHNAME" \
		"hash" "mget $FILENAME" "quit" | ftp -v $COMPNAME
echo

#
#	end script jpull
#
