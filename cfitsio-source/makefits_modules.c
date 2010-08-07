/*

	makefits_modules.c

	born 021028

	author jake
*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "fitsio.h"


#define MAX_LINE_LENGTH 50
#define MAX_KEYWORD_LENGTH 12
#define MAX_DESC_LENGTH 80	
#define DEBUG

int addkey(char *outfile, char *keyword, char *keyvalue)
{
	fitsfile *fptr;         /* FITS file pointer, defined in fitsio.h */
	char card[FLEN_CARD], newcard[FLEN_CARD], temp[FLEN_CARD];
	char oldvalue[FLEN_VALUE], comment[FLEN_COMMENT];
	int status = 0;   /*  CFITSIO status value MUST be initialized to zero!  */
	int keytype, i;

	if (!fits_open_file(&fptr, outfile, READWRITE, &status))
	{
		#ifdef DEBUG
			if (fits_read_card(fptr, keyword, card, &status))
			{
				printf("Keyword does not exist\n");
				card[0] = '\0';
				comment[0] = '\0';
				status = 0;  /* reset status after error */
			}
			else 
			{
				strcpy (temp, keyword);
				for (i=0; i<FLEN_CARD; i++) 
					temp[i]=toupper(temp[i]);
				if ( strcmp("COMMENT", temp) && strcmp("HISTORY", temp) )
					printf("%s\n",card);
			}
		#endif

		/* check if this is a protected keyword that must not be changed */
		if (*card && fits_get_keyclass(card) == TYP_STRUC_KEY)
		{
			#ifdef DEBUG
				printf("Protected keyword cannot be modified.\n");
			#endif
		}
		else
		{	
			strcpy (temp, keyword);
			for (i=0; i<FLEN_CARD; i++) 
				temp[i]=toupper(temp[i]);
			if ( !strcmp ("COMMENT", temp) )
			{	fits_write_comment ( fptr, keyvalue, &status );
				#ifdef DEBUG
					printf ("New comment added.\n");
				#endif
			}
			else if ( !strcmp ("HISTORY", temp) )
			{	fits_write_history ( fptr, keyvalue, &status );
				#ifdef DEBUG
					printf ("New history added.\n");
				#endif
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
				fits_update_card(fptr, keyword, card, &status);
				#ifdef DEBUG	
					printf("Keyword has been changed to:\n");
					printf("%s\n",card);
				#endif
			}
		}  
		fits_close_file(fptr, &status);
	}    /* open_file */

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);
}

int showkey(char *filename, char *keyword)
{
/*
	function showkey displays keyword and value

	if keyword is COMMENT or HISTORY, it displays all respective lines.

*/


	fitsfile *fptr;         /* FITS file pointer, defined in fitsio.h */
	char card[FLEN_CARD];
	int status = 0, nkeys, i;   /*  CFITSIO status value MUST be initialized to zero!  */

	if (!fits_open_file(&fptr, filename, READONLY, &status))
	{
		for (i=0; i<FLEN_CARD; i++) 
			keyword[i]=toupper(keyword[i]);
		if ( !strcmp(keyword, "COMMENT") || !strcmp(keyword, "HISTORY")) {
			fits_get_hdrspace(fptr, &nkeys, NULL, &status); /* get # of keywords */
			for (i = 1; i <= nkeys; i++) { /* Read and print each keywords */
				if (fits_read_record(fptr, i, card, &status))
					break;
				if ( !strncmp(card, keyword, 7) )
					printf("%s\n", card);
			}
		}
		else {
			if (fits_read_card(fptr, keyword, card, &status))
			{
				printf("Keyword does not exist\n");
				status = 0;  /* reset status after error */
			}
			else 
				printf("%s\n",card);
		}
		fits_close_file(fptr, &status);
	}    /* open_file */

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);
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


int read_ini ( char *inifilename, char *fitsfilename )
{

	int status = 0;   /*  CFITSIO status value MUST be initialized to zero!  */
	FILE *fp;

	size_t length;
	char readline[MAX_LINE_LENGTH];
	char value[MAX_DESC_LENGTH];
	char keyword[MAX_KEYWORD_LENGTH];
	
	#ifdef DEBUG
		printf ("INI filename: %s\n", inifilename);
	#endif

	if (( fp = fopen ( inifilename, "r" )) == NULL ) {
		printf ("Cannot open file.\n");
		exit(1);
	}

	while ( !feof (fp) ) {
		strncpy ( value, "", MAX_DESC_LENGTH );		//fill with NULLs to erase and reset value
		fgets ( readline, MAX_LINE_LENGTH, fp );
		readline[strlen(readline)-1] = '\0';		//crop trailing \n

	//	printf ("----------------\n%s\n", readline);
		length = strcspn ( readline, " " );		//find first (only?) space

		strncpy ( value, readline, length );		//pick off first part
	//	printf (" The value is :%s:\n", value );
		
		strcpy ( keyword, &readline[length+1] );	//pick off last part 
	//	printf (" The keyword is :%s:\n", keyword );


		if ( !strcmp (keyword, "int_time")) addkey ( fitsfilename, keyword, value );
		if ( !strcmp (keyword, "quietTime")) addkey ( fitsfilename, keyword, value );
		if ( !strcmp (keyword, "sysClock")) addkey ( fitsfilename, keyword, value );
	}

	fclose ( fp );

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);
}


int read_footer ( char *imgfile, char *fitsfile, short xsize, short ysize, short bytecount, short offset )
{
	FILE *fp;
	char temp[FLEN_COMMENT];
	int i;
	int status = 0;   /*  CFITSIO status value MUST be initialized to zero!  */

        if (( fp = fopen ( imgfile, "rb" )) == NULL ) {
                printf ("Cannot open file");
                exit(1);
        }

	if ( fseek ( fp, (bytecount*xsize*ysize)+offset, SEEK_SET)) {
		printf ("Failed Seek");
	}
	else 
	{	
		while ( !feof(fp) ) {
			strncpy(temp, "", FLEN_COMMENT);
			fgets ( temp, FLEN_COMMENT, fp );
			for (i=0; i<FLEN_COMMENT; i++) {
				if ( !isprint(temp[i])) 
					temp[i]='\0';
			}
			addkey ( fitsfile, "COMMENT", temp );
			#ifdef DEBUG	
				printf ( "Adding COMMENT from bottom of IMG file:\n" );
				printf ( "%s\n", temp );		
			#endif
		}
	}
	
	fclose(fp);

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);
}


