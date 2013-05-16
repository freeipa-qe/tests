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
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
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

	
	// Add user with password - for positive test
	@Test (groups={"userAddTests"}, description="Add valid users",
			dataProvider="getUserTestObjects")	
	public void testUseradd(String testName, String uid, String givenname, String sn, String newPassword, String verifyPassword) throws Exception {
		String expectedUID=uid;
		if (uid.length() == 0) {
			expectedUID=(givenname.substring(0,1)+sn).toLowerCase();
			log.fine("ExpectedUID: " + expectedUID);
		}
		
		//verify user doesn't exist
		Assert.assertFalse(sahiTasks.link(expectedUID).exists(), "Verify user " + expectedUID + " doesn't already exist");
		
		//new test user can be added now
		UserTasks.createUser(sahiTasks, uid, givenname, sn, newPassword, verifyPassword, "Add");		
		
		//verify user was added successfully 
		Assert.assertTrue(sahiTasks.link(expectedUID).exists(), "Added user " + expectedUID + "  successfully");
	}
	
	/*
	 *Add user with password not accept - for negative tests 
	 */
	@Test (groups={"userMismatchingPasswordNegativeTests"}, description="Add a user with mismatching passwords negative tests",
		dataProvider="getMismatchingPasswordNegativeTestsObjects")
		public void testPasswordMismatch(String testName, String uid, String givenname, String sn, String newPassword, String verifyPassword, String expectedError)throws Exception {
			String expectedUID=uid;
			if (uid.length() == 0) {
				expectedUID=(givenname.substring(0,1)+sn).toLowerCase();
				log.fine("ExpectedUID: " + expectedUID);
		}
			//verify user doesn't exist
			Assert.assertFalse(sahiTasks.link(expectedUID).exists(), "Verify user " + expectedUID + " doesn't already exist");
			
			//new testuser with unmatching passwords added now
			UserTasks.createUserForNegativePassword(sahiTasks, uid, givenname, sn, newPassword, verifyPassword, "Add", expectedError);	
			
			//verify user was not added successfully 
			Assert.assertFalse(sahiTasks.link(uid).exists(), "Verify user " + uid + "  was not added");
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
	public void testUserAddDeleteUndoReset (String testName, String uid, String mail1, String mail2, String	mail3, 
			String phone1, String phone2, String pager1, String pager2, String mobile1, String mobile2, 
			String fax1, String fax2) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be edited exists");
		
		//Add, Delete, Undo and Reset Contact Data
		UserTasks.addDeleteUndoResetContactData(sahiTasks, uid, mail1, phone1);
		
		//verify nothing changed	
		UserTasks.verifyUserContactData(sahiTasks, uid, mail1, mail3, mail2, phone1, phone2, pager1, pager2, mobile1, mobile2, fax1, fax2);
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
	 * Verify Kerberos Ticket Policy.
	 */
	@Test (groups={"userVerifyKerberosTicketPolicyTests"}, dataProvider="getKerberosTicketPolicyObjects", dependsOnGroups={"userAddTests"})	
	public void testUserVerifyKerberosTicketPolicy(String testName, String uid, String maxrenew, String maxlife) throws Exception {		
		//verify user is exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " is exists");
		
		//Verify Kerberos Ticket Policy Data
		UserTasks.verifyUserKerberosTicketPolicyData(sahiTasks, uid, maxrenew, maxlife);
		
		
	
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
	 * Deactivate users - for positive tests
	 */
	@Test (groups={"userDeactivateTests"}, dataProvider="getUserDeactivateStatusTestObjects", dependsOnGroups={"userAddTests", "userSetPasswordTests"})		
	public void testUserDeactivate(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be deactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, true);
		
		//modify this user
		UserTasks.modifyUserStatus(sahiTasks, uid, false, "Apply");
		
		//verify changes to status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		// verify user cannot kinit
		//Assert.assertFalse(CommonTasks.kinitAsUser(uid, password), "Verify " + uid + " cannot kinit");
		// xdong : TODO: login using formauth 
		// Verify - that user could not login
		//login back as the admin
		//Assert.assertFalse(CommonTasks.formauth(sahiTasks, uid, password), "Verify " + uid + " cannot kinit");
		CommonTasks.formauth(sahiTasks, uid, password);
		Assert.assertTrue(sahiTasks.div("error-box").exists(), "Verify " + uid + " cannot kinit");
		CommonTasks.formauth(sahiTasks, "admin", "Secret123");

	}
	
		
	/*
	 * Reactivate users - for positive tests
	 */
	@Test (groups={"userReactivateTests"}, dataProvider="getUserReactivateStatusTestObjects", dependsOnGroups={"userAddTests", "userDeactivateTests", "userSetPasswordTests"})	
	public void testUserReactivate(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be reactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		
		//modify this user
		UserTasks.modifyUserStatus(sahiTasks, uid, true, "Apply");
		
		//verify changes to status	
		UserTasks.verifyUserStatus(sahiTasks, uid, true);
		// verify user can kinit
		Assert.assertTrue(CommonTasks.kinitAsUser(uid, password), "Verify " + uid + " can kinit");
		
		// kinit back as admin to continue tests
		Assert.assertTrue(CommonTasks.kinitAsAdmin(), "Logged back in as admin to continue tests");
	}
	
	/*
	 * Deactivate users from User Page - for positive tests
	 */
	@Test (groups={"userDeactivateUserPageTests"}, dataProvider="getUserDeactivateStatusUserPageTestObjects", dependsOnGroups={"userAddTests", "userSetPasswordTests", "userDeactivateTests", "userReactivateTests"})		
	public void testUserDeactivateUserPage(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be deactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, true);
		
		//modify this user
		UserTasks.modifyUserStatusUserPage(sahiTasks, uid, false);
		
		//verify changes to status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		// verify user cannot kinit
		//Assert.assertFalse(CommonTasks.kinitAsUser(uid, password), "Verify " + uid + " cannot kinit");
		CommonTasks.formauth(sahiTasks, uid, password);
		Assert.assertTrue(sahiTasks.div("error-box").exists(), "Verify " + uid + " cannot kinit");
		CommonTasks.formauth(sahiTasks, "admin", "Secret123");
				
	}
	
	/*
	 * Deactivate users from User Page - for positive tests
	 */
	@Test (groups={"userDeactivateNegativeTests"}, dataProvider="getUserDeactivateNegativeTestObjects", dependsOnGroups={"userAddTests", "userSetPasswordTests", "userDeactivateTests", "userReactivateTests", "userReactivateTestsUserPage", "userDeactivateUserPageTests"})		
	public void testUserDeactivateNegative(String testName, String uid, String errorMsg) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " exists");
		
		//modify this user
		UserTasks.modifyUserStatusNegative(sahiTasks, uid);
		
		Assert.assertTrue(errorMsg.equals(sahiTasks.span("Operations Error").getText()), "Error Matches the expected error");
		
		sahiTasks.button("OK").click();
		
		
	}
	
	/*
	 * Reactivate users from User Page - for positive tests
	 */
	@Test (groups={"userReactivateTestsUserPage"}, dataProvider="getUserReactivateStatusUserPageTestObjects", dependsOnGroups={"userAddTests", "userDeactivateTests", "userSetPasswordTests", "userDeactivateUserPageTests", "userReactivateTests"})	
	public void testUserReactivateUserPage(String testName, String uid, String password) throws Exception {		
		//verify user to be edited exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + " to be reactivated exists");
		
		//verify expected status	
		UserTasks.verifyUserStatus(sahiTasks, uid, false);
		
		//modify this user
		UserTasks.modifyUserStatusUserPage(sahiTasks, uid, true);
		
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
	@Test (groups={"userEditDeleteTests"}, dataProvider="getUserEditDeleteTestObjects", 
			dependsOnGroups={"userAddTests", "userEditTests", "userSetPasswordTests", "userDeactivateTests", 
 "userReactivateTests",
			"invalidUserAddTests", "userSearchTests", "searchUsersNegativeTests", "userMultipleDataTests",
			"userAddDeleteUndoResetTests", "userDeactivateUserPageTests", "userReactivateTestsUserPage", "userDeactivateNegativeTests"})	
	public void testUserEditDelete(String testName, String uid) throws Exception {
		sahiTasks.link(uid).click();
		
		//modify this user
		UserTasks.deleteEditUser(sahiTasks, uid);
		
		//verify user is deleted
		Assert.assertFalse(sahiTasks.link(uid).exists(), "User " + uid + "  deleted successfully");
	}
	
	/*
	 * Delete users - one at a time - for positive tests
	 * note: make sure tests that use testuser are run before testuser gets deleted here
	 */
	@Test (groups={"userDeleteTests"}, dataProvider="getUserDeleteTestObjects", 
			dependsOnGroups={"userAddTests", "userEditTests", "userSetPasswordTests", "userDeactivateTests", 
 "userReactivateTests",
			"invalidUserAddTests", "userSearchTests", "searchUsersNegativeTests", "userMultipleDataTests",
			"userAddDeleteUndoResetTests", "userEditDeleteTests", "userDeactivateUserPageTests"})	
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
	 * 
	 * 
	 * 
	 */
	@Test (groups={"userMultipleDeleteTests"}, dataProvider="getMultipleUserDeleteTestObjects", dependsOnGroups={"userAddTests", "invalidUserAddTests", "userAddAndEditTests", "userAddAndAddAnotherTests",
			 "userEditIdentitySettingsTests", "userEditAccountSettingsTests", "userEditMailingAddressTests", "userDeleteSSHPubKeyTests", "userEditSSHPubKeyTests", "userEditUndoSSHPubKeyTests", "userEditEmpMiscInfoTests", "userSearchTests", "searchUsersNegativeTests", "userEditDeleteTests" })
	public void testMultipleUserDelete(String testName, String uid1, String uid2, String uid3, String uid4) throws Exception {		
		String uids[] = {uid1, uid2, uid3, uid4};
		
		//verify user to be deleted exists
		sahiTasks.navigateTo(commonTasks.userPage, true);
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
	 * sshpubkey Add
	 */
	@Test (groups={"userEditSSHPubKeyTests"}, dataProvider="getUserEditSSHPubKeyTestObjects",  dependsOnGroups="userAddAndEditTests")	
	public void testAddSSHPubKey(String testName, String uid, String keyType, String fileName, String keyName1, String addToKey) throws Exception {
		
		sahiTasks.navigateTo(CommonTasks.userPage);
		
		String sshKey=CommonTasks.generateSSH(uid,keyType,fileName);
		
		UserTasks.addSSHKey(sahiTasks,uid,sshKey,addToKey);
		if(keyType.equals("dsa")){
			Assert.assertTrue(sahiTasks.getText(sahiTasks.span(keyName1)).contains("ssh-dss"), "ssh " + keyType + " for " + uid + " added successfully");
		}
		else{
			Assert.assertTrue(sahiTasks.getText(sahiTasks.span(keyName1)).contains("ssh-" + keyType) , "ssh " + keyType + " for " + uid + " added successfully");
		}
	}
	
	/*
	 * sshpubkey Add Negative
	 */
	@Test (groups={"userEditNegativeSSHPubKeyTests"}, dataProvider="getUserEditNegativeSSHPubKeyTestObjects",  dependsOnGroups="userEditSSHPubKeyTests")	
	public void testAddNegativeSSHPubKey(String testName, String uid, String key, String keyType, String fileName, String errorMsg, String errorMsg1, String addToKey) throws Exception {
		
		sahiTasks.navigateTo(CommonTasks.userPage);
		
		
		if(keyType.equals(""))
			UserTasks.addSSHKey(sahiTasks, uid, key, addToKey);
		else{
			String sshKey=CommonTasks.generateSSH(uid,keyType,fileName);
			UserTasks.addSSHKey(sahiTasks, uid, sshKey, addToKey);
		}
		Assert.assertTrue((sahiTasks.div(errorMsg).exists() || sahiTasks.div(errorMsg1).exists()), "Add Negative tested successfully");
		if(sahiTasks.button("Cancel").exists()){
			sahiTasks.button("Cancel").click();
		}
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
		if(sahiTasks.button("Reset").exists()){
			sahiTasks.button("Reset").click();
		}
	}
	
	/*
	 * sshpubkey Refresh/Reset/Update
	 */
	@Test (groups={"userEditRefreshResetUpdateSSHPubKeyTests"}, dataProvider="getUserEditRefreshResetUpdateSSHPubKeyTestObjects",  dependsOnGroups={"userEditSSHPubKeyTests","userEditUndoSSHPubKeyTests","userEditNegativeSSHPubKeyTests"})	
	public void testAddRefreshResetUpdateSSHPubKey(String testName, String uid, String keyType, String fileName, String keyName, String spanName) throws Exception {
		
		sahiTasks.navigateTo(CommonTasks.userPage);
		
		String sshKey=CommonTasks.generateSSH(uid,keyType,fileName);
		UserTasks.SSHKeyRefershResetUpdate(sahiTasks, uid, sshKey, spanName);
		if(!spanName.equals("Update")){
			Assert.assertFalse(sahiTasks.span(keyName).exists(), "sshpubkey Add and " + spanName + " Successful");
		}
		else{
			Assert.assertTrue(sahiTasks.span(keyName).exists(), "sshpubkey Add and " + spanName + " Successful");
		}
	}
	
	/*
	 * sshpubkey Update/Reset/Cancel
	 */
	@Test (groups={"userEditUpdateResetCancelSSHPubKeyTests"}, dataProvider="getUserEditUpdateResetCancelSSHPubKeyTestObjects",  dependsOnGroups={"userEditSSHPubKeyTests","userEditUndoSSHPubKeyTests","userEditNegativeSSHPubKeyTests","userEditRefreshResetUpdateSSHPubKeyTests"})	
	public void testAddUpdateResetCancelSSHPubKey(String testName, String uid, String keyType, String fileName, String keyName, String buttonName) throws Exception {
		
		sahiTasks.navigateTo(CommonTasks.userPage);
		
		String sshKey=CommonTasks.generateSSH(uid,keyType,fileName);
		UserTasks.SSHKeyUpdateResetCancel(sahiTasks, uid, sshKey, buttonName);
		if(buttonName.equals("Reset")){
			Assert.assertFalse(sahiTasks.span(keyName).exists(), "sshpubkey Add and " + buttonName + " Successful");
		}
		else{
			Assert.assertTrue(sahiTasks.span(keyName).exists(), "sshpubkey Add and " + buttonName + " Successful");
		}
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
		if(sahiTasks.button("Reset").exists()){
			sahiTasks.button("Reset").click();
		}
	}
	
	/*
	 * sshpubkey Undo
	 */
	@Test (groups={"userEditUndoSSHPubKeyTests"}, dataProvider="getUserEditUndoSSHPubKeyTestObjects",  dependsOnGroups="userEditSSHPubKeyTests")	
	public void testUndoSSHPubKey(String testName, String uid, String keyType1, String keyType2, String fileName1, String fileName2, String spanName) throws Exception {
		
		sahiTasks.navigateTo(CommonTasks.userPage);
		
		String sshKey=CommonTasks.generateSSH(uid,keyType1,fileName1);
		String sshKey1="";
		if(!keyType2.equals("")){
			sshKey1=CommonTasks.generateSSH(uid,keyType2,fileName2);
		}
		
		UserTasks.addAndUndoSSHKey(sahiTasks,uid,sshKey,sshKey1, spanName);
		if(keyType2.equals(""))
			Assert.assertFalse(sahiTasks.span("New: key set").exists(), "sshKey Add and Undo successful");
		else
			Assert.assertFalse(sahiTasks.span("New: key set").exists(), "sshKey Add and UndoAll successful");
		
	}
	
	/*
	 * sshpubkey Delete
	 */
	@Test (groups={"userDeleteSSHPubKeyTests"}, dataProvider="getUserDeleteSSHPubKeyTestObjects",  dependsOnGroups={"userEditNegativeSSHPubKeyTests","userEditRefreshResetUpdateSSHPubKeyTests"})	
	public void testDeleteSSHPubKey(String testName, String uid) throws Exception {
		
		sahiTasks.navigateTo(CommonTasks.userPage);
		
		UserTasks.userSSHDelete(sahiTasks, uid);
		
		Assert.assertFalse(sahiTasks.span("sshkey-status strikethrough").exists(), "sshKey Deleted Successfully");
		
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
	 * search users negative
	 */
	@Test (groups={"searchUsersNegativeTests"}, dataProvider="getUsersSearchNegativeTestObjects",  dependsOnGroups={"userAddTests"})	
	public void testUserSearchNegative(String testName, String uid) throws Exception {
		
		//search host
		UserTasks.searchUser(sahiTasks, uid);
		
		//verify host was deleted
		Assert.assertFalse(sahiTasks.link(uid).exists(), uid + " does not exist - search successfully");
		UserTasks.clearSearch(sahiTasks);
	}
	
	/*
	 * Expand/Collapse
	 */	
	@Test (groups={"userExpandCollapseTests"}, dataProvider="getUserExpandCollapseTestObjects",  dependsOnGroups="userAddTests")
	public void testUserExpandCollapse(String testName, String uid) throws Exception {
		
		UserTasks.expandCollapseUser(sahiTasks, uid);		
		
	}
	
	/*
	 * bug verification 782981
	 */	
	@Test (groups={"bugVerfication782981"}, dataProvider="getbugverfication782981", dependsOnGroups="userAddTests")
	public void bug782981(String testName, String uid,String givenname,String sn,String password,String newPassword) throws Exception {
		//add a user
		UserTasks.createUser(sahiTasks, uid, givenname, sn, password, password, "Add");
		//login as new user to make sure form based auth page supports password changes.
		CommonTasks.formauthNewUser(sahiTasks, uid, password, newPassword);
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
		UserTasks.searchUser(sahiTasks, uid);
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Added new user " + uid + "  successfully");
		UserTasks.clearSearch(sahiTasks);
		//delete user
		CommonTasks.formauth(sahiTasks, "admin", "Secret123");
		sahiTasks.navigateTo(commonTasks.userPage, true);
		UserTasks.searchUser(sahiTasks, uid);
		UserTasks.deleteUser(sahiTasks, uid);
		Assert.assertFalse(sahiTasks.link(uid).exists(), "Delete new user " + uid + "  successfully");
		UserTasks.clearSearch(sahiTasks);
		
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
				"tuser8",
				"kuser"
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
	
	
	// Data to be used when adding users with password
	
	@DataProvider(name="getUserTestObjects")
	public Object[][] getUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserTestObjects());
	}
	protected List<List<Object>> createUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			uid              			givenname			sn   		newpassword 		verifypassword
		ll.add(Arrays.asList(new Object[]{ "add_good",				"testuser", 				"Test",				"User",      "testuser",		 "testuser"  } ));
		ll.add(Arrays.asList(new Object[]{ "add_optional_login_password", "", 					"Test",				"User",      "",					 "" 	 } ));
		ll.add(Arrays.asList(new Object[]{ "add_testuser",			"user2", 			    	"Test2",			"User2",	 "user2",	      	 "user2"	 } ));
		ll.add(Arrays.asList(new Object[]{ "add_special_char",		"1spe.cial_us-er$", 		"S$p|e>c--i_a%l_",	"%U&s?e+r(", "!@#$",			 "!@#$"	     } ));
		ll.add(Arrays.asList(new Object[]{ "add_kuser",				"kuser",					"Kerberos",			"User",		 "",					""       } ));	     
		return ll;	
	}
	
	//Data to be used when adding users with Mismatching password
	@DataProvider(name="getMismatchingPasswordNegativeTestsObjects")
	public Object[][] getMismatchingPasswordNegativeTestsObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserMismatchingPasswordObjects());
	}
	protected List<List<Object>> createUserMismatchingPasswordObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						uid             		givenname		    	 sn   		newpassword 		verifypassword		ExpectedError
		ll.add(Arrays.asList(new Object[]{ "add_mispassword",			     "tuser2",	 				  "Test",				"User1",       "testuser",		   "test",  	    "Passwords must match"  } ));
		ll.add(Arrays.asList(new Object[]{ "add_Leadind_Space_password",	"testuser1", 				  "Test",				"User1",      " testuser",		 " testuser",		"invalid 'password': Leading and trailing spaces are not allowed"  } ));
		ll.add(Arrays.asList(new Object[]{ "add_Trailing_Space_password",     "tuser1", 				  "Test",				"User1",       "testuser ",		 "testuser ",  	    "invalid 'password': Leading and trailing spaces are not allowed"  } ));
		
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
		ll.add(Arrays.asList(new Object[]{ "add_multiple_contactdata",		"testuser", 			"one@testrelm.com",	"two@testrelm.com", "three@testrelm.com",   "1234567", 	"7654321",		"9876543",	"3456789",		"135790",	"097531", 		"1122334", 	"4332211"	 } ));
		        
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
		ll.add(Arrays.asList(new Object[]{ "add_delete_undo_reset",			"testuser", 		"one@testrelm.com",	"two@testrelm.com", "three@testrelm.com",   "1234567", 	"7654321",		"9876543",	"3456789",		"135790",	"097531", 		"1122334", 	"4332211"	 } ));
		        
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
	 * Data to be used when deactivating user
	 */
	@DataProvider(name="getUserDeactivateStatusUserPageTestObjects")
	public Object[][] getUserDeactivateStatusUserPageTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserDeactivateStatusUserPageTestObjects());
	}
	protected List<List<Object>> createUserDeactivateStatusUserPageTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			  uid			password              		
		ll.add(Arrays.asList(new Object[]{ "deactivate_userpage",	  "testuser",	"Secret123"     } ));
		        
		return ll;	
	}
	
	
	/*
	 * Data to be used when deactivating user negative
	 */
	@DataProvider(name="getUserDeactivateNegativeTestObjects")
	public Object[][] getUserDeactivateNegativeTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserDeactivateNegativeTestObjects());
	}
	protected List<List<Object>> createUserDeactivateNegativeTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			  uid			errorMsg		             		
		ll.add(Arrays.asList(new Object[]{ "deactivate_negative",	  "testuser",	"Operations Error"     } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when reactivating user
	 */
	@DataProvider(name="getUserReactivateStatusUserPageTestObjects")
	public Object[][] getUserReactivateStatusUserPageTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserReactivateStatusUserPageTestObjects());
	}
	protected List<List<Object>> createUserReactivateStatusUserPageTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			  uid			password              		
		ll.add(Arrays.asList(new Object[]{ "reactivate_userpage",	  "testuser",	"Secret123"     } ));
		        
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
		ll.add(Arrays.asList(new Object[]{ "delete_single_user2",			"user2"     } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when deleting users
	 */
	@DataProvider(name="getUserEditDeleteTestObjects")
	public Object[][] getUserEditDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editDeleteUserTestObjects());
	}
	protected List<List<Object>> editDeleteUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					uid              		
		ll.add(Arrays.asList(new Object[]{ "edit_delete_user",				"testuser"     } ));
			        
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
	 * Data to be used when adding sshpubkeys
	 */
	
	@DataProvider(name="getUserEditSSHPubKeyTestObjects")
	public Object[][] getUserEditSSHPubKeyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(userEditSSHPubKeyTestObjects());
	}
	protected List<List<Object>> userEditSSHPubKeyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname		 		uid			keyType		fileName		keyName1			addToKey	
		ll.add(Arrays.asList(new Object[]{ "add_sshkey_rsa",		"user9",	"rsa",		"user9_rsa",	"sshkey-status",	""  	  } ));
		ll.add(Arrays.asList(new Object[]{ "add_sshkey_dsa",		"user9",	"dsa",		"user9_dsa",	"sshkey-status[1]",	"" 	  } ));
		ll.add(Arrays.asList(new Object[]{ "add_sshkey_rsa_space",	"user9",	"rsa",		"user9_rsa1",	"sshkey-status[2]",	" " 	  } ));
		ll.add(Arrays.asList(new Object[]{ "add_sshkey_rsa_equal",	"user9",	"rsa",		"user9_rsa2",	"sshkey-status[3]",	"="  	  } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when adding negative sshpubkeys
	 */
	
	@DataProvider(name="getUserEditNegativeSSHPubKeyTestObjects")
	public Object[][] getUserEditNegativeSSHPubKeyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(userEditNegativeSSHPubKeyTestObjects());
	}
	protected List<List<Object>> userEditNegativeSSHPubKeyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname		 				uid			key		keyType			fileName			errorMsg									errorMsg1										addToKey		
		ll.add(Arrays.asList(new Object[]{ "add_negative_sshkey_empty",		"user9",	"",		"",				"",					"no modifications to be performed",			"",												""  	  } ));
		ll.add(Arrays.asList(new Object[]{ "add_negative_sshkey_invalid",	"user9",	"test",	"",				"",					"invalid 'sshpubkey': must be binary data",	"invalid 'sshpubkey': invalid SSH public key",	"" 	  	  } ));
		ll.add(Arrays.asList(new Object[]{ "add_negative_sshkey_duplicate",	"user9",	"",		"rsa",			"user9_rsa",		"no modifications to be performed",			"",												""  	  } ));        
		
		return ll;	
	}
	/*
	 * Data to be used when deleting sshpubkeys
	 */
	@DataProvider(name="getUserDeleteSSHPubKeyTestObjects")
	public Object[][] getUserDeleteSSHPubKeyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(userDeleteSSHPubKeyTestObjects());
	}
	protected List<List<Object>> userDeleteSSHPubKeyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname		 	uid	
		ll.add(Arrays.asList(new Object[]{ "delete_sshkey",		"user9"  	  } ));
		
		        
		return ll;	
	}
	
	/*
	 * Data to be used on undo of sshpubkeys
	 */
	
	@DataProvider(name="getUserEditUndoSSHPubKeyTestObjects")
	public Object[][] getUserEditUndoSSHPubKeyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editUndoSSHPubKeyTestObjects());
	}
	protected List<List<Object>> editUndoSSHPubKeyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname		 			uid			keyType1	keyType2	fileName1		fileName2		spanName	keyName1			keyName2		
		ll.add(Arrays.asList(new Object[]{ "add_undo_sshkey_rsa",		"user9",	"rsa",		"",			"user9_rsa1",	"",				"undo"/*,		"sshkey-status[2]",	"" */ 	  } ));
		ll.add(Arrays.asList(new Object[]{ "add_undoAll_sshkey",		"user9",	"rsa",		"dsa",		"user9_rsa1",	"user9_dsa1",	"undo all"/*,	"sshkey-status[2]",	"sshkey-status[3]"  */	  } ));
		return ll;	
	}
	
	/*
	 * Data to be used on Refresh/Reset/Update of sshpubkeys
	 */
	
	@DataProvider(name="getUserEditRefreshResetUpdateSSHPubKeyTestObjects")
	public Object[][] getUserEditRefreshResetUpdateSSHPubKeyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(userEditRefreshResetUpdateSSHPubKeyTestObjects());
	}
	protected List<List<Object>> userEditRefreshResetUpdateSSHPubKeyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname		 		uid			keyType		fileName		keyName1			spanName	
		ll.add(Arrays.asList(new Object[]{ "add_sshkey_refresh",	"user9",	"rsa",		"user9_rsa5",	"sshkey-status[4]",	"Refresh"  	  } ));
		ll.add(Arrays.asList(new Object[]{ "add_sshkey_reset",		"user9",	"rsa",		"user9_rsa5",	"sshkey-status[4]",	"Reset" 	  } ));
		ll.add(Arrays.asList(new Object[]{ "add_sshkey_update",		"user9",	"rsa",		"user9_rsa5",	"sshkey-status[4]",	"Update" 	  } ));       
		return ll;	
	}
	
	/*
	 * Data to be used on Update/Reset/Cancel of sshpubkeys
	 */
	
	@DataProvider(name="getUserEditUpdateResetCancelSSHPubKeyTestObjects")
	public Object[][] getUserEditUpdateResetCancelSSHPubKeyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(userEditUpdateResetCancelSSHPubKeyTestObjects());
	}
	protected List<List<Object>> userEditUpdateResetCancelSSHPubKeyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname		 				uid			keyType		fileName		keyName1			spanName	
		ll.add(Arrays.asList(new Object[]{ "add_sshkey_cancel_backlink",	"user9",	"rsa",		"user9_rsa6",	"sshkey-status[5]",	"Cancel"  	  } ));
		ll.add(Arrays.asList(new Object[]{ "add_sshkey_reset_backlink",		"user9",	"rsa",		"user9_rsa6",	"sshkey-status[5]",	"Reset" 	  } ));
		ll.add(Arrays.asList(new Object[]{ "add_sshkey_update1_backlink",	"user9",	"rsa",		"user9_rsa6",	"sshkey-status[5]",	"Update" 	  } ));       
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
	 * Data to be used when verify kerberos ticket policy
	 */
	@DataProvider(name="getKerberosTicketPolicyObjects")
	public Object[][] getKerberosTicketPolicyObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(kerberosTicketPolicyObject());
	}
	protected List<List<Object>> kerberosTicketPolicyObject() {			
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					uid    		Maxrenew		maxlife		  			       		
		ll.add(Arrays.asList(new Object[]{ "kerberos_ticket_policy",		"kuser",	"604800",   	"86400"	} ));
		  
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
	 * Data to be used when searching users that are not added
	 */
	@DataProvider(name="getUsersSearchNegativeTestObjects")
	public Object[][] getUsersSearchNegativeTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserSearchNegativeTestObjects());
	}
	protected List<List<Object>> createUserSearchNegativeTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				hostname1
		ll.add(Arrays.asList(new Object[]{ "search_users_negative",		"user005" } ));
		        
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
	
	@DataProvider(name="getbugverfication782981")
	public Object[][] getbugverfication782981() {
		return TestNGUtils.convertListOfListsTo2dArray(editBugverfication782981());
	}
	protected List<List<Object>> editBugverfication782981() {			
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName          uid       givenname            sn              password           newPassword 			       		
		ll.add(Arrays.asList(new Object[]{ "bug782981",	 "bug782981",	"bug782981",	"bug782981",		"bug782981",		"Secret123"		} ));
		  
		return ll;	
	}


}
