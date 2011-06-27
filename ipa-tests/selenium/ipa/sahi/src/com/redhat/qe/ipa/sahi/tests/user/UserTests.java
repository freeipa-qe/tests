package com.redhat.qe.ipa.sahi.tests.user;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

public class UserTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(UserTests.class.getName());
	public static SahiTasks sahiTasks = null;	
	private String userPage = "/ipa/ui/#identity=user&navigation=identity";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+userPage, true);
	}
	

	/*
	 * Add users - for positive tests
	 */
	@Test (groups={"userAddTests"}, dataProvider="getUserTestObjects")	
	public void testUseradd(String testName, String uid, String givenname, String sn) throws Exception {
		//verify user doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(uid).exists(), "Verify user " + uid + " doesn't already exist");
		
		//new test user can be added now
		UserTasks.createUser(sahiTasks, uid, givenname, sn);		
		
		//verify user was added successfully
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Added user " + uid + "  successfully");
	}
	
	
	
	
	/*
	 * Edit users - for positive tests
	 */
	@Test (groups={"userEditTests"}, dataProvider="getUserEditTestObjects", dependsOnGroups="userAddTests")	
	public void testUserEdit(String testName, String uid, String title, String mail) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		//modify this user
		UserTasks.modifyUser(sahiTasks, uid, title, mail);
		
		//TODO: verify changes	
		UserTasks.verifyUserUpdates(sahiTasks, uid, title, mail);
	}
	
	/*
	 * Readd users - for negative tests
	 */
	@Test (groups={"userReaddTests"}, dataProvider="getUserReaddTestObjects", dependsOnGroups={"userAddTests","userEditTests"})	
	public void testUserReadd(String testName, String uid, String givenname, String sn) throws Exception {
		//verify user exists already
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + "  to be readded exists");
		
		//add repeat test user 
		UserTasks.recreateUser(sahiTasks, uid, givenname, sn);		
		
	}
	
	/*
	 * Delete users - one at a time - for positive tests
	 */
	@Test (groups={"userDeleteTests"}, dataProvider="getUserDeleteTestObjects", dependsOnGroups={"userAddTests","userReaddTests"})	
	public void testUserDelete(String testName, String uid) throws Exception {
		//verify user to be deleted exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + "  to be deleted exists");
		
		//modify this user
		UserTasks.deleteUser(sahiTasks, uid);
		
		//verify user is deleted
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(uid).exists(), "User " + uid + "  deleted successfully");
	}
	
	
	/*
	 * Delete multiple users - for positive tests
	 */
	@Test (groups={"chooseUserMultipleDeleteTests"}, dataProvider="getMultipleUserDeleteTestObjects", dependsOnGroups={"userAddTests","userReaddTests"})
	public void setMultipleUserDelete(String testName, String uid) throws Exception {		
		//verify user to be deleted exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + "  to be deleted exists");	
		
		//mark this user for deletion
		UserTasks.chooseMultipleUsers(sahiTasks, uid);		
	}
	
	@Test (groups={"userMultipleDeleteTests"}, dependsOnGroups="chooseUserMultipleDeleteTests")
	public void testMultipleUserDelete() throws Exception {		
		//delete the multiple chosen users
		UserTasks.deleteMultipleUser(sahiTasks);	
	}
	
	
	/*
	 * Data to be used when adding users
	 */
	@DataProvider(name="getUserTestObjects")
	public Object[][] getUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserTestObjects());
	}
	protected List<List<Object>> createUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//String sLongName = "auto_" + tasks.generateRandomString(251);
		
        //										testname					uid              		givenname	sn   
		ll.add(Arrays.asList(new Object[]{ "create_good_user",				"testuser", 			"Test",		"User"      } ));
		ll.add(Arrays.asList(new Object[]{ "create_user2",				    "user2", 			    "Test2",	"User2"     } ));
		ll.add(Arrays.asList(new Object[]{ "create_user3",				    "user3", 			    "Test3",	"User3"     } ));
		ll.add(Arrays.asList(new Object[]{ "create_user4",				    "user4", 			    "Test4",	"User4"     } ));
		ll.add(Arrays.asList(new Object[]{ "create_user5",				    "user5", 			    "Test5",	"User5"     } ));
		ll.add(Arrays.asList(new Object[]{ "create_user6",				    "user6", 			    "Test6",	"User6"     } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when readding users
	 */
	@DataProvider(name="getUserReaddTestObjects")
	public Object[][] getUserReaddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(recreateUserTestObjects());
	}
	protected List<List<Object>> recreateUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					uid              		givenname	sn   
		ll.add(Arrays.asList(new Object[]{ "create_good_user",				"testuser", 			"Test",		"User"     } ));
		
		        
		return ll;	
	}
	
	
	/*
	 * Data to be used when editing users
	 */
	@DataProvider(name="getUserEditTestObjects")
	public Object[][] getUserEditTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editUserTestObjects());
	}
	protected List<List<Object>> editUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//String sLongName = "auto_" + tasks.generateRandomString(251);
		
        //										testname					uid              		title					mail   
		ll.add(Arrays.asList(new Object[]{ "edit_good_user",				"testuser", 			"Software Engineer",	"testuser@example.com"     } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when deleting users
	 */
	@DataProvider(name="getUserDeleteTestObjects")
	public Object[][] getUserDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteUserTestObjects());
	}
	protected List<List<Object>> deleteUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					uid              		
		ll.add(Arrays.asList(new Object[]{ "delete_good_user",				"testuser"     } ));
		ll.add(Arrays.asList(new Object[]{ "delete_good_user",				"user2"     } ));
		ll.add(Arrays.asList(new Object[]{ "delete_good_user",				"user3"     } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when deleting multiple users
	 */
	@DataProvider(name="getMultipleUserDeleteTestObjects")
	public Object[][] getMultipleUserDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteMultipleUserTestObjects());
	}
	protected List<List<Object>> deleteMultipleUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();		
		
        //										testname					uid              		
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_users",			"user4"     } ));
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_users",			"user5"     } ));
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_users",			"user6"     } ));
		
		return ll;	
	}
	

}
