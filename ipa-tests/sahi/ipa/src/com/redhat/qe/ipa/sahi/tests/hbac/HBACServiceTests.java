package com.redhat.qe.ipa.sahi.tests.hbac;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.HBACTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;
import com.redhat.qe.ipa.sahi.tests.user.UserTests;

/*
 * Feedback from review:
 * 44. HBACServiceTests.testMultipleHBACServiceDelete should verify the
deletion.

45. In HBACServiceTests we could try adding/removing a HBAC service
into/from HBAC service group from the HBAC service association page.
 */

public class HBACServiceTests  extends SahiTestScript{
	private static Logger log = Logger.getLogger(UserTests.class.getName());
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks.navigateTo(commonTasks.hbacServicePage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&hbacsvc-facet=search" ;
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    System.out.println("CurrentPageNow: " + currentPageNow);
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			//CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.hbacServicePage, true);
		}		
	}

	/*
	 * Add a HBACService
	 */
	@Test (groups={"hbacServiceAddTests"}, description="Commented test for Bug 738339", dataProvider="getHBACServiceTestObjects")	
	public void testHBACServiceAdd(String testName, String cn, String description) throws Exception {
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Service " + cn + " doesn't already exist");
		
		HBACTasks.addHBACService(sahiTasks, cn, description, "Add");
		
		//verify rule were added
		Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Added HBAC Service " + cn + "  successfully");
	}
	
	/*
	 * Add, and then add another HBACService
	 */
	@Test (groups={"hbacServiceAddAndAddAnotherTests"}, dataProvider="getHBACServiceAddAndAddAnotherTestObjects")	
	public void testHBACServiceAddAndAddAnother(String testName, String cn1, String cn2, String description) throws Exception {
		//verify user, user group, host, host group doesn't exist
		Assert.assertFalse(sahiTasks.link(cn1).exists(), "Verify HBAC Service " + cn1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(cn2).exists(), "Verify HBAC Service " + cn2 + " doesn't already exist");
		
		HBACTasks.addHBACServiceThenAddAnother(sahiTasks, cn1, cn2, description);
		
		//verify user, user group, host, host group were added
		Assert.assertTrue(sahiTasks.link(cn1).exists(), "Added HBAC Service " + cn1 + "  successfully");
				
		Assert.assertTrue(sahiTasks.link(cn2).exists(), "Added HBAC Service " + cn2 + "  successfully");
	}
	
	/*
	 * Add, and edit HBAC Service
	 */	
	@Test (groups={"hbacServiceAddAndEditTests"}, dataProvider="getSingleHBACServiceTestObjects", dependsOnGroups="hbacServiceCancelAddTests")	
	public void testHBACServiceAddAndEdit(String testName, String cn, String description) throws Exception {
		
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify Service " + cn + " doesn't already exist");
		
		//new test rule can be added now
		HBACTasks.addAndEditHBACService(sahiTasks, cn, description);				
		
		//verify changes	
		HBACTasks.verifyHBACServiceUpdates(sahiTasks, cn, description);
	}
	
	/*
	 * Add, but Cancel adding HBAC Service
	 */
	@Test (groups={"hbacServiceCancelAddTests"}, dataProvider="getSingleHBACServiceTestObjects")	
	public void testHBACServiceCancelAdd(String testName, String cn, String description) throws Exception {
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Service " + cn + " doesn't already exist");
		
		//new test rule can be added now
		HBACTasks.addHBACService(sahiTasks, cn, description, "Cancel");
		
		//verify rule was added successfully
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Service " + cn + "  was not added");
	}
	

	/*
	 * Add Service - for negative tests
	 */
	@Test (groups={"invalidhbacServiceAddTests"}, dataProvider="getInvalidHBACServiceTestObjects", dependsOnGroups="hbacServiceAddTests")	
	public void testInvalidHBACServiceadd(String testName, String cn, String description, String expectedError) throws Exception {
		//new test user can be added now
		HBACTasks.createInvalidService(sahiTasks, cn, description, expectedError);		
	}
	
	/*
	 * Delete multiple HBAC Services
	 */
	@Test (groups={"hbacServiceMultipleDeleteTests"}, dataProvider="getMultipleHBACServiceTestObjects", dependsOnGroups={"hbacServiceAddTests", "hbacServiceAddAndEditTests", "invalidhbacServiceAddTests", "hbacServiceSearchTests", "hbacServiceEditTests" })
	public void testMultipleHBACServiceDelete(String testName, String cn1, String cn2, String cn3) throws Exception {	
		String cns[] = {cn1, cn2, cn3};
		
		
		//verify rule to be deleted exists
		for (String cn : cns) {
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Service " + cn + "  to be deleted exists");
		}			
		//mark this rule for deletion
		HBACTasks.chooseMultiple(sahiTasks, cns);		
		HBACTasks.deleteMultiple(sahiTasks);
	}
	
	
	/*
	 * Search an HBAC Service
	 */
	@Test (groups={"hbacServiceSearchTests"}, dataProvider="getHBACServiceSearchTestObjects",  dependsOnGroups={"hbacServiceAddTests", "hbacServiceAddAndEditTests", "hbacServiceAddAndAddAnotherTests"})
	public void testHBACServiceSearch(String testName, String searchString, String multipleResult1, String multipleResult2, String multipleResult3, String multipleResult4, String multipleResult5) throws Exception {		
		String[] multipleResults = {multipleResult1, multipleResult2, multipleResult3, multipleResult4, multipleResult5}; 
		CommonTasks.search(sahiTasks, searchString);
		
	
		//verify Services are found
		for (String multipleResult : multipleResults) {
			Assert.assertTrue(sahiTasks.link(multipleResult).exists(), "Verify HBAC Service " + multipleResult + " was found while searching");
		}
			
		CommonTasks.clearSearch(sahiTasks);
	}
	
	/*
	 * Expand/Collapse details of an HBAC Service
	 */
	@Test (groups={"hbacServiceExpandCollapseTests"}, dataProvider="getSingleHBACServiceTestObjects",  dependsOnGroups="hbacServiceAddAndEditTests")	
	public void testHBACServiceExpandCollapse(String testName, String cn, String description) throws Exception {
		
		HBACTasks.expandCollapseService(sahiTasks, cn, false);		
		
	}
	
	/*
	 * Delete an HBAC Service
	 */
	@Test (groups={"hbacServiceDeleteTests"}, dataProvider="getHBACServiceDeleteTestObjects", dependsOnGroups={"hbacServiceAddAndAddAnotherTests", "hbacServiceSearchTests", "hbacServiceCancelDeleteTests" })	
	public void testHBACServiceDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Service " + cn + "  to be deleted exists");
		
		//modify this user
		HBACTasks.deleteHBAC(sahiTasks, cn, "Delete");
		
		//verify user is deleted
		Assert.assertFalse(sahiTasks.link(cn).exists(), "HBAC Service " + cn + "  deleted successfully");
	}
	
	/*
	 * Edit an HBAC Service
	 */
	@Test (groups={"hbacServiceEditTests"}, dataProvider="getSingleHBACServiceTestObjects", dependsOnGroups={"hbacServiceAddAndEditTests" })	
	public void testHBACServiceEdit(String testName, String cn, String description) throws Exception {
		//verify HBAC Service to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + "  to be edited exists");
		
		//modify this HBAC Service
		HBACTasks.editHBACService(sahiTasks, cn, description, "Cancel", false);
		HBACTasks.editHBACService(sahiTasks, cn, description, "Reset", false);
		HBACTasks.editHBACService(sahiTasks, cn, description, "Update", false);
		
	}
	

	/*
	 * Delete, but Cancel deleting an HBACRule
	 */
	@Test (groups={"hbacServiceCancelDeleteTests"}, dataProvider="getHBACServiceDeleteTestObjects", dependsOnGroups={"hbacServiceAddAndAddAnotherTests" })	
	public void testHBACServiceCancelDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + "  to be deleted exists");
		
		//modify this user
		HBACTasks.deleteHBAC(sahiTasks, cn, "Cancel");
		
		//verify user is deleted
		Assert.assertTrue(sahiTasks.link(cn).exists(), "HBAC Rule " + cn + "  was not deleted");
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true, dependsOnGroups="init")
	public void cleanup() throws CloneNotSupportedException {
		String[] hbacRuleTestObjects = {"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",
										//"h@ba*c#Se?r!v<i~c`e"
										} ; 
		
		//verify rules were found
		for (String hbacRuleTestObject : hbacRuleTestObjects) {
			if (sahiTasks.link(hbacRuleTestObject.toLowerCase()).exists()){
				log.fine("Cleaning Sudo Rule: " + hbacRuleTestObject);
				HBACTasks.deleteHBAC(sahiTasks, hbacRuleTestObject.toLowerCase(), "Delete");
			}			
		} 
		
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding HBAC Service 
	 */
	@DataProvider(name="getHBACServiceTestObjects")
	public Object[][] getHBACServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceTestObjects());
	}
	protected List<List<Object>> createHBACServiceTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn			description
		ll.add(Arrays.asList(new Object[]{ "good_hbacservice",				"http",		"testing http service for HBAC"      } ));
		ll.add(Arrays.asList(new Object[]{ "good_hbacservice",				"https",	"testing https service for HBAC"      } ));
		ll.add(Arrays.asList(new Object[]{ "hbacservice_long",				"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789", "long svc name"      } ));
		// FIXME: nkrishnan - Bug 738339 - [ipa webui] Encode special chars in values when displaying 
		// not uncommenting, since flow depends on this test passing
	   // ll.add(Arrays.asList(new Object[]{ "hbacservice_specialchar",	    "h@ba*c#Se?r!v<i~c`e",			"svc name with special char"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding services 
	 */
	@DataProvider(name="getHBACServiceAddAndAddAnotherTestObjects")
	public Object[][] getHBACServiceAddAndAddAnotherTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceAndAddAnotherTestObject());
	}
	protected List<List<Object>> createHBACServiceAndAddAnotherTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						cn1			cn2 		description  
		ll.add(Arrays.asList(new Object[]{ "create_two_good_hbacservice",		"rlogin",	"portmap",	"testing svc for HBAC"			  } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding service 
	 */
	@DataProvider(name="getSingleHBACServiceTestObjects")
	public Object[][] getSingleHBACServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSingleHBACServiceTestObject());
	}
	protected List<List<Object>> createSingleHBACServiceTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn			description	   
		ll.add(Arrays.asList(new Object[]{ "create_good_hbacservice",		"ntpd",		"testing ntpd service for HBAC"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding invalid Service 
	 */
	@DataProvider(name="getInvalidHBACServiceTestObjects")
	public Object[][] getInvalidHBACServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidHBACServiceTestObject());
	}
	protected List<List<Object>> createInvalidHBACServiceTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname								cn				description									expected_Error   
		ll.add(Arrays.asList(new Object[]{ "create_duplicate_hbacservice",				"http",			"duplicate service",						"HBAC service with name \"http\" already exists"      } ));
		ll.add(Arrays.asList(new Object[]{ "hbacservice_with trailing_space_in_name",	"hbacSvc ",		"service with trailing space in name",		"invalid 'service': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "hbacservice_with leading_space_in_name",	" hbacSvc",		"service with leading space in name",		"invalid 'service': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "hbacservice_with trailing_space_in_desc",	"hbacSvc",		"service with trailing space in desc ",		"invalid 'desc': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "hbacservice_with leading_space_in_desc",	"hbacSvc",		" service with leading space in desc",		"invalid 'desc': Leading and trailing spaces are not allowed"	} ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when deleting multiple Services 
	 */
	@DataProvider(name="getMultipleHBACServiceTestObjects")
	public Object[][] getMultipleHBACServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteMultipleHBACServiceTestObjects());
	}
	protected List<List<Object>> deleteMultipleHBACServiceTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn1			cn2				cn3																																	cn4   
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_hbacservice",	"http",		"https",		"ntpd"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when searching for Services 
	 */
	@DataProvider(name="getHBACServiceSearchTestObjects")
	public Object[][] getHBACServiceSearchTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(searchHBACServiceTestObjects());
	}
	protected List<List<Object>> searchHBACServiceTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			searchstring	cn1			cn2			cn3			cn4			cn5																																	cn4   
		ll.add(Arrays.asList(new Object[]{ "search_hbacservice",	"testing",		"http",		"https",	"ntpd",		"rlogin",	"portmap"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when deleting service 
	 */
	@DataProvider(name="getHBACServiceDeleteTestObjects")
	public Object[][] getHBACServiceDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteHBACServiceTestObject());
	}
	protected List<List<Object>> deleteHBACServiceTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn				   
		ll.add(Arrays.asList(new Object[]{ "delete_hbacservice1",		"portmap"	 } ));
		ll.add(Arrays.asList(new Object[]{ "delete_hbacservice2",		"rlogin"	 } ));
		
		return ll;	
	}
	
	
}
