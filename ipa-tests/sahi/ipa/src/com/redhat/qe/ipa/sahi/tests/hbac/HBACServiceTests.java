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
import com.redhat.qe.ipa.sahi.tests.user.UserTests;

/*
 * Feedback from review:
 * 44. HBACServiceTests.testMultipleHBACServiceDelete should verify the
deletion. //done

45. In HBACServiceTests we could try adding/removing a HBAC service
into/from HBAC service group from the HBAC service association page. //done - 
added tests: hbacServiceCancelEnrollTests, hbacServiceEnrollTests, hbacServiceCancelDeleteEnrolledTests, hbacServiceDeleteEnrolledTests
 */

public class HBACServiceTests  extends SahiTestScript{
	private static Logger log = Logger.getLogger(UserTests.class.getName());
	/*
	 * PreRequisite - 
	 */
	// HBAC Service group used in this testsuite
	private String serviceGroup = "svc-grp-1";
	private String description = "set up service group";
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		
		//Add the HBAC Service Group, if not available
		sahiTasks.navigateTo(commonTasks.hbacServiceGroupPage, true);
		if (!sahiTasks.link(serviceGroup).exists()) {
			HBACTasks.addHBACService(sahiTasks, serviceGroup, description, "Add");;
		}
		
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
			//CommonTasks.checkError(sahiTasks);testMultipleHBACServiceDelete
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.hbacServicePage, true);
		}		
	}

	/*
	 * Add a HBACService
	 */
	@Test (groups={"hbacServiceAddTests"}, description="Add a HBACService; Commented test for Bug 738339", 
			dataProvider="getHBACServiceTestObjects")	
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
	@Test (groups={"hbacServiceAddAndAddAnotherTests"}, description="Add, and then add another HBACService",
			dataProvider="getHBACServiceAddAndAddAnotherTestObjects")	
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
	@Test (groups={"hbacServiceAddAndEditTests"}, description="Add, and edit HBAC Service",
			dataProvider="getHBACServiceAddAndEditTestObjects", dependsOnGroups="hbacServiceCancelAddTests")	
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
	@Test (groups={"hbacServiceCancelAddTests"}, description="Add, but Cancel adding HBAC Service",
			dataProvider="getHBACServiceCancelAddTestObjects")	
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
	@Test (groups={"invalidhbacServiceAddTests"}, description="Add Service - for negative tests",
			dataProvider="getInvalidHBACServiceTestObjects", dependsOnGroups="hbacServiceAddTests")	
	public void testInvalidHBACServiceadd(String testName, String cn, String description, String expectedError) throws Exception {
		//new test user can be added now
		HBACTasks.createInvalidService(sahiTasks, cn, description, expectedError);		
	}
	
	
	
	/*
	 * Cancel enrolling a HBAC Service to a HBAC Service Group
	 * 
	 */
	@Test (groups={"hbacServiceCancelEnrollTests"},  description="Cancel enrolling a Service into a Service Group", 
			dataProvider="getCancelEnrollHBACServiceTestObjects", 
			dependsOnGroups={"hbacServiceAddAndEditTests"})	
	public void testHBACServiceCancelEnroll(String testName, String service) throws Exception {
		
		//verify command exists
		Assert.assertTrue(sahiTasks.link(service).exists(), "Verify Service " + service + " exists");
		
		// Enroll service, but cancel
		HBACTasks.enrollServiceInServiceGroup(sahiTasks, service, serviceGroup, "Cancel");
		
		// Verify membership
		HBACTasks.verifyHBACServiceMembership(sahiTasks, service, serviceGroup, false);
		
	}
		
	
	/*
	 * Enroll a HBAC Service to a HBAC Service Group
	 * 
	 */
	@Test (groups={"hbacServiceEnrollTests"},  description="Enroll a Service into a Service Group", 
			dataProvider="getEnrollHBACServiceTestObjects", 
			dependsOnGroups={"hbacServiceAddAndEditTests", "hbacServiceCancelEnrollTests"})	
	public void testHBACServiceEnroll(String testName, String service) throws Exception {
		
		//verify service exists
		Assert.assertTrue(sahiTasks.link(service).exists(), "Verify Service " + service + " exists");
		
		// Enroll service
		HBACTasks.enrollServiceInServiceGroup(sahiTasks, service, serviceGroup, "Enroll");
		
		// Verify membership
		HBACTasks.verifyHBACServiceMembership(sahiTasks, service, serviceGroup, true);
		
	}
	

	
	/*
	 * Cancel deleting a HBAC Service from a HBAC Service Group
	 * 
	 */
	@Test (groups={"hbacServiceCancelDeleteEnrolledTests"},  description="Cancel deleting an enrolled service from its group",
			dataProvider="getCancelDelEnrolledHBACServiceTestObjects",
			dependsOnGroups={"hbacServiceAddAndEditTests", "hbacServiceEnrollTests"})	
	public void testHBACServiceCancelDeleteEnrolled(String testName, String service) throws Exception {
		
		//verify service exists
		Assert.assertTrue(sahiTasks.link(service).exists(), "Verify Command " + service + " exists");
		
		// Enroll service
		HBACTasks.deleteServiceFromServiceGroup(sahiTasks, service, serviceGroup,  "Cancel");
		
		// Verify membership
		HBACTasks.verifyHBACServiceMembership(sahiTasks, service, serviceGroup, true);
		
	}
	

	/*
	 * Delete a HBAC Service from a HBAC Service Group
	 * 
	 */
	@Test (groups={"hbacServiceDeleteEnrolledTests"},  description="Delete an enrolled service from its group", 
			dataProvider="getDeleteEnrolledHBACServiceTestObjects",
			dependsOnGroups={"hbacServiceAddAndEditTests", "hbacServiceEnrollTests", "hbacServiceCancelDeleteEnrolledTests"})	
	public void testHBACServiceDeleteEnrolled(String testName, String service) throws Exception {
		
		//verify service exists
		Assert.assertTrue(sahiTasks.link(service).exists(), "Verify Service " + service + " exists");
		
		// Enroll service
		HBACTasks.deleteServiceFromServiceGroup(sahiTasks, service, serviceGroup, "Delete");
		
		// Verify membership
		HBACTasks.verifyHBACServiceMembership(sahiTasks, service, serviceGroup, false);
		
	}
	
	
	/*
	 * Delete multiple HBAC Services
	 */
	@Test (groups={"hbacServiceMultipleDeleteTests"}, description="Delete multiple HBAC Services",
			dataProvider="getMultipleHBACServiceTestObjects", 
			dependsOnGroups={"hbacServiceAddTests", "hbacServiceAddAndEditTests", "invalidhbacServiceAddTests", 
			"hbacServiceSearchTests", "hbacServiceEditTests", "hbacServiceEnrollTests", "hbacServiceCancelEnrollTests",
			"hbacServiceCancelDeleteEnrolledTests", "hbacServiceDeleteEnrolledTests"})
	public void testMultipleHBACServiceDelete(String testName, String cn1, String cn2, String cn3) throws Exception {	
		String cns[] = {cn1, cn2, cn3};
		
		
		//verify services to be deleted exist
		for (String cn : cns) {
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Service " + cn + "  to be deleted exists");
		}			
		//mark this rule for deletion
		HBACTasks.chooseMultiple(sahiTasks, cns);		
		HBACTasks.deleteMultiple(sahiTasks);
		
		//verify services were deleted 
		for (String cn : cns) {
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Service " + cn + "  was deleted successfully");
		}	
	}
	
	
	/*
	 * Search an HBAC Service
	 */
	@Test (groups={"hbacServiceSearchTests"}, description="Search an HBAC Service",
			dataProvider="getHBACServiceSearchTestObjects",  dependsOnGroups={"hbacServiceAddTests", "hbacServiceAddAndEditTests", "hbacServiceAddAndAddAnotherTests"})
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
	@Test (groups={"hbacServiceExpandCollapseTests"}, description="Expand/Collapse details of an HBAC Service",
			dataProvider="getHBACServiceExpandCollapseTestObjects",  dependsOnGroups="hbacServiceAddAndEditTests")	
	public void testHBACServiceExpandCollapse(String testName, String cn, String description) throws Exception {
		
		HBACTasks.expandCollapseService(sahiTasks, cn, false);		
		
	}
	
	/*
	 * Delete an HBAC Service
	 */
	@Test (groups={"hbacServiceDeleteTests"}, description="Delete an HBAC Service",
			dataProvider="getHBACServiceDeleteTestObjects", dependsOnGroups={"hbacServiceAddAndAddAnotherTests", "hbacServiceSearchTests", "hbacServiceCancelDeleteTests" })	
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
	@Test (groups={"hbacServiceEditTests"}, description="Edit an HBAC Service",
			dataProvider="getHBACServiceEditTestObjects", dependsOnGroups={"hbacServiceAddAndEditTests" })	
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
	@Test (groups={"hbacServiceCancelDeleteTests"}, description="Delete, but Cancel deleting an HBACRule",
			dataProvider="getHBACServiceCancelDeleteTestObjects", dependsOnGroups={"hbacServiceAddAndAddAnotherTests" })	
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
										//"h@ba*c#Se?r!v<i~c`e",
										"rlogin"
										} ; 
		
		//verify rules were found
		for (String hbacRuleTestObject : hbacRuleTestObjects) {
			if (sahiTasks.link(hbacRuleTestObject.toLowerCase()).exists()){
				log.fine("Cleaning HBAC Rule: " + hbacRuleTestObject);
				HBACTasks.deleteHBAC(sahiTasks, hbacRuleTestObject.toLowerCase(), "Delete");
			}			
		} 
		
		sahiTasks.navigateTo(commonTasks.hbacServiceGroupPage, true);
		if (sahiTasks.link(serviceGroup).exists()){
			HBACTasks.deleteHBAC(sahiTasks, serviceGroup, "Delete");
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
		ll.add(Arrays.asList(new Object[]{ "good_service",				"http",		"testing http service for HBAC"      } ));
		ll.add(Arrays.asList(new Object[]{ "test_service",				"https",	"testing https service for HBAC"      } ));
		ll.add(Arrays.asList(new Object[]{ "long_service",				"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789", "long svc name"      } ));
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
		ll.add(Arrays.asList(new Object[]{ "add_and_add_another_service",		"rlogin",	"portmap",	"testing svc for HBAC"			  } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding service 
	 */
	@DataProvider(name="getHBACServiceAddAndEditTestObjects")
	public Object[][] getHBACServiceAddAndEditTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceAddAndEditTestObject());
	}
	protected List<List<Object>> createHBACServiceAddAndEditTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn			description	   
		ll.add(Arrays.asList(new Object[]{ "add_and_edit_service",		"ntpd",		"testing ntpd service for HBAC"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding service 
	 */
	@DataProvider(name="getHBACServiceCancelAddTestObjects")
	public Object[][] getHBACServiceCancelAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceCancelAddTestObject());
	}
	protected List<List<Object>> createHBACServiceCancelAddTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn			description	   
		ll.add(Arrays.asList(new Object[]{ "cancel_add_service",		"ntpd",		"testing ntpd service for HBAC"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding service 
	 */
	@DataProvider(name="getHBACServiceExpandCollapseTestObjects")
	public Object[][] getHBACServiceExpandCollapseTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceExpandCollapseTestObject());
	}
	protected List<List<Object>> createHBACServiceExpandCollapseTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn			description	   
		ll.add(Arrays.asList(new Object[]{ "expandcollapse_service",		"ntpd",		"testing ntpd service for HBAC"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding service 
	 */
	@DataProvider(name="getHBACServiceEditTestObjects")
	public Object[][] getSingleHBACServiceEditTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceEditTestObject());
	}
	protected List<List<Object>> createHBACServiceEditTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname		cn			description	   
		ll.add(Arrays.asList(new Object[]{ "edit_service",		"ntpd",		"testing ntpd service for HBAC"      } ));
		
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
		ll.add(Arrays.asList(new Object[]{ "create_duplicate_service",					"http",			"duplicate service",						"HBAC service with name \"http\" already exists"      } ));
		ll.add(Arrays.asList(new Object[]{ "service_with trailing_space_in_name",		"hbacSvc ",		"service with trailing space in name",		"invalid 'service': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "service_with leading_space_in_name",		" hbacSvc",		"service with leading space in name",		"invalid 'service': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "service_with trailing_space_in_desc",		"hbacSvc",		"service with trailing space in desc ",		"invalid 'desc': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "service_with leading_space_in_desc",		"hbacSvc",		" service with leading space in desc",		"invalid 'desc': Leading and trailing spaces are not allowed"	} ));
		
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
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_service",		"http",		"https",		"ntpd"      } ));
		
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
		ll.add(Arrays.asList(new Object[]{ "delete_hbacservice",		"portmap"	 } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when deleting service 
	 */
	@DataProvider(name="getHBACServiceCancelDeleteTestObjects")
	public Object[][] getHBACServiceCancelDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(cancelDeleteHBACServiceTestObject());
	}
	protected List<List<Object>> cancelDeleteHBACServiceTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn				   
		ll.add(Arrays.asList(new Object[]{ "cancel_delete_hbacservice",		"portmap"	 } ));
		
		return ll;	
	}
	
	
	
	/*
	 * Data to be used when cancelling enrolling a service 
	 */
	@DataProvider(name="getCancelEnrollHBACServiceTestObjects")
	public Object[][] getCancelEnrollHBACServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createCancelEnrollHBACServiceTestObject());
	}
	protected List<List<Object>> createCancelEnrollHBACServiceTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname									cn				   
		ll.add(Arrays.asList(new Object[]{ "cancel_enroll_service_into_servicegroup",		"ntpd"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when enrolling a service 
	 */
	@DataProvider(name="getEnrollHBACServiceTestObjects")
	public Object[][] getEnrollHBACServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createEnrollHBACServiceTestObject());
	}
	protected List<List<Object>> createEnrollHBACServiceTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						cn				   
		ll.add(Arrays.asList(new Object[]{ "enroll_service_into_group",			"ntpd"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when cancelling deleting a service from its group 
	 */
	@DataProvider(name="getCancelDelEnrolledHBACServiceTestObjects")
	public Object[][] getCancelDelEnrolledHBACServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createCancelDelEnrolledHBACServiceTestObject());
	}
	protected List<List<Object>> createCancelDelEnrolledHBACServiceTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname							cn				   
		ll.add(Arrays.asList(new Object[]{ "cancel_deleting_service_from_group",	"ntpd"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when deleting a service from its group 
	 */
	@DataProvider(name="getDeleteEnrolledHBACServiceTestObjects")
	public Object[][] getDeleteEnrolledHBACServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDeleteEnrolledHBACServiceTestObject());
	}
	protected List<List<Object>> createDeleteEnrolledHBACServiceTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn				   
		ll.add(Arrays.asList(new Object[]{ "delete_service_from_group",		"ntpd"      } ));
		
		return ll;	
	}
}
