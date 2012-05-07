package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class ServiceTasks {
	private static Logger log = Logger.getLogger(UserTasks.class.getName());
	
	/*
	 * Add a new service.
	 * @param sahiTasks 
	 * @param srvtype - Type of service to add
	 * @param hostname - hostname of machine hosting the service
	 * @param force - if true check the force button because DNS records do not exist
	 * @param button - Add or Cancel
	 */
	public static void addService(SahiTasks sahiTasks, String srvtype, String hostname, Boolean force, String button) {
		sahiTasks.link("Add").click();
		     sahiTasks.span("icon combobox-icon").click();
		     sahiTasks.select("list").choose(srvtype);
		
		sahiTasks.span("icon combobox-icon[1]").click();
		sahiTasks.select("list").choose(hostname);
		if (force == true){
				sahiTasks.checkbox("force").check();
		}
		sahiTasks.button(button).click();
	}
	
	/*
	 * Add a new custom service.
	 * @param sahiTasks 
	 * @param customservice - Type of service to add
	 * @param hostname - hostname of machine hosting the service
	 * @param force - if true check the force button because DNS records do not exist
	 */
	public static void addCustomService(SahiTasks sahiTasks, String customservice, String hostname, Boolean force) {
		sahiTasks.link("Add").click();
		sahiTasks.textbox("service").setValue(customservice);
		sahiTasks.span("icon combobox-icon").near(sahiTasks.textbox("host")).click();
		sahiTasks.select("list").choose(hostname);
		if (force == true){
				sahiTasks.checkbox("force").check();
		}
		sahiTasks.button("Add").click();
	}
	
	/*
	 * Delete a service
	 * @param sahiTasks 
	 * @param serviceprinc - service principal to delete
	 * @param button - Delete or Cancel
	 */
	public static void deleteService(SahiTasks sahiTasks, String serviceprinc, String button) {
		sahiTasks.checkbox(serviceprinc).click();
		sahiTasks.link("Delete").click();
		sahiTasks.button(button).click();
		
		if(button == "Cancel"){
			// uncheck if the action was to cancel
			sahiTasks.checkbox(serviceprinc).click();
		}
	}
	
	/*
	 * Delete multiple services.
	 * @param sahiTasks
	 * @param servicprinc - the array of service principals to delete
	 */
	public static void deleteService(SahiTasks sahiTasks, String [] serviceprincs) {
		for (String serviceprinc : serviceprincs) {
			sahiTasks.checkbox(serviceprinc).click();
		}
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	
	/*
	 * Add a certificate
	 * @param sahiTasks
	 * @param servicename - service to add certificate for
	 * @param csr - certificate request
	 * @param button - "Issue" or "Cancel"
	 */
	public static void addServiceCertificate(SahiTasks sahiTasks, String servicename, String csr, String button) {
		sahiTasks.link(servicename).click();
		sahiTasks.span("New Certificate").click();
		sahiTasks.textarea(0).setValue(csr);
		sahiTasks.button(button).click();
		sahiTasks.link("Services").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Revoke a certificate
	 * @param sahiTasks
	 * @param serviceprinc - service to add certificate for
	 * @param reason - reason for revocation - match exact string to reason in drop down menu
	 * @param button - Revoke or Cancel
	 */
	public static void revokeServiceCertificate(SahiTasks sahiTasks, String serviceprinc, String reason, String button) {
		sahiTasks.link(serviceprinc).click();
		sahiTasks.span("Revoke").click();
		sahiTasks.select(0).choose(reason);
		sahiTasks.button(button).click();
		sahiTasks.link("Services").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Restore a certificate
	 * @param sahiTasks
	 * @param serviceprinc - service to restore certificate for
	 * @param button - Restore or Cancel
	 */
	public static void restoreServiceCertificate(SahiTasks sahiTasks, String serviceprinc, String button) {
		sahiTasks.link(serviceprinc).click();
		sahiTasks.span("Restore").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Services").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Verify Valid Certificate
	 * @param sahiTasks
	 * @param servicename - servicename
	 * @param certexists - boolean - should one exist?
	 */
	public static void verifyServiceCertificate(SahiTasks sahiTasks, String servicename, boolean certexists) {
		sahiTasks.link(servicename).click();
		if (certexists == false){
			Assert.assertFalse(sahiTasks.span("Get").exists(), "Service certificate verify Get button doesn't exist");
			Assert.assertFalse(sahiTasks.span("View").exists(), "Service certificate verify View button  doesn't exist");
			Assert.assertFalse(sahiTasks.span("Revoke").exists(), "Service certificate verify Revoke button  doesn't exist");
			Assert.assertTrue(sahiTasks.span("New Certificate").exists(), "Service certificate verify New Certificate button exists");
		}
		else {
			sahiTasks.span("Get").isVisible();
			Assert.assertTrue(sahiTasks.span("Get").exists(), "Service certificate verify Get button");
			Assert.assertTrue(sahiTasks.span("View").exists(), "Service certificate verify View button");
			Assert.assertTrue(sahiTasks.span("Revoke").exists(), "Service certificate verify Revoke button");
		
			//view certificate
			sahiTasks.span("View").click();
			sahiTasks.button("Close").click();
		
			//get certificate
			sahiTasks.span("Get").click();
			sahiTasks.button("Close").click();
		}
		
		sahiTasks.link("Services").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Verify Revoked Certificate Status
	 * @param sahiTasks
	 * @param hostname - serviceprinc
	 * @param status - Revoked or Hold
	 * @param reason - If revoked or held, reason string to look for
	 */
	public static void verifyServiceCertificateStatus(SahiTasks sahiTasks, String serviceprinc, String status, String reason) {
		sahiTasks.link(serviceprinc).click();
		if (status == "Hold"){
			Assert.assertTrue(sahiTasks.span("Restore").exists(), "Host certificate on hold, verify Restore button");
			Assert.assertTrue(sahiTasks.span("Certificate Hold").exists(), "Verifying Certificate Hold status.");
		}
		if (status == "Revoked"){
			Assert.assertTrue(sahiTasks.span("New Certificate").exists(), "Host certificate revoked, verify New Certificate button");
			Assert.assertTrue(sahiTasks.span(reason).exists(), "Verifying Certificate Revoked status: " + reason);
		}
		
		sahiTasks.link("Services").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Add managedby host
	 * @param sahiTasks
	 * @param serviceprinc - service principal to add managed host to
	 * @param hostname - host name
	 * @param button - Revoke or Cancel
	 */
	public static void addManagedByHost(SahiTasks sahiTasks, String serviceprinc, String hostname, String button) {
		sahiTasks.link(serviceprinc).click();
		sahiTasks.link("managedby_host").click();
		sahiTasks.link("Add").click();
		sahiTasks.checkbox(hostname).click();
		sahiTasks.span(">>").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Services").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Remove managed host
	 * @param sahiTasks
	 * @param serviceprinc - service principal to add managed host to
	 * @param button - Revoke or Cancel
	 */
	public static void removeManagedByHost(SahiTasks sahiTasks, String serviceprinc, String hostname, String button) {
		sahiTasks.link(serviceprinc).click();
		sahiTasks.link("managedby_host").click();
		sahiTasks.checkbox(hostname).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button(button).click();
		if(button == "Cancel")
				{
					// uncheck if the action was to cancel
					sahiTasks.checkbox(hostname).click();
				}
		sahiTasks.link("Services").in(sahiTasks.div("content")).click();
	}
	
	
	/*
	 * Verify managedby host
	 * @param sahiTasks
	 * @param serviceprinc - service principal
	 * @param hostname - managedby host
	 */
	public static void verifyManagedByHost(SahiTasks sahiTasks, String managed, String managedby, boolean exists ) {
		sahiTasks.link(managed).click();
		sahiTasks.link("managedby_host").click();
		if (exists == true){
			Assert.assertTrue(sahiTasks.link(managedby).exists(), "Service " + managed + " is managed by " + managedby);
		}
		if (exists == false){
			Assert.assertFalse(sahiTasks.link(managedby).exists(), "Service " + managed + " is NOT managed by " + managedby);
		}	
		
		sahiTasks.link("Services").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Verify keytab provisioning
	 * @param sahiTasks
	 * @param serviceprinc - service principal
	 * @param provisioned - boolean provisioned or not
	 */
	public static void verifyServiceKeytab(SahiTasks sahiTasks, String serviceprinc, boolean provisioned ) {
		sahiTasks.link(serviceprinc).click();
		sahiTasks.span("Refresh").click();
		if (provisioned == false){
			Assert.assertTrue(sahiTasks.bold("Kerberos Key Not Present").exists(), "Service " + serviceprinc + " does not have a keytab provisioned");
		}
		if (provisioned == true){
			Assert.assertTrue(sahiTasks.bold("Kerberos Key Present, Service Provisioned:").exists(), "Service " + serviceprinc + " has a keytab provisioned");
		}	
		sahiTasks.link("Services").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Unprovision keytab
	 * @param sahiTasks
	 * @param serviceprinc - service principal
	 * @param button - boolean provisioned or not
	 */
	public static void deleteServiceKeytab(SahiTasks sahiTasks, String serviceprinc, String button ) {
		sahiTasks.link(serviceprinc).click();
		sahiTasks.span("Refresh").click();
		sahiTasks.span("Delete Key, Unprovision").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Services").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Add invalid service.
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param service name - name for the service
	 * @param expectedError - the error thrown when an invalid host is being attempted to be added
	 */
	public static void addInvalidService(SahiTasks sahiTasks, String hostname, String servicename, String expectedError, boolean requiredFieldTest) {
		sahiTasks.link("Add").click();
		sahiTasks.textbox("service").setValue(servicename);
		sahiTasks.span("icon combobox-icon").near(sahiTasks.textbox("host")).click();
		sahiTasks.select("list").choose(hostname);
		sahiTasks.button("Add").click();
		//Check for expected error
		log.fine("error check");
		if (requiredFieldTest)
			Assert.assertTrue(sahiTasks.span(expectedError).exists(), "Verified expected error when adding invalid service");
		else {
			Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding invalid service");
			
			log.fine("cancel(near retry)");
			sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
		}
		
		log.fine("cancel");
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}
}
