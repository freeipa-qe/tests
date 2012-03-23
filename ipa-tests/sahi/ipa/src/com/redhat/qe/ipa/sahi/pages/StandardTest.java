package com.redhat.qe.ipa.sahi.pages;

public interface StandardTest {
	
	// whenever the test case name changes, the following string array should change accordingly 
	public static final String[] standardAddTestCases = {"addSingle", "addAndAddAnother", "addThenEdit", "addThenCancel" ,"addNegativeDuplicate", "addNegativeRequiredFields","addNegative"};
	public static final String[] standardModTestCases = {"modify", "modifyNegative"}; ;
	public static final String[] standardDelTestCases = {"deleteSingle", "deleteMultiple"};
	
	public IPAWebTestMonitor addSingle(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addAndAddAnother(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addThenEdit(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addThenCancel(IPAWebTestMonitor monitor);
	
	public IPAWebTestMonitor addNegative(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addNegativeDuplicate(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addNegativeRequiredFields(IPAWebTestMonitor monitor);
	
	public IPAWebTestMonitor modify(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor modifyNegative(IPAWebTestMonitor monitor);
	
	public IPAWebTestMonitor deleteSingle(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor deleteMultiple(IPAWebTestMonitor monitor);
}
