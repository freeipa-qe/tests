package com.redhat.qe.ipa.sahi.pages;

public interface StandardTest {
	
	// whenever the test case name changes, the following string array should change accordingly 
	public static final String[] standardAddTestCases = {"addSingle", "addAndAddAnother", "addThenEdit", "addThenCancel", "addSpecial", "addLong", "addNegativeDuplicate", "addNegativeRequiredFields","addNegative"};
	public static final String[] standardModTestCases = {"modify", "modifyUpdateResetCancel", "modifyNegative","modifyConditionInclusiveAdd","modifyConditionInclusiveDelete","modifyConditionExclusiveAdd","modifyConditionExclusiveDelete","setDefaultGroup"}; //xdong for the last 4
	public static final String[] standardSearchTestCases = {"searchPositive", "searchNegative"};
	public static final String[] standardDelTestCases = {"deleteSingle", "deleteMultiple"};
	
	public IPAWebTestMonitor addSingle(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addSpecial(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addLong(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addAndAddAnother(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addThenEdit(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addThenCancel(IPAWebTestMonitor monitor);
		
	public IPAWebTestMonitor addNegative(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addNegativeDuplicate(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addNegativeRequiredFields(IPAWebTestMonitor monitor);
	
	public IPAWebTestMonitor modify(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor modifyUpdateResetCancel(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor modifyNegative(IPAWebTestMonitor monitor);
	
	public IPAWebTestMonitor modifyConditionInclusiveAdd(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionInclusiveDelete(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionExclusiveAdd(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionExclusiveDelete(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor setDefaultGroup(IPAWebTestMonitor monitor);//xdong
	
	
	public IPAWebTestMonitor searchPositive(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor searchNegative(IPAWebTestMonitor monitor);
	
	public IPAWebTestMonitor deleteSingle(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor deleteMultiple(IPAWebTestMonitor monitor);
}
