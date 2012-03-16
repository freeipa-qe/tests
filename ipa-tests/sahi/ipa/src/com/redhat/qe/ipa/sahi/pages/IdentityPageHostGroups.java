package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IdentityPageHostGroups extends IPAWebPage{

	private static Logger log = Logger.getLogger(IdentityPageHostGroups.class.getName());
	private static String url = CommonTasks.hostgroupPage; 
	
	public IdentityPageHostGroups (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile); 
		duplicateErrorMsgStartsWith = "host group with name";
		backLink = "Host Groups";
		addPage = "Add Host Group";
		duplicatePage = "Add Duplicate Host Group";
		modifyPage = "Modify Host Group";
		delPage = "Delete Host Group";

		registerStandardTestCases();
		System.out.println("New instance of " + IdentityPageHostGroups.class.getName() + " is ready"); 
	} 
}
