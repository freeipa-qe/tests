package com.redhat.qe.ipa.sahi.tasks;

public class AutomountTasks {

	public static void addAutomountLocation(SahiTasks browser,String location) {
		CommonHelper.addNewEntry(browser, location);
	}

	public static void addAutomountLocationAddAndAddAnother(SahiTasks browser,	String[] locations) {
		browser.span("Add").click();
		for (int i=0; i< locations.length; i++)
		{
			String location = locations[i]; 
			browser.textbox("cn").setValue(location);
			browser.button("Add and Add Another").click();
		}
		browser.button("Cancel").click();
	}

	public static void addAutomountLocationAddThenCancel(SahiTasks browser,	String automountLocation) {
		browser.span("Add").click();
		browser.textbox("cn").setValue(automountLocation);
		browser.button("Cancel").click();
	}

}
