package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IPAServerPagePermissions extends IPAWebPage{

	private static Logger log = Logger.getLogger(IPAServerPagePermissions.class.getName());
	private static String url = CommonTasks.permissionPage;
	
	public IPAServerPagePermissions (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "Permissions";
		duplicateErrorMsgStartsWith = "This entry";
		
		addPage = "Add Permissions";
		duplicatePage = "Add Duplicate Permissions";
		delPage = "Delete Permissions"; 
		registerStandardTestCases();
		System.out.println("New instance of " + IPAServerPagePermissions.class.getName() + " is ready");
	}

}
