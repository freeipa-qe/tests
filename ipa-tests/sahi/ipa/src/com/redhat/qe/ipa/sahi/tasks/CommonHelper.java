package com.redhat.qe.ipa.sahi.tasks;

import com.redhat.qe.ipa.sahi.tasks.*;

public class CommonHelper {

	public static void addNetGroup(SahiTasks browser, String netGroupName, String netGroupDescription)
	{  
		genericAdd(browser, netGroupName, netGroupDescription);
	}

	public static void deleteNetGroup(SahiTasks browser, String netGroupName) { 
		genericDelete(browser, netGroupName);
	}
	
	public static void deleteNetGroup(SahiTasks browser, String[] netGroupNames) { 
		genericDelete(browser, netGroupNames);
	}
	
	public static void addHBACrule(SahiTasks browser, String ruleName)
	{
		genericAdd(browser, ruleName);
	}
	
	public static void addHBACrule(SahiTasks browser, String[] ruleNames)
	{
		genericAdd(browser, ruleNames);
	}
	
	public static void deleteHBACrules(SahiTasks browser, String[] ruleNames)
	{
		genericDelete(browser, ruleNames);
	}
		
	public static void addSUDOrule(SahiTasks browser, String ruleName)
	{
		genericAdd(browser, ruleName);
	}
	
	public static void addSUDOrule(SahiTasks browser, String[] ruleNames)
	{
		genericAdd(browser, ruleNames);
	}
	
	public static void deleteSUDOrules(SahiTasks browser, String[] ruleNames)
	{
		genericDelete(browser, ruleNames);
	}
	
	/////////////////////////// generic function ///////////////////////////////
	private static void genericAdd(SahiTasks browser, String cnValue)
	{
		browser.span("Add").click();
		browser.textbox("cn").setValue(cnValue); 
		browser.button("Add").click();
	}
	
	private static void genericAdd(SahiTasks browser, String[] cnValues)
	{
		browser.span("Add").click();
		for(String cn:cnValues)
		{
			browser.textbox("cn").setValue(cn); 
			browser.button("Add and Add Another").click();
		}
		browser.button("Cancel").click();
	}
	
	private static void genericAdd(SahiTasks browser, String cnValue, String descValue)
	{
		browser.span("Add").click();
		browser.textbox("cn").setValue(cnValue);
		browser.textarea("description").setValue(descValue);
		browser.button("Add").click();
	}
	
	private static void genericDelete(SahiTasks browser, String cnValue)
	{
		browser.checkbox(cnValue).click(); 
		browser.span("Delete").click(); 
		browser.button("Delete").click();
	}
	
	private static void genericDelete(SahiTasks browser, String[] cnValues)
	{
		for (String cn: cnValues) 
			browser.checkbox(cn).click(); 
		browser.span("Delete").click(); 
		browser.button("Delete").click();
	}
	
}
