package com.redhat.qe.ipa.sahi.tests.group;

import java.util.*;
import java.util.logging.Logger;
import org.testng.annotations.*; 

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.*;
import com.redhat.qe.auto.testng.*;

public class GroupTests extends SahiTestScript{
	
	private static Logger log = Logger.getLogger(GroupTests.class.getName());
	private static SahiTasks browser=null;
	
	@BeforeClass (groups={"init"}, alwaysRun=true, dependsOnGroups="setup",
			description="Initialize app for this test suite run" )
	public void initialize() throws CloneNotSupportedException {
		browser=sahiTasks;
		browser.setStrictVisibilityCheck(true);
		browser.navigateTo(commonTasks.userPage,true);
		for (String uid: GroupTests.testUsers){ 
			String firstName = "test";
			String lastName=uid;
			UserTasks.addUserService(browser, uid, firstName, lastName);
		 } 
		browser.navigateTo(commonTasks.groupPage, true); 
	}
	 
	@AfterClass (groups={"cleanup"}, alwaysRun=true,
		description="delete test user accounts")
	public void cleanup() throws CloneNotSupportedException { 
		browser.navigateTo(commonTasks.userPage,true);
		for (String uid: GroupTests.testUsers){ 
			UserTasks.deleteUserService(browser, uid);
		}
		browser.navigateTo(commonTasks.groupPage, true);
		for(String group:testUserGroups){
				GroupTasks.deleteGroup(browser, group);
		}
	} 
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		// verify the url, ensuer the correct starting URL for each methods below
		String currentURL = browser.fetch("top.location.href");
		if (!currentURL.equals(commonTasks.groupPage)){
			log.info("starting url error \n\tcurrent url: "+currentURL + " is not a starting position, \n\texpect url: "+commonTasks.groupPage );
			browser.navigateTo(commonTasks.groupPage, true);
		}
	}
	
	@AfterMethod (alwaysRun=true)
	public void checkUnsavedChanges(){
		if (browser.link("User Groups").in(browser.span("back-link")).exists())
		{
			log.info("detected link 'User Groups', this might be caused by some unclean exit or exception throw (when test case faile), not an error, just try to go back to normal test ui flow");
			browser.link("User Groups").in(browser.span("back-link")).click();
		}
		log.info("Check error dialogs...");
		// sometimes there are unexpected error that cause the dialog "Unsaved Changes" dialog hanging, click it away
		if (browser.span("Unsaved Changes").exists() || browser.span("Unsaved Changes[1]").exists() ){
			log.info("found Unsaved Changes dialog, click it away");
			if( browser.span("Reset").exists()) 
				browser.span("Reset").click();
		}else{
			log.info("no Unsaved Changes dialog found, continue");
		}
		
		if (browser.span("Validation error").exists()){
			log.info("found'Validation error' dialog, click it away");
			if( browser.button("OK").exists()) 
				browser.button("OK").click();
		}else{
			log.info("no 'Validation error' dialog found, continue");
		}
		
		if (browser.span("IPA Error 3007").exists()){
			log.info("found 'IPA Error 3007r' dialog, click it away");
			if( browser.button("Cancel").exists()) 
				browser.button("Cancel").click();
		}else{
			log.info("no 'IPA error' dialog found, continue");
		}
		log.info("Check error dialogs done");
	}
	
	@Test (groups={"addGroup"}, dataProvider="addGroupMultiple",
		description="add group test, add multiple user groups") 
	public void addGroup_add(String testScenario, String groupName, String groupDescription, String gid, String groupType){
		Assert.assertFalse(browser.link(groupName).exists(),"before 'Add', group does NOT exists");
		GroupTasks.add_UserGroup(browser, groupName, groupDescription, gid, groupType);
		Assert.assertTrue(browser.link(groupName).exists(),"after 'Add', group exists");
	}
	
	@Test (groups={"addGroup"}, dataProvider="addGroupAddAndAddAnother",
		description="add group test: use 'add and add another' button to create multiple groups at one shot")
	public void addGroup_add_and_add_another(String testScenario, 
											String firstGroupName, String firstGroupDescription, String firstGid, String first_groupType,
											String secondGroupName, String secondGroupDescription, String secondGid, String second_groupType){
		Assert.assertFalse(browser.link(firstGroupName).exists(),"before 'Add', first group does NOT exists");
		Assert.assertFalse(browser.link(secondGroupName).exists(),"before 'Add', second group does NOT exists");
		
		GroupTasks.add_and_add_another_UserGroup(browser, 
												firstGroupName, firstGroupDescription, firstGid, first_groupType, 
												secondGroupName, secondGroupDescription, secondGid, second_groupType);
		
		Assert.assertTrue(browser.link(firstGroupName).exists(),"after 'Add', first group exists");
		Assert.assertTrue(browser.link(secondGroupName).exists(),"after 'Add', second group exists");
	}
	
	@Test (groups={"addGroup"}, dataProvider="addGroupAddAndEdit",
		description="add group test: add and switch to edit mode")
	public void addGroup_add_and_edit(String testScenario, String groupName, String groupDescription, String gid, String groupType){
		Assert.assertFalse(browser.link(groupName).exists(),"before 'Add', group does NOT exists");
		GroupTasks.add_and_edit_UserGroup(browser, groupName, groupDescription, gid, groupType);
		browser.link("User Groups").in(browser.div("content")).click();
		Assert.assertTrue(browser.link(groupName).exists(),"after 'Add', group exists");
	}
	
	@Test (groups={"addGroup"}, dataProvider="addGroupAddThenCancel",
		description="add group test")
	public void addGroup_add_then_cancel(String testScenario, String groupName, String groupDescription, String gid, String groupType){
		Assert.assertFalse(browser.link(groupName).exists(),"before 'Add', group does NOT exists");
		GroupTasks.add_then_cancel_UserGroup(browser, groupName, groupDescription, gid, groupType);
		Assert.assertFalse(browser.link(groupName).exists(),"after 'Add', group should not exists as well");
	}
	
	@Test (groups={"addGroup"}, dataProvider="addGroupPrepareData",
		description="add group test")
	public void addGroup_prepareData(String testScenario, String groupName, String groupDescription, String gid, String groupType){
		Assert.assertFalse(browser.link(groupName).exists(),"before 'Add', group does NOT exists");
		GroupTasks.add_UserGroup(browser, groupName, groupDescription, gid, groupType);
		commonTasks.search(browser, groupName);
		Assert.assertTrue(browser.link(groupName).exists(),"after 'Add', group exists");
		commonTasks.clearSearch(browser);
	}
	
	@Test (groups={"addGroup_negative"}, dataProvider="addGroupNegativeData", dependsOnGroups="addGroup", 
		description="negative test for adding groups")
	public void addGroup_Negatvie (String testScrenario, String groupName, String groupDescription, String expectedErrorMsg){ 
		browser.link("Add").click(); 
		browser.textbox("cn").setValue(groupName);
		browser.textarea("description").setValue(groupDescription);
		browser.button("Add").click();
		// only duplicate group name will trigger error dialog 
		if (browser.div("error_dialog").exists()){
			Assert.assertTrue(browser.div("error_dialog").getText().equals(expectedErrorMsg), "error dialog dected, now verify error msg");
			browser.button("Cancel").click();
		}else{
			Assert.assertTrue(browser.span(expectedErrorMsg).exists(), "expected error field triggered") ;
		}
		browser.button("Cancel").click();
		if (browser.link("User Groups").in(browser.span("back-link")).exists())
			browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	///////////////////////// searchGroup test cases //////////////////////	
	
	@Test (groups={"searchGroup"}, dataProvider="searchGroupPositiveData",  dependsOnGroups="addGroup_negative")
	public void testGroupSearch(String searchgroupName) {
		
		GroupTasks.searchGroup(browser, searchgroupName);
		
		
		Assert.assertTrue(browser.link(searchgroupName).exists(), "Searched and found group " + searchgroupName + "  successfully");
		
		GroupTasks.clearSearch(browser);
	}
	
	@Test (groups={"searchGroupNegative"}, dataProvider="searchGroupNegativeData",  dependsOnGroups={"searchGroup"})	
	public void testGroupSearchNegative(String searchgroupName)  {
		
		GroupTasks.searchGroup(browser, searchgroupName);
		
		Assert.assertFalse(browser.link(searchgroupName).exists(), "group" + searchgroupName + "  not found as expected");	
		
		GroupTasks.clearSearch(browser);
	}
	
		
	
	///////////////////////// modifyGroup test cases (enroll user and groups ) //////////////////////
     @Test(groups={"modifyGroup"},  dependsOnGroups={"searchGroup"},
		description="this is a bridge test group.")
	public void modifyGroupBridge()
	{
		log.info("bridge method: after addGroups, before all modifyGroup_xxx testcases");
	}
	
	@Test (groups={"modifyGroup_enrolluser"}, dataProvider="enrollUserSingle", dependsOnGroups="modifyGroup",
		description="enroll single user as member")
	public void modifyGroup_enrollUserSingle(String testScenario, String groupName, String userName){ 
		browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_user_single(browser, groupName, userName); 
		Assert.assertTrue(browser.link(userName).exists(), 
				"verify membership info: user:" + userName + " should be member of group:" + groupName); 
		GroupTasks.modifyGroup_remove_user_single(browser, groupName, userName); 
		Assert.assertFalse(browser.link(userName).exists(), 
				"verify membership info: user:" + userName + " should NOT be member of group:" + groupName); 
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrolluser"}, dataProvider="enrollUserMultiple", dependsOnGroups="modifyGroup",
		description="enroll multipul users as member at once") 
	public void modifyGroup_enrollMultiUsers(String testScenario, String groupName, String userName){
		String [] users = userName.split(",");
		browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_user_multiple(browser, groupName, users);
		for (String user:users)
			Assert.assertTrue(browser.link(user).exists(), 
					"verify membership info: user:[" + user + "] should be member of group:" + groupName); 
		GroupTasks.modifyGroup_remove_user_multiple(browser, groupName, users);
		for (String user:users)
			Assert.assertFalse(browser.link(user).exists(), 
					"verify membership info: user:[" + user + "] should NOT be member of group:" + groupName); 
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrolluser"}, dataProvider="enrollUserViaSearch", dependsOnGroups="modifyGroup",
		description="enroll users by use search filter")
	public void modifyGroup_enrollViaSearch(String testScenario, String groupName, String userName){
		 browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_user_viasearch(browser, groupName, userName); 
		Assert.assertTrue(browser.link(userName).exists(), 
				"verify membership info: user:" + userName + " should be member of group:" + groupName); 
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrolluser"}, dataProvider="enrollUserCancel", dependsOnGroups="modifyGroup",
		description="enroll: cancel enrollment, ensure user not member of group")
	public void modifyGroup_enrollCancel(String testScenario, String groupName, String userName){
		browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_user_cancel(browser, groupName, userName); 
		Assert.assertFalse(browser.link(userName).exists(), 
				"verify membership info: user:" + userName + " should be member of group:" + groupName); 
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrollgroup"}, dataProvider="enrollGroupSingle" ,dependsOnGroups="modifyGroup_enrolluser",
		description = "add other (single) user groups as member, create nested group")
	public void modifyGroup_member_group_single(String testScenario, String groupName, String childGroup){
		browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_member_group_single(browser, groupName, childGroup);
		Assert.assertTrue(browser.link(childGroup).exists(), 
				"verify membership info: group ("+childGroup+") should be member of group: ("+groupName+")");
		GroupTasks.modifyGroup_remove_member_group_single(browser, groupName, childGroup);
		Assert.assertFalse(browser.link(childGroup).exists(), 
				"verify membership info: group ("+childGroup+") should NOT be member of group: ("+groupName+")");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrollgroup"}, dataProvider="enrollGroupMultiple",dependsOnGroups="modifyGroup_enrolluser",
		description = "add other (multiple) user groups as member, create nested group")
	public void modifyGroup_member_group_multiple(String testScenario, String groupName, String childGroups){
		browser.link(groupName).click();
		String[] group = childGroups.split(",");
		GroupTasks.modifyGroup_enroll_member_group_multiple(browser, groupName, group);
		for (String childGroup: group)
			Assert.assertTrue(browser.link(childGroup).exists(), 
					"verify membership info: group ("+childGroup+") should be member of group: ("+groupName+")");
		GroupTasks.modifyGroup_remove_member_group_multiple(browser, groupName, group);
		for (String childGroup: group)
			Assert.assertFalse(browser.link(childGroup).exists(), 
					"verify membership info: group ("+childGroup+") should NOT be member of group: ("+groupName+")");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrollgroup"}, dataProvider="enrollGroupViaSearch",dependsOnGroups="modifyGroup_enrolluser",
		description = "add other (multiple) user groups as member by using filter/search function, create nested group")
	public void modifyGroup_member_group_viasearch(String testScenario, String groupName, String childGroup){
		browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_member_group_viasearch(browser, groupName, childGroup); 
		Assert.assertTrue(browser.link(childGroup).exists(), 
				"verify membership info: group ("+childGroup+") should be member of group: ("+groupName+")");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrollgroup"}, dataProvider="enrollMemberofGroupSingle",dependsOnGroups="modifyGroup_enrolluser",
		description = "add other (single) user groups as member, create nested group")
	public void modifyGroup_memberof_group_single(String testScenario, String groupName, String childGroup){
		browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_memberof_group_single(browser, groupName, childGroup);
		Assert.assertTrue(browser.link(childGroup).exists(), 
				"verify memberof membership info: group ("+childGroup+") should be member of group: ("+groupName+")");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrollgroup"}, dataProvider="enrollMemberofGroupMultiple",dependsOnGroups="modifyGroup_enrolluser",
		description = "add other (multiple) user groups as member, create nested group")
	public void modifyGroup_memberof_group_multiple(String testScenario, String groupName, String childGroups){
		browser.link(groupName).click();
		String[] children = childGroups.split(",");
		GroupTasks.modifyGroup_enroll_memberof_group_multiple(browser, groupName, children);
		for (String child: children)
			Assert.assertTrue(browser.link(child).exists(), 
					"verify memberof membership info: group ("+child+") should be member of group: ("+groupName+")");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrollgroup"}, dataProvider="enrollMemberofGroupViaSearch",dependsOnGroups="modifyGroup_enrolluser",
		description = "add other (multiple) user groups as member by using filter/search function, create nested group")
	public void modifyGroup_memberof_group_viasearch(String testScenario, String groupName, String childGroup){
		browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_memberof_group_viasearch(browser, groupName, childGroup); 
		Assert.assertTrue(browser.link(childGroup).exists(), 
				"verify memberof membership info: group ("+childGroup+") should be member of group: ("+groupName+")");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}

	////////////////////////////// settings test cases ////////////////////////////	
	@Test(groups={"modifySettings"}, dependsOnGroups="modifyGroup_enrollgroup",
		description="this is a bridge test group")
	public void modifySettings()
	{
		log.info("bridge method: after modifyGroups, before all modifyGroup_settings testcases");
	}
 
	@Test (groups={"modifyGroup_settings"}, dataProvider="groupSettings",dependsOnGroups="modifySettings",
		description = "modify group detail settings")
	public void modifyGroup_settings(String testScenario, String groupName, String description, String gid){
		browser.link(groupName).click();
		GroupTasks.modifyGroup_settings(browser,description, gid);
		Assert.assertEquals(browser.textarea("description").value(),description );
		Assert.assertEquals(browser.textbox("gidnumber").value(),gid ); 
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_settings"}, dataProvider="groupSettings_undo",dependsOnGroups="modifySettings",
		description = "modify group detail settings")
	public void modifyGroup_settings_button_undo(String testScenario, String groupName, String description, String gid){
		browser.link(groupName).click();
		GroupTasks.modifyGroup_settings_button_undo(browser,description, gid);
		Assert.assertNoMatch (browser.textarea("description").value(),description );
		Assert.assertNoMatch (browser.textbox("gidnumber").value(),gid ); 
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_settings"}, dataProvider="groupSettings_reset", dependsOnGroups="modifySettings",
		description = "modify group detail settings")
	public void modifyGroup_settings_button_reset(String testScenario, String groupName, String description, String gid){
		browser.link(groupName).click();
		GroupTasks.modifyGroup_settings_button_reset(browser,description, gid);
		Assert.assertNoMatch (browser.textarea("description").value(),description );
		Assert.assertNoMatch (browser.textbox("gidnumber").value(),gid ); 
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={ "modifyGroup_settings_negative"}, dataProvider="groupSettingsNegativeGID", dependsOnGroups="modifyGroup_settings",
		description = "modify group detail settings")
	public void modifyGroup_settings_negative_gid(String testScenario, String groupName, String gid, String expectedErrorMsg){
		browser.link(groupName).click();
		//GroupTasks.modifyGroup_settings_negative_gid (browser, gid);
		browser.link("Settings").click(); 
		browser.textbox("gidnumber").setValue(gid); 
		if (browser.span(expectedErrorMsg).exists())
		{ 
			browser.span("Reset").click();
			browser.link("User Groups").in(browser.span("back-link")).click();
			log.info("expected error msg: " +expectedErrorMsg + " found, test pass" );
		}else{
			browser.span("Reset").click();
			browser.link("User Groups").in(browser.span("back-link")).click();
			Assert.fail( "expec error msg field :["+expectedErrorMsg+"] Not found for data [gid=" + gid + "]");
		} 
	}
	
	@Test (groups={"modifyGroup_settings_negative"}, dataProvider="groupSettingsNegativeDESC",dependsOnGroups="modifyGroup_settings",
		description = "modify group detail settings")
	public void modifyGroup_settings_negative_desc(String testScenario, String groupName, String description, String expectedErrorMsg){
		browser.link(groupName).click();
		//GroupTasks.modifyGroup_settings_negative_desc (browser, description);
		browser.link("Settings").click();
		browser.textarea("description").setValue("just for testing");
		browser.textarea("description").setValue(description);
		browser.span("Update").click();
		if (browser.span(expectedErrorMsg).exists()){ 
			browser.span("Reset").click();
			browser.link("User Groups").in(browser.span("back-link")).click();
			log.info("expectederror field found") ;
		} else{
			browser.span("Reset").click();
			browser.link("User Groups").in(browser.span("back-link")).click();
			Assert.fail("Expected error-dialog does not show");
		} 
	}
	//xdong
	@Test (groups={"modifyGroupType_settings"}, dataProvider="groupTypeSettings",dependsOnGroups="bugverification",description = "modify group type detail settings")
		public void modifyGroupType_settings(String testScenario, String groupName,String groupDescription,String gid,String groupType){
			browser.textbox("filter").setValue(groupName);
			browser.span("icon search-icon").click();
			Assert.assertFalse(browser.link(groupName).exists(),"before 'Add', group does NOT exists");
			GroupTasks.add_UserGroup(browser, groupName, groupDescription, gid, groupType);
			browser.span("icon search-icon").click();
			Assert.assertTrue(browser.link(groupName).exists(),"after 'Add', group exists");
			
		    browser.link(groupName).click();
		    browser.link("External").click();		
			if (testScenario == "normalToPosix"){
				Assert.assertFalse(browser.span("Add").exists(),"Verified normal grouptype can't add external members");
				browser.link("Settings").click();
				browser.select("action").choose("Change to POSIX group");
				browser.span("Apply").click();
				Assert.assertTrue(browser.span("POSIX").exists(),"Group Type modified to POSIX as expected");
				browser.select("action").choose("Delete");
				browser.span("Apply").click();
				Assert.assertFalse(browser.link(groupName).exists(),"Group Type modified to POSIX deleted as expected");
			}else if (testScenario == "normalToExternal") {
				Assert.assertFalse(browser.span("Add").exists(),"Verified normal grouptype can't add external members");
				browser.link("Settings").click();
				browser.select("action").choose("Change to external group");
				browser.span("Apply").click();
				Assert.assertTrue(browser.span("External").exists(),"Group Type modified to external as expected");
				browser.select("action").choose("Delete");
				browser.span("Apply").click();
				Assert.assertFalse(browser.link(groupName).exists(),"Group Type modified to external deleted as expected");
			}else if (testScenario == "Posix") {
				Assert.assertFalse(browser.span("Add").exists(),"Verified Posix grouptype can't add external members");
				browser.link("Settings").click();
				browser.select("action").choose("Change to external group");
				Assert.assertFalse(browser.span("External").exists(),"Verified Posix grouptype can't be changed to external group type");
				browser.select("action").choose("Delete");
				browser.span("Apply").click();
				Assert.assertFalse(browser.link(groupName).exists(),"Group Type Posix deleted as expected");
			}else if (testScenario == "External") {
				Assert.assertTrue(browser.span("Add").exists(),"Verified external grouptype can add external members");
				//TODO :add/add another/canel tests for adding external members
				browser.link("Settings").click();
				browser.select("action").choose("Change to POSIX group");
				Assert.assertFalse(browser.span("POSIX").exists(),"Verified external grouptype can't be changed to Posix group type");
				browser.select("action").choose("Delete");
				browser.span("Apply").click();
				Assert.assertFalse(browser.link(groupName).exists(),"Group Type External deleted as expected");
			}
			browser.textbox("filter").setValue("");
			browser.span("icon search-icon").click();
		}
	
	/////////////////////////////////// netgroup test //////////////////////////////////	
	@Test(groups={"netgroup"}, dependsOnGroups="modifyGroup_settings_negative",
		description="this is a bridge test group")
	public void modifyNetGroupBridge()
	{
		log.info("bridge method: after modifySettings test cases");
	}

	@Test (groups={"modifyGroup_netgroup_prepare"},dependsOnGroups="netgroup", dataProvider="netGroupsPrepare", 
			description = "prepare data for netgroup test")
	public void modifyGroup_netgroup_prepareTestData(String netGroupName){
		browser.navigateTo(commonTasks.netgroupPage);
		String[] allNetGroupNames = netGroupName.split(",");
		for (String name: allNetGroupNames)
		{
			String desc = "test netgroup for usergroup testing : ["+name+"]";
			CommonHelper.addNewEntry(browser, name, desc); 
			Assert.assertTrue(browser.link(name).exists(), "create netgroup:[" + name + "] for testing");
		} 
	}
	
	@Test (groups={"modifyGroup_netgroup_add"},dependsOnGroups="modifyGroup_netgroup_prepare", dataProvider="netGroupsAddSingle", 
			description = "add single netgroup under group")
	public void modifyGroup_netgroup_addSingle( String userGroupName, String netGroupName){ 
		browser.link(userGroupName).click(); 
		GroupTasks.addNetGroup_Single(browser, netGroupName); 
		Assert.assertTrue(browser.link(netGroupName).exists(), 
				"expecte user group:["+userGroupName +"] under netgroup:["+netGroupName+"]");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_netgroup_add"},dependsOnGroups="modifyGroup_netgroup_prepare", dataProvider="netGroupsAddMultiple", 
			description = "add multiple netgroups under group")
	public void modifyGroup_netgroup_addMultiple( String userGroupName,  String multiNetGroupName){ 
		browser.link(userGroupName).click(); 
		String[] netGroupNames = multiNetGroupName.split(",");
		GroupTasks.addNetGroup_Multiple(browser, netGroupNames);
		for (String name:netGroupNames) 
			Assert.assertTrue(browser.link(name).exists(), "after add, check name exist in the list");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_netgroup_add"},dependsOnGroups="modifyGroup_netgroup_prepare", dataProvider="netGroupsAddViaSearch", 
			description = "add multiple netgroups by using search(filtering) function")
	public void modifyGroup_netgroup_addViaSearch( String userGroupName, String netGroupName){ 
		browser.link(userGroupName).click(); 
		GroupTasks.addNetGroup_ViaSearch(browser, netGroupName, netGroupName);
		Assert.assertTrue(browser.link(netGroupName).exists(), "after add, check name exist in the list");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_netgroup_delete"},dependsOnGroups="modifyGroup_netgroup_add", dataProvider="netGroupsDeleteSingle", 
			description = "delete single netgroup under group")
	public void modifyGroup_netgroup_deleteSingle(String userGroupName, String netGroupName){ 
		browser.link(userGroupName).click();  
		GroupTasks.deleteNetGroup_Single(browser, netGroupName);
		Assert.assertFalse(browser.link(netGroupName).exists(), 
				"netgroup name should not in the list after deleted");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_netgroup_delete"},dependsOnGroups="modifyGroup_netgroup_add", dataProvider="netGroupsDeleteMultiple", 
			description = "delete multiple netgroups under group")
	public void modifyGroup_netgroup_DeleteMultiple(String userGroupName, String netGroupName){ 
		browser.link(userGroupName).click();
		String[] names = netGroupName.split(","); 
		GroupTasks.deleteNetGroup_Multiple(browser, names);
		for (String name:names)
			Assert.assertFalse(browser.link(name).exists(), "netgroup does NOT exist after delete");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_netgroup_negative"}, dependsOnGroups="modifyGroup_netgroup_prepare", dataProvider="netGroupsNegative", 
			description = "negative test formodify netgroup relation" )
	public void modifyGroup_netgroup_negative(String testScenario, String groupName, String netGroups){
		//I can not thing of any negative test case for now (yi 1/25/2012)
	}
	
	@Test (groups={"modifyGroup_netgroup_cleanup"}, dependsOnGroups="modifyGroup_netgroup_delete", dataProvider="netGroupsCleanup", 
				description = "clean up test data for netgroup testing")
	public void modifyGroup_netgroup_cleanup( String netGroupNames){ 
		browser.navigateTo(commonTasks.netgroupPage); 
		String[] netGroups = netGroupNames.split(",");
		CommonHelper.deleteEntry(browser, netGroups); 
	 }
	
	/////////////////////////////////// role test //////////////////////////////////	
	@Test(groups={"role"}, description="this is a bridge test group.", dependsOnGroups="modifyGroup_netgroup_cleanup")
	public void modifyRoleGroupBridge()
	{
		log.info("bridge method: after netgroup test cases");
	}

	@Test (groups={"modifyGroup_role_add"},dependsOnGroups="role", dataProvider="roleAddSingle", 
			description = "add single role under group")
	public void modifyGroup_role_addSingle( String userGroupName, String role){ 
		browser.link(userGroupName).click(); 
		GroupTasks.addRole_Single(browser, role); 
		//Assert.assertTrue(browser.link(role.toLowerCase()).exists(),"expected user group:["+userGroupName +"] under role:["+role+"]");
		Assert.assertTrue(browser.link(role).exists(),"expected user group:["+userGroupName +"] under role:["+role+"]");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_role_add"},dependsOnGroups="role", dataProvider="roleAddMultiple", 
			description = "add multiple roles under group")
	public void modifyGroup_role_addMultiple( String userGroupName,  String multiRoles){ 
		browser.link(userGroupName).click(); 
		String[] roles = multiRoles.split(",");
		GroupTasks.addRole_Multiple(browser, roles);
		for (String role:roles) 
			//Assert.assertTrue(browser.link(role.toLowerCase()).exists(), "after add, check name exist in the list");
			Assert.assertTrue(browser.link(role).exists(), "after add, check name exist in the list");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_role_add"},dependsOnGroups="role", dataProvider="roleAddViaSearch", 
			description = "add multiple netgroups by using search(filtering) function")
	public void modifyGroup_role_addViaSearch(String userGroupName, String role){ 
		browser.link(userGroupName).click(); 
		GroupTasks.addRole_ViaSearch(browser, role, role);
		//Assert.assertTrue(browser.link(role.toLowerCase()).exists(), "after add, check name exist in the list");
		Assert.assertTrue(browser.link(role).exists(), "after add, check name exist in the list");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_role_delete"},dependsOnGroups="modifyGroup_role_add", dataProvider="roleDeleteSingle", 
			description = "delete single role under group")
	public void modifyGroup_role_deleteSingle(String userGroupName, String role){ 
		browser.link(userGroupName).click();  
		GroupTasks.deleteRole_Single(browser, role);
		//Assert.assertFalse(browser.link(role.toLowerCase()).exists(), "role name should not in the list after deleted");
		Assert.assertFalse(browser.link(role).exists(), "role name should not in the list after deleted");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_role_delete"},dependsOnGroups="modifyGroup_role_add", dataProvider="roleDeleteMultiple", 
			description = "delete multiple role under group")
	public void modifyGroup_role_DeleteMultiple(String userGroupName, String roles){ 
		browser.link(userGroupName).click();
		String[] names = roles.split(","); 
		GroupTasks.deleteRole_Multiple(browser, names);
		for (String role:names)
			//Assert.assertFalse(browser.link(role.toLowerCase()).exists(), "role does NOT exist after delete");
			Assert.assertFalse(browser.link(role).exists(), "role does NOT exist after delete");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_role_negative"}, dependsOnGroups="modifyGroup_role_add", dataProvider="roleNegative", 
			description = "negative test formodify role" )
	public void modifyGroup_role_negative(String testScenario, String groupName, String role){
		//I can not thing of any negative test case for now (yi 1/25/2012)
	}
	
	/////////////////////////////////// HBAC rules test //////////////////////////////////	
	@Test(groups={"hbac"}, description="this is a bridge test group.", dependsOnGroups="modifyGroup_role_delete")
	public void modifyHBACBridge()
	{
		log.info("bridge method: after role test cases");
	}


	@Test (groups={"modifyGroup_hbac_prepare"},dependsOnGroups="hbac", dataProvider="hbacPrepare", 
			description = "prepare data for HBAC test")
	public void modifyGroup_hbac_prepareTestData(String hbacRules){
		browser.navigateTo(commonTasks.hbacPage);
		String[] rules = hbacRules.split(",");
		CommonHelper.addNewEntry(browser, rules); 
		for (String rule: rules)
			Assert.assertTrue(browser.link(rule).exists(), "create HBAC rule:[" + rule + "] for testing success");
	}
	
	@Test (groups={"modifyGroup_hbac_add"},dependsOnGroups="modifyGroup_hbac_prepare", dataProvider="hbacAddSingle", 
			description = "add single hbac rule under group")
	public void modifyGroup_hbac_addSingle( String userGroupName, String hbacRule){ 
		browser.link(userGroupName).click(); 
		GroupTasks.addHBAC_Single(browser, hbacRule); 
		Assert.assertTrue(browser.link(hbacRule).exists(), 
				"expecte user group:["+userGroupName +"] has bhac rule:["+hbacRule+"]");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_hbac_add"},dependsOnGroups="modifyGroup_hbac_prepare", dataProvider="hbacAddMultiple", 
			description = "add multiple hbac rules under group")
	public void modifyGroup_hbac_addMultiple( String userGroupName,  String multiHBACrules){ 
		browser.link(userGroupName).click(); 
		String[] hbacRules= multiHBACrules.split(",");
		GroupTasks.addHBAC_Multiple(browser, hbacRules);
		for (String rule:hbacRules) 
			Assert.assertTrue(browser.link(rule).exists(), "after add, check name exist in the list");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_hbac_add"},dependsOnGroups="modifyGroup_hbac_prepare", dataProvider="hbacAddViaSearch", 
			description = "add multiple hbac rules by using search(filtering) function")
	public void modifyGroup_hbac_addViaSearch( String userGroupName, String hbacRule){ 
		browser.link(userGroupName).click(); 
		GroupTasks.addHBAC_ViaSearch(browser, hbacRule, hbacRule);
		Assert.assertTrue(browser.link(hbacRule).exists(), "after add, check name exist in the list");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_hbac_delete"},dependsOnGroups="modifyGroup_hbac_add", dataProvider="hbacDeleteSingle", 
			description = "delete single hbac rule under group")
	public void modifyGroup_hbac_deleteSingle(String userGroupName, String hbacRule){ 
		browser.link(userGroupName).click();  
		GroupTasks.deleteHBAC_Single(browser, hbacRule);
		Assert.assertFalse(browser.link(hbacRule).exists(), "hbac name should not in the list after deleted");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_hbac_delete"},dependsOnGroups="modifyGroup_hbac_add", dataProvider="hbacDeleteMultiple", 
			description = "delete multiple hbac rules under group")
	public void modifyGroup_hbac_DeleteMultiple(String userGroupName, String hbacRules){ 
		browser.link(userGroupName).click();
		String[] names = hbacRules.split(","); 
		GroupTasks.deleteHBAC_Multiple(browser, names);
		for (String name:names)
			Assert.assertFalse(browser.link(name).exists(), "hbac rule does NOT exist after delete");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_hbac_negative"}, dependsOnGroups="modifyGroup_hbac_prepare", dataProvider="hbacNegative", 
			description = "negative test formodify hbac rule " )
	public void modifyGroup_hbac_negative(String testScenario, String groupName, String hbacRule){
		//I can not thing of any negative test case for now (yi 1/25/2012)
	}
	
	@Test (groups={"modifyGroup_hbac_cleanup"}, dependsOnGroups="modifyGroup_hbac_delete", dataProvider="hbacCleanup", 
				description = "clean up test data for hbac testing")
	public void modifyGroup_hbac_cleanup( String hbacRules){ 
		browser.navigateTo(commonTasks.hbacPage); 
		String[] rules = hbacRules.split(",");
		CommonHelper.deleteEntry(browser, rules); 
	 }

	/////////////////////////////////// sudo rules test //////////////////////////////////	
	@Test(groups={"sudo"}, description="this is a bridge test group.", dependsOnGroups="modifyGroup_hbac_cleanup")
	public void modifyGroup()
	{
		log.info("bridge method: after hbac test cases");
	}


	@Test (groups={"modifyGroup_sudo_prepare"},dependsOnGroups="sudo", dataProvider="sudoPrepare", 
			description = "prepare data for SUDO test")
	public void modifyGroup_sudo_prepareTestData(String sudoRules){
		browser.navigateTo(commonTasks.sudoPage);
		String[] rules = sudoRules.split(",");
		CommonHelper.addNewEntry(browser, rules); 
		for (String rule: rules)
			Assert.assertTrue(browser.link(rule).exists(), "create SUDO rule:[" + rule + "] for testing success");
	}
	
	@Test (groups={"modifyGroup_sudo_add"},dependsOnGroups="modifyGroup_sudo_prepare", dataProvider="sudoAddSingle", 
			description = "add single sudo rule under group")
	public void modifyGroup_sudo_addSingle( String userGroupName, String sudoRule){ 
		browser.link(userGroupName).click(); 
		GroupTasks.addSUDO_Single(browser, sudoRule); 
		Assert.assertTrue(browser.link(sudoRule).exists(), 
				"expecte user group:["+userGroupName +"] has sudo rule:["+sudoRule+"]");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_sudo_add"},dependsOnGroups="modifyGroup_sudo_prepare", dataProvider="sudoAddMultiple", 
			description = "add multiple sudo rules under group")
	public void modifyGroup_sudo_addMultiple( String userGroupName,  String multiSUDOrules){ 
		browser.link(userGroupName).click(); 
		String[] sudoRules= multiSUDOrules.split(",");
		GroupTasks.addSUDO_Multiple(browser, sudoRules);
		for (String rule:sudoRules) 
			Assert.assertTrue(browser.link(rule).exists(), "after add, check name exist in the list");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_sudo_add"},dependsOnGroups="modifyGroup_sudo_prepare", dataProvider="sudoAddViaSearch", 
			description = "add multiple sudo rules by using search(filtering) function")
	public void modifyGroup_sudo_addViaSearch( String userGroupName, String sudoRule){ 
		browser.link(userGroupName).click(); 
		GroupTasks.addSUDO_ViaSearch(browser, sudoRule, sudoRule);
		Assert.assertTrue(browser.link(sudoRule).exists(), "after add, check name exist in the list");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_sudo_delete"},dependsOnGroups="modifyGroup_sudo_add", dataProvider="sudoDeleteSingle", 
			description = "delete single sudo rule under group")
	public void modifyGroup_sudo_deleteSingle(String userGroupName, String sudoRule){ 
		browser.link(userGroupName).click();  
		GroupTasks.deleteSUDO_Single(browser, sudoRule);
		Assert.assertFalse(browser.link(sudoRule).exists(), "sudo name should not in the list after deleted");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_sudo_delete"},dependsOnGroups="modifyGroup_sudo_add", dataProvider="sudoDeleteMultiple", 
			description = "delete multiple sudo rules under group")
	public void modifyGroup_sudo_DeleteMultiple(String userGroupName, String sudoRules){ 
		browser.link(userGroupName).click();
		String[] names = sudoRules.split(","); 
		GroupTasks.deleteSUDO_Multiple(browser, names);
		for (String name:names)
			Assert.assertFalse(browser.link(name).exists(), "sudo rule does NOT exist after delete");
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_sudo_negative"}, dependsOnGroups="modifyGroup_sudo_prepare", dataProvider="sudoNegative", 
			description = "negative test formodify sudo rule " )
	public void modifyGroup_sudo_negative(String testScenario, String groupName, String sudoRule){
		//I can not thing of any negative test case for now (yi 1/25/2012)
	}
	
	@Test (groups={"modifyGroup_sudo_cleanup"}, dependsOnGroups="modifyGroup_sudo_delete", dataProvider="sudoCleanup", 
			description = "clean up test data for sudo testing")
	public void modifyGroup_sudo_cleanup( String sudoRules){ 
		browser.navigateTo(commonTasks.sudoPage); 
		String[] rules = sudoRules.split(",");
		CommonHelper.deleteEntry(browser, rules); 
	 }
	
	@Test (groups={"bugverification"}, dependsOnGroups="modifyGroup_sudo_cleanup", 
			description="bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=745790" )
	public void verifybug745790(){
		/*String gid="3000000";
		String groupName = "bug745790";
		String groupDescription = "test case for bug# 745790";
		browser.span("Add").click();
		browser.textbox("cn").setValue(groupName);
		browser.textarea("description").setValue(groupDescription); 
		//ensure the default is "isPosix" on
		if (browser.checkbox("nonposix").checked()){
			log.info("check default behave: isPosix box is check by default, good, test continue");
			browser.textbox("gidnumber").setValue(gid);
			String readFromUI = browser.textbox("gidnumber").getValue();
			if (readFromUI.equals(gid)){
				log.info("when isPosix is checked, we expect GID filed is editable, test pass, continue");
			}else{
				log.info("when isPosix is checked, we expect GID field is editable, test failed, report error ");
				log.info("bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=745790 verification result: failed");
				Assert.assertTrue(false);
			}
			// now, uncheck the isPosix box, test if field gidnumber is editable, it should be greyed out
			browser.checkbox("nonposix").uncheck();
			browser.textbox("gidnumber").setValue(gid);
			readFromUI = browser.textbox("gidnumber").getValue();
			if (readFromUI.equals(gid)){
				log.info("when isPosix is unchecked, we expect GID field is NOT editable, test failed, report error ");
				Assert.assertTrue(false);
			}else{ 
				log.info("when isPosix is checked, we expect GID filed is NOT editable, test pass, all finished");
				log.info("bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=745790 verification result: verified");
			}
			browser.button("Cancel").click();
		}
		else{
			log.info("check default behave: isPosix box is unchecked by default, this is not expected, makr it fail");
			browser.button("Cancel").click();
			Assert.assertTrue(false, "default behave check failed: isPosix box is not checked by default");
		} */
	}
	
	/////////////////////////////////// other group modification negative test //////////////////////////////////
	@Test (groups={"modifyGroup_Negative"}, description = "negative test for modify groups", dataProvider="modifyGroup_Negative")
	public void modifyGroup_Negative (String testScenario, String negativeData){
		//need work
	}
	
	//@Test (groups={"deleteGroup"}, description="delete group test", dataProvider="firstUserGroupData", dependsOnGroups="modifyGroup_sudo_cleanup")
	@Test (groups={"deleteGroup"}, description="delete group test", dataProvider="firstUserGroupData", dependsOnGroups={"bugverification","modifyGroupType_settings"})
	public void deleteGroup_single(String testScenario, String groupName){
		Assert.assertTrue(browser.link(groupName).exists(),"before 'Delete', group should exists");
		GroupTasks.deleteGroup(browser, groupName);
		Assert.assertFalse(browser.link(groupName).exists(),"after 'Delete', group should disappear");
	}
	
	//@Test (groups={"deleteGroup"}, description="delete group test", dataProvider="remainingUserGroupData", dependsOnGroups="modifyGroup_sudo_cleanup")
	@Test (groups={"deleteGroup"}, description="delete group test", dataProvider="remainingUserGroupData", dependsOnGroups={"bugverification","modifyGroupType_settings"})
	public void deleteGroup_multiple(String testScenario, String groupNames){
		String[] groups = groupNames.split(",");
		for (String groupName:groups){
			commonTasks.search(browser, groupName);
			Assert.assertTrue(browser.link(groupName).exists(),"before 'Delete', group should exists");
			commonTasks.clearSearch(browser);
		}
		GroupTasks.deleteGroup(browser, groups);
		for (String groupName:groups){			
			commonTasks.search(browser, groupName);
			Assert.assertFalse(browser.link(groupName).exists(),"after 'Delete', group should disappear");
			commonTasks.clearSearch(browser);
		}
	}
	
	/*******************************************************
	 *				DATA PROVIDERS												 *
	 *******************************************************/
	private static String[] testUserGroups = {
						"usergrp000", "usergrp001", "usergrp002", "usergrp003", 
						"usergrp004", "usergrp005", "usergrp006", "usergrp007",
						"usergrp008", "usergrp009", "usergrp010", "usergrp011",
						"usergrp012", "usergrp013", "usergrp014", "usergrp015"};
	private static String[] testUsers = { "user000", "user001", "user002", "user003",
											"user004", "user005", "user006", "user007",
											"user008", "user009", "user010", "user011"};
	private static String[] testNetGroups = {"netgrp000", "netgrp001", "netgrp002", "netgrp003","netgrp004","netgrp005"};
	private static String[] roles = {"helpdesk", "IT Security Specialist", "IT Specialist", "Security Architect", "User Administrator"};
	private static String[] hbacRules= {"habc000", "habc001","habc002","habc003","habc004","habc005","habc006","habc007"};
	private static String[] sudoRules= {"sudo000", "sudo001","sudo002","sudo003","sudo004","sudo005","sudo006","sudo007"};
		
	@DataProvider (name="addGroupMultiple")
	public Object[][] get_addGroupMultiple(){
		String[][] groups={//scenario, user group name, description, posix or not info
						{"posix group",GroupTests.testUserGroups[0],"posix group, with given gid","1500000001","posix"},
						{"non posix group",GroupTests.testUserGroups[1],"non posix group","","normal"},
						{"default group: non-posix, assigned gid",GroupTests.testUserGroups[2],	"default group","","default"}};
		return groups;
	}
	
	@DataProvider (name="addGroupAddAndAddAnother")
	public Object[][] get_addGroupAddAndAddAnother(){
		String[][] groups={//scenario, user group name, description, posix or not info
						{"2 posix groups",	
								GroupTests.testUserGroups[3], "posix, given gid","1500000003","posix",
								GroupTests.testUserGroups[4], "posix, given gid","1500000004","posix"},
						{"2 non posix group",	
								GroupTests.testUserGroups[5], "non posix","","normal",
								GroupTests.testUserGroups[6], "non posix","","normal"},
						{"mixed groups: posix and non posix",
								GroupTests.testUserGroups[7], "non posix","","default",
								GroupTests.testUserGroups[8], "posix, assigned gid", "","posix"}	};
		return groups;
	}
	
	@DataProvider (name="addGroupAddAndEdit")
	public Object[][] get_addGroupAddAndEdit(){
		String[][] groups={//scenario, user group name, description, posix or not info
						{"posix group",	
								GroupTests.testUserGroups[9],"posix group, with given gid","1500000009","posix"},
						{"non posix group",	
								GroupTests.testUserGroups[10],"non posix group","","normal"},
						{"default group: non-posix, assigned gid",
								GroupTests.testUserGroups[11],	"default group","","default"}};
		return groups;
	}
	
	@DataProvider (name="addGroupAddThenCancel")
	public Object[][] get_addGroupAddThenCancel(){
		String[][] groups={//scenario, user group name, description, posix or not info
						{"posix group","usergrp013","posix group, with given gid",GroupTests.testUserGroups[11],"posix"}};
		return groups;
	}
	
	@DataProvider (name="addGroupPrepareData")
	public Object[][] get_addGroupPrepareData(){
		String[][] groups={//scenario, user group name, description, posix or not info 
				{"non posix group",GroupTests.testUserGroups[12],"non posix group","","normal"},
				{"default group: non-posix, assigned gid",GroupTests.testUserGroups[13],	"default group","","default"},
				{"posix group",	GroupTests.testUserGroups[14],"posix group, with given gid","1500000014","posix"},
				{"non posix group",GroupTests.testUserGroups[15],"non posix group","","normal"}	}; 
		return groups;
	}
	
	@DataProvider (name="firstUserGroupData")
	public Object[][] getSingleGroup(){
		String[][] singleGroup = {{"single group", GroupTests.testUserGroups[0]}};
		return singleGroup;
	}
	
	@DataProvider (name="remainingUserGroupData")
	public Object[][] getMultipulGroups(){
		StringBuffer buffer = new StringBuffer();
		for(int i=1;i<5;i++){
			if(i==4)
				buffer.append(GroupTests.testUserGroups[i]);
			else
				buffer.append(GroupTests.testUserGroups[i] + ",");
		}
		String[][] multipulGroups = {{"multipul groups", buffer.toString()}};
		return multipulGroups;
	}
	
	@DataProvider (name="enrollUserSingle")
	public Object[][] get_enrollUserSingle(){
		String[][] user = { {"first user under first group", GroupTests.testUserGroups[0], GroupTests.testUsers[0]} };
		return user;
	}
	
	@DataProvider (name="enrollUserMultiple")
	public Object[][] get_enrollUserMultiple(){
		String testuser1 = GroupTests.testUsers[1];
		String testuser2 = GroupTests.testUsers[2];
		String testuser3 = GroupTests.testUsers[3];
		String allTestUsers = testuser1 + "," + testuser2 + "," + testuser3;
		String[][] users={ {"user: tuser001, add to 2nd group",GroupTests.testUserGroups[1], allTestUsers }};
		return users;
	}
	
	@DataProvider (name="enrollUserViaSearch")
	public Object[][] get_enrollUserViaSearch(){
		String [][] user = { {"user: tuser004, add to 4nd group", GroupTests.testUserGroups[4], GroupTests.testUsers[4]} };
		return user;
	}
	
	@DataProvider (name="enrollUserCancel")
	public Object[][] get_enrollUserCancel(){
		String [][] user = { {"user: tuser006, add to 6th group, but canceled", GroupTests.testUserGroups[6], GroupTests.testUsers[6]} };
		return user;
	}
	
	@DataProvider (name="addGroupNegativeData")
	public Object[][] getAddGroupNegativeData(){
		String[][] negativeData = 
						{
							{"group name is required", "","group name is not provided", "Required field"},
							{"group description is required", "testgroupname","","Required field"},
							{"group name: invalid text", "----", "group name is invalid", "may only include letters, numbers, _, -, . and $"},
							{"uniqueness check for group name","editors", "duplicated group name", "group with name \"editors\" already exists"}};
		return negativeData;
	}
	
	@DataProvider (name="enrollGroupSingle")
	public Object[][] get_enrollGroupSingle(){
		String[][] childOfGroup = {{"add group001 as member of group000", GroupTests.testUserGroups[0], GroupTests.testUserGroups[1] }};
		return childOfGroup;
	}
		
	@DataProvider (name="enrollGroupMultiple")
	public Object[][] get_enrollGroupMultiple(){
		String[][] childOfGroup = {{"add group003 and group004 s member of group002", GroupTests.testUserGroups[2], GroupTests.testUserGroups[3] + "," +GroupTests.testUserGroups[4]}};
		return childOfGroup;
	}

	@DataProvider (name="enrollGroupViaSearch")
	public Object[][] get_enrollGroupViaSearch(){
		String[][] childOfGroup = { {"add group006 as member of group005", GroupTests.testUserGroups[5], GroupTests.testUserGroups[6] }};
		return childOfGroup;
	}

	@DataProvider (name="enrollMemberofGroupSingle")
	public Object[][] get_enrollMemberofGroupSingle(){
		String[][] childOfGroup = {{"add group008 as member of group007",	GroupTests.testUserGroups[7], GroupTests.testUserGroups[8] }};
		return childOfGroup;
	}
	
	@DataProvider (name="enrollMemberofGroupMultiple")
	public Object[][] get_enrollMemberofGroupMultiple(){
		String[][] childOfGroup = {{"add group010 and group011,as member of group009",GroupTests.testUserGroups[9], GroupTests.testUserGroups[10] + "," + GroupTests.testUserGroups[11]}};
		return childOfGroup;
	}
	
	@DataProvider (name="enrollMemberofGroupViaSearch")
	public Object[][] get_enrollMemberofGroupViaSearch(){
		String[][] childOfGroup = {{"addgroup012 as member of group013",GroupTests.testUserGroups[12], GroupTests.testUserGroups[13] }};
		return childOfGroup;
	}

	@DataProvider (name="groupSettings")
	public Object[][] get_groupSettings(){
		String[][] childOfGroup = {{"change setting for group usergrp000 ", GroupTests.testUserGroups[0], "modified setting for group: usergrouop000", "2000000001"}};
		return childOfGroup;
	}

	@DataProvider (name="groupSettings_undo")
	public Object[][] get_groupSettings_undo(){
		String[][] childOfGroup = {{"change setting for group usergrp000 ", GroupTests.testUserGroups[0], "msg for 'undo'usergrouop000", "test 'undo'"}};
		return childOfGroup;
	}
	
	@DataProvider (name="groupSettings_reset")
	public Object[][] get_groupSettings_reset(){
		String[][] childOfGroup = {{"change setting for group usergrp000 ", GroupTests.testUserGroups[0], "msg for 'reset' for group: usergrouop000", "test 'reset'"}};
		return childOfGroup;
	}
	
	@DataProvider (name="groupSettingsNegativeGID")
	public Object[][] get_groupSettingsNegativeGID(){
		String[][] childOfGroup = { //test scenario ; group name; group description ; gid number
									{"change setting for group usergrp000 ", GroupTests.testUserGroups[0], "string should not be here", "Must be an integer"},
									{"change setting for group usergrp000 ", GroupTests.testUserGroups[0], "2147483648", "Maximum value is 2147483647"},
									{"change setting for group usergrp000 ", GroupTests.testUserGroups[0], "0", "Minimum value is 1"},
									{"change setting for group usergrp000 ", GroupTests.testUserGroups[0], "-1", "Minimum value is 1"}	};
		return childOfGroup;
	}
	
	@DataProvider (name="groupSettingsNegativeDESC")
	public Object[][] get_groupSettingsNegativeDESC(){
		String[][] childOfGroup = {{"change setting for group usergrp000 ", GroupTests.testUserGroups[0], "", "Validation error "}};
		return childOfGroup;
	}
	
	//////////////////////////////// netgroup data providers ///////////////////////////
	@DataProvider(name="netGroupsPrepare")
	public Object[][] getNetGroupsPrepare()
	{
		String[][] netGroups = { //net group name
							{GroupTests.testNetGroups[0] + "," 
							+ GroupTests.testNetGroups[1] + ","
							+ GroupTests.testNetGroups[2] + ","
							+ GroupTests.testNetGroups[3] + ","
							+ GroupTests.testNetGroups[4] + ","
							+ GroupTests.testNetGroups[5] } };
		return netGroups;
	}

	@DataProvider(name="netGroupsAddSingle")
	public Object[][] getNetGroupsAddSingle()
	{
		String[][] netGroups = { //user group name; net group name 
						{GroupTests.testUserGroups[0], GroupTests.testNetGroups[0]},
						{GroupTests.testUserGroups[1], GroupTests.testNetGroups[1]},
						{GroupTests.testUserGroups[2], GroupTests.testNetGroups[2]},
						{GroupTests.testUserGroups[3], GroupTests.testNetGroups[3]},
						{GroupTests.testUserGroups[4], GroupTests.testNetGroups[4]},
						{GroupTests.testUserGroups[5], GroupTests.testNetGroups[5]}	};
		return netGroups;
	}

	@DataProvider(name="netGroupsAddMultiple")
	public Object[][] getNetGroupsaddMultiple()
	{
		String[][] netGroups = { //user group name; net group name (s)
							{GroupTests.testUserGroups[0], GroupTests.testNetGroups[1] + "," + GroupTests.testNetGroups[2]},
							{GroupTests.testUserGroups[1], GroupTests.testNetGroups[2] + "," + GroupTests.testNetGroups[3] + "," + GroupTests.testNetGroups[4]}};
		return netGroups;
	}

	@DataProvider(name="netGroupsAddViaSearch")
	public Object[][] getNetGroupsAddViaSearch()
	{
		String[][] netGroups = { {GroupTests.testUserGroups[2], GroupTests.testNetGroups[3]}};
		return netGroups;
	}

	@DataProvider(name="netGroupsDeleteSingle")
	public Object[][] getNetGroupsDeleteSingle()
	{
		return getNetGroupsAddSingle();
	}

	@DataProvider(name="netGroupsDeleteMultiple")
	public Object[][] getNetGroupsDeleteMultiple()
	{
		return getNetGroupsaddMultiple();
	}

	@DataProvider(name="netGroupsNegative")
	public Object[][] getNetGroupsNegative()
	{
		String[][] netGroups = { {GroupTests.testNetGroups[0]},
									{GroupTests.testNetGroups[1]},
									{GroupTests.testNetGroups[2]},
									{GroupTests.testNetGroups[3]},
									{GroupTests.testNetGroups[4]},
									{GroupTests.testNetGroups[5]}};
		return netGroups;
	}

	@DataProvider(name="netGroupsCleanup")
	public Object[][] getNetGroupsCleanup()
	{
		return getNetGroupsPrepare();
	}

	//////////////////////////////// role data providers ///////////////////////////
	@DataProvider(name="roleAddSingle")
	public Object[][] getRoleAddSingle()
	{
		String[][] selectedDefaultRoles= { //defaults from ipa ui
									{GroupTests.testUserGroups[0], GroupTests.roles[0]},
									{GroupTests.testUserGroups[0], GroupTests.roles[1]},
									{GroupTests.testUserGroups[0], GroupTests.roles[2]},
									{GroupTests.testUserGroups[0], GroupTests.roles[3]},
									{GroupTests.testUserGroups[0], GroupTests.roles[4]}};
		return selectedDefaultRoles;
	}

	@DataProvider(name="roleAddMultiple")
	public Object[][] getRoleAddMultiple()
	{
		String[][] selectedDefaultRoles= { //defaults from ipa ui
									{GroupTests.testUserGroups[1], GroupTests.roles[0] + "," + GroupTests.roles[1]},
									{GroupTests.testUserGroups[1], GroupTests.roles[2] + "," + GroupTests.roles[3] + "," + GroupTests.roles[4]}};
		return selectedDefaultRoles;
	}

	@DataProvider(name="roleAddViaSearch")
	public Object[][] getRoleDefault()
	{
		String[][] selectedDefaultRoles= { {GroupTests.testUserGroups[2], GroupTests.roles[0]},
											   {GroupTests.testUserGroups[3], GroupTests.roles[1]}};
		return selectedDefaultRoles;
	}

	@DataProvider(name="roleDeleteSingle")
	public Object[][] getRoleDeleteSingle()
	{
		return getRoleAddSingle();
	}

	@DataProvider(name="roleDeleteMultiple")
	public Object[][] getRoleDeleteMultiple()
	{
		return getRoleAddMultiple();
	}

	//////////////////////////////// hbac data providers ///////////////////////////
	@DataProvider(name="hbacPrepare")
	public Object[][] getHBACPrepare()
	{
		String[][] hbac ={{GroupTests.hbacRules[0] + ","
							+ GroupTests.hbacRules[1] + ","
							+ GroupTests.hbacRules[2] + ","
							+ GroupTests.hbacRules[3] + ","
							+ GroupTests.hbacRules[4] + ","
							+ GroupTests.hbacRules[5] + ","
							+ GroupTests.hbacRules[6] + ","
							+ GroupTests.hbacRules[7] }	};
		return hbac;
	}

	@DataProvider(name="hbacAddSingle")
	public Object[][] getHBACAddSingle()
	{
		String[][] hbac = {{GroupTests.testUserGroups[0], GroupTests.hbacRules[0]},
							{GroupTests.testUserGroups[0], GroupTests.hbacRules[1]},
							{GroupTests.testUserGroups[0], GroupTests.hbacRules[2]},
							{GroupTests.testUserGroups[0], GroupTests.hbacRules[3]},
							{GroupTests.testUserGroups[0], GroupTests.hbacRules[4]}	};
		return hbac;
	}

	@DataProvider(name="hbacAddMultiple")
	public Object[][] getHBACAddMultiple()
	{
		String[][] hbac = {{GroupTests.testUserGroups[1], GroupTests.hbacRules[0] + "," + GroupTests.hbacRules[1]},
							{GroupTests.testUserGroups[1], GroupTests.hbacRules[2] + "," + GroupTests.hbacRules[3] + "," + GroupTests.hbacRules[4]}	};
		return hbac;
	}

	@DataProvider(name="hbacAddViaSearch")
	public Object[][] getHBACAddViaSearch()
	{
		String[][] hbac = {{GroupTests.testUserGroups[2], GroupTests.hbacRules[0]},
							{GroupTests.testUserGroups[3], GroupTests.hbacRules[1]}	};
		return hbac;
	}

	@DataProvider(name="hbacDeleteSingle")
	public Object[][] getHBACDeleteSingle()
	{
		return getHBACAddSingle();
	}

	@DataProvider(name="hbacDeleteMultiple")
	public Object[][] getHBACDeleteMultiple()
	{
		return getHBACAddMultiple();
	}

	@DataProvider(name="hbacCleanup")
	public Object[][] getHBACCleanup()
	{
		return getHBACPrepare();
	}


	//////////////////////////////// sudo data providers ///////////////////////////
	@DataProvider(name="sudoPrepare")
	public Object[][] getsudoPrepare()
	{
		String[][] sudo ={{GroupTests.sudoRules[0] + ","
							+ GroupTests.sudoRules[1] + ","
							+ GroupTests.sudoRules[2] + ","
							+ GroupTests.sudoRules[3] + ","
							+ GroupTests.sudoRules[4] + ","
							+ GroupTests.sudoRules[5] + ","
							+ GroupTests.sudoRules[6] + ","
							+ GroupTests.sudoRules[7] }	};
		return sudo;
	}

	@DataProvider(name="sudoAddSingle")
	public Object[][] getsudoAddSingle()
	{
		String[][] sudo = {{GroupTests.testUserGroups[0], GroupTests.sudoRules[0]},
							{GroupTests.testUserGroups[0], GroupTests.sudoRules[1]},
							{GroupTests.testUserGroups[0], GroupTests.sudoRules[2]},
							{GroupTests.testUserGroups[0], GroupTests.sudoRules[3]},
							{GroupTests.testUserGroups[0], GroupTests.sudoRules[4]}	};
		return sudo;
	}

	@DataProvider(name="sudoAddMultiple")
	public Object[][] getsudoAddMultiple()
	{
		String[][] sudo = {{GroupTests.testUserGroups[1], GroupTests.sudoRules[0] + "," + GroupTests.sudoRules[1]},
							{GroupTests.testUserGroups[1], GroupTests.sudoRules[2] + "," + GroupTests.sudoRules[3] + "," + GroupTests.sudoRules[4]}};
		return sudo;
	}

	@DataProvider(name="sudoAddViaSearch")
	public Object[][] getsudoAddViaSearch()
	{
		String[][] sudo = {{GroupTests.testUserGroups[2], GroupTests.sudoRules[0]},
							{GroupTests.testUserGroups[3], GroupTests.sudoRules[1]}	};
		return sudo;
	}

	@DataProvider(name="sudoDeleteSingle")
	public Object[][] getsudoDeleteSingle()
	{
		return getsudoAddSingle();
	}

	@DataProvider(name="sudoDeleteMultiple")
	public Object[][] getsudoDeleteMultiple()
	{
		return getsudoAddMultiple();
	}

	@DataProvider(name="sudoCleanup")
	public Object[][] getsudoCleanup()
	{
		return getsudoPrepare();
	}
	@DataProvider(name="searchGroupPositiveData")
	 public Object[][] getsearchGroupPositive()
	{
		String [][] searchgroupName ={ {GroupTests.testUserGroups[1]},{GroupTests.testUserGroups[2]} ,{GroupTests.testUserGroups[3]},{GroupTests.testUserGroups[4]}};
		return searchgroupName;
	}
	@DataProvider(name="searchGroupNegativeData")
	 public Object[][] getsearchGroupNegative()
	{
		String [][] searchgroupName ={ {GroupTests.testUserGroups[5]+" "},{" "+GroupTests.testUserGroups[6] },{"%$#%@*&%@!@#"},{"invalidgroup"}};
		return searchgroupName;
	}
	
	@DataProvider(name="groupTypeSettings")
	 public Object[][] getgroupTypeSettings()
		{
			String [][] groupTypeSettingsData ={ 
			
			{"normalToPosix","usergrp016","non posix normal group","","normal"},//add all three grouptypes to verify only external group could add external members.
			{"normalToExternal","usergrp017","non posix normal group","","normal"},
			{"Posix","usergrp018","posix group, with given gid","1500000001","posix"},
			{"External","usergrp019","non posix external group","","external"}};
			return groupTypeSettingsData;
		}
	 
}//class GroupTest
