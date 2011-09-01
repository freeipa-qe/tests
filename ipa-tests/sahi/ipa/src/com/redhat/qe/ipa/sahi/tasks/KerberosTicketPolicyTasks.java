package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;


public class KerberosTicketPolicyTasks {
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	
	/*
	 * verify the kerberos ticket policy value 
	 * @param browser - sahi browser instance 
	 * @param textboxName - which text box (field) to be verify
	 * @param expectedValue - what value expected  
	 */
	public static boolean verifyPolicy(SahiTasks browser,String textboxName, String expectedValue){ 
		String currentValue = browser.textbox(textboxName).getText();
		return expectedValue.equals(currentValue); 
	}//verifyPolicy
	
	/*
	 * Modify password field : test  update", this is a wrapper for modifyPolicy_update, this is more like a service provide to other class
	 * @param browser - sahi browser instance 
	 * @param textboxName - which text box (field) to be tested
	 * @param value - what value will it set to 
	 */
	public static void modifyPolicy(SahiTasks browser,String textboxName, String value){
		KerberosTicketPolicyTasks.modifyPolicy_update(browser, textboxName, value);
	}//modifyPolicy
	
	/*
	 * Modify password field : test "undo", "reset" and update"
	 * @param browser - sahi browser instance 
	 * @param textboxName - which text box (field) to be tested
	 * @param value - what value will it set to 
	 */
	public static void modifyPolicy_update(SahiTasks browser, String textboxName, String value){
		browser.textbox(textboxName).setValue(value);
		browser.span("Update").click();
	}//modifyPolicy_update
	
	/*
	 * Modify password field : test "undo", "reset" and update"
	 * @param browser - sahi browser instance 
	 * @param textboxName - which text box (field) to be tested
	 * @param value - what value will it set to 
	 */
	public static void modifyPolicy_undo(SahiTasks browser, String textboxName, String value){
		browser.textbox(textboxName).setValue(value);
		browser.span("undo").click();	
	}//modifyPolicy_undo
	
	/*
	 * Modify password field : test "reset" button, it should discard the changes. 
	 * @param browser - sahi browser instance 
	 * @param textboxName - which text box (field) to be tested
	 * @param value - what value will it set to 
	 */
	public static void modifyPolicy_reset(SahiTasks browser,String textboxName, String value){
		browser.textbox(textboxName).setValue(value);
		browser.span("Reset").click();
	}//modifyPolicy_reset
	 
}// Class: KerberosTicketPolicyTasks

