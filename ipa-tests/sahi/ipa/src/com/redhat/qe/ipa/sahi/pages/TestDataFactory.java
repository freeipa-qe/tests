package com.redhat.qe.ipa.sahi.pages;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Hashtable;

public class TestDataFactory {
	private static TestDataFactory instance;
	private int totalParts = 4;
	private char delimiter = ','; 
	private String testDataPropertyFile;
	private Hashtable<String, Hashtable<String,ArrayList<String>>> testData;
	private Hashtable<String, Integer> testDataPointer;

	public static TestDataFactory instance(String propertyFile) 
	{
		if (instance == null)
			instance = new TestDataFactory(propertyFile);
		return instance;
	}

	public ArrayList<String> getUIELements(String page)
	{
		ArrayList<String> uiElements = new ArrayList<String>();
		Hashtable<String, ArrayList<String>> pageData = testData.get(page);
		Enumeration<String> keys = pageData.keys(); 
		while (keys.hasMoreElements())
		{
			String uiElement = keys.nextElement();
			uiElements.add(uiElement);
		}
		return uiElements;
	}
	
	public String getValue(String page, String tag, String id)
	{
		Hashtable<String, ArrayList<String>> pageData = testData.get(page);
		String htmlDataKey = tag + ":" + id;
		String dataPointerKey = page + ":" + htmlDataKey;
		ArrayList<String> htmlData = pageData.get(htmlDataKey);
		Integer pointer = testDataPointer.get(dataPointerKey);
		String value = htmlData.get(pointer.intValue()); 
		// increase data pointer, and save it back to hashtable
		// if it point to last one, then don't change
		// FIXME: I need a policy here: what should happen if data pointer points to last one? 
		//  		throw exception or cycling through beginning 
		int newPointer = pointer.intValue() + 1;
		if (newPointer < htmlData.size())
			testDataPointer.put(dataPointerKey, newPointer);
		return value;
	}
	
	public void resetPointer(String page, String tag, String id)
	{ 
		String htmlDataKey = tag + ":" + id;
		String dataPointerKey = page + ":" + htmlDataKey;    
		testDataPointer.put(dataPointerKey, new Integer(0)); 
	}
	
	private TestDataFactory(String propertyFile)
	{
		this.testDataPropertyFile = propertyFile;
		testData = loadTestPropertyFile(testDataPropertyFile);
		initDataPointer();
	}

	private void initDataPointer()
	{
		testDataPointer = new Hashtable<String, Integer>();
		String testDataKey=null, page=null,id=null;
		ArrayList<String> data;
		Enumeration<String> keys = testData.keys(); 
		while (keys.hasMoreElements())
		{
			page = keys.nextElement();
			Hashtable<String,ArrayList<String>> htmlData = testData.get(page); 
			Enumeration<String> htmlIDs = htmlData.keys(); 
			while(htmlIDs.hasMoreElements())
			{
				id = htmlIDs.nextElement();
				testDataKey = page + ":" + id;				
				data = htmlData.get(id); 
				if (testDataPointer.containsKey(testDataKey)){
					System.out.println("duplicated test data key:[" + testDataKey + "] found");
				}else{
					Integer pointer = new Integer(0);
					testDataPointer.put(testDataKey, pointer);
					System.out.println("test data key:["+ testDataKey + "] loaded, data pointer initialized");
				}
			}//while--inner
		}//while--outter
	}
	
	private Hashtable<String, Hashtable<String,ArrayList<String>>> loadTestPropertyFile(String testPropertyFile)
	{ 
		System.out.print("\nstart parsing test data file:["+testPropertyFile + "] ... "); 
		Hashtable<String, //IPA Web Page Name, such as "HBAC Rules add page"
				  Hashtable<String, // HTML Tag Name + element id , such as "textbox:cn", "textarea:description"
				  			ArrayList<String>> // finally, test data in ArrayList 
				 > testdata = new Hashtable<String, Hashtable<String,ArrayList<String>>>(); 
		try { 
			FileInputStream fin = new FileInputStream(testPropertyFile);
			DataInputStream in = new DataInputStream(fin);
			InputStreamReader ins = new InputStreamReader(in);
			BufferedReader reader = new BufferedReader(ins);
			String[] reflineData=null;
			String refline=null, line=null;
			int acutalDataLineCounter =0;
			while((line = reader.readLine())!=null)
			{ 
				String currentLine = line.trim();
				if (currentLine.length()>0 && ! currentLine.startsWith("#")) 
				{
//					System.out.println("["+acutalDataLineCounter+"] current line:" + currentLine);
//					System.out.println("\tref     line:" + refline);
					String[] currentData = breakLine(delimiter, currentLine); 
					parseLine(',', reflineData, currentData, testdata);
					refline = currentLine;
					reflineData = currentData; 
					acutalDataLineCounter++;
				}
			}
			printTestData(testdata);
			fin.close();
			System.out.print("reading finished\n");
		} catch (FileNotFoundException e) { 
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return testdata;
	}

	private void parseLine(char delimiter, 
							String[] refData, 
							String[] dataInCurrentLine,
							Hashtable<String, Hashtable<String,ArrayList<String>>> testdata)
	{ 
		if (dataInCurrentLine == null)
			return;
		if (refData != null) 
			for (int i=0;i<dataInCurrentLine.length;i++) 
				if ( dataInCurrentLine[i].equals("%"))
					dataInCurrentLine[i] = refData[i];  
		
		// save these four parts into our data structure
		String IPAWebPageName = dataInCurrentLine[0];
		String HTMLTagName = dataInCurrentLine[1];
		String ElementID =  dataInCurrentLine[2];
		String TestData =  dataInCurrentLine[3];
		
		String testDataKey = HTMLTagName + ":" + ElementID;
		ArrayList<String> testDataList = stringTOArrayList(TestData);
		// Sample line:
		//Add HBAC Rule, textbox,  cn, +[:hbac001:hbac002:hbac003:hbac004:hbac005]
		if (testdata.containsKey(IPAWebPageName))
		{
			Hashtable<String,ArrayList<String>> htmlData = testdata.get(IPAWebPageName);
			if (htmlData.containsKey(testDataKey))
			{
				ArrayList<String> existingData = htmlData.get(testDataKey);
				htmlData.put(testDataKey, testDataList); 
				System.out.println("Duplicated tagname:cn value exist");
				System.out.println("Existing data:"+existingData);
				System.out.println("Current  data:"+TestData);
				System.out.println("Result: current data will be used"); 
			}else{
				htmlData.put(testDataKey, testDataList); 
				System.out.println("New test data found : \n\tkey=["+testDataKey + "]\n\tvalue=["+TestData +"]");
			}
			testdata.put(IPAWebPageName, htmlData);
		}else{ 
			Hashtable<String,ArrayList<String>> htmlData = new Hashtable<String,ArrayList<String>> ();
			htmlData.put(testDataKey, testDataList);
			testdata.put(IPAWebPageName, htmlData);
			System.out.println("New test data found : \n\tkey=["+testDataKey + "]\n\tvalue=["+TestData +"]");
		}
	}
	
	private String[] breakLine(char delimiter, String line)
	{
		/**
		 * Data structure:
		 * Hashtable: IPA Web Page Name (String) -> Hashtable (HTML Tag Name:element id -> test values)))
		 * Example:
		 * Add HBAC Rule, textbox,  cn, +[:hbac001:hbac002:hbac003:hbac004:hbac005]
		 */ 
		if (line == null)
			return null;
		String lineToParse = line;
		String[] dataInCurrentLine = new String[totalParts];
		int partIndex = 0;
		int stringIndex = 0;
		for (int i=0; i < lineToParse.length(); i++)
		{
			char c = lineToParse.charAt(i);
			if (c == delimiter)
			{
				if (partIndex == (totalParts - 2) ) 
				{
					String thisPart = line.substring(stringIndex, i).trim();
					dataInCurrentLine[partIndex] = thisPart;
					String lastPart = line.substring(i+1,line.length()).trim();
					dataInCurrentLine[partIndex+1] = lastPart;
					break;
				}else{
					String thisPart = line.substring(stringIndex, i).trim();
					dataInCurrentLine[partIndex] = thisPart;
					stringIndex = i+1;
					partIndex ++;
				} 
			}
		}//for-loop
		return dataInCurrentLine;
	}
	
	private ArrayList<String> stringTOArrayList(String testDataInString)
	{
		ArrayList<String> testData = new ArrayList<String>();
		char c=1;
		char delimiter=0;
		int begin=0;
		for (int i=0; i<testDataInString.length();i++)
		{
			 c = testDataInString.charAt(i);
			 if (c == '[')
			 {
				 delimiter = testDataInString.charAt(i+1);
				 i++;
				 begin=i;
			 }
			 if (c == delimiter)
			 {
				 String dataStr = testDataInString.substring(begin+1,i).trim();
				 testData.add(dataStr);
				 begin = i;
			 }
			 if (c == ']')
			 {
				 String dataStr = testDataInString.substring(begin+1,i).trim();
				 testData.add(dataStr);
			 }
		}
		return testData;
	}
	
	private void printTestData(Hashtable<String, Hashtable<String,ArrayList<String>>> testdata)
	{
		System.out.println("========== test data loaded ==============");
		String page=null,id=null;
		ArrayList<String> data;
		Enumeration<String> keys = testdata.keys();
		int i=0;
		while (keys.hasMoreElements())
		{
			page = keys.nextElement();
			Hashtable<String,ArrayList<String>> htmlData = testdata.get(page);
			Enumeration<String> htmlIDs = htmlData.keys();
			System.out.println("["+i+"]" + page );
			while(htmlIDs.hasMoreElements())
			{
				id = htmlIDs.nextElement();
				data = htmlData.get(id);
				System.out.print("\t{" + id + "\t==\t{");
				for (String d:data)
					System.out.print("[" + d + "]");
				System.out.print("}\n");
			} 
			System.out.println("");
			i++;
		}
		System.out.println("========================================");
	} 
}
