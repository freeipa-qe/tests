package com.redhat.qe.ipa.sahi.tests.user;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

public class UserTests {
	public static SahiTasks sahiTasks = null;	
	private String userPage = "/ipa/ui/#identity=user&navigation=identity";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true)
	public void intialize() throws CloneNotSupportedException {					
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+userPage, true);
	}
	

	/*
	 * Add users - for positive tests
	 */
	@Test (groups={"userAddTests"}, dataProvider="getUserTestObjects")	
	public void testUseradd(String testName, String uid, String givenname, String sn) throws Exception {
		//TODO: verify user doesn't exist
		
		//new test user can be added now
		UserTasks.createUser(sahiTasks, uid, givenname, sn);		
		
		//TODO: verify user was added successfully
	}
	
	/*
	 * Edit users - for positive tests
	 */
	@Test (groups={"userEditTests"}, dataProvider="getUserEditTestObjects")	
	public void testUserEdit(String testName, String uid, String title, String mail) throws Exception {
		
		//TODO:  verify user to be edited exists
		
		//modify this user
		UserTasks.modifyUser(sahiTasks, uid, title, mail);
		
		//TODO: verify changes		
	}
	
	
	/*
	 * Delete users - for positive tests
	 */
	@Test (groups={"userDeleteTests"}, dataProvider="getUserDeleteTestObjects")	
	public void testUserDelete(String testName, String uid) throws Exception {
		

		//TODO: verify user to be edited exists
		
		//modify this user
		UserTasks.deleteUser(sahiTasks, uid);
		
		//TODO:  verify user is deleted
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
		ll.add(Arrays.asList(new Object[]{ "create_user2",				    "user2", 			    "Test2",	"User2"     } ));
		ll.add(Arrays.asList(new Object[]{ "create_user3",				    "user3", 			    "Test3",	"User3"     } ));
		        
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
