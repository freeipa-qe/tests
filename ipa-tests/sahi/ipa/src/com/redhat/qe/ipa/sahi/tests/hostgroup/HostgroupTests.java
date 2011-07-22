package com.redhat.qe.ipa.sahi.tests.hostgroup;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class HostgroupTests extends SahiTestScript{
	public static SahiTasks sahiTasks = null;	
	private String hostgroupPage = "/ipa/ui/#identity=hostgroup&navigation=policy";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostgroupPage, true);
	}

	/*
	 * Add host group positive tests
	 */
	@Test (groups={"addHostGroupTests"}, dataProvider="getHostGroupTestObjects")	
	public void testHostGroupAdd(String groupName, String description) throws Exception {

	}

/*******************************************************
 ************      DATA PROVIDERS     ******************
 *******************************************************/

	/*
	 * Data to be used when adding hostgroups - for positive cases
	 */
	@DataProvider(name="getHostGroupTestObjects")
	public Object[][] getHostGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostGroupTestObjects());
	}
	protected List<List<Object>> createHostGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname		groupanme		description
		ll.add(Arrays.asList(new Object[]{ 		"",				"",				"" } ));
	        
		return ll;	
	}
}