package com.redhat.qe.ipa.sahi.tests.automember;

import java.lang.reflect.Constructor;
import java.util.logging.Logger;

import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.ipa.sahi.pages.IPAWebAutomation;
import com.redhat.qe.ipa.sahi.tests.group.GroupTests;

public class AutomemberTests extends IPAWebAutomation {
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
	
	@Test (groups={"delete"}, dataProvider="deleteData", dependsOnGroups = "modify",
		description = "execute test cases in delete queue")
	public void test_delete(String scenario, String testPage, String testDataFile) throws Exception { 
		executeQueue(testPage, "delete", testDataFile);
	}
	
	/***************************************************************************** 
	 *             Data providers                                                * 
	 *****************************************************************************/
	
	private String AutomemberTestDataFile = "/home/ipawebui/sahi/ipa/src/com/redhat/qe/ipa/sahi/tests/automember/automembertest.properties";
	
	private String[] PolicyPageAutomemberUserGroupRules = {"simple add and delete","PolicyPageAutomemberUserGroupRules", AutomemberTestDataFile};
	private String[] PolicyPageAutomemberHostGroupRules = {"simple add and delete","PolicyPageAutomemberHostGroupRules", AutomemberTestDataFile};
	private String[] IdentityPageUsers = {"simple add and delete","IdentityPageUsers", AutomemberTestDataFile};
	private String[] IdentityPageUserGroups = {"simple add and delete","IdentityPageUserGroups", AutomemberTestDataFile};
	private String[] IdentityPageHostGroups = {"simple add and delete", "IdentityPageHostGroups", AutomemberTestDataFile};
	
	private String[][] testdataAdd = {};
	//private String[][] testdataAdd    = {IdentityPageUsers,IdentityPageUserGroups,IdentityPageHostGroups,PolicyPageAutomemberUserGroupRules,PolicyPageAutomemberHostGroupRules};
	private String[][] testdataModify = {PolicyPageAutomemberUserGroupRules,PolicyPageAutomemberHostGroupRules};
	//private String[][] testdataDelete = {IdentityPageUsers,IdentityPageUserGroups,IdentityPageHostGroups,PolicyPageAutomemberUserGroupRules,PolicyPageAutomemberHostGroupRules};
	private String[][] testdataDelete = {};
	
	@DataProvider(name="addData")
	public Object[][] getAddData(){return testdataAdd; }

	@DataProvider(name="modifyData")
	public Object[][] getModifyData(){return testdataModify;}

	@DataProvider(name="deleteData")
	public Object[][] getDeleteData(){return testdataDelete;}
	
}
	
	
	