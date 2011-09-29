package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;

public class ConfigurationTasks {
	private static Logger log = Logger.getLogger(ConfigurationTasks.class.getName());
	
	
	
	public static void setConfigValue(SahiTasks sahiTasks, String field, String value) {
		sahiTasks.textbox(field).setValue(value);
		sahiTasks.span("Update").click();
	}
	
	public static void verifyConfigValue(SahiTasks sahiTasks, String field, String value) {
		Assert.assertEquals(sahiTasks.textbox(field).value(), value, "Verified config value for " + field + "  is " + value);
	}
	
	public static void setInvalidConfigValue(SahiTasks sahiTasks, String field, String value, String expectedError1, String expectedError2) {
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
		sahiTasks.span("undo").click();
	}
	
	/*
	 * Verify the search size limit brings back the expected number of entries
	 */
	public static void verifySearchSizeLimitFunctional(SahiTasks sahiTasks, CommonTasks commonTasks, String value, String expectedRows) {
		sahiTasks.navigateTo(commonTasks.userPage);
		if (value.equals(expectedRows))
			Assert.assertTrue(sahiTasks.span("Query returned more results than the configured size limit. Displaying the first " + value + " results.").exists(), "");
		else
			Assert.assertTrue(sahiTasks.span(expectedRows + " users matched").exists(), "");
		
		sahiTasks.navigateTo(commonTasks.hbacPage);
		if (value.equals(expectedRows))
			Assert.assertTrue(sahiTasks.span("Query returned more results than the configured size limit. Displaying the first " + value + " results.").exists(), "");
		else
			Assert.assertTrue(sahiTasks.span(expectedRows + " HBAC rules matched").exists(), "");
		
		sahiTasks.navigateTo(commonTasks.configurationPage);
	}
	
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
	
	
}
