/*

	read_ini

	by Jake

	born 021011

	purpose: to read camera created ini files


*/


#include <stdio.h>
#include <string.h>

const MAX_LINE_LENGTH = 50;
const MAX_FILENAME_LENGTH = 20;
const MAX_KEYWORD_LENGTH = 12;
const MAX_DESC_LENGTH = 80;	

int main(int argc, char *argv[])
{
	FILE *fp;
	char filename[MAX_FILENAME_LENGTH];	
	char readline[MAX_LINE_LENGTH];
	size_t length;
	char value[MAX_DESC_LENGTH];
	char keyword[MAX_KEYWORD_LENGTH];

        if (argc != 2)
        {
                printf("read_ini inifilename.ini\n");
                printf("\n");
                return(0);
        }


	strcpy (filename, argv[1] );	//	"ids2100.ini\0");
	printf ("%s\n", filename);

	if (( fp = fopen ( filename, "r" )) == NULL ) {
		printf ("Cannot open file.\n");
		exit(1);
	}

	while ( !feof (fp) ) {
		fgets ( readline, MAX_LINE_LENGTH, fp );
		readline[strlen(readline)-1] = '\0';		//crop trailing \n

		printf ("----------------\n%s\n", readline);
		length = strcspn ( readline, " " );		//find first (only?) space

		strncpy ( value, readline, length );		//pick off first part
		printf (" The value is :%s:\n", value );
		strncpy ( value, "", MAX_DESC_LENGTH );		//fill with NULLs to erase and reset value
		
		strcpy ( keyword, &readline[length+1] );	//pick off last part 
		printf (" The keyword is :%s:\n", keyword );
	}

	fclose ( fp );
        return(0);
}




/*

	end read_ini


*/
