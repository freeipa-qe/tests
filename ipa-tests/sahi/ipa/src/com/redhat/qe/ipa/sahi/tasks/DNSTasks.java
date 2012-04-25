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
//			Assert.assertTrue(false, "ipa error occurs");
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
	 * Modify DNS zone record: Add one record
	 * @param browser 
	 * @param record_name
	 * @param record_data
	 * @param record_type
	 */
	public static void zoneRecords_add(SahiTasks browser, String record_name, String record_data, String record_type){
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
			//Assert.assertTrue(false, "ipa error ( dialog )occurs");
		}else if (browser.span("Required field").exists()){
			log.info ("Required field msg appears, usually this means missing data input");
			browser.button("Cancel").click();
			//Assert.assertTrue(false, "missing required field");
		}else{
			// self-check to verify the newly added record
			Assert.assertTrue(browser.link(record_name).exists(),"ensure new record name: (" + record_name + ") in the list");
			// delete the newly created record
			browser.checkbox(record_name).click();
			browser.link("Delete").click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.link(record_name).exists(),"delete newly created record: (" + record_name + ")"); 
		} 
	}//zoneRecords_add
	
	/*
	 * Modify DNS zone record : "Add and Add another"
	 * @param browser 
	 * @param record_name
	 * @param record_data
	 * @param record_type
	 */
	public static void zoneRecords_addandaddanother(SahiTasks browser, 
													String first_record_name, String first_record_data, String first_record_type,
													String second_record_name, String second_record_data, String second_record_type){
		// assume the page is already in the dns modification page
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(first_record_name); 
		browser.select("record_type").choose(first_record_type);
		browser.textbox("record_data").setValue(first_record_data);
		browser.button("Add and Add Another").click(); 
		
		// after click this button, we should stay in the same dialog box. so we can continue add the second one. 
		browser.textbox("idnsname").setValue(second_record_name); 
		browser.select("record_type").choose(second_record_type);
		browser.textbox("record_data").setValue(second_record_data);
		browser.button("Add and Add Another").click();
		
		// after click the same button the second time, we shouls still stay in the same dialog, we can now "cancel" it
		browser.button("Cancel").click();
		
		if (browser.div("/IPA Error */").exists()){
			log.info("IPA error dialog appears, usually this is data format error");
			// there will be two cancel button here
			browser.button("Cancel").click();
			browser.button("Cancel").click();
			//Assert.assertTrue(false, "ipa error ( dialog )occurs");
		}else if (browser.span("Required field").exists()){
			log.info ("Required field msg appears, usually this means missing data input");
			browser.button("Cancel").click();
			//Assert.assertTrue(false, "missing required field");
		}else{
			// self-check to verify the newly added record
			if  (browser.link(first_record_name).exists()){
				log.info("new record name: (" + first_record_name + ") found in the list");  
				//delete this record
				browser.checkbox(first_record_name).click();
				browser.link("Delete").click();
				browser.button("Delete").click();
				Assert.assertFalse(browser.link(first_record_name).exists(),"assert new record name: (" + second_record_name + ") in the list"); 

			}else{
				Assert.fail("new record name: (" + first_record_name + ") NOT found in the list"); 
			}
			if (browser.link(second_record_name).exists()){
				log.info("assert new record name: (" + second_record_name + ") in the list");
				//delete this record 
				browser.checkbox(second_record_name).click();
				browser.link("Delete").click();
				browser.button("Delete").click(); 
				Assert.assertFalse(browser.link(second_record_name).exists(),"assert new record name: (" + second_record_name + ") in the list"); 
			}else{
				Assert.fail("new record name: (" + second_record_name + ") NOT found in the list"); 
			}  
		}//if no error detected  
	}//zoneRecords_addandaddanother
	
	/*
	 * Modify DNS zone record: Add one record and switch to Edit mode
	 * @param browser 
	 * @param record_name
	 * @param record_data
	 * @param record_type
	 */
	public static void zoneRecords_addandedit(SahiTasks browser, String record_name, String record_data, String record_type){
		// assume the page is already in the dns modification page
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(record_name); 
		browser.select("record_type").choose(record_type);
		browser.textbox("record_data").setValue(record_data);
		browser.button("Add and Edit").click();  
		
		//we are now suppose to be in detail editing page
		if (browser.heading3("DNS Resource Record: " + record_data).exists()){
			log.info("verified: we are in record detail editing mode");
			// go back to zone record list
			browser.link("dnszone").click();
			// self-check to verify the newly added record
			Assert.assertTrue(browser.link(record_name).exists(),"ensure new record name: (" + record_name + ") in the list");
			// delete the newly created record
			browser.checkbox(record_name).click();
			browser.link("Delete").click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.link(record_name).exists(),"delete newly created record: (" + record_name + ")");
		
		}
		
		//Notes from yi zhang: we don't care about how this record is being edited, as long as we are in the right place.
		// 						verifying the functionality of this page would be another test case. 
	
	}//zoneRecords_addandedit
	
	/*
	 * Modify DNS zone record: Add one record and switch to Edit mode
	 * @param browser 
	 * @param record_name
	 * @param record_data
	 * @param record_type
	 */
	public static void zoneRecords_add_then_cancel(SahiTasks browser, String record_name, String record_data, String record_type){
		// assume the page is already in the dns modification page
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(record_name); 
		browser.select("record_type").choose(record_type);
		browser.textbox("record_data").setValue(record_data);
		browser.button("Cancel").click();   
		Assert.assertFalse(browser.link(record_data).exists(),"make sure the data does not get into ipa server");  
	
	}//zoneRecords_add_then_cancel
	
	
	/*
	 * Modify dns zone settings
	 * @param browser  
	 * @param zoneName - dns zone name
	 * @param fieldName - dns setting field type name 
	 * @param fieldValue - dns setting field value
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
	// mvarun : updated verifyRecord task because it is used in Hosts tests(hostAddDNSTest)
	
	
	public static void verifyRecord(SahiTasks sahiTasks, String zone, String name, String recordtype, String data, String exists) {
        sahiTasks.link(zone).click();
        if (exists == "YES")
        {
            com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(name).exists(), "Verify record " + name + " of type " + recordtype + " exists");
            sahiTasks.link(name).click();
            Assert.assertTrue(sahiTasks.checkbox(data).near(sahiTasks.label(recordtype + ":")).exists(),  "Verify record " + name + " has record type " + recordtype + " with a value of " + data);
        }
        else
        {
            com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(name).exists(), "Verify record " + name + " of type " + recordtype + " does NOT exists");
        }       
        sahiTasks.link("DNS Zones").in(sahiTasks.div("content")).click();
    }
	
	
	
	/*
	 * Delete DNS reverse address for a host
	 * @param sahiTasks 
	 * @param ptr - ptr
	 */
	public static void deleteRecord(SahiTasks browser, String zone, String name) {
		browser.link(zone).click();
		browser.checkbox(name).click();
		browser.link("Delete").click();
		browser.button("Delete").click();
		browser.link("DNS Zones").in(browser.div("content")).click();
	}
	
}// Class: DNSTasks

