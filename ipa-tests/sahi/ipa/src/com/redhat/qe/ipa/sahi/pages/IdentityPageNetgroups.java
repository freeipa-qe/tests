package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IdentityPageNetgroups extends IPAWebPage{

	private static Logger log = Logger.getLogger(IdentityPageNetgroups.class.getName());
	private static String url = CommonTasks.netgroupPage; 
	
	public IdentityPageNetgroups (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile); 
		duplicateErrorMsgStartsWith = "netgroup with name";
		backLink = "Netgroups";
		addPage = "Add Netgroup";
		duplicatePage = "Add Duplicate Netgroup";
		modifyPage = "Modify Netgroup";
		delPage = "Delete Netgroup";
		registerStandardTestCases();
		System.out.println("New instance of " + IdentityPageNetgroups.class.getName() + " is ready"); 
	}
}
