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
		
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.navigateTo(commonTasks.passwordPolicyPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		String currentURL = sahiTasks.fetch("top.location.href");
		//TODO: yi: check alternate page
		if (!currentURL.equals(commonTasks.passwordPolicyPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+commonTasks.passwordPolicyPage +")");
			sahiTasks.navigateTo(commonTasks.passwordPolicyPage, true);
		}
	}//checkURL
	
	/*
	 * Add & Delete password policy
	 */
	@Test (groups={"passwordPolicyBaseTest"}, dataProvider="getPasswordPolicy")	
	public void passwordPolicyBaseTest(String testName, String policyName, String priority) throws Exception {
		PasswordPolicyTasks.add_PasswordPolicy(sahiTasks, policyName,priority); 
		PasswordPolicyTasks.delete_PasswordPolicy(sahiTasks, policyName);
	}

	/*
	 * Add password policy
	 */
	@Test (groups={"test_add_PasswordPolicy"}, dataProvider="getPasswordPolicy")	
	public void test_add_PasswordPolicy(String testName, String policyName, String priority) throws Exception {
		PasswordPolicyTasks.add_PasswordPolicy(sahiTasks, policyName,priority);  
	}//test_add_PasswordPolicy
	
	/*
	 * Add password policy, and then add another in the same dialog box
	 */
	@Test (groups={"test_add_and_add_another_PasswordPolicy"}, dataProvider="getPasswordPolicy")	
	public void test_add_and_add_another_PasswordPolicy(String testName, String policyName, String priority) throws Exception {
		//FIXME : need work on this method and data provider
		//PasswordPolicyTasks.add_and_add_another_PasswordPolicy(sahiTasks, policyName,priority);  
	}//test_add_and_add_another_PasswordPolicy
	
	/*
	 * Add password policy, then switch to editing mode immediately 
	 */
	@Test (groups={"test_add_and_edit_PasswordPolicy"}, dataProvider="getPasswordPolicy")	
	public void test_add_and_edit_PasswordPolicy(String testName, String policyName, String priority) throws Exception {
		//FIXME : need work on this method and data provider
		//PasswordPolicyTasks.add_and_edit_PasswordPolicy(sahiTasks, policyName,priority);  
	}//test_add_and_edit_PasswordPolicy
	
	/*
	 * Add then cancel password policy
	 */
	@Test (groups={"test_add_then_cancel_PasswordPolicy"}, dataProvider="getPasswordPolicy")	
	public void test_add_then_cancel_PasswordPolicy(String testName, String policyName, String priority) throws Exception {
		//FIXME : need work on this method and data provider
		//PasswordPolicyTasks.add_then_cancel_PasswordPolicy(sahiTasks, policyName,priority);  
	}//test_add_then_cancel_PasswordPolicy
	
	
	/*
	 * Delete password policy
	 */
	@Test (groups={"test_delete_PasswordPolicy"}, dataProvider="getPasswordPolicy")	
	public void test_delete_PasswordPolicy(String testName, String policyName, String priority) throws Exception {
		
		PasswordPolicyTasks.delete_PasswordPolicy(sahiTasks, policyName);
		
	}//test_delete_PasswordPolicy
	
	/*
	 * Modify password policy details, positive test cases
	 */
	@Test (groups={"test_modify_PasswordPolicy"}, dataProvider="getPasswordPolicyDetails")	
	public void test_modify_PasswordPolicy(String testName, String policyName, String fieldName, String fieldValue) throws Exception {
		// get into password policy detail page
		sahiTasks.link(policyName).click();
		// performing test here
		PasswordPolicyTasks.modify_PasswordPolicy(sahiTasks, testName, policyName, fieldName, fieldValue);  
		//go back to password policy list
		sahiTasks.link("Password Policies").click();
	}//test_modify_PasswordPolicy
	
	/*
	 * Modify password policy details, negative test cases
	 */
	@Test (groups={"test_modify_PasswordPolicy_Negative"}, dataProvider="getPasswordPolicyDetailsNegative")	
	public void test_modify_PasswordPolicy_Negative(String testName, String policyName, String fieldName, 
											 String fieldNegValue, String expectedErrorMsg_field, String expectedErrorMsg_dialog) throws Exception {
		// get into password policy detail page
		sahiTasks.link(policyName).click();
		// performing test here 
		PasswordPolicyTasks.modify_PasswordPolicy_Negative(sahiTasks, testName, policyName, fieldName, fieldNegValue, expectedErrorMsg_field, expectedErrorMsg_dialog);
		//go back to password policy list
		//sahiTasks.link("Password Policies").click();
	}//test_modify_PasswordPolicy_Negative
	
	
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
		ll.add(Arrays.asList(new Object[]{"password policy detail field: krbmaxpwdlife", "editors","krbmaxpwdlife","50"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy detail field: krbminpwdlife", "editors","krbminpwdlife","5"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy detail field: krbpwdhistorylength", "editors","krbpwdhistorylength","6"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy detail field: krbpwdmindiffchars", "editors","krbpwdmindiffchars","3"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy detail field: krbpwdminlength", "editors","krbpwdminlength","12"} ));  
		return ll;	
	}//Data provider: getPasswordPolicyDetails 
	
	@DataProvider(name="getPasswordPolicyDetailsNegative")
	public Object[][] getPasswordPolicyDetailsNegative() {
		return TestNGUtils.convertListOfListsTo2dArray(createPasswordPolicyDetailsNegative());
	}
	protected List<List<Object>> createPasswordPolicyDetailsNegative() {		
		//FIXME: not I have anything wrong here, but a bug has been reported for in-consistency error msg : https://bugzilla.redhat.com/show_bug.cgi?id=731805
		List<List<Object>> ll = new ArrayList<List<Object>>();  
											// testName, policy name, fieldName, fieldValue
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbmaxpwdlife: non-integer",  
											"editors","krbmaxpwdlife","abc", "Must be an integer", "invalid 'krbmaxpwdlife': must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbmaxpwdlife: upper range integer", 
											"editors","krbmaxpwdlife","2147483648", "Maximum value is 2147483647", "invalid 'maxlife': can be at most 2147483647"} ));
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbmaxpwdlife: lower range integer", 
											"editors","krbmaxpwdlife","-1","" , "invalid 'maxlife': must be at least 0"} ));		
		
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbminpwdlife: non-integer", 
											"editors","krbminpwdlife","edf", "Must be an integer", "invalid 'krbminpwdlife': must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbminpwdlife: upper range integer", 
											"editors","krbminpwdlife","2147483648", "Maximum value is 2147483647","invalid 'minlife': can be at most 2147483647"} ));
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbminpwdlife: lower range integer", 
											"editors","krbminpwdlife","-1","", "invalid 'minlife': must be at least 0"} ));
		
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbpwdhistorylength: non-integer", 
											"editors","krbpwdhistorylength","HIJ", "Must be an integer", "invalid 'krbpwdhistorylength': must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbpwdhistorylength: upper range integer", 
											"editors","krbpwdhistorylength","2147483648", "Maximum value is 2147483647", "invalid 'history': can be at most 2147483647"} ));
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbpwdhistorylength: lower range integer", 
											"editors","krbpwdhistorylength","-1", "","invalid 'history': must be at least 0"} ));
		
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbpwdmindiffchars: noon-integer", 
											"editors","krbpwdmindiffchars","3lm", "Must be an integer", "invalid 'krbpwdmindiffchars': must be an integer"} )); 
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbpwdmindiffchars: upper range integer", 
											"editors","krbpwdmindiffchars","2147483648", "Maximum value is 2147483647", "invalid 'minclasses': can be at most 5"} ));
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbpwdmindiffchars: lower range integer", 
											"editors","krbpwdmindiffchars","-1","", "invalid 'minclasses': must be at least 0"} ));
		
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbpwdminlength: non-integer", 
											"editors","krbpwdminlength","n0p", "Must be an integer", "invalid 'krbpwdminlength': must be an integer"} ));  
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbpwdminlength: upper range integer", 
											"editors","krbpwdminlength","2147483648", "Maximum value is 2147483647", "invalid 'minlength': can be at most 2147483647"} ));
		ll.add(Arrays.asList(new Object[]{"password policy detail mod test: krbpwdminlength: lower range integer", 
											"editors","krbpwdminlength","-1", "", "invalid 'minlength': must be at least 0"} ));	
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
