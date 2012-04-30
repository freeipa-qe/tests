package com.redhat.qe.ipa.sahi.tests.rbac;

import java.util.logging.Logger;

import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.PermissionTasks;
import com.redhat.qe.ipa.sahi.tasks.PrivilegeTasks;
import com.redhat.qe.ipa.sahi.tasks.RoleTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

public class RBACFunctional extends SahiTestScript {
	private static Logger log = Logger.getLogger(RoleTasks.class.getName());
	private String currentPage = "";
	private String alternateCurrentPage = "";

	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.setStrictVisibilityCheck(true);
		sahiTasks.navigateTo(commonTasks.rolePage, true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&privilege-facet=search" ;		
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.rolePage, true);
		}		
	}
	
	/*
	 * Scenario 1: Add a Host
	 *  get its keytab. 
	 *  kinit as this host
	 *  add a user - fails
	 *  kinit back as admin
	 *  assign a role to thi shost that allows it to add users
	 *  add a user - passes
	 */		
	@Test (groups={"hostAddsUser"}, description="Host has a role to add user", 
			dataProvider="hostAddsUserTestObjects")	
	public void testHostAddsUser(String testName, String roleName, String roleDescription, String privilege, String hostName) throws Exception {		
		//add host		
		log.info("Adding new host");
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		String domain = System.getProperty("ipa.server.domain");
		String fqdn = hostName + "." + domain;
		String ipadr = "";		
		if (!sahiTasks.link(fqdn.toLowerCase()).exists())
			HostTasks.addHost(sahiTasks, hostName, commonTasks.getIpadomain(), ipadr);
		
		log.info("Exceute ipa-getkeytab");
		//ipa-getkeytab -s rhel63-server.testrelm.com -p host/rolehost.testrelm.com@TESTRELM.COM -k /tmp/testrole.keytab 
		String keytabFile="/tmp/testrole.keytab";
		String ipaGetkeytabCommand=" ipa-getkeytab -s " + System.getProperty("ipa.server.fqdn") + " -p host/" + fqdn.toLowerCase() 
		+ "@" + System.getProperty("ipa.server.realm") + " -k " + keytabFile;
		CommonTasks.executeIPACommand(ipaGetkeytabCommand);
		
		log.info("kinit as host using keytab");
		//kinit -k -t /tmp/testrole.keytab  host/rolehost.testrelm.com@TESTRELM.COM
		String ipaKinitCommand="kinit -k -t " + keytabFile + " host/" + fqdn.toLowerCase() + "@" + System.getProperty("ipa.server.realm");
		CommonTasks.executeIPACommand(ipaKinitCommand);
		
		log.info("logout, and return to main page");
		sahiTasks.link("Logout").click();
	    sahiTasks.link("Return to main page.").click();
	    
	    //As a host logged in, no UI is displayed...so the below is not valid..will run this test in CLI...but keeping it here for now
		sahiTasks.navigateTo(commonTasks.userPage, true);
		
		//verify role doesn't exist
		Assert.assertFalse(sahiTasks.link(roleName).exists(), "Verify role " + roleName + " doesn't already exist");
		
		//new role can be added now
		sahiTasks.navigateTo(commonTasks.rolePage, true);
		RoleTasks.addRole(sahiTasks, roleName, roleDescription, "Add");
		
		//verify 
		
	}
	
	
	/*
	 * Bug 785152
	 */
	@Test (groups={"dnsUpdateAdmin"}, description="Bug 785152 - User with permission to update dnsrecord, cannot open it", 
			dataProvider="dnsUpdateAdminTestObjects")
			//, dependsOnGroups="permissionAddSubtreeTests")	
	public void testDNSUpdateAdmin(String testName, String permissionName, String privilegeName, String privilegeDescription,
			String roleName, String roleDescription, String userName) throws Exception {		
		//Add privilege with permission
		sahiTasks.navigateTo(commonTasks.privilegePage, true);
		log.info("Add Privilege");
		String permissions[] = {permissionName};
		PrivilegeTasks.addPrivilegeAddMembers(sahiTasks, privilegeName, privilegeDescription, "Permissions", permissionName, permissions, "Add");
		
		//Add Role with privilege
		sahiTasks.navigateTo(commonTasks.rolePage, true);
		log.info("Add Role");
		String privileges[] = {privilegeName};
		RoleTasks.addRoleAddPrivileges(sahiTasks, roleName, roleDescription, privilegeName, privileges, "Add");	
		 
		//Add user
		sahiTasks.navigateTo(commonTasks.userPage, true);
		log.info("Add User");
		String password=userName;
		UserTasks.createUser(sahiTasks, userName, userName, userName, password, password, "Add");	
		
		//Add user to Role
		sahiTasks.navigateTo(commonTasks.rolePage, true);
		log.info("Add User to Role");
	    RoleTasks.addMemberToRole(sahiTasks, roleName, "User", userName);

	    String newPassword="Secret123";
	    log.info("Kinit as " + userName );
	    CommonTasks.kinitAsNewUserFirstTime(userName, password, newPassword);
	    
	    sahiTasks.link("Logout").click();
	    sahiTasks.link("Return to main page.").click();
	    Assert.assertEquals("Logged In As: " + userName + " " + userName,sahiTasks.link("Logged In As: " + userName +  " " + userName).text(), 
	    		"User logged in as expected: " + userName);
	    
	
		//Verify bug
		sahiTasks.navigateTo(commonTasks.dnsPage, true);
		Assert.assertFalse(sahiTasks.span("Error: IPA Error 3007").exists(), "No error when going to DNS Page");
		Assert.assertFalse(sahiTasks.link(System.getProperty("ipa.server.domain")).exists(), "No zone listed for " 
				+ System.getProperty("ipa.server.domain"));
	
		CommonTasks.kinitAsAdmin();
		sahiTasks.link("Logout").click();
	    sahiTasks.link("Return to main page.").click();
	}
	
	
	/*
	 * Bug 807361
	 */
	@Test (groups={"dnsListZone"}, description="Bug 807361 - DNS records in LDAP are publicly accessible", 
			dataProvider="dnsListZoneTestObjects", dependsOnGroups="dnsUpdateAdmin")	
	public void testDNSListZone(String testName, String permissionName, String privilegeName,
			String roleName, String userName) throws Exception {
	
	    
		log.info("Add Permission - read dns entries");	
		sahiTasks.navigateTo(commonTasks.privilegePage, true);
		String permissions[] = {permissionName};
		PrivilegeTasks.addMembersToPrivilege(sahiTasks, privilegeName, "Permissions", permissionName, permissions, "Add");
		
		
		String password="Secret123";
		CommonTasks.kinitAsUser(userName, password);
		sahiTasks.link("Logout").click();
	    sahiTasks.link("Return to main page.").click();
	    Assert.assertEquals("Logged In As: " + userName + " " + userName,sahiTasks.link("Logged In As: " + userName + " " + userName).text(),
	    		"User logged in as expected: " + userName);
	  //Verify bug
		sahiTasks.navigateTo(commonTasks.dnsPage, true);
		Assert.assertTrue(sahiTasks.link(System.getProperty("ipa.server.domain")).exists(), "Expected zone listed for " 
				+ System.getProperty("ipa.server.domain"));
		Assert.assertTrue(sahiTasks.link(System.getProperty("ipa.server.reversezone")).exists(), "Expected zone listed for " 
				+ System.getProperty("ipa.server.reversezone"));
		
		CommonTasks.kinitAsAdmin();
		sahiTasks.link("Logout").click();
	    sahiTasks.link("Return to main page.").click();
		
	}
	
	/*
	 * Cleanup after tests are run
	 */
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException {
		sahiTasks.navigateTo(commonTasks.permissionPage, true);
		String[] permissionTestObjects = {"Manage DNSRecord1"				
		};
		for (String permissionTestObject : permissionTestObjects) {
			log.fine("Cleaning Permission: " + permissionTestObject);
			PermissionTasks.deletePermission(sahiTasks, permissionTestObject, "Delete");
		} 
		
		sahiTasks.navigateTo(commonTasks.privilegePage, true);
		String[] privilegeTestObjects = {"TestPrivilegeDNS"				
		};
		for (String privilegeTestObject : privilegeTestObjects) {
			log.fine("Cleaning Privilege: " + privilegeTestObject);
			PrivilegeTasks.deletePrivilege(sahiTasks, privilegeTestObject, "Delete");
		} 
		
		
		sahiTasks.navigateTo(commonTasks.rolePage, true);
		String[] roleTestObjects = {"TestRoleDNS"				
		};
		for (String roleTestObject : roleTestObjects) {
			log.fine("Cleaning Role: " + roleTestObject);
			RoleTasks.deleteRole(sahiTasks, roleTestObject, "Delete");
		} 
		
		
		sahiTasks.navigateTo(commonTasks.userPage, true);
		String[] userTestObjects = {"testuserdns"				
		};
		for (String userTestObject : userTestObjects) {
			log.fine("Cleaning Role: " + userTestObject);
			UserTasks.deleteUser(sahiTasks, userTestObject);
		} 
		
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	/*
	 * Data to be used when adding roles
	 */		
	@DataProvider(name="hostAddsUserTestObjects")
	public Object[][] gethostAddsUserTestObjects() {
		String[][] roles={
        //	testname			Role Name		Role Description  	Privilege				Host Name 			
		{ "host_add_user",		"TestRole1",	"TestRole1",		"User Administrators",	"testhost"	}
		};
        
		return roles;	
	}
	
	/*
	 * Data to be used when testing bug 785152
	 */		
	@DataProvider(name="dnsUpdateAdminTestObjects")
	public Object[][] getdnsUpdateAdminTestObjects() {
		String[][] roles={
		// testName			permissionName	 		privilegeName	 	privilegeDescription 	roleName 		roleDescription		userName
		{ "dnsUpdateAdmin",	"Manage DNSRecord1",	"TestPrivilegeDNS",	"TestPrivilegeDNS",	  	"TestRoleDNS", 	"TestRoleDNS",		"testuserdns"	}
		};
        
		return roles;	
	}
	
	/*
	 * Data to be used when testing bug 807361
	 */		
	@DataProvider(name="dnsListZoneTestObjects")
	public Object[][] getdnsListZoneTestObjects() {
		String[][] roles={
		// testName			permissionName	 		privilegeName	 	 	roleName 			userName
		{ "dnsUpdateAdmin",	"Read DNS Entries",		"TestPrivilegeDNS",	  	"TestRoleDNS", 		"testuserdns"	}
		};
        
		return roles;	
	}
	
}
