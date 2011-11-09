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
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

/*
 * 
 * Review comments:
 * 1. In UserTests we can include positive tests for valid non-alphanumeric
chars such as _, -, . and $ in various position within uid. // done

2. In UserTests.userEditTests we could test emptying a text field and
deleting values from multivalued fields as well.// TODO: nkrishnan - add a test

3. In UserTests.userAddDeleteUndoResetTests we can verify that the
undo/reset does revert the fields before leaving the page.// TODO: nkrishnan - add a test

4. In UserTests' userEditIdentitySettingsTests,
testUserEditMailingAddress, and testUserEditEmpMiscInfo we can verify
that required fields are checked on update (i.e. missing required fields
will generate a validation error from the UI instead of error message
from the server).// TODO: nkrishnan - add a test

5. In UserTests.userSetPasswordTests we could test empty, invalid, or
mismatching passwords. We might also want to verify that the user will
see the self-service UI instead of the full admin UI.// TODO: nkrishnan - add a test

6. We could also test adding a user that has actually been added via
CLI. It should fail, but then automatically refresh the page to show the
user. Same thing for deleting a user.// TODO: nkrishnan - add a test

7. Similar to #6 but involving multiple users. The error dialog should
show the users that failed to be added/deleted.// TODO: nkrishnan - add a test

8. We might want to test the Select/Unselect All checkbox in various tables.// TODO: nkrishnan - add a test

9. In UserTests.userSearchTests we can test different filters, e.g.
searching using partial uid or last name.// TODO: nkrishnan - add a test

10. We can test adding/removing a user to/from another entity (i.e.
groups, netgroups, roles, hbac rules, and sudo rules) using the user's
member-of tabs.// TODO: nkrishnan - add a test
 */

public class UserTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(UserTests.class.getName());
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.navigateTo(commonTasks.userPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&user-facet=search" ;
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			//CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.userPage, true);
		}		
	}

	/*
	 * Add users - for positive tests
	 */
	@Test (groups={"userAddTests"}, description="Add valid users",
			dataProvider="getUserTestObjects")	
	public void testUseradd(String testName, String uid, String givenname, String sn) throws Exception {
		String expectedUID=uid;
		if (uid.length() == 0) {
			expectedUID=(givenname.substring(0,1)+sn).toLowerCase();
			log.fine("ExpectedUID: " + expectedUID);
		}
		
		//verify user doesn't exist
		Assert.assertFalse(sahiTasks.link(expectedUID).exists(), "Verify user " + expectedUID + " doesn't already exist");
		
		//new test user can be added now
		UserTasks.createUser(sahiTasks, uid, givenname, sn, "Add");		
		
		//verify user was added successfully
		Assert.assertTrue(sahiTasks.link(expectedUID).exists(), "Added user " + expectedUID + "  successfully");
	}
	
	/*
	 * Add users - for positive tests
	 */
	@Test (groups={"userCancelAddTests"}, description="Cancel adding a user",
			dataProvider="getCancelAddUserTestObjects")	
	public void testUserCancelAdd(String testName, String uid, String givenname, String sn) throws Exception {
		//verify user doesn't exist
		Assert.assertFalse(sahiTasks.link(uid).exists(), "Verify user " + uid + " doesn't already exist");
		
		//new test user can be added now
		UserTasks.createUser(sahiTasks, uid, givenname, sn, "Cancel");		
		
		//verify user was added successfully
		Assert.assertFalse(sahiTasks.link(uid).exists(), "Verify user " + uid + "  was not added");
	}
	
	/*
	 * Add users - for negative tests
	 */
	@Test (groups={"invalidUserAddTests"}, description="Add user - invalid",
			dataProvider="getInvalidUserTestObjects",  dependsOnGroups="userAddTests")	
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
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
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
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		//modify this user
		UserTasks.addMultipleUserData(sahiTasks, uid, mail1, mail2, mail3, phone1, phone2, pager1, pager2, mobile1, mobile2, fax1, fax2);
		
		//verify changes	
		UserTasks.verifyUserContactData(sahiTasks, uid, mail3, mail2, mail1, phone1, phone2, pager1, pager2, mobile1, mobile2, fax1, fax2);
	}
	
	@Test (groups={"userAddDeleteUndoResetTests"}, description="Add/Delete/Undo/Reset contact data",
			dataProvider="getUserAddDeleteUndoResetTestObjects", 
			dependsOnGroups={"userAddTests", "userEditTests", "userMultipleDataTests"})	
	public void testUserAddDeleteUndoReset(String testName, String uid, String mail1, String mail2, String	mail3, 
			String phone1, String phone2, String pager1, String pager2, String mobile1, String mobile2, 
			String fax1, String fax2) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
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
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		//modify this user
		UserTasks.modifyUserIdentitySettings(sahiTasks, uid, givenname, sn, fullname, displayName, initials);
		
		//verify changes	
		UserTasks.verifyUserIdentitySettings(sahiTasks, uid, givenname, sn, fullname, displayName, initials);
	}
	
	/*
	 * Update Identity Settings with invalid data
	 */
	@Test (groups={"userEditIdentitySettingsNegativeTests"}, description="Verify Error when editing Identity Settings using invalid data", 
			dataProvider="getUserEditIdentitySettingsNegativeTestObjects", 
			dependsOnGroups={"userAddTests"})	
	public void testUserEditIdentityNegativeSettings(String testName, String uid, String fieldName, String fieldValue, String expectedError, String buttonToClick ) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		//modify this user
		UserTasks.modifyUserIdentitySettingsNegative(sahiTasks, uid, fieldName, fieldValue, expectedError, buttonToClick);
	}
	
	/*
	 * Update Account Settings
	 */
	@Test (groups={"userEditAccountSettingsTests"}, dataProvider="getUserEditAccountSettingsTestObjects", dependsOnGroups={"userAddTests"})	
	public void testUserEditAccountSettings(String testName, String uid, String uidnumber, String gidnumber, String loginshell, String homedirectory) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
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
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
			
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
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
			
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
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		//modify this user
		UserTasks.modifyUserPassword(sahiTasks, uid, password);
		
		//verify changes	
		Assert.assertTrue(CommonTasks.kinitAsNewUserFirstTime(uid, password, newPassword), "Logged in and reset password for " + uid);
		
		// kinit back as admin to continue tests
		Assert.assertTrue(CommonTasks.kinitAsAdmin(), "Logged back in as admin to continue tests");
	}
	
	
	/*
	 * Cancel when deactivating users - for positive tests
	 */
	@Test (groups={"userCancelDeactivateTests"}, dataProvider="getUserCancelDeactivateStatusTestObjects", dependsOnGroups={"userAddTests",
			"userSetPasswordTests"})	
	public void testUserCancelDeactivate(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be deactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, true);
		
		//modify this user
		UserTasks.modifyUserStatus(sahiTasks, uid, false, "Cancel");
		
		//verify status	
		UserTasks.verifyUserStatus(sahiTasks, uid, true);
		// verify user can still kinit
		Assert.assertTrue(CommonTasks.kinitAsUser(uid, password), "Verify " + uid + " can still kinit");
		
		// kinit back as admin to continue tests
		Assert.assertTrue(CommonTasks.kinitAsAdmin(), "Logged back in as admin to continue tests");
	}
	

	/*
	 * Deactivate users - for positive tests
	 */
	@Test (groups={"userDeactivateTests"}, dataProvider="getUserDeactivateStatusTestObjects", dependsOnGroups={"userAddTests", "userCancelDeactivateTests", 
			"userSetPasswordTests"})	
	public void testUserDeactivate(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be deactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, true);
		
		//modify this user
		UserTasks.modifyUserStatus(sahiTasks, uid, false, "Deactivate");
		
		//verify changes to status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		// verify user cannot kinit
		Assert.assertFalse(CommonTasks.kinitAsUser(uid, password), "Verify " + uid + " cannot kinit");
		
		
	}
	
	/*
	 * Cancel when reactivating users - for positive tests
	 */
	@Test (groups={"userCancelReactivateTests"}, dataProvider="getUserCancelReactivateStatusTestObjects", dependsOnGroups={"userAddTests", "userDeactivateTests", "userSetPasswordTests"})	
	public void testUserCancelReactivate(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be reactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		
		//modify this user
		UserTasks.modifyUserStatus(sahiTasks, uid, true, "Cancel");
		
		//verify changes to status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		// verify user cannot kinit
		Assert.assertFalse(CommonTasks.kinitAsUser(uid, password), "Verify " + uid + " cannot kinit");
		
	}
	
	
	/*
	 * Reactivate users - for positive tests
	 */
	@Test (groups={"userReactivateTests"}, dataProvider="getUserReactivateStatusTestObjects", dependsOnGroups={"userAddTests", "userDeactivateTests", "userSetPasswordTests", "userCancelReactivateTests"})	
	public void testUserReactivate(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be reactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		
		//modify this user
		UserTasks.modifyUserStatus(sahiTasks, uid, true, "Activate");
		
		//verify changes to status	
		UserTasks.verifyUserStatus(sahiTasks, uid, true);
		// verify user can kinit
		Assert.assertTrue(CommonTasks.kinitAsUser(uid, password), "Verify " + uid + " can kinit");
		
		// kinit back as admin to continue tests
		Assert.assertTrue(CommonTasks.kinitAsAdmin(), "Logged back in as admin to continue tests");
	}
	
	/*
	 * Delete users - one at a time - for positive tests
	 * note: make sure tests that use testuser are run before testuser gets deleted here
	 */
	@Test (groups={"userDeleteTests"}, dataProvider="getUserDeleteTestObjects", 
			dependsOnGroups={"userAddTests", "userEditTests", "userSetPasswordTests", "userDeactivateTests", 
			"userReactivateTests", "invalidUserAddTests", "userSearchTests", "userMultipleDataTests", "userAddDeleteUndoResetTests"})	
	public void testUserDelete(String testName, String uid) throws Exception {
		//verify user to be deleted exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + "  to be deleted exists");
		
		//modify this user
		UserTasks.deleteUser(sahiTasks, uid);
		
		//verify user is deleted
		Assert.assertFalse(sahiTasks.link(uid).exists(), "User " + uid + "  deleted successfully");
	}
	
	// TODO: Nkrishnan: Add test for Delete - but cancel
	
	
	/*
	 * Delete multiple users - for positive tests
	 */
	@Test (groups={"userMultipleDeleteTests"}, dataProvider="getMultipleUserDeleteTestObjects", dependsOnGroups={"userAddTests", "invalidUserAddTests", "userAddAndEditTests", "userAddAndAddAnotherTests",
			"userEditIdentitySettingsTests", "userEditAccountSettingsTests", "userEditMailingAddressTests", "userEditEmpMiscInfoTests", "userSearchTests" })
	public void testMultipleUserDelete(String testName, String uid1, String uid2, String uid3, String uid4) throws Exception {		
		String uids[] = {uid1, uid2, uid3, uid4};
		
		//verify user to be deleted exists
		for (String uid : uids) {
			Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + "  to be deleted exists");
		}
					
		//mark this user for deletion
		UserTasks.chooseMultipleUsers(sahiTasks, uids);		
		UserTasks.deleteMultipleUser(sahiTasks);	
		//verify user is deleted 
		for (String uid : uids) {
			Assert.assertFalse(sahiTasks.link(uid).exists(), "Verify user " + uid + "  is deleted");
		}
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
		Assert.assertFalse(sahiTasks.link(expectedUID1).exists(), "Verify user " + expectedUID1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(expectedUID2).exists(), "Verify user " + expectedUID2 + " doesn't already exist");
		
		//new test user can be added now
		UserTasks.createUserThenAddAnother(sahiTasks, givenname1, sn1, givenname2, sn2);				
		
		//verify users were added successfully
		Assert.assertTrue(sahiTasks.link(expectedUID1).exists(), "Added user " + expectedUID1 + "  successfully");
		Assert.assertTrue(sahiTasks.link(expectedUID2).exists(), "Added user " + expectedUID2 + "  successfully");
	}
	
	
	/*
	 * Add and Edit user
	 */
	@Test (groups={"userAddAndEditTests"}, dataProvider="getUserAddAndEditTestObjects",  dependsOnGroups="userAddTests")	
	public void testUserAddAndEdit(String testName, String uid, String givenname, String sn, String title, String mail) throws Exception {
		
		//verify users don't exist
		Assert.assertFalse(sahiTasks.link(uid).exists(), "Verify user " + uid + " doesn't already exist");
		
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
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Searched and found user " + uid + "  successfully");
		if (!multipleResult.equals(""))
			Assert.assertTrue(sahiTasks.link(multipleResult).exists(), "Searched and found another user " + multipleResult + "  successfully");
		
		UserTasks.clearSearch(sahiTasks);
	}
	
	
	/*
	 * Expand/Collapse
	 */	
	@Test (groups={"userExpandCollapseTests"}, dataProvider="getUserExpandCollapseTestObjects",  dependsOnGroups="userAddTests")
	public void testUserExpandCollapse(String testName, String uid) throws Exception {
		
		UserTasks.expandCollapseUser(sahiTasks, uid);		
		
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException {
		sahiTasks.navigateTo(commonTasks.userPage, true);
		
		String[] uids = {"user1",		
				"user2",
				"testuser",	
				"tuser",	
				"1spe.cial_us-er$",	
				"user9",
				"tuser7",
				"tuser8"
				} ;

		//verify users were found
		for (String uid : uids) {
			if (sahiTasks.link(uid).exists()){
				log.fine("Cleaning User: " + uid);
				UserTasks.deleteUser(sahiTasks, uid);
			}			
		} 
	}
	
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding users - for positive cases
	 */
	@DataProvider(name="getCancelAddUserTestObjects")
	public Object[][] getCancelAddUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createCancelAddUserTestObjects());
	}
	protected List<List<Object>> createCancelAddUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname				uid              	givenname		sn   
		ll.add(Arrays.asList(new Object[]{ "cancel_add",			"user1", 			"Test1",		"User1"      } ));
		
		return ll;	
	}
	
	@DataProvider(name="getUserTestObjects")
	public Object[][] getUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserTestObjects());
	}
	protected List<List<Object>> createUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			uid              			givenname			sn   
		ll.add(Arrays.asList(new Object[]{ "add_good",				"testuser", 				"Test",				"User"      } ));
		ll.add(Arrays.asList(new Object[]{ "add_optional_login",	"", 						"Test",				"User"      } ));
		ll.add(Arrays.asList(new Object[]{ "add_testuser",			"user2", 			    	"Test2",			"User2"     } ));
		ll.add(Arrays.asList(new Object[]{ "add_special_char",		"1spe.cial_us-er$", 		"S$p|e>c--i_a%l_",	"%U&s?e+r(" } ));
		      
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
		
        //										testname							uid										givenname	sn   		 ExpectedError
		
		ll.add(Arrays.asList(new Object[]{ "create_long_user",						"abcdefghijklmnopqrstuvwxyx12345678", 	"Long",		"User",      "invalid 'login': can be at most 32 characters"	} ));
		ll.add(Arrays.asList(new Object[]{ "recreate_user",							"testuser", 							"Test",		"User",		 "user with name \"testuser\" already exists"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_user_with_optional_login_again",	"", 									"Testing",	"User",		 "user with name \"tuser\" already exists"	} ));
		
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
		
        //										testname			uid              		title					mail   
		ll.add(Arrays.asList(new Object[]{ "edit_user",				"testuser", 			"Software Engineer",	"testuser@example.com"     } ));
		        
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding multiple Contact info for users
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
	 * Data to be used when adding multiple Contact info for users
	 */
	@DataProvider(name="getUserAddDeleteUndoResetTestObjects")
	public Object[][] getUserAddDeleteUndoResetTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserAddDeleteUndoResetTestObjects());
	}
	protected List<List<Object>> createUserAddDeleteUndoResetTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					uid              	mail1			mail2			mail3 				phone1		phone2  		pager1		pager2			mobile1		mobile2			fax1		fax2
		ll.add(Arrays.asList(new Object[]{ "add_delete_undo_reset",			"testuser", 		"one@testrelm",	"two@testrelm", "three@testrelm",   "1234567", 	"7654321",		"9876543",	"3456789",		"135790",	"097531", 		"1122334", 	"4332211"	 } ));
		        
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
	 * Data to be used when cancelling deactivating user
	 */
	@DataProvider(name="getUserCancelDeactivateStatusTestObjects")
	public Object[][] getUserCancelDeactivateStatusTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserCancelDeactivateStatusTestObjects());
	}
	protected List<List<Object>> createUserCancelDeactivateStatusTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				  uid			password              		
		ll.add(Arrays.asList(new Object[]{ "cancel_deactivate",			"testuser",		"Secret123"     } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when deactivating user
	 */
	@DataProvider(name="getUserDeactivateStatusTestObjects")
	public Object[][] getUserDeactivateStatusTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserDeactivateStatusTestObjects());
	}
	protected List<List<Object>> createUserDeactivateStatusTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			  uid			password              		
		ll.add(Arrays.asList(new Object[]{ "deactivate",			"testuser",		"Secret123"     } ));
		        
		return ll;	
	}

	/*
	 * Data to be used when cancelling reactivating user
	 */
	@DataProvider(name="getUserCancelReactivateStatusTestObjects")
	public Object[][] getUserCancelReactivateStatusTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserCancelReactivateStatusTestObjects());
	}
	protected List<List<Object>> createUserCancelReactivateStatusTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				  uid			password              		
		ll.add(Arrays.asList(new Object[]{ "cancel_reactivate",			"testuser",		"Secret123"     } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when reactivating user
	 */
	@DataProvider(name="getUserReactivateStatusTestObjects")
	public Object[][] getUserReactivateStatusTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserReactivateStatusTestObjects());
	}
	protected List<List<Object>> createUserReactivateStatusTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			  uid			password              		
		ll.add(Arrays.asList(new Object[]{ "reactivate",			"testuser",		"Secret123"     } ));
		        
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
		ll.add(Arrays.asList(new Object[]{ "delete_single_user1",			"testuser"     } ));
		ll.add(Arrays.asList(new Object[]{ "delete_single_user2",			"user2"     } ));
		        
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
		
        //										testname					uid1		uid2		uid3		uid4              		
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_users",			"tuser",	"user9",	"tuser7",	"tuser8"     } ));
		
		
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
		
        //										testname				givenname1		sn1			givenname2		sn2   
		ll.add(Arrays.asList(new Object[]{ "add_and_add_another",		"Test",			"User7",	"Test",			"User8"     } ));
		        
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
		
        //										testname		uid				givenname		sn			title					mail   
		ll.add(Arrays.asList(new Object[]{ "add_and_edit",		"user9",		"Test",			"User",		"Software Engineer",	"testuser@example.com"     } ));
		        
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
		
        //										testname				uid       		multiple_result1	       		
		ll.add(Arrays.asList(new Object[]{ "search_user1",				"testuser",		""    				} ));
		ll.add(Arrays.asList(new Object[]{ "search_user2",				"user2",		""	     			} ));
		ll.add(Arrays.asList(new Object[]{ "search_multipleresult",		"tuser",		"testuser"     		} ));
		        
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
		ll.add(Arrays.asList(new Object[]{ "expand_collapse",			"testuser"    				} ));
		  
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
		
        //										testname				uid    		givenname		sn				fullname			displayName		initials   			       		
		ll.add(Arrays.asList(new Object[]{ "identity_settings",			"tuser",	"Mickey",		"Mouse",		"Mickey Mouse",		"Mickey M.",	"MM"	  				} ));
		  
		return ll;	
	}
	
	/*
	 * Invalid data to be used when updating Identity Settings for users
	 */
	@DataProvider(name="getUserEditIdentitySettingsNegativeTestObjects")
	public Object[][] getUserEditIdentitySettingsNegativeTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserEditIdentitySettingsNegativeTestObjects());
	}
	protected List<List<Object>> createUserEditIdentitySettingsNegativeTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname										cn   		fieldName		fieldValue		expected error													 cancel/ok button
		ll.add(Arrays.asList(new Object[]{ "identity_settings_firstname_trailing_space",		"user2",	"givenname",	"XXX ",			"invalid 'first': Leading and trailing spaces are not allowed",		"Cancel"	} ));
		ll.add(Arrays.asList(new Object[]{ "identity_settings_firstname_leading_space",			"user2",	"givenname",	" XXX",			"invalid 'first': Leading and trailing spaces are not allowed", 	"Cancel"	} ));
		ll.add(Arrays.asList(new Object[]{ "identity_settings_firstname_blank",					"user2",	"givenname",	"",			"Input form contains invalid or missing values.", 					"OK"	} ));
		
		
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
		
        //										testname					uid    		uidnumber		gidnumber		loginshell		homedirectory   			       		
		ll.add(Arrays.asList(new Object[]{ "account_settings",				"tuser",	"123456789",	"987654321",	"/bin/csh",		"/home/newtuser"		} ));
		  
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
		ll.add(Arrays.asList(new Object[]{ "mailingAddress_settings",			"tuser",	"200 Broadway Ave",		"Bedford",		"MA",		"01730"		} ));
		  
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
		
        //										testname		uid    		org			manager			car  			       		
		ll.add(Arrays.asList(new Object[]{ "emp_misc",			"tuser",	"QE",		"testuser",		"012 ABC"		} ));
		  
		return ll;	
	}
	

}
