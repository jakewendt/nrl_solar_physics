
import java.io.*;
import java.lang.Integer;
import java.lang.System;
import java.lang.reflect.Array;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;
import java.util.*;
import java.text.*;
import javax.swing.table.*;


public class VectorTest{
	static int i;
	static int j;

	public static void main(String[] args) {
		Vector test = new Vector(0,1);
		test.add ( new String[] { "1st element" } );
		test.add ( new String[] { "2nd element" } );
		test.add ( new String[] { "3rd element" } );
		test.add ( new String[] { "4th element" } );
		test.add ( new String[] { "5th element" } );
		test.add ( new String[] { "6th element A", "6th element B" } );

		System.out.println ( test.capacity() );


		for ( i=0; i<test.capacity(); i++ ) {
			//System.out.println ( test.get(i).getClass().getName() );
			if ( test.get(i).getClass().isArray() ) {
				//System.out.println ("It is an array");
				//retrieve the array object and convert to useful array

				if ( Array.getLength(test.get(i)) > 1 )
					System.out.println ("Combo Box");
				else
					System.out.println ("TextField");
				for ( j=0;j<Array.getLength( test.get(i) ); j++) {
					System.out.println ( Array.get( test.get(i), j ) );
				}
			}
			else System.out.println ( test.get(i) );
		}
	}
}

