package com.redhat.qe.ipa21.tasks;

import com.redhat.qe.auto.selenium.Element;
import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.ipa21.locators.UIElements;

public class GroupTasks {
	
	private static com.redhat.qe.ipa21.locators.UIElements UI = new UIElements();
	
	
	public static Element groupNameInput = new Element ("cn");
	public static Element descriptionInput = new Element ("description");
	public static Element addButton = new Element("//button[@type='button']");
	
	public static void createGroup(ExtendedSelenium selenium, String groupName, String description) {
		selenium.click(new Element(UI.link,"Add"));
		selenium.type(groupNameInput, groupName);
		selenium.type(descriptionInput, description);
		selenium.click(addButton);	
	}

}
