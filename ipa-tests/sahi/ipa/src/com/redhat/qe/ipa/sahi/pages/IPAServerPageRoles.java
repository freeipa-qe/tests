package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IPAServerPageRoles extends IPAWebPage{

	private static Logger log = Logger.getLogger(IPAServerPageRoles.class.getName());
	private static String url = CommonTasks.rolePage;
	
	public IPAServerPageRoles (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "Roles";
		duplicateErrorMsgStartsWith = "role with name";
		
		addPage = "Add Roles";
		duplicatePage = "Add Duplicate Roles";
		delPage = "Delete Roles"; 
		registerStandardTestCases();
		System.out.println("New instance of " + IPAServerPageRoles.class.getName() + " is ready");
	}
}
