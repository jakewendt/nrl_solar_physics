#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "fitsio.h"

double median ( double *arr, long arrcount );
int compare (const void * a, const void * b);

int main(int argc, char *argv[])
{
	fitsfile *fptr;  /* FITS file pointer */
	int status = 0;  /* CFITSIO status value MUST be initialized to zero! */
	int hdutype, naxis, ii;
	long naxes[2], totpix, fpixel[2], rowlen;
	double *pix, sum = 0., medianval = 0.;	//, minval = 1.E33, maxval = -1.E33;
	double *medarray;

	if (argc != 2) { 
		printf("Usage: imagemedian image \n");
		printf("\n");
		printf("Compute median of pixels in the input image\n");
		printf("(Actually the median of the median of each row.)\n");
		printf("\n");
		printf("Examples: \n");
		printf("  imagemedian image.fits                    - the whole image\n");
//		printf("  imagemedian 'image.fits[200:210,300:310]' - image section\n");
//		printf("  imagemedian 'table.fits+1[bin (X,Y) = 4]' - image constructed\n");
//		printf("     from X and Y columns of a table, with 4-pixel bin size\n");
		printf("\n");
		return(0);
	}

	if ( !fits_open_file(&fptr, argv[1], READONLY, &status) )
	{
		if (fits_get_hdu_type(fptr, &hdutype, &status) || hdutype != IMAGE_HDU) { 
			printf("Error: this program only works on images, not tables\n");
			return(1);
		}

		fits_get_img_dim(fptr, &naxis, &status);
		fits_get_img_size(fptr, 2, naxes, &status);

		if (status || naxis != 2) { 
			printf("Error: NAXIS = %d.  Only 2-D images are supported.\n", naxis);
			return(1);
		}

		pix = (double *) malloc(naxes[0] * sizeof(double)); /* memory for 1 row */
		medarray = (double *) malloc(naxes[1] * sizeof(double)); /* memory for 1 column */

		if (pix == NULL) {
			printf("Memory allocation error\n");
			return(1);
		}

		totpix = naxes[0] * naxes[1];
		fpixel[0] = 1;  /* read starting with first pixel in each row */






//		printf("totpix: %lu\n", totpix);
//		printf("fpixel: %lu\n", fpixel[0]);
//		printf("fpixel: %lu\n", fpixel[1]);
//		printf("Whole : %lu\n", naxes[0]);
//		printf("Mod   : %lu\n", naxes[0]%2);
//		printf("Div   : %lu\n", naxes[0]/2);
//		printf("Whole : %lu\n", naxes[1]-1);
//		printf("Mod   : %lu\n", (naxes[1]-1)%2);
//		printf("Div   : %lu\n", (naxes[1]-1)/2);


		/* process image one row at a time; increment row # in each loop */
		for (fpixel[1] = 1; fpixel[1] <= naxes[1]; fpixel[1]++)
		{  
			/* give starting pixel coordinate and number of pixels to read */
			if (fits_read_pix(fptr, TDOUBLE, fpixel, naxes[0],0, pix,0, &status))
				break;   /* jump out of loop on error */

//	compute row median and store then compute median of medians 
//	not perfect, but pretty close

//		store in medianarray

			medarray[fpixel[1]] = median ( pix, naxes[0] );
//			printf("%g\n", medarray[fpixel[1]]);




//			for (ii = 0; ii < naxes[0]; ii++) {
//				sum += pix[ii];                      /* accumlate sum */
//				if (pix[ii] < minval) minval = pix[ii];  /* find min and  */
//				if (pix[ii] > maxval) maxval = pix[ii];  /* max values    */
//			}
		}
      
		free(pix);
		fits_close_file(fptr, &status);
	}

	if (status)  {
		fits_report_error(stderr, status); /* print any error message */
	} 

 	else {
		printf("%g\n", median ( medarray, naxes[1] ) );


// 		if (totpix > 0) meanval = sum / totpix;
//
//		printf("Statistics of %ld x %ld  image  = %g\n",
//			naxes[0], naxes[1]);
//		printf("  sum of pixels = %g\n", sum);
//		printf("  mean value    = %g\n", meanval);
//		printf("  minimum value = %g\n", minval);
//		printf("  maximum value = %g\n", maxval);
	}

	return(status);
}

double median ( double *arr, long arrcount )
{
	int i;
	double *arrcopy;

	//	reserve memory for copy of arr
	arrcopy = (double *) malloc(arrcount * sizeof(double)); 

	//	create copy of arr
	for ( i=0; i < arrcount; i++ ) 
		arrcopy[i] = arr[i];

	//	sort copy
	qsort ( arrcopy, arrcount, sizeof(double), compare );


	//	return median

	return ( ((arrcount%2)==0) ? 
		(arrcopy[arrcount/2]+arrcopy[(arrcount/2)-1])/2 :
		(arrcopy[arrcount/2]) 
		);
}


int compare (const void * a, const void * b)
{
  return ( *(double*)a - *(double*)b );
}

