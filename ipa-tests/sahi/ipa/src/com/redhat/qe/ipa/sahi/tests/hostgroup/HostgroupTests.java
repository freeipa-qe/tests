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
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
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
		HostgroupTasks.addAndAddAnotherHost(sahiTasks, groupName1, groupName2, groupName3);
	
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

/*******************************************************
 ************      DATA PROVIDERS     ******************
 *******************************************************/

	/*
	 * Data to be used when adding hostgroups - for positive cases
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
	 * Data to be used when deleting hostgroups - for positive cases
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
	 * Data to be used when adding hostgroups - for positive cases
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
}