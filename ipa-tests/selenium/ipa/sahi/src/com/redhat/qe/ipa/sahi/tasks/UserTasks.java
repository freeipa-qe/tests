package com.redhat.qe.ipa.sahi.tasks;


public class UserTasks {
	
	
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
		
	}
	
	/*
	 * Delete the user. Check if user is available for deleting before calling this.
	 * @param sahiTasks
	 * @param uid - the uid of user to be deleted
	 */
	public static void deleteUser(SahiTasks sahiTasks, String uid) {
		
	}
	
	/*
	 * Recreate a user. Check if user already exists before calling this.
	 * @param selenium 
	 * @param userName - uid for the existing user
	 * @param givenName - first name for the existing user
	 * @param sn - last name for the existing user
	 */
	public static void recreateUser(SahiTasks sahiTasks, String uid, String givenName, String sn) {
		
		
	}

}
