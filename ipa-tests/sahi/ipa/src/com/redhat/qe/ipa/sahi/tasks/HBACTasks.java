package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;

/**
 * @author root
 *
 */
public class HBACTasks {
	private static Logger log = Logger.getLogger(HBACTasks.class.getName());
	
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
	public static void chooseMultipleRules(SahiTasks sahiTasks, String[] cns) {		
		for (String cn : cns) {
			sahiTasks.checkbox(cn).click();		
		}		
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
	 * Delete an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to be deleted
	 * @param buttonToClick - Possible values - "Delete" or "Cancel"
	 */
	public static void deleteHBACRule(SahiTasks sahiTasks, String cn, String buttonToClick) {
		sahiTasks.checkbox(cn).click();
		sahiTasks.link("Delete").click();
		sahiTasks.button(buttonToClick).click();
		
		
		if (buttonToClick.equals("Cancel")) {
			//Uncheck the box for this Rule
			sahiTasks.checkbox(cn).click();
		}
	}

	/**
	 * Add and edit an HBAC Rule
	 * 
	 * @param sahiTasks
	 * @param cn - new HBACRule name
	 * @param buttonToClick - Possible values - "Add" or "Cancel"
	 */
	public static void addAndEditHBACRule(SahiTasks sahiTasks, String cn, String uid, String hostgroupName, String service, String fqdn) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.button("Add and Edit").click();
		
		try {
			Thread.sleep(5000);
		} catch (InterruptedException e) {
			
			e.printStackTrace();
		}
		//Click to Add Users from "Who" section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Who"))).near(sahiTasks.span("Users")).click();
		sahiTasks.checkbox(uid).click();
		sahiTasks.link(">>").click();
		sahiTasks.button("Enroll").click();
		
		//Click to add Host groups from "Accessing" section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Accessing"))).near(sahiTasks.span("Host Groups")).click();
		sahiTasks.checkbox(hostgroupName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		//Click to add HBAC Service from "Via Service" Section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Via Service"))).near(sahiTasks.span("HBAC Services")).click();
		sahiTasks.checkbox(service).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		//Click to add HBAC Service from "From" Section
		sahiTasks.span("Add").under(sahiTasks.heading2(("From"))).near(sahiTasks.span("Hosts")).click();
		sahiTasks.checkbox(fqdn).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		
		//Update and go back to HBAC Rules list
		sahiTasks.link("Update").click();
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();		
	}


	/**
	 * Add HBAC rule, and Add Another
	 * @param sahiTasks
	 * @param cn1 - Rule to be added
	 * @param cn2 - Next Rule to be added
	 */
	public static void addHBACRuleThenAddAnother(SahiTasks sahiTasks, String cn1, String cn2) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn1);
		sahiTasks.button("Add and Add Another").click();
		sahiTasks.textbox("cn").setValue(cn2);
		sahiTasks.button("Add").click();
	}
	
	public static void verifyHBACRuleUpdates(SahiTasks sahiTasks, String cn, String uid, String hostgroupName, String service, String fqdn) {
		//click on rule to edit
		sahiTasks.link(cn).click();
		String currentPageNow = sahiTasks.fetch("top.location.href");
		Assert.assertTrue(sahiTasks.checkbox(uid).exists(), "Verified user " + uid + " added for Rule " + cn);
		Assert.assertTrue(sahiTasks.checkbox(hostgroupName).exists(), "Verified Host Group " + hostgroupName + " added for Rule " + cn);
		Assert.assertTrue(sahiTasks.checkbox(service).exists(), "Verified Service " + service + " added for Rule " + cn);
		Assert.assertTrue(sahiTasks.checkbox(fqdn).exists(), "Verified From: Host " + fqdn + " added for Rule " + cn);
		
		//Also verify from other pages
		sahiTasks.link(uid).click();
		UserTasks.verifyUserMemberOf(sahiTasks, uid, "HBAC Rules", cn, "direct", "YES", true);
		sahiTasks.link(cn).click();
		sahiTasks.link(hostgroupName).click();
		HostgroupTasks.verifyMemberOf(sahiTasks, hostgroupName, "hbacrule", cn, "direct", "YES", true);
		sahiTasks.link(cn).click();
		sahiTasks.link(fqdn).click();
		HostTasks.verifyHostMemberOf(sahiTasks, fqdn, "HBAC Rules", cn, "indirect", "YES", true);		
		sahiTasks.link(cn).click();
		
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();	
	}




	/**
	 * Modify General Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to modify for
	 */
	public static void modifyHBACRuleGeneralSection(SahiTasks sahiTasks, String cn, String description) {
		sahiTasks.link(cn).click();
		
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.radio("ipaenabledflag[1]").click();
		
		sahiTasks.span("Update").click();
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();	
		
	}
	
	/**
	 * Verify General Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to verify
	 */
	public static void verifyHBACRuleGeneralSection(SahiTasks sahiTasks, String cn, String description) {
		sahiTasks.link(cn).click();
		
		Assert.assertTrue(sahiTasks.textarea("description").containsText(description), "Verified description is set correctly");
		Assert.assertTrue(sahiTasks.radio("ipaenabledflag[1]").checked(), "Verified rule is disabled");		
		
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();			
	}

	/**
	 * Modify Who Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to modify for
	 */
	public static void modifyHBACRuleWhoSection(SahiTasks sahiTasks, String cn, String user, String usergroup ) {
		sahiTasks.link(cn).click();
		
		sahiTasks.checkbox(user).click();
		sahiTasks.span("Add").under(sahiTasks.heading2(("Who"))).near(sahiTasks.span("Users")).click();
		sahiTasks.checkbox("hidememb").click();
		sahiTasks.link("Find").click();
		//FIXME: Bug 729665
		//Assert.assertFalse(sahiTasks.checkbox(user).exists(), "Enrolled user not listed");
		sahiTasks.button("Cancel").click();		
		sahiTasks.span("Delete").click();
		sahiTasks.button("Delete").click();
		sahiTasks.span("Add").under(sahiTasks.heading2(("Who"))).near(sahiTasks.span("User Groups")).click();
		sahiTasks.checkbox(usergroup).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		sahiTasks.span("Update").click();
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();			
	}
	
		
	/**
	 * Verify Who Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to verify
	 */
	public static void verifyHBACRuleWhoSection(SahiTasks sahiTasks, String cn, String user, String usergroup) {
		sahiTasks.link(cn).click();
		
		Assert.assertFalse(sahiTasks.checkbox(user).exists(), "Verified user: " + user + " not on list for rule: " + cn);
		Assert.assertTrue(sahiTasks.checkbox(usergroup).exists(), "Verified usergroup: " + usergroup + " is on list for rule: " + cn);
		
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();	
	}
	
	/**
	 * Modify Accessing Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to modify for
	 */
	public static void modifyHBACRuleAccessingSection(SahiTasks sahiTasks, String cn, String fqdn, String hostgroupname ) {
		sahiTasks.link(cn).click();
		
		sahiTasks.radio("hostcategory").click();
		sahiTasks.span("undo").click();

		sahiTasks.span("Add").under(sahiTasks.heading2(("Accessing"))).near(sahiTasks.span("Hosts")).click();
		
		//TODO: nkrishnan - should the suffix be used? Currently - there is a host added in the From Section, 
		// and so the suffix is needed here in the Accessing section
		sahiTasks.checkbox(fqdn).under(sahiTasks.heading2(("Accessing"))).under(sahiTasks.span("Hosts")).click(); 		
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		sahiTasks.span("Add").under(sahiTasks.heading2(("Accessing"))).near(sahiTasks.span("Host Groups")).click();
		sahiTasks.checkbox("hidememb").click();
		sahiTasks.link("Find").click();
		//FIXME: Bug 729665
		//Assert.assertFalse(sahiTasks.checkbox(hostgroupname).exists(), "Enrolled host group not listed");
		sahiTasks.button("Cancel").click();
		
		sahiTasks.checkbox(hostgroupname).click();
		sahiTasks.span("Delete").under(sahiTasks.heading2(("Accessing"))).near(sahiTasks.span("Host Groups")).click();
		sahiTasks.button("Delete").click();
		
		
		sahiTasks.span("Update").click();
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();			
		
	}
	
	/**
	 * Verify Accessing Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to verify
	 */
	public static void verifyHBACRuleAccessingSection(SahiTasks sahiTasks, String cn, String fqdn, String hostgroupname) {
		sahiTasks.link(cn).click();
		
		Assert.assertTrue(sahiTasks.checkbox(fqdn).under(sahiTasks.heading2(("Accessing"))).near(sahiTasks.span("Hosts")).exists(), "Verified Host: " + fqdn + " is on list for rule: " + cn);
		Assert.assertFalse(sahiTasks.checkbox(hostgroupname).under(sahiTasks.heading2(("Accessing"))).near(sahiTasks.span("Host Groups")).exists(), "Verified Host Group: " + hostgroupname + " is not on list for rule: " + cn);
				
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();			
	}

	


	/**
	 * Modify From Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to modify for
	 */
	public static void modifyHBACRuleFromSection(SahiTasks sahiTasks, String cn, String fqdn, String hostgroupname ) {
		sahiTasks.link(cn).click();
		
		
		String filterBy = "hbac";
		
		sahiTasks.span("Add").under(sahiTasks.heading2(("From"))).near(sahiTasks.span("Host Groups")).click();
		sahiTasks.textbox("filter").setValue(filterBy);
		sahiTasks.span("Find").click();
		Assert.assertTrue(sahiTasks.checkbox(hostgroupname).exists(), "Found Host Group - " + hostgroupname);
		sahiTasks.checkbox(hostgroupname).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		
		sahiTasks.span("Add").under(sahiTasks.heading2(("From"))).near(sahiTasks.span("Hosts")).click();
		sahiTasks.checkbox("hidememb").click();
		sahiTasks.link("Find").click();
		//FIXME: Bug 729665
		//Assert.assertFalse(sahiTasks.checkbox(fqdn).exists(), "Enrolled host not listed");
		sahiTasks.button("Cancel").click();
		
		sahiTasks.checkbox(fqdn).under(sahiTasks.heading2(("From"))).near(sahiTasks.span("Hosts")).click();
		sahiTasks.span("Delete").under(sahiTasks.heading2(("From"))).near(sahiTasks.span("Hosts")).click();
		sahiTasks.button("Delete").click();
	
		sahiTasks.span("Update").click();
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();			
		
	}
	
	/**
	 * Verify From Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to verify
	 */
	public static void verifyHBACRuleFromSection(SahiTasks sahiTasks, String cn, String fqdn, String hostgroupname) {
		sahiTasks.link(cn).click();
		
		Assert.assertFalse(sahiTasks.checkbox(fqdn).under(sahiTasks.heading2(("From"))).near(sahiTasks.span("Hosts")).exists(), "Verified Host: " + fqdn + " is not on list for rule: " + cn);
		Assert.assertTrue(sahiTasks.checkbox(hostgroupname).under(sahiTasks.heading2(("From"))).under(sahiTasks.span("Hosts")).exists(), "Verified Host Group: " + hostgroupname + " is on list for rule: " + cn);
				
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();			
	}



	/**
	 * Modify Via Service Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to modify for
	 */
	public static void modifyHBACRuleViaServiceSection(SahiTasks sahiTasks, String cn, String searchString, String[] searchResult) {
		sahiTasks.link(cn).click();
		
		sahiTasks.span("Add").under(sahiTasks.heading2(("Via Service"))).near(sahiTasks.span("HBAC Services")).click();
		sahiTasks.textbox("filter").setValue(searchString);
		sahiTasks.link("Find").click();
		
		for (String result : searchResult) {
			Assert.assertTrue(sahiTasks.checkbox(result).exists(), "Verified Find results include " + result);		
			sahiTasks.checkbox(result).click();
		}		
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		sahiTasks.span("Add").under(sahiTasks.heading2(("Via Service"))).near(sahiTasks.span("HBAC Service Groups")).click();
		sahiTasks.checkbox("Sudo").click();
		sahiTasks.link(">>").click();
		sahiTasks.button("Enroll").click();
		
		sahiTasks.span("Update").click();
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();				
	}
	
	/**
	 * Verify Via Service Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to verify
	 */
	public static void verifyHBACRuleViaServiceSection(SahiTasks sahiTasks, String cn, String[] searchResult) {
		sahiTasks.link(cn).click();
		
		for (String result : searchResult) {
			Assert.assertTrue(sahiTasks.checkbox(result).exists(), "Verified Service " + result + " is enabled for rule " + cn);		
		}
		Assert.assertTrue(sahiTasks.checkbox("sudo").exists(), "Verified Service Group Sudo is enabled for rule " + cn);
		
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();	
	}




	/**
	 * Verify changes are reset or undone
	 * @param sahiTasks
	 * @param cn
	 */
	public static void resetUndoHBACRuleSections(SahiTasks sahiTasks, String cn) {
		sahiTasks.link(cn).click();
		
		String originalDescription = sahiTasks.textarea("description").getValue();
		String newDescription = "This description will be reset";		
		sahiTasks.textarea("description").setValue(newDescription);		
		sahiTasks.radio("usercategory").click();
		
		// TODO: nkrishnan - how to check Add/Delete are disabled when "all" is selected
		
		sahiTasks.span("Reset").click();
	
		Assert.assertEquals(sahiTasks.textarea("description").getText(), originalDescription, "Changes to Description are Reset");
		Assert.assertTrue(sahiTasks.radio("usercategory[1]").checked(), "Changes to UserCategory are Reset");
		
		sahiTasks.textarea("description").setValue("will undo this desc from here");
		sahiTasks.span("undo").click();
		Assert.assertEquals(sahiTasks.textarea("description").getText(), originalDescription, "Changes to Description are Undone");
		
		sahiTasks.radio("hostcategory").click();
		sahiTasks.span("undo").click();
		Assert.assertTrue(sahiTasks.radio("hostcategory[1]").checked(), "Changes to HostCategory are Undone");
		
		sahiTasks.radio("servicecategory").click();

		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();
		sahiTasks.button("Reset").click();
		
	}
	
	public static void expandCollapseRule(SahiTasks sahiTasks, String cn) {
		sahiTasks.link(cn).click();
		
		sahiTasks.span("Collapse All").click();
		sahiTasks.waitFor(1000);

		//Verify no data is visible
		Assert.assertFalse(sahiTasks.textarea("description").exists(), "No data is visible");
		
		
		sahiTasks.heading2("Who").click();
		//Verify only data for account settings is displayed
		Assert.assertTrue(sahiTasks.span("Users").exists(), "Verified data available for Rule " + cn);
		
		
		sahiTasks.span("Expand All").click();
		sahiTasks.waitFor(1000);
		//Verify data is visible
		Assert.assertTrue(sahiTasks.span("Add").under(sahiTasks.heading2(("From"))).near(sahiTasks.span("Host Groups")).exists(), "Now Data is visible");
		
		sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();
	}
	
}
