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
	public void addAutomount_negative_duplicate_location(String automountLocation) throws Exception {  
// code goes here
	}

	@Test (groups={"addAutomountLocation_negative"},
		description = "required filed: automation location name is required")
	public void addAutomount_negative_required_field(String automountLocation) throws Exception {  
// code goes here
	}

	@Test (groups={"addAutomount_negative"},
		description = "negative test for add automount: test for required fileds: name and attribute")
	public void addAutomount_negative_requiredFields() throws Exception { 
		browser.span("Add").click();
		
		// Test case 1: without give any input, click 'Add' , try to create an empty permission
		browser.button("Add").click();
		if (browser.span("Required field").exists()) 
			log.info("error fields: 'Required field' appears as expected, test continue"); // report success
		else
			Assert.assertTrue(false, "error fields 'Required field' does NOT appear as expected, test failed");
		
		// Test case 2: give one input : permission name and try to create a permission without any attribute attache to it, this should fail
		browser.textbox("aciname").setValue("PermissionWithoutAttribute"); 
		browser.button("Add").click();
		if (browser.span("Required field").exists())
			log.info("error fields: 'Required field' appears as expected, test continue"); // report success
		else
			Assert.assertTrue(false, "error fields 'Required field' does NOT appear as expected, test failed");
		
		// Test case 3: give one input : attributes and try to create a permission without name (but has attributes), this should fail
		browser.textbox("aciname").setValue(""); 
		browser.checkbox("cn").check();
		browser.button("Add").click();
		if (browser.span("Required field").exists())
			log.info("error fields: 'Required field' appears as expected, test continue"); // report success
		else
			Assert.assertTrue(false, "error fields 'Required field' does NOT appear as expected, test failed");
		
		// if we reach this far, all test are done, click 'Cancel' to click away the dialog box
		browser.button("Cancel").click(); 
	}

	/////////// modify permission /////////////////////////
	@Test (groups={"modifyPermission"}, dataProvider="modifyPermission_AddSingleAttributes", dependsOnGroups="addAutomount",
		description="modify automount: add single attributes ")
	public void modifyPermission_addSingleAttritube(String permissionName, String attributeToAdd) throws Exception { 
		browser.link(permissionName).click();
		browser.checkbox(attributeToAdd).check();
		browser.span("Update").click();
		browser.link("Automount Locations").in(browser.span("back-link")).click(); 
		//FIXME: need a solution to verify test case result
	}

	@Test (groups={"modifyPermission"}, dataProvider="modifyPermission_update", dependsOnGroups="addAutomount",
		description="modify automount: add single attributes ")
	public void modifyPermission_update(String permissionName, String attributesToUncheck) throws Exception {
		browser.link(permissionName).click();

		browser.link("Automount Locations").in(browser.span("back-link")).click(); 
	}

	@Test (groups={"modifyPermission_negative"}, dataProvider="modifyPermission_negative", dependsOnGroups="addAutomount",
		description="negative test case for automount modification")
	public void modifyPermission_negative(String permissionName, String attributesToUncheck) throws Exception {

	}

	/////////// delete /////////////////////////

	@Test (groups={"deleteAutomountLocation"}, dataProvider="leftOverAutomountLocations", dependsOnGroups="addAutomountLocation",
			description="delete automount")
	public void deleteLeftOverPermission(String automountLocations) throws Exception { 
		String[] locations = automountLocations.split(",");
		for (String location:locations)
			Assert.assertTrue(browser.link(location).exists(), "before delete, autoumount location (" + location + ")should exist in list");
		CommonHelper.deleteEntry(browser, locations);  
		for (String location:locations)
			Assert.assertFalse(browser.link(location).exists(), "after delete, automount location (" + location + ") should NOT exist in list");
	}
	
	/***************************************************************************** 
	 *             Data providers                                                * 
	 *****************************************************************************/
	private static String[] existingPermissions = {"User Self service", "Self can write own password"}; 
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
	
	@DataProvider(name="leftOverAutomountLocations")
	public Object[][] getLeftOverLocations()
	{
		StringBuffer buffer = new StringBuffer();
		for (String location:testAutomountLocation)
			buffer.append(location + ",");
		String[][] automountlocations = {{buffer.substring(0,buffer.length()-1)}}; 
		return automountlocations;
	}
}//class AutomountTests
