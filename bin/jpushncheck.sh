#! /bin/sh
#
#
#	begin script jpushncheck
#
#
#	author: the Jake
#	born: 	000614
#
#	purpose: push over $1(file) to $2(computer) via ftp
#
#	requires .netrc to have the necessary settings for $2
#
#	Mods:	000810	jake	changed to allow listing of files
#			030804	jake	added checking feature to jpush
#

if [ $# -lt 2 ]; then
	echo
	echo "Usage:    jpushncheck <filename> <computer-name>"
	echo "     ie.  jpushncheck what to-where"
	echo "Example:  jpushncheck lz050454.iso hera"
	echo
	exit 1
fi 

Target=`echo $@ | gawk '{print $NF}'`

while [ $# -ge 2 ]
do
	echo "jpushing $1 to $Target"
	printf "%b\n%b\n%s\n%s\n%s\n%s\n" "prompt" "bin" "put $1" "quit" \
			| ftp -v $Target
	
	SourceSize=`/bin/ls -l $1 | gawk '{print $5}'`
	SourceSize=${SourceSize:-1}
	TargetSize=`ftp-size $Target $1`
	TargetSize=${TargetSize:-0}

	if [ $SourceSize -eq $TargetSize ]
	then
		echo "Passed Size Check"
		shift
	else
		echo "Failed Size Check"
		echo "Source : " $SourceSize
		echo "Target : " $TargetSize
	fi
	sleep 5
done


exit

#
#	end script jpushncheck
#
