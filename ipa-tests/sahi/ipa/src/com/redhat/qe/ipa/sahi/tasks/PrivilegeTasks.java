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
		sahiTasks.link("Privileges").in(sahiTasks.div("content")).click();
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

	public static void expandCollapsePrivilege(SahiTasks sahiTasks, String name) {
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

	public static void modifyPrivilegeButNotSave(SahiTasks sahiTasks, String name, String description, String newDescription,
			String buttonToClick) {
		sahiTasks.link(name).click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(newDescription);
		sahiTasks.link("Privileges").in(sahiTasks.div("content")).click();
		sahiTasks.button(buttonToClick).click();
		
		if (!buttonToClick.equals("Cancel")) {
			CommonTasks.search(sahiTasks, name);
			if (buttonToClick.equals("Update"))
				verifyPrivilege(sahiTasks, name, newDescription);
			else
				verifyPrivilege(sahiTasks, name, description);
			CommonTasks.clearSearch(sahiTasks);
		} else {
			Assert.assertEquals(newDescription, sahiTasks.textarea("description").value());	
			sahiTasks.span("Reset").click();
			sahiTasks.link("Privileges").in(sahiTasks.div("content")).click();
		}
	}

	public static void modifyInvalidPrivilege(SahiTasks sahiTasks, String name, String newDescription, String expectedError) {
		sahiTasks.link(name).click();
		sahiTasks.link("Settings").click();
		if (newDescription.isEmpty()) {
			sahiTasks.textarea("description").setValue(" ");
		}
		sahiTasks.textarea("description").setValue(newDescription);
		sahiTasks.span("Update").click();
		Assert.assertTrue(sahiTasks.div("ui-dialog-content ui-widget-content").text().contains(expectedError), " Verified expected error");
		if (sahiTasks.button("OK").exists()) 
			sahiTasks.button("OK").click();
		else
			sahiTasks.button("Cancel").click();
		sahiTasks.span("Reset").click();
		sahiTasks.link("Privileges").in(sahiTasks.div("content")).click();
	}
	
	public static void addPrivilegeAddPermissions(SahiTasks sahiTasks, String name, String description, String searchString, String[] permissions, String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.span("Add").click();
		sahiTasks.textbox("filter").setValue(searchString);
		sahiTasks.span("Find").click();
		for (String permission : permissions) {
			if (!permission.isEmpty()) {
				sahiTasks.checkbox(permission).click();
			}
		}
		sahiTasks.span(">>").click();
		sahiTasks.button(buttonToClick).click();
		sahiTasks.link("Privileges").in(sahiTasks.div("content")).click();
	}
	

	public static void addPrivilegeSelectDeselectPermissionsToAdd(SahiTasks sahiTasks, String name, String description, String permission1, String permission2) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.span("Add").click();
		sahiTasks.textbox("filter").setValue(permission1);
		sahiTasks.span("Find").click();
		sahiTasks.checkbox(permission1).click();
		sahiTasks.span(">>").click();
		sahiTasks.textbox("filter").setValue(permission2);
		sahiTasks.span("Find").click();
		sahiTasks.checkbox(permission2).click();
		sahiTasks.span(">>").click();
		sahiTasks.checkbox(permission1).click(); // to unselect permission1
		sahiTasks.span("<<").click(); //take off permisison2 from list
		sahiTasks.button("Add").click();
		sahiTasks.link("Privileges").in(sahiTasks.div("content")).click();
	}
	
	

	public static void verifyPrivilegeMembership(SahiTasks sahiTasks, String name, String membershipToCheckfor, String[] permissions, boolean exists) {
		sahiTasks.link(name).click();
		if (membershipToCheckfor.equals("Permissions"))
			sahiTasks.link("memberof_permission").click();
		else
			sahiTasks.link("member_role").click();
		for (String permission : permissions) {
			if (!permission.isEmpty()) {
				if (exists){
					Assert.assertTrue(sahiTasks.link(permission).exists(), "Verified permission " + permission + " is listed for " + name );
				}	
				else {
					Assert.assertFalse(sahiTasks.link(permission).exists(), "Verified permission " + permission + " is not listed for " + name );
				}
			}
		}	
		sahiTasks.link("Privileges").in(sahiTasks.div("content")).click();
	}
	
	public static void verifyPrivilegeMembershipInPermission(SahiTasks sahiTasks, String name, String[] permissions) {
		sahiTasks.link(name).click();
		sahiTasks.link("memberof_permission").click();
		for (String permission : permissions) {
			if (!permission.isEmpty()) {
				sahiTasks.link(permission).click();
				sahiTasks.link("member_privilege").click();
				Assert.assertTrue(sahiTasks.link(name.toLowerCase()).exists(), "Verified Privilege " + name + " is listed for " + permission );
				sahiTasks.link(name.toLowerCase()).click();
			}
		}	
		
		sahiTasks.link("Privileges").in(sahiTasks.div("content")).click();
	}
	
	
		
}
