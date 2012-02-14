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
	@Test (groups={"deleteAutomountLocation"}, dataProvider="deleteAutomountLocationSingle", dependsOnGroups="deleteIndirectAutomountMap",
			description="delete single automount location")
	public void deleteAutomountLocationSingle(String automountLocation) throws Exception { 
		Assert.assertTrue(browser.link(automountLocation).exists(), "before delete, autoumount location (" + automountLocation + ")should exist in list");
		CommonHelper.deleteEntry(browser, automountLocation);  
		Assert.assertFalse(browser.link(automountLocation).exists(), "after delete, automount location (" + automountLocation + ") should NOT exist in list");
	}

	@Test (groups={"deleteAutomountLocation"}, dataProvider="deleteAutomountLocationMultiple", dependsOnGroups="deleteIndirectAutomountMap",
			description="delete multiple automount location")
	public void deleteAutomountLocationMultiple(String automountLocations) throws Exception { 
		String[] locations = automountLocations.split(",");
		for (String location:locations)
			Assert.assertTrue(browser.link(location).exists(), "before delete, autoumount location (" + location + ")should exist in list");
		CommonHelper.deleteEntry(browser, locations);  
		for (String location:locations)
			Assert.assertFalse(browser.link(location).exists(), "after delete, automount location (" + location + ") should NOT exist in list");
	}
	
	@Test (groups={"deleteAutomountLocation"}, dataProvider="leftOverAutomountLocations", dependsOnGroups="deleteIndirectAutomountMap",
			description="delete automount")
	public void deleteLeftOverPermission(String automountLocations) throws Exception 
	{ 
		String[] locations = automountLocations.split(",");
		CommonHelper.deleteEntry(browser, locations);  
	}

	/////////// add automount map /////////////////////////
	@Test (groups={"addAutomountMap"}, dataProvider="addAutomountMap", dependsOnGroups="addAutomountLocation",
		description = "add new automount map via 'Add' button")
	public void addAutomountMap_add(String automountLocation, String automountMap) throws Exception {  
		browser.link(automountLocation).click();
		Assert.assertFalse(browser.link(automountMap).exists(), "before add, automount map (" + automountMap + ")should NOT exist in list");
		AutomountTasks.addAutomountMap(browser, automountMap);  
		Assert.assertTrue(browser.link(automountMap).exists(), "after add, automount map (" + automountMap + ") should exist in list");
	}

	@Test (groups={"addAutomountMap"}, dataProvider="addAutomountMap_addandaddanother",dependsOnGroups="addAutomountLocation",
		description = "add new automount via 'Add and Add Another' button")
	public void addAutomountMap_addandaddanother(String automountLocation, String automountMaps) throws Exception {  
		browser.link(automountLocation).click();
		String[] maps = CommonHelper.stringToArray(automountMaps);
		for (String map:maps)
			Assert.assertFalse(browser.link(map).exists(), "before add, location ["+map+"] does not exist");
		AutomountTasks.addAutomountMapAddAndAddAnother(browser, maps);
		for (String map:maps)
			Assert.assertTrue(browser.link(map).exists(), "after add, location ["+map+"] does exist");
	}

	@Test (groups={"addAutomountMap"}, dataProvider="addAutomountMap_addthenedit", dependsOnGroups="addAutomountLocation",
		description = "add new automount map via 'Add and Edit' button")
	public void addAutomountMap_addthenedit(String automountLocation, String automountMap) throws Exception {  
		browser.link(automountLocation).click();
		Assert.assertFalse(browser.link(automountMap).exists(), "before add, automount map (" + automountMap + ") should NOT exist in list");
		browser.span("Add").click();
		browser.textbox("automountmapname").setValue(automountMap);
		browser.textarea("description").setValue(automountMap + ": auto description");
		browser.button("Add and Edit").click();
		if (browser.link("details").exists() && browser.link("Automount Keys").exists())
		{
			log.info("in edit mode, test success, now go back to automount ");
			browser.link(automountLocation).in(browser.span("path")).click(); 
		}
		else{
			log.info("not in edit mode, test failed");
			Assert.assertTrue(false, "after click 'Add and Edit' we are not in edit mode, test failed");
		}
		Assert.assertTrue(browser.link(automountMap).exists(), "after add, automount map (" + automountMap + ") should exist in list");
	}

	@Test (groups={"addAutomountMap"},  dataProvider="addAutomountMap_addthencancel",dependsOnGroups="addAutomountLocation",
		description = "add new automount via 'Add' then click 'Cancel', expect no new automount map being added")
	public void addAutomountMap_addthencancel(String automountLocation) throws Exception {  
		browser.link(automountLocation).click(); 
		String automountMap = "IwillBeCanceled";
		Assert.assertFalse(browser.link(automountMap).exists(), "before add, automount map (" + automountMap + ")should NOT exist in list");
		AutomountTasks.addAutomountMapAddThenCancel(browser,automountMap);
		Assert.assertFalse(browser.link(automountMap).exists(), "after add, automount map (" + automountMap + ") should NOT exist in list as well");
	}

	@Test (groups={"addAutomountMap_negative"}, dependsOnGroups="addAutomountLocation",
		description = "no duplicated automount map is allowed")
	public void addAutomountMap_negative_duplicate_location(String automountLocation) throws Exception {  
		browser.link(automountLocation).click();  
		for (String map:existingAutomountMaps)
		{
			String description = map + " duplicated automount map is not allowed";
			browser.textbox("automountmapname").setValue(map);
			browser.textarea("description").setValue(description);
			browser.button("Add").click();
			if (browser.div("automount map with name \"" + map + "\" already exists").exists())
			{
				log.info("duplicate automount map: " + map +" is forbidden, good, test continue");
				browser.button("Cancel").click();
				browser.button("Cancel").click();
			}
			else
				Assert.assertTrue(false, "duplicate automount map is allowed : name="+map+", bad, test failed");
		}
	}

	@Test (groups={"addAutomountMap_negative"}, dependsOnGroups="addAutomountLocation",
		description = "required filed: automation location name is required")
	public void addAutomountMap_negative_required_field(String automountLocation) throws Exception {  
		browser.link(automountLocation).click();  
		browser.span("Add").click();
		// without enter map name, just click Add
		browser.button("Add").click();
		if (browser.span("Required field").exists())
			log.info("error fields: 'Required field' appears as expected, test success"); // report success
		else
			Assert.assertTrue(false, "error fields 'Required field' does NOT appear as expected, test failed"); 
	}

	/////////// modify automount map settings/////////////////////////
	@Test (groups={"modifyAutomountMap"}, dataProvider="modifyAutomountMap", dependsOnGroups="addAutomountMap",
		description="modify automount map: check undo button ")
	public void modifyAutomountMap_undo(String automountLocation, String automountMapName) throws Exception 
	{
		browser.link(automountLocation).click();
		browser.link(automountMapName).click();
		browser.link("details").click();
		String originalDescription = browser.textarea("description").getText();
		browser.textarea("description").setValue("I am not suppose to be here: test for undo");
		if (browser.span("undo").exists())
		{
			log.info("after changes made into description, link 'undo' appears, good, test continue");
			browser.span("undo").click();
			String afterUndo = browser.textarea("description").getText();
			if (originalDescription.equals(afterUndo)) 
			{
				log.info("'undo' will restored the original description value, good, test passed");
			}else{
				log.info("click 'undo' does not restore original description value, test failed");
				Assert.assertTrue(false, "unexpected behave for 'undo': click 'undo' does not restore settings");
			}
			browser.link(automountLocation).in(browser.span("path")).click(); 
		}else{
			log.info("after changes made into permission, link 'undo' does NOT appear, test failed ");
			browser.span("Reset").click();
			browser.link(automountLocation).in(browser.span("path")).click(); 
			Assert.assertTrue(false, "unexpected behave: link 'undo' does not show up as expected");
		} 
	}

	@Test (groups={"modifyAutomountMap"}, dataProvider="modifyAutomountMap", dependsOnGroups="addAutomountMap",
		description="modify automount map : test for reset button")
	public void modifyAutomountMap_reset(String automountLocation, String automountMapName) throws Exception 
	{
		browser.link(automountLocation).click();
		browser.link(automountMapName).click();
		browser.link("details").click();
		String originalDescription = browser.textarea("description").getText();
		browser.textarea("description").setValue("I am not suppose to be here: test for reset");
		browser.span("Reset").click();  
		String afterReset = browser.textarea("description").getText();
		if (originalDescription.equals(afterReset)) 
		{
			log.info("'reset' will restored the original description value, good, test passed");
			browser.link(automountLocation).in(browser.span("path")).click(); 
		}else{
			log.info("click 'reset' does not restore original description value, test failed");
			browser.link(automountLocation).in(browser.span("path")).click(); 
			Assert.assertTrue(false, "unexpected behave for 'reset': click 'Reset' does not original description");
		} 
	}

	@Test (groups={"modifyAutomountMap"}, dataProvider="modifyAutomountMap", dependsOnGroups="addAutomountMap",
		description="modify automount map : test for update button")
	public void modifyAutomountMap_update(String automountLocation,String automountMapName) throws Exception
	{
		browser.link(automountLocation).click();
		browser.link(automountMapName).click(); 
		browser.link("details").click();
		String description = automountLocation + "->" + automountMapName + ": description modified, in test 'Update'";
		browser.textarea("description").setValue(description);
		browser.span("Update").click();
		String afterUpdate = browser.textarea("description").getText();
		if (description.equals(afterUpdate)) 
		{
			log.info("'Update' sets new value for description as expected, test passed");
			browser.link(automountLocation).in(browser.span("path")).click(); 
		}else{
			log.info("click 'Update' does not set newl description value, test failed");
			browser.link(automountLocation).in(browser.span("path")).click();  
			Assert.assertTrue(false, "unexpected behave for 'Update': click 'Update' does not set new value for 'description'");
		}  
	}

	@Test (groups={"modifyAutomountMap_negative"}, dataProvider="modifyAutomountMap_negative", dependsOnGroups="addAutomountMap",
		description="negative test case for self service permission modification")
	public void modifyAutomountMap_negative(String automountLocation, String automountMapName, String description) throws Exception {
		browser.link(automountLocation).click();
		browser.link(automountMapName).click(); 
		browser.link("details").click();
		browser.link(automountLocation).in(browser.span("path")).click(); 
	}

	/////////// delete automount map /////////////////////////
	@Test (groups={"deleteAutomountMap"}, dataProvider="deleteAutomountMapSingle", dependsOnGroups="modifyAutomountMap",
			description="delete single automount map")
	public void deleteAutomountMapSingle(String automountLocation,String automountMap) throws Exception { 
		browser.link(automountLocation).click();
		Assert.assertTrue(browser.link(automountMap).exists(), "before delete, autoumount location (" + automountMap + ")should exist in list");
		CommonHelper.deleteEntry(browser, automountMap);  
		Assert.assertFalse(browser.link(automountMap).exists(), "after delete, automount map (" + automountMap + ") should NOT exist in list");
	}

	@Test (groups={"deleteAutomountMap"}, dataProvider="deleteAutomountMapMultiple", dependsOnGroups="modifyAutomountMap",
			description="delete multiple automount map")
	public void deleteAutomountMapMultiple(String automountLocation,String automountMaps) throws Exception { 
		browser.link(automountLocation).click();
		String[] maps = CommonHelper.stringToArray(automountMaps);
		for (String map:maps)
			Assert.assertTrue(browser.link(map).exists(), "before delete, autoumount location (" + map + ")should exist in list");
		CommonHelper.deleteEntry(browser, maps);  
		for (String map:maps)
			Assert.assertFalse(browser.link(map).exists(), "after delete, automount map (" + map + ") should NOT exist in list");
	}

	/////////// add indirect automount map /////////////////////////
	@Test (groups={"addIndirectAutomountMap"}, dataProvider="addIndirectAutomountMap", dependsOnGroups="addAutomountLocation",
		description = "add new indirect automount map via 'Add' button")
	public void addIndirectAutomountMap_add(String automountLocation, String indirectAutomountMap, String mountPoint, String parentMap) throws Exception {  
		browser.link(automountLocation).click();
		Assert.assertFalse(browser.link(indirectAutomountMap).exists(), "before add, indirect automount map (" + indirectAutomountMap + ")should NOT exist in list");
		AutomountTasks.addIndirectAutomountMap(browser, indirectAutomountMap, mountPoint, parentMap);  
		Assert.assertTrue(browser.link(indirectAutomountMap).exists(), "after add, indirect automount map (" + indirectAutomountMap + ") should exist in list");
	}

	@Test (groups={"addIndirectAutomountMap"}, dataProvider="addIndirectAutomountMap_addandaddanother",dependsOnGroups="addAutomountLocation",
		description = "add new automount via 'Add and Add Another' button")
	public void addIndirectAutomountMap_addandaddanother(String automountLocation, String indirectAutomountMaps, String mountPoint, String parentMap) throws Exception {  
		browser.link(automountLocation).click();
		String[] maps = CommonHelper.stringToArray(indirectAutomountMaps);
		String[] points = CommonHelper.stringToArray(mountPoint);
		String[] parents = CommonHelper.stringToArray(parentMap);
		for (String map:maps)
			Assert.assertFalse(browser.link(map).exists(), "before add, location ["+map+"] does not exist");
		AutomountTasks.addIndirectAutomountMapAddAndAddAnother(browser, maps, points, parents);
		for (String map:maps)
			Assert.assertTrue(browser.link(map).exists(), "after add, location ["+map+"] does exist");
	}

	@Test (groups={"addIndirectAutomountMap"}, dataProvider="addIndirectAutomountMap_addthenedit", dependsOnGroups="addAutomountLocation",
		description = "add new indirect automount map via 'Add and Edit' button")
	public void addIndirectAutomountMap_addthenedit(String automountLocation, String indirectAutomountMap, String mountPoint, String parentMap) throws Exception {  
		browser.link(automountLocation).click();
		Assert.assertFalse(browser.link(indirectAutomountMap).exists(), "before add, indirect automount map (" + indirectAutomountMap + ") should NOT exist in list");
		browser.span("Add").click();
		browser.radio("add_indirect").click();
		browser.textbox("automountmapname").setValue(indirectAutomountMap);
		browser.textarea("description").setValue(indirectAutomountMap + ": auto description");
		browser.textbox("key").setValue(mountPoint);
		browser.textbox("parentmap").setValue(parentMap.trim());
		browser.button("Add and Edit").click();
		if (browser.link("details").exists() && browser.link("Automount Keys").exists())
		{
			log.info("in edit mode, test success, now go back to automount ");
			browser.link(automountLocation).in(browser.span("path")).click(); 
			Assert.assertTrue(browser.link(indirectAutomountMap).exists(), "after add, indirect automount map (" + indirectAutomountMap + ") should exist in list");
		}
		else{
			log.info("not in edit mode, test failed");
			Assert.assertTrue(browser.link(indirectAutomountMap).exists(), "after add, indirect automount map (" + indirectAutomountMap + ") should exist in list");
			Assert.assertTrue(false, "after click 'Add and Edit' we are not in edit mode, test failed");
		}
	}

	@Test (groups={"addIndirectAutomountMap"},  dataProvider="addIndirectAutomountMap_addthencancel",dependsOnGroups="addAutomountLocation",
		description = "add new automount via 'Add' then click 'Cancel', expect no new indirect automount map being added")
	public void addIndirectAutomountMap_addthencancel(String automountLocation) throws Exception {  
		browser.link(automountLocation).click(); 
		String indirectAutomountMap = "IwillBeCanceled";
		String mountPoint = "IamUseless";
		String parentMap = "does not matter";
		Assert.assertFalse(browser.link(indirectAutomountMap).exists(), "before add, indirect automount map (" + indirectAutomountMap + ")should NOT exist in list");
		AutomountTasks.addIndirectAutomountMapAddThenCancel(browser,indirectAutomountMap, mountPoint, parentMap);
		Assert.assertFalse(browser.link(indirectAutomountMap).exists(), "after add, indirect automount map (" + indirectAutomountMap + ") should NOT exist in list as well");
	}

	@Test (groups={"addIndirectAutomountMap_negative"}, dataProvider="addIndirectAutomountMap_duplicate_map", dependsOnGroups="addAutomountLocation",
		description = "no duplicated indirect automount map is allowed")
	public void addIndirectAutomountMap_negative_duplicate_indirectmap(String automountLocation) throws Exception {  
		String indirectAutomountMap = "IwillBeCanceled";
		String mountPoint = "IamUseless";
		String parentMap = "does not matter";
		browser.link(automountLocation).click();  
		for (String map:existingIndirectAutomountMaps)
		{
			String description = map + " duplicated indirect automount map is not allowed";
			browser.span("Add").click();
			browser.radio("add_indirect").click();
			browser.textbox("automountmapname").setValue(indirectAutomountMap);
			browser.textarea("description").setValue(description);
			browser.textbox("key").setValue(mountPoint);
			browser.textbox("parentmap").setValue(parentMap);
			browser.button("Add").click();
			if (browser.div(automountLocation + ": automount map not found").exists())
			{
				log.info("duplicate indirect automount map: " + map +" is forbidden, good, test continue");
				browser.button("Cancel").click();
				browser.button("Cancel").click();
			}
			else
				Assert.assertTrue(false, "duplicate indirect automount map is allowed : name="+map+", bad, test failed");
		}
	}


	@Test (groups={"addIndirectAutomountMap_negative"}, dataProvider="addIndirectAutomountMap_addthenedit", dependsOnGroups="addAutomountLocation",
		description = "no duplicated indirect automount map is allowed")
	public void addIndirectAutomountMap_negative_duplicate_mountpoint(String automountLocation, String indirectAutomountMap, String mountPoint, String parentMap )throws Exception {  
		// notes: this test case will use same data provider as addIndirectAutomountMap_addthenedit, but change the automountmapname to avoid the problem as test case addIndirectAutomountMap_negative_duplicate_indirectmap
		String indirectMapName = "negative_" + indirectAutomountMap;
		String description = mountPoint + " :duplicated mount point is not allowed";
		browser.link(automountLocation).click();  
		browser.span("Add").click();
		browser.radio("add_indirect").click();
		browser.textbox("automountmapname").setValue(indirectMapName);
		browser.textarea("description").setValue(description);
		browser.textbox("key").setValue(mountPoint);
		browser.textbox("parentmap").setValue(parentMap.trim());
		browser.button("Add").click();
		if (browser.div("key named " + mountPoint + " already exists").exists())
		{
			log.info("duplicate mount point: " + mountPoint +" is forbidden, good, test passed");
			browser.button("Cancel").click();
			browser.button("Cancel").click();
		}
		else
			Assert.assertTrue(false, "duplicate mount point (also called key) is allowed : name="+ mountPoint + ", test failed");
	}

	@Test (groups={"addIndirectAutomountMap_negative"},dataProvider="addIndirectAutomountMapRequiredField", dependsOnGroups="addAutomountLocation",
		description = "required filed: automation map name is required")
	public void addIndirectAutomountMap_negative_required_field_mapname(String automountLocation) throws Exception {  
		browser.link(automountLocation).click();  
		browser.span("Add").click();
		browser.radio("add_indirect").click();
		// without enter map name, just click Add
		browser.button("Add").click();
		if (browser.span("Required field").exists())
			log.info("error fields: 'Required field' appears as expected, test success"); // report success
		else
			Assert.assertTrue(false, "error fields 'Required field' does NOT appear as expected, test failed"); 
	}

	@Test (groups={"addIndirectAutomountMap_negative"}, dataProvider="addIndirectAutomountMapRequiredField", dependsOnGroups="addAutomountLocation",
		description = "required filed: parent map has to exist when it is being specified")
	public void addIndirectAutomountMap_negative_required_field_mountpoint(String automountLocation) throws Exception {  
		browser.link(automountLocation).click();  
		browser.span("Add").click();
		browser.radio("add_indirect").click();
		browser.textbox("automountmapname").setValue("testValue");
		// without enter mount point value, just click Add
		browser.button("Add").click();
		if (browser.span("Required field").exists())
			log.info("error fields: 'Required field' appears as expected, test success"); // report success
		else
			Assert.assertTrue(false, "error fields 'Required field' does NOT appear as expected, test failed"); 
	}

	/////////// modify indirect automount map settings/////////////////////////
	@Test (groups={"modifyIndirectAutomountMap"}, dataProvider="modifyIndirectAutomountMap", dependsOnGroups="addIndirectAutomountMap",
		description="modify indirect automount map: check undo button ")
	public void modifyIndirectAutomountMap_undo(String automountLocation, String indirectAutomountMapName) throws Exception 
	{
		browser.link(automountLocation).click();
		browser.link(indirectAutomountMapName).click();
		browser.link("details").click();
		String originalDescription = browser.textarea("description").getText();
		browser.textarea("description").setValue("I am not suppose to be here: test for undo");
		if (browser.span("undo").exists())
		{
			log.info("after changes made into description, link 'undo' appears, good, test continue");
			browser.span("undo").click();
			String afterUndo = browser.textarea("description").getText();
			if (originalDescription.equals(afterUndo)) 
			{
				log.info("'undo' will restored the original description value, good, test passed");
			}else{
				log.info("click 'undo' does not restore original description value, test failed");
				Assert.assertTrue(false, "unexpected behave for 'undo': click 'undo' does not restore settings");
			}
			browser.link(automountLocation).in(browser.span("path")).click(); 
		}else{
			log.info("after changes made into permission, link 'undo' does NOT appear, test failed ");
			browser.span("Reset").click();
			browser.link(automountLocation).in(browser.span("path")).click(); 
			Assert.assertTrue(false, "unexpected behave: link 'undo' does not show up as expected");
		} 
	}

	@Test (groups={"modifyIndirectAutomountMap"}, dataProvider="modifyIndirectAutomountMap", dependsOnGroups="addIndirectAutomountMap",
		description="modify indirect automount map: test for reset button")
	public void modifyIndirectAutomountMap_reset(String automountLocation, String indirectAutomountMapName) throws Exception 
	{
		browser.link(automountLocation).click();
		browser.link(indirectAutomountMapName).click();
		browser.link("details").click();
		String originalDescription = browser.textarea("description").getText();
		browser.textarea("description").setValue("I am not suppose to be here: test for reset");
		browser.span("Reset").click();  
		String afterReset = browser.textarea("description").getText();
		if (originalDescription.equals(afterReset)) 
		{
			log.info("'reset' will restored the original description value, good, test passed");
			browser.link(automountLocation).in(browser.span("path")).click(); 
		}else{
			log.info("click 'reset' does not restore original description value, test failed");
			browser.link(automountLocation).in(browser.span("path")).click(); 
			Assert.assertTrue(false, "unexpected behave for 'reset': click 'Reset' does not original description");
		} 
	}

	@Test (groups={"modifyIndirectAutomountMap"}, dataProvider="modifyIndirectAutomountMap", dependsOnGroups="addIndirectAutomountMap",
		description="modify indirect automount: test for update button")
	public void modifyIndirectAutomountMap_update(String automountLocation,String indirectAutomountMapName) throws Exception
	{
		browser.link(automountLocation).click();
		browser.link(indirectAutomountMapName).click(); 
		browser.link("details").click();
		String description = automountLocation + "->" + indirectAutomountMapName + ": description modified, in test 'Update'";
		browser.textarea("description").setValue(description);
		browser.span("Update").click();
		String afterUpdate = browser.textarea("description").getText();
		if (description.equals(afterUpdate)) 
		{
			log.info("'Update' sets new value for description as expected, test passed");
			browser.link(automountLocation).in(browser.span("path")).click(); 
		}else{
			log.info("click 'Update' does not set newl description value, test failed");
			browser.link(automountLocation).in(browser.span("path")).click();  
			Assert.assertTrue(false, "unexpected behave for 'Update': click 'Update' does not set new value for 'description'");
		}  
	}

	@Test (groups={"modifyIndirectAutomountMap_negative"}, dataProvider="modifyIndirectAutomountMap_negative", dependsOnGroups="addIndirectAutomountMap",
		description="negative test case for self service permission modification")
	public void modifyIndirectAutomountMap_negative(String automountLocation, String indirectAutomountMapName, String description) throws Exception {
		browser.link(automountLocation).click();
		browser.link(indirectAutomountMapName).click(); 
		browser.link("details").click();
		browser.link(automountLocation).in(browser.span("path")).click(); 
	}

	/////////// delete indirect automount map /////////////////////////
	@Test (groups={"deleteIndirectAutomountMap"}, dataProvider="deleteIndirectAutomountMapSingle", dependsOnGroups="modifyIndirectAutomountMap",
			description="delete single indirect automount map")
	public void deleteIndirectAutomountMapSingle(String automountLocation,String indirectAutomountMap, String mountPoint, String parentMap) throws Exception { 
		// the value : mountPoint and parentMap is not used intentionally 
		browser.link(automountLocation).click();
		Assert.assertTrue(browser.link(indirectAutomountMap).exists(), "before delete, autoumount location (" + indirectAutomountMap + ")should exist in list");
		CommonHelper.deleteEntry(browser, indirectAutomountMap);  
		Assert.assertFalse(browser.link(indirectAutomountMap).exists(), "after delete, indirect automount map (" + indirectAutomountMap + ") should NOT exist in list");
	}

	@Test (groups={"deleteIndirectAutomountMap"}, dataProvider="deleteIndirectAutomountMapMultiple", dependsOnGroups="modifyIndirectAutomountMap",
			description="delete multiple indirect automount map")
	public void deleteIndirectAutomountMapMultiple(String automountLocation,String indirectAutomountMaps, String mountPoint, String parentMap) throws Exception { 
		// the value : mountPoint and parentMap is not used intentionally 
		browser.link(automountLocation).click();
		String[] maps = CommonHelper.stringToArray(indirectAutomountMaps);
		for (String map:maps)
			Assert.assertTrue(browser.link(map).exists(), "before delete, autoumount location (" + map + ")should exist in list");
		CommonHelper.deleteEntry(browser, maps);  
		for (String map:maps)
			Assert.assertFalse(browser.link(map).exists(), "after delete, indirect automount map (" + map + ") should NOT exist in list");
	}


	/***************************************************************************** 
	 *             Data providers                                                * 
	 *****************************************************************************/
	private static String[] existingAutomountLocations = {"default"}; 
	private static String[] existingIndirectAutomountMaps = {"auto.direct", "auto.master"};
	private static String[] existingAutomountMaps = {"auto.direct","auto.master"}; 

	private static String[] testAutomountLocation = {"automountlocation000","automountlocation001","automountlocation002","automountlocation003","automountlocation004","automountlocation005"};
	private static String[] testAutomountMap = {"automountmap000","automountmap001","automountmap002","automountmap003","automountmap004","automountmap005"};
	private static String[] testIndirectindirectMap = {"indirectmap000","indirectmap001","indirectmap002","indirectmap003","indirectmap004","indirectmap005"};
	private static String[] testAutomountKeys= {"automountkey000","automountkey001","automountkey002","automountkey003","automountkey004","automountkey005"};
	private static String[] testMountPoint = testAutomountKeys;
	private static String[] testParentMap = {existingIndirectAutomountMaps[0], existingIndirectAutomountMaps[1]," "," "," "," "};

	/// test data for automount location ///	
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
	public Object[][] leftOverAutomountLocations()
	{
		String all = CommonHelper.arrayToString(testAutomountLocation);
		String[][] automountlocations = {{all}}; 
		return automountlocations;
	}

	/// test data for automount map ///	
	@DataProvider(name="addAutomountMap")
	public Object[][] getaddAutomountMap()
	{
		String[][] automountmaps = {{testAutomountLocation[0], testAutomountMap[0]} , {testAutomountLocation[0], testAutomountMap[1]} }; 
		return automountmaps;
	}

	@DataProvider(name="addAutomountMap_addandaddanother")
	public Object[][] getAddAutomountMap_addandaddanother()
	{
		String[][] automountmaps = {{testAutomountLocation[0], testAutomountMap[2] + "," + testAutomountMap[3] + "," + testAutomountMap[4]}}; 
		return automountmaps;
	}

	@DataProvider(name="addAutomountMap_addthenedit")
	public Object[][] getAddAutomountMap_addthenedit()
	{
		String[][] automountmaps = {{testAutomountLocation[0], testAutomountMap[5]}}; 
		return automountmaps;
	}

	@DataProvider(name="addAutomountMap_addthencancel")
	public Object[][] getAddAutomountMap_addthencancel()
	{
		String[][] automountmaps = {{testAutomountLocation[0]}}; 
		return automountmaps;
	}

	@DataProvider(name="modifyAutomountMap")
	public Object[][] getAddAutomountMap_reset()
	{
		return getAddAutomountMap_addthenedit();
	}


	@DataProvider(name="deleteAutomountMapSingle")
	public Object[][] getDeleteAutomountMapSingle()
	{
		return getaddAutomountMap();
	}

	@DataProvider(name="deleteAutomountMapMultiple")
	public Object[][] getDeleteAutomountMapMultiple()
	{
		return getAddAutomountMap_addandaddanother();
	}

	@DataProvider(name="leftOverAutomountMaps")
	public Object[][] leftOverAutomountMaps()
	{
		String all = CommonHelper.arrayToString(testAutomountMap);
		String[][] automountmaps = {{testAutomountLocation[0], all}}; 
		return automountmaps;
	}

	/// test data for indirect automount map ///	
	@DataProvider(name="addIndirectAutomountMap")
	public Object[][] getaddIndirectAutomountMap()
	{
		String[][] indirectAutomountmaps = {
			{testAutomountLocation[0], testIndirectindirectMap[0], testMountPoint[0], testParentMap[0]},  
			{testAutomountLocation[0], testIndirectindirectMap[1], testMountPoint[1], testParentMap[1]} }; 
		return indirectAutomountmaps;
	}

	@DataProvider(name="addIndirectAutomountMap_addandaddanother")
	public Object[][] getAddIndirectAutomountMap_addandaddanother()
	{
		String[][] indirectAutomountmaps = {{
			testAutomountLocation[0], 
			testIndirectindirectMap[2] + "," + testIndirectindirectMap[3] + "," + testIndirectindirectMap[4],
			testMountPoint[2] + "," + testMountPoint[3] + "," + testMountPoint[4],
			testParentMap[0]  + "," + testParentMap[1]  + "," + testParentMap[2]
			 } }; 
		return indirectAutomountmaps;
	}

	@DataProvider(name="addIndirectAutomountMap_addthenedit")
	public Object[][] getAddIndirectAutomountMap_addthenedit()
	{
		String[][] indirectAutomountmaps = {{testAutomountLocation[0], testIndirectindirectMap[5], testMountPoint[5], testParentMap[5]}}; 
		return indirectAutomountmaps;
	}

	@DataProvider(name="addIndirectAutomountMap_addthencancel")
	public Object[][] getAddIndirectAutomountMap_addthencancel()
	{
		String[][] indirectAutomountmaps = {{testAutomountLocation[0]}}; 
		return indirectAutomountmaps;
	}

	@DataProvider(name="addIndirectAutomountMapRequiredField")
	public Object[][] getAddIndirectAutomountMap_RequiredField()
	{
		String[][] indirectAutomountmaps = {{testAutomountLocation[0]}};
		return indirectAutomountmaps;
	}

	@DataProvider(name="modifyIndirectAutomountMap")
	public Object[][] getAddIndirectAutomountMap_reset()
	{
		String[][] indirectAutomountmaps = {{testAutomountLocation[0], testIndirectindirectMap[0]}}; 
		return indirectAutomountmaps;
	}

	@DataProvider(name="addIndirectAutomountMap_duplicate_map")
	public Object[][] getIndirectAutomountMapDuplicateMap()
	{
		String[][] indirectAutomountmaps = {{testAutomountLocation[0]}}; 
		return indirectAutomountmaps;
	}

	@DataProvider(name="deleteIndirectAutomountMapSingle")
	public Object[][] getDeleteIndirectindirectAutomountmapsingle()
	{
		return getaddIndirectAutomountMap();
	}

	@DataProvider(name="deleteIndirectAutomountMapMultiple")
	public Object[][] getDeleteIndirectAutomountMapMultiple()
	{
		return getAddIndirectAutomountMap_addandaddanother();
	}

	@DataProvider(name="leftOverIndirectindirectAutomountmaps")
	public Object[][] leftOverIndirectindirectAutomountmaps()
	{
		String all = CommonHelper.arrayToString(testIndirectindirectMap);
		String[][] indirectAutomountmaps = {{testAutomountLocation[0], all}}; 
		return indirectAutomountmaps;
	}

}//class AutomountTests
