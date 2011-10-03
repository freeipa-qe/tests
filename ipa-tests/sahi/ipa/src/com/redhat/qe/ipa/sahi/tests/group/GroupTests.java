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
		browser.navigateTo(commonTasks.groupPage, true);
		browser.setStrictVisibilityCheck(true);
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
	
	@Test (groups={"deleteGroup"}, description="delete group test", dataProvider="firstUserGroupData", dependsOnGroups="addGroup")
	public void deleteGroup_single(String testScenario, String groupName){
		Assert.assertTrue(browser.link(groupName).exists(),"before 'Delete', group should exists");
		GroupTasks.deleteGroup(browser, groupName);
		Assert.assertFalse(browser.link(groupName).exists(),"after 'Delete', group should disappear");
	}
	
	@Test (groups={"deleteGroup"}, description="delete group test", dataProvider="remainingUserGroupData", dependsOnGroups="addGroup")
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
