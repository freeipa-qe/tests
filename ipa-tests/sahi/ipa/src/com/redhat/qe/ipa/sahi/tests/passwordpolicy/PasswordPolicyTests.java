package com.redhat.qe.ipa.sahi.tests.passwordpolicy;

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
import com.redhat.qe.ipa.sahi.tasks.PasswordPolicyTasks;
import com.redhat.qe.auto.testng.*;

public class PasswordPolicyTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(PasswordPolicyTests.class.getName());
	public static SahiTasks sahiTasks = null;	 
	public static String url = System.getProperty("ipa.server.url")+CommonTasks.passwordPolicyPage; 
	
	
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
	 * Add & Delete password policy
	 */
	@Test (groups={"passwordPolicyBaseTest"}, dataProvider="getPasswordPolicy")	
	public void passwordPolicyBaseTest(String testName, String policyName, String priority) throws Exception {
		PasswordPolicyTasks.addPasswordPolicy(sahiTasks, policyName,priority); 
		PasswordPolicyTasks.delPasswordPolicy(sahiTasks, policyName);
	}

	/*
	 * Add password policy
	 */
	@Test (groups={"addPasswordPolicy"}, dataProvider="getPasswordPolicy")	
	public void addPasswordPolicy(String testName, String policyName, String priority) throws Exception {
		PasswordPolicyTasks.addPasswordPolicy(sahiTasks, policyName,priority);  
	}//addPasswordPolicy
	
	/*
	 * Delete password policy
	 */
	@Test (groups={"deletePasswordPolicy"}, dataProvider="getPasswordPolicy")	
	public void deletePasswordPolicy(String testName, String policyName, String priority) throws Exception {
		
		PasswordPolicyTasks.delPasswordPolicy(sahiTasks, policyName);
	}//deletePasswordPolicy
	
	/*
	 * Modify password policy details, positive test cases
	 */
	@Test (groups={"modifyPasswordPolicy"}, dataProvider="getPasswordPolicyDetails")	
	public void modifyPasswordPolicy(String testName, String policyName, String fieldName, String fieldValue) throws Exception {
		// get into password policy detail page
		sahiTasks.link(policyName).click();
		// performing test here
		PasswordPolicyTasks.modifyPasswordPolicy(sahiTasks, testName, policyName, fieldName, fieldValue);  
		//go back to password policy list
		sahiTasks.link("Password Policies").click();
	}//modifyPasswordPolicy
	
	/*
	 * Modify password policy details, negative test cases
	 */
	@Test (groups={"modifyPasswordPolicyNegative"}, dataProvider="getPasswordPolicyDetailsNegative")	
	public void modifyPasswordPolicyNegative(String testName, String policyName, String fieldName, String fieldNegValue, String expectedErrorMsg) throws Exception {
		// get into password policy detail page
		sahiTasks.link(policyName).click();
		// performing test here 
		PasswordPolicyTasks.modifyPasswordPolicyNegative(sahiTasks, testName, policyName, fieldName, fieldNegValue, expectedErrorMsg);
		//go back to password policy list
		//sahiTasks.link("Password Policies").click();
	}//modifyPasswordPolicy
	
	
	/***************************************************************************
	 *                          Data providers                                 *
	 ***************************************************************************/
	 
	@DataProvider(name="getPasswordPolicyDetails")
	public Object[][] getPasswordPolicyDetails() {
		return TestNGUtils.convertListOfListsTo2dArray(createPasswordPolicyDetails());
	}
	protected List<List<Object>> createPasswordPolicyDetails() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
											// testName, policy name, fieldName, fieldValue
		ll.add(Arrays.asList(new Object[]{"password policy base test", "editors","krbmaxpwdlife","50"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy base test", "editors","krbminpwdlife","5"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy base test", "editors","krbpwdhistorylength","6"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy base test", "editors","krbpwdmindiffchars","3"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy base test", "editors","krbpwdminlength","12"} ));  
		return ll;	
	}//Data provider: getPasswordPolicyDetails 
	
	@DataProvider(name="getPasswordPolicyDetailsNegative")
	public Object[][] getPasswordPolicyDetailsNegative() {
		return TestNGUtils.convertListOfListsTo2dArray(createPasswordPolicyDetailsNegative());
	}
	protected List<List<Object>> createPasswordPolicyDetailsNegative() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
											// testName, policy name, fieldName, fieldValue
		ll.add(Arrays.asList(new Object[]{"password policy base test", "editors","krbmaxpwdlife","abc", "Must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy base test", "editors","krbminpwdlife","edf", "Must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy base test", "editors","krbpwdhistorylength","HIJ", "Must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy base test", "editors","krbpwdmindiffchars","3lm", "Must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy base test", "editors","krbpwdminlength","n0p", "Must be an integer"} ));  
		return ll;	
	}//Data provider: createPasswordPolicyDetailsNegative 
	 
	@DataProvider(name="getPasswordPolicy")
	public Object[][] getPasswordPolicyObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createPasswordPolicy());
	}
	protected List<List<Object>> createPasswordPolicy() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
		ll.add(Arrays.asList(new Object[]{
				// testName, password policy name, priority 	
				"password policy base test", "editors","5"} )); 
		return ll;	
	}//Data provider: createPasswordPolicy 
	
}//class DNSTest
