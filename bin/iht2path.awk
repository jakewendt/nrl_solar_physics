#	iht2path
#
#	USAGE:	gawk -f iht2path [img_hdr.txt formated file]
#
#	by Jake
#
#	purpose:	to generate a file listing with path from
#			an img_hdr.txt formated file
#

BEGIN{
	OFS=""
}

{	split($2, date, "/")

	if ( $4 == "EIT" ) cam="c4"
	else if ( $4 == "C3" ) cam="c3"
	else if ( $4 == "C2" ) cam="c2"
	else cam="c1"

	print "/net/corona/lz/level_05/", substr(date["1"],3,2), date["2"], date["3"], "/", cam, "/", $1
}

#
#	end iht2path
#