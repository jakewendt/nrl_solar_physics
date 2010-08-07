
# gawk -f syslg /home/newsome/scratch/syslogs/syslog


BEGIN {
	"date +%b%e" | getline date
    "cat yesterday" | getline today

    today_num = substr(today,4)
    if ( int(today_num) < 10 )	filedaynum = 0 today_num
    else	filedaynum = today_num

    monthname = substr(today,1,3)

    filedate = monthname filedaynum

	system ("/bin/rm -rf "filedate)
    system ("mkdir "filedate)
}

{
    if ( $1$2 == today )
	{
    	split($4, cname, ".")
        split($5, fname, "[")

        filename = cname[1] "." fname[1] "." filedate
        print >> filedate "/" filename
	}
}

END {
    print date	> "yesterday"
}

