package com.redhat.qe.ipa.base;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.LinkedHashMap;
import java.util.logging.Level;

import org.testng.annotations.BeforeSuite;

import com.redhat.qe.auto.instantiate.VersionedInstantiator;
import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.auto.testng.TestScript;
import com.redhat.qe.ipa21.locators.UIElements;
import com.redhat.qe.ipa21.tasks.CommonTasks;
import com.thoughtworks.selenium.HttpCommandProcessor;

public class SeleniumTestScript extends TestScript  {
	
	public static ExtendedSelenium selenium = null;

	protected static String seleniumServerHostname;
	protected static int seleniumServerPort;
	protected static String seleniumVersion;
	protected static String browserPath;
	public static String ipaServerURL;		//Example: https://rhel61-server5.testrelm
	
	public static String ipaVersion;
	public static String ipaAdminUser;
	public static String ipaAdminPassword;
	public static String ipaServerHostname;
	public static String ipaServerPath;
	public static String ipaServerProtocol;
	public static int ipaServerPort;
	public static VersionedInstantiator instantiator;
	protected static com.redhat.qe.ipa21.locators.UIElements UI			= null;
	protected static com.redhat.qe.ipa21.tasks.CommonTasks tasks		= null;
	
	public SeleniumTestScript() {
		
		seleniumServerHostname = "rhel61-server5.testrelm";
		seleniumServerPort = 4444;
		seleniumVersion = "2.1";
		//ipaServerURL = "https://rhel61-server5.testrelm";
		
		ipaServerURL = System.getProperty("ipa.server.url");
		if (ipaServerURL == null) throw new RuntimeException("IPA Server URL must be specified by a system property 'ipa.server.url'.");
		else {
			try {
				ipaServerHostname = new URL(ipaServerURL).getHost();
				ipaServerPath = new URL(ipaServerURL).getPath();
				ipaServerProtocol = new URL(ipaServerURL).getProtocol();
				ipaServerPort = new URL(ipaServerURL).getPort();
				System.out.println("PATH="+ipaServerPath);

			}
			catch(MalformedURLException mue){
				throw new RuntimeException("Unable to parse URL for IPA Server: " + ipaServerURL, mue);
			}
		}
		
		String seleniumServerAddress = System.getProperty("selenium.address");
		try {
			String[] split = seleniumServerAddress.split(":");
			seleniumServerHostname = split[0];
			seleniumServerPort = Integer.parseInt(split[1]);			
		}
		catch(Exception e){
			log.log(Level.SEVERE, "Could not determine selenium server hostname and port.  Property should be in format of '[hostname]:[port]'.", e);
		}
		browserPath = System.getProperty("selenium.browser.path");
		
		//set up versioned class loading for tasks
		LinkedHashMap<String, String> versions = new LinkedHashMap<String, String>();
		versions.put("2.1", "ipa21");
		
		
		//IPA SPECIFIC PROPERTIES
		ipaVersion = System.getProperty("ipa.version");
		ipaAdminUser = System.getProperty("ipa.admin.user");
		ipaAdminPassword = System.getProperty("ipa.admin.password");
		
		//Cloud Engine Version Instantiator
		instantiator = new VersionedInstantiator(versions, 3, ipaVersion);
		tasks = (CommonTasks)instantiator.getVersionedInstance(CommonTasks.class);
		UI = (UIElements)instantiator.getVersionedInstance(UIElements.class);
		//nav = (NavigationTasks)instantiator.getVersionedInstance(NavigationTasks.class);
		
	}
	
	protected void startSelenium() throws Exception {
		log.fine("Connecting to selenium server at " + seleniumServerHostname + ":" + seleniumServerPort);
		if (selenium == null) {
			if (seleniumVersion != null && seleniumVersion.startsWith("2")) {
				HttpCommandProcessor proc = new HttpCommandProcessor(seleniumServerHostname, seleniumServerPort, "*firefox ", ipaServerURL);
				selenium = new ExtendedSelenium(proc);
			}
			else {
				selenium = new ExtendedSelenium(seleniumServerHostname, seleniumServerPort, "*firefox "+browserPath, ipaServerURL);
			}
		}
		selenium.start();
	}
	
	@BeforeSuite(groups = {"setup"})
	public void setupSession() throws Exception{
		startSelenium();
		CommonTasks.kinitAsAdmin(ipaAdminUser, ipaAdminPassword);		
	}


}
