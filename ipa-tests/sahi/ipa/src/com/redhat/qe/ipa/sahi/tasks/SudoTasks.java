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
	
	public static void createInvalidRule(SahiTasks sahiTasks, String cn, String expectedError) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.button("Add").click();
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding invalid rule " + cn);
		sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
		
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
	 * @param cn - new Sudo Rule name
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
		
		//Click to add Host groups from "Access this host" section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Access this host"))).near(sahiTasks.span("Host Groups")).click();
		sahiTasks.checkbox(hostgroupName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		//Click to add Sudo Command from "Allow" Section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Run Commands"))).under(sahiTasks.heading3("Allow")).near(sahiTasks.span("Sudo Commands")).click();
		sahiTasks.checkbox(commandName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		//Click to add RunAs User from "As whom" Section
		sahiTasks.span("Add").under(sahiTasks.heading2(("As Whom"))).near(sahiTasks.span("User Groups[1]")).click();
		sahiTasks.checkbox(runAsGroupName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		
		//Update and go back to Sudo Rules list
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
		Assert.assertTrue(sahiTasks.span("Add").under(sahiTasks.heading2(("Access this host"))).near(sahiTasks.span("Host Groups")).exists(), "Now Data is visible");
		
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();
	}
	
	
	public static void modifySudoRuleGeneralSection(SahiTasks sahiTasks, String cn, String description) {
		sahiTasks.link(cn).click();
		
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.radio("ipaenabledflag[1]").click();
		
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();	
		
	}
	
	public static void verifySudoRuleGeneralSection(SahiTasks sahiTasks, String cn, String description) {
        sahiTasks.link(cn).click();
		
		Assert.assertTrue(sahiTasks.textarea("description").containsText(description), "Verified description is set correctly");
		Assert.assertTrue(sahiTasks.radio("ipaenabledflag[1]").checked(), "Verified rule is disabled");		
		
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();			
	}
	
	public static void modifySudoRuleOptionsSection(SahiTasks sahiTasks, String cn, String option1, String option2) {
		sahiTasks.link(cn).click();
		Assert.assertTrue(sahiTasks.span(option1).exists(), "Verified option to be deleted exists");
		sahiTasks.checkbox(option1).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button("Delete").click();
		
		sahiTasks.span("Add").click();
		sahiTasks.textbox("ipasudoopt").setValue(option2);
		sahiTasks.button("Add").click();
		
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();	
		
	}
	
	public static void verifySudoRuleOptionsSection(SahiTasks sahiTasks, String cn, String option1, String option2) {
        sahiTasks.link(cn).click();
		
        
        Assert.assertFalse(sahiTasks.span(option1).exists(), "Verified option was deleted successfuly");
        Assert.assertTrue(sahiTasks.span(option2).exists(), "Verified option was added successfuly");
        
        
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();			
	}

	

	/**
	 * Modify Who Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to modify for
	 */
	public static void modifySudoRuleWhoSection(SahiTasks sahiTasks, String cn, String user, String usergroup ) {
		sahiTasks.link(cn).click();
		
		sahiTasks.checkbox(user).click();	
		sahiTasks.span("Delete").under(sahiTasks.heading2(("Who"))).near(sahiTasks.span("Users")).click();
		sahiTasks.button("Delete").click();
		sahiTasks.span("Add").under(sahiTasks.heading2(("Who"))).near(sahiTasks.span("User Groups")).click();
		sahiTasks.checkbox(usergroup).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();
		
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content")).click();			
	}
	
		
	
	
	
	public static void verifySudoRuleForEnrollmentInWhoSection(SahiTasks sahiTasks, CommonTasks commonTasks, String cn, String member, 
			String memberType, String type, boolean isMember) {
		sahiTasks.link(cn).click();
		
		if (sahiTasks.link(member).exists()) {
			sahiTasks.link(member).click();
			CommonTasks.verifyMemberOf(sahiTasks, member, memberType, "Sudo Rules", cn, type, isMember);			
		}
		else {
			if (memberType.equals("Users"))
				sahiTasks.navigateTo(commonTasks.userPage);
			else
				sahiTasks.navigateTo(commonTasks.groupPage);
			sahiTasks.link(member).click();
			CommonTasks.verifyMemberOf(sahiTasks, member, memberType, "Sudo Rules", cn, type, isMember);
		}
	}
	
	/*
	 * Choose multiple rules. 
	 * @param sahiTasks
	 * @param cn -  cn of the rule to be deleted
	 */
	public static void chooseMultiple(SahiTasks sahiTasks, String[] cns) {		
		for (String cn : cns) {
			sahiTasks.checkbox(cn).click();		
		}		
	}
	
	/*
	 * Delete multiple rules. 
	 * @param sahiTasks
	 */
	public static void deleteMultiple(SahiTasks sahiTasks) {		
		sahiTasks.link("Delete").click();
		sahiTasks.button("Delete").click();
	}
	
	
	
	
	/**
	 * Delete an Sudo Rule
	 * @param sahiTasks
	 * @param cn - the rule to be deleted
	 * @param buttonToClick - Possible values - "Delete" or "Cancel"
	 */
	public static void deleteSudo(SahiTasks sahiTasks, String cn, String buttonToClick) {
		sahiTasks.checkbox(cn).click();
		sahiTasks.link("Delete").click();
		sahiTasks.button(buttonToClick).click();
		
		
		if (buttonToClick.equals("Cancel")) {
			sahiTasks.checkbox(cn).click();
		}
	}


	
	
	/*****************************************************************************************
	 *********************** 		Tasks for Sudo Commands		********************** 
	 *****************************************************************************************/
	public static void createSudoruleCommandAdd(SahiTasks sahiTasks, String cn, String description) {
		
		sahiTasks.link("Sudo Commands").click();
		sahiTasks.span("Add").click();
		sahiTasks.textbox("sudocmd").setValue(cn);
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
