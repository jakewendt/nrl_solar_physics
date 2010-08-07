#!/bin/sh
#
#	return bias 
#
#	based on IDL version
#
#	tested 030613 to match IDL version around all crucial points
#

BIN=/net/louis14/export/home/apache/share/cgi-bin/MovieTool/bin


tel=$1
mjd=`$BIN/yyyymmdd2mjd $2`
port=$3

case $tel in
	C1)	case $port in
			A)	b=364
				;;
			B)	b=331
				;;
			C)	g=`$BIN/jexpr 50395 - $mjd`	#	19961107
				f=`$BIN/jexpr $g / 468.308`
				e=`$BIN/jexpr exp $f`
				d=`$BIN/jexpr 1 - $e`
				c=`$BIN/jexpr 30.739 \* $d`
				b=`$BIN/jexpr 351.958 + $c`
				;;
			D)	b=522
				;;
			*)	b=0
				;;
		esac
		;;
	C2)	case $port in
			A)	b=364
				;;
			B)	b=540
				;;
			C)	firstday=50079				#	19951227
				if [ $mjd -le 51057 ]		#	19980831
				then 
					coeff="470.97732 0.12792513 -3.6621933e-05"	#	before the mispoint
				elif [ $mjd -lt 51819 ]		#	20000101
				then 
					coeff="551.67277 0.091365902 -0.00012637790 7.4049597e-08"	# 	since 1 Sep 98
					firstday=51099			#	19981012
				elif [ $mjd -lt 51915 ]		#	20010105
				then 
					coeff="574.5788 0.019772032"	#	since 1 Oct 00
					firstday=51558			#	20000114
				else		#	therefore [ mjd -ge 51915 ]	#	20010105
					coeff="582.0574 0.016625946"	#	since 1 Oct 00
					firstday=51915			#	20010105
				fi
				dd=`$BIN/jexpr $mjd - $firstday`
				b=`$BIN/jpoly $dd $coeff`
				;;
			D)	b=526
				;;
			*)	b=0
				;;
		esac
		;;
	C3)	case $port in
			A)	b=314
				;;
			B)	b=346
				;;
			C)	if [ $mjd -lt 50072 ]   		#	19951220
				then 
					b=319 
				else 
					if [ $mjd -le 51057 ]	#	19980831
					then 
						coeff="322.21639 0.011775379 4.4256968E-05 -3.167423e-08"	#	before the misspoint
						firstday=50072		#	19951220
					elif [ $mjd -le 51696 ]	#	20000531
					then 
						coeff="354.50857 0.062196067 -8.8114799e-05 5.0505447e-08"	#	since 1 Sep 98
						firstday=51099		#	19981012
					elif [ $mjd -lt 51915 ]	#	20010105
					then 
						coeff="369.02719 0.014994955 -4.0873204e-06"	#	since 1 Jun 00
						firstday=51558		#	20000114
					else		#therefore [ $mjd -ge 51915 ] 	#	20010105
						coeff="373.94898 0.011018500"		#	since 1 Jun 01
						firstday=51915		#	20010105
					fi
					dd=`$BIN/jexpr $mjd - $firstday`
					b=`$BIN/jpoly $dd $coeff`		
				fi
				;;
			D)	b=283
				;;
			*)	b=0
				;;
		esac
		;;
	EIT)	case $port in
			A)	b=1017
				;;
			B)	b=840
				;;
			C)	b=1041
				;;
			D)	b=844
				;;
			*)	b=0
				;;
		esac
		;;
	*)	b=0
		;;
esac


echo $b


