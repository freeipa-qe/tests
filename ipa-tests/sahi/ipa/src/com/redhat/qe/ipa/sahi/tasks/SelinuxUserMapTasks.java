package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class SelinuxUserMapTasks {
	private static Logger log = Logger.getLogger(UserTasks.class.getName());
	
	/*
	 * Create a selinux user maps
	 * @param sahiTasks 
	 * @param groupname - groupname
	 * @param description -  description for group
	 * @param button - Add or Cancel
	 */
	public static void addSelinuxUserMap(SahiTasks sahiTasks, String ruleName, String selinuxUsername, String button) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(ruleName);
		sahiTasks.textbox("ipaselinuxuser").setValue(selinuxUsername);
		sahiTasks.button(button).click();
	}
	
	/*
	 * add a selinux user maps and add another
	 * @param sahiTasks 
	 * @param groupName1
	 * @param groupName2
	 * @param groupName3
	 */
	public static void addAndAddAnotherSelinuxUserMap(SahiTasks sahiTasks, String ruleName1, String ruleName2, String ruleName3, String selinuxUser1, String selinuxUser2, String selinuxUser3) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(ruleName1);
		sahiTasks.textbox("ipaselinuxuser").setValue(selinuxUser1);
		sahiTasks.button("Add and Add Another").click();
		
		sahiTasks.textbox("cn").setValue(ruleName2);
		sahiTasks.textbox("ipaselinuxuser").setValue(selinuxUser2);
		sahiTasks.button("Add and Add Another").click();
		
		sahiTasks.textbox("cn").setValue(ruleName3);
		sahiTasks.textbox("ipaselinuxuser").setValue(selinuxUser3);
		sahiTasks.button("Add").click();
	}
	
	/*
	 * add and edit a selinux user maps
	 * @param sahiTasks 
	 * @param groupName - name of selinux user maps
	 * @param description1 - first description
	 * @param description2 - new description for edit
	 * @param undo - YES NO
	 */
	public static void addAndEditSelinuxUserMap(SahiTasks sahiTasks, String ruleName, String selinuxuser, String description) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(ruleName);
		sahiTasks.textbox("ipaselinuxuser").setValue(selinuxuser);
		sahiTasks.button("Add and Edit").click();
		sahiTasks.textarea("description").setValue(description);
		sahiTasks.waitFor(1000);
		sahiTasks.span("Update").click();
		sahiTasks.waitFor(1000);
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify host group settings
	 * @param sahiTasks 
	 * @param groupName - name of selinux user maps
	 * @param description
	 * @param nisdomain - nis domain
	 */
	public static void verifySelinuxUserMapSettings(SahiTasks sahiTasks, String ruleName, String description) {
		sahiTasks.link(ruleName).click();
		Assert.assertEquals(sahiTasks.textarea("description").value(), description, "Verified existing description for selinux user map: " + ruleName);
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
		
	}
	
	/*
	 * Delete the selinux user maps.
	 * @param sahiTasks
	 * @param groupName - name of the selinux user maps
	 * @param button - Delete or Cancel
	 */
	public static void deleteNetgroup(SahiTasks sahiTasks, String groupName, String button) {
		sahiTasks.checkbox(groupName).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button(button).click();
		
		if (button == "Cancel"){
			sahiTasks.checkbox(groupName).click();
		}
	}
	
	/*
	 * Delete multiple selinux user maps.
	 * @param sahiTasks
	 * @param groupnames - the array of groupnames to delete
	 */
	public static void deleteSelinuxUserMaps(SahiTasks sahiTasks, String [] selinuxrules) {
		for (String selinuxrule : selinuxrules) {
			if (sahiTasks.checkbox(selinuxrule).exists())
				sahiTasks.checkbox(selinuxrule).click();
		}
		sahiTasks.span("Delete").click();
		sahiTasks.button("Delete").click();
	}
	

	
	public static void addMembers(SahiTasks sahiTasks, String groupName, String section, String type, String [] names, 
			String button, String action) {
		sahiTasks.link(groupName).click();
		if (button.equals("All")) {
			String categoryToChoose="";
			if (section.equals("User"))
				categoryToChoose = "usercategory" + "-1";
			else
				categoryToChoose = "hostcategory" +"-2";
			sahiTasks.radio(categoryToChoose+"-0").click();
			sahiTasks.span(action).click();
		}
				
		if (button.equals("Add")) {
			sahiTasks.span("Add").under(sahiTasks.heading2(section)).near(sahiTasks.div(type)).click();
			for (String name : names) {
				if(!name.equals("")){
					sahiTasks.textbox("filter").near(sahiTasks.span("Find")).setValue(name);
					sahiTasks.span("Find").click();
					sahiTasks.checkbox(name).click();
					sahiTasks.link(">>").click();
				}
			}			
			sahiTasks.button(action).click();
		}
		//for(String name:names)
		//	Assert.assertTrue(sahiTasks.link(name).exists(), "User " + name + " added succesfully");
		
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
	}
	
	
	public static void verifyMembers(SahiTasks sahiTasks, String groupName, String section, String type, String [] names, 
			String button, String action) {
		sahiTasks.link(groupName).click();
		if (button.equals("All")) {
			String categoryToVerify = "";
			String memberToVerify = "";
			if (section.equals("User")) {
				categoryToVerify = "usercategory" + "-1";
				if (type.equals("Users"))
					memberToVerify = "memberuser_user";
				else	
					memberToVerify = "memberuser_group";
			}
			else {
				categoryToVerify = "hostcategory" +"-2";
				if (type.equals("Hosts"))
					memberToVerify = "memberhost_host";
				else	
					memberToVerify = "memberhost_hostgroup";
			}
			Assert.assertTrue(sahiTasks.radio(categoryToVerify + "-0").checked(), "Verified " + section + " set to All after choosing to " + action);
			Assert.assertFalse(sahiTasks.checkbox(memberToVerify + "[1]").exists(), "Verified no members are listed in " + section);
		}
		
		if (button.equals("Add")) {			
			for (String name : names) {
				if (!name.isEmpty()){
					if (action.equals("Cancel"))
						Assert.assertFalse(sahiTasks.checkbox(name).exists(), "Verified " + name + " is not listed under " + section);
					else
						Assert.assertTrue(sahiTasks.checkbox(name).exists(), "Verified " + name + " is listed under " + section);
				}				
			}		
		}
		
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * button = All -> delete all members
	 * button = Delete -> delete names passed in
	 */
	
	public static void deleteUserMembers(SahiTasks sahiTasks, String groupName, String section, String type, String [] names, String button) {
		sahiTasks.link(groupName).click();
		if (button.equals("All")) {
			String memberToVerify = "";
			if (section.equals("User")) {
				if (type.equals("Users"))
					memberToVerify = "memberuser_user";
				else	
					memberToVerify = "memberuser_group";
			}
			else {
				if (type.equals("Hosts"))
					memberToVerify = "memberhost_host";
				else	
					memberToVerify = "memberhost_hostgroup";
			}
			sahiTasks.checkbox(memberToVerify).check();
		}
		if (button.equals("Delete")) {
			for (String name : names) {
				if (!name.isEmpty()){
					sahiTasks.checkbox(name).check();
				}
			}			
		}
		sahiTasks.span("Delete").under(sahiTasks.heading2(section)).near(sahiTasks.div(type)).click();
		sahiTasks.button("Delete").click();
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
	}
	
	
	
	public static void modifySelinuxusermapMembership(SahiTasks sahiTasks, String groupName, String category) {
		sahiTasks.link(groupName).click();
		String categoryToChoose="";
		if (category.equals("usercategory"))
			if (!System.getProperty("os.name").startsWith("Windows")){
				categoryToChoose = category + "-1";
			}else{
				categoryToChoose = category + "-4";
			}
		
		else
			if (!System.getProperty("os.name").startsWith("Windows")){
				categoryToChoose = category + "-2";
			}else{
				categoryToChoose = category + "-5";
			}
		sahiTasks.radio(categoryToChoose+"-1").click();
		sahiTasks.span("Update").click();		
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();	
	}
	
	

	public static void selinuxUserMapAction(SahiTasks sahiTasks, String rulename, String action) {
		sahiTasks.link(rulename).click();
		sahiTasks.select("action").choose(action);
		sahiTasks.span("Apply").click();
		if(sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).exists())
			sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
		
	}

	public static void selinuxUserMapUndoRefreshResetUpdate(SahiTasks sahiTasks, String rulename, String hbacRule, String action) {
		sahiTasks.link(rulename).click();
		sahiTasks.span("icon combobox-icon").click();
		sahiTasks.select("list").choose(hbacRule);
		sahiTasks.span(action).click();
	}

	public static void selinuxUserMapUpdateResetCancel(SahiTasks sahiTasks,	String rulename, String hbacRule, String action) {
		
		sahiTasks.link(rulename).click();
		sahiTasks.span("icon combobox-icon").click();
		sahiTasks.select("list").choose(hbacRule);
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
		if(sahiTasks.button(action).exists())
			sahiTasks.button(action).click();
	}

	public static void selinuxUserMapDeleteSingle(SahiTasks sahiTasks, String rulename) {
		if(sahiTasks.checkbox(rulename).exists())
			sahiTasks.checkbox(rulename).click();
		sahiTasks.span("Delete").click();
		sahiTasks.button("Delete").click();
	}

	public static void selinuxUserMapDeleteMultiple(SahiTasks sahiTasks, String[] rulenames) {
		
		for(String rulename:rulenames){
			if(sahiTasks.checkbox(rulename).exists())
				sahiTasks.checkbox(rulename).click();
		}
		sahiTasks.span("Delete").click();
		sahiTasks.button("Delete").click();
	}

	public static void AddDisabledHbacRule(SahiTasks sahiTasks,	String hbacrule, String rulename) {
		sahiTasks.navigateTo(CommonTasks.hbacRulesPolicyPage, true);
		sahiTasks.checkbox(hbacrule).click();
		sahiTasks.span("Disable").click();
		if(sahiTasks.button("OK").exists())
			sahiTasks.button("OK").click();
		
		sahiTasks.navigateTo(CommonTasks.selinuxPage, true);
		sahiTasks.link(rulename).click();
		sahiTasks.span("icon combobox-icon").click();
		sahiTasks.select("list").choose(hbacrule);
		sahiTasks.span("Update").click();
		sahiTasks.link("SELinux User Maps").in(sahiTasks.div("content")).click();
		
		
	}

}