
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
import javax.swing.event.*;


public class FITSTable extends JPanel {
	//
	//	WHY IS THIS NOT "TableModel model = new FITSTableModel();" ?????
	//		as seen in other code.  I guess I still don't understand
	//		this whole OOP Java and C++ thing yet.
	//
	static final FITSTableModel model = new FITSTableModel();
	static final FITSCellEditor editor = new FITSCellEditor();
	static final JTable table = new JTable(model);

	public FITSTable () {

		this.setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
		this.setBorder(BorderFactory.createEmptyBorder(10,5,10,5));

		String[] columnNames = {"Keyword","Value"};
		model.setColumnIdentifiers( columnNames );

		table.setRowHeight(25);
		table.getColumnModel().getColumn(1).setCellEditor( editor );
		table.getColumnModel().getColumn(0).setPreferredWidth(100);
		table.getColumnModel().getColumn(1).setPreferredWidth(400);

		table.setPreferredScrollableViewportSize(new Dimension(500, 200));

		JScrollPane scrollPane = new JScrollPane( table );
		this.add( scrollPane );
		this.setLayout(new GridLayout(1, 1)); // Added "this." 030212 - shouldn't be an issue
		table.setToolTipText("<html><b>QUICK TIPS:</b><br><ol>"+
						"<li>To enter values, double-click on a field and "+
							"either choose from the list or type in a value."+
						"<li>You MUST hit Return after entering a value."+
						"<li>Only HISTORY and COMMENT fields may have spaces."+
						"<li>Spaces in other keywords will generate an inline comment."+
						"<li>An upslash will also generate an inline comment.</ol></html>");
	}


	public void addRow ( String key, Vector values, String editable ) {
		//	
		// Perhaps it would be better to pass the model and editor as params
		// as opposed to making them class variable
		//	
		model.addRow ( new Object[] { key, values.get(0) } );
		editor.addRow ( values, editable );
	}

	public void addRow ( String key, Vector values ) {
		//	
		// Perhaps it would be better to pass the model and editor as params
		// as opposed to making them class variable
		//	
		model.addRow ( new Object[] { key, values.get(0) } );
		editor.addRow ( values );
	}

	public void addRow ( String key, String[] values, String editable ) {
		//	
		// Perhaps it would be better to pass the model and editor as params
		// as opposed to making them class variable
		//	
		model.addRow ( new Object[] { key, values[0] } );
		editor.addRow ( values, editable );
	}

	public void addRow ( String key, String[] values ) {
		//	
		// Perhaps it would be better to pass the model and editor as params
		// as opposed to making them class variable
		//	
		model.addRow ( new Object[] { key, values[0] } );
		editor.addRow ( values );
	}

	public static Object getValueAt ( int row, int column ) {
		return table.getValueAt ( row, column );
	}

	public static int getRowCount () {
		return table.getRowCount();
	}

	public static void clearTable () {
		int i=0;

		while ( table.getRowCount() > 0 ) {
			//System.out.println ("Removing row "+ i++);
			model.removeRow(0);
		}
		editor.clearTable();
	}

}

