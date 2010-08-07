/*

	copykey.c

	born 020626
	
	author jake


*/


#include <string.h>
#include <stdio.h>
#include "fitsio.h"

int main(int argc, char *argv[])
{
	fitsfile *fptr;         /* FITS file pointer, defined in fitsio.h */
	char fromcard[FLEN_CARD], tocard[FLEN_CARD], tempcard[FLEN_CARD];
	char oldvalue[FLEN_VALUE], comment[FLEN_COMMENT];
	int status = 0;   /*  CFITSIO status value MUST be initialized to zero!  */
	int keytype;

	if (argc != 4) 
	{
		printf("Usage:  copykey keyword fromfilename tofilename \n");
		printf("\n");
		printf("Copy keyword and value from one file to another.\n");
		printf("\n");
		printf("Examples: \n");
		printf ("  copykey keyword infile.fits outfile.fits \n");
		return(0);
	}

	/* Open fromfile and grab keyword and value */
	if (!fits_open_file(&fptr, argv[2], READONLY, &status))
	{
		if (fits_read_card(fptr, argv[1], fromcard, &status))
			printf("Keyword does not exist in source.\n");
		else
		{
			printf("Copying the following keyword.\n%s\n",fromcard);
			fits_close_file(fptr, &status);

			/* Open tofile and check for keyword */
			if (!fits_open_file(&fptr, argv[3], READWRITE, &status))
			{
				if (fits_read_card(fptr, argv[1], tocard, &status))
					printf("Keyword does not exist in target.\nWriting.\n");
				else
					printf("Keyword exists in target.\nOverwriting.\n%s\n",tocard);
				status = 0;

				/* check if this is a protected keyword that must not be changed */
				if (*tocard && fits_get_keyclass(tocard) == TYP_STRUC_KEY)
					printf("Protected keyword cannot be modified.\n");
				else
				{
					/* overwrite the keyword with the new value */
					fits_update_card(fptr, argv[1], fromcard, &status);
					
					printf("Keyword has been changed to:\n");
					printf("%s\n",fromcard);
				}
				fits_close_file(fptr, &status);
			}
		} /* open_target */ 
	}    /* open_source */

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);
}

