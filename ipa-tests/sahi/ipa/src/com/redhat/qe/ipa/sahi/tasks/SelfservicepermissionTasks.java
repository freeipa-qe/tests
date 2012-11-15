package com.redhat.qe.ipa.sahi.tasks;

import org.testng.Assert;

public class SelfservicepermissionTasks {

	public static void addSelfservicePermission(SahiTasks browser, String permissionName, String[] attrs) {
		browser.span("Add").click();
		browser.textbox("aciname").setValue(permissionName);
		for (String attribute:attrs)
			browser.checkbox(attribute).check();
		browser.button("Add").click();

	}

	public static void addSelfservicePermissionAddAndAddAnother(SahiTasks browser, String[] names, String[] attrs)
	{
		browser.span("Add").click();
		for (int i=0; i< names.length ; i++)
		{
			String name = names[i];
			String attribute = attrs[i];
			browser.textbox("aciname").setValue(name);
			browser.checkbox(attribute).check();
			browser.button("Add and Add Another").click();
		}
		browser.button("Cancel").click();
	}

	public static void addSelfservicePermissionAddThenEdit(SahiTasks browser, String name, String[] attrs)
	{
		browser.span("Add").click();
		browser.textbox("aciname").setValue(name);
		for (String attr:attrs)
			browser.checkbox(attr).check();

		browser.button("Add and Edit").click();
	}

	public static void addSelfservicePermissionAddThenCancel(SahiTasks browser, String name, String[] attrs)
	{
		browser.span("Add").click();
		browser.textbox("aciname").setValue(name);
		for (String attr:attrs)
			browser.checkbox(attr).check();
		browser.button("Cancel").click();
	}
	
	public static void deletePermission(SahiTasks browser, String permissionNames[]) {
		CommonHelper.deleteEntry(browser, permissionNames);
	}

	public static void deletePermission(SahiTasks browser, String permissionName) {
		CommonHelper.deleteEntry(browser, permissionName);
	}

	public static void resetSSHKeyPermission(SahiTasks browser, String permission,	String attribute1, String attribute2) {
		if(browser.link(permission).exists()){
			browser.link(permission).click();
		}
		browser.checkbox(attribute1).check();
		browser.checkbox(attribute2).uncheck();
		browser.span("Update").click();
		
		
	}

	public static void deleteSSHKey(SahiTasks browser, String errorMsg) {
		browser.link("Delete").click();
		browser.span("Update").click();
	}

	public static void revertSSHKeyPermission(SahiTasks browser, String permission, String attribute1, String attribute2) {
		
		if(browser.link(permission).exists()){
			browser.link(permission).click();
		}
		browser.checkbox(attribute1).uncheck();
		browser.checkbox(attribute2).check();
		browser.span("Update").click();
	}
	public static void settingExpandCollapse(SahiTasks browser) {
		
		browser.span("Collapse All").click();
		browser.waitFor(1000);
		Assert.assertFalse(browser.label("Self-service name:").isVisible(),"No self-service Name is visible");
		browser.span("Expand All").click();
		browser.waitFor(1000);
		Assert.assertTrue(browser.label("Self-service name:").isVisible(),"self-service Name is visible");
		
		browser.heading2("General").click();
		browser.waitFor(1000);
		Assert.assertFalse(browser.label("Self-service name:").isVisible(),"No Attributes are visible");
		browser.heading2("General").click();
		browser.waitFor(1000);
		Assert.assertTrue(browser.label("Self-service name:").isVisible(),"Attributes are visible");
		
		
	}
	
	public static void pwdExpiration(SahiTasks browser,String userpassword,String newpassword) {
		
		browser.link("Reset your password.").click();
		browser.password("current_password").setValue(userpassword);
		browser.password("password1").setValue(newpassword);
		browser.password("password2").setValue(newpassword);
		browser.button("Reset Password").click();
		
	}

}
