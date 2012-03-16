package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class PolicyPageSudoCommand extends IPAWebPage{

	private static Logger log = Logger.getLogger(PolicyPageSudoCommand.class.getName());
	private static String url = CommonTasks.sudoCommandPage; 
	
	public PolicyPageSudoCommand (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "Sudo Commands";
		duplicateErrorMsgStartsWith = "sudo command with name";
		
		addPage = "Add Sudo Commands";
		duplicatePage = "Add Duplicate Sudo Commands";
		delPage = "Delete Sudo Commands"; 
		registerStandardTestCases();
		System.out.println("New instance of " + PolicyPageSudoCommand.class.getName() + " is ready");
	}
}
