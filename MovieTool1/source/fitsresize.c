
#include <stdio.h>
#include "fitsio.h"

int main(int argc, char *argv[])
{
	fitsfile *infptr, *outfptr;   /* FITS file pointers defined in fitsio.h */
	int status = 0, ii = 1;       /* status must always be initialized = 0  */
	long outsize[2]={2048,2048};

	if (argc != 5)
	{
		printf("Usage:  fitsresize inputfile outputfile outxsize outysize\n");
		printf("\n");
		printf("\n");
		printf("Examples:\n");
		printf("\n");
		printf("fitsresize in.fit out.fit 1024 1024\n");
		printf("\n");
		return(0);
	}

	/* Open the input file */
	if ( !fits_open_file(&infptr, argv[1], READONLY, &status) )
	{
		/* Create the output file */
		if ( !fits_create_file(&outfptr, argv[2], &status) )
		{
			/* Copy every HDU until we get an error */
			while( !fits_movabs_hdu(infptr, ii++, NULL, &status) )
				fits_copy_hdu(infptr, outfptr, 0, &status);
			/* Reset status after normal error */
			if (status == END_OF_FILE) status = 0;

			fits_resize_img ( outfptr, 16, 2, outsize, &status);

			fits_close_file(outfptr,  &status);
		}
	fits_close_file(infptr, &status);
	}

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);
}

