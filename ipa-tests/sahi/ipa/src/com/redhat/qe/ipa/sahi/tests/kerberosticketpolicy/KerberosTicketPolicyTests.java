package com.redhat.qe.ipa.sahi.tests.kerberosticketpolicy;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.KerberosTicketPolicyTasks;
import com.redhat.qe.auto.testng.*;

public class KerberosTicketPolicyTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(KerberosTicketPolicyTests.class.getName());
	public static SahiTasks sahiTasks = null;	 
	public static String url = System.getProperty("ipa.server.url")+CommonTasks.kerberosTicketPolicyPage; 
	
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();
		sahiTasks.navigateTo(url, true);
		sahiTasks.setStrictVisibilityCheck(true);
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		String currentURL = sahiTasks.fetch("top.location.href");
		if (!currentURL.equals(url)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+url +")");
			sahiTasks.navigateTo(url, true);
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

	}//modifyKerberosTicketPolicy
	
	
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
		ll.add(Arrays.asList(new Object[]{"password policy base test","krbmaxrenewableage","6408000"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy base test","krbmaxticketlife","864000"} )); 
		return ll;	
	}//Data provider: getKerberosTicketPolicyDetails 
	
	@DataProvider(name="getKerberosTicketPolicyDetailsNegative")
	public Object[][] getKerberosTicketPolicyDetailsNegative() {
		return TestNGUtils.convertListOfListsTo2dArray(createKerberosTicketPolicyDetailsNegative());
	}
	protected List<List<Object>> createKerberosTicketPolicyDetailsNegative() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
											// testName, policy name, fieldName, fieldValue
		ll.add(Arrays.asList(new Object[]{"password policy base test","krbmaxrenewableage","abc", "Must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy base test","krbmaxrenewableage","20000000000000", "Maximum value is 2147483647"}));
		
		ll.add(Arrays.asList(new Object[]{"password policy base test","krbmaxticketlife","edf", "Must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy base test","krbmaxticketlife","20000000000000", "Maximum value is 2147483647"}));
		return ll;	
	}//Data provider: createKerberosTicketPolicyDetailsNegative 
	 
	@DataProvider(name="getKerberosTicketPolicy")
	public Object[][] getKerberosTicketPolicyObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createKerberosTicketPolicy());
	}
	protected List<List<Object>> createKerberosTicketPolicy() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
		ll.add(Arrays.asList(new Object[]{
				// testName, password policy name, priority 	
				"password policy base test", "editors","5"} )); 
		return ll;	
	}//Data provider: createKerberosTicketPolicy 
	
}//class DNSTest
