
import java.awt.*;
import java.awt.event.*;
import java.util.*;
import javax.swing.*;
import javax.swing.table.*;

public class TestTable extends JFrame
{
	private final static String LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	JTable table;
	Vector row;

	public TestTable()
	{
		Object[][] data = { {"1", "A"}, {"2", "B"}, {"3", "C"} };
		String[] columnNames = {"Number","Letter"};
		DefaultTableModel model = new DefaultTableModel(data, columnNames);
		table = new JTable(model);

		JScrollPane scrollPane = new JScrollPane( table );
		getContentPane().add( scrollPane );

		JButton button = new JButton( "Add Row" );
		getContentPane().add( button, BorderLayout.SOUTH );
		button.addActionListener( new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				DefaultTableModel model = (DefaultTableModel)table.getModel();
				Object[] newRow = new Object[2];
				int row = table.getRowCount() + 1;
				newRow[0] = Integer.toString( row );
		
				if (row > LETTERS.length())
					newRow[1] = "?";
				else
					newRow[1] = LETTERS.substring(row-1,row);

				model.addRow( newRow );
			}
		});

	}

	public static void main(String[] args)
	{
		TestTable frame = new TestTable();
		frame.setDefaultCloseOperation( EXIT_ON_CLOSE );
		frame.pack();
		frame.setVisible(true);
	}
}
