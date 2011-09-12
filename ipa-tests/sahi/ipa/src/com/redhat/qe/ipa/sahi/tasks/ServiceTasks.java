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
		sahiTasks.select(0).choose(srvtype);
		sahiTasks.span("icon combobox-icon").click();
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
		sahiTasks.span("icon combobox-icon").click();
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
	 * Verify Valid Certificate Status
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
}
