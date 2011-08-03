package com.redhat.qe.ipa.sahi.tasks;

import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class DNSTasks {

	/*
	 * Add DNS zone
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 */
	public static boolean addDNSzone(SahiTasks browser, String zoneName, String authoritativeNameserver, String rootEmail) {
		boolean created=false;
		/*** original recorded steps
		browser.link("DNS").click();
		browser.span("Add[1]").click();
		browser.textbox("idnsname").setValue("sahi.zone.001");
		browser.textbox("idnssoamname").setValue("dhcp121.sjc.redhat.com");
		browser.textbox("idnssoarname").setValue("root.dhcp-121.sjc.redhat.com");
		browser.textbox("idnssoamname").setValue("dhcp-121.sjc.redhat.com");
		browser.button("Add").click();
		browser.checkbox("select[4]").click();
		browser.span("Delete[1]").click();
		browser.button("Delete").click();
		*/
		 
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(zoneName);
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail); 
		browser.button("Add").click();
		browser.checkbox(zoneName).click();
		browser.span("Delete").click();
		browser.button("Delete").click();
		return created;
	}//addDNSzone
	
	/*
	 * Add DNS zone
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 */
	public static boolean delDNSzone(SahiTasks browser, String zoneName, String authoritativeNameserver, String rootEmail) {
		boolean deleted=false; 
		
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(zoneName);
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail); 
		browser.button("Add").click();
		browser.checkbox(zoneName).click();
		browser.span("Delete").click();
		browser.button("Delete").click();
		return deleted;
	}//delDNSzone
	
	/*
	 * Add DNS reverse zone
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 */
	public static boolean addDNSReversezone(SahiTasks sahiTasks, String zone, String name, String type, String data) {
		boolean created=false;
		sahiTasks.link(zone).click();
		sahiTasks.button("Add").click();
		sahiTasks.textbox("idnsname").setValue(name);
		sahiTasks.select("dns-record-type").choose(type);
		sahiTasks.textarea("record_data").setValue(data);
		sahiTasks.button("Add").click(); 
		return created;
	}//addDNSResersezone
	
	/*
	 * Add DNS zone
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 */
	public static boolean delDNSReversezone(SahiTasks sahiTasks, String zone, String name, String type, String data) {
		boolean deleted=false;
		sahiTasks.link(zone).click();
		sahiTasks.button("Add").click();
		sahiTasks.textbox("idnsname").setValue(name);
		sahiTasks.select("dns-record-type").choose(type);
		sahiTasks.textarea("record_data").setValue(data);
		sahiTasks.button("Add").click();
		return deleted;
	}//delDNSReversezone
	
	/*
	 * Modify dns zone records
	 * @param browser  
	 * @param zoneName - dna zone name
	 */
	public static boolean zoneRecordsModification(SahiTasks browser, String zoneName) {
		boolean deleted=false; 
		return deleted;
	}//zoneRecordsModification
	
	/*
	 * Modify dns zone settings
	 * @param browser  
	 * @param zoneName - dns zone name
	 */
	public static boolean zoneSettingsModification(SahiTasks browser, String zoneName) {
		boolean deleted=false; 
		return deleted;
	}//zoneSettingsModification
	
	/*
	 * Modify dns zone records
	 * @param browser  
	 * @param reverseZoneName - dna reverse zone name
	 */
	public static boolean reverseZoneRecordsModification(SahiTasks browser, String reverseZoneName) {
		boolean deleted=false; 
		return deleted;
	}//reverseZoneRecordsModification
	
	/*
	 * Modify dns zone settings
	 * @param browser  
	 * @param zoneName - dna zone name
	 */
	public static boolean reverseZoneSettingsModification(SahiTasks browser, String zoneName) {
		boolean deleted=false; 
		return deleted;
	}//reverseZoneSettingsModification
	
	
	/*
	 * Add DNS forward address for a host
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 */
	public static void addRecord(SahiTasks sahiTasks, String zone, String name, String type, String data) {
		sahiTasks.link(zone).click();
		sahiTasks.button("Add").click();
		sahiTasks.textbox("idnsname").setValue(name);
		sahiTasks.select("dns-record-type").choose(type);
		sahiTasks.textarea("record_data").setValue(data);
		sahiTasks.button("Add").click();
	}
	
	/*
	 * Add DNS forward address for a host
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 */
	public static void verifyRecord(SahiTasks sahiTasks, String zone, String name, String type, String data, String exists) {
		sahiTasks.link(zone).click();
		if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(name).exists(), "Verify record " + name + " of type " + type + " exists");
			sahiTasks.link(name).click();
			com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textbox(type).value(), data, "Verify record " + name + " has record type " + type + " with a value of " + data);
			sahiTasks.link("dnszone").in(sahiTasks.div("content")).click();
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(name).exists(), "Verify record " + name + " of type " + type + " does NOT exists");
		}		
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * Delete DNS reverse address for a host
	 * @param sahiTasks 
	 * @param ptr - ptr
	 */
	public static void deleteRecord(SahiTasks sahiTasks, String zone, String name) {
		sahiTasks.link(zone).click();
		sahiTasks.checkbox(name).click();
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content")).click();
	}
	
}// Class: DNSTasks

