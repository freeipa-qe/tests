package com.redhat.qe.ipa.sahi.tests.passwordpolicy;

import java.util.*;
import java.util.logging.Logger;
import org.testng.annotations.*;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.*;
import com.redhat.qe.auto.testng.*;

public class PasswordPolicyTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(PasswordPolicyTests.class.getName());
	private static SahiTasks browser=null;
	
	private static String[] testGroups = new String[]{
					"passwordpolicygrp000","passwordpolicygrp001","passwordpolicygrp002",
					"passwordpolicygrp003","passwordpolicygrp004","passwordpolicygrp005" }; 
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		browser=sahiTasks;
		browser.setStrictVisibilityCheck(true);
		
		// create test group
		browser.navigateTo(commonTasks.groupPage, true);
		PasswordPolicyTasks.createUserGroupsForTest(browser, testGroups);
		
		// ready for test
		browser.navigateTo(commonTasks.passwordPolicyPage, true);
		
	}//initialize
	
	@AfterClass (groups={"cleanup"}, description="delete test group", alwaysRun=true)
	public void cleanup()  {
		try{
			browser.navigateTo(commonTasks.groupPage, true);
			PasswordPolicyTasks.deleteUserGroupsForTest(browser, testGroups); 
		}catch (Exception e){
			log.info("there might be a sahi bug here, the above 'navigateTo' does not refresh page and therefore deleteUserGroupsForTest failed");
			e.printStackTrace();
		}
	}//cleanup
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		String currentURL = browser.fetch("top.location.href");
		if (!currentURL.equals(commonTasks.passwordPolicyPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+commonTasks.passwordPolicyPage +")");
			browser.navigateTo(commonTasks.passwordPolicyPage, true);
		}
	}//checkURL
	
	/*
	 * Add & Delete password policy
	 */
	@Test (groups={"passwordPolicyBaseTest"}, dataProvider="basicPasswordPolicy")	
	public void passwordPolicyBaseTest(String testName, String policyName, String priority) throws Exception {
		PasswordPolicyTasks.add_PasswordPolicy(browser, policyName,priority); 
		PasswordPolicyTasks.delete_PasswordPolicy(browser, policyName);
	}

	/*
	 * Add password policy
	 */
	@Test (groups={"addPolicy"}, dataProvider="1stPolicy")	
	public void addPolicy(String testName, String policyName, String priority) throws Exception {
		Assert.assertFalse(browser.link(policyName).exists(),"policy ["+policyName + "] does not exist before add");
		PasswordPolicyTasks.add_PasswordPolicy(browser, policyName,priority);  
		Assert.assertTrue(browser.link(policyName).exists(),"new policy ["+policyName + "] has been added");
	}//addPolicy
	
	/*
	 * Add password policy, and then add another in the same dialog box
	 */
	@Test (groups={"addPolicy"}, dataProvider="2nd_5thPolicy")	
	public void test_add_and_add_another_PasswordPolicy(String testName, String firstPolicyName, String firstPolicyPriority, String secondPolicyName, String secondPolicyPriority) throws Exception {
		Assert.assertFalse(browser.link(firstPolicyName).exists(), "policy ["+ firstPolicyName  + "] does not exist before test");
		Assert.assertFalse(browser.link(secondPolicyName).exists(),"policy ["+ secondPolicyName + "] does not exist before test");
		PasswordPolicyTasks.add_and_add_another(browser, firstPolicyName, firstPolicyPriority, secondPolicyName, secondPolicyPriority);  
		Assert.assertTrue(browser.link(firstPolicyName).exists(), "new policy ["+ firstPolicyName  + "] has been added");
		Assert.assertTrue(browser.link(secondPolicyName).exists(),"new policy ["+ secondPolicyName + "] has been added");
	}//test_add_and_add_another_PasswordPolicy
	
	/*
	 * Add password policy, then switch to editing mode immediately 
	 */
	@Test (groups={"addPolicy"}, dataProvider="6thPolicy")	
	public void test_add_and_edit_PasswordPolicy(String testName, String policyName, String priority) throws Exception {
		Assert.assertFalse(browser.link(policyName).exists(), "policy ["+ policyName  + "] does not exist before test");
		PasswordPolicyTasks.add_and_edit(browser, policyName,priority); 
		Assert.assertTrue(browser.link("Password Policies").exists());
		browser.link("Password Policies").click();
		Assert.assertTrue(browser.link(policyName).exists(), "new policy [" + policyName +"] has been added");
	}//test_add_and_edit_PasswordPolicy
	
	/*
	 * Add then cancel password policy
	 */
	@Test (groups={"addPolicy"}, dataProvider="editorPolicy")	
	public void test_add_then_cancel_PasswordPolicy(String testName, String policyName, String priority) throws Exception {
		Assert.assertFalse(browser.link(policyName).exists(), "policy ["+ policyName  + "] does not exist before test");
		PasswordPolicyTasks.add_then_cancel(browser, policyName,priority);  
		Assert.assertFalse(browser.link(policyName).exists(), "policy ["+ policyName  + "] does not exist after test");		
	}//test_add_then_cancel_PasswordPolicy
	
	
	/*
	 * Delete password policy
	 */
	@Test (groups={"deletePolicy"}, dataProvider="allTestPolicies", dependsOnGroups="modifyPolicy")	
	public void deletePolicy(String policyName) throws Exception {
		log.info("delete test policy:["+policyName+"]");
		PasswordPolicyTasks.delete_PasswordPolicy(browser, policyName);
		Assert.assertFalse(browser.link(policyName).exists(), "policy ["+ policyName  + "] does not exist after test");		
	}//test_delete_PasswordPolicy
	
	/*
	 * Modify password policy details, positive test cases
	 */
	@Test (groups={"modifyPolicy"}, dataProvider="positivePolicyData", dependsOnGroups="addPolicy")	
	public void modifyPolicy_PositiveTest(String testName, String policyName, String fieldName, String fieldValue) throws Exception {
		// get into password policy detail page
		browser.link(policyName).click();
		// performing test here
		PasswordPolicyTasks.modify_PasswordPolicy_Positive(browser, testName, policyName, fieldName, fieldValue);  
		//go back to password policy list
		browser.link("Password Policies").in(browser.div("content")).click();
	}//test_modify_PasswordPolicy
	
	/*
	 * Modify password policy details, negative test cases
	 */
	@Test (groups={"modifyPolicy"}, dataProvider="negativePolicyData", dependsOnGroups="addPolicy")	
	public void modifyPolicy_NegativeTest(String testName, String policyName, String fieldName, 
											 String fieldNegValue, String expectedErrorMsg) throws Exception {
		// get into password policy detail page
		browser.link(policyName).click();
		// performing test here 
		PasswordPolicyTasks.modify_PasswordPolicy_Negative(browser, testName, policyName, fieldName, fieldNegValue, expectedErrorMsg);
		
	}//test_modify_PasswordPolicy_Negative
	
	
	/***************************************************************************
	 *                          Data providers                                 *
	 ***************************************************************************/
	 
	@DataProvider(name="positivePolicyData")
	public Object[][] getPositivePolicyData() {
		String policy = PasswordPolicyTests.testGroups[0];
		String testData[][]=
			{
				{"test field: krbmaxpwdlife", policy,"krbmaxpwdlife","50"} ,
				{"test field: krbminpwdlife", policy,"krbminpwdlife","5"} ,
				{"test field: krbpwdhistorylength", policy,"krbpwdhistorylength","6"} ,
				{"test field: krbpwdmindiffchars", policy,"krbpwdmindiffchars","3"} ,
				{"test field: krbpwdminlength", policy,"krbpwdminlength","12"}
			};
		return testData;	
	}//Data provider: getPasswordPolicyDetails 
	
	@DataProvider(name="negativePolicyData")
	public Object[][] getNegativePolicyData() {
		
		String policy = PasswordPolicyTests.testGroups[0]; 
								// testName, policy name, fieldName, fieldValue(negative), expected error msg
		String testData[][] = 
			{	
				{"krbmaxpwdlife: non-integer", 		  policy,"krbmaxpwdlife","abc", "Must be an integer"}, 
				{"krbmaxpwdlife: upper range integer",policy,"krbmaxpwdlife","2147483648", "Maximum value is 2147483647"},
				{"krbmaxpwdlife: lower range integer",policy,"krbmaxpwdlife","-1","Minimum value is 0"},		
				
				{"krbminpwdlife: non-integer",		  policy,"krbminpwdlife","edf", "Must be an integer"},
				{"krbminpwdlife: upper range integer",policy,"krbminpwdlife","2147483648", "Maximum value is 2147483647"},
				{"krbminpwdlife: lower range integer",policy,"krbminpwdlife","-1","Minimum value is 0"},
		
				{"krbpwdhistorylength: non-integer",	    policy,"krbpwdhistorylength","HIJ", "Must be an integer"}, 
				{"krbpwdhistorylength: upper range integer",policy,"krbpwdhistorylength","2147483648", "Maximum value is 2147483647"},
				{"krbpwdhistorylength: lower range integer",policy,"krbpwdhistorylength","-1", "Minimum value is 0"},
		
				{"krbpwdmindiffchars: noon-integer",	   policy,"krbpwdmindiffchars","3lm", "Must be an integer"}, 
				{"krbpwdmindiffchars: upper range integer",policy,"krbpwdmindiffchars","2147483648", "Maximum value is 5"},
				{"krbpwdmindiffchars: lower range integer",policy,"krbpwdmindiffchars","-1","Minimum value is 0"},
		
				{"krbpwdminlength: non-integer",		policy,"krbpwdminlength","n0p", "Must be an integer"},  
				{"krbpwdminlength: upper range integer",policy,"krbpwdminlength","2147483648", "Maximum value is 2147483647"},
				{"krbpwdminlength: lower range integer",policy,"krbpwdminlength","-1", "Minimum value is 0"}
			};
		return testData;	
	}//Data provider: createPasswordPolicyDetailsNegative 
	 
	@DataProvider(name="basicPasswordPolicy")
	public Object[][] getBasicPasswordPolicy() {
		String testData[][] ={{"password policy base test", "editors","15"}}; 
		return testData;	
	}//Data provider: createPasswordPolicy 
	
	@DataProvider(name="1stPolicy")
	public Object[][] get_1stPolicy() {
		String[][] policy =  { {"1st password policy", PasswordPolicyTests.testGroups[0],"0"} };
		return policy; 
	}//singlePolicy;
	
	@DataProvider(name="2nd_5thPolicy")
	public Object[][] get_2nd_5thPolicy() {
		String[][] policy = { {"2nd and 3rd password policy", PasswordPolicyTests.testGroups[1],"1", PasswordPolicyTests.testGroups[2],"2"},
							  {"4th and 5th password policy", PasswordPolicyTests.testGroups[3],"3", PasswordPolicyTests.testGroups[4],"4"},
							};
		return policy; 
	}//singlePolicy;
	
	@DataProvider(name="6thPolicy")
	public Object[][] get_6thPolicy() {
		String[][] policy = { {"6th password policy", PasswordPolicyTests.testGroups[5],"5"}};
		return policy; 
	}//get_6thPolicy;
	
	@DataProvider(name="editorPolicy")
	public Object[][] get_7thPolicy() {
		String[][] policy = { {"password policy for group 'editors'", "editors","6"}};
		return policy; 
	}//get_7thPolicy;
	
	@DataProvider (name="allTestPolicies")
	public Object[][] getAllTestPolicies(){
		String[][] policies = { {"passwordpolicygrp000"},{"passwordpolicygrp001"},{"passwordpolicygrp002"},
								{"passwordpolicygrp003"},{"passwordpolicygrp004"},{"passwordpolicygrp005"}};
//		String[][] policies = new String[PasswordPolicyTests.testGroups.length][1];
//		for (int i=0;i<PasswordPolicyTests.testGroups.length; i++){
//			policies[i][0]= PasswordPolicyTests.testGroups[i];
//		}
		return policies;
	}
}//class DNSTest
