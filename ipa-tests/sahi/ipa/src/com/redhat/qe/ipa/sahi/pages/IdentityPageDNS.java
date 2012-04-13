package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IdentityPageDNS extends IPAWebPage{

	private static Logger log = Logger.getLogger(IdentityPageDNS.class.getName());
	private static String url = CommonTasks.dnsPage; 
	String addReversePage;
	String duplicateReversePage;
	String modifyReversePage;
	String deleteReversePage;
	String modifySettingsPage;
	String modifyRecordsPage;
	
	public IdentityPageDNS (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile); 
		duplicateErrorMsgStartsWith = "DNS zone with name";
		backLink = "DNS Zones";
		addPage = "Add DNS Zone";
//		addReversePage = "Add Reverse DNS Zone";
//		addPage = addReversePage; // temp 
		
		duplicatePage = "Add Duplicate DNS Zone";
//		duplicateReversePage = "Add Reverse Duplicate DNS Zone";
//		duplicatePage = duplicateReversePage; // temp
		
		modifySettingsPage = "Modify DNS Zone Settings";
//		modifyReversePage = "Modify Reverse DNS Record";
//		modifyPage = modifyReversePage; //temp
		
		modifyRecordsPage = "Modify DNS Records";
		
		delPage = "Delete DNS Zone";
//		deleteReversePage = "Delete Reverse DNS Zone";
//		delPage = deleteReversePage ; //temp
		 
		//registerTestCases("add", "addSingle");
		//registerTestCases("modify", "modifySettings");
		registerTestCases("modify", "modifyRecords");
		registerTestCases("delete", "deleteSingle");
		System.out.println("New instance of " + IdentityPageDNS.class.getName() +" is ready"); 
	}
	
	public IPAWebTestMonitor modifySettings(IPAWebTestMonitor monitor) {
		String pageName = modifySettingsPage;
		
		String testAccount = factory.getModifyTestAccount(pageName);
		if (testAccount != null && browser.link(testAccount).exists())
		{
			browser.link(testAccount).click();
			browser.link("details").click();
			return executeModify(monitor, pageName);
		}else{
			monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
			return monitor;
		} 
	}
	
	public IPAWebTestMonitor modifyRecords(IPAWebTestMonitor monitor) {
		String pageName = modifyRecordsPage;
		
		String testAccount = factory.getModifyTestAccount(pageName);
		if (testAccount != null && browser.link(testAccount).exists())
		{
			browser.link(testAccount).click();
			browser.link("@").click();
			
			///////////////////////////////////////////////////////////////
			ArrayList<String> uiElements = factory.getUIELements(pageName); 
			for (String uiElement:uiElements)
			{
				String[] elementID = uiElement.split(":"); 
				String recordType = elementID[0];
				String tagAndid = elementID[1]; 
				String[] tagid = tagAndid.split("=");
				String tag = tagid[0];
				String id = tagid[1];
				String value = factory.getValue(pageName, recordType, tagAndid);
				
				/// add ///
				monitor.setCurrentTestData(pageName,  "{"+ recordType + ":" + tag + ":" + id + ":" + value + " 'add single'}");
				browser.span("Add").near(browser.label(recordType + ":")).click();
				
				setElementValue(monitor, pageName,tag,id,value); 
				browser.span("Add").near(browser.span("Add and Add Another")).click(); 
				
				if (browser.checkbox(value).exists()){
					monitor.pass("Add one " + recordType + " success");
					/// delete one ///
					monitor.setCurrentTestData(pageName,  "{"+ recordType + ":" + tag + ":" + id + ":" + value + " 'delete single'}");
					browser.checkbox(value).check();
					browser.span("Delete").near(browser.label(recordType + ":")).click();
					browser.button("Delete").click();
					if (browser.checkbox(value).exists()){
						monitor.fail("can not delete this record");
					}else{
						monitor.pass("record deleted");
					}
				}
				else{
					monitor.fail("Add new record " + recordType + " failed");
				}
				/// add and add another ///
				
				/// add then cancel ///
				
				/// edit ///
				
				/// delete single ///
				
				/// delete multiple ///
				
			} 
			browser.link(backLink).click(); 
			///////////////////////////////////////////////////////////////
			return monitor;
		}else{
			monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
			return monitor;
		} 
	}
	
	
}
