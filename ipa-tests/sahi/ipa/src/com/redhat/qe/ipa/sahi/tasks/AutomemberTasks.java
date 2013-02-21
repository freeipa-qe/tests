package com.redhat.qe.ipa.sahi.tasks;

import com.redhat.qe.auto.testng.Assert;

public class AutomemberTasks {
	public static void automember_AddSingle(SahiTasks browser,String groupName) {
		browser.span("Add").click();
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").choose(groupName);
		browser.button("Add").click();
	
	}
	public static void automember_AddAndAddAnother(SahiTasks browser,String groupName1,String groupName2) {
		browser.span("Add").click();
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").choose(groupName1);
		browser.button("Add and Add Another").click();
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").choose(groupName2);
		browser.button("Add").click();
	}
	public static void automember_AddAndEdit(SahiTasks browser,String groupName) {
		browser.span("Add").click();
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").choose(groupName);
		browser.button("Add and Edit").click();
		browser.textarea("description").setValue("verify get into edit mode");
		browser.span("Update").click();
	}
	public static void automember_AddThenCancel(SahiTasks browser,String groupName) {
		browser.span("Add").click();
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").choose(groupName);
		browser.button("Cancel").click();
	}
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
	
	public static void automember_AddNegativeRequiredField(SahiTasks browser) {
		browser.span("Add").click();
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").choose("");
		browser.button("Add").click();
	}
	public static void automember_ConditionAddSingle(SahiTasks browser,String testName,String attribute,String expression) {
		if (testName == "Inclusive"){
			browser.span("Add").near(browser.heading2("Inclusive")).click();
			browser.select("key").choose(attribute);
			browser.textbox("automemberinclusiveregex").setValue(expression);
			browser.button("Add").click();
		}else{
			browser.span("Add").near(browser.heading2("Exclusive")).click();
			browser.select("key").choose(attribute);
			browser.textbox("automemberexclusiveregex").setValue(expression);
			browser.button("Add").click();
		}
	}
	public static void automember_ConditionAddAndAddAnother(SahiTasks browser,String testName,String attribute1,String attribute2,String expression1,String expression2) {
		if (testName == "Inclusive"){
			browser.span("Add").near(browser.heading2("Inclusive")).click();
			browser.select("key").choose(attribute1);
			browser.textbox("automemberinclusiveregex").setValue(expression1);
			browser.button("Add and Add Another").click();
			browser.select("key").choose(attribute2);
			browser.textbox("automemberinclusiveregex").setValue(expression2);
			browser.button("Add").click();
		}else{
			browser.span("Add").near(browser.heading2("Exclusive")).click();
			browser.select("key").choose(attribute1);
			browser.textbox("automemberexclusiveregex").setValue(expression1);
			browser.button("Add and Add Another").click();
			browser.select("key").choose(attribute2);
			browser.textbox("automemberexclusiveregex").setValue(expression2);
			browser.button("Add").click();
		}
	}
	public static void automember_ConditionAddThenCancel(SahiTasks browser,String testName,String attribute,String expression) {
		if (testName == "Inclusive"){
			browser.span("Add").near(browser.heading2("Inclusive")).click();
			browser.select("key").choose(attribute);
			browser.textbox("automemberinclusiveregex").setValue(expression);
			browser.button("Cancel").click();
		}else{
			browser.span("Add").near(browser.heading2("Exclusive")).click();
			browser.select("key").choose(attribute);
			browser.textbox("automemberexclusiveregex").setValue(expression);
			browser.button("Cancel").click();
		}
		
	}
	public static void automember_ConditionDeleteSingle(SahiTasks browser,String testName,String attribute,String expression) {
		String 	checkboxName = attribute + "=" + expression ;
		if (testName == "Inclusive"){
			browser.checkbox(checkboxName).click();
			browser.span("Delete").near(browser.heading2("Inclusive")).click(); 
			browser.button("Delete").click();
		}else{
			browser.checkbox(checkboxName).click();
			browser.span("Delete").near(browser.heading2("Exclusive")).click(); 
			browser.button("Delete").click();
		}
	}
	public static void automember_ConditionDeleteMultiple(SahiTasks browser,String testName,String attribute1,String attribute2,String expression1,String expression2) {
		String 	checkboxName1 = attribute1 + "=" + expression1;
		String 	checkboxName2 = attribute2 + "=" + expression2; 
		String checkboxNames[] ={checkboxName1,checkboxName2};
		for (String checkboxName:checkboxNames) {
			browser.checkbox(checkboxName).click();
		}
		if (testName == "Inclusive"){
			browser.span("Delete").near(browser.heading2("Inclusive")).click(); 
			browser.button("Delete").click();
		}else{
			browser.span("Delete").near(browser.heading2("Exclusive")).click(); 
			browser.button("Delete").click();
		}
	}
			
	public static void automember_DefaultGroup(SahiTasks browser,String groupName) {
		browser.span("icon combobox-icon").click();
		browser.span("icon search-icon[1]").click();
		browser.select("list").choose(groupName);
		Assert.assertEquals(browser.textbox("automemberdefaultgroup").getValue(),groupName);
		browser.span("icon combobox-icon").click();
		browser.span("icon search-icon[1]").click();
		browser.select("list").choose("");
	}
	
	public static void automember_GenericEdit(SahiTasks browser,String testName,String groupName) {
		String editModeVerifyString = "Verify In editing mode 28dkrj3290mjz.IR4AGKJ";
		String unsavedChangesString = "This page has unsaved changes. Please save or revert.";
		//test undo, refresh,reset and update, edit description included
		String originalValue = browser.textarea("description").getValue();
		browser.textarea("description").setValue(editModeVerifyString);
		Assert.assertTrue(browser.span("undo").exists(),"undo button shows up when editing description");
		browser.span("undo").click();
		Assert.assertEquals(browser.textarea("description").getValue(),originalValue);
		browser.textarea("description").setValue(editModeVerifyString);
		browser.span("Refresh").click();
		Assert.assertEquals(browser.textarea("description").getValue(),originalValue);
		browser.textarea("description").setValue(editModeVerifyString);
		browser.span("Reset").click();
		Assert.assertEquals(browser.textarea("description").getValue(),originalValue);
		browser.textarea("description").setValue(editModeVerifyString);
		browser.span("Update").click();
		Assert.assertEquals(browser.textarea("description").getValue(),editModeVerifyString);
		//test update, reset and cancel when modify and click backlink.
		browser.textarea("description").setValue(unsavedChangesString);
		//testName is either "User group rules" or "Host group rules"
		browser.link(testName).in(browser.div("content")).click();
		Assert.assertTrue(browser.div(unsavedChangesString).exists(),"Unsaved changes prompt came out as expected");
		browser.button("Update").click();
		browser.link(groupName).click();
		Assert.assertEquals(browser.textarea("description").getValue(),unsavedChangesString);
		browser.textarea("description").setValue(editModeVerifyString);
		browser.link(testName).in(browser.div("content")).click();
		Assert.assertTrue(browser.div(unsavedChangesString).exists(),"Unsaved changes prompt came out as expected");
		browser.button("Reset").click();
		browser.link(groupName).click();
		Assert.assertEquals(browser.textarea("description").getValue(),unsavedChangesString);
		browser.textarea("description").setValue(editModeVerifyString);
		browser.link(testName).in(browser.div("content")).click();
		Assert.assertTrue(browser.div(unsavedChangesString).exists(),"Unsaved changes prompt came out as expected");
		browser.button("Cancel").click();
		browser.span("Update").click();
		//collapse expand
		browser.span("Collapse All").click();
		browser.waitFor(1000);
		//Verify no data is visible
		Assert.assertFalse(browser.label("Description:").exists(), "Collapse as expected");
		browser.span("Expand All").click();
		browser.waitFor(1000);
		//Verify data is visible
		Assert.assertTrue(browser.label("Description:").exists(), "Expand as expected");
		browser.link(testName).in(browser.div("content")).click();
	}

	public static void automember_DeleteSingle(SahiTasks browser,String groupName) {
		browser.checkbox(groupName).click();
		browser.span("Delete").click();
		browser.button("Delete").click();
	}
	
	public static void automember_DeleteMultiple(SahiTasks browser,String groupNames[]) {
		for (String groupName:groupNames) {
			browser.checkbox(groupName).click();
		}
		browser.span("Delete").click();
		browser.button("Delete").click();
	}

	
}
