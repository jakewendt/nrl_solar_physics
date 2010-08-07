/*

	born 021023

	author jake

	version 021023

	Java Native C code for MakeFITSGUI

*/

#include <jni.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "fitsio.h"
#include "MakeFITSGUI.h"

#define MAX_LINE_LENGTH 50
#define MAX_KEYWORD_LENGTH 12
#define MAX_DESC_LENGTH 80	
#define FILENAMELEN 128
#define DEBUG


JNIEXPORT jint JNICALL Java_MakeFITSGUI_MakeFITS
  (JNIEnv *env, jobject jobj, jstring jimgpathname, jstring jimgfilename, jstring jimgdate)
{
	struct tm *currenttime;
	time_t caltime;
	char filename[FILENAMELEN]="\0";
	char fileorig[FILENAMELEN]="\0";
	char tempfilename[FILENAMELEN]="\0";
	char temp[FLEN_COMMENT]="\0";
	char filedate[20]="\0";
	char fitsname[FILENAMELEN]="\0";
        FILE *fp;
        short int naxis1, naxis2, charint, i;


	/* Convert Java String into C String */
	const jbyte *str;
	str = (*env)->GetStringUTFChars(env, jimgpathname, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(filename, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jimgpathname, str);


	str = (*env)->GetStringUTFChars(env, jimgfilename, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(fileorig, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jimgfilename, str);


	str = (*env)->GetStringUTFChars(env, jimgdate, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(filedate, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jimgdate, str);


	#ifdef DEBUG
		#if defined(__linux__)
			printf("Running on a Linux Machine.\n");
		#elif defined(_WIN32)
			printf("Running on a Windows Machine.\n");
		#elif defined(__unix__) && !defined(__linux__)
			printf("Running on a Unix Machine.\n");
		#else
			//#error unrecognised machine
			printf("Don't know what machine you are running.\nUse caution and please contact Jake.\n");
		#endif
	#endif

	caltime = time ( NULL );
	currenttime =  gmtime( &caltime );

/*	S = Spacecraft (a,b,d) (d is for "development", or anything
		that is not associated with one or the other s/c);
	T = a digit representing telescope: 1=EUVI, 2=COR1, 3=COR2,
		4=HI1, 5=HI2, 6=GT, 0=generic "development";
	L = a digit representing number of images used to create
		this image, 0 if > 9;
*/

	sprintf (fitsname, "cxx_%04i%02i%02i_%02i%02i%02i.fts",
		(*currenttime).tm_year+1900,
		(*currenttime).tm_mon+1,
		(*currenttime).tm_mday,
		(*currenttime).tm_hour,
		(*currenttime).tm_min,
		(*currenttime).tm_sec);


	#ifdef DEBUG
		printf ("Version : 021016\n");
	#endif

	printf ("Output fitsname: %s\n",fitsname);

	strcpy (tempfilename, filename ); //	"ccd42_5_23_l.img" );
	strcat (tempfilename, "[ul");

	if (( fp = fopen (filename, "rb" )) == NULL ) {
		printf ("Cannot open file");
		exit(1);
	}
	fread ( &naxis1, 1, 2, fp );		//read first 2 bytes from img file

	#if !defined(_WIN32) && !defined (__linux__)
        	ffswap2 ( &naxis1, 1 );		//only byteswap if not on Windows or Linux machine
	#endif
	sprintf(temp, "%u", naxis1);
	strcat(tempfilename, temp);
	strcat(tempfilename, ",");

        fread ( &naxis2, 1, 2, fp );		//read second 2 bytes from img file
	#if !defined(_WIN32) && !defined (__linux__)
		ffswap2 ( &naxis2, 1 );		//only byteswap if not on Windows or Linux machine
	#endif
	sprintf(temp,"%u", naxis2);
	strcat(tempfilename, temp);
	strcat (tempfilename, ":4]");
        fclose (fp);

	#ifdef DEBUG
		printf ("%s\n\n", tempfilename);
	#endif

	fitscopy ( tempfilename, fitsname );
	addkey ( fitsname, "FILENAME", fitsname );
	addkey ( fitsname, "FILEORIG", fileorig );	//	"ccd42_5_23_l.img" );	//argv[1] );
	sprintf (temp, "%04i-%02i-%02it%02i:%02i:%02i.???",
		(*currenttime).tm_year+1900,
		(*currenttime).tm_mon+1,
		(*currenttime).tm_mday,
		(*currenttime).tm_hour,
		(*currenttime).tm_min,
		(*currenttime).tm_sec);
	addkey ( fitsname, "DATE-OBS", temp );
	addkey ( fitsname, "DATE", temp );
	addkey ( fitsname, "HISTORY", "Converted from IMG to FITS using Jake's makefits." );
	sprintf (temp, "Compiled from %s on %s %s.", __FILE__, __TIME__, __DATE__);
	addkey ( fitsname, "COMMENT", temp );
	addkey ( fitsname, "ORIGIN", "NRL");

//	read_ini ( argv[2], filename );		//add select keywords from ini file


//	read_footer needs ( imgfilename, fitsfilename, xsize, ysize, bytecount(2), offset )


	if (( fp = fopen ( filename, "rb" )) == NULL ) {
                printf ("Cannot open file");
		//	exit(1);
        } else
	{	//
		// Add any comments at end of IMG file
		//
		if ( fseek ( fp, (2*naxis1*naxis2)+4, SEEK_SET)) {
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
				addkey ( fitsname, "COMMENT", temp );
				#ifdef DEBUG	
					printf ( "Adding COMMENT from bottom of IMG file:\n" );
					printf ( "%s\n", temp );		
				#endif
			}
		}
		fclose(fp);
	}
	
	return(0);
}

JNIEXPORT jint JNICALL Java_MakeFITSGUI_addKey
  (JNIEnv * env, jobject jobj, jstring jstrFitsFileName, jstring jstrKeyWord, jstring jstrKeyValue)
{
	char outfile[FILENAMELEN];
	char keyword[FLEN_KEYWORD];
	char keyvalue[FLEN_VALUE];
	int status = 0;   /*  CFITSIO status value MUST be initialized to zero!  */

	/* Convert Java Strings to C Strings */
	const jbyte *str;
	str = (*env)->GetStringUTFChars(env, jstrFitsFileName, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(outfile, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jstrFitsFileName, str);


	str = (*env)->GetStringUTFChars(env, jstrKeyWord, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(keyword, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jstrKeyWord, str);


	str = (*env)->GetStringUTFChars(env, jstrKeyValue, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(keyvalue, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jstrKeyValue, str);


	addkey ( outfile, keyword, keyvalue );

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);
}




JNIEXPORT jint JNICALL Java_MakeFITSGUI_showKey
  (JNIEnv * env, jobject jobj, jstring jstrFitsFileName, jstring jstrKeyWord)
{
	char filename[FILENAMELEN];
	char keyword[FLEN_KEYWORD];
	int status = 0;   /*  CFITSIO status value MUST be initialized to zero!  */

	/* Convert Java Strings to C Strings */
	const jbyte *str;
	str = (*env)->GetStringUTFChars(env, jstrFitsFileName, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(filename, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jstrFitsFileName, str);

	str = (*env)->GetStringUTFChars(env, jstrKeyWord, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(keyword, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jstrKeyWord, str);


	showkey ( filename, keyword );

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);
}














JNIEXPORT jint JNICALL Java_MakeFITSGUI_fitsCopy
  (JNIEnv * env, jobject jobj, jstring jstrImgPathName, jstring jstrFitsFileName, jint jx, jint jy)
{
	char infile[FILENAMELEN], outfile[FILENAMELEN];
	char inpath[FILENAMELEN];
	char extension[FILENAMELEN] = "\0";
	//fitsfile *infptr, *outfptr;   /* FITS file pointers defined in fitsio.h */
	int status = 0;       /* status must always be initialized = 0  */
	int length = 0;

	/* Convert Java Strings to C Strings */
	const jbyte *str;
	str = (*env)->GetStringUTFChars(env, jstrImgPathName, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(inpath, "%s", str );

	length = strcspn ( inpath, "." );
	strcpy ( extension, &inpath[length+1] );
	if ( !strcmp (extension, "img") ) sprintf ( inpath, "%s[ul%u,%u:4]", str, jx, jy);


	#ifdef DEBUG 
		printf ("%s:%s:\n", inpath, extension );
	#endif


	(*env)->ReleaseStringUTFChars(env, jstrImgPathName, str);

	str = (*env)->GetStringUTFChars(env, jstrFitsFileName, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(outfile, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jstrFitsFileName, str);

	fitscopy ( inpath, outfile );

	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);

}


JNIEXPORT jstring JNICALL Java_MakeFITSGUI_getIMGSize
  (JNIEnv * env, jobject jobj, jstring jstrImgFileName )
{
	char infile[FILENAMELEN];
	FILE *fp;
	short int naxis1, naxis2;
	int status = 0;		/* status must always be initialized = 0  */
	char output[20];

	/* Convert Java Strings to C Strings */
	const jbyte *str;
	str = (*env)->GetStringUTFChars(env, jstrImgFileName, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(infile, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jstrImgFileName, str);

	if (( fp = fopen (infile, "rb" )) == NULL ) {
		printf ("Cannot open file");
		exit(1);
	}
	fread ( &naxis1, 1, 2, fp );		//read first 2 bytes from img file

	#if !defined(_WIN32) && !defined (__linux__)
        	ffswap2 ( &naxis1, 1 );		//only byteswap if not on Windows or Linux machine
	#endif

        fread ( &naxis2, 1, 2, fp );		//read second 2 bytes from img file
	#if !defined(_WIN32) && !defined (__linux__)
		ffswap2 ( &naxis2, 1 );		//only byteswap if not on Windows or Linux machine
	#endif
	sprintf(output,"%u,%u", naxis1, naxis2);


	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);

	return (*env)->NewStringUTF(env, output);

}


JNIEXPORT jint JNICALL Java_MakeFITSGUI_readFooter
  (JNIEnv *env, jobject jobj, jstring jstrImgPathName, jstring jstrFitsFileName, jint xsize, jint ysize, jint bytecount, jint offset)
{
	char imgfile[FILENAMELEN], fitsfilename[FILENAMELEN];
	FILE *fp;
	int status = 0;		/* status must always be initialized = 0  */
	char output[20];

	/* Convert Java Strings to C Strings */
	const jbyte *str;
	str = (*env)->GetStringUTFChars(env, jstrImgPathName, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(imgfile, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jstrImgPathName, str);

	str = (*env)->GetStringUTFChars(env, jstrFitsFileName, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(fitsfilename, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jstrFitsFileName, str);


	read_footer ( imgfile, fitsfilename, xsize, ysize, bytecount, offset );


	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);
	return(status);

}


JNIEXPORT jstring JNICALL Java_MakeFITSGUI_readFITSKeyNum
  (JNIEnv *env, jobject jobj, jstring jstrFITSPathName, jint jKeyNumber){

	char fitsfilename[FILENAMELEN];
	fitsfile *fp;         /* FITS file pointer, defined in fitsio.h */
	int status = 0;		/* status must always be initialized = 0  */
	char keyword[FLEN_KEYWORD], value[FLEN_VALUE], comment[FLEN_COMMENT];
	char output[FLEN_CARD];

	/* Convert Java Strings to C Strings */
	const jbyte *str;
	str = (*env)->GetStringUTFChars(env, jstrFITSPathName, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(fitsfilename, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jstrFITSPathName, str);


	if (!fits_open_file(&fp, fitsfilename, READONLY, &status))
	{
		fits_read_keyn (fp, jKeyNumber, keyword, value, comment, &status );
		sprintf ( output, "%s/%s / %s", keyword, value, comment );
		fits_close_file(fp, &status);
	} else {
		printf ("Cannot open file to readFITSKeyNum");
	}


	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);

	return (*env)->NewStringUTF(env, output);
}


JNIEXPORT jint JNICALL Java_MakeFITSGUI_getKeywordCount
  (JNIEnv *env, jobject jobj, jstring jstrFITSPathName)
{

	fitsfile *fp;		/* FITS file pointer, defined in fitsio.h */
	char fitsfilename[FILENAMELEN];
	char card[FLEN_CARD];	/* Standard string lengths defined in fitsio.h */
	int status = 0, nkeys;

	/* Convert Java Strings to C Strings */
	const jbyte *str;
	str = (*env)->GetStringUTFChars(env, jstrFITSPathName, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(fitsfilename, "%s", str);
	(*env)->ReleaseStringUTFChars(env, jstrFITSPathName, str);



	if (!fits_open_file(&fp, fitsfilename, READONLY, &status))
	{
		fits_get_hdrspace(fp, &nkeys, NULL, &status); /* get # of keywords */
		fits_close_file(fp, &status);
	} else {
		printf ("Cannot open file to getKeywordCount");
	}




	/* if error occured, print out error message */
	if (status) fits_report_error(stderr, status);

	return(nkeys);
}


