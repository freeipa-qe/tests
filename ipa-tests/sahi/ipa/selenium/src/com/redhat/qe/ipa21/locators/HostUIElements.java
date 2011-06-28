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
 * A container for Host UI locators that are common to more than one page in the 
 * IPA application. 
 * 
 * @author jgalipea
 *
 */

public class HostUIElements extends UILocatorStrategies  {

	public HostUIElements(){
		
	}

	public ExtendedSelenium sel(){
		return SeleniumTestScript.selenium;
	}
	
	// Locator Strategies
	public LocatorStrategy link = new StringSandwichLocatorStrategy("link", "link=");
	
	public Element addButton = new Element("//button[@type='button']");
	public Element deleteButton = new Element("Delete");
	public Element updateButton = new Element ("//button[@type='button']");
		
	//Identity - Host - Add	
	public Element hostNameInput = new Element ("fqdn");
	public Element forceFlag = new Element ("force");
	
	//Identity - Host - Edit
	public Element hostDescriptionInput = new Element ("description");
	public LocatorStrategy updateLink = new StringSandwichLocatorStrategy("updateLink", "css=span.input_link");
	
	//Identity - Host - Delete
	public Element hostDeleteLink = new Element("css=.entity[name='host'] .facet[name='search'] input[value='hostName']");

	public String hostUpdateLink;
}
