package com.redhat.qe.ipa.sahi.base;

import org.testng.annotations.BeforeSuite;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.auto.testng.TestScript;

import java.util.logging.Logger;

public abstract class SahiTestScript extends TestScript {
	private static Logger log = Logger.getLogger(SahiTestScript.class.getName());
	public static SahiTasks sahiTasks = null;
	public static CommonTasks commonTasks = null;

	
	protected String browserType			= System.getProperty("ipa.browser.type");
	protected String browserPath			= System.getProperty("ipa.browser.path");
	protected String browserName			= System.getProperty("ipa.browser.name");
	protected String browserOpt				= System.getProperty("ipa.browser.opt");

	protected String sahiBaseDir			= System.getProperty("ipa.sahi.base.dir");
	protected String sahiUserdataDir		= System.getProperty("ipa.sahi.userdata.dir");

	protected String bundleHostURL			= System.getProperty("ipa.bundleServer.url");

	public SahiTestScript() {
		super();
		commonTasks = new CommonTasks();
		sahiTasks = new SahiTasks(browserType, browserPath, browserName, browserOpt, sahiBaseDir, sahiUserdataDir);
	}
	
	public static SahiTasks getSahiTasks() {
		return sahiTasks;
	}
	
	public static CommonTasks getCommonTasks() {
		return commonTasks;
	}

	
	@BeforeSuite(groups={"setup"})
	public static void openBrowser() {
		String password= System.getProperty("ipa.server.password");
		CommonTasks.formauth(sahiTasks,"admin",password);			
	}

	
/*
	@AfterSuite(groups={"teardown"})
	public void closeBrowser() {
		log.finer("Closing browser");
		sahiTasks.close();
	}*/
}
