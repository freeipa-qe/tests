package com.redhat.qe.ipa.sahi.tests.selfservicepermission;

import java.util.*;
import java.util.logging.Logger;

import junit.framework.Assert;

import org.testng.annotations.*;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SelfservicepermissionTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class SelfservicepermissionTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(SelfservicepermissionTests.class.getName());
	private static SahiTasks browser; // Yi: I think variable name "browser" is more descriptive compare to sahiTasks
	
	private static String textFieldName_maxTicketLife  = "krbmaxticketlife";
	private static String textFieldName_maxRenewableAge = "krbmaxrenewableage";
	private static String maxValue = "2147483647";
	private static String minValue = "1";
	private static String biggerThanMax = "20000000000000";
	private static String smallerThanMin = "0";
	private static String valid_renewableAge = "6000000";
	private static String valid_maxlife = "800000";
	private static String nonInteger= "100ABC";
	private static String errmsg_nonInteger = "Must be an integer";
	private static String errmsg_minValue = "Minimum value is " + SelfservicepermissionTests.minValue;
	private static String errmsg_maxValue = "Maximum value is " + SelfservicepermissionTests.maxValue;
	
	private static String defaultMaxLife = null ;
	private static String defaultRenewableAge = null;
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		browser = sahiTasks; 	// Yi: I think variable name "browser" is more descriptive compare to sahiTasks
		browser.navigateTo(commonTasks.kerberosTicketPolicyPage, true);
		browser.setStrictVisibilityCheck(true);
		//store default values
		defaultMaxLife = browser.textbox(SelfservicepermissionTests.textFieldName_maxTicketLife).getText();
		defaultRenewableAge = browser.textbox(SelfservicepermissionTests.textFieldName_maxRenewableAge).getText();
	}//initialize
	
	@AfterClass (groups={"restoreDefault"} , description="Restore the default value when test is done", alwaysRun=true)
	public void restoreDefault() throws CloneNotSupportedException {
		browser.navigateTo(commonTasks.kerberosTicketPolicyPage, true);
		SelfservicepermissionTasks.modifyPolicy(browser, SelfservicepermissionTests.textFieldName_maxRenewableAge,SelfservicepermissionTests.defaultRenewableAge );
		SelfservicepermissionTasks.modifyPolicy(browser, SelfservicepermissionTests.textFieldName_maxTicketLife, SelfservicepermissionTests.defaultMaxLife);
		log.info("restore value to default" 
					+ "max renewable age: " + SelfservicepermissionTests.defaultRenewableAge + "; "
					+ "max kerberos ticket life:"+ SelfservicepermissionTests.defaultMaxLife);
	}// restoreDefault
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		// ensure the starting page for each test case is the kerberos ticket policy page
		String currentURL = browser.fetch("top.location.href"); 
		CommonTasks.checkError(sahiTasks);
		if (!currentURL.equals(commonTasks.kerberosTicketPolicyPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+commonTasks.kerberosTicketPolicyPage +")");
			browser.navigateTo(commonTasks.kerberosTicketPolicyPage, true);
		}
	}//checkURL
	
	
	/*
	 * Modify password policy details, positive test cases
	 */
	@Test (groups={"modifyPolicy_PositiveTest"}, dataProvider="positiveData")	
	public void modifyPolicy_PositiveTest(String testDescription, String textboxName, String value) throws Exception {
		
		String originalValue = browser.textbox(textboxName).getText();
		log.info("check test data for field:" + textboxName + " original value:["+ originalValue +"] will set to new value:[" + value + "]");
		// data check: it is meaningless if the new value same as original value
		Assert.assertFalse("pass in data can not equals to the original value", originalValue.equals(value));
		
		log.info("test for undo button");
		SelfservicepermissionTasks.modifyPolicy_undo(browser,textboxName, value);
		String afterUndo = browser.textbox(textboxName).getText();
		Assert.assertTrue("'undo' should restore the textbox value", originalValue.equals(afterUndo));
		 
		log.info("test for reset button"); 
		SelfservicepermissionTasks.modifyPolicy_reset(browser,textboxName, value);
		String afterReset = browser.textbox(textboxName).getText();
		Assert.assertTrue("'reset' should restore the textbox value", originalValue.equals(afterReset));
	
		log.info("test for update button");
		SelfservicepermissionTasks.modifyPolicy_update(browser,textboxName, value);
		String afterUpdate = browser.textbox(textboxName).getText();
		Assert.assertTrue("'update' should save set new value for textbox", value.equals(afterUpdate)); 
		Assert.assertFalse("'update' should save set new value for textbox", originalValue.equals(afterUpdate)); 

	}//modifyKerberosTicketPolicy
	
	/*
	 * Modify password policy details, negative test cases
	 */
	@Test (groups={"modifyPolicy_NegativeTest"}, dataProvider="negativeData")
	public void modifyPolicy_NegativeTest(String testDescription, String textboxName, String invalidData, String expectedErrorMsg) throws Exception {
		
		// enter negative data to trigger error msg report
		browser.textbox(textboxName).setValue(invalidData);
		Assert.assertTrue("error msg field should appear",browser.span(expectedErrorMsg).exists());
		
		// click password policy link to trigger dialog box for invalid data input
		browser.link("Password Policies").click();
		
		Assert.assertTrue("error dialog box should appear", browser.span("ui-dialog-title").near(browser.div("This page has unsaved changes. Please save or revert.")).exists());
		log.info("dialog box for invalid input data appears as expected, click 'reset' and back to password policy list");
		
		// click away this dialog box
		browser.button("Reset").click();
		 
	}//modifyPolicy_NegativeTest
	
	
	/***************************************************************************
	 *                                                                         *
	 *                          Data providers                                 *
	 *                                                                         *
	 ***************************************************************************/
	 
	@DataProvider(name="positiveData")
	public Object[][] getPositiveData() {
		return TestNGUtils.convertListOfListsTo2dArray(createPositiveData());
	}
	protected List<List<Object>> createPositiveData() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
											// test description, textbox name, data (positive test data)
		ll.add(Arrays.asList(new Object[]{"kerberos policy test for max renewable age", 
											SelfservicepermissionTests.textFieldName_maxRenewableAge ,
											SelfservicepermissionTests.valid_renewableAge} )); 
		ll.add(Arrays.asList(new Object[]{"kerberos policy test for max kerberos ticket life",
											SelfservicepermissionTests.textFieldName_maxTicketLife, 
											SelfservicepermissionTests.valid_maxlife} )); 
		return ll;	
	}//positiveData
	
	@DataProvider(name="negativeData")
	public Object[][] getNegativeData() {
		return TestNGUtils.convertListOfListsTo2dArray(createNegativeData());
	}
	protected List<List<Object>> createNegativeData() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
											// test description, textbox Name, negative test data
		ll.add(Arrays.asList(new Object[]{"kerberos policy max renewable age: invalid data: string used instead of integer",
											SelfservicepermissionTests.textFieldName_maxRenewableAge,
											SelfservicepermissionTests.nonInteger, 
											SelfservicepermissionTests.errmsg_nonInteger} )); 
		ll.add(Arrays.asList(new Object[]{"kerberos policy max renewable age: bigger than max value",
											SelfservicepermissionTests.textFieldName_maxRenewableAge,
											SelfservicepermissionTests.biggerThanMax, 
											SelfservicepermissionTests.errmsg_maxValue}));
		ll.add(Arrays.asList(new Object[]{"kerberos policy max renewable age: smaller than min value",
											SelfservicepermissionTests.textFieldName_maxRenewableAge,
											SelfservicepermissionTests.smallerThanMin, 
											SelfservicepermissionTests.errmsg_minValue}));
		
		ll.add(Arrays.asList(new Object[]{"kerberos policy max ticket life, invalid data: string used instead of integer",
											SelfservicepermissionTests.textFieldName_maxTicketLife,
											SelfservicepermissionTests.nonInteger, 
											SelfservicepermissionTests.errmsg_nonInteger} )); 
		ll.add(Arrays.asList(new Object[]{"kerberos policy max ticket life, bigger than max value",
											SelfservicepermissionTests.textFieldName_maxTicketLife,
											SelfservicepermissionTests.biggerThanMax, 
											SelfservicepermissionTests.errmsg_maxValue}));
		ll.add(Arrays.asList(new Object[]{"kerberos policy max ticket life, smaller than min value",
											SelfservicepermissionTests.textFieldName_maxTicketLife,
											SelfservicepermissionTests.smallerThanMin, 
											SelfservicepermissionTests.errmsg_minValue}));
		return ll;	
	}// negativeData
	 
}//class SelfservicepermissionTests
