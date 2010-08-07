
import java.io.*;
import java.lang.Integer;
import java.lang.System;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;
import java.util.*;
import java.text.*;



public class MakeFITSGUI extends JPanel {
	/*	JNI Native Functions		*/
	private native String getIMGSize ( String imgPathName );
	private native int addKey ( String fitsOutFileName, String keyword, String keyValue );
	private native int showKey ( String fitsOutFileName, String keyword );
	private native int fitsCopy ( String imgPathName, String fitsOutFileName, int xsize, int ysize );
	private native int readFooter ( String imgPathName, String fitsOutFileName, int xsize, 
		int ysize, int bytecount, int offset );
	private native int getKeywordCount ( String fitsInFileName );
	private native String readFITSKeyNum ( String fitsInFileName, int KeywordNumber );

	/*	MakeFITSGUI Constants		*/
	final private String PCCopyDir = new String ("Y:\\secchi\\");
	final private String UnixCopyDir = new String ("/net/cedar/pub/secchi/");


	/*	MakeFITSGUI Variables		*/
	private long longdate;
	private String longdatestrobs = new String("");
	private String longdatestrnow = new String("");
	private String imgFilename = new String("");
	private String imgPathName = new String("");
	private String fitsOutFileName = new String("");	//Only used when adding the FILENAME keyword
	private String fitsOutPathName1 = new String ("");
	private String fitsOutPathName2 = new String ("");
	private String fitsOutPathName3 = new String ("");
	private String sourceFileName = new String("");
	private String sourceExtension = new String("");
	private String secchiExtension = new String("");	//Used for the filename coding
	private String outputDir = new String ("");
	private String copyDir = new String ("");
	private String keyObsrvtry = new String ("");
	private String codeObsrvtry = new String ("");
	private String keyCamera = new String ("");
	private String codeCamera = new String ("");
	private File outputDirFile;
	private int index;
	private int tempint;
	private int xsize = 0;
	private int ysize = 0;
	private String imgsizes = new String("");
	private File imgFile;
	private File fitsInFile;
	private File fitsOutFile;
	private File iniFile;
	private String keyword = new String("");
	private String keyvalue = new String("");
	private String comment = new String("");



	/*	MakeFITSGUI Functions and Procedures	*/
	public MakeFITSGUI() {
		JTabbedPane tabbedPane = new JTabbedPane();
		final JFileChooser fc = new JFileChooser();

		final ExampleFileFilter imgFilter = new ExampleFileFilter();
		imgFilter.addExtension("img");
		imgFilter.setDescription("Camera IMG files.");
		fc.setFileFilter (imgFilter);

		final ExampleFileFilter iniFilter = new ExampleFileFilter();
		iniFilter.addExtension("ini");
		iniFilter.setDescription("Camera INI files.");
		fc.setFileFilter(iniFilter);

		final ExampleFileFilter fitsFilter = new ExampleFileFilter();
		fitsFilter.addExtension("fits");
		fitsFilter.addExtension("fts");
		fitsFilter.addExtension("fit");
		fitsFilter.setDescription("FITS, FTS and FIT files.");
		fc.setFileFilter(fitsFilter);



		final JLabel fitsOutFileLabel2 = new JLabel ("No FITS file has been selected.");
		final JLabel fitsOutFileLabel3 = new JLabel ("No FITS file has been selected.");	// put here because of early ref

		/**********************************************************************************/
		//	Panel1 reads an IMG file and converts it into a FITS.
		//	It then adds any comments from the bottom of the IMG file.
		//	It then adds several standard comments.
		//	It then copies the FITS file to the designated area.
		//
		//	NOT FINISHED YET.....
		//
		//	It then moves the IMG file to the designated area.
		//
		//
		/**********************************************************************************/
		JPanel panel1 = new JPanel();
		panel1.setLayout(new BoxLayout(panel1, BoxLayout.Y_AXIS));
		panel1.setBorder(BorderFactory.createEmptyBorder(20,20,20,20));
		//Create the open button
		JButton openIMGButton1 = new JButton("Select the input IMG file." );
		final JLabel imgFileLabel1 = new JLabel("No file has been selected.");
		openIMGButton1.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				fc.setFileFilter(imgFilter);
				fc.setFileSelectionMode( JFileChooser.FILES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					imgFile = fc.getSelectedFile();
					
					/*	Strip and Reassemble the TimeStamp	*/
					Date newdate = new Date(imgFile.lastModified());
					longdate = imgFile.lastModified();
					tempint = 1900 + newdate.getYear();
					longdatestrobs = Integer.toString( tempint ); 
						//	Compile the date components
						//	into a single string
						//	SHOULD BE A BETTER WAY TO DO THIS
					tempint = 1 + newdate.getMonth();
					if ( tempint < 10 ) longdatestrobs = ( longdatestrobs + "0" + tempint );
						else longdatestrobs = ( longdatestrobs + tempint ); 
					tempint = newdate.getDate();
					if ( tempint < 10 ) longdatestrobs = ( longdatestrobs + "0" + tempint );
						else longdatestrobs = ( longdatestrobs + tempint ); 
					tempint = newdate.getHours();
					if ( tempint < 10 ) longdatestrobs = ( longdatestrobs + "_0" + tempint );
						else longdatestrobs = ( longdatestrobs + "_" + tempint ); 
					tempint = newdate.getMinutes();
					if ( tempint < 10 ) longdatestrobs = ( longdatestrobs + "0" + tempint );
						else longdatestrobs = ( longdatestrobs + tempint ); 
					tempint = newdate.getSeconds();
					if ( tempint < 10 ) longdatestrobs = ( longdatestrobs + "0" + tempint );
						else longdatestrobs = ( longdatestrobs + tempint ); 
					System.out.println ( longdatestrobs );
					
					imgPathName = imgFile.getAbsolutePath();
					imgsizes = getIMGSize( imgPathName ); 
					index = imgsizes.indexOf ( "," );
                                	if ( index == -1 ) {
						imgsizes = "" ;
						System.out.println("No comma found in filesize!?!?");
						System.out.println("Unable to determine Image Dimensions.");
					} else {
						xsize = Integer.parseInt (imgsizes.substring(0,index) );
						ysize = Integer.parseInt (imgsizes.substring(index+1) );
                                        	imgFileLabel1.setText( imgFile.getAbsolutePath() + " - " + xsize + ", " + ysize );
					}
				} else {
					System.out.println("Open command cancelled by user." );
				}
			}
		});
		openIMGButton1.setAlignmentX(Component.CENTER_ALIGNMENT);
		imgFileLabel1.setAlignmentX(Component.CENTER_ALIGNMENT);

		JPanel pnlTest = new JPanel();
			pnlTest.setLayout(new GridLayout(1, 2));

			JPanel pnlObsrvtry = new JPanel();
				pnlObsrvtry.setLayout(new GridLayout(0, 1));
				Border titleO = BorderFactory.createTitledBorder ("Spacecraft");
				Border innerO = new CompoundBorder ( titleO, new EmptyBorder(20,20,20,20));
				pnlObsrvtry.setBorder ( new CompoundBorder( new EmptyBorder(0,20,0,20), innerO ));
	
				JRadioButton[] rdbObsrvtry = new JRadioButton[3];
				final ButtonGroup rdbgrpObsrvtry = new ButtonGroup();
				rdbObsrvtry[0] = new JRadioButton("Spacecraft 'A'");
				rdbObsrvtry[1] = new JRadioButton("Spacecraft 'B'");
				rdbObsrvtry[2] = new JRadioButton("Other 'C'");
				for ( int i = 0; i < 3; i++ ) {
					rdbObsrvtry[i].setActionCommand(""+i);
					rdbgrpObsrvtry.add(rdbObsrvtry[i]);
					pnlObsrvtry.add(rdbObsrvtry[i]);
				}
				rdbObsrvtry[2].setSelected(true);

			JPanel pnlCamera = new JPanel();
				pnlCamera.setLayout(new GridLayout(0, 1));
				Border titleC = BorderFactory.createTitledBorder ("Camera");
				Border innerC = new CompoundBorder ( titleC,  new EmptyBorder(20,20,20,20));
				pnlCamera.setBorder ( new CompoundBorder( new EmptyBorder(0,20,0,20), innerC ));
	
				JRadioButton[] rdbCamera = new JRadioButton[8];
				final ButtonGroup rdbgrpCamera = new ButtonGroup();
				rdbCamera[0] = new JRadioButton("EUVI");
				rdbCamera[1] = new JRadioButton("COR1");
				rdbCamera[2] = new JRadioButton("COR2");
				rdbCamera[3] = new JRadioButton("HI1");
				rdbCamera[4] = new JRadioButton("HI2");
				rdbCamera[5] = new JRadioButton("GT");
				rdbCamera[6] = new JRadioButton("Talktronics");
				rdbCamera[7] = new JRadioButton("RAL development camera");
				for ( int i = 0; i < 8; i++ ) {
					rdbCamera[i].setActionCommand(""+i);
					rdbgrpCamera.add(rdbCamera[i]);
					pnlCamera.add(rdbCamera[i]);
				}
				rdbCamera[6].setSelected(true);

		pnlTest.add ( pnlObsrvtry );
		pnlTest.add ( pnlCamera );


		//Create the output directory button
		JButton outputDirButton1 = new JButton("Select the Output Directory." );
		final JLabel outputDirLabel1 = new JLabel("No Output Dir has been selected.");
		outputDirButton1.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				fc.setFileSelectionMode ( JFileChooser.DIRECTORIES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					outputDirFile = fc.getSelectedFile();
					
					outputDir = new String ( outputDirFile.getAbsolutePath() + outputDirFile.separator );
					System.out.println ( outputDir );

					outputDirLabel1.setText( outputDirFile.getAbsolutePath() + outputDirFile.separator );
				} else {
					System.out.println("Open command cancelled by user." );
				}
			}
		});
		outputDirButton1.setAlignmentX(Component.CENTER_ALIGNMENT);
		outputDirLabel1.setAlignmentX(Component.CENTER_ALIGNMENT);

		//Create the GO button
		JButton makefitsButton1 = new JButton("GO!" );
		makefitsButton1.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if ( imgsizes.trim().equalsIgnoreCase("") )
					System.out.println ("Was unable to determine Image Dimensions earlier");
				else if ( imgPathName.trim().equalsIgnoreCase("") )
					System.out.println ("No IMG In File Selected.");
				else {				
					secchiExtension = new String ("_");

					//	L = a digit representing processing level, or 
					//	'r' for quick-look or 'p' for pre-flight  
					secchiExtension = secchiExtension + "p";	
					
					switch ( Integer.parseInt(rdbgrpCamera.getSelection().getActionCommand())) {
						case 0: codeCamera = new String ("eu");	
							keyCamera = new String ("EUVI");
							break;
						case 1: codeCamera = new String ("c1");	
							keyCamera = new String ("COR1");
							break;
						case 2: codeCamera = new String ("c2");	
							keyCamera = new String ("COR2");
							break;
						case 3:	codeCamera = new String ("h1");	
							keyCamera = new String ("HI1");
							break;
						case 4: codeCamera = new String ("h2");	
							keyCamera = new String ("HI2");
							break;
						case 5: codeCamera = new String ("gt");	
							keyCamera = new String ("GT");
							break;
						case 6: codeCamera = new String ("tk");	
							keyCamera = new String ("Talktronics");
							break;
						case 7: codeCamera = new String ("ra");	
							keyCamera = new String ("RAL Developement Camera");
							break;
						default:	//	Bad Selection (shouldn't be possible with Radio)
					}
					secchiExtension = secchiExtension + codeCamera;

					switch ( Integer.parseInt(rdbgrpObsrvtry.getSelection().getActionCommand())) {
						case 0: codeObsrvtry = new String ("a");
							keyObsrvtry = new String ("STEREO A");
							break;
						case 1: codeObsrvtry = new String ("b");
							keyObsrvtry = new String ("STEREO B");
							break;
						case 2: codeObsrvtry = new String ("c");
							keyObsrvtry = new String ("Other");
							break;
						default:	//	Bad Selection (shouldn't be possible with Radio)
					}
					secchiExtension = secchiExtension + codeObsrvtry;

					secchiExtension = secchiExtension + ".fts" ;
					fitsOutFileName = longdatestrobs + secchiExtension;
					fitsOutPathName1 = outputDir + longdatestrobs + secchiExtension;

					fitsCopy ( imgPathName, fitsOutPathName1, xsize, ysize );
					readFooter ( imgPathName, fitsOutPathName1, xsize, ysize, 2, 4 );
					addKey ( fitsOutPathName1, "HISTORY", 
						"Converted from IMG to FITS using Jake's Java/JNI/C MakeFITSGUI.");
					addKey ( fitsOutPathName1, "FILENAME", fitsOutFileName );



					addKey ( fitsOutPathName1, "FILEORIG", imgFilename );
					//	MAY HAVE TO ADD AN A OR B INSIDE THIS FILENAME




					addKey ( fitsOutPathName1, "DATE_OBS", longdatestrobs );
					addKey ( fitsOutPathName1, "DETECTOR", keyCamera );
					addKey ( fitsOutPathName1, "OBSRVTRY", keyObsrvtry );

	
					Date now = new Date();
					now.getTime();				//	Get Current Time
					tempint = 1900 + now.getYear();		
						//	Compile the date components
						//	into a single string
						//	SHOULD BE A BETTER WAY TO DO THIS
					longdatestrnow = Integer.toString( tempint ); 
					tempint = 1 + now.getMonth();
					if ( tempint < 10 ) longdatestrnow = ( longdatestrnow + "0" + tempint );
						else longdatestrnow = ( longdatestrnow + tempint ); 
					tempint = now.getDate();
					if ( tempint < 10 ) longdatestrnow = ( longdatestrnow + "0" + tempint );
						else longdatestrnow = ( longdatestrnow + tempint ); 
					tempint = now.getHours();
					if ( tempint < 10 ) longdatestrnow = ( longdatestrnow + "_0" + tempint );
						else longdatestrnow = ( longdatestrnow + "_" + tempint ); 
					tempint = now.getMinutes();
					if ( tempint < 10 ) longdatestrnow = ( longdatestrnow + "0" + tempint );
						else longdatestrnow = ( longdatestrnow + tempint ); 
					tempint = now.getSeconds();
					if ( tempint < 10 ) longdatestrnow = ( longdatestrnow + "0" + tempint );
						else longdatestrnow = ( longdatestrnow + tempint ); 
	
					addKey ( fitsOutPathName1, "DATE", longdatestrnow );
					System.out.println("Finished making FITS File.");

					//	Set fitsOutPathName2 (adding previous keywords)
					//	and fitsOutPathName3 (adding new keywords)
					//	to fitsOutPathName1
					//	ALSO SET LABEL VALUES !!!!!!!
					fitsOutPathName2 = new String ( fitsOutPathName1 );
					fitsOutPathName3 = new String ( fitsOutPathName1 );
					fitsOutFileLabel2.setText ( fitsOutPathName1 ); 
					fitsOutFileLabel3.setText ( fitsOutPathName1 ); 

					if ( System.getProperty("file.separator").trim().equalsIgnoreCase("/") ) 
						copyDir = UnixCopyDir;
					else 
						copyDir = PCCopyDir;

					System.out.println("Preparing to copy file to " + copyDir );


					//	Copy fits file to Archive Dir
					fitsCopy ( fitsOutPathName1, new String (copyDir + fitsOutFileName), 0, 0 );

					System.out.println("Copied file to " + copyDir );
				}
			}
		});
		makefitsButton1.setAlignmentX(Component.CENTER_ALIGNMENT);

		panel1.add(Box.createRigidArea(new Dimension(0,20)));
		panel1.add(openIMGButton1);
		panel1.add(imgFileLabel1);
		panel1.add(Box.createRigidArea(new Dimension(0,20)));
		panel1.add ( pnlTest );
		panel1.add(Box.createRigidArea(new Dimension(0,20)));
		panel1.add(outputDirButton1);
		panel1.add(outputDirLabel1);
		panel1.add(Box.createRigidArea(new Dimension(0,20)));
		panel1.add(makefitsButton1);

		tabbedPane.addTab("Create FITS file from IMG", panel1);
		tabbedPane.setSelectedIndex(0);


		/**********************************************************************************/
		//	Panel2 opens an INI file and displays its contents as keywords and values.
		//
		//	The user then can add selected keywords to a selected FITS file.
		//
		//
		/**********************************************************************************/
		JPanel panel2 = new JPanel();

		panel2.setLayout(new BoxLayout(panel2, BoxLayout.Y_AXIS));
		panel2.setBorder(BorderFactory.createEmptyBorder(100,50,100,50));

		JButton openINIButton2 = new JButton("Select the input INI file.");
		final JLabel iniFileLabel2 = new JLabel ("No INI file has been selected.");
		final JComboBox iniList = new JComboBox () ;

		openINIButton2.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				fc.setFileFilter(iniFilter);
				fc.setFileSelectionMode( JFileChooser.FILES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					String s;

					iniFile = fc.getSelectedFile();

					System.out.println("Opening: " + iniFile.getName() + "." );
					iniList.removeAllItems();

					sourceFileName = iniFile.getAbsolutePath();					

					index = sourceFileName.lastIndexOf (".");
					sourceExtension = sourceFileName.substring(index+1);

					if ( sourceExtension.equalsIgnoreCase("ini") )
					{

						try {
							RandomAccessFile in = new RandomAccessFile 
								( iniFile.getAbsolutePath(),  new String("r") );
			
							in.seek(0);             //      reset pointer to beginning of file
							while ((s = in.readLine()) != null ) {
	
								index = s.lastIndexOf ( " " );
			                                	if ( index == -1 ) 
									System.out.println("No space found in line:" + s);
								else {
									keyvalue = s.substring(0,index);
									keyword = s.substring(index+1);
									iniList.addItem ( keyword + " = " + keyvalue );
								}
							}
						}       catch ( StringIndexOutOfBoundsException err ) {
							System.err.println("OutofBounds");
						}       catch ( NullPointerException err ) {
							System.err.println("NullPointer" + err );
						}       catch ( NumberFormatException err){
							System.err.println("NumberFormatException");
						}       catch ( EOFException err){
							System.err.println("EOFException");
						}       catch ( FileNotFoundException err){
							System.err.println("FileNotFoundException");
						}       catch ( IOException err){
							System.err.println("IOException");
						}
					} else {
						//System.out.println ("You chose a file with extension :" + sourceExtension + ":");

						int i, count, index2;
						count = getKeywordCount ( iniFile.getAbsolutePath() );
						//System.out.println ( count );
			
						for ( i=0; i<=count; i++ ){
							s = readFITSKeyNum( iniFile.getAbsolutePath(), i );

							index = s.indexOf ( "/" );
		                                	if (index < 1 )
								System.out.println("No keyword/value found in line:" + s);
							else {
								keyword = s.substring(0,index).trim();
								index2 = s.indexOf ("/", index+1);
								//System.out.println( "1: " + index + ", 2: " + index2 );
								keyvalue = s.substring (index+1, index2).trim();
								comment = s.substring ( index2+1).trim();
								
								if ( keyword.equalsIgnoreCase("COMMENT") || 
									keyword.equalsIgnoreCase("HISTORY"))
									iniList.addItem ( keyword + " = " + comment );
								else
									iniList.addItem ( keyword + " = " + keyvalue + "/" + comment );

								//String test;
								//test = ( keyword.trim() + " = " + keyvalue.trim() + comment.trim() );
								//System.out.println ("Length " + test.length() );
							}
						}

					}

					iniFileLabel2.setText ( iniFile.getAbsolutePath() );
				} else {
					System.out.println("Open command cancelled by user." );
				}
			}
		});
		openINIButton2.setAlignmentX(Component.CENTER_ALIGNMENT);
		iniFileLabel2.setAlignmentX(Component.CENTER_ALIGNMENT);
		JButton openFITSButton2 = new JButton("Select the FITS file to be modified.");
		openFITSButton2.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				fc.setFileFilter(fitsFilter);
				fc.setFileSelectionMode( JFileChooser.FILES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					fitsOutFile = fc.getSelectedFile();
					fitsOutPathName2 = fitsOutFile.getAbsolutePath();
					fitsOutFileName = fitsOutFile.getName();
					fitsOutFileLabel2.setText( fitsOutFile.getAbsolutePath() );
				} else {
					System.out.println("Open command cancelled by user." );
				}
			}
		});
		openFITSButton2.setAlignmentX(Component.CENTER_ALIGNMENT);
		fitsOutFileLabel2.setAlignmentX(Component.CENTER_ALIGNMENT);
		JButton addkeyButton2 = new JButton("Add selected key to selected FITS file.");
		addkeyButton2.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				if ( sourceFileName.trim().equalsIgnoreCase("") )
					System.out.println ("No Source (INI/FITS) File Selected.");
				else if ( fitsOutPathName2.trim().equalsIgnoreCase("") )
					System.out.println ("No FITS Output File Selected.");
				else {
					String readComboBox = ( (String) iniList.getSelectedItem() );
					index = readComboBox.indexOf ( "=" );
					if ( index == -1 ) 
						System.out.println("No comma found in filesize!?!?");
					else {
						keyword = readComboBox.substring ( 0, index-1 );
						keyvalue = readComboBox.substring ( index+2 );
					}
					//
					//	IF KEYVALUE IS MORE THAN ONE WORD,
					//	ALL BUT THE FIRST WILL BE COMMENTS TO THE KEYWORD
					//
					addKey ( fitsOutPathName2, keyword, keyvalue);
					System.out.println ( "Adding " + keyword + " : " + keyvalue );
				}
			}
		});
		addkeyButton2.setAlignmentX(Component.CENTER_ALIGNMENT);

		panel2.add( openINIButton2 );
		panel2.add( iniFileLabel2 );
		panel2.add(Box.createRigidArea(new Dimension(0,20)));
		panel2.add ( iniList );
		panel2.add(Box.createRigidArea(new Dimension(0,20)));
		panel2.add (openFITSButton2);
		panel2.add (fitsOutFileLabel2);
		panel2.add(Box.createRigidArea(new Dimension(0,20)));
		panel2.add (addkeyButton2);

		tabbedPane.addTab("Add FITS Keywords from INI or FITS file", panel2 );



		/**********************************************************************************/
		JPanel panel3 = new JPanel();

		panel3.setLayout(new BoxLayout(panel3, BoxLayout.Y_AXIS));
		panel3.setBorder(BorderFactory.createEmptyBorder(100,50,100,50));


		JPanel pnlKeyword = new JPanel();
			pnlKeyword.setLayout(new GridLayout(0, 1));
			Border titleK = BorderFactory.createTitledBorder ("Keyword");
			Border innerK = new CompoundBorder ( titleK, new EmptyBorder(20,20,20,20));
			pnlKeyword.setBorder ( new CompoundBorder( new EmptyBorder(0,20,0,20), innerK ));
			final JTextField txtKeyword = new JTextField ("", 20);
			pnlKeyword.add ( txtKeyword );

		JPanel pnlValue = new JPanel();
			pnlValue.setLayout(new GridLayout(0, 1));
			Border titleV = BorderFactory.createTitledBorder ("Value");
			Border imarginV = new EmptyBorder(20,20,20,20);
			Border omarginV = new EmptyBorder(0,20,0,20);
			Border innerV = new CompoundBorder ( titleV, imarginV );
			pnlValue.setBorder ( new CompoundBorder( omarginV, innerV ));
			final JTextField txtValue = new JTextField ("", 70);
			pnlValue.add ( txtValue );


		JButton openFITSButton3 = new JButton("Select the FITS file to be modified.");



		openFITSButton3.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				fc.setFileFilter(fitsFilter);
				fc.setFileSelectionMode( JFileChooser.FILES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					fitsOutFile = fc.getSelectedFile();
					fitsOutPathName3 = fitsOutFile.getAbsolutePath();
					fitsOutFileName = fitsOutFile.getName();
					fitsOutFileLabel3.setText( fitsOutFile.getAbsolutePath() );
				} else {
					System.out.println("Open command cancelled by user." );
				}
			}
		});



		openFITSButton3.setAlignmentX(Component.CENTER_ALIGNMENT);
		fitsOutFileLabel3.setAlignmentX(Component.CENTER_ALIGNMENT);
		JButton addkeyButton3 = new JButton("Add selected key to selected FITS file.");
		addkeyButton3.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				keyword = txtKeyword.getText();
				keyvalue = txtValue.getText();

				if ( keyword.trim().equalsIgnoreCase ("") )
					System.out.println ("No keyword has been entered.");
				else if ( keyvalue.trim().equalsIgnoreCase ("") )
					System.out.println ("No value has bee entered.");
				else if ( fitsOutPathName3.trim().equalsIgnoreCase ("") )
					System.out.println ("No FITS Out File Name has been selected.");
				else {
					//
					//	IF KEYVALUE IS MORE THAN ONE WORD,
					//	ALL BUT THE FIRST WILL BE COMMENTS TO THE KEYWORD
					//
					addKey ( fitsOutPathName3, keyword, keyvalue);

					System.out.println ( "Adding " + keyword + " : " + keyvalue );
				}
			}
		});
		addkeyButton3.setAlignmentX(Component.CENTER_ALIGNMENT);

		panel3.add(Box.createRigidArea(new Dimension(0,20)));
		panel3.add(pnlKeyword);
		panel3.add(Box.createRigidArea(new Dimension(0,20)));
		panel3.add(pnlValue);
		panel3.add(Box.createRigidArea(new Dimension(0,20)));
		panel3.add (openFITSButton3);
		panel3.add (fitsOutFileLabel3);
		panel3.add(Box.createRigidArea(new Dimension(0,20)));
		panel3.add (addkeyButton3);

		tabbedPane.addTab("Add Completely new FITS Keywords", panel3 );


		/**********************************************************************************/
		//Add the tabbed pane to this panel.
		setLayout(new GridLayout(1, 1)); 
		add(tabbedPane);
	}


	public static void main(String[] args) {
		JFrame frame = new JFrame("MakeFITSGUI");
		frame.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {System.exit(0);}
		});

		frame.getContentPane().add(new MakeFITSGUI(), 
			BorderLayout.CENTER);
		frame.setSize(600, 600);
		frame.setVisible(true);
	}

	static{
		System.loadLibrary("MakeFITSGUI");	//	This is required by JNI
	}
}



/*

java.lang.System

    java.version Java Runtime Environment version
    java.vendor Java Runtime Environment vendor
    java.vendor.url Java vendor URL
    java.home Java installation directory
    java.vm.specification.version Java Virtual Machine specification version
    java.vm.specification.vendor Java Virtual Machine specification vendor
    java.vm.specification.name Java Virtual Machine specification name
    java.vm.version Java Virtual Machine implementation version
    java.vm.vendor Java Virtual Machine implementation vendor
    java.vm.name Java Virtual Machine implementation name
    java.specification.version Java Runtime Environment specification version
    java.specification.vendor Java Runtime Environment specification vendor
    java.specification.name Java Runtime Environment specification name
    java.class.version Java class format version number
    java.class.path Java class path
    java.library.path List of paths to search when loading libraries
    java.io.tmpdir Default temp file path
    java.compiler Name of JIT compiler to use
    java.ext.dirs Path of extension directory or directories
    os.name Operating system name
    os.arch Operating system architecture
    os.version Operating system version
    file.separator File separator ("/" on UNIX)
    path.separator Path separator (":" on UNIX)
    line.separator Line separator ("\n" on UNIX)
    user.name User's account name
    user.home User's home directory
    user.dir User's current working directory

*/

