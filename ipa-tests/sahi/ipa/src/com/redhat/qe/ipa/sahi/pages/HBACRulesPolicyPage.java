package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class HBACRulesPolicyPage extends IPAWebPage implements StandardTest {

	private static Logger log = Logger.getLogger(HBACRulesPolicyPage.class.getName());
	private static String url = CommonTasks.hbacRulesPolicyPage; 
	private String addPage = "Add HBAC Rule";
	private String duplicatePage = "Add Duplicate";
	private String delPage = "Delete";
	
	public HBACRulesPolicyPage (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile); 
		registerStandardTestCases();
		System.out.println("New instance of HBACRulesPolicyPage is ready"); 
	}
 /*
	private void registerStandardTestCases()
	{
		this.registerTestCases("add", addTestCases);
		this.registerTestCases("modify", modTestCases);
		this.registerTestCases("delete", delTestCases);
	}
	*/

	@Override
	public IPAWebTestMonitor addSingle(IPAWebTestMonitor monitor){
		try {
			addSingleNewEntry(monitor, addPage);
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
			addMultipleNewEntries(monitor, addPage, numOfEntries);
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
		try {
			addNewEntryThenEdit(monitor,addPage);
			monitor.pass();
		} catch (IPAWebAutomationException e) {
			e.printStackTrace();
			monitor.fail(e);
		}
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
			// check error dialog box
			if (browser.div("error_dialog").exists()){
				if (browser.div("error_dialog").getText().equals("HBAC rule with name \".*\" already exists"))
					monitor.pass();
				else
					monitor.fail("Error dialog triggered, but no desired error msg found");
		//		closePopUpDialog();
			}else
				monitor.fail("No error dialog triggered");
			return monitor;
		} catch (IPAWebAutomationException e) {
			monitor.fail(e); 
			return monitor;
		}
		
//		String duplicatedEntry = "duplicate";
//		browser.span("Add").click();
//		browser.textbox("cn").setValue(duplicatedEntry);
//		browser.button("Add").click(); 
//		
//		// enter the same data second time
//		browser.span("Add").click();
//		browser.textbox("cn").setValue(duplicatedEntry);
//		browser.button("Add").click();
//		
	}

	@Override
	public IPAWebTestMonitor addNegativeRequiredFields(IPAWebTestMonitor monitor) {
		browser.span("Add").click();
		browser.button("Add").click(); 
		if (browser.span("Required field").exists())
			monitor.pass();
		else
			monitor.fail("No 'Required field' lable appears");
		// closePopUpDialog();
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor modify(IPAWebTestMonitor monitor) {
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
		int numOfEntries = 4;
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
