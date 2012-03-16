package com.redhat.qe.ipa.sahi.pages;

import java.util.*;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class IdentityPageDNS extends IPAWebPage{
//FIXME: Need work here. leave this one the last to do
	private static Logger log = Logger.getLogger(IdentityPageDNS.class.getName());
	private static String url = CommonTasks.dnsPage; 
	
	public IdentityPageDNS (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile); 
		duplicateErrorMsgStartsWith = "service with name";
		backLink = "DNS Zones";
		addPage = "Add DNS";
		duplicatePage = "Add Duplicate DNS";
		modifyPage = "Modify DNS";
		delPage = "Delete DNS";

		registerStandardTestCases();
		System.out.println("New instance of " + IdentityPageDNS.class.getName() +" is ready"); 
	}
}
