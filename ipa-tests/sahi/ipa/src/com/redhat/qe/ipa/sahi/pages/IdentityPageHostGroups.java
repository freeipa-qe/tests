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
		addOnePage = "Add One Host Group";
		duplicatePage = "Add Duplicate Host Group";
		modifySettingsPage = "Modify Host Group";
		delPage = "Delete Host Group";

		registerStandardTestCases();
		//registerTestCases("add","addSingle");//xdong for automember use
		//registerTestCases("add","addAndAddAnother");//xdong for automember use
		//registerTestCases("add","addThenEdit");//xdong for automember use
		//registerTestCases("add","addThenCancel");//xdong for automember use
		//registerTestCases("add","addOne");//xdong for automember use
		//registerTestCases("modify","modifyConditionInclusiveAdd");//xdong for automember use
		//registerTestCases("modify","modifyConditionInclusiveDelete");//xdong for automember use
		//registerTestCases("modify","modifyConditionExclusiveAdd");//xdong for automember use
		//registerTestCases("modify","modifyConditionExclusiveDelete");//xdong for automember use
		//registerTestCases("modify","setDefaultGroup");//xdong for automember use
		//registerTestCases("modify","modifyUpdateResetCancel");//xdong for automember use
		//registerTestCases("delete","deleteSingle");//xdong for automember use
		//registerTestCases("delete","deleteMultiple");//xdong for automember use
		
		System.out.println("New instance of " + IdentityPageHostGroups.class.getName() + " is ready"); 
	} 
}
