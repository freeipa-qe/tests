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
		sahiTasks.link("Privileges").in(sahiTasks.div("content nav-space-3")).click();
	}

	public static void verifyPrivilege(SahiTasks sahiTasks, String name, String newDescription) {
		CommonTasks.search(sahiTasks, name);
		sahiTasks.link(name).click();
		sahiTasks.link("Settings").click();
		Assert.assertEquals(newDescription, sahiTasks.textarea("description").value());	
		sahiTasks.link("Privileges").in(sahiTasks.div("content nav-space-3")).click();
		CommonTasks.clearSearch(sahiTasks);
	}

	public static void deletePrivilege(SahiTasks sahiTasks,	String name, String buttonToClick) {
		CommonTasks.search(sahiTasks, name);
		if (sahiTasks.link(name).exists()){
			sahiTasks.checkbox(name).click();
			sahiTasks.link("Delete").click();
			sahiTasks.button(buttonToClick).click();
			
			
			if (buttonToClick.equals("Cancel")) {
				sahiTasks.checkbox(name).click();
			}
		}
		CommonTasks.clearSearch(sahiTasks);
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
			
			sahiTasks.link("Privileges").in(sahiTasks.div("content nav-space-3")).click();
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
		sahiTasks.link("Privileges").in(sahiTasks.div("content nav-space-3")).click();
	}

	public static void modifyPrivilegeButNotSave(SahiTasks sahiTasks, String name, String description, String newDescription,
			String buttonToClick) {
		sahiTasks.link(name).click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(newDescription);
		sahiTasks.link("Privileges").near(sahiTasks.span(name)).click();
		sahiTasks.button(buttonToClick).click();
		
		if (!buttonToClick.equals("Cancel")) {
			CommonTasks.search(sahiTasks, name);
			if (buttonToClick.equals("Update")){
				verifyPrivilege(sahiTasks, name, newDescription);
				CommonTasks.search(sahiTasks, name);
				sahiTasks.link(name).click();
				sahiTasks.link("Settings").click();
				sahiTasks.textarea("description").setValue(description);
				sahiTasks.span("Update").click();
				sahiTasks.link("Privileges").near(sahiTasks.span(name)).click();
			}
			else
				verifyPrivilege(sahiTasks, name, description);
			CommonTasks.clearSearch(sahiTasks);
		} else {
			Assert.assertEquals(newDescription, sahiTasks.textarea("description").value());	
			sahiTasks.span("Reset").click();
			sahiTasks.link("Privileges").in(sahiTasks.div("content nav-space-3")).click();
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
		sahiTasks.link("Privileges").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	
	public static void addMembersToPrivilege(SahiTasks sahiTasks, String name, String memberType, String searchString, String[] members, String buttonToClick) {
		addPrivilegeAddMembers(sahiTasks, name, "", memberType, searchString, members, buttonToClick);
	}
	
	
	public static void addPrivilegeAddMembers(SahiTasks sahiTasks, String name, String description, String memberType, String searchString, String[] permissions, String buttonToClick) {
		if (!description.isEmpty()) {
			sahiTasks.span("Add").click();
			sahiTasks.textbox("cn").setValue(name);
			sahiTasks.textarea("description").setValue(description);
			sahiTasks.button("Add and Edit").click();
		} else {
			CommonTasks.search(sahiTasks, name);
			sahiTasks.link(name).click();
		}
		
	
		if (memberType.equals("Permissions"))
			sahiTasks.link("memberof_permission").click();
		else
			sahiTasks.link("member_role").click();
			
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
		sahiTasks.link("Privileges").in(sahiTasks.div("content nav-space-3")).click();
		sahiTasks.span("Refresh").click();
		CommonTasks.clearSearch(sahiTasks);
	}

	
	public static void addPrivilegeSelectDeselectMembersToAdd(SahiTasks sahiTasks, String name, String description, 
			String memberType, String member1, String member2) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add and Edit").click();
		if (memberType.equals("Permissions"))
			sahiTasks.link("memberof_permission").click();
		else
			sahiTasks.link("member_role").click();
		sahiTasks.span("Add").click();
		sahiTasks.textbox("filter").setValue(member1);
		sahiTasks.span("Find").click();
		sahiTasks.checkbox(member1).click();
		sahiTasks.span(">>").click();
		sahiTasks.textbox("filter").setValue(member2);
		sahiTasks.span("Find").click();
		sahiTasks.checkbox(member2).click();
		sahiTasks.span(">>").click();
		sahiTasks.checkbox(member1).click(); // to unselect member1
		sahiTasks.span("<<").click(); //take off member2 from list
		sahiTasks.button("Add").click();
		sahiTasks.link("Privileges").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	

	public static void verifyPrivilegeMembership(SahiTasks sahiTasks, String name, String membershipToCheckfor, String[] members, boolean exists) {
		CommonTasks.search(sahiTasks, name);
		sahiTasks.link(name).click();
		if (membershipToCheckfor.equals("Permissions"))
			sahiTasks.link("memberof_permission").click();
		else
			sahiTasks.link("member_role").click();
		for (String member : members) {
			if (!member.isEmpty()) {
				if (exists){
					if(membershipToCheckfor.equals("Permissions"))
						Assert.assertTrue(sahiTasks.link(member.toLowerCase()).exists(), "Verified " + member + " is listed for " + name );
					else
						Assert.assertTrue(sahiTasks.link(member).exists(), "Verified " + member + " is listed for " + name );
				}	
				else {
					if(membershipToCheckfor.equals("Permissions"))
						Assert.assertFalse(sahiTasks.link(member.toLowerCase()).exists(), "Verified " + member + " is not listed for " + name );
					else
						Assert.assertFalse(sahiTasks.link(member).exists(), "Verified " + member + " is not listed for " + name );
				}
			}
		}	
		sahiTasks.link("Privileges").in(sahiTasks.div("content nav-space-3")).click();
		CommonTasks.clearSearch(sahiTasks);
	}
	
	public static void verifyPrivilegeMembershipInPermissionRole(SahiTasks sahiTasks, String name, String memberType, String[] members) {
		sahiTasks.link(name).click();
		if (memberType.equals("Permissions"))
			sahiTasks.link("memberof_permission").click();
		else
			sahiTasks.link("member_role").click();
		for (String member : members) {
			if (!member.isEmpty()) {
				sahiTasks.link(member).click();
				if (memberType.equals("Permissions"))
					sahiTasks.link("member_privilege").click();
				else
					sahiTasks.link("memberof_privilege").click();
				
					Assert.assertTrue(sahiTasks.link(name).exists(), "Verified Privilege " + name + " is listed for " + member );
					sahiTasks.link(name).click();
				
				if (memberType.equals("Permissions"))
					sahiTasks.link("memberof_permission").click();
				else
					sahiTasks.link("member_role").click();
			}
		}		
		sahiTasks.link("Privileges").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	public static void  deleteMemberFromPrivilege(SahiTasks sahiTasks, String name, String memberType, String[] members, 
			String allOrOne, String buttonToClick) {
		sahiTasks.link(name).click();
		if (memberType.equals("Permissions"))
			sahiTasks.link("memberof_permission").click();
		else
			sahiTasks.link("member_role").click();
		if (allOrOne.equals("All")) {
			sahiTasks.checkbox("cn").check();
		} else {
			for (String member : members) {
				if (!member.isEmpty()) {
					sahiTasks.checkbox(member).check();
				}
			}
		}
				
		sahiTasks.span("Delete").click();
		sahiTasks.button(buttonToClick).click();
		sahiTasks.link("Privileges").in(sahiTasks.div("content nav-space-3")).click();		
	}
		
}
