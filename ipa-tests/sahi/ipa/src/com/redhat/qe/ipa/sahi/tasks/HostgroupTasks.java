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
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
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
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
		
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
	 * @param membertype - host or hostgroup
	 * @param names - array of names to add as members
	 * @param button - Enroll or Cancel
	 */
	public static void addMembers(SahiTasks sahiTasks, String groupName, String membertype, String [] names, String button) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("member_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("member_hostgroup").click();
		}
		
		sahiTasks.link("Enroll").click();
		
		for (String name : names) {
			sahiTasks.checkbox(name).click();
		}
		sahiTasks.span(">>").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify members
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param membertype - host or hostgroup
	 * @param names - array of names to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members YES if they should be
	 */
	public static void verifyMembers(SahiTasks sahiTasks, String groupName, String membertype, String [] names, String type, String exists) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("member_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("member_hostgroup").click();
		}
		
		sahiTasks.radio(type).click();
		
		for (String name : names) {
			if (exists == "YES"){
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(name).exists(), membertype + " " + name + " is a member of host group " + groupName);
			}
			else {
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(name).exists(), membertype + " " + name + " is NOT member of host group " + groupName);
			}
		}
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify member of
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param memberoftype - hostgroup, hbacrule or sudorule
	 * @param names - array of names to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members of the enroll type - YES if they should be
	 */
	public static void verifyMemberOf(SahiTasks sahiTasks, String groupName, String memberoftype, String [] names, String type, String exists) {
		sahiTasks.link(groupName).click();
		if (memberoftype == "hostgroup"){
			sahiTasks.link("memberof_hostgroup").click();
		}
		if (memberoftype == "hbacrule"){
			sahiTasks.link("memberof_hbacrule").click();
		}
		if (memberoftype == "sudorule"){
			sahiTasks.link("memberof_sudorule").click();
		}
		sahiTasks.radio(type).click();
		
		for (String name : names) {
			if (exists == "YES"){
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(name).exists(), "Host group " + groupName + " is a memberof host group " + memberoftype + ": " + name);
			}
			else {
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(name).exists(), "Host group " + groupName + " is NOT a memberof host group " + memberoftype + ": " + name);
			}
		}
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Remove host members
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param hostnames - array of hostnames to remove as members
	 * @param button - Delete or Cancel
	 */
	public static void removeMember(SahiTasks sahiTasks, String groupName, String membertype, String [] names, String button) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("member_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("member_hostgroup").click();
		}
		
		for (String name : names) {
			sahiTasks.checkbox(name).click();
		}
		sahiTasks.span("Delete").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
	}
}