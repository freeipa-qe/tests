package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;


public class UserTasks {
	private static Logger log = Logger.getLogger(UserTasks.class.getName());
	
	/*
	 * Create a new user. Check if user already exists before calling this.
	 * @param sahiTasks 
	 * @param uid - uid for the new user
	 * @param givenName - first name for the new user
	 * @param sn - last name for the new user
	 */
	public static void createUser(SahiTasks sahiTasks, String uid, String givenName, String sn) {
		sahiTasks.link("Add").click();
		sahiTasks.link("Optional field: click to show").click();
		sahiTasks.textbox("uid").setValue(uid);
		sahiTasks.textbox("givenname").setValue(givenName);
		sahiTasks.textbox("sn").setValue(sn);
		sahiTasks.button("Add").click();
	}
	
	/*
	 * Create a new invalid user.
	 * @param sahiTasks 
	 * @param uid - uid for the new user
	 * @param givenName - first name for the new user
	 * @param sn - last name for the new user
	 * @param expectedError - the error thrown when an invalid user is being attempted to be added
	 */
	public static void createInvalidUser(SahiTasks sahiTasks, String uid, String givenName, String sn, String expectedError) {
		sahiTasks.link("Add").click();
		sahiTasks.link("Optional field: click to show").click();
		sahiTasks.textbox("uid").near(sahiTasks.label("User login:")).setValue(uid);
		sahiTasks.textbox("givenname").near(sahiTasks.label("First name:")).setValue(givenName);
		sahiTasks.textbox("sn").near(sahiTasks.label("Last name:")).setValue(sn);
		sahiTasks.button("Add").near(sahiTasks.button("Add and Add Another")).click();
		//Check for expected error
		log.fine("error check");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding invalid user " + uid);
		// since the add user window and the message window have Cancel buttons
		// specify which cancel button to hit by indicating what is near it.
		// TODO: Remove ref later: http://sahi.co.in/w/sahi-api-examples
		// TODO: Remove ref later: http://sahi.co.in/java/javadocs/net/sf/sahi/client/ElementStub.html#near%28net.sf.sahi.client.ElementStub%29
		log.fine("cancel(near retry)");
		sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
		log.fine("cancel");
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}
	
	/*
	 * Create a new invalid user with invalid char in uid
	 * @param sahiTasks 
	 * @param uid - uid for the new user
	 * @param givenName - first name for the new user
	 * @param sn - last name for the new user
	 * @param expectedError - the error thrown when an invalid user is being attempted to be added
	 */
	public static void createInvalidCharUser(SahiTasks sahiTasks, String uid, String givenName, String sn, String expectedError) {
		sahiTasks.link("Add").click();
		sahiTasks.link("Optional field: click to show").click();
		sahiTasks.textbox("uid").near(sahiTasks.label("User login:")).setValue(uid);
		sahiTasks.textbox("givenname").near(sahiTasks.label("First name:")).setValue(givenName);
		sahiTasks.textbox("sn").near(sahiTasks.label("Last name:")).setValue(sn);
		//Check for expected error
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.span(expectedError).exists(), "Verified expected error when adding invalid user " + uid);
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}
	
	/* Edit the user. Check if user is available for editing before calling this.
	 * @param sahiTasks
	 * @param uid - the uid of user to be edited
	 * @param title - title string being edited for this user
	 * @param mail - mail string being edited for this user
	 */
	public static void modifyUser(SahiTasks sahiTasks, String uid, String title, String mail) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//edit user's job title
		sahiTasks.textbox("title").setValue(title);
		
		//add a mail address for user
		sahiTasks.link("Add[1]").click();
		sahiTasks.textbox("mail").setValue(mail);
		
		//Update and go back to user list
		sahiTasks.link("Update").click();
		sahiTasks.link("Users[1]").click();
	}
	
	
	/* Verify changes made for the user. 
	 * @param sahiTasks
	 * @param uid - the uid of user to be edited
	 * @param title - title string being edited for this user
	 * @param mail - mail string being edited for this user
	 */
	public static void verifyUserUpdates(SahiTasks sahiTasks, String uid, String title, String mail) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//verify user's job title
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("title").value(), title, "Verified updated title for user " + uid);
		
		//verify mail address for user
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("mail").value(), mail, "Verified updated mail for user " + uid);
		sahiTasks.link("Users[1]").click();
	}
	
	
	/* Verify status for the user. 
	 * @param sahiTasks
	 * @param uid - the uid of user to be edited
	 */
	public static void verifyUserStatus(SahiTasks sahiTasks, String uid, boolean status) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//verify user's status
		if (status)
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link("Active: Click to Deactivate").exists(), "Verified Active status for user " + uid);
		else
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link("Inactive: Click to Activate").exists(), "Verified Inactive status for user " + uid);
		
		sahiTasks.link("Users[1]").click();
	}
	
	/* Update the user status. 
	 * @param sahiTasks
	 * @param uid - the uid of user to be edited
	 */
	public static void modifyUserStatus(SahiTasks sahiTasks, String uid, boolean newStatus) {		
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//edit user's job title
		if (newStatus)
			sahiTasks.link("Inactive: Click to Activate").click();
		else
			sahiTasks.link("Active: Click to Deactivate").click();
		
		// Update and go back to user list
		// FIXME: BUG 
		// sahiTasks.link("Update").click();
		sahiTasks.link("Users[1]").click();
	}
	
	
	/* Reset user password. 
	 * @param sahiTasks
	 * @param uid - the uid of user to be edited
	 */
	public static void modifyUserPassword(SahiTasks sahiTasks, String uid, String password) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//reset user's password
		sahiTasks.link("Reset Password").click();
		sahiTasks.password(0).setValue(password);
		sahiTasks.password(1).setValue(password);
		sahiTasks.button("Reset Password").click();
		
		// Update and go back to user list
		// FIXME: BUG 
		// sahiTasks.link("Update").click();
		sahiTasks.link("Users[1]").click();
	}
	
	/*
	 * Delete the user. Check if user is available for deleting before calling this.
	 * @param sahiTasks
	 * @param uid - the uid of user to be deleted
	 */
	public static void deleteUser(SahiTasks sahiTasks, String uid) {
		sahiTasks.checkbox(uid).click();
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	
	/*
	 * Choose multiple users. 
	 * @param sahiTasks
	 * @param uid - the uid of user to be deleted
	 */
	public static void chooseMultipleUsers(SahiTasks sahiTasks, String uid) {		
		sahiTasks.checkbox(uid).click();		
	}
	
	/*
	 * Delete multiple users. 
	 * @param sahiTasks
	 * @param uid - the uid of user to be deleted
	 */
	public static void deleteMultipleUser(SahiTasks sahiTasks) {		
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	
	/*
	 * Recreate a user. Check if user already exists before calling this.
	 * @param selenium 
	 * @param userName - uid for the existing user
	 * @param givenName - first name for the existing user
	 * @param sn - last name for the existing user
	 */
	public static void recreateUser(SahiTasks sahiTasks, String uid, String givenName, String sn) {		
		sahiTasks.link("Add").click();
		sahiTasks.textbox("uid[1]").setValue(uid);
		sahiTasks.textbox("givenname[1]").setValue(givenName);
		sahiTasks.textbox("sn[1]").setValue(sn);
		sahiTasks.button("Add").click();
		//Check for expected error
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.div("user with name \"" + uid + "\" already exists").exists(), "Verified expected error when readding user " + uid);
		sahiTasks.button("Cancel").click();
		sahiTasks.button("Cancel").click();
	}

	/*
	 * Create a new user. Then add another user. Check if users already exists before calling this.
	 * @param sahiTasks 
	 * @param givenName1 - first name for the first user to be added
	 * @param sn1 - last name for the first user to be added
	 * @param givenName2 - first name for the second user to be added
	 * @param sn2 - last name for the second user to be added
	 */
	public static void createUserThenAddAnother(SahiTasks sahiTasks, String givenName1, String sn1, String givenName2, String sn2) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("givenname").setValue(givenName1);
		sahiTasks.textbox("sn").setValue(sn1);
		sahiTasks.button("Add and Add Another").click();
		sahiTasks.textbox("givenname").setValue(givenName2);
		sahiTasks.textbox("sn").setValue(sn2);
		sahiTasks.button("Add").click();	
	}
	
	
	/*
	 * Create a new user. Then edit this user. Check if users already exists before calling this.
	 * @param sahiTasks 
	 * @param givenName - first name for the new user to be added
	 * @param sn - last name for the new user to be added
	 * 
	 */
	public static void createUserThenEdit(SahiTasks sahiTasks, String uid, String givenName, String sn, String title, String mail) {
		sahiTasks.span("Add").click();
		sahiTasks.link("Optional field: click to show").click();
		sahiTasks.textbox("uid").setValue(uid);
		sahiTasks.textbox("givenname").setValue(givenName);
		sahiTasks.textbox("sn").setValue(sn);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.textbox("title").setValue(title);
		sahiTasks.link("Add[1]").click();
		sahiTasks.textbox("mail").setValue(mail);
		sahiTasks.span("Update").click();
		sahiTasks.link("Users[1]").click();
	}
	
	/*
	 * Verify User membership in a group or rule
	 * @param sahiTasks 
	 * @param uid
	 * @param membertype - "User Groups" or "Netgroups" or "Roles" or "HBAC Rules" or "Sudo Rules"
	 * @param grprulename - group or rule name 
	 * @param exists - "YES" if the membership is expected to exist
	 */
	public static void verifyUserMemberOf(SahiTasks sahiTasks, String uid, String membertype, String grprulename, String exists) {
		sahiTasks.link(uid).click();
		if (membertype == "User Groups"){
			sahiTasks.link("memberof_group").click();
		}
		if (membertype == "Netgroups"){
			sahiTasks.link("memberof_netgroup").click();
		}
		if (membertype =="Roles"){
			sahiTasks.link("memberof_role").click();
		}
		if (membertype == "HBAC Rules"){
			sahiTasks.link("memberof_hbacrule").click();
		}
		if (membertype == "Sudo Rules"){
			sahiTasks.link("memberof_sudorule").click();
		}
	
		if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(grprulename).exists(), "User " + uid + " is a member of " + membertype + " " + grprulename);
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(grprulename).exists(), "User " + uid + " is NOT member of " + membertype + " "+ grprulename);
		}
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Verify User membership in a group or rule
	 * @param sahiTasks 
	 * @param uid
	 * @param membertype - "User Groups" or "Netgroups" or "Roles" or "HBAC Rules" or "Sudo Rules"
	 * @param grprulenames - array of group or rule names 
	 * @param exists - "YES" if the membership is expected to exist
	 */
	public static void verifyUserMemberOf(SahiTasks sahiTasks, String uid, String membertype, String [] grprulenames, String exists) {
		sahiTasks.link(uid).click();
		if (membertype == "User Groups"){
			sahiTasks.link("memberof_group").click();
		}
		if (membertype == "Netgroups"){
			sahiTasks.link("memberof_netgroup").click();
		}
		if (membertype =="Roles"){
			sahiTasks.link("memberof_role").click();
		}
		if (membertype == "HBAC Rules"){
			sahiTasks.link("memberof_hbacrule").click();
		}
		if (membertype == "Sudo Rules"){
			sahiTasks.link("memberof_sudorule").click();
		}
		for (String grprulename : grprulenames){
			if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(grprulename).exists(), "User " + uid + " is a member of " + membertype + " " + grprulename);
			}
			else {
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(grprulename).exists(), "User " + uid + " is NOT member of " + membertype + " "+ grprulename);
			}
		}
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
}
