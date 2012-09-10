package com.redhat.qe.ipa.sahi.tests.passwordpolicy;

import java.util.logging.Logger;
import org.testng.annotations.*;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.*;
import com.redhat.qe.auto.testng.*;

public class PasswordPolicyTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(PasswordPolicyTests.class.getName());
	private static SahiTasks browser=null;
	
	private static String[] testUserGroups = new String[]{
					"passwordpolicygrp000","passwordpolicygrp001","passwordpolicygrp002",
					"passwordpolicygrp003","passwordpolicygrp004","passwordpolicygrp005" }; 
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		browser=sahiTasks;
		browser.setStrictVisibilityCheck(true);
		
		browser.navigateTo(commonTasks.groupPage, true);
		PasswordPolicyTasks.createUserGroupsForTest(browser, testUserGroups);
		
		// ready for test
		browser.navigateTo(commonTasks.passwordPolicyPage, true);
		
	}//initialize
	
	@AfterClass (groups={"cleanup"}, description="delete test user groups", alwaysRun=true)
	public void cleanup()  {
		try{
			browser.navigateTo(commonTasks.groupPage, true);
			PasswordPolicyTasks.deleteUserGroupsForTest(browser, testUserGroups); 
		}catch (Exception e){
			log.info("there might be a sahi bug here, the above 'navigateTo' does not refresh page and therefore deleteUserGroupsForTest failed");
			e.printStackTrace();
		}
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		String currentURL = browser.fetch("top.location.href");
		CommonTasks.checkError(sahiTasks);
		if (!currentURL.equals(commonTasks.passwordPolicyPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+commonTasks.passwordPolicyPage +")");
			browser.navigateTo(commonTasks.passwordPolicyPage, true);
		}
	}

	@Test (groups={"passwordPolicyBaseTest"}, dataProvider="basicPasswordPolicy")	
	public void passwordPolicyBaseTest(String testName, String policyName, String priority) throws Exception {
		PasswordPolicyTasks.add_Policy(browser, policyName,priority); 
		PasswordPolicyTasks.delete_Policy(browser, policyName);
	}

	@Test (groups={"addPolicy"}, dataProvider="1stPolicy")	
	public void addPolicy_add(String testName, String policyName, String priority) throws Exception {
		Assert.assertFalse(browser.link(policyName).exists(),"policy ["+policyName + "] does not exist before add");
		PasswordPolicyTasks.add_Policy(browser, policyName,priority);  
		Assert.assertTrue(browser.link(policyName).exists(),"new policy ["+policyName + "] has been added");
	}

	@Test (groups={"addPolicy"}, dataProvider="2nd_5thPolicy")	
	public void addPolicy_add_and_add_another(String testName, String firstPolicyName, String firstPolicyPriority, String secondPolicyName, String secondPolicyPriority) throws Exception {
		Assert.assertFalse(browser.link(firstPolicyName).exists(), "policy ["+ firstPolicyName  + "] does not exist before test");
		Assert.assertFalse(browser.link(secondPolicyName).exists(),"policy ["+ secondPolicyName + "] does not exist before test");
		
		PasswordPolicyTasks.add_and_add_another_Policy(browser, firstPolicyName, firstPolicyPriority, secondPolicyName, secondPolicyPriority); 
		
		Assert.assertTrue(browser.link(firstPolicyName).exists(), "new policy ["+ firstPolicyName  + "] has been added");
		Assert.assertTrue(browser.link(secondPolicyName).exists(),"new policy ["+ secondPolicyName + "] has been added");
	}

	@Test (groups={"addPolicy"}, dataProvider="6thPolicy")	
	public void addPolicy_add_and_edit(String testName, String policyName, String priority) throws Exception {
		Assert.assertFalse(browser.link(policyName).exists(), "policy ["+ policyName  + "] does not exist before test");
		
		PasswordPolicyTasks.add_and_edit_Policy(browser, policyName,priority); 
		
		Assert.assertTrue(browser.link("Password Policies").exists());
		browser.link("Password Policies").click();
		
		Assert.assertTrue(browser.link(policyName).exists(), "new policy [" + policyName +"] has been added");
	}

	@Test (groups={"addPolicy"}, dataProvider="editorPolicy")	
	public void addPolicy_add_then_cancel(String testName, String policyName, String priority) throws Exception {
		Assert.assertFalse(browser.link(policyName).exists(), "policy ["+ policyName  + "] does not exist before test");
		PasswordPolicyTasks.add_then_cancel_Policy(browser, policyName,priority);  
		Assert.assertFalse(browser.link(policyName).exists(), "policy ["+ policyName  + "] does not exist after test");		
	}
	
	@Test (groups={"addPolicy"})
	public void addPolicy_NegativeTest() throws Exception {
		browser.span("Add").click();
		
		// scenario:  non integer for policy priority
		String nonInteger="abc";
		String nonInteger_errorMsg = "Must be an integer"; 
		browser.textbox("cospriority").setValue(nonInteger);
		Assert.assertTrue(browser.span(nonInteger_errorMsg).exists(),"non integer priority data should trigger error msg");
		
		// scenario: lower bound of data range
		String lowerThanMin = "-1";
		//String lowerThanMin_errorMsg = "invalid 'priority': must be at least 0";
		String lowerThanMin_errorMsg ="Minimum value is 0";
		browser.textbox("cn").click();
		browser.select("list").choose("passwordpolicygrp000");
		browser.textbox("cospriority").setValue(lowerThanMin);
		browser.button("Add").click();		
		Assert.assertTrue(browser.span(lowerThanMin_errorMsg).exists(),"data range check: lower than min");
		//Assert.assertTrue(browser.div(lowerThanMin_errorMsg).exists(),"data range check: lower than min");
		//browser.button("Cancel").near(browser.button("Retry")).click();
		browser.button("Cancel").near(browser.button("Add and Edit")).click();
		
		// Scenario: upper bound of data range
		browser.span("Add").click();
		String biggerThanMax="2147483648";
		String biggerThanMax_errorMsg="Maximum value is 2147483647";
		browser.textbox("cospriority").setValue(biggerThanMax);
		Assert.assertTrue(browser.span(biggerThanMax_errorMsg).exists(),"data range check: bigger than max");
		
		// Scenario: empty policy name
		String emptyName_errorMsg="Required field";
		browser.textbox("cn").click();
		browser.select("list").choose(""); 
		browser.textbox("cospriority").setValue("100");
		browser.button("Add").click();
		Assert.assertTrue(browser.span(emptyName_errorMsg).exists(),"Group name check");
		//Assert.assertTrue(browser.div("error_dialog").exists(),"select empty string should trigger error dialog box");
		//browser.button("Cancel").click(); // click away the ipa error dialog box
		browser.button("Cancel").click(); // click away the add policy dialog box, end of test
	}//addPolicy_NegativeTest

	@Test (groups={"deletePolicy"}, dataProvider="allTestPolicies", dependsOnGroups={"modifyPolicy","PolicyExpandCollapseTest"})	
	public void deletePolicy(String policyName) throws Exception {
		log.info("delete test policy:["+policyName+"]");
		PasswordPolicyTasks.delete_Policy(browser, policyName);
		Assert.assertFalse(browser.link(policyName).exists(), "policy ["+ policyName  + "] does not exist after test");		
	}
	
	@Test (groups={"modifyPolicy"}, dataProvider="positivePolicyData", dependsOnGroups="addPolicy")	
	public void modifyPolicy_PositiveTest(String testName, String policyName, String fieldName, String fieldValue) throws Exception {
		// get into password policy detail page
		browser.link(policyName).click();
		
		String originalValue = browser.textbox(fieldName).getText();
		PasswordPolicyTasks.modifyPolicy_undo(browser, fieldName, fieldValue);
		Assert.assertTrue(originalValue.equals(browser.textbox(fieldName).getText()), "after 'undo', the original value being restored" );
		
		PasswordPolicyTasks.modifyPolicy_reset(browser, fieldName, fieldValue);
		Assert.assertTrue(originalValue.equals(browser.textbox(fieldName).getText()),"after 'Reset', the original value being restored"); 

		PasswordPolicyTasks.modifyPolicy_update(browser,fieldName, fieldValue);
		String after = browser.textbox(fieldName).getText();
		Assert.assertTrue(after.equals(fieldValue),"after 'update', the field value not changed, report failure"); 

		//go back to password policy list
		browser.link("Password Policies").in(browser.div("content")).click();
	}

	@Test (groups={"modifyPolicy"}, dataProvider="negativePolicyData", dependsOnGroups="addPolicy")	
	public void modifyPolicy_NegativeTest(String testName, String policyName, String fieldName, 
											 String fieldNegValue, String expectedErrorMsg) throws Exception {
		// get into password policy detail page
		browser.link(policyName).click();
		PasswordPolicyTasks.modifyPolicy_Negative(browser, testName, policyName, fieldName, fieldNegValue, expectedErrorMsg);
	}//test_modify_PasswordPolicy_Negative
	
	
	@Test (groups={"PolicyExpandCollapseTest"}, dataProvider="Policy_ExpandCollapse", dependsOnGroups="modifyPolicy")	
	public void PolicyExpand_CollapseTest(String testName, String policyName) throws Exception {
		// get into password policy detail page
		browser.link(policyName).click();
		browser.span("Collapse All").click();
		browser.waitFor(1000);
		Assert.assertFalse(browser.label("Group:").isVisible(),"No fields are visible");
		
		browser.span("Expand All").click();
		browser.waitFor(1000);
		Assert.assertTrue(browser.label("Group:").isVisible(),"All fields are visible");
		
		browser.span("icon section-expand expanded-icon").click();
		browser.waitFor(1000);
		Assert.assertFalse(browser.label("Group:").isVisible(),"No fields are visible");
		
		browser.span("icon section-expand collapsed-icon").click();
		browser.waitFor(1000);
		Assert.assertTrue(browser.label("Group:").isVisible(),"All fields are visible");
	}
	
	/***************************************************************************
	 *                          Data providers                                 *
	 ***************************************************************************/
	 
	@DataProvider(name="positivePolicyData")
	public Object[][] getPositivePolicyData() {
		String policy = PasswordPolicyTests.testUserGroups[0];
		String testData[][]=
			{
				{"test field: krbmaxpwdlife", policy,"krbmaxpwdlife","50"} ,
				{"test field: krbminpwdlife", policy,"krbminpwdlife","5"} ,
				{"test field: krbpwdhistorylength", policy,"krbpwdhistorylength","6"} ,
				{"test field: krbpwdmindiffchars", policy,"krbpwdmindiffchars","3"} ,
				{"test field: krbpwdminlength", policy,"krbpwdminlength","12"},				
				{"test field: krbpwdmaxfailure", policy,"krbpwdmaxfailure","6"},
				{"test field: krbpwdfailurecountinterval", policy,"krbpwdfailurecountinterval","60"},
				{"test field: krbpwdlockoutduration", policy,"krbpwdlockoutduration","600"}
				
				
			};
		return testData;	
	}//Data provider: getPasswordPolicyDetails 
	
	@DataProvider(name="negativePolicyData")
	public Object[][] getNegativePolicyData() {
		
		String policy = PasswordPolicyTests.testUserGroups[0]; 
								// testName, policy name, fieldName, fieldValue(negative), expected error msg
		String testData[][] = 
			{	
				{"krbmaxpwdlife: non-integer", 		  policy,"krbmaxpwdlife","abc", "Must be an integer"}, 
				{"krbmaxpwdlife: upper range integer",policy,"krbmaxpwdlife","2147483648", "Maximum value is 2147483647"},
				{"krbmaxpwdlife: lower range integer",policy,"krbmaxpwdlife","-1","Minimum value is 0"},		
				
				{"krbminpwdlife: non-integer",		  policy,"krbminpwdlife","edf", "Must be an integer"},
				{"krbminpwdlif1stPolicye: upper range integer",policy,"krbminpwdlife","2147483648", "Maximum value is 2147483647"},
				{"krbminpwdlife: lower range integer",policy,"krbminpwdlife","-1","Minimum value is 0"},
		
				{"krbpwdhistorylength: non-integer",	    policy,"krbpwdhistorylength","HIJ", "Must be an integer"}, 
				{"krbpwdhistorylength: upper range integer",policy,"krbpwdhistorylength","2147483648", "Maximum value is 2147483647"},
				{"krbpwdhistorylength: lower range integer",policy,"krbpwdhistorylength","-1","Minimum value is 0"},
		
				{"krbpwdmindiffchars: non-integer",	   policy,"krbpwdmindiffchars","3lm", "Must be an integer"}, 
				{"krbpwdmindiffchars: upper range integer",policy,"krbpwdmindiffchars","2147483648", "Maximum value is 5"},
				{"krbpwdmindiffchars: lower range integer",policy,"krbpwdmindiffchars","-1","Minimum value is 0"},
		
				{"krbpwdminlength: non-integer",		policy,"krbpwdminlength","n0p", "Must be an integer"},  
				{"krbpwdminlength: upper range integer",policy,"krbpwdminlength","2147483648", "Maximum value is 2147483647"},
				{"krbpwdminlength: lower range integer",policy,"krbpwdminlength","-1","Minimum value is 0"},
								
				{"krbpwdmaxfailure: non-integer",		 policy,"krbpwdmaxfailure","n0p", "Must be an integer"},  
				{"krbpwdmaxfailure: upper range integer",policy,"krbpwdmaxfailure","2147483648", "Maximum value is 2147483647"},
				{"krbpwdmaxfailure: lower range integer",policy,"krbpwdmaxfailure","-1","Minimum value is 0"},
				
				{"krbpwdfailurecountinterval: non-integer",		 policy,"krbpwdfailurecountinterval","n0p", "Must be an integer"},  
				{"krbpwdfailurecountinterval: upper range integer",policy,"krbpwdfailurecountinterval","2147483648", "Maximum value is 2147483647"},
				{"krbpwdfailurecountinterval: lower range integer",policy,"krbpwdfailurecountinterval","-1","Minimum value is 0"},
				
				{"krbpwdlockoutduration: non-integer",		 policy,"krbpwdlockoutduration","n0p", "Must be an integer"},  
				{"krbpwdlockoutduration: upper range integer",policy,"krbpwdlockoutduration","2147483648", "Maximum value is 2147483647"},
				{"krbpwdlockoutduration: lower range integer",policy,"krbpwdlockoutduration","-1","Minimum value is 0"}
				
				
				
				
				
			};
		return testData;	
	}//Data provider: createPasswordPolicyDetailsNegative 
	 
	@DataProvider(name="basicPasswordPolicy")
	public Object[][] getBasicPasswordPolicy() {
		String testData[][] ={{"password policy base test", "editors","15"}}; 
		return testData;	
	} 
	
	@DataProvider(name="1stPolicy")
	public Object[][] get_1stPolicy() {
		String[][] policy =  { {"1st password policy", PasswordPolicyTests.testUserGroups[0],"0"} };
		return policy; 
	}
	
	@DataProvider(name="2nd_5thPolicy")
	public Object[][] get_2nd_5thPolicy() {
		String[][] policies = { {"2nd and 3rd password policy", PasswordPolicyTests.testUserGroups[1],"1", PasswordPolicyTests.testUserGroups[2],"2"},
							  {"4th and 5th password policy", PasswordPolicyTests.testUserGroups[3],"3", PasswordPolicyTests.testUserGroups[4],"4"},
							};
		return policies; 
	}
	
	@DataProvider(name="6thPolicy")
	public Object[][] get_6thPolicy() {
		String[][] policy = { {"6th password policy", PasswordPolicyTests.testUserGroups[5],"5"}};
		return policy; 
	}
	
	@DataProvider(name="editorPolicy")
	public Object[][] get_editorPolicy() {
		String[][] policy = { {"password policy for group 'editors'", "editors","6"}};
		return policy; 
	}

	@DataProvider (name="allTestPolicies")
	public Object[][] getAllTestPolicies(){
		String[][] policies = { {"passwordpolicygrp000"},{"passwordpolicygrp001"},{"passwordpolicygrp002"},
								{"passwordpolicygrp003"},{"passwordpolicygrp004"},{"passwordpolicygrp005"}};
		return policies;
	}
	

	@DataProvider(name="Policy_ExpandCollapse")
	public Object[][] getPolicy_ExpandCollapse() {
		String[][] policy =  { {"Policy_ExpandCollapse_Test", PasswordPolicyTests.testUserGroups[0]} };
		return policy; 
	}
	
}//class PasswordPolicyTests
