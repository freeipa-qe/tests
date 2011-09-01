package com.redhat.qe.ipa.sahi.tests.sudo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

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
	private String runAsGroupName = "runassudogrp";
	private String runAsGroupDescription = "Group2 to be used for Sudo tests";
	
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
	private String commandName = "/bin/ls";
	private String commandDescription = "testing ls command for Sudo";
	
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
		if (!sahiTasks.link(runAsGroupName).exists())
			GroupTasks.createGroupService(sahiTasks, runAsGroupName, runAsGroupDescription, commonTasks.groupPage);
		
		System.out.println("Check CurrentPage: " + commonTasks.hostPage);
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		if (!sahiTasks.link(fqdn.toLowerCase()).exists())
			HostTasks.addHost(sahiTasks, hostname, commonTasks.getIpadomain(), ipadr);
		
		System.out.println("Check CurrentPage: " + commonTasks.hostgroupPage);
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		if (!sahiTasks.link(hostgroupName).exists()) {
			HostgroupTasks.addHostGroup(sahiTasks, hostgroupName, description, "Add");
		}
		
		System.out.println("Check CurrentPage: " + commonTasks.hostgroupPage);
		sahiTasks.navigateTo(commonTasks.sudoCommandPage, true);
		if (!sahiTasks.link(commandName).exists()) {
			SudoTasks.createSudoruleCommandAdd(sahiTasks, commandName, commandDescription);
		}
			
		
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
		//verify sudo rule doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify sudorule " + cn + " doesn't already exist");
		
		//new sudo rule can be added now
		SudoTasks.createSudorule(sahiTasks, cn, "Add");		
		
		//verify sudo rule was added successfully
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Added sudorule " + cn + "  successfully");
	}
	
	/*
	 * Add, and then add another Sudo Rule
	 */
	@Test (groups={"sudoRuleAddAndAddAnotherTests"}, dataProvider="getSudoRuleAddAndAddAnotherTestObjects")	
	public void testSudoRuleAddAndAddAnother(String testName, String cn1, String cn2) throws Exception {		
		Assert.assertFalse(sahiTasks.link(cn1).exists(), "Verify Sudo Rule " + cn1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(cn2).exists(), "Verify Sudo Rule " + cn2 + " doesn't already exist");
		
		SudoTasks.addSudoRuleThenAddAnother(sahiTasks, cn1, cn2);
		
		Assert.assertTrue(sahiTasks.link(cn1).exists(), "Added Sudo Rule " + cn1 + "  successfully");
		Assert.assertTrue(sahiTasks.link(cn2).exists(), "Added Sudo Rule " + cn2 + "  successfully");
	}
	
	/*
	 * Add, and edit HBACRule
	 */	
	@Test (groups={"sudoRuleAddAndEditTests"}, dataProvider="getSingleSudoRuleTestObjects")	
	public void testHBACRuleAddAndEdit(String testName, String cn) throws Exception {
		
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify Sudo rule " + cn + " doesn't already exist");
		
		
		//new test rule can be added now
		SudoTasks.addAndEditSudoRule(sahiTasks, cn, uid, hostgroupName, commandName, runAsGroupName);				
		
		//verify changes	
		SudoTasks.verifySudoRuleUpdates(sahiTasks, cn, uid, hostgroupName, commandName, runAsGroupName);
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
	 * Add Rules - check required fields - for negative tests
	 */
	@Test (groups={"sudoRuleRequiredFieldAddTests"}, dataProvider="getSudoRuleRequiredFieldTestObjects")	
	public void testSudoRuleRequiredFieldAdd(String testName, String cn, String expectedError) throws Exception {
		//new test user can be added now
		SudoTasks.createRuleWithRequiredField(sahiTasks, cn, expectedError);		
	}
	

	/*
	 * Edit Sudorule - for positive tests
	 */
	@Test (groups={"sudoruleEditTests"}, dataProvider="getsudoruleEditTestObjects")	
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
		ll.add(Arrays.asList(new Object[]{ "sudorule_long",					"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789"      } ));
		ll.add(Arrays.asList(new Object[]{ "sudorule_specialchar",			"s@ud*o#Ru?le"      } ));
		
		
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
		ll.add(Arrays.asList(new Object[]{ "create_two_good_sudorule",			"sudorule1",		"sudorule2"  } ));
		
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
		ll.add(Arrays.asList(new Object[]{ "create_good_sudorule",			"sudoRule3"      } ));
		
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
		       
		return ll;	
	}

	

	
	
}
