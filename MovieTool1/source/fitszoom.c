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
	fitsfile *infptr, *outfptr;  /* FITS file pointers */
	int status = 0;  /* CFITSIO status value MUST be initialized to zero! */
	int innaxis, check = 1, i, j, k, op, keytype;
	long npixels = 1, firstpix[2] = {1,1}, outfirstpix[2] = {1,1};
	long innaxes[2] = {1,1};
	double *inpix;
	double *outpix;
	long outsize[2] = {1024,1024};
	int zoomfactor;
	char card[FLEN_CARD];

	if (argc != 4) { 
		printf("Usage: fitszoom inimage integerzoomfactor outimage \n");
		printf("\n");
		printf("Compiled from cfitsio v2.460\n");
		printf("\n");
		printf("outimage is of format BITPIX = -32\n");
		printf("\n");
		printf("Example: \n");
		printf("  fitszoom in.fts 2 out.fts - doubles in.fts \n");
		return(0);
	}

	fits_open_file(&infptr, argv[1], READONLY, &status); /* open input images */

	fits_get_img_dim(infptr, &innaxis, &status);  /* read dimensions */
	fits_get_img_size(infptr, 2, innaxes, &status);

	if (status) {
		fits_report_error(stderr, status); /* print error message */
		return(status);
	}

	if (innaxis > 2) {
		printf("Error: images with > 2 dimensions are not supported\n");
		check = 0;
	}

	zoomfactor = atoi(argv[2]);

	/* create the new empty output file if the above checks are OK */
	if (check && !fits_create_file(&outfptr, argv[3], &status) )
	{
		/* copy all the header keywords from first image to new output file */
		fits_copy_header(infptr, outfptr, &status);

		/* change to floating point variable */
		fits_modify_key_lng (outfptr, "BITPIX", -32, "&", &status );

		/* resize outimage to proper size */
		outsize[0] = innaxes[0] * zoomfactor;
		outsize[1] = innaxes[1] * zoomfactor;
		fits_resize_img (outfptr, -32, 2, outsize, &status );

		npixels = innaxes[0];  /* no. of pixels to read in each row */
		inpix = (double *) malloc(npixels * sizeof(double)); /* mem for 1 in row */
		outpix = (double *) malloc( zoomfactor * npixels * sizeof(double)); /* mem for 1 out row */

		if (inpix == NULL) {
			printf("Memory allocation error\n");
			return(1);
		}

		/* loop over all rows of the plane */
		for (firstpix[1] = 1; firstpix[1] <= innaxes[1]; firstpix[1]++)
		{
			/* Read both images as doubles, regardless of actual datatype.  */
			/* Give starting pixel coordinate and no. of pixels to read.    */
			/* This version does not support undefined pixels in the image. */
			if (fits_read_pix(infptr, TDOUBLE, firstpix, npixels, NULL, inpix,
				NULL, &status)  )
				break;   /* jump out of loop on error */

			/* expand a single line */
			for (i=0; i< npixels; i++) {
				for ( j=1; j<=zoomfactor; j++) {
					outpix[i*zoomfactor +j-1] = inpix[i];
				}
			}

			/* write the line the appropriate number of times */
			for (i=1; i<=zoomfactor; i++) {
				outfirstpix[1] = (firstpix[1]-1) * zoomfactor + i;
				fits_write_pix(outfptr, TDOUBLE, outfirstpix, zoomfactor*npixels,
					outpix, &status); /* write new values to output image */
			}
		}


		fits_close_file(outfptr, &status);
		free(inpix);
	}

	fits_close_file(infptr, &status);
	 
	if (status) fits_report_error(stderr, status); /* print any error message */
		return(status);
}

