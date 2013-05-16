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
 * Comments from review
 * 46. In HBACServiceGroupTests we can verify that removing a service group
will remove the group from the member service's memberof list. //done - testHBACServiceGroupEnrollServiceDeleteGroup()

47. HBACServiceGroupTests.testMultipleHBACServiceGroupDelete should
verify the deletion. //done
 */

public class HBACServiceGroupTests extends SahiTestScript{
private static Logger log = Logger.getLogger(UserTests.class.getName());
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks.navigateTo(commonTasks.hbacServiceGroupPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&hbacsvcgroup-facet=search" ;
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    System.out.println("CurrentPageNow: " + currentPageNow);
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			//CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.hbacServiceGroupPage, true);
		}		
	}
	
	/*
	 * Add a HBACService Group
	 */
	@Test (groups={"hbacServiceGroupAddTests"}, description="Add a HBAC Service Group",
			dataProvider="getHBACServiceGroupTestObjects")	
	public void testHBACServiceGroupAdd(String testName, String cn, String description) throws Exception {
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn.toLowerCase()).exists(), "Verify HBAC Service Group" + cn + " doesn't already exist");
		
		HBACTasks.addHBACService(sahiTasks, cn, description, "Add");
		
		//verify rule were added
		Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Added HBAC Service Group " + cn + "  successfully");
	}
	
	/*
	 * Add, and then add another HBAC Service Group
	 */
	@Test (groups={"hbacServiceGroupAddAndAddAnotherTests"}, description="Add, and then add another HBAC Service Group",
			dataProvider="getHBACServiceGroupAddAndAddAnotherTestObjects")	
	public void testHBACServiceGroupAddAndAddAnother(String testName, String cn1, String cn2, String description) throws Exception {
		//verify user, user group, host, host group doesn't exist
		Assert.assertFalse(sahiTasks.link(cn1).exists(), "Verify HBAC Service Group " + cn1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(cn2).exists(), "Verify HBAC Service Group " + cn2 + " doesn't already exist");
		
		HBACTasks.addHBACServiceThenAddAnother(sahiTasks, cn1, cn2, description);
		
		//verify user, user group, host, host group were added
		Assert.assertTrue(sahiTasks.link(cn1).exists(), "Added HBAC Service Group " + cn1 + "  successfully");
		Assert.assertTrue(sahiTasks.link(cn2).exists(), "Added HBAC Service Group " + cn2 + "  successfully");
	}
	
	/*
	 * Add, and edit HBAC Service group
	 */	
	@Test (groups={"hbacServiceGroupAddAndEditTests"}, description="Add, and edit HBAC Service group",
			dataProvider="getHBACServiceGroupAddAndEditTestObjects", dependsOnGroups="hbacServiceGroupCancelAddTests")	
	public void testHBACServiceGroupAddAndEdit(String testName, String cn, String description) throws Exception {
		
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify Service Group " + cn + " doesn't already exist");
		
		//new test rule can be added now
		String newdescription = "new testing su-test service group for HBAC"  ;
		HBACTasks.addAndEditHBACServiceGroup(sahiTasks, cn, description, newdescription);				
		
		//verify changes	
		HBACTasks.verifyHBACServiceGroupUpdates(sahiTasks, cn, newdescription);
	}
	
	/*
	 * Add, but Cancel adding HBAC Service Group
	 */
	@Test (groups={"hbacServiceGroupCancelAddTests"}, description="Add, but Cancel adding HBAC Service Group",
			dataProvider="getHBACServiceGroupCancelAddTestObjects")	
	public void testHBACServiceGroupCancelAdd(String testName, String cn, String description) throws Exception {
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Service Group " + cn + " doesn't already exist");
		
		//new test rule can be added now
		HBACTasks.addHBACService(sahiTasks, cn, description, "Cancel");
		
		//verify rule was added successfully
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Service Group " + cn + "  was not added");
	}
	
	
	/*
	 * Add Service Group- for negative tests
	 */
	@Test (groups={"invalidhbacServiceGroupAddTests"}, description="Add Service Group- for negative tests",
			dataProvider="getInvalidHBACServiceGroupTestObjects")	
	public void testInvalidHBACServiceGroupadd(String testName, String cn, String description, String expectedError) throws Exception {
		//new test user can be added now
		HBACTasks.createInvalidService(sahiTasks, cn, description, expectedError);		
	} 
	
	 
	/*
	 * Search an HBAC Service Group
	 */
	@Test (groups={"hbacServiceGroupSearchTests"}, description="Search an HBAC Service Group",
			dataProvider="getHBACServiceGroupSearchTestObjects",  
			dependsOnGroups={"hbacServiceGroupAddTests", "hbacServiceGroupAddAndEditTests", "hbacServiceGroupAddAndAddAnotherTests"})
	public void testHBACServiceGroupSearch(String testName, String searchString, String multipleResult1, String multipleResult2, String multipleResult3, String multipleResult4) throws Exception {		
		String[] multipleResults = {multipleResult1, multipleResult2, multipleResult3, multipleResult4}; 
		
		CommonTasks.search(sahiTasks, searchString);
		
	
		//verify Services are found
		for (String multipleResult : multipleResults) {
			Assert.assertTrue(sahiTasks.link(multipleResult).exists(), "Verify HBAC Service Group " + multipleResult + " was found while searching");
		}
			
		CommonTasks.clearSearch(sahiTasks);
	}
	
	/*
	 * Expand/Collapse details of an HBAC Service Group
	 */
	@Test (groups={"hbacServiceGroupExpandCollapseTests"}, description="Expand/Collapse details of an HBAC Service Group",
			dataProvider="getHBACServiceGroupExpandCollapseTestObjects",  dependsOnGroups="hbacServiceGroupAddAndEditTests")	
	public void testHBACServiceGroupExpandCollapse(String testName, String cn, String description) throws Exception {
		
		HBACTasks.expandCollapseService(sahiTasks, cn, true);		
		
	}
	
	
	
	/*
	 * Edit an HBAC service group, and navigate back and forth between the group, and its service member
	 */
	@Test (groups={"hbacServiceGroupNavigateTests"}, description="Edit an HBAC service group, and navigate back and forth between the group, and its service member",
			dataProvider="getHBACServiceGroupNavigateTestObjects", dependsOnGroups={"hbacServiceGroupAddAndEditTests" })	
	public void testHBACServiceGroupNavigate(String testName, String cn, String description) throws Exception {
		// the group added in a previous test - su-test - has 2 services enrolled - su and su-l
			
		HBACTasks.verifyHBACServiceGroupNavigation(sahiTasks, cn);
		sahiTasks.navigateTo(commonTasks.hbacServiceGroupPage, true);//xdong
		if (System.getProperty("os.name").startsWith("Windows"))//mvarun
		{
			sahiTasks.link("HBAC Service Groups").in(sahiTasks.div("content nav-space-3")).click();//Xdong
		}
	
	}
	
	/*
	 * Enroll same service in 2 different groups, then delete from one group, then delete 
	 * the service (thus deleting from the other group)
	 */
	@Test (groups={"hbacServiceGroupOneServiceTwoGroupsTests"}, description="Enroll svc in 2 grps, del from one, then another, verify memberships",
			dataProvider="getHBACServiceGroupOneServiceTwoGroupsTestObjects", 
			dependsOnGroups={"hbacServiceGroupAddAndAddAnotherTests" })	
	public void testHBACServiceGroupOneServiceTwoGroups(String testName, String service, String svcgrp1, String svcgrp2, String svcDescription) throws Exception {
		//add a service - rlogin
		sahiTasks.navigateTo(commonTasks.hbacServicePage, true);
		HBACTasks.addHBACService(sahiTasks, service, svcDescription, "Add");
		sahiTasks.navigateTo(commonTasks.hbacServiceGroupPage, true);
		
		//enroll rlogin into login1, login2
		HBACTasks.enrollServiceinServiceGroup(sahiTasks, svcgrp1, service);
		HBACTasks.enrollServiceinServiceGroup(sahiTasks, svcgrp2, service);
		
		HBACTasks.verifyServicesInServiceGroup(sahiTasks, service, svcgrp1, true);
		HBACTasks.verifyServicesInServiceGroup(sahiTasks, service, svcgrp2, true);
		
		HBACTasks.deleteFromServiceGroup(sahiTasks, service, svcgrp1, "Delete");
		HBACTasks.verifyServicesInServiceGroup(sahiTasks, service, svcgrp1, false);
		HBACTasks.verifyServicesInServiceGroup(sahiTasks, service, svcgrp2, true);
		
		sahiTasks.navigateTo(commonTasks.hbacServicePage, true);
		HBACTasks.deleteHBAC(sahiTasks, service, "Delete");
		sahiTasks.navigateTo(commonTasks.hbacServiceGroupPage, true);
		HBACTasks.verifyServicesInServiceGroup(sahiTasks, service, svcgrp2, false);		
	}
	
	/*
	 * Enroll service in a group. Verify memberships. Now delete the service group, and 
	 * verify membership for the service
	 */
	@Test (groups={"hbacServiceGroupEnrollServiceDeleteGroupTests"}, description="Enroll service, delete group, verify membership of service",
			dataProvider="getHBACServiceGroupEnrollServiceDeleteGroupTestObjects")	
	public void testHBACServiceGroupEnrollServiceDeleteGroup(String testName, String service, String svcgrp, String description) throws Exception {
		
		Assert.assertFalse(sahiTasks.link(svcgrp).exists(), "Verify HBAC Service Group " + svcgrp + "  to be added does not exist");
		
		//add the service group
		HBACTasks.addHBACService(sahiTasks, svcgrp, description, "Add");
		//enroll service
		HBACTasks.enrollServiceinServiceGroup(sahiTasks, svcgrp, service);
		//verify membership
		sahiTasks.navigateTo(commonTasks.hbacServicePage, true);
		HBACTasks.verifyHBACServiceMembership(sahiTasks, service, svcgrp, true);
		sahiTasks.navigateTo(commonTasks.hbacServiceGroupPage, true);
		//delete service group
		HBACTasks.deleteHBAC(sahiTasks, svcgrp, "Delete");
		//verify membership
		sahiTasks.navigateTo(commonTasks.hbacServicePage, true);
		HBACTasks.verifyHBACServiceMembership(sahiTasks, service, svcgrp, false);
		sahiTasks.navigateTo(commonTasks.hbacServiceGroupPage, true);
		
	}
	
	
	
	/*
	 * Enroll service 
	 */
	@Test (groups={"hbacServiceGroupEnrollServiceTests"}, description="Enroll service",
			dataProvider="getEnrollHBACServiceInServiceGroupTestObjects", dependsOnGroups={"hbacServiceGroupAddTests" })	
	public void testHBACServiceGroupEnrollService(String testName, String service, String svcgrp) throws Exception {
		Assert.assertTrue(sahiTasks.link(svcgrp).exists(), "Verify HBAC Service Group " + svcgrp + "  to be edited exists");
		
		HBACTasks.enrollServiceinServiceGroup(sahiTasks, svcgrp, service);
		HBACTasks.verifyServicesInServiceGroup(sahiTasks, service, svcgrp, true);
		//HBACTasks.enrollServiceAgainInServiceGroup(sahiTasks, svcgrp, service);
	}
	
	
	/*
	 * Edit an HBAC Service Group to delete a service
	 */
	@Test (groups={"hbacServiceGroupDeleteServiceTests"}, description="Edit an HBAC Service Group to delete a service",
			dataProvider="getHBACServiceGroupDeleteServiceTestObjects", dependsOnGroups={"hbacServiceGroupAddTests", "hbacServiceGroupEnrollServiceTests", "hbacServiceGroupCancelDeleteServiceTests" })	
	public void testHBACServiceGroupDeleteService(String testName, String service, String svcgrp) throws Exception {
		
		Assert.assertTrue(sahiTasks.link(svcgrp).exists(), "Verify HBAC Service Group " + svcgrp + "  to be edited exists");
		HBACTasks.verifyServicesInServiceGroup(sahiTasks, service, svcgrp, true);
		
		HBACTasks.deleteFromServiceGroup(sahiTasks, service, svcgrp, "Delete");
		HBACTasks.verifyServicesInServiceGroup(sahiTasks, service, svcgrp, false);
	}
	
		
	
	/*
	 * Edit an HBAC Service Group to cancel deleting a service
	 */
	@Test (groups={"hbacServiceGroupCancelDeleteServiceTests"}, description="Edit an HBAC Service Group to cancel deleting a service", 
			dataProvider="getHBACServiceCancelDeleteServiceTestObjects", 
			dependsOnGroups={"hbacServiceGroupAddTests", "hbacServiceGroupEnrollServiceTests" })	
	public void testHBACServiceGroupCancelDeleteService(String testName, String service, String svcgrp) throws Exception {
		Assert.assertTrue(sahiTasks.link(svcgrp).exists(), "Verify HBAC Service Group " + svcgrp + "  to be edited exists");
		HBACTasks.verifyServicesInServiceGroup(sahiTasks, service, svcgrp, true);
		
		HBACTasks.deleteFromServiceGroup(sahiTasks, service, svcgrp, "Cancel");
		HBACTasks.verifyServicesInServiceGroup(sahiTasks, service, svcgrp, true);
	}
	
	
	
	
	/*
	 * Edit an HBAC Service Group
	 */
	@Test (groups={"hbacServiceGroupEditTests"}, description="Edit an HBAC Service Group",
			dataProvider="getHBACServiceGroupEditTestObjects", 
			dependsOnGroups={"hbacServiceGroupAddAndEditTests" })	
	public void testHBACServiceGroupEdit(String testName, String cn, String description) throws Exception {
		//verify HBAC Service to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Service Group " + cn + "  to be edited exists");
		
		//modify this HBAC Service
		String newdescription = "new testing su-test service group for HBAC"  ;
		HBACTasks.editHBACService(sahiTasks, cn, newdescription, "Cancel", true);
		HBACTasks.editHBACService(sahiTasks, cn, newdescription, "Reset", true);
		HBACTasks.editHBACService(sahiTasks, cn, newdescription, "Update", true);
		
	}
	
	/*
	 * Delete, but Cancel deleting an HBAC Service Group
	 */
	@Test (groups={"hbacServiceGroupCancelDeleteTests"}, description="Cancel deleting a HBAC Service Group",
			dataProvider="getHBACServiceGroupCancelDeleteTestObjects", 
			dependsOnGroups={"hbacServiceGroupAddAndAddAnotherTests" })	
	public void testHBACServiceGroupCancelDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Service Group " + cn + "  to be deleted exists");
		
		HBACTasks.deleteHBAC(sahiTasks, cn, "Cancel");
		
		//verify user is deleted
		Assert.assertTrue(sahiTasks.link(cn).exists(), "HBAC Service Group " + cn + "  was not deleted");
	}
	
	
	/*
	 * Delete an HBAC Service Group
	 */
	@Test (groups={"hbacServiceGroupDeleteTests"}, description="Delete an HBAC Service Group",
			dataProvider="getHBACServiceGroupDeleteTestObjects", dependsOnGroups={"hbacServiceGroupAddAndAddAnotherTests", "hbacServiceGroupSearchTests", "hbacServiceGroupCancelDeleteTests" })	
	public void testHBACServiceGroupDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Service Group " + cn + "  to be deleted exists");
		
		HBACTasks.deleteHBAC(sahiTasks, cn, "Delete");
		
		//verify user is deleted
		Assert.assertFalse(sahiTasks.link(cn).exists(), "HBAC Service Group " + cn + "  deleted successfully");
	}
	
	
	/*
	 * Delete multiple HBAC Service Groups
	 */
	@Test (groups={"hbacServiceGroupMultipleDeleteTests"}, description="Delete multiple HBAC Service Groups",
			dataProvider="getMultipleHBACServiceGroupTestObjects", dependsOnGroups={"hbacServiceGroupAddTests", "hbacServiceGroupAddAndEditTests", "invalidhbacServiceGroupAddTests", 
			"hbacServiceGroupSearchTests", "hbacServiceGroupEditTests", "hbacServiceGroupCancelDeleteServiceTests", "hbacServiceGroupDeleteServiceTests", "invalidhbacServiceGroupModTests" })
	public void testMultipleHBACServiceGroupDelete(String testName, String cn1, String cn2, String cn3) throws Exception {	
		String cns[] = {cn1, cn2, cn3};
		
		
		//verify service groups to be deleted exist
		for (String cn : cns) {
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Service Groups " + cn + "  to be deleted exists");
		}			
		//mark this rule for deletion
		HBACTasks.chooseMultiple(sahiTasks, cns);		
		HBACTasks.deleteMultiple(sahiTasks);
		
		//verify service groups were deleted
		for (String cn : cns) {
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Service Groups " + cn + "  was deleted successfully");
		}
	}
	
	
	@Test (groups={"invalidhbacServiceGroupModTests"}, description="Modify HBAC Service Group With Invalid Setting",
			dataProvider="getHBACServiceGroupInvalidAddTestObjects", dependsOnGroups={"hbacServiceGroupAddTests"} )
	public void testInvalidHBACServiceGroupMod(String testName, String cn, String description, String expectedError) throws Exception {
		HBACTasks.modifyHBACServiceGroupWithInvalidSetting(sahiTasks, cn, description, expectedError);
	}
	
	
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true, dependsOnGroups="init")
	public void cleanup() throws CloneNotSupportedException {
		String[] hbacServiceGroupTestObjects = {"hbac group1",
												"hbac group2",
												"su-test",
												"web",
												"abcdefghijklmnopqrstuvwxyz123456789@ANDAGAIN#abcdefghijklmnopqrstuvwxyz123456789*ANDAGAINabcdefghijklmnopqrstuvwxyz123456789?".toLowerCase(),
												"login2"
												} ; 
		
		//verify rules were found
		for (String hbacServiceGroupTestObject : hbacServiceGroupTestObjects) {
			if (sahiTasks.link(hbacServiceGroupTestObject.toLowerCase()).exists()){
				log.fine("Cleaning HBAC Service Group: " + hbacServiceGroupTestObject);
				HBACTasks.deleteHBAC(sahiTasks, hbacServiceGroupTestObject.toLowerCase(), "Delete");
			}			
		} 
		
	}
	
	
	
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding HBAC Service 
	 */
	@DataProvider(name="getHBACServiceGroupTestObjects")
	public Object[][] getHBACServiceGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupTestObjects());
	}
	protected List<List<Object>> createHBACServiceGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn			description
		ll.add(Arrays.asList(new Object[]{ "add_good_servicegroup",			"web",		"testing http service group for HBAC"      } ));
		ll.add(Arrays.asList(new Object[]{ "add_long_servicegroup",			"abcdefghijklmnopqrstuvwxyz123456789@ANDAGAIN#abcdefghijklmnopqrstuvwxyz123456789*ANDAGAINabcdefghijklmnopqrstuvwxyz123456789?",		"testing https service group for HBAC"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding service groups
	 */
	@DataProvider(name="getHBACServiceGroupAddAndAddAnotherTestObjects")
	public Object[][] getHBACServiceGroupAddAndAddAnotherTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupAndAddAnotherTestObject());
	}
	protected List<List<Object>> createHBACServiceGroupAndAddAnotherTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname							cn1			cn2 		description  
		ll.add(Arrays.asList(new Object[]{ "add_and_add_another_servicegroup",		"login1",	"login2",	"testing svc groups for HBAC"			  } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding service group
	 */
	@DataProvider(name="getHBACServiceGroupAddAndEditTestObjects")
	public Object[][] getHBACServiceGroupAddAndEditTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupAddAndEditTestObject());
	}
	protected List<List<Object>> createHBACServiceGroupAddAndEditTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						cn				description	   								
		ll.add(Arrays.asList(new Object[]{ "add_and_edit_servicegroup",		"su-test",		"testing su-test service group for HBAC"    } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding service group
	 */
	@DataProvider(name="getHBACServiceGroupCancelAddTestObjects")
	public Object[][] getHBACServiceGroupCancelAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupCancelAddTestObject());
	}
	protected List<List<Object>> createHBACServiceGroupCancelAddTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						cn				description	   								
		ll.add(Arrays.asList(new Object[]{ "cancel_add_servicegroup",		"su-test",		"testing su-test service group for HBAC"    } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding service group
	 */
	@DataProvider(name="getHBACServiceGroupExpandCollapseTestObjects")
	public Object[][] getHBACServiceGroupExpandCollapseTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupExpandCollapseTestObject());
	}
	protected List<List<Object>> createHBACServiceGroupExpandCollapseTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						cn				description	   								
		ll.add(Arrays.asList(new Object[]{ "expand_collapse_servicegroup",		"su-test",		"testing su-test service group for HBAC"    } ));
		
		return ll;	
	}
	
	
	
	/*
	 * Data to be used when adding service group
	 */
	@DataProvider(name="getHBACServiceGroupNavigateTestObjects")
	public Object[][] getHBACServiceGroupNavigateTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupNavigateTestObject());
	}
	protected List<List<Object>> createHBACServiceGroupNavigateTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn				description	   								
		ll.add(Arrays.asList(new Object[]{ "navigate_servicegroup",		"su-test",		"testing su-test service group for HBAC"    } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding service group
	 */
	@DataProvider(name="getHBACServiceGroupEditTestObjects")
	public Object[][] getHBACServiceGroupEditTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupEditTestObject());
	}
	protected List<List<Object>> createHBACServiceGroupEditTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			cn				description	   								
		ll.add(Arrays.asList(new Object[]{ "edit_servicegroup",		"su-test",		"testing su-test service group for HBAC"    } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding invalid Service Group 
	 */
	@DataProvider(name="getInvalidHBACServiceGroupTestObjects")
	public Object[][] getInvalidHBACServiceGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidHBACServiceGroupTestObject());
	}
	protected List<List<Object>> createInvalidHBACServiceGroupTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname									cn								description 					expected_Error   
		ll.add(Arrays.asList(new Object[]{ "create_duplicate_servicegroup",				"ftp",							"duplicate service group", 		"HBAC service group with name \"ftp\" already exists"      } ));
		ll.add(Arrays.asList(new Object[]{ "servicegroup_with trailing_space_in_name",	"hbacServiceGroup ",			"name with trailing space", 	"invalid 'name': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "servicegroup_with leading_space_in_name",	" hbacServiceGroup",			"name with leading space",		"invalid 'name': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "servicegroup_with trailing_space_in_desc",	"hbacServiceGroup",				"desc with trailing space ",	"invalid 'desc': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "servicegroup_with leading_space_in_desc",	"hbacServiceGroup",				" desc with leading space",		"invalid 'desc': Leading and trailing spaces are not allowed"	} ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when searching for Service Groups
	 */
	@DataProvider(name="getHBACServiceGroupSearchTestObjects")
	public Object[][] getHBACServiceGroupSearchTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(searchHBACServiceGroupTestObjects());
	}
	protected List<List<Object>> searchHBACServiceGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				searchstring	cn1			cn2			cn3			cn4																																		cn4   
		ll.add(Arrays.asList(new Object[]{ "search_servicegroup",	"testing",		"login1",	"login2",	"su-test",		"web"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when deleting service groups
	 */
	@DataProvider(name="getHBACServiceGroupDeleteTestObjects")
	public Object[][] getHBACServiceGroupDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteHBACServiceGroupTestObject());
	}
	protected List<List<Object>> deleteHBACServiceGroupTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn				   
		ll.add(Arrays.asList(new Object[]{ "delete_servicegroup",		"login1"	 } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when cancelling deleting service groups
	 */
	@DataProvider(name="getHBACServiceGroupCancelDeleteTestObjects")
	public Object[][] getHBACServiceGroupCancelDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(cancelDeleteHBACServiceGroupTestObject());
	}
	protected List<List<Object>> cancelDeleteHBACServiceGroupTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						cn				   
		ll.add(Arrays.asList(new Object[]{ "cancel_delete_servicegroup",		"login1"	 } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when deleting multiple Service Groups 
	 */
	@DataProvider(name="getMultipleHBACServiceGroupTestObjects")
	public Object[][] getMultipleHBACServiceGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteMultipleHBACServiceGroupTestObjects());
	}
	protected List<List<Object>> deleteMultipleHBACServiceGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						cn1			cn2			cn3																																	cn4   
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_servicegroups",		"su-test",		"web",		"abcdefghijklmnopqrstuvwxyz123456789@andagain#abcdefghijklmnopqrstuvwxyz123456789*andagainabcdefghijklmnopqrstuvwxyz123456789?"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when deleting multiple Service Groups 
	 */
	@DataProvider(name="getHBACServiceGroupOneServiceTwoGroupsTestObjects")
	public Object[][] getHBACServiceGroupOneServiceTwoGroupsTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupOneServiceTwoGroupsTestObjects());
	}
	protected List<List<Object>> createHBACServiceGroupOneServiceTwoGroupsTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				service			svcgrp1			svcgrp2			description	   
		ll.add(Arrays.asList(new Object[]{ "one_service_two_groups",	"rlogin",		"login1",		"login2",		"testing rlogin service"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when enrolling/deleting service from service group 
	 */
	@DataProvider(name="getHBACServiceGroupEnrollServiceDeleteGroupTestObjects")
	public Object[][] getHBACServiceGroupEnrollServiceDeleteGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupEnrollServiceDeleteGroupTestObjects());
	}
	protected List<List<Object>> createHBACServiceGroupEnrollServiceDeleteGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						service				svcgrp   		description
		ll.add(Arrays.asList(new Object[]{ "enroll_service_delete_servicegroup",	"gdm-password",		"hbac group3", 	"this group will be deleted"		      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when enrolling service in service group 
	 */
	@DataProvider(name="getEnrollHBACServiceInServiceGroupTestObjects")
	public Object[][] getEnrollHBACServiceInServiceGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(enrollServiceInHBACServiceGroupTestObjects());
	}
	protected List<List<Object>> enrollServiceInHBACServiceGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						service		svcgrp   
		ll.add(Arrays.asList(new Object[]{ "enroll_service_in_servicegroup",	"gdm",		"web"		      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when enrolling/deleting service from service group 
	 */
	@DataProvider(name="getHBACServiceGroupDeleteServiceTestObjects")
	public Object[][] getHBACServiceGroupDeleteServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupDeleteServiceTestObjects());
	}
	protected List<List<Object>> createHBACServiceGroupDeleteServiceTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						service		svcgrp   
		ll.add(Arrays.asList(new Object[]{ "delete_service_from_servicegroup",	"gdm",		"web"		      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when enrolling/deleting service from service group 
	 */
	@DataProvider(name="getHBACServiceCancelDeleteServiceTestObjects")
	public Object[][] getHBACServiceCancelDeleteServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceCancelDeleteServiceTestObjects());
	}
	protected List<List<Object>> createHBACServiceCancelDeleteServiceTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname								service		svcgrp   
		ll.add(Arrays.asList(new Object[]{ "cancel_delete_service_from_servicegroup",	"gdm",		"web"		      } ));
		
		return ll;	
	}
	
	@DataProvider(name="getHBACServiceGroupInvalidAddTestObjects")
	public Object[][] getHBACServiceGroupInvalidAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupInvalidAddTestObjects());
	}
	protected List<List<Object>> createHBACServiceGroupInvalidAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname											cn   						description
		ll.add(Arrays.asList(new Object[]{ "servicegroup_with trailing_space_in_desc",				"web",				"Description with trailing space ",		"invalid 'desc': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "servicegroup_with leading_space_in_desc",				"web",				" Description with leading space",		"invalid 'desc': Leading and trailing spaces are not allowed"      } ));
		
		return ll;	
	}
	
	
	
	
}
