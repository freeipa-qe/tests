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
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
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
	 * Add users - for negative tests
	 */
	@Test (groups={"invalidUserAddTests"}, dataProvider="getInvalidUserTestObjects",  dependsOnGroups="userAddTests")	
	public void testInvalidUseradd(String testName, String uid, String givenname, String sn, String expectedError) throws Exception {
		//new test user can be added now
		UserTasks.createInvalidUser(sahiTasks, uid, givenname, sn, expectedError);		
	}
	
	/*
	 * Add users with invalid chars - for negative tests
	 * Separate from above because - the error is not in a message box, but is indicated 
	 * in red, as soon as an invalid char is typed into the textbox
	 */
	@Test (groups={"invalidCharUserAddTests"}, dataProvider="getInvalidCharUserTestObjects")	
	public void testInvalidCharUseradd(String testName, String uid, String givenname, String sn, String expectedError) throws Exception {
		//new test user can be added now
		UserTasks.createInvalidCharUser(sahiTasks, uid, givenname, sn, expectedError);		
	}
	
	
	/*
	 * Edit users - for positive tests
	 */
	@Test (groups={"userEditTests"}, dataProvider="getUserEditTestObjects", dependsOnGroups={"userAddTests"})	
	public void testUserEdit(String testName, String uid, String title, String mail) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		//modify this user
		UserTasks.modifyUser(sahiTasks, uid, title, mail);
		
		//verify changes	
		UserTasks.verifyUserUpdates(sahiTasks, uid, title, mail);
	}
	
	/*
	 * Set user's password - for positive tests
	 */
	@Test (groups={"userSetPasswordTests"}, dataProvider="getUserSetPasswordTestObjects", dependsOnGroups={"userAddTests"})	
	public void testUserSetPassword(String testName, String uid, String password, String newPassword) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		//modify this user
		UserTasks.modifyUserPassword(sahiTasks, uid, password);
		
		//verify changes	
		com.redhat.qe.auto.testng.Assert.assertTrue(CommonTasks.kinitAsNewUserFirstTime(uid, password, newPassword), "Logged in and reset password for " + uid);
		
		// kinit back as admin to continue tests
		com.redhat.qe.auto.testng.Assert.assertTrue(CommonTasks.kinitAsAdmin(), "Logged back in as admin to continue tests");
	}

	/*
	 * Deactivate users - for positive tests
	 */
	@Test (groups={"userDeactivateTests"}, dataProvider="getUserStatusTestObjects", dependsOnGroups={"userAddTests", "userSetPasswordTests"})	
	public void testUserDeactivate(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be deactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, true);
		
		//modify this user
		UserTasks.modifyUserStatus(sahiTasks, uid, false);
		
		//verify changes to status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		// verify user cannot kinit
		com.redhat.qe.auto.testng.Assert.assertFalse(CommonTasks.kinitAsUser(uid, password), "Verify " + uid + " cannot kinit");
		
		
	}
	
	/*
	 * Reactivate users - for positive tests
	 */
	@Test (groups={"userReactivateTests"}, dataProvider="getUserStatusTestObjects", dependsOnGroups={"userAddTests", "userDeactivateTests", "userSetPasswordTests"})	
	public void testUserReactivate(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be deactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		
		//modify this user
		UserTasks.modifyUserStatus(sahiTasks, uid, true);
		
		//verify changes to status	
		UserTasks.verifyUserStatus(sahiTasks, uid, true);
		// verify user can kinit
		com.redhat.qe.auto.testng.Assert.assertTrue(CommonTasks.kinitAsUser(uid, password), "Verify " + uid + " can kinit");
		
		// kinit back as admin to continue tests
		com.redhat.qe.auto.testng.Assert.assertTrue(CommonTasks.kinitAsAdmin(), "Logged back in as admin to continue tests");
	}
	
	/*
	 * Delete users - one at a time - for positive tests
	 * note: make sure tests that use testuser are run before testuser gets deleted here
	 */
	@Test (groups={"userDeleteTests"}, dataProvider="getUserDeleteTestObjects", 
			dependsOnGroups={"userAddTests", "userEditTests", "userSetPasswordTests", "userDeactivateTests", "userReactivateTests", "invalidUserAddTests"})	
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
	@Test (groups={"chooseUserMultipleDeleteTests"}, dataProvider="getMultipleUserDeleteTestObjects", dependsOnGroups={"userAddTests", "invalidUserAddTests"})
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
	
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding users - for positive cases
	 */
	@DataProvider(name="getUserTestObjects")
	public Object[][] getUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserTestObjects());
	}
	protected List<List<Object>> createUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
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
	 * Data to be used when adding users - for negative cases
	 */
	@DataProvider(name="getInvalidUserTestObjects")
	public Object[][] getInvalidUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidUserTestObjects());
	}
	protected List<List<Object>> createInvalidUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname		uid										givenname	sn   		 ExpectedError
		
		ll.add(Arrays.asList(new Object[]{ "create_long_user",	"abcdefghijklmnopqrstuvwxyx12345678", 	"Long",		"User",      "invalid 'login': can be at most 32 characters"	} ));
		ll.add(Arrays.asList(new Object[]{ "recreate_user",		"testuser", 							"Test",		"User",		 "user with name \"testuser\" already exists"	} ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding users - for negative cases
	 */
	@DataProvider(name="getInvalidCharUserTestObjects")
	public Object[][] getInvalidCharUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidCharUserTestObjects());
	}
	protected List<List<Object>> createInvalidCharUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname		uid										givenname	sn   		 ExpectedError
		
		ll.add(Arrays.asList(new Object[]{ "invalid_char_#",	"abcd#", 								"Test",		"User",		 "may only include letters, numbers, _, -, . and $"	} ));
		ll.add(Arrays.asList(new Object[]{ "invalid_char_@",	"abcd@", 								"Test",		"User",		 "may only include letters, numbers, _, -, . and $"	} ));
		ll.add(Arrays.asList(new Object[]{ "invalid_char_*",	"abcd*", 								"Test",		"User",		 "may only include letters, numbers, _, -, . and $"	} ));
		ll.add(Arrays.asList(new Object[]{ "invalid_char_?",	"abcd?", 								"Test",		"User",		 "may only include letters, numbers, _, -, . and $"	} ));
		
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
		
        //										testname					uid              		title					mail   
		ll.add(Arrays.asList(new Object[]{ "edit_good_user",				"testuser", 			"Software Engineer",	"testuser@example.com"     } ));
		        
		return ll;	
	}
	
	
	/*
	 * Data to be used when setting password for user
	 */
	@DataProvider(name="getUserSetPasswordTestObjects")
	public Object[][] getUserSetPasswordTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(setUserPasswordTestObjects());
	}
	protected List<List<Object>> setUserPasswordTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					uid				password		newpassword   
		ll.add(Arrays.asList(new Object[]{ "set_user_password",				"testuser",  	"testuser",		"Secret123"   } ));
		        
		return ll;	
	}
	
	
	
	/*
	 * Data to be used when deactivating user
	 */
	@DataProvider(name="getUserStatusTestObjects")
	public Object[][] getUserStatusTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editStatusUserTestObjects());
	}
	protected List<List<Object>> editStatusUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					     uid			password              		
		ll.add(Arrays.asList(new Object[]{ "deactivate_test_user",				"testuser",		"Secret123"     } ));
		        
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
