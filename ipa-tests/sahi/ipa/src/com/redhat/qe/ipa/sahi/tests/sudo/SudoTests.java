package com.redhat.qe.ipa.sahi.tests.sudo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;
import com.redhat.qe.ipa.sahi.tests.sudo.SudoTests;

public class SudoTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(SudoTests.class.getName());
	public static SahiTasks sahiTasks = null;	
	private String userPage = "/ipa/ui/#navigation=policy&policy=sudo";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+userPage, true);
	}
	

	/*
	 * Add sudorule - for positive tests
	 */
	@Test (groups={"sudoruleAddTests"}, dataProvider="getSudoruleTestObjects")	
	public void testSudoruleadd(String testName, String cn) throws Exception {
		String expectedcn=cn;
		if (cn.length() == 0) {
			expectedcn=(cn).toLowerCase();
			log.fine("Expectedcn: " + expectedcn);
		}
		
		//verify user doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(expectedcn).exists(), "Verify sudorule " + expectedcn + " doesn't already exist");
		
		//new test user can be added now
		SudoTasks.createSudorule(sahiTasks, cn);		
		
		//verify user was added successfully
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(expectedcn).exists(), "Added sudorule " + expectedcn + "  successfully");
	}
	

	/*
	 * Delete sudo rule - positive tests
	 * note: make sure tests that use testrule1 are run before testrule1 gets deleted here
	 */
	@Test (groups={"sudoruleDeleteTests"}, dataProvider="getSudoruleDeleteTestObjects", 
			dependsOnGroups={"sudoruleAddTests"})	
	public void testSudoruleDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify sudorule " + cn + "  to be deleted exists");
		
		//modify this user
		SudoTasks.deleteSudorule(sahiTasks, cn);
		
		//verify user is deleted
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Sudorule " + cn + "  deleted successfully");
	}
	
	
	/*
	 * Search
	 */
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding users - for positive cases
	 */
	@DataProvider(name="getSudoruleTestObjects")
	public Object[][] getSudoruleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleTestObjects());
	}
	protected List<List<Object>> createSudoruleTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "create_sudorule",				"testrule1"	} ));
				        
		return ll;	
	}
	
	/*
	 * Data to be used when deleting sudo rules
	 */
	@DataProvider(name="getSudoruleDeleteTestObjects")
	public Object[][] getSudoruleDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteSudoruleTestObjects());
	}
	protected List<List<Object>> deleteSudoruleTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn              		
		ll.add(Arrays.asList(new Object[]{ "delete_good_sudorule",				"testrule1"     } ));
		        
		return ll;	
	}
	
		
	
}
