package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;


public class KerberosTicketPolicyTasks {
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	
	/*
	 * Modify password field : test "undo", "reset" and update"
	 * @param browser - sahi browser instance 
	 * @param testName - test case message
	 * @param fieldName - which field to be tested
	 * @param fieldValue - positive value, used for "update","reset" and "undo" test 
	 */
	public static void modifyDetails(SahiTasks browser, String test_description, String name, String value){
				
		// test for undo
		String originalValue = browser.textbox(name).getText();
		browser.textbox(name).setValue(value);
		browser.span("undo").click();
		if (originalValue.equals(browser.textbox(name).getText())){
			log.info("after 'undo', the original value being restored");
		}else{
			log.info("after 'undo', the original value is NOT being restored, report failure");
			Assert.fail("'undo' failed");
		}
		
		// test for reset
		browser.textbox(name).setValue(value);
		browser.span("Reset").click();
		if (originalValue.equals(browser.textbox(name).getText())){
			log.info("after 'Reset', the original value being restored");
		}else{
			log.info("after 'Reset', the original value is NOT being restored, report failure");
			Assert.fail("'Reset' failed");
		}
		
		// test for update
		browser.textbox(name).setValue(value);
		browser.span("Update").click();
		String after = browser.textbox(name).getText();
		if (originalValue.equals(after)){
			log.info("after 'update', the field value not changed, report failure");
			Assert.fail("'update' failed");
		}else{
			if (after.equals(value)){
				log.info("'Update' test passed, field ["+name+"]'s value changed to ["+value+"] as expected");
			}else{
				Assert.fail("'Reset' failed");
			}
		}
		
	}//modifyKerberosTicketPolicy
	
	/*
	 * Modify password field : test "error field msg", this is negative test
	 * @param browser - sahi browser instance 
	 * @param testName - test case message
	 * @param fieldName - which field to be tested
	 * @param fieldNegValue - negative value, used for "update","reset" and "undo" test 
	 * @param expectedErrorMsg - when wrong data entered, we expect an error field appears and output some error msg
	 */
	public static void modifyDetails_negative(SahiTasks browser, String test_description, String name, String negative_value, String expectedErrorMsg){
 
		// enter negative data to trigger error msg report
		browser.textbox(name).setValue(negative_value);
		
		if (browser.span(expectedErrorMsg).exists()){ 
			log.info("error triggered, error msg match as expected, test pass"); 
		}else{
			Assert.fail("wrong format data entered, but no error msg triggered, report failure");
		}
		
		// click password policy link to trigger "dirty" report
		browser.link("Password Policies").click();
		if (browser.span("ui-dialog-title").near(browser.div("This page has unsaved changes. Please save or revert.")).exists()){
			log.info("Dirty dialog appears as expected, click 'reset' and back to password policy list");
			browser.button("Reset").click();
		}else{
			log.info("Dirty dialog does NOT appear as expected, report failure");
			Assert.fail("no dirty dialog appear");
		}
		 
	}//modifyKerberosTicketPolicyNega

	/*
	 * Modify password field : test "undo", "reset" and update"
	 * @param browser - sahi browser instance  
	 * @param name - which field to be tested
	 * @param value - positive value 
	 */
	public static void setDetails(SahiTasks browser, String name, String value){
				  
		browser.textbox(name).setValue(value);
		browser.span("Update").click(); 
		
	}//setDetails
	
}// Class: KerberosTicketPolicyTasks

