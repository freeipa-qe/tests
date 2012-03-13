package com.redhat.qe.ipa.sahi.pages;

public interface StandardTest {
	
	// whenever the test case name changes, the following string array should change accordingly 
	public static final String[] addTestCases = {"addSingle", "addAndAddAnother", "addThenEdit", "addThenCancel" ,"addNegativeDuplicate", "addNegativeRequiredFields"};
	public static final String[] modTestCases = {"modify", "modifyNegative"}; ;
	public static final String[] delTestCases = {"deleteSingle", "deleteMultiple"};
	
	public IPAWebTestMonitor addSingle(IPAWebTestMonitor result);
	public IPAWebTestMonitor addAndAddAnother(IPAWebTestMonitor result);
	public IPAWebTestMonitor addThenEdit(IPAWebTestMonitor result);
	public IPAWebTestMonitor addThenCancel(IPAWebTestMonitor result);
	
	public IPAWebTestMonitor addNegativeDuplicate(IPAWebTestMonitor result);
	public IPAWebTestMonitor addNegativeRequiredFields(IPAWebTestMonitor result);
	
	public IPAWebTestMonitor modify(IPAWebTestMonitor result);
	public IPAWebTestMonitor modifyNegative(IPAWebTestMonitor result);
	
	public IPAWebTestMonitor deleteSingle(IPAWebTestMonitor result);
	public IPAWebTestMonitor deleteMultiple(IPAWebTestMonitor result);
}
