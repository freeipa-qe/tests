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
	

	public static void deleteSudorule(SahiTasks sahiTasks, String cn) {
		
		sahiTasks.link("Sudo Rules").click();
		sahiTasks.checkbox("select[1]").click();
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
		sahiTasks.checkbox("select[2]").click();
		sahiTasks.span("Delete[1]").click();
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
		sahiTasks.checkbox("select[4]").click();
		sahiTasks.span("Delete[2]").click();
		sahiTasks.button("Delete").click();
	}
	
}
