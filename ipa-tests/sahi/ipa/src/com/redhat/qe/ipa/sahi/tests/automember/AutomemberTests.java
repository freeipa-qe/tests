package com.redhat.qe.ipa.sahi.tests.automember;

import java.lang.reflect.Constructor;
import java.util.logging.Logger;

import org.testng.annotations.AfterClass;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.pages.IPAWebAutomation;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.NetgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;
import com.redhat.qe.ipa.sahi.tests.group.GroupTests;

public class AutomemberTests extends IPAWebAutomation {
	private static String packageName ="com.redhat.qe.ipa.sahi.pages.";  
	private static Logger log = Logger.getLogger(GroupTests.class.getName()); 
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	
	private String user1 = "mjohn";
	private String user2 = "mscott";
	private String [] users = {user1, user2};
	
	private String usergroup1 = "searchbug846754_dev";
	private String usergroup2 = "defgroup";
	private String usergroup3 = "a";
	private String usergroup4 = "b";
	private String usergroup5 = "c";
	private String usergroup6 = "du001";
	
	private String [] usergroups = {usergroup1, usergroup2, usergroup3, usergroup4, usergroup5, usergroup6};
	
	private String hostgroup1 = "searchbug846754_qaservers";
	private String hostgroup2 = "defhostgroup";
	private String hostgroup3 = "dd";
	private String hostgroup4 = "ee";
	private String hostgroup5 = "ff";
	private String hostgroup6 = "dh001";
	
	private String [] hostgroups = {hostgroup1, hostgroup2, hostgroup3, hostgroup4, hostgroup5 ,hostgroup6};
		
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true)
	public void initialize() throws CloneNotSupportedException {	
		
		//log.info("kinit as admin");
		//Assert.assertTrue(CommonTasks.kinitAsAdmin(), "Logged in successfully as admin");
		
		log.info("Opening browser");
		browser.open();
		log.info("Accessing: IPA Server URL");
		browser.setStrictVisibilityCheck(true);
		
		
		currentPage = browser.fetch("top.location.href");
		alternateCurrentPage = browser.fetch("top.location.href") + "&netgroup-facet=search" ;
        
		CommonTasks.formauth(browser, "admin", "Secret123");
		
		//add users for automember
		browser.navigateTo(commonTasks.userPage, true);
		for (String username : users){
			UserTasks.createUser(browser, username, username, username, "Add");
		} 
		
		//add groups for automember
		browser.navigateTo(commonTasks.groupPage, true);
		for (String groupname : usergroups){
			String groupDescription = groupname + " description";
			GroupTasks.addGroup(browser, groupname, groupDescription);
		} 
		
		//add hostgroups for automember
		browser.navigateTo(commonTasks.hostgroupPage, true);
		for (String hostgroup : hostgroups) {
			String description = hostgroup + " description";
			HostgroupTasks.addHostGroup(browser, hostgroup, description, "Add");
		}

	} 
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	
		//delete user
		browser.navigateTo(commonTasks.userPage, true);
		for (String username : users){
			UserTasks.deleteUser(browser, username);
		}
		//delete user groups
		browser.navigateTo(commonTasks.groupPage, true);
		GroupTasks.deleteGroup(browser, usergroups);
		
		//delete host groups
		browser.navigateTo(commonTasks.hostgroupPage, true);
		HostgroupTasks.deleteHostgroup(browser, hostgroups);
		
		browser.navigateTo(commonTasks.automemberUserGroupPage,true);
		browser.checkbox("cn").click();
		browser.span("Delete").click();
		if(browser.button("Delete").exists())
			browser.button("Delete").click();
		browser.textbox("automemberdefaultgroup").setValue("");
		
		browser.navigateTo(commonTasks.automemberHostGroupPage,true);
		browser.checkbox("cn").click();
		browser.span("Delete").click();
		if(browser.button("Delete").exists())
			browser.button("Delete").click();
		browser.textbox("automemberdefaultgroup").setValue("");
	}
	
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
	
	@Test (groups={"nonStandardAutomember"}, dataProvider="automemberData", dependsOnGroups = "add",
			description = "execute test cases specified for automember")
		public void test_automember(String scenario, String testPage, String testDataFile) throws Exception { 
			executeQueue(testPage, "nonStandardAutomember", testDataFile);
	}	
	
	@Test (groups={"modify"}, dataProvider="modifyData", dependsOnGroups ={"add","nonStandardAutomember"},
		description = "execute test cases in modify queue")
	public void test_modify(String scenario, String testPage, String testDataFile) throws Exception { 
		executeQueue(testPage, "modify", testDataFile);
	}
	
	@Test (groups={"search"}, dataProvider="searchData", dependsOnGroups = {"add", "modify", "nonStandardAutomember"},
		description = "execute test cases in search queue")
	public void test_search(String scenario, String testPage, String testDataFile) throws Exception { 
		executeQueue(testPage, "search", testDataFile);
	}

	@Test (groups={"delete"}, dataProvider="deleteData", dependsOnGroups = {"add", "modify", "nonStandardAutomember","search"},
		description = "execute test cases in delete queue")
	public void test_delete(String scenario, String testPage, String testDataFile) throws Exception { 
		executeQueue(testPage, "delete", testDataFile);
	}

	
	/***************************************************************************** 
	 *             Data providers                                                * 
	 *****************************************************************************/
	//RHEL::
	private String AutomemberTestDataFile = "/home/ipawebui/sahi/ipa/src/com/redhat/qe/ipa/sahi/tests/automember/automembertest.properties";
	//F17::
	//private String AutomemberTestDataFile = "/home/test/ipawebui/sahi/ipa/src/com/redhat/qe/ipa/sahi/tests/automember/automembertest.properties";
	//Win::
	//private String AutomemberTestDataFile = "C:\\automembertest.properties";
		
	private String[] PolicyPageAutomemberUserGroupRules = {"simple add and delete","PolicyPageAutomemberUserGroupRules", AutomemberTestDataFile};
	private String[] PolicyPageAutomemberHostGroupRules = {"simple add and delete","PolicyPageAutomemberHostGroupRules", AutomemberTestDataFile};
	private String[] IdentityPageUserGroups = {"simple add and delete","IdentityPageUserGroups", AutomemberTestDataFile};
	private String[] IdentityPageHostGroups = {"simple add and delete", "IdentityPageHostGroups", AutomemberTestDataFile};
	
	
	private String[][] testdataAdd    = {PolicyPageAutomemberUserGroupRules,PolicyPageAutomemberHostGroupRules};
	private String[][] testdataAutomember = {PolicyPageAutomemberUserGroupRules,PolicyPageAutomemberHostGroupRules};
	private String[][] testdataModify = {PolicyPageAutomemberUserGroupRules,PolicyPageAutomemberHostGroupRules};
	private String[][] testdataSearch = {PolicyPageAutomemberUserGroupRules,PolicyPageAutomemberHostGroupRules};
	private String[][] testdataDelete = {PolicyPageAutomemberUserGroupRules,PolicyPageAutomemberHostGroupRules};
	
	
	@DataProvider(name="addData")
	public Object[][] getAddData(){return testdataAdd; }
	
	@DataProvider(name="automemberData")
	public Object[][] getAutomemberData(){return testdataAutomember;}
	
	@DataProvider(name="modifyData")
	public Object[][] getModifyData(){return testdataModify;}
	
	@DataProvider(name="searchData")
	public Object[][] getSearchData(){return testdataSearch;}

	@DataProvider(name="deleteData")
	public Object[][] getDeleteData(){return testdataDelete;}

	
}
	
	
	