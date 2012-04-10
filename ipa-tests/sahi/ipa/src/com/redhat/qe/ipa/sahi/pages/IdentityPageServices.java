package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IdentityPageServices extends IPAWebPage{

	private static Logger log = Logger.getLogger(IdentityPageServices.class.getName());
	private static String url = CommonTasks.servicePage; 
	
	public IdentityPageServices (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile); 
		addPage = "Add Service";
		duplicatePage = "Add Duplicate Service";
		modifySettingsPage = "Modify Service";
		delPage = "Delete Service";
		duplicateErrorMsgStartsWith = "service with name";
		backLink = "Services";
		registerStandardTestCases();
		System.out.println("New instance of " + IdentityPageServices.class.getName() + " is ready");
	}
}
