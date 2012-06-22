package com.redhat.qe.ipa.sahi.pages;

import java.util.ArrayList;
import java.util.Hashtable;

import com.redhat.qe.auto.testng.Assert;

public class IPAWebTestMonitor {
	private long startTime;
	private long finishTime; 
	private long exeTime;
	private String methodName; 
	private String className;
	private String status;
	private StringBuffer currentTestData; 
	private String currentTestPageName;
	private Hashtable<String,Exception> testExceptions;
	private Hashtable<String,String> testLogMessage;
	private ArrayList<String> allTestData;
	private ArrayList<Integer> passedTestData;
	private ArrayList<Integer> failedTestData;
	private String header = "\n";
	private String dataSeparator = " & ";
	
	// big change here: use hash of hash of hash of hash to report
	// class name -> method name -> data set -> pass/fail
	// final report will be a tree like structure
	private Hashtable<String,Hashtable<String,String>> testResults;
	
	public IPAWebTestMonitor(String testClass, String testMethod)
	{
		className = testClass;
		methodName = testMethod; 
		currentTestData = new StringBuffer(); 
		testExceptions = new Hashtable<String,Exception>();
		testLogMessage = new Hashtable<String,String>();
		allTestData = new ArrayList<String>();
		passedTestData = new ArrayList<Integer>();
		failedTestData = new ArrayList<Integer>(); 
		testResults = new Hashtable<String,Hashtable<String,String>>();
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
		 String msg = "No message logged, test pass";
		 pass(msg);
	}
	
	public void pass(String msg)
	{
		if (msg == null)
			msg = "No message logged, test pass";
		String key = currentTestData.toString();
		allTestData.add(key);
		passedTestData.add(new Integer(allTestData.size()-1));
		currentTestData.delete(0, currentTestData.length());
		testLogMessage.put(key, msg);
		saveTestResult(key,msg,"pass");
		System.out.println("[PASS] (" + className + "-" + methodName + ") Test Data:["+ key + "] LOG :[" + msg + "]");
		Assert.assertTrue(!msg.equals(null), ""+ className + "-" + methodName + ") Test Data:["+ key + "] LOG :[" + msg + "]" );
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
			msg = "No message defined, test failed";
		String key = currentTestData.toString();
		allTestData.add(key);
		failedTestData.add(new Integer(allTestData.size()-1)); 
		currentTestData.delete(0, currentTestData.length()); 
		testLogMessage.put(key, msg);
		saveTestResult(key,msg,"fail");
		System.out.println("[FAIL] (" + className + "-" + methodName + ") Test Data:["+ key + "] error message:[" + msg + "]");
	}
	
	private void saveTestResult(String key, String logmessage, String result)
	{
		Hashtable<String,String> dataSetResult = new Hashtable<String,String>();
		dataSetResult.put("logmessage", logmessage);
		dataSetResult.put("result", result);
		testResults.put(key, dataSetResult);
	}
	
	public Exception getTestException(String key) {
		if (key !=null && testExceptions.containsKey(key))
			return testExceptions.get(key);
		else
			return null;
	}

	public void setCurrentTestData(String pageName, String value)
	{
		if (currentTestPageName == null){
			currentTestPageName = pageName;
			currentTestData.delete(0,currentTestData.length());
			currentTestData.append(pageName + ": " + value);
		}else{
			if (currentTestPageName.equals(pageName)){
				if (currentTestData.length() == 0)// if currentTestData has been cleared, this happens when a pass/fail being reported
					currentTestData.append(pageName + ": " + value);
				else
					currentTestData.append("&" + value);
			}else{
				// If currentTestPageName is different from pageName, then some error here, I can not think of any
				// scenario fall in this category. leave it blank for now
			}
		}
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
		String signture = className + ":" + methodName;
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
				buffer.append(header + "~~~~~~~~~ Passed dataset ["+ passedTestData.get(i).intValue() + "] ~~~~~~~\n");
				buffer.append(testdata);
				buffer.append(header + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
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
				buffer.append(header + "~~~~~~~~~ Failed dataset ["+ failedTestData.get(i).intValue() + "] ~~~~~~~\n");
				buffer.append(testdata);
				//buffer.append(header + "    ~~~~~~~~~~~~~~~~~~~~~~~~~~ \n");
				if (testExceptions.containsKey(testdata) && testExceptions.get(testdata)!= null){
					Exception e = testExceptions.get(testdata);
					String errorMsg = e.getMessage();
					buffer.append(header+ "Error message:" + errorMsg );
				}
				buffer.append(header + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
				if (logmsg != null & !logmsg.equals("NONE"))
					buffer.append(header+"log message: ["+logmsg+"]");
			}
		}
		return buffer.toString();
	}
	
	public Hashtable<String,Hashtable<String,String>> getTestResults() { return testResults; }
	public String getTestClassName () { return className; }
	public String getTestCaseName () { return methodName; }
	public int getTotalTestCases() { return allTestData.size();}
	public String getTestStatus(){ return status;}
	public long getExecutionDuration() { return exeTime;}
	public int getPassedCount() { return passedTestData.size();}
	public int getFailedCount() { return failedTestData.size();}

}
