package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class PasswordPolicyTasks {
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	 
	public static void createUserGroupsForTest(SahiTasks browser, String[] groupNames){ 
		for (int i=0;i<groupNames.length;i++){
			String groupName = groupNames[i];
			String groupDescription = "user group for password policy test :" + groupName;
			GroupTasks.addGroup(browser, groupName, groupDescription);
		}
	}
	
	public static void deleteUserGroupsForTest(SahiTasks browser, String[] groupNames){ 
		for (int i=0;i<groupNames.length;i++){
			String groupName = groupNames[i]; 
			GroupTasks.deleteGroup(browser, groupName); 
			log.info("delete user group [" + groupName + "]");
		}
	}
	
	public static void add_Policy(SahiTasks browser, String policyName, String priority) { 
		browser.span("Add").click();
		browser.textbox("cospriority").setValue(priority);
		browser.textbox("cn").click();
		browser.select("list").choose(policyName); 
		browser.button("Add").click();  
	}
	
	public static void add_and_add_another_Policy(SahiTasks browser, 
													String firstPolicyName,  String firstPolicyPriority, 
													String secondPolicyName, String secondPolicyPriority) { 
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
	}

	public static void add_and_edit_Policy(SahiTasks browser, String policyName, String priority) { 
		browser.span("Add").click();
		browser.textbox("cospriority").setValue(priority);
		browser.textbox("cn").click();
		browser.select("list").choose(policyName); 
		browser.button("Add and Edit").click();
	}

	public static void add_then_cancel_Policy(SahiTasks browser, String policyName, String priority) { 
		browser.span("Add").click();
		browser.textbox("cospriority").setValue(priority);
		browser.textbox("cn").click();
		browser.select("list").choose(policyName); 
		browser.span("Cancel").click();
	}

	public static void delete_Policy(SahiTasks browser, String policyName) { 
		browser.checkbox(policyName).click();
		browser.span("Delete").click();
		browser.button("Delete").click();
	}

	public static void modifyPolicy_undo(SahiTasks browser,String textboxName, String textboxValue){  
		browser.textbox(textboxName).setValue(textboxValue);
		browser.span("undo").click(); 
	}
	
	public static void modifyPolicy_reset(SahiTasks browser,String textboxName, String textboxValue){  
		browser.textbox(textboxName).setValue(textboxValue);
		browser.span("Reset").click();
	}
	
	public static void modifyPolicy_update(SahiTasks browser, String textboxName, String textboxValue){ 
		browser.textbox(textboxName).setValue(textboxValue);
		browser.span("Update").click(); 
	}
	
	public static void modifyPolicy_Negative(SahiTasks browser, String testName, String policyName, 
											 String textboxName, String textboxValue_Negative, 
											 String expectedErrorMsg){
		
		browser.textbox(textboxName).setValue(textboxValue_Negative);
		if (!expectedErrorMsg.equals(""))
		{
			if(browser.span(expectedErrorMsg).exists())
			{
				log.info("error msg field triggered, error msg match as expected, test continue for error dialog box check");
			}
			else 
			{
				browser.span("Update").click();
				Assert.assertTrue(browser.div(expectedErrorMsg).exists(),"error msg field triggered, error msg match as expected, test continue for error dialog box check");
				browser.button("Cancel").click();

			}
			
		}
		
		browser.span("Update").click();
		if(browser.span("Validation error").exists())
		{
			browser.span("OK").click(); 
		}
		else
		{
			browser.button("Cancel").click();
			
		}
		
		
		browser.link("Password Policies").in(browser.div("content")).click();
		Assert.assertTrue(browser.span("Unsaved Changes").near(browser.div("This page has unsaved changes. Please save or revert.")).exists(),
						  "Unsaved dialog appears as expected");
		 
		browser.button("Reset").click(); 
	}//modify_PasswordPolicy_Negative
	
}// Class: PasswordPolicyTasks

