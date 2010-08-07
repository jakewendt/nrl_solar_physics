#! /bin/sh
#
#
#	begin script jpush
#
#
#	author: the Jake
#	born: 	000614
#
#	purpose: push over $1(file) to $2(computer) via ftp
#
#	requires .netrc to have the necessary settings for $2
#
#	Mods:	000810	the Jake	changed to allow listing of files
#

if [ $# -lt 2 ]; then
	echo
	echo "Usage:    jpush <filename> <computer-name>"
	echo "     ie.  jpush what to-where"
	echo "Example:  jpush lz050454.iso hera"
	echo
	exit 1
fi 

WHERE=`echo $@ | gawk '{print $NF}'`

while [ $# -ge 2 ]
do
	echo "jpushing $1 to $2"
	printf "%b\n%b\n%s\n%s\n%s\n%s\n" "prompt" "bin" "put $1" "quit" \
			| ftp -v $WHERE
	shift
done

exit

#
#	end script jpush
#
