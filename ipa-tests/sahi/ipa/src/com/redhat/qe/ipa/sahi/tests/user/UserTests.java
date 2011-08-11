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
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.userPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
	}
	

	/*
	 * Add users - for positive tests
	 */
	@Test (groups={"userAddTests"}, dataProvider="getUserTestObjects")	
	public void testUseradd(String testName, String uid, String givenname, String sn) throws Exception {
		String expectedUID=uid;
		if (uid.length() == 0) {
			expectedUID=(givenname.substring(0,1)+sn).toLowerCase();
			log.fine("ExpectedUID: " + expectedUID);
		}
		
		//verify user doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(expectedUID).exists(), "Verify user " + expectedUID + " doesn't already exist");
		
		//new test user can be added now
		UserTasks.createUser(sahiTasks, uid, givenname, sn, "Add");		
		
		//verify user was added successfully
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(expectedUID).exists(), "Added user " + expectedUID + "  successfully");
	}
	
	/*
	 * Add users - for positive tests
	 */
	@Test (groups={"userCancelAddTests"}, dataProvider="getSingleUserTestObjects")	
	public void testUserCancelAdd(String testName, String uid, String givenname, String sn) throws Exception {
		//verify user doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(uid).exists(), "Verify user " + uid + " doesn't already exist");
		
		//new test user can be added now
		UserTasks.createUser(sahiTasks, uid, givenname, sn, "Cancel");		
		
		//verify user was added successfully
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(uid).exists(), "Verify user " + uid + "  was not added");
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
	 * Edit users to add multiple data for Contact - for positive tests
	 */
	@Test (groups={"userMultipleDataTests"}, dataProvider="getUserMultipleDataTestObjects", dependsOnGroups={"userAddTests", "userEditTests"})	
	public void testUserAddMultipleData(String testName, String uid, String mail1, String mail2, String	mail3, 
			String phone1, String phone2, String pager1, String pager2, String mobile1, String mobile2, 
			String fax1, String fax2) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		//modify this user
		UserTasks.addMultipleUserData(sahiTasks, uid, mail1, mail2, mail3, phone1, phone2, pager1, pager2, mobile1, mobile2, fax1, fax2);
		
		//verify changes	
		UserTasks.verifyUserContactData(sahiTasks, uid, mail3, mail2, mail1, phone1, phone2, pager1, pager2, mobile1, mobile2, fax1, fax2);
	}
	
	@Test (groups={"userAddDeleteUndoResetTests"}, dataProvider="getUserMultipleDataTestObjects", dependsOnGroups={"userAddTests", "userEditTests", "userMultipleDataTests"})	
	public void testUserAddDeleteUndoReset(String testName, String uid, String mail1, String mail2, String	mail3, 
			String phone1, String phone2, String pager1, String pager2, String mobile1, String mobile2, 
			String fax1, String fax2) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		//Add, Delete, Undo and Reset Contact Data
		UserTasks.addDeleteUndoResetContactData(sahiTasks, uid, mail1, phone1);
		
		//verify nothing changed	
		UserTasks.verifyUserContactData(sahiTasks, uid, mail3, mail2, mail1, phone1, phone2, pager1, pager2, mobile1, mobile2, fax1, fax2);
	}
	
	/*
	 * Update Identity Settings
	 */
	@Test (groups={"userEditIdentitySettingsTests"}, dataProvider="getUserEditIdentitySettingsTestObjects", dependsOnGroups={"userAddTests"})	
	public void testUserEditIdentitySettings(String testName, String uid, String givenname, String sn, String fullname, String displayName, String initials) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		//modify this user
		UserTasks.modifyUserIdentitySettings(sahiTasks, uid, givenname, sn, fullname, displayName, initials);
		
		//verify changes	
		UserTasks.verifyUserIdentitySettings(sahiTasks, uid, givenname, sn, fullname, displayName, initials);
	}
	
	
	/*
	 * Update Account Settings
	 */
	@Test (groups={"userEditAccountSettingsTests"}, dataProvider="getUserEditAccountSettingsTestObjects", dependsOnGroups={"userAddTests"})	
	public void testUserEditAccountSettings(String testName, String uid, String uidnumber, String gidnumber, String loginshell, String homedirectory) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		String invalidUID = "-1";
		String expectedError = "Minimum value is 1";
		UserTasks.modifyUserAccountSettingsForInvalidUID(sahiTasks, uid, invalidUID, expectedError);
		
		//modify this user
		UserTasks.modifyUserAccountSettings(sahiTasks, uid, uidnumber, gidnumber, loginshell, homedirectory);
		
		//verify changes	
		UserTasks.verifyUserAccountSettings(sahiTasks, uid, uidnumber, gidnumber, loginshell, homedirectory);
	}

	/*
	 * Update Mailing Address
	 */
	@Test (groups={"userEditMailingAddressTests"}, dataProvider="getUserEditMailingAddressTestObjects", dependsOnGroups={"userAddTests"})	
	public void testUserEditMailingAddress(String testName, String uid, String street, String city, String state, String zip) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
			
		//modify this user
		UserTasks.modifyUserMailingAddress(sahiTasks, uid, street, city, state, zip);
		
		//verify changes	
		UserTasks.verifyUserMailingAddress(sahiTasks, uid, street, city, state, zip);
	}
	
	/*
	 * Update Employee & Misc Info
	 */
	@Test (groups={"userEditEmpMiscInfoTests"}, dataProvider="getUserEditEmpMiscInfoTestObjects", dependsOnGroups={"userAddTests"})	
	public void testUserEditEmpMiscInfo(String testName, String uid, String org, String manager, String carlicense) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
			
		//modify this user
		UserTasks.modifyUserEmpMiscInfo(sahiTasks, uid, org, manager, carlicense);
		
		//verify changes	
		UserTasks.verifyUserEmpMiscInfo(sahiTasks, uid, org, manager, carlicense);
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
	 * Cancel when deactivating users - for positive tests
	 */
	@Test (groups={"userCancelDeactivateTests"}, dataProvider="getUserStatusTestObjects", dependsOnGroups={"userAddTests", "userSetPasswordTests"})	
	public void testUserCancelDeactivate(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be deactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, true);
		
		//modify this user
		UserTasks.modifyUserStatus(sahiTasks, uid, false, "Cancel");
		
		//verify status	
		UserTasks.verifyUserStatus(sahiTasks, uid, true);
		// verify user can still kinit
		com.redhat.qe.auto.testng.Assert.assertTrue(CommonTasks.kinitAsUser(uid, password), "Verify " + uid + " can still kinit");
		
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
		UserTasks.modifyUserStatus(sahiTasks, uid, false, "Deactivate");
		
		//verify changes to status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		// verify user cannot kinit
		com.redhat.qe.auto.testng.Assert.assertFalse(CommonTasks.kinitAsUser(uid, password), "Verify " + uid + " cannot kinit");
		
		
	}
	
	/*
	 * Cancel when reactivating users - for positive tests
	 */
	@Test (groups={"userCancelReactivateTests"}, dataProvider="getUserStatusTestObjects", dependsOnGroups={"userAddTests", "userDeactivateTests", "userSetPasswordTests"})	
	public void testUserCancelReactivate(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be reactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		
		//modify this user
		UserTasks.modifyUserStatus(sahiTasks, uid, true, "Cancel");
		
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
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be reactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		
		//modify this user
		UserTasks.modifyUserStatus(sahiTasks, uid, true, "Activate");
		
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
			dependsOnGroups={"userAddTests", "userEditTests", "userSetPasswordTests", "userDeactivateTests", "userReactivateTests", "invalidUserAddTests", "userSearchTests"})	
	public void testUserDelete(String testName, String uid) throws Exception {
		//verify user to be deleted exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + "  to be deleted exists");
		
		//modify this user
		UserTasks.deleteUser(sahiTasks, uid);
		
		//verify user is deleted
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(uid).exists(), "User " + uid + "  deleted successfully");
	}
	
	// TODO: Nkrishnan: Add test for Delete - but cancel
	
	
	/*
	 * Delete multiple users - for positive tests
	 */
	@Test (groups={"chooseUserMultipleDeleteTests"}, dataProvider="getMultipleUserDeleteTestObjects", dependsOnGroups={"userAddTests", "invalidUserAddTests", "userAddAndEditTests", "userAddAndAddAnotherTests",
			"userEditIdentitySettingsTests", "userEditAccountSettingsTests", "userEditMailingAddressTests", "userEditEmpMiscInfoTests", "userSearchTests" })
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
	 * Add and Add another user
	 */
	@Test (groups={"userAddAndAddAnotherTests"}, dataProvider="getUserAddAndAddAnotherTestObjects")	
	public void testUserAddAndAddAnother(String testName, String givenname1, String sn1, String givenname2, String sn2) throws Exception {
		String expectedUID1=(givenname1.substring(0,1)+sn1).toLowerCase();
		String expectedUID2=(givenname2.substring(0,1)+sn2).toLowerCase();
		log.fine("ExpectedUID1: " + expectedUID1 + " and ExpectedUID2: " + expectedUID2);		
		
		//verify users don't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(expectedUID1).exists(), "Verify user " + expectedUID1 + " doesn't already exist");
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(expectedUID2).exists(), "Verify user " + expectedUID2 + " doesn't already exist");
		
		//new test user can be added now
		UserTasks.createUserThenAddAnother(sahiTasks, givenname1, sn1, givenname2, sn2);				
		
		//verify users were added successfully
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(expectedUID1).exists(), "Added user " + expectedUID1 + "  successfully");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(expectedUID2).exists(), "Added user " + expectedUID2 + "  successfully");
	}
	
	
	/*
	 * Add and Edit user
	 */
	@Test (groups={"userAddAndEditTests"}, dataProvider="getUserAddAndEditTestObjects",  dependsOnGroups="userAddTests")	
	public void testUserAddAndEdit(String testName, String uid, String givenname, String sn, String title, String mail) throws Exception {
		
		//verify users don't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(uid).exists(), "Verify user " + uid + " doesn't already exist");
		
		//new test user can be added now
		UserTasks.createUserThenEdit(sahiTasks, uid, givenname, sn, title, mail);				
		
		//verify changes	
		UserTasks.verifyUserUpdates(sahiTasks, uid, title, mail);
	}
	
		
	/*
	 * Search
	 */
	@Test (groups={"userSearchTests"}, dataProvider="getUserSearchTestObjects",  dependsOnGroups="userAddTests")
	public void testUserSearch(String testName, String uid, String multipleResult) throws Exception {
		
		UserTasks.searchUser(sahiTasks, uid);
		
		//verify users was found
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(uid).exists(), "Searched and found user " + uid + "  successfully");
		if (!multipleResult.equals(""))
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(multipleResult).exists(), "Searched and found another user " + multipleResult + "  successfully");
		
		UserTasks.clearSearch(sahiTasks);
	}
	
	
	/*
	 * Expand/Collapse
	 */	
	@Test (groups={"userExpandCollapseTests"}, dataProvider="getUserExpandCollapseTestObjects",  dependsOnGroups="userAddTests")
	public void testUserExpandCollapse(String testName, String uid) throws Exception {
		
		UserTasks.expandCollapseUser(sahiTasks, uid);		
		
	}
	
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding users - for positive cases
	 */
	@DataProvider(name="getSingleUserTestObjects")
	public Object[][] getSingleUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSingleUserTestObjects());
	}
	protected List<List<Object>> createSingleUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					uid              	givenname		sn   
		ll.add(Arrays.asList(new Object[]{ "create_single_user",				"user1", 			"Test1",		"User1"      } ));
		
		return ll;	
	}
	
	@DataProvider(name="getUserTestObjects")
	public Object[][] getUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserTestObjects());
	}
	protected List<List<Object>> createUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					uid              		givenname	sn   
		ll.add(Arrays.asList(new Object[]{ "create_good_user",				"testuser", 			"Test",		"User"      } ));
		ll.add(Arrays.asList(new Object[]{ "create_user_with_optional_login","", 					"Test",		"User"      } ));
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
		
        //										testname						uid										givenname	sn   		 ExpectedError
		
		ll.add(Arrays.asList(new Object[]{ "create_long_user",					"abcdefghijklmnopqrstuvwxyx12345678", 	"Long",		"User",      "invalid 'login': can be at most 32 characters"	} ));
		ll.add(Arrays.asList(new Object[]{ "recreate_user",						"testuser", 							"Test",		"User",		 "user with name \"testuser\" already exists"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_user_with_optional_login",	"", 									"Testing",	"User",		 "user with name \"tuser\" already exists"	} ));
		
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
	 * Data to be used when adding multiple Contact infor for users
	 */
	@DataProvider(name="getUserMultipleDataTestObjects")
	public Object[][] getUserMultipleDataTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(addUserMultipleDataTestObjects());
	}
	protected List<List<Object>> addUserMultipleDataTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					uid              		mail1			mail2			mail3 				phone1		phone2  		pager1		pager2			mobile1		mobile2			fax1		fax2
		ll.add(Arrays.asList(new Object[]{ "add_multiple_contactdata",		"testuser", 			"one@testrelm",	"two@testrelm", "three@testrelm",   "1234567", 	"7654321",		"9876543",	"3456789",		"135790",	"097531", 		"1122334", 	"4332211"	 } ));
		        
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
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_users",			"tuser"     } ));
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_users",			"user9"     } ));
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_users",			"tuser7"     } ));
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_users",			"tuser8"     } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding and then adding users again
	 */
	@DataProvider(name="getUserAddAndAddAnotherTestObjects")
	public Object[][] getUserAddAndAddAnotherTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserAndAddAnotherTestObjects());
	}
	protected List<List<Object>> createUserAndAddAnotherTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					givenname1		sn1			givenname2		sn2   
		ll.add(Arrays.asList(new Object[]{ "add_two_users",					"Test",			"User7",	"Test",			"User8"     } ));
		        
		return ll;	
	}
	
	
	/*
	 * Data to be used when editing users
	 */
	@DataProvider(name="getUserAddAndEditTestObjects")
	public Object[][] getUserAddAndEditTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(addAndEditUserTestObjects());
	}
	protected List<List<Object>> addAndEditUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			uid				givenname		sn			title					mail   
		ll.add(Arrays.asList(new Object[]{ "add_and_edit_user",		"user9",		"Test",			"User",		"Software Engineer",	"testuser@example.com"     } ));
		        
		return ll;	
	}
	
	
	/*
	 * Data to be used when searching for users
	 */
	@DataProvider(name="getUserSearchTestObjects")
	public Object[][] getUserSearchTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(searchUserTestObjects());
	}
	protected List<List<Object>> searchUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					uid       		multiple_result1	       		
		ll.add(Arrays.asList(new Object[]{ "search_good_user",				"testuser",		""    				} ));
		ll.add(Arrays.asList(new Object[]{ "search_good_user2",				"user2",		""	     			} ));
		ll.add(Arrays.asList(new Object[]{ "search_good_tuser",				"tuser",		"testuser"     		} ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when searching for users
	 */
	@DataProvider(name="getUserExpandCollapseTestObjects")
	public Object[][] getUserExpandCollapseTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(expandCollapseUserTestObjects());
	}
	protected List<List<Object>> expandCollapseUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					uid       			       		
		ll.add(Arrays.asList(new Object[]{ "expand_collapse_user",			"testuser"    				} ));
		  
		return ll;	
	}
	
	
	/*
	 * Data to be used when updating Identity Settings for users
	 */
	@DataProvider(name="getUserEditIdentitySettingsTestObjects")
	public Object[][] getUserEditIdentitySettingsTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editIdentitySettingsTestObjects());
	}
	protected List<List<Object>> editIdentitySettingsTestObjects() {			
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						uid    		givenname		sn				fullname			displayName		initials   			       		
		ll.add(Arrays.asList(new Object[]{ "identity_settings_user",			"tuser",	"Mickey",		"Mouse",		"Mickey Mouse",		"Mickey M.",	"MM"	  				} ));
		  
		return ll;	
	}
	
	
	/*
	 * Data to be used when updating Account Settings for users
	 */
	@DataProvider(name="getUserEditAccountSettingsTestObjects")
	public Object[][] getUserEditAccountSettingsTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editAccountSettingsTestObjects());
	}
	protected List<List<Object>> editAccountSettingsTestObjects() {			
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						uid    		uidnumber		gidnumber		loginshell		homedirectory   			       		
		ll.add(Arrays.asList(new Object[]{ "account_settings_user",				"tuser",	"123456789",	"987654321",	"/bin/csh",		"/home/newtuser"		} ));
		  
		return ll;	
	}
	
	/*
	 * Data to be used when updating Mailing Address for users
	 */
	@DataProvider(name="getUserEditMailingAddressTestObjects")
	public Object[][] getUserEditMailingAddressTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editMailingAddressTestObjects());
	}
	protected List<List<Object>> editMailingAddressTestObjects() {			
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						uid    		street					city			state		zip   			       		
		ll.add(Arrays.asList(new Object[]{ "account_settings_user",				"tuser",	"200 Broadway Ave",		"Bedford",		"MA",		"01730"		} ));
		  
		return ll;	
	}
	
	
	/*
	 * Data to be used when updating Mailing Address for users
	 */
	@DataProvider(name="getUserEditEmpMiscInfoTestObjects")
	public Object[][] getUserEditEmpMiscInfoTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editEmpMiscInfoTestObjects());
	}
	protected List<List<Object>> editEmpMiscInfoTestObjects() {			
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				uid    		org			manager			car  			       		
		ll.add(Arrays.asList(new Object[]{ "emp_misc_user",				"tuser",	"QE",		"testuser",		"012 ABC"		} ));
		  
		return ll;	
	}
	

}
