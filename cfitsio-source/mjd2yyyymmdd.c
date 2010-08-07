
/*

	snaked javascript code from Numerial Recipes for this

*/

#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

int main ( int argc, char* argv[] ) { 

	long ja,jalpha,jb,jc,jd,je, yyyy, julian;
	int dd, mm, ab;
	char s_yyyymmdd[9]="\0";

	if ( argc != 2 ) { 
		printf("\n");
		printf("Usage: mjd2yyyymmdd mjd\n");
		printf("  returns yyyymmdd\n");
		printf("\n");
		printf("  Examples\n");
		printf("    mjd2yyyymmdd 51000\n");
		printf("\n");
		return(0);
	}

	julian=atol(argv[1]) + 2400001;	2400000.5;

	if ( julian > 2299160) {
		jalpha = (long)(((julian-1867216)-0.25) / 36524.25);
		ja = julian + 1 + jalpha - (long)(0.25*jalpha);
	} else 
		ja = julian;

	jb = ja + 1524;
	jc = (long)(6680 +(( jb - 2439870 ) - 122.1 ) / 365.25 );
	jd = (long)(365 * jc + 0.25 * jc );
	je = (long)(( jb - jd ) / 30.6001 );

	dd = jb - jd -(long)(30.6001 * je);
	mm = je - 1;
	if ( mm > 12 ) mm -= 12;
	yyyy = jc - 4715;
	if ( mm > 2 ) --yyyy;
	ab = 1;
	if ( yyyy <= 0 ) { 
		yyyy = 1 - yyyy; 
		ab = -1; 
	}

	sprintf ( s_yyyymmdd, "%ld%02d%02d", yyyy, mm, dd );
	printf("%s\n", s_yyyymmdd );
	return atol(s_yyyymmdd);
}

