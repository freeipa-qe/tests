package com.redhat.qe.ipa.sahi.tests.hbac;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import org.apache.commons.lang.StringEscapeUtils;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.HBACTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

public class HBACTests extends SahiTestScript {
	
	private static Logger log = Logger.getLogger(HBACTests.class.getName());
	public static SahiTasks sahiTasks = null;

	
	/*
	 * PreRequisite - 
	 */
	//User used in this testsuite
	private String uid = "hbacusr";
	private String givenName = "HBAC";
	private String sn = "Test";
	
	//Group used in this testsuite
	private String groupName = "hbacgrp";
	private String groupDescription = "Group to be used for HBAC tests";
	
	//Host  used in this testsuite
	private String domain = System.getProperty("ipa.server.domain");
	private String fqdn = "hbachost." + domain;
	private String ipadr = "";
	
	//Hostgroup used in this testsuite
	private String hostgroupName = "hbachostgroup";
	private String description = "Hostgroup to be used for HBAC tests";
	
	//Host member in Hostgroup -  used in this testsuite
	private String membertype = "host";
	private String[] names = {fqdn};
	
	private String currentPage = "";
	private String alternateCurrentPage1 = "";
	private String alternateCurrentPage2 = "";
	private String alternateCurrentPage3 = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.setStrictVisibilityCheck(true);
		
/*		//verify objects required for this suite do not already exist
		HBACTasks.checkIfObjectsReqdByTestExist(sahiTasks, uid, groupName, fqdn, hostgroupName);
		
		//add new user, user group, host, host group
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.userPage, true);
		UserTasks.createUser(sahiTasks, uid, givenName, sn, "Add");

		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.groupPage, true);
		GroupTasks.createGroupService(sahiTasks, groupName, groupDescription, CommonTasks.groupPage);
		

		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostPage, true);
		HostTasks.addHost(sahiTasks, fqdn, ipadr);
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostgroupPage, true);
		HostgroupTasks.addHostGroup(sahiTasks, hostgroupName, description, "Add");
		HostgroupTasks.addMembers(sahiTasks, hostgroupName, membertype, names, "Enroll");*/
		
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hbacPage, true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage1 = sahiTasks.fetch("top.location.href") + "&hbacrule-facet=search" ;
		alternateCurrentPage2 = sahiTasks.fetch("top.location.href") + "&hbacsvc-facet=search";
		alternateCurrentPage3 = sahiTasks.fetch("top.location.href") + "&hbacsvcgroup-facet=search";
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    System.out.println("CurrentPageNow: " + currentPageNow);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage1)
				&& !currentPageNow.equals(alternateCurrentPage2) && !currentPageNow.equals(alternateCurrentPage3)) {
			CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hbacPage, true);
		}		
	}
	
	/*****************************************************************************************
	 *********************** 			HBAC Rules						********************** 
	 *****************************************************************************************/
	/*
	 * Add HBACRule
	 */
	@Test (groups={"hbacRuleAddTests"}, dataProvider="getHBACRuleTestObjects")	
	public void testHBACRuleAdd(String testName, String cn) throws Exception {
		//verify user, user group, host, host group doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + " doesn't already exist");
		
		HBACTasks.addHBACRule(sahiTasks, cn, "Add");
		
		//verify user, user group, host, host group were added
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Added HBAC Rule " + cn + "  successfully");
	}
	
	/*
	 * Add, and then add another HBACRule
	 */
	@Test (groups={"hbacRuleAddAndAddAnotherTests"}, dataProvider="getHBACRuleAddAndAddAnotherTestObjects")	
	public void testHBACRuleAddAndAddAnother(String testName, String cn1, String cn2) throws Exception {
		//verify user, user group, host, host group doesn't exist
		Assert.assertFalse(sahiTasks.link(cn1).exists(), "Verify HBAC Rule " + cn1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(cn2).exists(), "Verify HBAC Rule " + cn2 + " doesn't already exist");
		
		HBACTasks.addHBACRuleThenAddAnother(sahiTasks, cn1, cn2);
		
		//verify user, user group, host, host group were added
		Assert.assertTrue(sahiTasks.link(cn1).exists(), "Added HBAC Rule " + cn1 + "  successfully");
		Assert.assertTrue(sahiTasks.link(cn2).exists(), "Added HBAC Rule " + cn2 + "  successfully");
	}
	
	/*
	 * Add, and edit HBACRule
	 */	
	//@Test (groups={"hbacRuleAddAndEditTests"}, dataProvider="getSingleHBACRuleTestObjects", dependsOnGroups="hbacRuleCancelAddTests")	
	@Test (groups={"hbacRuleAddAndEditTests"}, dataProvider="getSingleHBACRuleTestObjects")
	public void testHBACRuleAddAndEdit(String testName, String cn) throws Exception {
		
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify rule " + cn + " doesn't already exist");
		
		// Add service category for this rule
		String service = "ftp" ;
		
		//new test rule can be added now
		HBACTasks.addAndEditHBACRule(sahiTasks, cn, uid, hostgroupName, service);				
		
		//verify changes	
		HBACTasks.verifyHBACRuleUpdates(sahiTasks, cn, uid, hostgroupName, service);
	}
	
	/*
	 * Add, but Cancel adding HBACRule
	 */
	@Test (groups={"hbacRuleCancelAddTests"}, dataProvider="getSingleHBACRuleTestObjects")	
	public void testHBACRuleCancelAdd(String testName, String cn) throws Exception {
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + " doesn't already exist");
		
		//new test rule can be added now
		HBACTasks.addHBACRule(sahiTasks, cn, "Cancel");
		
		//verify rule was added successfully
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + "  was not added");
	}
	
	/*
	 * Delete an HBACRule
	 */
	@Test (groups={"hbacRuleDeleteTests"}, dataProvider="getHBACRuleDeleteTestObjects", dependsOnGroups={"hbacRuleAddAndEditTests", "hbacRuleAddAndAddAnotherTests", "hbacRuleSearchTests" })	
	public void testHBACRuleDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + "  to be deleted exists");
		
		//modify this user
		HBACTasks.deleteHBACRule(sahiTasks, cn, "Delete");
		
		//verify user is deleted
		Assert.assertFalse(sahiTasks.link(cn).exists(), "HBAC Rule " + cn + "  deleted successfully");
	}
	
	/*
	 * Delete multiple HBACRule
	 */
	@Test (groups={"hbacRuleMultipleDeleteTests"}, dataProvider="getMultipleHBACRuleTestObjects", dependsOnGroups={"hbacRuleAddTests", "hbacRuleSearchTests" })
	public void testMultipleHBACRuleDelete(String testName, String cn1, String cn2, String cn3, String cn4) throws Exception {	
		String cns[] = {cn1, cn2, cn3, cn4};
		
		
		//verify rule to be deleted exists
		for (String cn : cns) {
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + "  to be deleted exists");
		}			
		//mark this rule for deletion
		HBACTasks.chooseMultipleRules(sahiTasks, cns);		
		HBACTasks.deleteMultipleRules(sahiTasks);
	}
		
		
	/*
	 * Delete, but Cancel deleting an HBACRule
	 */
	@Test (groups={"hbacRuleCancelDeleteTests"}, dataProvider="getSingleHBACRuleTestObjects", dependsOnGroups={"hbacRuleAddAndEditTests" })	
	public void testHBACRuleCancelDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + "  to be deleted exists");
		
		//modify this user
		HBACTasks.deleteHBACRule(sahiTasks, cn, "Cancel");
		
		//verify user is deleted
		Assert.assertTrue(sahiTasks.link(cn).exists(), "HBAC Rule " + cn + "  was not deleted");
	}
	
	/*
	 * Edit an HBACRule
	 */
	
	
	/*
	 * Edit, but Reset an HBACRule
	 */
	
	
	/*
	 * Edit the General Section for the HBACRule
	 */
	@Test (groups={"hbacRuleGeneralSettingsTests"}, dataProvider="getHBACRuleGeneralSettingsTestObjects", dependsOnGroups={"hbacRuleAddAndEditTests"})	
	public void testHBACRuleGeneralSettings(String testName, String cn, String description) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		//modify this rule
		HBACTasks.modifyHBACRuleGeneralSection(sahiTasks, cn, description);
		
		//verify changes	
		HBACTasks.verifyHBACRuleGeneralSection(sahiTasks, cn, description);
	}
	
	
	/*
	 * Edit the Who Section for the HBACRule
	 */
	@Test (groups={"hbacRuleWhoSettingsTests"}, dataProvider="getSingleHBACRuleTestObjects", dependsOnGroups={"hbacRuleAddAndEditTests"})	
	public void testHBACRuleWhoSettings(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		//modify this rule
		HBACTasks.modifyHBACRuleWhoSection(sahiTasks, cn, uid, groupName);
		
		//verify changes	
		HBACTasks.verifyHBACRuleWhoSection(sahiTasks, cn, uid, groupName);
	}
	
	/*
	 * Edit...undo changes for an HBACRule
	 */
	
	/*
	 * Edit the Accessing Section for the HBACRule
	 */
	
	/*
	 * Edit the From Section for the HBACRule
	 */
	
	/*
	 * Edit the Via Service Section for the HBACRule
	 */
	
	/*
	 * Expand/Collapse details of an HBACRule
	 */
	
	/*
	 * Search an HBACRule
	 */
	@Test (groups={"hbacRuleSearchTests"}, dataProvider="getHBACRuleSearchTestObjects",  dependsOnGroups={"hbacRuleAddTests", "hbacRuleAddAndEditTests", "hbacRuleAddAndAddAnotherTests"})
	public void testHBACRuleSearch(String testName, String cn, String multipleResult) throws Exception {		
		CommonTasks.search(sahiTasks, cn);
		
		//verify rules were found
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Searched and found Rule " + cn + "  successfully");
		if (!multipleResult.equals(""))
			Assert.assertTrue(sahiTasks.link(multipleResult).exists(), "Searched and found another Rule " + multipleResult + "  successfully");
		
		CommonTasks.clearSearch(sahiTasks);
	}
	
	
	/*****************************************************************************************
	 *********************** 			HBAC Services					********************** 
	 *****************************************************************************************/
	
	/*
	 * Add a HBACService
	 */
	
	/*
	 * Add, and then add another HBACService
	 */
	
	/*
	 * Add, and edit HBACService
	 */
	
	/*
	 * Add, but Cancel adding HBACService
	 */
	
	/*
	 * Delete an HBACService
	 */
	
	/*
	 * Delete multiple HBACService
	 */
	
	/*
	 * Delete, but Cancel deleting an HBACService
	 */
	
	/*
	 * Edit an HBACService
	 */
	
	/*
	 * Expand/Collapse details of an HBACService
	 */
	
	/*
	 * Search an HBACService
	 */
	
	
	/*****************************************************************************************
	 *********************** 			HBAC Service Groups				********************** 
	 *****************************************************************************************/
	/*
	 * Add a HBACServiceGroup
	 */
	
	/*
	 * Add, and then add another HBACServiceGroup
	 */
	
	/*
	 * Add, and edit HBACServiceGroup
	 */
	
	/*
	 * Add, but Cancel adding HBACServiceGroup
	 */
	
	/*
	 * Delete an HBACServiceGroup
	 */
	
	/*
	 * Delete multiple HBACServiceGroup
	 */
	
	/*
	 * Delete, but Cancel deleting an HBACServiceGroup
	 */
	
	/*
	 * Edit an HBACServiceGroup
	 */
	
	/*
	 * Expand/Collapse details of an HBACServiceGroup
	 */
	
	/*
	 * Search an HBACServiceGroup
	 */
	
		
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true, dependsOnGroups="init")
	public void cleanup() throws CloneNotSupportedException {
		//delete user, user group, host, host group added for this suite
	/*	sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.userPage, true);
		UserTasks.deleteUser(sahiTasks, uid);

		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.groupPage, true);
		GroupTasks.deleteGroup(sahiTasks, groupName);
		

		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostPage, true);
		HostTasks.deleteHost(sahiTasks, fqdn);
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostgroupPage, true);
		HostgroupTasks.deleteHostgroup(sahiTasks, hostgroupName, "Delete");
		
		// verify objects added for this suite are successfully cleaned
		HBACTasks.checkIfObjectsReqdByTestExist(sahiTasks, uid, groupName, fqdn, hostgroupName);
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hbacPage, true);*/
	}
	
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleTestObjects")
	public Object[][] getHBACRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleTestObjects());
	}
	protected List<List<Object>> createHBACRuleTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "good_hbacrule",					"dev_hbacRule"      } ));
		ll.add(Arrays.asList(new Object[]{ "hbacrule_1",					"hbacRule1"      } ));
		ll.add(Arrays.asList(new Object[]{ "hbacrule_long",					"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789"      } ));
		ll.add(Arrays.asList(new Object[]{ "hbacrule_specialchar",			"h@ba*c#Ru?le"      } ));
		
		return ll;	
	}
	
	@DataProvider(name="getMultipleHBACRuleTestObjects")
	public Object[][] getMultipleHBACRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteMultipleHBACRuleTestObjects());
	}
	protected List<List<Object>> deleteMultipleHBACRuleTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn1					cn2					cn3																																	cn4   
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_hbacrule",		"dev_hbacRule",		"hbacRule1",		"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",		"h@ba*c#Ru?le"      } ));
		
		return ll;	
	}
	

	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getSingleHBACRuleTestObjects")
	public Object[][] getSingleHBACRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSingleHBACRuleTestObject());
	}
	protected List<List<Object>> createSingleHBACRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "create_good_hbacrule",			"eng_hbacRule"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleGeneralSettingsTestObjects")
	public Object[][] getHBACRuleGeneralSettingsTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editHBACRuleGeneralSettingsTestObject());
	}
	protected List<List<Object>> editHBACRuleGeneralSettingsTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   				description
		ll.add(Arrays.asList(new Object[]{ "create_good_hbacrule",			"eng_hbacRule",		"This rule is for eng"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when deleting rules 
	 */
	@DataProvider(name="getHBACRuleDeleteTestObjects")
	public Object[][] getHBACRuleDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteHBACRuleTestObject());
	}
	protected List<List<Object>> deleteHBACRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "create_good_hbacrule",			"eng_hbacRule"      } ));
		ll.add(Arrays.asList(new Object[]{ "create_good_hbacrule",			"doc_hbacRule"      } ));
		ll.add(Arrays.asList(new Object[]{ "create_good_hbacrule",			"doc_hbacRule1"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleAddAndAddAnotherTestObjects")
	public Object[][] getHBACRuleAddAndAddAnotherTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleAndAddAnotherTestObject());
	}
	protected List<List<Object>> createHBACRuleAndAddAnotherTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						cn1						cn2   
		ll.add(Arrays.asList(new Object[]{ "create_two_good_hbacrule",			"doc_hbacRule",		"doc_hbacRule1"  } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when searching for rules 
	 */
	@DataProvider(name="getHBACRuleSearchTestObjects")
	public Object[][] getHBACRuleSearchTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(searchHBACRuleTestObject());
	}
	protected List<List<Object>> searchHBACRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn       				multiple_result1  
		ll.add(Arrays.asList(new Object[]{ "search_good_hbacrule",			"eng_hbacRule",			""  } ));		
		ll.add(Arrays.asList(new Object[]{ "search_good_hbacrule",			"h@ba*c#Ru?le",			""  } ));
		ll.add(Arrays.asList(new Object[]{ "search_good_hbacrule",			"doc_hbacRule",			"doc_hbacRule1"  } ));
		
		return ll;	
	}
}
