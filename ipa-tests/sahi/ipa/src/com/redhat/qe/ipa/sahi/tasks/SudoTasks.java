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
	public static void createSudoRule(SahiTasks sahiTasks, String cn, String buttonToClick) {

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
	
	public static void createWithRequiredFieldMissing(SahiTasks sahiTasks,	String cn, String object, String expectedError) {		
		sahiTasks.span("Add").click();
		sahiTasks.textbox(object).setValue(cn);
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
	public static void addSudoThenAddAnother(SahiTasks sahiTasks, String cn1, String cn2) {
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
	public static void addAndEditSudoRule(SahiTasks sahiTasks, String cn, String uid, String hostgroupName, String commandName, String commandGroupName, String runAsGroupName) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.button("Add and Edit").click();
		
		try {
			Thread.sleep(5000);
		} catch (InterruptedException e) {
			
			e.printStackTrace();
		}
		
		//Click to Add SudoOption
		sahiTasks.span("Add").under(sahiTasks.heading2("Options")).near(sahiTasks.div("Sudo Option")).click();
		sahiTasks.textbox("ipasudoopt").setValue("logfile=/var/log/sudolog");
		sahiTasks.button("Add").click();
		
		//Click to Add Users from "Who" section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Who"))).near(sahiTasks.div("Users")).click();
		sahiTasks.checkbox(uid).click();
		sahiTasks.link(">>").click();
		sahiTasks.button("Add").click();
		
		//Click to add Host groups from "Access this host" section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Access this host"))).near(sahiTasks.div("Host Groups")).click();
		sahiTasks.checkbox(hostgroupName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Add").click();
		
		//Click to add Sudo Command from "Allow" Section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Run Commands"))).under(sahiTasks.heading3("Allow")).near(sahiTasks.div("Sudo Allow Commands")).click();
		sahiTasks.checkbox(commandName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Add").click();
		
		//Click to add Sudo Command Group From from "Deny" Section
		sahiTasks.span("Add").under(sahiTasks.heading2(("Run Commands"))).under(sahiTasks.heading3("Deny")).near(sahiTasks.div("Sudo Deny Command Groups")).click();
		sahiTasks.checkbox(commandGroupName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Add").click();
		
		//Click to add RunAs User from "As whom" Section
		sahiTasks.span("Add").under(sahiTasks.heading2(("As Whom"))).near(sahiTasks.div("RunAs Groups")).click();
		sahiTasks.checkbox(runAsGroupName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Add").click();
		
		
		//Update and go back to Sudo Rules list
		sahiTasks.link("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();
		sahiTasks.span("Refresh").click();
	}


	
	public static void verifySudoRuleUpdates(SahiTasks sahiTasks, String cn, String uid, String hostgroupName, String commandName, String commandGroupName, String runAsGroupName) {
		//click on rule to edit
		sahiTasks.link(cn).click();
		Assert.assertTrue(sahiTasks.checkbox(uid).exists(), "Verified user " + uid + " added for Rule " + cn);
		Assert.assertTrue(sahiTasks.checkbox(hostgroupName).exists(), "Verified Host Group " + hostgroupName + " added for Rule " + cn);
		Assert.assertTrue(sahiTasks.checkbox(commandName).exists(), "Verified Command " + commandName + " added for Rule " + cn);
		Assert.assertTrue(sahiTasks.checkbox(commandGroupName).exists(), "Verified Command Group" + commandGroupName + " added for Rule " + cn);
		Assert.assertTrue(sahiTasks.checkbox(runAsGroupName).exists(), "Verified From: Host " + runAsGroupName + " added for Rule " + cn);
		
		//Also verify from other pages
		sahiTasks.link(uid).click();
		UserTasks.verifyUserMemberOf(sahiTasks, uid, "Sudo Rules", cn, "direct", "YES", true);
		sahiTasks.link(cn).click();
		sahiTasks.link(hostgroupName).click();
		HostgroupTasks.verifyMemberOf(sahiTasks, hostgroupName, "sudorule", cn, "direct", "YES", true);
		sahiTasks.link(cn).click();
		
		// FIXME: nkrishnan: Bug 735185 - MemberOf not listed for HBAC Rules (Source host/hostgroup) and Sudo Rules (RunAs user/usergroups)		
		// not uncommenting, since flow depends on this test passing
		//sahiTasks.link(runAsGroupName).click();
		//GroupTasks.verifyMemberOf(sahiTasks, runAsGroupName, "sudorules", cn, "direct", "YES", true);		
		//sahiTasks.link(cn).click();
		
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();	
	}

	
	public static void expandCollapseRule(SahiTasks sahiTasks, String cn) {
		sahiTasks.link(cn).click();
		
		sahiTasks.span("Collapse All").click();
		sahiTasks.waitFor(1000);

		//Verify no data is visible
		Assert.assertFalse(sahiTasks.textarea("description").exists(), "No data is visible");
		
		
		sahiTasks.heading2("Who").click();
		//Verify only data for account settings is displayed
		Assert.assertTrue(sahiTasks.div("Users").exists(), "Verified data available for Rule " + cn);
		
		
		sahiTasks.span("Expand All").click();
		sahiTasks.waitFor(1000);
		//Verify data is visible
		Assert.assertTrue(sahiTasks.span("Add").under(sahiTasks.heading2(("Access this host"))).near(sahiTasks.div("Host Groups")).exists(), "Now Data is visible");
		
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	
	public static void modifySudoRuleGeneralSection(SahiTasks sahiTasks, String cn, String description) {
		sahiTasks.link(cn).click();
		
		sahiTasks.select("action").choose("Disable");
		sahiTasks.span("Apply").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();
		//sahiTasks.link("Sudo Rules[1]").click();
		Assert.assertTrue(sahiTasks.div("Disabled").exists(),"Varify Sudo rule is disabled sucessfully");
		sahiTasks.link("SudoRule6").click();
		sahiTasks.select("action").choose("Enable");
		sahiTasks.span("Apply").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();
		//sahiTasks.link("Sudo Rules[1]").click();
		Assert.assertTrue(sahiTasks.div("Enabled").exists(),"Varify Sudo rule is enabled sucessfully");
		sahiTasks.link("SudoRule6").click();
		sahiTasks.select("action").choose("Delete");
		sahiTasks.span("Apply").click();
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify Rule " + cn + " deleted successfully");
		
		
		
		
		
			
		
	}
	
	public static void verifySudoRuleGeneralSection(SahiTasks sahiTasks, String cn, String description) {
        sahiTasks.link(cn).click();
		
		Assert.assertTrue(sahiTasks.textarea("description").containsText(description), "Verified description is set correctly");
		Assert.assertTrue(sahiTasks.radio("ipaenabledflag-1-1").checked(), "Verified rule is disabled");		
		
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();			
	}
	
	public static void modifySudoRuleOptionsSection(SahiTasks sahiTasks, String cn, String option1, String option2) {
		sahiTasks.link(cn).click();
		Assert.assertTrue(sahiTasks.div(option1).exists(), "Verified option to be deleted exists");
		sahiTasks.checkbox(option1).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button("Delete").click();
		
		sahiTasks.span("Add").click();
		sahiTasks.textbox("ipasudoopt").setValue(option2);
		sahiTasks.button("Cancel").click();
		Assert.assertFalse(sahiTasks.span(option2).exists(), "Verified option was cancelled when adding");
		
		sahiTasks.span("Add").click();
		sahiTasks.textbox("ipasudoopt").setValue(option2);
		sahiTasks.button("Add").click();
		
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();	
		
	}
	
	public static void verifySudoRuleOptionsSection(SahiTasks sahiTasks, String cn, String option1, String option2) {
        sahiTasks.link(cn).click();
		
        
        Assert.assertFalse(sahiTasks.span(option1).exists(), "Verified option was deleted successfuly");
        Assert.assertTrue(sahiTasks.div(option2).exists(), "Verified option was added successfuly");
        
        
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();			
	}

	

	/**
	 * Modify Who Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to modify for
	 */
	public static void modifySudoRuleUserCategorySection(SahiTasks sahiTasks, String cn, String user, String usergroup ) {
		sahiTasks.link(cn).click();
		
		deleteFromSudoRule(sahiTasks, cn,  "Who", "Users", user, "Delete");		
		addToSudoRule(sahiTasks, cn, "Who", "User Groups", usergroup, "Add");			
		
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();			
	}
	
	
	
	
	public static void verifySudoRuleForEnrollment(SahiTasks sahiTasks, CommonTasks commonTasks, String cn, String member, 
			String memberType, String type, boolean isMember) {
		sahiTasks.link(cn).click();
		
		if (sahiTasks.link(member).exists()) {
			sahiTasks.link(member).click();	
			CommonTasks.verifyMemberOf(sahiTasks, member, memberType, "Sudo Rules", cn, type, isMember);			
		}
		else {
			if (memberType.equals("Users"))
				sahiTasks.navigateTo(commonTasks.userPage);
			if (memberType.equals("User Groups"))
				sahiTasks.navigateTo(commonTasks.groupPage);
			if (memberType.equals("Hosts"))
				sahiTasks.navigateTo(commonTasks.hostPage);
			if (memberType.equals("Host Groups"))
				sahiTasks.navigateTo(commonTasks.hostgroupPage);
			sahiTasks.link(member).click();
			CommonTasks.verifyMemberOf(sahiTasks, member, memberType, "Sudo Rules", cn, type, isMember);
		}
	}
	
	/*
	 * modify to add external user and host
	 */
	public static void modifySudoRuleExternalUserHostSetting(SahiTasks sahiTasks, String cn, String externalUser, String externalHost ) {
		sahiTasks.link(cn).click();
		
		sahiTasks.span("Add").under(sahiTasks.heading2(("Who"))).near(sahiTasks.div("Users")).click();
		sahiTasks.textbox("external").setValue(externalUser);
		//System.exit(0);
		sahiTasks.span(">>").click();
		sahiTasks.button("Add").click();
		
		sahiTasks.span("Add").under(sahiTasks.heading2(("Access this host"))).near(sahiTasks.div("Hosts")).click();
		sahiTasks.textbox("external").setValue(externalHost);
		sahiTasks.link(">>").click();
		sahiTasks.button("Add").click();
		
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();			
	}
	
	/*
	 * verify adding external user and host
	 */
	public static void verifySudoRuleExternalUserHostSetting(SahiTasks sahiTasks, String cn, String externalUser, String externalHost ) {
		sahiTasks.link(cn).click();
		
		Assert.assertTrue(sahiTasks.checkbox(externalUser).under(sahiTasks.heading2(("Who"))).exists(), "Verified user " + externalUser + " added for Rule " + cn);
		Assert.assertTrue(sahiTasks.checkbox(externalHost).under(sahiTasks.heading2(("Access this host"))).exists(), "Verified Host Group " + externalHost + " added for Rule " + cn);
		
	   sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();			
	}
	
	/**
	 * Modify Who Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to modify for
	 */
	public static void modifySudoRuleHostCategorySection(SahiTasks sahiTasks, String cn, String hostName, String hostgroupName ) {
		sahiTasks.link(cn).click();
		deleteFromSudoRule(sahiTasks, cn,  "Access this host", "Host Groups", hostgroupName, "Delete");
		addToSudoRule(sahiTasks, cn, "Access this host", "Hosts", hostName, "Add");
	
		
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();			
	}

	
	
	/**
	 * Modify Who Section for an HBAC Rule
	 * @param sahiTasks
	 * @param cn - the rule to modify for
	 */
	public static void modifySudoRuleCommandCategorySection(SahiTasks sahiTasks, String cn, String lsCommandName, String allowCommandGroupName, 
			String vimCommandName, String denyCommandGroupName ) {
		sahiTasks.link(cn).click();
		
		deleteFromSudoRule(sahiTasks, cn, "Run Commands", "Allow", "Sudo Allow Commands", lsCommandName, "Delete");		
		addToSudoRule(sahiTasks, cn, "Run Commands", "Allow", "Sudo Allow Command Groups", allowCommandGroupName, "Add");		
		addToSudoRule(sahiTasks, cn, "Run Commands", "Deny", "Sudo Deny Commands", vimCommandName, "Add");		
		deleteFromSudoRule(sahiTasks, cn, "Run Commands", "Deny", "Sudo Deny Command Groups", denyCommandGroupName, "Delete");	
		
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();			
	}
	
	
	/**
	 * Modify As Whom Section for Sudo Rule
	 * @param sahiTasks
	 * @param cn - the rule to modify for
	 */
	public static void modifySudoRuleRunAsUserCategorySection(SahiTasks sahiTasks, String cn, String runasUser, String runasUsergroup, boolean isAdd ) {
		sahiTasks.link(cn).click();
		log.info("In modifySudoRuleRunAsUserCategorySection");
		if (isAdd) {
			addToSudoRule(sahiTasks, cn, "As Whom", "RunAs Users", runasUser, "Add");	
			addToSudoRule(sahiTasks, cn, "As Whom", "Groups of RunAs Users", runasUsergroup, "Add");
			log.info("Added user, group");
		} else {
			deleteFromSudoRule(sahiTasks, cn,  "As Whom", "RunAs Users", runasUser, "Delete");
			deleteFromSudoRule(sahiTasks, cn,  "As Whom", "Groups of RunAs Users", runasUsergroup, "Delete");
			log.info("deleted user, group");
		}
		
		
		
		//deleteFromSudoRule(sahiTasks, cn,  "Who", "Users", user, "Delete");
		/*sahiTasks.checkbox(user).click();	
		sahiTasks.span("Delete").under(sahiTasks.heading2(("Who"))).near(sahiTasks.span("Users")).click();
		sahiTasks.button("Delete").click();*/
		
	//	addToSudoRule(sahiTasks, cn, "Who", "User Groups", usergroup, "Enroll");		
		/*sahiTasks.span("Add").under(sahiTasks.heading2(("Who"))).near(sahiTasks.span("User Groups")).click();
		sahiTasks.checkbox(usergroup).click();
		sahiTasks.span(">>").click();
		sahiTasks.button("Enroll").click();*/
		
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();			
	}
	
	

	public static void verifySudoRuleForRunAsUserCategorySection(SahiTasks sahiTasks, CommonTasks commonTasks, String cn, 
			String runasUser, String runasUsergroup, boolean isExpected) {
		sahiTasks.link(cn).click();
		
		if (isExpected) {
			Assert.assertTrue(sahiTasks.link(runasUser).under(sahiTasks.heading2(("As Whom"))).exists(), "Verified " + runasUser + " is added for rule " + cn );
			Assert.assertTrue(sahiTasks.link(runasUsergroup).under(sahiTasks.heading2(("As Whom"))).exists(), "Verified " + runasUsergroup + " is added for rule " + cn );			
		} else {
			Assert.assertFalse(sahiTasks.link(runasUser).under(sahiTasks.heading2(("As Whom"))).exists(), "Verified " + runasUser + " is deleted from rule " + cn );
			Assert.assertFalse(sahiTasks.link(runasUsergroup).under(sahiTasks.heading2(("As Whom"))).exists(), "Verified " + runasUsergroup + " is deleted from rule " + cn );			
		}
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();	
	}
	
	/**
	 * Modify As Whom Section for Sudo Rule
	 * @param sahiTasks
	 * @param cn - the rule to modify for
	 */
	public static void modifySudoRuleRunAsGroupCategorySection(SahiTasks sahiTasks, String cn, String runasGroup, boolean isAdd ) {
		sahiTasks.link(cn).click();
		if (isAdd) {
			addToSudoRule(sahiTasks, cn, "As Whom", "RunAs Groups", runasGroup, "Add");
		} else {
			deleteFromSudoRule(sahiTasks, cn,  "As Whom", "RunAs Groups", runasGroup, "Delete");
		}		
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();			
	}
	
	
	public static void verifySudoRuleForRunAsGroupCategorySection(SahiTasks sahiTasks, CommonTasks commonTasks, String cn, String runasGroup, boolean isExpected) {
		sahiTasks.link(cn).click();
		
		if (isExpected) {
			Assert.assertTrue(sahiTasks.link(runasGroup).under(sahiTasks.heading2(("As Whom"))).exists(), "Verified " + runasGroup + " is added for rule " + cn );			
		} else {
			Assert.assertFalse(sahiTasks.link(runasGroup).under(sahiTasks.heading2(("As Whom"))).exists(), "Verified " + runasGroup + " is deleted from rule " + cn );			
		}
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();	
	}
	
	public static void addToSudoRule(SahiTasks sahiTasks, String cn, String heading2, String type, String member, String buttonToClick ) {
		addToSudoRule(sahiTasks, cn, heading2, "", type, member, buttonToClick);				
	}
	
	public static void addToSudoRule(SahiTasks sahiTasks, String cn, String heading2, String heading3, String type, String member, String buttonToClick ) {
		if (heading3.equals(""))
			sahiTasks.span("Add").under(sahiTasks.heading2((heading2))).near(sahiTasks.div(type)).click();
		else
			sahiTasks.span("Add").under(sahiTasks.heading2((heading2))).under(sahiTasks.heading3(heading3)).near(sahiTasks.div(type)).click();
		
		sahiTasks.checkbox(member).click();
		sahiTasks.span(">>").click();
		sahiTasks.button(buttonToClick).click();
	}
	
	
	public static void deleteFromSudoRule(SahiTasks sahiTasks, String cn, String heading2, String type, String member, String buttonToClick ) {
		deleteFromSudoRule(sahiTasks, cn, heading2, "", type, member, buttonToClick);				
	}
	
	public static void deleteFromSudoRule(SahiTasks sahiTasks, String cn, String heading2, String heading3, String type, String member, String buttonToClick ) {
		sahiTasks.checkbox(member).click();
		if (heading3.equals(""))
			sahiTasks.span("Delete").under(sahiTasks.heading2((heading2))).near(sahiTasks.div(type)).click();
		else
			sahiTasks.span("Delete").under(sahiTasks.heading2((heading2))).under(sahiTasks.heading3(heading3)).near(sahiTasks.div(type)).click();
		
		sahiTasks.button(buttonToClick).click();
	}
	
	public static void enrollAgain(SahiTasks sahiTasks, String cn, String member, String heading2, String type) {
		enrollAgain(sahiTasks, cn, member, heading2, "", type);
	}
	
	public static void enrollAgain(SahiTasks sahiTasks, String cn, String member, String heading2, String heading3, String type) {
		String expectedError = member + ": This entry is already a member";
		sahiTasks.link(cn).click();
		
		if (heading3.equals(""))
			sahiTasks.span("Add").under(sahiTasks.heading2((heading2))).near(sahiTasks.div(type)).click();
		else
			sahiTasks.span("Add").under(sahiTasks.heading2((heading2))).under(sahiTasks.heading3(heading3)).near(sahiTasks.div(type)).click();
		
		sahiTasks.checkbox(member).under(sahiTasks.div("Available")).click();
		sahiTasks.span(">>").click();		
		sahiTasks.button("Add").click();
		

		Assert.assertTrue(sahiTasks.span("Operations Error").exists(), "Verified Expected Error Message Header");
		//Assert.assertTrue(sahiTasks.div("Some operations failed. Show detailsHide details" + expectedError).exists(), "Verified Expected Error Message");
		sahiTasks.link("Show details").click();
		Assert.assertTrue(sahiTasks.listItem(expectedError).exists(), "Verified Expected Error Details when enrolling same service twice");
		sahiTasks.button("OK").click();
		
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();		
	}
		
	public static void verifySudoRuleCommandCategorySection(SahiTasks sahiTasks, String cn, String lsCommandName, String allowCommandGroupName, 
			String vimCommandName, String denyCommandGroupName) {
		//click on rule to edit
		sahiTasks.link(cn).click();
		Assert.assertFalse(sahiTasks.checkbox(lsCommandName).exists(), "Verified command " + lsCommandName + " is deleted from Allow section of " + cn);
		Assert.assertTrue(sahiTasks.checkbox(allowCommandGroupName).exists(), "Verified Sudo Command Group " + allowCommandGroupName + " is added to Allow Section of " + cn);
		Assert.assertTrue(sahiTasks.checkbox(vimCommandName).exists(), "Verified Command " + vimCommandName + " is added to Deny section of " + cn);
		Assert.assertFalse(sahiTasks.checkbox(denyCommandGroupName).exists(), "Verified Sudo Command Group" + denyCommandGroupName + " is deleted from Deny section of  " + cn);
		
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();			
	}
	
	
	/**
	 * @param sahiTasks
	 * @param cn
	 * @param category - usercategory/hostcategory/cmdcategory/ipasudorunasusercategory/ipasudorunasgroupcategory
	 * @param action - undo/Reset/Update
	 */
	public static void undoResetUpdateSudoRuleSections(SahiTasks sahiTasks, String cn, String category, String action) {
		sahiTasks.link(cn).click();
		
		sahiTasks.radio(category).click();
		sahiTasks.span(action).click();
		if ( (action.equals("undo")) || (action.equals("Reset")) )
			Assert.assertFalse(sahiTasks.radio(category).checked(), "Verified " + category + " set after choosing to " + action);		
		else
			Assert.assertTrue(sahiTasks.radio(category).checked(), "Verified " + category + " set after choosing to " + action);
		sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();			
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
	public static void createSudoCommandAdd(SahiTasks sahiTasks, String cn, String description, String buttonToClick) {
		
		sahiTasks.link("Sudo Commands").click();
		sahiTasks.span("Add").click();
		sahiTasks.textbox("sudocmd").setValue(cn);
		sahiTasks.button(buttonToClick).click();
	}
	

	public static void addSudoCommandThenAddAnother(SahiTasks sahiTasks, String cn1, String cn2) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("sudocmd").setValue(cn1);
		sahiTasks.button("Add and Add Another").click();
		sahiTasks.textbox("sudocmd").setValue(cn2);
		sahiTasks.button("Add").click();
	}

	
	public static void addAndEditSudoCommand(SahiTasks sahiTasks, String cn, String description) {

		sahiTasks.span("Add").click();
		sahiTasks.textbox("sudocmd").setValue(cn);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.textarea("description").setValue(description);
		
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Commands").in(sahiTasks.div("content nav-space-3")).click();
	}
	

	public static void verifySudoCommandUpdates(SahiTasks sahiTasks, String cn,	String newdescription) {
		CommonTasks.search(sahiTasks, cn);
		if(sahiTasks.link(cn).exists())
			sahiTasks.link(cn).click();
		//verify comamnd description
		Assert.assertEquals(sahiTasks.textarea("description").value(), newdescription, "Verified description for command " + cn);

		sahiTasks.link("Sudo Commands").in(sahiTasks.div("content nav-space-3")).click();
		CommonTasks.clearSearch(sahiTasks);
	}
	

	public static void enrollCommandInCommandGroup (SahiTasks sahiTasks, String command, String commandGroup, String buttonToClick) {

		sahiTasks.link(command).click(); 
		sahiTasks.link("memberof_sudocmdgroup").click();
		sahiTasks.span("Add").click();
		sahiTasks.checkbox(commandGroup).under(sahiTasks.div("Available")).click();
		sahiTasks.link(">>").click();
		sahiTasks.button(buttonToClick).click();
		sahiTasks.link("Sudo Commands").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	public static void deleteCommandFromCommandGroup (SahiTasks sahiTasks, String command, String commandGroup, String buttonToClick) {

		sahiTasks.link(command).click(); 
		sahiTasks.link("memberof_sudocmdgroup").click();
		sahiTasks.checkbox(commandGroup).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button(buttonToClick).click();
		
		if (buttonToClick.equals("Cancel")) {
			//Uncheck the box for this Rule
			sahiTasks.checkbox(commandGroup).click();
		}
		
		sahiTasks.link("Sudo Commands").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	

	public static void verifySudoCommandMembership (SahiTasks sahiTasks, String command, String commandGroup, boolean isMember) {

		sahiTasks.link(command).click(); 

		sahiTasks.link("memberof_sudocmdgroup").click();
		if (isMember)
			Assert.assertTrue(sahiTasks.link(commandGroup).exists(), "Verified command " + command + " is member of " + commandGroup);
		else
			Assert.assertFalse(sahiTasks.link(commandGroup).exists(), "Verified command " + command + " is not member of " + commandGroup);

		sahiTasks.link("Sudo Commands").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	public static void createInvalidSudoCommand(SahiTasks sahiTasks,	String cn, String description, String expectedError) {		
		sahiTasks.span("Add").click();
		sahiTasks.textbox("sudocmd").setValue(cn);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add").click();
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified Expected Error Message when creating invalid sudo command group");
		sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}
	
	public static void modifySudoCommandSettings(SahiTasks sahiTasks, String cn, String description) {
		sahiTasks.link(cn).click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea("description").setValue(" ");
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.span("Update").click();
		sahiTasks.link("Sudo Commands").in(sahiTasks.div("content nav-space-3")).click();
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

	public static void createSudoCommandGroupAdd(SahiTasks sahiTasks, String cn, String description, String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button(buttonToClick).click();
				
	}
	
	
	/*
	 * Add Sudo Commands to Sudo Command Groups
	 * @param sahiTasks
	 * @param commandGroupName - name of sudo command group
	 * @param membertype - sudo command/sudo command group
	 * @param name - name to add as member
	 * @param button - Enroll or Cancel
	 */
	public static void addMembers(SahiTasks sahiTasks, String commandGroupName, String commandName, String button) {
		sahiTasks.link(commandGroupName).click();

		sahiTasks.span("Add").click();
		sahiTasks.checkbox(commandName).click();
		sahiTasks.span(">>").click();
		sahiTasks.button(button).click();
		sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	
	
	public static void deleteSudoCommandGroupDel(SahiTasks sahiTasks, String cn, String buttonToClick) {
		
		sahiTasks.link("Sudo Command Groups").click();
		sahiTasks.checkbox(cn).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button(buttonToClick).click();
		
		if (buttonToClick.equals("Cancel")) {
			//Uncheck the box for this Rule
			sahiTasks.checkbox(cn).click();
		}
		
	}
	
	public static void modifySudoruleCommandGroupWithInvalidSetting(SahiTasks sahiTasks, String cn, String description, String expectedError) {
		CommonTasks.modifyToInvalidSettingTextarea(sahiTasks, cn, "description", description, expectedError, "Cancel");
		sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	public static void createInvalidSudoCommandGroup(SahiTasks sahiTasks,	String cn, String description, String expectedError) {		
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add").click();
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified Expected Error Message when creating invalid sudo command group");
		sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}
	
	public static void createSudoCommandGroupWithRequiredField(SahiTasks sahiTasks,	String cn, String description, String expectedError) {		
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add").click();
		Assert.assertTrue(sahiTasks.span(expectedError).exists(), "Verified expected error when adding invalid rule " + cn);
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
	}
	
	/**
	 * Add Sudo cmd grp, and Add Another
	 * @param sahiTasks
	 * @param cn1 - Rule to be added
	 * @param cn2 - Next Rule to be added
	 */
	public static void addSudoCommandGroupThenAddAnother(SahiTasks sahiTasks, String cn1, String cn2, String description) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn1);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add and Add Another").click();
		sahiTasks.textbox("cn").setValue(cn2);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add").click();
	}
	
	
	public static void addAndEditSudoCommandGroup(SahiTasks sahiTasks, String cn, String description, String command) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.waitFor(1000);
		sahiTasks.span("Add").click();
		sahiTasks.checkbox(command).near(sahiTasks.row(command)).click();
		sahiTasks.span(">>").click();		
		sahiTasks.span("Add").near(sahiTasks.button("Cancel")).click();
		
		sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
		sahiTasks.span("Refresh").click();
	}
	
	
	public static void verifySudoCommandGroupUpdates(SahiTasks sahiTasks, String cn, String description, String command) {
		sahiTasks.link(cn.toLowerCase()).click();
		sahiTasks.link("member_sudocmd").click();
		Assert.assertTrue(sahiTasks.link(command).exists(), "Verified comand " + command + " is a memberof " + cn);
		sahiTasks.link("Settings").click();
		Assert.assertEquals(sahiTasks.textarea("description").value(), description, "Verified description for  " + cn);
		sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	public static void enrollIntoCommandGroup (SahiTasks sahiTasks, String command, String commandGroup, String buttonToClick) {

		sahiTasks.link(commandGroup).click(); 
		sahiTasks.link("member_sudocmd").click();
		sahiTasks.span("Add").click();
		sahiTasks.checkbox(command).under(sahiTasks.div("Available")).click();
		sahiTasks.link(">>").click();
		sahiTasks.button(buttonToClick).click();
		sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	public static void enrollAgainIntoCommandGroup (SahiTasks sahiTasks, String command, String commandGroup, String expectedError) {

		sahiTasks.link(commandGroup).click(); 
		sahiTasks.link("member_sudocmd").click();
		sahiTasks.span("Add").click();
		sahiTasks.checkbox(command).under(sahiTasks.div("Available")).click();
		sahiTasks.link(">>").click();
		sahiTasks.button("Add").click();
		
		CommonTasks.checkOperationsError(sahiTasks, expectedError);
		sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	public static void verifySudoCommandGroupMembership (SahiTasks sahiTasks, String command, String commandGroup, boolean isMember) {

		sahiTasks.link(commandGroup).click(); 

		sahiTasks.link("member_sudocmd").click();
		if (isMember)
			Assert.assertTrue(sahiTasks.link(command).exists(), "Verified command " + command + " is member of " + commandGroup);
		else
			Assert.assertFalse(sahiTasks.link(command).exists(), "Verified command " + command + " is not member of " + commandGroup);

		sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	public static void deleteFromCommandGroup (SahiTasks sahiTasks, String command, String commandGroup, String buttonToClick) {

		sahiTasks.link(commandGroup).click(); 
		sahiTasks.link("member_sudocmd").click();
		sahiTasks.checkbox(command).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button(buttonToClick).click();
		
		if (buttonToClick.equals("Cancel")) {
			//Uncheck the box for this Rule
			sahiTasks.checkbox(command).click();
		}
		
		sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	
	public static void editSudoCommandGroup(SahiTasks sahiTasks, String cn,	String description, String buttonToClick, boolean isCommandGroup) {
		
        String newDescription = "New testing description";
		sahiTasks.link(cn).click();
		if (isCommandGroup) {
			sahiTasks.link("Settings").click();
		}
		sahiTasks.textarea("description").setValue(newDescription);
		
		if (isCommandGroup) 
			sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
		else
			sahiTasks.link("Sudo Commands").in(sahiTasks.div("content nav-space-3")).click();
		
		Assert.assertTrue(sahiTasks.span("Unsaved Changes").exists(), "Verified Error message title");
		Assert.assertTrue(sahiTasks.div("This page has unsaved changes. Please save or revert.").exists(), "Verified expected error");
		
		sahiTasks.button(buttonToClick).click();
		

		if (buttonToClick.equals("Cancel")){
			sahiTasks.textarea("description").getValue().equals(newDescription);
			Assert.assertEquals(sahiTasks.textarea("description").value(), newDescription, "Verified description for service " + cn + " after Cancel");
			
			if (isCommandGroup) {
				sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
				sahiTasks.button("Reset").click();
			}
			else {
				sahiTasks.link("Sudo Commands").in(sahiTasks.div("content nav-space-3")).click();
			    sahiTasks.button("Reset").click();
			}
		}
		else if (buttonToClick.equals("Reset")) {
			sahiTasks.link(cn).click();
			if (isCommandGroup) {
				sahiTasks.link("Settings").click();
			}
			Assert.assertEquals(sahiTasks.textarea("description").value(), description, "Verified description for service " + cn + " after Reset");
			if (isCommandGroup) 
				sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
			else
				sahiTasks.link("Sudo Commands").in(sahiTasks.div("content nav-space-3")).click();
		}
		else {
			sahiTasks.link(cn).click();
			if (isCommandGroup) {
				sahiTasks.link("Settings").click();
			}
			Assert.assertEquals(sahiTasks.textarea("description").value(), newDescription, "Verified description for service " + cn + " after Reset");
			if (isCommandGroup) 
				sahiTasks.link("Sudo Command Groups").in(sahiTasks.div("content nav-space-3")).click();
			else
				sahiTasks.link("Sudo Commands").in(sahiTasks.div("content nav-space-3")).click();
		}
	}
}
