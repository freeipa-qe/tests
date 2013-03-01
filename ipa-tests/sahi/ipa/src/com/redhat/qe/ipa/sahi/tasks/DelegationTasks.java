package com.redhat.qe.ipa.sahi.tasks;

import com.redhat.qe.auto.testng.Assert;

public class DelegationTasks {
	public static void delegation_AddSingle(SahiTasks browser,String delegationName, String groupName,String memberGroup,String attribute) {
		browser.span("Add").click();
		browser.textbox("aciname").setValue(delegationName);
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose(groupName);
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose(memberGroup);
		browser.checkbox(attribute).click();
		browser.button("Add").click();
	
	}
	public static void delegation_AddAndAddAnother(SahiTasks browser,String delegationName1,String permissionType1,String groupName1,String memberGroup1,String attribute1,String delegationName2,String permissionType2,String groupName2,String memberGroup2,String attribute2) {
		browser.span("Add").click();
		browser.textbox("aciname").setValue(delegationName1);
		browser.checkbox(permissionType1).click();
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose(groupName1);
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose(memberGroup1);
		browser.checkbox(attribute1).click();
		browser.button("Add and Add Another").click();
		browser.textbox("aciname").setValue(delegationName2);
		browser.checkbox(permissionType2).click();
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose(groupName2);
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose(memberGroup2);
		browser.checkbox(attribute2).click();
		browser.button("Add").click();
	}
	public static void delegation_AddAndEdit(SahiTasks browser,String delegationName,String permissionType1,String permissionType2,String groupName,String memberGroup,String attribute1,String attribute2) {
		browser.span("Add").click();
		browser.textbox("aciname").setValue(delegationName);
		browser.checkbox(permissionType1).click();
		browser.checkbox(permissionType2).click();
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose(groupName);
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose(memberGroup);
		browser.checkbox(attribute1).click();
		browser.checkbox(attribute2).click();
		browser.button("Add and Edit").click();
		Assert.assertTrue(browser.checkbox(permissionType1).checked(),permissionType1 + " checked as expected");
		Assert.assertTrue(browser.checkbox(permissionType2).checked(),permissionType2 + " checked as expected");
		Assert.assertEquals(browser.textbox("group").getValue(),groupName);
		Assert.assertEquals(browser.textbox("memberof").getValue(),memberGroup);
		Assert.assertTrue(browser.checkbox(attribute1).checked(),attribute1 + " checked as expected");
		Assert.assertTrue(browser.checkbox(attribute2).checked(),attribute2 + " checked as expected");
	}
	
	public static void delegation_AddThenCancel(SahiTasks browser,String delegationName,String permissionType, String groupName,String memberGroup,String attribute) {
		browser.span("Add").click();
		browser.textbox("aciname").setValue(delegationName);
		browser.checkbox(permissionType).click();
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose(groupName);
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose(memberGroup);
		browser.checkbox(attribute).click();
		browser.button("Cancel").click();
	}
	
	public static void delegation_AddLong(SahiTasks browser,String delegationName,String permissionType, String groupName,String memberGroup,String attribute) {
		browser.span("Add").click();
		browser.textbox("aciname").setValue(delegationName);
		browser.checkbox(permissionType).click();
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose(groupName);
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose(memberGroup);
		browser.checkbox(attribute).click();
		browser.button("Add").click();
	}
	
	public static void delegation_AddNegativeRequiredField(SahiTasks browser) {
		browser.span("Add").click();
		browser.button("Add").click();
	}
	
	public static void delegation_AddNegativeName(SahiTasks browser,String delegationName,String permissionType, String groupName,String memberGroup,String attribute) {
		browser.span("Add").click();
		browser.textbox("aciname").setValue(delegationName);
		browser.checkbox(permissionType).click();
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose(groupName);
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose(memberGroup);
		browser.checkbox(attribute).click();
		browser.button("Add").click();
	}
	
	public static void delegation_AddDuplicate(SahiTasks browser,String delegationName,String permissionType, String groupName,String memberGroup,String attribute) {
		browser.span("Add").click();
		browser.textbox("aciname").setValue(delegationName);
		browser.checkbox(permissionType).click();
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose(groupName);
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose(memberGroup);
		browser.checkbox(attribute).click();
		browser.button("Add and Add Another").click();
		browser.textbox("aciname").setValue(delegationName);
		browser.checkbox(permissionType).click();
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose(groupName);
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose(memberGroup);
		browser.checkbox(attribute).click();
		browser.button("Add").click();
		if (browser.div("error_dialog").exists()){ 
			String errormsg = browser.div("error_dialog").getText(); 
			Assert.assertEquals("This entry already exists",errormsg); 
			browser.button("Cancel").click();
			browser.button("Cancel").click();
		}
	}
	
	public static void delegation_GenericEdit(SahiTasks browser,String delegationName,String permissionType, String groupName,String memberGroup,String attribute) {
		String unsavedChangesString = "This page has unsaved changes. Please save or revert.";
		//verify delegation name
		Assert.assertTrue(browser.label(delegationName).exists());
		//verify permission is "write" as default 
		Assert.assertTrue(browser.checkbox("write").checked(),"verify permission is write as default");
		//verify usergroup and member user group name
		Assert.assertEquals(browser.textbox("group").getValue(),groupName);
		Assert.assertEquals(browser.textbox("memberof").getValue(),memberGroup);
		//verify attributes
		Assert.assertTrue(browser.checkbox(attribute).checked());
		//test undo, refresh,reset and update
		browser.checkbox("read").click();
		Assert.assertTrue(browser.span("undo").exists(),"undo button shows up when making changes");
		browser.span("undo").click();
		Assert.assertFalse(browser.checkbox("read").checked());
		browser.checkbox("read").click();
		browser.span("Refresh").click();
		Assert.assertFalse(browser.checkbox("read").checked());
		browser.checkbox("read").click();
		browser.span("Reset").click();
		Assert.assertFalse(browser.checkbox("read").checked());
		browser.checkbox("read").click();
		browser.span("Update").click();
		Assert.assertTrue(browser.checkbox("read").checked());
		//test update, reset and cancel when modify and click backlink 
		browser.checkbox("read").click();
		browser.link("Delegations").in(browser.div("content")).click();
		Assert.assertTrue(browser.div(unsavedChangesString).exists(),"Unsaved changes prompt came out as expected");
		browser.button("Update").click();
		browser.link(delegationName).click();
		Assert.assertFalse(browser.checkbox("read").checked());
		browser.checkbox("read").click();
		browser.link("Delegations").in(browser.div("content")).click();
		Assert.assertTrue(browser.div(unsavedChangesString).exists(),"Unsaved changes prompt came out as expected");
		browser.button("Reset").click();
		browser.link(delegationName).click();
		Assert.assertFalse(browser.checkbox("read").checked());
		browser.checkbox("read").click();
		browser.link("Delegations").in(browser.div("content")).click();
		Assert.assertTrue(browser.div(unsavedChangesString).exists(),"Unsaved changes prompt came out as expected");
		browser.button("Cancel").click();
		Assert.assertTrue(browser.checkbox("read").checked());
		browser.span("Reset").click();
		//test required field show up when uncheck all permissions
		Assert.assertFalse(browser.checkbox("read").checked());
		Assert.assertTrue(browser.checkbox("write").checked());
		browser.checkbox("write").click();
		browser.span("Update").click();
		Assert.assertTrue(browser.div("validation_error").exists(),"Validation error prompt came out as expected"); 
		String errormsg = browser.div("validation_error").getText(); 
		Assert.assertEquals("Input form contains invalid or missing values.",errormsg); 
		browser.button("OK").click();
		browser.checkbox("write").click();
		//test required field show up when setting user group/member user group into blank
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose("");
		browser.span("Update").click();
		Assert.assertTrue(browser.div("validation_error").exists(),"Validation error prompt came out as expected"); 
		String errormsg2 = browser.div("validation_error").getText(); 
		Assert.assertEquals("Input form contains invalid or missing values.",errormsg2);
		browser.button("OK").click();
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose(groupName);
		browser.span("Update").click();
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose("");
		browser.span("Update").click();
		Assert.assertTrue(browser.div("validation_error").exists(),"Validation error prompt came out as expected"); 
		String errormsg3 = browser.div("validation_error").getText(); 
		Assert.assertEquals("Input form contains invalid or missing values.",errormsg3);
		browser.button("OK").click();
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose(memberGroup);
		browser.span("Update").click();
		//collapse expand
		browser.span("Collapse All").click();
		browser.waitFor(1000);
		//Verify no data is visible
		Assert.assertFalse(browser.label("Delegation name:").exists(), "Collapse as expected");
		browser.span("Expand All").click();
		browser.waitFor(1000);
		//Verify data is visible
		Assert.assertTrue(browser.label("Delegation name:").exists(), "Expand as expected");
		browser.link("Delegations").in(browser.div("content")).click();
	}
	
	public static void delegation_EditUserinfoWithNoDelegation(SahiTasks browser,String userToBeEdited ) {
		browser.link(userToBeEdited).click();
		//unable to apply disable and delete option
		browser.select("action").choose("Disable");
		browser.span("Apply").click();
		Assert.assertTrue(browser.div("error_dialog").exists(),"Error dialog prompt came out as expected"); 
		browser.button("Cancel").click();
		browser.select("action").choose("Delete");
		browser.span("Apply").click();
		Assert.assertTrue(browser.div("error_dialog").exists(),"Error dialog prompt came out as expected"); 
		browser.button("Cancel").click();
		browser.select("action").choose("-- select action --");
	    Assert.assertFalse(browser.textbox("title").exists(),"unable to edit job title attribute as expected");
	    Assert.assertFalse(browser.textbox("givenname").exists(),"unable to edit given name attribute as expected");
	    Assert.assertFalse(browser.textbox("cn").exists(),"unable to edit full name attribute as expected");
	    Assert.assertFalse(browser.textbox("displayname").exists(),"unable to edit display name attribute as expected");
	    Assert.assertFalse(browser.textbox("initials").exists(),"unable to edit initials attribute as expected");
	    Assert.assertFalse(browser.textbox("loginshell").exists(),"unable to edit login shell attribute as expected");
	    Assert.assertFalse(browser.link("Add").near(browser.label("SSH public keys:")).exists(),"unable to edit ssh public keys attribute as expected");
	    browser.link("Reset Password").click();
	    Assert.assertFalse(browser.button("Reset Password").exists(),"unable to reset password as expected");
	    browser.link("Delete").near(browser.label("Email address:")).click();
	    browser.span("Update").click();
	    Assert.assertTrue(browser.div("error_dialog").exists(),"Error dialog prompt came out as expected"); 
		browser.button("Cancel").click();
		browser.span("undo all").near(browser.label("Email address:")).click();
		Assert.assertFalse(browser.link("Add").near(browser.label("Telephone Number:")).exists(),"unable to edit telephone number attribute as expected");
		Assert.assertFalse(browser.link("Add").near(browser.label("Pager Number:")).exists(),"unable to edit pager number attribute as expected");
		Assert.assertFalse(browser.link("Add").near(browser.label("Mobile Telephone Number:")).exists(),"unable to edit mobile telephone number attribute as expected");
		Assert.assertFalse(browser.link("Add").near(browser.label("Fax Number:")).exists(),"unable to edit fax number attribute as expected");
		Assert.assertFalse(browser.textbox("street").exists(),"unable to edit street addr. attribute as expected");
		Assert.assertFalse(browser.textbox("l").exists(),"unable to edit city attribute as expected");
		Assert.assertFalse(browser.textbox("st").exists(),"unable to edit state attribute as expected");
		Assert.assertFalse(browser.textbox("postalcode").exists(),"unable to edit zip code attribute as expected");
		Assert.assertFalse(browser.textbox("ou").exists(),"unable to edit org. unit attribute as expected");
		Assert.assertFalse(browser.textbox("manager").exists(),"unable to edit manager attribute as expected");
		Assert.assertFalse(browser.textbox("carlicense").exists(),"unable to edit carlicense attribute as expected");
		browser.link("Users").in(browser.div("content")).click();
		
	}

	public static void delegation_EditUserinfoWithDelegation(SahiTasks browser,String delegationName,String permissionType, String groupName,String memberGroup,String attribute1,String attribute2,String delegatedUser,String userToBeEdited1,String userToBeEdited2,String displayNameToUpdate,String emailToUpdate) {
	    //Add delegation rule with displayname and email attributes,then verify only these two are changed and can be updated
		browser.span("Add").click();
		browser.textbox("aciname").setValue(delegationName);
		browser.span("icon combobox-icon").click();
		browser.select("list").near(browser.label("User group:")).choose(groupName);
		browser.span("icon combobox-icon[1]").click();
		browser.select("list").near(browser.label("Member user group:")).choose(memberGroup);
		browser.checkbox(attribute1).click();
		browser.checkbox(attribute2).click();
		browser.button("Add").click();
		CommonTasks.formauth(browser, delegatedUser, "Secret123");
		browser.link("Users").in(browser.div("content")).click();
		browser.link(userToBeEdited1).click();
		//unable to apply disable and delete option
		browser.select("action").choose("Disable");
		browser.span("Apply").click();
		Assert.assertTrue(browser.div("error_dialog").exists(),"Error dialog prompt came out as expected"); 
		browser.button("Cancel").click();
		browser.select("action").choose("Delete");
		browser.span("Apply").click();
		Assert.assertTrue(browser.div("error_dialog").exists(),"Error dialog prompt came out as expected"); 
		browser.button("Cancel").click();
		browser.select("action").choose("-- select action --");
		Assert.assertTrue(browser.textbox("displayname").exists(),"delegation with display name attribute added successfully");
		browser.textbox("displayname").setValue(displayNameToUpdate);
		browser.span("Update").click();
		Assert.assertEquals(browser.textbox("displayname").getValue(),displayNameToUpdate);
		Assert.assertTrue(browser.textbox("mail-0").exists(),"delegation with email attribute added successfully");
		browser.textbox("mail-0").setValue(emailToUpdate);
		browser.span("Update").click();
		Assert.assertEquals(browser.textbox("mail-0").getValue(),emailToUpdate);
		browser.link("Users").in(browser.div("content")).click();
		//verify that user outside delegation member group can not be edited
		DelegationTasks.delegation_EditUserinfoWithNoDelegation(browser,userToBeEdited2);
	}
	
	
	public static void delegation_DeleteSingle(SahiTasks browser,String groupName) {
		browser.checkbox(groupName).click();
		browser.span("Delete").click();
		browser.button("Delete").click();
	}
	
	public static void delegation_DeleteMultiple(SahiTasks browser,String groupNames[]) {
		for (String groupName:groupNames) {
			browser.checkbox(groupName).click();
		}
		browser.span("Delete").click();
		browser.button("Delete").click();
	}

	
}
