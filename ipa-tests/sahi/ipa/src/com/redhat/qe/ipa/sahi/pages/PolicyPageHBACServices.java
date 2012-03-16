package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class PolicyPageHBACServices extends IPAWebPage{

	private static Logger log = Logger.getLogger(PolicyPageHBACServices.class.getName());
	private static String url = CommonTasks.hbacServicePage; 
	
	public PolicyPageHBACServices (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "HBAC Services";
		duplicateErrorMsgStartsWith = "HBAC service with name";
		addPage = "Add HBAC Services";
		duplicatePage = "Add Duplicate HBAC Services";
		delPage = "Delete HBAC Services"; 
		registerStandardTestCases();
		System.out.println("New instance of " + PolicyPageHBACServices.class.getName() + " is ready");
	}
}
