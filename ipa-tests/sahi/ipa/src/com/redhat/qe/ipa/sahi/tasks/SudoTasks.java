package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class SudoTasks {
	private static Logger log = Logger.getLogger(SudoTasks.class.getName());
	
	/*
	 * Create a new sudorule. Check if sudorule already exists before calling this.
	 * @param sahiTasks 
	 * @param cn - sudorule name
	 */
	public static void createSudorule(SahiTasks sahiTasks, String cn) {

		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.button("Add").click();

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
	
	public static void createSudoruleCommandAdd(SahiTasks sahiTasks, String cn, String description) {
		
		sahiTasks.link("Sudo Commands").click();
		sahiTasks.span("Add[1]").click();
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
