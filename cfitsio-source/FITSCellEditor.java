
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
import java.lang.reflect.Array;

public class FITSCellEditor extends DefaultCellEditor implements ActionListener {

	private static Vector lists = new Vector ( 0, 1 );
	private static Vector editablelist = new Vector ( 0, 1 );
	private JComboBox editor = null;
//	private static String lastValue = new String("");

	public FITSCellEditor() {
		super( new JTextField() );

		//	Default is double-click to start editting
		//	Use the following to set to single click 
		//setClickCountToStart( 1 );
	}

	public void actionPerformed(ActionEvent ae) {
		//	Fires when a combo box is double clicked.
		//	The following line is just a safety measure
		//	to ensure that all other cells are stopped.



		stopCellEditing();

		//	Grab current value before editting, just in case...
//		lastValue = new String ( editor.getSelectedItem().toString() );
//		System.out.println ( lastValue );

	}

	public Object getCellEditorValue()
	{
		if( editor == null )
		{
			// Panick! We are in a state we should never end upp in.
			// Normally this should be an assert.
			return null;
		}

//		return ( editor.getSelectedItem().toString().trim().equalsIgnoreCase("") 
//			? lastValue : editor.getSelectedItem() );

		return ( editor.getSelectedItem() );
	}


	public Component getTableCellEditorComponent(JTable table,Object value, boolean isSelected, int row, int column)
	{	int i, j;
		String e;

		if( row >= 0 && row < lists.size() )
		{

			editor = new JComboBox ();
			if ( lists.get(row).getClass().isArray() ) {
				//	Assuming a String Array
				//	I don't really use these anymore, but some may still exist.
				//
				for ( i=0; i<Array.getLength( lists.get(row) ); i++) {
					editor.addItem( Array.get ( lists.get(row), i ) );
				}
			} else {
				//	Assuming a Vector
				//	The latest and greatest technique.  I think.
				//
				//System.out.println ( "Editor :" + lists.get(row) );
				//System.out.println ( "Editor :" + ((Vector)lists.get(row)).size() );
				//System.out.println ( "Editor :" + lists.size() );
			
				for ( i=0; i<((Vector)lists.get(row)).size() ; i++) {
					editor.addItem( ((Vector)lists.get(row)).get(i) );
				}
			}

			editor.addActionListener ( this );	//ADDED BY JAKE
			editor.setSelectedItem(value);

			if ( editablelist.get(row).toString().equalsIgnoreCase("true") ) editor.setEditable(true);
			return editor;
		}
		else
		{
			// If the row is outside our "scope" somehow we should throw a nice little error
			throw new IllegalArgumentException("Row is out of scope, no associated combobox");
		}
	}


	public void addRow( Vector newdata ) {
		lists.add( newdata );
		editablelist.add ( "true" );
	}

	public void addRow( Vector newdata, String editable ) {
		lists.add( newdata );
		editablelist.add ( editable );
	}

	public void addRow( String[] newdata ) {
		lists.add( newdata );
		editablelist.add ( "true" );
	}

	public void addRow( String[] newdata, String editable ) {
		lists.add( newdata );
		editablelist.add ( editable );
	}

	public static void clearTable () {
		lists.clear();
		editablelist.clear();//	just added so may crash
	}
}


