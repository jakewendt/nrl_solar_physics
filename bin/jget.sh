#! /bin/sh
#
#
#	begin script jget
#
#	author: the Jake
#	born:   000726
#
#	Attempting to mimic a Windows Registry
#
#	purpose:	read a value from the REGISTER
#


gawk --assign=vari="$1" -F= '$1 == vari {print $2}' $bin/REGISTER

#
#	end script jget
#