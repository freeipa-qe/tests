package com.redhat.qe.ipa.sahi.tests.hostgroup;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class HostgroupTests extends SahiTestScript{
	public static SahiTasks sahiTasks = null;	
	private String hostgroupPage = "/ipa/ui/#identity=hostgroup&navigation=identity";
	private String hostPage = "/ipa/ui/#identity=host&navigation=identity";
	private String domain = System.getProperty("ipa.server.domain");
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
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
	 * Add and edit host group settings
	 */
	@Test (groups={"hostMembersTests"}, dataProvider="getHostMembersTestObjects")
	public void testHostMembers(String testName) throws Exception {
		String devwebserver = "webserver_dev." + domain;
		String qewebserver = "webserver_qe." + domain;
		String devhost = "laptop_dev." + domain;
		String qehost = "laptop_qa." + domain;
		String engwebserver = "webserver_eng." + domain;
		
		String [] hostnames = {devwebserver, qewebserver, devhost, qehost, engwebserver};
		
		String devgroup = "development hosts";
		String qegroup = "quality hosts";
		String enggroup = "engineering hosts";
		
		String [] hostgroups = {devgroup, qegroup, enggroup};
		
		//add hosts for host group members
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		for (String hostname : hostnames) {
			HostTasks.addHost(sahiTasks, hostname, "");
		}
		
		//add host groups
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
		for (String hostgroup : hostgroups) {
			String description = hostgroup + " group";
			HostgroupTasks.addHostGroup(sahiTasks, hostgroup, description, "Add");
		}
		
		String [] devhosts = {devwebserver, devhost};
		String [] qehosts = {qewebserver, qehost};
		String [] enghosts = {engwebserver};
		
		// add the host members
		HostgroupTasks.addMembers(sahiTasks, devgroup, "host", devhosts, "Enroll");
		HostgroupTasks.addMembers(sahiTasks, qegroup, "host", qehosts, "Enroll");
		HostgroupTasks.addMembers(sahiTasks, enggroup, "host", enghosts, "Enroll");
		
		//verify the host members
		HostgroupTasks.verifyMembers(sahiTasks, devgroup, "host", devhosts, "direct", "YES");
		HostgroupTasks.verifyMembers(sahiTasks, qegroup, "host", qehosts, "direct", "YES");
		HostgroupTasks.verifyMembers(sahiTasks, enggroup, "host", enghosts, "direct", "YES");
		
		//Now let's nest the groups and verify direct host group members and indirect host members
		String [] enggroups = {devgroup, qegroup};
		HostgroupTasks.addMembers(sahiTasks, enggroup, "hostgroup", enggroups, "Enroll");
		HostgroupTasks.verifyMembers(sahiTasks, enggroup, "hostgroup", enggroups, "direct", "YES");
		HostgroupTasks.verifyMembers(sahiTasks, enggroup, "host", qehosts, "indirect", "YES");
		HostgroupTasks.verifyMembers(sahiTasks, enggroup, "host", devhosts, "indirect", "YES");
		 
		//delete hosts
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		HostTasks.deleteHost(sahiTasks, hostnames);
		
		//delete host groups
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
		HostgroupTasks.deleteHostgroup(sahiTasks, hostgroups);

	}
	
	/*
	 * Verify memberof
	 */
	//TODO add in sudorule and hbacrule when those tasks are developed
	@Test (groups={"memberofTest"}, dataProvider="getMemberofTestObjects")	
	public void testMemberof(String testName) throws Exception {
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
		
		String devgroup = "development hosts";
		String qegroup = "quality hosts";
		String enggroup = "engineering hosts";
		String [] hostgroups = {devgroup, qegroup, enggroup};
		
		//add host groups
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
		for (String hostgroup : hostgroups) {
			String description = hostgroup + " group";
			HostgroupTasks.addHostGroup(sahiTasks, hostgroup, description, "Add");
		}
		
		String [] enggroups = {devgroup, qegroup};
		HostgroupTasks.addMembers(sahiTasks, enggroup, "hostgroup", enggroups, "Enroll");
		
		//verify member of
		String [] devnames = {enggroup};
		HostgroupTasks.verifyMemberOf(sahiTasks, devgroup, "hostgroup", devnames, "direct", "YES");
		
		String [] qenames = {enggroup};
		HostgroupTasks.verifyMemberOf(sahiTasks, qegroup, "hostgroup", qenames, "direct", "YES");
		
		//clean up
		HostgroupTasks.deleteHostgroup(sahiTasks, hostgroups);
};
	
	/*
	 * Cancel add members test
	 */
	@Test (groups={"cancelAddMembersTest"}, dataProvider="getCancelAddMemberTestObjects")	
	public void testCancelAddMembers(String testName, String groupName, String membertype, String member) throws Exception {
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
		String description = "cancel host group tests";
		//add new host group
		HostgroupTasks.addHostGroup(sahiTasks, groupName, description, "Add");
		
		if (membertype == "host"){
			sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
			HostTasks.addHost(sahiTasks, member, "");
		}
		if (membertype == "hostgroup"){
			HostgroupTasks.addHostGroup(sahiTasks, member, description, "Add");
		}
		
		//verify the host group exists
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName).exists(), "Verify host group " + groupName + " exists");
		
		//cancel adding member
		String [] members = {member};
		HostgroupTasks.addMembers(sahiTasks, groupName, membertype, members, "Cancel");
		
		//verify the member is not a member
		HostgroupTasks.verifyMembers(sahiTasks, groupName, membertype, members, "direct", "NO");
		
		//clean up delete host group
		HostgroupTasks.deleteHostgroup(sahiTasks, groupName, "Delete");
		if (membertype == "host"){
			sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
			HostTasks.deleteHost(sahiTasks, member);
		}
		if(membertype == "hostgroup"){
			sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
			HostgroupTasks.deleteHostgroup(sahiTasks, member, "Delete");
		}
		
	}
		/*
		 * Cancel remove members test
		 */
		@Test (groups={"cancelRemoveMembersTest"}, dataProvider="getCancelRemoveMemberTestObjects")	
		public void testCancelRemoveMembers(String testName, String groupName, String membertype, String member) throws Exception {
			sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
			String description = "cancel host group tests";
			//add new host group
			HostgroupTasks.addHostGroup(sahiTasks, groupName, description, "Add");
			
			if (membertype == "host"){
				sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
				HostTasks.addHost(sahiTasks, member, "");
				
			}
			if (membertype == "hostgroup"){
				HostgroupTasks.addHostGroup(sahiTasks, member, description, "Add");
			}
			
			String [] members = {member};
			sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
			HostgroupTasks.addMembers(sahiTasks, groupName, membertype, members, "Enroll");
			HostgroupTasks.verifyMembers(sahiTasks, groupName, membertype, members, "direct", "YES");
			
			//cancel removing member
			HostgroupTasks.removeMember(sahiTasks, groupName, membertype, members, "Cancel");
			HostgroupTasks.verifyMembers(sahiTasks, groupName, membertype, members, "direct", "YES");
			
			//clean up delete host group
			HostgroupTasks.deleteHostgroup(sahiTasks, groupName, "Delete");
			if (membertype == "host"){
				sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
				HostTasks.deleteHost(sahiTasks, member);
			}
			if(membertype == "hostgroup"){
				sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
				HostgroupTasks.deleteHostgroup(sahiTasks, member, "Delete");
			}

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
	@DataProvider(name="getHostMembersTestObjects")
	public Object[][] getHostMembersTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostMembersTestObjects());
	}
	protected List<List<Object>> createHostMembersTestObjects() {		
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
	
		//										testname						groupname	membertype		member	
		ll.add(Arrays.asList(new Object[]{ 		"cancel_addhostmember", 		"mygroup", 	"host", 		"myhost." + domain  } ));
		ll.add(Arrays.asList(new Object[]{ 		"cancel_addhostgroupmember",	"mygroup",	"hostgroup", 	"membergroup"} ));
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
		ll.add(Arrays.asList(new Object[]{ 		"cancel_removehostmember",		"mygroup",	"host",			"myhost." + domain } ));
		ll.add(Arrays.asList(new Object[]{ 		"cancel_removehostgroupmember",	"mygroup",	"hostgroup",	"membergroup" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when verifying memberof
	 */
	@DataProvider(name="getMemberofTestObjects")
	public Object[][] getMemberofTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createMemberofTestObjects());
	}
	protected List<List<Object>> createMemberofTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					
		ll.add(Arrays.asList(new Object[]{ 		"host_memberof" } ));
		return ll;	
	}
}