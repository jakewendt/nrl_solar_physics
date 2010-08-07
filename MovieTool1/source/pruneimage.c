#include <string.h>
#include <stdio.h>
#include "fitsio.h"

/*

	LASCO FITS files crash during fftrec (fits_test_record)
	which is called in ffprec (fits_write_record)
	which is in putkey.c

		#define fits_test_record    fftrec
		#define fits_write_record       ffprec

	This call must be commented out be compilation or it 
	just won't work.

*/

int main(int argc, char *argv[])
{
	fitsfile *afptr, *outfptr;  /* FITS file pointers */
	int status = 0;  /* CFITSIO status value MUST be initialized to zero! */
	int anaxis, check = 1, ii, op, keytype;
	long npixels = 1, firstpix[3] = {1,1,1}, ntodo;
	long anaxes[3] = {1,1,1};
	double *apix;
	double maxval, minval;
	char card[FLEN_CARD];

	if (argc != 5) { 
		printf("Usage: pruneimage image max min outimage \n");
		printf("\n");
		printf("Compiled from cfitsio v2.460\n");
		printf("\n");
		printf("Trim off the peaks and valley values of the image.\n");
		printf("\n");
		printf("outimage is of format BITPIX = -32\n");
		printf("\n");
		printf("Example: \n");
		printf("  pruneimage in.fit 1000 850 out.fits - sets all values above 1000 to 1000\n");
		printf("                                            and all values below 850 to 850.\n");
		return(0);
	}

	fits_open_file(&afptr, argv[1], READONLY, &status); /* open input images */
	fits_get_img_dim(afptr, &anaxis, &status);  /* read dimensions */
	fits_get_img_size(afptr, 3, anaxes, &status);

	if (status) {
		fits_report_error(stderr, status); /* print error message */
		return(status);
	}

	if (anaxis > 3) {
		printf("Error: images with > 3 dimensions are not supported\n");
		check = 0;
	}

	maxval = atof ( argv[2] );
	minval = atof ( argv[3] );

	/* create the new empty output file if the above checks are OK */
	if (check && !fits_create_file(&outfptr, argv[4], &status) )
	{
		/* copy all the header keywords from first image to new output file */
		fits_copy_header(afptr, outfptr, &status);

		/* change to floating point variable */
		fits_modify_key_lng (outfptr, "BITPIX", -32, "&", &status );

		fits_modify_key_flt (outfptr, "DATAMIN", minval, -10, "&", &status );
		fits_modify_key_flt (outfptr, "DATAMAX", maxval, -10, "&", &status );

		npixels = anaxes[0];  /* no. of pixels to read in each row */
		apix = (double *) malloc(npixels * sizeof(double)); /* mem for 1 row */

		if (apix == NULL) {
			printf("Memory allocation error\n");
			return(1);
		}

		/* loop over all planes of the cube (2D images have 1 plane) */
		for (firstpix[2] = 1; firstpix[2] <= anaxes[2]; firstpix[2]++)
		{
			/* loop over all rows of the plane */
			for (firstpix[1] = 1; firstpix[1] <= anaxes[1]; firstpix[1]++)
			{
				/* Read both images as doubles, regardless of actual datatype.  */
				/* Give starting pixel coordinate and no. of pixels to read.    */
				/* This version does not support undefined pixels in the image. */
				if (fits_read_pix(afptr, TDOUBLE, firstpix, npixels, NULL, apix,
					NULL, &status)  )
					break;   /* jump out of loop on error */



				for(ii=0; ii< npixels; ii++) {
					if ( apix[ii] > maxval )
						apix[ii] = maxval;
					else if ( apix[ii] < minval )
						apix[ii] = minval;
				}

				fits_write_pix(outfptr, TDOUBLE, firstpix, npixels,
					apix, &status); /* write new values to output image */
			}
		}    /* end of loop over planes */

		fits_close_file(outfptr, &status);
		free(apix);
	}

	fits_close_file(afptr, &status);
	 
	if (status) fits_report_error(stderr, status); /* print any error message */
		return(status);
}

