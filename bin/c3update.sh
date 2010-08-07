#!/bin/sh

if [ $# -lt 1 ]
then
	echo "\nUsage:  $0 <img_hdr.txt>\n"
	exit 1
fi


lines=`wc -l $1 | gawk '{print $1}'`
i=1

while [ ${i} -le ${lines} ]
do
	echo "Line #${i}"
	tail +${i} $1 | head -1
	line=`tail +${i} $1 | head -1`
	filename=`echo $line | gawk '{print $1}'`
	exptime=`echo $line | gawk '{print $5}'`
	filter=`echo $line | gawk '{print $10}'`
	lp_num=`echo $line | gawk '{print $12}'`
	echo "modhead $filename EXPTIME $exptime"
	modhead $filename EXPTIME $exptime
	echo "modhead $filename FILTER $filter"
	modhead $filename FILTER $filter
	echo "modhead $filename LP_NUM $lp_num"
	modhead $filename LP_NUM $lp_num
	i=`expr $i + 1`
done


