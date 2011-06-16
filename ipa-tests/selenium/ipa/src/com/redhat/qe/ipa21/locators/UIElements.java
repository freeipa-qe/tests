package com.redhat.qe.ipa21.locators;


import com.redhat.qe.auto.paginate.IPager;
import com.redhat.qe.auto.selenium.CombinedLocatorTemplate;
import com.redhat.qe.auto.selenium.Element;
import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.auto.selenium.LocatorSandwich;
import com.redhat.qe.auto.selenium.LocatorStrategy;
import com.redhat.qe.auto.selenium.LocatorTemplate;
import com.redhat.qe.auto.selenium.StringSandwichLocatorStrategy;
import com.redhat.qe.auto.selenium.TabElement;
import com.redhat.qe.auto.selenium.UILocatorStrategies;
import com.redhat.qe.ipa.base.SeleniumTestScript;



/**
 * A container for UI locators that are common to more than one page in the 
 * IPA application. 
 * 
 * @author nkrishnan
 *
 */


public class UIElements extends UILocatorStrategies  {
	
	public UIElements(){
		
	}

	public ExtendedSelenium sel(){
		return SeleniumTestScript.selenium;
	}
	
	// Locator Strategies
	public LocatorStrategy link = new StringSandwichLocatorStrategy("link", "link=");
	
	public Element addButton = new Element("//button[@type='button']");
	public Element button = new Element("//button[@type='button']");
	
	
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
	
	//Identity - User - Delete
	public Element testuserDeleteLink = new Element("css=.entity[name='user'] .facet[name='search'] input[value='testuser']");
	
	//Identity - Group - Add
	public Element groupNameInput = new Element ("cn");
	public Element groupDescriptionInput = new Element ("description");
		
	//Identity - Host - Add	
	public Element hostNameInput = new Element ("fqdn");
	public Element forceFlag = new Element ("force");
}
