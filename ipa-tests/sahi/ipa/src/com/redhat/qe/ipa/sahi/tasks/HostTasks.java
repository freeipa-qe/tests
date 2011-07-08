package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.thoughtworks.selenium.Wait;


public class HostTasks {
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	
	/*
	 * Create a host without dns records defined.
	 * @param sahiTasks 
	 * @param hostname - shortname
	 * @param domain - domain name
	 */
	public static void forceCreateHost(SahiTasks sahiTasks, String hostname, String domain) {
		sahiTasks.link("Add").click();
		sahiTasks.textbox("Host Name:").setValue(hostname);
		//sahiTasks.textbox() - need to add selecting correct domain from list
		sahiTasks.checkbox("Force:").click();
		sahiTasks.button("Add").click();
	}
	
	/*
	 * Create a host without dns records defined.
	 * @param sahiTasks 
	 * @param fqdn - fully qualified hostname
	 */
	public static void forceCreateHostFQDN(SahiTasks sahiTasks, String fqdn) {
		sahiTasks.link("Add").click();
		sahiTasks.textbox("Host name").setValue(fqdn);
		//sahiTasks.textbox("Host name").near(sahiTasks.label("Host Name:")).setValue(fqdn);
		sahiTasks.checkbox("force").click();
		sahiTasks.button("Add").click();
	}
	
	/*
	 * Create a new invalid host.
	 * @param sahiTasks 
	 * @param hostname - shortname
	 * @param domain - domain name
	 * @param ipadr - ip address for the host
	 * @param expectedError - the error thrown when an invalid host is being attempted to be added
	 */
	public static void createInvalidHostForce(SahiTasks sahiTasks, String hostname, String domain, String ipadr, String expectedError) {
		sahiTasks.link("Add").click();
		sahiTasks.select("fqdn-entity-select").choose(domain);
		sahiTasks.textbox("Host name").near(sahiTasks.label("Host Name:")).setValue(hostname);
		sahiTasks.checkbox("force").near(sahiTasks.label("Force:")).click();
		sahiTasks.button("Add").click();
		//Check for expected error
		log.fine("error check");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding invalid host");
	
		log.fine("cancel(near retry)");
		sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
		log.fine("cancel");
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}
	
	/*
	 * Delete the host.
	 * @param sahiTasks
	 * @param fqdn - the fqdn of the host to be deleted
	 */
	public static void deleteHost(SahiTasks sahiTasks, String fqdn) {
		sahiTasks.checkbox(fqdn).click();
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
}

