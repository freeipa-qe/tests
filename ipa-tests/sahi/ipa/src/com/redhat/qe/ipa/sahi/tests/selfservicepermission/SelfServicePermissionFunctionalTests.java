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
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

public class SelfServicePermissionFunctionalTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(SelfservicepermissionTests.class.getName());
	private static SahiTasks browser;
	
	/*
	 * PreRequisite - 
	 */
	//User used in this testsuite
	private String uid = "user1";
	private String givenName = "user";
	private String sn = "one";
	private String password="Secret123";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		browser = sahiTasks;
		browser.navigateTo(commonTasks.selfservicepermissionPage, true);
		browser.setStrictVisibilityCheck(true); 
	}//initialize
	
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
	@Test (groups={"addUserSSHKey"}, dataProvider="getAddUserSSHKey",
		description = "Login as user and add sshkey")
	public void testUserAddSSHKey(String testName, String uid, String givenName, String sn, String password, String keyType, String fileName, String keyName1, String addToKey) throws Exception { 
		browser.navigateTo(commonTasks.userPage, true);
		if (!browser.link(uid).exists())
			UserTasks.createUser(sahiTasks, uid, givenName, sn, password, password, "Add");
		
		
		commonTasks.formauthNewUser(sahiTasks, uid, password, password);
		
		String sshKey=CommonTasks.generateSSH(uid,keyType,fileName);
		
		UserTasks.addSSHKey(sahiTasks,uid,sshKey,addToKey);
		
		Assert.assertTrue(sahiTasks.getText(sahiTasks.span(keyName1)).contains("ssh-" + keyType) , "ssh " + keyType + " for " + uid + " added successfully");
		
	}
	@Test (groups={"resetUserSSHKeyPermission"}, dataProvider="getResetUserSSHKeyPermission",
			description = "Reset the user sshkey selfservice permission")
	public void testUserResetSSHKeyPermission(String testName, String uid, String permission, String attribute1, String attribute2, String password, String errorMsg) throws Exception { 
		commonTasks.formauth(browser, "admin", System.getProperty("ipa.server.password"));
		
		browser.navigateTo(commonTasks.selfservicepermissionPage, true);
		
		SelfservicepermissionTasks.resetSSHKeyPermission(browser, permission, attribute1, attribute2);
		
		commonTasks.formauth(sahiTasks, uid, password);
		
		SelfservicepermissionTasks.deleteSSHKey(browser, errorMsg);
		
		if(browser.div("error_dialog").exists()){
			Assert.assertTrue(browser.div("error_dialog").getText().contains(errorMsg), "Error Matches Expected error message");
			browser.button("Cancel").click();
		}
		commonTasks.formauth(browser, "admin", System.getProperty("ipa.server.password"));
		
		browser.navigateTo(commonTasks.userPage, true);
		
		UserTasks.deleteUser(browser, uid);
		
		browser.navigateTo(commonTasks.selfservicepermissionPage, true);
		
		SelfservicepermissionTasks.revertSSHKeyPermission(browser, permission, attribute1, attribute2);
		
		
	}
	

	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding sshpubkeys as user
	 */
	
	@DataProvider(name="getAddUserSSHKey")
	public Object[][] getAddUserSSHKey() {
		return TestNGUtils.convertListOfListsTo2dArray(AddUserSSHKeyTestObjects());
	}
	protected List<List<Object>> AddUserSSHKeyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname		 		uid			givenName		sn		password		keyType		fileName		keyName1			addToKey	
		ll.add(Arrays.asList(new Object[]{ "add_sshkey_rsa_user",	"user9",	"user",			"one",	"Secret123",	"rsa",		"user9_rsa",	"sshkey-status",	""  	  } ));
		return ll;	
	}
	
	/*
	 * Data to be used when resetting user sshkey selfservice permission
	 */
	
	@DataProvider(name="getResetUserSSHKeyPermission")
	public Object[][] getResetUserSSHKeyPermission() {
		return TestNGUtils.convertListOfListsTo2dArray(resetUserSSHKeyPermissionTestObjects());
	}
	protected List<List<Object>> resetUserSSHKeyPermissionTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname		 			uid			permission										attribute1		attribute2		password		errorMsg			
		ll.add(Arrays.asList(new Object[]{ "reset_sshkey_permission",	"user9",	"Users can manage their own SSH public keys",	"carlicense",	"ipasshpubkey",	"Secret123",	"Insufficient access: Insufficient 'write' privilege"  	  } ));
		return ll;	
	}
	
	
}
