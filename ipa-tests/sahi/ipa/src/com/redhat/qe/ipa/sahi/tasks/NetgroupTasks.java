package com.redhat.qe.ipa.sahi.tasks;

import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class NetgroupTasks {
	
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
		sahiTasks.textbox("description").setValue(description);
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
		sahiTasks.textbox("description").setValue(description1);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.link("Settings").click();
		sahiTasks.textbox("description").setValue(description2);
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
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("description").value(), description, "Verified existing description for net group: " + groupName);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("nisdomainname").value(), nisdomain, "Verified existing nis domain for net group: " + groupName);
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
			sahiTasks.checkbox(groupname).click();
		}
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	
	/*
	 * Add members
	 * @param sahiTasks
	 * @param groupname - name of net group
	 * @param membertype - host hostgroup user usergroup netgroup
	 * @param names - array of names to add as members
	 * @param button - Enroll or Cancel
	 */
	public static void addMembers(SahiTasks sahiTasks, String groupName, String membertype, String [] names, String button) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("memberhost_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("memberhost_hostgroup").click();
		}
		if (membertype == "user"){
			sahiTasks.link("memberuser_user").click();
		}
		if (membertype == "usergroup"){
			sahiTasks.link("memberuser_group").click();
		}
		if (membertype == "netgroup"){
			sahiTasks.link("member_netgroup").click();
		}
		sahiTasks.link("Enroll").click();
		
		for (String name : names) {
			sahiTasks.checkbox(name).click();
		}
		sahiTasks.span(">>").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * hide already enrolled
	 * @param sahiTasks
	 * @param groupname - name of net group
	 * @param membertype - host hostgroup user usergroup netgroup
	 * @param enrolled - name of already enrolled
	 * @param hide - whether or not to hide the enrolled - YES or NO
	 * @param searchstr - string to filter the search on
	 */
	public static void hideAlreadyEnrolled(SahiTasks sahiTasks, String groupName, String membertype, String enrolled, String hide, String searchstr) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("memberhost_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("memberhost_hostgroup").click();
		}
		if (membertype == "user"){
			sahiTasks.link("memberuser_user").click();
		}
		if (membertype == "usergroup"){
			sahiTasks.link("memberuser_group").click();
		}
		if (membertype == "netgroup"){
			sahiTasks.link("member_netgroup").click();
		}
		
		sahiTasks.link("Enroll").click();
		if( hide == "YES" ){
			sahiTasks.checkbox("hidememb").check();
			sahiTasks.textbox("filter").setValue(searchstr);
			sahiTasks.span("Find").click();
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(enrolled).exists(), "enrolled "+ membertype + " " + enrolled + " is hidden");
		}
		else {
			sahiTasks.checkbox("hidememb").uncheck();
			sahiTasks.textbox("filter").setValue(searchstr);
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(enrolled).exists(), "enrolled "+ membertype + " " + enrolled + " is NOT hidden");
		}
		
		sahiTasks.button("Cancel").click();
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify members
	 * @param sahiTasks
	 * @param groupname - name of net group
	 * @param membertype - host hostgroup user usergroup netgroup
	 * @param names - array of names to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members YES if they should be
	 */
	public static void verifyMembers(SahiTasks sahiTasks, String groupName, String membertype, String [] names, String exists) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("memberhost_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("memberhost_hostgroup").click();
		}
		if (membertype == "user"){
			sahiTasks.link("memberuser_user").click();
		}
		if (membertype == "usergroup"){
			sahiTasks.link("memberuser_group").click();
		}
		if (membertype == "netgroup"){
			sahiTasks.link("member_netgroup").click();
		}
		
		for (String name : names) {
			if (exists == "YES"){
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(name).exists(), membertype + " " + name + " is a member of host group " + groupName);
			}
			else {
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(name).exists(), membertype + " " + name + " is NOT member of host group " + groupName);
			}
		}
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify member of
	 * @param sahiTasks
	 * @param groupname - name of net group
	 * @param names - array of names to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members of the enroll type - YES if they should be
	 */
	public static void verifyMemberOf(SahiTasks sahiTasks, String groupName, String [] names, String type, String exists) {
		sahiTasks.link(groupName).click();
		sahiTasks.link("memberof_netgroup").click();
		sahiTasks.radio(type).click();
		
		for (String name : names) {
			if (exists == "YES"){
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(name).exists(), "Net group " + groupName + " is a memberof net group : " + name);
			}
			else {
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(name).exists(), "Net group " + groupName + " is NOT a memberof net group: " + name);
			}
		}
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Remove net group members
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param membertype - host hostgroup user usergroup netgroup
	 * @param name - names of member to remove
	 * @param button - Delete or Cancel
	 */
	public static void removeMember(SahiTasks sahiTasks, String groupName, String membertype, String name, String button) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("memberhost_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("memberhost_hostgroup").click();
		}
		if (membertype == "user"){
			sahiTasks.link("memberuser_user").click();
		}
		if (membertype == "usergroup"){
			sahiTasks.link("memberuser_group").click();
		}
		if (membertype == "netgroup"){
			sahiTasks.link("member_netgroup").click();
		}
		
		sahiTasks.checkbox(name).click();

		sahiTasks.span("Delete").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Remove net group members
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param membertype - host hostgroup user usergroup netgroup
	 * @param names - array of names to remove as members
	 * @param button - Delete or Cancel
	 */
	public static void removeMember(SahiTasks sahiTasks, String groupName, String membertype, String [] names, String button) {
		sahiTasks.link(groupName).click();
		if (membertype == "host"){
			sahiTasks.link("memberhost_host").click();
		}
		if (membertype == "hostgroup"){
			sahiTasks.link("memberhost_hostgroup").click();
		}
		if (membertype == "user"){
			sahiTasks.link("memberuser_user").click();
		}
		if (membertype == "usergroup"){
			sahiTasks.link("memberuser_group").click();
		}
		if (membertype == "netgroup"){
			sahiTasks.link("member_netgroup").click();
		}
		
		for (String name : names) {
			sahiTasks.checkbox(name).click();
		}
		sahiTasks.span("Delete").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
	}
}