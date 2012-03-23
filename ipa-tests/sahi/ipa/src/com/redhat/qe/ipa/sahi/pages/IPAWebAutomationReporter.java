package com.redhat.qe.ipa.sahi.pages;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;

public class IPAWebAutomationReporter {
	private static IPAWebAutomationReporter instance; 
	private Hashtable<String,IPAWebTestMonitor> announceQueue;
	private ArrayList<IPAWebTestMonitor> finishedQueue; 
	private ArrayList<Integer> failed; // index of failed test cases in finishedQueue
	private ArrayList<Integer> passed; // index of passed test cases in finishedQueue
	private ArrayList<Integer> empty;  // index of test cases that has empty test data sets in finishedQueue
									   // 	these test case are mostly place holder
	private StringBuffer report;
	private Hashtable<String,Hashtable<String,Hashtable<String,Hashtable<String,String>>>> finalTestResult;
	
	public static IPAWebAutomationReporter instance() 
	{
		if (instance == null)
			instance = new IPAWebAutomationReporter();
		return instance;
	}
	
	private IPAWebAutomationReporter()
	{
		announceQueue = new Hashtable<String,IPAWebTestMonitor>();
		finishedQueue = new ArrayList<IPAWebTestMonitor>(); 
		failed = new ArrayList<Integer>();
		passed = new ArrayList<Integer>();
		empty  = new ArrayList<Integer>();
		finalTestResult = new Hashtable<String,Hashtable<String,Hashtable<String,Hashtable<String,String>>>>();
	}
	
	public String produceReport()
	{
		report = new StringBuffer();
		report.append("==================== Test Result Summary ========================");
		report.append("\nTotal finished test cases:" + finishedQueue.size());
		report.append("\nTotal PASS[" + passed.size() + "]  FAIL[" + failed.size() + "]  EMPTY[" + empty.size() +"]");
		report.append("\n*--------------------------------------------------------------*");
		report.append("\n|                         PASSED                               |");
		report.append("\n*--------------------------------------------------------------*");
		report.append(getReport(passed));
		
		report.append("\n*--------------------------------------------------------------*");
		report.append("\n|                         FAILED                               |");
		report.append("\n*--------------------------------------------------------------*");
		report.append(getReport(failed)); 
		
		report.append("\n*--------------------------------------------------------------*");
		report.append("\n|                         EMPTY                                |");
		report.append("\n*--------------------------------------------------------------*");
		report.append(getReport(empty));
		
		report.append("\n===================================================================");
		return report.toString();
	}
	
	public String produceTreeReport()
	{
		Enumeration<String> testClasses = finalTestResult.keys();
		Iterator<String> classNames = getSortedKeys(testClasses);
		StringBuffer treeReport = new StringBuffer(); 
		int totalPass = 0;
		int totalFail = 0;
		int totalTest = 0;
		int passingRate = 0; 
		treeReport.append("\n### [Passing Rate:(passingRate%) Total(totalTest) PASS(totalPass) FAIL(totalFail) ] ###\n"); 
		while (classNames.hasNext()){
			int totalPassInClass = 0;
			int totalFailInClass = 0;
			int totalTestInClass = 0;
			int totalPassingRateInClass = 0;
			String className = classNames.next();
			Hashtable<String,Hashtable<String,Hashtable<String,String>>> testCases = finalTestResult.get(className);
			Iterator<String> testMethodNames = getSortedKeys(testCases.keys());
			treeReport.append("\n" + "+ " + className + " [Passing Rate:(totalPassingRateInClass%) Total(totalTestInClass) PASS(totalPassInClass) FAIL(totalFailInClass)]");
			while (testMethodNames.hasNext()){
				int totalPassInTestCase = 0;
				int totalFailInTestCase = 0;
				int totalTestInTestCase = 0;
				String methodName = testMethodNames.next();
				Hashtable<String,Hashtable<String,String>> dataSets = testCases.get(methodName);
				Iterator<String> testDataSetNames = getSortedKeys(dataSets.keys());
				treeReport.append("\n" + "|--+ " + methodName + " [Total:totalTestInTestCase PASS:totalPassInTestCase FAIL:totalFailInTestCase]");
				while(testDataSetNames.hasNext()){
					String dataSetName = testDataSetNames.next();
					Hashtable<String,String> testDataSetResult = dataSets.get(dataSetName);
					
					if (dataSetName == null || dataSetName.equals(""))
						dataSetName = "NO TEST DATA DEFINED";
					treeReport.append("\n" + "|     |--- " + dataSetName);
					String logmessage = testDataSetResult.get("logmessage");
					String result = testDataSetResult.get("result"); 
					
					if (result.equals("pass")){
						treeReport.append("\n" + "|           |==> " + "(" + result + ") log: ["+logmessage+"]"); 
						totalPassInTestCase++;
						totalTestInTestCase++;
						totalTestInClass++;
						totalPassInClass++; 
						totalTest++;
						totalPass++;
					}else{
						treeReport.append("\n" + "|@@@@@@@@@@@|==> " + "(" + result + ") log: ["+logmessage+"]"); 
						totalFailInTestCase++;
						totalTestInTestCase++;
						totalFailInClass++;
						totalTestInClass++;
						totalTest++;
						totalFail++;
					}
				}//while--testDataSet
				String sub = treeReport.toString().replaceAll("totalTestInTestCase", totalTestInTestCase+"").replaceAll("totalPassInTestCase", totalPassInTestCase+"").replaceAll("totalFailInTestCase", totalFailInTestCase+"");
				treeReport.delete(0, treeReport.length()); 
				treeReport.append(sub);
			}//while--testCase
			totalPassingRateInClass = (int)(((double)totalPassInClass/(double)totalTestInClass) * 100 );
			String sub = treeReport.toString().replaceAll("totalTestInClass", totalTestInClass+"").replaceAll("totalPassInClass", totalPassInClass+"").replaceAll("totalFailInClass", totalFailInClass+"").replaceAll("totalPassingRateInClass", totalPassingRateInClass + "");
			treeReport.delete(0, treeReport.length());  
			treeReport.append(sub);
		}//while--class
		passingRate = (int)(((double)totalPass/(double)totalTest) * 100 );
		String sub = treeReport.toString().replaceAll("totalTest", totalTest+"").replaceAll("totalPass", totalPass+"").replaceAll("totalFail", totalFail+"").replaceAll("passingRate", passingRate + "");
		treeReport.delete(0, treeReport.length()); 
		treeReport.append(sub);
		return treeReport.toString();
	}
	
	public void addTestCaseInExecutionQueue(IPAWebTestMonitor monitor)
	{ 
		monitor.start();
		String signture = monitor.getTestSignture();
		announceQueue.put(signture,monitor);
	}
	
	public void addIPAWebTestResult(IPAWebTestMonitor monitor)
	{
		monitor.finish();
		if (announceQueue.containsKey(monitor.getTestSignture())){
			announceQueue.remove(monitor.getTestSignture());
		}
		finishedQueue.add(monitor);
		//save test results 
		String className = monitor.getTestClassName();
		String testCaseName = monitor.getTestCaseName();
		Hashtable<String,Hashtable<String,String>> testResults = monitor.getTestResults();
		saveTestResult(className, testCaseName, testResults);
		
		Integer index = new Integer(finishedQueue.size()-1);
		// return=0: empty test data set ; return=1: all passed ; return=-1: not empty and some failed
		int resultStatusCode = monitor.getResultStatusCode();
		if (resultStatusCode == 0)
			empty.add(index);
		else if (resultStatusCode == 1)
			passed.add(index);
		else
			failed.add(index);
	}
	
	private void saveTestResult(String className, String testCaseName, Hashtable<String,Hashtable<String,String>> testResults)
	{
		Hashtable<String,Hashtable<String,Hashtable<String,String>>> Class;
		Hashtable<String,Hashtable<String,String>> TestCase;
		if (finalTestResult.containsKey(className))
		{
			Class = finalTestResult.get(className);
			if (Class.containsKey(testCaseName))
			{
				TestCase = Class.get(testCaseName); 
			}else{
				TestCase = new Hashtable<String,Hashtable<String,String>>(); 
			}
		}else{
			Class = new Hashtable<String,Hashtable<String,Hashtable<String,String>>>();
			TestCase = new Hashtable<String,Hashtable<String,String>>(); 
		}
		
		Class.put(testCaseName, testResults);
		finalTestResult.put(className, Class);
	}
	
	private String getReport(ArrayList<Integer> index)
	{
		StringBuffer buffer = new StringBuffer();
		for (Integer i:index){
			IPAWebTestMonitor monitor = finishedQueue.get(i.intValue());
			String report = monitor.getReport();
			buffer.append(report);
		}
		if (buffer.length()==0 )
			buffer.append("\n");
		return buffer.toString();
	}
	
	private Iterator<String> getSortedKeys(Enumeration<String> keys)
	{ 
		List<String> list = Collections.list(keys);
		Collections.sort(list);
		Iterator<String> iter = list.iterator();
		return iter;
	}
}
