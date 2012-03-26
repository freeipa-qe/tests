package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IdentityPageHosts extends IPAWebPage {

	private static Logger log = Logger.getLogger(IdentityPageHosts.class.getName());
	private static String url = CommonTasks.hostPage;  
	
	public IdentityPageHosts (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile); 
		duplicateErrorMsgStartsWith = "host with name";
		backLink = "Hosts";
		addPage = "Add Host";
		duplicatePage = "Add Duplicate Host";
		modifyPage = "Modify Host";
		delPage = "Delete Host";
		registerStandardTestCases();
		System.out.println("New instance of " + IdentityPageHosts.class.getName() + " is ready"); 
	}

	@Override
	public IPAWebTestMonitor addAndAddAnother(IPAWebTestMonitor monitor){
		int numOfEntries = 3;
		try { 
			browser.span("Add").click(); 
			for (int i=0; i< numOfEntries ; i++)
			{ 
				fillDataIntoPage(monitor,addPage);
				browser.button("Add and Add Another").click();
				browser.button("OK").click();
			}
			browser.button("Cancel").click();
			monitor.pass();
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		} catch (Exception e){
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}

	@Override
	public IPAWebTestMonitor addThenEdit(IPAWebTestMonitor monitor){  
		try {// Host add has its' own logic fllow, do not use generic function here
			browser.span("Add").click();
			fillDataIntoPage(monitor,addPage); 
			browser.button("Add and Edit").click();
			closeDialog();
			boolean inEditingMode = verifyInEditingMode();
			if (!inEditingMode)
				monitor.fail("after click 'Add and Edit', we are not in edit mode");
			else
				monitor.pass();
		} catch (IPAWebAutomationException e) {
			e.printStackTrace();
			monitor.fail(e);
		}
		browser.link(backLink).in(browser.span("back-link")).click();
		return monitor;
	}

	@Override
	public IPAWebTestMonitor addNegativeDuplicate(IPAWebTestMonitor monitor) {
		
		// enter the data first time
		try {
			addSingleNewEntry(monitor, duplicatePage);
			closeDialog();
			addSingleNewEntry(monitor, duplicatePage);
			
			// check error dialog box
			if (browser.div("error_dialog").exists()){
				String errorMsg = browser.div("error_dialog").getText();
				if (errorMsg.startsWith(duplicateErrorMsgStartsWith) && errorMsg.endsWith(duplicateErrorMsgEndsWith))
					monitor.pass();
				else
					monitor.fail("Error dialog triggered, but no desired error msg found");
				closeDialog();
			}else
				monitor.fail("No error dialog triggered");
			return monitor;
		} catch (IPAWebAutomationException e) {
			monitor.fail(e); 
			return monitor;
		}
	}
}
