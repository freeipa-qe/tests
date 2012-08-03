package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class NetgroupTasks {
	private static Logger log = Logger.getLogger(UserTasks.class.getName());
	
	/*
	 * Create a net group
	 * @param sahiTasks 
	 * @param groupname - groupname
	 * @param description -  description for group
	 * @param button - Add or Cancel
	 */
	public static void addNetGroup(SahiTasks sahiTasks, String groupName, String description, String button) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupName);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button(button).click();
	}
	
	/*
	 * add a net group and add another
	 * @param sahiTasks 
	 * @param groupName1
	 * @param groupName2
	 * @param groupName3
	 */
	public static void addAndAddAnotherNetGroup(SahiTasks sahiTasks, String groupName1, String groupName2, String groupName3) {
		String description1 = groupName1 + " description";
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupName1);
		sahiTasks.textarea("description").setValue(description1);
		sahiTasks.button("Add and Add Another").click();
		
		String description2 = groupName2 + " description";
		sahiTasks.textbox("cn").setValue(groupName2);
		sahiTasks.textarea("description").setValue(description2);
		sahiTasks.button("Add and Add Another").click();
		
		String description3 = groupName3 + " description";
		sahiTasks.textbox("cn").setValue(groupName3);
		sahiTasks.textarea("description").setValue(description3);
		sahiTasks.button("Add").click();
	}
	
	/*
	 * add and edit a net group
	 * @param sahiTasks 
	 * @param groupName - name of net group
	 * @param description1 - first description
	 * @param description2 - new description for edit
	 * @param undo - YES NO
	 */
	public static void addAndEditNetGroup(SahiTasks sahiTasks, String groupName, String description1, String description2, String nisdomain) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupName);
		sahiTasks.textarea("description").setValue(description1);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(description2);
		sahiTasks.textbox("nisdomainname").setValue(nisdomain);
		sahiTasks.span("Update").click();
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify host group settings
	 * @param sahiTasks 
	 * @param groupName - name of net group
	 * @param description
	 * @param nisdomain - nis domain
	 */
	public static void verifyNetGroupSettings(SahiTasks sahiTasks, String groupName, String description, String nisdomain) {
		sahiTasks.link(groupName).click();
		sahiTasks.link("Settings").click();
		Assert.assertEquals(sahiTasks.textarea("description").value(), description, "Verified existing description for net group: " + groupName);
		Assert.assertEquals(sahiTasks.textbox("nisdomainname").value(), nisdomain, "Verified existing nis domain for net group: " + groupName);
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
		
	}
	
	/*
	 * Delete the net group.
	 * @param sahiTasks
	 * @param groupName - name of the net group
	 * @param button - Delete or Cancel
	 */
	public static void deleteNetgroup(SahiTasks sahiTasks, String groupName, String button) {
		sahiTasks.checkbox(groupName).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button(button).click();
		
		if (button == "Cancel"){
			sahiTasks.checkbox(groupName).click();
		}
	}
	
	/*
	 * Delete multiple net groups.
	 * @param sahiTasks
	 * @param groupnames - the array of groupnames to delete
	 */
	public static void deleteNetgroup(SahiTasks sahiTasks, String [] groupnames) {
		for (String groupname : groupnames) {
			if (sahiTasks.checkbox(groupname).exists())
				sahiTasks.checkbox(groupname).click();
		}
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	

	
	public static void addMembers(SahiTasks sahiTasks, String groupName, String section, String type, String [] names, 
			String button, String action) {
		sahiTasks.link(groupName).click();
		if (button.equals("All")) {
			String categoryToChoose="";
			if (section.equals("User"))
				categoryToChoose = "usercategory" + "-1";
			else
				categoryToChoose = "hostcategory" +"-2";
			sahiTasks.radio(categoryToChoose+"-0").click();
			sahiTasks.span(action).click();
		}
				
		if (button.equals("Add")) {
			sahiTasks.span("Add").under(sahiTasks.heading2(section)).near(sahiTasks.div(type)).click();
			for (String name : names) {
				sahiTasks.textbox("filter").near(sahiTasks.span("Find")).setValue(name);
				sahiTasks.span("Find").click();
				sahiTasks.checkbox(name).click();
				sahiTasks.link(">>").click();
			}			
			sahiTasks.button(action).click();
		}
		
		
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
	}
	
	
	public static void verifyMembers(SahiTasks sahiTasks, String groupName, String section, String type, String [] names, 
			String button, String action) {
		sahiTasks.link(groupName).click();
		if (button.equals("All")) {
			String categoryToVerify = "";
			String memberToVerify = "";
			if (section.equals("User")) {
				categoryToVerify = "usercategory" + "-1";
				if (type.equals("Users"))
					memberToVerify = "memberuser_user";
				else	
					memberToVerify = "memberuser_group";
			}
			else {
				categoryToVerify = "hostcategory" +"-2";
				if (type.equals("Hosts"))
					memberToVerify = "memberhost_host";
				else	
					memberToVerify = "memberhost_hostgroup";
			}
			Assert.assertTrue(sahiTasks.radio(categoryToVerify + "-0").checked(), "Verified " + section + " set to All after choosing to " + action);
			Assert.assertFalse(sahiTasks.checkbox(memberToVerify + "[1]").exists(), "Verified no members are listed in " + section);
		}
		
		if (button.equals("Add")) {			
			for (String name : names) {
				if (!name.isEmpty()){
					if (action.equals("Cancel"))
						Assert.assertFalse(sahiTasks.checkbox(name).exists(), "Verified " + name + " is not listed under " + section);
					else
						Assert.assertTrue(sahiTasks.checkbox(name).exists(), "Verified " + name + " is listed under " + section);
				}				
			}		
		}
		
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * button = All -> delete all members
	 * button = Delete -> delete names passed in
	 */
	
	public static void deleteUserMembers(SahiTasks sahiTasks, String groupName, String section, String type, String [] names, String button) {
		sahiTasks.link(groupName).click();
		if (button.equals("All")) {
			String memberToVerify = "";
			if (section.equals("User")) {
				if (type.equals("Users"))
					memberToVerify = "memberuser_user";
				else	
					memberToVerify = "memberuser_group";
			}
			else {
				if (type.equals("Hosts"))
					memberToVerify = "memberhost_host";
				else	
					memberToVerify = "memberhost_hostgroup";
			}
			sahiTasks.checkbox(memberToVerify).check();
		}
		if (button.equals("Delete")) {
			for (String name : names) {
				if (!name.isEmpty()){
					sahiTasks.checkbox(name).check();
				}
			}			
		}
		sahiTasks.span("Delete").under(sahiTasks.heading2(section)).near(sahiTasks.div(type)).click();
		sahiTasks.button("Delete").click();
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
	}
	
	
	/**
	 * @param sahiTasks
	 * @param cn
	 * @param category - usercategory/hostcategory
	 * @param action - undo/Reset/Update
	 */
	public static void undoResetUpdateNetgroup(SahiTasks sahiTasks, String groupName, String category, String action) {
		sahiTasks.link(groupName).click();
		String categoryToChoose="";
		if (category.equals("usercategory"))
			categoryToChoose = category + "-1";
		else
			categoryToChoose = category +"-2";
		sahiTasks.radio(categoryToChoose+"-0").click();
		sahiTasks.span(action).click();
		if (action.equals("Update"))  
			Assert.assertTrue(sahiTasks.radio(categoryToChoose + "-0").checked(), "Verified " + category + " set after choosing to " + action);		
		else
			Assert.assertTrue(sahiTasks.radio(categoryToChoose + "-1").checked(), "Verified " + category + " set after choosing to " + action);
		
		//TODO: Verify that when radio button for Anyone or Any Host is chosen, this disables the 
		// links to Add, and Delete
	/*	if (action.equals("Update")) {
			Assert.assertEquals("true", sahiTasks.span("Add[2]").fetch("disabled"));
	//		Assert.assertEquals("true", sahiTasks.span("Add").under(sahiTasks.heading2("Host")).near(sahiTasks.div("Hosts")).fetch("disabled"));
		//	Assert.assertEquals("true", sahiTasks.span("Delete").under(sahiTasks.heading2("Host")).near(sahiTasks.div("Hosts")).fetch("disabled"));
	//		Assert.assertEquals("true", sahiTasks.span("Add").under(sahiTasks.heading2("Host Groups")).near(sahiTasks.div("Hosts")).fetch("disabled"));
	//		Assert.assertEquals("true", sahiTasks.span("Delete").under(sahiTasks.heading2("Host Groups")).near(sahiTasks.div("Hosts")).fetch("disabled"));
		}*/
		
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();	
	}	
	
	public static void modifyNetgroupMembership(SahiTasks sahiTasks, String groupName, String category) {
		sahiTasks.link(groupName).click();
		String categoryToChoose="";
		if (category.equals("usercategory"))
			categoryToChoose = category + "-1";
		else
			categoryToChoose = category +"-2";
		sahiTasks.radio(categoryToChoose+"-1").click();
		sahiTasks.span("Update").click();		
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();	
	}
	
	public static void unsavedChangesNetgroup(SahiTasks sahiTasks, String groupName, String description, String action) {
		sahiTasks.link(groupName).click();
        String newDescription = description + " Updated";
		sahiTasks.textarea("description").setValue(newDescription);
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
		
		sahiTasks.button(action).click();
		if (action.equals("Cancel")) {
			sahiTasks.span("undo").click();
			sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
		} 
		
		
		if(sahiTasks.link(groupName).exists())
			sahiTasks.link(groupName).click();
		if (action.equals("Update")) {
			Assert.assertEquals(newDescription, sahiTasks.textarea("description").value(), "Verified description is as expected: " + newDescription);
		} else {
			Assert.assertEquals(description, sahiTasks.textarea("description").value(), "Verified description is as expected: " + description);
		}
	
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();	
	}
	
	public static void expandCollapseNetgroup(SahiTasks sahiTasks, String groupName) {
		
			sahiTasks.link(groupName).click();
			sahiTasks.span("Collapse All").click();
			sahiTasks.waitFor(1000);
			
			//Verify no data is visible
			Assert.assertFalse(sahiTasks.textarea("description").exists(), "No description is visible");
			
			sahiTasks.heading2("User").click();
			Assert.assertTrue(sahiTasks.div("User category the rule applies to: AnyoneSpecified Users and Groups undo").exists(), "When User section is clicked, can see its contents");
			
			
			sahiTasks.span("Expand All").click();
			sahiTasks.waitFor(1000);
			//Verify data is visible
			Assert.assertTrue(sahiTasks.textarea("description").exists(), "Now description is visible");
			
			sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
		
		
	}
	
	
	public static void modifyNetgroupDescription(SahiTasks sahiTasks, String groupName, String description) {
		sahiTasks.link(groupName).click();
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.span("Update").click();
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
	}
	

	
	
	/*
	 * add invalid net group
	 * @param sahiTasks 
	 * @param groupname - group name
	 * @param description - description for group
	 * @param expectedError - the error thrown when an invalid net group is being attempted to be added
	 */
	public static void addInvalidNetGroup(SahiTasks sahiTasks, String groupname, String description, String expectedError) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupname);
		sahiTasks.textarea("description").setValue(description);
	
		sahiTasks.button("Add").click();
		//Check for expected error
		log.fine("error check");
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding invalid host group :: " + expectedError);
	
		log.fine("cancel(near retry)");
		sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
		log.fine("cancel");
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}
	
	/*
	 * Add invalid net group.
	 * @param sahiTasks 
	 * @param groupname - group name
	 * @param description - description for host group
	 * @param expectedError - the error thrown when an invalid net group is being attempted to be added
	 */
	public static void addInvalidCharNetGroup(SahiTasks sahiTasks, String groupname, String description, String expectedError) {
		
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupname);
		sahiTasks.textarea("description").setValue(description);
	
		sahiTasks.button("Add").click();
		//Check for expected error
		log.fine("error check");
		Assert.assertTrue(sahiTasks.span(expectedError).exists(), "Verified expected error when adding invalid net group :: " + expectedError);
	
		log.fine("cancel(near retry)");
		sahiTasks.button("Cancel").click();
	}

	public static void searchNetgroup(SahiTasks sahiTasks, String netgroup) {
		sahiTasks.textbox("filter").setValue(netgroup);
		sahiTasks.span("icon search-icon").click();
		
	}
	
	public static void clearSearch(SahiTasks sahiTasks) {
		sahiTasks.textbox("filter").setValue("");
		sahiTasks.span("icon search-icon").click();
		
	}
}