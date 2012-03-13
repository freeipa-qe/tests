package com.redhat.qe.ipa.sahi.pages;

import java.util.ArrayList;
import java.util.Hashtable;

public class IPAWebTestMonitor {
	private long startTime;
	private long finishTime; 
	private long exeTime;
	private String testCaseName; 
	private String testPage;
	private String status;
	private StringBuffer currentTestData; 
	private Hashtable<String,Exception> testExceptions;
	private Hashtable<String,String> testLogMessage;
	private ArrayList<String> allTestData;
	private ArrayList<Integer> passedTestData;
	private ArrayList<Integer> failedTestData;
	private String header;
	public IPAWebTestMonitor(String testPage, String testCaseName)
	{
		this.testPage = testPage;
		this.testCaseName = testCaseName; 
		currentTestData = new StringBuffer(); 
		testExceptions = new Hashtable<String,Exception>();
		testLogMessage = new Hashtable<String,String>();
		allTestData = new ArrayList<String>();
		passedTestData = new ArrayList<Integer>();
		failedTestData = new ArrayList<Integer>();
		header = "\n";
	}
	
	public void start() {
		startTime = System.currentTimeMillis();
		status = "started";
	}
	public void finish() { 
		finishTime = System.currentTimeMillis();
		status = "finished";
		exeTime = finishTime - startTime;
	}
	
	public void pass(){ 
		 String msg = "NONE";
		 pass(msg);
	}
	
	public void pass(String msg)
	{
		if (msg == null)
			msg = "NONE";
		String key = currentTestData.toString();
		allTestData.add(key);
		passedTestData.add(new Integer(allTestData.size()-1));
		currentTestData.delete(0, currentTestData.length());
		testLogMessage.put(key, msg);
		System.out.println("\nPASS: "+ key);
	}
	
	public void fail(Exception e) {
		if (e != null){ 
			String key = currentTestData.toString();
			String msg = e.getMessage();
			testExceptions.put(key, e); 
			fail(msg); 
		}else{
			String msg = "exception is null, no error message found";
			fail(msg);
		}
	}
	
	public void fail(String msg)
	{
		if (msg == null)
			msg = "NONE";
		String key = currentTestData.toString();
		allTestData.add(key);
		failedTestData.add(new Integer(allTestData.size()-1)); 
		currentTestData.delete(0, currentTestData.length()); 
		testLogMessage.put(key, msg);
		System.out.println("\nFAIL: "+ key + " [" + msg + "]");
	}
	
	public Exception getTestException(String key) {
		if (testExceptions.containsKey(key))
			return testExceptions.get(key);
		else
			return null;
	}
	 
	public void setCurrentTestData(String data) 
	{
		currentTestData.append(data + "\n");
	}
	
	public String getCurrentTestData() { 
		return currentTestData.toString();
	}
	
	public int exeutionTimeInSecond()
	{
		long duration = finishTime - startTime;
		int d = (int)(duration/1000);
		return d;
	}
	
	public String getTestSignture(){
		String signture = testPage + ":" + testCaseName;
		return signture;
	}
	
	public int getResultStatusCode()
	{// return 0: empty test data set
	 // return 1: all passed
	 // return -1: not empty and some failed
		int code=-1;
		if (failedTestData.size() == 0 && passedTestData.size() == 0)
			code=0;
		else if (failedTestData.size() == 0 && passedTestData.size() > 0)
			code=1;
		return code;
	}
	
	public int getTotalTestCases() { return allTestData.size();}
	public String getTestStatus(){ return status;}
	public long getExecutionDuration() { return exeTime;}
	public int getPassedCount() { return passedTestData.size();}
	public int getFailedCount() { return failedTestData.size();}
	
	public String getReport() {
		StringBuffer buffer = new StringBuffer();
		if ( (passedTestData.size() + failedTestData.size() ) > 0)
			buffer.append(header + getTestSignture() + "\tPASS["+ passedTestData.size()+"] FAIL["+failedTestData.size()+"]");
		else
		{
			buffer.append(header + "No test data defined: " + getTestSignture());
			return buffer.toString();
		}
		if (passedTestData.size()>0){
			//buffer.append(header+"\t--- Passed Data Set ["+ passedTestData.size() +"] ---"); 
			for(int i=0; i< passedTestData.size(); i++){
				String testdata = allTestData.get(passedTestData.get(i).intValue());
				String logmsg = testLogMessage.get(testdata);
				buffer.append(header + "~~~~~~ dataset ["+ passedTestData.get(i).intValue() + "] ~~~~~~~\n");
				buffer.append(testdata);
				buffer.append("~~~~~~~~~ Test Result: PASS ~~~~~~~~~~~~~~~~~~~~~\n");
				if (logmsg != null & !logmsg.equals("NONE"))
					buffer.append(header+"log message: ["+logmsg+"]");
			}
		}
		
		if (failedTestData.size()>0)
		{
			//buffer.append(header+"\t--- Failed Data Set ["+ failedTestData.size() +"] ---"); 
			for (int i=0; i< failedTestData.size(); i++ )
			{ 
				String testdata = allTestData.get(failedTestData.get(i).intValue());
				String logmsg = testLogMessage.get(testdata); 
				buffer.append(header + "~~~~~~ dataset ["+ failedTestData.get(i).intValue() + "] ~~~~~~~\n");
				buffer.append(testdata);
				buffer.append("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
				if (testExceptions.containsKey(testdata) && testExceptions.get(testdata)!= null){
					Exception e = testExceptions.get(testdata);
					String errorMsg = e.getMessage();
					buffer.append(header+ "Exception message:" + errorMsg );
				}
				buffer.append("~~~~~~~~~~~ Test Result: FAIL ~~~~~~~~~~~~~~~~~~~\n");
				if (logmsg != null & !logmsg.equals("NONE"))
					buffer.append(header+"log message: ["+logmsg+"]");
			}
		}
		return buffer.toString();
	}
}
