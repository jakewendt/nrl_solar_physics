/*

	yyyymmdd2mjd

	by jake - 030610


	Let INT(X) denote the integer part 
	(sometimes known in mathematical circles as the floor function ), 
	let Y be the year, M the month number (1=January, 2=February, etc.), 
	D the day of the month, and UT the universal time. 

	for all AD dates in Gregorian calendar...
	JD - 367*Y - INT(7(Y + INT((M+9)/12))/4)  -  INT(3(INT((Y+(M-9)/7)/100) + 1) /4) + INT (275M/9) + D + 1721028.5 + UT/24

	for dates 1901-2099 Gregorian
	JD = 367Y - INT(7(Y+INT((M+9)/12))/4) + INT (275M/9) + D + 1721013.5 + UT/24


	gcc -lm yyyymmdd2mjd.c -o yyyymmdd2mjd

*/


#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>


int main( int argc, char* argv[] )
{
	//	parse year, month, day
	char date[10]="\0";
	char s_year[5]="\0";
	char s_month[3]="\0";
	char s_day[3]="\0";
	int year, month, day;
	double jd, mjd;

	if ( argc != 2 ) { 
		printf("\n");
		printf("Usage: yyyymmdd2mjd yyyymmdd\n");
		printf("  returns modified julian date\n");
		printf("\n");
		printf("  Examples\n");
		printf("    yyyymmdd2mjd 20030610\n");
		printf("\n");
		return(0);
	}


	strcpy(date, argv[1]);

	strncpy ( s_year, &date[0], 4 );
	strncpy ( s_month, &date[4], 2 );
	strncpy ( s_day, &date[6], 2 );

	year=atoi( s_year );
	month=atoi( s_month );
	day=atoi( s_day );

	jd = 367 * year - floor( 7*(year+floor( (month+9)/12))/4) + floor( 275*month/9) + day + 1721013.5;
	mjd = jd - 2400000.5;
//	mjd--;		/*	subtract one to match our IDL routine for whatever reason	*/

	printf("%ld\n", (long) mjd  );
	return( mjd );
}



/*

These 2 seem to be off by 1.

from IDL's utc2yymmdd.pro
IDL[louis14]>date.mjd = 50072 951221
IDL[louis14]>date.mjd = 50079 951228
IDL[louis14]>date.mjd = 50395 961108
IDL[louis14]>date.mjd = 51057 980901
IDL[louis14]>date.mjd = 51099 981013
IDL[louis14]>date.mjd = 51558 000115
IDL[louis14]>date.mjd = 51696 000601
IDL[louis14]>date.mjd = 51819 001002
IDL[louis14]>date.mjd = 51915 010106

from ....
http://scienceworld.wolfram.com/astronomy/ModifiedJulianDate.html

A modified version of the Julian date denoted MJD obtained by subtracting 2,400,000.5 days from the Julian date JD,

The MJD therefore gives the number of days since midnight on November 17, 1858. This date corresponds to 2400000.5 days after day 0 of the Julian calendar. MJD is still in common usage in tabulations by the U. S. Naval Observatory. Care is needed in converting to other time units, however, as a result of the half day offset (unlike the Julian date, the modified Julian date is referenced to midnight instead of noon) and because of the insertion of semiannual leap seconds (which are inserted at midnight).

The following table gives the modified Julian date for the "zeroth" of each month at 0 UT. So add to get the Julian date of a given day D of the month at a given time .

Month     1997  1998  1999  2000
January   50448 50813 51178 51543
February  50479 50844 51209 51574
March     50507 50872 51237 51603
April     50538 50903 51268 51634
May       50568 50933 51298 51664
June      50599 50964 51329 51695
July      50629 50994 51359 51725
August    50660 51025 51390 51756
September 50691 51056 51421 51787
October   50721 51086 51451 51817
November  50752 51117 51482 51848
December  50782 51147 51512 51878

*/

/*

gcc -lm yyyymmdd2mjd.c -o yyyymmdd2mjd

*/

