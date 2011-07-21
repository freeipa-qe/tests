package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class HostTasks {
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	
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
	 * add a host and add another
	 * @param sahiTasks 
	 * @param hostname - hostname1
	 * @param hostname - hostname2
	 * @param hostname - hostname2
	 */
	public static void addAndAddAnotherHost(SahiTasks sahiTasks, String hostname1, String hostname2, String hostname3) {
		sahiTasks.link("Add[1]").click();
		sahiTasks.isVisible(sahiTasks.textbox("fqdn"), true);
		sahiTasks.textbox("fqdn").near(sahiTasks.label("Host Name: ")).setValue(hostname1);
		sahiTasks.checkbox("force").near(sahiTasks.label("Force:")).click();
		sahiTasks.button("Add and Add Another").click();
		
		sahiTasks.isVisible(sahiTasks.textbox("fqdn"), true);
		sahiTasks.textbox("fqdn").near(sahiTasks.label("Host Name: ")).setValue(hostname2);
		sahiTasks.checkbox("force").near(sahiTasks.label("Force:")).click();
		sahiTasks.button("Add and Add Another").click();
		
		sahiTasks.isVisible(sahiTasks.textbox("fqdn"), true);
		sahiTasks.textbox("fqdn").near(sahiTasks.label("Host Name: ")).setValue(hostname3);
		sahiTasks.checkbox("force").near(sahiTasks.label("Force:")).click();
		sahiTasks.button("Add").click();
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
		sahiTasks.link(hostname).click(); 
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
	 * Modify a host
	 * @param sahiTasks
	 * @param field - the field of the host to be modify (description, local, location, platform or os)
	 */
	public static void modifyHost(SahiTasks sahiTasks, String hostname, String field, String value) {
		sahiTasks.link(hostname).click();

		if (field == "description"){
			sahiTasks.textbox("description").setValue(value);
		}
		if (field == "local"){
			sahiTasks.textbox("l").setValue(value);
		}
		if (field == "location"){
			sahiTasks.textbox("nshostlocation").setValue(value);
		}
		if (field == "platform"){
			sahiTasks.textbox("nshardwareplatform").setValue(value);
		}
		if (field == "os"){
			sahiTasks.textbox("nsosversion").setValue(value);
		}
		
		sahiTasks.link("Update").click();
		sahiTasks.link("Hosts[1]").click();
	}
	
	/*
	 * Undo Modify a host
	 * @param sahiTasks
	 * @param field - the field of the host to be modify (description, local, location, platform or os)
	 */
	public static void undoModifyHost(SahiTasks sahiTasks, String hostname, String olddesc, String newdesc, String oldlocal, String newlocal, String oldlocation, String newlocation, String oldplatform, String newplatform, String oldos, String newos) {
		sahiTasks.link(hostname).click();

		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("description").value(), olddesc, "Verified existing description for host: " + olddesc);
		sahiTasks.textbox("description").setValue(newdesc);
		sahiTasks.span("undo[1]").click();
		
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("l").value(), oldlocal, "Verified existing local for host: " + oldlocal);
		sahiTasks.textbox("l").setValue(newlocal);
		sahiTasks.span("undo[2]").click();
		
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("nshostlocation").value(), oldlocation, "Verified existing location for host: " + oldlocation);
		sahiTasks.textbox("nshostlocation").setValue(newlocation);
		sahiTasks.span("undo[3]").click();
		
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("nshardwareplatform").value(), oldplatform, "Verified existing hardware platform for host: " + oldplatform);
		sahiTasks.textbox("nshardwareplatform").setValue(newplatform);
		sahiTasks.span("undo[4]").click();
		
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("nsosversion").value(), oldos, "Verified existing operating system for host: " + oldos);
		sahiTasks.textbox("nsosversion").setValue(newos);
		sahiTasks.span("undo[5]").click();
		
		sahiTasks.link("Hosts[1]").click();
	}
	
	/*
	 * Set Host OTP
	 * @param sahiTasks
	 * @param value - value to set for OTP
	 */
	public static void modifyHost(SahiTasks sahiTasks, String hostname, String otp) {
		sahiTasks.link(hostname).click();
		sahiTasks.textbox("otp").setValue(otp);
		sahiTasks.span("Set OTP").click();
		sahiTasks.link("Hosts[1]").click();
	}
	
	/*
	 * Verify a host field
	 * @param sahiTasks
	 * @param field - the field of the host to be modify (description, local, location, platform or os)
	 */
	public static void verifyHostField(SahiTasks sahiTasks, String hostname, String field, String value) {
		sahiTasks.link(hostname).click();
		if (field == "description"){
			com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("description").value(), value, "Verified description for host: " + value);
		}
		if (field == "local"){
			com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("l").value(), value, "Verified local for host: " + value);
		}
		if (field == "location"){
			com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("nshostlocation").value(), value, "Verified location for host: " + value);
		}
		if (field == "platform"){
			com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("nshardwareplatform").value(), value, "Verified hardware platform for host: " + value);
		}
		if (field == "os"){
			com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("nsosversion").value(), value, "Verified operating system for host: " + value);
		}
		if (field == "otp"){
			com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox("otp").value(), value, "Verified One Time Password for host: " + value);
		}

		sahiTasks.link("Hosts[1]").click();
	}
	
	/*
	 * Set Managed by Host.
	 * @param sahiTasks
	 * @param managed - host that will be managed
	 * @param managedby - host managing the other host
	 * @param button - Enroll or Cancel
	 */
	public static void setManagedByHost(SahiTasks sahiTasks, String managed, String managedby, String button) {
		String checkbox = managedby+"[1]";
		sahiTasks.link(managed).click();
		sahiTasks.link("managedby_host").click();
		sahiTasks.span("Enroll").click();
		sahiTasks.checkbox(checkbox).click();
		sahiTasks.span(">>").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Hosts[2]").click();
	}
	
	/*
	 * Remove Managed by Host.
	 * @param sahiTasks
	 * @param managed - host that will be managed
	 * @param managedby - host managing the other host
	 * @param button - Delete or Cancel
	 */
	public static void removeManagedByHost(SahiTasks sahiTasks, String managed, String managedby, String button) {
		String checkbox = managedby+"[1]";
		sahiTasks.link(managed).click();
		sahiTasks.link("managedby_host").click();
		sahiTasks.checkbox(checkbox).click();
		sahiTasks.span("Delete[2]").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Hosts[2]").click();

	}
	
	/*
	 * Verify managed by hsot
	 * @param sahiTasks
	 * @param managed - host that will be managed
	 * @param managedby - host managing the other host
	 */
	public static void verifyManagedByHost(SahiTasks sahiTasks, String managed, String managedby, String exists ) {
		sahiTasks.link(managed).click();
		sahiTasks.link("managedby_host").click();
		if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(managedby+"[1]").exists(), "Host " + managed + " is managed by " + managedby);
		}
		if (exists == "NO"){
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(managedby+"[1]").exists(), "Host " + managed + " is NOT managed by " + managedby);
		}	
		sahiTasks.link("Hosts[2]").click();
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
	
	/*
	 * Delete multiple hosts.
	 * @param sahiTasks
	 * @param hostnames - the array of hostnames to delete
	 */
	public static void deleteHost(SahiTasks sahiTasks, String [] hostnames) {
		for (String hostname : hostnames) {
			sahiTasks.checkbox(hostname).click();
		}
		sahiTasks.link("Delete[1]").click();
		sahiTasks.button("Delete").click();
	}
}

