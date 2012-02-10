package com.redhat.qe.ipa.sahi.tests.automount;

import java.util.*;
import java.util.logging.Logger;
import org.testng.annotations.*;

import com.redhat.qe.auto.testng.Assert; 
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonHelper;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.AutomountTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class AutomountTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(AutomountTests.class.getName());
	private static SahiTasks browser;
 	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		browser = sahiTasks;
		browser.navigateTo(commonTasks.automountPage, true);
		browser.setStrictVisibilityCheck(true); 
	}//initialize
	
	@AfterClass (groups={"cleanup"} , description="Restore the default  when test is done", alwaysRun=true)
	public void testcleanup() throws CloneNotSupportedException {
		// place holder: for now, I don't have anything.
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		// ensure the starting page for each test case is the automount page
		String currentURL = browser.fetch("top.location.href"); 
		CommonTasks.checkError(sahiTasks);
		if (!currentURL.equals(commonTasks.automountPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+commonTasks.automountPage +")");
			browser.navigateTo(commonTasks.automountPage, true);
		}
	}//checkURL
	
	@AfterMethod (alwaysRun=true)
	public void checkPossibleError(){
		// check possible error, i don't have anything here for now
	}//checkPossibleError
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//                               test cases                                                         //
	//////////////////////////////////////////////////////////////////////////////////////////////////////

	/////////// add automount location /////////////////////////
	@Test (groups={"addAutomountLocation"}, dataProvider="addAutomountLocation",
		description = "add new automount location via 'Add' button")
	public void addAutomountLocation_add(String automountLocation) throws Exception {  
		Assert.assertFalse(browser.link(automountLocation).exists(), "before add, automount location (" + automountLocation + ")should NOT exist in list");
		AutomountTasks.addAutomountLocation(browser, automountLocation);  
		Assert.assertTrue(browser.link(automountLocation).exists(), "after add, automount location (" + automountLocation + ") should exist in list");
	}

	@Test (groups={"addAutomountLocation"}, dataProvider="addAutomountLocation_addandaddanother",
		description = "add new automount via 'Add and Add Another' button")
	public void addAutomount_addandaddanother(String automountLocations) throws Exception {  
		String[] locations = CommonHelper.stringToArray(automountLocations);
		for (String location:locations)
			Assert.assertFalse(browser.link(location).exists(), "before add, location ["+location+"] does not exist");
		AutomountTasks.addAutomountLocationAddAndAddAnother(browser, locations);
		for (String location:locations)
			Assert.assertTrue(browser.link(location).exists(), "after add, location ["+location+"] does exist");
	}

	@Test (groups={"addAutomountLocation"}, dataProvider="addAutomountLocation_addthenedit",
		description = "add new automount via 'Add and Edit' button")
	public void addAutomount_addthenedit(String automountLocation) throws Exception {  
		Assert.assertFalse(browser.link(automountLocation).exists(), "before add, automount location (" + automountLocation + ") should NOT exist in list");
		browser.span("Add").click();
		browser.textbox("cn").setValue(automountLocation);
		browser.button("Add and Edit").click();
		if (browser.link("details").exists() && browser.link("maps").exists())
		{
			log.info("in edit mode, test success, now go back to automount ");
			browser.link("Automount Locations").in(browser.span("back-link")).click(); 
		}
		else{
			log.info("not in edit mode, test failed");
			Assert.assertTrue(false, "after click 'Add and Edit' we are not in edit mode, test failed");
		}
		Assert.assertTrue(browser.link(automountLocation).exists(), "after add, automount location (" + automountLocation + ") should exist in list");
	}

	@Test (groups={"addAutomountLocation"},  dataProvider="addAutomountLocation_addthencancel",
		description = "add new automount via 'Add' then click 'Cancel', expect no new automount location being added")
	public void addAutomount_addthencancel(String automountLocation) throws Exception {  
		Assert.assertFalse(browser.link(automountLocation).exists(), "before add, automount location (" + automountLocation + ")should NOT exist in list");
		AutomountTasks.addAutomountLocationAddThenCancel(browser,automountLocation);
		Assert.assertFalse(browser.link(automountLocation).exists(), "after add, automount location (" + automountLocation + ") should NOT exist in list as well");
	}

	@Test (groups={"addAutomountLocation_negative"},
		description = "no duplicated automount location is allowed")
	public void addAutomount_negative_duplicate_location() throws Exception {  
		for (String location:existingAutomountLocations)
		{
			browser.span("Add").click();
			browser.textbox("cn").setValue(location); 
			browser.button("Add").click();
			if (browser.div("automount location with name \"" + location + "\" already exists").exists())
			{
				log.info("duplicate automount location: " + location +" is forbidden, good, test continue");
				browser.button("Cancel").click();
				browser.button("Cancel").click();
			}
			else
				Assert.assertTrue(false, "duplicate automount location is allowed : name="+location+", bad, test failed");
		}
	}

	@Test (groups={"addAutomountLocation_negative"},
		description = "required filed: automation location name is required")
	public void addAutomount_negative_required_field() throws Exception {  
		browser.span("Add").click();
		// without enter location name, just click Add
		browser.button("Add").click();
		if (browser.span("Required field").exists())
			log.info("error fields: 'Required field' appears as expected, test success"); // report success
		else
			Assert.assertTrue(false, "error fields 'Required field' does NOT appear as expected, test failed");
	
	}

	/////////// modify automount location settings/////////////////////////
	@Test (groups={"modifyAutomountLocation"},dependsOnGroups="addAutomountLocation",
		description="modify automount settings: in fact, this is no test case here. I have this test method only to show I have been thinking about this")
	public void modifyAutomountLocationSettings() throws Exception { 
		log.info("No test case necessary for automount location setting ");
	}

	/////////// delete automount location /////////////////////////
	@Test (groups={"deleteAutomountLocation"}, dataProvider="deleteAutomountLocationSingle", dependsOnGroups="addAutomountLocation",
			description="delete single automount location")
	public void deleteAutomountLocationSingle(String automountLocation) throws Exception { 
		Assert.assertTrue(browser.link(automountLocation).exists(), "before delete, autoumount location (" + automountLocation + ")should exist in list");
		CommonHelper.deleteEntry(browser, automountLocation);  
		Assert.assertFalse(browser.link(automountLocation).exists(), "after delete, automount location (" + automountLocation + ") should NOT exist in list");
	}

	@Test (groups={"deleteAutomountLocation"}, dataProvider="deleteAutomountLocationMultiple", dependsOnGroups="addAutomountLocation",
			description="delete multiple automount location")
	public void deleteAutomountLocationMultiple(String automountLocations) throws Exception { 
		String[] locations = automountLocations.split(",");
		for (String location:locations)
			Assert.assertTrue(browser.link(location).exists(), "before delete, autoumount location (" + location + ")should exist in list");
		CommonHelper.deleteEntry(browser, locations);  
		for (String location:locations)
			Assert.assertFalse(browser.link(location).exists(), "after delete, automount location (" + location + ") should NOT exist in list");
	}
	
	@Test (groups={"deleteAutomountLocation"}, dataProvider="leftOverAutomountLocations", dependsOnGroups="addAutomountLocation",
			description="delete automount")
	public void deleteLeftOverPermission(String automountLocations) throws Exception { 
		String[] locations = automountLocations.split(",");
		CommonHelper.deleteEntry(browser, locations);  
	}
	
	/***************************************************************************** 
	 *             Data providers                                                * 
	 *****************************************************************************/
	private static String[] existingAutomountLocations = {"default"}; 
	private static String[] testAutomountLocation = {"automountlocation000","automountlocation001","automountlocation002","automountlocation003","automountlocation004","automountlocation005"};
	
	@DataProvider(name="addAutomountLocation")
	public Object[][] getaddAutomountLocation()
	{
		String[][] automountlocations = {{testAutomountLocation[0]} , {testAutomountLocation[1]} }; 
		return automountlocations;
	}

	@DataProvider(name="addAutomountLocation_addandaddanother")
	public Object[][] getAddAutomountLocation_addandaddanother()
	{
		String[][] automountlocations = {{testAutomountLocation[2] + "," + testAutomountLocation[3] + "," + testAutomountLocation[4]}}; 
		return automountlocations;
	}

	@DataProvider(name="addAutomountLocation_addthenedit")
	public Object[][] getAddAutomountLocation_addthenedit()
	{
		String[][] automountlocations = {{testAutomountLocation[5]}}; 
		return automountlocations;
	}

	@DataProvider(name="addAutomountLocation_addthencancel")
	public Object[][] getAddAutomountLocation_addthencancel()
	{
		String[][] automountlocations = {{"i am invisible"}}; 
		return automountlocations;
	}

	@DataProvider(name="deleteAutomountLocationSingle")
	public Object[][] getDeleteAutomountLocationSingle()
	{
		return getaddAutomountLocation();
	}

	@DataProvider(name="deleteAutomountLocationMultiple")
	public Object[][] getDeleteAutomountLocationMultiple()
	{
		return getAddAutomountLocation_addandaddanother();
	}

	@DataProvider(name="leftOverAutomountLocations")
	public Object[][] getLeftOverLocations()
	{
		String all = CommonHelper.arrayToString(testAutomountLocation);
		String[][] automountlocations = {{all}}; 
		return automountlocations;
	}
}//class AutomountTests
