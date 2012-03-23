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
		modifyPage = "Modify User";
		modifyNegativePage = "Modify User Negative";
		delPage = "Delete User";

		//registerStandardTestCases();
		registerTestCases("add", "addNegative");
		System.out.println("New instance of " + IdentityPageUsers.class.getName() + " is ready"); 
	}

}
