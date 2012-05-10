package com.redhat.qe.ipa.sahi.tests.configuration;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.ConfigurationTasks;
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.HBACTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;


/*
 * Comments from review:
 * 1)  Scenario ... you could try to delete the configgroup while it is set to the default.  You shouldn't be able to delete it. //done

2) I am not sure that spaces should be allowed in the default email domain.

So ... 2 questions for Rob ... //done
1) should spaces be allowed in default email domain?
2) what is the max user length if the value is set to blank or should blank not be allowed?

I also tried running the tests from eclipse and I think there is an order issue, or you need to set the search size limit to 
over 21 as the last value in that test.  The config user that gets added and then deleted, doesn't get deleted because it is 
displayed on the screen and then subsequently adding the user again - duplicate user error. //done
 */
public class ConfigurationTest extends SahiTestScript{
	private static Logger log = Logger.getLogger(ConfigurationTest.class.getName()); 
	

	private String currentPage = "";
	
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", 
			alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		//sahiTasks.setStrictVisibilityCheck(true);
		
		//to set up search tests, adding objects in one category on identity and policy tabs 
		//add users
		sahiTasks.navigateTo(commonTasks.userPage, true);
		String testUser="user";
		for (int i=0; i<15; i++) {
			if (!sahiTasks.link(testUser+i).exists())
				UserTasks.createUser(sahiTasks, testUser+i, testUser+i, testUser+i, "Add");
		}		
		UserTasks.modifyUserMailingAddress(sahiTasks, "user0", "Westford Street", "Westford", "MA", "01234");
		//add hbacrules
		sahiTasks.navigateTo(commonTasks.hbacPage, true);
	    String testHBACRule="rule";
	    for (int i=0; i<15; i++) {
			if (!sahiTasks.link(testHBACRule+i).exists())
				HBACTasks.addHBACRule(sahiTasks, testHBACRule+i, "Add");
	    }
		
		sahiTasks.navigateTo(commonTasks.groupPage, true);
	    String testGroup="group";
	    for (int i=0; i<5; i++) {
			if (!sahiTasks.link(testGroup+i).exists())
				GroupTasks.addGroup(sahiTasks, testGroup+i, "testing for config");
	    }
		
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		currentPage = sahiTasks.fetch("top.location.href");
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) ) {
			//CommonTasks.checkError(sahiTasks);
			log.fine("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.configurationPage, true);
		}		
	}		
	
	
	/*
	 * Test Search Options - size
	 * if search limit is set to x, search for x objects in users and rules
	 * Not testing a search limit on all objects:
	 * users/groups/hosts/hostgroups/netgroups/hbacrules/hbacsvc/hbacsvgrp/sudoriles/sudocmd/sudocmdgrp 
	 * 
	 * Setting the time limit or size limit value to zero (0) or -1 means that there are no limits on searches. 
	 */
	@Test (groups={"configSearchOptionSizeLimitTests"}, description="Verify valid search size limit values", 
			dataProvider="getConfigSearchOptionSizeLimitTestObjects")	
	public void testConfigSearchOptionSizeLimitValue(String testName, String value, String expectedRows) throws Exception {
			ConfigurationTasks.setConfigValue(sahiTasks, "ipasearchrecordslimit", value);
			ConfigurationTasks.verifyConfigValue(sahiTasks, "ipasearchrecordslimit", value);
		//	ConfigurationTasks.verifySearchSizeLimitFunctional(sahiTasks, commonTasks, value, expectedRows);
			//set search size limit back to its default
			ConfigurationTasks.setConfigValue(sahiTasks, "ipasearchrecordslimit", "100");
	} 
	
	/*
	 * Test Search Options - size
	 * Using invalid sizes
	 */
	@Test (groups={"configSearchOptionInvalidSizeLimitTests"}, description="Verify invalid search size limit values", 
			dataProvider="getConfigSearchOptionInvalidSizeLimitTestObjects")	
	public void testConfigSearchOptionInvalidSizeLimitValue(String testName, String value, String expectedError1, String expectedError2) throws Exception {
			ConfigurationTasks.setInvalidConfigValue(sahiTasks, "ipasearchrecordslimit", value, expectedError1, expectedError2);
	} 
	
	/*
	 * Test Search Options - time
	 * 
	 * TODO: nkrishnan: Manual test to be added to make sure the search for a long list, 
	 * times out within timelimit
	 */
	@Test (groups={"configSearchOptionTimeLimitTests"}, description="Verify valid search time limit values", 
			dataProvider="getConfigSearchOptionTimeLimitTestObjects")	
	public void testConfigSearchOptionTimeLimitValue(String testName, String value) throws Exception {
			ConfigurationTasks.setConfigValue(sahiTasks, "ipasearchtimelimit", value);
			ConfigurationTasks.verifyConfigValue(sahiTasks, "ipasearchtimelimit", value);			
	} 
	
	/*
	 * Test Search Options - time
	 * Using invalid sizes
	 * 
	 * 
	 */
	@Test (groups={"configSearchOptionInvalidTimeLimitTests"}, description="Verify invalid search time limit values", 
			dataProvider="getConfigSearchOptionInvalidTimeLimitTestObjects")	
	public void testConfigSearchOptionInvalidTimeLimitValue(String testName, String value, String expectedError1, String expectedError2) throws Exception {
			ConfigurationTasks.setInvalidConfigValue(sahiTasks, "ipasearchtimelimit", value, expectedError1, expectedError2);
	} 
	
	
	/* 
	 * Test User Options - uid,givenname,sn,telephonenumber,ou,title
	 * search fields - add user and search for the field
	 */
	@Test (groups={"configUserOptionSearchFieldTests"}, description="Verify valid User Search Field values", 
			dataProvider="getConfigUserOptionSearchFieldTestObjects")	
	public void testConfigUserOptionSearchField(String testName, String searchField, String searchValue, String expectedUser) throws Exception {
		ConfigurationTasks.setConfigValue(sahiTasks, "ipausersearchfields", searchField);
		ConfigurationTasks.verifyConfigValue(sahiTasks, "ipausersearchfields", searchField);
		ConfigurationTasks.verifyUserSearchFieldFunctional(sahiTasks, commonTasks, searchValue, expectedUser);
	} 
	
	
	/* 
	 * Test User Options 
	 * search field - invalid data
	 * 
	 */
	@Test (groups={"configUserOptionInvalidSearchFieldTests"}, description="Verify invalid User Search Field values", 
			dataProvider="getConfigUserOptionInvalidSearchFieldTestObjects")	
	public void testConfigUserOptionInvalidSearchField(String testName, String value, String expectedError) throws Exception {
		ConfigurationTasks.setInvalidConfigValue(sahiTasks, "ipausersearchfields", value, expectedError, "");		
	}
	
	/*
	 * Test User Options - email 
	 * 
	 */
	@Test (groups={"configUserOptionEmailTests"}, description="Verify valid User Default Email values", 
			dataProvider="getConfigUserOptionEmailTestObjects")	
	public void testConfigUserOptionEmail(String testName, String email) throws Exception {
		ConfigurationTasks.setConfigValue(sahiTasks, "ipadefaultemaildomain", email);
		ConfigurationTasks.verifyConfigValue(sahiTasks, "ipadefaultemaildomain", email);
		String user = "user1";
		ConfigurationTasks.verifyUserEmailFunctional(sahiTasks, commonTasks, email, user);
	} 
	
	
	/*
	 * Test User Options - email - invalid
	 * 
	 */
	
	@Test (groups={"configUserOptionInvalidEmailTests"}, description="Verify invalid User Default Email values", 
			dataProvider="getConfigUserOptionInvalidEmailTestObjects")	
	public void testConfigUserOptionInvalidEmail(String testName, String email, String expectedError) throws Exception {
		ConfigurationTasks.setInvalidConfigValue(sahiTasks, "ipadefaultemaildomain", email, expectedError, "");		
	}
		
	/*
	 * Test User Options - group 
	 * 
	 */
	@Test (groups={"configUserOptionGroupTests"}, description="Verify valid User Default User Group values", 
			dataProvider="getConfigUserOptionGroupTestObjects")	
	public void testConfigUserOptionGroup(String testName, String group) throws Exception {
		ConfigurationTasks.setGroupConfigValue(sahiTasks, commonTasks, group);
		ConfigurationTasks.verifyConfigValue(sahiTasks, "ipadefaultprimarygroup", group);		
		String user = "configuser";
		ConfigurationTasks.verifyUserGroupFunctional(sahiTasks, commonTasks, group, user);
		ConfigurationTasks.verifyDeleteDefaultUserGroup(sahiTasks, commonTasks, group);
	} 
	
	
	/*
	 * Test User Options - home dir 
	 * 
	 */
	@Test (groups={"configUserOptionHomeDirTests"}, description="Verify valid User Home Directory values", 
			dataProvider="getConfigUserOptionHomeDirTestObjects")	
	public void testConfigUserOptionHomeDir(String testName, String homedir) throws Exception {
		ConfigurationTasks.setConfigValue(sahiTasks, "ipahomesrootdir", homedir);
		ConfigurationTasks.verifyConfigValue(sahiTasks, "ipahomesrootdir", homedir);
		String user = "configuser";
		ConfigurationTasks.verifyUserHomeDirFunctional(sahiTasks, commonTasks, homedir, user);
	} 
	
	
	/*
	 * Test User Options - home dir - invalid
	 * 
	 */
	
	@Test (groups={"configUserOptionInvalidHomeDirTests"}, description="Verify invalid User Home Directory values", 
			dataProvider="getConfigUserOptionInvalidHomeDirTestObjects")	
	public void testConfigUserOptionInvalidHomeDir(String testName, String homedir, String expectedError) throws Exception {
		ConfigurationTasks.setInvalidConfigValue(sahiTasks, "ipahomesrootdir", homedir, expectedError, "");		
	}
		
	
	
	/*
	 * Test User Options
	 * Name length
	 */
	@Test (groups={"configUserOptionNameLengthTests"}, description="Verify valid User Name Length values", 
			dataProvider="getConfigUserOptionNameLengthTestObjects")	
	public void testConfigUserOptionNameLength(String testName, String nameLength, String userGood, String userBad) throws Exception {
		ConfigurationTasks.setConfigValue(sahiTasks, "ipamaxusernamelength", nameLength);
		ConfigurationTasks.verifyConfigValue(sahiTasks, "ipamaxusernamelength", nameLength);
		
		ConfigurationTasks.verifyUserNameLengthFunctional(sahiTasks, commonTasks, nameLength, userGood, userBad);
	} 
	
	
	/*
	 * Test User Options - Name length - invalid
	 * 
	 */	
	@Test (groups={"configUserOptionInvalidNameLengthTests"}, description="Verify invalid User Name Length values", 
			dataProvider="getConfigUserOptionInvalidNameLengthTestObjects")	
	public void testConfigUserOptionInvalidNameLength(String testName, String nameLength, String expectedError1, String expectedError2) throws Exception {
		ConfigurationTasks.setInvalidConfigValue(sahiTasks, "ipamaxusernamelength", nameLength, expectedError1, expectedError2);		
	}
	
	
	/*
	 * Test User Options
	 * Password Expiration Notification
	 * TODO: nkrishnan - add manual tasks to verify values
	 */
	@Test (groups={"configUserOptionPwdExpNotifyTests"}, description="Verify valid Password Expiration Notification values", 
			dataProvider="getConfigUserOptionPwdExpNotifyTestObjects")	
	public void testConfigUserOptionPwdExpNotify(String testName, String pwdExpNotify) throws Exception {
		ConfigurationTasks.setConfigValue(sahiTasks, "ipapwdexpadvnotify", pwdExpNotify);
		ConfigurationTasks.verifyConfigValue(sahiTasks, "ipapwdexpadvnotify", pwdExpNotify);
	} 
	
	
	/*
	 * Test User Options - Password Expiration Notification - invalid
	 * 
	 */	
	@Test (groups={"configUserOptionInvalidPwdExpNotifyTests"}, description="Verify invalid Password Expiration Notification values", 
			dataProvider="getConfigUserOptionInvalidPwdExpNotifyTestObjects")	
	public void testConfigUserOptionInvalidPwdExpNotify(String testName, String pwdExpNotify, String expectedError1, String expectedError2) throws Exception {
		ConfigurationTasks.setInvalidConfigValue(sahiTasks, "ipapwdexpadvnotify", pwdExpNotify, expectedError1, expectedError2);		
	}
	
	/*
	 * Test User Options
	 * Enable Migration mode
	 * TODO: nkrishnan - add manual tasks to verify values
	 */
	@Test (groups={"configUserOptionEnableMigrationModeTests"}, description="Verify Enable Migration mode", 
			dataProvider="getConfigUserOptionEnableMigrationModeTestObjects")	
	public void testConfigUserOptionEnableMigrationMode(String testName, String mode) throws Exception {
		ConfigurationTasks.setMigrationModeConfigValue(sahiTasks, mode);
		ConfigurationTasks.verifyMigrationModeConfigValue(sahiTasks, mode);
	} 
	
	
	/* 
	 * Test Group Options - 
	 * search fields - search for group
	 */
	@Test (groups={"configGroupOptionSearchFieldTests"}, description="Verify valid Group Search Field values", 
			dataProvider="getConfigGroupOptionSearchFieldTestObjects")	
	public void testConfigGroupOptionSearchField(String testName, String searchField, String searchValue, String expectedGroup) throws Exception {
		ConfigurationTasks.setConfigValue(sahiTasks, "ipagroupsearchfields", searchField);
		ConfigurationTasks.verifyConfigValue(sahiTasks, "ipagroupsearchfields", searchField);
		ConfigurationTasks.verifyGroupSearchFieldFunctional(sahiTasks, commonTasks, searchValue, expectedGroup);
	} 
	
	
	/* 
	 * Test Group Options 
	 * search field - invalid data
	 * 
	 */
	@Test (groups={"configGroupOptionInvalidSearchFieldTests"}, description="Verify invalid Group Search Field values", 
			dataProvider="getConfigGroupOptionInvalidSearchFieldTestObjects")	
	public void testConfigGroupOptionInvalidSearchField(String testName, String value, String expectedError) throws Exception {
		ConfigurationTasks.setInvalidConfigValue(sahiTasks, "ipagroupsearchfields", value, expectedError, "");		
	}
	
	

	/*
	 * Default user objectclasses
	 *  https://bugzilla.redhat.com/show_bug.cgi?id=741951 
	 *  https://bugzilla.redhat.com/show_bug.cgi?id=741957
	 * if posixaccount is deleted, when adding a user - error -
	 * if ipaobject is deleted, when adding a user - error -
	 * if krbticketpolicyaux is deleted, can add user. ipa user-show will not list this in its objectclass
	 * 
	 * TODO: nkrishnan: Add tests after bugs are addressed
	 */
	
	
	/*
	 * Undo/Reset 
	 */
	@Test (groups={"configUndoResetTests"}, description="Verify Undo/Reset", 
			dataProvider="getConfigUndoResetTestObjects")	
	public void testConfigUndoReset(String testName, String field, String value, String buttonToClick) throws Exception {
		ConfigurationTasks.modifyAndVerifyConfigValues(sahiTasks, field, value, buttonToClick);		
	}
	
	
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException {
		
		//clean users and rules added
		sahiTasks.navigateTo(commonTasks.userPage, true);
		String testUser="user";
		for (int i=0; i<15; i++) {
			if (sahiTasks.link(testUser+i).exists())
				UserTasks.deleteUser(sahiTasks, testUser+i);
		}	
		if (sahiTasks.link("configuser").exists())
				UserTasks.deleteUser(sahiTasks, "configuser");	
	
		
		sahiTasks.navigateTo(commonTasks.hbacPage, true);
	    String testHBACRule="rule";
	    for (int i=0; i<15; i++) {
			if (sahiTasks.link(testHBACRule+i).exists())
				HBACTasks.deleteHBAC(sahiTasks, testHBACRule+i, "Delete");
	    }
		
		sahiTasks.navigateTo(commonTasks.groupPage, true);
	    String testGroup="group";
	    for (int i=0; i<5; i++) {
			if (sahiTasks.link(testGroup+i).exists())
				GroupTasks.deleteGroup(sahiTasks, testGroup+i);
	    } 
	    
	
	    
	  //restore defaults
	    sahiTasks.navigateTo(commonTasks.configurationPage, true);
	    ConfigurationTasks.restoreDefaults(sahiTasks, commonTasks);
	    
	    
	    
	    sahiTasks.navigateTo(commonTasks.groupPage, true);
		if (sahiTasks.link("configgroup").exists())
			GroupTasks.deleteGroup(sahiTasks, "configgroup");
		
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Test size limits - valid
	 */
	@DataProvider(name="getConfigSearchOptionSizeLimitTestObjects")
	public Object[][] getConfigSearchOptionSizeLimitTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigSearchOptionSizeLimitTestObjects());
	}
	protected List<List<Object>> createConfigSearchOptionSizeLimitTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			cn   		expectedRows				
		ll.add(Arrays.asList(new Object[]{ "sizelimit_negative",	"-1",		"16"	} ));
		ll.add(Arrays.asList(new Object[]{ "sizelimit_zero",		"0",		"16"      } ));
		ll.add(Arrays.asList(new Object[]{ "sizelimit_ten",			"10",		"10"      } ));
		
		
		return ll;	
	}
	
	/*
	 * Test size limits - invalid
	 */
	@DataProvider(name="getConfigSearchOptionInvalidSizeLimitTestObjects")
	public Object[][] getConfigSearchOptionInvalidSizeLimitTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigSearchOptionInvalidSizeLimitTestObjects());
	}
	protected List<List<Object>> createConfigSearchOptionInvalidSizeLimitTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   		expectedError1											expectedError2			
		ll.add(Arrays.asList(new Object[]{ "sizelimit_letter",				"abc",		"Input form contains invalid or missing values.",		"Must be an integer"		} ));
		ll.add(Arrays.asList(new Object[]{ "sizelimit_space",				" 10",      "Input form contains invalid or missing values.",		"Must be an integer"		} ));
		ll.add(Arrays.asList(new Object[]{ "sizelimit_blank",	           	"",		    "Input form contains invalid or missing values.",		"Must be an integer"		} ));
		
		return ll;	
	}
	
	
	/*
	 * Test time limits - valid
	 */
	@DataProvider(name="getConfigSearchOptionTimeLimitTestObjects")
	public Object[][] getConfigSearchOptionTimeLimitTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigSearchOptionTimeLimitTestObjects());
	}
	protected List<List<Object>> createConfigSearchOptionTimeLimitTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			cn   						
		ll.add(Arrays.asList(new Object[]{ "timelimit_negative",	"-1"	} ));
		ll.add(Arrays.asList(new Object[]{ "timelimit_ten",			"10"   	} ));
		
		
		return ll;	
	}
	
	
	
	/*
	 * Test time limits - invalid
	 */
	@DataProvider(name="getConfigSearchOptionInvalidTimeLimitTestObjects")
	public Object[][] getConfigSearchOptionInvalidTimeLimitTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigSearchOptionInvalidTimeLimitTestObjects());
	}
	protected List<List<Object>> createConfigSearchOptionInvalidTimeLimitTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   		expectedError1															expectedError2			
		ll.add(Arrays.asList(new Object[]{ "timelimit_zero",				"0",      	"invalid 'ipasearchtimelimit': searchtimelimit must be -1 or > 1.",		""		} ));
		ll.add(Arrays.asList(new Object[]{ "timelimit_letter",				"abc",		"Input form contains invalid or missing values.",						"Must be an integer"		} ));
		ll.add(Arrays.asList(new Object[]{ "timelimit_blank",		        "",         "Input form contains invalid or missing values.",						"Must be an integer"		} ));
		ll.add(Arrays.asList(new Object[]{ "timelimit_space",				" 10",      "Input form contains invalid or missing values.",						"Must be an integer"		} ));
		
				
		
		return ll;	
	}
	
	/*
	 * Test user options limits
	 * User Search Fields
	 * default list: uid,givenname,sn,telephonenumber,ou,title
	 */
	@DataProvider(name="getConfigUserOptionSearchFieldTestObjects")
	public Object[][] getConfigUserOptionSearchFieldTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionSearchFieldTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionSearchFieldTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   			searchValue		expectedUser				
		ll.add(Arrays.asList(new Object[]{ "usersearchfield_existing",		"uid",			"user4",		"user4"			} ));
		ll.add(Arrays.asList(new Object[]{ "usersearchfield_new",			"postalcode",	"01234",		"user0"			} ));				
		
		return ll;	
	}
	
	/*
	 * Test user options limits
	 * User Search Fields
	 */
	@DataProvider(name="getConfigUserOptionInvalidSearchFieldTestObjects")
	public Object[][] getConfigUserOptionInvalidSearchFieldTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionInvalidSearchFieldTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionInvalidSearchFieldTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						cn   		expectedError1				
		ll.add(Arrays.asList(new Object[]{ "usersearchfield_blank",				"",			"Input form contains invalid or missing values." } ));
		ll.add(Arrays.asList(new Object[]{ "usersearchfield_trailing_space",	"uid ",     "invalid 'usersearch': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "usersearchfield_leading_space",		" uid",     "invalid 'usersearch': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "usersearchfield_notallowed",		"abc",     	"invalid 'ipausersearchfields': attribute \"abc\" not allowed"	} ));
			
		return ll;	
	}
	
	/*
	 * Test user options 
	 * Default e-mail domain for new users
	 */
	@DataProvider(name="getConfigUserOptionEmailTestObjects")
	public Object[][] getConfigUserOptionEmailTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionEmailTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionEmailTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				email						uid			
		ll.add(Arrays.asList(new Object[]{ "useremail_new",				"idmqe.redhat.com"			} ));
		ll.add(Arrays.asList(new Object[]{ "useremail_specialchar",			"$idm-qe_redh@+.c^om~"		} ));		
		ll.add(Arrays.asList(new Object[]{ "useremail_blank",			""							} ));
		ll.add(Arrays.asList(new Object[]{ "useremail_numbers",			"12idm34qe"					} ));
		ll.add(Arrays.asList(new Object[]{ "useremail_space_inbetween",	"12 34"						} ));
		
		
		return ll;	
	}
	
	/*
	 * Test user options limits - invalid
	 * Default e-mail domain for new users
	 */
	@DataProvider(name="getConfigUserOptionInvalidEmailTestObjects")
	public Object[][] getConfigUserOptionInvalidEmailTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionInvalidEmailTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionInvalidEmailTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						email   			expectedError																} ));
		ll.add(Arrays.asList(new Object[]{ "useremail_trailing_space",			"testrelm ",     "invalid 'emaildomain': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "useremail_leading_space",			" testrelm",     "invalid 'emaildomain': Leading and trailing spaces are not allowed"	} ));
			
		return ll;	
	}
	
	/*
	 * Test user options 
	 * Default group for new users
	 */
	@DataProvider(name="getConfigUserOptionGroupTestObjects")
	public Object[][] getConfigUserOptionGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionGroupTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				group			
		ll.add(Arrays.asList(new Object[]{ "usergroup_new",				"configgroup"			} ));
		
		return ll;	
	}
	
	
	/*
	 * Test user options 
	 * Home dir
	 */
	@DataProvider(name="getConfigUserOptionHomeDirTestObjects")
	public Object[][] getConfigUserOptionHomeDirTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionHomeDirTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionHomeDirTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					homedir						uid			
		ll.add(Arrays.asList(new Object[]{ "userhomedir_new",				"/home/users"					} ));
		ll.add(Arrays.asList(new Object[]{ "userhomedir_specialchar",		"^&/*)(h*o@m%e/!u^s:e~r`s"		} ));		
		ll.add(Arrays.asList(new Object[]{ "userhomedir_numbers",			"1/home2/3users4"					} ));
		ll.add(Arrays.asList(new Object[]{ "userhomedir_space_inbetween",	"12 34"						} ));
		
		
		return ll;	
	}
	
	
	/*
	 * Test user options home dir - invalid
	 * Home dir 
	 */
	@DataProvider(name="getConfigUserOptionInvalidHomeDirTestObjects")
	public Object[][] getConfigUserOptionInvalidHomeDirTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionInvalidHomeDirTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionInvalidHomeDirTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						homedir   			expectedError																} ));
		ll.add(Arrays.asList(new Object[]{ "userhomedir_trailing_space",		"/home ",     "invalid 'homedirectory': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "userhomedir_leading_space",			" /home",     "invalid 'homedirectory': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "userhomedir_blank",				       "",	      "Input form contains invalid or missing values." } ));
		return ll;	    
	}
	
	/*
	 * Test user options 
	 * Username length
	 */
	@DataProvider(name="getConfigUserOptionNameLengthTestObjects")
	public Object[][] getConfigUserOptionNameLengthTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionNameLengthTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionNameLengthTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						usernameLength			uidShort		uidLong			
		ll.add(Arrays.asList(new Object[]{ "usernamelength_new",				"5",					"abcde",		"abcdef"					} ));	
		//TODO: nkrishnan: Check the expected length, is set to blank
		// doc at http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/html/Enterprise_Identity_Management_Guide/chap-Enterprise_Identity_Management_Guide-Configuring_IPA_Users_and_Groups.html#sect-Enterprise_Identity_Management_Guide-Configuring_IPA_Users-Specifying_Default_User_Settings
		// indicates default is 8.
		//TODO: mvarun: A dialogue box pops up on the browser when expected length, is set to blank. So it has been added to  invalid test.
		//ll.add(Arrays.asList(new Object[]{ "usernamelength_blank",				"",						"abcdefgh",		"abcdefghi"					} ));
		
		
		return ll;	
	}
	

	/*
	 * Test user options 
	 * Username length
	 */
	@DataProvider(name="getConfigUserOptionInvalidNameLengthTestObjects")
	public Object[][] getConfigUserOptionInvalidNameLengthTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionInvalidNameLengthTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionInvalidNameLengthTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						usernameLength		expectedError1										expectedError2			
		ll.add(Arrays.asList(new Object[]{ "usernamelength_specialchar",		"*", 				"Input form contains invalid or missing values.", 	"Must be an integer"		} ));		
		ll.add(Arrays.asList(new Object[]{ "usernamelength_letters",			"abc", 				"Input form contains invalid or missing values.", 	"Must be an integer"			} ));
		ll.add(Arrays.asList(new Object[]{ "usernamelength_space_inbetween",	"1 2", 				"Input form contains invalid or missing values.", 	"Must be an integer"			} ));
		ll.add(Arrays.asList(new Object[]{ "usernamelength_max",				"2147483648", 		"Input form contains invalid or missing values.", 	"Maximum value is 2147483647"			} ));
		ll.add(Arrays.asList(new Object[]{ "usernamelength_blank",				"",                 "Input form contains invalid or missing values.",   "Must be an integer" } ));
		
		return ll;	
	}
	
	
	/*
	 * Test user options 
	 * Password Expiration notification
	 */
	@DataProvider(name="getConfigUserOptionPwdExpNotifyTestObjects")
	public Object[][] getConfigUserOptionPwdExpNotifyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionPwdExpNotifyTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionPwdExpNotifyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					pwd exp			
		ll.add(Arrays.asList(new Object[]{ "userpwdexpnotify_new",			"5"		} ));	
		
		
		
		return ll;	
	}
	
	
	
	/*
	 * Test user options 
	 * Password Expiration notification
	 */
	@DataProvider(name="getConfigUserOptionInvalidPwdExpNotifyTestObjects")
	public Object[][] getConfigUserOptionInvalidPwdExpNotifyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionInvalidPwdExpNotifyTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionInvalidPwdExpNotifyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						pwd exp				expectedError1										expectedError2			
		ll.add(Arrays.asList(new Object[]{ "userpwdexpnotify_specialchar",		"*", 				"Input form contains invalid or missing values.", 	"Must be an integer"		} ));		
		ll.add(Arrays.asList(new Object[]{ "userpwdexpnotify_letters",			"abc", 				"Input form contains invalid or missing values.", 	"Must be an integer"			} ));
		ll.add(Arrays.asList(new Object[]{ "userpwdexpnotify_space_inbetween",	"1 2", 				"Input form contains invalid or missing values.", 	"Must be an integer"			} ));
		ll.add(Arrays.asList(new Object[]{ "userpwdexpnotify_max",				"2147483648", 		"Input form contains invalid or missing values.", 	"Maximum value is 2147483647"			} ));
		ll.add(Arrays.asList(new Object[]{ "userpwdexpnotify_blank",	      	"", 	            "Input form contains invalid or missing values.",   "Must be an integer"} ));
		
		return ll;	
	}
	
	/*
	 * Test user options 
	 * Enable Migration Mode
	 */
	@DataProvider(name="getConfigUserOptionEnableMigrationModeTestObjects")
	public Object[][] getConfigUserOptionEnableMigrationModeTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUserOptionEnableMigrationModeTestObjects());
	}
	protected List<List<Object>> createConfigUserOptionEnableMigrationModeTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					mode				
		ll.add(Arrays.asList(new Object[]{ "usermigrationmode_enable",		"enable"		} ));	
		ll.add(Arrays.asList(new Object[]{ "usermigrationmode_disable",		"disable"		} ));	
		
		
		return ll;	
	}
	
	
	/*
	 * Test Group options limits
	 * Group Search Fields
	 * default list:cn,description
	 */
	@DataProvider(name="getConfigGroupOptionSearchFieldTestObjects")
	public Object[][] getConfigGroupOptionSearchFieldTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigGroupOptionSearchFieldTestObjects());
	}
	protected List<List<Object>> createConfigGroupOptionSearchFieldTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   			searchValue		expectedGroup				
		ll.add(Arrays.asList(new Object[]{ "groupsearchfield_existing",		"cn",			"group1",		"group1"			} ));
		//TODO: nkrishnan: what is another group attribute to use for searching??
		// mvarun: there is no another group attribute to use for searching.
		//ll.add(Arrays.asList(new Object[]{ "groupsearchfield_new",			"postalcode",	"01234",		"user0"			} ));				
		
		return ll;	
	}
	
	/*
	 * Test Group options limits
	 * Group Search Fields
	 */
	@DataProvider(name="getConfigGroupOptionInvalidSearchFieldTestObjects")
	public Object[][] getConfigGroupOptionInvalidSearchFieldTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigGroupOptionInvalidSearchFieldTestObjects());
	}
	protected List<List<Object>> createConfigGroupOptionInvalidSearchFieldTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						cn   		expectedError1				
		ll.add(Arrays.asList(new Object[]{ "groupsearchfield_blank",			"",			"Input form contains invalid or missing values."														} ));
		ll.add(Arrays.asList(new Object[]{ "groupsearchfield_trailing_space",	"uid ",     "invalid 'groupsearch': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "groupsearchfield_leading_space",	" uid",     "invalid 'groupsearch': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "groupsearchfield_notallowed",		"abc",     	"invalid 'ipagroupsearchfields': attribute \"abc\" not allowed"	} ));
			
		return ll;	
	}
	
	/*
	 * Undo/Reset Tests
	 */
	@DataProvider(name="getConfigUndoResetTestObjects")
	public Object[][] getConfigUndoResetTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createConfigUndoResetTestObjects());
	}
	protected List<List<Object>> createConfigUndoResetTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					field							value			buttonToClick				
		ll.add(Arrays.asList(new Object[]{ "config_email_undo",				"ipadefaultemaildomain",		"test",			"undo"		} ));	
		ll.add(Arrays.asList(new Object[]{ "config_groupsearch_reset",		"ipagroupsearchfields",			"gidNumber",	"Reset"		} ));	
		
		
		return ll;	
	}
	
}
