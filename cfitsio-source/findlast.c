
#include <stdio.h>


int main( int argc, char *argv[])
{
	int i, len, tmp;

	len = strlen (argv[1]);

	printf ("%s - %u - ", argv[1], len);

	tmp=0;

	do {
		printf ("\n%s", &argv[1][tmp]);
		tmp = tmp + 1 + strcspn ( &argv[1][tmp], "." ) ;

		if ( (tmp) < len ) {
			printf ("\nFound . at : %u ", tmp);
			i = tmp;
		} else
			printf ("\nFound . past end at : %u ", tmp);
	} while ( tmp<len );

	printf ("\n");
	
	printf ("The last . is at index %u\n", i);
        printf ("extension is %s\n", &argv[1][i] );

	return(0);
}
