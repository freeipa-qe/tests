package com.redhat.qe.ipa.sahi.tests.globalization;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import java.util.ArrayList;
import java.util.Properties;
import java.util.logging.Logger;

import javax.mail.Address;
import javax.mail.Message;
import javax.mail.MessageRemovedException;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.testng.annotations.*; 

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.pages.EmailTool;
import com.redhat.qe.ipa.sahi.pages.IPAWebAutomationActionNotDefinedException;
import com.redhat.qe.ipa.sahi.pages.IPAWebPage; 
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.GlobalizationWebAutomationTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 
import com.redhat.qe.ipa.sahi.tests.group.GroupTests; 
import com.redhat.qe.ipa.sahi.pages.*;

public class GlobalizationWebAutomation extends IPAWebAutomation {
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
	
	private String globalizationAcceptanceTestDataFile = "/home/ipawebui/sahi/test.properties";
	private String[] IdentityPageUsers = {"simple add and delete","IdentityPageUsers", globalizationAcceptanceTestDataFile};
	private String[] IdentityPageUserGroups = {"simple add and delete","IdentityPageUserGroups", globalizationAcceptanceTestDataFile};
	private String[] IdentityPageHosts = {"simple add and delete","IdentityPageHosts", globalizationAcceptanceTestDataFile};
	private String[] IdentityPageHostGroups = {"simple add and delete", "IdentityPageHostGroups", globalizationAcceptanceTestDataFile};
	private String[] IdentityPageNetgroups = {"simple add and delete", "IdentityPageNetgroups", globalizationAcceptanceTestDataFile};
	private String[] IdentityPageServices = {"simple add and delete", "IdentityPageServices", globalizationAcceptanceTestDataFile};

	private String[] PolicyPageHBACRules = {"simple add and delete","PolicyPageHBACRules", globalizationAcceptanceTestDataFile};
	private String[] PolicyPageHBACServices = {"simple add and delete", "PolicyPageHBACServices",globalizationAcceptanceTestDataFile};
	private String[] PolicyPageHBACServiceGroups = {"simple add and delete", "PolicyPageHBACServiceGroups",globalizationAcceptanceTestDataFile};

	private String[] PolicyPageSudoCommands = {"simple add and delete", "PolicyPageSudoCommand",globalizationAcceptanceTestDataFile};
	private String[] PolicyPageSudoCommandGroups = {"simple add and delete", "PolicyPageSudoCommandGroups",globalizationAcceptanceTestDataFile};
	private String[] PolicyPageAutomountLocations = {"simple add and delete", "PolicyPageAutomountLocation",globalizationAcceptanceTestDataFile};
	
	private String[] IPAServerPageRoles = {"simple add and delete", "IPAServerPageRoles",globalizationAcceptanceTestDataFile};
	private String[] IPAServerPagePrivileges = {"simple add and delete", "IPAServerPagePrivileges",globalizationAcceptanceTestDataFile};
	private String[] IPAServerPagePermissions = {"simple add and delete", "IPAServerPagePermissions",globalizationAcceptanceTestDataFile};
	private String[] IPAServerPageSelfServicePermissions = {"simple add and delete", "IPAServerPageSelfServicePermissions",globalizationAcceptanceTestDataFile};
	private String[] IPAServerPageDelegations = {"simple add and delete", "IPAServerPageDelegation",globalizationAcceptanceTestDataFile};

/*
 * 
	private String[][] allTestdataAdd = {IdentityPageUsers,IdentityPageUserGroups,IdentityPageHosts,IdentityPageHostGroups,IdentityPageNetgroups,IdentityPageServices,
									PolicyPageHBACRules,PolicyPageHBACServices, PolicyPageHBACServiceGroups,
									PolicyPageSudoRules,PolicyPageSudoCommands,PolicyPageAutomountLocations,
									IPAServerPageRoles, IPAServerPagePrivileges, IPAServerPagePermissions,IPAServerPageSelfServicePermissions,
									IPAServerPageDelegation};
	private String[][] allTestdataModify = testdataAdd;
	private String[][] allTestdataDelete =	testdataAdd;
*/	
	private String[][] testdataAdd    = {IdentityPageUsers,IdentityPageUserGroups,IdentityPageHosts,IdentityPageHostGroups,
			IdentityPageNetgroups,IdentityPageServices,PolicyPageHBACRules,PolicyPageHBACServices, PolicyPageHBACServiceGroups,
			PolicyPageSudoCommands,PolicyPageAutomountLocations,IPAServerPageRoles, IPAServerPagePrivileges, IPAServerPagePermissions,
			IPAServerPageSelfServicePermissions};
	private String[][] testdataModify = {IdentityPageUsers,IdentityPageUserGroups,IdentityPageHosts,IdentityPageHostGroups,
			IdentityPageNetgroups,IdentityPageServices,PolicyPageHBACRules,PolicyPageHBACServices, PolicyPageHBACServiceGroups,
			PolicyPageSudoCommands,PolicyPageAutomountLocations,IPAServerPageRoles, IPAServerPagePrivileges, IPAServerPagePermissions,
			IPAServerPageSelfServicePermissions};
	private String[][] testdataDelete =	{IdentityPageUsers,IdentityPageUserGroups,IdentityPageHosts,IdentityPageHostGroups,
			IdentityPageNetgroups,IdentityPageServices,PolicyPageHBACRules,PolicyPageHBACServices, PolicyPageHBACServiceGroups,
			PolicyPageSudoCommands,PolicyPageAutomountLocations,IPAServerPageRoles, IPAServerPagePrivileges, IPAServerPagePermissions,
			IPAServerPageSelfServicePermissions};
	
	@DataProvider(name="addData")
	public Object[][] getAddData(){return testdataAdd; }

	@DataProvider(name="modifyData")
	public Object[][] getModifyData(){return testdataModify;}

	@DataProvider(name="deleteData")
	public Object[][] getDeleteData(){return testdataDelete;}
 
}
