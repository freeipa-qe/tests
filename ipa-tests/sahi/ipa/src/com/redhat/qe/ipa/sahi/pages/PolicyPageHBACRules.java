package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class PolicyPageHBACRules extends IPAWebPage{

	private static Logger log = Logger.getLogger(PolicyPageHBACRules.class.getName());
	private static String url = CommonTasks.hbacRulesPolicyPage; 
	
	public PolicyPageHBACRules (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile); 
		backLink = "HBAC Rules";
		duplicateErrorMsgStartsWith = "HBAC rule with name";
		addPage = "Add HBAC Rule";
		duplicatePage = "Add Duplicate HBAC Rule";
		delPage = "Delete HBAC Rule";
		
		registerStandardTestCases();
		System.out.println("New instance of "+ PolicyPageHBACRules.class.getName() + " is ready"); 
	}
}
