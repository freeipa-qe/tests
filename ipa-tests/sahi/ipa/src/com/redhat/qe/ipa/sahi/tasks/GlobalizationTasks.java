package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;


public class GlobalizationTasks {
	private static Logger log = Logger.getLogger(GlobalizationTasks.class.getName());
	
	public static void modifyUserSettings(SahiTasks sahiTasks,String uid ,String givenname,String sn, String initials,String street,String city,String state,String carlicense) 
	{
		sahiTasks.link(uid).click();
		sahiTasks.textbox("givenname").setValue(givenname);
		sahiTasks.textbox("sn").setValue(sn);
		sahiTasks.textbox("initials").setValue(initials);
		sahiTasks.textbox("street").setValue(street);
		sahiTasks.textbox("l").setValue(city);
		sahiTasks.textbox("st").setValue(state);
		sahiTasks.textbox("carlicense").setValue(carlicense);
		
		sahiTasks.link("Update").click();
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
	}
	
	
	public static void verifyUserSettings(SahiTasks sahiTasks,String uid ,String givenname,String sn, String initials,String street,String city,String state,String carlicense){
		//click on user to edit
				sahiTasks.link(uid).click();
				
				//verify user's job title
				Assert.assertEquals(sahiTasks.textbox("givenname").value(), givenname, "Verified updated First name with UTF-8 string for user " + uid + ": " + givenname);
				Assert.assertEquals(sahiTasks.textbox("sn").value(), sn, "Verified updated Last name with UTF-8 string for user " + uid + ": " + sn);
				Assert.assertEquals(sahiTasks.textbox("initials").value(), initials, "Verified updated firstname with UTF-8 string for user " + uid + ": " + initials);
				Assert.assertEquals(sahiTasks.textbox("street").value(), street, "Verified updated street with UTF-8 string for user " + uid + ": " + street);
				Assert.assertEquals(sahiTasks.textbox("l").value(), city, "Verified updated city with UTF-8 string for user " + uid + ": " + city);
				Assert.assertEquals(sahiTasks.textbox("st").value(), state, "Verified updated State with UTF-8 string for user " + uid + ": " + state);
				Assert.assertEquals(sahiTasks.textbox("carlicense").value(), carlicense, "Verified updated car license with UTF-8 string for user " + uid + ": " + carlicense);
				sahiTasks.link("Users").in(sahiTasks.div("content")).click();
				
	}
	
	public static void modifyNegativeUserSetting(SahiTasks sahiTasks, String uid, String homedir, String expectedmsg)
	{
		sahiTasks.link(uid).click();
		sahiTasks.textbox("homedirectory").setValue(homedir);		
		//Update and go back to user list
		sahiTasks.link("Update").click();
		if (sahiTasks.div(expectedmsg).exists())
		 {
			log.info("IPA error dialog appears:: ExpectedError ::"+expectedmsg);
			sahiTasks.button("Cancel").click();
							
		}
		sahiTasks.span("undo").click();
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
		
	}
	
	//userGroup_add
	public static void userGroup_add(SahiTasks sahiTasks, String groupName, String groupDescription, String gid, String groupType, String expectedErrorMsg)
	{
		
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(groupName);
		sahiTasks.textarea("description").setValue(groupDescription); 
		sahiTasks.textbox("gidnumber").setValue(gid);
		sahiTasks.radio(groupType).click();
		sahiTasks.button("Add").click();
		if (sahiTasks.span(expectedErrorMsg).exists()){
			Assert.assertTrue(sahiTasks.span(expectedErrorMsg).exists(), "expected error field triggered") ;
			log.info("group name rejected UTF-8 string");
			sahiTasks.button("Cancel").click();		
		}else if (sahiTasks.div("error_dialog").exists()){
			Assert.assertTrue(sahiTasks.div("error_dialog").getText().equals(expectedErrorMsg), "error dialog dected, now verify error msg");
			log.info("group name exists");
			sahiTasks.button("Cancel").click();
			sahiTasks.button("Cancel").click();
		}
		
	}
	
	//netgroup
	
	
		public static void addNetGroup(SahiTasks sahiTasks, String groupName, String description, String expectedErrorMsg) {
			sahiTasks.span("Add").click();
			sahiTasks.textbox("cn").setValue(groupName);
			sahiTasks.textarea("description").setValue(description);
			sahiTasks.button("Add").click();
			if (sahiTasks.span(expectedErrorMsg).exists()){
				Assert.assertTrue(sahiTasks.span(expectedErrorMsg).exists(), "expected error field triggered") ;
				log.info("netgroup name rejected UTF-8 string");
				sahiTasks.button("Cancel").click();		
			}else if (sahiTasks.div("error_dialog").exists()){
				Assert.assertTrue(sahiTasks.div("error_dialog").getText().equals(expectedErrorMsg), "error dialog dected, now verify error msg");
				//log.info("group name already exists");
				sahiTasks.button("Cancel").click();
				sahiTasks.button("Cancel").click();
					}
			else{
				log.info("Verify net group " + groupName + " was added successfully with UTF-8 string");
			}
		}
		
		public static void modifyHBACRule(SahiTasks sahiTasks, String cn, String description) {
			sahiTasks.link(cn).click();
			
			sahiTasks.textarea("description").setValue(description);
			sahiTasks.span("Update").click();
			sahiTasks.link("HBAC Rules").in(sahiTasks.div("content nav-space-3")).click();
			sahiTasks.link(cn).click();
			Assert.assertTrue(sahiTasks.textarea("description").containsText(description), "Verified description with UTF 8 string is set correctly");
			sahiTasks.link("HBAC Rules").in(sahiTasks.div("content nav-space-3")).click();
		}
		
		public static void modifySudoRule(SahiTasks sahiTasks, String cn, String description) {
			sahiTasks.link(cn).click();			
			sahiTasks.textarea("description").setValue(description);
			sahiTasks.span("Update").click();
			sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();
			sahiTasks.link(cn).click();
			Assert.assertTrue(sahiTasks.textarea("description").containsText(description), "Verified description with UTF 8 string is set correctly");
			sahiTasks.link("Sudo Rules").in(sahiTasks.div("content nav-space-3")).click();
		}
		public static void sudoCommandAdd(SahiTasks sahiTasks, String cn, String description, String buttonToClick) {
			
			sahiTasks.link("Sudo Commands").click();
			sahiTasks.span("Add").click();
			sahiTasks.textbox("sudocmd").setValue(cn);
			sahiTasks.textarea("description").setValue(description);
			sahiTasks.button(buttonToClick).click();
		}

		public static void AutomountMap(SahiTasks sahiTasks, String automountMap, String description,String expectedErrorMsg) {
			sahiTasks.span("Add").click();
			sahiTasks.textbox("automountmapname").setValue(automountMap);
			sahiTasks.textarea("description").setValue(description);
			sahiTasks.button("Add").click();
			if (sahiTasks.span(expectedErrorMsg).exists()){
				Assert.assertTrue(sahiTasks.span(expectedErrorMsg).exists(), "expected error field triggered") ;
				log.info("automount map rejected UTF-8 string");
				sahiTasks.button("Cancel").click();		
			}else if (sahiTasks.div("error_dialog").exists()){
				Assert.assertTrue(sahiTasks.div("error_dialog").getText().equals(expectedErrorMsg), "error dialog dected, now verify error msg");
				log.info("automountmap rejected UTF-8 string");
				sahiTasks.button("Cancel").click();
				sahiTasks.button("Cancel").click();
			}
			
		}
		public static void AutomountKey(SahiTasks sahiTasks, String automountKey,String description,String expectedErrorMsg) {
			sahiTasks.span("Add").click();
			sahiTasks.textbox("automountkey").setValue(automountKey);
			sahiTasks.textbox("automountinformation").setValue(description);
			sahiTasks.button("Add").click();
			if (sahiTasks.span(expectedErrorMsg).exists()){
				Assert.assertTrue(sahiTasks.span(expectedErrorMsg).exists(), "expected error field triggered") ;
				log.info("automount key rejected UTF-8 string");
				sahiTasks.button("Cancel").click();		
			}else if (sahiTasks.div("error_dialog").exists()){
				Assert.assertTrue(sahiTasks.div("error_dialog").getText().equals(expectedErrorMsg), "error dialog dected, now verify error msg");
				log.info("automountkey and key information rejected UTF-8 string");
				sahiTasks.button("Cancel").click();
				sahiTasks.button("Cancel").click();
			}
		}
		public static void Automember(SahiTasks sahiTasks,String groupName,String description) {
			sahiTasks.span("Add").click();
			sahiTasks.span("icon combobox-icon[1]").click();
			sahiTasks.select("list").choose(groupName);
			sahiTasks.button("Add and Edit").click();
			sahiTasks.textarea("description").setValue(description);
			sahiTasks.span("Update").click();
		}
		//rbacRuleDeleteSingle
		public static void rbacDelete(SahiTasks sahiTasks,String name,String buttonToClick) {
				sahiTasks.checkbox(name).click();
				sahiTasks.link("Delete").click();
				sahiTasks.button(buttonToClick).click();
		}
		
		public static void selfservice(SahiTasks sahiTasks,String name,String cn,String expectedErrorMsg) {
			sahiTasks.span("Add").click();
			sahiTasks.textbox("aciname").setValue(name); 
			sahiTasks.checkbox(cn).check();
			sahiTasks.button("Add").click();
			if (sahiTasks.span(expectedErrorMsg).exists()){
				Assert.assertTrue(sahiTasks.span(expectedErrorMsg).exists(), "expected error field triggered") ;
				log.info("Self-service name rejected UTF-8 string");
				sahiTasks.button("Cancel").click();		
			}else if (sahiTasks.div("error_dialog").exists()){
				Assert.assertTrue(sahiTasks.div("error_dialog").getText().equals(expectedErrorMsg), "error dialog dected, now verify error msg");
				log.info("Self-service name rejected UTF-8 string");
				sahiTasks.button("Cancel").click();
				sahiTasks.button("Cancel").click();
			}
		}
		public static void configuration(SahiTasks sahiTasks,String fieldname, String fieldvalue,String expectedErrorMsg) {
			sahiTasks.textbox(fieldname).setValue(fieldvalue);
			sahiTasks.span("Update").click();
			if (sahiTasks.div("error_dialog").exists()){
				//Assert.assertTrue(browser.paragraph(expectedErrorMsg).exists(), "expected error field triggered") ;
				log.info(""+fieldname+"rejected UTF-8 string");
				sahiTasks.button("Cancel").click();
				sahiTasks.span("Reset").click();
				}
		}
		
}