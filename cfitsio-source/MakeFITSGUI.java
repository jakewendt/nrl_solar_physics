/*								*/
/*								*/
/*	MakeFITSGUI.java							*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*	030202 - removed old non-table stuff			*/
/*		 modifying code to allow for RAL dat files	*/
/*		 RAL dat files can have multiple images		*/
/*											*/
/*	030205 - added FITSTable.clear stuff			*/
/*		 added ability to have # comments in .ini	*/
/*											*/
/*	030212 - add iniVector stuff to all for			*/
/*		saving and customizing header info			*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/
/*											*/


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
	/*		MakeFITSGUI Constants			*/
	final private String PCCopyDir = new String ("Y:\\secchi\\");
	final private String UnixCopyDir = new String ("/net/cedar/pub/secchi/");
	public final String  MakeFITSGUIVersion = new String ( "20030220" );

	/********************************************************/
	/*		JNI Native Functions			*/
	private native String getIMGSize ( String imgPathName );
	private native int addKey ( String fitsOutFileName, String keyword, String keyValue );
	private native int showKey ( String fitsOutFileName, String keyword );
	private native int fitsCopy ( String imgPathName, String fitsOutFileName, int xsize, int ysize );
	private native int fitsCopyOffset ( String imgPathName, String fitsOutFileName, int xsize, int ysize, int offset );
	private native int readFooter ( String imgPathName, String fitsOutFileName, int xsize, 
		int ysize, int bytecount, int offset );
	private native int getKeywordCount ( String fitsInFileName );
	private native String readFITSKeyNum ( String fitsInFileName, int KeywordNumber );


	/********************************************************/
	/*		MakeFITSGUI Variables			*/
	private long longdate;						//	used to store the date when read in long format
	private String strDateObsKy = new String("");	//	the DATE-OBS in keyword format
	private String strDateObsFn = new String("");	//	the DATE-OBS in filename format
	private String strDateNow = new String("");		//	the current DATE in keyword format
	private String imgFilename = new String("");		//	IMG filename only
	private String imgPathName = new String("");		//	IMG filename with path
	private String fitsOutFileName = new String("");	//	FITS filename only (for keyword) (generated)
	private String tmpFITSName = new String("");		//	TEMPORARY FITS Filename in mainpanel
	private String fitsOutPathName = new String ("");	//	FITS filename with path (generated)
	private String sourceFileName = new String("");	//	
	private String sourcePath = new String ("");	
	private String sourceCoreName = new String("");	//	
	private String sourceExtension = new String("");	//	extension of IMG or DAT file
	private String secchiExtension = new String("");	//	Used for the filename coding
	private String outputDir = new String ("");		//	directory selected as output target
	private String copyDir = new String ("");		//	directory FITS file is copied to after generation
	private String keyObsrvtry = new String ("");	//	OBSRVTRY keyword value
	private String codeObsrvtry = new String ("");	//	OBSRVTRY code
	private String keyDetector = new String ("");	//	DETECTOR keyword value
	private String codeDetector = new String ("");	//	DETECTOR code

	private int imgOffset;						// 	raw image offset
	private int index;
	private int intKeywordCount;
	private int tempint;
	private int xsize = 0;
	private int ysize = 0;
	private int naxis1 = 0;						//	possible that not need both size and axis
	private int naxis2 = 0;
	private String imgsizes = new String("");
	private String keyword = new String("");
	private String keyvalue = new String("");
	private String comment = new String("");

	private File imgFile;
	private File fitsInFile;
	private File fitsOutFile;
	private File iniFile;
	private File outputDirFile;
		
	private FITSTable FITSPanel = new FITSTable();
	private iniVector iniheader = new iniVector ("header.ini");

	/********************************************************/
	/*	PROGRAM SETTINGS INFORMATION			*/
	static private File settingsFile;			//	file for storing program settings
	final static private String settingsFilename = 
		new String ( System.getProperty ("user.home") + 
			System.getProperty ("file.separator") +
			"makefits.ini" );			//	filename for storing program settings
	static private String strDirIn = new String ("");	//	initial FITS IN directory for filechooser
	static private String strDirOut = new String ("");	//	initial FITS OUT directory for filechooser
	/********************************************************/

	private static Vector iniComments = new Vector (0, 1);


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
					if ( setting.charAt(0) != '#' ) {	// COMMENT LINE
						index = setting.lastIndexOf ( "=" );
						if ( index == -1 ) 
							System.err.println("Invalid line :" + setting);
						else {
							//System.out.println ( "Valid setting: " + setting );
							varName = setting.substring(0,index).trim();
							if ( varName.equalsIgnoreCase("IN_DIR") ) 
								strDirIn = new String ( setting.substring(index+1).trim() );
							else if ( varName.equalsIgnoreCase("OUT_DIR") ) {
								strDirOut = new String ( setting.substring(index+1).trim() );
								outputDir = strDirOut;	// DO I REALLY NEED BOTH OF THESE?  SAME DATA.
							} else System.err.println ("No valid setting");
						}
					} else {
						iniComments.add ( setting );
						//System.out.println ("Found Comment Line");
						//System.out.println ( iniComments.lastElement().toString() );
					}
				}
				in.close();
			}       catch ( StringIndexOutOfBoundsException err ) {
				System.err.println("OutofBounds reading makefits.ini");
			}       catch ( NullPointerException err ) {
				System.err.println("NullPointer reading makefits.ini" + err );
			}       catch ( NumberFormatException err){
				System.err.println("NumberFormatException reading makefits.ini");
			}       catch ( EOFException err){
				System.err.println("EOFException reading makefits.ini");
			}       catch ( FileNotFoundException err){
				System.err.println("FileNotFoundException reading makefits.ini");
			}       catch ( IOException err){
				System.err.println("IOException reading makefits.ini");
			}
		} else System.err.println ("No makefits.ini file found.  Using default settings.");

		/**********************************************************************************/



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
		JPanel mainpanel = new JPanel();
		mainpanel.setLayout(new BoxLayout(mainpanel, BoxLayout.Y_AXIS));
		mainpanel.setBorder(BorderFactory.createEmptyBorder(20,20,20,20));

		JButton btnInputFile = new JButton ("Select Input File");
		final JLabel lblInputFile = new JLabel ("NONE SELECTED", JLabel.CENTER);
		lblInputFile.setToolTipText ("Name of currently selected Input File.");
		btnInputFile.setToolTipText ("Click this button to select a raw data file (IMG, DAT)");
		btnInputFile.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				fc.setCurrentDirectory ( new File ( strDirIn ) );
				fc.setFileFilter(imgFilter);
				fc.setFileSelectionMode( JFileChooser.FILES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					int index;

					imgFile = fc.getSelectedFile();
					imgFilename = imgFile.getName();
					imgPathName = imgFile.getAbsolutePath();
					lblInputFile.setText( imgPathName );

					sourcePath = imgPathName.substring
						( 0, imgPathName.length() - imgFilename.length() );
					//System.out.println ("Path " + sourcePath );
					sourceCoreName = imgFilename.substring
						( 0, imgFilename.length()-4);
					//System.out.println ("Core " + sourceCoreName ); 
					sourceExtension = imgFilename.substring
						( imgFilename.length()-3, imgFilename.length() );
					//System.out.println ("Ext  " + sourceExtension );
					
					/*************************************************/
					//	SAVE DIRECTORY CHOICE
					strDirIn = new String ( imgFile.getParent() 
						+ System.getProperty ("file.separator") );
					/*************************************************/
					
					/*************************************************/
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
						System.err.println("Unable to determine Image Dimensions.");
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






					/************************************************************/
					//	CONVERT IMG INTO TEMPORARY FITS FILE FOR READING
					//
					System.out.println ("Creating temporary FITS file for reading.");
					if ( sourceExtension.trim().equalsIgnoreCase("img") )
						imgOffset = 4;
					else if ( sourceExtension.trim().equalsIgnoreCase("dat") )
					{	imgOffset = 0;  // THIS VALUE WILL CHANGE IF MULTIPLE IMAGES
						xsize = 2150;
						ysize = 2150;
					}
				
					fitsCopyOffset ( imgPathName, tmpFITSName, xsize, ysize, imgOffset );

					if ( sourceExtension.trim().equalsIgnoreCase("img") )
						readFooter ( imgPathName, tmpFITSName, xsize, ysize, 2, 4 );

					/************************************************************/
					//	READ THE ENTIRE HEADER AND DISPLAY IN TABLE AS UNEDITABLE
					//
			
					String s;
					int i, index2;
					FITSPanel.clearTable();	//	Make sure table is empty

					intKeywordCount = getKeywordCount ( tmpFITSName );
					System.out.println ("Found " + intKeywordCount + " keywords in temp FITS file.");
					System.out.println ("Reading temporary FITS file header.");
					for ( i=0; i<=intKeywordCount; i++ ){
						s = readFITSKeyNum( tmpFITSName, i );

						index = s.indexOf ( "/" );
	                                	if (index < 1 )
							System.err.println("No keyword/value found in line:" + s);
						else {
							keyword = s.substring(0,index).trim();
							index2 = s.indexOf ("/", index+1);
							keyvalue = s.substring (index+1, index2).trim();
							comment = s.substring ( index2+1).trim();
							
							if ( keyword.equalsIgnoreCase("COMMENT") || 
								keyword.equalsIgnoreCase("HISTORY"))
							{
								FITSPanel.addRow ( keyword, new String[] { keyvalue + comment }, "false" );
								//FITSPanel.addRow ( keyword, new String[] { comment }, "false" );
								//System.out.println ( keyword + "     " +  comment );
							}
							else
							{
								FITSPanel.addRow ( keyword, new String[] 
									{ keyvalue + "     /     " + comment }, "false" );
								/************************************************************/
								//	grab any values that may be needed ( ie. NAXIS1 and NAXIS2 )
								//
								if ( keyword.equalsIgnoreCase ("NAXIS1") )
									naxis1 = Integer.parseInt ( keyvalue );
								else if ( keyword.equalsIgnoreCase ("NAXIS2") )
									naxis2 = Integer.parseInt ( keyvalue );

								//System.out.println ( keyword + "     " + keyvalue + "     " + comment );
							}
						}
					}


					/************************************************************/
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
					/************************************************************/






					/************************************************************/
					//	THEN ADD FIXED KEYWORDS (NOT READ FROM TABLE)
					//
					FITSPanel.addRow ( "DATE", new String[] {"COMPUTED_AT_GO_TIME"}, "false");
					FITSPanel.addRow ( "FILENAME", new String[] {"COMPUTED_AT_GO_TIME"}, "false");


					iniheader.readFile();
					/************************************************************/
					//	THEN ADD REST OF HEADER TO TABLE
					//
					FITSPanel.addRow ( "FILEORIG", new String[] { imgFilename }, "false");
					FITSPanel.addRow ( "DATE_OBS", new String[] { strDateObsKy }, "false");
					FITSPanel.addRow ( "EXPTIME", new String[] {""}, "true" );



					FITSPanel.addRow ( "OBSRVTRY", iniheader.getKeyVector("OBSRVTRY"), "false" );
					FITSPanel.addRow ( "DETECTOR", iniheader.getKeyVector("DETECTOR"), "false" );
					FITSPanel.addRow ( "SUMMED", iniheader.getKeyVector("SUMMED"), "false" );
					FITSPanel.addRow ( "SUMTYPE", iniheader.getKeyVector("SUMTYPE") );



					FITSPanel.addRow ( "P1COL", new String[] {"1"}, "true");
					FITSPanel.addRow ( "P2COL", new String[] { Integer.toString ( naxis1 ) }, "false");
					FITSPanel.addRow ( "P1ROW", new String[] {"1"}, "true" );
					FITSPanel.addRow ( "P2ROW", new String[] { Integer.toString ( naxis2 ) }, "false" );



					FITSPanel.addRow ( "INSTRUME", iniheader.getKeyVector("INSTRUME"), "false" );
					FITSPanel.addRow ( "VERSION", new String[] { MakeFITSGUIVersion }, "false");
					FITSPanel.addRow ( "ORIGIN", iniheader.getKeyVector("ORIGIN") );
					FITSPanel.addRow ( "BUNIT", iniheader.getKeyVector("BUNIT"));
					FITSPanel.addRow ( "BLANK", iniheader.getKeyVector("BLANK") );
					FITSPanel.addRow ( "COMMENT", new String[] 
						{"FITS coordinates for center of 1024x1024 image are [512.5, 512.5]"}, "false");
					FITSPanel.addRow ( "COMMENT", new String[] 
						{"DATE-OBS is equal to .img file last-modified date"}, "false");
					FITSPanel.addRow ( "OBSERVER", iniheader.getKeyVector("OBSERVER") );
					FITSPanel.addRow ( "OBJECT", iniheader.getKeyVector("OBJECT") );
					FITSPanel.addRow ( "OBS_PROG", iniheader.getKeyVector("OBS_PROG"));
					FITSPanel.addRow ( "CCD_ID", iniheader.getKeyVector("CCD_ID"));

					//	Always make sure that CAMERA comes after DETECTOR
					FITSPanel.addRow ( "CAMERA", iniheader.getKeyVector("CAMERA"), "false" );
					FITSPanel.addRow ( "DIODSTEP", iniheader.getKeyVector("DIODSTEP"));
					FITSPanel.addRow ( "DIODWVLN", iniheader.getKeyVector("DIODWVLN"));
					FITSPanel.addRow ( "DIODFILE", iniheader.getKeyVector("DIODFILE"));
					FITSPanel.addRow ( "CS", iniheader.getKeyVector("CS"));
					FITSPanel.addRow ( "SR", iniheader.getKeyVector("SR"));
					FITSPanel.addRow ( "FILTER", iniheader.getKeyVector("FILTER"), "false" );
					FITSPanel.addRow ( "DIODCOAT", iniheader.getKeyVector("DIODCOAT"), "false" );
					FITSPanel.addRow ( "DIODDESC", iniheader.getKeyVector("DIODDESC"), "false" );
					FITSPanel.addRow ( "CONTAMIN", iniheader.getKeyVector("CONTAMIN"), "false" );
					FITSPanel.addRow ( "DCS", iniheader.getKeyVector("DCS") );
					FITSPanel.addRow ( "VOLTAGE",iniheader.getKeyVector("VOLTAGE") );
					FITSPanel.addRow ( "CCD_COAT", iniheader.getKeyVector("CCD_COAT"), "false" );
					FITSPanel.addRow ( "VIDGAIN", iniheader.getKeyVector("VIDGAIN") );
					FITSPanel.addRow ( "DITHER", iniheader.getKeyVector("DITHER"), "false" );
					FITSPanel.addRow ( "READPORT", iniheader.getKeyVector("READPORT"), "false" );
					FITSPanel.addRow ( "MODE", iniheader.getKeyVector("MODE"), "false" );
					FITSPanel.addRow ( "CCD_WFH", iniheader.getKeyVector("CCD_WFH") );
					FITSPanel.addRow ( "CCD_WFV", iniheader.getKeyVector("CCD_WFV") );
					FITSPanel.addRow ( "TEMP_CCD", iniheader.getKeyVector("TEMP_CCD") );
					/************************************************************/




				}
			}	
		});


		JButton btnOutputDir = new JButton ( "Select Output Dir");
		final JLabel lblOutputDir = new JLabel ( strDirOut, JLabel.CENTER );
		lblOutputDir.setToolTipText ("Name of currently selected Output Dir.");
		btnOutputDir.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				System.out.println ("Select OutputDir Button Test");

				fc.setCurrentDirectory ( new File ( strDirOut ) );
				fc.setFileSelectionMode ( JFileChooser.DIRECTORIES_ONLY );
				int returnVal = fc.showOpenDialog(MakeFITSGUI.this);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					outputDirFile = fc.getSelectedFile();
					outputDir = new String ( outputDirFile.getAbsolutePath() + outputDirFile.separator );
					lblOutputDir.setText( outputDir );

					/*************************************************/
					//      SAVE DIRECTORY CHOICE
					strDirOut = new String ( outputDirFile.getPath() + System.getProperty ("file.separator") );
					//System.out.println (strDirOut);
					/*************************************************/
				} else {
					//      System.out.println("Open command cancelled by user." );
				}




			}
		});
		btnOutputDir.setToolTipText("Click this button to select the Output Directory for your FITS files.");

		JButton btnAddComment = new JButton ("Add Comment");
		btnAddComment.addActionListener( new ActionListener()
		{	public void actionPerformed(ActionEvent e)
			{
				FITSPanel.addRow ( "COMMENT", new String[] {""} );
			}
		});
		btnAddComment.setToolTipText ("Click this button to add a blank Comment line to the table");
		


		JButton btnAddHistory = new JButton ("Add History");
		btnAddHistory.addActionListener( new ActionListener()
		{	public void actionPerformed(ActionEvent e)
			{
				FITSPanel.addRow ( "HISTORY", new String[] {""} );
			}
		});
		btnAddHistory.setToolTipText ("Click this button to add a blank History line to the table");




		/**********************************************************************************/
		//	Create the GO! button that actually does the work.
		/**********************************************************************************/
		JButton btnMakeFITS = new JButton("GO!" );
		btnMakeFITS.setToolTipText ("<html><center>Click this button to create a "+
								"<br>FITS file from the selected "+
								"<br>data file and with a header "+
								"<br>like the table above.");
		btnMakeFITS.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if ( imgsizes.trim().equalsIgnoreCase("") )
					System.err.println ("Was unable to determine Image Dimensions earlier");
				else if ( imgPathName.trim().equalsIgnoreCase("") )
					System.err.println ("No IMG In File Selected.");
				else 
				{	int totalimgs=0;
					int currentimg=0;
					int i;
					Vector offsets = new Vector( 0, 1);	// added for multi image RAL dat files
					offsets.clear();

					if ( sourceExtension.trim().equalsIgnoreCase("dat") )
					{
						String setting = new String ();
						try {
							RandomAccessFile in = new RandomAccessFile 
								( sourcePath + sourceCoreName + ".txt" , new String("r") );
							in.seek(0);             //      reset pointer to beginning of file
							while ((setting = in.readLine()) != null ) 
							{
								totalimgs++;
								offsets.add ( new Integer (setting.substring(0, 11 )) );
								//	System.out.println (setting);
							}
							in.close();
						}       catch ( StringIndexOutOfBoundsException err ) {
							System.err.println("OutofBounds reading text file");
						}       catch ( NullPointerException err ) {
							System.err.println("NullPointer reading text file" + err );
						}       catch ( NumberFormatException err){
							System.err.println("NumberFormatException reading text file");
						}       catch ( EOFException err){
							System.err.println("EOFException reading text file");
						}       catch ( FileNotFoundException err){
							System.err.println("FileNotFoundException reading text file");
						}       catch ( IOException err){
							System.err.println("IOException reading text file");
						}
						System.out.println ("FILE contains " + totalimgs + " images.");

					}
					else
					{
						totalimgs = 1;
						offsets.add ( new Integer(4) );
					}
					//	for (i=0; i<totalimgs; i++)
					//	{
					//		System.out.println ("Offset " + i + " - " + offsets.get(i) +" -- " +
					//			 Integer.parseInt( offsets.get(i).toString() ));
					//	}


					for ( currentimg=0; currentimg<totalimgs; currentimg++ )
					{

						//	Only really need to do this once for multi image files
						//	Perhaps add an if currentimg=0 then statement

						if ( currentimg == 0 ) {

							for (i=intKeywordCount+2; i<FITSPanel.getRowCount(); i++) 
							{
								if ( FITSPanel.getValueAt( i, 0 ).toString().trim().equalsIgnoreCase("DETECTOR") )
								{
									if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("EUVI") )
										codeDetector = new String ("eu");	
									else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("COR1") )
										codeDetector = new String ("c1");	
									else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("COR2") )
										codeDetector = new String ("c2");	
									else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("HI1") )
										codeDetector = new String ("h1");	
									else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("HI2") )
										codeDetector = new String ("h2");	
									else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("GT") )
										codeDetector = new String ("gt");	
									else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("Development") )
										codeDetector = new String ("dv");
									else codeDetector = new String ("xx");
								}
								else if ( FITSPanel.getValueAt( i, 0 ).toString().trim()
										.equalsIgnoreCase("OBSRVTRY") )
								{
									if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("Other_C") )
										codeObsrvtry = new String ("c");
									else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("STEREO_A") )
										codeObsrvtry = new String ("a");
									else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("STEREO_B") )
										codeObsrvtry = new String ("b");
									else codeObsrvtry = new String ("x");
	
								}


								//	Assuming that DETECTOR comes CAMERA


								else if ( FITSPanel.getValueAt( i, 0 ).toString().trim()
										.equalsIgnoreCase("CAMERA") && codeDetector.equalsIgnoreCase("dv") )
								{
									if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("Talktronics") )
										codeDetector = new String ("tk");
									else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("RAL_DM") )
										codeDetector = new String ("ra");
									else if ( FITSPanel.getValueAt ( i, 1 ).toString().trim()
										.equalsIgnoreCase("RAL_Prototype") )
										codeDetector = new String ("rp");
								}
							}
	
							if ( sourceExtension.trim().equalsIgnoreCase("dat") )
							{	xsize = 2150;
								ysize = 2150;
							}
				
						}	// END SPECIAL INST FOR  ( currentimg == 0 )


						/************************************************************/
						//
						//	L = a digit representing processing level, or 
						//	'r' for quick-look or 'p' for pre-flight  
						//
						//if ( sourceExtension.trim().equalsIgnoreCase("img") )
						if ( totalimgs > 1 )
							secchiExtension = new String ( "_p" + codeDetector + codeObsrvtry + 
								"-" + Integer.toString(currentimg)  + ".fts" );
						else
							secchiExtension = new String ( "_p" + codeDetector + codeObsrvtry + ".fts" );

						fitsOutFileName = strDateObsFn + secchiExtension;
						fitsOutPathName = outputDir + strDateObsFn + secchiExtension;

						imgOffset = Integer.parseInt (offsets.get(currentimg).toString());

						fitsCopyOffset ( imgPathName, fitsOutPathName, xsize, ysize, imgOffset );
						if ( sourceExtension.trim().equalsIgnoreCase("img") )
							readFooter ( imgPathName, fitsOutPathName, xsize, ysize, 2, 4 );
						addKey ( fitsOutPathName, "HISTORY", 
							"Converted from IMG to FITS using Jake's Java/JNI/C MakeFITSGUI.");
	
						addKey ( fitsOutPathName, "FILENAME", fitsOutFileName );
	
//
//	MAY HAVE TO ADD AN A OR B INSIDE THIS FILENAME
//

	
						Date now = new Date();		//	the Date object has been deprecated,
												//	but hasn't been replaced with equiv.
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
						addKey ( fitsOutPathName, "DATE", strDateNow );
	
						/************************************************************/
						//
						//	Add most of table to FITS header
						//
						for (i=intKeywordCount+2; i<FITSPanel.getRowCount(); i++) 
						{
							//System.out.println ( "Adding keyword --- " + FITSPanel.getValueAt(i,0).toString() );
							if ( !FITSPanel.getValueAt( i, 1 ).toString().trim().equalsIgnoreCase("") )
								addKey ( fitsOutPathName, 
									FITSPanel.getValueAt( i, 0 ).toString(),
									FITSPanel.getValueAt( i, 1 ).toString() );
						}
	
						System.out.println("Finished making FITS File:" + fitsOutPathName );
	
	
						/****************************************************************/
						//	Copy fits file to Archive Dir
						//
						if ( System.getProperty("file.separator").trim().equalsIgnoreCase("/") ) 
							copyDir = UnixCopyDir;
						else 
							copyDir = PCCopyDir;
						System.out.println("Preparing to copy file to " + copyDir + " for archiving.");
							
						fitsCopy ( fitsOutPathName, new String (copyDir + fitsOutFileName), 0, 0 );
						System.out.println("Copied file to " + copyDir );
						//System.out.println("STILL TESTING. FILE NOT COPIED......" );




					}	// END FOR LOOP THROUGH MULTIPLE IMAGES IN FILE

					System.out.println ("Done.");

					/****************************************************************/
					//
					//		Add Last Used Keywords to header.ini
					//
					for (i=intKeywordCount+4; i<FITSPanel.getRowCount(); i++) 
					{
						//System.out.println ( "Adding keyword --- " + FITSPanel.getValueAt(i,0).toString() );
						//if ( !FITSPanel.getValueAt( i, 0 ).toString().equalsIgnoreCase("FILENAME") )
						//if ( !FITSPanel.getValueAt( i, 0 ).toString().equalsIgnoreCase("DATE") )
						//if ( !FITSPanel.getValueAt( i, 0 ).toString().equalsIgnoreCase("FILEORIG") )
						//if ( !FITSPanel.getValueAt( i, 0 ).toString().equalsIgnoreCase("DATE_OBS") )
						if ( !FITSPanel.getValueAt( i, 0 ).toString().equalsIgnoreCase("COMMENT") )
						if ( !FITSPanel.getValueAt( i, 0 ).toString().equalsIgnoreCase("HISTORY") )
						if ( !FITSPanel.getValueAt( i, 0 ).toString().equalsIgnoreCase("VERSION") )
							iniheader.setDefaultKey ( FITSPanel.getValueAt( i, 0 ).toString(),
								FITSPanel.getValueAt( i, 1 ).toString() );
					}
					iniheader.writeFile();
	
				}	//	END ELSE BLOCK
			}	//	END ACTIONPERFORMED BLOCK
		});
		btnMakeFITS.setAlignmentX(Component.CENTER_ALIGNMENT);

		JPanel btnPanel1 = new JPanel();
			btnPanel1.setLayout(new GridLayout(0, 2));
			//Border titleB = BorderFactory.createTitledBorder ("Buttons");
			//Border imarginB = new EmptyBorder(20,20,20,20);
			//Border omarginB = new EmptyBorder(0,20,0,20);
			//Border innerB = new CompoundBorder ( titleB, imarginB );
			//btnPanel1.setBorder ( new CompoundBorder( omarginB, innerB ));
			btnPanel1.add ( btnInputFile );
			btnPanel1.add ( btnOutputDir );
			btnPanel1.add ( lblInputFile );
			btnPanel1.add ( lblOutputDir );

		mainpanel.add ( btnPanel1 );
		mainpanel.add ( FITSPanel );

		JPanel btnPanel2 = new JPanel();
			btnPanel2.setLayout(new GridLayout(0, 4));
			//Border titleB = BorderFactory.createTitledBorder ("Buttons");
			//Border imarginB = new EmptyBorder(20,20,20,20);
			//Border omarginB = new EmptyBorder(0,20,0,20);
			//Border innerB = new CompoundBorder ( titleB, imarginB );
			//btnPanel2.setBorder ( new CompoundBorder( omarginB, innerB ));
			btnPanel2.add ( Box.createRigidArea(new Dimension(5,0)));
			btnPanel2.add ( btnAddComment );
			btnPanel2.add ( btnAddHistory );

		mainpanel.add ( btnPanel2 );

		JPanel btnPanel3 = new JPanel();
			btnPanel3.setLayout(new GridLayout(0, 3));
			//Border titleB = BorderFactory.createTitledBorder ("Buttons");
			//Border imarginB = new EmptyBorder(20,20,20,20);
			//Border omarginB = new EmptyBorder(0,20,0,20);
			//Border innerB = new CompoundBorder ( titleB, imarginB );
			//btnPanel3.setBorder ( new CompoundBorder( omarginB, innerB ));
			btnPanel3.add ( Box.createRigidArea(new Dimension(5,0)));
			btnPanel3.add ( btnMakeFITS );

		mainpanel.add ( btnPanel3 );


		/**********************************************************************************/
		//	Add the pane to this panel.
		setLayout(new GridLayout(1, 1)); 
		add(mainpanel);
		/**********************************************************************************/
	}


	public static void main(String[] args) {
		JFrame frame = new JFrame("MakeFITSGUI");
		frame.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				int i;
				try {
					RandomAccessFile out = new RandomAccessFile 
						( settingsFilename, new String("rw") );
					out.seek(0);             //      reset pointer to beginning of file
					for (i=0; i<iniComments.capacity(); i++) {
						out.writeBytes ( iniComments.get(i).toString() + "\n" );
					}
					out.writeBytes ( "IN_DIR = " + strDirIn + "\n" );
					out.writeBytes ( "OUT_DIR = " + strDirOut + "\n" );
					out.setLength ( out.getFilePointer () );
					out.close();
				}       catch ( StringIndexOutOfBoundsException err ) {
					System.err.println("OutofBounds writing makefits.ini");
				}       catch ( NullPointerException err ) {
					System.err.println("NullPointer writing makefits.ini" + err );
				}       catch ( NumberFormatException err){
					System.err.println("NumberFormatException writing makefits.ini");
				}       catch ( EOFException err){
					System.err.println("EOFException writing makefits.ini");
				}       catch ( FileNotFoundException err){
					System.err.println("FileNotFoundException writing makefits.ini");
				}       catch ( IOException err ) {
					System.err.println("IOException writing makefits.ini");
				}

				System.exit(0);
			}
		});

		System.out.println ("");
		System.out.println ("QUICK TIPS...");
		System.out.println ("\tTo enter values, double-click on a field and either choose from the list or type in a value.");
		System.out.println ("\tYou MUST hit Return after entering a value.");
		System.out.println ("\tOnly HISTORY and COMMENT fields may have spaces.");
		System.out.println ("\tSpaces in other keywords will generate an inline comment.");
		System.out.println ("\tAn upslash will also generate an inline comment.");
		System.out.println ("");


		frame.getContentPane().add(new MakeFITSGUI(), 
			BorderLayout.CENTER);
		frame.setSize(640, 480);
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


