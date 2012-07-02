package com.redhat.qe.ipa.sahi.pages;

public interface NonStandardTest {
	
	// whenever the test case name changes, the following string array should change accordingly 
	public static final String[] EditUserDelegationTestCases = {"addUserGroup", "delegationNotAdded", "addUserDelegation", "deleteNonStandard"};
	
	public IPAWebTestMonitor addUserDelegation(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor addUserGroup(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor delegationNotAdded(IPAWebTestMonitor monitor);
	//public IPAWebTestMonitor delegationAdded(IPAWebTestMonitor monitor);
	public IPAWebTestMonitor deleteNonStandard(IPAWebTestMonitor monitor);
	
}
