package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class HostTasks {
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	private static String realm = System.getProperty("ipa.server.realm");
	
	/*
	 * Create a host without dns records defined.
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 */
	public static void addHost(SahiTasks sahiTasks, String fqdn, String ipadr) {
		sahiTasks.link("Add[1]").click();
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
	 * @param description -  example: internal web server
	 * @param local - example: 314 Littleton Road, Westford, MA
	 * @param location - example: 3rd floor lab
	 * @param platform - example: x86_64
	 * @param os - example: Red Hat Enterprise Linux 6
	 */
	public static void addHostAndEdit(SahiTasks sahiTasks, String hostname, String ipadr, String description, String local, String location, String platform, String os) {
		sahiTasks.link("Add[1]").click();
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
		sahiTasks.textbox("l").setValue(local);
		sahiTasks.textbox("nshostlocation").setValue(location);
		sahiTasks.textbox("nshardwareplatform").setValue(platform);
		sahiTasks.textbox("nsosversion").setValue(os);
		sahiTasks.link("Update").click();
		sahiTasks.link("Hosts[1]").click();
	}
	
	/*
	 * Verify host fields
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param description - description for host
	 * @param local - example: 314 Littleton Road, Westford, MA
	 * @param location - example: 3rd floor lab
	 * @param platform - example: x86_64
	 * @param os - example: Red Hat Enterprise Linux 6
	 */
	public static void verifyHostSettings(SahiTasks sahiTasks, String hostname, String description, String local, String location, String platform, String os) {
		//String[] components = hostname.split ("\\.");
		//String shortname = components[0];
		//String principal = "host/"+shortname+"@"+realm;	
		sahiTasks.link(hostname).click(); 
		//com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.label(hostname).containsText(hostname), "Verified fqdn for host: "+ hostname);
		//com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.label(principal).value(), principal, "Verified principal for host: " + principal);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("description").value(), description, "Verified description for host: " + description);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("l").value(), local, "Verified local for host: " + local);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("nshostlocation").value(), location, "Verified location for host: " + location);
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("nshardwareplatform").value(), platform, "Verified platform for host: " + platform);
		sahiTasks.link("Hosts[1]").click();
	}
	
	/*
	 * Create a new invalid host.
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr - ip address for the host
	 * @param expectedError - the error thrown when an invalid host is being attempted to be added
	 */
	public static void addInvalidHost(SahiTasks sahiTasks, String hostname, String ipadr, String expectedError) {
		sahiTasks.link("Add[1]").click();
		sahiTasks.textbox("fqdn").near(sahiTasks.label("Host Name:")).setValue(hostname);
		if(ipadr == ""){ 
			sahiTasks.checkbox("force").near(sahiTasks.label("Force:")).click();
		}
		if (ipadr != ""){
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
		sahiTasks.link("Delete[1]").click();
		sahiTasks.button("Delete").click();
	}
}

