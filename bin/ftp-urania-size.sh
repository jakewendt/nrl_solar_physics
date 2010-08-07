#! /bin/sh -a
#
#       ftp-urania-size
#
#
#       born    020301
#	by      theJake
#
#	purpose:	returns the file size on urania of $1
#



#	ftpsize=`printf "%s\n" "dir" | ftp urania | grep $1 | gawk '{print $5}'`       #       SmartFTP
ftpsize=`printf "%s\n" "dir" | ftp urania | grep $1 | gawk '{print $3}'`       #       FtpXQ
ftpsize=${ftpsize:-0}
echo $ftpsize

#
#	end ftp-urania-size
#