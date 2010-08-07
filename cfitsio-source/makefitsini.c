/*

	makefits.c

	born 020626

	author jake

	version 021016

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

/*
int fitscopy ( char *infile, char *outfile );
int appendheader ( char *outfile, char *infile );
int addkey(char *outfile, char *keyword, char *keyvalue);
int read_ini ( char *inifilename, char *fitsfilename );
*/

int main(int argc, char *argv[])
{

	struct tm *currenttime;
	time_t caltime;
	char filename[30]="\0", fileorig[17]="\0", tempfilename[30]="\0", temp[10]="\0";
        FILE *fp;
        short int naxis;

	if (argc != 3)
	{
		printf("Usage:  makefitsini inputdatafile inputinifile\n");
		printf("\n");
		printf("Examples:\n");
		printf("\n");
		printf("makefitsini in.dat header.ini\n");
		printf("\n");
		printf("Note that it may be necessary to enclose the input data file name\n");
		printf("in single quote characters on the Unix command line.\n\n");
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

	sprintf (filename, "cxx_%04i%02i%02i_%02i%02i%02i.fts",
		(*currenttime).tm_year+1900,
		(*currenttime).tm_mon+1,
		(*currenttime).tm_mday,
		(*currenttime).tm_hour,
		(*currenttime).tm_min,
		(*currenttime).tm_sec);


	#ifdef DEBUG
		printf ("Version : 021016\n");
		printf ("Output filename: %s\n",filename);
	#endif

	strcpy (tempfilename, argv[1]);
	strcat (tempfilename, "[ul");

        if (( fp = fopen ( argv[1], "rb" )) == NULL ) {
                printf ("Cannot open file");
                exit(1);
        }
        fread ( &naxis, 1, 2, fp );		//read first byte from img file

	#ifdef __unix__
        	ffswap2 ( &naxis, 1 );		//only byteswap if on unix machine
	#endif
	sprintf(temp, "%u", naxis);
	strcat(tempfilename, temp);
	strcat(tempfilename, ",");

        fread ( &naxis, 1, 2, fp );		//read second byte from img file
	#ifdef __unix__
        	ffswap2 ( &naxis, 1 );		//only byteswap if on unix machine
	#endif
	sprintf(temp,"%u", naxis);
	strcat(tempfilename, temp);
	strcat (tempfilename, ":4]");
        fclose (fp);

	#ifdef DEBUG
		printf ("%s\n\n", tempfilename);
	#endif

	fitscopy ( tempfilename, filename );
	addkey ( filename, "FILENAME", filename );
	addkey ( filename, "FILEORIG", argv[1] );
	addkey ( filename, "COMMENT", "Converted from IMG to FITS using Jake's makefitsini" );
	read_ini ( argv[2], filename );		//add select keywords from ini file

	return(0);
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
			if (strcmp("COMMENT", keyword))
				printf("%s\n",card);

		/* check if this is a protected keyword that must not be changed */
		if (*card && fits_get_keyclass(card) == TYP_STRUC_KEY)
		{
			printf("Protected keyword cannot be modified.\n");
		}
		else
		{	if (!strcmp("COMMENT", keyword)) 
			{	/* do not overwrite COMMENTs */
				strcpy(newcard, keyword);     /* copy keyword name */
				strcat(newcard, "   ");       /* ' ' value delimiter */
				strcat(newcard, keyvalue);    /* new value */
				printf ("New comment added.\n");
				printf ("%s\n", newcard);
				fits_write_record(outfptr, newcard, &status);
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
		}  
		fits_close_file(outfptr, &status);
	}    /* open_file */

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);
}



int read_ini ( char *inifilename, char *fitsfilename )
{

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
        return(0);
}


