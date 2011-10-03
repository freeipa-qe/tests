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
	
	private String [] netgroups = {devgroup, qegroup, enggroup};
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
	
	private String [] devusers = {user1, user2};
	private String [] qeusers = {user3};
	
	private String [] users = {user1, user2, user3};
	
	
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
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			CommonTasks.checkError(sahiTasks);
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
	@Test (groups={"deleteMultipleNetGroupTests"}, dataProvider="getAddAndAddAnotherNetGroupTestObjects",  dependsOnGroups="addAndAddAnotherNetGroupTests")	
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
	 * Host Members tests
	 */
	@Test (groups={"netGroupHostMembersTests"}, dataProvider="getNetGroupHostMembersTestObjects")
	public void testNetGroupHostMembers(String testName) throws Exception {
		// cancel enroll
		NetgroupTasks.addMembers(sahiTasks, enggroup, "host", enghosts, "Cancel");
		NetgroupTasks.verifyMembers(sahiTasks, enggroup, "host", enghosts, "NO");
		
		// add the host members
		NetgroupTasks.addMembers(sahiTasks, devgroup, "host", devhosts, "Enroll");
		NetgroupTasks.addMembers(sahiTasks, qegroup, "host", qehosts, "Enroll");
		NetgroupTasks.addMembers(sahiTasks, enggroup, "host", enghosts, "Enroll");
		
		//verify the host members
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "host", devhosts, "YES");
		NetgroupTasks.verifyMembers(sahiTasks, qegroup, "host", qehosts, "YES");
		NetgroupTasks.verifyMembers(sahiTasks, enggroup, "host", enghosts, "YES");
		
		//nest the host groups
		NetgroupTasks.addMembers(sahiTasks, enggroup, "netgroup", nestedmembers, "Enroll");
		
		//verify member of for hosts
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		HostTasks.verifyHostMemberOf(sahiTasks, devwebserver + "." + domain, "Netgroups", devgroup, "direct", "YES", false);
		HostTasks.verifyHostMemberOf(sahiTasks, devwebserver + "." + domain, "Netgroups", enggroup, "indirect", "YES", false);
		HostTasks.verifyHostMemberOf(sahiTasks, qewebserver + "." + domain, "Netgroups", qegroup, "direct", "YES", false);
		HostTasks.verifyHostMemberOf(sahiTasks, qewebserver + "." + domain, "Netgroups", enggroup, "indirect", "YES", false);
		HostTasks.verifyHostMemberOf(sahiTasks, engwebserver + "." + domain, "Netgroups", enggroup, "direct", "YES", false);
		
		//cancel remove members
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		NetgroupTasks.removeMember(sahiTasks, enggroup, "host", enghosts, "Cancel");
		NetgroupTasks.verifyMembers(sahiTasks, enggroup, "host", enghosts, "YES");
		
		// add the host members
		NetgroupTasks.removeMember(sahiTasks, devgroup, "host", devhosts, "Delete");
		NetgroupTasks.removeMember(sahiTasks, qegroup, "host", qehosts, "Delete");
		NetgroupTasks.removeMember(sahiTasks, enggroup, "host", enghosts, "Delete");
		
		//verify the host members
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "host", devhosts, "NO");
		NetgroupTasks.verifyMembers(sahiTasks, qegroup, "host", qehosts, "NO");
		NetgroupTasks.verifyMembers(sahiTasks, enggroup, "host", enghosts, "NO");
		
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
	}
	
	/*
	 * Host Group Members tests
	 */
	@Test (groups={"netGroupHostGroupMembersTests"}, dataProvider="getNetGroupHostGroupMembersTestObjects")
	public void testNetGroupHostGroupMembers(String testName) throws Exception {
		//cancel add host group member
		NetgroupTasks.addMembers(sahiTasks, devgroup, "hostgroup", grp1members, "Cancel");
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "hostgroup", grp1members, "NO");
		
		// add the host group members
		NetgroupTasks.addMembers(sahiTasks, devgroup, "hostgroup", grp1members, "Enroll");
		NetgroupTasks.addMembers(sahiTasks, qegroup, "hostgroup", grp2members, "Enroll");
		
		//verify the host group members
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "hostgroup", grp1members, "YES");
		NetgroupTasks.verifyMembers(sahiTasks, qegroup, "hostgroup", grp2members, "YES");
		
		//TODO enable this check when bug 727921 is fixed
		//verify member of host groups
		//sahiTasks.navigateTo(hostgroupPage, true);
		//HostgroupTasks.verifyMemberOf(sahiTasks, hostgroup1A, "netgroups", devgroup, "direct", "YES");
		//HostgroupTasks.verifyMemberOf(sahiTasks, hostgroup1B, "netgroups", devgroup, "direct", "YES");
		//HostgroupTasks.verifyMemberOf(sahiTasks, hostgroup2, "netgroups", qegroup, "direct", "YES");
		
		//cancel remove member
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		NetgroupTasks.removeMember(sahiTasks, devgroup, "hostgroup", grp1members, "Cancel");
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "hostgroup", grp1members, "YES");
		
		//remove members
		NetgroupTasks.removeMember(sahiTasks, devgroup, "hostgroup", grp1members, "Delete");
		NetgroupTasks.removeMember(sahiTasks, qegroup, "hostgroup", grp2members, "Delete");
		
		//verify the host group members
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "hostgroup", grp1members, "NO");
		NetgroupTasks.verifyMembers(sahiTasks, qegroup, "hostgroup", grp2members, "NO");

	}
	
	/*
	 * User Group Members tests
	 */
	@Test (groups={"netGroupUserGroupMembersTests"}, dataProvider="getNetGroupUserGroupMembersTestObjects")
	public void testNetGroupUserGroupMembers(String testName) throws Exception {
		// cancel add user group member
		NetgroupTasks.addMembers(sahiTasks, devgroup, "usergroup", ugroup1members, "Cancel");
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "usergroup", ugroup1members, "NO");
		
		// add the user group members
		NetgroupTasks.addMembers(sahiTasks, devgroup, "usergroup", ugroup1members, "Enroll");
		NetgroupTasks.addMembers(sahiTasks, qegroup, "usergroup", ugroup2members, "Enroll");
		
		//verify the host group members
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "usergroup", ugroup1members, "YES");
		NetgroupTasks.verifyMembers(sahiTasks, qegroup, "usergroup", ugroup2members, "YES");
		
		//verify user group member of net group
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		GroupTasks.verifyMemberOf(sahiTasks, usergroup1A, "netgroups", devgroup, "direct", "YES", false);
		GroupTasks.verifyMemberOf(sahiTasks, usergroup1B, "netgroups", devgroup, "direct", "YES", false);
		GroupTasks.verifyMemberOf(sahiTasks, usergroup2, "netgroups", qegroup, "direct", "YES", false);
		
		//cancel remove member
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		NetgroupTasks.removeMember(sahiTasks, devgroup, "usergroup", ugroup1members, "Cancel");
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "usergroup", ugroup1members, "YES");
		
		//remove members
		NetgroupTasks.removeMember(sahiTasks, devgroup, "usergroup", ugroup1members, "Delete");
		NetgroupTasks.removeMember(sahiTasks, qegroup, "usergroup", ugroup2members, "Delete");
		
		//verify the user group members
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "usergroup", ugroup1members, "NO");
		NetgroupTasks.verifyMembers(sahiTasks, qegroup, "usergroup", ugroup2members, "NO");
	}
	
	/*
	 * User Members tests
	 */
	@Test (groups={"netGroupUserMembersTests"}, dataProvider="getNetGroupUserMembersTestObjects")
	public void testNetGroupUserMembers(String testName) throws Exception {
		// cancel add user member
		NetgroupTasks.addMembers(sahiTasks, devgroup, "user", devusers, "Cancel");
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "user", devusers, "NO");
		
		// add the user members
		NetgroupTasks.addMembers(sahiTasks, devgroup, "user", devusers, "Enroll");
		NetgroupTasks.addMembers(sahiTasks, qegroup, "user", qeusers, "Enroll");
		
		//verify the user members
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "user", devusers, "YES");
		NetgroupTasks.verifyMembers(sahiTasks, qegroup, "user", qeusers, "YES");
		
		//verify user member of net group
		sahiTasks.navigateTo(commonTasks.userPage, true);
		UserTasks.verifyUserMemberOf(sahiTasks, user1, "Netgroups", devgroup, "direct", "YES", false);
		UserTasks.verifyUserMemberOf(sahiTasks, user2, "Netgroups", devgroup, "direct", "YES", false);
		UserTasks.verifyUserMemberOf(sahiTasks, user3, "Netgroups", qegroup, "direct", "YES", false);
		
		//cancel remove member
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		NetgroupTasks.removeMember(sahiTasks, devgroup, "user", devusers, "Cancel");
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "user", devusers, "YES");
		
		//remove members
		NetgroupTasks.removeMember(sahiTasks, devgroup, "user", devusers, "Delete");
		NetgroupTasks.removeMember(sahiTasks, qegroup, "user", qeusers, "Delete");
		
		//verify the user group members
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "user", devusers, "NO");
		NetgroupTasks.verifyMembers(sahiTasks, qegroup, "user", qeusers, "NO");
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
		ll.add(Arrays.asList(new Object[]{ 		"addnetgroup_longdesc",			"long description",		"thisisanetgroupwithaveryveryveryveryveryveryveryveryveryveryveryveryveryverylongdescription",	 "Add" } ));
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
		ll.add(Arrays.asList(new Object[]{ 		"delete_netgroup_longdesc",			"long description",			 											"Delete" } ));
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
		ll.add(Arrays.asList(new Object[]{ 		"add_and_add_another_then_del_multiple",	"this is group one",		"marketing",	 	"sales" } ));
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
	 * Data to be used when adding host members
	 */
	@DataProvider(name="getNetGroupHostMembersTestObjects")
	public Object[][] getNetGroupHostMembersTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetGroupHostMembersTestObjects());
	}
	protected List<List<Object>> createNetGroupHostMembersTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					
		ll.add(Arrays.asList(new Object[]{ 		"host_memberships" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when adding host members
	 */
	@DataProvider(name="getNetGroupHostGroupMembersTestObjects")
	public Object[][] getNetGroupHostGroupMembersTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetGroupHostGroupMembersTestObjects());
	}
	protected List<List<Object>> createNetGroupHostGroupMembersTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					
		ll.add(Arrays.asList(new Object[]{ 		"hostgroup_memberships" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when adding user group members
	 */
	@DataProvider(name="getNetGroupUserGroupMembersTestObjects")
	public Object[][] getNetGroupUserGroupMembersTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetGroupUserGroupMembersTestObjects());
	}
	protected List<List<Object>> createNetGroupUserGroupMembersTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					
		ll.add(Arrays.asList(new Object[]{ 		"usergroup_memberships" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when adding user members
	 */
	@DataProvider(name="getNetGroupUserMembersTestObjects")
	public Object[][] getNetGroupUserMembersTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNetGroupUserMembersTestObjects());
	}
	protected List<List<Object>> createNetGroupUserMembersTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					
		ll.add(Arrays.asList(new Object[]{ 		"user_memberships" } ));
		return ll;	
	}
	
}