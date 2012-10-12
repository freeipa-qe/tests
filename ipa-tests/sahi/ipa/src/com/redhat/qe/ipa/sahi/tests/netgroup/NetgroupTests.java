package com.redhat.qe.ipa.sahi.tests.netgroup;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.NetgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.PrivilegeTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

public class NetgroupTests extends SahiTestScript{

	private String domain = CommonTasks.ipadomain;
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	private String devwebserver = "webserver-dev";
	private String qewebserver = "webserver-qe";
	private String devhost = "laptop-dev";
	private String qehost = "laptop-qa";
	private String engwebserver = "webserver-eng";
	
	private String [] hostnames = {devwebserver, qewebserver, devhost, qehost, engwebserver};
	
	private String devgroup = "development";
	private String qegroup = "quality";
	private String enggroup = "engineering";
	
	private String [] netgroups = {devgroup, qegroup, enggroup, "bug815494_netgroup", "bug814785_netgroup", "netgroupmembership1", "netgroupmembership2", "netgroupmembership3"};
	private String [] nestedmembers = {devgroup, qegroup};
	
	private String [] devhosts = {devwebserver + "." + domain, devhost + "." + domain};
	private String [] qehosts = {qewebserver + "." + domain, qehost + "." + domain};
	private String [] enghosts = {engwebserver + "." + domain};
	
	private String hostgroup1A = "hostgroup1a";
	private String hostgroup1B = "hostgroup1b";
	private String hostgroup2 = "hostgroup2";
	
	private String [] hostgroups = {hostgroup1A, hostgroup1B, hostgroup2};
	
	private String [] grp1members = {hostgroup1A, hostgroup1B};
	private String [] grp2members = {hostgroup2};
	
	private String usergroup1A = "group1a";
	private String usergroup1B = "group1b";
	private String usergroup2 = "group2";
	
	private String [] ugroup1members = {usergroup1A, usergroup1B};
	private String [] ugroup2members = {usergroup2};
	
	private String [] usergroups = {usergroup1A, usergroup1B, usergroup2};
	
	private String user1 = "devuser1";
	private String user2 = "devuser2";
	private String user3 = "qeuser";
	private String user4 = "bug815494_user";
	
	private String [] devusers = {user1, user2};
	private String [] qeusers = {user3};
	
	private String [] users = {user1, user2, user3, user4};
	
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks.setStrictVisibilityCheck(true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&netgroup-facet=search" ;
		
		//add hosts for host group members
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		for (String hostname : hostnames) {
			HostTasks.addHost(sahiTasks, hostname, commonTasks.getIpadomain(), "");
		}
		
		//add host groups for net group members
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		for (String hostgroup : hostgroups) {
			String description = hostgroup + " description";
			HostgroupTasks.addHostGroup(sahiTasks, hostgroup, description, "Add");
		}
		
		//add user groups for net group members 
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		for (String groupname : usergroups){
			String groupDescription = groupname + " description";
			GroupTasks.addGroup(sahiTasks, groupname, groupDescription);
		}
		
		//add users for net group members 
		sahiTasks.navigateTo(commonTasks.userPage, true);
		for (String username : users){
			UserTasks.createUser(sahiTasks, username, username, username, "Add");
		} 
		
		//add net groups
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		for (String netgroup : netgroups) {
			String description = netgroup + " group";
			NetgroupTasks.addNetGroup(sahiTasks, netgroup, description, "Add");
		}
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	
		//delete hosts
		final String [] delhosts = {devwebserver + "." + domain, qewebserver + "." + domain, devhost + "." + domain, qehost + "." + domain, engwebserver + "." + domain };
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		HostTasks.deleteHost(sahiTasks, delhosts);
		
		//delete host groups
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		HostgroupTasks.deleteHostgroup(sahiTasks, hostgroups);
		
		//delete user groups
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		GroupTasks.deleteGroup(sahiTasks, usergroups);
		
		//delete users
		sahiTasks.navigateTo(commonTasks.userPage, true);
		for (String username : users){
			UserTasks.deleteUser(sahiTasks, username);
		}
		
		//delete net groups
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		NetgroupTasks.deleteNetgroup(sahiTasks, netgroups);
	}
	
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			//CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		}		
	}
	
	/*
	 * Add net group positive tests
	 */
	@Test (groups={"addNetGroupTests"}, dataProvider="getAddNetGroupTestObjects")	
	public void testNetGroupAdd(String testName, String groupName, String description, String button) throws Exception {
		//verify host group doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify net group " + groupName + " doesn't already exist");
		
		//add new host group
		NetgroupTasks.addNetGroup(sahiTasks, groupName, description, button);
		
		String lowercase = groupName.toLowerCase();

		if (button == "Cancel"){
			//verify net group was not added
			Assert.assertFalse(sahiTasks.link(lowercase).exists(), "Verify net group " + groupName + " was not added");
		}
		else {
			Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify net group " + groupName + " was added successfully");
		}
	}
	
	/*
	 * Delete net groups positive tests
	 */
	@Test (groups={"deleteNetGroupTests"}, dataProvider="getDeleteNetGroupTestObjects",  dependsOnGroups="addNetGroupTests")	
	public void testNetGroupDelete(String testName, String groupName, String button) throws Exception {
		// verify host group exists
		String lowercase = groupName.toLowerCase();
		Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify net group " + groupName + " exists");
		
		//delete net group
		NetgroupTasks.deleteNetgroup(sahiTasks, lowercase, button);
		
		if (button == "Cancel"){
			Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify net group " + groupName + " still exists");
		}
		else {
			Assert.assertFalse(sahiTasks.link(lowercase).exists(), "Verify net group " + groupName + " was deleted successfully");
		}
	}
	
	/*
	 * Add and Add Another net group
	 */
	@Test (groups={"addAndAddAnotherNetGroupTests"}, dataProvider="getAddAndAddAnotherNetGroupTestObjects")	
	public void testNetGroupAddAndAddAnother(String testName, String groupName1, String groupName2, String groupName3) throws Exception {
		
		//verify host group doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName1).exists(), "Verify net group " + groupName1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(groupName2).exists(), "Verify net group " + groupName2 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(groupName3).exists(), "Verify net group " + groupName3 + " doesn't already exist");
		
		//add new host group
		HostgroupTasks.addAndAddAnotherHostGroup(sahiTasks, groupName1, groupName2, groupName3);
	
		//verify host group exists
		Assert.assertTrue(sahiTasks.link(groupName1).exists(), "Verify net group " + groupName1 + " exists");
		Assert.assertTrue(sahiTasks.link(groupName2).exists(), "Verify net group " + groupName2 + " exists");
		Assert.assertTrue(sahiTasks.link(groupName3).exists(), "Verify net group " + groupName3 + " exists");
	
	}
	
	/*
	 * Delete multiple net groups positive tests
	 */
	@Test (groups={"deleteMultipleNetGroupTests"}, dataProvider="getAddAndAddAnotherNetGroupTestObjects",  dependsOnGroups={"addAndAddAnotherNetGroupTests", "searchNetgroupTests", "searchNetgroupNegativeTests"})	
	public void testNetGroupDeleteMultiple(String testName, String groupName1, String groupName2, String groupName3) throws Exception {
		//verify host group exists
		Assert.assertTrue(sahiTasks.link(groupName1).exists(), "Verify net group " + groupName1 + " exists");
		Assert.assertTrue(sahiTasks.link(groupName2).exists(), "Verify net group " + groupName2 + " exists");
		Assert.assertTrue(sahiTasks.link(groupName3).exists(), "Verify net group " + groupName3 + " exists");
		
		String [] groupnames = {groupName1, groupName2, groupName3};
		//delete net group
		NetgroupTasks.deleteNetgroup(sahiTasks, groupnames);

		//verify net group doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName1).exists(), "Verify net group " + groupName1 + " was deleted successfully");
		Assert.assertFalse(sahiTasks.link(groupName2).exists(), "Verify net group " + groupName2 + " was deleted successfully");
		Assert.assertFalse(sahiTasks.link(groupName3).exists(), "Verify net group " + groupName3 + " was deleted successfully");
		
	}
	
	/*
	 * Add and edit net group settings
	 */
	@Test (groups={"addAndEditNetGroupSettingsTest"}, dataProvider="getAddAndEditNetGroupTestObjects")	
	public void testnetGroupAddAndEdit(String testName, String groupName, String description1, String description2, String nisdomain) throws Exception {
		//verify net group doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify net group " + groupName + " doesn't already exist");
		
		//add new net group
		NetgroupTasks.addAndEditNetGroup(sahiTasks, groupName, description1, description2, nisdomain);
		
		//verify the net group exists
		Assert.assertTrue(sahiTasks.link(groupName).exists(), "Verify net group " + groupName + " exists");
		
		//verify the net group setting
		NetgroupTasks.verifyNetGroupSettings(sahiTasks, groupName, description2, nisdomain);
		
		//clean up delete net group
		NetgroupTasks.deleteNetgroup(sahiTasks, groupName, "Delete");

	}
	
	/*
	 * Unsaved changes tests
	 */
	@Test (groups={"netGroupUnsavedChangesTests"}, dataProvider="getNetGroupUnsavedChangesTestObjects")
	public void testnetGroupUnsavedChanges(String testName, String cn, String description, String action) throws Exception {
		
		NetgroupTasks.unsavedChangesNetgroup(sahiTasks, cn, description, action);
		if (action.equals("Update")) {
			NetgroupTasks.modifyNetgroupDescription(sahiTasks, cn, description);
		}
	}
		
	
		
	
	/*
	 * Members tests
	 */
	@Test (groups={"netGroupMembersUndoRefreshResetUpdateTests"}, dataProvider="getNetGroupUndoRefreshResetUpdateTestObjects")
	public void testnetGroupMembersUndoRefreshResetUpdate(String testName, String cn, String category, String action) throws Exception {
		
		NetgroupTasks.undoResetUpdateNetgroup(sahiTasks, cn, category, action);
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		if (action.equals("Update")) {
			NetgroupTasks.modifyNetgroupMembership(sahiTasks, cn, category);
		}
	}
		
	
	/*
	 * Expand/Collapse details of a Netgroup
	 */
	@Test (groups={"netgroupExpandCollapseTests"}, description="Expand and Collapse details of a Netgroup", 
			dataProvider="getNetgroupExpandCollapseTestObjects")
	public void testNetgroupExpandCollapse(String testName, String cn) throws Exception {
		
		NetgroupTasks.expandCollapseNetgroup(sahiTasks, cn);		
		
	}
	
	
	/*
	 * Add user member details of a Netgroup
	 */
	@Test (groups={"netgroupMemberTests"}, description="Add a member to a Netgroup", 
			dataProvider="getNetgroupMemberTestObjects")
	public void testNetgroupMember(String testName, String cn, String section, String type, String name1, String name2, String button, String action) throws Exception {
		String names[] = {name1, name2};
		NetgroupTasks.addMembers(sahiTasks, cn, section, type, names, button, action);	
		//verify
		NetgroupTasks.verifyMembers(sahiTasks, cn, section, type, names, button, action);
		//undo the changes for next test
		if (button.equals("All"))
			NetgroupTasks.modifyNetgroupMembership(sahiTasks, cn, section.toLowerCase()+"category");
		if (button.equals("Add") && action.equals("Add")) 
			NetgroupTasks.deleteUserMembers(sahiTasks, cn, section, type, names, "Delete");
	}
	
	/*
	 * search hosts
	 */
	@Test (groups={"searchNetgroupTests"}, dataProvider="getNetgroupSearchTestObjects",  dependsOnGroups={"addAndAddAnotherNetGroupTests"})	
	public void testNetgroupSearch(String testName, String netgroup1, String netgroup2) throws Exception {
		String [] netgroups = {netgroup1, netgroup2};
		for (String netgroup : netgroups) {
			
		//search host
		NetgroupTasks.searchNetgroup(sahiTasks, netgroup);
		
		//verify host was deleted
		
		Assert.assertTrue(sahiTasks.link(netgroup).exists(), "Found  " + netgroup + "  successfully");
		
		
		NetgroupTasks.clearSearch(sahiTasks);
		}
	}
	
	/*
	 * search hosts negative
	 */
	@Test (groups={"searchNetgroupNegativeTests"}, dataProvider="getNetgroupSearchNegativeTestObjects",  dependsOnGroups={"addAndAddAnotherNetGroupTests"})	
	public void testNetgroupSearchNegative(String testName, String netgroup) throws Exception {
		
		//search host
		NetgroupTasks.searchNetgroup(sahiTasks, netgroup);
		
		//verify host was deleted
		Assert.assertFalse(sahiTasks.link(netgroup).exists(), netgroup + " does not exist - search successfully");
		NetgroupTasks.clearSearch(sahiTasks);
	}
	
	
	/*
	 * Bug 815494
	 */
	@Test (groups={"NetgroupUser_bug815494"}, dataProvider="getNetgroupUser_bug815494TestObjects")	
	public void testNetgroupUser_bug815494(String testName, String groupName) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		String names[]={user4};
		NetgroupTasks.addMembers(sahiTasks, groupName, "User", "Users", names, "Add", "Add");
		sahiTasks.link(groupName).click();
		Assert.assertTrue(sahiTasks.link(user4).exists(),"User " + user4 + " successfully added");
		sahiTasks.link("Netgroups").near(sahiTasks.span(groupName)).click();
	}
	
	/*
	 * Bug 814785
	 */
	@Test (groups={"NetgroupEdit_bug814785"}, dataProvider="getNetgroupEdit_bug814785TestObjects")	
	public void testNetgroupEdit_bug814785(String testName, String groupName, String newDescription) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		sahiTasks.link(groupName).click();
		sahiTasks.textarea("description").setValue(newDescription);
		sahiTasks.link("Netgroups").near(sahiTasks.span(groupName)).click();
		sahiTasks.button("Update").click();
		Assert.assertTrue(sahiTasks.link(groupName).exists(), "Redirected back to Netgroup listing page");
		sahiTasks.link(groupName).click();
		Assert.assertEquals(sahiTasks.textarea("description").getValue(), newDescription, "Netgroup description updated successfully");
		sahiTasks.link("Netgroups").near(sahiTasks.span(groupName)).click();
	}
	
	/*
	 * Bug 814785
	 */
	@Test (groups={"NetgroupMembership"}, dataProvider="getNetgroupMembershipTestObjects")	
	public void testNetgroupMembership(String testName, String groupName1, String groupName2, String groupName3) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		sahiTasks.link(groupName1).click();
		sahiTasks.link("member_netgroup").click();
		String groupNames[]={groupName2};
		NetgroupTasks.addNetgroupMember(sahiTasks, groupNames, "Add");
		
		sahiTasks.link(groupName1).click();
		sahiTasks.link("memberof_netgroup").click();
		String groupNames1[]={groupName3};
		NetgroupTasks.addNetgroupMember(sahiTasks, groupNames1, "Add");
		
		sahiTasks.link(groupName1).click();
		sahiTasks.link("member_netgroup").click();
		for(String name:groupNames)
			Assert.assertTrue(sahiTasks.link(name).exists(), groupName1 + " has members " + name);
		
		sahiTasks.link("memberof_netgroup").click();
		for(String name:groupNames1)
			Assert.assertTrue(sahiTasks.link(name).exists(), groupName1 + " is a member of " + name);
		
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();	
		
		sahiTasks.link(groupName2).click();
		sahiTasks.link("memberof_netgroup").click();
		for(String name:groupNames1)
			Assert.assertTrue(sahiTasks.link(name).exists(), groupName2 + " is a member of " + name);
		Assert.assertTrue(sahiTasks.link(groupName1).exists(), groupName2 + " is a member of " + groupName1);
		
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
		
		sahiTasks.link(groupName3).click();
		sahiTasks.link("member_netgroup").click();
		Assert.assertTrue(sahiTasks.link(groupName1).exists(), groupName3 + " has members " + groupName1);
		sahiTasks.radio("indirect").click();
		for(String name:groupNames)
			Assert.assertTrue(sahiTasks.link(name).exists(), groupName3 + " has indirect members " + name + ",");
		sahiTasks.link("Netgroups").in(sahiTasks.div("content")).click();
			
	}
		
	

/*******************************************************
 ************      DATA PROVIDERS     ******************
 *******************************************************/

	/*
	 * Data to be used when adding net groups 
	 */
	@DataProvider(name="getAddNetGroupTestObjects")
	public Object[][] getAddNetGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddNetGroupTestObjects());
	}
	protected List<List<Object>> createAddNetGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname						groupanme			description					button
		ll.add(Arrays.asList(new Object[]{ 		"addnetgroup_cancel",			"newnetgroup",		"this is a new netgroup",	 "Cancel" } ));
		ll.add(Arrays.asList(new Object[]{ 		"addnetgroup_mixedcase",		"NewNetGroup",		"this is a new netgroup",	 "Add" } ));  
		ll.add(Arrays.asList(new Object[]{ 		"addnetgroup_longname",			"thisisanetgroupwithaveryveryveryveryveryveryveryveryverylongname",		"Net group with long name",	 "Add" } ));
		ll.add(Arrays.asList(new Object[]{ 		"addnetgroup_longdesc",			"longdescription",		"thisisanetgroupwithaveryveryveryveryveryveryveryveryveryveryveryveryveryverylongdescription",	 "Add" } ));
	//	ll.add(Arrays.asList(new Object[]{ 		"addnetgroup_bz815481",			"a",				"this is a new netgroup with one letter name",	 "Add" } ));  
		return ll;	
	}
	
	/*
	 * Data to be used when deleting net groups 
	 */
	@DataProvider(name="getDeleteNetGroupTestObjects")
	public Object[][] getDeleteNetGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDeleteNetGroupTestObjects());
	}
	protected List<List<Object>> createDeleteNetGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname							groupanme																button
		ll.add(Arrays.asList(new Object[]{ 		"delete_netgroup_cancel",			"NewNetGroup",															"Cancel" } ));  
		ll.add(Arrays.asList(new Object[]{ 		"delete_netgroup_cancel",			"NewNetGroup",															"Delete" } ));
		ll.add(Arrays.asList(new Object[]{ 		"delete_netgroup_longname",			"thisisanetgroupwithaveryveryveryveryveryveryveryveryverylongname", 	"Delete" } ));
		ll.add(Arrays.asList(new Object[]{ 		"delete_netgroup_longdesc",			"longdescription",		 											"Delete" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when add and add another net groups and delete multiple
	 */
	@DataProvider(name="getAddAndAddAnotherNetGroupTestObjects")
	public Object[][] getAddAndAddAnotherNetGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddAndAddAnotherNetGroupTestObjects());
	}
	protected List<List<Object>> createAddAndAddAnotherNetGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname									groupanme1					groupname2			groupname3
		ll.add(Arrays.asList(new Object[]{ 		"add_and_add_another_then_del_multiple",	"thisisgroupone",		"marketing",	 	"sales" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when adding and editing net groups
	 */
	@DataProvider(name="getAddAndEditNetGroupTestObjects")
	public Object[][] getAddAndEditNetGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddAndEditNetGroupTestObjects());
	}
	protected List<List<Object>> createAddAndEditNetGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname						groupanme1			description1				description2						nisdomain
		ll.add(Arrays.asList(new Object[]{ 		"add_and_edit_setting",			"engineering2",		"engineering net group",	"red hat engineering net group",  	"new.nis.domain"} ));
		return ll;	
	}
	
	/*
	 * Data to be used when updating members
	 */
	@DataProvider(name="getNetGroupUndoRefreshResetUpdateTestObjects")
	public Object[][] getNetGroupUndoRefreshResetUpdateTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetGroupUndoRefreshResetUpdateTestObjects());
	}
	protected List<List<Object>> createNetGroupUndoRefreshResetUpdateTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					netgroup		category			Action	
		ll.add(Arrays.asList(new Object[]{ 		"host_memberships_undo",	"engineering",	"hostcategory",		"undo"	 } ));
		ll.add(Arrays.asList(new Object[]{ 		"host_memberships_reset",	"engineering",	"hostcategory",		"Reset"	 } ));	
		ll.add(Arrays.asList(new Object[]{ 		"host_memberships_refresh",	"engineering",	"hostcategory",		"Refresh"	 } ));
		ll.add(Arrays.asList(new Object[]{ 		"host_memberships_update",	"engineering",	"hostcategory",		"Update" }	));
		ll.add(Arrays.asList(new Object[]{ 		"user_memberships_undo",	"engineering",	"usercategory",		"undo"	 } ));
		ll.add(Arrays.asList(new Object[]{ 		"user_memberships_reset",	"engineering",	"usercategory",		"Reset"	 } ));	
		ll.add(Arrays.asList(new Object[]{ 		"user_memberships_refresh",	"engineering",	"usercategory",		"Refresh"	 } ));
		ll.add(Arrays.asList(new Object[]{ 		"user_memberships_update",	"engineering",	"usercategory",		"Update" }	));
		return ll;	
	}
	
	/*
	 * Data to be used when not saving changes
	 */
	@DataProvider(name="getNetGroupUnsavedChangesTestObjects")
	public Object[][] getNetGroupUnsavedChangesTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetGroupUnsavedChangesTestObjects());
	}
	protected List<List<Object>> createNetGroupUnsavedChangesTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname						netgroup		description			Action	
		ll.add(Arrays.asList(new Object[]{ 		"description_Cancel",			"engineering",	"engineering group",		"Cancel"	 } ));
		ll.add(Arrays.asList(new Object[]{ 		"description_Reset",			"engineering",	"engineering group",		"Reset"	 } ));	
	//	ll.add(Arrays.asList(new Object[]{ 		"description_Update_bz814785",	"engineering",	"engineering group",		"Update"	 } ));
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding user members
	 */
	@DataProvider(name="getNetgroupMemberTestObjects")
	public Object[][] getNetgroupMemberTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetgroupMemberTestObjects());
	}
	protected List<List<Object>> createNetgroupMemberTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		// 									testName						 cn		 		section		type			name1							name2						button		action	
		ll.add(Arrays.asList(new Object[]{ 	"add_user_netgroup",			"engineering",	"User",		"Users",		"devuser1", 					"devuser2",					"Add",		"Add"		 } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_user_netgroup_cancel",		"engineering",	"User",		"Users",		"qeuser",						"",							"Add",		"Cancel"	 } ));	
		ll.add(Arrays.asList(new Object[]{ 	"add_user_netgroup_all",		"engineering",	"User",		"Users",		"",								"",							"All", 		"Update"	 } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_usergroup_netgroup",		"engineering",	"User",		"User Groups",	"group1a", 						"group1b",					"Add",		"Add"		 } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_usergroup_netgroup_cancel","engineering",	"User",		"User Groups",	"group2",						"",							"Add",		"Cancel"	 } ));	
		ll.add(Arrays.asList(new Object[]{ 	"add_usergroup_netgroup_all",	"engineering",	"User",		"User Groups",	"",								"",							"All", 		"Update"	 } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_host_netgroup",			"engineering",	"Host",		"Hosts",		"laptop-dev.testrelm.com", 		"laptop-qa.testrelm.com",	"Add",		"Add"		 } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_host_netgroup_cancel",		"engineering",	"Host",		"Hosts",		"webserver-dev.testrelm.com",	"",							"Add",		"Cancel"	 } ));	
		ll.add(Arrays.asList(new Object[]{ 	"add_host_netgroup_all",		"engineering",	"Host",		"Hosts",		"",								"",							"All", 		"Update"	 } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_hostgroup_netgroup",		"engineering",	"Host",		"Host Groups",	"hostgroup1a", 					"hostgroup1b",				"Add",		"Add"		 } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_hostgroup_netgroup_cancel","engineering",	"Host",		"Host Groups",	"hostgroup2",					"",							"Add",		"Cancel"	 } ));	
		ll.add(Arrays.asList(new Object[]{ 	"add_hostgroup_netgroup_all",	"engineering",	"Host",		"Host Groups",	"",								"",							"All", 		"Update"	 } ));
	
		return ll;	
	}
	
	
	
	
	/*
	 * Data to be used when expanding/collapsing Netgroup details
	 */
	@DataProvider(name="getNetgroupExpandCollapseTestObjects")
	public Object[][] getNetgroupExpandCollapseTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetgroupExpandCollapseTestObjects());
	}
	protected List<List<Object>> createNetgroupExpandCollapseTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					netgroup		
		ll.add(Arrays.asList(new Object[]{ 		"netgroup_expand_collapse",	"engineering" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when searching netgroups
	 */
	@DataProvider(name="getNetgroupSearchTestObjects")
	public Object[][] getNetgroupSearchTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetgroupSearchTestObjects());
	}
	protected List<List<Object>> createNetgroupSearchTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				netgroup1		netgroup2
		ll.add(Arrays.asList(new Object[]{ "search_netgroup",			"marketing",	"sales" } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when searching netgroups that are not added
	 */
	@DataProvider(name="getNetgroupSearchNegativeTestObjects")
	public Object[][] getNetgroupSearchNegativeTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetgroupSearchNegativeTestObjects());
	}
	protected List<List<Object>> createNetgroupSearchNegativeTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				netgroup
		ll.add(Arrays.asList(new Object[]{ "search_netgroup_negative",	"finance" } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used for bug 815494
	 */
	@DataProvider(name="getNetgroupUser_bug815494TestObjects")
	public Object[][] getNetgroupUser_bug815494TestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetgroupUser_bug815494TestObjects());
	}
	protected List<List<Object>> createNetgroupUser_bug815494TestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname					groupName
		ll.add(Arrays.asList(new Object[]{ 	"NetgroupUser_bug815494", 	"bug815494_netgroup" } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used for bug 815494
	 */
	@DataProvider(name="getNetgroupEdit_bug814785TestObjects")
	public Object[][] getNetgroupEdit_bug814785TestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetgroupEdit_bug814785TestObjects());
	}
	protected List<List<Object>> createNetgroupEdit_bug814785TestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname					groupName				newDescription
		ll.add(Arrays.asList(new Object[]{ 	"NetgroupEdit_bug814785",	"bug814785_netgroup",	"bug814785_netgroup description" } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used for Netgroup Membership
	 */
	@DataProvider(name="getNetgroupMembershipTestObjects")
	public Object[][] getNetgroupMembershipTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetgroupMembershipTestObjects());
	}
	protected List<List<Object>> createNetgroupMembershipTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname						groupName1				groupName2				groupName3
		ll.add(Arrays.asList(new Object[]{ 	"NetgroupMembership",	"netgroupmembership1",	"netgroupmembership2",	"netgroupmembership3" } ));
		        
		return ll;	
	}
	
}