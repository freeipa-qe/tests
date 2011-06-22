package com.redhat.qe.ipa21.tasks;

import com.redhat.qe.auto.selenium.Element;
import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.ipa21.locators.GroupUIElements;
import com.redhat.qe.ipa21.locators.UIElements;

public class GroupTasks {
	 
	private static com.redhat.qe.ipa21.locators.GroupUIElements GroupUI = new GroupUIElements();

	
	public static void createGroup(ExtendedSelenium selenium, String groupName, String description) {
		selenium.click(new Element(GroupUI.link,"Add"));
		selenium.type(GroupUI.groupNameInput, groupName);
		selenium.type(GroupUI.groupDescriptionInput, description);
		selenium.click(GroupUI.addButton);	
	}

	public static void deleteGroup(ExtendedSelenium selenium, String groupName) {
		selenium.click("//input[@name='select' and @value='" + groupName + "']");
		selenium.click("link=Delete"); 
		selenium.click(GroupUI.deleteButton);	
	}
	
}//class GroupTasks
