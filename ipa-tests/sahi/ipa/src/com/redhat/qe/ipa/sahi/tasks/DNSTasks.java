package com.redhat.qe.ipa.sahi.tasks;

import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class DNSTasks {

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
	}
	
}

