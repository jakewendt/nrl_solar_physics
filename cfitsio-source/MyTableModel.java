
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


class MyTableModel extends DefaultTableModel {
    	private boolean DEBUG = true;
        final String[] columnNames = {"First Name", 
                                      "Last Name",
                                      "Sport",
                                      "# of Years",
                                      "Vegetarian"};
        final Object[][] data = {
            {"Mary", "Campione", 
             "Snowboarding", new Integer(5), new Boolean(false)},
            {"Alison", "Huml", 
             "Rowing", new Integer(3), new Boolean(true)},
            {"Kathy", "Walrath",
             "Chasing toddlers", new Integer(2), new Boolean(false)},
            {"Mark", "Andrews",
             "Speed reading", new Integer(20), new Boolean(true)},
            {"Angela", "Lih",
             "Teaching high school", new Integer(4), new Boolean(false)}
        };

 /**
*  Adds a row to the end of the model.  The new row will contain
*  <code>null</code> values unless <code>rowData</code> is specified.
*  Notification of the row being added will be generated.
*
* @param   rowData          optional data of the row being added
*/
public void addRow(Vector rowData) {
if (rowData == null) {
rowData = new Vector(getColumnCount());
}
else {
rowData.setSize(getColumnCount());
}

dataVector.addElement(rowData);

// Generate notification
//newRowsAdded(new TableModelEvent(this, getRowCount()-1, getRowCount()-1,
//TableModelEvent.ALL_COLUMNS, TableModelEvent.INSERT));
}




        public int getColumnCount() {
            return columnNames.length;
        }
        
        public int getRowCount() {
            return data.length;
        }

        public String getColumnName(int col) {
            return columnNames[col];
        }

        public Object getValueAt(int row, int col) {
            return data[row][col];
        }

        /*
         * JTable uses this method to determine the default renderer/
         * editor for each cell.  If we didn't implement this method,
         * then the last column would contain text ("true"/"false"),
         * rather than a check box.
         */
        public Class getColumnClass(int c) {
            return getValueAt(0, c).getClass();
        }

        /*
         * Don't need to implement this method unless your table's
         * editable.
         */
        public boolean isCellEditable(int row, int col) {
            //Note that the data/cell address is constant,
            //no matter where the cell appears onscreen.
            if (col < 2) { 
                return false;
            } else {
                return true;
            }
        }

        /*
         * Don't need to implement this method unless your table's
         * data can change.
         */
        public void setValueAt(Object value, int row, int col) {
            if (DEBUG) {
                System.out.println("Setting value at " + row + "," + col
                                   + " to " + value
                                   + " (an instance of " 
                                   + value.getClass() + ")");
            }

            if (data[0][col] instanceof Integer                        
                    && !(value instanceof Integer)) {                  
                //With JFC/Swing 1.1 and JDK 1.2, we need to create    
                //an Integer from the value; otherwise, the column     
                //switches to contain Strings.  Starting with v 1.3,   
                //the table automatically converts value to an Integer,
                //so you only need the code in the 'else' part of this 
                //'if' block.                                          
                //XXX: See TableEditDemo.java for a better solution!!!
                try {
                    data[row][col] = new Integer(value.toString());
                    fireTableCellUpdated(row, col);
                } catch (NumberFormatException e) {
//                    JOptionPane.showMessageDialog(MakeFITSGUI.this,
			System.out.println (
                        "The \"" + getColumnName(col)
                        + "\" column accepts only integer values.");
                }
            } else {
                data[row][col] = value;
                fireTableCellUpdated(row, col);
            }

            if (DEBUG) {
                System.out.println("New value of data:");
                printDebugData();
            }
        }

        private void printDebugData() {
            int numRows = getRowCount();
            int numCols = getColumnCount();

            for (int i=0; i < numRows; i++) {
                System.out.print("    row " + i + ":");
                for (int j=0; j < numCols; j++) {
                    System.out.print("  " + data[i][j]);
                }
                System.out.println();
            }
            System.out.println("--------------------------");
        }
}


