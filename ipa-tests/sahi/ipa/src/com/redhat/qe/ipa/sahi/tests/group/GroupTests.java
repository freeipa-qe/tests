package com.redhat.qe.ipa.sahi.tests.group;

import java.util.*;
import java.util.logging.Logger;
import org.testng.annotations.*; 

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.*;
import com.redhat.qe.auto.testng.*;

public class GroupTests extends SahiTestScript{
	
	private static Logger log = Logger.getLogger(GroupTests.class.getName());
	private static SahiTasks browser=null;
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		browser=sahiTasks;
		browser.setStrictVisibilityCheck(true);
		browser.navigateTo(commonTasks.userPage,true);
		for (String userInfo: GroupTests.testUsers){
			String[] user = userInfo.split(" ");
			String uid = user[0];
			String firstName = user[1];
			String lastName  = user[2];
			UserTasks.addUserService(browser, uid, firstName, lastName);
         } 
		browser.navigateTo(commonTasks.groupPage, true); 
	}
	 
	@AfterClass (groups={"cleanup"}, description="delete test user accounts", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException { 
		browser.navigateTo(commonTasks.userPage,true);
		for (String userInfo: GroupTests.testUsers){
			String[] user = userInfo.split(" ");
			String uid = user[0];
			UserTasks.deleteUserService(browser, uid);
		}
		browser.navigateTo(commonTasks.groupPage, true);
	} 
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		String currentURL = browser.fetch("top.location.href");
		if (!currentURL.equals(commonTasks.groupPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+commonTasks.groupPage +")");
			browser.navigateTo(commonTasks.groupPage, true);
		}
	}
	
	@Test (groups={"addGroup"}, description="add group test", dataProvider="1st_3rd_UserGroupsData")
	public void addGroup_add(String testScenario, String groupName, String groupDescription, String gid, String isPosix){
		Assert.assertFalse(browser.link(groupName).exists(),"before 'Add', group does NOT exists");
		GroupTasks.add_UserGroup(browser, groupName, groupDescription, gid, isPosix);
		Assert.assertTrue(browser.link(groupName).exists(),"after 'Add', group exists");
	}
	
	@Test (groups={"addGroup"}, description="add group test", dataProvider="4th_9th_UserGroupsData")
	public void addGroup_add_and_add_another(String testScenario, 
											String firstGroupName, String firstGroupDescription, String firstGid, String first_isPosix,
											String secondGroupName, String secondGroupDescription, String secondGid, String second_isPosix){
		Assert.assertFalse(browser.link(firstGroupName).exists(),"before 'Add', first group does NOT exists");
		Assert.assertFalse(browser.link(secondGroupName).exists(),"before 'Add', second group does NOT exists");
		
		GroupTasks.add_and_add_another_UserGroup(browser, 
												firstGroupName, firstGroupDescription, firstGid, first_isPosix, 
												secondGroupName, secondGroupDescription, secondGid, second_isPosix);
		
		Assert.assertTrue(browser.link(firstGroupName).exists(),"after 'Add', first group exists");
		Assert.assertTrue(browser.link(secondGroupName).exists(),"after 'Add', second group exists");
	}
	
	@Test (groups={"addGroup"}, description="add group test", dataProvider="10th_12th_UserGroupsData")
	public void addGroup_add_and_edit(String testScenario, String groupName, String groupDescription, String gid, String isPosix){
		Assert.assertFalse(browser.link(groupName).exists(),"before 'Add', group does NOT exists");
		GroupTasks.add_and_edit_UserGroup(browser, groupName, groupDescription, gid, isPosix);
		browser.link("User Groups").in(browser.div("content")).click();
		Assert.assertTrue(browser.link(groupName).exists(),"after 'Add', group exists");
	}
	
	@Test (groups={"addGroup"}, description="add group test", dataProvider="13th_UserGroupsData")
	public void addGroup_add_then_cancel(String testScenario, String groupName, String groupDescription, String gid, String isPosix){
		Assert.assertFalse(browser.link(groupName).exists(),"before 'Add', group does NOT exists");
		GroupTasks.add_then_cancel_UserGroup(browser, groupName, groupDescription, gid, isPosix);
		Assert.assertFalse(browser.link(groupName).exists(),"after 'Add', group should not exists as well");
	}
	
	@Test (groups={"addGroup_negative"}, description="negative test for adding groups", dataProvider="addGroup_negativeData")
	public void addGroup_Negatvie (String testScrenario, String groupName, String groupDescription, String expectedErrorMsg){ 
		browser.link("Add").click(); 
        browser.textbox("cn").setValue(groupName);
        browser.textbox("description").setValue(groupDescription);
        browser.button("Add").click();  
        // only duplicate group name will trigger error dialog 
        if (browser.div("error_dialog").exists()){
        	Assert.assertTrue(browser.div("error_dialog").getText().equals(expectedErrorMsg), "error dialog dected, now verify error msg");
        	browser.button("Cancel").click();
        }else{
        	Assert.assertTrue(browser.span(expectedErrorMsg).exists(), "expected error field triggered") ;
        }
        browser.button("Cancel").click();
	}
	
	@Test (groups={"modifyGroup_enrolluser"}, description="enroll single user as member", dataProvider="1st_User", dependsOnGroups="addGroup" )
	public void modifyGroup_enrollSingleUser(String testScenario, String groupName, String userName){ 
		browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_single(browser, groupName, userName); 
		Assert.assertTrue(GroupTasks.isGroupMember(browser, groupName, "user", userName), 
				"verify membership info: user:" + userName + " should be member of group:" + groupName); 
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrolluser"}, description="enroll multipul users as member at once", dataProvider="2nd_4th_Users", dependsOnGroups="addGroup" )
	public void modifyGroup_enrollMultiUsers(String testScenario, String groupName, String userName){
		String [] users = userName.split(" ");
		browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_multipul(browser, groupName, users);
		for (String user:users){
			Assert.assertTrue(GroupTasks.isGroupMember(browser, groupName, "user", user), 
								"verify membership info: user:" + user + " should be member of group:"+groupName); 
		}
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrolluser"}, description="enroll users by use search filter", dataProvider="5th_User", dependsOnGroups="addGroup" )
	public void modifyGroup_enrollViaSearch(String testScenario, String groupName, String userName){
 		browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_via_search(browser, groupName, userName); 
		Assert.assertTrue(GroupTasks.isGroupMember(browser, groupName, "user", userName), 
				"verify membership info: user:" + userName + " should be member of group:" + groupName); 
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup_enrolluser"}, description="enroll: cancel enrollment, ensure user not member of group", dataProvider="modifyUsers_enrolluser", dependsOnGroups="addGroup" )
	public void modifyGroup_enrollCancel(String testScenario, String groupName, String userName){
 		browser.link(groupName).click();
		GroupTasks.modifyGroup_enroll_cancel(browser, groupName, userName); 
		Assert.assertFalse(GroupTasks.isGroupMember(browser, groupName, "user", userName), 
				"verify membership info: user:" + userName + " should NOT be member of group:" + groupName);
		browser.link("User Groups").in(browser.span("back-link")).click();
	}
	
	@Test (groups={"modifyGroup"}, description = "add other user groups as member, create nested group", dataProvider="childGroups")
	public void modifyGroup_group(String testScenario, String groupName, String childGroups){
		//need work
	}
	
	@Test (groups={"modifyGroup"}, description = "modify group detail settings", dataProvider="GroupsSettings")
	public void modifyGroup_settings(String testScenario, String groupName, String settings){
		//need work
	}
	
	@Test (groups={"modifyGroup"}, description = "modify memberof relation", dataProvider="parentGroup")
	public void modifyGroup_memberof(String testScenario, String groupName, String parentGroup){
		//need work 
	}
	
	@Test (groups={"modifyGroup"}, description = "modify netgroup relation", dataProvider="netGroups")
	public void modifyGroup_netgroup(String testScenario, String groupName, String netGroups){
		//need work
	}
	
	@Test (groups={"modifyGroup"}, description = "modify role relation", dataProvider="roles")
	public void modifyGroup_role(String testScenario, String groupName, String roles) {
		//need work
	}
	
	@Test (groups={"modifyGroup"}, description = "modify HBAC rules", dataProvider="HBACrules")
	public void modifyGroup_HBACrules(String testDescription, String HBACruels){
		//need work
	}
	
	@Test (groups={"modifyGroup"}, description = "modify sudo rules", dataProvider="sudo rules")
	public void modifyGroup_SUDOrules(String testDescription, String sudoRules){
		//need work
	}
	
	@Test (groups={"modifyGroup_Negative"}, description = "negative test for modify groups", dataProvider="modifyGroup_Negative")
	public void modifyGroup_Negative (String testScenario, String negativeData){
		//need work
	}
	
	@Test (groups={"deleteGroup"}, description="delete group test", dataProvider="firstUserGroupData", dependsOnGroups="modifyGroup_enrolluser")
	public void deleteGroup_single(String testScenario, String groupName){
		Assert.assertTrue(browser.link(groupName).exists(),"before 'Delete', group should exists");
		GroupTasks.deleteGroup(browser, groupName);
		Assert.assertFalse(browser.link(groupName).exists(),"after 'Delete', group should disappear");
	}
	
	@Test (groups={"deleteGroup"}, description="delete group test", dataProvider="remainingUserGroupData", dependsOnGroups="modifyGroup_enrolluser")
	public void deleteGroup_multiple(String testScenario, String groupNames){
		String[] groups = groupNames.split(" ");
		for (String groupName:groups){
			Assert.assertTrue(browser.link(groupName).exists(),"before 'Delete', group should exists");
		}
		GroupTasks.deleteGroup(browser, groups);
		for (String groupName:groups){			
			Assert.assertFalse(browser.link(groupName).exists(),"after 'Delete', group should disappear");
		}
	}
	
	/*******************************************************
	 *                DATA PROVIDERS                       *
	 *******************************************************/
	private static String[] testUserGroups = {
								"usergrp000", "usergrp001", "usergrp002", "usergrp003", 
								"usergrp004", "usergrp005", "usergrp006", "usergrp007",
								"usergrp008", "usergrp009", "usergrp010", "usergrp011"
								};
	
	private static String[] testUsers = {
								"tuser000 test user000", "tuser001 test user001", "tuser002 test user002", "tuser003 test user003", 
								"tuser004 test user004", "tuser005 test user005", "tuser006 test user006", "tuser007 test user007",
								"tuser008 test user008", "tuser009 test user009", "tuser010 test user010", "tuser011 test user011"
								};
	
	@DataProvider (name="1st_3rd_UserGroupsData")
	public Object[][] get_1st_3rd_UserGroupsData(){
		String[][] groups={  //scenario, user group name, description, posix or not info
						{"posix group",	
								GroupTests.testUserGroups[0],"posix group, with given gid","1500000001","isPosix"},
						{"non posix group",	
								GroupTests.testUserGroups[1],"non posix group","","nonPosix"},
						{"default group: non-posix, assigned gid",
								GroupTests.testUserGroups[2],	"default group","","default"}
					  };
		return groups;
	}
	
	@DataProvider (name="4th_9th_UserGroupsData")
	public Object[][] get_4th_3rd_UserGroupsData(){
		String[][] groups={  //scenario, user group name, description, posix or not info
						{"2 posix groups",	
								GroupTests.testUserGroups[3], "posix, given gid","1500000003","isPosix",
								GroupTests.testUserGroups[4], "posix, given gid","1500000004","isPosix"},
						{"2 non posix group",	
								GroupTests.testUserGroups[5], "non posix","","nonPosix",
								GroupTests.testUserGroups[6], "non posix","","nonPosix"},
						{"mixed groups: posix and non posix",
								GroupTests.testUserGroups[7], "non posix","","default",
								GroupTests.testUserGroups[8], "posix, assigned gid", "","isPosix"}
					  };
		return groups;
	}
	
	
	@DataProvider (name="10th_12th_UserGroupsData")
	public Object[][] get_10th_12th_UserGroupsData(){
		String[][] groups={  //scenario, user group name, description, posix or not info
						{"posix group",	
								GroupTests.testUserGroups[9],"posix group, with given gid","1500000009","isPosix"},
						{"non posix group",	
								GroupTests.testUserGroups[10],"non posix group","","nonPosix"},
						{"default group: non-posix, assigned gid",
								GroupTests.testUserGroups[11],	"default group","","default"}
					  };
		return groups;
	}
	
	@DataProvider (name="13th_UserGroupsData")
	public Object[][] get_13th_UserGroupsData(){
		String[][] groups={  //scenario, user group name, description, posix or not info
							{"posix group","usergrp013","posix group, with given gid","1500000013","isPosix"},
					  	};
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
		for(int i=1;i<GroupTests.testUserGroups.length;i++){
			buffer.append(GroupTests.testUserGroups[i] + " ");
		}
		String[][] multipulGroups = {{"multipul groups", buffer.toString()}};
		return multipulGroups;
	}
	
	@DataProvider (name="1st_User")
	public Object[][] get_1st_User(){
		String[][] user = { {"first user under first group", GroupTests.testUserGroups[0], GroupTests.testUsers[0]} };
		return user;
	}
	
	@DataProvider (name="2nd_4th_Users")
	public Object[][] get_2nd_4th_Users(){
		String[][] users={ {"user: tuser001, add to 2nd group", 
							GroupTests.testUserGroups[1], 
							GroupTests.testUsers[1] + " " + GroupTests.testUsers[2] + " " + GroupTests.testUsers[3]} 
						};
		return users;
	}
	
	@DataProvider (name="5th_User")
	public Object[][] get_5th_User(){
		String [][] user = { {"user: tuser004, add to 4nd group", GroupTests.testUserGroups[4], GroupTests.testUsers[4]} };
		return user;
	}
	
	@DataProvider (name="6th_User")
	public Object[][] get_6th_User(){
		String [][] user = { {"user: tuser006, add to 6th group, but canceled", GroupTests.testUserGroups[6], GroupTests.testUsers[6]} };
		return user;
	}
	
	@DataProvider (name="addGroup_negativeData")
	public Object[][] getAddGroup_negativeData(){
		String[][] negativeData = 
						{
							{"group name is required", "","group name is not provided", "Required field"},
							{"group description is required", "testgroupname","","Required field"},
							{"group name: invalid text", "----", "group name is invalid", "may only include letters, numbers, _, -, . and $"},
							{"uniqueness check for group name","editors", "duplicated group name", "group with name \"editors\" already exists"}
						  };
		return negativeData;
	}
	
	@DataProvider(name="getGroupObjects")
	public Object[][] getGroupObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createGroupObjects());
	}
	protected List<List<Object>> createGroupObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //	test name, groupName, groupDescription				
		ll.add(Arrays.asList(new Object[]{ "addgroup","sahi_auto_001","auto generated by sahi, group 001"} )); 
		        
		return ll;	
	}//createGroupObject
	
}//class GroupTest
