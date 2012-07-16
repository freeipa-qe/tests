package com.redhat.qe.ipa.sahi.tests.delegation;

import java.util.logging.Logger;


import org.testng.annotations.*; 

import com.redhat.qe.ipa.sahi.tasks.UserTasks;
import com.redhat.qe.ipa.sahi.tests.group.GroupTests; 
import com.redhat.qe.ipa.sahi.pages.*;
import com.redhat.qe.ipa.sahi.*;

public class DelegationTests extends IPAWebAutomation {
	private static String packageName ="com.redhat.qe.ipa.sahi.pages.";  
	private static Logger log = Logger.getLogger(GroupTests.class.getName());
	
	@AfterMethod (alwaysRun=true)
	public void checkPossibleError(){
		// check possible error, i don't have anything here for now
	}//checkPossibleError
	
	////////////////////////////////////////////////
	//                test cases                  //
	////////////////////////////////////////////////
	
	
	@Test (groups={"add"}, dataProvider="addData",
		description = "execute test cases in add queue")
	public void test_add(String scenario, String testPage, String testDataFile) throws Exception { 
		start = System.currentTimeMillis();
		executeQueue(testPage, "add", testDataFile);
		
	}

	@Test (groups={"modify"}, dataProvider="modifyData", dependsOnGroups = "add",
		description = "execute test cases in modify queue")
	public void test_modify(String scenario, String testPage, String testDataFile) throws Exception {
		executeQueue(testPage, "modify", testDataFile);
	}
	
	
	@Test (groups={"search"}, dataProvider="searchData", dependsOnGroups = "add",
			description = "execute test cases in search queue")
		public void test_search(String scenario, String testPage, String testDataFile) throws Exception {
			executeQueue(testPage, "search", testDataFile);
	}
	
	@Test (groups={"delete"}, dataProvider="deleteData", dependsOnGroups = {"add","search"},
		description = "execute test cases in delete queue")
	public void test_delete(String scenario, String testPage, String testDataFile) throws Exception {
		executeQueue(testPage, "delete", testDataFile);
	}
	
	@Test (groups={"nonStandardUserDelegation"}, dataProvider="UserDelegationdata",
			description = "execute test cases in NonStandardDelegation queue")
		public void test_UserDelegation(String scenario, String testPage, String testDataFile) throws Exception {
			executeQueue(testPage, "nonStandardUserDelegation", testDataFile);
		}
	
	/***************************************************************************** 
	 *             Data providers                                                * 
	 *****************************************************************************/
	
	private String DelegationTestDataFile = "/home/ipawebui/sahi/ipa/src/com/redhat/qe/ipa/sahi/tests/delegation/test.delegation.properties";
	private String[] IPAServerPageDelegation = {"Delegation Tests","IPAServerPageDelegation", DelegationTestDataFile};

	private String[][] testdataAdd    = {IPAServerPageDelegation};
	private String[][] testdataModify = {IPAServerPageDelegation};
	private String[][] testdataSearch = {IPAServerPageDelegation};
	private String[][] testdataDelete =	{IPAServerPageDelegation};
	private String[][] testdataUserDelegation =	{IPAServerPageDelegation};
	
	@DataProvider(name="addData")
	public Object[][] getAddData(){return testdataAdd; }

	@DataProvider(name="modifyData")
	public Object[][] getModifyData(){return testdataModify;}
	
	@DataProvider(name="searchData")
	public Object[][] getSearchData(){return testdataSearch;}

	@DataProvider(name="deleteData")
	public Object[][] getDeleteData(){return testdataDelete;}
	
	@DataProvider(name="UserDelegationdata")
	public Object[][] getUserDelegationData(){return testdataUserDelegation;}
 
}
