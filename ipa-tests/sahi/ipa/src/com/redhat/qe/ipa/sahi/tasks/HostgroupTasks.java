package com.redhat.qe.ipa.sahi.tasks;
import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class HostgroupTasks {
	private static Logger log = Logger.getLogger(UserTasks.class.getName());
	
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
		sahiTasks.textarea("description").setValue(description);
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
		sahiTasks.textarea("description").setValue(description1);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(description2);
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
		Assert.assertEquals(sahiTasks.textarea("description").value(), description, "Verified existing description for host group: " + groupName);
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
	 * @param name - name to add as member
	 * @param button - Enroll or Cancel
	 */
	public static void addMembers(SahiTasks sahiTasks, String groupName, String membertype, String name, String button) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("member_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("member_hostgroup").click();
		}
		
		sahiTasks.radio("direct").click();
		//sahiTasks.link("Add").click();
		sahiTasks.link("Add").near(sahiTasks.div("RefreshDeleteAddShow Results Direct Membership Indirect Membership")).click();
		sahiTasks.checkbox(name).click();
		
		sahiTasks.span(">>").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
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
		
		sahiTasks.radio("direct").click();
		sahiTasks.link("Add").near(sahiTasks.div("RefreshDeleteAddShow Results Direct Membership Indirect Membership")).click();
		//sahiTasks.link("Add").click();
		
		for (String name : names) {
			sahiTasks.checkbox(name).click();
		}
		sahiTasks.span(">>").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Add host members
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param membertype - host or hostgroup
	 * @param enrolled - enrolled host or host group
	 * @param button - YES if want to hide enrolled groups
	 */
	public static void hideAlreadyEnrolled(SahiTasks sahiTasks, String groupName, String membertype, String enrolled, String hide, String searchstr) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("member_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("member_hostgroup").click();
		}
		sahiTasks.radio("direct").click();
		sahiTasks.link("Add").click();
		if( hide == "YES" ){
			sahiTasks.checkbox("hidememb").check();
			sahiTasks.textbox("filter").setValue(searchstr);
			sahiTasks.span("Find").click();
			Assert.assertFalse(sahiTasks.span(enrolled+"[1]").exists(), "enrolled " + membertype + " " + enrolled + " is hidden");
		}
		if ( hide == "NO") {
			sahiTasks.checkbox("hidememb").uncheck();
			sahiTasks.textbox("filter").setValue(searchstr);
			sahiTasks.span("Find").click();
			Assert.assertTrue(sahiTasks.span(enrolled+"[1]").exists(), "enrolled " + membertype + " " + enrolled + " is NOT hidden");
		}
		
		sahiTasks.button("Cancel").click();
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify members
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param membertype - host or hostgroup
	 * @param name - name to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members YES if they should be
	 */
	public static void verifyMembers(SahiTasks sahiTasks, String groupName, String membertype, String name, String type, String exists) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("member_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("member_hostgroup").click();
		}
		
		sahiTasks.radio(type).click();
		
		if (exists == "YES"){
			Assert.assertTrue(sahiTasks.link(name).exists(), membertype + " " + name + " is a member of host group " + groupName);
		}
		else {
			Assert.assertFalse(sahiTasks.link(name).exists(), membertype + " " + name + " is NOT member of host group " + groupName);
		}
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
				Assert.assertTrue(sahiTasks.link(name).exists(), membertype + " " + name + " is a member of host group " + groupName);
			}
			else {
				Assert.assertFalse(sahiTasks.link(name).exists(), membertype + " " + name + " is NOT member of host group " + groupName);
			}
		}
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
	}
	/*
	 * verify member of
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param memberoftype - hostgroup, hbacrule or sudorule
	 * @param name - group name or rule of membership
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members of the enroll type - YES if they should be
	 */
	public static void verifyMemberOf(SahiTasks sahiTasks, String groupName, String memberoftype, String grprulename, 
			String type, String exists, boolean onPage) {
		if (!onPage) 
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
		
		if (exists == "YES"){
			Assert.assertTrue(sahiTasks.link(grprulename).exists(), "Host group " + groupName + " is a memberof host group " + memberoftype + ": " + grprulename);
		}
		else {
			Assert.assertFalse(sahiTasks.link(grprulename).exists(), "Host group " + groupName + " is NOT a memberof host group " + memberoftype + ": " + grprulename);
		}

		if (!onPage) 
			sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
	}
	/*
	 * verify member of
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param memberoftype - hostgroup, hbacrule or sudorule
	 * @param names - array of group or rule names to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members of the enroll type - YES if they should be
	 */
	public static void verifyMemberOf(SahiTasks sahiTasks, String groupName, String memberoftype, String [] grprulenames, String type, String exists) {
		sahiTasks.link(groupName).click();
		if (memberoftype == "hostgroup"){
			sahiTasks.link("memberof_hostgroup").click();
		}
		if (memberoftype == "netgroup"){
			sahiTasks.link("memberof_netgroup").click();
		}
		if (memberoftype == "hbacrule"){
			sahiTasks.link("memberof_hbacrule").click();
		}
		if (memberoftype == "sudorule"){
			sahiTasks.link("memberof_sudorule").click();
		}
		sahiTasks.radio(type).click();
		
		for (String grprulename : grprulenames) {
			if (exists == "YES"){
				Assert.assertTrue(sahiTasks.link(grprulename).exists(), "Host group " + groupName + " is a memberof " + memberoftype + ": " + grprulename);
			}
			else {
				Assert.assertFalse(sahiTasks.link(grprulename).exists(), "Host group " + groupName + " is NOT a memberof " + memberoftype + ": " + grprulename);
			}
		}
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Remove host members
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param hostnames - names to remove as member
	 * @param button - Delete or Cancel
	 */
	public static void removeMembers(SahiTasks sahiTasks, String groupName, String membertype, String name, String button) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("member_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("member_hostgroup").click();
		}
		
		sahiTasks.radio("direct").click();
		sahiTasks.checkbox(name).click();

		//sahiTasks.span("Delete").click();
		sahiTasks.link("Delete").near(sahiTasks.div("RefreshDeleteAddShow Results Direct Membership Indirect Membership")).click();
		sahiTasks.button(button).click();
		if (button.equals("Cancel"))
			sahiTasks.checkbox(name).click();
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Remove host members
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param hostnames - array of names to remove as members
	 * @param button - Delete or Cancel
	 */
	public static void removeMembers(SahiTasks sahiTasks, String groupName, String membertype, String [] names, String button) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("member_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("member_hostgroup").click();
		}
		
		sahiTasks.radio("direct").click();
		for (String name : names) {
			sahiTasks.checkbox(name).click();
		}
		//sahiTasks.span("Delete").click();
		sahiTasks.link("Delete").near(sahiTasks.div("RefreshDeleteAddShow Results Direct Membership Indirect Membership")).click();
		sahiTasks.button(button).click();
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * add invalid host group
	 * @param sahiTasks 
	 * @param groupname - group name
	 * @param description - description for group
	 * @param expectedError - the error thrown when an invalid host group is being attempted to be added
	 */
	public static void addInvalidHostGroup(SahiTasks sahiTasks, String groupname, String description, String expectedError) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupname);
		sahiTasks.textarea("description").setValue(description);
	
		sahiTasks.button("Add").click();
		//Check for expected error
		log.fine("error check");
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding invalid host group :: " + expectedError);
	
		log.fine("cancel(near retry)");
		sahiTasks.button("Cancel").click();
		
	}
	
	/*
	 * Add invalid host group.
	 * @param sahiTasks 
	 * @param groupname - group name
	 * @param description - description for host group
	 * @param expectedError - the error thrown when an invalid host group is being attempted to be added
	 */
	public static void addInvalidCharHostGroup(SahiTasks sahiTasks, String groupname, String description, String expectedError) {
		
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupname);
		sahiTasks.textarea("description").setValue(description);
	
		sahiTasks.button("Add").click();
		//Check for expected error
		log.fine("error check");
		Assert.assertTrue(sahiTasks.span(expectedError).exists(), "Verified expected error when adding invalid host group :: " + expectedError);
	
		log.fine("cancel(near retry)");
		sahiTasks.button("Cancel").click();
	}
	
	/*
	 * modify host group - invalid description - dirty page
	 * @param sahiTasks 
	 * @param groupname - group name
	 * @param description - description for host group
	 * @param expectedError - the error thrown when an invalid host group is being attempted to be added
	 */
	public static void modifyInvalidUndoHostGroup(SahiTasks sahiTasks, String groupname, String description, String expectedError) {
		
		sahiTasks.link(groupname).click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(" ");
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.span("Update").click();

		//Check for expected error
		log.fine("error check");
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding modifying host group :: " + expectedError);
	
		sahiTasks.button("OK").click();
		sahiTasks.span("undo").click();
		
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
		if (sahiTasks.button("Reset").exists()) {
			sahiTasks.button("Reset").click();
		}
	}
	
	/*
	 * modify host group - invalid description - dirty page
	 * @param sahiTasks 
	 * @param groupname - group name
	 * @param description - description for host group
	 * @param expectedError - the error thrown when an invalid host group is being attempted to be added
	 */
	public static void modifyInvalidDirtyHostGroup(SahiTasks sahiTasks, String groupname, String description, String expectedError) {
		
		sahiTasks.link(groupname).click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.span("Update").click();

		//Check for expected error
		log.fine("error check");
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding modifying host group :: " + expectedError);
	
		log.fine("cancel(near retry)");
		sahiTasks.button("Cancel").click();
		
		sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
		if (sahiTasks.button("Reset").exists()) {
			sahiTasks.button("Reset").click();
		}
	}
}