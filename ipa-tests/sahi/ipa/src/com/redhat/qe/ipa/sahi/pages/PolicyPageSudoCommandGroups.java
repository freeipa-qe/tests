package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class PolicyPageSudoCommandGroups extends IPAWebPage{

	private static Logger log = Logger.getLogger(PolicyPageSudoCommandGroups.class.getName());
	private static String url = CommonTasks.sudoCommandGroupPage; 
	
	public PolicyPageSudoCommandGroups (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "Sudo Command Groups";
		duplicateErrorMsgStartsWith = "sudo command group with name";
		
		addPage = "Add Sudo Command Groups";
		duplicatePage = "Add Duplicate Sudo Command Groups";
		delPage = "Delete Sudo Command Groups"; 
		registerStandardTestCases();
		System.out.println("New instance of " + PolicyPageSudoCommandGroups.class.getName() + " is ready");
	}
}
