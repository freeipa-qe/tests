package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IPAServerPagePrivileges extends IPAWebPage{

	private static Logger log = Logger.getLogger(IPAServerPagePrivileges.class.getName());
	private static String url = CommonTasks.privilegePage;
	
	public IPAServerPagePrivileges (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "Privileges";
		duplicateErrorMsgStartsWith = "privilege with name";
		
		addPage = "Add Privileges";
		duplicatePage = "Add Duplicate Privileges";
		delPage = "Delete Privileges"; 
		registerStandardTestCases();
		System.out.println("New instance of " + IPAServerPagePrivileges.class.getName() + " is ready");
	}
}
