package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class PolicyPageSudoRules extends IPAWebPage{

	private static Logger log = Logger.getLogger(PolicyPageSudoRules.class.getName());
	private static String url = CommonTasks.sudoRulePage; 
	
	public PolicyPageSudoRules (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "Sudo Rules";
		duplicateErrorMsgStartsWith = "Sudo rule with name";
		
		addPage = "Add Sudo Rules";
		duplicatePage = "Add Duplicate Sudo Rules";
		delPage = "Delete Sudo Rules"; 
		registerStandardTestCases();
		System.out.println("New instance of " + PolicyPageSudoRules.class.getName() + " is ready");
	}
}
