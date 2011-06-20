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
	private String userPage = "/ipa/ui/#identity=user&navigation=identity";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true)
	public void intialize() throws CloneNotSupportedException {		
		selenium = CommonTasks.sel();	
		selenium.open(SeleniumTestScript.ipaServerURL + userPage);		
	}
	

	/*
	 * Add users - for positive tests
	 */
	@Test (groups={"userAddTests"}, dataProvider="getUserTestObjects")	
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
	}
	
	/*
	 * Edit users - for positive tests
	 */
	@Test (groups={"userEditTests"}, dataProvider="getUserEditTestObjects")	
	public void testUserEdit(String testName, String uid, String title, String mail) throws Exception {
		// wait for the User Groups page to be loaded
		CommonTasks.waitForRefreshTillTextPresent(selenium, "Add");
		
		// wait for the users to be listed before checking if the user to be added exists already
		CommonTasks.waitForRefresh(selenium);

		// verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(selenium.isTextPresent(uid), uid + " is available for editing");
		
		//modify this user
		UserTasks.modifyUser(selenium, uid, title, mail);
		CommonTasks.waitForRefresh(selenium);
		
		//TODO: verify changes		
	}
	
	
	/*
	 * Delete users - for positive tests
	 */
	@Test (groups={"userDeleteTests"}, dataProvider="getUserDeleteTestObjects")	
	public void testUserDelete(String testName, String uid) throws Exception {
		// wait for the User Groups page to be loaded
		CommonTasks.waitForRefreshTillTextPresent(selenium, "Delete");
		
		// wait for the users to be listed before checking if the user to be added exists already
		CommonTasks.waitForRefresh(selenium);

		// verify user to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(selenium.isTextPresent(uid), uid + " is available for deleting");
		
		//modify this user
		UserTasks.deleteUser(selenium, uid);
		CommonTasks.waitForRefresh(selenium);
		
		// verify user is deleted
		com.redhat.qe.auto.testng.Assert.assertFalse(selenium.isTextPresent(uid), uid + " was deleted");
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
	
	
	/*
	 * Data to be used when editing users
	 */
	@DataProvider(name="getUserEditTestObjects")
	public Object[][] getUserEditTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editUserTestObjects());
	}
	protected List<List<Object>> editUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//String sLongName = "auto_" + tasks.generateRandomString(251);
		
        //										testname					uid              		title					mail   
		ll.add(Arrays.asList(new Object[]{ "edit_good_user",				"testuser", 			"Software Engineer",	"testuser@example.com"     } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when deleting users
	 */
	@DataProvider(name="getUserDeleteTestObjects")
	public Object[][] getUserDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteUserTestObjects());
	}
	protected List<List<Object>> deleteUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//String sLongName = "auto_" + tasks.generateRandomString(251);
		
        //										testname					uid              		
		ll.add(Arrays.asList(new Object[]{ "delete_good_user",				"testuser"     } ));
		        
		return ll;	
	}

}
