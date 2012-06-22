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
	private String testAccountLabel = "TEST_ACCOUNT"; // special label used in property file to identify test account 
	
	private String testDataPropertyFile;
	private Hashtable<String, //IPA Web Page Name, such as "HBAC Rules add page"
	  			Hashtable<String, // HTML Tag Name + element id , such as "textbox:cn", "textarea:description"
			  				ArrayList<String>> // finally, test data in ArrayList 
			 			> testData;
	private Hashtable<String,ArrayList<String>> UIOrder;
	private Hashtable<String, String> testAccounts; // IPA Web Page Name, such as "HBAC Rules add page" -> test account
	private Hashtable<String, Integer> testDataPointer;
	private Hashtable<String, Boolean> hasMoreTestData;
	public static TestDataFactory instance(String propertyFile) 
	{
		if (instance == null)
			instance = new TestDataFactory(propertyFile);
		return instance;
	}
	
	// constructor
	private TestDataFactory(String propertyFile)
	{
		this.testDataPropertyFile = propertyFile;
		testAccounts = new Hashtable<String,String>();
		testData = new Hashtable<String, Hashtable<String,ArrayList<String>>>(); 
		UIOrder = new Hashtable<String,ArrayList<String>>();
		testDataPointer = new Hashtable<String, Integer>();
		hasMoreTestData = new Hashtable<String, Boolean>();
		loadTestPropertyFile(testDataPropertyFile);
		initDataPointer();
	}
	
	public ArrayList<String> getUIELements(String page)
	{
		ArrayList<String> uiElements;
		if (UIOrder.containsKey(page))
			uiElements = UIOrder.get(page);
		else
			uiElements = null; // this indicates error
		/**
		ArrayList<String> uiElements = new ArrayList<String>();
		Hashtable<String, ArrayList<String>> pageData = testData.get(page);
		Enumeration<String> keys = pageData.keys(); 
		while (keys.hasMoreElements())
		{
			String uiElement = keys.nextElement();
			uiElements.add(uiElement);
		}
		*/
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
			testDataPointer.put(dataPointerKey, new Integer(newPointer));
		else
			hasMoreTestData.put(page, new Boolean(false));
		return value;
	}
	
	public void resetDataPointer(String page, String tag, String id)
	{ 
		String htmlDataKey = tag + ":" + id;
		String dataPointerKey = page + ":" + htmlDataKey;    
		testDataPointer.put(dataPointerKey, new Integer(0)); 
	}

	private void initDataPointer()
	{
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
	
	private void loadTestPropertyFile(String testPropertyFile)
	{ 
		System.out.print("\nstart parsing test data file:["+testPropertyFile + "] ... ");  
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
					parseLine(delimiter, reflineData, currentData, testData);
					refline = currentLine;
					reflineData = currentData; 
					acutalDataLineCounter++;
				}
			}
			printTestData(testData);
			fin.close();
			System.out.print("reading finished\n");
		} catch (FileNotFoundException e) { 
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} 
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
				if (  dataInCurrentLine[i] !=null && dataInCurrentLine[i].equals("%"))
					dataInCurrentLine[i] = refData[i];  
		
		// save these four parts into our data structure
		String IPAWebPageName = dataInCurrentLine[0];
		String HTMLTagName = dataInCurrentLine[1];
		String ElementID =  dataInCurrentLine[2];
		String TestData =  dataInCurrentLine[3];
		
		if (HTMLTagName.equals(testAccountLabel) && ! ElementID.equals(""))
		{
			testAccounts.put(IPAWebPageName, ElementID);
			return;
		}
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
			hasMoreTestData.put(IPAWebPageName, new Boolean(true));
		}
		
		// save into UIOrder hashtable
		ArrayList<String> order;
		if (UIOrder.containsKey(IPAWebPageName)) 
			order = UIOrder.get(IPAWebPageName);			
		else
			order = new ArrayList<String>();
		order.add(testDataKey);
		UIOrder.put(IPAWebPageName, order);
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
		int delimiterIndex = 0;
		int stringIndex=0;
		for (;stringIndex < lineToParse.length(); stringIndex ++)
		{
			char c = lineToParse.charAt(stringIndex);
			if (c == delimiter)
			{
				if (partIndex == (totalParts - 2) ) 
				{
					String thisPart = line.substring(delimiterIndex, stringIndex).trim();
					dataInCurrentLine[partIndex] = thisPart;
					String lastPart = line.substring(stringIndex+1,line.length()).trim();
					dataInCurrentLine[partIndex+1] = lastPart;
					break;
				}else{
					String thisPart = line.substring(delimiterIndex, stringIndex).trim();
					dataInCurrentLine[partIndex] = thisPart;
					delimiterIndex = stringIndex+1;
					partIndex ++;
				} 
			}
		}//for-loop
		if (partIndex == (totalParts - 2) && stringIndex == lineToParse.length() )
		{
			// it means we found only 2 delimiter, let's get the last part
			String lastPart = line.substring(delimiterIndex + 1, line.length());
			dataInCurrentLine[partIndex] = lastPart;
		}
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
		String page=null, id=null;
		ArrayList<String> data;
		Enumeration<String> keys = testdata.keys();
		int i=0;
		while (keys.hasMoreElements())
		{
			page = keys.nextElement();
			ArrayList<String> uiElements;
			if (UIOrder.containsKey(page))
				uiElements = UIOrder.get(page);
			else
				continue; // this indicates error, skip to next one
			
			Hashtable<String,ArrayList<String>> htmlData = testdata.get(page);
			System.out.println("["+i+"]" + page );
			
			// print test data in order
			for (int j=0; j<uiElements.size(); j++)
			{
				id = uiElements.get(j);
				data = htmlData.get(id);
				System.out.print("\t[" + j + "]{" + id + "\t==\t{");
				for (String d:data)
					System.out.print("[" + d + "]");
				System.out.print("}\n");
			}
			System.out.println("");
			i++;
		}
		System.out.println("========================================");
	}

	public String getModifyTestAccount(String pageName) {
		// sample data: Modify User, TEST_ACCOUNT, user001
		if (pageName == null)
			return null;
		String modifyTestAccount = testAccounts.get(pageName); 
		return modifyTestAccount;
	}

	public String[] extractValues(String combinedString) {
		// format: homedirectory, +[:变化(value #0 invalid per syntax: Invalid syntax.)]
		String[] extracted = new String[3]; 
		int start = -1;
		int end = -1;
		String errortype="";
		for (int i=0; i<combinedString.length(); i++)
		{
			char c = combinedString.charAt(i);
			if (c == '(')
				start = i;
			else if (c == ')')
				end = i; 
			if(end>-1 && end==i-1 && (c=='l' || c=='t')){
				errortype=combinedString.substring(i);
			}
		}
		if (start == -1 || end == -1){
			// no () part in "combinedString" found, or format not right
			extracted[0] = combinedString.trim();
			extracted[1] = null;
			extracted[2]=null;
		}else{
			String value = combinedString.substring(0,start);
			String errmsg = combinedString.substring(start+1,end);
			extracted[0] = value.trim();
			extracted[1] = errmsg.trim();
			extracted[2]=errortype;
		}
		return extracted;
	}

	public boolean hasMoreTestData(String pageName) {
		boolean thereIsMore = false;
		if (pageName == null)
			return false;
		if (hasMoreTestData.containsKey(pageName))
			thereIsMore = hasMoreTestData.get(pageName).booleanValue();
		return thereIsMore;
	} 
}
