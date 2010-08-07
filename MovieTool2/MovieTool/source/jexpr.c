/*

	gcc -lm jexpr.c -o jexpr

	some of these functions were implemented with C99
	and won't compile correctly until using gcc 3.2

*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

//double exp2 ( double );

int main(int argc, char *argv[])
{
	double output;

	if ( argc > 4 || argc < 3 ) { 
		printf("\n");
		printf("Usage: jexpr number operator number\n");
		printf("  operators ( +, -, \\*, /)\n");
		printf("  or jexpr function number (returns the function result)\n");
		printf("  functions ( acos, asin, atan, cbrt, ceil, cos, exp, \n");
		printf("       exp2, log, log2, log10, sin, sqrt, round, tan )\n");
		printf("\n");
		printf("  I work with floats unlike expr\n");
		printf("\n");
		printf("  Examples\n");
		printf("  jexpr 5.2 \\* 7.001\n");
		printf("  jexpr exp 4\n");
		printf("\n");
		return(0);
	}

	if ( argc == 4 ) {
		if ( *argv[2] == '+' ) {
			output = atof(argv[1]) + atof(argv[3]);
		} else if ( *argv[2] == '-' ) {
			output = atof(argv[1]) - atof(argv[3]);
		} else if ( *argv[2] == '*' ) {
			output = atof(argv[1]) * atof(argv[3]);
		} else if ( *argv[2] == '/' ) {
			output = atof(argv[1]) / atof(argv[3]);
		} else {
	/*		printf("Error: unknown arithmetic operator\n");*/
			return(1);
		}
	} else {
		if ( !strcmp( argv[1], "acos") ) {
			output = acos ( atof (argv[2]) );
		} else if ( !strcmp( argv[1], "asin") ) {
			output = asin ( atof (argv[2]) );
		} else if ( !strcmp( argv[1], "atan") ) {
			output = atan ( atof (argv[2]) );
		} else if ( !strcmp( argv[1], "cbrt") ) {
			output = cbrt ( atof (argv[2]) );
		} else if ( !strcmp( argv[1], "ceil") ) {
			output = ceil ( atof (argv[2]) );
		} else if ( !strcmp( argv[1], "cos") ) {
			output = cos ( atof (argv[2]) );
		} else if ( !strcmp( argv[1], "exp") ) {
			output = exp ( atof (argv[2]) );
/*		} else if ( !strcmp( argv[1], "exp2") ) {
			output = exp2 ( atof (argv[2]) );
*/		} else if ( !strcmp( argv[1], "log") ) {
			output = log ( atof (argv[2]) );
		} else if ( !strcmp( argv[1], "log10") ) {
			output = log10 ( atof (argv[2]) );
/*		} else if ( !strcmp( argv[1], "log2") ) {
			output = log2 ( atof (argv[2]) );
*/		} else if ( !strcmp( argv[1], "sin") ) {
			output = sin ( atof (argv[2]) );
		} else if ( !strcmp( argv[1], "sqrt") ) {
			output = sqrt ( atof (argv[2]) );
/*		} else if ( !strcmp( argv[1], "round") ) {
			output = round ( atof (argv[2]) );
*/		} else if ( !strcmp( argv[1], "tan") ) {
			output = tan ( atof (argv[2]) );
		} else {
	/*		printf("Error: unknown function\n");*/
			return(2);
		}
	}

	printf("%g\n", output);

	return(0);
}

/*

gcc -lm jexpr.c -o jexpr

*/

