package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IdentityPageUsers extends IPAWebPage{

	private static Logger log = Logger.getLogger(IdentityPageUsers.class.getName());
	private static String url = CommonTasks.userPage;  
	
	public IdentityPageUsers (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile); 
		duplicateErrorMsgStartsWith = "user with name";
		backLink = "Users";
		addPage = "Add User";
		addNegativePage = "Add User Negative";
		duplicatePage = "Add Duplicate User";
		modifySettingsPage = "Modify User";
		modifyNegativePage = "Modify User Negative";
		delPage = "Delete User";

		
		//registerStandardTestCases();
		registerTestCases("add","addSingle");//xdong for automember init use
		registerTestCases("add","addAndAddAnother");//xdong for automember use
		registerTestCases("add","addThenEdit");//xdong for automember use
		registerTestCases("add","addThenCancel");//xdong for automember use
		registerTestCases("delete","deleteSingle");//xdong for automember use
		registerTestCases("delete","deleteMultiple");//xdong for automember use
		
		System.out.println("New instance of " + IdentityPageUsers.class.getName() + " is ready"); 
	}

}
