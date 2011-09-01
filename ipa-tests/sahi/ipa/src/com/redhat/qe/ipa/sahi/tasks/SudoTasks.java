package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class SudoTasks {
	private static Logger log = Logger.getLogger(SudoTasks.class.getName());
	
	/*
	 * Create a new sudorule. Check if sudorule already exists before calling this.
	 * @param sahiTasks 
	 * @param cn - sudorule name
	 */
	public static void createSudorule(SahiTasks sahiTasks, String cn, String buttonToClick) {

		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.button(buttonToClick).click();

	}
	
	
	public static void createRuleWithRequiredField(SahiTasks sahiTasks,	String cn, String expectedError) {		
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.button("Add").click();
		Assert.assertTrue(sahiTasks.span(expectedError).exists(), "Verified expected error when adding invalid rule " + cn);
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}
	
	
	/**
	 * Add Sudo rule, and Add Another
	 * @param sahiTasks
	 * @param cn1 - Rule to be added
	 * @param cn2 - Next Rule to be added
	 */
	public static void addSudoRuleThenAddAnother(SahiTasks sahiTasks, String cn1, String cn2) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn1);
		sahiTasks.button("Add and Add Another").click();
		sahiTasks.textbox("cn").setValue(cn2);
		sahiTasks.button("Add").click();
	}

	/**
	 * Add and edit an Sudo Rule
	 * 
	 * @param sahiTasks
	 * @param cn - new HBACRule name
	 * @param buttonToClick - Possible values - "Add" or "Cancel"
	 */
	public static void addAndEditSudoRule(SahiTasks sahiTasks, String cn, String uid, String hostgroupName, String commandName, String runAsGroupName) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.button("Add and Edit").click();
		
		try {
			Thread.sleep(5000);
		} catch (InterruptedException e) {
			
			e.printStackTrace();
		}
		
		//Click to Add SudoOption
		sahiTasks.span("Add").under(sahiTasks.heading2("Options")).near(sahiTasks.span("Sudo Option")).click();
		sahiTasks.textbox("ipasudoopt").setValue("logfile=/var/log/sudolog");
		sahiTasks.button("Add").click();
		
		//Click to Add Users from "Who" section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Who"))).near(sahiTasks.span("Users")).click();
		sahiTasks.checkbox(uid).click();
		sahiTasks.link(">>").click();
		sahiTasks.button("Enroll").click();
		
		//Click to add Host groups from "Accessing" section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Access this host"))).near(sahiTasks.span("Host Groups")).click();
		sahiTasks.checkbox(hostgroupName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		//Click to add HBAC Service from "Via Service" Section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Run Commands"))).under(sahiTasks.heading3("Allow")).near(sahiTasks.span("Sudo Commands")).click();
		sahiTasks.checkbox(commandName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		//Click to add HBAC Service from "From" Section
		sahiTasks.span("Add").under(sahiTasks.heading2(("As Whom"))).near(sahiTasks.span("User Groups[1]")).click();
		sahiTasks.checkbox(runAsGroupName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		
		//Update and go back to HBAC Rules list
		sahiTasks.link("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();		
	}


	
	public static void verifySudoRuleUpdates(SahiTasks sahiTasks, String cn, String uid, String hostgroupName, String commandName, String runAsGroupName) {
		//click on rule to edit
		sahiTasks.link(cn).click();
		Assert.assertTrue(sahiTasks.checkbox(uid).exists(), "Verified user " + uid + " added for Rule " + cn);
		Assert.assertTrue(sahiTasks.checkbox(hostgroupName).exists(), "Verified Host Group " + hostgroupName + " added for Rule " + cn);
		Assert.assertTrue(sahiTasks.checkbox(commandName).exists(), "Verified Command " + commandName + " added for Rule " + cn);
		Assert.assertTrue(sahiTasks.checkbox(runAsGroupName).exists(), "Verified From: Host " + runAsGroupName + " added for Rule " + cn);
		
		//Also verify from other pages
		sahiTasks.link(uid).click();
		UserTasks.verifyUserMemberOf(sahiTasks, uid, "Sudo Rules", cn, "direct", "YES", true);
		sahiTasks.link(cn).click();
		sahiTasks.link(hostgroupName).click();
		HostgroupTasks.verifyMemberOf(sahiTasks, hostgroupName, "sudorule", cn, "direct", "YES", true);
		sahiTasks.link(cn).click();
		
		// FIXME: nkrishnan: Bug 735185 - MemberOf not listed for HBAC Rules (Source host/hostgroup) and Sudo Rules (RunAs user/usergroups)		
		//sahiTasks.link(runAsGroupName).click();
		//GroupTasks.verifyMemberOf(sahiTasks, runAsGroupName, "sudorules", cn, "direct", "YES", true);		
		//sahiTasks.link(cn).click();
		
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();	
	}

	
	public static void modifySudorule(SahiTasks sahiTasks, String cn, String description, String ipasudoopt) {
		
		sahiTasks.link("Sudo Rules").click();
		sahiTasks.cell(cn).click();
		sahiTasks.link(cn).click();
		sahiTasks.textarea("description").setValue(description);
		
		//Update and go back to sudo rules list 
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();
		
		// Disable Sudo rule
		sahiTasks.link("Sudo Rules").click();
		sahiTasks.link(cn).click();
		sahiTasks.radio("ipaenabledflag[1]").click();
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules[1]").click();
		sahiTasks.link(cn).click();
		
		//Re-enable sudo rule
		sahiTasks.link("Sudo Rules").click();
		sahiTasks.link(cn).click();
		sahiTasks.radio("ipaenabledflag").click();
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules[1]").click();
		sahiTasks.link(cn).click();
		
		//Add sudo command to this rule
		sahiTasks.link("Sudo Rules").click();
		sahiTasks.link(cn).click();
		sahiTasks.heading3("Allow").click();
		sahiTasks.span("Add[6]").click();
		sahiTasks.checkbox("select[21]").click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		sahiTasks.link(cn).click();
		
		//Del sudo command from this rule
		sahiTasks.link("Sudo Rules[1]").click();
		sahiTasks.link(cn).click();
		sahiTasks.checkbox("select[10]").click();
		sahiTasks.span("Delete[6]").click();
		sahiTasks.button("Delete").click();
		sahiTasks.link("Sudo Rules[1]").click();
		
		//Add sudooption to an existing sudorule and go back to sudo rules list
		sahiTasks.link(cn).click();
		sahiTasks.span("Add[1]").click();
		sahiTasks.textbox("ipasudoopt").setValue(ipasudoopt);
		sahiTasks.button("Add").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();
		
		//Del sudooption from an existing sudorule and go back to sudo rules list
		sahiTasks.link(cn).click();
		sahiTasks.checkbox(ipasudoopt).click();
		sahiTasks.span("Delete[1]").click();
		sahiTasks.button("Delete").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();
		
		//
	}

	public static void verifySudoruledescUpdates(SahiTasks sahiTasks, String cn, String description, String ipasudoopt) {
		//click on sudo rule to edit
		sahiTasks.link(cn).click();
		
		//verify sudorule's description
		com.redhat.qe.auto.testng.Assert.assertEquals(sahiTasks.textarea("description").value(), description, "Verified updated description for sudorule " + cn);
				
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();
	}
	
	public static void deleteSudorule(SahiTasks sahiTasks, String cn) {
		
		sahiTasks.link("Sudo Rules").click();
		sahiTasks.checkbox(cn).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button("Delete").click();
		
	}
	

	
	
	/*****************************************************************************************
	 *********************** 		Tasks for Sudo Commands		********************** 
	 *****************************************************************************************/
	public static void createSudoruleCommandAdd(SahiTasks sahiTasks, String cn, String description) {
		
		sahiTasks.link("Sudo Commands").click();
		sahiTasks.span("Add").click();
		sahiTasks.textbox("sudocmd").setValue(cn);
		sahiTasks.textbox("description").setValue(description);
		sahiTasks.button("Add").click();
	}
	
	public static void deleteSudoruleCommandDel(SahiTasks sahiTasks, String cn, String description) {
		
		sahiTasks.link("Sudo Commands").click();
		
		sahiTasks.checkbox(cn).click();
		sahiTasks.span("Delete[13]").click();
		sahiTasks.button("Delete").click();
	}
	
	
	/*****************************************************************************************
	 *********************** 		Tasks for Sudo Command Groups		********************** 
	 *****************************************************************************************/

	public static void createSudoruleCommandGroupAdd(SahiTasks sahiTasks, String cn, String description) {

		sahiTasks.link("Sudo Command Groups").click();
		sahiTasks.span("Add[2]").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.textbox("description").setValue(description);
		sahiTasks.button("Add").click();
				
	}
	
	public static void deleteSudoruleCommandGroupDel(SahiTasks sahiTasks, String cn, String description) {
		
		sahiTasks.link("Sudo Command Groups").click();
		sahiTasks.checkbox(cn).click();
		sahiTasks.span("Delete[2]").click();
		sahiTasks.button("Delete").click();
		
	}
}
