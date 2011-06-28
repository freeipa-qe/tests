package com.redhat.qe.ipa21.locators;

import com.redhat.qe.auto.selenium.Element;
import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.auto.selenium.LocatorStrategy;
import com.redhat.qe.auto.selenium.StringSandwichLocatorStrategy;
import com.redhat.qe.ipa.base.SeleniumTestScript;

/**
 * A container for User UI locators that are common to more than one page in the 
 * IPA application. 
 * 
 * @author nkrishnan
 *
 */

public class UserUIElements {
    public UserUIElements(){
		
	}

	public ExtendedSelenium sel(){
		return SeleniumTestScript.selenium;
	}
	
	//Identity - User - Add
	public Element userNameInput = new Element ("uid");
	public Element givennameInput = new Element ("givenname");
	public Element snInput = new Element ("sn");
	
	//Identity - User - Edit
	public Element titleInput = new Element ("title");
	public Element mailInput = new Element ("mail");
	public Element undoInput = new Element ("undo");
	public LocatorStrategy userMailLink = new StringSandwichLocatorStrategy("userMailLink", "css=span[name=mail] a[name=add]");
	public LocatorStrategy updateLink = new StringSandwichLocatorStrategy("updateLink", "css=span.input_link");
	
}
