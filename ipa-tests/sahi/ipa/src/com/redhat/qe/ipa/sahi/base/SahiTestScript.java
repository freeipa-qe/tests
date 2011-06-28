package com.redhat.qe.ipa.sahi.base;

import org.testng.annotations.BeforeSuite;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.auto.testng.TestScript;

import java.util.logging.Logger;

public abstract class SahiTestScript extends TestScript {
	private static Logger log = Logger.getLogger(SahiTestScript.class.getName());
	public static SahiTasks sahiTasks = null;

	


	protected String browserPath			= System.getProperty("ipa.browser.path", "/usr/bin/firefox");
	protected String browserName			= System.getProperty("ipa.browser.name", "firefox");
	protected String browserOpt				= System.getProperty("ipa.browser.opt", "");

	protected String sahiBaseDir			= System.getProperty("ipa.sahi.base.dir", "/home/nk/sahi");
	protected String sahiUserdataDir		= System.getProperty("ipa.sahi.userdata.dir", sahiBaseDir+"/userdata");

	protected String bundleHostURL			= System.getProperty("ipa.bundleServer.url");

	public SahiTestScript() {
		super();

		sahiTasks = new SahiTasks(browserPath, browserName, browserOpt, sahiBaseDir, sahiUserdataDir);
	}
	
	public static SahiTasks getSahiTasks() {
		return sahiTasks;
	}

	
	@BeforeSuite(groups={"setup"})
	public static void openBrowser() {
		log.finer("kinit as admin");
		com.redhat.qe.auto.testng.Assert.assertTrue(CommonTasks.kinitAsAdmin(), "Logged in successfully as admin");
		log.finer("Opening browser");
		sahiTasks.open();
		log.finer("Accessing: IPA Server URL");
		sahiTasks.navigateTo(System.getProperty("ipa.server.url"), true);
	}

	
/*
	@AfterSuite(groups={"teardown"})
	public void closeBrowser() {
		log.finer("Closing browser");
		sahiTasks.close();
	}*/
}
