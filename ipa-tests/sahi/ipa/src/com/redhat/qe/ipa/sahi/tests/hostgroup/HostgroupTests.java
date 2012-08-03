package com.redhat.qe.ipa.sahi.tests.hostgroup;

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
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;

public class HostgroupTests extends SahiTestScript{
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	// hosts and host arrays
	private String myhost_short = "testhost";
	private String devwebserver_short = "webserver-dev";
	private String qewebserver_short = "webserver-qe";
	private String devhost_short = "laptop-dev";
	private String qehost_short = "laptop-qa";
	private String engwebserver_short = "webserver-eng";
	
	private String myhost = "testhost." + CommonTasks.ipadomain;
	private String devwebserver = "webserver-dev." + CommonTasks.ipadomain;
	private String qewebserver = "webserver-qe." + CommonTasks.ipadomain;
	private String devhost = "laptop-dev." + CommonTasks.ipadomain;
	private String qehost = "laptop-qa." + CommonTasks.ipadomain;
	private String engwebserver = "webserver-eng." + CommonTasks.ipadomain;
	
	private String [] devhosts = {devwebserver, devhost};
	private String [] qehosts = {qewebserver, qehost};
	private String [] enghosts = {engwebserver};
	private String [] hostnames_short = {myhost_short, devwebserver_short, qewebserver_short, devhost_short, qehost_short, engwebserver_short};
	private String [] hostnames = {myhost, devwebserver, qewebserver, devhost, qehost, engwebserver};
	
	//host groups and host group arrays
	private String myhostgroup = "myhostgroup";
	private String devgroup = "development_hosts";
	private String qegroup = "quality_hosts";
	private String enggroup = "engineering_hosts";
	
	private String [] enggroups = {devgroup, qegroup};
	
	private String [] allhostgroups = {myhostgroup, devgroup, qegroup, enggroup};
	
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&hostgroup-facet=search" ;
		
		//add host groups
		for (String hostgroup : allhostgroups) {
			String description = hostgroup + " group";
			HostgroupTasks.addHostGroup(sahiTasks, hostgroup, description, "Add");
		}
		
		//add hosts for host group members
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		for (String hostname : hostnames_short) {
			HostTasks.addHost(sahiTasks, hostname, commonTasks.getIpadomain(), "");
		} 
		
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	
		// delete the hosts added for testing
		sahiTasks.navigateTo(commonTasks.hostPage, true); 
		HostTasks.deleteHost(sahiTasks, hostnames);
		
		//delete the host groups added for testing
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		HostgroupTasks.deleteHostgroup(sahiTasks, allhostgroups);
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			//CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		}		
	}
	
	/*
	 * Add host group positive tests
	 */
	@Test (groups={"addHostGroupTests"}, dataProvider="getAddHostGroupTestObjects")	
	public void testHostGroupAdd(String testName, String groupName, String description, String button) throws Exception {
		//verify host group doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify host group " + groupName + " doesn't already exist");
		
		//add new host group
		HostgroupTasks.addHostGroup(sahiTasks, groupName, description, button);
		
		String lowercase = groupName.toLowerCase();

		if (button == "Cancel"){
			//verify host group was not added
			Assert.assertFalse(sahiTasks.link(lowercase).exists(), "Verify host group " + groupName + " was not added");
		}
		else {
			Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify host group " + groupName + " was added successfully");
		}
	}
	
	/*
	 * Delete host groups positive tests
	 */
	@Test (groups={"deleteHostGroupTests"}, dataProvider="getDeleteHostGroupTestObjects",  dependsOnGroups="addHostGroupTests")	
	public void testHostGroupDelete(String testName, String groupName, String button) throws Exception {
		// verify host group exists
		String lowercase = groupName.toLowerCase();
		Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify host group " + groupName + " exists");
		
		//delete host group
		HostgroupTasks.deleteHostgroup(sahiTasks, lowercase, button);
		
		if (button == "Cancel"){
			Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify host group " + groupName + " still exists");
		}
		else {
			Assert.assertFalse(sahiTasks.link(lowercase).exists(), "Verify host group " + groupName + " was deleted successfully");
		}
	}
	
	/*
	 * Add and Add Another host group positive tests
	 */
	@Test (groups={"addAndAddAnotherHostGroupTests"}, dataProvider="getAddAndAddAnotherHostGroupTestObjects")	
	public void testHostGroupAddAndAddAnother(String testName, String groupName1, String groupName2, String groupName3) throws Exception {
		
		//verify host group doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName1).exists(), "Verify host group " + groupName1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(groupName2).exists(), "Verify host group " + groupName2 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(groupName3).exists(), "Verify host group " + groupName3 + " doesn't already exist");
		
		//add new host group
		HostgroupTasks.addAndAddAnotherHostGroup(sahiTasks, groupName1, groupName2, groupName3);
	
		//verify host group exists
		Assert.assertTrue(sahiTasks.link(groupName1).exists(), "Verify host group " + groupName1 + " exists");
		Assert.assertTrue(sahiTasks.link(groupName2).exists(), "Verify host group " + groupName2 + " exists");
		Assert.assertTrue(sahiTasks.link(groupName3).exists(), "Verify host group " + groupName3 + " exists");
	
	}
	
	/*
	 * Delete multiple host groups positive tests
	 */
	@Test (groups={"deleteMultipleHostGroupTests"}, dataProvider="getAddAndAddAnotherHostGroupTestObjects",  dependsOnGroups={"addAndAddAnotherHostGroupTests", "searchHostGroupTests", "searchHostGroupNegativeTests"})	
	public void testHostGroupDeleteMultiple(String testName, String groupName1, String groupName2, String groupName3) throws Exception {
		//verify host group exists
		Assert.assertTrue(sahiTasks.link(groupName1).exists(), "Verify host group " + groupName1 + " exists");
		Assert.assertTrue(sahiTasks.link(groupName2).exists(), "Verify host group " + groupName2 + " exists");
		Assert.assertTrue(sahiTasks.link(groupName3).exists(), "Verify host group " + groupName3 + " exists");
		
		String [] groupnames = {groupName1, groupName2, groupName3};
		//delete host group
		HostgroupTasks.deleteHostgroup(sahiTasks, groupnames);

		//verify host group doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName1).exists(), "Verify host group " + groupName1 + " was deleted successfully");
		Assert.assertFalse(sahiTasks.link(groupName2).exists(), "Verify host group " + groupName2 + " was deleted successfully");
		Assert.assertFalse(sahiTasks.link(groupName3).exists(), "Verify host group " + groupName3 + " was deleted successfully");
		
	}
	
	/*
	 * Delete multiple host groups positive tests
	 */
	@Test (groups={"searchHostGroupTests"}, dataProvider="getSearchHostGroupTestObjects",  dependsOnGroups="addAndAddAnotherHostGroupTests")	
	public void testSearchHostGroup(String testName, String groupName1, String groupName2) throws Exception {
		
		
		String [] groupnames = {groupName1, groupName2};
		for(String groupname : groupnames){
		//delete host group
		HostgroupTasks.searchHostgroup(sahiTasks, groupname);

		//verify host group doesn't exist
		Assert.assertTrue(sahiTasks.link(groupname).exists(), "Found host group " + groupname + " successfully");
		HostgroupTasks.clearSearchHostgroup(sahiTasks);
		}
	}
	
	
	/*
	 * Delete multiple host groups positive tests
	 */
	@Test (groups={"searchHostGroupNegativeTests"}, dataProvider="getSearchHostGroupNegativeTestObjects",  dependsOnGroups="addAndAddAnotherHostGroupTests")	
	public void testSearchHostGroupNegative(String testName, String groupName) throws Exception {
		
		
		
		//search negative host group
		HostgroupTasks.searchHostgroup(sahiTasks, groupName);

		//verify host group doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName).exists(), groupName + " Host Group does not exist : search successfully");
		HostgroupTasks.clearSearchHostgroup(sahiTasks);
		
	}
	
	/*
	 * Add and edit host group settings
	 */
	@Test (groups={"addAndEditHostGroupSettingsTest"}, dataProvider="getAddAndEditHostGroupTestObjects", dependsOnGroups="deleteMultipleHostGroupTests")	
	public void testHostGroupAddAndEdit(String testName, String groupName, String description1, String description2) throws Exception {
		//verify host group doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify host group " + groupName + " doesn't already exist");
		
		//add new host group
		HostgroupTasks.addAndEditHostGroup(sahiTasks, groupName, description1, description2);
		
		//verify the host group exists
		Assert.assertTrue(sahiTasks.link(groupName).exists(), "Verify host group " + groupName + " exists");
		
		//verify the description setting
		HostgroupTasks.verifyHostGroupSettings(sahiTasks, groupName, description2);
		
		//clean up delete host group
		HostgroupTasks.deleteHostgroup(sahiTasks, groupName, "Delete");

	}
	
	/*
	 * Host Members tests
	 */
	@Test (groups={"AddHostMembersTests"}, dataProvider="getAddHostMembersTestObjects")
	public void testAddHostMembers(String testName) throws Exception {

		// add the host members
		HostgroupTasks.addMembers(sahiTasks, devgroup, "host", devhosts, "Add");
		HostgroupTasks.addMembers(sahiTasks, qegroup, "host", qehosts, "Add");
		HostgroupTasks.addMembers(sahiTasks, enggroup, "host", enghosts, "Add");
		
		//verify the host members
		HostgroupTasks.verifyMembers(sahiTasks, devgroup, "host", devhosts, "direct", "YES");
		HostgroupTasks.verifyMembers(sahiTasks, qegroup, "host", qehosts, "direct", "YES");
		HostgroupTasks.verifyMembers(sahiTasks, enggroup, "host", enghosts, "direct", "YES");
		
		//Now let's nest the groups and verify direct host group members and indirect host members
		HostgroupTasks.addMembers(sahiTasks, enggroup, "hostgroup", enggroups, "Add");
		HostgroupTasks.verifyMembers(sahiTasks, enggroup, "hostgroup", enggroups, "direct", "YES");
		HostgroupTasks.verifyMembers(sahiTasks, enggroup, "host", qehosts, "indirect", "YES");
		HostgroupTasks.verifyMembers(sahiTasks, enggroup, "host", devhosts, "indirect", "YES");

	}
	
	/*
	 * Verify Host Group member of
	 */
	@Test (groups={"hostGroupMemberofTest"}, dataProvider="getHostGroupMemberofTestObjects",  dependsOnGroups="AddHostMembersTests")	
	public void testGroupHostMemberof(String testName) throws Exception {
		
		//verify member of host group member of
		HostgroupTasks.verifyMemberOf(sahiTasks, devgroup, "hostgroup", enggroup, "direct", "YES", false);
		HostgroupTasks.verifyMemberOf(sahiTasks, qegroup, "hostgroup", enggroup, "direct", "YES", false);
	}
	
	/*
	 * Verify Host member of
	 */
	@Test (groups={"hostMemberofTest"}, dataProvider="getHostMemberofTestObjects",  dependsOnGroups="hostGroupMemberofTest")	
	public void testHostMemberof(String testName) throws Exception {
		
		//verify member of for hosts
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		HostTasks.verifyHostMemberOf(sahiTasks, devwebserver, "Host Groups", devgroup, "direct", "YES", false);
		HostTasks.verifyHostMemberOf(sahiTasks, devwebserver, "Host Groups", enggroup, "indirect", "YES", false);
		HostTasks.verifyHostMemberOf(sahiTasks, qewebserver, "Host Groups", qegroup, "direct", "YES", false);
		HostTasks.verifyHostMemberOf(sahiTasks, qewebserver, "Host Groups", enggroup, "indirect", "YES", false);
		HostTasks.verifyHostMemberOf(sahiTasks, engwebserver, "Host Groups", enggroup, "direct", "YES", false);
		
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
	}
	
	/*
	 * Cancel add members test
	 */
	@Test (groups={"cancelAddMembersTest"}, dataProvider="getCancelAddMemberTestObjects", dependsOnGroups="hostGroupMemberofTest")	
	public void testCancelAddMembers(String testName, String groupName, String membertype, String member) throws Exception {
		
		HostgroupTasks.addMembers(sahiTasks, groupName, membertype, member, "Cancel");
		
		//verify the member is not a member
		HostgroupTasks.verifyMembers(sahiTasks, groupName, membertype, member, "direct", "NO");
	}
	
	/*
	 * Cancel remove members test
	 */
	@Test (groups={"cancelRemoveMembersTest"}, dataProvider="getCancelRemoveMemberTestObjects",  dependsOnGroups="cancelAddMembersTest")	
	public void testCancelRemoveMembers(String testName, String groupName, String membertype, String member) throws Exception {
			
	//cancel removing member
	HostgroupTasks.removeMembers(sahiTasks, groupName, membertype, member, "Cancel");
	HostgroupTasks.verifyMembers(sahiTasks, groupName, membertype, member, "direct", "YES");
	}
	
	/*
	 * Remove member hosts test
	 */
	@Test (groups={"removeHostMembersTest"}, dataProvider="getRemoveHostMemberTestObjects",  dependsOnGroups="cancelRemoveMembersTest")	
	public void testRemoveHostMembers(String testName, String groupName, String [] members) throws Exception {
			
	// remove host members
	HostgroupTasks.removeMembers(sahiTasks, groupName, "host", members, "Delete");
	HostgroupTasks.verifyMembers(sahiTasks, groupName, "host", members, "direct", "NO");
	}
	
	/*
	 * Remove member host groups test
	 */
	@Test (groups={"removeHostGroupMembersTest"}, dataProvider="getRemoveHostGroupMemberTestObjects",  dependsOnGroups="removeHostMembersTest")	
	public void testRemoveHostGroupMembers(String testName, String groupName, String member) throws Exception {
			
	//remove host group member
	HostgroupTasks.removeMembers(sahiTasks, groupName, "hostgroup", member, "Delete");
	HostgroupTasks.verifyMembers(sahiTasks, groupName, "hostgroup", member, "direct", "NO");
	}
	
	/*
	 * negative add host group tests
	 */
	@Test (groups={"invalidHostGroupAddTests"}, dataProvider="getAddInvalidHostGroupTestObjects")	
	public void testInvalidHostadd(String testName, String groupname, String description, String expectedError) throws Exception {
		
		HostgroupTasks.addInvalidHostGroup(sahiTasks, groupname, description, expectedError);
	}
	
	/*
	 * negative add host group characters tests
	 */
	@Test (groups={"invalidCharHostGroupAddTests"}, dataProvider="getAddInvalidHostCharGroupTestObjects")	
	public void testInvalidCharHostadd(String testName, String groupname, String description, String expectedError) throws Exception {
		
		HostgroupTasks.addInvalidCharHostGroup(sahiTasks, groupname, description, expectedError);
	}
	
	/*
	 * negative modify host group characters tests
	 */
	@Test (groups={"invalidHostGroupModifyTests"}, dataProvider="getModifyInvalidHostGroupTestObjects")	
	public void testInvalidHostGroupModify(String testName, String groupname, String description, String expectedError) throws Exception {
		
		HostgroupTasks.modifyInvalidDirtyHostGroup(sahiTasks, groupname, description, expectedError);
	}
	
	/*
	 * negative modify host group undo tests
	 */
	@Test (groups={"invalidHostGroupModifyUndoTests"}, dataProvider="getModifyInvalidHostGroupUndoTestObjects")	
	public void testInvalidHostGroupUndoModify(String testName, String groupname, String description, String expectedError) throws Exception {
		
		HostgroupTasks.modifyInvalidUndoHostGroup(sahiTasks, groupname, description, expectedError);
	}
		

/*******************************************************
 ************      DATA PROVIDERS     ******************
 *******************************************************/

	/*
	 * Data to be used when adding host groups 
	 */
	@DataProvider(name="getAddHostGroupTestObjects")
	public Object[][] getAddHostGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddHostGroupTestObjects());
	}
	protected List<List<Object>> createAddHostGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname						groupanme			description					button
		ll.add(Arrays.asList(new Object[]{ 		"addhostgroup_cancel",			"newhostgroup",		"this is a new hostgroup",	 "Cancel" } ));
		ll.add(Arrays.asList(new Object[]{ 		"addhostgroup_mixedcase",		"NewHostGroup",		"this is a new hostgroup",	 "Add" } ));  
		ll.add(Arrays.asList(new Object[]{ 		"addhostgroup_longname",		"thisisahostgroupwithaveryveryveryveryveryveryveryveryverylongname",		"Host group with long name",	 "Add" } ));
		ll.add(Arrays.asList(new Object[]{ 		"addhostgroup_longdesc",		"long_description",		"thisisahostgroupwithaveryveryveryveryveryveryveryveryveryveryveryveryveryverylongdescription",	 "Add" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when deleting host groups 
	 */
	@DataProvider(name="getDeleteHostGroupTestObjects")
	public Object[][] getDeleteHostGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDeleteHostGroupTestObjects());
	}
	protected List<List<Object>> createDeleteHostGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname							groupanme																button
		ll.add(Arrays.asList(new Object[]{ 		"delete_hostgroup_cancel",			"NewHostGroup",															"Cancel" } ));  
		ll.add(Arrays.asList(new Object[]{ 		"delete_hostgroup_cancel",			"NewHostGroup",															"Delete" } ));
		ll.add(Arrays.asList(new Object[]{ 		"delete_hostgroup_longname",		"thisisahostgroupwithaveryveryveryveryveryveryveryveryverylongname", 	"Delete" } ));
		ll.add(Arrays.asList(new Object[]{ 		"delete_hostgroup_longdesc",		"long_description",			 											"Delete" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when adding host groups
	 */
	@DataProvider(name="getAddAndAddAnotherHostGroupTestObjects")
	public Object[][] getAddAndAddAnotherHostGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddAndAddAnotherHostGroupTestObjects());
	}
	protected List<List<Object>> createAddAndAddAnotherHostGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname									groupanme1					groupname2			groupname3
		ll.add(Arrays.asList(new Object[]{ 		"add_and_add_another_then_del_multiple",	"this_is_group_one",		"engineering",	 	"sales" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when adding and editing host groups
	 */
	@DataProvider(name="getAddAndEditHostGroupTestObjects")
	public Object[][] getAddAndEditHostGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddAndEditHostGroupTestObjects());
	}
	protected List<List<Object>> createAddAndEditHostGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname						groupanme1			description1					description2			
		ll.add(Arrays.asList(new Object[]{ 		"add_and_edit_setting",			"engineering",		"engineering host group",	 	"red hat engineering host group" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when adding host members
	 */
	@DataProvider(name="getAddHostMembersTestObjects")
	public Object[][] getHostMembersTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddHostMembersTestObjects());
	}
	protected List<List<Object>> createAddHostMembersTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					
		ll.add(Arrays.asList(new Object[]{ 		"host_memberships" } ));
		return ll;	
	}
	
	/*
	 * Data to be cancel adding member
	 */
	@DataProvider(name="getCancelAddMemberTestObjects")
	public Object[][] getCancelAddMemberTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createCancelAddMemberTestObjects());
	}
	protected List<List<Object>> createCancelAddMemberTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname						groupname		membertype		member	
		ll.add(Arrays.asList(new Object[]{ 		"cancel_addhostmember", 		myhostgroup, 	"host", 		myhost  } ));
		ll.add(Arrays.asList(new Object[]{ 		"cancel_addhostgroupmember",	myhostgroup,	"hostgroup", 	enggroup } ));
		return ll;	
	}
	
	/*
	 * Data to be cancel removing member
	 */
	@DataProvider(name="getCancelRemoveMemberTestObjects")
	public Object[][] getCancelRemoveMemberTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createCancelRemoveMemberTestObjects());
	}
	protected List<List<Object>> createCancelRemoveMemberTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname						groupname	membertype		member	
		ll.add(Arrays.asList(new Object[]{ 		"cancel_removehostmember",		enggroup,	"host",			engwebserver } ));
		ll.add(Arrays.asList(new Object[]{ 		"cancel_removehostgroupmember",	enggroup,	"hostgroup",	devgroup } ));
		return ll;	
	}
	
	/*
	 * Data to be used when verifying Host memberof
	 */
	@DataProvider(name="getHostGroupMemberofTestObjects")
	public Object[][] getHostGroupMemberofTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostGroupMemberofTestObjects());
	}
	protected List<List<Object>> createHostGroupMemberofTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					
		ll.add(Arrays.asList(new Object[]{ 		"hostgroup_memberof" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when verifying Host memberof
	 */
	@DataProvider(name="getHostMemberofTestObjects")
	public Object[][] getHostMemberofTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostMemberofTestObjects());
	}
	protected List<List<Object>> createHostMemberofTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					
		ll.add(Arrays.asList(new Object[]{ 		"host_memberof" } ));
		return ll;	
	}
	
	/*
	 * Data to be removing host member
	 */
	@DataProvider(name="getRemoveHostMemberTestObjects")
	public Object[][] getRemoveHostMemberTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createRemoveHostMemberTestObjects());
	}
	protected List<List<Object>> createRemoveHostMemberTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname						groupname	member	
		ll.add(Arrays.asList(new Object[]{ 		"removehostmembers_qe",			qegroup,	qehosts } ));
		ll.add(Arrays.asList(new Object[]{ 		"removehostmembers_dev",		devgroup,	devhosts } ));
		ll.add(Arrays.asList(new Object[]{ 		"removehostmembers_eng",		enggroup,	enghosts } ));
		return ll;	
	}
	
	/*
	 * Data to be removing host member
	 */
	@DataProvider(name="getRemoveHostGroupMemberTestObjects")
	public Object[][] getRemoveHostMemberGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createRemoveHostGroupMemberTestObjects());
	}
	protected List<List<Object>> createRemoveHostGroupMemberTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname						groupname	member	
		ll.add(Arrays.asList(new Object[]{ 		"removehostgroup_qe",			enggroup,	qegroup } ));
		ll.add(Arrays.asList(new Object[]{ 		"removehostgroup_qe",			enggroup,	devgroup } ));
		return ll;	
	}
	
	/*
	 * Data to be used when adding host groups 
	 */
	@DataProvider(name="getAddInvalidHostGroupTestObjects")
	public Object[][] getInvalidHostGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidHostGroupTestObjects());
	}
	protected List<List<Object>> createInvalidHostGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname							groupanme			description				expectedError
		ll.add(Arrays.asList(new Object[]{ 		"addinvalid_name_with_space",	    "my group",			"my description",	 	"may only include letters, numbers, _, -, and ." } ));
		ll.add(Arrays.asList(new Object[]{ 		"duplicate_hostgroup",				myhostgroup,		"my description",	 	"host group with name \"" + myhostgroup + "\" already exists" } ));
		ll.add(Arrays.asList(new Object[]{ 		"addinvalid_name_space",			" ",				"my description",	 	"may only include letters, numbers, _, -, and ." } ));
		ll.add(Arrays.asList(new Object[]{ 		"addinvalid_name_leading_space",	" newgroup",		"my description",	 	"may only include letters, numbers, _, -, and ." } ));
		ll.add(Arrays.asList(new Object[]{ 		"addinvalid_name_trailing_space",	"newgroup ",		"my description",	 	"may only include letters, numbers, _, -, and ." } ));
		ll.add(Arrays.asList(new Object[]{ 		"addinvalid_desc_space",			"newgroup",			" ",	 				"invalid 'desc': Leading and trailing spaces are not allowed" } ));
		ll.add(Arrays.asList(new Object[]{ 		"addinvalid_desc_leading_space",	"newgroup",			" my description",	 	"invalid 'desc': Leading and trailing spaces are not allowed" } ));
		ll.add(Arrays.asList(new Object[]{ 		"addinvalid_name_trailing_space",	"newgroup",			"my description ",	 	"invalid 'desc': Leading and trailing spaces are not allowed" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when adding invalid character host groups 
	 */
	@DataProvider(name="getAddInvalidHostCharGroupTestObjects")
	public Object[][] getInvalidCharHostGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidCharHostGroupTestObjects());
	}
	protected List<List<Object>> createInvalidCharHostGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname							groupanme			description						expectedError
		
		ll.add(Arrays.asList(new Object[]{ 		"addinvalid_no_name_or_description",	"",					"",	 						"Required field" } ));
		ll.add(Arrays.asList(new Object[]{ 		"addinvalid_no_name",					"",					"my description",	 		"Required field" } ));  
		ll.add(Arrays.asList(new Object[]{ 		"addinvalid_no_description",			"asdfjaskl",		"",							"Required field" } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when modify host groups - negative 
	 */
	@DataProvider(name="getModifyInvalidHostGroupTestObjects")
	public Object[][] getInvalidHostGroupModifyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidHostGroupModifyTestObjects());
	}
	protected List<List<Object>> createInvalidHostGroupModifyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname										groupanme			description			expectedError
		ll.add(Arrays.asList(new Object[]{ 		"modify_invalid_description_leadingspace",		myhostgroup,		" my description",	 "invalid 'desc': Leading and trailing spaces are not allowed" } ));
		ll.add(Arrays.asList(new Object[]{ 		"modify_invalid_description_trailingspace",		myhostgroup,		"my description ",	 "invalid 'desc': Leading and trailing spaces are not allowed" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when modify host groups undo - negative 
	 */
	@DataProvider(name="getModifyInvalidHostGroupUndoTestObjects")
	public Object[][] getInvalidHostGroupUndoModifyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidHostGroupUndoModifyTestObjects());
	}
	protected List<List<Object>> createInvalidHostGroupUndoModifyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname										groupanme			description			expectedError
		ll.add(Arrays.asList(new Object[]{ 		"modify_invalid_description_empty",				myhostgroup,		"",	 				 "Input form contains invalid or missing values." } ));
		return ll;	
	}
	
	/*
	 * Data to be used when searching host groups
	 */
	@DataProvider(name="getSearchHostGroupTestObjects")
	public Object[][] getSearchHostGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostGroupSearchTestObjects());
	}
	protected List<List<Object>> createHostGroupSearchTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				groupName1				hostname2
		ll.add(Arrays.asList(new Object[]{ "search_host_groups",		"engineering",			"sales" } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when searching host groups
	 */
	@DataProvider(name="getSearchHostGroupNegativeTestObjects")
	public Object[][] getSearchHostGroupNegativeTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostGroupNegativeSearchTestObjects());
	}
	protected List<List<Object>> createHostGroupNegativeSearchTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				groupName
		ll.add(Arrays.asList(new Object[]{ "search_host_groups_negative","marketing" } ));
		        
		return ll;	
	}
}