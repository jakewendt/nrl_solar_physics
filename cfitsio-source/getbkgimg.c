
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

long yyyymmdd2mjd( char date[] );
long mjd2yyyymmdd( long mjulian );

int main ( int argc, char* argv[] ) { 
	int i;
	char camera[10]="\0";
	char date[10]="\0";
	char dir[60]="\0";
	char camnum='2';
	char fil[3]="xx\0";
	char pol[3]="xx\0";
	char date6[7]="000000\0";
	char modelfile[30]="\0";
	char fullname[70]="\0";
	long mjd=0, ldate, rota;
	FILE *fp;

	if ( argc < 5 ) { 
		printf("\n");
		printf("Usage: getbkgimg camera yyyymmdd filter polar <optional rotation angle assumed 0>\n");
		printf("  returns name of closest previous model.\n");
		printf("Only for LASCO C2 and C3.\n");
		printf("Dir /net/corona/lasco/monthly hard coded in here.\n");
		printf("REQUIRES 2 char camera\n");
		printf("REQUIRES 8 char date\n");
		printf("\n");
		printf("  Examples\n");
		printf("    getbkgimg C2 20030710 Orange Clear 180\n");
		printf("\n");
		return(0);
	}


//	if ( strlen(argv[1]) != 2 ) exit(1);
	strcpy ( camera, argv[1] );
	camnum = camera[1];

//	if ( strlen(argv[2]) != 8 ) exit(2);
	strcpy ( date, argv[2] );
	mjd = yyyymmdd2mjd ( date ); 
//	printf ("%ld\n", mjd);

	strncpy ( fil, argv[3], 2 );
	for ( i=0; i<strlen(fil); fil[i]=tolower(fil[i++]) );
		
	strncpy ( pol, argv[4], 2 );
	for ( i=0; i<strlen(pol); pol[i]=tolower(pol[i++]) );

	/* environment variables not set for www user	*/
	/* otherwise could use a statement like...		*/
	/* strcpy ( dir, getenv ("MONTHLY_IMAGES") );	*/

	if ( argc == 6 ) {
		rota = atoi ( argv[5] );
	}
	//printf ("%d\n", rota);

	if ( rota > 2 ) {
		strcpy ( dir, "/net/corona/lasco/monthly/rolled" ); 
	} else {
		strcpy ( dir, "/net/corona/lasco/monthly" ); 
	}
	//printf ("%s\n", dir );


	/* loop backward through MJDs until get a hit	*/
	/* 100 days seems to be about the longest gap	*/
	/* that I found between models, but I didn't	*/
	/* do a very thorough check.					*/
	for ( i=0; i<100; i++ ) {

		ldate = mjd2yyyymmdd ( mjd - i );
		sprintf ( date, "%ld", ldate );
		//printf ("- %s\n", date );

		strcpy ( date6, &date[2] );

		if ( rota > 2 ) {
			sprintf( modelfile, "%cmr_%s%s_%s.fts", camnum, fil, pol, date6 ); 
		} else {
			sprintf( modelfile, "%cm_%s%s_%s.fts", camnum, fil, pol, date6 ); 
		}
//		printf ("%s\n", modelfile );

		sprintf( fullname, "%s/%s", dir, modelfile ); 
//		printf ("%s\n", dir );

		if (( fp = fopen (fullname, "r")) == NULL) {
//			printf ("Cannot open file : %s\n", fullname);
		} else {
			printf ("%s\n", fullname );
			fclose(fp);
			break;
		}
	}

	return (0);
}

long yyyymmdd2mjd( char date[] )
{
	char s_year[5]="\0";
	char s_month[3]="\0";
	char s_day[3]="\0";
	int year, month, day;
	double mjd;

	strncpy ( s_year, &date[0], 4 );
	strncpy ( s_month, &date[4], 2 );
	strncpy ( s_day, &date[6], 2 );

	year=atoi( s_year );
	month=atoi( s_month );
	day=atoi( s_day );

	mjd = 367 * year - floor( 7*(year+floor( (month+9)/12))/4) + floor( 275*month/9) + day + 1721013.5 - 2400000.5;

	return( mjd );
}


long mjd2yyyymmdd( long mjulian ) {

	long ja,jalpha,jb,jc,jd,je, yyyy, julian;
	int dd, mm, ab;
	char s_yyyymmdd[9]="\0";

	julian = mjulian + 2400001;	2400000.5;

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

	return atol(s_yyyymmdd);
}

