package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class PolicyPageHBACServiceGroups extends IPAWebPage{

	private static Logger log = Logger.getLogger(PolicyPageHBACServiceGroups.class.getName());
	private static String url = CommonTasks.hbacServiceGroupPage; 
	
	public PolicyPageHBACServiceGroups (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "HBAC Service Groups";
		duplicateErrorMsgStartsWith = "HBAC service group with name";
		
		addPage = "Add HBAC Service Groups";
		duplicatePage = "Add Duplicate HBAC Service Groups";
		delPage = "Delete HBAC Service Groups"; 
		registerStandardTestCases();
		System.out.println("New instance of " + PolicyPageHBACServiceGroups.class.getName() + " is ready");
	}
}
