package com.redhat.qe.ipa.sahi.tests.delegation;

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
	
	@Test (groups={"delete"}, dataProvider="deleteData", dependsOnGroups = {"modify","add","search"},
		description = "execute test cases in delete queue")
	public void test_delete(String scenario, String testPage, String testDataFile) throws Exception { 
		executeQueue(testPage, "delete", testDataFile);
	}
	
	/***************************************************************************** 
	 *             Data providers                                                * 
	 *****************************************************************************/
	
	private String DelegationTestDataFile = "/home/ipawebui/sahi/test.delegation.properties";
	private String[] IPAServerPageDelegation = {"simple add and delete","IPAServerPageDelegation", DelegationTestDataFile};

	private String[][] testdataAdd    = {IPAServerPageDelegation};
	private String[][] testdataModify = {IPAServerPageDelegation};
	private String[][] testdataSearch = {IPAServerPageDelegation};
	private String[][] testdataDelete =	{IPAServerPageDelegation};
	
	@DataProvider(name="addData")
	public Object[][] getAddData(){return testdataAdd; }

	@DataProvider(name="modifyData")
	public Object[][] getModifyData(){return testdataModify;}
	
	@DataProvider(name="searchData")
	public Object[][] getSearchData(){return testdataSearch;}

	@DataProvider(name="deleteData")
	public Object[][] getDeleteData(){return testdataDelete;}
 
}
