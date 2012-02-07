package com.redhat.qe.ipa.sahi.tests.selfservicepermission;

import java.util.*;
import java.util.logging.Logger;
import org.testng.annotations.*;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonHelper;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SelfservicepermissionTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 

public class SelfservicepermissionTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(SelfservicepermissionTests.class.getName());
	private static SahiTasks browser;
 	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		browser = sahiTasks;
		browser.navigateTo(commonTasks.selfservicepermissionPage, true);
		browser.setStrictVisibilityCheck(true); 
	}//initialize
	
	@AfterClass (groups={"cleanup"} , description="Restore the default  when test is done", alwaysRun=true)
	public void testcleanup() throws CloneNotSupportedException {
		// place holder: for now, I don't have anything.
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		// ensure the starting page for each test case is the self service permission page
		String currentURL = browser.fetch("top.location.href"); 
		CommonTasks.checkError(sahiTasks);
		if (!currentURL.equals(commonTasks.selfservicepermissionPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+commonTasks.selfservicepermissionPage +")");
			browser.navigateTo(commonTasks.selfservicepermissionPage, true);
		}
	}//checkURL
	
	@AfterMethod (alwaysRun=true)
	public void checkPossibleError(){
		// check possible error, i don't have anything here for now
	}//checkPossibleError
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//                               test cases                                                         //
	//////////////////////////////////////////////////////////////////////////////////////////////////////

	/////////// add permission /////////////////////////
	@Test (groups={"addPermission"}, dataProvider="addPermission",
		description = "add new self service permission via 'Add' button")
	public void addPermission_add(String scenario, String permissionName, String attributes) throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage); 
		String[] attrs = attributes.split(",");
		Assert.assertFalse(browser.link(permissionName).exists(), "before add, permission should NOT exist in list");
		SelfservicepermissionTasks.addSelfservicePermission(browser, permissionName, attrs);  
		Assert.assertTrue(browser.link(permissionName).exists(), "after add, permission should exist in list");
	}

	@Test (groups={"addPermission"}, dataProvider="addPermission_addandaddanother",
		description = "add new self service permission via 'Add and Add Another' button, expect user can stay at same dialogue to continue add new permission")
	public void addPermission_addandaddanother(String permissionNames, String attributes) throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage); 
		String[] names = permissionNames.split(",");
		String[] attrs = attributes.split(",");
		for (String name:names)
			Assert.assertFalse(browser.link(name).exists(), "before add, permission should NOT exist in list");
		SelfservicepermissionTasks.addSelfservicePermissionAddAndAddAnother(browser, names, attrs);  
		for (String name:names)
			Assert.assertTrue(browser.link(name).exists(), "after add, permission should exist in list");
	}
	
	@Test (groups={"addPermission"}, dataProvider="addPermission_addthenedit",
		description = "add new self service permission via 'Add and Edit' button, expect to get into editting mode after add")
	public void addPermission_addthenedit(String permissionName, String attributes) throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage); 
		String[] attrs = attributes.split(",");
		Assert.assertFalse(browser.link(permissionName).exists(), "before add, permission should NOT exist in list");
		SelfservicepermissionTasks.addSelfservicePermissionAddThenEdit(browser, permissionName, attrs); 
		for (String attr:attrs)
			Assert.assertTrue(browser.checkbox(attr).checked(), "in editing mode, attr should exist and also being already checked");
		browser.link("Self Service Permissions").in(browser.span("back-link")).click(); 
	}
	
	@Test (groups={"addPermission"}, dataProvider="addPermission_addthencancel",
		description = "add new self service permission then click 'Cancel' button, expect no new permission being created")
	public void addPermission_addthencancel(String permissionName, String attributes) throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage); 
		String[] attrs = attributes.split(",");
		Assert.assertFalse(browser.link(permissionName).exists(), "before add, permission should NOT exist in list");
		SelfservicepermissionTasks.addSelfservicePermissionAddThenCancel(browser, permissionName, attrs);  
		Assert.assertFalse(browser.link(permissionName).exists(), "after add, permission should NOT exist in list as well");
	}

	@Test (groups={"addPermission_negative"},
		description = "create duplicate self service permission" )
	public void addPermisiono_negative_duplicatePermissiion() throws Exception{
		browser.navigateTo(commonTasks.selfservicepermissionPage);  
		for (String name:existingPermissions)
		{
			browser.span("Add").click();
			browser.textbox("aciname").setValue(name); 
			browser.checkbox("cn").check();
			browser.button("Add").click();
			if (browser.div("This entry already exists").exists())
			{
				log.info("duplicate self service permission name: " + name +" is forbidden, good, test continue");
				browser.button("Cancel").click();
				browser.button("Cancel").click();
			}
			else
				Assert.assertTrue(false, "duplicate self service permission name is allowed : name="+name+", bad, test failed");
		}
	}
	
	@Test (groups={"addPermission_negative"},
		description = "negative test for add self service permission: test for required fileds: name and attribute")
	public void addPermission_negative_requiredFields() throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage);  
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
	@Test (groups={"modifyPermission"}, dataProvider="modifyPermission_AddSingleAttributes", dependsOnGroups="addPermission",
		description="modify self service permission: add single attributes ")
	public void modifyPermission_addSingleAttritube(String permissionName, String attributeToAdd) throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage); 
		browser.link(permissionName).click();
		browser.checkbox(attributeToAdd).check();
		browser.span("Update").click();
		browser.link("Self Service Permissions").in(browser.span("back-link")).click(); 
		//FIXME: need a solution to verify test case result
	}

	@Test (groups={"modifyPermission"}, dataProvider="modifyPermission_AddMultipleAttributes", dependsOnGroups="addPermission",
		description="modify self service permission: add single attributes ")
	public void modifyPermission_addMultipleAttritubes(String permissionName, String attributesToAdd) throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage); 
		browser.link(permissionName).click();
		String[] attributes = attributesToAdd.split(",");
		for (String attr:attributes)
			browser.checkbox(attr).check();
		browser.span("Update").click();
		browser.link("Self Service Permissions").in(browser.span("back-link")).click(); 
		//FIXME: need a solution to verify test case result
	}

	@Test (groups={"modifyPermission"}, dataProvider="modifyPermission_deleteSingleAttributes", dependsOnGroups="addPermission",
		description="modify self service permission: add single attributes ")
	public void modifyPermission_deleteSingleAttritube(String permissionName, String attributeToDelete) throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage); 
		browser.link(permissionName).click();
		browser.checkbox(attributeToDelete).uncheck();
		browser.span("Update").click();
		browser.link("Self Service Permissions").in(browser.span("back-link")).click(); 
		//FIXME: need a solution to verify test case result
	}

	@Test (groups={"modifyPermission"}, dataProvider="modifyPermission_deleteMultipleAttributes", dependsOnGroups="addPermission",
		description="modify self service permission: add single attributes ")
	public void modifyPermission_deleteMultipleAttritube(String permissionName, String attributesToDelete) throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage); 
		browser.link(permissionName).click();
		String[] attributes = attributesToDelete.split(",");
		for (String attr:attributes)
			browser.checkbox(attr).uncheck();
		browser.span("Update").click();
		browser.link("Self Service Permissions").in(browser.span("back-link")).click(); 
		//FIXME: need a solution to verify test case result
	}

	@Test (groups={"modifyPermission"}, dataProvider="modifyPermission_undo", dependsOnGroups="addPermission",
		description="modify self service permission: add single attributes ")
	public void modifyPermission_undo(String permissionName, String attribute) throws Exception {
	//  test cases for : undo, reset, update
	}

	@Test (groups={"modifyPermission"}, dataProvider="modifyPermission_reset", dependsOnGroups="addPermission",
		description="modify self service permission: add single attributes ")
	public void modifyPermission_reset(String permissionName, String attribute) throws Exception {
	//  test cases for : undo, reset, update
	}

	@Test (groups={"modifyPermission"}, dataProvider="modifyPermission_update", dependsOnGroups="addPermission",
		description="modify self service permission: add single attributes ")
	public void modifyPermission_update(String permissionName, String attribute) throws Exception {
	//  test cases for : undo, reset, update
	}


	@Test (groups={"modifyPermission_negative"}, dataProvider="undecided", dependsOnGroups="addPermission",
		description="negative test case for self service permission modification")
	public void modifyPermission_negative(String testDescription, String textboxName, String invalidData, String expectedErrorMsg) throws Exception {
		 // remove all attributes from permission
	}
	/////////// delete permission /////////////////////////
	@Test (groups={"deletePermission"}, dataProvider="deletePermissionSingle", dependsOnGroups="modifyPermission",
		description="delete self service permission")
	public void deletePermissionSingle(String scenario, String permissionName, String attributes) throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage);
		Assert.assertTrue(browser.link(permissionName).exists(), "before delete, permission should in the list");
		SelfservicepermissionTasks.deletePermission(browser, permissionName);
		Assert.assertFalse(browser.link(permissionName).exists(), "after delete, permission should disappear");
	}
	
	@Test (groups={"deletePermission"}, dataProvider="deletePermissionMultiple", dependsOnGroups="modifyPermission",
		description="delete multiple self service permissions at once")
	public void deletePermissionMultiple(String permissionNames, String attributes) throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage);
		String[] names = permissionNames.split(",");
		for(String name:names)
			Assert.assertTrue(browser.link(name).exists(), "before delete, permission should in the list"); 
		SelfservicepermissionTasks.deletePermission(browser, names); 
		for(String name:names)
			Assert.assertFalse(browser.link(name).exists(), "after delete, permission should disappear");
	}
	
	@Test (groups={"deletePermission"}, dataProvider="leftOverPermissions", dependsOnGroups="modifyPermission",
			description="delete self service permission")
		public void deleteLeftOverPermission(String scenario, String permissionName) throws Exception {
			browser.navigateTo(commonTasks.selfservicepermissionPage);
			Assert.assertTrue(browser.link(permissionName).exists(), "before delete, permission should in the list");
			SelfservicepermissionTasks.deletePermission(browser, permissionName);
			Assert.assertFalse(browser.link(permissionName).exists(), "after delete, permission should disappear");
		}
	
	/***************************************************************************** 
	 *             Data providers                                                * 
	 *****************************************************************************/
	private static String[] existingPermissions = { "User Self service", "Self can write own password"};
	
	private static String[] defaults = {"audio","businesscategory","carlicense","cn","departmentnumber",
											"description","destinationindicator","displayname","employeenumber",
											"employeetype","employeetype","gecos","gidnumber","givenname","homedirectory",
											"homephone","homepostaladdress","inetuserhttpurl", "inetuserstatus",
											"initials","internationalisdnnumber","ipauniqueid","jpegphoto","krbcanonicalname",
											"krbextradata","krbextradata","krblastfailedauth","krblastpwdchange","krblastsuccessfulauth",
											"krbloginfailedcount","krbmaxrenewableage","krbmaxticketlife","krbpasswordexpiration",
											"krbprincipalaliases","krbprincipalexpiration","krbprincipalkey","krbprincipalname",
											"krbprincipaltype","krbpwdhistory","krbpwdpolicyreference","krbticketflags","krbticketpolicyreference",
											"krbupenabled","l","labeleduri","loginshell","mail","manager","memberof","mepmanagedentry",
											"mobile","o","objectclass","ou","pager","photo","physicaldeliveryofficename","postaladdress",
											"postalcode","postofficebox","preferreddeliverymethod","preferredlanguage","registeredaddress",
											"roomnumber","secretary","seealso","sn","st","street","telephonenumber","teletexterminalidentifier",
											"telexnumber","title","uid","uidnumber","usercertificate","userpassword","userpkcs12",
											"usersmimecertificate","x121address","x500uniqueidentifier"};
	private static Random random = new Random(System.currentTimeMillis());
	private static int pick=5;
	private static String singlePermission = CommonHelper.getSingle(random, defaults);
	private static String multiplePermissions = CommonHelper.getMultiple(random,  pick, defaults);
	private static String allPermissions = CommonHelper.getAll(defaults);
	private static String[] testPermissions = {"permission000", "permission001", "permission002", "permission003", "permission004",
													"permission005", "permission006", "permission007", "permission008", "permission009"};
	
	@DataProvider(name="addPermission")
	public Object[][] getAddPermission()
	{
		String[][] permissions = 
						{{"scenario: single attribute", testPermissions[0], singlePermission},
						{"scenario: multiple attributes", testPermissions[1], multiplePermissions},
						{"scenario: all attributes", testPermissions[2], allPermissions}};
		return permissions;
	}

	@DataProvider(name="addPermission_addandaddanother")
	public Object[][] getAddPermission_addandaddanother()
	{
		String[][] permissions = {{testPermissions[3] + "," + testPermissions[4] + "," + testPermissions[5] ,multiplePermissions}};
		return permissions;
	}

	@DataProvider(name="addPermission_addthenedit")
	public Object[][] getAddPermission_addthenedit()
	{
		String[][] permissions = {{testPermissions[6] ,multiplePermissions}};
		return permissions;
	}

	@DataProvider(name="addPermission_addthencancel")
	public Object[][] getAddPermission_addthencancel()
	{
		String[][] permissions = {{"addThanCancel",multiplePermissions}};
		return permissions;
	}

	@DataProvider(name="modifyPermission_AddSingleAttributes")
	public Object[][] getAddPermission_AddSingleAttributes()
	{
		String[][] permissions = {{testPermissions[1],singlePermission}};
		return permissions;
	}

	@DataProvider(name="modifyPermission_AddMultipleAttributes")
	public Object[][] getAddPermission_AddMultipleAttributes()
	{
		String[][] permissions = {{testPermissions[0],multiplePermissions}};
		return permissions;
	}

	@DataProvider(name="modifyPermission_deleteSingleAttributes")
	public Object[][] getAddPermission_deleteSingleAttributes()
	{
		String[][] permissions = {{testPermissions[1],singlePermission}};
		return permissions;
	}

	@DataProvider(name="modifyPermission_deleteMultipleAttributes")
	public Object[][] getAddPermission_deleteMultipleAttributes()
	{
		String[][] permissions = {{testPermissions[0],multiplePermissions}};
		return permissions;
	}

	@DataProvider(name="deletePermissionSingle")
	public Object[][] getDeletePermissionSingle()
	{
		return getAddPermission();
	}

	@DataProvider(name="deletePermissionMultiple")
	public Object[][] getDeletePermissionMultiple()
	{
		return getAddPermission_addandaddanother();
	}

	@DataProvider(name="leftOverPermissions")
	public Object[][] getLeftOverPermissions()
	{
		String[][] permissions = {{testPermissions[6]}};
		return permissions;
	}
}//class SelfservicepermissionTests
