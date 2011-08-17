package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class PasswordPolicyTasks {
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	
	/*
	 * Add password policy
	 * @param browser 
	 * @param policyName
	 * @param priority 
	 */
	public static void addPasswordPolicy(SahiTasks browser, String policyName, String priority) {
//		browser.span("Add[2]").click();
//		browser.span("icon combobox-icon").click();
//		browser.select("list").choose("editors");
//		browser.textbox("cospriority").setValue("5");
//		browser.button("Add").click();
//		browser.checkbox("select[5]").click();
//		browser.span("Delete[2]").click();
//		browser.button("Delete").click();
		
		browser.span("Add").click();
		browser.textbox("cospriority").setValue(priority);
		
		browser.textbox("cn").click();
		browser.select("list").choose(policyName); 
		browser.button("Add").click();  
		// self-check
		Assert.assertTrue(browser.link(policyName).exists(),"new policy ["+policyName + "] added");
	}//addPasswordPolicy
	
	/*
	 * Delete password policy
	 * @param browser - sahi browser instance 
	 * @param zoneName - dns zone name (to be deleted) 
	 */
	public static void delPasswordPolicy(SahiTasks browser, String policyName) { 
		browser.checkbox(policyName).click();
		browser.span("Delete").click();
		browser.button("Delete").click(); 
		// self-check
		Assert.assertFalse(browser.link(policyName).exists(),"policy ["+policyName+"] deleted"); 
	}//delPasswordPolicy
	
	/*
	 * Modify password field : test "undo", "error field msg", "reset" and update"
	 * @param browser - sahi browser instance 
	 * @param testName - test case message
	 * @param policyName - password policy name
	 * @param fieldName - which field to be tested
	 * @param fieldValue - positive value, used for "update","reset" and "undo" test 
	 */
	public static void modifyPasswordPolicy(SahiTasks browser, String testName, String policyName, String fieldName, String fieldValue){
				
		// test for undo
		String originalValue = browser.textbox(fieldName).getText();
		browser.textbox(fieldName).setValue(fieldValue);
		browser.span("undo").click();
		if (originalValue.equals(browser.textbox(fieldName).getText())){
			log.info("after 'undo', the original value being restored");
		}else{
			log.info("after 'undo', the original value is NOT being restored, report failure");
			Assert.fail("'undo' failed");
		}
		
		// test for reset
		browser.textbox(fieldName).setValue(fieldValue);
		browser.span("Reset").click();
		if (originalValue.equals(browser.textbox(fieldName).getText())){
			log.info("after 'Reset', the original value being restored");
		}else{
			log.info("after 'Reset', the original value is NOT being restored, report failure");
			Assert.fail("'Reset' failed");
		}
		
		// test for update
		browser.textbox(fieldName).setValue(fieldValue);
		browser.span("Update").click();
		String after = browser.textbox(fieldName).getText();
		if (originalValue.equals(after)){
			log.info("after 'update', the field value not changed, report failure");
			Assert.fail("'update' failed");
		}else{
			if (after.equals(fieldValue)){
				log.info("'Update' test passed, field ["+fieldName+"]'s value changed to ["+fieldValue+"] as expected");
			}else{
				Assert.fail("'Reset' failed");
			}
		}
		
	}//modifyPasswordPolicy
	
	/*
	 * Modify password field : test "error field msg", this is negative test
	 * @param browser - sahi browser instance 
	 * @param testName - test case message
	 * @param policyName - password policy name
	 * @param fieldName - which field to be tested
	 * @param fieldNegValue - negative value, used for "update","reset" and "undo" test 
	 * @param expectedErrorMsg - when wrong data entered, we expect an error field appears and output some error msg
	 */
	public static void modifyPasswordPolicyNegative(SahiTasks browser, String testName, String policyName, 
													String fieldName, String fieldNegValue, String expectedErrorMsg){
 
		// enter negative data to trigger error msg report
		String originalValue = browser.textbox(fieldName).getText();
		browser.textbox(fieldName).setValue(fieldNegValue);
		
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
		 
	}//modifyPasswordPolicyNegative
	
}// Class: PasswordPolicyTasks

