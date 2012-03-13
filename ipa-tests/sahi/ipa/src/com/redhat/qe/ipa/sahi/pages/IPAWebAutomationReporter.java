package com.redhat.qe.ipa.sahi.pages;

import java.util.ArrayList;
import java.util.Hashtable;

public class IPAWebAutomationReporter {
	private static IPAWebAutomationReporter instance; 
	private Hashtable<String,IPAWebTestMonitor> announceQueue;
	private ArrayList<IPAWebTestMonitor> finishedQueue; 
	private ArrayList<Integer> failed; // index of failed test cases in finishedQueue
	private ArrayList<Integer> passed; // index of passed test cases in finishedQueue
	private ArrayList<Integer> empty;  // index of test cases that has empty test data sets in finishedQueue
									   // 	these test case are mostly place holder
	private StringBuffer report;
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
	}
	
	public String produceReport()
	{
		report = new StringBuffer();
		report.append("==================== Test Result Summary ========================");
		report.append("\nTotal finished test cases:" + finishedQueue.size());
		report.append("\nTotal PASS[" + passed.size() + "]  FAIL[" + failed.size() + "]  EMPTY[" + empty.size() +"]");
		report.append("\n+--------------------------------------------------------------+");
		report.append("\n|                         PASSED                               |");
		report.append("\n+--------------------------------------------------------------+");
		report.append(getReport(passed));
		
		report.append("\n+--------------------------------------------------------------+");
		report.append("\n|                         FAILED                               |");
		report.append("\n+--------------------------------------------------------------+");
		report.append(getReport(failed)); 
		
		report.append("\n+--------------------------------------------------------------+");
		report.append("\n|                         EMPTY                                |");
		report.append("\n+--------------------------------------------------------------+");
		report.append(getReport(empty));
		
		report.append("\n===================================================================");
		return report.toString();
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
}
