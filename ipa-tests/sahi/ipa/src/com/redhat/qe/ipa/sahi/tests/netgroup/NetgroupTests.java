package com.redhat.qe.ipa.sahi.tests.netgroup;

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
import com.redhat.qe.ipa.sahi.tasks.NetgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class NetgroupTests extends SahiTestScript{
	public static SahiTasks sahiTasks = null;	
	private String hostgroupPage = "/ipa/ui/#identity=hostgroup&navigation=identity";
	private String hostPage = "/ipa/ui/#identity=host&navigation=identity";
	private String netgroupPage = "/ipa/ui/#identity=netgroup&navigation=identity";
	private String domain = System.getProperty("ipa.server.domain");
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+netgroupPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
	}
	
	/*
	 * Add net group positive tests
	 */
	@Test (groups={"addNetGroupTests"}, dataProvider="getAddNetGroupTestObjects")	
	public void testNetGroupAdd(String testName, String groupName, String description, String button) throws Exception {
		//verify host group doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify net group " + groupName + " doesn't already exist");
		
		//add new host group
		NetgroupTasks.addNetGroup(sahiTasks, groupName, description, button);
		
		String lowercase = groupName.toLowerCase();

		if (button == "Cancel"){
			//verify net group was not added
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(lowercase).exists(), "Verify net group " + groupName + " was not added");
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify net group " + groupName + " was added successfully");
		}
	}
	
	/*
	 * Delete net groups positive tests
	 */
	@Test (groups={"deleteNetGroupTests"}, dataProvider="getDeleteNetGroupTestObjects",  dependsOnGroups="addNetGroupTests")	
	public void testNetGroupDelete(String testName, String groupName, String button) throws Exception {
		// verify host group exists
		String lowercase = groupName.toLowerCase();
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify net group " + groupName + " exists");
		
		//delete net group
		NetgroupTasks.deleteNetgroup(sahiTasks, lowercase, button);
		
		if (button == "Cancel"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(lowercase).exists(), "Verify net group " + groupName + " still exists");
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(lowercase).exists(), "Verify net group " + groupName + " was deleted successfully");
		}
	}
	
	/*
	 * Add and Add Another net group
	 */
	@Test (groups={"addAndAddAnotherNetGroupTests"}, dataProvider="getAddAndAddAnotherNetGroupTestObjects")	
	public void testNetGroupAddAndAddAnother(String testName, String groupName1, String groupName2, String groupName3) throws Exception {
		
		//verify host group doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName1).exists(), "Verify net group " + groupName1 + " doesn't already exist");
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName2).exists(), "Verify net group " + groupName2 + " doesn't already exist");
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName3).exists(), "Verify net group " + groupName3 + " doesn't already exist");
		
		//add new host group
		HostgroupTasks.addAndAddAnotherHostGroup(sahiTasks, groupName1, groupName2, groupName3);
	
		//verify host group exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName1).exists(), "Verify net group " + groupName1 + " exists");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName2).exists(), "Verify net group " + groupName2 + " exists");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName3).exists(), "Verify net group " + groupName3 + " exists");
	
	}
	
	/*
	 * Delete multiple net groups positive tests
	 */
	@Test (groups={"deleteMultipleNetGroupTests"}, dataProvider="getAddAndAddAnotherNetGroupTestObjects",  dependsOnGroups="addAndAddAnotherNetGroupTests")	
	public void testNetGroupDeleteMultiple(String testName, String groupName1, String groupName2, String groupName3) throws Exception {
		//verify host group exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName1).exists(), "Verify net group " + groupName1 + " exists");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName2).exists(), "Verify net group " + groupName2 + " exists");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName3).exists(), "Verify net group " + groupName3 + " exists");
		
		String [] groupnames = {groupName1, groupName2, groupName3};
		//delete net group
		NetgroupTasks.deleteNetgroup(sahiTasks, groupnames);

		//verify net group doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName1).exists(), "Verify net group " + groupName1 + " was deleted successfully");
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName2).exists(), "Verify net group " + groupName2 + " was deleted successfully");
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName3).exists(), "Verify net group " + groupName3 + " was deleted successfully");
		
	}
	
	/*
	 * Add and edit net group settings
	 */
	@Test (groups={"addAndEditNetGroupSettingsTest"}, dataProvider="getAddAndEditNetGroupTestObjects")	
	public void testnetGroupAddAndEdit(String testName, String groupName, String description1, String description2, String nisdomain) throws Exception {
		//verify net group doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify net group " + groupName + " doesn't already exist");
		
		//add new net group
		NetgroupTasks.addAndEditNetGroup(sahiTasks, groupName, description1, description2, nisdomain);
		
		//verify the net group exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(groupName).exists(), "Verify net group " + groupName + " exists");
		
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
		String devwebserver = "webserver_dev." + domain;
		String qewebserver = "webserver_qe." + domain;
		String devhost = "laptop_dev." + domain;
		String qehost = "laptop_qa." + domain;
		String engwebserver = "webserver_eng." + domain;
		
		String [] hostnames = {devwebserver, qewebserver, devhost, qehost, engwebserver};
		
		String devgroup = "development hosts";
		String qegroup = "quality hosts";
		String enggroup = "engineering hosts";
		
		String [] netgroups = {devgroup, qegroup, enggroup};
		
		//add hosts for host group members
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		for (String hostname : hostnames) {
			HostTasks.addHost(sahiTasks, hostname, "");
		}
		
		//add net groups
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+netgroupPage, true);
		for (String netgroup : netgroups) {
			String description = netgroup + " group";
			NetgroupTasks.addNetGroup(sahiTasks, netgroup, description, "Add");
		}
		
		String [] devhosts = {devwebserver, devhost};
		String [] qehosts = {qewebserver, qehost};
		String [] enghosts = {engwebserver};
		
		// add the host members
		NetgroupTasks.addMembers(sahiTasks, devgroup, "host", devhosts, "Enroll");
		NetgroupTasks.addMembers(sahiTasks, qegroup, "host", qehosts, "Enroll");
		NetgroupTasks.addMembers(sahiTasks, enggroup, "host", enghosts, "Enroll");
		
		//verify the host members
		NetgroupTasks.verifyMembers(sahiTasks, devgroup, "host", devhosts, "YES");
		NetgroupTasks.verifyMembers(sahiTasks, qegroup, "host", qehosts, "YES");
		NetgroupTasks.verifyMembers(sahiTasks, enggroup, "host", enghosts, "YES");
		 
		//delete hosts
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		HostTasks.deleteHost(sahiTasks, hostnames);
		
		//delete host groups
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+netgroupPage, true);
		NetgroupTasks.deleteNetgroup(sahiTasks, netgroups);

	}
	
	/*
	 * Host Group Members tests
	 */
	@Test (groups={"netGroupHostGroupMembersTests"}, dataProvider="getNetGroupHostGroupMembersTestObjects")
	public void testNetGroupHostGroupMembers(String testName) throws Exception {
		String hostgroup1A = "hostgroup1a";
		String hostgroup1B = "hostgroup1b";
		String hostgroup2 = "hostgroup2";
		
		String [] hostgroups = {hostgroup1A, hostgroup1B, hostgroup2};
		
		String netgroup1 = "netgroup one";
		String netgroup2 = "netgroup two";
		
		String [] netgroups = {netgroup1, netgroup2};
		
		//add host groups for net group members
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
		for (String hostgroup : hostgroups) {
			String description = hostgroup + " description";
			HostgroupTasks.addHostGroup(sahiTasks, hostgroup, description, "Add");
		}
		
		//add net groups
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+netgroupPage, true);
		for (String netgroup : netgroups) {
			String description = netgroup + " description";
			NetgroupTasks.addNetGroup(sahiTasks, netgroup, description, "Add");
		}
		
		String [] grp1members = {hostgroup1A, hostgroup1B};
		String [] grp2members = {hostgroup2};
		
		// add the host group members
		NetgroupTasks.addMembers(sahiTasks, netgroup1, "hostgroup", grp1members, "Enroll");
		NetgroupTasks.addMembers(sahiTasks, netgroup2, "hostgroup", grp2members, "Enroll");
		
		//verify the host group members
		NetgroupTasks.verifyMembers(sahiTasks, netgroup1, "hostgroup", grp1members, "YES");
		NetgroupTasks.verifyMembers(sahiTasks, netgroup2, "hostgroup", grp2members, "YES");
		 
		//delete hosts
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
		HostgroupTasks.deleteHostgroup(sahiTasks, hostgroups);
		
		//delete host groups
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+netgroupPage, true);
		NetgroupTasks.deleteNetgroup(sahiTasks, netgroups);

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
		ll.add(Arrays.asList(new Object[]{ 		"add_and_add_another_then_del_multiple",	"this is group one",		"engineering",	 	"sales" } ));
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
		ll.add(Arrays.asList(new Object[]{ 		"add_and_edit_setting",			"engineering",		"engineering net group",	"red hat engineering net group",  	"new.nis.domain"} ));
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
	
}