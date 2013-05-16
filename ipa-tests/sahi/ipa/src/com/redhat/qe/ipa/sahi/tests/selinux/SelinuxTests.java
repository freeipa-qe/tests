package com.redhat.qe.ipa.sahi.tests.selinux;

import java.util.ArrayList;


import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import java.util.Arrays;
import java.util.List;

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
import com.redhat.qe.ipa.sahi.tasks.SelinuxUserMapTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

public class SelinuxTests extends SahiTestScript {
	
	private String domain = CommonTasks.ipadomain;
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	private String [] hostnames = {"selinux-host1", "selinux-host2", "selinux-host3"};
	private String [] usernames = {"selinux-user1", "selinux-user2", "selinux-user3"};
	
	private String selinux_hostgroup1 = "selinux-hostgroup1";
	private String selinux_hostgroup2 = "selinux-hostgroup2";
	private String selinux_hostgroup3 = "selinux-hostgroup3";
	
	private String [] hostgroups = {selinux_hostgroup1, selinux_hostgroup2, selinux_hostgroup3};
	
	private String selinux_usergroup1 = "selinux-usergroup1";
	private String selinux_usergroup2 = "selinux-usergroup2";
	private String selinux_usergroup3 = "selinux-usergroup3";
	
	private String [] ugroups = {selinux_usergroup1, selinux_usergroup2, selinux_usergroup3};
	private String selinuxUsersOld="";
	//not able to user_u:s0-s0:c0.c1023 (If I run 'semanage user -l' on RHEL 6.4 it looks like user_u cannot s0-s0:c0.c1023 only s0)
	private String [] selinuxusers={"guest_u:s0", "xguest_u:s0", "user_u:s0", "staff_u:s0-s0:c0.c1023", "unconfined_u:s0-s0:c0.c1023"};
	private String selinuxdefaultuser="";
	
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks.setStrictVisibilityCheck(true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&netgroup-facet=search" ;
		
		//add host groups for selinux user maps
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		for (String hostgroup : hostgroups) {
			String description = hostgroup + " description";
			HostgroupTasks.addHostGroup(sahiTasks, hostgroup, description, "Add");
		}
				
		//add user groups for selinux user maps
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		for (String groupname : ugroups){
			String groupDescription = groupname + " description";
			GroupTasks.addGroup(sahiTasks, groupname, groupDescription);
		}				
		
		//add hosts for selinux user maps
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		for (String hostname : hostnames) {
			HostTasks.addHost(sahiTasks, hostname, commonTasks.getIpadomain(), "");
		}
		
		//add users for selinux user maps 
		sahiTasks.navigateTo(commonTasks.userPage, true);
		for (String username : usernames){
			UserTasks.createUser(sahiTasks, username, username, username, "Add");
		} 
		
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		selinuxdefaultuser=sahiTasks.textbox("ipaselinuxusermapdefault").getValue();
		selinuxUsersOld=sahiTasks.textbox("ipaselinuxusermaporder").getValue();
		
		sahiTasks.navigateTo(commonTasks.hbacRulesPolicyPage, true);
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue("selinux_hbacrule1");
		sahiTasks.button("Add and Edit").click();
		//sahiTasks.span("Add").near(sahiTasks.tableHeader("UsersDeleteAdd")).click();
		sahiTasks.span("Add").near(sahiTasks.div("Users")).click();
		sahiTasks.textbox("filter").setValue(usernames[0]);
		sahiTasks.span("Find").click();
		sahiTasks.checkbox(usernames[0]).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Add").click();
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content nav-space-3")).click();
		
		sahiTasks.navigateTo(commonTasks.hbacRulesPolicyPage, true);
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue("selinux_hbacrule2");
		sahiTasks.button("Add").click();
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {
		
		
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		sahiTasks.textbox("ipaselinuxusermaporder").setValue(selinuxUsersOld);
		sahiTasks.span("Update").click();
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		String [] selinuxusermaps={"selinux_rule1", "selinux_rule5", "selinux_rule7", "selinux_rule8", "selinux_rule9", "selinux_rule10", "selinux_rule11", "selinux_rule12", "selinux_rule13", "selinux_rule14", "selinux_rule@", "selinuxruleveryveryveryveryveryveryveryveryveryverylongname"};
		SelinuxUserMapTasks.deleteSelinuxUserMaps(sahiTasks, selinuxusermaps);
		
		sahiTasks.navigateTo(commonTasks.hbacRulesPolicyPage, true);
		String[] hbacrules={"selinux_hbacrule1", "selinux_hbacrule2"};
		for(String hbacrule:hbacrules)
			HBACTasks.deleteHBAC(sahiTasks, hbacrule, "Delete");
		
		//delete hosts
		final String [] delhosts = {"selinux-host1." + domain, "selinux-host2." + domain, "selinux-host3." + domain };
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		HostTasks.deleteHost(sahiTasks, delhosts);
		
		//delete users
		sahiTasks.navigateTo(commonTasks.userPage, true);
		for (String username : usernames){
			UserTasks.deleteUser(sahiTasks, username);
		}
		
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		GroupTasks.deleteGroup(sahiTasks, ugroups);
		
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		HostgroupTasks.deleteHostgroup(sahiTasks, hostgroups);		
		
	}
	
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			//CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		}		
	}
	/*
	 * Add selinux user map positive tests
	 */
	@Test (groups={"addSelinuxUserMapTests"}, dataProvider="getAddSelinuxUserMapTestObjects")	
	public void testSelinuxUserMapAdd(String testName, String rulename, String selinuxuser, String buttonToClick) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage);
		
		//Add an selinux user map
		Assert.assertFalse(sahiTasks.link(rulename).exists(), "Selinux user map for " + selinuxuser + " with rule " + rulename + " not found");
		SelinuxUserMapTasks.addSelinuxUserMap(sahiTasks, rulename, selinuxuser, buttonToClick);
		if(buttonToClick.equals("Add"))
			Assert.assertTrue(sahiTasks.link(rulename).exists(), "Selinux User Map added successfully for user " + selinuxuser);
		else
			Assert.assertFalse(sahiTasks.link(rulename).exists(), "Selinux User Map Add and Cancel tested successfully for user " + selinuxuser);
	}
	
	/*
	 * Add selinux user map syntax positive tests
	 */
	@Test (groups={"addSelinuxUserMapSyntaxTests"}, dataProvider="getAddSelinuxUserMapSyntaxTestObjects")	
	public void testSelinuxUserMapSyntaxAdd(String testName, String rulename, String selinuxuser, String buttonToClick) throws Exception {
		
		
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		
		String selinuxUsersNew=selinuxUsersOld + "$" + selinuxuser;
		sahiTasks.textbox("ipaselinuxusermaporder").setValue(selinuxUsersNew);
		sahiTasks.span("Update").click();
		sahiTasks.navigateTo(commonTasks.selinuxPage);
		
		//Add an selinux user map
		Assert.assertFalse(sahiTasks.link(rulename).exists(), "Selinux user map for " + selinuxuser + " with rule " + rulename + " not found");
		SelinuxUserMapTasks.addSelinuxUserMap(sahiTasks, rulename, selinuxuser, buttonToClick);
		if(buttonToClick.equals("Add"))
			Assert.assertTrue(sahiTasks.link(rulename).exists(), "Selinux User Map added successfully for user " + selinuxuser);
		else
			Assert.assertFalse(sahiTasks.link(rulename).exists(), "Selinux User Map Add and Cancel tested successfully for user " + selinuxuser);
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		sahiTasks.textbox("ipaselinuxusermaporder").setValue(selinuxUsersOld);
		sahiTasks.span("Update").click();
	}
	
	/*
	 * Add selinux user map negative tests
	 */
	@Test (groups={"addNegativeSelinuxUserMapTests"}, dataProvider="getAddNegativeSelinuxUserMapTestObjects", dependsOnGroups="addSelinuxUserMapTests")	
	public void testNegativeSelinuxUserMapAdd(String testName, String rulename, String selinuxuser, String errorMsg) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage);
		
		//Add an selinux user map
		
		SelinuxUserMapTasks.addSelinuxUserMap(sahiTasks, rulename, selinuxuser, "Add");
		if(rulename.isEmpty() || selinuxuser.isEmpty() || rulename.contains("$"))
			Assert.assertTrue(sahiTasks.span(errorMsg).exists(), "Verified Expected Error Message");
		else
			Assert.assertTrue(sahiTasks.div(errorMsg).exists(), "Verified Expected Error Message");
		if(sahiTasks.button("Cancel").exists())
			sahiTasks.button("Cancel").click();
		if(sahiTasks.button("Cancel").exists())
			sahiTasks.button("Cancel").click();
	}
	
	/*
	 * Add selinux user map add multiple
	 */
	@Test (groups={"addAndAddAnotherSelinuxUserMapTests"}, dataProvider="getaddAndAddAnotherSelinuxUserMapTestObjects")	
	public void testaddAndAddAnotherSelinuxUserMap(String testName, String rulename1, String rulename2, String rulename3, String selinuxuser1, String selinuxuser2, String selinuxuser3) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage);
		
		//Add an selinux user map
		Assert.assertFalse(sahiTasks.link(rulename1).exists(), "Selinux user map for " + selinuxuser1 + " with rule " + rulename1 + " not found");
		Assert.assertFalse(sahiTasks.link(rulename2).exists(), "Selinux user map for " + selinuxuser2 + " with rule " + rulename2 + " not found");
		Assert.assertFalse(sahiTasks.link(rulename3).exists(), "Selinux user map for " + selinuxuser3 + " with rule " + rulename3 + " not found");
		
		SelinuxUserMapTasks.addAndAddAnotherSelinuxUserMap(sahiTasks, rulename1, rulename2, rulename3, selinuxuser1, selinuxuser2, selinuxuser3);
		
		Assert.assertTrue(sahiTasks.link(rulename1).exists(), "Selinux User Map added successfully for user " + selinuxuser1);
		Assert.assertTrue(sahiTasks.link(rulename2).exists(), "Selinux User Map added successfully for user " + selinuxuser2);
		Assert.assertTrue(sahiTasks.link(rulename3).exists(), "Selinux User Map added successfully for user " + selinuxuser3);
	}
	
	/*
	 * Add selinux user map add and then edit
	 */
	@Test (groups={"addAndEditSelinuxUserMapTests"}, dataProvider="getaddAndEditSelinuxUserMapTestObjects")	
	public void testaddAndEditSelinuxUserMap(String testName, String rulename, String selinuxuser, String description) throws Exception {
		
		//verify selinux user map doesn't exist
				Assert.assertFalse(sahiTasks.link(rulename).exists(), "Verify selinux user map " + rulename + " doesn't already exist");
				
				//add new selinux user map
				SelinuxUserMapTasks.addAndEditSelinuxUserMap(sahiTasks, rulename, selinuxuser, description);
				sahiTasks.span("Refresh").click();
				//verify the selinux user map exists
				Assert.assertTrue(sahiTasks.link(rulename).exists(), "Verify selinux user map " + rulename + " exists");
				
				//verify the selinux user map setting
				SelinuxUserMapTasks.verifySelinuxUserMapSettings(sahiTasks, rulename, description);
	}
	
	/*
	 * Add selinux user map actions
	 */
	@Test (groups={"selinuxUserMapActionsTests"}, dataProvider="getselinuxUserMapActionsTestObjects", dependsOnGroups="addAndEditSelinuxUserMapTests")	
	public void testSelinuxUserMapActions(String testName, String rulename, String action) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		
		SelinuxUserMapTasks.selinuxUserMapAction(sahiTasks, rulename, action);
		
		if(action.equals("Delete"))
			Assert.assertFalse(sahiTasks.link(rulename).exists(), "Selinux User Map " + rulename + " deleted successfully");
		else if(action.equals("Disable"))
			Assert.assertTrue(sahiTasks.cell("Disabled").exists(), "Selinux User Map " + rulename + " disabled successfully");
		else
			Assert.assertTrue(sahiTasks.cell("Enabled").exists(), "Selinux User Map " + rulename + " enabled successfully");
		
		
	}
	
	/*
	 * Add selinux user map Undo/Refresh/Reset/Update
	 */
	@Test (groups={"selinuxUserMapUndoRefreshResetUpdateTests"}, dataProvider="getselinuxUserMapUndoRefreshResetUpdateTestObjects", dependsOnGroups="addAndAddAnotherSelinuxUserMapTests")	
	public void testSelinuxUserMapUndoRefreshResetUpdate(String testName, String rulename, String hbacRule, String action) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		
		SelinuxUserMapTasks.selinuxUserMapUndoRefreshResetUpdate(sahiTasks, rulename, hbacRule, action);
		
		if(action.equals("Update"))
			Assert.assertEquals(sahiTasks.textbox("seealso").getValue(), hbacRule, "Selinux User Map " + rulename + " updated successfully");
		else 
			Assert.assertEquals(sahiTasks.textbox("seealso").getValue(), "", action + " done successfully on SELinux User Map " + rulename);
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
		
	}
	
	/*
	 * Add selinux user map Update/Reset/Cancel
	 */
	@Test (groups={"selinuxUserMapUpdateResetCancelTests"}, dataProvider="getselinuxUserMapUpdateResetCancelTestObjects", dependsOnGroups="addAndAddAnotherSelinuxUserMapTests")	
	public void testSelinuxUserMapUpdateResetCancel(String testName, String rulename, String hbacRule, String action) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		
		SelinuxUserMapTasks.selinuxUserMapUpdateResetCancel(sahiTasks, rulename, hbacRule, action);
		
		if(action.equals("Cancel")){
			Assert.assertEquals(sahiTasks.textbox("seealso").getValue(), hbacRule, "Changes to Selinux User Map " + rulename + " remain intact");
		}
		else {
			sahiTasks.link(rulename).click();
			if(action.equals("Update"))
				Assert.assertEquals(sahiTasks.textbox("seealso").getValue(), hbacRule, "Selinux User Map " + rulename + " updated successfully");
			else
				Assert.assertEquals(sahiTasks.textbox("seealso").getValue(), "", action + " done successfully on SELinux User Map " + rulename);
		}
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
		if(sahiTasks.button("Reset").exists())
			sahiTasks.button("Reset").click();
	}
	
	/*
	 * Delete Single selinux user map
	 * 	 */
	@Test (groups={"selinuxUserMapDeleteSingleTests"}, dataProvider="getselinuxUserMapDeleteSingleTestObjects", dependsOnGroups="selinuxUserMapMemberCategory" )	
	public void testSelinuxUserMapDeleteSingle(String testName, String rulename) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		SelinuxUserMapTasks.selinuxUserMapDeleteSingle(sahiTasks, rulename);
		Assert.assertFalse(sahiTasks.link(rulename).exists(), rulename + " deleted successfully");
	}
	
	/*
	 * Enable/Disable multiple selinux user map
	 */
	@Test (groups={"selinuxUserMapEnableDisableMultipleTests"}, dataProvider="getselinuxUserMapEnableDisableMultipleTestObjects", dependsOnGroups={"addAndAddAnotherSelinuxUserMapTests"})	
	public void testSelinuxUserMapEnableDisableMultiple(String testName, String rulename1, String rulename2, String action) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		String[] rulenames={rulename1, rulename2};
		SelinuxUserMapTasks.selinuxUserMapEnableDisable(sahiTasks, rulenames, action);
		for(String rules:rulenames){
			if(action.equals("Disable"))
				Assert.assertTrue(sahiTasks.cell("Disabled").exists(), "Selinux User Map " + rules + " disabled successfully");
			else
				Assert.assertTrue(sahiTasks.cell("Enabled").exists(), "Selinux User Map " + rules + " enabled successfully");
		}
	}
	
	/*
	 * Delete Multiple selinux user map
	 */
	@Test (groups={"selinuxUserMapDeleteMultipleTests"}, dataProvider="getselinuxUserMapDeleteMultipleTestObjects", dependsOnGroups={"addSelinuxUserMapTests", "addAndAddAnotherSelinuxUserMapTests", "selinuxUserMapEnableDisableMultipleTests", "selinuxUserMapDeleteNegativeHBACRuleTests", "selinuxUserMapSearchTests"})	
	public void testSelinuxUserMapDeleteMultiple(String testName) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		String[] rulenames={"selinux_rule3", "selinux_rule4"};
		SelinuxUserMapTasks.selinuxUserMapDeleteMultiple(sahiTasks, rulenames);
		for(String rulename:rulenames)
			Assert.assertFalse(sahiTasks.link(rulename).exists(), rulename + " deleted successfully");
	}
	
	/*
	 * Add user member details of a SELinux User Maps
	 */
	@Test (groups={"selinuxUserMapMemberTests"}, description="Add a member to a SELinux User Map", dependsOnGroups={"addAndAddAnotherSelinuxUserMapTests","selinuxUserMapEnableDisableMultipleTests"},
			dataProvider="getSelinuxUserMapMemberTestObjects")
	public void testselinuxUserMapMember(String testName, String cn, String section, String type, String name1, String name2, String button, String action) throws Exception {
		String names[] = {name1, name2};
		SelinuxUserMapTasks.addMembers(sahiTasks, cn, section, type, names, button, action);	
		//verify
		SelinuxUserMapTasks.verifyMembers(sahiTasks, cn, section, type, names, button, action);
		//undo the changes for next test
		if (button.equals("All"))
			SelinuxUserMapTasks.modifySelinuxusermapMembership(sahiTasks, cn, section.toLowerCase()+"category");
		if (button.equals("Add") && action.equals("Add")) 
			SelinuxUserMapTasks.deleteUserMembers(sahiTasks, cn, section, type, names, "Delete");
	}
	
	/*
	 * Add disabled HBAC rule to SELinux User Maps
	 */
	@Test (groups={"selinuxUserMapDisabledHBACRuleTests"}, description="Add a disabled HBAC rule to a SELinux User Map", dependsOnGroups="addSelinuxUserMapTests",
			dataProvider="getSelinuxUserMapDisabledHBACRuleTestObjects")
	public void testselinuxUserMapDisabledHBACRule(String testName, String hbacrule, String rulename) throws Exception {
		
		SelinuxUserMapTasks.AddDisabledHbacRule(sahiTasks, hbacrule, rulename);
		
		sahiTasks.link(rulename).click();
		Assert.assertEquals(sahiTasks.textbox("seealso").getValue(), hbacrule, " Disabled hbac rule " + hbacrule + " successfully added to Selinux User Map " + rulename);
	}
	
	/*
	 * Delete an HBAC rule assigned to an SELinux User Map
	 */
	@Test (groups={"selinuxUserMapDeleteNegativeHBACRuleTests"}, dependsOnGroups="selinuxUserMapUpdateResetCancelTests",
			dataProvider="getSelinuxUserMapDeleteNegativeHBACRuleTestObjects")
	public void testselinuxUserMapDeleteNegativeHBACRule(String testName, String hbacrule, String rulename) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.hbacRulesPolicyPage, true);
		HBACTasks.deleteHBAC(sahiTasks, hbacrule, "Delete");

		if(sahiTasks.link("Show details").exists())
			sahiTasks.link("Show details").click();
		Assert.assertTrue(sahiTasks.listItem(hbacrule + " cannot be deleted because SELinux User Map " + rulename + " requires it").exists(), "Delete of HBAC rule failed successfully");
		if(sahiTasks.button("OK").exists())
			sahiTasks.button("OK").click();
	}
	
	/*
	 * Delete an HBAC rule assigned to an SELinux User Map
	 */
	@Test (groups={"selinuxUserMapMembersNegativeTests"}, dependsOnGroups="selinuxUserMapUpdateResetCancelTests",
			dataProvider="getSelinuxUserMapMembersNegativeTestObjects")
	public void testselinuxUserMapMembersNegative(String testName, String cn, String section, String type, String name, String button, String action, String errorMsg) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		
		String names[] = {name};
		SelinuxUserMapTasks.addMembers(sahiTasks, cn, section, type, names, button, action);	
		
		Assert.assertTrue(sahiTasks.div(errorMsg).exists(), "Verified expected error message successfully");
		if(sahiTasks.button("Cancel").exists())
			sahiTasks.button("Cancel").click();
	}
	
	/*
	 * Delete an HBAC rule assigned to an SELinux User Map
	 */
	@Test (groups={"selinuxUserMapHBACRuleNegativeTests"}, dependsOnGroups="selinuxUserMapMemberTests",
			dataProvider="getSelinuxUserMapHBACRuleNegativeTestObjects")
	public void testselinuxUserMapHBACRuleNegative(String testName, String hbacrule, String rulename, String errorMsg) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		String[] names={"selinux-user2"};
		String[] hosts={"selinux-host1.testrelm.com"};
		SelinuxUserMapTasks.addMembers(sahiTasks, rulename, "User", "Users", names, "Add", "Add");
		SelinuxUserMapTasks.addMembers(sahiTasks, rulename, "Host", "Hosts", hosts, "Add", "Add");
		SelinuxUserMapTasks.selinuxUserMapUpdateResetCancel(sahiTasks, rulename, hbacrule, "Update");
				
		Assert.assertTrue(sahiTasks.div(errorMsg).exists(), "Verified expected error message successfully");
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
		if(sahiTasks.button("Cancel").exists())
			sahiTasks.button("Cancel").click();
	}
	
	/*
	 * Search SELinux User Map
	 */
	@Test (groups={"selinuxUserMapSearchTests"}, dependsOnGroups={"addAndAddAnotherSelinuxUserMapTests","selinuxUserMapEnableDisableMultipleTests"},
			dataProvider="getSelinuxUserMapSearchTestObjects")
	public void testselinuxUserMapSearch(String testName, String rulename) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		
		commonTasks.search(sahiTasks, rulename);
		Assert.assertTrue(sahiTasks.link(rulename).exists(), rulename + " successfully found");
		commonTasks.clearSearch(sahiTasks);
		
	}
	
	/*
	 * Search SELinux User Map
	 */
	@Test (groups={"selinuxUserMapSearchNegativeTests"}, dependsOnGroups="selinuxUserMapSearchTests",
			dataProvider="getSelinuxUserMapSearchNegativeTestObjects")
	public void testselinuxUserMapSearchNegative(String testName, String rulename) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		
		commonTasks.search(sahiTasks, rulename);
		Assert.assertFalse(sahiTasks.link(rulename).exists(), rulename + " successfully not found");
		commonTasks.clearSearch(sahiTasks);
		
	}
	
	/*
	 * Change category to All SELinux User Map
	 */
	@Test (groups={"selinuxUserMapMemberCategory"}, dependsOnGroups="selinuxUserMapHBACRuleNegativeTests",
			dataProvider="getSelinuxUserMapMemberCategoryTestObjects")
	public void testselinuxUserMapMemberCategory(String testName, String rulename, String user, String host) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.selinuxPage, true);
		sahiTasks.link(rulename).click();
		if (!System.getProperty("os.name").startsWith("Windows")){ 
			sahiTasks.radio("usercategory-1-0").click(); 
		}else{ 
		    sahiTasks.radio("usercategory-8-0").click(); 
		} 
		if (!System.getProperty("os.name").startsWith("Windows")){ 
			sahiTasks.radio("hostcategory-2-0").click(); 
		}else{ 
			sahiTasks.radio("hostcategory-9-0").click(); 
		} 
		sahiTasks.span("Update").click();
		Assert.assertFalse(sahiTasks.checkbox(user).exists(), "User Category changed successfully");
		Assert.assertFalse(sahiTasks.checkbox(host).exists(), "Host Category changed successfully");
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
		
		sahiTasks.link(rulename).click();
		sahiTasks.span("Add").under(sahiTasks.heading2("User")).near(sahiTasks.div("Users")).click();
		Assert.assertFalse(sahiTasks.textbox("filter").exists(), "Users cannot be added if the category is Anyone");
		
		sahiTasks.span("Add").under(sahiTasks.heading2("Host")).near(sahiTasks.div("Hosts")).click();
		Assert.assertFalse(sahiTasks.textbox("filter").exists(), "Hosts cannot be added if the category is Anyone");
		
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Change category to All SELinux User Map
	 */
	@Test (groups={"selinuxUserMapNegativeSelinuxUser"}, dataProvider="getSelinuxUserMapNegativeSelinuxUserTestObjects")
	public void testselinuxUserMapNegativeSelinuxUser(String testName, String rulename, String selinuxuser) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		
		
		String selinuxUsersNew=selinuxUsersOld + "$" + selinuxuser;
		sahiTasks.textbox("ipaselinuxusermaporder").setValue(selinuxUsersNew);
		sahiTasks.span("Update").click();
		Assert.assertTrue(sahiTasks.span("IPA Error 3009").exists(), "Error verified");
		if(sahiTasks.button("Cancel").exists())
			sahiTasks.button("Cancel").click();
		
		sahiTasks.navigateTo(commonTasks.selinuxPage);
		SelinuxUserMapTasks.addSelinuxUserMap(sahiTasks, rulename, selinuxuser, "Add");
		Assert.assertTrue(sahiTasks.span("IPA Error 3009").exists(), "Error verified");
		if(sahiTasks.button("Cancel").exists())
			sahiTasks.button("Cancel").click();
		if(sahiTasks.button("Cancel").exists())
			sahiTasks.button("Cancel").click();
		
		sahiTasks.textbox("ipaselinuxusermaporder").setValue(selinuxUsersOld);
	}
	
	/*
	 * Modify Negative SELinux User
	 */
	@Test (groups={"selinuxUserMapModifyNegativeSelinuxUser"}, dataProvider="getSelinuxUserMapModifyNegativeSelinuxUserTestObjects")
	public void testselinuxUserMapModifyNegativeSelinuxUser(String testName, String rulename, String selinuxuser) throws Exception {
		
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		
		
		String selinuxUsersNew=selinuxUsersOld + "$" + selinuxuser;
		sahiTasks.textbox("ipaselinuxusermaporder").setValue(selinuxUsersNew);
		sahiTasks.span("Update").click();
				
		sahiTasks.navigateTo(commonTasks.selinuxPage);
		SelinuxUserMapTasks.addSelinuxUserMap(sahiTasks, rulename, selinuxuser, "Add");
		
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		selinuxuser=selinuxuser.replace('0', '1');
		selinuxUsersNew=selinuxUsersOld + "$" + selinuxuser;
		sahiTasks.textbox("ipaselinuxusermaporder").setValue(selinuxUsersNew);
		sahiTasks.span("Update").click();
		Assert.assertTrue(sahiTasks.span("IPA Error 3009").exists(), "Error verified");
		if(sahiTasks.button("Cancel").exists())
			sahiTasks.button("Cancel").click();
		
		sahiTasks.textbox("ipaselinuxusermaporder").setValue(selinuxUsersOld);
	}
	
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/

		/*
		 * Data to be used when adding selinux user map 
		 */
		@DataProvider(name="getAddSelinuxUserMapTestObjects")
		public Object[][] getAddSelinuxUserMapTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createAddSelinuxUserMapTestObjects());
		}
		protected List<List<Object>> createAddSelinuxUserMapTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname								rulename			selinuxuser					button
			ll.add(Arrays.asList(new Object[]{ 		"addselinuxusermap_MLS_singlelevel",	"selinux_rule1",	selinuxdefaultuser,			"Add" } ));
			ll.add(Arrays.asList(new Object[]{ 		"addselinuxusermap_cancel",				"selinux_rule6",	selinuxdefaultuser,			"Cancel" } ));
			ll.add(Arrays.asList(new Object[]{ 		"addselinuxusermap_disabledhbacrule",	"selinux_rule7",	selinuxusers[0],			"Add" } ));
			ll.add(Arrays.asList(new Object[]{ 		"addselinuxusermap_special",            "selinux_rule@",    selinuxusers[0],			"Add" } ));
			ll.add(Arrays.asList(new Object[]{ 		"addselinuxusermap_longname",			"selinuxruleveryveryveryveryveryveryveryveryveryverylongname",		selinuxusers[0], 		"Add" } ));
			return ll;	
		}

		/*
		 * Data to be used when adding selinux user map syntax
		 */
		@DataProvider(name="getAddSelinuxUserMapSyntaxTestObjects")
		public Object[][] getAddSelinuxUserMapSyntaxTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createAddSelinuxUserMapSyntaxTestObjects());
		}
		protected List<List<Object>> createAddSelinuxUserMapSyntaxTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname								rulename			selinuxuser						button
			ll.add(Arrays.asList(new Object[]{ 		"addselinuxusermap_MLS_range",			"selinux_rule8",	"user_u:s0-s1",					"Add" } ));
			ll.add(Arrays.asList(new Object[]{ 		"addselinuxusermap_MCS_range",			"selinux_rule9",	"user_u:s0-s15:c0.c1023",		"Add" } ));
			ll.add(Arrays.asList(new Object[]{ 		"addselinuxusermap_MCS_commas",			"selinux_rule10",	"user_u:s0-s1:c0,c2,c15.c26",	"Add" } ));
			ll.add(Arrays.asList(new Object[]{ 		"addselinuxusermap_MLS_singlevalue",	"selinux_rule11",	"user_u:s0-s0:c0.c1023",		"Add" } ));
			return ll;	
		}
		/*
		 * Data to be used when adding multiple selinux user map 
		 */
		@DataProvider(name="getaddAndAddAnotherSelinuxUserMapTestObjects")
		public Object[][] getaddAndAddAnotherSelinuxUserMapTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createaddAndAddAnotherSelinuxUserMapTestObjects());
		}
		protected List<List<Object>> createaddAndAddAnotherSelinuxUserMapTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname						rulename1			rulename2			rulename3			selinuxuser1		selinuxuser2		selinuxuser2			
			ll.add(Arrays.asList(new Object[]{ 		"addselinuxusermap_multiple",	"selinux_rule2",	"selinux_rule3",	"selinux_rule4",	selinuxusers[1],	selinuxusers[2],	selinuxusers[3] } ));
			  
			return ll;	
		}
		
		/*
		 * Data to be used when add and edit of selinux user map 
		 */
		@DataProvider(name="getaddAndEditSelinuxUserMapTestObjects")
		public Object[][] getaddAndEditSelinuxUserMapTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createaddAndEditSelinuxUserMapTestObjects());
		}
		protected List<List<Object>> createaddAndEditSelinuxUserMapTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname						rulename1			selinuxuser			description			
			ll.add(Arrays.asList(new Object[]{ 		"addandeditselinuxusermap",		"selinux_rule5",	selinuxdefaultuser,	"selinux description"	 } ));
			  
			return ll;	
		}
		
		/*
		 * Data to be used when Enable/Disable/Delete selinux user map 
		 */
		@DataProvider(name="getselinuxUserMapActionsTestObjects")
		public Object[][] getselinuxUserMapActionsTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapActionsTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapActionsTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname						rulename1			action						
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermapaction_disable",	"selinux_rule5",	"Disable"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermapaction_enable",	"selinux_rule5",	"Enable"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermapaction_delete",	"selinux_rule5",	"Delete"	 } ));
			return ll;	
		}
		
		/*
		 * Data to be used when Undo/Refresh/Reset/Update of selinux user map 
		 */
		@DataProvider(name="getselinuxUserMapUndoRefreshResetUpdateTestObjects")
		public Object[][] getselinuxUserMapUndoRefreshResetUpdateTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapUndoRefreshResetUpdateTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapUndoRefreshResetUpdateTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname						rulename			hbacrule			action						
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_undo",	"selinux_rule4",	"selinux_hbacrule1",	"undo"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_refresh",	"selinux_rule4",	"selinux_hbacrule1","Refresh"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_reset",	"selinux_rule4",	"selinux_hbacrule1","Reset"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_update",	"selinux_rule4",	"selinux_hbacrule1","Update"	 } ));
			return ll;	
		}
		/*
		 * Data to be used when Upadte/Reset/Cancel of selinux user map 
		 */
		@DataProvider(name="getselinuxUserMapUpdateResetCancelTestObjects")
		public Object[][] getselinuxUserMapUpdateResetCancelTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapUpdateResetCancelTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapUpdateResetCancelTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname							rulename			hbacrule			action						
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_backlink_cancel",	"selinux_rule3",	"selinux_hbacrule1","Cancel"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_backlink_reset",	"selinux_rule3",	"selinux_hbacrule1","Reset"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_backlink_update",	"selinux_rule3",	"selinux_hbacrule1","Update"	 } ));
			return ll;	
		}
		
		/*
		 * Data to be used for single delete of selinux user map 
		 */
		@DataProvider(name="getselinuxUserMapDeleteSingleTestObjects")
		public Object[][] getselinuxUserMapDeleteSingleTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapDeleteSingleTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapDeleteSingleTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname						rulename								
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_delete1",	"selinux_rule2"	 } ));
					
			return ll;	
		}
		
		/*
		 * Data to be used for single delete of selinux user map 
		 */
		@DataProvider(name="getselinuxUserMapDeleteMultipleTestObjects")
		public Object[][] getselinuxUserMapDeleteMultipleTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapDeleteMultipleTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapDeleteMultipleTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname														
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_deletemultiple"	 } ));
			
			return ll;	
		}
		
		/*
		 * Data to be used when adding user members
		 */
		@DataProvider(name="getSelinuxUserMapMemberTestObjects")
		public Object[][] getSelinuxUserMapMemberTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createSelinuxUserMapMemberTestObjects());
		}
		protected List<List<Object>> createSelinuxUserMapMemberTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			// 									testName								 cn		 			section		type			name1							name2							button		action	
			ll.add(Arrays.asList(new Object[]{ 	"add_user_selinuxusermap",				"selinux_rule2",	"User",		"Users",		"selinux-user1", 				"selinux-user2",				"Add",		"Add"		 } ));
			ll.add(Arrays.asList(new Object[]{ 	"add_user_selinuxusermap_cancel",		"selinux_rule2",	"User",		"Users",		"selinux-user3",				"",								"Add",		"Cancel"	 } ));	
        	ll.add(Arrays.asList(new Object[]{ 	"add_user_selinuxusermap_all",			"selinux_rule2",	"User",		"Users",		"",								"",								"All", 		"Update"	 } ));
			ll.add(Arrays.asList(new Object[]{ 	"add_usergroup_selinuxusermap",			"selinux_rule2",	"User",		"User Groups",	"selinux-usergroup1", 			"selinux-usergroup2",			"Add",		"Add"		 } ));
			ll.add(Arrays.asList(new Object[]{ 	"add_usergroup_selinuxusermap_cancel",	"selinux_rule2",	"User",		"User Groups",	"selinux-usergroup3",			"",								"Add",		"Cancel"	 } ));	
			ll.add(Arrays.asList(new Object[]{ 	"add_usergroup_selinuxusermap_all",		"selinux_rule2",	"User",		"User Groups",	"",								"",								"All", 		"Update"	 } ));
			ll.add(Arrays.asList(new Object[]{ 	"add_host_selinuxusermap",				"selinux_rule2",	"Host",		"Hosts",		"selinux-host1.testrelm.com", 	"selinux-host2.testrelm.com",	"Add",		"Add"		 } ));
			ll.add(Arrays.asList(new Object[]{ 	"add_host_selinuxusermap_cancel",		"selinux_rule2",	"Host",		"Hosts",		"selinux-host3.testrelm.com",	"",								"Add",		"Cancel"	 } ));	
			ll.add(Arrays.asList(new Object[]{ 	"add_host_selinuxusermap_all",			"selinux_rule2",	"Host",		"Hosts",		"",								"",								"All", 		"Update"	 } ));
			ll.add(Arrays.asList(new Object[]{ 	"add_hostgroup_selinuxusermap",			"selinux_rule2",	"Host",		"Host Groups",	"selinux-hostgroup1",			"selinux-hostgroup2",			"Add",		"Add"		 } ));
			ll.add(Arrays.asList(new Object[]{ 	"add_hostgroup_selinuxusermap_cancel",	"selinux_rule2",	"Host",		"Host Groups",	"selinux-hostgroup3",			"",								"Add",		"Cancel"	 } ));	
			ll.add(Arrays.asList(new Object[]{ 	"add_hostgroup_selinuxusermap_all",		"selinux_rule2",	"Host",		"Host Groups",	"",								"",								"All", 		"Update"	 } ));
		
			return ll;	
		}
		
		/*
		 * Data to be used for single delete of selinux user map 
		 */
		@DataProvider(name="getSelinuxUserMapDisabledHBACRuleTestObjects")
		public Object[][] getSelinuxUserMapDisabledHBACRuleTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapDisabledHBACRuleTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapDisabledHBACRuleTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname									hbacrule				rulename								
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_disabledhbacrule",	"selinux_hbacrule2",	"selinux_rule7"	 } ));
			
			return ll;	
		}
		
		/*
		 * Data to be used for negative selinux user map 
		 */
		@DataProvider(name="getAddNegativeSelinuxUserMapTestObjects")
		public Object[][] getAddNegativeSelinuxUserMapTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapAddNegativeTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapAddNegativeTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname								rulename															selinuxuser				errorMsg							
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_requiredfield",			"",																	"",						"Required field"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_duplicate",				"selinux_rule1",													selinuxdefaultuser,		"SELinux User Map rule with name \"selinux_rule1\" already exists"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_duplicaterule",			"selinux_rule1",													selinuxusers[0],		"SELinux User Map rule with name \"selinux_rule1\" already exists"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_nonexistinguser",		"selinux_rule6",													"abc:s0",				"SELinux user abc:s0 not found in ordering list (in config)"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_invalidusersyntaxMCS",	"selinux_rule6",													"user:s0:c",			"invalid 'selinuxuser': Invalid MCS value, must match c[0-1023].c[0-1023] and/or c[0-1023]-c[0-c0123]"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_invalidusersyntaxMLS",	"selinux_rule6",													"user",					"invalid 'selinuxuser': Invalid MLS value, must match s[0-15](-s[0-15])"	 } ));
			
			//https://fedorahosted.org/freeipa/ticket/2985
			//ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_special_tkt2985",		"selinux_rule@",													selinuxusers[0],		"may only incude letters, numbers, _, -, . and $"	 } ));
			//ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_long_tkt2985",			"selinuxruleveryveryveryveryveryveryveryveryveryverylongname",		selinuxusers[0],		"invalid 'selinuxusermap': can be at most 32 characters"	 } ));
			return ll;	
		}
		
		/*
		 * Data to be used for negative selinux user map 
		 */
		@DataProvider(name="getSelinuxUserMapDeleteNegativeHBACRuleTestObjects")
		public Object[][] getSelinuxUserMapDeleteNegativeHBACRuleTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapDeleteNegativeTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapDeleteNegativeTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname									hbacrule					rulename							
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_deleteNegativeHBACrule",	"selinux_hbacrule1",		"selinux_rule3"			 } ));
			
			return ll;	
		}
		/*
		 * Data to be used for negative selinux user map 
		 */
		@DataProvider(name="getSelinuxUserMapMembersNegativeTestObjects")
		public Object[][] getSelinuxUserMapMembersNegativeTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapMembersNegativeTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapMembersNegativeTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//									testName							cn		 			section			type			name			button		action	errorMsg						
			ll.add(Arrays.asList(new Object[]{ 	"add_usernegative_selinuxusermap",	"selinux_rule3",	"User",			"Users",		"selinux-user1","Add",		"Add",	"HBAC rule and local members cannot both be set"			 } ));
			
			return ll;	
		}
		/*
		 * Data to be used for negative selinux user map 
		 */
		@DataProvider(name="getSelinuxUserMapHBACRuleNegativeTestObjects")
		public Object[][] getSelinuxUserMapHBACRuleNegativeTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapHBACRuleNegativeTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapHBACRuleNegativeTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname									hbacrule					rulename			errorMsg				
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_addNegativeHBACrule",		"selinux_hbacrule1",		"selinux_rule2",	"HBAC rule and local members cannot both be set"		 } ));
			
			return ll;	
		}
		
		
		/*
		 * Data to be used for negative selinux user map 
		 */
		@DataProvider(name="getSelinuxUserMapSearchTestObjects")
		public Object[][] getSelinuxUserMapSearchTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapSearchTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapSearchTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname						rulename						
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_search",		"selinux_rule2"	 } ));
			
			return ll;	
		}
		
		/*
		 * Data to be used for negative search selinux user map 
		 */
		@DataProvider(name="getSelinuxUserMapSearchNegativeTestObjects")
		public Object[][] getSelinuxUserMapSearchNegativeTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapSearchNegativeTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapSearchNegativeTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname							rulename						
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_searchnegative",	"selinux_rule$"	 } ));
			
			return ll;	
		}
		
		
		/*
		 * Data to be used for negative search selinux user map 
		 */
		@DataProvider(name="getSelinuxUserMapMemberCategoryTestObjects")
		public Object[][] getSelinuxUserMapMemberCategoryTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapMemberCategoryTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapMemberCategoryTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname								rulename			user				host					
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_membercategoryupdate",	"selinux_rule2",	"selinux-user2",	"selinux-host1.testrelm.com"	 } ));
			
			return ll;	
		}
		
		/*
		 * Data to be used for negative selinux user 
		 */
		@DataProvider(name="getSelinuxUserMapNegativeSelinuxUserTestObjects")
		public Object[][] getSelinuxUserMapNegativeSelinuxUserTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapNegativeSelinuxUserTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapNegativeSelinuxUserTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname							rulename			user																			
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_extratext_tkt3119",	"selinux_rule12",	"xguest_u:s5-s1:c0-c4.c4,c4:-Why is stuff allowed here?"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_outofrange_tkt3119","selinux_rule13",	"xguest_u:s92:c99999999,c0"	 } ));
			
			return ll;	
		}
		
		/*
		 * Data to be used for modify selinux user 
		 */
		@DataProvider(name="getSelinuxUserMapModifyNegativeSelinuxUserTestObjects")
		public Object[][] getSelinuxUserMapModifyNegativeSelinuxUserTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapModifyNegativeSelinuxUserTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapModifyNegativeSelinuxUserTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname							rulename			user																			
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_modifyuser_tkt3119","selinux_rule14",	"user_u:s0"	 } ));
			
			return ll;	
		}
		
		/*
		 * Data to be used for modify selinux user 
		 */
		@DataProvider(name="getselinuxUserMapEnableDisableMultipleTestObjects")
		public Object[][] getselinuxUserMapEnableDisableMultipleTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createselinuxUserMapEnableDisableMultipleTestObjects());
		}
		protected List<List<Object>> createselinuxUserMapEnableDisableMultipleTestObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
		
			//										testname								rulename1			rulename2			action																			
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_disablemultiple",	"selinux_rule2",	"selinux_rule3",	"Disable"	 } ));
			ll.add(Arrays.asList(new Object[]{ 		"selinuxusermap_enablemultiple",	"selinux_rule2",	"selinux_rule3",	"Enable"	 } ));
			return ll;	
		}
}
