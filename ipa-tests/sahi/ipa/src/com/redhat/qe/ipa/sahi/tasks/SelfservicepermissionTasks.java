package com.redhat.qe.ipa.sahi.tasks;

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

}
