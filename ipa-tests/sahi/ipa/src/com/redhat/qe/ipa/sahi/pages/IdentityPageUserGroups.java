package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IdentityPageUserGroups extends IPAWebPage{

	private static Logger log = Logger.getLogger(IdentityPageUserGroups.class.getName());
	private static String url = CommonTasks.groupPage; 

	public IdentityPageUserGroups (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile); 
		duplicateErrorMsgStartsWith = "user with name"; 
		backLink="User Groups";
		addPage = "Add User Group";
		duplicatePage = "Add Duplicate User Group";
		modifyPage = "Modify User Group";
		delPage = "Delete User Group"; 
		
		registerStandardTestCases();
		System.out.println("New instance of "+ IdentityPageUserGroups.class.getName() + " is ready"); 
	}   

	@Override
	public IPAWebTestMonitor modify(IPAWebTestMonitor monitor) {
		browser.link("user001").click();
		try {
			fillDataIntoPage(monitor,modifyPage);
			browser.span("Update").click();
			if (browser.div("error_dialog").exists())
			{
				monitor.fail("error dialog appears");
				closeDialog();
				browser.span("Reset").click();
			}
			else
				monitor.pass();
		} catch (IPAWebAutomationActionNotDefinedException e) {
			monitor.fail(e);
			e.printStackTrace();
		}
		browser.link("User").in(browser.span("back-link")).click();
		return monitor;
	}

}
