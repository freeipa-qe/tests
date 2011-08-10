package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

public class HBACTasks {
	private static Logger log = Logger.getLogger(HBACTasks.class.getName());
	
	/*
	 * Verify user, user group, host, host group do not exist
	 */
	public static void checkIfObjectsReqdByTestExist(SahiTasks sahiTasks, String uid, String groupName, String fqdn, String hostgroupName) {
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.userPage, true);
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(uid).exists(), "Verify User " + uid + " doesn't already exist");
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.groupPage, true);
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify Group " + groupName + " doesn't already exist");
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostPage, true);
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(fqdn.toLowerCase()).exists(), "Verify host " + fqdn + " doesn't already exist");
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+ CommonTasks.hostgroupPage, true);
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(hostgroupName).exists(), "Verify Hostgroup " + hostgroupName + " doesn't already exist");		
	}
	

	
	
	/**
	 * Add an HBAC Rule
	 * 
	 * @param sahiTasks
	 * @param cn - new HBACRule name
	 * @param buttonToClick - Possible values - "Add" or "Cancel"
	 */
	public static void addHBACRule(SahiTasks sahiTasks, String cn, String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.button(buttonToClick).click();
	}
	
	/*
	 * Choose multiple rules. 
	 * @param sahiTasks
	 * @param cn -  cn of the rule to be deleted
	 */
	public static void chooseMultipleRules(SahiTasks sahiTasks, String cn) {		
		sahiTasks.checkbox(cn).click();		
	}
	
	/*
	 * Delete multiple rules. 
	 * @param sahiTasks
	 */
	public static void deleteMultipleRules(SahiTasks sahiTasks) {		
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	
	

	/**
	 * Add and edit an HBAC Rule
	 * 
	 * @param sahiTasks
	 * @param cn - new HBACRule name
	 * @param buttonToClick - Possible values - "Add" or "Cancel"
	 */
	public static void addAndEditHBACRule(SahiTasks sahiTasks, String cn, String uid, String hostgroupName, String service) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.button("Add and Edit").click();
		
		//Click to Add Users from "Who" section
		sahiTasks.span("Add").click();
		sahiTasks.checkbox(uid).click();
		sahiTasks.link(">>").click();
		sahiTasks.button("Enroll").click();
		
		//Click to add Host groups from "Accessing" section
		sahiTasks.span("Add[3]").click();
		sahiTasks.checkbox(hostgroupName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		//Click to add HBAC Service from "Via Service" Section
		sahiTasks.span("Add[4]").click();
		sahiTasks.checkbox(service).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		
		//Update and go back to HBAC Rules list
		sahiTasks.link("Update").click();
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();		
	}
	
	
	public static void verifyHBACRuleUpdates(SahiTasks sahiTasks, String cn, String uid, String hostgroupName, String service) {
		//click on rule to edit
		sahiTasks.link(cn).click();
		
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.checkbox(uid).exists(), "Verified user added for Rule " + cn);
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.checkbox(hostgroupName).exists(), "Verified Host Group  added for Rule " + cn);
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.checkbox(service).exists(), "Verified Service  added for Rule " + cn);
		
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();	
	}
	
	
	
	
}
