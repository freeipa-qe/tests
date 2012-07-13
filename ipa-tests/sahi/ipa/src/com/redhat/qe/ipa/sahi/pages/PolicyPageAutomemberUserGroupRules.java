package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class PolicyPageAutomemberUserGroupRules extends IPAWebPage {
	private static Logger log = Logger.getLogger(PolicyPageAutomemberUserGroupRules.class.getName());
	private static String url = CommonTasks.automemberUserGroupPage;
	
	public PolicyPageAutomemberUserGroupRules (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "User group rules";
		duplicateErrorMsgStartsWith = "User Group Rule with name";
		
		addPage = "Add Automember User";//when using "Add Automember User" in the properties,it will use all the methods that contain pageName=addPage,and the methods are defined in standardTests
		duplicatePage = "Add Duplicate Automember User";
		modifySettingsPage = "Modify Automember User";
		modifyNegativePage = "Modify Automember User Negative";
		modifyConditionInclusiveAddPage = "Modify Automember Condition User Inclusive Add";
		modifyConditionInclusiveDeletePage ="Modify Automember Condition User Inclusive Delete";
		modifyConditionExclusiveAddPage ="Modify Automember Condition User Exclusive Add";
		modifyConditionExclusiveDeletePage ="Modify Automember Condition User Exclusive Delete";
		modifyUpdateResetCancelPage ="Modify Clicking Backlink User";
	    searchPage = "Search Automember Rule User";	
		setDefaultGroupPage = "Set Default User Group";
		delPage = "Delete Automember User"; 
	
		
		//registerStandardTestCases();
		registerTestCases("add","addSingle");//xdong for automember use
		registerTestCases("add","addAndAddAnother");//xdong for automember use
		registerTestCases("add","addThenEdit");//xdong for automember use
		registerTestCases("add","addThenCancel");//xdong for automember use
		registerTestCases("modify","modifyConditionInclusiveAdd");//xdong for automember use
		registerTestCases("modify","modifyConditionInclusiveDelete");//xdong for automember use
		registerTestCases("modify","modifyConditionExclusiveAdd");//xdong for automember use
		registerTestCases("modify","modifyConditionExclusiveDelete");//xdong for automember use
		registerTestCases("modify","setDefaultGroup");//xdong for automember use
		registerTestCases("modify","modifyUpdateResetCancel");//xdong for automember use
		registerTestCases("delete","deleteSingle");//xdong for automember use
		registerTestCases("delete","deleteMultiple");//xdong for automember use
		System.out.println("New instance of " + PolicyPageAutomemberUserGroupRules.class.getName() + " is ready");
	}

}
