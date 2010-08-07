/*

modified code for IDL procedure of the same name.

; INPUTS:
;	X:	The variable.  This value can be a scalar, vector or array.
;
;	C:	The vector of polynomial coefficients.  The degree of 
;		of the polynomial is N_ELEMENTS(C) - 1.
;
; OUTPUTS:
;	POLY returns a result equal to:
;		 C[0] + c[1] * X + c[2]*x^2 + ...
;

	gcc jpoly.c -o jpoly

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main ( int argc, char* argv[] ) {

	int n, i;
	double x, y;

	if ( argc < 4 ) {
		printf("\n");
		printf("Usage: jpoly value list-of-coefficients\n");
		printf("  Evaluate polynomial function at value.\n");
		printf("\n");
		printf("  Examples\n");
		printf("  jpoly 5 2 4 7\n");
		printf("  evaluates (2 + 4x + 7x^2) at x=5\n");
		printf("\n");
		return(0);
	}


	x = atof ( argv[1] );
//	printf("Variable x: %f\n", x);

//	printf("Number of total numbers : %ld\n", argc - 1);

//	printf("Number of coeffs : %ld\n", argc - 2);

	n = argc - 3;
//	printf("Degree of Polynomial : %ld\n", n );

	y = atof ( argv[n+2] );
//	printf ("Y:Coeff # %d : %s\n", n, argv[n+2] );

	for ( i=n+2-1; i>1; i-- ) {
		y = y * x + atof( argv[i] );
//		printf ("Loop:Coeff # %d : %s\n", i, argv[i]);
	}

	printf("%f\n", y );
	return(0);
}

/*
N = N_ELEMENTS(C)-1	;Find degree of polynomial
Y = c[n]
for i=n-1,0,-1 do $
	y = y * x + c[i]
return,y
end
*/
/*

gcc jpoly.c -o jpoly

*/

