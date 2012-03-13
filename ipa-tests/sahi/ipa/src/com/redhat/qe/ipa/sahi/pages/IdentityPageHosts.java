package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IdentityPageHosts extends IPAWebPage implements StandardTest {

	private static Logger log = Logger.getLogger(IdentityPageHosts.class.getName());
	private static String url = CommonTasks.hostPage; 
	private String addPage = "Add Host";
	private String duplicatePage = "Add Duplicate Host";
	private String modifyPage = "Modify Host";
	private String delPage = "Delete Host";
	
	public IdentityPageHosts (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile); 
		registerStandardTestCases();
		System.out.println("New instance of IdentityPageHost is ready"); 
		duplicateErrorMsgStartsWith = "host with name";
		backLink = "Hosts";
	}
 
	private void registerStandardTestCases()
	{
		this.registerTestCases("add", addTestCases);
		//this.registerTestCases("modify", modTestCases);
		this.registerTestCases("delete", delTestCases);
	}

	@Override
	public IPAWebTestMonitor addSingle(IPAWebTestMonitor monitor){
		try {
			addSingleNewEntry(monitor, addPage);
			closePopUpDialog();
			monitor.pass();
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
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
			closePopUpDialog();
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
	public IPAWebTestMonitor addThenCancel(IPAWebTestMonitor monitor){
		try {
			addNewEntryThenCancelOperation(monitor, addPage);
			monitor.pass();
		} catch (IPAWebAutomationException e) {
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}

	@Override
	public IPAWebTestMonitor addNegativeDuplicate(IPAWebTestMonitor monitor) {
		
		// enter the data first time
		try {
			addSingleNewEntry(monitor, duplicatePage);
			closePopUpDialog();
			addSingleNewEntry(monitor, duplicatePage);
			
			
			// check error dialog box
			if (browser.div("error_dialog").exists()){
				String errorMsg = browser.div("error_dialog").getText();
				if (errorMsg.startsWith(duplicateErrorMsgStartsWith) && errorMsg.endsWith(duplicateErrorMsgEndsWith))
					monitor.pass();
				else
					monitor.fail("Error dialog triggered, but no desired error msg found");
				closePopUpDialog();
			}else
				monitor.fail("No error dialog triggered");
			return monitor;
		} catch (IPAWebAutomationException e) {
			monitor.fail(e); 
			return monitor;
		}
	}

	@Override
	public IPAWebTestMonitor addNegativeRequiredFields(IPAWebTestMonitor monitor) {
		browser.span("Add").click();
		browser.button("Add").click(); 
		if (browser.span("Required field").exists())
			monitor.pass();
		else
			monitor.fail("No 'Required field' lable appears");
		closePopUpDialog();
		return monitor;
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
				closePopUpDialog();
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
	
	@Override
	public IPAWebTestMonitor modifyNegative(IPAWebTestMonitor monitor) {
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor deleteSingle(IPAWebTestMonitor monitor){ 
		try {
			deleteSingleEntry(monitor, delPage);
			monitor.pass();
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		} 
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor deleteMultiple(IPAWebTestMonitor monitor){
		int numOfEntries = 5;
		try {
			deleteMultipleEntry(monitor, delPage, numOfEntries);
			monitor.pass();
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		} catch (Exception e){
			monitor.fail(e);
		}
		return monitor;
	}
	 
}
