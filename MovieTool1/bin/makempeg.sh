#!/bin/sh
#
#	$ROOT/makempeg.sh ../ImageDir.$$.mpg $INDIR
#
#	$1 = Output MPEG File Name
#	$2 = Source Directory
#

BIN=/net/louis14/export/home/apache/share/cgi-bin/MovieTool/bin

echo "PATTERN     IBBPBBPBBPBB" > /tmp/mpegparams.$$
echo "OUTPUT      $1" >> /tmp/mpegparams.$$
echo "GOP_SIZE 12" >> /tmp/mpegparams.$$
echo "SLICES_PER_FRAME  1" >> /tmp/mpegparams.$$
echo "BASE_FILE_FORMAT  PPM" >> /tmp/mpegparams.$$
echo "INPUT_CONVERT  $BIN/giftoppm *" >> /tmp/mpegparams.$$
echo "INPUT_DIR   $2" >> /tmp/mpegparams.$$
echo "INPUT" >> /tmp/mpegparams.$$

cd $2
for each in `/bin/ls -1 *.gif`
do
echo "$each" >> /tmp/mpegparams.$$
done

echo "END_INPUT" >> /tmp/mpegparams.$$
echo "PIXEL    HALF" >> /tmp/mpegparams.$$
echo "RANGE    8" >> /tmp/mpegparams.$$
echo "PSEARCH_ALG LOGARITHMIC" >> /tmp/mpegparams.$$
echo "BSEARCH_ALG SIMPLE" >> /tmp/mpegparams.$$
echo "IQSCALE     4" >> /tmp/mpegparams.$$
echo "PQSCALE     4" >> /tmp/mpegparams.$$
echo "BQSCALE     4" >> /tmp/mpegparams.$$
echo "REFERENCE_FRAME   DECODED" >> /tmp/mpegparams.$$
echo "FORCE_ENCODE_LAST_FRAME" >> /tmp/mpegparams.$$


echo "<PRE>"
$BIN/mpeg_encode /tmp/mpegparams.$$
echo "</PRE>"

/bin/rm /tmp/mpegparams.$$

