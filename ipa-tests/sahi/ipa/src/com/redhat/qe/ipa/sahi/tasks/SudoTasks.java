package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;


public class SudoTasks {
	private static Logger log = Logger.getLogger(SudoTasks.class.getName());
	
	/*
	 * Create a new sudorule. Check if user already exists before calling this.
	 * @param sahiTasks 
	 * @param cn - sudo rule name
	 */
	public static void createSudorule(SahiTasks sahiTasks, String cn) {

		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.button("Add").click();

	}
	

	public static void deleteSudorule(SahiTasks sahiTasks, String cn) {
		
		sahiTasks.checkbox("select[1]").click();
		sahiTasks.span("Delete").click();
		sahiTasks.button("Delete").click();
		
	}
	
}