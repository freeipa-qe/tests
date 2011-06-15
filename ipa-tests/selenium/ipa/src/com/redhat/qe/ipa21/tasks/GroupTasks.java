package com.redhat.qe.ipa21.tasks;

import com.redhat.qe.auto.selenium.Element;
import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.ipa21.locators.UIElements;

public class GroupTasks {
	
	private static com.redhat.qe.ipa21.locators.UIElements UI = new UIElements();
	
		
	
	public static void createGroup(ExtendedSelenium selenium, String groupName, String description) {
		selenium.click(new Element(UI.link,"Add"));
		selenium.type(UI.groupNameInput, groupName);
		selenium.type(UI.descriptionInput, description);
		selenium.click(UI.addButton);	
	}

}
