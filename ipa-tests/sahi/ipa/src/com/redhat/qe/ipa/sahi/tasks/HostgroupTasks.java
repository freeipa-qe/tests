package com.redhat.qe.ipa.sahi.tasks;

import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class HostgroupTasks {
	
	/*
	 * Create a host group
	 * @param sahiTasks 
	 * @param groupname - groupname
	 * @param description -  description for group
	 * @param button - Add or Cancel
	 */
	public static void addHostGroup(SahiTasks sahiTasks, String groupName, String description, String button) {
		sahiTasks.span("Add[1]").click();
		sahiTasks.textbox("cn").setValue(groupName);
		sahiTasks.textbox("description").setValue(description);
		sahiTasks.button(button).click();
	}
	
	/*
	 * add a host and add another
	 * @param sahiTasks 
	 * @param hostname - hostname1
	 * @param hostname - hostname2
	 * @param hostname - hostname2
	 */
	public static void addAndAddAnotherHost(SahiTasks sahiTasks, String groupName1, String groupName2, String groupName3) {
		String description1 = groupName1 + " description";
		sahiTasks.span("Add[1]").click();
		sahiTasks.textbox("cn").setValue(groupName1);
		sahiTasks.textbox("description").setValue(description1);
		sahiTasks.button("Add and Add Another").click();
		
		String description2 = groupName2 + " description";
		sahiTasks.textbox("cn").setValue(groupName2);
		sahiTasks.textbox("description").setValue(description2);
		sahiTasks.button("Add and Add Another").click();
		
		String description3 = groupName3 + " description";
		sahiTasks.textbox("cn").setValue(groupName3);
		sahiTasks.textbox("description").setValue(description3);
		sahiTasks.button("Add").click();
	}
	
	/*
	 * Delete the host group.
	 * @param sahiTasks
	 * @param groupName - name of the host group
	 * @param button - Delete or Cancel
	 */
	public static void deleteHostgroup(SahiTasks sahiTasks, String groupName, String button) {
		sahiTasks.checkbox(groupName).click();
		sahiTasks.span("Delete[1]").click();
		sahiTasks.button(button).click();
		
		if (button == "Cancel"){
			sahiTasks.checkbox(groupName).click();
		}
	}
	
	/*
	 * Delete multiple host groups.
	 * @param sahiTasks
	 * @param groupnames - the array of groupnames to delete
	 */
	public static void deleteHostgroup(SahiTasks sahiTasks, String [] groupnames) {
		for (String groupname : groupnames) {
			sahiTasks.checkbox(groupname).click();
		}
		sahiTasks.link("Delete[1]").click();
		sahiTasks.button("Delete").click();
	}
}