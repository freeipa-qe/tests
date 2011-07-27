package com.redhat.qe.ipa.sahi.tasks;

import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class HostgroupTasks {
	
	/*
	 * Create a host group
	 * @param sahiTasks 
	 * @param groupname - groupname
	 * @param description -  description for group
	 * @param button - Add or Cancel
	 */
	public static void addHostGroup(SahiTasks sahiTasks, String groupName, String description, String button) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupName);
		sahiTasks.textbox("description").setValue(description);
		sahiTasks.button(button).click();
	}
	
	/*
	 * add a host group and add another
	 * @param sahiTasks 
	 * @param groupName1
	 * @param groupName2
	 * @param groupName3
	 */
	public static void addAndAddAnotherHostGroup(SahiTasks sahiTasks, String groupName1, String groupName2, String groupName3) {
		String description1 = groupName1 + " description";
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupName1);
		sahiTasks.textbox("description").setValue(description1);
		sahiTasks.button("Add and Add Another").click();
		
		String description2 = groupName2 + " description";
		sahiTasks.textbox("cn").setValue(groupName2);
		sahiTasks.textbox("description").setValue(description2);
		sahiTasks.button("Add and Add Another").click();
		
		String description3 = groupName3 + " description";
		sahiTasks.textbox("cn").setValue(groupName3);
		sahiTasks.textbox("description").setValue(description3);
		sahiTasks.button("Add").click();
	}
	
	/*
	 * add and edit a host group
	 * @param sahiTasks 
	 * @param groupName - name of host group
	 * @param description1 - first description
	 * @param description2 - new description for edit
	 * @param undo - YES NO
	 */
	public static void addAndEditHostGroup(SahiTasks sahiTasks, String groupName, String description1, String description2) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupName);
		sahiTasks.textbox("description").setValue(description1);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.link("Settings").click();
		sahiTasks.textbox("description").setValue(description2);
		sahiTasks.span("Update").click();
		sahiTasks.link("Host Groups[1]").click();
	}
	
	/*
	 * verify host group settings
	 * @param sahiTasks 
	 * @param groupName - name of host group
	 * @param description
	 */
	public static void verifyHostGroupSettings(SahiTasks sahiTasks, String groupName, String description) {
		sahiTasks.link(groupName).click();
		sahiTasks.link("Settings").click();
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("description").value(), description, "Verified existing description for host group: " + groupName);
		sahiTasks.link("Host Groups[1]").click();
		
	}
	
	/*
	 * Delete the host group.
	 * @param sahiTasks
	 * @param groupName - name of the host group
	 * @param button - Delete or Cancel
	 */
	public static void deleteHostgroup(SahiTasks sahiTasks, String groupName, String button) {
		sahiTasks.checkbox(groupName).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button(button).click();
		
		if (button == "Cancel"){
			sahiTasks.checkbox(groupName).click();
		}
	}
	
	/*
	 * Delete multiple host groups.
	 * @param sahiTasks
	 * @param groupnames - the array of groupnames to delete
	 */
	public static void deleteHostgroup(SahiTasks sahiTasks, String [] groupnames) {
		for (String groupname : groupnames) {
			sahiTasks.checkbox(groupname).click();
		}
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	
	/*
	 * Add host members
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param hostnames - array of hostnames to add as members
	 * @param button - Enroll or Cancel
	 */
	public static void addHostMember(SahiTasks sahiTasks, String groupName, String [] hostnames, String button) {
		sahiTasks.link(groupName).click();
		sahiTasks.link("member_host").click();
		sahiTasks.link("Enroll").click();
		
		for (String hostname : hostnames) {
			sahiTasks.checkbox(hostname).click();
		}
		sahiTasks.span(">>").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Host Groups[1]").click();
	}
	
	/*
	 * Add host members
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param hostnames - array of hostnames to add as members
	 * @param button - Enroll or Cancel
	 */
	public static void verifyHostMember(SahiTasks sahiTasks, String groupName, String [] hostnames) {
		sahiTasks.link(groupName).click();
		sahiTasks.link("member_host").click();
		
		for (String hostname : hostnames) {
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(hostname).exists(), "Host " + hostname + " is a member of host group " + groupName);
		}
		sahiTasks.link("Host Groups[1]").click();
	}
}