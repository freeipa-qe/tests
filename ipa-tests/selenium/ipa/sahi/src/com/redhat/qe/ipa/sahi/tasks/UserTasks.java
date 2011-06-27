package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.base.SahiTestScript;


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
		sahiTasks.textbox("uid").setValue(uid);
		sahiTasks.textbox("givenname").setValue(givenName);
		sahiTasks.textbox("sn").setValue(sn);
		sahiTasks.button("Add").click();	
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
		sahiTasks.span("\u25c0 Back to List").click();
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

}
