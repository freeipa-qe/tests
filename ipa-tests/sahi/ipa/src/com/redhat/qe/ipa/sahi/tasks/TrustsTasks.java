package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;


public class TrustsTasks {
	private static Logger log = Logger.getLogger(TrustsTasks.class.getName());
	
	/*
	 * @param sahiTasks
	 * @param relamName - the realmName of Trust to be add
	 * @param account - Account for Administrative
	 * @param Password - Password for Administrative
	 */
	
	public static void addTrusts(SahiTasks sahiTasks, String realmName,String account,String password,String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("realm_server").setValue(realmName);
		sahiTasks.radio("method_admin-account").click();
		sahiTasks.textbox("realm_admin").setValue(account);
		sahiTasks.password("realm_passwd").setValue(password);
		sahiTasks.button(buttonToClick).click();
		
	}
	
	/*
	 * @param sahiTasks
	 * @param relamName - the realmName of Trust to be add
	 * @param account - Account for Administrative
	 * @param Password - Password for Administrative
	 */
	public static void addNegativeTrusts(SahiTasks sahiTasks, String realmName, String account,String password,String expectedError,String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("realm_server").setValue(realmName);
		sahiTasks.radio("method_admin-account").click();
		sahiTasks.textbox("realm_admin").setValue(account);
		sahiTasks.password("realm_passwd").setValue(password);
		sahiTasks.button(buttonToClick).click();
		if (sahiTasks.span(expectedError).exists())
		{
			log.info ("Required field msg appears, usually this means missing data input");
			sahiTasks.button("Cancel").click();
			
		}
		 else if (sahiTasks.div(expectedError).exists())
		{
			log.info("IPA error dialog appears:: ExpectedError ::"+expectedError);
			// there will be two cancel button here
			sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
			sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
			
		}
	}
	
	/*
	 * @param sahiTasks
	 * @param firstRealmName - the firstrealmName of Trust to be add
	 * @param firstAccount - Account for first Administrative
	 * @param firstPassword - Password for first Administrative
	 * @param firstButtonToClick - Add and Another
	 * @param secondRealmName - the secondrealmName of Trust to be add
	 * @param secondAccount - Account for second Administrator
	 * @param secondPassword - Password for second Administrator
	 * @param secondButtonToClick - Add
	 * 
	 */
	
	public static void addAndAddAnotheTrusts(SahiTasks sahiTasks, String firstRealmName, String firstAccount,String firstPassword,String firstButtonToClick,String secondRealmName, String secondAccount,String secondPassword,String secondButtonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("realm_server").setValue(firstRealmName);
		sahiTasks.radio("method_admin-account").click();
		sahiTasks.textbox("realm_admin").setValue(firstAccount);
		sahiTasks.password("realm_passwd").setValue(firstPassword);
		sahiTasks.button(firstButtonToClick).click();	
		sahiTasks.textbox("realm_server").setValue(secondRealmName);
		sahiTasks.radio("method_admin-account").click();
		sahiTasks.textbox("realm_admin").setValue(secondAccount);
		sahiTasks.password("realm_passwd").setValue(secondPassword);
		sahiTasks.button(secondButtonToClick).click();	
	}
	
	/*
	 * @param sahiTasks
	 * @param RealmName - the firstrealmName of Trust to be add
	 * @param domainNBName - Domain NetBIOS name of the trust 
	 * @param domainSecurity- Domain Security Identifier of the trust
	 * @param trustDirection- Trust direction of the trust
	 * @param trustType- Trust type of the trust
	 */
	public static void VerifySetting(SahiTasks sahiTasks, String realmName, String domainNBName,String domainSecurity,String trustDirection,String trustType ) {
		Assert.assertTrue(sahiTasks.label(realmName).exists(),"Verified RealmName");
		Assert.assertTrue(sahiTasks.label(domainNBName).exists(),"Verified Domain NetBIOS name");
		Assert.assertTrue(sahiTasks.label(domainSecurity).exists(),"Verified Domain Security Identifier");
		Assert.assertTrue(sahiTasks.label(trustDirection).exists(),"Verified Trust direction");
		Assert.assertTrue(sahiTasks.label(trustType).exists(),"Verified Trust type");
		sahiTasks.link("Trusts").near(sahiTasks.div("facet")).click();
	}
	
	/*
	 * Expand And Collapse Test
	 * @param sahiTasks
	 * @param RealmName - the firstrealmName of Trust to be add
	 */
	public static void expandCollapseTest(SahiTasks sahiTasks){
		sahiTasks.span("Collapse All").click();
		sahiTasks.waitFor(2000);
		//Verify no data is visible
		Assert.assertFalse(sahiTasks.label("Realm name:").isVisible(),"No Trust settings is visible");
		sahiTasks.span("Expand All").click();
		sahiTasks.waitFor(2000);
		Assert.assertTrue(sahiTasks.label("Realm name:").isVisible(),"All Trust settings is visible Now");
		sahiTasks.heading2("Trust Settings").click();
		sahiTasks.waitFor(2000);
		Assert.assertFalse(sahiTasks.label("Realm name:").isVisible(),"No Trust settings is visible");
		sahiTasks.heading2("Trust Settings").click();
		sahiTasks.waitFor(2000);
		Assert.assertTrue(sahiTasks.label("Realm name:").isVisible(),"All Trust settings is visible Now");
		sahiTasks.link("Trusts").near(sahiTasks.div("facet")).click();
	}
	
	
	/*
	 * Delete the trust. Check if realmName is available for deleting before calling this.
	 * @param sahiTasks
	 * @param relamName - the realmName of Trust to be deleted
	 */
	public static void deleteTrusts(SahiTasks sahiTasks, String realmName,String buttonToClick) {
		if(sahiTasks.link(realmName).exists())
		{
			sahiTasks.checkbox(realmName).click();
			sahiTasks.span("Delete").click();
			sahiTasks.button(buttonToClick).click();
			if (buttonToClick.equals("Cancel")) 
			{
			sahiTasks.checkbox(realmName).click();
			}
			
			
		}
	}
	
	
	
	
}