package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;

public class PrivilegeTasks {
	private static Logger log = Logger.getLogger(PrivilegeTasks.class.getName());

	public static void addPrivilege(SahiTasks sahiTasks, String name, String description, String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button(buttonToClick).click();
	}

	public static void addAndAddAnotherPrivilege(SahiTasks sahiTasks,
			String name1, String name2, String description1, String description2) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name1);
		sahiTasks.textarea("description").setValue(description1);
		sahiTasks.button("Add and Add Another").click();
		Assert.assertTrue(sahiTasks.div("Privilege successfully added").exists(), "Verified confirmation message");
		sahiTasks.textbox("cn").setValue(name2);
		sahiTasks.textarea("description").setValue(description2);
		sahiTasks.button("Add").click();
	}

	public static void addAndEditPrivilege(SahiTasks sahiTasks, String name, String description, String newdescription) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(newdescription);
		sahiTasks.span("Update").click();
		sahiTasks.link("Privileges").in(sahiTasks.div("content")).click();
	}

	public static void verifyPrivilege(SahiTasks sahiTasks, String name, String newDescription) {
		sahiTasks.link(name).click();
		sahiTasks.link("Settings").click();
		Assert.assertEquals(newDescription, sahiTasks.textarea("description").value());	
		sahiTasks.link("Privileges").click();
	}

	public static void deletePrivilege(SahiTasks sahiTasks,	String name, String buttonToClick) {		
		if (sahiTasks.link(name).exists()){
			sahiTasks.checkbox(name).click();
			sahiTasks.link("Delete").click();
			sahiTasks.button(buttonToClick).click();
			
			
			if (buttonToClick.equals("Cancel")) {
				sahiTasks.checkbox(name).click();
			}
		}
	}

	public static void addInvalidPrivilege(SahiTasks sahiTasks, String name, String description, String expectedError) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add").click();
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding invalid privilege " + name);
		sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}

	public static void addPrivilegeWithRequiredField(SahiTasks sahiTasks, String name, String description, String expectedError) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add").click();
		if (name.isEmpty())
		  Assert.assertTrue(sahiTasks.span(expectedError).near(sahiTasks.textbox("cn")).exists(), "Verified expected error for missing name");
		if (description.isEmpty())
			 Assert.assertTrue(sahiTasks.span(expectedError).near(sahiTasks.textarea("description")).exists(), "Verified expected error for missing description");
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}

	public static void deleteMultiplePrivilege(SahiTasks sahiTasks,	String searchString, String[] names, String buttonToClick) {
		CommonTasks.search(sahiTasks, searchString);
		for (String name : names) {
			if (!name.isEmpty()) {
				sahiTasks.checkbox(name).click();
			}
		}	
		sahiTasks.span("Delete").click();
		sahiTasks.button(buttonToClick).click();
		CommonTasks.clearSearch(sahiTasks);		
	}

	public static void expandCollapsePermission(SahiTasks sahiTasks, String name) {
		CommonTasks.search(sahiTasks, name);
		if (sahiTasks.link(name).exists()) {
			sahiTasks.link(name).click();
			sahiTasks.link("Settings").click();
			sahiTasks.span("Collapse All").click();
			sahiTasks.waitFor(1000);
			
			//Verify no data is visible
			Assert.assertFalse(sahiTasks.textarea("description").exists(), "No description is visible");
			
			sahiTasks.span("Expand All").click();
			sahiTasks.waitFor(1000);
			//Verify data is visible
			Assert.assertTrue(sahiTasks.textarea("description").exists(), "Now description is visible");
			
			sahiTasks.link("Privileges").in(sahiTasks.div("content")).click();
		}
		CommonTasks.clearSearch(sahiTasks);
		
	}


	public static void undoResetUpdatePrivilege(SahiTasks sahiTasks, String name, String description, String newDescription, String buttonToClick) {
		sahiTasks.link(name).click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(newDescription);
		sahiTasks.span(buttonToClick).click();	
		if ( (buttonToClick.equals("undo")) || (buttonToClick.equals("Reset")) ) {
			Assert.assertEquals(description, sahiTasks.textarea("description").value());			
		} else {
			Assert.assertEquals(newDescription, sahiTasks.textarea("description").value());	
		}
		sahiTasks.link("Privileges").in(sahiTasks.div("content")).click();
	}
	

}
