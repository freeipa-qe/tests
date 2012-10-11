package com.redhat.qe.ipa.sahi.tasks;

import com.redhat.qe.auto.testng.Assert;

public class AutomemberTasks {

	public static void automember_AddDuplicate(SahiTasks browser,String groupName) {
		browser.span("Add").click();
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").choose(groupName);
		browser.button("Add and Add Another").click();
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").choose(groupName);
		browser.button("Add").click();
		if (browser.div("error_dialog").exists()){ 
			String errormsg = browser.div("error_dialog").getText(); 
			Assert.assertEquals("auto_member_rule with name \"" + groupName + "\" already exists",errormsg); 
			browser.button("Cancel").click();
			browser.button("Cancel").click();
		}
	}
	
	public static void automember_Delete(SahiTasks browser,String groupName) {
		browser.checkbox(groupName).click();
		browser.span("Delete").click();
		browser.button("Delete").click();
	}
	
	
}
