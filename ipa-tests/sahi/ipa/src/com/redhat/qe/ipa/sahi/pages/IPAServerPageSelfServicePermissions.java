package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IPAServerPageSelfServicePermissions extends IPAWebPage{

	private static Logger log = Logger.getLogger(IPAServerPageSelfServicePermissions.class.getName());
	private static String url = CommonTasks.selfservicepermissionPage;
	
	public IPAServerPageSelfServicePermissions (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "Self Service Permissions";
		duplicateErrorMsgStartsWith = "This entry";
		
		addPage = "Add SelfServicePermissions";
		duplicatePage = "Add Duplicate SelfServicePermissions";
		delPage = "Delete SelfServicePermissions"; 
		registerStandardTestCases();
		System.out.println("New instance of " + IPAServerPageSelfServicePermissions.class.getName() + " is ready");
	}

}
