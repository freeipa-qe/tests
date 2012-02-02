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
		SelfservicepermissionTasks.addSelfservicePermission(browser, permissionName, attrs);  
		Assert.assertTrue(browser.link(permissionName).exists(), "after add, permission should exist in list");
	}

	@Test (groups={"addPermission"}, dataProvider="undecided",
		description = "add new self service permission via 'Add and Add Another' button, expect user can stay at same dialogue to continue add new permission")
	public void addPermission_addandaddanother() throws Exception {
		 
	}
	
	@Test (groups={"addPermission"}, dataProvider="undecided",
		description = "add new self service permission via 'Add and Edit' button, expect to get into editting mode after add")
	public void addPermission_addthenedit() throws Exception {
		 
	}
	
	@Test (groups={"addPermission"}, dataProvider="undecided",
		description = "add new self service permission then click 'Cancel' button, expect no new permission being created")
	public void addPermission_addthencancel() throws Exception {
	}

	@Test (groups={"addPermission_negative"}, dataProvider="addPermissionNegative",
		description = "negative test for add self service permission")
	public void addPermission_negative() throws Exception {
		// check required fields: permission name, at least one attribute
		// check illegal permission names 
	}
  
	/////////// modify permission /////////////////////////
	@Test (groups={"modifyPermission"}, dataProvider="modifyPermission", dependsOnGroups="addPermission",
		description="modify self service permission")
	public void modifyPermission(String testDescription, String textboxName, String invalidData, String expectedErrorMsg) throws Exception {
		 
	}

	@Test (groups={"modifyPermission_negative"}, dataProvider="undecided", dependsOnGroups="addPermission",
		description="negative test case for self service permission modification")
	public void modifyPermission_negative(String testDescription, String textboxName, String invalidData, String expectedErrorMsg) throws Exception {
		 
	}
	/////////// delete permission /////////////////////////
	@Test (groups={"deletePermission"}, dataProvider="deletePermission", dependsOnGroups="addPermission",
		description="delete self service permission")
	public void deletePermission(String scenario, String permissionName, String attributes) throws Exception {
		browser.navigateTo(commonTasks.selfservicepermissionPage);
		Assert.assertTrue(browser.link(permissionName).exists(), "before delete, permission should in the list");
		SelfservicepermissionTasks.deletePermission(browser, permissionName);
		Assert.assertFalse(browser.link(permissionName).exists(), "after delete, permission should disappear");
	}
	
	
	/***************************************************************************** 
	 *             Data providers                                                * 
	 *****************************************************************************/
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
	
	
	@DataProvider(name="addPermission")
	public Object[][] getAddPermission()
	{
		String[][] permissions = 
						{{"scenario: single attribute","singleAttribute", singlePermission},
						{"scenario: multiple attributes","multipleAttribute", multiplePermissions},
						{"scenario: all attributes","allAttritubes", allPermissions}};
		return permissions;
	}

	@DataProvider(name="deletePermission")
	public Object[][] getDeletePermission()
	{
		return getAddPermission();
	}

}//class SelfservicepermissionTests
