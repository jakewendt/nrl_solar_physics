
import java.io.*;
import java.lang.Integer;
import java.lang.System;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;
import java.util.*;
import java.text.*;
import javax.swing.table.*;
import javax.swing.event.TableModelEvent;
import javax.swing.event.TableModelListener;


class FITSTableModel extends DefaultTableModel implements TableModelListener { // implements TableModel, TableModelListener {

	FITSTableModel () {
		super ();
		addTableModelListener(this);	//	to allow for notification when cell changes
	}

	public boolean isCellEditable(int row, int col) {
		//Note that the data/cell address is constant,
		//no matter where the cell appears onscreen.
		return ( ( col < 1 ) ? false : true );
	}


	public void tableChanged(TableModelEvent event) {
		int row = event.getFirstRow();
		int column = event.getColumn();
		if ((row == -1) || (column == -1)) {
			return;
		}
		Object key = getValueAt( row, 0 );
		Object data = getValueAt( row, 1 );
		Object temp = new Object();
		int naxis = 0;

		try {
			if ( key.toString().trim().equalsIgnoreCase ("P1ROW") ) {
				int p1row = 1;
				try {
					p1row = Integer.parseInt ( data.toString() );
				} catch (NumberFormatException e) {	//	Not a Number
					setValueAt ( Integer.toString( 1 ), row, column );
					p1row = 1;
				}
				int i = 0;
	
				for ( i=1; i <= getRowCount(); i++ ) {
					temp = getValueAt ( i, 0 );
					if ( temp.toString().trim().equalsIgnoreCase("NAXIS2") ) {
						naxis = Integer.parseInt ( getValueAt ( i, 1 ).toString().
							substring(0, getValueAt ( i, 1 ).toString().indexOf("/") ).trim() );
						break; 
					}
					// the following should never be true
					if ( (i+1) == getRowCount() ) 
						System.err.println ("P1ROW-Error.  Last Key.  Notify Jake."); 
				}
	
				//	evaluate data to see if it is within constraints
				//		constraints are dependent on other values
				if ( p1row >= 1 && p1row <= naxis/2 ) {
					for ( i=1; i <= getRowCount(); i++ ) {
						temp = getValueAt ( i, 0 );
						if ( temp.toString().trim().equalsIgnoreCase("P2ROW") ) {
							setValueAt ( Integer.toString( p1row - 1 + naxis ), i, 1 );
							break; 
						}
					}
				} else {
					//	If not within constraints, set to 1
					//	because can't find good way to undo
					//	last modification
					System.out.println ("P1ROW outside constraints.  Must be >=1 and <= NAXIS2/2.");
					setValueAt ( Integer.toString( 1 ), row, column );
				}
	
			} else if ( key.toString().trim().equalsIgnoreCase ("P1COL") ) {
				int p1col = 1;
				try {
					p1col = Integer.parseInt ( data.toString() );
				} catch (NumberFormatException e) {	//	Not a Number
					setValueAt ( Integer.toString( 1 ), row, column );
					p1col = 1;
				}
				int i = 0;

				for ( i=1; i <= getRowCount(); i++ ) {
					temp = getValueAt ( i, 0 );
					if ( temp.toString().trim().equalsIgnoreCase("NAXIS1") ) {
						naxis = Integer.parseInt ( getValueAt ( i, 1 ).toString().
							substring(0, getValueAt ( i, 1 ).toString().indexOf("/") ).trim() );
						break; 
					}
					// the following should never be true
					if ( (i+1) == getRowCount() ) 
						System.err.println ("P1COL-Error.  Last Key.  Notify Jake."); 
				}
	
				//	evaluate data to see if it is within constraints
				//		constraints are dependent on other values
				if ( p1col >= 1 && p1col <= naxis/2 ) {
					for ( i=1; i <= getRowCount(); i++ ) {
						temp = getValueAt ( i, 0 );
						if ( temp.toString().trim().equalsIgnoreCase("P2COL") ) {
							setValueAt ( Integer.toString( p1col - 1 + naxis ), i, 1 );
							break; 
						}
					}
				} else {
					//	If not within constraints, set to 1
					//	because can't find good way to undo
					//	last modification
					System.out.println ("P1COL outside constraints.  Must be >=1 and <= NAXIS1/2.");
					setValueAt ( Integer.toString( 1 ), row, column );
				}
	
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}


