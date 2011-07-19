package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 


public class GroupTasks {
	private static Logger log = Logger.getLogger(GroupTasks.class.getName());
		
	/*
	 * Create a Group and then delete it.
	 * @param sahiTasks 
	 * @param groupName - user group name
	 * @param groupDescription - group description
	 */
	public static void createGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {

		sahiTasks.link("User Groups").click();
		sahiTasks.span("ui-icon add-icon[1]").click();
		sahiTasks.textbox("cn").setValue("auto_sahi_java_001");
		sahiTasks.textbox("description").setValue("auto sahi 001 in java");
		sahiTasks.button("Add").click();
		sahiTasks.checkbox("select[4]").click();
		sahiTasks.link("Delete[1]").click();
		sahiTasks.button("Delete").click();
		
	}//createGroup


	/*
	 * Test for: Simple add Group
	 * @param sahiTasks 
	 * @param groupName - user group name
	 * @param groupDescription - group description
	 */
	public static void simpleAddGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {

		sahiTasks.link("User Groups").click();
		sahiTasks.span("ui-icon add-icon[1]").click();
		sahiTasks.textbox("cn").setValue("auto_sahi_java_001");
		sahiTasks.textbox("description").setValue("auto sahi 001 in java");
		sahiTasks.button("Add").click();
		sahiTasks.checkbox("select[4]").click();
		sahiTasks.link("Delete[1]").click();
		sahiTasks.button("Delete").click();
		
	}// simpleAddGroup


	/*
	 * Test for: add and add another Group
	 * @param sahiTasks 
	 * @param groupName - user group name
	 * @param groupDescription - group description
	 */
	public static void addAndAddAnotherGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {
		
	}// addAndAddAnotherGroup


	/*
	 * Test for: add and edit Group
	 * @param sahiTasks 
	 * @param groupName - user group name
	 * @param groupDescription - group description
	 */
	public static void addAndAddAnotherGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {
		
	}// addAndEditGroup


	/*
	 * Create a Many Groups and then delete them, covers all essential function under Group operations
	 * @param sahiTasks 
	 */
	public static void smokeTest(SahiTasks sahiTasks) {

			sahiTasks.link("User Groups").click();
			sahiTasks.link("Add[1]").click();
			sahiTasks.textbox("cn").setValue("sahi_auto_001");
			sahiTasks.textbox("description").setValue("automatic group by sahi 001");
			sahiTasks.button("Add").click();
			sahiTasks.link("Add[1]").click();
			sahiTasks.textbox("cn").setValue("sahi_auto_add_and_add_another_001");
			sahiTasks.textbox("description").setValue("add and add another 001");
			sahiTasks.button("Add and Add Another").click();
			sahiTasks.textbox("cn").setValue("sahi_atuo_add_and_add_another_002");
			sahiTasks.textbox("description").setValue("sahi automatic, add and add another 002");
			sahiTasks.button("Add and Add Another").click();
			sahiTasks.textbox("cn").setValue("sahi-auto-add_and_edit");
			sahiTasks.textbox("description").setValue("sahi automatic add and edit");
			sahiTasks.button("Add and Edit").click();
			sahiTasks.link("User Groups[2]").click();
			sahiTasks.link("Settings[1]").click();
			sahiTasks.textbox("description").setValue("sahi automatic add and edit, modified");
			sahiTasks.link("Update").click();
			sahiTasks.link("User Groups[7]").click();
			sahiTasks.link("Add[1]").click();
			sahiTasks.textbox("cn[1]").setValue("sahi_auto_add_and_cancel");
			sahiTasks.textbox("description[1]").setValue("add then cancle, it should not exist");
			sahiTasks.button("Cancel").click();
			sahiTasks.checkbox("select[6]").click();
			sahiTasks.checkbox("select[7]").click();
			sahiTasks.checkbox("select[8]").click();
			sahiTasks.checkbox("select[9]").click();
			sahiTasks.link("Delete[1]").click();
			//sahiTasks.button("Delete").click(); 
	}// smokeTest
	
}//class Group Tasks

