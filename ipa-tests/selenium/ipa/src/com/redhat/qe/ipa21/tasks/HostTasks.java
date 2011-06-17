package com.redhat.qe.ipa21.tasks;

import com.redhat.qe.auto.selenium.Element;
import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.ipa21.locators.UIElements;
import com.redhat.qe.ipa21.locators.HostUIElements;

public class HostTasks {
	
	private static com.redhat.qe.ipa21.locators.HostUIElements HostUI = new HostUIElements();
	
	public static void forceAddHost(ExtendedSelenium selenium, String hostName) {
		selenium.click(new Element(HostUI.link,"Add"));
		selenium.type(HostUI.hostNameInput, hostName);
		selenium.click(HostUI.forceFlag);
		selenium.click(HostUI.addButton);	
	}
	
	public static void modifyHost(ExtendedSelenium selenium, String hostName, String hostDescription) {
		selenium.click(new Element(HostUI.link,hostName));
		selenium.type(HostUI.hostDescriptionInput, hostDescription);
		selenium.click(new Element(HostUI.link,"Update"));
		selenium.click(new Element(HostUI.hostUpdateLink));	
	}
	
	
	public static void deleteHost(ExtendedSelenium selenium, String hostName) {
		selenium.click("css=.entity[name='host'] .facet[name='search'] input[value='hostName']");
		selenium.click("link=Delete");
		selenium.click("//button[@type='button']");
	}

}
