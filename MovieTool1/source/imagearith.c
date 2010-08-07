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
	fitsfile *afptr, *bfptr, *outfptr;  /* FITS file pointers */
	int status = 0;  /* CFITSIO status value MUST be initialized to zero! */
	int anaxis, bnaxis, check = 1, ii, op, keytype;
	long npixels = 1, firstpix[3] = {1,1,1}, ntodo;
	long anaxes[3] = {1,1,1}, bnaxes[3]={1,1,1};
	double *apix, *bpix;
	char card[FLEN_CARD];

	if (argc != 5) { 
		printf("Usage: imagearith image1 OPER image2 outimage \n");
		printf("\n");
		printf("Compiled from cfitsio v2.460\n");
		printf("\n");
		printf("Perform arithmetic operation on 2 input images\n");
		printf("creating a new output image.  Supported arithmetic\n");
		printf("operators are add, sub, mul, div (only first character required)\n");
		printf("You can now use the 4 symbols also.\n");
		printf("NEW! Use Greater(g or >) or Lesser(l or <) as operation to return the greater\n");
		printf(" or lesser pixel from either image.  Great for masking!\n");
		printf("\n");
		printf("outimage is of format BITPIX = -32\n");
		printf("\n");
		printf("Example: \n");
		printf("  imagearith in1.fits ADD in2.fits out.fits - add the 2 files\n");
		printf("  imagearith in1.fits a in2.fits out.fits - add the 2 files\n");
		printf("  imagearith in1.fits + in2.fits out.fits - add the 2 files\n");
		printf("  imagearith in1.fits \\* in2.fits out.fits - multiply the 2 files\n");
		printf("  imagearith in1.fits \\> in2.fits out.fits - greater of the 2 files\n");
		printf("  imagearith in1.fits g in2.fits out.fits - greater of the 2 files\n");
		return(0);
	}

	fits_open_file(&afptr, argv[1], READONLY, &status); /* open input images */
	fits_open_file(&bfptr, argv[3], READONLY, &status);

	fits_get_img_dim(afptr, &anaxis, &status);  /* read dimensions */
	fits_get_img_dim(bfptr, &bnaxis, &status);
	fits_get_img_size(afptr, 3, anaxes, &status);
	fits_get_img_size(bfptr, 3, bnaxes, &status);

	if (status) {
		fits_report_error(stderr, status); /* print error message */
		return(status);
	}

	if (anaxis > 3) {
		printf("Error: images with > 3 dimensions are not supported\n");
		check = 0;
	}
	/* check that the input 2 images have the same size */
	else if ( anaxes[0] != bnaxes[0] || 
		anaxes[1] != bnaxes[1] || 
		anaxes[2] != bnaxes[2] ) {
		printf("Error: input images don't have same size\n");
		check = 0;
	}

	if      (*argv[2] == 'a' || *argv[2] == 'A' || *argv[2] == '+' )
		op = 1;
	else if (*argv[2] == 's' || *argv[2] == 'S' || *argv[2] == '-' )
		op = 2;
	else if (*argv[2] == 'm' || *argv[2] == 'M' || *argv[2] == '*' )
		op = 3;
	else if (*argv[2] == 'd' || *argv[2] == 'D' || *argv[2] == '/' )
		op = 4;
	else if (*argv[2] == 'g' || *argv[2] == 'G' || *argv[2] == '>' )
		op = 5;
	else if (*argv[2] == 'l' || *argv[2] == 'L' || *argv[2] == '<' )
		op = 6;
	else {
		printf("Error: unknown arithmetic operator\n");
		check = 0;
	}

	/* create the new empty output file if the above checks are OK */
	if (check && !fits_create_file(&outfptr, argv[4], &status) )
	{
		/* copy all the header keywords from first image to new output file */
		fits_copy_header(afptr, outfptr, &status);

		/* change to floating point variable */
		fits_modify_key_lng ( outfptr, "BITPIX", -32, "&", &status );
		
		npixels = anaxes[0];  /* no. of pixels to read in each row */
		apix = (double *) malloc(npixels * sizeof(double)); /* mem for 1 row */
		bpix = (double *) malloc(npixels * sizeof(double)); 

		if (apix == NULL || bpix == NULL) {
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
					NULL, &status)  ||         
					fits_read_pix(bfptr, TDOUBLE, firstpix, npixels,  NULL, bpix,
					NULL, &status)  )        
					break;   /* jump out of loop on error */

				switch (op) {
					case 1:         
						for(ii=0; ii< npixels; ii++)
							apix[ii] += bpix[ii];
						break;
					case 2:
						for(ii=0; ii< npixels; ii++)
							apix[ii] -= bpix[ii];
						break;
					case 3:
						for(ii=0; ii< npixels; ii++)
							apix[ii] *= bpix[ii];
						break;
					case 4:
						for(ii=0; ii< npixels; ii++) {
							if (bpix[ii] !=0.) 
								apix[ii] /= bpix[ii];
							else
								apix[ii] = 0.;
						}
						break;
					case 5:
						for(ii=0; ii< npixels; ii++)
							apix[ii] = ( apix[ii] - bpix[ii] ) >= 0. ? apix[ii] : bpix[ii];
						break;
					case 6:
						for(ii=0; ii< npixels; ii++)
							apix[ii] = ( apix[ii] - bpix[ii] ) < 0. ? apix[ii] : bpix[ii];
						break;

				}
				fits_write_pix(outfptr, TDOUBLE, firstpix, npixels,
					apix, &status); /* write new values to output image */
			}
		}    /* end of loop over planes */

		fits_close_file(outfptr, &status);
		free(apix);
		free(bpix);
	}

	fits_close_file(afptr, &status);
	fits_close_file(bfptr, &status);
	 
	if (status) fits_report_error(stderr, status); /* print any error message */
		return(status);
}

