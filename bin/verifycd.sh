#!/bin/sh
#
#	begin script verify-cd
#
#	born on 020321
#
#	by jake
#
#	purpose:	verify the contents of special cds burnt
#
#	example:	verifycd /net/corona/cplex1/avourlid/vault/level_05/cd4/
#			compares listing (4 dirs deep) of cdrom and $1
#

currdir=`pwd`


cd /cdrom/cdrom0
/bin/ls -lL * | gawk '{print $5,$9}' > $currdir/verifycd-cd
/bin/ls -lL */* | gawk '{print $5,$9}' >> $currdir/verifycd-cd
/bin/ls -lL */*/* | gawk '{print $5,$9}' >> $currdir/verifycd-cd
/bin/ls -lL */*/*/* | gawk '{print $5,$9}' >> $currdir/verifycd-cd

cd $1
/bin/ls -lL * | gawk '{print $5,$9}' > $currdir/verifycd-hd
/bin/ls -lL */* | gawk '{print $5,$9}' >> $currdir/verifycd-hd
/bin/ls -lL */*/* | gawk '{print $5,$9}' >> $currdir/verifycd-hd
/bin/ls -lL */*/*/* | gawk '{print $5,$9}' >> $currdir/verifycd-hd

cd $currdir
diff verifycd-?d


#
#	end script verify-cd
#
