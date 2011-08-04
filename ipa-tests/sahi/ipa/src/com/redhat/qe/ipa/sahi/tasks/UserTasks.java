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
	public static void createUser(SahiTasks sahiTasks, String uid, String givenName, String sn, String buttonToClick) {
		sahiTasks.link("Add").click();
		sahiTasks.link("Optional field: click to show").click();
		sahiTasks.textbox("uid").setValue(uid);
		sahiTasks.textbox("givenname").setValue(givenName);
		sahiTasks.textbox("sn").setValue(sn);
		sahiTasks.button(buttonToClick).click();
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
		sahiTasks.link("Add").click();
		sahiTasks.textbox("mail").setValue(mail);
		
		//Update and go back to user list
		sahiTasks.link("Update").click();
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	
	public static void modifyUserIdentitySettings(SahiTasks sahiTasks, String uid, String givenname, String sn, 
			String fullname, String displayName, String initials) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		sahiTasks.textbox("givenname").setValue(givenname);
		sahiTasks.textbox("sn").setValue(sn);
		sahiTasks.textbox("cn").setValue(fullname);
		sahiTasks.textbox("displayname").setValue(displayName);
		sahiTasks.textbox("initials").setValue(initials);
				
		//Update and go back to user list
		sahiTasks.link("Update").click();
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	public static void modifyUserAccountSettings(SahiTasks sahiTasks, String uid, String uidnumber, String gidnumber, String loginshell, String homedirectory) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		sahiTasks.textbox("uidnumber").setValue(uidnumber);
		sahiTasks.textbox("gidnumber").setValue(gidnumber);
		sahiTasks.textbox("loginshell").setValue(loginshell);
		sahiTasks.textbox("homedirectory").setValue(homedirectory);
				
		//Update and go back to user list
		sahiTasks.link("Update").click();
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	
	public static void modifyUserAccountSettingsForInvalidUID(SahiTasks sahiTasks, String uid, String invalidUID, String expectedError) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		sahiTasks.textbox("uidnumber").setValue(invalidUID);
		//Check for expected error
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.span(expectedError).exists(), "Verified expected error when changing UID to " + invalidUID);
						
		//Undo and go back to user list
		sahiTasks.span("undo").click();
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	public static void modifyUserMailingAddress(SahiTasks sahiTasks, String uid, String street, String city, String state, String zip) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		sahiTasks.textbox("street").setValue(street);
		sahiTasks.textbox("l").setValue(city);
		sahiTasks.textbox("st").setValue(state);
		sahiTasks.textbox("postalcode").setValue(zip);
				
		//Update and go back to user list
		sahiTasks.link("Update").click();
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	
	public static void modifyUserEmpMiscInfo(SahiTasks sahiTasks, String uid, String org, String manager, String carlicense) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		sahiTasks.textbox("ou").setValue(org);
		sahiTasks.select("list").choose(manager);
		sahiTasks.textbox("carlicense").setValue(carlicense);
				
		//Update and go back to user list
		sahiTasks.link("Update").click();
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	public static void addMultipleUserData(SahiTasks sahiTasks, String uid, String mail1, String mail2, String	mail3, 
			String phone1, String phone2, String pager1, String pager2, String mobile1, String mobile2, String fax1, String fax2) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		
		sahiTasks.link("Add").click();
		sahiTasks.textbox("mail").setValue(mail1);
		sahiTasks.link("Add").click();
		sahiTasks.textbox("mail[1]").setValue(mail2);
		sahiTasks.link("Add").click();
		sahiTasks.textbox("mail[2]").setValue(mail3);
		
		sahiTasks.link("Add[1]").click();
		sahiTasks.textbox("telephonenumber").setValue(phone1);
		sahiTasks.link("Add[1]").click();
		sahiTasks.textbox("telephonenumber[1]").setValue(phone2);
		
		sahiTasks.link("Add[2]").click();
		sahiTasks.textbox("pager").setValue(pager1);
		sahiTasks.link("Add[2]").click();
		sahiTasks.textbox("pager[1]").setValue(pager2);
		
		sahiTasks.link("Add[3]").click();
		sahiTasks.textbox("mobile").setValue(mobile1);
		sahiTasks.link("Add[3]").click();
		sahiTasks.textbox("mobile[1]").setValue(mobile2);
		
		sahiTasks.link("Add[4]").click();
		sahiTasks.textbox("facsimiletelephonenumber").setValue(fax1);
		sahiTasks.link("Add[4]").click();
		sahiTasks.textbox("facsimiletelephonenumber[1]").setValue(fax2);
		
		//Update and go back to user list
		sahiTasks.link("Update").click();
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	
	/* Verify changes made for the user. 
	 * @param sahiTasks
	 * @param uid - the uid of user to be edited
	 * @param title - title string being edited for this user
	 * @param mail - mail string being edited for this user
	 */
	public static void verifyUserContactData(SahiTasks sahiTasks, String uid, String mail1, String mail2, String	mail3, 
			String phone1, String phone2, String pager1, String pager2, String mobile1, String mobile2, String fax1, String fax2) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//verify mail address for user
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("mail").value(), mail1, "Verified mail for user " + uid + ": " + mail1);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("mail[1]").value(), mail2, "Verified mail for user " + uid + ": " + mail2);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("mail[2]").value(), mail3, "Verified mail for user " + uid + ": " + mail3);
		
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("telephonenumber").value(), phone1, "Verified phone for user " + uid + ": " + phone1);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("telephonenumber[1]").value(), phone2, "Verified phone for user " + uid + ": " + phone2);
		
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("pager").value(), pager1, "Verified pager for user " + uid + ": " + pager1);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("pager[1]").value(), pager2, "Verified pager for user " + uid + ": " + pager2);
	
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("mobile").value(), mobile1, "Verified mobile for user " + uid  + ": " + mobile1);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("mobile[1]").value(), mobile2, "Verified mobile for user " + uid + ": " + mobile2);
	
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("facsimiletelephonenumber").value(), fax1, "Verified fax for user " + uid  + ": " + fax1);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("facsimiletelephonenumber[1]").value(), fax2, "Verified fax for user " + uid + ": " + fax2);
	
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	
	public static void addDeleteUndoResetContactData(SahiTasks sahiTasks, String uid, String mail, String phone) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//Add but Reset		
		sahiTasks.link("Add").click();
		sahiTasks.span("Reset").click();
		
		//Delete but Reset
		sahiTasks.link("Delete").click();
		sahiTasks.span("Reset").click();
		
		//Edit - then Reset
		sahiTasks.textbox("mail").setValue(mail+mail);
		sahiTasks.span("Reset").click();
		
		//Add - then undo
		sahiTasks.link("Add").click();
		sahiTasks.span("undo").click();
		
		//Delete - then undo
		sahiTasks.link("Delete").click();
		sahiTasks.span("undo").click();
		
		//Edit - then undo
		sahiTasks.textbox("telephonenumber").setValue(phone+phone);
		sahiTasks.span("undo").click();
		
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	public static void verifyUserUpdates(SahiTasks sahiTasks, String uid, String title, String mail) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//verify user's job title
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("title").value(), title, "Verified updated title for user " + uid);
		
		//verify mail address for user
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("mail").value(), mail, "Verified updated mail for user " + uid);
		
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	
	
	public static void verifyUserIdentitySettings(SahiTasks sahiTasks, String uid, String givenname, String sn, String fullname, String displayName, String initials) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//verify user's job title
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("givenname").value(), givenname, "Verified updated First name for user " + uid + ": " + givenname);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("sn").value(), sn, "Verified updated Last name for user " + uid + ": " + sn);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("cn").value(), fullname, "Verified updated Full Name for user " + uid + ": " + fullname);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("displayname").value(), displayName, "Verified updated Display name for user " + uid + ": " + displayName);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("initials").value(), initials, "Verified updated firstname for user " + uid + ": " + initials);
		
		
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	
	public static void verifyUserAccountSettings(SahiTasks sahiTasks, String uid, String uidnumber, String gidnumber, String loginshell, String homedirectory) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//verify user's job title
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("uidnumber").value(), uidnumber, "Verified updated UID for user " + uid + ": " + uidnumber);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("gidnumber").value(), gidnumber, "Verified updated GID for user " + uid + ": " + gidnumber);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("loginshell").value(), loginshell, "Verified updated Login Shell for user " + uid + ": " + loginshell);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("homedirectory").value(), homedirectory, "Verified updated Home directory for user " + uid + ": " + homedirectory);
		
		
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	
	public static void verifyUserMailingAddress(SahiTasks sahiTasks, String uid, String street, String city, String state, String zip) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//verify user's job title
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("street").value(), street, "Verified updated street for user " + uid + ": " + street);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("l").value(), city, "Verified updated city for user " + uid + ": " + city);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("st").value(), state, "Verified updated State for user " + uid + ": " + state);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("postalcode").value(), zip, "Verified updated Zip for user " + uid + ": " + zip);
		
		
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	public static void verifyUserEmpMiscInfo(SahiTasks sahiTasks, String uid, String org, String manager, String carlicense) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//verify user's job title
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("ou").value(), org, "Verified updated Org. Unit for user " + uid + ": " + org);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("manager").value(), manager, "Verified updated Manager for user " + uid + ": " + manager);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("carlicense").value(), carlicense, "Verified updated car license for user " + uid + ": " + carlicense);
		
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
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
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link("Click to Deactivate").exists(), "Verified Active status for user " + uid);
		else
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link("Click to Activate").exists(), "Verified Inactive status for user " + uid);
	
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	/* Update the user status. 
	 * @param sahiTasks
	 * @param uid - the uid of user to be edited
	 */
	public static void modifyUserStatus(SahiTasks sahiTasks, String uid, boolean newStatus, String buttonToClick) {		
		//click on user to edit
		sahiTasks.link(uid).click();
		
		//edit user's job title
		if (newStatus)
			sahiTasks.link("Click to Activate").click();
		else
			sahiTasks.link("Click to Deactivate").click();
		sahiTasks.button(buttonToClick).click();
		//go back to user list
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
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
		
		// go back to user list
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
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
		sahiTasks.link("Add").click();
		sahiTasks.textbox("mail").setValue(mail);
		sahiTasks.span("Update").click();
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	public static void searchUser(SahiTasks sahiTasks, String uid) {
		sahiTasks.textbox("filter").setValue(uid);
		sahiTasks.span("icon search-icon").click();
	}	
	
	
	public static void expandCollapseUser(SahiTasks sahiTasks, String uid) {
		//click on user to edit
		sahiTasks.link(uid).click();
		
		sahiTasks.span("Collapse All").click();
		sahiTasks.waitFor(1000);

		//Verify no data is visible
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.textbox("title").exists(), "No data is visible");
		
		
		sahiTasks.heading2("Account Settings").click();
		//Verify only data for account settings is displayed
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.label(uid).exists(), "Verified data available for user " + uid);
		
		
		sahiTasks.span("Expand All").click();
		sahiTasks.waitFor(1000);
		//Verify data is visible
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.textbox("title").exists(), "Now Data is visible");
		
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();	
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
