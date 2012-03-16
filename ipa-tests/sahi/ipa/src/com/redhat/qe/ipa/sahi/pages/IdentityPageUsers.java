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
		duplicatePage = "Add Duplicate User";
		modifyPage = "Modify User";
		delPage = "Delete User";

		registerStandardTestCases();
		System.out.println("New instance of " + IdentityPageUsers.class.getName() + " is ready"); 
	}

	@Override
	public IPAWebTestMonitor modify(IPAWebTestMonitor monitor) {
		//FIXME: Hardcode data used here: user001
		browser.link("user001").click();
		try {
			fillDataIntoPage(monitor,modifyPage);
			browser.span("Update").click();
			if (browser.div("error_dialog").exists())
			{
				monitor.fail("error dialog appears");
				closePopUpDialog();
				browser.span("Reset").click();
			}
			else
				monitor.pass();
		} catch (IPAWebAutomationActionNotDefinedException e) {
			monitor.fail(e);
			e.printStackTrace();
		}
		browser.link(backLink).in(browser.span("back-link")).click();
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor modifyNegative(IPAWebTestMonitor monitor) {
		return monitor;
	}
	
}
