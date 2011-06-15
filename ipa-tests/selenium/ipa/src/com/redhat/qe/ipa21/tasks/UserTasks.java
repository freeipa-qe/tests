package com.redhat.qe.ipa21.tasks;

import com.redhat.qe.auto.selenium.Element;
import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.ipa21.locators.UIElements;

public class UserTasks {
	
	private static com.redhat.qe.ipa21.locators.UIElements UI = new UIElements();	
	
	
	/*
	 * Create a new user. Check if user already exists before calling this.
	 * @param selenium 
	 * @param userName - uid for the new user
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
	
	public static void modifyUser(ExtendedSelenium selenium, String uid) {
		selenium.click(new Element(UI.link,uid));
		selenium.type(UI.titleInput, "Software Engineer");
		selenium.click(new Element(UI.userMailLink));
		selenium.waitForPageToLoad();
		//CommonTasks.waitForRefreshTillTextPresent(selenium, "undo");
		selenium.type(UI.mailInput, "testuser@example.com");
		selenium.click(new Element(UI.link,"Update"));
		selenium.click(new Element(UI.updateLink));
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
