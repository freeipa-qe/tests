package com.redhat.qe.ipa.sahi.tests.automember;

import java.util.logging.Logger;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.AutomemberTasks;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.PermissionTasks;
import com.redhat.qe.ipa.sahi.tasks.RoleTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

public class Automember_Bug_Verification extends SahiTestScript {
	private static Logger log = Logger.getLogger(RoleTasks.class.getName());
	private String currentPage = "";
	private String alternateCurrentPage = "";

	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.setStrictVisibilityCheck(true);
		sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&privilege-facet=search" ;		
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.rolePage, true);
		}		
	}
	
	
	/*
	 * Bug 818258
	 */
	@Test (groups={"MissingSpecifiedName_Bug818258"}, description="Bug 818258 -Missing Specified Name In Error Msg", 
			dataProvider="MissingSpecifiedNameBug818258TestObjects")	
	
	public void testMissingSpecifiedName_Bug8182581(String groupName,String groupDescription,String gid,String groupType,String hostgroupName,String description) throws Exception {
	
	    //add a group
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		Assert.assertFalse(sahiTasks.link(groupName).exists(),"before 'Add', group does NOT exists");
		GroupTasks.add_UserGroup(sahiTasks, groupName, groupDescription, gid, groupType);
		Assert.assertTrue(sahiTasks.link(groupName).exists(),"after 'Add', group exists");
		//add and add another automember user group rule and verify the bug
		sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
		Assert.assertFalse(sahiTasks.link(groupName).exists(),"before 'Add', usergroup role does NOT exists");
		AutomemberTasks.automember_AddDuplicate(sahiTasks,groupName);
		Assert.assertTrue(sahiTasks.link(groupName).exists(),"after 'Add', usergroup role exists");
		//delete the rule
		sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
		Assert.assertTrue(sahiTasks.link(groupName).exists(),"before 'Delete', usergroup role exists");
		AutomemberTasks.automember_Delete(sahiTasks,groupName);
		Assert.assertFalse(sahiTasks.link(groupName).exists(),"after 'Delete', usergroup role does NOT exists");
		//delete the group
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		Assert.assertTrue(sahiTasks.link(groupName).exists(),"before 'Delete', usergroup exists");
		GroupTasks.deleteGroup(sahiTasks, groupName);
		Assert.assertFalse(sahiTasks.link(groupName).exists(),"after 'Delete', usergroup does NOT exists");
		
		//add a hostgroup
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		Assert.assertFalse(sahiTasks.link(hostgroupName).exists(),"before 'Add', hostgroup does NOT exists");
		HostgroupTasks.addHostGroup(sahiTasks, hostgroupName, description, "Add");
		Assert.assertTrue(sahiTasks.link(hostgroupName).exists(),"after 'Add', hostgroup exists");
		//add and add another automember hostgroup rule and verify the bug
		sahiTasks.navigateTo(commonTasks.automemberHostGroupPage, true);
		Assert.assertFalse(sahiTasks.link(hostgroupName).exists(),"before 'Add', hostgroup role does NOT exists");
		AutomemberTasks.automember_AddDuplicate(sahiTasks,hostgroupName);
		Assert.assertTrue(sahiTasks.link(hostgroupName).exists(),"after 'Add', hostgroup role exists");
		//delete the rule
		sahiTasks.navigateTo(commonTasks.automemberHostGroupPage, true);
		Assert.assertTrue(sahiTasks.link(hostgroupName).exists(),"before 'Delete', usergroup role exists");
		AutomemberTasks.automember_Delete(sahiTasks,hostgroupName);
		Assert.assertFalse(sahiTasks.link(hostgroupName).exists(),"after 'Delete', usergroup role does NOT exists");
		//delete the hostgroup
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		Assert.assertTrue(sahiTasks.link(hostgroupName).exists(),"before 'Delete', hostgroup exists");
		HostgroupTasks.deleteHostgroup(sahiTasks, hostgroupName,"Delete");
		Assert.assertFalse(sahiTasks.link(hostgroupName).exists(),"after 'Delete', hostgroup does NOT exists");
				
	}
	
	@DataProvider(name="MissingSpecifiedNameBug818258TestObjects")
    public Object[][] MissingSpecifiedNameBug818258TestObjects() {
            String[][] roles={
            //   groupName          groupDescription        gid   groupType      hostgroupName         description    
            {  "bug818258_grp",      "bug818258_grp",       "",   "normal" ,  "bug818258_hstgrp" ,  "bug818258_hstgrp" }
            };
            return roles;
    }
	
}
