package com.redhat.qe.ipa.sahi.tests.sudo;

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
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;
import com.redhat.qe.ipa.sahi.tests.sudo.SudoTests;

public class SudoTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(SudoTests.class.getName());
	
	/*
	 * PreRequisite - 
	 */
	//User used in this testsuite
	private String uid = "sudousr";
	private String givenName = "Sudo";
	private String sn = "Test1";
	private String runAsUID = "runassudousr";
	private String runAsGivenName = "Sudo";
	private String runAsSN = "Test2";
	
	
	//Group used in this testsuite
	private String groupName = "sudogrp";
	private String groupDescription = "Group1 to be used for Sudo tests";
	private String runAsUserGroupName = "runassudousrgrp";
	private String runAsUserGroupDescription = "Group2 to be used for Sudo tests";
	private String runAsGroupName = "runassudogrp";
	private String runAsGroupDescription = "Group3 to be used for Sudo tests";

	
	//Host  used in this testsuite
	private String domain = System.getProperty("ipa.server.domain");
	private String hostname = "sudohost";
	private String fqdn = hostname + "." + domain;
	private String ipadr = "";
	
	//Hostgroup used in this testsuite
	private String hostgroupName = "sudohostgroup";
	private String description = "Hostgroup to be used for Sudo tests";
	
	//Host member in Hostgroup -  used in this testsuite
	private String membertype = "host";
	private String[] names = {fqdn};
	
	//Sudo Command used in this testsuite
	private String lsCommandName = "/bin/ls";
	private String lsCommandDescription = "testing ls command for Sudo";
	private String vimCommandName = "/usr/bin/vim";
	private String vimCommandDescription = "testing vim command for Sudo";
	
	//Sudo Command Groups used in this testsuite
	private String allowCommandGroupName = "allowgroup";
	private String allowCommandGroupDescription = "allow group for Sudo commands";
	private String denyCommandGroupName = "denygroup";
	private String denyCommandGroupDescription = "deny group for Sudo commands";
	
	
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.setStrictVisibilityCheck(true);
		
		//add new user, user group, host, host group
		System.out.println("Check CurrentPage: " + commonTasks.userPage);
		sahiTasks.navigateTo(commonTasks.userPage, true);
		if (!sahiTasks.link(uid).exists())
			UserTasks.createUser(sahiTasks, uid, givenName, sn, "Add");
		if (!sahiTasks.link(runAsUID).exists())
			UserTasks.createUser(sahiTasks, runAsUID, runAsGivenName, runAsSN, "Add");

		System.out.println("Check CurrentPage: " + commonTasks.groupPage);
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		if (!sahiTasks.link(groupName).exists())
			GroupTasks.createGroupService(sahiTasks, groupName, groupDescription, commonTasks.groupPage);
		if (!sahiTasks.link(runAsUserGroupName).exists())
			GroupTasks.createGroupService(sahiTasks, runAsUserGroupName, runAsUserGroupDescription, commonTasks.groupPage);
		if (!sahiTasks.link(runAsGroupName).exists())
			GroupTasks.createGroupService(sahiTasks, runAsGroupName, runAsGroupDescription, commonTasks.groupPage);
		
		
		System.out.println("Check CurrentPage: " + commonTasks.hostPage);
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		if (!sahiTasks.link(fqdn.toLowerCase()).exists())
			HostTasks.addHost(sahiTasks, hostname, commonTasks.getIpadomain(), ipadr);
		
		System.out.println("Check CurrentPage: " + commonTasks.hostgroupPage);
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		if (!sahiTasks.link(hostgroupName).exists()) 
			HostgroupTasks.addHostGroup(sahiTasks, hostgroupName, description, "Add");
		
		
		System.out.println("Check CurrentPage: " + commonTasks.sudoCommandPage);
		sahiTasks.navigateTo(commonTasks.sudoCommandPage, true);
		if (!sahiTasks.link(lsCommandName).exists()) 
			SudoTasks.createSudoCommandAdd(sahiTasks, lsCommandName, lsCommandDescription, "Add");
		if (!sahiTasks.link(vimCommandName).exists()) 
			SudoTasks.createSudoCommandAdd(sahiTasks, vimCommandName, vimCommandDescription, "Add");
		
		System.out.println("Check CurrentPage: " + commonTasks.sudoCommandGroupPage);
		sahiTasks.navigateTo(commonTasks.sudoCommandGroupPage, true);
		if (!sahiTasks.link(allowCommandGroupName).exists()) 
			SudoTasks.createSudoCommandGroupAdd(sahiTasks, allowCommandGroupName, allowCommandGroupDescription, "Add");
		if (!sahiTasks.link(denyCommandGroupName).exists()) 
			SudoTasks.createSudoCommandGroupAdd(sahiTasks, denyCommandGroupName, denyCommandGroupDescription, "Add");		
			
		
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
			sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		}		
	}
	

	/*
	 * Add sudorule - for positive tests
	 */
	@Test (groups={"sudoRuleAddTests"}, description="Add Sudo Rules", dataProvider="getSudoruleTestObjects")	
	public void testSudoruleadd(String testName, String cn) throws Exception {		
		//verify sudo rule doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify sudorule " + cn + " doesn't already exist");
		
		//new sudo rule can be added now
		SudoTasks.createSudoRule(sahiTasks, cn, "Add");		
		
		//verify sudo rule was added successfully
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Added sudorule " + cn + "  successfully");
	}
	
	/*
	 * Add, and then add another Sudo Rule
	 */
	@Test (groups={"sudoRuleAddAndAddAnotherTests"}, description="Add and Add Another Sudo Rule", dataProvider="getSudoRuleAddAndAddAnotherTestObjects")	
	public void testSudoRuleAddAndAddAnother(String testName, String cn1, String cn2) throws Exception {		
		Assert.assertFalse(sahiTasks.link(cn1).exists(), "Verify Sudo Rule " + cn1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(cn2).exists(), "Verify Sudo Rule " + cn2 + " doesn't already exist");
		
		SudoTasks.addSudoThenAddAnother(sahiTasks, cn1, cn2);
		
		Assert.assertTrue(sahiTasks.link(cn1).exists(), "Added Sudo Rule " + cn1 + "  successfully");
		Assert.assertTrue(sahiTasks.link(cn2).exists(), "Added Sudo Rule " + cn2 + "  successfully");
	}
	
	/*
	 * Add, and edit Sudo Rule
	 */	
	@Test (groups={"sudoRuleAddAndEditTests"}, description="Add and Edit Sudo Rule; commented test for Bug 735185", 
			dataProvider="getEditSudoRuleTestObjects")		
	public void testSudoRuleAddAndEdit(String testName, String cn) throws Exception {
		
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify Sudo rule " + cn + " doesn't already exist");
		
		
		//new test rule can be added now
		SudoTasks.addAndEditSudoRule(sahiTasks, cn, uid, hostgroupName, lsCommandName, denyCommandGroupName, runAsGroupName);				
		
		//verify changes	
		SudoTasks.verifySudoRuleUpdates(sahiTasks, cn, uid, hostgroupName, lsCommandName, denyCommandGroupName, runAsGroupName);
	}
	
	/*
	 * Add, but Cancel adding SudoRule
	 */
	@Test (groups={"sudoRuleCancelAddTests"}, description="Add but Cancel Adding Sudo Rule", dataProvider="getSingleSudoRuleTestObjects")	
	public void testSudoRuleCancelAdd(String testName, String cn) throws Exception {
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify Sudo Rule " + cn + " doesn't already exist");
		
		//new test rule can be added now
		SudoTasks.createSudoRule(sahiTasks, cn, "Cancel");
		
		//verify rule was added successfully
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify Sudo Rule " + cn + "  was not added");
	}
	
	
	/*
	 * Add Rules - for negative tests
	 */
	@Test (groups={"invalidSudoRuleAddTests"}, description="Add duplicate Rule", dataProvider="getInvalidSudoRuleTestObjects", dependsOnGroups="sudoRuleAddTests")	
	public void testInvalidSudoRuleadd(String testName, String cn, String expectedError) throws Exception {
		//new test user can be added now
		SudoTasks.createInvalidRule(sahiTasks, cn, expectedError);		
	}
	
	
	/*
	 * Add Rules - check required fields - for negative tests
	 */
	@Test (groups={"sudoRuleRequiredFieldAddTests"}, description="Add blank Rule", dataProvider="getSudoRuleRequiredFieldTestObjects")	
	public void testSudoRuleRequiredFieldAdd(String testName, String cn, String expectedError) throws Exception {
		//new test user can be added now
		SudoTasks.createRuleWithRequiredField(sahiTasks, cn, expectedError);		
	}
	

	
	
	/*
	 * Delete multiple Sudo Rules
	 */
	@Test (groups={"sudoRuleMultipleDeleteTests"}, description="Delete Multiple Rules", dataProvider="getMultipleSudoRuleTestObjects", 
			dependsOnGroups={"sudoRuleAddTests", "sudoRuleSearchTests" })		
	public void testMultipleSudoRuleDelete(String testName, String cn1, String cn2) throws Exception {	
		String cns[] = {cn1, cn2};
		
		
		//verify rule to be deleted exists
		for (String cn : cns) {
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Sudo Rule " + cn + "  to be deleted exists");
		}			
		//mark this rule for deletion
		SudoTasks.chooseMultiple(sahiTasks, cns);		
		SudoTasks.deleteMultiple(sahiTasks);
	}
	
	/*
	 * Delete a Sudo Rule
	 */
	@Test (groups={"sudoRuleDeleteTests"}, description="Delete Rules one at a time", dataProvider="getSudoRuleDeleteTestObjects", 
			dependsOnGroups={"sudoRuleAddTests", "sudoRuleSearchTests", "invalidSudoRuleAddTests" })	
	public void testSudoRuleDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Sudo Rule " + cn + "  to be deleted exists");
		
		//modify this user
		SudoTasks.deleteSudo(sahiTasks, cn, "Delete");
		
		//verify user is deleted
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Sudo Rule " + cn + "  deleted successfully");
	}
	
	/*
	 * Expand/Collapse details of a Sudo Rule
	 */
	@Test (groups={"sudoRuleExpandCollapseTests"}, description="Expand and Collapse details of a Rule", dataProvider="getEditSudoRuleTestObjects",  
			dependsOnGroups="sudoRuleAddAndEditTests")
	public void testSudoRuleExpandCollapse(String testName, String cn) throws Exception {
		
		SudoTasks.expandCollapseRule(sahiTasks, cn);		
		
	}
	
	/*
	 * Search a Sudo Rule
	 */
	@Test (groups={"sudoRuleSearchTests"}, description="Search for Rules", dataProvider="getSudoRuleSearchTestObjects", 
			dependsOnGroups={"sudoRuleAddTests", "sudoRuleAddAndAddAnotherTests", "sudoRuleAddAndEditTests"})
	public void testSudoRuleSearch(String testName, String searchString, String multipleResult1, String multipleResult2, String multipleResult3, String multipleResult4) throws Exception {		
		String[] multipleResults = {multipleResult1, multipleResult2, multipleResult3, multipleResult4};
		CommonTasks.search(sahiTasks, searchString);
		
		//verify rules were found
		for (String multipleResult : multipleResults) {
			Assert.assertTrue(sahiTasks.link(multipleResult).exists(), "Verify Sudo Service " + multipleResult + " was found while searching");
		}
		CommonTasks.clearSearch(sahiTasks);
	}
	
	

	/*
	 * Edit the General Section for the Sudo Rule
	 */
	@Test (groups={"sudoRuleGeneralSettingsTests"}, dataProvider="getSudoRuleGeneralSettingsTestObjects", dependsOnGroups={"sudoRuleAddAndEditTests"})
	public void testSudoRuleGeneralSettings(String testName, String cn, String description) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		//modify this rule
		SudoTasks.modifySudoRuleGeneralSection(sahiTasks, cn, description);
		
		//verify changes	
		SudoTasks.verifySudoRuleGeneralSection(sahiTasks, cn, description);
		
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "ipaenabledflag", "undo");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "ipaenabledflag", "Reset");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "ipaenabledflag", "Update");
	}
	
	
	/*
	 * Edit the Options Section for the Sudo Rule
	 */
	@Test (groups={"sudoRuleOptionsSettingsTests"}, dataProvider="getSudoRuleOptionsSettingsTestObjects", dependsOnGroups={"sudoRuleAddAndEditTests"})
	public void testSudoRuleOptionsSettings(String testName, String cn, String option1, String option2) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		//modify this rule
		SudoTasks.modifySudoRuleOptionsSection(sahiTasks, cn, option1, option2);
		
		//verify changes	
		SudoTasks.verifySudoRuleOptionsSection(sahiTasks, cn, option1, option2);
	}
	

	/*
	 * Edit the Who Section for the Sudo Rule
	 * Testing:
	 * Verify user added as part of sudoRuleAddAndEditTests is a member of this sudo rule
	 * delete this user, add a user group in this section
	 * verify the user is not a member, and groups is a member of this sudo rule
	 * add the user to the group
	 * verify the user is an indirect member of the group
	 * verify undo/reset/update for this section when working with the radiobutton
	 */
	@Test (groups={"sudoRuleUserCategorySettingsTests"}, dataProvider="getEditSudoRuleTestObjects", dependsOnGroups={"sudoRuleAddAndEditTests"})
	public void testSudoRuleUserCategorySettings(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		//verify by clicking on user - it is a member of this Sudo rule
		SudoTasks.verifySudoRuleForEnrollment(sahiTasks, commonTasks, cn, uid, "Users", "direct", true);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		//modify this rule
		SudoTasks.modifySudoRuleUserCategorySection(sahiTasks, cn, uid, groupName);
		//verify by clicking on usergroup - it is a member of this Sudo rule
		SudoTasks.verifySudoRuleForEnrollment(sahiTasks, commonTasks, cn, groupName, "User Groups", "direct", true);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		
		//verify by clicking on user - it is a member of this Sudo rule
		SudoTasks.verifySudoRuleForEnrollment(sahiTasks,commonTasks,cn, uid, "Users", "direct", false);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		//add user to usergroup
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		GroupTasks.addMembers(sahiTasks, groupName, "user", uid, "Enroll");
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		//now verify it is indirect member of this Sudo rule
		SudoTasks.verifySudoRuleForEnrollment(sahiTasks, commonTasks, cn, uid, "Users", "indirect", true);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "usercategory", "undo");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "usercategory", "Reset");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "usercategory", "Update");
	}
	
	
	/*
	 * Edit the "Access this Host" Section for the Sudo Rule
	 * Testing:
	 * Verify hostgroup added as part of sudoRuleAddAndEditTests is a member of this sudo rule
	 * add the host to the hostgroup
	 * verify the host is an indirect member of the group
	 * delete this hostgroup, add a host in this section
	 * verify the hostgroup is not a member, and host is a member of this sudo rule
	 * 
	 * verify undo/reset/update for this section when working with the radiobutton
	 */
	@Test (groups={"sudoRuleHostCategorySettingsTests"}, dataProvider="getEditSudoRuleTestObjects", dependsOnGroups={"sudoRuleAddAndEditTests"})
	public void testSudoRuleHostCategorySettings(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		//verify by clicking on hostgroup - it is a member of this Sudo rule
		SudoTasks.verifySudoRuleForEnrollment(sahiTasks, commonTasks, cn, hostgroupName, "Host Groups", "direct", true);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		//add host to hostgroup
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		HostgroupTasks.addMembers(sahiTasks, hostgroupName, "host", fqdn, "Enroll");
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		//now verify it is indirect member of this Sudo rule
		SudoTasks.verifySudoRuleForEnrollment(sahiTasks, commonTasks, cn, fqdn, "Hosts", "indirect", true);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		//modify this rule
		SudoTasks.modifySudoRuleHostCategorySection(sahiTasks, cn, fqdn, hostgroupName);
		//verify by clicking on usergroup - it is a member of this Sudo rule
		SudoTasks.verifySudoRuleForEnrollment(sahiTasks, commonTasks, cn, hostgroupName, "Host Groups", "direct", false);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		
		//verify by clicking on user - it is a member of this Sudo rule
		SudoTasks.verifySudoRuleForEnrollment(sahiTasks,commonTasks,cn, fqdn, "Hosts", "direct", true);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
				
		
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "hostcategory", "undo");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "hostcategory", "Reset");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "hostcategory", "Update");
	}
	
	
	/*
	 * Edit the Who Section for the Sudo Rule
	 * Testing:
	 * Verify user added as part of sudoRuleAddAndEditTests is a member of this sudo rule
	 * delete this user, add a user group in this section
	 * verify the user is not a member, and groups is a member of this sudo rule
	 * add the user to the group
	 * verify the user is an indirect member of the group
	 * verify undo/reset/update for this section when working with the radiobutton
	 */
	@Test (groups={"sudoRuleCommandCategorySettingsTests"}, dataProvider="getEditSudoRuleTestObjects", dependsOnGroups={"sudoRuleAddAndEditTests"})
	//@Test (groups={"sudoRuleCommandCategorySettingsTests"}, dataProvider="getEditSudoRuleTestObjects")
	public void testSudoRuleCommandCategorySettings(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		
		//modify this rule
		SudoTasks.modifySudoRuleCommandCategorySection(sahiTasks, cn, lsCommandName, allowCommandGroupName, vimCommandName, denyCommandGroupName);
	    SudoTasks.verifySudoRuleCommandCategorySection(sahiTasks, cn, lsCommandName, allowCommandGroupName, vimCommandName, denyCommandGroupName);
	    
		//add command to commandgroup
		sahiTasks.navigateTo(commonTasks.sudoCommandGroupPage, true);
		SudoTasks.addMembers(sahiTasks, allowCommandGroupName, lsCommandName, "Enroll");
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "cmdcategory", "undo");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "cmdcategory", "Reset");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "cmdcategory", "Update");
	}
	
	/*
	 * Edit the As Whom Section for the Sudo Rule
	 * Testing:
	 * Add user, and user group to runAs User Category
	 * verify these were added
	 * Add user again - verify expected error
	 * Verify user added as part of sudoRuleAddAndEditTests is a member of this sudo rule //bug
	 * delete this user
	 * verify the user is not a member, and groups is a member of this sudo rule //bug
	 * add the user to the group
	 * verify the user is an indirect member of the group //bug
	 * 
	 * delete the user and usergrop from runAs UserCategory
	 * verify these were deleted
	 * verify undo/reset/update for this section when working with the radiobutton
	 */
	@Test (groups={"sudoRuleRunAsUserCategorySettingsTests"}, description="Failures caused by bug 735185 & 736455 ",  
			dataProvider="getEditSudoRuleTestObjects", dependsOnGroups={"sudoRuleAddAndEditTests"})
	public void testSudoRuleRunAsUserCategorySettings(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		
		//modify this rule to add 
		SudoTasks.modifySudoRuleRunAsUserCategorySection(sahiTasks, cn, runAsUID, runAsUserGroupName, true);
		
		SudoTasks.verifySudoRuleForRunAsUserCategorySection(sahiTasks, commonTasks, cn, runAsUID, runAsUserGroupName, true);
		
		// FIXME: nkrishnan: Bug 735185 - MemberOf not listed for HBAC Rules (Source host/hostgroup) and Sudo Rules (RunAs user/usergroups)
		//verify by clicking on user - it is a member of this Sudo rule
		SudoTasks.verifySudoRuleForEnrollment(sahiTasks, commonTasks, cn, runAsUID, "Users", "direct", true);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		//verify by clicking on usergroup - it is a member of this Sudo rule
		SudoTasks.verifySudoRuleForEnrollment(sahiTasks, commonTasks, cn, runAsUserGroupName, "User Groups", "direct", true);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		//end of bug test
		
		//enroll user twice
		SudoTasks.enrollAgain(sahiTasks, cn, runAsUID, "As Whom", "Users");
	
		
		// FIXME: Bug 736455 - [ipa webui] Sudo Rule includes indirect hosts and users members in its list to add 
		// and related to above Bug 735185 
		//add user to usergroup
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		GroupTasks.addMembers(sahiTasks, groupName, "user", uid, "Enroll");
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		//now verify it is indirect member of this Sudo rule
		SudoTasks.verifySudoRuleForEnrollment(sahiTasks, commonTasks, cn, uid, "Users", "indirect", true);
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		//end of bug test
		
		//modify this rule to delete
		SudoTasks.modifySudoRuleRunAsUserCategorySection(sahiTasks, cn, runAsUID, runAsUserGroupName, false);
		SudoTasks.verifySudoRuleForRunAsUserCategorySection(sahiTasks, commonTasks, cn, runAsUID, runAsUserGroupName, false);
		
		
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "ipasudorunasusercategory", "undo");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "ipasudorunasusercategory", "Reset");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "ipasudorunasusercategory", "Update");
	}
	
	/*
	 * Testing:
	 * Verify the group that was added as part of AddAndEdit Test is listed
	 * Delete this group
	 * verify the group was deleted
	 * verify undo/reset/update for this section when working with the radiobutton
	 */
	@Test (groups={"sudoRuleRunAsGroupCategorySettingsTests"}, dataProvider="getEditSudoRuleTestObjects", 
			dependsOnGroups={"sudoRuleAddAndEditTests"})
	public void testSudoRuleRunAsGroupCategorySettings(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		SudoTasks.verifySudoRuleForRunAsGroupCategorySection(sahiTasks, commonTasks, cn, runAsGroupName, true);
		
		//enroll user twice
		SudoTasks.enrollAgain(sahiTasks, cn, runAsGroupName, "As Whom", "User Groups[1]");
		
		//modify this rule to delete
		SudoTasks.modifySudoRuleRunAsGroupCategorySection(sahiTasks, cn, runAsGroupName, false);
		SudoTasks.verifySudoRuleForRunAsGroupCategorySection(sahiTasks, commonTasks, cn, runAsGroupName, false);
		
		
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "ipasudorunasgroupcategory", "undo");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "ipasudorunasgroupcategory", "Reset");
		SudoTasks.undoResetUpdateSudoRuleSections(sahiTasks, cn, "ipasudorunasgroupcategory", "Update");		
	}
	
	/*
	 * Verify member list for the Sudo Rule
	 * uid is added as member of groupName
	 * groupName is added to Who list for Rule
	 * When choosing to add Users to From list for Rule, verify that uid 
	 * is not listed since it already is in the list for this Rule, because
	 * the it is memberof groupName
	 */
	@Test (groups={"sudoRuleMemberListTests"}, dataProvider="getSudoRuleMemberListTestObjects", dependsOnGroups={"sudoRuleAddTests"})	
	public void testSudoRuleMemberList(String testName, String cn) throws Exception {		
		//verify rule to be edited exists
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " to be edited exists");
		
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		HostgroupTasks.addMembers(sahiTasks, hostgroupName, membertype, names, "Enroll");
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		//modify this rule
		//TODO : nkrishan - SudoTasks.modifySudoRuleWhoSectionMemberList(sahiTasks, cn, fqdn, hostgroupName);
		
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		HostgroupTasks.removeMembers(sahiTasks, hostgroupName, membertype, names, "Delete");
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
	}
	

	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException {
		//delete user, user group, host, host group added for this suite
		sahiTasks.navigateTo(commonTasks.userPage, true);
		//Since memberships were checked previously, may not be in the front page for User
		if (sahiTasks.link("Users").in(sahiTasks.div("content")).exists())
			sahiTasks.link("Users").in(sahiTasks.div("content")).click();
		if (sahiTasks.link(uid).exists())
			UserTasks.deleteUser(sahiTasks, uid);
		if (sahiTasks.link(runAsUID).exists())
			UserTasks.deleteUser(sahiTasks, runAsUID);


		sahiTasks.navigateTo(commonTasks.groupPage, true);
		//Since memberships were checked previously, may not be in the front page for User Group
		if (sahiTasks.link("User Groups").in(sahiTasks.div("content")).exists())
			sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
		if (sahiTasks.link(groupName).exists())
			GroupTasks.deleteGroup(sahiTasks, groupName);
		if (sahiTasks.link(runAsUserGroupName).exists())
			GroupTasks.deleteGroup(sahiTasks, runAsUserGroupName);
		if (sahiTasks.link(runAsGroupName).exists())
			GroupTasks.deleteGroup(sahiTasks, runAsGroupName);
			
			
		
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
			
			
		
/*		
		sahiTasks.navigateTo(commonTasks.sudoCommandPage, true);
		if (sahiTasks.link(lsCommandName).exists()) {
			//SudoTasks.deleteSudoruleCommand(sahiTasks, lsCommandName, lsCommandDescription);
		}		
		
		clean up sudo command groups*/
		
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		
		String[] sudoRuleTestObjects = {"S@ud*o#Ru?le",		
				"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",
				"SudoRule1",	
				"SudoRule2",	
				"SudoRule3",	
				"SudoRule4",
				//"SudoRule5"
				} ;

		//verify rules were found
		for (String sudoRuleTestObject : sudoRuleTestObjects) {
			if (sahiTasks.link(sudoRuleTestObject).exists()){
				log.fine("Cleaning Sudo Rule: " + sudoRuleTestObject);
				SudoTasks.deleteSudo(sahiTasks, sudoRuleTestObject, "Delete");
			}			
		} 
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
		ll.add(Arrays.asList(new Object[]{ "create_sudorule",				"SudoRule1"} ));
		ll.add(Arrays.asList(new Object[]{ "sudorule_long",					"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789"      } ));
		ll.add(Arrays.asList(new Object[]{ "sudorule_specialchar",			"S@ud*o#Ru?le"      } ));
		
		
		return ll;	
	}
	

	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getSudoRuleAddAndAddAnotherTestObjects")
	public Object[][] getSudoRuleAddAndAddAnotherTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoRuleAndAddAnotherTestObject());
	}
	protected List<List<Object>> createSudoRuleAndAddAnotherTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						cn1					cn2   
		ll.add(Arrays.asList(new Object[]{ "create_two_good_sudorule",			"SudoRule2",		"SudoRule3"  } ));
		
		return ll;	
	}
	
	

	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getEditSudoRuleTestObjects")
	public Object[][] getEditSudoRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createEditSudoRuleTestObject());
	}
	protected List<List<Object>> createEditSudoRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   			
		ll.add(Arrays.asList(new Object[]{ "create_good_sudorule",			"SudoRule4"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getSingleSudoRuleTestObjects")
	public Object[][] getSingleSudoRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSingleSudoRuleTestObject());
	}
	protected List<List<Object>> createSingleSudoRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   			
		ll.add(Arrays.asList(new Object[]{ "create_good_sudorule",			"SudoRule5"      } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding invalid rules 
	 */
	@DataProvider(name="getInvalidSudoRuleTestObjects")
	public Object[][] getInvalidSudoRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidSudoRuleTestObject());
	}
	protected List<List<Object>> createInvalidSudoRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn					expected_Error   
		ll.add(Arrays.asList(new Object[]{ "create_duplicate_sudorule",		"sudorule1",		"sudo rule with name \"sudorule1\" already exists"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding rules with required fields 
	 */
	@DataProvider(name="getSudoRuleRequiredFieldTestObjects")
	public Object[][] getSudoRuleRequiredFieldTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoRuleRequiredFieldTestObject());
	}
	protected List<List<Object>> createSudoRuleRequiredFieldTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn					expected_Error   
		ll.add(Arrays.asList(new Object[]{ "create_blank_sudorule",			"",					"Required field"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when searching for rules 
	 */
	@DataProvider(name="getSudoRuleSearchTestObjects")
	public Object[][] getSudoRuleSearchTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSearchSudoRuleTestObject());
	}
	protected List<List<Object>> createSearchSudoRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					searchString   			multiple_result1	multiple_result2	multiple_result2	multiple_result2
		ll.add(Arrays.asList(new Object[]{ "search_specialchar_sudorule",	"S@ud*o#Ru?le",			"S@ud*o#Ru?le",		"",					"",					""			  } ));
		ll.add(Arrays.asList(new Object[]{ "search_multiple_sudorule",		"sudo",					"SudoRule1",  		"SudoRule2",		"SudoRule3",		"SudoRule4" } ));
		
		return ll;	
	}
	

	
	@DataProvider(name="getMultipleSudoRuleTestObjects")
	public Object[][] getMultipleSudoRuleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteMultipleSudoRuleTestObjects());
	}
	protected List<List<Object>> deleteMultipleSudoRuleTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn1					cn2																																			
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_sudorule",		"S@ud*o#Ru?le",		"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789"      } ));
		
		return ll;	
	}

	
	/*
	 * Data to be used when deleting rules 
	 */
	@DataProvider(name="getSudoRuleDeleteTestObjects")
	public Object[][] getSudoRuleDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteSudoRuleTestObject());
	}
	protected List<List<Object>> deleteSudoRuleTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "delete_sudorule",			"SudoRule1"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when modifying General Section 
	 */
	@DataProvider(name="getSudoRuleGeneralSettingsTestObjects")
	public Object[][] getSudoRuleGeneralSettingsTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editSudoRuleGeneralSettingsTestObject());
	}
	protected List<List<Object>> editSudoRuleGeneralSettingsTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   				description
		ll.add(Arrays.asList(new Object[]{ "edit_general_sudorule",			"SudoRule4",		"This rule is for eng"      } ));
		
		return ll;	
	}
	

	/*
	 * Data to be used when modifying General Section 
	 */
	@DataProvider(name="getSudoRuleOptionsSettingsTestObjects")
	public Object[][] getSudoRuleOptionsSettingsTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editSudoRuleOptionsSettingsTestObject());
	}
	protected List<List<Object>> editSudoRuleOptionsSettingsTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   				option1							option2
		ll.add(Arrays.asList(new Object[]{ "edit_general_sudorule",			"SudoRule4",		"logfile=/var/log/sudolog",		"env_delete+=\"JAVA_HOME\""      } ));
		
		return ll;	
	}
	
}
