package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class DNSTasks {
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	/*
	 * Add DNS zone
	 * @param browser 
	 * @param zoneName
	 * @param authoritativeNameserver
	 * @param rootEmail
	 */
	public static void addDNSzone(SahiTasks browser, String zoneName, String authoritativeNameserver, String rootEmail) {
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(zoneName);
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail); 
		browser.button("Add").click();  
		// self-check
		Assert.assertTrue(browser.link(zoneName).exists(),"assert new zone in the zone list");
	}//addDNSzone
	
	/*
	 * Add DNS zone
	 * @param browser - sahi browser instance 
	 * @param zoneName - dns zone name (to be deleted) 
	 */
	public static void delDNSzone(SahiTasks browser, String zoneName) { 
		browser.checkbox(zoneName).click();
		browser.span("Delete").click();
		browser.button("Delete").click(); 
		
		// self-check
		Assert.assertFalse(browser.link(zoneName).exists(),"assert new zone not in the zone list"); 
	}//delDNSzone
	
	/*
	 * Add DNS reverse zone
	 * @param browser 
	 * @param reverseZoneName - 
	 * @param authoritativeNameserver -  authoritative nameserver
	 * @param rootEmail - email address for root
	 */
	public static void addDNSReversezone(SahiTasks browser, String reverseZoneName, String authoritativeNameserver, String rootEmail) {
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(reverseZoneName);
		browser.checkbox("name_from_ip").click();
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail); 
		browser.button("Add").click();  
//		if (browser.div("/IPA Error */").exists()){
//			browser.button("Cancel").click();
//			Assert.assertTrue(false, "ipa error occures");
//		}else if (browser.span("Required field").exists()){
//			browser.button("Cancel").click();
//			Assert.assertTrue(false, "missing required field");
//		}else{
//			Assert.assertTrue(browser.link("reverseZone").exists(), "create reverse zone success");
//		}
	}//addDNSResersezone
	
	/*
	 * Add DNS zone
	 * @param browser 
	 * @param hostname - reverse dns zone name (that to be deleted 
	 */
	public static void delDNSReversezone(SahiTasks browser, String reverseZoneName) {
		browser.checkbox(reverseZoneName).click();
		browser.span("Delete").click();
		browser.button("Delete").click(); 
	}//delDNSReversezone
	
	/*
	 * Modify dns zone records
	 * @param browser  
	 * @param zoneName - dna zone name
	 * @param record_name
	 * @param record_data
	 * @param record_type
	 */
	public static void zoneRecordsModification(SahiTasks browser,String record_name, String record_data, String record_type) {
		DNSTasks.recordsModify(browser, record_name, record_data, record_type);
	}//zoneRecordsModification
	
	/*
	 * Modify DNS zone record: A record
	 * @param browser 
	 * @param record_name
	 * @param record_data
	 * @param record_type
	 */
	public static void recordsModify(SahiTasks browser, String record_name, String record_data, String record_type){
		// assume the page is already in the dns modification page
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(record_name); 
		browser.select("record_type").choose(record_type);
		browser.textbox("record_data").setValue(record_data);
		browser.button("Add").click(); 
		if (browser.div("/IPA Error */").exists()){
			log.info("IPA error dialog appears, usually this is data format error");
			// there will be two cancel button here
			browser.button("Cancel").click();
			browser.button("Cancel").click();
			//Assert.assertTrue(false, "ipa error ( dialog )occures");
		}else if (browser.span("Required field").exists()){
			log.info ("Required field msg appears, usually this means missing data input");
			browser.button("Cancel").click();
			//Assert.assertTrue(false, "missing required field");
		}else{
			// self-check to verify the newly added record
			Assert.assertTrue(browser.link(record_name).exists(),"assert new record name: (" + record_name + ") in the list"); 
		} 
	}//zoneRecordModify
	
	/*
	 * Modify dns zone settings
	 * @param browser  
	 * @param zoneName - dns zone name
	 */
	public static void zoneSettingsModification(SahiTasks browser, String zoneName, String fieldName, String fieldValue) {

		// get into setting page
		browser.link("Settings").click();
		
		// save the original value
		String originalValue = browser.textbox(fieldName).getValue();
		
		// test for undo
		browser.textbox(fieldName).setValue(fieldValue);
		browser.span("undo").click(); 
		String undoValue = browser.textbox(fieldName).getValue();
		
		// check undo value with original value
		if (originalValue.equals(undoValue)){
			log.info("Undo works");
		}else{
			log.info("Undo failed");
			Assert.fail("Undo failed");
		}
		
		// test for reset
		browser.textbox(fieldName).setValue(fieldValue);
		browser.span("Reset").click(); 
		String resetValue = browser.textbox(fieldName).getValue();
		// check undo value with original value
		if (originalValue.equals(resetValue)){
			log.info("Reset works");
		}else{
			log.info("Reset failed");
			Assert.fail("Reset failed");
		}
		
		// test for update
		browser.textbox(fieldName).setValue(fieldValue);
		browser.span("Update").click();
		if (browser.div("error_dialog").exists()){ 
			String errormsg = browser.div("error_dialog").getText(); 
			log.info("ERROR update failed: " + errormsg);
			Assert.fail("Update failed");
			browser.button("Cancel").click(); 
			//Assert.assertTrue(false, "ipa error ( dialog )occurs");
		}else { 
			String updateValue = browser.textbox(fieldName).getValue();
			// check update value with original value
			if (fieldValue.equals(updateValue)){
				log.info("Update works, updated value matches");
			}else{
				log.info("Update failed, updated value does not match with passin value");
				Assert.fail("Update failed, passin:"+fieldValue + " actual field :"+updateValue);
			}
		}// if no error appears, it should pass
		
	}//zoneSettingsModification
	
	/*
	 * Modify dns zone records
	 * @param browser  
	 * @param reverseZoneName - dna reverse zone name
	 */
	public static void reverseZoneRecordsModification(SahiTasks browser, String reverseZoneName) {
 
	}//reverseZoneRecordsModification
	
	/*
	 * Modify dns zone settings
	 * @param browser  
	 * @param zoneName - dna zone name
	 */
	public static void reverseZoneSettingsModification(SahiTasks browser, String zoneName) {
 
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

