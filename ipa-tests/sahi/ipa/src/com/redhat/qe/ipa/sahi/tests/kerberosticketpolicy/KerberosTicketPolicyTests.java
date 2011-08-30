package com.redhat.qe.ipa.sahi.tests.kerberosticketpolicy;

import java.util.*;
import java.util.logging.Logger;

import junit.framework.Assert;

import org.testng.annotations.*;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.KerberosTicketPolicyTasks;

public class KerberosTicketPolicyTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(KerberosTicketPolicyTests.class.getName());
	
	private static String textFieldName_maxTicketLife  = "krbmaxticketlife";
	private static String textFieldName_maxRenewableAge = "krbmaxrenewableage";
	private static String maxValue = "2147483647";
	private static String minValue = "1";
	private static String biggerThanMax = "20000000000000";
	private static String smallerThanMin = "0";
	private static String valid_renewableAge = "6408000";
	private static String valid_maxlife = "864000";
	private static String nonInteger= "100ABC";
	private static String errmsg_nonInteger = "Must be an integer";
	private static String errmsg_minValue = "Minimum value is " + KerberosTicketPolicyTests.minValue;
	private static String errmsg_maxValue = "Maximum value is " + KerberosTicketPolicyTests.maxValue;
	
	private static String defaultMaxLife = null ;
	private static String defaultRenewableAge = null;
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks.navigateTo(commonTasks.kerberosTicketPolicyPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		//store default values
		defaultMaxLife = sahiTasks.textbox(KerberosTicketPolicyTests.textFieldName_maxTicketLife).getText();
		defaultRenewableAge = sahiTasks.textbox(KerberosTicketPolicyTests.textFieldName_maxRenewableAge).getText();
	}//initialize
	
	@AfterClass (groups={"restoreDefault"} , description="Restore the default value when test is done", alwaysRun=true)
	public void restoreDefault() throws CloneNotSupportedException {
		sahiTasks.navigateTo(commonTasks.kerberosTicketPolicyPage, true);
		KerberosTicketPolicyTasks.setDetails(sahiTasks, KerberosTicketPolicyTests.textFieldName_maxRenewableAge,KerberosTicketPolicyTests.defaultRenewableAge );
		KerberosTicketPolicyTasks.setDetails(sahiTasks, KerberosTicketPolicyTests.textFieldName_maxTicketLife, KerberosTicketPolicyTests.defaultMaxLife);
		log.info("restore value to default: max renewable age: " + KerberosTicketPolicyTests.defaultRenewableAge + ", max kerberos ticket life:"+ KerberosTicketPolicyTests.defaultMaxLife);
	}// restoreDefault
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		// ensure the starting page for each test case is the kerberos ticket policy page
		String currentURL = sahiTasks.fetch("top.location.href"); 
		if (!currentURL.equals(commonTasks.kerberosTicketPolicyPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+commonTasks.kerberosTicketPolicyPage +")");
			sahiTasks.navigateTo(commonTasks.kerberosTicketPolicyPage, true);
		}
	}//checkURL
	
	/*
	 * Modify password policy details, positive test cases
	 */
	@Test (groups={"modifyKerberosTicketPolicy"}, dataProvider="getKerberosTicketPolicyDetails")	
	public void modifyKerberosTicketPolicy(String testName, String fieldName, String fieldValue) throws Exception {

		KerberosTicketPolicyTasks.modifyDetails(sahiTasks, testName, fieldName, fieldValue);  

	}//modifyKerberosTicketPolicy
	
	/*
	 * Modify password policy details, negative test cases
	 */
	@Test (groups={"modifyKerberosTicketPolicyNegative"}, dataProvider="getKerberosTicketPolicyDetailsNegative")	
	public void modifyKerberosTicketPolicyNegative(String testName, String fieldName, String fieldNegValue, String expectedErrorMsg) throws Exception {

//		KerberosTicketPolicyTasks.modifyDetails_negative(sahiTasks, testName, fieldName, fieldNegValue, expectedErrorMsg);

	}//modifyKerberosTicketPolicyNegative
	
	
	/***************************************************************************
	 *                          Data providers                                 *
	 ***************************************************************************/
	 
	@DataProvider(name="getKerberosTicketPolicyDetails")
	public Object[][] getKerberosTicketPolicyDetails() {
		return TestNGUtils.convertListOfListsTo2dArray(createKerberosTicketPolicyDetails());
	}
	protected List<List<Object>> createKerberosTicketPolicyDetails() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
											// testName, policy name, fieldName, fieldValue
		ll.add(Arrays.asList(new Object[]{"kerberos policy test for max renewable age", 
											KerberosTicketPolicyTests.textFieldName_maxRenewableAge ,
											KerberosTicketPolicyTests.valid_renewableAge} )); 
		ll.add(Arrays.asList(new Object[]{"kerberos policy test for max kerberos ticket life",
											KerberosTicketPolicyTests.textFieldName_maxTicketLife, 
											KerberosTicketPolicyTests.valid_maxlife} )); 
		return ll;	
	}//Data provider: getKerberosTicketPolicyDetails 
	
	@DataProvider(name="getKerberosTicketPolicyDetailsNegative")
	public Object[][] getKerberosTicketPolicyDetailsNegative() {
		return TestNGUtils.convertListOfListsTo2dArray(createKerberosTicketPolicyDetailsNegative());
	}
	protected List<List<Object>> createKerberosTicketPolicyDetailsNegative() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
											// testName, policy name, fieldName, fieldValue
		ll.add(Arrays.asList(new Object[]{"kerberos policy max renewable age: invalid data: string used instead of integer",
											KerberosTicketPolicyTests.textFieldName_maxRenewableAge,
											KerberosTicketPolicyTests.nonInteger, 
											KerberosTicketPolicyTests.errmsg_nonInteger} )); 
		ll.add(Arrays.asList(new Object[]{"kerberos policy max renewable age: bigger than max value",
											KerberosTicketPolicyTests.textFieldName_maxRenewableAge,
											KerberosTicketPolicyTests.biggerThanMax, 
											KerberosTicketPolicyTests.errmsg_maxValue}));
		ll.add(Arrays.asList(new Object[]{"kerberos policy max renewable age: smaller than min value",
											KerberosTicketPolicyTests.textFieldName_maxRenewableAge,
											KerberosTicketPolicyTests.smallerThanMin, 
											KerberosTicketPolicyTests.errmsg_minValue}));
		
		ll.add(Arrays.asList(new Object[]{"kerberos policy max ticket life, invalid data: string used instead of integer",
											KerberosTicketPolicyTests.textFieldName_maxTicketLife,
											KerberosTicketPolicyTests.nonInteger, 
											KerberosTicketPolicyTests.errmsg_nonInteger} )); 
		ll.add(Arrays.asList(new Object[]{"kerberos policy max ticket life, bigger than max value",
											KerberosTicketPolicyTests.textFieldName_maxTicketLife,
											KerberosTicketPolicyTests.biggerThanMax, 
											KerberosTicketPolicyTests.errmsg_maxValue}));
		ll.add(Arrays.asList(new Object[]{"kerberos policy max ticket life, smaller than min value",
											KerberosTicketPolicyTests.textFieldName_maxTicketLife,
											KerberosTicketPolicyTests.smallerThanMin, 
											KerberosTicketPolicyTests.errmsg_minValue}));
		return ll;	
	}//Data provider: createKerberosTicketPolicyDetailsNegative 
	 
}//class KerberosTicketPolicyTests
