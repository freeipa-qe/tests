package com.redhat.qe.ipa.sahi.tests.kerberosticketpolicy;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.KerberosTicketPolicyTasks;

public class KerberosTicketPolicyTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(KerberosTicketPolicyTests.class.getName());
	
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks.navigateTo(commonTasks.kerberosTicketPolicyPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
	}//initialize
	
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

		KerberosTicketPolicyTasks.modifyKerberosTicketPolicy(sahiTasks, testName, fieldName, fieldValue);  

	}//modifyKerberosTicketPolicy
	
	/*
	 * Modify password policy details, negative test cases
	 */
	@Test (groups={"modifyKerberosTicketPolicyNegative"}, dataProvider="getKerberosTicketPolicyDetailsNegative")	
	public void modifyKerberosTicketPolicyNegative(String testName, String fieldName, String fieldNegValue, String expectedErrorMsg) throws Exception {

		KerberosTicketPolicyTasks.modifyKerberosTicketPolicyNegative(sahiTasks, testName, fieldName, fieldNegValue, expectedErrorMsg);

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
		ll.add(Arrays.asList(new Object[]{"kerberos policy test for max renewable age","krbmaxrenewableage","6408000"} )); 
		ll.add(Arrays.asList(new Object[]{"kerberos policy test for max kerberos ticket life","krbmaxticketlife","864000"} )); 
		return ll;	
	}//Data provider: getKerberosTicketPolicyDetails 
	
	@DataProvider(name="getKerberosTicketPolicyDetailsNegative")
	public Object[][] getKerberosTicketPolicyDetailsNegative() {
		return TestNGUtils.convertListOfListsTo2dArray(createKerberosTicketPolicyDetailsNegative());
	}
	protected List<List<Object>> createKerberosTicketPolicyDetailsNegative() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
											// testName, policy name, fieldName, fieldValue
		ll.add(Arrays.asList(new Object[]{"kerberos policy max renewable age: invalid data: string used instead of integer","krbmaxrenewableage","abc", "Must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"kerberos policy max renewable age: bigger than max value","krbmaxrenewableage","20000000000000", "Maximum value is 2147483647"}));
		ll.add(Arrays.asList(new Object[]{"kerberos policy max renewable age: smaller than min value","krbmaxrenewableage","0", "Minimum value is 1"}));
		
		ll.add(Arrays.asList(new Object[]{"kerberos policy max ticket life, invalid data: string used instead of integer","krbmaxticketlife","edf", "Must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"kerberos policy max ticket life, bigger than max value","krbmaxticketlife","20000000000000", "Maximum value is 2147483647"}));
		ll.add(Arrays.asList(new Object[]{"kerberos policy max ticket life, smaller than min value","krbmaxticketlife","0", "Minimum value is 1"}));
		return ll;	
	}//Data provider: createKerberosTicketPolicyDetailsNegative 
	 
}//class KerberosTicketPolicyTests
