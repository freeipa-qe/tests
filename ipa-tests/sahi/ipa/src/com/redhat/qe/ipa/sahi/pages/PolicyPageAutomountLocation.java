package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class PolicyPageAutomountLocation extends IPAWebPage{

	private static Logger log = Logger.getLogger(PolicyPageAutomountLocation.class.getName());
	private static String url = CommonTasks.automountPage; 
	
	public PolicyPageAutomountLocation (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "Automount Locations";
		duplicateErrorMsgStartsWith = "automount location with name";
		
		addPage = "Add Automount Locations";
		duplicatePage = "Add Duplicate Automount Locations";
		delPage = "Delete Automount Locations"; 
		registerStandardTestCases();
		System.out.println("New instance of " + PolicyPageAutomountLocation.class.getName() + " is ready");
	}
}
