package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;

public class ConfigurationTasks {
	private static Logger log = Logger.getLogger(ConfigurationTasks.class.getName());
	
	
	
	public static void setConfigValue(SahiTasks sahiTasks, String field, String value) {
		if (value.isEmpty())
			sahiTasks.textbox(field).setValue(" ");
		sahiTasks.textbox(field).setValue(value);
		sahiTasks.span("Update").click();
	}
	
	public static void verifyConfigValue(SahiTasks sahiTasks, String field, String value) {
		Assert.assertEquals(sahiTasks.textbox(field).value(), value, "Verified config value for " + field + "  is " + value);		
	}
	
	public static void setInvalidConfigValue(SahiTasks sahiTasks, String field, String value, String expectedError1, String expectedError2) {
		sahiTasks.span("Refresh").click();
		if (value.isEmpty())
			sahiTasks.textbox(field).setValue(" ");
		sahiTasks.textbox(field).setValue(value);
		if (!expectedError2.isEmpty())
			Assert.assertTrue(sahiTasks.span(expectedError2).exists(), "Verified expected error - " + expectedError2);
		sahiTasks.span("Update").click();
		//sahiTasks.span("Validation error").click();
		Assert.assertTrue(sahiTasks.div(expectedError1).exists(), "Verified expected error - " + expectedError1);
		if (sahiTasks.button("OK").exists())
			sahiTasks.button("OK").click();
		else
			if (sahiTasks.button("Cancel").exists())
				sahiTasks.button("Cancel").click();
		sahiTasks.span("undo").near(sahiTasks.textbox("ipausersearchfields")).click();
	}
	
	public static void setGroupConfigValue(SahiTasks sahiTasks, CommonTasks commonTasks, String group) {
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		if (!sahiTasks.link(group).exists())
			GroupTasks.addGroup(sahiTasks, group, group);
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		
		
		sahiTasks.span("icon combobox-icon").click();
		sahiTasks.select("list").choose(group);
		
		//sahiTasks.textbox("ipadefaultprimarygroup").setValue(group);
		sahiTasks.span("Update").click();
	}
	
	public static void setMigrationModeConfigValue(SahiTasks sahiTasks, String mode) {
		if (mode.equals("enable") && (!sahiTasks.checkbox("ipamigrationenabled").checked()) )
			sahiTasks.checkbox("ipamigrationenabled").click();
		if (mode.equals("disable") && (sahiTasks.checkbox("ipamigrationenabled").checked()) )
			sahiTasks.checkbox("ipamigrationenabled").click();
		sahiTasks.span("Update").click();
		
	}
	
	public static void verifyMigrationModeConfigValue(SahiTasks sahiTasks, String mode) {
		if (mode.equals("enable"))
			Assert.assertTrue(sahiTasks.checkbox("ipamigrationenabled").checked(), "Verified Migration mode is enabled");
		else
			Assert.assertFalse(sahiTasks.checkbox("ipamigrationenabled").checked(), "Verified Migration mode is disabled");
	}
	
	/*
	 * Verify the search size limit brings back the expected number of entries
	 */
	
// NOTE : In search size limit is set to be 5 With 10 users added, go to user page, and expect only 5 to be listed...but all 10 are listed.
	//https://bugzilla.redhat.com/show_bug.cgi?id=818985
	
	/*public static void verifySearchSizeLimitFunctional(SahiTasks sahiTasks, CommonTasks commonTasks, String value, String expectedRows) {
		sahiTasks.navigateTo(commonTasks.userPage, true);
		if (value.equals(expectedRows)){
			Assert.assertTrue(sahiTasks.span("Query returned more results than the configured size limit. Displaying the first " + value + 
					" results.").exists(), "Verified number of users returned is " + value);
		}
		else
		{
			Assert.assertTrue(sahiTasks.span(expectedRows + " users matched").exists(), "Verified number of users returned is " + expectedRows);
		}
		sahiTasks.navigateTo(commonTasks.hbacPage);
		if (value.equals(expectedRows))
			Assert.assertTrue(sahiTasks.span("Query returned more results than the configured size limit. Displaying the first " + value + " results.").exists(), "");
		else
			Assert.assertTrue(sahiTasks.span(expectedRows + " HBAC rules matched").exists(), "");
		
		sahiTasks.navigateTo(commonTasks.configurationPage);
	}*/
	
	/*
	 * Verify search brings back users based on set search field
	 *
	 */
	
	public static void verifyUserSearchFieldFunctional(SahiTasks sahiTasks, CommonTasks commonTasks, String searchValue, String expectedUser) {
		sahiTasks.navigateTo(commonTasks.userPage);
		CommonTasks.search(sahiTasks, searchValue);				
		Assert.assertTrue(sahiTasks.checkbox(expectedUser).exists(), "Searched successfully for " + expectedUser);
		
		CommonTasks.clearSearch(sahiTasks);
		sahiTasks.navigateTo(commonTasks.configurationPage);
	}
	
	
	/*
	 * Verify search brings back groups based on set search field
	 *
	 */
	
	public static void verifyGroupSearchFieldFunctional(SahiTasks sahiTasks, CommonTasks commonTasks, String searchValue, String expectedGroup) {
		sahiTasks.navigateTo(commonTasks.groupPage);
		CommonTasks.search(sahiTasks, searchValue);				
		Assert.assertTrue(sahiTasks.checkbox(expectedGroup).exists(), "Searched successfully for " + expectedGroup);
		
		CommonTasks.clearSearch(sahiTasks);
		sahiTasks.navigateTo(commonTasks.configurationPage);
	}
	
	/*
	 * Verify default domain for user's email is as set in default email domain field
	 *
	 */
	
	public static void verifyUserEmailFunctional(SahiTasks sahiTasks, CommonTasks commonTasks, String email, String user) {
		sahiTasks.navigateTo(commonTasks.userPage);
		//add an email for this user
		sahiTasks.link(user).click();
		sahiTasks.link("Add").near(sahiTasks.label("Email address:")).click();
		//do not specify domain
		sahiTasks.textbox("mail-0").setValue(user);
		sahiTasks.link("Update").click();
		
		//verify default domain is picked
		if (email.isEmpty())
			Assert.assertEquals(sahiTasks.textbox("mail-0").value(), user, "Verified mail for user " + user + ": " + user);
		else
			Assert.assertEquals(sahiTasks.textbox("mail-0").value(), user + "@" + email, "Verified mail for user " + user + ": " + user + "@" + email);
		
		//delete this email for next test
		sahiTasks.link("Delete").click();
		sahiTasks.link("Update").click();
		
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
		
		sahiTasks.navigateTo(commonTasks.configurationPage);
	}
	
	
	/*
	 * Verify default group for user is as set in config
	 *
	 */
	
	public static void verifyUserGroupFunctional(SahiTasks sahiTasks, CommonTasks commonTasks, String group, String user) {
		sahiTasks.navigateTo(commonTasks.userPage);
		UserTasks.createUser(sahiTasks, user, user, user, "Add");
		//add an email for this user
		sahiTasks.link(user).click();		
		CommonTasks.verifyMemberOf(sahiTasks, user, "User", "User Groups", group, "direct", true);	
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
		UserTasks.deleteUser(sahiTasks, user);
		
		sahiTasks.navigateTo(commonTasks.configurationPage);
	}
	
	

	/*
	 * Verify default group for user cannot be deleted
	 *
	 */
	
	public static void verifyDeleteDefaultUserGroup(SahiTasks sahiTasks, CommonTasks commonTasks, String group) {
		sahiTasks.navigateTo(commonTasks.groupPage);
		GroupTasks.deleteGroup(sahiTasks, group);
		String expectedError = "The default users group cannot be removed";
		CommonTasks.checkOperationsError(sahiTasks, expectedError);
		sahiTasks.navigateTo(commonTasks.configurationPage);
	}
	
	
	/*
	 * Verify home dir for user is as set in config
	 *
	 */
	
	public static void verifyUserHomeDirFunctional(SahiTasks sahiTasks, CommonTasks commonTasks, String homedir, String user) {
		sahiTasks.navigateTo(commonTasks.userPage);
		UserTasks.createUser(sahiTasks, user, user, user, "Add");
		//add an email for this user
		sahiTasks.link(user).click();	
		Assert.assertEquals(sahiTasks.textbox("homedirectory").value(), homedir + "/" + user, "Verified  Home directory for user " + user + ": " + homedir);
		sahiTasks.link("Users").in(sahiTasks.div("content")).click();
		UserTasks.deleteUser(sahiTasks, user);
		
		sahiTasks.navigateTo(commonTasks.configurationPage);
	}
	
	/*
	 * Verify max name length for user is as set in config
	 *
	 */
	
	public static void verifyUserNameLengthFunctional(SahiTasks sahiTasks, CommonTasks commonTasks, String nameLength, String userGood, String userBad) {
		sahiTasks.navigateTo(commonTasks.userPage);
		UserTasks.createUser(sahiTasks, userGood, userGood, userGood, "Add");
		//add an email for this user
		Assert.assertTrue(sahiTasks.link(userGood).exists(), "Verified " + userGood + " was added successfully");
		
		//TODO: nkrishnan: what is the max length, if set to blank? 
		if (!nameLength.isEmpty()) {
			UserTasks.createUser(sahiTasks, userBad, userBad, userBad, "Add");
			
			String expectedError = "invalid 'login': can be at most " + nameLength + " characters";
			Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding invalid user " + userBad);
			sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
			log.fine("cancel");
			sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
		}
		
		
		UserTasks.deleteUser(sahiTasks, userGood);
		
		sahiTasks.navigateTo(commonTasks.configurationPage);
	}
	
	public static void modifyAndVerifyConfigValues(SahiTasks sahiTasks, String field, String value, String buttonToClick) {
		String originalValue = sahiTasks.textbox(field).getValue();
		sahiTasks.textbox(field).setValue(value);
		
		if(buttonToClick.equals("undo"))
				 
			
		{
			sahiTasks.span("undo").near(sahiTasks.textbox("ipadefaultemaildomain")).click();
		}
		
		sahiTasks.span(buttonToClick).click();
		//buttonToClick is either Undo or Reset...so verify value is reverted
		Assert.assertEquals(sahiTasks.textbox(field).value(), originalValue, "Verified config value for " + field + "  is " + originalValue);
	}
	
	
	public static void restoreDefaults(SahiTasks sahiTasks, CommonTasks commonTasks) {
	    ConfigurationTasks.setConfigValue(sahiTasks, "ipasearchrecordslimit", "100");
	    ConfigurationTasks.setConfigValue(sahiTasks, "ipasearchtimelimit", "2");
	    ConfigurationTasks.setConfigValue(sahiTasks, "ipausersearchfields", "uid,givenname,sn,telephonenumber,ou,title");
	    ConfigurationTasks.setConfigValue(sahiTasks, "ipadefaultemaildomain", "testrelm");
	    ConfigurationTasks.setGroupConfigValue(sahiTasks, commonTasks, "ipausers");
	    ConfigurationTasks.setConfigValue(sahiTasks, "ipahomesrootdir", "/home");
	    ConfigurationTasks.setConfigValue(sahiTasks, "ipamaxusernamelength", "32");
	    ConfigurationTasks.setConfigValue(sahiTasks, "ipapwdexpadvnotify", "4");
	    ConfigurationTasks.setConfigValue(sahiTasks, "ipagroupsearchfields", "cn,description");
	}
		

	
}
