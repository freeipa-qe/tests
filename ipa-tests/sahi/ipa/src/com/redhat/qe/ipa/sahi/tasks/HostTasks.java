package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.thoughtworks.selenium.Wait;


public class HostTasks {
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	
	/*
	 * Create a host without dns records defined.
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 */
	public static void addHost(SahiTasks sahiTasks, String fqdn, String ipadr) {
		sahiTasks.link("Add").click();
		sahiTasks.isVisible(sahiTasks.textbox("fqdn"), true);
		sahiTasks.textbox("fqdn").near(sahiTasks.label("Host Name: ")).setValue(fqdn);
		if(ipadr == ""){ 
			sahiTasks.checkbox("force").near(sahiTasks.label("Force:")).click();
		}
		if (ipadr != ""){
			sahiTasks.textbox("ip_address").setValue(ipadr);
		}
		//sahiTasks.checkbox("force").click();
		sahiTasks.button("Add").click();
	}
	
	/*
	 * Add and Edit a host
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 * @param description - description for host
	 */
	public static void addHostAndEdit(SahiTasks sahiTasks, String hostname, String ipadr, String description) {
		sahiTasks.link("Add").click();
		sahiTasks.isVisible(sahiTasks.textbox("fqdn"), true);
		sahiTasks.textbox("fqdn").near(sahiTasks.label("Host Name: ")).setValue(hostname);
		if(ipadr == ""){ 
			sahiTasks.checkbox("force").near(sahiTasks.label("Force:")).click();
		}
		if (ipadr != ""){
			sahiTasks.textbox("ip_address").setValue(ipadr);
		}
		sahiTasks.button("Add and Edit").click();
		sahiTasks.textbox("description").setValue(description);
		sahiTasks.link("Update").click();
	}
	
	/*
	 * Verify host fields
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param description - description for host
	 * @param provisioned - TRUE or FALSE string (kerberos key exists)
	 * @param otp - if one time password has been issued for pending enrollment, the otp value
	 * @param certificate - TRUE or FALSE or REVOKED
	 */
	public static void verifyHostSettings(SahiTasks sahiTasks, String hostname, String description) {
		String[] components = hostname.split ("\\.");
		String shortname = components[0];
		String principal = "host/"+shortname+"@TESTRELM";	
		sahiTasks.link(hostname).click(); 
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("fqdn").containsText(hostname), "Verified fqdn for host: "+ hostname);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("krbprincipalname").value(), principal, "Verified principal for host: " + principal);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("description").value(), description, "Verified description for host: " + description);
	}
	
	/*
	 * Create a new invalid host.
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr - ip address for the host
	 * @param expectedError - the error thrown when an invalid host is being attempted to be added
	 */
	public static void addInvalidHost(SahiTasks sahiTasks, String hostname, String ipadr, String expectedError) {
		sahiTasks.link("Add").click();
		sahiTasks.textbox("fqdn").near(sahiTasks.label("Host Name:")).setValue(hostname);
		if(ipadr == null){ 
			sahiTasks.checkbox("force").near(sahiTasks.label("Force:")).click();
		}
		if (ipadr != null){
			sahiTasks.textbox("ip_address").setValue(ipadr);
		}
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
		String lowerdn = fqdn.toLowerCase();
		sahiTasks.checkbox(lowerdn).click();
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
}

