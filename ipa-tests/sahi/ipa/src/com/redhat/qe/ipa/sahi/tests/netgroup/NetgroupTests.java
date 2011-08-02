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
	
}