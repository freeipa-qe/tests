package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IPAServerPageDelegation extends IPAWebPage{

	private static Logger log = Logger.getLogger(IPAServerPageDelegation.class.getName());
	private static String url = CommonTasks.delegationPage;
	
	public IPAServerPageDelegation (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "Delegations";
		duplicateErrorMsgStartsWith = "This entry";
		
		addPage = "Add Delegation";
		addSpecialPage="Add Special Delegation";
		addLongPage="Add Long Delegation";
		duplicatePage = "Add Duplicate Delegation";
		addNegativePage="Add Negative Delegation";
		modifySettingsPage="Modify Delegation Settings";
		modifyUpdateResetCancelPage="Modify Delegation UpdateResetCancel";
		//modifyNegativePage="Modify Delegation Negative";
		searchPage="Search Delegation";
		delPage = "Delete Delegation"; 
		registerStandardTestCases();
		System.out.println("New instance of " + IPAServerPageDelegation.class.getName() + " is ready");
	}

}
