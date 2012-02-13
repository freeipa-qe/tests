package com.redhat.qe.ipa.sahi.tasks;

public class AutomountTasks {

	///// task method for automount location ///////////
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

	///// task method for direct automount map ///////////
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

	///// task method for indirect map ///////////
	public static void addIndirectAutomountMap(SahiTasks browser, String indirectAutomountMap, String mountPoint, String parentMap) {
		browser.span("Add").click();
		browser.radio("add_indirect").click();
		browser.textbox("automountmapname").setValue(indirectAutomountMap);
		browser.textarea("description").setValue(indirectAutomountMap + " : auto description");
		browser.textbox("kep").setValue(mountPoint);
		browser.textbox("parentmap").setValue(parentMap);
		browser.button("Add").click();
	}

	public static void addIndirectAutomountMapAddAndAddAnother(SahiTasks browser,String[] indirectAutomountMaps, String[] mountPoints, String[] parentMaps) {
		browser.span("Add").click();
		for (int i=0; i< indirectAutomountMaps.length; i++)
		{
			String map = indirectAutomountMaps[i]; 
			String mountPoint = mountPoints[i];
			String parentMap = parentMaps[i];

			browser.radio("add_indirect").click();
			browser.textbox("automountmapname").setValue(map);
			browser.textarea("description").setValue(map  + " : auto description for indirect automount name");
			browser.textbox("kep").setValue(mountPoint);
			browser.textbox("parentmap").setValue(parentMap);
			browser.button("Add and Add Another").click();
		}
		browser.button("Cancel").click();
	}

	public static void addIndirectAutomountMapAddThenCancel(SahiTasks browser,String indirectAutomountMap, String mountPoint, String parentMap) {
		browser.span("Add").click();
		browser.radio("add_indirect").click();
		browser.textbox("automountmapname").setValue(indirectAutomountMap);
		browser.textarea("description").setValue(indirectAutomountMap + " : auto description for indirect automount name");
		browser.textbox("kep").setValue(mountPoint);
		browser.textbox("parentmap").setValue(parentMap);
		browser.button("Cancel").click();
	}

}
