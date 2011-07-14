package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.thoughtworks.selenium.Wait;


public class DNSTasks {
	private static Logger log = Logger.getLogger(DNSTasks.class.getName());
	public static String frealm = "testrelm";
	public static String rrealm = "16.10.in-addr.arpa.";
	
	/*
	 * Add DNS forward address for a host
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 */
	public static void addArecord(SahiTasks sahiTasks, String hostname, String ipadr) {
		sahiTasks.link(frealm).click();
		sahiTasks.button("Add").click();
		sahiTasks.textbox(3).near(sahiTasks.label("Record name")).setValue(hostname);
		sahiTasks.select("dns-record-type").choose("A");
		sahiTasks.textarea(0).setValue(ipadr);
		sahiTasks.button("Add").click();
	}
	
	/*
	 * Add DNS reverse address for a host
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ptr -  ptr record value
	 */
	public static void addPTRrecord(SahiTasks sahiTasks, String hostname, String ptr) {
		sahiTasks.link(frealm).click();
		sahiTasks.button("Add").click();
		sahiTasks.textbox(3).near(sahiTasks.label("Record name")).setValue(hostname);
		sahiTasks.select("dns-record-type").choose("PTR");
		sahiTasks.textarea(0).setValue(ptr);
		sahiTasks.button("Add").click();
	}
	
	/*
	 * Delete DNS forward address for a host
	 * @param sahiTasks 
	 * @param hostname - hostname
	 */
	public static void deleteArecord(SahiTasks sahiTasks, String hostname ) {
		sahiTasks.link(frealm).click();
		sahiTasks.checkbox(hostname).click();
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	
	/*
	 * Delete DNS reverse address for a host
	 * @param sahiTasks 
	 * @param ptr - ptr
	 */
	public static void deletePTRrecord(SahiTasks sahiTasks, String ptr ) {
		sahiTasks.link(rrealm).click();
		sahiTasks.checkbox(ptr).click();
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	
}

