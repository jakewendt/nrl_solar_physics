#! /bin/sh -a
#
#       ftp-urania-size
#
#
#       born    020301
#	by      jake
#
#	purpose:	returns the file size on $1 of $2
#				tested really only for urania
#



#	ftpsize=`printf "%s\n" "dir" | ftp $1 | grep $2 | gawk '{print $5}'`       #       SmartFTP
ftpsize=`printf "%s\n" "dir" | ftp $1 | grep $2 | gawk '{print $3}'`       #       FtpXQ
ftpsize=${ftpsize:-0}
echo $ftpsize

#
#	end ftp-urania-size
#
