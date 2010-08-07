#! /bin/sh
#
#
#	begin script jset
#
#	author:	the Jake
#	born:	000726
#
#	Attempting to mimic a Windows Registry
#
#	purpose:	write a value to the REGISTER
#

if [ $# -ne 2 ]
then
	echo "ERROR:  jset VARIABLE VALUE"
	echo "VALUEs with wildcards must be wrapped in quotes"
	exit 1
fi

line=`gawk --assign=vari="$1" -F= '$1 == vari {print NR}' $bin/REGISTER`

if [ -z "$line" ]
then	#	new variable
	echo $1"="$2 >> $bin/REGISTER
else	#	changing existing value
	stop=`expr $line - 1`
	head -$stop $bin/REGISTER > $bin/tempregister
	echo $1"="$2 >> $bin/tempregister
	start=`expr $line + 1`
	tail +$start $bin/REGISTER >> $bin/tempregister
	mv $bin/tempregister $bin/REGISTER
fi
exit 0

#
#	end script jset
#
