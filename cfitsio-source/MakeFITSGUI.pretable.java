
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



public class MakeFITSGUI extends JPanel {
	/********************************************************/
	/*		JNI Native Functions			*/
	private native String getIMGSize ( String imgPathName );
	private native int addKey ( String fitsOutFileName, String keyword, String keyValue );
	private native int showKey ( String fitsOutFileName, String keyword );
	private native int fitsCopy ( String imgPathName, String fitsOutFileName, int xsize, int ysize );
	private native int readFooter ( String imgPathName, String fitsOutFileName, int xsize, 
		int ysize, int bytecount, int offset );
	private native int getKeywordCount ( String fitsInFileName );
	private native String readFITSKeyNum ( String fitsInFileName, int KeywordNumber );

	/********************************************************/
	/*		MakeFITSGUI Constants			*/
	final private String PCCopyDir = new String ("Y:\\secchi\\");
	final private String UnixCopyDir = new String ("/net/cedar/pub/secchi/");


	/********************************************************/
	/*		MakeFITSGUI Variables			*/
	private long longdate;					//	used to store the date when read in long format
	private String strDateObsKy = new String("");		//	the DATE-OBS in keyword format
	private String strDateObsFn = new String("");		//	the DATE-OBS in filename format
	private String strDateNow = new String("");		//	the current DATE in keyword format
	private String imgFilename = new String("");		//	IMG filename only
	private String imgPathName = new String("");		//	IMG filename with path
	private String fitsOutFileName = new String("");	//	FITS filename only (for keyword) (generated)
	private String tmpFITSName = new String("");		//	TEMPORARY FITS Filename in panel5
	private String fitsOutPathName1 = new String ("");	//	FITS filename with path (generated)
	private String fitsOutPathName2 = new String ("");	//	FITS filename with path (generated or selected)
	private String fitsOutPathName3 = new String ("");	//	FITS filename with path (generated or selected)
	private String sourceFileName = new String("");		//	INI or FITS filename source of keywords
	private String sourceExtension = new String("");	//	extension of INI or FITS file
	private String secchiExtension = new String("");	//	Used for the filename coding
	private String outputDir = new String ("");		//	directory selected as output target
	private String copyDir = new String ("");		//	directory FITS file is copied to after generation
	private String keyObsrvtry = new String ("");		//	OBSRVTRY keyword value
	private String codeObsrvtry = new String ("");		//	OBSRVTRY code
	private String keyDetector = new String ("");		//	DETECTOR keyword value
	private String codeDetector = new String ("");		//	DETECTOR code

	private int index;
	private int intKeywordCount;
	private int tempint;
	private int xsize = 0;
	private int ysize = 0;
	private String imgsizes = new String("");
	private String keyword = new String("");
	private String keyvalue = new String("");
	private String comment = new String("");

	private File imgFile;
	private File fitsInFile;
	private File fitsOutFile;
	private File iniFile;
	private File outputDirFile;

	/********************************************************/
	/*	PROGRAM SETTINGS INFORMATION			*/
	static private File settingsFile;			//	file for storing program settings
	final static private String settingsFilename = 
		new String ( System.getProperty ("user.home") + 
			System.getProperty ("file.separator") +
			"makefits.ini" );			//	filename for storing program settings
	static private String fcDirIMG = new String ("");	//	initial IMG directory for filechooser
	static private String fcDirOut = new String ("");	//	initial FITS OUT directory for filechooser
	static private String fcDirIn = new String ("");	//	initial FITS IN directory for filechooser
	/********************************************************/



	/*	MakeFITSGUI Functions and Procedures	*/
	public MakeFITSGUI() {

		/**********************************************************************************/
		//
		//		READ SETTINGS FILE DATA
		//
		System.out.println ( "Reading settings from: " + settingsFilename );
		System.out.println ( "User's home dir: " + System.getProperty ("user.home") );
		settingsFile = new File ( settingsFilename );
		if ( settingsFile.exists() ) {
			String setting = new String ("");
			String varName = new String ("");
			String varValue = new String ("");

			try {
				RandomAccessFile in = new RandomAccessFile 
					( settingsFilename, new String("r") );
				in.seek(0);             //      reset pointer to beginning of file
				while ((setting = in.readLine()) != null ) {
					index = setting.lastIndexOf ( "=" );
                                	if ( index == -1 ) 
						System.out.println("Invalid line :" + setting);
					else {
						System.out.println ( "Valid setting: " + setting );
						varName = setting.substring(0,index).trim();
						if ( varName.equalsIgnoreCase("IMG_DIR") ) 
							fcDirIMG = new String ( setting.substring(index+1).trim() );
						else if ( varName.equalsIgnoreCase("OUT_DIR") ) 
							fcDirOut = new String ( setting.substring(index+1).trim() );
						else if ( varName.equalsIgnoreCase("IN_DIR") ) 
							fcDirIn = new String ( setting.substring(index+1).trim() );
						else System.out.println ("No valid setting");
					//	System.out.println ( varName + " -- " + fcDirIMG + " -- " 
					//		+ fcDirOut + " -- " + fcDirIn );
					}
				}
				in.close();
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
		} else System.out.println ("No makefits.ini file found.  Using default settings.");

		/**********************************************************************************/





		JTabbedPane tabbedPane = new JTabbedPane();

		/**********************************************************************************/
		//
		//		DEFINE FILECHOOSER AND IT'S FILTERS
		//
		final JFileChooser fc = new JFileChooser();

		final ExampleFileFilter imgFilter = new ExampleFileFilter();
		imgFilter.addExtension("img");
		imgFilter.addExtension("dat");
		imgFilter.setDescription("Camera IMG/RAL files.");
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
		/**********************************************************************************/


		/**********************************************************************************/
		//
		//		OBJECTS WITH EARLY REFERENCES
		//
		final JLabel fitsOutFileLabel2 = new JLabel ("No FITS file has been selected.");
		final JLabel fitsOutFileLabel3 = new JLabel ("No FITS file has been selected.");	
		/**********************************************************************************/



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
				fc.setCurrentDirectory ( new File ( fcDirIMG ) );
				fc.setFileFilter(imgFilter);
				fc.setFileSelectionMode( JFileChooser.FILES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					imgFile = fc.getSelectedFile();
					
					/*	Strip and Reassemble the TimeStamp	*/
					Date newdate = new Date(imgFile.lastModified());
					longdate = imgFile.lastModified();
					tempint = 1900 + newdate.getYear();

					strDateObsKy = Integer.toString( tempint ); 
						//	Compile the date components
						//	into a single string
						//	SHOULD BE A BETTER WAY TO DO THIS
					tempint = 1 + newdate.getMonth();
					if ( tempint < 10 ) strDateObsKy = ( strDateObsKy + "-0" + tempint );
						else strDateObsKy = ( strDateObsKy + "-" + tempint ); 
					tempint = newdate.getDate();
					if ( tempint < 10 ) strDateObsKy = ( strDateObsKy + "-0" + tempint );
						else strDateObsKy = ( strDateObsKy + "-" + tempint ); 
					tempint = newdate.getHours();
					if ( tempint < 10 ) strDateObsKy = ( strDateObsKy + "t0" + tempint );
						else strDateObsKy = ( strDateObsKy + "t" + tempint ); 
					tempint = newdate.getMinutes();
					if ( tempint < 10 ) strDateObsKy = ( strDateObsKy + ":0" + tempint );
						else strDateObsKy = ( strDateObsKy + ":" + tempint ); 
					tempint = newdate.getSeconds();
					if ( tempint < 10 ) strDateObsKy = ( strDateObsKy + ":0" + tempint );
						else strDateObsKy = ( strDateObsKy + ":" + tempint ); 

					tempint = 1900 + newdate.getYear();
					strDateObsFn = Integer.toString( tempint ); 
						//	Compile the date components
						//	into a single string
						//	SHOULD BE A BETTER WAY TO DO THIS
					tempint = 1 + newdate.getMonth();
					if ( tempint < 10 ) strDateObsFn = ( strDateObsFn + "0" + tempint );
						else strDateObsFn = ( strDateObsFn + tempint ); 
					tempint = newdate.getDate();
					if ( tempint < 10 ) strDateObsFn = ( strDateObsFn + "0" + tempint );
						else strDateObsFn = ( strDateObsFn + tempint ); 
					tempint = newdate.getHours();
					if ( tempint < 10 ) strDateObsFn = ( strDateObsFn + "_0" + tempint );
						else strDateObsFn = ( strDateObsFn + "_" + tempint ); 
					tempint = newdate.getMinutes();
					if ( tempint < 10 ) strDateObsFn = ( strDateObsFn + "0" + tempint );
						else strDateObsFn = ( strDateObsFn + tempint ); 
					tempint = newdate.getSeconds();
					if ( tempint < 10 ) strDateObsFn = ( strDateObsFn + "0" + tempint );
						else strDateObsFn = ( strDateObsFn + tempint ); 


					//	System.out.println ( "Date Obs (keyword)  " + strDateObsKy );
					//	System.out.println ( "Date Obs (filename) " + strDateObsFn );
					
					imgFilename = imgFile.getName();
					imgPathName = imgFile.getAbsolutePath();
					imgsizes = getIMGSize( imgPathName ); 
					index = imgsizes.indexOf ( "," );
                                	if ( index == -1 ) {
						imgsizes = "" ;
						//	System.out.println("No comma found in filesize!?!?");
						System.out.println("Unable to determine Image Dimensions.");
					} else {
						xsize = Integer.parseInt (imgsizes.substring(0,index) );
						ysize = Integer.parseInt (imgsizes.substring(index+1) );
                                        	imgFileLabel1.setText( imgFile.getAbsolutePath() + " - " + xsize + ", " + ysize );
					}

					/*************************************************/
					//	SAVE DIRECTORY CHOICE
					fcDirIMG = new String ( imgFile.getParent() + System.getProperty ("file.separator") );
					//	System.out.println (fcDirIMG);
					/*************************************************/
				} else {
					//	System.out.println("Open command canceled by user." );
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

			JPanel pnlDetector = new JPanel();
				pnlDetector.setLayout(new GridLayout(0, 1));
				Border titleD = BorderFactory.createTitledBorder ("Detector");
				Border innerD = new CompoundBorder ( titleD,  new EmptyBorder(20,20,20,20));
				pnlDetector.setBorder ( new CompoundBorder( new EmptyBorder(0,20,0,20), innerD ));
	
				JRadioButton[] rdbDetector = new JRadioButton[8];
				final ButtonGroup rdbgrpDetector = new ButtonGroup();
				rdbDetector[0] = new JRadioButton("EUVI");
				rdbDetector[1] = new JRadioButton("COR1");
				rdbDetector[2] = new JRadioButton("COR2");
				rdbDetector[3] = new JRadioButton("HI1");
				rdbDetector[4] = new JRadioButton("HI2");
				rdbDetector[5] = new JRadioButton("GT");
				rdbDetector[6] = new JRadioButton("Talktronics");
				rdbDetector[7] = new JRadioButton("RAL development camera");
				for ( int i = 0; i < 8; i++ ) {
					rdbDetector[i].setActionCommand(""+i);
					rdbgrpDetector.add(rdbDetector[i]);
					pnlDetector.add(rdbDetector[i]);
				}
				rdbDetector[6].setSelected(true);


			JPanel pnlCamera = new JPanel();
				pnlCamera.setLayout(new GridLayout(0, 1));
				Border titleC = BorderFactory.createTitledBorder ("Camera");
				Border innerC = new CompoundBorder ( titleC, new EmptyBorder(20,20,20,20));
				pnlCamera.setBorder ( new CompoundBorder( new EmptyBorder(0,20,0,20), innerC ));
	
				JRadioButton[] rdbCamera = new JRadioButton[3];
				final ButtonGroup rdbgrpCamera = new ButtonGroup();
				rdbCamera[0] = new JRadioButton("Talktronics IDS-2100");
				rdbCamera[1] = new JRadioButton("RAL Prototype");
				rdbCamera[2] = new JRadioButton("RAL DM");
				for ( int i = 0; i < 3; i++ ) {
					rdbCamera[i].setActionCommand(""+i);
					rdbgrpCamera.add(rdbCamera[i]);
					pnlCamera.add(rdbCamera[i]);
				}
				rdbCamera[0].setSelected(true);

		pnlTest.add ( pnlObsrvtry );
		pnlTest.add ( pnlDetector );
		pnlTest.add ( pnlCamera );


		//Create the output directory button
		JButton outputDirButton1 = new JButton("Select the Output Directory." );
		final JLabel outputDirLabel1 = new JLabel("No Output Dir has been selected.");
		outputDirButton1.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				fc.setCurrentDirectory ( new File ( fcDirOut ) );
				fc.setFileSelectionMode ( JFileChooser.DIRECTORIES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					outputDirFile = fc.getSelectedFile();
					
					outputDir = new String ( outputDirFile.getAbsolutePath() + outputDirFile.separator );
					//	System.out.println ( outputDir );

					outputDirLabel1.setText( outputDirFile.getAbsolutePath() + outputDirFile.separator );
					/*************************************************/
					//	SAVE DIRECTORY CHOICE
					fcDirOut = new String ( outputDirFile.getPath() + System.getProperty ("file.separator") );
					//	System.out.println (fcDirOut);
					/*************************************************/
				} else {
					//	System.out.println("Open command cancelled by user." );
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
					
					switch ( Integer.parseInt(rdbgrpDetector.getSelection().getActionCommand())) {
						case 0: codeDetector = new String ("eu");	
							keyDetector = new String ("EUVI");
							break;
						case 1: codeDetector = new String ("c1");	
							keyDetector = new String ("COR1");
							break;
						case 2: codeDetector = new String ("c2");	
							keyDetector = new String ("COR2");
							break;
						case 3:	codeDetector = new String ("h1");	
							keyDetector = new String ("HI1");
							break;
						case 4: codeDetector = new String ("h2");	
							keyDetector = new String ("HI2");
							break;
						case 5: codeDetector = new String ("gt");	
							keyDetector = new String ("GT");
							break;
						case 6: codeDetector = new String ("tk");	
							keyDetector = new String ("Talktronics");
							break;
						case 7: codeDetector = new String ("ra");	
							keyDetector = new String ("RAL Development Camera");
							break;
						default:	//	Bad Selection (shouldn't be possible with Radio)
					}
					secchiExtension = secchiExtension + codeDetector;

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
					fitsOutFileName = strDateObsFn + secchiExtension;
					fitsOutPathName1 = outputDir + strDateObsFn + secchiExtension;

					fitsCopy ( imgPathName, fitsOutPathName1, xsize, ysize );
					readFooter ( imgPathName, fitsOutPathName1, xsize, ysize, 2, 4 );
					addKey ( fitsOutPathName1, "HISTORY", 
						"Converted from IMG to FITS using Jake's Java/JNI/C MakeFITSGUI.");
					addKey ( fitsOutPathName1, "FILENAME", fitsOutFileName );



					addKey ( fitsOutPathName1, "FILEORIG", imgFilename );
					//	MAY HAVE TO ADD AN A OR B INSIDE THIS FILENAME




					addKey ( fitsOutPathName1, "DATE-OBS", strDateObsKy );
					addKey ( fitsOutPathName1, "DETECTOR", keyDetector );
					switch ( Integer.parseInt(rdbgrpCamera.getSelection().getActionCommand())) {
						case 0: addKey ( fitsOutPathName1, "CAMERA", "Talktronics_IDS-2100");
							break;
						case 1: addKey ( fitsOutPathName1, "CAMERA", "RAL_Prototype");
							break;
						case 2: addKey ( fitsOutPathName1, "CAMERA", "RAL_DM");
							break;
						default:	//	Bad Selection (shouldn't be possible with Radio)
					}

					addKey ( fitsOutPathName1, "OBSRVTRY", keyObsrvtry );

	
					Date now = new Date();
					now.getTime();				//	Get Current Time
					tempint = 1900 + now.getYear();		
						//	Compile the date components
						//	into a single string
						//	SHOULD BE A BETTER WAY TO DO THIS
					strDateNow = Integer.toString( tempint ); 
					tempint = 1 + now.getMonth();
					if ( tempint < 10 ) strDateNow = ( strDateNow + "-0" + tempint );
						else strDateNow = ( strDateNow + "-" + tempint ); 
					tempint = now.getDate();
					if ( tempint < 10 ) strDateNow = ( strDateNow + "-0" + tempint );
						else strDateNow = ( strDateNow + "-" + tempint ); 
					tempint = now.getHours();
					if ( tempint < 10 ) strDateNow = ( strDateNow + "t0" + tempint );
						else strDateNow = ( strDateNow + "t" + tempint ); 
					tempint = now.getMinutes();
					if ( tempint < 10 ) strDateNow = ( strDateNow + ":0" + tempint );
						else strDateNow = ( strDateNow + ":" + tempint ); 
					tempint = now.getSeconds();
					if ( tempint < 10 ) strDateNow = ( strDateNow + ":0" + tempint );
						else strDateNow = ( strDateNow + ":" + tempint ); 
	
					addKey ( fitsOutPathName1, "DATE", strDateNow );
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
				fc.setCurrentDirectory ( new File ( fcDirIn ) );
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

						int i, index2;
						intKeywordCount = getKeywordCount ( iniFile.getAbsolutePath() );
						//System.out.println ( intKeywordCount );
			
						for ( i=0; i<=intKeywordCount; i++ ){
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

					/*************************************************/
					//	SAVE DIRECTORY CHOICE
					fcDirIn = new String ( iniFile.getParent() + System.getProperty("file.separator") );
					//	System.out.println (fcDirIn);
					/*************************************************/
				} else {
					//	System.out.println("Open command cancelled by user." );
				}
			}
		});
		openINIButton2.setAlignmentX(Component.CENTER_ALIGNMENT);
		iniFileLabel2.setAlignmentX(Component.CENTER_ALIGNMENT);
		JButton openFITSButton2 = new JButton("Select the FITS file to be modified.");
		openFITSButton2.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				fc.setFileFilter(fitsFilter);
				fc.setCurrentDirectory ( new File ( fcDirIn ) );
				fc.setFileSelectionMode( JFileChooser.FILES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					fitsOutFile = fc.getSelectedFile();
					fitsOutPathName2 = fitsOutFile.getAbsolutePath();
					fitsOutFileName = fitsOutFile.getName();
					fitsOutFileLabel2.setText( fitsOutFile.getAbsolutePath() );

					/*************************************************/
					//	SAVE DIRECTORY CHOICE
					fcDirIn = new String ( fitsOutFile.getParent() + System.getProperty("file.separator") );
					//	System.out.println (fcDirIn);
					/*************************************************/
				} else {
					//	System.out.println("Open command cancelled by user." );
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
				fc.setCurrentDirectory ( new File ( fcDirIn ) );
				fc.setFileSelectionMode( JFileChooser.FILES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					fitsOutFile = fc.getSelectedFile();
					fitsOutPathName3 = fitsOutFile.getAbsolutePath();
					fitsOutFileName = fitsOutFile.getName();
					fitsOutFileLabel3.setText( fitsOutFile.getAbsolutePath() );

					/*************************************************/
					//	SAVE DIRECTORY CHOICE
					fcDirIn = new String ( fitsOutFile.getParent() + System.getProperty("file.separator") );
					//	System.out.println (fcDirIn);
					/*************************************************/
				} else {
					//	System.out.println("Open command cancelled by user." );
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
		JPanel panel5 = new JPanel();
		panel5.setLayout(new BoxLayout(panel5, BoxLayout.Y_AXIS));
		panel5.setBorder(BorderFactory.createEmptyBorder(20,20,20,20));
		final FITSTable FITSPanel = new FITSTable();

		JButton btnPanel5File = new JButton ("Select Input File");
		btnPanel5File.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				fc.setCurrentDirectory ( new File ( fcDirIMG ) );
				fc.setFileFilter(imgFilter);
				fc.setFileSelectionMode( JFileChooser.FILES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					int index;

					imgFile = fc.getSelectedFile();
					imgFilename = imgFile.getName();
					imgPathName = imgFile.getAbsolutePath();
					
					/*	Strip and Reassemble the TimeStamp	*/
					Date newdate = new Date(imgFile.lastModified());
					longdate = imgFile.lastModified();
					tempint = 1900 + newdate.getYear();

					strDateObsKy = Integer.toString( tempint ); 
						//	Compile the date components
						//	into a single string
						//	SHOULD BE A BETTER WAY TO DO THIS
					tempint = 1 + newdate.getMonth();
					if ( tempint < 10 ) strDateObsKy = ( strDateObsKy + "-0" + tempint );
						else strDateObsKy = ( strDateObsKy + "-" + tempint ); 
					tempint = newdate.getDate();
					if ( tempint < 10 ) strDateObsKy = ( strDateObsKy + "-0" + tempint );
						else strDateObsKy = ( strDateObsKy + "-" + tempint ); 
					tempint = newdate.getHours();
					if ( tempint < 10 ) strDateObsKy = ( strDateObsKy + "t0" + tempint );
						else strDateObsKy = ( strDateObsKy + "t" + tempint ); 
					tempint = newdate.getMinutes();
					if ( tempint < 10 ) strDateObsKy = ( strDateObsKy + ":0" + tempint );
						else strDateObsKy = ( strDateObsKy + ":" + tempint ); 
					tempint = newdate.getSeconds();
					if ( tempint < 10 ) strDateObsKy = ( strDateObsKy + ":0" + tempint );
						else strDateObsKy = ( strDateObsKy + ":" + tempint ); 

					tempint = 1900 + newdate.getYear();
					strDateObsFn = Integer.toString( tempint ); 
						//	Compile the date components
						//	into a single string
						//	SHOULD BE A BETTER WAY TO DO THIS
					tempint = 1 + newdate.getMonth();
					if ( tempint < 10 ) strDateObsFn = ( strDateObsFn + "0" + tempint );
						else strDateObsFn = ( strDateObsFn + tempint ); 
					tempint = newdate.getDate();
					if ( tempint < 10 ) strDateObsFn = ( strDateObsFn + "0" + tempint );
						else strDateObsFn = ( strDateObsFn + tempint ); 
					tempint = newdate.getHours();
					if ( tempint < 10 ) strDateObsFn = ( strDateObsFn + "_0" + tempint );
						else strDateObsFn = ( strDateObsFn + "_" + tempint ); 
					tempint = newdate.getMinutes();
					if ( tempint < 10 ) strDateObsFn = ( strDateObsFn + "0" + tempint );
						else strDateObsFn = ( strDateObsFn + tempint ); 
					tempint = newdate.getSeconds();
					if ( tempint < 10 ) strDateObsFn = ( strDateObsFn + "0" + tempint );
						else strDateObsFn = ( strDateObsFn + tempint ); 


					imgsizes = getIMGSize( imgPathName ); 
					index = imgsizes.indexOf ( "," );
                                	if ( index == -1 ) {
						imgsizes = "" ;
						//	System.out.println("No comma found in filesize!?!?");
						System.out.println("Unable to determine Image Dimensions.");
					} else {
						xsize = Integer.parseInt (imgsizes.substring(0,index) );
						ysize = Integer.parseInt (imgsizes.substring(index+1) );
					}

					//
					//	DELETE POSSIBLE TARGET OUTPUT TEMPORARY FITS FILE
					//
					//	USE NOW AS TEMPORARY FILENAME FOR NOW....
					//
					Date now = new Date();
					now.getTime();				//	Get Current Time
					tempint = 1900 + now.getYear();		
						//	Compile the date components
						//	into a single string
						//	SHOULD BE A BETTER WAY TO DO THIS
					strDateNow = Integer.toString( tempint ); 
					tempint = 1 + now.getMonth();
					if ( tempint < 10 ) strDateNow = ( strDateNow + "0" + tempint );
						else strDateNow = ( strDateNow + tempint ); 
					tempint = now.getDate();
					if ( tempint < 10 ) strDateNow = ( strDateNow + "0" + tempint );
						else strDateNow = ( strDateNow + tempint ); 
					tempint = now.getHours();
					if ( tempint < 10 ) strDateNow = ( strDateNow + "t0" + tempint );
						else strDateNow = ( strDateNow + "t" + tempint ); 
					tempint = now.getMinutes();
					if ( tempint < 10 ) strDateNow = ( strDateNow + "0" + tempint );
						else strDateNow = ( strDateNow + tempint ); 
					tempint = now.getSeconds();
					if ( tempint < 10 ) strDateNow = ( strDateNow + "0" + tempint );
						else strDateNow = ( strDateNow + tempint ); 





					tmpFITSName =  ( System.getProperty ( "user.home" )
							+ System.getProperty ( "file.separator" )
							+ "temp-" + strDateNow + ".fits" );
					System.out.println ("Using temporary name: " + tmpFITSName );








					//
					//	CONVERT IMG INTO TEMPORARY FITS FILE FOR READING
					//
					System.out.println ("Creating temporary FITS file for reading.");
					fitsCopy ( imgPathName, tmpFITSName, xsize, ysize );
					if ( imgPathName.substring ( imgPathName.length()-3, imgPathName.length() )
						.equalsIgnoreCase("img") )
						readFooter ( imgPathName, tmpFITSName, xsize, ysize, 2, 4 );

					//
					//	READ THE ENTIRE HEADER AND DISPLAY IN TABLE AS UNEDITABLE
					//
			
					String s;
					int i, index2;

					intKeywordCount = getKeywordCount ( tmpFITSName );
					System.out.println ("Found " + intKeywordCount + " keywords in temp FITS file.");
					System.out.println ("Reading temporary FITS file header.");
					for ( i=0; i<=intKeywordCount; i++ ){
						s = readFITSKeyNum( tmpFITSName, i );

						index = s.indexOf ( "/" );
	                                	if (index < 1 )
							System.out.println("No keyword/value found in line:" + s);
						else {
							keyword = s.substring(0,index).trim();
							index2 = s.indexOf ("/", index+1);
							keyvalue = s.substring (index+1, index2).trim();
							comment = s.substring ( index2+1).trim();
							
							if ( keyword.equalsIgnoreCase("COMMENT") || 
								keyword.equalsIgnoreCase("HISTORY"))
							{
								FITSPanel.addRow ( keyword, new String[] { comment }, "false" );
								System.out.println ( keyword + "     " +  comment );
							}
							else
							{
								FITSPanel.addRow ( keyword, new String[] 
									{ keyvalue + "     /     " + comment }, "false" );
								System.out.println ( keyword + "     " + keyvalue + "     " + comment );
							}
						}
					}


					//
					//	THEN DELETE TEMPORARY FITS FILE
					//
					//	delete ( tmpFITSName );
                                        File tmpFITSFile = new File ( tmpFITSName );
                                        if ( tmpFITSFile.delete() )
						System.out.println ( "Temporary FITS file deleted." );
					else
						System.out.println ( "Temporary FITS file deletion FAILED." );
					//
					//	PERHAPS SET tmpFITSFile TO NOTHING OR NULL HERE????
					//




					//
					//	THEN ADD REST OF HEADER TO TABLE
					//
					//FITSPanel.addRow ( "SIMPLE", new String[] {""}, "false");         //COMPUTED
					//FITSPanel.addRow ( "BITPIX", new String[] {""}, "false");         //COMPUTED
					//FITSPanel.addRow ( "NAXIS", new String[] {""}, "false");
					//FITSPanel.addRow ( "NAXIS1", new String[] {""}, "false" );
					//FITSPanel.addRow ( "NAXIS2", new String[] {""}, "false");
					FITSPanel.addRow ( "DATE", new String[] {"COMPUTED_AT_GO_TIME"}, "false");
					FITSPanel.addRow ( "FILENAME", new String[] {"COMPUTED_AT_GO_TIME"}, "false");


					FITSPanel.addRow ( "FILEORIG", new String[] { imgFilename }, "false");
					FITSPanel.addRow ( "DATE_OBS", new String[] { strDateObsKy }, "false");
					FITSPanel.addRow ( "EXPTIME", new String[] {""}, "true" );
					FITSPanel.addRow ( "OBSRVTRY", new String [] 
						{ "Other_C", "STEREO_A", "STEREO_B" }, "false" );
					FITSPanel.addRow ( "DETECTOR", new String [] 
						{ "Talktronics", "EUVI", "COR1", "COR2", "HI1", "HI2", 
							"GT", "RAL_development_camera" }, "false" );
					FITSPanel.addRow ( "SUMMED", new String[] {""} );
					FITSPanel.addRow ( "SUMTYPE", new String[] 
						{"CCD", "NONE", "SEB", "REBIN", "CONGRID"} );
					FITSPanel.addRow ( "P1COL", new String[] {"1"}, "false");
					FITSPanel.addRow ( "P2COL", new String[] {"NAXIS1"}, "false");
					FITSPanel.addRow ( "P1ROW", new String[] {"1"}, "false" );
					FITSPanel.addRow ( "P2ROW", new String[] {"NAXIS2"}, "false" );
					FITSPanel.addRow ( "INTRUMEN", new String[] {"SECCHI"}, "false" );
					FITSPanel.addRow ( "VERSION", new String[] {"yymmdd"});
					FITSPanel.addRow ( "ORIGIN", new String[] 
						{"NRL", "GSFC", "UBHAM", "LMSAL", "APL"} );
					FITSPanel.addRow ( "BUNIT", new String[] {""} );
					FITSPanel.addRow ( "BLANK", new String[] {""} );
					FITSPanel.addRow ( "COMMENT", new String[] {""} );
					FITSPanel.addRow ( "COMMENT", new String[] {""} );
					FITSPanel.addRow ( "COMMENT", new String[] 
						{"FITS coordinates for center of 1024x1024 image are [512.5, 512.5]"}, "false");
					FITSPanel.addRow ( "COMMENT", new String[] 
						{"DATE-OBS is equal to .img file last-modified date"}, "false");
					FITSPanel.addRow ( "HISTORY", new String[] {""} );
					FITSPanel.addRow ( "OBSERVER", new String[] {"ListOfNames"});
					FITSPanel.addRow ( "OBJECT", new String[] {""});
					FITSPanel.addRow ( "OBS_PROG", new String[] {"InsertList"});
					FITSPanel.addRow ( "COMMENT", new String[] {""} );
					FITSPanel.addRow ( "CCD_ID", new String[] {""});
					FITSPanel.addRow ( "CAMERA", new String [] 
						{ "Talktronics_IDS-2100", "RAL_Prototype", "RAL_DM" }, "false" );
					FITSPanel.addRow ( "DIODSTEP", new String[] {""});
					FITSPanel.addRow ( "DIODWVLN", new String[] {""});
					FITSPanel.addRow ( "DIODFILE", new String[] {""});
					FITSPanel.addRow ( "CS", new String[] {""});
					FITSPanel.addRow ( "SR", new String[] {""});
					FITSPanel.addRow ( "FILTER", new String[] {"InsertList"}, "false" );
					FITSPanel.addRow ( "DIODCOAT", new String[] {"InsertList"}, "false" );
					FITSPanel.addRow ( "DIODDESC", new String[] {"InsertList"}, "false" );
					FITSPanel.addRow ( "CONTAMIN", new String[] {"False", "True"}, "false" );
					FITSPanel.addRow ( "DCS", new String[] {""} );
					FITSPanel.addRow ( "VOLTAGE",new String[] {""} );
					FITSPanel.addRow ( "CCD_COAT", new String[] {"InsertList"}, "false" );
					FITSPanel.addRow ( "VIDGAIN", new String[] {""} );
					FITSPanel.addRow ( "DITHER", new String[] {"False", "True"}, "false" );
					FITSPanel.addRow ( "READPORT", new String[] {"A", "B"}, "false" );
					FITSPanel.addRow ( "MODE", new String[] 
						{"DUMP", "INTEGRAT", "READOUT", "CONT"}, "false" );
					FITSPanel.addRow ( "CCD_WFH", new String[] {""} );
					FITSPanel.addRow ( "CCD_WFV", new String[] {""} );
					FITSPanel.addRow ( "TEMP_CCD", new String[] {""} );
					FITSPanel.addRow ( "COMMENT", new String[] {""} );
					//FITSPanel.addRow ( "PROCESSING TYPE", new String [] { "p" }, "false" );
				}
			}	
		});



		JButton btnAddComment = new JButton ("Add Comment");
		btnAddComment.addActionListener( new ActionListener()
		{	public void actionPerformed(ActionEvent e)
			{
				FITSPanel.addRow ( "COMMENT", new String[] {""} );
			}
		});
		


		JButton btnAddHistory = new JButton ("Add History");
		btnAddHistory.addActionListener( new ActionListener()
		{	public void actionPerformed(ActionEvent e)
			{
				FITSPanel.addRow ( "HISTORY", new String[] {""} );
			}
		});







		//Create the GO button
		JButton btnMakeFITS = new JButton("GO!" );
		btnMakeFITS.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if ( imgsizes.trim().equalsIgnoreCase("") )
					System.out.println ("Was unable to determine Image Dimensions earlier");
				else if ( imgPathName.trim().equalsIgnoreCase("") )
					System.out.println ("No IMG In File Selected.");
				else {				
					int i;

					for (i=intKeywordCount+2; i<FITSPanel.getRowCount(); i++) 
					{
						if ( FITSPanel.getValueAt( i, 0 ).toString().trim().equalsIgnoreCase("DETECTOR") )
						{
							if ( FITSPanel.getValueAt ( i, 1 ).toString().trim().equalsIgnoreCase("EUVI") )
								codeDetector = new String ("eu");	
							else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim().equalsIgnoreCase("COR1") )
								codeDetector = new String ("c1");	
							else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim().equalsIgnoreCase("COR2") )
								codeDetector = new String ("c2");	
							else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim().equalsIgnoreCase("HI1") )
								codeDetector = new String ("h1");	
							else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim().equalsIgnoreCase("HI2") )
								codeDetector = new String ("h2");	
							else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim().equalsIgnoreCase("GT") )
								codeDetector = new String ("gt");	
							else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim().equalsIgnoreCase("Talktronics") )
								codeDetector = new String ("tk");	
							else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim().equalsIgnoreCase("RAL_Development_Camera") )
								codeDetector = new String ("ra");	
							else codeDetector = new String ("xx");
						}
						else if ( FITSPanel.getValueAt( i, 0 ).toString().trim().equalsIgnoreCase("OBSRVTRY") )
						{
							if ( FITSPanel.getValueAt ( i, 1 ).toString().trim().equalsIgnoreCase("Other_C") )
								codeObsrvtry = new String ("c");
							else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim().equalsIgnoreCase("STEREO_A") )
								codeObsrvtry = new String ("a");
							else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim().equalsIgnoreCase("STEREO_B") )
								codeObsrvtry = new String ("b");
							else codeObsrvtry = new String ("x");

						}
					}



					//
					//	L = a digit representing processing level, or 
					//	'r' for quick-look or 'p' for pre-flight  
					//
					secchiExtension = new String ( "_p" + codeDetector + codeObsrvtry + ".fts" );

					fitsOutFileName = strDateObsFn + secchiExtension;
					fitsOutPathName1 = outputDir + strDateObsFn + secchiExtension;

					fitsCopy ( imgPathName, fitsOutPathName1, xsize, ysize );
					if ( imgPathName.substring ( imgPathName.length()-3, imgPathName.length() )
						.equalsIgnoreCase("img") )
						readFooter ( imgPathName, fitsOutPathName1, xsize, ysize, 2, 4 );
					addKey ( fitsOutPathName1, "HISTORY", 
						"Converted from IMG to FITS using Jake's Java/JNI/C MakeFITSGUI.");

					addKey ( fitsOutPathName1, "FILENAME", fitsOutFileName );

//
//	MAY HAVE TO ADD AN A OR B INSIDE THIS FILENAME
//

	
					Date now = new Date();
					now.getTime();				//	Get Current Time
					tempint = 1900 + now.getYear();		
						//	Compile the date components
						//	into a single string
						//	SHOULD BE A BETTER WAY TO DO THIS
					strDateNow = Integer.toString( tempint ); 
					tempint = 1 + now.getMonth();
					if ( tempint < 10 ) strDateNow = ( strDateNow + "-0" + tempint );
						else strDateNow = ( strDateNow + "-" + tempint ); 
					tempint = now.getDate();
					if ( tempint < 10 ) strDateNow = ( strDateNow + "-0" + tempint );
						else strDateNow = ( strDateNow + "-" + tempint ); 
					tempint = now.getHours();
					if ( tempint < 10 ) strDateNow = ( strDateNow + "t0" + tempint );
						else strDateNow = ( strDateNow + "t" + tempint ); 
					tempint = now.getMinutes();
					if ( tempint < 10 ) strDateNow = ( strDateNow + ":0" + tempint );
						else strDateNow = ( strDateNow + ":" + tempint ); 
					tempint = now.getSeconds();
					if ( tempint < 10 ) strDateNow = ( strDateNow + ":0" + tempint );
						else strDateNow = ( strDateNow + ":" + tempint ); 
					addKey ( fitsOutPathName1, "DATE", strDateNow );

					//
					//	Add most of table to FITS header
					//
					for (i=intKeywordCount+2; i<FITSPanel.getRowCount(); i++) 
					{
						System.out.println ( "Adding keyword --- " + FITSPanel.getValueAt(i,0).toString() );
						addKey ( fitsOutPathName1, 
							FITSPanel.getValueAt( i, 0 ).toString(),
							FITSPanel.getValueAt( i, 1 ).toString() );
					}






					System.out.println("Finished making FITS File.");

					//	Set fitsOutPathName2 (adding previous keywords)
					//	and fitsOutPathName3 (adding new keywords)
					//	to fitsOutPathName1
					//	ALSO SET LABEL VALUES !!!!!!!
					//fitsOutPathName2 = new String ( fitsOutPathName1 );
					//fitsOutPathName3 = new String ( fitsOutPathName1 );
					//fitsOutFileLabel2.setText ( fitsOutPathName1 ); 
					//fitsOutFileLabel3.setText ( fitsOutPathName1 ); 

					if ( System.getProperty("file.separator").trim().equalsIgnoreCase("/") ) 
						copyDir = UnixCopyDir;
					else 
						copyDir = PCCopyDir;
					System.out.println("Preparing to copy file to " + copyDir + " for archiving.");


					//	Copy fits file to Archive Dir
					//fitsCopy ( fitsOutPathName1, new String (copyDir + fitsOutFileName), 0, 0 );

					System.out.println("STILL TESTING. FILE NOT COPIED......   Copied file to " + copyDir );
				}
			}
		});
		btnMakeFITS.setAlignmentX(Component.CENTER_ALIGNMENT);























		panel5.add ( btnPanel5File );
		panel5.add ( FITSPanel );

		JPanel btnPanel = new JPanel();
			btnPanel.setLayout(new GridLayout(0, 2));
			//Border titleB = BorderFactory.createTitledBorder ("Buttons");
			//Border imarginB = new EmptyBorder(20,20,20,20);
			//Border omarginB = new EmptyBorder(0,20,0,20);
			//Border innerB = new CompoundBorder ( titleB, imarginB );
			//btnPanel.setBorder ( new CompoundBorder( omarginB, innerB ));
			btnPanel.add ( btnAddComment );
			btnPanel.add ( btnAddHistory );

		panel5.add ( btnPanel );
		panel5.add ( btnMakeFITS );
		tabbedPane.addTab ("New FITS Table", panel5);



		/**********************************************************************************/
		//Add the tabbed pane to this panel.
		setLayout(new GridLayout(1, 1)); 
		add(tabbedPane);
	}


	public static void main(String[] args) {
		JFrame frame = new JFrame("MakeFITSGUI");
		frame.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				try {
					RandomAccessFile out = new RandomAccessFile 
						( settingsFilename, new String("rw") );
					out.seek(0);             //      reset pointer to beginning of file
					out.writeBytes ( "IMG_DIR = " + fcDirIMG + "\n" );
					out.writeBytes ( "OUT_DIR = " + fcDirOut + "\n" );
					out.writeBytes ( "IN_DIR = " + fcDirIn + "\n" );
					out.setLength ( out.getFilePointer () );
					out.close();
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
				}       catch ( IOException err ) {
					System.err.println("IOException");
				}

				System.exit(0);
			}
		});

		frame.getContentPane().add(new MakeFITSGUI(), 
			BorderLayout.CENTER);
		frame.setSize(800, 600);
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


