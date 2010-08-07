

import java.io.*;
import java.util.*;
import java.lang.System;

class iniVector 
{
	private Vector vec = new Vector (0, 1);
	private Vector iniComments = new Vector (0,1);
	private String iniFilename = new String ("");

	public iniVector() {
//		readFile();
	}

	public iniVector( String filename ) {
		setFilename ( filename );
//		readFile();
	}

	public void readFile() {
		File inFile = new File ( getFilename() );

		vec.clear();
		iniComments.clear();

		if ( inFile.exists() ) {
			System.out.print ("Reading settings from " + getFilename() + "\n");
			String setting = new String ("");
			try {
				RandomAccessFile in = new RandomAccessFile 
					( getFilename(), new String("r") );
				in.seek(0);             //      reset pointer to beginning of file
				while ((setting = in.readLine()) != null ) {
					if ( setting.charAt(0) != '#' ) {       // COMMENT LINE
						int index = setting.lastIndexOf ( "=" );
						if ( index == -1 ) 
							System.err.println("Invalid line :" + setting);
						else {
							//System.out.println ( "Valid setting: " + setting );
							addKey ( setting.substring(0,index).trim(),
								setting.substring(index+1).trim() );
						}
					} else {
						iniComments.add ( setting );
						//System.out.println ("Found Comment Line: " + iniComments.lastElement().toString() );
					}
				}
				in.close();
			}	catch ( StringIndexOutOfBoundsException err ) {
				System.err.println("OutofBounds reading testfile");
			}	catch ( NullPointerException err ) {
				System.err.println("NullPointer reading testfile" + err );
			}	catch ( NumberFormatException err){
				System.err.println("NumberFormatException reading testfile");
			}	catch ( EOFException err){
				System.err.println("EOFException reading testfile");
			}	catch ( FileNotFoundException err){
				System.err.println("FileNotFoundException reading testfile");
			}	catch ( IOException err){
				System.err.println("IOException reading testfile");
			}
		} else System.err.println ("File Not Found.  " + getFilename() );
	}


	public Vector getKeylistVector () {
		Vector retvec = new Vector ( 0, 1);

		for ( int i=0; i < vec.size(); i++ ) {
			retvec.add( ((Vector)vec.get(i)).get(0).toString());
		}

		return retvec;
	}

	public int getKeyCount () {
		return ( vec.size() );
	}

	public void addKey ( String newKeyName, String newKeyValue ) {
		if ( vec.size() == 0 ) {
			vec.add ( new Vector (0,1) );
			((Vector)vec.get(0)).add ( newKeyName );
			((Vector)vec.get(0)).add ( newKeyValue );
		} else {
			if ( KeyExists ( newKeyName ) ) {
				int kindx = getKeyIndex (newKeyName);
				int vindx = ((Vector)vec.get( kindx )).indexOf ( newKeyValue );
				if ( vindx >= 0 ) {
					((Vector)vec.get( kindx )).remove(vindx);
					((Vector)vec.get( kindx )).insertElementAt ( newKeyValue, 1 );
				} else
					((Vector)vec.get( kindx )).add ( newKeyValue );
			} else {
				vec.add ( new Vector (0,1) );
				((Vector)vec.get(vec.size()-1 )).add ( newKeyName );
				((Vector)vec.get(vec.size()-1 )).add ( newKeyValue );
			}
		}
//		System.out.println ( ((Vector)vec.get(getKeyIndex(newKeyName))) );
	}

	//
	//	just like addKey, but always inserts at top
	//	
	public void setDefaultKey ( String newKeyName, String newKeyValue ) {
		if ( vec.size() == 0 ) {
			vec.add ( new Vector (0,1) );
			((Vector)vec.get(0)).add ( newKeyName );
			((Vector)vec.get(0)).add ( newKeyValue );
		} else {
			if ( KeyExists ( newKeyName ) ) {
				int kindx = getKeyIndex (newKeyName);
				int vindx = ((Vector)vec.get( kindx )).indexOf ( newKeyValue );
				if ( vindx >= 0 ) 
					((Vector)vec.get( kindx )).remove(vindx);
				((Vector)vec.get( kindx )).insertElementAt ( newKeyValue, 1 );
			} else {
				vec.add ( new Vector (0,1) );
				((Vector)vec.get(vec.size()-1 )).add ( newKeyName );
				((Vector)vec.get(vec.size()-1 )).add ( newKeyValue );
			}
		}
//		System.out.println ( ((Vector)vec.get(getKeyIndex(newKeyName))) );
	}

	public int getKeyIndex ( String keyname ) {
		for ( int i=0; i<vec.size(); i++)
			if ( ((Vector)vec.get(i)).get(0).toString()
				.equalsIgnoreCase( keyname ) )
					return i;
		return -1;
	}


	public boolean KeyExists ( String keyname ) {
		for ( int i=0; i<vec.size(); i++)
			if ( ((Vector)vec.get(i)).get(0).toString()
				.equalsIgnoreCase( keyname ) )
					return true;
		return false;
	}

	public int getValueCount ( String keyname ) {
		if ( KeyExists( keyname ) ) 
			return ((Vector)vec.get(getKeyIndex( keyname ))).size() - 1;
		else
			return 0;
	}

	public void setFilename ( String newFilename ) {
		iniFilename = new String ( newFilename );
	}
	
	public String getFilename () {
		return iniFilename;
	}


	public Vector getKeyVector ( String keyname ) {
		if ( KeyExists( keyname ) ) {
			Vector temp = ((Vector)((Vector)vec.get(getKeyIndex(keyname))).clone());
			temp.remove(0);
			return temp;
		} else {
			Vector temp = new Vector (0,1);
			temp.add ("");
			return temp;	
		}
	}










/*************************************************************

			INCOMPLETE LINE.  

*************************************************************/




	public void writeFile () {
		try {
			RandomAccessFile out = new RandomAccessFile 
				( getFilename(), new String("rw") );
			out.seek(0);             //      reset pointer to beginning of file
			for (int i=0; i<iniComments.size(); i++) {
				out.writeBytes ( iniComments.get(i).toString() + "\n" );
			}
			for ( int i=0; i < vec.size() ; i++ ) {
				for ( int j=1; j < ((Vector)vec.get(i)).size() ; j++ ) {
					out.writeBytes ( ((Vector)vec.get(i)).get(0).toString().trim() 
					+ " = " + 
					((Vector)vec.get(i)).get(j).toString().trim() + "\n" );
				}
			}
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

	}

/************************************************

	ADD A DESTRUCTOR THAT CALLS THE WRITEFILE()

************************************************/




	public static void main(String[] args) {
		iniVector testVector = new iniVector("testoutfile");
		
		System.out.println ("Main");
		System.out.println ( testVector.getKeyCount() );
		for ( int i=0; i< testVector.vec.size(); i++){
			System.out.println (  i + "--" + testVector.vec.get(i).toString() );
		}
		
		System.out.println ( testVector.getKeylistVector() );

		Vector klist = new Vector (0,1);
		klist = testVector.getKeylistVector();
		for ( int i=0; i< testVector.getKeyCount(); i++ ) {
			System.out.println ( "Values in key #"+i+"  "+testVector.getValueCount ( klist.get(i).toString() ) );
			System.out.println ( "Key Vector " + testVector.getKeyVector ( klist.get(i).toString() ) );
		}
		testVector.writeFile();
			
	}
}
