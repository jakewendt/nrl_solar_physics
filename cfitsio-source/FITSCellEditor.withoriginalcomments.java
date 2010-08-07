
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

// It should really extend AbstractCellEditor instead of DefaultCellEditor
// But I did not have 1.4 available. 
public class FITSCellEditor extends DefaultCellEditor implements ActionListener {

	private static Vector lists = new Vector ( 0, 1 );
	private static Vector editablelist = new Vector ( 0, 1 );
//	private JComboBox[] combos = null;	//REMOVED BY JAKE
	private JComboBox editor = null;

	public FITSCellEditor() {

		// This line should be removed if AbstractCellEditor is used
		// The JTextField It is NOT used - it is just here to avoid
		// NullPointerException. 
		super( new JTextField() );





		// Note: This should obviously be four from the context of the original posting

		// Pre construct the three selected resources
		// This could be done as lazy instantation if there are many instantiated
		// versions of this default cell editor. Probably not needed
//		combos = new JComboBox[3];
//		combos[0] = new JComboBox( new Object[] { "0select1", "0select2", "0select3" } );
//		combos[1] = new JComboBox( new Object[] { "1select1", "1select2", "1select3" } );
//		combos[2] = new JComboBox( new Object[] { "2select1", "2select2", "2select3" } );


		// We need to register ourself so we know when the user decided they
		// had enough and we should stop the cell editing
		// Obviously this introduces some proplems with using arrow keys and
		// mouse clicks, but we decided that the users know how to make the action
		// event appear.
//		for(int i = 0; i < combos.length; i++)
//		{
//			combos[i].addActionListener( this );
//		}

	}

	public void actionPerformed(ActionEvent ae)
	{
		// If any of the comboboxes are editing, we better stop it.
		stopCellEditing();
		// we could at this point make sure that the editor is null
		// both for editing stopped and editing cancelled
	}

	public Object getCellEditorValue()
	{
		if( editor == null )
		{
			// Panick! We are in a state we should never end upp in.
			// Normally this should be an assert.
			return null;
		}
		return editor.getSelectedItem();
	}


	public Component getTableCellEditorComponent(JTable table,Object value, boolean isSelected, int row, int column)
	{	int i, j;
		String e;
		//if( row >= 0 && row < combos.length )
		if( row >= 0 && row < lists.capacity() )
		{
			// We want the current value to be selected
			// Apropriate checks for null could be handled here as well.
			//if ( Array.getLength( lists.get(row) ) > 1 )
			//{
				editor = new JComboBox ();
				if ( lists.get(row).getClass().isArray() ) {
					for ( i=0; i<Array.getLength( lists.get(row) ); i++) {
						editor.addItem( Array.get ( lists.get(row), i ) );
					}
				} else {
					System.out.println ( "Editor :" + lists.get(row) );
					System.out.println ( "Editor :" + ((Vector)lists.get(row)).capacity() );
					System.out.println ( "Editor :" + lists.capacity() );
				
					for ( i=0; i<((Vector)lists.get(row)).capacity() ; i++) {
						editor.addItem( ((Vector)lists.get(row)).get(i) );
					}
				}

				editor.addActionListener ( this );	//ADDED BY JAKE
				editor.setSelectedItem(value);
				if ( editablelist.get(row).toString().equalsIgnoreCase("true") ) editor.setEditable(true);
			//}
			//else
			//{
			//	editor = new JTextField ();
			//}
			return editor;
		}
		else
		{
			// If the row is outside our "scope" somehow we should throw a nice little error
			throw new IllegalArgumentException("Row is out of scope, no associated combobox");
			// Alternatives for this would be to:
			// a) Just let it throw the ArrayIndexOutOfBondsException
			// b) Run modulus % on the row and just keep on repeating the pattern
		}
	}
	



	public void addRow( Vector newdata ) {
		lists.add( (Vector)newdata );
		System.out.println ( "FITSCellEditor : " + newdata );
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
	}
}


