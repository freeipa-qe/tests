package com.redhat.qe.ipa21.tasks;

import com.redhat.qe.auto.selenium.Element;
import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.ipa21.locators.UIElements;

public class UserTasks {
	
	private static com.redhat.qe.ipa21.locators.UIElements UI = new UIElements();	
	
	
	/*
	 * Create a new user. Check if user already exists before calling this.
	 * @param selenium 
	 * @param uid - uid for the new user
	 * @param givenName - first name for the new user
	 * @param sn - last name for the new user
	 */
	public static void createUser(ExtendedSelenium selenium, String uid, String givenName, String sn) {
		selenium.click(new Element(UI.link,"Add"));
		selenium.type(UI.userNameInput, uid);
		selenium.type(UI.givennameInput, givenName);
		selenium.type(UI.snInput, sn);
		selenium.click(UI.addButton);	
	}
	
	/* Edit the user. Check if user is available for editing before calling this.
	 * @param selenium
	 * @param uid - the uid of user to be edited
	 * @param title - title string being edited for this user
	 * @param mail - mail string being edited for this user
	 */
	public static void modifyUser(ExtendedSelenium selenium, String uid, String title, String mail) {
		selenium.click(new Element(UI.link,uid));
		selenium.type(UI.titleInput, title);
		selenium.click(new Element(UI.userMailLink));
		//TODO: have to wait....can do this when stepping through
		selenium.type(UI.mailInput, mail);
		selenium.click(new Element(UI.link,"Update"));
		selenium.click(new Element(UI.updateLink));
	}
	
	/*
	 * Delete the user. Check if user is available for deleting before calling this.
	 * @param selenium
	 * @param uid - the uid of user to be deleted
	 */
	public static void deleteUser(ExtendedSelenium selenium, String uid) {
		selenium.click(UI.testuserDeleteLink);
		selenium.click(new Element(UI.link,"Delete"));
		selenium.click(UI.button);
	}
	
	/*
	 * Recreate a user. Check if user already exists before calling this.
	 * @param selenium 
	 * @param userName - uid for the existing user
	 * @param givenName - first name for the existing user
	 * @param sn - last name for the existing user
	 */
	public static void recreateUser(ExtendedSelenium selenium, String uid, String givenName, String sn) {
		selenium.click(new Element(UI.link,"Add"));
		selenium.type(UI.userNameInput, uid);
		selenium.type(UI.givennameInput, givenName);
		selenium.type(UI.snInput, sn);
		selenium.click(UI.addButton);	
		//verify error message
		
	}

}
