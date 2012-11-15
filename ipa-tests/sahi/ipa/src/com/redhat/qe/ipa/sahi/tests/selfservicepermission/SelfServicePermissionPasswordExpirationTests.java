package com.redhat.qe.ipa.sahi.tests.selfservicepermission;

import java.util.*;

import java.util.logging.Logger;
import org.testng.annotations.*;

import com.redhat.qe.auto.testng.Assert; 
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonHelper;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.ConfigurationTasks;
import com.redhat.qe.ipa.sahi.tasks.PasswordPolicyTasks;
import com.redhat.qe.ipa.sahi.tasks.SelfservicepermissionTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

public class SelfServicePermissionPasswordExpirationTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(SelfservicepermissionTests.class.getName());
	private static SahiTasks browser;
	
	/*
	 * PreRequisite - 
	 */
	
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		browser = sahiTasks;
		browser.navigateTo(commonTasks.selfservicepermissionPage, true);
		browser.setStrictVisibilityCheck(true); 
		//Changing configuration user option - Password Expiration Notification (days) to 2 days
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		String pwdExpNotify="2";
		ConfigurationTasks.setConfigValue(sahiTasks, "ipapwdexpadvnotify", pwdExpNotify);
		ConfigurationTasks.verifyConfigValue(sahiTasks, "ipapwdexpadvnotify", pwdExpNotify);
		//Changing Password policies - Max lifetime (days) to 4 days.
		browser.navigateTo(commonTasks.passwordPolicyPage, true);
		String fieldValue = "4";
		browser.link("global_policy").click();
		PasswordPolicyTasks.modifyPolicy_update(browser,"krbmaxpwdlife", fieldValue);
		browser.navigateTo(commonTasks.passwordPolicyPage, true);
	}//initialize	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//                               test cases                                                         //
	//////////////////////////////////////////////////////////////////////////////////////////////////////

	@Test (groups={"userPasswordExpiration_BZ813402"}, dataProvider="getUserPasswordExpiration",
			description = "Login as user and add sshkey")
		public void testUserPwdExpir_BZ813402(String testName, String uid, String givenName, String sn, String password,String userpassword, String newpassword, String expectedMsg ) throws Exception { 
		
		// adding new user (user813402) for first time.
		browser.navigateTo(commonTasks.userPage, true);
			if (!browser.link(uid).exists())
				UserTasks.createUser(sahiTasks, uid, givenName, sn, password, password, "Add");
			    Assert.assertTrue(sahiTasks.link(uid).exists(), "Added user " + uid + "  successfully");
			
			    //Logging in as  user813402 
			commonTasks.formauthNewUser(sahiTasks, uid, password, userpassword);
			Assert.assertTrue(browser.div("4 undo").exists(),"Max lifetime is 4");
			
			
			//Incrementing current current date
			String[] cmd = {"/bin/bash", "-c", "date -s '2 day'"};
			log.info("changing date");
			Runtime.getRuntime().exec(cmd);
			log.info("incremented 2 days successfully");
			
			// log-out from current user to avoid session closed error.			
                if(!sahiTasks.link("form-based authentication").exists()){
				
				if(sahiTasks.link("Logout").exists()){
					
					sahiTasks.link("Logout").click();
					if (!System.getProperty("os.name").startsWith("Windows"))
					   Runtime.getRuntime().exec("kdestroy");
				}
}
			//Logging in as user813402 for checking password expires Notification 
			commonTasks.formauth(sahiTasks, uid, userpassword);
			
			//Entering new password before expiring current password
			Assert.assertTrue(browser.span(expectedMsg).exists(),"Expected message :- "+expectedMsg +"");
			SelfservicepermissionTasks.pwdExpiration(browser,userpassword,newpassword);
			log.info("password re-set successfully");
		 

			//re-login as admin
			commonTasks.formauth(browser, "admin", System.getProperty("ipa.server.password"));
			
			// deleting user813402
			//verify user to be deleted exists
			Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + "  to be deleted exists");
			//modify this user
			UserTasks.deleteUser(sahiTasks, uid);
			//verify user is deleted
			Assert.assertFalse(sahiTasks.link(uid).exists(), "User " + uid + "  deleted successfully");
			
			
		}
		
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {
		// restoring default values 
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		String pwdExpNotify="4";
		ConfigurationTasks.setConfigValue(sahiTasks, "ipapwdexpadvnotify", pwdExpNotify);
		ConfigurationTasks.verifyConfigValue(sahiTasks, "ipapwdexpadvnotify", pwdExpNotify);
		//Changing Password policies - Max lifetime (days) to 4 days.
		browser.navigateTo(commonTasks.passwordPolicyPage, true);
		String fieldValue = "90";
		browser.link("global_policy").click();
		PasswordPolicyTasks.modifyPolicy_update(browser,"krbmaxpwdlife", fieldValue);
		browser.navigateTo(commonTasks.passwordPolicyPage, true);
		//restoring current date back
		//decrementing current date
		String[] cmd = {"/bin/bash", "-c", "date -s '2 day ago'"};
		log.info("changing date");
		Runtime.getRuntime().exec(cmd);
		log.info("decrementing 2 days successfully");
		
	}
		

		/*******************************************************
		 ************      DATA PROVIDERS     ******************
		 *******************************************************/
		
		/*
		 * Data to be used when adding sshpubkeys as user
		 */
		
		@DataProvider(name="getUserPasswordExpiration")
		public Object[][] getUserPasswordExpiration() {
			return TestNGUtils.convertListOfListsTo2dArray(createUserPasswordObjects());
		}
		protected List<List<Object>> createUserPasswordObjects() {		
			List<List<Object>> ll = new ArrayList<List<Object>>();
			
	        //									testName		 		          uid			  givenName		     sn		  password	   userPasswod	newPassword	            ExpectedMSG
			ll.add(Arrays.asList(new Object[]{ "PasswordExpiration_BZ813402",	"user813402",	  "user",			"test",	"Password123", "varun123" ,"Secret123","Your password expires in 1 days. Reset your password."} ));
			return ll;	
		}
		
		
	}
