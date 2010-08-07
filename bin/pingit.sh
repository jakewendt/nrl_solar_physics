#!/bin/sh
#
#	born:	late 2001
#
#	purpose:	to determine the status of IP addresses
#

i=0
while [ $i -le 255 ]
do
	ans=`ping 132.250.160.$i 2`
	if [ "$ans" -eq "132.250.160.$i" ]
	then
		ans=`nslookup 132.250.160.$i | grep Name | gawk '{print $2}'`
		echo "+  132.250.160.$i  $ans" >> outfile
	else
		ans=`nslookup 132.250.160.$i | grep Name | gawk '{print $2}'`
		if [ "$ans" = "" ]
		then
                	echo "-  132.250.160.$i" >> outfile
		else
			echo "?  132.250.160.$i  $ans" >> outfile
                fi
	fi
	i=`expr $i + 1`
done


