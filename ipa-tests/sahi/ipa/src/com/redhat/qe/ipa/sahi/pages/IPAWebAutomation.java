package com.redhat.qe.ipa.sahi.pages;

import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.auto.testng.TestScript;
import com.redhat.qe.auto.testng.Assert;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.logging.Logger;

public abstract class IPAWebAutomation extends TestScript {
	private static Logger log = Logger.getLogger(SahiTestScript.class.getName());
	public static SahiTasks browser = null;
	public static CommonTasks commonTasks = null;
	protected IPAWebAutomationReporter reporter;
	protected long start,finish;
	
	protected String browserType			= System.getProperty("ipa.browser.type");
	protected String browserPath			= System.getProperty("ipa.browser.path");
	protected String browserName			= System.getProperty("ipa.browser.name");
	protected String browserOpt				= System.getProperty("ipa.browser.opt");

	protected String sahiBaseDir			= System.getProperty("ipa.sahi.base.dir");
	protected String sahiUserdataDir		= System.getProperty("ipa.sahi.userdata.dir");

	protected String bundleHostURL			= System.getProperty("ipa.bundleServer.url");
	
	protected static String packageName ="com.redhat.qe.ipa.sahi.pages.";  
	
	public IPAWebAutomation() {
		super();
		commonTasks = new CommonTasks();
		browser = new SahiTasks(browserType, browserPath, browserName, browserOpt, sahiBaseDir, sahiUserdataDir);
		reporter = IPAWebAutomationReporter.instance();
	}
	
	public static SahiTasks getBrowser() {
		return browser;
	}
	
	public static CommonTasks getCommonTasks() {
		return commonTasks;
	}
 
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true)
	public void initialize() throws CloneNotSupportedException {
		log.info("kinit as admin");
		Assert.assertTrue(CommonTasks.kinitAsAdmin(), "Logged in successfully as admin");
		log.info("Opening browser");
		browser.open();
		log.info("Accessing: IPA Server URL");
		browser.setStrictVisibilityCheck(true); 
	}//initialize
	
	@Test (groups="report", dependsOnGroups = "delete",
			description = "give a test report once all test are done" )
		public void makeTestReport()
		{
			finish = System.currentTimeMillis();
			if (reporter != null)
			{
				// retire regular report later
				// FIXME: future feature: i should have different format of report come out, such as html table like format
//				String report=reporter.produceReport();
//				System.out.println(report); 
				
				String treeReport = reporter.produceTreeReport();
				System.out.println(treeReport);
				
				/*String emailServer = "smtp.corp.redhat.com";
				String to="nsoman@redhat.com";
				String from="ipaqa@redhat.com";
				String subject="test automation result";*/
				//EmailTool postman = new EmailTool(emailServer, from, to, subject, treeReport);
				//postman.deliver();
			}else{
				log.info("report error here");
			}
		}
	
	@AfterClass (groups={"cleanup"} , description="Restore the default  when test is done", alwaysRun=true)
	public void testcleanup() throws CloneNotSupportedException {
		// place holder: for now, I don't have anything.
	}
	 
	
	protected void executeQueue(String testPage, String testQueue, String testDataFile) throws ClassNotFoundException, NoSuchMethodException, IllegalAccessException, InvocationTargetException, IllegalArgumentException, SecurityException, InstantiationException 
	{
			Class<?> c = Class.forName(packageName + testPage);  
			Constructor<?> constructor = c.getConstructor(new Class[] {SahiTasks.class,String.class});
			IPAWebPage page = (IPAWebPage)(constructor.newInstance(browser, testDataFile));  
			ArrayList<String> testCases = page.getTestQueue(testQueue);
			for(String testcase: testCases)
			{ 
				// ensure the right starting point of each test case;
				Method ensureURL = c.getMethod("ensureUrl");
				ensureURL.invoke(page); 
				
				// prepare the test case execution monitor 
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
				int test=monitor.getResultStatusCode();
				if(test<1){
					Assert.assertTrue(false, "" + methodName + " failed");
				}
				else{
					Assert.assertTrue(true, "" + methodName +" passed");
				}
			}
	}
	
}
