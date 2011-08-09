package com.redhat.qe.ipa.sahi.tests.hostgroup;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class HostgroupTests extends SahiTestScript{
	public static SahiTasks sahiTasks = null;	
	private String domain = System.getProperty("ipa.server.domain");
	
	// hosts and host arrays
	private String devwebserver = "webserver_dev." + domain;
	private String qewebserver = "webserver_qe." + domain;
	private String devhost = "laptop_dev." + domain;
	private String qehost = "laptop_qa." + domain;
	private String engwebserver = "webserver_eng." + domain;
	private String [] devhosts = {devwebserver, devhost};
	private String [] qehosts = {qewebserver, qehost};
	private String [] enghosts = {engwebserver};
	private String [] hostnames = {devwebserver, qewebserver, devhost, qehost, engwebserver};
	
	//host groups and host group arrays
	private String myhostgroup = "myhostgroup";
	private String devgroup = "development hosts";
	private String qegroup = "quality hosts";
	private String enggroup = "engineering hosts";
	
	private String [] enggroups = {devgroup, qegroup};
	
	private String [] allhostgroups = {myhostgroup, devgroup, qegroup, enggroup};
	
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostgroupPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		
		//add host groups
		for (String hostgroup : allhostgroups) {
			String description = hostgroup + " group";
			HostgroupTasks.addHostGroup(sahiTasks, hostgroup, description, "Add");
		}
		
		//add hosts for host group members
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostPage, true);
		for (String hostname : hostnames) {
			HostTasks.addHost(sahiTasks, hostname, "");
		}
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostgroupPage, true);
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	
		// delete the hosts added for testing
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostPage, true);
		HostTasks.deleteHost(sahiTasks, hostnames);
		
		//delete the host groups added for testing
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostgroupPage, true);
		HostgroupTasks.deleteHostgroup(sahiTasks, allhostgroups);
	}
	
	/*
	 * Add host group positive tests
	 */
	@Test (groups={"addHostGroupTests"}, dataProvider="getAddHostGroupTestObjects")	
	public void testHostGroupAdd(String testName, String groupName, String description, String button) throws Exception {
		//verify host group doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify host group " + groupName + " doesn't already exist");
		
		//add new host group
		HostgroupTasks.addHostGroup(sahiTasks, groupName, description, button);
		
		String lowercase = groupName.toLowerCase();

		if (button == "Cancel"){
			//verify host group was not added
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(lowercase).exists(), "Verify host group " + groupName + " was not added");
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify host group " + groupName + " was added successfully");
		}
	}
	
	/*
	 * Delete host groups positive tests
	 */
	@Test (groups={"deleteHostGroupTests"}, dataProvider="getDeleteHostGroupTestObjects",  dependsOnGroups="addHostGroupTests")	
	public void testHostGroupDelete(String testName, String groupName, String button) throws Exception {
		// verify host group exists
		String lowercase = groupName.toLowerCase();
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify host group " + groupName + " exists");
		
		//delete host group
		HostgroupTasks.deleteHostgroup(sahiTasks, lowercase, button);
		
		if (button == "Cancel"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify host group " + groupName + " still exists");
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(lowercase).exists(), "Verify host group " + groupName + " was deleted successfully");
		}
	}
	
	/*
	 * Add and Add Another host group positive tests
	 */
	@Test (groups={"addAndAddAnotherHostGroupTests"}, dataProvider="getAddAndAddAnotherHostGroupTestObjects")	
	public void testHostGroupAddAndAddAnother(String testName, String groupName1, String groupName2, String groupName3) throws Exception {
		
		//verify host group doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName1).exists(), "Verify host group " + groupName1 + " doesn't already exist");
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName2).exists(), "Verify host group " + groupName2 + " doesn't already exist");
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName3).exists(), "Verify host group " + groupName3 + " doesn't already exist");
		
		//add new host group
		HostgroupTasks.addAndAddAnotherHostGroup(sahiTasks, groupName1, groupName2, groupName3);
	
		//verify host group exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName1).exists(), "Verify host group " + groupName1 + " exists");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName2).exists(), "Verify host group " + groupName2 + " exists");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName3).exists(), "Verify host group " + groupName3 + " exists");
	
	}
	
	/*
	 * Delete multiple host groups positive tests
	 */
	@Test (groups={"deleteMultipleHostGroupTests"}, dataProvider="getAddAndAddAnotherHostGroupTestObjects",  dependsOnGroups="addAndAddAnotherHostGroupTests")	
	public void testHostGroupDeleteMultiple(String testName, String groupName1, String groupName2, String groupName3) throws Exception {
		//verify host group exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName1).exists(), "Verify host group " + groupName1 + " exists");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName2).exists(), "Verify host group " + groupName2 + " exists");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName3).exists(), "Verify host group " + groupName3 + " exists");
		
		String [] groupnames = {groupName1, groupName2, groupName3};
		//delete host group
		HostgroupTasks.deleteHostgroup(sahiTasks, groupnames);

		//verify host group doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName1).exists(), "Verify host group " + groupName1 + " was deleted successfully");
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName2).exists(), "Verify host group " + groupName2 + " was deleted successfully");
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName3).exists(), "Verify host group " + groupName3 + " was deleted successfully");
		
	}
	
	/*
	 * Add and edit host group settings
	 */
	@Test (groups={"addAndEditHostGroupSettingsTest"}, dataProvider="getAddAndEditHostGroupTestObjects")	
	public void testHostGroupAddAndEdit(String testName, String groupName, String description1, String description2) throws Exception {
		//verify host group doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify host group " + groupName + " doesn't already exist");
		
		//add new host group
		HostgroupTasks.addAndEditHostGroup(sahiTasks, groupName, description1, description2);
		
		//verify the host group exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName).exists(), "Verify host group " + groupName + " exists");
		
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
		HostgroupTasks.addMembers(sahiTasks, devgroup, "host", devhosts, "Enroll");
		HostgroupTasks.addMembers(sahiTasks, qegroup, "host", qehosts, "Enroll");
		HostgroupTasks.addMembers(sahiTasks, enggroup, "host", enghosts, "Enroll");
		
		//verify the host members
		HostgroupTasks.verifyMembers(sahiTasks, devgroup, "host", devhosts, "direct", "YES");
		HostgroupTasks.verifyMembers(sahiTasks, qegroup, "host", qehosts, "direct", "YES");
		HostgroupTasks.verifyMembers(sahiTasks, enggroup, "host", enghosts, "direct", "YES");
		
		//Now let's nest the groups and verify direct host group members and indirect host members
		HostgroupTasks.addMembers(sahiTasks, enggroup, "hostgroup", enggroups, "Enroll");
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
		HostgroupTasks.verifyMemberOf(sahiTasks, devgroup, "hostgroup", enggroup, "direct", "YES");
		HostgroupTasks.verifyMemberOf(sahiTasks, qegroup, "hostgroup", enggroup, "direct", "YES");
	}
	
	/*
	 * Verify Host member of
	 */
	@Test (groups={"hostMemberofTest"}, dataProvider="getHostMemberofTestObjects",  dependsOnGroups="AddHostMembersTests")	
	public void testHostMemberof(String testName) throws Exception {
		
		//verify member of for hosts
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostPage, true);
		HostTasks.verifyHostMemberOf(sahiTasks, devwebserver, "Host Groups", devgroup, "direct", "YES");
		HostTasks.verifyHostMemberOf(sahiTasks, devwebserver, "Host Groups", enggroup, "indirect", "YES");
		HostTasks.verifyHostMemberOf(sahiTasks, qewebserver, "Host Groups", qegroup, "direct", "YES");
		HostTasks.verifyHostMemberOf(sahiTasks, qewebserver, "Host Groups", enggroup, "indirect", "YES");
		HostTasks.verifyHostMemberOf(sahiTasks, engwebserver, "Host Groups", enggroup, "direct", "YES");
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostgroupPage, true);
	}
	
	/*
	 * Cancel add members test
	 */
	@Test (groups={"cancelAddMembersTest"}, dataProvider="getCancelAddMemberTestObjects")	
	public void testCancelAddMembers(String testName, String groupName, String membertype, String member) throws Exception {
		
		String [] members = {member};
		HostgroupTasks.addMembers(sahiTasks, groupName, membertype, members, "Cancel");
		
		//verify the member is not a member
		HostgroupTasks.verifyMembers(sahiTasks, groupName, membertype, members, "direct", "NO");
	}
	
	/*
	 * Cancel remove members test
	 */
	@Test (groups={"cancelRemoveMembersTest"}, dataProvider="getCancelRemoveMemberTestObjects",  dependsOnGroups="AddHostMembersTests")	
	public void testCancelRemoveMembers(String testName, String groupName, String membertype, String member) throws Exception {
			
	String [] members = {member};
			
	//cancel removing member
	HostgroupTasks.removeMember(sahiTasks, groupName, membertype, members, "Cancel");
	HostgroupTasks.verifyMembers(sahiTasks, groupName, membertype, members, "direct", "YES");

	}
		
		/*
		 * Hide enrolled host group tests
		 */
		@Test (groups={"hideAlreadyEnrolledGroupsTests"}, dataProvider="getHideAlreadyEnrolledGroupsTestObjects")	
		public void testHideAlreadyEnrolledGroups (String testName) throws Exception {
			String parent = "engineering";
			String qechild1 = "1qe";
			String qechild2 = "2qe";
			String devchild1 = "1dev";
			String devchild2 = "2dev";
			
			String [] hostgroups = {parent, qechild1, qechild2, devchild1, devchild2};
			String [] enrolled = {qechild1, devchild1};
			
			for (String hostgroup : hostgroups){
				HostgroupTasks.addHostGroup(sahiTasks, hostgroup, hostgroup, "Add");
			}
			HostgroupTasks.addMembers(sahiTasks, parent, "hostgroup", enrolled, "Enroll");
			
			HostgroupTasks.hideAlreadyEnrolled(sahiTasks, parent, "hostgroup", qechild1, "YES", "qe");
			
			HostgroupTasks.hideAlreadyEnrolled(sahiTasks, parent, "hostgroup", devchild1, "YES", "dev");
			
			HostgroupTasks.hideAlreadyEnrolled(sahiTasks, parent, "hostgroup", qechild1, "NO", "qe");
			
			HostgroupTasks.hideAlreadyEnrolled(sahiTasks, parent, "hostgroup", qechild1, "NO", "dev");
			
			//clean up
			HostgroupTasks.deleteHostgroup(sahiTasks, hostgroups);
	}
		
		/*
		 * Hide enrolled host tests
		 */
		@Test (groups={"hideAlreadyEnrolledHostsTests"}, dataProvider="getHideAlreadyEnrolledHostsTestObjects")	
		public void testHideAlreadyEnrolledHosts (String testName) throws Exception {
			String groupname = "application servers";
			String devappserver = "appserver_dev." + domain;
			String devwebserver = "webserver_dev." + domain;
			String qeappserver = "appserver_qe." + domain;
			String qewebserver = "webserver_qe." + domain;
			String [] hostnames = {devappserver, devwebserver, qeappserver, qewebserver};
			
			HostgroupTasks.addHostGroup(sahiTasks, groupname, groupname, "Add");
			
			sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostPage, true);
			for (String hostname : hostnames){
				HostTasks.addHost(sahiTasks, hostname, "");
			}
		
			sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostgroupPage, true);
			String [] enrolled = {devappserver, qeappserver};
			HostgroupTasks.addMembers(sahiTasks, groupname, "host", enrolled, "Enroll");
			
			HostgroupTasks.hideAlreadyEnrolled(sahiTasks, groupname, "host", devappserver, "YES", "dev");
			
			HostgroupTasks.hideAlreadyEnrolled(sahiTasks, groupname, "host", qeappserver, "YES", "qe");
			
			HostgroupTasks.hideAlreadyEnrolled(sahiTasks, groupname, "host", devappserver, "NO", "dev");
			
			HostgroupTasks.hideAlreadyEnrolled(sahiTasks, groupname, "host", qeappserver, "NO", "qe");
			
			//clean up
			HostgroupTasks.deleteHostgroup(sahiTasks, groupname, "Delete");
			
			sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostPage, true);;
			HostTasks.deleteHost(sahiTasks, hostnames);
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
		ll.add(Arrays.asList(new Object[]{ 		"addhostgroup_longdesc",		"long description",		"thisisahostgroupwithaveryveryveryveryveryveryveryveryveryveryveryveryveryverylongdescription",	 "Add" } ));
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
		ll.add(Arrays.asList(new Object[]{ 		"delete_hostgroup_longdesc",		"long description",			 											"Delete" } ));
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
		ll.add(Arrays.asList(new Object[]{ 		"add_and_add_another_then_del_multiple",	"this is group one",		"engineering",	 	"sales" } ));
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
		ll.add(Arrays.asList(new Object[]{ 		"cancel_addhostmember", 		myhostgroup, 	"host", 		engwebserver  } ));
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
	 * Data to be used when verifying hide already enrolled host groups
	 */
	@DataProvider(name="getHideAlreadyEnrolledGroupsTestObjects")
	public Object[][] getHideAlreadyEnrolledGroupsTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHideAlreadyEnrolledGroupsTestObjects());
	}
	protected List<List<Object>> createHideAlreadyEnrolledGroupsTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					
		ll.add(Arrays.asList(new Object[]{ 		"hide_enrolled_hostgroups" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when verifying hide already enrolled hosts
	 */
	@DataProvider(name="getHideAlreadyEnrolledHostsTestObjects")
	public Object[][] getHideAlreadyEnrolledHostsTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHideAlreadyEnrolledHostsTestObjects());
	}
	protected List<List<Object>> createHideAlreadyEnrolledHostsTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					
		ll.add(Arrays.asList(new Object[]{ 		"hide_enrolled_hosts" } ));
		return ll;	
	}
}