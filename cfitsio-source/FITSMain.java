
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


public class FITSMain extends JPanel {
        public static void main(String[] args) {
                JFrame frame = new JFrame("FITSTable");
                frame.addWindowListener(new WindowAdapter() {
                        public void windowClosing(WindowEvent e) {
				int i;
				for ( i=0; i<FITSTable.getRowCount(); i++ ) {
					System.out.println ( FITSTable.getValueAt ( i, 0 ) + " -- " + FITSTable.getValueAt ( i, 1 ) );
				}
                                System.exit(0);
                        }
                });
                frame.getContentPane().add(new FITSTable(), 
                        BorderLayout.CENTER);
                frame.setSize(600, 400);
                frame.setVisible(true);
	}
}

