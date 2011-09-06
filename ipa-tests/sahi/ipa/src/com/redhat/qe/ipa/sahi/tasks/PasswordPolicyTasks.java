package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tests.passwordpolicy.PasswordPolicyTests;



public class PasswordPolicyTasks {
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	
	
	public static void createUserGroupsForTest(SahiTasks browser, String[] groupNames){ 
		for (int i=0;i<groupNames.length;i++){
			String groupName = groupNames[i];
			String groupDescription = "user group for password policy test :" + groupName;
			GroupTasks.addGroup(browser, groupName, groupDescription);
		}
	}//prepareTestGroup
	
	public static void deleteUserGroupsForTest(SahiTasks browser, String[] groupNames){ 
		for (int i=0;i<groupNames.length;i++){
			String groupName = groupNames[i]; 
			GroupTasks.deleteGroup(browser, groupName); 
			log.info("delete user group [" + groupName + "]");
		}
	}//prepareTestGroup
	
	/*
	 * Add password policy
	 * @param browser : browser instance
	 * @param policyName : password policy name
	 * @param priority  : password policy priority 
	 */
	public static void add_PasswordPolicy(SahiTasks browser, String policyName, String priority) { 
		browser.span("Add").click();
		browser.textbox("cospriority").setValue(priority);
		browser.textbox("cn").click();
		browser.select("list").choose(policyName); 
		browser.button("Add").click();  

	}//add_PasswordPolicy
	
	/*
	 * Add password policy
	 * @param browser : browser instance
	 * @param policyName : password policy name
	 * @param priority  : password policy priority 
	 */
	public static void add_and_add_another(SahiTasks browser, String firstPolicyName, String firstPolicyPriority, String secondPolicyName, String secondPolicyPriority) { 
		browser.span("Add").click();
		
		// work on first policy
		browser.textbox("cospriority").setValue(firstPolicyPriority);
		browser.textbox("cn").click();
		browser.select("list").choose(firstPolicyName); 
		browser.button("Add and Add Another").click();  

		// now work on adding another
		browser.textbox("cospriority").setValue(secondPolicyPriority);
		browser.textbox("cn").click();
		browser.select("list").choose(secondPolicyName); 
		browser.button("Add and Add Another").click();  
		
		// click away the add dialog box
		browser.button("Cancel").click();
	}//add_and_add_another
	
	/*
	 * Add password policy
	 * @param browser : browser instance
	 * @param policyName : password policy name
	 * @param priority  : password policy priority 
	 */
	public static void add_and_edit(SahiTasks browser, String policyName, String priority) { 
		browser.span("Add").click();
		browser.textbox("cospriority").setValue(priority);
		browser.textbox("cn").click();
		browser.select("list").choose(policyName); 
		browser.button("Add and Edit").click();
	}//add_then_edit
	
	/*
	 * Add password policy : cancel the "add policy" action
	 * @param browser : browser instance
	 * @param policyName : password policy name
	 * @param priority  : password policy priority 
	 */
	public static void add_then_cancel(SahiTasks browser, String policyName, String priority) { 
		browser.span("Add").click();
		browser.textbox("cospriority").setValue(priority);
		browser.textbox("cn").click();
		browser.select("list").choose(policyName); 
		browser.span("Cancel").click();
	}//add_then_cancel
	
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
	public static void modify_PasswordPolicy_Positive(SahiTasks browser, String testName, String policyName, String fieldName, String fieldValue){
				
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
													String expectedErrorMsg){
		// enter negative data to trigger error msg report
		browser.textbox(fieldName).setValue(fieldNegValue);
		
		// check error msg field, only when expectedErrorMsg_field != ""
		if (!expectedErrorMsg.equals("")){
			if (browser.span(expectedErrorMsg).exists()){ 
				log.info("error msg field triggered, error msg match as expected, test continue for error dialog box check"); 
			}else{
				Assert.fail("error msg field expected, but not triggered OR not appear at all, test failed"); 
			}
		}
		
		//  click 'update' to trigger error dialog
		browser.span("Update").click();
		if (browser.span("Validation error").exists()){ 
			log.info("click update link triggers the error dialog as expected"); 
			browser.span("OK").click();
		}else{
			log.info("click update does NOT trigger error dialog as expected, test failed");
			Assert.fail("wrong format data entered, but no error msg triggered, report failure");
		}
		 
		//browser.link("Password Policies").click();
		browser.link("Password Policies").in(browser.div("content")).click();
		if (browser.span("Unsaved Changes").near(browser.div("This page has unsaved changes. Please save or revert.")).exists()){
			log.info("Unsaved dialog appears as expected, click 'reset' and back to password policy list");
			browser.button("Reset").click();
		}else{
			log.info("Unsaved dialog does NOT appear as expected, report failure");
			Assert.fail("no error dialog appear");
		}
		 
	}//modify_PasswordPolicy_Negative
	
}// Class: PasswordPolicyTasks

