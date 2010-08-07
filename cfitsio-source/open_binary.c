

#include <stdio.h>
#include "fitsio2.h"

int main ( int argc, char *argv[] )
{
	FILE *fp;
	short int naxis1, naxis2;

	if (( fp = fopen ( argv[1], "rb" )) == NULL ) {
		printf ("Cannot open file");
		exit(1);
	}
	
	fread ( &naxis1, 1, 2, fp );

	ffswap2 ( &naxis1, 1 );

	printf("%u\n", naxis1 );


	fread ( &naxis2, 1, 2, fp );

	ffswap2 ( &naxis2, 1 );

	printf("%u\n", naxis2 );




	fclose (fp);
	return(0);
}
