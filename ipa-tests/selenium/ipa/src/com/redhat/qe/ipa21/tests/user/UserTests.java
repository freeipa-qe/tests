package com.redhat.qe.ipa21.tests.user;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.base.SeleniumTestScript;
import com.redhat.qe.ipa21.tasks.CommonTasks;
import com.redhat.qe.ipa21.tasks.UserTasks;

public class UserTests {
	public  ExtendedSelenium selenium = null;	
	private String userPage = SeleniumTestScript.ipaServerURL + "/ipa/ui/#identity=0&navigation=0";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true)
	public void intialize() throws CloneNotSupportedException {		
		selenium = CommonTasks.sel();	
		selenium.open(SeleniumTestScript.ipaServerURL + "/ipa/ui/#identity=0&navigation=0");
	}
	

	/*
	 * Add users - for positive tests
	 */
	@Test (groups={"userTests"}, dataProvider="getUserTestObjects")	
	public void testUseradd(String testName, String uid, String givenname, String sn) throws Exception {
		// wait for the User Groups page to be loaded
		CommonTasks.waitForRefreshTillTextPresent(selenium, "Add");
		
		// wait for the users to be listed before checking if the user to be added exists already
		CommonTasks.waitForRefresh(selenium);

		// verify user doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(selenium.isTextPresent(uid), uid + " was added in previous test");
		
		//new test user can be added now
		UserTasks.createUser(selenium, uid, givenname, sn);			
		CommonTasks.waitForRefresh(selenium);
		//verify user was added successfully
		com.redhat.qe.auto.testng.Assert.assertTrue(selenium.isTextPresent(uid), uid + " added successfully");
		
		//modify this user
		UserTasks.modifyUser(selenium, uid);
		CommonTasks.waitForRefresh(selenium);
	}
	
	/*
	 * Data to be used when adding users
	 */
	@DataProvider(name="getUserTestObjects")
	public Object[][] getUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserTestObjects());
	}
	protected List<List<Object>> createUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//String sLongName = "auto_" + tasks.generateRandomString(251);
		
        //										testname					uid              		givenname	sn   
		ll.add(Arrays.asList(new Object[]{ "create_good_user",				"testuser", 			"Test",		"User"     } ));
		        
		return ll;	
	}

}
