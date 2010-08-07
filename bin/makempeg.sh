#!/bin/sh
#
#	begin script makempeg
#
#
#	by	Jake
#	born 	020403
#
#

if [ $# -ne 2 ]
then
	echo "Bad info"
	exit 1
fi


result=`which giftoppm | gawk 'BEGIN{OFS=""} {print $2,$3,$4}'`

if [ "$result" != "" ]	# = "Command not found."
then
	convert_type='PNM'
	converter='giftopnm'
else
	convert_type='PPM'
	converter='giftoppm'
fi

paramfile='idl2mpeg.params'

echo 'PATTERN     IBBPBBPBBPBB' > $paramfile
echo 'OUTPUT      ' $2   >> $paramfile
echo 'GOP_SIZE 12'   >> $paramfile
echo 'SLICES_PER_FRAME  1'  >> $paramfile
echo 'BASE_FILE_FORMAT  ' $convert_type   >> $paramfile
echo 'INPUT_CONVERT  ' $converter ' *'   >> $paramfile
echo 'INPUT_DIR .'   >> $paramfile
echo 'INPUT'  >> $paramfile

/bin/ls -1 $1/*gif >> $paramfile

echo 'END_INPUT'  >> $paramfile
echo 'PIXEL    HALF'   >> $paramfile
echo 'RANGE    8'  >> $paramfile
echo 'PSEARCH_ALG LOGARITHMIC'  >> $paramfile
echo 'BSEARCH_ALG SIMPLE'  >> $paramfile
echo 'IQSCALE	4'  >> $paramfile
echo 'PQSCALE	4'  >> $paramfile
echo 'BQSCALE	4'   >> $paramfile
echo 'REFERENCE_FRAME	DECODED'  >> $paramfile
echo 'FORCE_ENCODE_LAST_FRAME'  >> $paramfile




mpeg_encode $paramfile


#
#	end script makempeg
#
