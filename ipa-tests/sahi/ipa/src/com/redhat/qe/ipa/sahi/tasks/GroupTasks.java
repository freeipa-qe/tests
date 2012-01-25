package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 
import com.redhat.qe.ipa.sahi.tests.group.GroupTests;


public class GroupTasks {
	private static Logger log = Logger.getLogger(GroupTasks.class.getName());
	 
	///////////////////////////////// generic actions //////////////////////////////
	private static void addSingle(SahiTasks browser, String nameToCheck)
	{
		browser.link("Add").click(); 
		browser.checkbox(nameToCheck).check();
		browser.span(">>").click();
		browser.button("Add").click();  
	}
	
	private static void addMultiple(SahiTasks browser, String[] namesToCheck)
	{
		browser.link("Add").click(); 
		for (String name:namesToCheck)
			browser.checkbox(name).check();
		browser.span(">>").click();
		browser.button("Add").click();
	}
	
	private static void addViaSearch(SahiTasks browser,String filter, String name) {
		browser.link("Add").click();
		browser.textbox("filter").setValue(filter); 
		browser.span("Find").click();
		browser.checkbox(name).check();
		browser.span(">>").click();
		browser.button("Add").click();  
	}

	private static void deleteSingle(SahiTasks browser, String nameToCheck)
	{
        browser.checkbox(nameToCheck).check();
		browser.span("Delete").click();
		browser.button("Delete").click(); 
	}
	
	private static void deleteMultiple(SahiTasks browser, String[] namesToCheck)
	{
        for (String name:namesToCheck)
			browser.checkbox(name).check();
		browser.span("Delete").click();
		browser.button("Delete").click();  
	}
	///////////////////////////////////////////////////////////////
	public static void addGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupName);
		sahiTasks.textbox("description").setValue(groupDescription);
		sahiTasks.button("Add").click();
	}
	
	public static void deleteGroup(SahiTasks sahiTasks, String groupName) {
		sahiTasks.checkbox(groupName).click();
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}

	public static void deleteGroup(SahiTasks sahiTasks, String [] groupnames) {
		for (String groupname : groupnames) {
			sahiTasks.checkbox(groupname).click();
		}
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	
	/*
	 * Create a Group, the purpose of this is to provide a public interface to other test suite to create a new group.
	 * @param sahiTasks 
	 * @param groupName - user group name
	 * @param groupDescription - group description
	 */
	public static void createGroupService(SahiTasks sahiTasks, String groupName, String groupDescription, String originalURL) {
	// negative to group creation page, but there might be a bug here	
		//TODO: yi: navigate in tests before starting task
		//sahiTasks.navigateTo(GroupTests.groupPage, true);
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupName);
		sahiTasks.textbox("description").setValue(groupDescription);
		sahiTasks.button("Add").click();

	// go back to caller url
		sahiTasks.navigateTo(originalURL, true);

	}//createGroupService
	
	/*
	 * verify members
	 * @param sahiTasks
	 * @param groupname - name of user group
	 * @param membertype - user or usergroup
	 * @param name - name of member to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members YES if they should be
	 */
	public static void verifyMembers(SahiTasks sahiTasks, String groupName, String membertype, String name, String exists) {
		sahiTasks.link(groupName).click();
		if (membertype == "user"){
			sahiTasks.link("member_user").click();
		}
		if (membertype == "usergroup"){
			sahiTasks.link("member_group").click();
		}	

		if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(name).exists(), membertype + " " + name + " is a member of user group " + groupName);
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(name).exists(), membertype + " " + name + " is NOT member of user group " + groupName);
		}

		sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify members
	 * @param sahiTasks
	 * @param groupname - name of user group
	 * @param membertype - user or usergroup
	 * @param names - array of names to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members YES if they should be
	 */
	public static void verifyMembers(SahiTasks sahiTasks, String groupName, String membertype, String [] names, String exists) {
		sahiTasks.link(groupName).click();
		if (membertype == "user"){
			sahiTasks.link("member_user").click();
		}
		if (membertype == "usergroup"){
			sahiTasks.link("member_group").click();
		}	
		for (String name : names) {
			if (exists == "YES"){
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(name).exists(), membertype + " " + name + " is a member of user group " + groupName);
			}
			else {
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(name).exists(), membertype + " " + name + " is NOT member of user group " + groupName);
			}
		}
		sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify member of
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param memberoftype - usergroups, netgroups, roles, hbacrules or sudorules
	 * @param names - array of group or rule names to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members of the enroll type - YES if they should be
	 */
	public static void verifyMemberOf(SahiTasks sahiTasks, String groupName, String memberoftype, String [] grprulenames, String type, String exists) {
		sahiTasks.link(groupName).click();
		if (memberoftype == "usergroups"){
			sahiTasks.link("memberof_hostgroup").click();
		}
		if (memberoftype == "netgroups"){
			sahiTasks.link("memberof_netgroup").click();
		}
		if (memberoftype == "roles"){
			sahiTasks.link("memberof_rule").click();
		}
		if (memberoftype == "hbacrules"){
			sahiTasks.link("memberof_hbacrule").click();
		}
		if (memberoftype == "sudorules"){
			sahiTasks.link("memberof_sudorule").click();
		}
		sahiTasks.radio(type).click();
		
		for (String grprulename : grprulenames) {
			if (exists == "YES"){
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(grprulename).exists(), "User group " + groupName + " is a memberof " + memberoftype + ": " + grprulename);
			}
			else {
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(grprulename).exists(), "User group " + groupName + " is NOT a memberof " + memberoftype + ": " + grprulename);
			}
		}
		sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify member of
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param memberoftype - usergroups, netgroups, roles, hbacrules or sudorules
	 * @param name - name of rule or group that user group to verify member of
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members of the enroll type - YES if they should be
	 */
	public static void verifyMemberOf(SahiTasks sahiTasks, String groupName, String memberoftype, String grprulename,
			String type, String exists, boolean onPage) {
		if (!onPage) 
			sahiTasks.link(groupName).click();
		if (memberoftype == "usergroups"){
			sahiTasks.link("memberof_hostgroup").click();
		}
		if (memberoftype == "netgroups"){
			sahiTasks.link("memberof_netgroup").click();
		}
		if (memberoftype == "roles"){
			sahiTasks.link("memberof_rule").click();
		}
		if (memberoftype == "hbacrules"){
			sahiTasks.link("memberof_hbacrule").click();
		}
		if (memberoftype == "sudorules"){
			sahiTasks.link("memberof_sudorule").click();
		}
		sahiTasks.radio(type).click();
		
		if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(grprulename).exists(), "User group " + groupName + " is a memberof " + memberoftype + ": " + grprulename);
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(grprulename).exists(), "User group " + groupName + " is NOT a memberof " + memberoftype + ": " + grprulename);
		}

		if (!onPage) 
			sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
		
	}

	public static void add_UserGroup(SahiTasks browser, String groupName, String groupDescription, String gid, String isPosix){
		//browser.link("Add").click();
		browser.span("Add").click();
		browser.textbox("cn").setValue(groupName);
		browser.textarea("description").setValue(groupDescription); 
		if (! gid.equals(""))
			browser.textbox("gidnumber").setValue(gid);
		
		if (isPosix.equals("nonPosix")){
			browser.checkbox("nonposix").click();
		}
		browser.button("Add").click();
	}
	
	public static void add_and_add_another_UserGroup(
							SahiTasks browser, 
							String firstGroupName, String firstGroupDescription, String firstGid, String first_isPosix,
							String secondGroupName, String secondGroupDescription, String secondGid, String second_isPosix){
		
		//browser.link("Add").click();
		browser.span("Add").click();
		browser.textbox("cn").setValue(firstGroupName);
		browser.textarea("description").setValue(firstGroupDescription);
		if (! firstGid.equals(""))
			browser.textbox("gidnumber").setValue(firstGid);
		if (first_isPosix.equals("nonPosix")){
			browser.checkbox("nonposix").click();
		}
		
		// click Add and Add Another to create a new group without leave the current dialog, 
		// this the main purpose of this test case
		browser.button("Add and Add Another").click();	
		browser.textbox("cn").setValue(secondGroupName);
		browser.textarea("description").setValue(secondGroupDescription);
		if (! secondGid.equals(""))
			browser.textbox("gidnumber").setValue(secondGid);
		if (second_isPosix.equals("nonPosix")){
			browser.checkbox("nonposix").click();
		}
		
		// finally cancel to go back to main user group page
		browser.button("Add and Add Another").click();
		browser.button("Cancel").click();
	}
	
	public static void add_and_edit_UserGroup(SahiTasks browser, String groupName, String groupDescription, String gid, String isPosix){
		browser.link("Add").click();

		browser.textbox("cn").setValue(groupName);
		browser.textarea("description").setValue(groupDescription);
		browser.textbox("gidnumber").setValue(gid);
		if (isPosix.equals("nonPosix")){
			browser.checkbox("nonposix").click();
		} 
		browser.button("Add and Edit").click();
		
		// do some minimum editing to ensure page navigation is what we are intend to do
		browser.link("Settings").click();
		browser.textarea("description").setValue("verify get into edit mode: " + groupDescription);
		browser.link("Update").click();
		
		// go back to use group list page
		//browser.link("User Groups").in(browser.div("content")).click();
	}
	
	public static void add_then_cancel_UserGroup(SahiTasks browser, String groupName, String groupDescription, String gid, String isPosix){
		browser.link("Add").click();

		browser.textbox("cn").setValue(groupName);
		browser.textarea("description").setValue(groupDescription);
		browser.textbox("gidnumber").setValue(gid);
		if (isPosix.equals("isPosix")){
			browser.checkbox("nonposix").click();
		} 
		browser.button("Cancel").click();
	}

	/*
	 * Add group members
	 * @param sahiTasks
	 * @param groupname - name of user group
	 * @param membertype - user or usergroup
	 * @param name - name to add as member
	 * @param button - Enroll or Cancel
	 */
	public static void addMembers(SahiTasks sahiTasks, String groupName, String membertype, String name, String button) {
		sahiTasks.link(groupName).click();
		if (membertype == "user"){
			sahiTasks.link("member_user").click();
		}
		if (membertype == "usergroup"){
			sahiTasks.link("memberof_group").click();
		}
		
		sahiTasks.radio("direct").click();
		sahiTasks.link("Enroll").click();
		
		sahiTasks.checkbox(name).click();
		
		sahiTasks.span(">>").click();
		sahiTasks.button(button).click();
		sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
	 }
	
	
	/*
	 * Remove user members
	 * @param sahiTasks
	 * @param groupname - name of group
	 * @param name - names to remove as member
	 * @param button - Delete or Cancel
	 */
	public static void removeMembers(SahiTasks sahiTasks, String groupName, String membertype, String name, String button) {
		sahiTasks.link(groupName).click();
		if (membertype == "user"){
			sahiTasks.link("member_user").click();
		}
		if (membertype == "usergroup"){
			sahiTasks.link("member_group").click();
		}
		
		sahiTasks.radio("direct").click();
		sahiTasks.checkbox(name).click();

		sahiTasks.span("Delete").click();
		sahiTasks.button(button).click();
		sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
	}

	public static void modifyGroup_enroll_user_single(SahiTasks browser, String groupName, String userName) {
        addSingle(browser, userName);
		//browser.link("Add").click();
		//browser.checkbox(userName).check();
		//browser.span(">>").click();
		//browser.button("Add").click(); 
	}

	public static void modifyGroup_remove_user_single(SahiTasks browser, String groupName, String userName) {
        deleteSingle(browser, userName);
		//browser.checkbox(userName).check();
		//browser.span("Delete").click();
		//browser.button("Delete").click(); 
	}
	
	public static void modifyGroup_enroll_user_multiple(SahiTasks browser, String groupName, String[] users) {
		browser.link("Add").click();
        addMultiple(browser, users);
		//for (String userName:users)
		//	browser.checkbox(userName).check();
		//browser.span(">>").click();
		//browser.button("Add").click();  
	}

	public static void  modifyGroup_remove_user_multiple(SahiTasks browser, String groupName, String[] users) {
        deleteMultiple(browser, users);
		//for (String userName:users)
		//	browser.checkbox(userName).check();
		//browser.span("Delete").click();
		//browser.button("Delete").click(); 
	}
	
	public static void modifyGroup_enroll_user_viasearch(SahiTasks browser,String groupName, String userName) {
        addViaSearch(browser, userName, userName);
		//browser.link("Add").click();
		//browser.textbox("filter").setValue(userName); 
		//browser.span("Find").click();
		//browser.checkbox(userName).check();
		//browser.span(">>").click();
		//browser.button("Add").click();  
	}

	public static void modifyGroup_enroll_user_cancel(SahiTasks browser,String groupName, String userName) {
		browser.link("Add").click();
		browser.checkbox(userName).check();
		browser.span(">>").click();
		browser.button("Cancel").click(); 
	}

	public static void modifyGroup_enroll_member_group_single(SahiTasks browser,String groupName, String childGroup) {
		browser.link("member_group").click();
        addSingle(browser, childGroup);
		//browser.link("Add").click(); 
		//browser.checkbox(childGroup).check();
		//browser.span(">>").click();
		//browser.button("Add").click();  
	}

	public static void modifyGroup_remove_member_group_single(SahiTasks browser,String groupName, String childGroup) {
		browser.link("member_group").click(); 
        deleteSingle(browser, childGroup);
		//browser.checkbox(childGroup).check();
		//browser.span("Delete").click();
		//browser.button("Delete").click();  
	}
	
	public static void modifyGroup_enroll_member_group_multiple(SahiTasks browser,String groupName, String[] childGroups) {
		browser.link("member_group").click();
		browser.link("Add").click(); 
		for (String childGroup:childGroups)
			browser.checkbox(childGroup).check();
		browser.span(">>").click();
		browser.button("Add").click();  
	}

	public static void modifyGroup_remove_member_group_multiple(SahiTasks browser,String groupName, String[] childGroups) {
		browser.link("member_group").click(); 
        deleteMultiple(browser, childGroups);
		//for (String childGroup:childGroups)
		//	browser.checkbox(childGroup).check();
		//browser.span("Delete").click();
		//browser.button("Delete").click();  
	}
	
	public static void modifyGroup_enroll_member_group_viasearch(SahiTasks browser,String groupName, String childGroup) {
		browser.link("member_group").click();
        addViaSearch(browser, childGroup, childGroup);
		//browser.link("Add").click();
		//browser.textbox("filter").setValue(childGroup); 
		//browser.span("Find").click();
		//browser.checkbox(childGroup).check();
		//browser.span(">>").click();
		//browser.button("Add").click();  
	}
	
	public static void modifyGroup_enroll_memberof_group_single(SahiTasks browser,String groupName, String childGroup) {
		browser.link("memberof_group").click();
		browser.link("Add").click(); 
		browser.checkbox(childGroup).check();
		browser.span(">>").click();
		browser.button("Add").click();  
	}

	public static void modifyGroup_remove_memberof_group_single(SahiTasks browser,String groupName, String childGroup) {
		browser.link("memberof_group").click(); 
        deleteSingle(browser, childGroup);
		//browser.checkbox(childGroup).check();
		//browser.span("Delete").click();
		//browser.button("Delete").click();  
	}
	
	public static void modifyGroup_enroll_memberof_group_multiple(SahiTasks browser,String groupName, String[] childGroups) {
		browser.link("memberof_group").click();
		browser.link("Add").click(); 
		for (String childGroup:childGroups)
			browser.checkbox(childGroup).check();
		browser.span(">>").click();
		browser.button("Add").click();  
	}
	
	public static void modifyGroup_remove_memberof_group_multiple(SahiTasks browser,String groupName, String[] childGroups) {
		browser.link("memberof_group").click(); 
        deleteMultiple(browser, childGroups);
		//for (String childGroup:childGroups)
		//	browser.checkbox(childGroup).check();
		//browser.span("Delete").click();
		//browser.button("Delete").click();  
	}
	public static void modifyGroup_enroll_memberof_group_viasearch(SahiTasks browser,String groupName, String childGroup) {
		browser.link("memberof_group").click();
        addViaSearch(browser, childGroup, childGroup);
		//browser.link("Add").click();
		//browser.textbox("filter").setValue(childGroup); 
		//browser.span("Find").click();
		//browser.checkbox(childGroup).check();
		//browser.span(">>").click();
		//browser.button("Add").click();  
	}

	public static void modifyGroup_settings(SahiTasks browser,String description, String gid) {
		browser.link("Settings").click();
		browser.textarea("description").setValue(description);
		browser.textbox("gidnumber").setValue(gid);
		browser.span("Update").click();
	}

	public static void modifyGroup_settings_button_reset(SahiTasks browser,	String description, String gid) {
		browser.link("Settings").click();
		browser.textarea("description").setValue("for test only, this test should not be accept since we will click 'undo'"); 
		browser.textbox("gidnumber").setValue("for test only, it will go away");
		browser.span("Reset").click(); 
	}
	
	public static void modifyGroup_settings_button_undo(SahiTasks browser,	String description, String gid) {
		browser.link("Settings").click();
		browser.textarea("description").setValue("for test only, this test should not be accept since we will click 'undo'");
		browser.span("undo").click();
		browser.textbox("gidnumber").setValue("for test only, it will go away");
		browser.span("undo").click(); 
	}
	
	public static void modifyGroup_settings_negative_gid(SahiTasks browser,	String gid) {
		browser.link("Settings").click(); 
		browser.textbox("gidnumber").setValue(gid); 
	}
	
	public static void modifyGroup_settings_negative_desc(SahiTasks browser, String desc){
		browser.link("Settings").click();
		browser.textarea("description").setValue(desc);
	}

	public static void addNetGroup_Single(SahiTasks browser, String netGroupName) {
		browser.link("memberof_netgroup").click();
		addSingle(browser, netGroupName);
	}


	public static void addNetGroup_Multiple(SahiTasks browser,String[] netGroupNames) {
		browser.link("memberof_netgroup").click();
		addMultiple(browser, netGroupNames);
	}

	public static void addNetGroup_ViaSearch(SahiTasks browser,	String filter, String groupNames) {
		browser.link("memberof_netgroup").click();
		addViaSearch(browser, filter, groupNames);
	}

	public static void deleteNetGroup_Single(SahiTasks browser,String netGroupName) {
		browser.link("memberof_netgroup").click();
		Assert.assertTrue(browser.link(netGroupName).exists(), "netgroup name should in the list before deleted");
		deleteSingle(browser, netGroupName);
	}
	
	public static void deleteNetGroup_Multiple(SahiTasks browser,String[] netGroupNames) {
		browser.link("memberof_netgroup").click();
		for (String name:netGroupNames)
			Assert.assertTrue(browser.link(name).exists(), "netgroup exist before delete");
		deleteMultiple(browser, netGroupNames);
	}

	public static void addRole_Single(SahiTasks browser, String role) {
		browser.link("memberof_role").click();
		addSingle(browser, role);
	}


	public static void addRole_Multiple(SahiTasks browser,String[] roles) {
		browser.link("memberof_role").click();
		addMultiple(browser, roles);
	}

	public static void addRole_ViaSearch(SahiTasks browser,	String filter, String role) {
		browser.link("memberof_role").click();
		addViaSearch(browser, filter, role);
	}

	public static void deleteRole_Single(SahiTasks browser,String role) {
		browser.link("memberof_role").click();
		Assert.assertTrue(browser.link(role.toLowerCase()).exists(), "role should in the list before deleted");
		deleteSingle(browser, role.toLowerCase());
	}
	
	public static void deleteRole_Multiple(SahiTasks browser,String[] roles) {
		browser.link("memberof_role").click(); 
		String[] lowerCaseRoles = new String[roles.length];
		int i=0;
		for (String name:roles)
		{
			String lowerCaseRoleName = name.toLowerCase();
			lowerCaseRoles[i] = lowerCaseRoleName;
			i++;
			Assert.assertTrue(browser.link(lowerCaseRoleName).exists(), "roles exist before delete");
		}
		deleteMultiple(browser, lowerCaseRoles);
	}
}//class Group Tasks

