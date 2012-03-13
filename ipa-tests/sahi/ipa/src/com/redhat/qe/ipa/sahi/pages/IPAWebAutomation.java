package com.redhat.qe.ipa.sahi.pages;

import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeSuite;

import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.auto.testng.TestScript;
import com.redhat.qe.auto.testng.Assert;
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
	
	@AfterClass (groups={"cleanup"} , description="Restore the default  when test is done", alwaysRun=true)
	public void testcleanup() throws CloneNotSupportedException {
		// place holder: for now, I don't have anything.
	}
}
