package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;

public class RoleTasks {
	private static Logger log = Logger.getLogger(RoleTasks.class.getName());
	
	public static void addRole(SahiTasks sahiTasks, String name, String description, String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button(buttonToClick).click();
	}
	
	public static void addAndAddAnotherRole(SahiTasks sahiTasks,
			String name1, String name2, String description1, String description2) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name1);
		sahiTasks.textarea("description").setValue(description1);
		sahiTasks.button("Add and Add Another").click();
		Assert.assertTrue(sahiTasks.div("Role successfully added").exists(), "Verified confirmation message");
		sahiTasks.textbox("cn").setValue(name2);
		sahiTasks.textarea("description").setValue(description2);
		sahiTasks.button("Add").click();
	}
	
	public static void addAndEditRole(SahiTasks sahiTasks, String name, String description, String newdescription) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(newdescription);
		sahiTasks.span("Update").click();
		sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
	}

	
	public static void undoResetUpdateRole(SahiTasks sahiTasks, String name, String description, String newDescription, String buttonToClick) {
		sahiTasks.link(name).click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(newDescription);
		sahiTasks.span(buttonToClick).click();	
		if ( (buttonToClick.equals("undo")) || (buttonToClick.equals("Reset")) ) {
			Assert.assertEquals(description, sahiTasks.textarea("description").value());			
		} else {
			Assert.assertEquals(newDescription, sahiTasks.textarea("description").value());	
		}
		sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
	}

	public static void modifyRoleButNotSave(SahiTasks sahiTasks, String name, String description, String newDescription,
			String buttonToClick) {
		sahiTasks.link(name).click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(newDescription);
		sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
		sahiTasks.button(buttonToClick).click();
		
		if (!buttonToClick.equals("Cancel")) {
			CommonTasks.search(sahiTasks, name);
			if (buttonToClick.equals("Update")){
				verifyRole(sahiTasks, name, newDescription);
				sahiTasks.link(name).click();
				sahiTasks.link("Settings").click();
				sahiTasks.textarea("description").setValue(description);
				sahiTasks.span("Update").click();
				sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
				
			}
			else
				verifyRole(sahiTasks, name, description);
			CommonTasks.clearSearch(sahiTasks);
		} else {
			Assert.assertEquals(newDescription, sahiTasks.textarea("description").value());	
			sahiTasks.span("Reset").click();
			sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
		}
	}


	public static void addInvalidRole(SahiTasks sahiTasks, String name, String description, String expectedError) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add").click();
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding invalid role " + name);
		sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}
	
	public static void modifyInvalidRole(SahiTasks sahiTasks, String name, String newDescription, String expectedError) {
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
		sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	
	
	public static void verifyRole(SahiTasks sahiTasks, String name, String newDescription) {
		sahiTasks.link(name).click();
		sahiTasks.link("Settings").click();
		Assert.assertEquals(newDescription, sahiTasks.textarea("description").value());	
		sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	
	public static void deleteRole(SahiTasks sahiTasks,	String name, String buttonToClick) {
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
	
	public static void addRoleWithRequiredField(SahiTasks sahiTasks, String name, String description, String expectedError) {
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
	
	public static void expandCollapseRole(SahiTasks sahiTasks, String name) {
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
			
			sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
		}
		CommonTasks.clearSearch(sahiTasks);
		
	}
	

	public static void deleteMultipleRole(SahiTasks sahiTasks,	String searchString, String[] names, String buttonToClick) {
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
	
	public static void addPrivilegesToRole(SahiTasks sahiTasks, String name, String searchString, String[] privileges, String buttonToClick) {
		addRoleAddPrivileges(sahiTasks, name, "", searchString, privileges, buttonToClick);
	}
	public static void addRoleAddPrivileges(SahiTasks sahiTasks, String name, String description, String searchString, String[] privileges, String buttonToClick) {
		if (!description.isEmpty()) {
			sahiTasks.span("Add").click();
			sahiTasks.textbox("cn").setValue(name);
			sahiTasks.textarea("description").setValue(description);
			sahiTasks.button("Add and Edit").click();
		} else {
			sahiTasks.link(name).click();
		}		
		sahiTasks.link("memberof_privilege").click();
		sahiTasks.span("Add").click();
		sahiTasks.textbox("filter").setValue(searchString);
		sahiTasks.span("Find").click();
		for (String privilege : privileges) {
			if (!privilege.isEmpty()) {
				sahiTasks.checkbox(privilege).click();
			}
		}
		sahiTasks.span(">>").click();
		sahiTasks.button(buttonToClick).click();
		sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
		sahiTasks.span("Refresh").click();
	}
	
	
	public static void addMemberToRole(SahiTasks sahiTasks, String name, String type, String member) {
		addRoleAddMember(sahiTasks, name, "", type, member);
	}
	
	public static void addRoleAddMember(SahiTasks sahiTasks, String name, String description, String type, String member) {
		if (!description.isEmpty()) {
			sahiTasks.span("Add").click();
			sahiTasks.textbox("cn").setValue(name);
			sahiTasks.textarea("description").setValue(description);
			sahiTasks.button("Add and Edit").click();
		} else {
			CommonTasks.search(sahiTasks, name);
			sahiTasks.link(name).click();
		}
		
		if (type.equals("Users")) 
			sahiTasks.link("member_user").click();
		if (type.equals("Groups")) 
			sahiTasks.link("member_group").click();
		if (type.equals("Hosts")) 
			sahiTasks.link("member_host").click();
		if (type.equals("HostGroups")) 
			sahiTasks.link("member_hostgroup").click();
		sahiTasks.span("Add").click();
		sahiTasks.checkbox(member).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Add").click();
		sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
		sahiTasks.span("Refresh").click();
		CommonTasks.clearSearch(sahiTasks);
	}
	
	
	public static void verifyRoleMemberOfPrivilege(SahiTasks sahiTasks, String name, String membershipToCheckfor, String[] privileges, boolean exists) {
		CommonTasks.search(sahiTasks, name);
		sahiTasks.link(name).click();
		if (membershipToCheckfor.equals("Privileges"))
			sahiTasks.link("memberof_privilege").click();
		
		for (String privilege : privileges) {
			if (!privilege.isEmpty()) {
				if (exists){
					Assert.assertTrue(sahiTasks.link(privilege).exists(), "Verified privilege " + privilege + " is listed for " + name );
				}	
				else {
					Assert.assertFalse(sahiTasks.link(privilege).exists(), "Verified privilege " + privilege + " is not listed for " + name );
				}
			}
		}	
		sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
		CommonTasks.clearSearch(sahiTasks);
	}
	
	public static void verifyMembership(SahiTasks sahiTasks, String name, String type, String member) {
		CommonTasks.search(sahiTasks, name);
		sahiTasks.link(name).click();
		
		if (type.equals("Users")) 
			sahiTasks.link("member_user").click();
		if (type.equals("Groups")) 
			sahiTasks.link("member_group").click();
		if (type.equals("Hosts")) 
			sahiTasks.link("member_host").click();
		if (type.equals("HostGroups")) 
			sahiTasks.link("member_hostgroup").click();
		
		Assert.assertTrue(sahiTasks.link(member).exists(), "Verified " + member + " is listed for " + name );
		sahiTasks.link(member).click();	
		//missing memberof_role in hostgroup,bug812109
		sahiTasks.link("memberof_role").click();
		Assert.assertTrue(sahiTasks.link(name).exists(), "Verified " + name + " is listed for " + member );
		sahiTasks.link(name).click();
		sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
		CommonTasks.clearSearch(sahiTasks);
	}
	
	public static void verifyRoleMembershipInPrivilege(SahiTasks sahiTasks, String name, String[] privileges) {
		sahiTasks.link(name).click();
		for (String privilege : privileges) {
			if (!privilege.isEmpty()) {
				sahiTasks.link("memberof_privilege").click();
				sahiTasks.link(privilege).click();
				sahiTasks.link("member_role").click();
				Assert.assertTrue(sahiTasks.link(name).exists(), "Verified Role " + name + " is listed for " + privilege );
				sahiTasks.link(name).click();
			}
		}	
		
		sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	public static void addRoleSelectDeselectPrivilegesToAdd(SahiTasks sahiTasks, String name, String description, String privilege1, String privilege2) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(name);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.link("memberof_privilege").click();
		sahiTasks.span("Add").click();
		sahiTasks.textbox("filter").setValue(privilege1);
		sahiTasks.span("Find").click();
		sahiTasks.checkbox(privilege1).click();
		sahiTasks.span(">>").click();
		sahiTasks.textbox("filter").setValue(privilege2);
		sahiTasks.span("Find").click();
		sahiTasks.checkbox(privilege2).click();
		sahiTasks.span(">>").click();
		sahiTasks.checkbox(privilege1).click(); // to unselect privilege1
		sahiTasks.span("<<").click(); //take off permisison2 from list
		sahiTasks.button("Add").click();
		sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	/*
	 *     


browser.span("Add[2]").click();
browser.textbox("cn[2]").setValue("Automount TestRole");
browser.textarea("description[1]").setValue("Automount TestRole");
browser.button("Add and Edit").click();
browser.link("Users[3]").click();
browser.span("Add[3]").click();
browser.checkbox("available[1]").click();
browser.span(">>").click();
browser.button("Add").click();
browser.link("Roles[1]").click();


browser.link("Automount TestRole").click();
browser.div("Automount TestRole members:").click();
browser.link("Users (1)").click();
browser.link("a[1]").click();
browser.link("Roles (1)").click();
browser.link("hbac testrole").click();
browser.link("Roles[1]").click();
browser.link("Automount TestRole").click();
browser.link("User Groups[1]").click();
browser.span("Add[4]").click();
browser.checkbox("available[4]").click();
browser.span(">>").click();
browser.button("Add").click();
browser.link("Roles[2]").click();
browser.link("Automount TestRole").click();
browser.link("User Groups[1]").click();
browser.link("permissiontestgroup").click();
browser.link("Roles (1)[2]").click();
browser.link("automount testrole").click();
browser.link("Roles[1]").click();
browser.link("Automount TestRole").click();
browser.link("Hosts[1]").click();
browser.span("Add[5]").click();
browser.checkbox("available[1]").click();
browser.span(">>").click();
browser.button("Add").click();
browser.link("Roles[3]").click();
browser.link("Automount TestRole").click();
browser.link("Hosts[1]").click();
browser.link("rhel63-server.testrelm.com").click();
browser.link("Roles (1)[4]").click();
browser.link("automount testrole[1]").click();
browser.link("Roles[1]").click();
browser.link("Automount TestRole").click();
browser.link("Host Groups[1]").click();
browser.span("Add[6]").click();
browser.checkbox("available[1]").click();
browser.span(">>").click();
browser.button("Add").click();
browser.link("Roles[4]").click();
browser.link("Automount TestRole").click();
browser.link("Host Groups[1]").click();
browser.link("aaa").click();

	 */
	 
	
}
