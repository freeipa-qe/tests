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
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.HBACTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;


/* 
 * Review comments
 * 40. In HBACTasks adding/deleting entries (e.g. users, hosts) into/from a
rule is saved immediately, so no need to click Update because the button
will be disabled anyway. //done 

41. In HBACTests.hbacRuleMemberListTests it tests hosts. It should test
users too. It should also test if the host/user is already added
directly it should not appear again in the available list. //done 

42. Ideally all tests that change the data should be validated via CLI
too, but this is probably low priority. // TODO: nkrishnan - add a test

43. In HBACTests we could verify that when a category is set to 'all'
the entries in that category are deleted. //done 

  I think there is additional negative testing we can do //added some..but there could be more
  
  One thing that I think we should log a bug on that should not affect our automation at all is the main page for HBAC rules ... 
  There is only "all" category for object type that can be associated with a rule and it is not editable.  I do not think they 
  should be displayed on the main page at all.  I think just the rule name (link), description and whether the rule is enabled or disabled.
  // logged bug 738038
   * 
   * 
   *  more comments:
   * 48. In HBACTests we could verify that the 'Accessing' list is
independent from the 'From' list. We should be able to add/delete a
host/hostgroup to/from either/both lists.// TODO: nkrishnan - add a test

49. We could also verify that the host's HBAC Rules tab corresponds to
the HBAC rule's 'Accessing' list but not the 'From' list.// TODO: nkrishnan - add a test


 */

public class HBACTests extends SahiTestScript {
	
	private static Logger log = Logger.getLogger(HBACTests.class.getName());
		
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
	private String hostname = "hbachost";
	private String fqdn = hostname + "." + domain;
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
		sahiTasks.setStrictVisibilityCheck(true);
		
		//add new user, user group, host, host group
		System.out.println("Check CurrentPage: " + commonTasks.userPage);
		sahiTasks.navigateTo(commonTasks.userPage, true);
		if (!sahiTasks.link(uid).exists())
			UserTasks.createUser(sahiTasks, uid, givenName, sn, "Add");

		System.out.println("Check CurrentPage: " + commonTasks.groupPage);
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		if (!sahiTasks.link(groupName).exists())
			GroupTasks.createGroupService(sahiTasks, groupName, groupDescription, commonTasks.groupPage);
		
		System.out.println("Check CurrentPage: " + commonTasks.hostPage);
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		if (!sahiTasks.link(fqdn.toLowerCase()).exists())
			HostTasks.addHost(sahiTasks, hostname, commonTasks.getIpadomain(), ipadr);
		
		System.out.println("Check CurrentPage: " + commonTasks.hostgroupPage);
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		if (!sahiTasks.link(hostgroupName).exists()) {
			HostgroupTasks.addHostGroup(sahiTasks, hostgroupName, description, "Add");
		}
		
		System.out.println("Check CurrentPage: " + commonTasks.hbacPage);
		sahiTasks.navigateTo(commonTasks.hbacPage, true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage1 = sahiTasks.fetch("top.location.href") + "&hbacrule-facet=search" ;
		alternateCurrentPage2 = sahiTasks.fetch("top.location.href") + "&hbacsvc-facet=search";
		alternateCurrentPage3 = sahiTasks.fetch("top.location.href") + "&hbacsvcgroup-facet=search";
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    System.out.println("CurrentPageNow: " + currentPageNow);
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage1)
				&& !currentPageNow.equals(alternateCurrentPage2) && !currentPageNow.equals(alternateCurrentPage3)) {
			//CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.hbacPage, true);
		}		
	}
	
	/*****************************************************************************************
	 *********************** 			HBAC Rules						********************** 
	 *****************************************************************************************/
	/*
	 * Add HBACRule
	 */
	@Test (groups={"hbacRuleAddTests"}, description="Add HBAC Rules",
			dataProvider="getHBACRuleTestObjects")	
	public void testHBACRuleAdd(String testName, String cn) throws Exception {
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + " doesn't already exist");
		
		HBACTasks.addHBACRule(sahiTasks, cn, "Add");
		
		//verify rule were added
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Added HBAC Rule " + cn + "  successfully");
	}
	
	/*
	 * Add, and then add another HBACRule
	 */
	@Test (groups={"hbacRuleAddAndAddAnotherTests"}, description="Add and Add Another HBAC Rule",
			dataProvider="getHBACRuleAddAndAddAnotherTestObjects")	
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
	 * Add, but Cancel adding HBACRule
	 */
	@Test (groups={"hbacRuleCancelAddTests"}, description="Cancel Add an HBAC Rule",
			dataProvider="getCancelAddHBACRuleTestObjects")	
	public void testHBACRuleCancelAdd(String testName, String cn) throws Exception {
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + " doesn't already exist");
		
		//new test rule can be added now
		HBACTasks.addHBACRule(sahiTasks, cn, "Cancel");
		
		//verify rule was added successfully
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + "  was not added");
	}
	
	/*
	 * Add, and edit HBACRule
	 */	
	@Test (groups={"hbacRuleAddAndEditTests"}, description="Add and Edit an HBAC rule; commented test for Bug 735185", 
			dataProvider="getAddAndEditHBACRuleTestObjects", dependsOnGroups="hbacRuleCancelAddTests")	
	public void testHBACRuleAddAndEdit(String testName, String cn) throws Exception {
		
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify rule " + cn + " doesn't already exist");
		
		// Add service category for this rule
		String service = "ftp" ;
		
		//new test rule can be added now
		HBACTasks.addAndEditHBACRule(sahiTasks, cn, uid, hostgroupName, service, fqdn);				
		
		//verify changes	
		HBACTasks.verifyHBACRuleUpdates(sahiTasks, cn, uid, hostgroupName, service, fqdn);
	}
	
	/*
	 * Add Rules - for negative tests
	 */
	@Test (groups={"invalidhbacRuleAddTests"}, description="Add HBAC Rules - invalid",
			dataProvider="getInvalidHBACRuleTestObjects", dependsOnGroups="hbacRuleAddTests")	
	public void testInvalidHBACRuleadd(String testName, String cn, String expectedError) throws Exception {
		//new test user can be added now
		HBACTasks.createInvalidRule(sahiTasks, cn, expectedError);		
	}
	
	/*
	 * Add Rules - check required fields - for negative tests
	 */
	@Test (groups={"hbacRuleRequiredFieldAddTests"}, description="Add HBAC Rules - missing required field",
			dataProvider="getHBACRuleRequiredFieldTestObjects")	
	public void testHBACRuleRequiredFieldAdd(String testName, String cn, String expectedError) throws Exception {
		//new test user can be added now
		HBACTasks.createRuleWithRequiredField(sahiTasks, cn, expectedError);		
	}
	
	/*
	 * Delete an HBACRule
	 */
	@Test (groups={"hbacRuleDeleteTests"}, description="Delete an HBAC Rule",
			dataProvider="getHBACRuleDeleteTestObjects", 
			dependsOnGroups={"hbacRuleAddAndEditTests",	"hbacRuleAddAndAddAnotherTests", "hbacRuleSearchTests", 
			"hbacRuleViaServiceSettingsTests", "hbacRuleWhoSettingsTests", 	 "hbacRuleFromSettingsTests" })	
	public void testHBACRuleDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + "  to be deleted exists");
		
		//modify this user
		HBACTasks.deleteHBAC(sahiTasks, cn, "Delete");
		
		//verify user is deleted
		Assert.assertFalse(sahiTasks.link(cn).exists(), "HBAC Rule " + cn + "  deleted successfully");
	}
	
	/*
	 * Delete multiple HBACRule
	 */
	@Test (groups={"hbacRuleMultipleDeleteTests"}, description="Delete multiple HBAC Rules",
			dataProvider="getMultipleHBACRuleTestObjects", 
			dependsOnGroups={"hbacRuleAddTests", "hbacRuleSearchTests", "invalidhbacRuleAddTests", "hbacRuleMemberListTests", "hbacRuleEnableDisableTests" })
	public void testMultipleHBACRuleDelete(String testName, String cn1, String cn2, String cn3) throws Exception {	
		String cns[] = {cn1, cn2, cn3};
		
		
		//verify rule to be deleted exists
		for (String cn : cns) {
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + "  to be deleted exists");
		}			
		//mark this rule for deletion
		HBACTasks.chooseMultiple(sahiTasks, cns);		
		HBACTasks.deleteMultiple(sahiTasks);
	}
		
		
	/*
	 * Delete, but Cancel deleting an HBACRule
	 */
	@Test (groups={"hbacRuleCancelDeleteTests"}, description="Cancel Delete an HBAC Rule",
			dataProvider="getCancelDeleteHBACRuleTestObjects", dependsOnGroups={"hbacRuleAddAndEditTests" })	
	public void testHBACRuleCancelDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + "  to be deleted exists");
		
		//cancel deleting this rule
		HBACTasks.deleteHBAC(sahiTasks, cn, "Cancel");
		
		//verify user is deleted
		Assert.assertTrue(sahiTasks.link(cn).exists(), "HBAC Rule " + cn + "  was not deleted");
	}
	
	/*
	 * Edit, but Reset/Undo an HBACRule
	 */
	@Test (groups={"hbacRuleResetUndoSettingsTests"}, description="Edit, but Reset/Undo an HBACRule",
			dataProvider="getResetUndoHBACRuleTestObjects", dependsOnGroups={"hbacRuleAddAndEditTests"})	
	public void testHBACRuleResetSettings(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		//modify this rule, then reset/undo
		HBACTasks.resetUndoHBACRuleSections(sahiTasks, cn);
		
	}
	
	/*
	 * Edit the General Section for the HBACRule
	 */
	@Test (groups={"hbacRuleInvalidGeneralSettingsTests"}, description="Edit the General Section for the HBACRule - invalid",
			dataProvider="getHBACRuleInvalidGeneralSettingsTestObjects", dependsOnGroups={"hbacRuleAddAndEditTests"})	
	public void testHBACRuleInvalidGeneralSettings(String testName, String cn, String description) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		String expectedError = "invalid 'desc': Leading and trailing spaces are not allowed";
		
		//modify this rule
		HBACTasks.modifyHBACRuleInvalidGeneralSection(sahiTasks, cn, description, expectedError);
		
	}
	
	/*
	 * Edit the General Section for the HBACRule
	 */
	@Test (groups={"hbacRuleGeneralSettingsTests"}, description="Edit the General Section for the HBACRule",
			dataProvider="getHBACRuleGeneralSettingsTestObjects")	
	public void testHBACRuleGeneralSettings(String testName, String cn, String description) throws Exception {		
		HBACTasks.addHBACRule(sahiTasks, cn, "Add");
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
	@Test (groups={"hbacRuleWhoSettingsTests"}, description="Edit the Who Section for the HBACRule",
			dataProvider="getHBACRuleWhoSettingsTestObjects", dependsOnGroups={"hbacRuleAddAndEditTests", "hbacRuleMemberListTests"})	
	public void testHBACRuleWhoSettings(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		//modify this rule
		HBACTasks.modifyHBACRuleWhoSection(sahiTasks, cn, uid, groupName);
		
		//verify changes	
		HBACTasks.verifyHBACRuleWhoSection(sahiTasks, cn, uid, groupName);
	}
	
	
	/*
	 * Edit the Accessing Section for the HBACRule
	 */
	@Test (groups={"hbacRuleAccessingSettingsTests"}, description="Edit the Accessing Section for the HBACRule",
			dataProvider="getHBACRuleAccessingSectionTestObjects", 
			dependsOnGroups={"hbacRuleAddAndEditTests", "hbacRuleMemberListTests"})	
	public void testHBACRuleAccessingSettings(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		//modify this rule
		HBACTasks.modifyHBACRuleAccessingSection(sahiTasks, cn, fqdn, hostgroupName);
		
		//verify changes	
		HBACTasks.verifyHBACRuleAccessingSection(sahiTasks, cn, fqdn, hostgroupName);
	}
	

	/*
	 * Edit the From Section for the HBACRule
	 */
	@Test (groups={"hbacRuleFromSettingsTests"}, description="Edit the From Section for the HBACRule",
			dataProvider="getHBACRuleFromSectionTestObjects", 
			dependsOnGroups={"hbacRuleAddAndEditTests", "hbacRuleMemberListTests"})	
	public void testHBACRuleFromSettings(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		//modify this rule
		HBACTasks.modifyHBACRuleFromSection(sahiTasks, cn, fqdn, hostgroupName);
		
		//verify changes	
		HBACTasks.verifyHBACRuleFromSection(sahiTasks, cn, fqdn, hostgroupName);
	}
	
	/*
	 * Edit the Via Service Section for the HBACRule
	 */
	@Test (groups={"hbacRuleViaServiceSettingsTests"}, description="Edit the Via Service Section for the HBACRule",
			dataProvider="getHBACRuleViaServiceSectionTestObjects", 
			dependsOnGroups={"hbacRuleAddAndEditTests"})	
	public void testHBACRuleViaServiceSettings(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		//modify this rule
		String searchString = "dm";
		String searchResult[] = {"gdm", "gdm-password", "kdm" };
		HBACTasks.modifyHBACRuleViaServiceSection(sahiTasks, cn, searchString, searchResult );
		
		//verify changes	
		HBACTasks.verifyHBACRuleViaServiceSection(sahiTasks, cn, searchResult);
	}
	
	
	/*
	 * Verify member list for the HBACRule
	 * fqdn is added as member of hostgroupName
	 * hostgroupName is added to From list for Rule
	 * When choosing to add Hosts to From list for Rule, verify that fqdn 
	 * is not listed since it already is in the list for this Rule, because
	 * the it is memberof hostgroupName
	 */
	@Test (groups={"hbacRuleMemberListTests"}, description="Verify host member list for the HBACRule", 
			dataProvider="getHBACRuleHostMemberListTestObjects", dependsOnGroups={"hbacRuleAddTests"})	
	public void testHBACRuleMemberList(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		HostgroupTasks.addMembers(sahiTasks, hostgroupName, membertype, names, "Add");
		sahiTasks.navigateTo(commonTasks.hbacPage, true);
		//modify this rule
		HBACTasks.modifyHBACRuleAccessingSectionMemberList(sahiTasks, cn, fqdn, hostgroupName);
		
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		HostgroupTasks.removeMembers(sahiTasks, hostgroupName, membertype, names, "Delete");
		sahiTasks.navigateTo(commonTasks.hbacPage, true);
		
	}
	
	
	
	/*
	 * Verify member list for the HBACRule
	 * uid is added as member of groupName
	 * groupName is added to Who list for Rule
	 * When choosing to add Users to Who list for Rule, verify that uid 
	 * is not listed since it already is in the list for this Rule, because
	 * the it is memberof groupName
	 */
	@Test (groups={"hbacRuleUserMemberListTests"}, description="Verify user member list for the HBACRule",
			dataProvider="getHBACRuleUserMemberListTestObjects", dependsOnGroups={"hbacRuleAddTests"})	
	public void testHBACRuleUserMemberList(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		GroupTasks.addMembers(sahiTasks, groupName, membertype, uid, "Add");
		sahiTasks.navigateTo(commonTasks.hbacPage, true);
		//modify this rule
		HBACTasks.modifyHBACRuleWhoSectionMemberList(sahiTasks, cn, uid, groupName);
		
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		GroupTasks.removeMembers(sahiTasks, groupName, "user", uid, "Delete");
		sahiTasks.navigateTo(commonTasks.hbacPage, true);
		
	}
	
	/*
	 * In HBACTests we could verify that when a category is set to 'all' the entries in that category are deleted.
	 * Add a source host (Done in hbacRuleFromSettingsTests)
	 * Set the sourcehostcategory to 'all'
	 * Update this
	 * Verify error
	 * Delete source host 
	 * Set the sourcehostcategory to 'all'
	 * Update this
	 * Should be successful
	 */
	@Test (groups={"hbacRuleUpdateCategoryTests"}, description="Update category -> delete entries",
			dataProvider="getHBACRuleUpdateCategoryTestObjects", 
			dependsOnGroups={"hbacRuleAddAndEditTests", "hbacRuleFromSettingsTests"})	
	public void testHBACRuleUpdateCategory(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		HBACTasks.updateCategory(sahiTasks, cn, hostgroupName, true);		
	}
	
	
	
	/*
	 * Expand/Collapse details of an HBACRule
	 */
	@Test (groups={"hbacRuleExpandCollapseTests"}, description="Expand/Collapse details of an HBACRule",
			dataProvider="getHBACRuleExpandCollapseTestObjects",  dependsOnGroups="hbacRuleAddAndEditTests")
	public void testHBACRuleExpandCollapse(String testName, String cn) throws Exception {
		
		HBACTasks.expandCollapseRule(sahiTasks, cn);		
		
	}
	
	/*
	 * Search an HBACRule
	 */
	@Test (groups={"hbacRuleSearchTests"}, description="Search an HBACRule",
			dataProvider="getHBACRuleSearchTestObjects",  
			dependsOnGroups={"hbacRuleAddTests", "hbacRuleAddAndEditTests", "hbacRuleAddAndAddAnotherTests"})
	public void testHBACRuleSearch(String testName, String cn, String multipleResult) throws Exception {		
		CommonTasks.search(sahiTasks, cn);
		
		//verify rules were found
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Searched and found Rule " + cn + "  successfully");
		if (!multipleResult.equals(""))
			Assert.assertTrue(sahiTasks.link(multipleResult).exists(), "Searched and found another Rule " + multipleResult + "  successfully");
		
		CommonTasks.clearSearch(sahiTasks);
	}
	
	
	/*
	 * HBACRule Enable and disable
	 */
	@Test (groups={"hbacRuleEnableDisableTests"}, description="Enable and Disable an HBACRule in HBAC RULES Page",
			dataProvider="getHBACRuleEnableDisableTestObjects",  
			dependsOnGroups={ "hbacRuleAddAndEditTests"})
	public void testRuleEnableDisable(String testName, String cn1,String status,String Buttontoclick) throws Exception {
		
	     HBACTasks.enableDIsableHBACTests(sahiTasks,cn1,status,Buttontoclick);
		
		
		
	}
	
	
	
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true, dependsOnGroups="init")
	public void cleanup() throws CloneNotSupportedException {
		//delete user, user group, host, host group added for this suite
		sahiTasks.navigateTo(commonTasks.userPage, true);
		//Since memberships were checked previously, may not be in the front page for User
		if (sahiTasks.link("Users").in(sahiTasks.div("content")).exists())
			sahiTasks.link("Users").in(sahiTasks.div("content")).click();
		if (sahiTasks.link(uid).exists())
			UserTasks.deleteUser(sahiTasks, uid);

		sahiTasks.navigateTo(commonTasks.groupPage, true);
		//Since memberships were checked previously, may not be in the front page for User Group
		if (sahiTasks.link("User Groups").in(sahiTasks.div("content")).exists())
			sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
		if (sahiTasks.link(groupName).exists())
			GroupTasks.deleteGroup(sahiTasks, groupName);
		
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		//Since memberships were checked previously, may not be in the front page for Hosts
		if (sahiTasks.link("Hosts").in(sahiTasks.div("content")).exists())
			sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
		if (sahiTasks.link(fqdn.toLowerCase()).exists())
			HostTasks.deleteHost(sahiTasks, fqdn);
		
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		//Since memberships were checked previously, may not be in the front page for Host Groups
		if (sahiTasks.link("Host Groups").in(sahiTasks.div("content")).exists())
			sahiTasks.link("Host Groups").in(sahiTasks.div("content")).click();
		if (sahiTasks.link(hostgroupName).exists())
			HostgroupTasks.deleteHostgroup(sahiTasks, hostgroupName, "Delete");
		
		
		sahiTasks.navigateTo(commonTasks.hbacPage, true);
		String[] hbacRuleTestObjects = {"doc_hbacRule", 
										"doc_hbacRule1"
										} ; 

		//delete any leftover rules created for this test suite
		for (String hbacRuleTestObject : hbacRuleTestObjects) {
			if (sahiTasks.link(hbacRuleTestObject).exists()){
				log.fine("Cleaning HBAC Service Group: " + hbacRuleTestObject);
				HBACTasks.deleteHBAC(sahiTasks, hbacRuleTestObject, "Delete");
			}			
		} 

		
	
	
	
	
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
		ll.add(Arrays.asList(new Object[]{ "add_good_rule",					"dev_hbacRule"      } ));
		ll.add(Arrays.asList(new Object[]{ "add_long_rule",					"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789"      } ));
		ll.add(Arrays.asList(new Object[]{ "add_specialchar_rule",			"h@ba*c#Ru?le"      } ));
		
		return ll;	
	}
	
	@DataProvider(name="getMultipleHBACRuleTestObjects")
	public Object[][] getMultipleHBACRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteMultipleHBACRuleTestObjects());
	}
	protected List<List<Object>> deleteMultipleHBACRuleTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn1					cn2																																	cn3   
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_rule",		"dev_hbacRule",		"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",		"h@ba*c#Ru?le"      } ));
		
		return ll;	
	}
	

	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getCancelAddHBACRuleTestObjects")
	public Object[][] getCancelAddHBACRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createCancelAddHBACRuleTestObject());
	}
	protected List<List<Object>> createCancelAddHBACRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn   
		ll.add(Arrays.asList(new Object[]{ "cancel_add_rule",			"eng_hbacRule"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getAddAndEditHBACRuleTestObjects")
	public Object[][] getAddAndEditHBACRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddAndEditHBACRuleTestObject());
	}
	protected List<List<Object>> createAddAndEditHBACRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn   
		ll.add(Arrays.asList(new Object[]{ "add_and_edit_rule",			"eng_hbacRule"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getCancelDeleteHBACRuleTestObjects")
	public Object[][] getCancelDeleteHBACRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createCancelDeleteHBACRuleTestObject());
	}
	protected List<List<Object>> createCancelDeleteHBACRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "cancel_delete_rule",			"eng_hbacRule"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getResetUndoHBACRuleTestObjects")
	public Object[][] getResetUndoHBACRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createResetUndoHBACRuleTestObject());
	}
	protected List<List<Object>> createResetUndoHBACRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn   
		ll.add(Arrays.asList(new Object[]{ "reset_undo_rule",			"eng_hbacRule"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleWhoSettingsTestObjects")
	public Object[][] getHBACRuleWhoSettingsTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleWhoSettingsTestObject());
	}
	protected List<List<Object>> createHBACRuleWhoSettingsTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			cn   
		ll.add(Arrays.asList(new Object[]{ "edit_who_rule",			"eng_hbacRule"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleAccessingSectionTestObjects")
	public Object[][] getHBACRuleAccessingSectionTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleAccessingSectionTestObject());
	}
	protected List<List<Object>> createHBACRuleAccessingSectionTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "edit_accessing_rule",			"eng_hbacRule"      } ));
		
		return ll;	
	}
	
	
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleFromSectionTestObjects")
	public Object[][] getHBACRuleFromSectionTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleFromSectionTestObject());
	}
	protected List<List<Object>> createHBACRuleFromSectionTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "edit_from_rule",			"eng_hbacRule"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleViaServiceSectionTestObjects")
	public Object[][] getHBACRuleViaServiceSectionTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleViaServiceSectionTestObject());
	}
	protected List<List<Object>> createHBACRuleViaServiceSectionTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "create_good_rule",			"eng_hbacRule"      } ));
		
		return ll;	
	}
	
	
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleUpdateCategoryTestObjects")
	public Object[][] getHBACRuleUpdateCategoryTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleUpdateCategoryTestObject());
	}
	protected List<List<Object>> createHBACRuleUpdateCategoryTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "update_category_rule",			"eng_hbacRule"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleExpandCollapseTestObjects")
	public Object[][] getHBACRuleExpandCollapseTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleExpandCollapseTestObject());
	}
	protected List<List<Object>> createHBACRuleExpandCollapseTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "expand_collapse_rule",			"eng_hbacRule"      } ));
		
		return ll;	
	}
	

	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleHostMemberListTestObjects")
	public Object[][] getHBACRuleHostMemberListTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleHostMemberListTestObject());
	}
	protected List<List<Object>> createHBACRuleHostMemberListTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "hostmembership_rule",			"dev_hbacRule"      } ));
		
		return ll;	
	}

	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleUserMemberListTestObjects")
	public Object[][] getHBACRuleUserMemberListTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleUserMemberListTestObject());
	}
	protected List<List<Object>> createHBACRuleUserMemberListTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "usermembership_rule",			"dev_hbacRule"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getInvalidHBACRuleTestObjects")
	public Object[][] getInvalidHBACRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidHBACRuleTestObject());
	}
	protected List<List<Object>> createInvalidHBACRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname							cn					expected_Error   
		ll.add(Arrays.asList(new Object[]{ "create_duplicate_rule",					"dev_hbacRule",		"HBAC rule with name \"dev_hbacRule\" already exists"      } ));
		ll.add(Arrays.asList(new Object[]{ "rule_with trailing_space_in_name",		"hbacRule ",		"invalid 'name': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "rule_with leading_space_in_name",		" hbacRule",		"invalid 'name': Leading and trailing spaces are not allowed"	} ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding rules with required fields 
	 */
	@DataProvider(name="getHBACRuleRequiredFieldTestObjects")
	public Object[][] getHBACRuleRequiredFieldTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleRequiredFieldTestObject());
	}
	protected List<List<Object>> createHBACRuleRequiredFieldTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn					expected_Error   
		ll.add(Arrays.asList(new Object[]{ "create_blank_rule",			"",					"Required field"      } ));
		
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
		
        //										testname				cn   				description
		ll.add(Arrays.asList(new Object[]{ "edit_general_rule",			"eng_hbacRule1",		"This rule is for eng"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getHBACRuleInvalidGeneralSettingsTestObjects")
	public Object[][] getHBACRuleInvalidGeneralSettingsTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editHBACRuleInvalidGeneralSettingsTestObject());
	}
	protected List<List<Object>> editHBACRuleInvalidGeneralSettingsTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname									cn   				description
		ll.add(Arrays.asList(new Object[]{ "edit_general_rule_trailingspace_in_desc",		"eng_hbacRule",		"This rule is for eng "      } ));
		ll.add(Arrays.asList(new Object[]{ "edit_general_rule_leadingspace_in_desc",		"eng_hbacRule",		" This rule is for eng"      } ));
		
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
		ll.add(Arrays.asList(new Object[]{ "delete_rule",			"eng_hbacRule"      } ));
		
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
		
        //										testname						cn1					cn2   
		ll.add(Arrays.asList(new Object[]{ "add_and_add_another_rule",			"doc_hbacRule",		"doc_hbacRule1"  } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when searching for rules 
	 */
	@DataProvider(name="getHBACRuleSearchTestObjects")
	public Object[][] getHBACRuleSearchTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSearchHBACRuleTestObject());
	}
	protected List<List<Object>> createSearchHBACRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn       				multiple_result1  
		ll.add(Arrays.asList(new Object[]{ "search_good_rule",			"eng_hbacRule",			""  } ));		
		ll.add(Arrays.asList(new Object[]{ "search_specialchar_rule",	"h@ba*c#Ru?le",			""  } ));
		ll.add(Arrays.asList(new Object[]{ "search_multiple_rule",			"doc_hbacRule",			"doc_hbacRule1"  } ));
		
		return ll;	
	}
	/*
	 * Data to be used when enable or disable rules
	 */
	@DataProvider(name="getHBACRuleEnableDisableTestObjects")
	public Object[][] getHBACRuleEnableDisableTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleEnableDisableTestObjects());
	}
	protected List<List<Object>> createHBACRuleEnableDisableTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn       		Status			button to click	  
		ll.add(Arrays.asList(new Object[]{ "rule_disable_test",			"eng_hbacRule",		"Disabled",	     "Disable"  } ));	
		ll.add(Arrays.asList(new Object[]{ "rule_enable_test",			"eng_hbacRule",		"Enabled"	    ,"Enable"  } ));
		return ll;	
		}
		
	
}
