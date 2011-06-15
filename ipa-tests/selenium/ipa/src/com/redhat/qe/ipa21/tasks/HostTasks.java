package com.redhat.qe.ipa21.tasks;

import com.redhat.qe.auto.selenium.Element;
import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.ipa21.locators.UIElements;

public class HostTasks {
	
	private static com.redhat.qe.ipa21.locators.UIElements UI = new UIElements();
	
	public static void forceAddHost(ExtendedSelenium selenium, String hostName) {
		selenium.click(new Element(UI.link,"Add"));
		selenium.type(UI.hostNameInput, hostName);
		selenium.click(UI.forceFlag);
		selenium.click(UI.addButton);	
	}
	
	
	public static void deleteHost(ExtendedSelenium selenium, String hostName) {
		selenium.getAllFields();
	}

}
