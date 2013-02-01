package com.redhat.qe.ipa.sahi.pages;

public interface StandardTest {
	
	// whenever the test case name changes, the following string array should change accordingly 
	public static final String[] standardAddTestCases = {"addSingle", "addAndAddAnother", "addThenEdit", "addThenCancel","addNegativeDuplicate", "addNegativeRequiredFields"};//"addNegative" is cancelled for now since in globalization ,most of pages don't have "addNegative" test data
	//public static final String[] standardModTestCases = {"modify", "modifyNegative","modifyUpdateResetCancel"};// we don't have the related test data in globalization.
	public static final String[] standardSearchTestCases = {"searchPositive", "searchNegative"};
	public static final String[] standardDelTestCases = {"deleteSingle", "deleteMultiple"};
	public static final String[] EditUserDelegationTestCases = {"addUserGroup", "delegationNotAdded", "addUserDelegation", "addSpecial", "addLong","addNegative","modify", "modifyNegative","modifyUpdateResetCancel","deleteNonStandard"};
	public static final String[] AutomemberTestCases = {"modify","modifyUpdateResetCancel","modifyConditionInclusiveAddSingle","modifyConditionInclusiveAddAndAddAnother","modifyConditionInclusiveAddThenCancel","modifyConditionInclusiveDeleteSingle","modifyConditionInclusiveDeleteMultiple","modifyConditionExclusiveAddSingle","modifyConditionExclusiveAddAndAddAnother","modifyConditionExclusiveAddThenCancel","modifyConditionExclusiveDeleteSingle","modifyConditionExclusiveDeleteMultiple","setDefaultGroup"};//xdong
	
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
	
	public IPAWebTestMonitor modifyConditionInclusiveAddSingle(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionInclusiveAddAndAddAnother(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionInclusiveAddThenCancel(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionInclusiveDeleteSingle(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionInclusiveDeleteMultiple(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionExclusiveAddSingle(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionExclusiveAddAndAddAnother(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionExclusiveAddThenCancel(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionExclusiveDeleteSingle(IPAWebTestMonitor monitor);//xdong
	public IPAWebTestMonitor modifyConditionExclusiveDeleteMultiple(IPAWebTestMonitor monitor);//xdong
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
