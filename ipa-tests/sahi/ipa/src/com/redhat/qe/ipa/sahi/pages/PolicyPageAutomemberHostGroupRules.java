package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class PolicyPageAutomemberHostGroupRules extends IPAWebPage {
	private static Logger log = Logger.getLogger(PolicyPageAutomemberHostGroupRules.class.getName());
	private static String url = CommonTasks.automemberHostGroupPage;
	
	public PolicyPageAutomemberHostGroupRules (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "Host group rules";
		duplicateErrorMsgStartsWith = "Host Group Rule with name";
		
		addPage = "Add Automember Host";
		duplicatePage = "Add Duplicate Automember Host";
		modifySettingsPage = "Modify Automember Host";
		modifyNegativePage = "Modify Automember Host Negative";
		modifyConditionInclusiveAddPage = "Modify Automember Condition Host Inclusive Add";
		modifyConditionInclusiveDeletePage ="Modify Automember Condition Host Inclusive Delete";
		modifyConditionExclusiveAddPage ="Modify Automember Condition Host Exclusive Add";
		modifyConditionExclusiveDeletePage ="Modify Automember Condition Host Exclusive Delete";
		setDefaultGroupPage = "Set Default Host Group";
		delPage = "Delete Automember Host"; 
	
		registerStandardTestCases();
		System.out.println("New instance of " + PolicyPageAutomemberHostGroupRules.class.getName() + " is ready");
	}

}
