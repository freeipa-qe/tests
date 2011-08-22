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
	/*public static void addHost(SahiTasks sahiTasks, String hostname, String domain, String ipadr) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("hostname").setValue(hostname);
		sahiTasks.textbox("dnszone").setValue(domain);
		sahiTasks.checkbox("force").click();
		sahiTasks.textbox("ip_address").setValue(ipadr);
		sahiTasks.button("Add").click();
	}*/
	
	/*
	 * Create a host without dns records defined.
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param domain - dns domain
	 * @param ipadr -  ipaddress
	 */
	public static void addHost(SahiTasks sahiTasks, String hostname, String hostdomain, String ipadr) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("hostname").setValue(hostname);
		sahiTasks.textbox("dnszone").setValue(hostdomain);
			
		if(ipadr == ""){ 
			sahiTasks.checkbox("force").click();
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
	public static void addHostAndEdit(SahiTasks sahiTasks, String domain, String hostname, String ipadr, String description, String local, String location, String platform, String os) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("hostname").setValue(hostname);
		sahiTasks.textbox("dnszone").setValue(domain);
		if(ipadr == ""){ 
			sahiTasks.checkbox("force").click();
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
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * add a host and add another
	 * @param sahiTasks 
	 * @param hostname - hostname1
	 * @param hostname - hostname2
	 * @param hostname - hostname2
	 */
	public static void addAndAddAnotherHost(SahiTasks sahiTasks, String hostname1, String hostname2, String hostname3, String domain) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("hostname").setValue(hostname1);
		sahiTasks.textbox("dnszone").setValue(domain);
		sahiTasks.checkbox("force").click();
		sahiTasks.button("Add and Add Another").click();
		
		sahiTasks.textbox("hostname").setValue(hostname2);
		sahiTasks.textbox("dnszone").setValue(CommonTasks.ipadomain);
		
		sahiTasks.checkbox("force").click();
		sahiTasks.button("Add and Add Another").click();
		
		sahiTasks.textbox("hostname").setValue(hostname3);
		sahiTasks.textbox("dnszone").setValue(CommonTasks.ipadomain);
		sahiTasks.checkbox("force").click();
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
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Create a new invalid host.
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr - ip address for the host
	 * @param expectedError - the error thrown when an invalid host is being attempted to be added
	 */
	public static void addInvalidHost(SahiTasks sahiTasks, String hostname, String hostdomain, String ipadr, String expectedError) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("hostname").setValue(hostname);
		sahiTasks.textbox("dnszone").setValue(CommonTasks.ipadomain);
		if(ipadr == ""){ 
			sahiTasks.checkbox("force").click();
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
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Undo Modify a host
	 * @param sahiTasks
	 * @param field - the field of the host to be modify (description, local, location, platform or os)
	 */
	public static void undoModifyHost(SahiTasks sahiTasks, String hostname, String newdesc, String newlocal, String newlocation, String newplatform, String newos) {
		sahiTasks.link(hostname).click();

		sahiTasks.textbox("description").setValue(newdesc);
		sahiTasks.span("undo").click();
		
		sahiTasks.textbox("l").setValue(newlocal);
		sahiTasks.span("undo").click();
		
		sahiTasks.textbox("nshostlocation").setValue(newlocation);
		sahiTasks.span("undo").click();
		
		sahiTasks.textbox("nshardwareplatform").setValue(newplatform);
		sahiTasks.span("undo").click();
		
		sahiTasks.textbox("nsosversion").setValue(newos);
		sahiTasks.span("undo").click();
		
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Set otp
	 * @param sahiTasks
	 * @param value - value to set for OTP
	 */
	public static void modifyHostOTP(SahiTasks sahiTasks, String hostname, String otp) {
		sahiTasks.link(hostname).click();
		sahiTasks.textbox("otp").setValue(otp);
		sahiTasks.span("Set OTP").click();
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
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

		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Set Managed by Host.
	 * @param sahiTasks
	 * @param managed - host that will be managed
	 * @param managedby - host managing the other host
	 * @param button - Enroll or Cancel
	 */
	public static void setManagedByHost(SahiTasks sahiTasks, String managed, String managedby, String button) {
		//String checkbox = managedby+"[1]";
		sahiTasks.link(managed).click();
		sahiTasks.link("managedby_host").click();
		sahiTasks.span("Enroll").click();
		sahiTasks.checkbox(managedby).click();
		sahiTasks.span(">>").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Remove Managed by Host.
	 * @param sahiTasks
	 * @param managed - host that will be managed
	 * @param managedby - host managing the other host
	 * @param button - Delete or Cancel
	 */
	public static void removeManagedByHost(SahiTasks sahiTasks, String managed, String managedby, String button) {
		//String checkbox = managedby+"[1]";
		sahiTasks.link(managed).click();
		sahiTasks.link("managedby_host").click();
		sahiTasks.checkbox(managedby).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();

	}
	
	/*
	 * Verify managed by host
	 * @param sahiTasks
	 * @param managed - host that will be managed
	 * @param managedby - host managing the other host
	 */
	public static void verifyManagedByHost(SahiTasks sahiTasks, String managed, String managedby, String exists ) {
		sahiTasks.link(managed).click();
		sahiTasks.link("managedby_host").click();
		if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(managedby).exists(), "Host " + managed + " is managed by " + managedby);
		}
		if (exists == "NO"){
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(managedby).exists(), "Host " + managed + " is NOT managed by " + managedby);
		}	
		
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
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
	
	/*
	 * Delete the host.
	 * @param sahiTasks
	 * @param fqdn - the fqdn of the host to be deleted
	 * @param updatedns - YES
	 */
	public static void deleteHost(SahiTasks sahiTasks, String fqdn, String updatedns) {
		String lowerdn = fqdn.toLowerCase();
		sahiTasks.checkbox(lowerdn).click();
		sahiTasks.link("Delete").click();
		if (updatedns == "YES"){
			sahiTasks.checkbox("updatedns").click();
		}
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
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	
	/*
	 * Verify DNS host link
	 * @param sahiTasks
	 * @param hostname
	 * @param exists - YES if you expect the link to exist otherwise NO
	 */
	public static void verifyHostDNSLink(SahiTasks sahiTasks, String hostname, String exists) {
		sahiTasks.link(hostname).click();
		if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(hostname).exists(), "Host " + hostname + " link to DNS exists");
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(hostname).exists(), "Host " + hostname + " link to DNS does NOT exists");
		}
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Add a certificate
	 * @param sahiTasks
	 * @param hostname - host to add certificate for
	 * @param csr - certificate request
	 */
	public static void addHostCertificate(SahiTasks sahiTasks, String hostname, String csr) {
		sahiTasks.link(hostname).click();
		sahiTasks.span("New Certificate").click();
		sahiTasks.textarea(0).setValue(csr);
		sahiTasks.button("Issue").click();
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Verify Valid Certificate Status
	 * @param sahiTasks
	 * @param hostname - hostname
	 */
	public static void verifyHostCertificate(SahiTasks sahiTasks, String hostname) {
		sahiTasks.link(hostname).click();
		sahiTasks.span("Get").isVisible();
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.span("Get").exists(), "Host certificate verify Get button");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.span("View").exists(), "Host certificate verify View button");
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.span("Revoke").exists(), "Host certificate verify Revoke button");
		
		//view certificate
		sahiTasks.span("View").click();
		sahiTasks.button("Close").click();
		
		//get certificate
		sahiTasks.span("Get").click();
		sahiTasks.button("Close").click();
		
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();

	}
	
	/*
	 * Revoke a certificate
	 * @param sahiTasks
	 * @param hostname - host to add certificate for
	 * @param reason - reason for revokation - match exact string to reason in drop down menu
	 * @param button - Revoke or Cancel
	 */
	public static void revokeHostCertificate(SahiTasks sahiTasks, String hostname, String reason, String button) {
		sahiTasks.link(hostname).click();
		sahiTasks.span("Revoke").click();
		sahiTasks.select(0).choose(reason);
		sahiTasks.button(button).click();
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Verify Revoked Certificate Status
	 * @param sahiTasks
	 * @param hostname - hostname
	 * @param status - Revoked or Hold
	 * @param reason - If revoked or held, reason string to look for
	 */
	public static void verifyHostCertificate(SahiTasks sahiTasks, String hostname, String status, String reason) {
		sahiTasks.link(hostname).click();
		if (status == "Hold"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.span("Restore").exists(), "Host certificate on hold, verify Restore button");
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.span("Certificate Hold").exists(), "Verifying Certificate Hold status.");
		}
		if (status == "Revoked"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.span("New Certificate").exists(), "Host certificate revoked, verify New Certificate button");
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.span(reason).exists(), "Verifying Certificate Revoked status: " + reason);
		}
		
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Restore a certificate
	 * @param sahiTasks
	 * @param hostname - host to add certificate for
	 * @param button - Restore or Cancel
	 */
	public static void restoreHostCertificate(SahiTasks sahiTasks, String hostname, String button) {
		sahiTasks.link(hostname).click();
		sahiTasks.span("Restore").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	/*
	 * Request new certificate
	 * @param sahiTasks
	 * @param hostname - host to add certificate for
	 * @param button - Issue or Cancel
	 */
	public static void newHostCertificate(SahiTasks sahiTasks, String hostname, String csr, String button) {
		sahiTasks.link(hostname).click();
		sahiTasks.span("New Certificate").click();
		sahiTasks.textarea(0).setValue(csr);
		sahiTasks.button(button).click();
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/* Request new certificate
	 * @param sahiTasks
	 * @param hostname - host to add certificate for
	 * @param button - Issue or Cancel
	 */
	public static void invalidHostCSR(SahiTasks sahiTasks, String hostname, String csr, String expectedError) {
		sahiTasks.link(hostname).click();
		sahiTasks.span("New Certificate").click();
		sahiTasks.textarea(0).setValue(csr);
		sahiTasks.button("Issue").click();
		
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error with invalid csr.");
		sahiTasks.button("Cancel").click();
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Verify host membership in a group or rule
	 * @param sahiTasks 
	 * @param hostname
	 * @param membertype - "Host Groups" or "Netgroups" or "Roles" or "HBAC Rules" or "Sudo Rules"
	 * @param grprulename - group or rule name
	 * @param type - direct or indirect
	 * @param exists - "YES" if the membership is expected to exist
	 */
	public static void verifyHostMemberOf(SahiTasks sahiTasks, String hostname, String membertype, String grprulename, String type, 
			String exists, boolean onPage) {
		if (!onPage) 
			sahiTasks.link(hostname).click();
		if (membertype == "Host Groups"){
			sahiTasks.link("memberof_hostgroup").click();
		}
		if (membertype == "Netgroups"){
			sahiTasks.link("memberof_netgroup").click();
		}
		if (membertype =="Roles"){
			sahiTasks.link("memberof_role").click();
		}
		if (membertype == "HBAC Rules"){
			sahiTasks.link("memberof_hbacrule").click();
		}
		if (membertype == "Sudo Rules"){
			sahiTasks.link("memberof_sudorule").click();
		}
		
		sahiTasks.radio(type).click();


		if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(grprulename).exists(), "Host " + hostname + " is a member of " + membertype + " " + grprulename);
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(grprulename).exists(), "Host " + hostname + " is NOT member of " + membertype + " "+ grprulename);
		}
		if (!onPage) 
			sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Verify host membership in a group or rule
	 * @param sahiTasks 
	 * @param hostname
	 * @param membertype - "Host Groups" or "Netgroups" or "Roles" or "HBAC Rules" or "Sudo Rules"
	 * @param grprulenames - array of group or rule names 
	 * @param type - direct or indirect
	 * @param exists - "YES" if the membership is expected to exist
	 */
	public static void verifyHostMemberOf(SahiTasks sahiTasks, String hostname, String membertype, String [] grprulenames, String type, String exists) {
		sahiTasks.link(hostname).click();
		if (membertype == "Host Groups"){
			sahiTasks.link("memberof_hostgroup").click();
		}
		if (membertype == "Netgroups"){
			sahiTasks.link("memberof_netgroup").click();
		}
		if (membertype =="Roles"){
			sahiTasks.link("memberof_role").click();
		}
		if (membertype == "HBAC Rules"){
			sahiTasks.link("memberof_hbacrule").click();
		}
		if (membertype == "Sudo Rules"){
			sahiTasks.link("memberof_sudorule").click();
		}
		
		sahiTasks.radio(type).click();

		
		for (String grprulename : grprulenames){
			if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(grprulename).exists(), "Host " + hostname + " is a member of " + membertype + " " + grprulename);
			}
			else {
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(grprulename).exists(), "Host " + hostname + " is NOT member of " + membertype + " "+ grprulename);
			}
		}
		sahiTasks.link("Hosts").in(sahiTasks.div("content")).click();
	}
}

