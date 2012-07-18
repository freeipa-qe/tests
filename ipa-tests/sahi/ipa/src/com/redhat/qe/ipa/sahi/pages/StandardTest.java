package com.redhat.qe.ipa.sahi.pages;

public interface StandardTest {
	
	// whenever the test case name changes, the following string array should change accordingly 
	public static final String[] standardAddTestCases = {"addSingle", "addAndAddAnother", "addThenEdit", "addThenCancel", "addSpecial", "addLong", "addNegativeDuplicate", "addNegativeRequiredFields","addNegative"};
	public static final String[] standardModTestCases = {"modify", "modifyNegative"};
	public static final String[] standardSearchTestCases = {"searchPositive", "searchNegative"};
	public static final String[] standardDelTestCases = {"deleteSingle", "deleteMultiple"};
	public static final String[] EditUserDelegationTestCases = {"addUserGroup", "delegationNotAdded", "addUserDelegation", "deleteNonStandard","modifyUpdateResetCancel"};
	public static final String[] AutomemberTestCases = {"modifyConditionInclusiveAdd","modifyConditionInclusiveDelete","modifyConditionExclusiveAdd","modifyConditionExclusiveDelete","modifyUpdateResetCancel","setDefaultGroup"};//xdong
	
	public IPAWebTestMonitor addSingle(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addSpecial(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addLong(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addAndAddAnother(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addThenEdit(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addThenCancel(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addOne(IPAWebTestMonitor monitor);//xdong
	
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
	
	public IPAWebTestMonitor addUserDelegation(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addUserGroup(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor delegationNotAdded(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor deleteNonStandard(IPAWebTestMonitor monitor);
}
