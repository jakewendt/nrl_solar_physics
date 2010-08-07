/*

	makefits.c

	born 020626
	
	author jake


*/


#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "fitsio.h"

/*
int fitscopy ( char *infile, char *outfile );
int appendheader ( char *outfile, char *infile );
int copykey( char *keyword, char *fromfile, char *tofile );
*/

int main(int argc, char *argv[])
{
	struct tm *currenttime;
	time_t caltime;
	char filename[30]="\0", fileorig[17]="\0";

	if (argc != 3)
	{
		printf("Usage:  makefits inputdatafile inputheaderfile\n");
		printf("\n");
		printf("Examples:\n");
		printf("\n")		;
		printf("makefits in.dat[ul2560,2048:4] header.fit\n");
		printf("\n");
		printf("Note that it may be necessary to enclose the input data file name\n");
		printf("in single quote characters on the Unix command line.\n");
		return(0);
	}	

	caltime = time ( NULL );
	currenttime =  gmtime( &caltime );

/*	S = Spacecraft (a,b,d) (d is for "development", or anything
		that is not associated with one or the other s/c);
	T = a digit representing telescope: 1=EUVI, 2=COR1, 3=COR2,
		4=HI1, 5=HI2, 6=GT, 0=generic "development";
	L = a digit representing number of images used to create
		this image, 0 if > 9;
*/

	sprintf (filename, "d01_%04i%02i%02i_%02i%02i%02i.fts",
		(*currenttime).tm_year+1900,
		(*currenttime).tm_mon+1,
		(*currenttime).tm_mday,
		(*currenttime).tm_hour,
		(*currenttime).tm_min,
		(*currenttime).tm_sec);

	printf ("%s\n",filename);
	fitscopy ( argv[1], filename );
	appendheader ( filename, argv[2] );
	addkey ( filename, "FILENAME", filename );
	if (!strcspn (argv[1], "["))
		strcpy(fileorig, argv[1]);
	else
		strncpy(fileorig, argv[1], (strcspn (argv[1], "[")));
	addkey ( filename, "FILEORIG", fileorig );

	return(0);
}


int appendheader ( char *outfile, char *infile )
{
	fitsfile *infptr, *outfptr;         /* FITS file pointer, defined in fitsio.h */
	char card[FLEN_CARD];   /* Standard string lengths defined in fitsio.h */
	int status = 0;   /* CFITSIO status value MUST be initialized to zero! */
	int nkeys, ii;
	char keyword[FLEN_KEYWORD], keyvalue[FLEN_VALUE], keycomment[FLEN_COMMENT];
	char temp[FLEN_KEYWORD];

	strcpy(temp,"COMMENT");
	if (!fits_open_file(&infptr, infile, READONLY, &status))
	{
		if (!fits_open_file(&outfptr, outfile, READWRITE, &status))
		{
			fits_get_hdrspace(infptr, &nkeys, NULL, &status); /* get # of keywords */

			for (ii = 1; ii <= nkeys; ii++) { /* Read and write each keywords */

				if (fits_read_record(infptr, ii, card, &status))break;
				fits_read_keyn(infptr, ii, keyword, keyvalue, keycomment, &status);

                                /* check if this is a protected keyword that must not be changed */
				if (*card && fits_get_keyclass(card) == TYP_STRUC_KEY)
					printf("%s - Protected keyword cannot be modified.\n", keyword);
				else
				{	if (!strcmp(temp, keyword)) 
					{	/* do not overwrite COMMENTs */
						fits_write_record(outfptr, card, &status);
					}
					else
					{
						fits_update_card(outfptr, keyword, card, &status);
					}
                                        printf("Writing - %s\n", card);
				}

			}
			fits_close_file(outfptr, &status);
		}

		if (status == END_OF_FILE)  status = 0; /* Reset after normal error */

		fits_close_file(infptr, &status);
	}
}




int fitscopy ( char *infile, char *outfile) 
{
	fitsfile *infptr, *outfptr;   /* FITS file pointers defined in fitsio.h */
	int status = 0, ii = 1;       /* status must always be initialized = 0  */

	/* Open the input file */
	if ( !fits_open_file(&infptr, infile, READONLY, &status) )
	{
		/* Create the output file */
		if ( !fits_create_file(&outfptr, outfile, &status) )
		{
			/* Copy every HDU until we get an error */
			while( !fits_movabs_hdu(infptr, ii++, NULL, &status) )
				fits_copy_hdu(infptr, outfptr, 0, &status);
 
			/* Reset status after normal error */
			if (status == END_OF_FILE) status = 0;

			fits_close_file(outfptr,  &status);
		}
		fits_close_file(infptr, &status);
	}

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);
}






int addkey(char *outfile, char *keyword, char *keyvalue)
{
	fitsfile *outfptr;         /* FITS file pointer, defined in fitsio.h */
	char card[FLEN_CARD], newcard[FLEN_CARD];
	char oldvalue[FLEN_VALUE], comment[FLEN_COMMENT];
	int status = 0;   /*  CFITSIO status value MUST be initialized to zero!  */
	int keytype;

	if (!fits_open_file(&outfptr, outfile, READWRITE, &status))
	{
		if (fits_read_card(outfptr, keyword, card, &status))
		{
			printf("Keyword does not exist\n");
			card[0] = '\0';
			comment[0] = '\0';
			status = 0;  /* reset status after error */
		}
		else
			printf("%s\n",card);

		/* check if this is a protected keyword that must not be changed */
		if (*card && fits_get_keyclass(card) == TYP_STRUC_KEY)
		{
			printf("Protected keyword cannot be modified.\n");
		}
		else
		{
			/* get the comment string */
			if (*card)fits_parse_value(card, oldvalue, comment, &status);

			/* construct template for new keyword */
			strcpy(newcard, keyword);     /* copy keyword name */
			strcat(newcard, " = ");       /* '=' value delimiter */
			strcat(newcard, keyvalue);    /* new value */
			if (*comment) {
				strcat(newcard, " / ");  /* comment delimiter */
				strcat(newcard, comment);     /* append the comment */
			}

			/* reformat the keyword string to conform to FITS rules */
			fits_parse_template(newcard, card, &keytype, &status);

			/* overwrite the keyword with the new value */
			fits_update_card(outfptr, keyword, card, &status);

			printf("Keyword has been changed to:\n");
			printf("%s\n",card);
		}  
		fits_close_file(outfptr, &status);
	}    /* open_file */

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);
}

















/*

	Don't think these are necessary anymore

*/


int copykey( char *keyword, char *fromfile, char *tofile )
{
	fitsfile *fptr;         /* FITS file pointer, defined in fitsio.h */
	char fromcard[FLEN_CARD], tocard[FLEN_CARD], tempcard[FLEN_CARD];
	char oldvalue[FLEN_VALUE], comment[FLEN_COMMENT];
	int status = 0;   /*  CFITSIO status value MUST be initialized to zero!  */
	int keytype;


	/* Open fromfile and grab keyword and value */
	if (!fits_open_file(&fptr, fromfile, READONLY, &status))
	{
		if (fits_read_card(fptr, keyword, fromcard, &status))
			printf("Keyword does not exist in source.\n");
		else
		{
			printf("Copying the following keyword.\n%s\n",fromcard);
			fits_close_file(fptr, &status);

			/* Open tofile and check for keyword */
			if (!fits_open_file(&fptr, tofile, READWRITE, &status))
			{
				if (fits_read_card(fptr, keyword, tocard, &status))
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
					fits_update_card(fptr, keyword, fromcard, &status);
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
