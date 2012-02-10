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

	public static void addAutomountMap(SahiTasks browser, String automountMap) {
		browser.span("Add").click();
		browser.textbox("automountmapname").setValue(automountMap);
		browser.textarea("description").setValue(automountMap + " : auto description");
		browser.button("Add").click();
	}

	public static void addAutomountMapAddAndAddAnother(SahiTasks browser,String[] automountMaps) {
		browser.span("Add").click();
		for (int i=0; i< automountMaps.length; i++)
		{
			String map = automountMaps[i]; 
			browser.textbox("automountmapname").setValue(map);
			browser.textarea("description").setValue(map + " : auto description");
			browser.button("Add and Add Another").click();
		}
		browser.button("Cancel").click();
	}

	public static void addAutomountMapAddThenCancel(SahiTasks browser,String automountMap) {
		browser.span("Add").click();
		browser.textbox("automountmapname").setValue(automountMap);
		browser.textarea("description").setValue(automountMap + " : auto description");
		browser.button("Cancel").click();
	}

}
