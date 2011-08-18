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
	public static void add_PasswordPolicy(SahiTasks browser, String policyName, String priority) {
		// blokced here, 
		browser.span("Add").click();
		browser.textbox("cospriority").setValue(priority);
		
		browser.textbox("cn").click();
		browser.select("list").choose(policyName); 
		browser.button("Add").click();  
		// self-check
		Assert.assertTrue(browser.link(policyName).exists(),"new policy ["+policyName + "] added");
	}//add_PasswordPolicy
	//FIXME: I need extend addPasswordPolicy to "add_and_add_other, add_and_edit, add_then_cancel"
	
	/*
	 * Delete password policy
	 * @param browser - sahi browser instance 
	 * @param policyName - password policy to be deleted 
	 */
	public static void delete_PasswordPolicy(SahiTasks browser, String policyName) { 
		browser.checkbox(policyName).click();
		browser.span("Delete").click();
		browser.button("Delete").click(); 
		// self-check
		Assert.assertFalse(browser.link(policyName).exists(),"policy ["+policyName+"] deleted"); 
	}//delete_PasswordPolicy
	
	/*
	 * Modify password field : test "undo", "error field msg", "reset" and update"
	 * @param browser - sahi browser instance 
	 * @param testName - test case message
	 * @param policyName - password policy name
	 * @param fieldName - which field to be tested
	 * @param fieldValue - positive value, used for "update","reset" and "undo" test 
	 */
	public static void modify_PasswordPolicy(SahiTasks browser, String testName, String policyName, String fieldName, String fieldValue){
				
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
		
	}//modify_PasswordPolicy
	
	/*
	 * Modify password field : test "error field msg", this is negative test
	 * @param browser - sahi browser instance 
	 * @param testName - test case message
	 * @param policyName - password policy name
	 * @param fieldName - which field to be tested
	 * @param fieldNegValue - negative value, used for "update","reset" and "undo" test 
	 * @param expectedErrorMsg - when wrong data entered, we expect an error field appears and output some error msg
	 */
	public static void modify_PasswordPolicy_Negative(SahiTasks browser, String testName, String policyName, 
													String fieldName, String fieldNegValue, 
													String expectedErrorMsg_field, String expectedErrorMsg_dialog){
 //FIXME: NEED somem major work here
		// enter negative data to trigger error msg report
		browser.textbox(fieldName).setValue(fieldNegValue);
		
		// check error msg field, only when expectedErrorMsg_field != ""
		if (!expectedErrorMsg_field.equals("")){
			if (browser.span(expectedErrorMsg_field).exists()){ 
				log.info("error msg field triggered, error msg match as expected, test continue for error dialog box check"); 
			}else{
				Assert.fail("error msg field expected, but not triggered OR not appear at all, test failed"); 
			}
		}
		
		//  click 'update' to trigger error dialog
		browser.span("Update").click();
		if (browser.div("error_dialog").exists()){
			// if dialog appears, we will continue check the error msg
			String errmsg_dialog = browser.div("error_dialog").getText();
			if (errmsg_dialog.equals(expectedErrorMsg_dialog)){
				log.info("update trigger the error dialog as expected, the error msg match as expected, test pass");
			}else{
				log.info("update trigger the error dialog as expected, but the error msg does NOT match, test failed");
				log.info("expected error msg:["+ expectedErrorMsg_dialog +"]");
				log.info("actual   error msg:["+errmsg_dialog+"]");
				Assert.fail("mis-match error msg, test failed");
			}
			// as long as the error dialog appears, we need click it away after checking error msg
			browser.button("Cancel").click();
		}else{
			log.info("click update does NOT trigger error dialog as expected, test failed");
			Assert.fail("wrong format data entered, but no error msg triggered, report failure");
		}//inner if-else 
		
		// click password policy link to trigger "dirty" report
		browser.span("Password Policies").click();
		if (browser.span("ui-dialog-title").near(browser.div("This page has unsaved changes. Please save or revert.")).exists()){
			log.info("Dirty dialog appears as expected, click 'reset' and back to password policy list");
			browser.button("Reset").click();
		}else{
			log.info("Dirty dialog does NOT appear as expected, report failure");
			Assert.fail("no dirty dialog appear");
		}
		 
	}//modify_PasswordPolicy_Negative
	
}// Class: PasswordPolicyTasks

