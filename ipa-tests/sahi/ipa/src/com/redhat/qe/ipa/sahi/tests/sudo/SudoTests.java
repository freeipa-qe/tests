package com.redhat.qe.ipa.sahi.tests.sudo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
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
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.setStrictVisibilityCheck(true);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&sudorule-facet=search" ;
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.hbacPage, true);
		}		
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
		
		//verify sudo rule doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(expectedcn).exists(), "Verify sudorule " + expectedcn + " doesn't already exist");
		
		//new sudo rule can be added now
		SudoTasks.createSudorule(sahiTasks, cn);		
		
		//verify sudo rule was added successfully
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(expectedcn).exists(), "Added sudorule " + expectedcn + "  successfully");
	}
	

	/*
	 * Edit Sudorule - for positive tests
	 */
	@Test (groups={"sudoruleEditTests"}, dataProvider="getsudoruleEditTestObjects", dependsOnGroups={"sudoruleCommandAddTests"})	
	public void testsudoruleEdit(String testName, String cn, String description, String ipasudoopt) throws Exception {		
		//verify sudorule to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify sudorule " + cn + " to be edited exists");
		
		//add sudo option to this rule
		SudoTasks.modifySudorule(sahiTasks, cn, description, ipasudoopt);
		
		//verify changes	
		SudoTasks.verifySudoruledescUpdates(sahiTasks, cn, description, ipasudoopt);
		
	}
	
	/*
	 * Delete sudo rule - positive tests
	 * note: make sure tests that use testrule1 are run before testrule1 gets deleted here
	 */
	@Test (groups={"sudoruleDeleteTests"}, dataProvider="getSudoruleDeleteTestObjects", 
			dependsOnGroups={"sudoruleEditTests"})	
	public void testSudoruleDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify sudorule " + cn + "  to be deleted exists");
		
		//modify this sudo rule
		SudoTasks.deleteSudorule(sahiTasks, cn);
		
		//verify user is deleted
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Sudorule " + cn + "  deleted successfully");
	}
	
	
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding sudo rules - for positive cases
	 */
	@DataProvider(name="getSudoruleTestObjects")
	public Object[][] getSudoruleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleTestObjects());
	}
	protected List<List<Object>> createSudoruleTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "create_sudorule",				"testrule1"	} ));
		/*
		ll.add(Arrays.asList(new Object[]{ "create_sudorule",				"testrule2"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudorule",				"testrule3"	} ));
		*/
		return ll;	
	}

	/*
	 * Data to be used when editing sudorule - for positive cases
	 */
	@DataProvider(name="getsudoruleEditTestObjects")
	public Object[][] getSudoruleCommandEditTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editSudoruleCommandEditTestObjects());
	}
	protected List<List<Object>> editSudoruleCommandEditTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   			description						ipasudoopt
		ll.add(Arrays.asList(new Object[]{ "edit_sudorule1",		"testrule1",		"Test description for testrule1",	"/var/log/sudolog"	} ));
								        
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
		/*
		ll.add(Arrays.asList(new Object[]{ "delete_good_sudorule",				"testrule2"     } ));
		ll.add(Arrays.asList(new Object[]{ "delete_good_sudorule",				"testrule3"     } ));
		*/        
		return ll;	
	}

	

	
	
}
