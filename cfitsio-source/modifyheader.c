/*



	modified by the jake

	021016

	modular construction (mod_ak.c)
	can have multiple comments and historys

*/

#include <string.h>
#include <stdio.h>
#include "fitsio.h"

int main(int argc, char *argv[])
{
	int status=0;

	if (argc == 3) 
	{
		status = showkey ( argv[1], argv[2] );
	}
	else if (argc == 4)
	{
		status = addkey ( argv[1], argv[2], argv[3] );
	}
	else {
		printf("\nUsage:  modifyheader filename[ext] keyword newvalue\n");
		printf("\n");
		printf("Add or modify the value of a header keyword.\n");
		printf("If 'newvalue' is not specified then just print \n");
		printf("the current value. \n");
		printf("\n");
		printf("Examples: \n");
		printf("  modifyheader file.fits dec      - list the DEC keyword \n");
		printf("  modifyheader file.fits dec 30.0 - set DEC = 30.0 \n\n");
		return(0);
	}
	return(status);
}

