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
import com.redhat.qe.ipa.sahi.pages.EmailTool;
import com.redhat.qe.ipa.sahi.pages.IPAWebAutomationActionNotDefinedException;
import com.redhat.qe.ipa.sahi.pages.IPAWebPage; 
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
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
	
	@Test (groups="report", dependsOnGroups = "delete",
		description = "give a test report once all test are done" )
	public void procudeTestReport()
	{
		finish = System.currentTimeMillis();
		if (reporter != null)
		{
			String report=reporter.produceReport();
			System.out.println(report); 
			
			String emailServer = "smtp.corp.redhat.com";
			String to="yzhang@redhat.com";
			String from="ipaqa@redhat.com";
			String subject="test automation result";
			EmailTool postman = new EmailTool(emailServer, from, to, subject, report);
			postman.deliver();
		}else{
			log.info("report error here");
		}
	}
	
	private void executeQueue(String testPage, String testQueue, String testDataFile)
	{
		try{ 
			Class<?> c = Class.forName(packageName + testPage);  
			Constructor<?> constructor = c.getConstructor(new Class[] {SahiTasks.class,String.class});
			IPAWebPage page = (IPAWebPage)(constructor.newInstance(browser, testDataFile));  
			ArrayList<String> testCases = page.getTestQueue(testQueue);
			for(String testcase: testCases)
			{ 
				// ensure the right starting point of each test case;
				Method ensureURL = c.getMethod("ensureUrl");
				ensureURL.invoke(page); 
				
				// prepre the test case execution monitor 
				Method m = c.getMethod(testcase, IPAWebTestMonitor.class );
				String methodName = m.getName();
				String queueKey = testPage + ":" + methodName; 
				log.info("enter method:[" + methodName + "]");
				IPAWebTestMonitor monitor = new IPAWebTestMonitor(testPage, methodName);  
				reporter.addTestCaseInExecutionQueue(monitor); 
				// start test case execution
				m.invoke(page, monitor);
				reporter.addIPAWebTestResult(monitor);
				log.info("leaving method:[" + methodName + "]");
			} 
		} catch (ClassNotFoundException x) {
		    x.printStackTrace();
		} catch (NoSuchMethodException x) {
		    x.printStackTrace();
		} catch (IllegalAccessException x) {
		    x.printStackTrace();
		} catch (InvocationTargetException x) {
		    x.printStackTrace();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (SecurityException e) {
			e.printStackTrace();
		} catch (InstantiationException e) {
			e.printStackTrace();
		}
	}
	
	
	/***************************************************************************** 
	 *             Data providers                                                * 
	 *****************************************************************************/
	
	private String globalizationAcceptanceTestDataFile = "./test.properties";
	private String[] IdentityPageUsers = {"simple add and delete","IdentityPageUsers", globalizationAcceptanceTestDataFile};
	private String[] IdentityPageUserGroups = {"simple add and delete","IdentityPageUserGroups", globalizationAcceptanceTestDataFile};
	private String[] IdentityPageHosts = {"simple add and delete","IdentityPageHosts", globalizationAcceptanceTestDataFile};
	private String[] IdentityPageHostGroups = {"simple add and delete", "IdentityPageHostGroups", globalizationAcceptanceTestDataFile};
	private String[] IdentityPageNetgroups = {"simple add and delete", "IdentityPageNetgroups", globalizationAcceptanceTestDataFile};
	private String[] IdentityPageServices = {"simple add and delete", "IdentityPageServices", globalizationAcceptanceTestDataFile};

	private String[] PolicyPageHBACRules = {"simple add and delete","HBACRulesPolicyPage", globalizationAcceptanceTestDataFile};
//	private String[][] testdataAdd    = {IdentityPageUsers,IdentityPageUserGroups,PolicyPageHBACRules,IdentityPageHosts,IdentityPageHostGroups,IdentityPageNetgroups,IdentityPageServices};
//	private String[][] testdataModify = {IdentityPageUsers,IdentityPageUserGroups,PolicyPageHBACRules,IdentityPageHosts,IdentityPageHostGroups,IdentityPageNetgroups,IdentityPageServices};
//	private String[][] testdataDelete =	{IdentityPageUsers,IdentityPageUserGroups,PolicyPageHBACRules,IdentityPageHosts,IdentityPageHostGroups,IdentityPageNetgroups,IdentityPageServices};
	
	private String[][] testdataAdd    = {IdentityPageServices};
	private String[][] testdataModify = {IdentityPageServices};
	private String[][] testdataDelete =	{IdentityPageServices};
	
	@DataProvider(name="addData")
	public Object[][] getAddData(){return testdataAdd; }

	@DataProvider(name="modifyData")
	public Object[][] getModifyData(){return testdataModify;}

	@DataProvider(name="deleteData")
	public Object[][] getDeleteData(){return testdataDelete;}
 
}
