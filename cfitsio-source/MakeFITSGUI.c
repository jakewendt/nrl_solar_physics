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
//#define DEBUG



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





JNIEXPORT jint JNICALL Java_MakeFITSGUI_fitsCopyOffset
  (JNIEnv * env, jobject jobj, jstring jstrImgPathName, jstring jstrFitsFileName, jint jx, jint jy, jint joff)
{
	char infile[FILENAMELEN], outfile[FILENAMELEN];
	char inpath[FILENAMELEN];
	char extension[FILENAMELEN] = "\0";
	//fitsfile *infptr, *outfptr;   /* FITS file pointers defined in fitsio.h */
	int status = 0;       /* status must always be initialized = 0  */
	int length = 0;
	int i, tmp;

	/* Convert Java Strings to C Strings */
	const jbyte *str;
	str = (*env)->GetStringUTFChars(env, jstrImgPathName, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(inpath, "%s", str );

	length = strlen ( inpath );

	#ifdef DEBUG
		printf ("filename:%s - length:%u", inpath, length);
	#endif

	tmp=0;
	#ifdef DEBUG
		printf ("\nSearching for extension.");
	#endif
	do {
		tmp = tmp + 1 + strcspn ( &inpath[tmp], "." );

		if ( tmp < length ) {
			#ifdef DEBUG
				printf ("\nFound . at : %u ", tmp);
				printf ("\n%s", &inpath[tmp]);
			#endif
			i = tmp;
		}
	} while ( tmp<length );

	strcpy ( extension, &inpath[i] );
	#ifdef DEBUG
		printf ("\nThe last . is at index %u", i);
		printf ("\n:%s:%s:", inpath, extension );
		printf ("\nUsing extension: %s\n", extension);
	#endif

	sprintf ( inpath, "%s[ul%u,%u:%u]", str, jx, jy, joff);

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



JNIEXPORT jint JNICALL Java_MakeFITSGUI_fitsCopy
  (JNIEnv * env, jobject jobj, jstring jstrImgPathName, jstring jstrFitsFileName, jint jx, jint jy)
{
	char infile[FILENAMELEN], outfile[FILENAMELEN];
	char inpath[FILENAMELEN];
	char extension[FILENAMELEN] = "\0";
	//fitsfile *infptr, *outfptr;   /* FITS file pointers defined in fitsio.h */
	int status = 0;       /* status must always be initialized = 0  */
	int length = 0;
	int i, tmp;

	/* Convert Java Strings to C Strings */
	const jbyte *str;
	str = (*env)->GetStringUTFChars(env, jstrImgPathName, NULL);
	if (str == NULL) {
		return 0; /* OutOfMemoryError already thrown */
	}
	sprintf(inpath, "%s", str );

	length = strlen ( inpath );

	#ifdef DEBUG
		printf ("filename:%s - length:%u", inpath, length);
	#endif

	tmp=0;
	#ifdef DEBUG
		printf ("\nSearching for extension.");
	#endif
	do {
		tmp = tmp + 1 + strcspn ( &inpath[tmp], "." );

		if ( tmp < length ) {
			#ifdef DEBUG
				printf ("\nFound . at : %u ", tmp);
				printf ("\n%s", &inpath[tmp]);
			#endif
			i = tmp;
		}
	} while ( tmp<length );

	strcpy ( extension, &inpath[i] );
	#ifdef DEBUG
		printf ("\nThe last . is at index %u", i);
		printf ("\n:%s:%s:", inpath, extension );
		printf ("\nUsing extension: %s\n", extension);
	#endif

	if ( !strcmp (extension, "img") ) sprintf ( inpath, "%s[ul%u,%u:4]", str, jx, jy);
	else if  ( !strcmp (extension, "dat") ) sprintf ( inpath, "%s[ul2150,2150]", str );






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




