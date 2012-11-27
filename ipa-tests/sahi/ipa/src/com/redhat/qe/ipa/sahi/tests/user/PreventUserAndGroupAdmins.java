package com.redhat.qe.ipa.sahi.tests.user;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
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
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

public class PreventUserAndGroupAdmins extends SahiTestScript{
	private static Logger log = Logger.getLogger(UserTests.class.getName());
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException
{
		sahiTasks.navigateTo(commonTasks.userPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&user-facet=search" ;
	
		// adding users to check bug-805233 (Prevent deletion of the last admin)
		
		sahiTasks.navigateTo(commonTasks.userPage, true);
		String testUser="testusers";
		for (int i=1; i<4; i++) 
		{
			if (!sahiTasks.link(testUser+i).exists())
				UserTasks.createUser(sahiTasks, testUser+i, testUser+i, testUser+i, "Add");
		}
}

	@Test (groups={"preventUsersAdmin_Bz846309"},dataProvider="getUserTestObjects")	
	public void testUsersAdmin(String testName, String uid, String expectedMsg) throws Exception {
		sahiTasks.navigateTo(commonTasks.userPage, true);
		//  trying to disable identity-User's admin, should throws an error.
		UserTasks.disableUsersAdmin(sahiTasks, uid);
		UserTasks.preventAdmin(sahiTasks,uid, expectedMsg);
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify " + uid + "  was not didabled");
		// trying to delete identity-User's admin, should throws an error.
		UserTasks.deleteUser(sahiTasks, uid);
		UserTasks.preventAdmin(sahiTasks,uid, expectedMsg);
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify " + uid + "  was not deleted");
	}
	
	
	@Test (groups={"preventGroupAdmin_Bz805233"},dataProvider="getGroupTestObjects")	
	public void testGroupssAdmin(String testName,String uid, String groupName, String expectedMsg,String expectedMsg2) throws Exception {
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		// trying to delete identity-UsersGroup admins, should throws an error.
		GroupTasks.deleteGroup(sahiTasks, groupName);
		UserTasks.preventAdmin(sahiTasks,groupName, expectedMsg);
		Assert.assertTrue(sahiTasks.link(groupName).exists(), "Verify group " + groupName + "  was not deleted");
		//trying to remove all members at once , should throws an error.
		UserTasks.deleteGroupAndMember(sahiTasks,uid,groupName ,expectedMsg,expectedMsg2);
	}
	
	
	
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException {
		
		//clean users and rules added
		sahiTasks.navigateTo(commonTasks.userPage, true);
		String testUser="testusers";
		for (int i=1; i<4; i++) {
			if (sahiTasks.link(testUser+i).exists())
				UserTasks.deleteUser(sahiTasks, testUser+i);
		}	
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	@DataProvider(name="getUserTestObjects")
	public Object[][] getUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserTestObjects());
	}
	protected List<List<Object>> createUserTestObjects() {			
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					                 uid    	   	expectedMsg		       		
		ll.add(Arrays.asList(new Object[]{ "prevent_disabling_admin_Bz846309 ",				"admin",	"admin cannot be deleted or disabled because it is the last member of group admins"		} ));
		  
		return ll;	
	}
	
	
	
	@DataProvider(name="getGroupTestObjects")
	public Object[][] getGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createGroupTestObjects());
	}
	protected List<List<Object>> createGroupTestObjects() {			
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					                uid   groupName    	   	expectedMsg1		       		                               expectedMsg2
		ll.add(Arrays.asList(new Object[]{ "Prevent_deletion_of_the_last_admin_Bz805233",  "admin","admins",	"group admins cannot be deleted/modified: privileged group", "admin cannot be deleted or disabled because it is the last member of group admins"		} ));
		  
		return ll;	
	}
	
	
	
	

}


	//"preventUserAdmin_Bz846309"
		
		

