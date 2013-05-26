package com.redhat.qe.ipa.sahi.tests.globalization;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.AutomemberTasks;
import com.redhat.qe.ipa.sahi.tasks.AutomountTasks;
import com.redhat.qe.ipa.sahi.tasks.CommonHelper;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.DNSTasks;
import com.redhat.qe.ipa.sahi.tasks.DelegationTasks;
import com.redhat.qe.ipa.sahi.tasks.GlobalizationTasks;
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.HBACTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.NetgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.PrivilegeTasks;
import com.redhat.qe.ipa.sahi.tasks.RoleTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.SelinuxUserMapTasks;
import com.redhat.qe.ipa.sahi.tasks.ServiceTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;
import com.redhat.qe.ipa.sahi.tests.automember.AutomemberUserGroupTests;
import com.redhat.qe.ipa.sahi.tests.dns.DNSTests;
public class Globalization extends SahiTestScript{
	private static Logger log = Logger.getLogger(Globalization.class.getName());
	private String domain = "";
	private String currentPage = "";
	private String alternateCurrentPage = "";
	private String mytesthost = "";
	private String realm = "";
	private String reversezone = "";
	private String groupname="globalizationgroup";
	private String hostgroup="globalizationgroup";
	public static String nameserver1="";
	public static String nameserver2="";
	public static String nameserver="";


	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.setStrictVisibilityCheck(true);
		domain = commonTasks.getIpadomain();
		mytesthost = "globalizationhost" + "." + domain;
		realm = domain.toUpperCase();

		sahiTasks.navigateTo(commonTasks.hostPage, true);
		//add host and service
		reversezone = commonTasks.getReversezone();
		String [] dcs = reversezone.split("\\.");
		String ipprefix = dcs[2] + "." + dcs[1] + "." + dcs[0] + ".";
		String ipaddr1 = ipprefix + "199";

		HostTasks.addHost(sahiTasks, "globalizationhost", domain, ipaddr1);

		nameserver1=CommonTasks.getIpafqdn();
		nameserver2=".";
		nameserver=nameserver1.concat(nameserver2);
		//delete user groups
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		String groupDescription = groupname + " description";
		GroupTasks.addGroup(sahiTasks, groupname, groupDescription);				
		//delete host groups
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		String description = hostgroup + " description";
		HostgroupTasks.addHostGroup(sahiTasks, hostgroup, description, "Add");

	}	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		HostTasks.deleteHost(sahiTasks, mytesthost, "YES");
		//delete user groups
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		GroupTasks.deleteGroup(sahiTasks, groupname);
		//delete host groups
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		HostgroupTasks.deleteHostgroup(sahiTasks, hostgroup,"Delete");


	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~IDENTITY USER~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

	@Test (groups={"userTests_Add"}, description="Add valid users",
			dataProvider="getUserTestObjects")	
	public void testUseradd(String testName, String uid, String givenname, String sn, String newPassword, String verifyPassword, String expectedmsg ) throws Exception{
		sahiTasks.navigateTo(commonTasks.userPage, true);
		String expectedUID=uid;
		if (uid.length() == 0) {
			expectedUID=(givenname.substring(0,1)+sn).toLowerCase();
			log.fine("ExpectedUID: " + expectedUID);}		
		//new user can be added now
		UserTasks.createUser(sahiTasks, uid, givenname, sn, newPassword, verifyPassword, "Add");		
		if(testName.endsWith("negative"))
		{
			if (sahiTasks.span(expectedmsg).exists())
			{	log.info ("Required field msg appears :: ExpectedError ::"+expectedmsg);
			sahiTasks.button("Cancel").click();}
			else if (sahiTasks.div(expectedmsg).exists())
			{
				log.info("IPA error dialog appears:: ExpectedError ::"+expectedmsg);
				// there will be two cancel button here
				sahiTasks.button("Cancel").click();
				sahiTasks.button("Cancel").click();				
			}
			Assert.assertFalse(sahiTasks.link(expectedUID).exists(), "User ID or Password rejected UTF-8 string");}
		else
			//verify user was added successfully with UTF-8 string
			Assert.assertTrue(sahiTasks.link(expectedUID).exists(), "Added user " + expectedUID + "  successfully with UTF-8 string");
	}

	@Test (groups={"user_modify"}, description="Add valid users",
			dataProvider="getUserSettingObjects",dependsOnGroups={"userTests_Add"})	
	public void userModify(String testName, String uid, String givenname, String sn, String initials, String street, String city, String state, String carlicense ) throws Exception 
	{
		GlobalizationTasks.modifyUserSettings(sahiTasks,uid, givenname, sn, initials, street, city, state, carlicense);
		GlobalizationTasks.verifyUserSettings(sahiTasks, uid, givenname, sn, initials, street, city, state, carlicense);
	}

	@Test (groups={"user_modify_negative"}, description="add homedirectory with UTF-8 string",
			dataProvider="getNegativeUserSettingObjects", dependsOnGroups={"userTests_Add","user_modify"})
	public void userModifyNegative(String testname,String uid, String homedir, String expectedmsg) throws Exception
	{
		GlobalizationTasks.modifyNegativeUserSetting(sahiTasks, uid, homedir, expectedmsg);

	}
	/*
	 * Delete users
	 */
	@Test (groups={"userTests_Delete"}, dataProvider="getUserDeleteObjects", 
			dependsOnGroups={"userTests_Add","user_modify_negative","user_modify"})
	public void testUserDelete(String testName, String uid) throws Exception {
		//verify user to be deleted exists
		Assert.assertTrue(sahiTasks.link(uid).exists(), "Verify user " + uid + "  to be deleted exists");
		//modify this user
		UserTasks.deleteUser(sahiTasks, uid);
		//verify user is deleted
		Assert.assertFalse(sahiTasks.link(uid).exists(), "User " + uid + "  deleted successfully");
	}


	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~IDENTITY USER GROUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

	@Test (groups={"userGroup"}, dataProvider="groupObjects",
			description="add user group name with UTF-8 string for negative test and add discreption with UTF-8 string for positive test",dependsOnGroups={"userTests_Delete"})
	public void userGroup(String testName, String groupName, String groupDescription, String gid, String groupType,String expectedErrorMsg){
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		if(testName.startsWith("add")){
			GlobalizationTasks.userGroup_add(sahiTasks, groupName, groupDescription, gid, groupType,expectedErrorMsg);}
		if(testName.startsWith("delete")){
			Assert.assertTrue(sahiTasks.link(groupName).exists(),"before 'Delete', group exists");
			GroupTasks.deleteGroup(sahiTasks, groupName);
			Assert.assertFalse(sahiTasks.link(groupName).exists(),"after 'Delete', group successfully deleted");}
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~IDENTITY HOST~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//	
	@Test (groups={"host_Add"}, dataProvider="getHostTestObjects",dependsOnGroups={"userGroup"})	
	public void hostTest(String testName, String hostname, String hostdomain, String ipadr, String expectedError) throws Exception {
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		HostTasks.addInvalidHost(sahiTasks, hostname, hostdomain, ipadr, expectedError, false);
		log.info("host name rejected UTF-8 string");
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~IDENTITY HOST GROUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	@Test (groups={"hostGroup"}, dataProvider="getHostGroupObjects",dependsOnGroups={"host_Add"})	
	public void hostGroup(String testName, String groupName, String description,String expectedError) throws Exception {
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		//add new host group
		if(testName.endsWith("negative")){
			HostgroupTasks.addInvalidHostGroup(sahiTasks, groupName, description, expectedError);
		log.info("Host group rejected UTF-8 string");}
		else if(testName.endsWith("positive")){
			HostgroupTasks.addHostGroup(sahiTasks, groupName, description, "Add");
			log.info("Host group discreption accepted UTF-8 string");}
		else if(testName.startsWith("delete")){
			// verify host group exists
			Assert.assertTrue(sahiTasks.link(groupName).exists(), "Verify host group " + groupName + " exists");
			//delete host group
			HostgroupTasks.deleteHostgroup(sahiTasks, groupName, "Delete");
			Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify host group " + groupName + " was deleted successfully");
		}
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~IDENTITY NET GROUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

	@Test (groups={"netGroup"}, dataProvider="getNetGroupObjects",dependsOnGroups={"hostGroup"})	
	public void netGroup(String testName, String groupName, String description, String expectedError ) throws Exception {
		//add new net group
		sahiTasks.navigateTo(commonTasks.netgroupPage, true);
		if(testName.startsWith("add")){
			GlobalizationTasks.addNetGroup(sahiTasks, groupName, description, expectedError);}
		if(testName.startsWith("delete")){
			// verify host group exists
			Assert.assertTrue(sahiTasks.link(groupName).exists(), "Verify net group " + groupName + " exists");
			//delete net group
			NetgroupTasks.deleteNetgroup(sahiTasks, groupName, "Delete");
			Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify net group " + groupName + " was deleted successfully");
		}
	}

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~IDENTITY SERVICES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	@Test (groups={"service_Add"}, dataProvider="getServiceObjects",dependsOnGroups={"netGroup"})	
	public void serviceTest(String testName, String hostname, String servicename, String expectedError) throws Exception {
		sahiTasks.navigateTo(commonTasks.servicePage, true);
		ServiceTasks.addInvalidService(sahiTasks, hostname, servicename, expectedError, false);
		log.info("service rejected UTF-8 string");
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~IDENTITY DNS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	@Test (groups={"DNSZone_Add"}, dataProvider="getDNSZoneObjects",dependsOnGroups={"service_Add"} )	
	public void addDNSZone(String testName, String zoneName, String authoritativeNameserver, String rootEmail, String expectedError) throws Exception {
		sahiTasks.navigateTo(commonTasks.dnsPage, true);
		DNSTasks.addDNSzoneNegativeTest(sahiTasks, zoneName, authoritativeNameserver, rootEmail,expectedError); 
		log.info("DNS zone rejected UTF-8 string");
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~POLICY HBAC~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	//----HBAC RULE----//
	@Test (groups={"hbacRule"}, description="Add HBAC Rules",dataProvider="getHBACRuleObjects",dependsOnGroups={"DNSZone_Add"})	
	public void testHBACRule(String testName, String cn,String description) throws Exception {
		sahiTasks.navigateTo(commonTasks.hbacPage, true);
		if(testName.startsWith("add")){
			//verify rule doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Rule " + cn + " doesn't already exist");
			HBACTasks.addHBACRule(sahiTasks, cn, "Add");
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Added HBAC Rule " + cn + "  successfully with UTF-8 string");}
		if(testName.startsWith("modify")){
			GlobalizationTasks.modifyHBACRule(sahiTasks, cn, description);	}
		if(testName.startsWith("delete")){
			HBACTasks.deleteHBAC(sahiTasks, cn, "Delete");
			//verify user is deleted
			Assert.assertFalse(sahiTasks.link(cn).exists(), "HBAC Rule " + cn + "  deleted successfully");
		}
	}


	//----HBAC SERVICES----//
	@Test (groups={"hbacService"}, description="Add a HBACService",	dataProvider="getHBACServiceObjects",dependsOnGroups={"hbacRule"})	
	public void testHBACService(String testName, String cn, String description) throws Exception {
		sahiTasks.navigateTo(commonTasks.hbacServicePage, true);
		if(testName.startsWith("add")){
			//verify rule doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Service " + cn + " doesn't already exist");
			HBACTasks.addHBACService(sahiTasks, cn, description, "Add");
			Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Added HBAC Service " + cn + "  successfully with UTF-8 string");}
		if(testName.startsWith("delete")){
			HBACTasks.deleteHBAC(sahiTasks, cn, "Delete");
			//verify user is deleted
			Assert.assertFalse(sahiTasks.link(cn).exists(), "HBAC Service " + cn + "  deleted successfully");
		}
	}

	//----HBAC SERVICES GROUP----//
	@Test (groups={"hbacServiceGroup"}, description="Add a HBAC Service Group",	dataProvider="getHBACServiceGroupObjects",dependsOnGroups={"hbacService" })	
	public void testHBACServiceGroup(String testName, String cn, String description) throws Exception {
		sahiTasks.navigateTo(commonTasks.hbacServiceGroupPage, true);
		if(testName.startsWith("add")){
			//verify rule doesn't exist
			Assert.assertFalse(sahiTasks.link(cn.toLowerCase()).exists(), "Verify HBAC Service Group" + cn + " doesn't already exist");
			HBACTasks.addHBACService(sahiTasks, cn, description, "Add");
			Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Added HBAC Service Group " + cn + "  successfully with UTF8 string");}
		if(testName.startsWith("delete")){
			HBACTasks.deleteHBAC(sahiTasks, cn, "Delete");
			//verify user is deleted
			Assert.assertFalse(sahiTasks.link(cn).exists(), "HBAC Service Group " + cn + "  deleted successfully");	}
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~POLICY SUDO~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	//----SUDO RULE----//
	@Test (groups={"sudoRule"}, description="Add Sudo Rules",dataProvider="getSudoruleObjects",dependsOnGroups="hbacServiceGroup")
	public void testSudoRule(String testName, String cn,String description) throws Exception {		
		sahiTasks.navigateTo(commonTasks.sudoRulePage, true);
		if(testName.startsWith("add")){
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify sudorule " + cn + " doesn't already exist");
			//new sudo rule can be added now
			SudoTasks.createSudoRule(sahiTasks, cn, "Add");		
			//verify sudo rule was added successfully
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Added sudorule " + cn + "  successfully with UTF-8 string");}
		if(testName.startsWith("modify")){
			GlobalizationTasks.modifySudoRule(sahiTasks, cn, description);}
		if(testName.startsWith("delete")){
			SudoTasks.deleteSudo(sahiTasks, cn, "Delete");}
	}
	//-----SUDO COMMAND-----//
	@Test (groups={"sudoCommand"}, description="Add a Sudo Command",dataProvider="getSudoCommandObjects",dependsOnGroups="sudoRule")
	public void sudoCommand(String testName, String cn, String description) throws Exception {
		sahiTasks.navigateTo(commonTasks.sudoCommandPage, true);
		if(testName.startsWith("add")){
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify sudocommand " + cn + "  doesn't already exist");
			//new sudo rule command can be added now
			GlobalizationTasks.sudoCommandAdd(sahiTasks, cn, description, "Add");
			//verify sudo rule command was added successfully
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Added Sudorule Command " + cn + "  successfully with UTF-8 string");}
		if(testName.startsWith("delete")){
			SudoTasks.deleteSudo(sahiTasks, cn, "Delete");
			//verify sudo rule command was added successfully
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Sudorule Command " + cn + "  deleted successfully");
		}
	} 
	//-----SUDO COMMAND GROUP-----//
	@Test (groups={"sudoCommandGroup"},dataProvider="getSudoCommandGroupObjects",dependsOnGroups="sudoCommand")	
	public void sudoCommandGroup(String testName, String cn, String description) throws Exception {
		sahiTasks.navigateTo(commonTasks.sudoCommandGroupPage, true);
		if(testName.startsWith("add")){
			Assert.assertFalse(sahiTasks.link(cn.toLowerCase()).exists(), "Verify sudocommand group " + cn + "  doesn't already exist");
			SudoTasks.createSudoCommandGroupAdd(sahiTasks, cn, description, "Add");
			//verify sudo command group was added successfully
			Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Added Sudo Command Group" + cn + "  successfully with UTF-8 string");}
		if(testName.startsWith("delete")){
			//new sudo command group can be deleted now
			SudoTasks.deleteSudoCommandGroupDel(sahiTasks, cn, "Delete");
			//verify sudo rule command group was added successfully
			Assert.assertFalse(sahiTasks.link(cn.toLowerCase()).exists(), "Sudorule Command Group" + cn + "  deleted successfully");
		}				
	} 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~POLICY AUTOMOUNT~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	@Test (groups={"Automount"}, dataProvider="automountObject",	description = "add new automount location,map and key with UTF-8 string",dependsOnGroups="sudoCommandGroup")
	public void addAutomount(String testName,String automountLocation,String automountMap,String automountKey,String description,String exceptedError) throws Exception {  
		sahiTasks.navigateTo(commonTasks.automountPage, true);
		if(testName.contains("location_positive")){
			Assert.assertFalse(sahiTasks.link(automountLocation).exists(), "before add, automount location (" + automountLocation + ")should NOT exist in list");
			AutomountTasks.addAutomountLocation(sahiTasks, automountLocation);  
			Assert.assertTrue(sahiTasks.link(automountLocation).exists(), "Added automount location (" + automountLocation + ") successfully with UTF-8 string");}
		if(testName.contains("map_positive")){
			sahiTasks.link(automountLocation).click();
			Assert.assertFalse(sahiTasks.link(automountMap).exists(), "before add, automount map (" + automountMap + ")should NOT exist in list");
			GlobalizationTasks.AutomountMap(sahiTasks, automountMap,description,exceptedError);  
			Assert.assertTrue(sahiTasks.link(automountMap).exists(), "Added automount map (" + automountMap + ") successfully and description with UTF-8 string");
			sahiTasks.link("Automount Locations").in(sahiTasks.div("content")).click();}
		if(testName.contains("map_negative")){
			sahiTasks.link(automountLocation).click();
			GlobalizationTasks.AutomountMap(sahiTasks, automountMap,description,exceptedError); 
			Assert.assertFalse(sahiTasks.link(automountMap).exists(), "automount map rejected UTF-8 string");
			sahiTasks.link("Automount Locations").in(sahiTasks.div("content")).click();}
		if(testName.contains("key_negative")){
			sahiTasks.link(automountLocation).click();
			sahiTasks.link(automountMap).click();
			GlobalizationTasks.AutomountKey(sahiTasks, automountKey,description,exceptedError); 
			Assert.assertFalse(sahiTasks.link(automountKey).exists(), "automount key and info rejected UTF-8 string");
			sahiTasks.link("Automount Locations").in(sahiTasks.div("content")).click();}
		if(testName.startsWith("delete")){
			sahiTasks.navigateTo(commonTasks.automountPage, true);
			Assert.assertTrue(sahiTasks.link(automountLocation).exists(), "before delete, autoumount location (" + automountLocation + ")should exist in list");
			CommonHelper.deleteEntry(sahiTasks, automountLocation);  
			Assert.assertFalse(sahiTasks.link(automountLocation).exists(), "after delete, automount location (" + automountLocation + ") should NOT exist in list");}
	}

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~POLICY SELINUX USER MAP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	@Test (groups={"selinuxUserMap"}, dataProvider="getSelinuxUserMapObjects",dependsOnGroups="Automount")	
	public void selinuxUserMap(String testName, String rulename, String selinuxuser) throws Exception {
		sahiTasks.navigateTo(commonTasks.selinuxPage);
		if(testName.startsWith("add")){
			//Add an selinux user map
			Assert.assertFalse(sahiTasks.link(rulename).exists(), "Selinux user map for " + selinuxuser + " with rule " + rulename + " not found");
			SelinuxUserMapTasks.addSelinuxUserMap(sahiTasks, rulename, selinuxuser, "Add");
			log.info("SELinux User Map: Successfully Rule Name added with UTF-8 String");}
		if(testName.startsWith("delete")){
			SelinuxUserMapTasks.selinuxUserMapDeleteSingle(sahiTasks, rulename);
			Assert.assertFalse(sahiTasks.link(rulename).exists(), rulename + " deleted successfully");}
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~POLICY AUTOMEMBER~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	@Test (groups={"automember"},dataProvider="getAutomemberObjects",dependsOnGroups="selinuxUserMap")	
	public void testAutomember(String testName, String groupName,String description) throws Exception {
		if(testName.contains("automemberusergrouprule")){
			sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
			Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify automember " + groupName + " doesn't already exist");
			//Add automember
			GlobalizationTasks.Automember(sahiTasks, groupName,description);	
			sahiTasks.link("User group rules").in(sahiTasks.div("content nav-space-3")).click();
			//verify automember was added successfully 
			Assert.assertTrue(sahiTasks.link(groupName).exists(), "Added automember " + groupName + "  successfully with UTF-8 description");}
		if(testName.contains("delete_automemberusergroup")){
			CommonTasks.search(sahiTasks,groupName);
			Assert.assertTrue(sahiTasks.link(groupName).exists(),"automember rule exists before delete");
			AutomemberTasks.automember_DeleteSingle(sahiTasks,groupName);
			Assert.assertFalse(sahiTasks.link(groupName).exists(),"automember deleted");
			CommonTasks.clearSearch(sahiTasks);	}
		if(testName.contains("automemberhostgrouprule")){
			sahiTasks.navigateTo(commonTasks.automemberHostGroupPage, true);
			Assert.assertFalse(sahiTasks.link(hostgroup).exists(), "Verify automember " + hostgroup + " doesn't already exist");
			//Add automember
			GlobalizationTasks.Automember(sahiTasks, hostgroup,description);	
			sahiTasks.link("Host group rules").in(sahiTasks.div("content nav-space-3")).click();
			Assert.assertTrue(sahiTasks.link(hostgroup).exists(), "Added automember " + hostgroup + "  successfully with UTF-8 description");}
		if(testName.contains("delete_automemberhostgroup")){
			CommonTasks.search(sahiTasks,hostgroup);
			Assert.assertTrue(sahiTasks.link(hostgroup).exists(),"automember rule exists before delete");
			AutomemberTasks.automember_DeleteSingle(sahiTasks,hostgroup);
			Assert.assertFalse(sahiTasks.link(hostgroup).exists(),"automember deleted");
			CommonTasks.clearSearch(sahiTasks);	}
	}

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SERVICE RBAC~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	@Test (groups={"RBAC"}, description="Add Role",dataProvider="roleObjects",dependsOnGroups="automember")	
	public void testRBACRole(String testName, String name, String description) throws Exception {
		if(testName.contains("add_rbacrule")){
			sahiTasks.navigateTo(commonTasks.rolePage, true);
			//verify role doesn't exist
			Assert.assertFalse(sahiTasks.link(name).exists(), "Verify Role " + name + " doesn't already exist");
			//new role can be added now
			RoleTasks.addRole(sahiTasks, name, description, "Add");
			//verify role was added successfully
			CommonTasks.search(sahiTasks, name);
			Assert.assertTrue(sahiTasks.link(name).exists(), "Added Role " + name + "  successfully with UTF-8 string");
			CommonTasks.clearSearch(sahiTasks);}
		if(testName.contains("delete_rbacrule")){
			CommonTasks.search(sahiTasks, name);
			GlobalizationTasks.rbacDelete(sahiTasks,name,"Delete");
			Assert.assertFalse(sahiTasks.link(name).exists(),"rule deleted");
			CommonTasks.clearSearch(sahiTasks);		}
		if(testName.contains("add_rbacprivilege")){
			sahiTasks.navigateTo(commonTasks.privilegePage, true);
			//verify role doesn't exist
			Assert.assertFalse(sahiTasks.link(name).exists(), "Verify privilege " + name + " doesn't already exist");
			//new role can be added now
			PrivilegeTasks.addPrivilege(sahiTasks, name, description, "Add");
			//verify role was added successfully
			CommonTasks.search(sahiTasks, name);
			Assert.assertTrue(sahiTasks.link(name).exists(), "Added privilege " + name + "  successfully with UTF-8 string");
			CommonTasks.clearSearch(sahiTasks);}
		if(testName.contains("delete_rbacprivilege")){
			CommonTasks.search(sahiTasks, name);
			GlobalizationTasks.rbacDelete(sahiTasks,name,"Delete");
			Assert.assertFalse(sahiTasks.link(name).exists(),"privilege deleted");
			CommonTasks.clearSearch(sahiTasks);
		}
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SERVICE SELFSERVICE~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	@Test (groups={"selfservice"}, description="Add service",dataProvider="selfserviceObjects",dependsOnGroups="RBAC")	
	public void selfservice(String testName, String name, String cn,String expectedErrorMsg) throws Exception {
		sahiTasks.navigateTo(commonTasks.selfservicepermissionPage, true);
		Assert.assertFalse(sahiTasks.link(name).exists(), "Verify service " + name + " doesn't already exist");
		GlobalizationTasks.selfservice(sahiTasks,name,cn,expectedErrorMsg);
		Assert.assertFalse(sahiTasks.link(name).exists(), "service rejeced UTF-8 string");
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SERVICE DELEGATION~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	@Test (groups={"delegation"}, description=" Add and delete",dataProvider="getDelegationObjects",dependsOnGroups="selfservice")	
	public void testDelegation(String testName,String delegationName,String groupName,String memberGroup,String attribute) throws Exception {
		sahiTasks.navigateTo(commonTasks.delegationPage, true);
		if(testName.startsWith("add")){
			//verify delegation doesn't exist
			Assert.assertFalse(sahiTasks.link(delegationName).exists(), "Verify delegation " + delegationName + " doesn't already exist");
			//Add delegation : no permission checked,different group and member group,single attribute 
			DelegationTasks.delegation_AddSingle(sahiTasks,delegationName,groupName,memberGroup,attribute);		
			//verify delegation was added successfully 
			Assert.assertTrue(sahiTasks.link(delegationName).exists(), "Added delegation " + delegationName + "  successfully with UTF-8 string");}
		else{
			CommonTasks.search(sahiTasks,delegationName);
			Assert.assertTrue(sahiTasks.link(delegationName).exists(),"delegation rule exists before delete");
			DelegationTasks.delegation_DeleteSingle(sahiTasks,delegationName);
			Assert.assertFalse(sahiTasks.link(delegationName).exists(),"delegation rule not exist after delete");
			CommonTasks.clearSearch(sahiTasks);
		}
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SERVICE CONFIGURATION~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	@Test (groups={"configuration"}, description="Add configuration field",dataProvider="configurationObjects",dependsOnGroups="delegation")	
	public void testConfiguration(String testName, String fieldname, String fieldvalue,String expectedErrorMsg) throws Exception {
		sahiTasks.navigateTo(commonTasks.configurationPage, true);
		GlobalizationTasks.configuration(sahiTasks,fieldname,fieldvalue,expectedErrorMsg);
	}

	/***************************************************************************** 
	 *             Data providers                                                * 
	 *****************************************************************************/

	@DataProvider(name="getUserTestObjects")
	public Object[][] getUserTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserTestObjects());
	}
	protected List<List<Object>> createUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//										testname			uid              			givenname			sn   		newpassword 		verifypassword			exceptedmsg1
		ll.add(Arrays.asList(new Object[]{ "add_user_positive",   "user001",          			"ವರುಣ್",			   "ಮೈಲಾರಯ್ಯ",            "password",		        "password",         ""  } ));
		ll.add(Arrays.asList(new Object[]{ "add_user_negative",   "user001negative世界", 		"世界",				"世界",         "",					  "",               "may only include letters, numbers, _, -, . and $"	 } ));
		ll.add(Arrays.asList(new Object[]{ "add_user_password_negative","user2", 			   	"Test2",			"User2",	  "世界",	      	      "世界",            "Constraint violation: The value is not 7-bit clean: 世界"	 } ));
		return ll;	
	}

	@DataProvider(name="getUserSettingObjects")
	public Object[][] getUserSettingObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUserSettingObjects());
	}
	protected List<List<Object>> createUserSettingObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//		TestName,                  uid,         givenname,  sn,  initials,    street,       city,     state,     carLicense
		ll.add(Arrays.asList(new Object[]{ "modify_user_positive",   "user001",   "ಮೈಲಾರಯ್ಯ",   "ವರುಣ್",  "ಮವ",	     "ಸೂರ್ಯನ ಕಿರಣ109",   "ಬೆಂಗಳೂರು",   "ಕರ್ನಾಟಕ",      "ವಮ1122"  } ));
		return ll;	
	}
@DataProvider(name="getNegativeUserSettingObjects")
	public Object[][] getNegativeUserSettingObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createNegativeUserSettingObjects());
	}
	protected List<List<Object>> createNegativeUserSettingObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//	TestName,                  uid,         homedir,           exceptedmsg,  
		ll.add(Arrays.asList(new Object[]{ "modify_user_negative",       "user001",      "/home/变化",   "homeDirectory: value #0 invalid per syntax: Invalid syntax."  } ));
		return ll;	
	}

	/*
	 * Data to be used when deleting users
	 */
	@DataProvider(name="getUserDeleteObjects")
	public Object[][] getUserDeleteObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteUserTestObjects());
	}
	protected List<List<Object>> deleteUserTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//										testname					uid              		
		ll.add(Arrays.asList(new Object[]{ "delete_user_positive",			"user001"     } ));

		return ll;	
	}


	@DataProvider(name="groupObjects")
	public Object[][] groupObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createGroupObjects());
	}
	protected List<List<Object>> createGroupObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//                                 TestName,                     groupName,             groupDescription,       gid,       groupType,  			expectedErrorMsg        		
		ll.add(Arrays.asList(new Object[]{ "add_group_negative",		  "世界" ,         "adding usergroup with UTF-8 string", "800000001",  "normal",  "may only include letters, numbers, _, -, . and $"  } ));
		ll.add(Arrays.asList(new Object[]{ "add_group_positive",		  "usergroup001" , "UTF-8字符串Discreption",             "800000002",  "posix",  "No error msg"  } ));        
		ll.add(Arrays.asList(new Object[]{ "delete_group",		          "usergroup001","","","",""} ));
		return ll;	
	}
	@DataProvider(name="getHostTestObjects")
	public Object[][] getHostTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(HostTestObjects());
	}
	protected List<List<Object>> HostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//										testname				hostname  hostdomain ipaddr	expected_error
		ll.add(Arrays.asList(new Object[]{ "add_host_negative",		            "世界",		domain,"","invalid 'hostname': invalid domain-name: only letters, numbers, and - are allowed. DNS label may not start or end with -" } ));

		return ll;	
	}


	@DataProvider(name="getHostGroupObjects")
	public Object[][] getHostGroupObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostGroupTestObjects());
	}
	protected List<List<Object>> createHostGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//										testname						groupanme			description				    	error
		ll.add(Arrays.asList(new Object[]{ 		"add_hostgroup_negative",	     "余姚市",	  	 "add hostgroup with UTF-8 string", "may only include letters, numbers, _, -, and ." 	  } ));  
		ll.add(Arrays.asList(new Object[]{ 		"add_hostgroup_positive",	     "hostgroup001", "UTF-8字符串Discreption",           ""} ));
		ll.add(Arrays.asList(new Object[]{ 		"delete_hostgroup",		      	 "hostgroup001","",""} ));
		return ll;	
	}

	
	@DataProvider(name="getNetGroupObjects")
	public Object[][] getNetGroupObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddNetGroupObjects());
	}
	protected List<List<Object>> createAddNetGroupObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//										testname						groupanme			description					error
		ll.add(Arrays.asList(new Object[]{ 		"add_netgroup_negative",		"ಕರ್ನಾಟಕ",		      "adding new netgroup with UTF-8 ",	 "may only include letters, numbers, _, -, and ." } ));
		ll.add(Arrays.asList(new Object[]{ 		"add_netgroup_positive",		"netgroup001",	   "UTF-8字符串Discreption",	 "no error" } ));  
		ll.add(Arrays.asList(new Object[]{ 		"delete_netgroup",			"netgroup001","",""} ));
		return ll;	
	}



	@DataProvider(name="getServiceObjects")
	public Object[][] getServiceObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createServiceObjects());
	}
	protected List<List<Object>> createServiceObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//										testname					hostname     	servicename    expectedError
		ll.add(Arrays.asList(new Object[]{ "add_service_negative",	mytesthost, 	 		 "资源002",			"krbPrincipalName: value #0 invalid per syntax: Invalid syntax."} ));
		return ll;	
	}

	@DataProvider(name="getDNSZoneObjects")
	public Object[][] getDNSZoneObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSZoneObjects());
	}
	protected List<List<Object>> createDNSZoneObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
		// testName,             zoneName,                         authoritativeNameserver,         rootEmail	                expectedError
		ll.add(Arrays.asList(new Object[]{	"add_dnsZonename_negative",    "παγκοσμιοποίηση.dns.test.zone"         ,nameserver,             "root." + DNSTests.dummyHost, "invalid 'name': only letters, numbers, and - are allowed. DNS label may not start or end with -"} ));
		return ll;
	}

	@DataProvider(name="getHBACRuleObjects")
	public Object[][] getHBACRuleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleObjects());
	}
	protected List<List<Object>> createHBACRuleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "add_hbacrule_positive",					"资源001",""      } ));
		ll.add(Arrays.asList(new Object[]{ "modify_hbacrule_positive",			"资源001",		"this is test description 资源 001"      } ));
		ll.add(Arrays.asList(new Object[]{ "delete_hbacrule",					"资源001",""      } ));
		return ll;	
	}

	@DataProvider(name="getHBACServiceObjects")
	public Object[][] getHBACServiceObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceObjects());
	}
	protected List<List<Object>> createHBACServiceObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//										testname					cn			description
		ll.add(Arrays.asList(new Object[]{ "add_hbacservice_positive",			      "hbacservice资源001",		"description hbacservice资源001"      } ));
		ll.add(Arrays.asList(new Object[]{ "delete_hbacservice",		"hbacservice资源001",""	 } ));
		return ll;	
	}

	@DataProvider(name="getHBACServiceGroupObjects")
	public Object[][] getHBACServiceGroupObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupObjects());
	}
	protected List<List<Object>> createHBACServiceGroupObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//										testname					cn							description
		ll.add(Arrays.asList(new Object[]{ "add_servicegroup_positive",			"hbacservice资源group001",		"description hbacservice资源group001"      } ));
		ll.add(Arrays.asList(new Object[]{ "delete_servicegroup",	"hbacservice资源group001",""	 } ));
		return ll;	
	}


	@DataProvider(name="getSudoruleObjects")
	public Object[][] getSudoruleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleObjects());
	}
	protected List<List<Object>> createSudoruleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//										testname			cn   			
		ll.add(Arrays.asList(new Object[]{ "add_sudorule_positive",			"SudoRule资源1",""} ));
		ll.add(Arrays.asList(new Object[]{ "modify_sudorule_positive",			"SudoRule资源1","description sudorule资源1"} ));
		ll.add(Arrays.asList(new Object[]{ "delete_sudorule",			"SudoRule资源1",""} ));
		return ll;	
	}

	@DataProvider(name="getSudoCommandObjects")
	public Object[][] getSudoCommandObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoCommandObjects());
	}
	protected List<List<Object>> createSudoCommandObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//										testname			cn   					desc	
		ll.add(Arrays.asList(new Object[]{ "add_sudocommand_positive",	"sudocmdduplicate资源001", 	"description sudocmd资源group001"	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_sudocommand",	"sudocmdduplicate资源001", 	""	} ));
		return ll;	
	}
	@DataProvider(name="getSudoCommandGroupObjects")
	public Object[][] getSudoCommandGroupObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(sudoCommandGroupObjects());
	}
	protected List<List<Object>> sudoCommandGroupObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//									testname			cn   	
		ll.add(Arrays.asList(new Object[]{ "add_sudocommandgroup_positive",		"sudocmd资源group001", "description sudocmd资源group001"	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_sudocommandgroup",		"sudocmd资源group001",""	} ));

		return ll;	
	}


	@DataProvider(name="automountObject")
	public Object[][] automountObject() {
		return TestNGUtils.convertListOfListsTo2dArray(createautomountObject());
	}
	protected List<List<Object>> createautomountObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//									testname			cn   	
		ll.add(Arrays.asList(new Object[]{ "add_location_positive",		"automountlocation资源001", "","","",""	} ));
		ll.add(Arrays.asList(new Object[]{ "add_map_positive",		"automountlocation资源001","automountmap001", "","description automountmap资源group001","noerror"	} ));
		ll.add(Arrays.asList(new Object[]{ "add_map_negative",		"automountlocation资源001","automountmap资源002","", "description automountmap资源group002","invalid 'map': The character u'\\u8d44' is not allowed."	} ));			        
		ll.add(Arrays.asList(new Object[]{ "add_key_negative_key",		"automountlocation资源001","automountmap001","automountkey资源001", "info automountkey001","invalid 'key': The character u'\\u8d44' is not allowed."	} ));
		ll.add(Arrays.asList(new Object[]{ "add_key_negative_info",		"automountlocation资源001","automountmap001","automountkey002", "info automountkey资源group002","invalid 'info': The character u'\\u8d44' is not allowed."	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_location",		"automountlocation资源001", "","","",""	} ));
		return ll;	
	}
	@DataProvider(name="getSelinuxUserMapObjects")
	public Object[][] getSelinuxUserMapObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSelinuxUserMapObjects());
	}
	protected List<List<Object>> createSelinuxUserMapObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//									testname		                 	cn   	
		ll.add(Arrays.asList(new Object[]{ "add_Selinuxuser_positive",		"selinuxrule资源001", "unconfined_u:s0-s0:c0.c1023"	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_Selinuxuser",		    "selinuxrule资源001",""	} ));
		return ll;	
	}
	@DataProvider(name="getAutomemberObjects")
	public Object[][] getAutomemberObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberObjects());
	}
	protected List<List<Object>> createAutomemberObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//									testName		 					   groupName			
		ll.add(Arrays.asList(new Object[]{ "modify_automemberusergrouprule_positive",   groupname, "automember பயனர் குழு விளக்கம்"} ));
		ll.add(Arrays.asList(new Object[]{ "delete_automemberusergroup",   groupname, ""} ));
		ll.add(Arrays.asList(new Object[]{ "modify_automemberhostgrouprule_positive",   hostgroup, "automember హోస్ట్ గ్రూప్ వివరణ"} ));
		ll.add(Arrays.asList(new Object[]{ "delete_automemberhostgroup",   hostgroup, ""} ));
		return ll;	
	}
	@DataProvider(name="roleObjects")
	public Object[][] roleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createroleObjects());
	}
	protected List<List<Object>> createroleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//									testName		 					   groupName			
		ll.add(Arrays.asList(new Object[]{ "add_rbacrule_positive",   "role资源001", "description role资源001"} ));
		ll.add(Arrays.asList(new Object[]{ "delete_rbacrule",   "role资源001", ""} ));
		ll.add(Arrays.asList(new Object[]{ "add_rbacprivilege_positive",   "privilege资源001", "description privilege资源001"} ));
		ll.add(Arrays.asList(new Object[]{ "delete_rbacprivilege",   "privilege资源001", ""} ));

		return ll;
	}

	@DataProvider(name="selfserviceObjects")
	public Object[][] selfserviceObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createselfserviceObjects());
	}
	protected List<List<Object>> createselfserviceObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//									testName		 			name,		cn,			error			
		ll.add(Arrays.asList(new Object[]{ "add_selfservice_negative",   "service资源001", "audio","May only contain letters, numbers, -, _, and space"} ));
		return ll;
	}
	@DataProvider(name="getDelegationObjects")
	public Object[][] getDelegationObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationObjects());
	}
	protected List<List<Object>> createDelegationObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();

		//									testName        delegationName      groupName       memberGroup    attribute			
		ll.add(Arrays.asList(new Object[]{ "add_delegation_positive",   "资源delegation001",     groupname,      hostgroup,  "audio" } ));
		ll.add(Arrays.asList(new Object[]{ "delete_delegation",       "资源delegation001",     "",      "",  "" } ));
		return ll;	
	}

	@DataProvider(name="configurationObjects")
	public Object[][] configurationObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createconfigurationObjects());
	}
	protected List<List<Object>> createconfigurationObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//									testName		 			fieldname,				fieldvalue,			error			
		ll.add(Arrays.asList(new Object[]{ "add_usersearch_negative",   "ipausersearchfields", 		"測試資源",		"invalid 'usersearch': The character u'\\u6e2c' is not allowed."} ));
		ll.add(Arrays.asList(new Object[]{ "add_homesrootdir_negative",   "ipahomesrootdir", 			"測試資源",		"invalid 'homedirectory': The character u'\\u6e2c' is not allowed."} ));
		ll.add(Arrays.asList(new Object[]{ "add_defaultloginshell_negative",   "ipadefaultloginshell", 		"測試資源",		"ipaDefaultLoginShell: value #0 invalid per syntax: Invalid syntax."} ));
		ll.add(Arrays.asList(new Object[]{ "add_userobjectclasses_negative",   "ipauserobjectclasses-0",		"測試資源",		"objectclass 測試資源 not found"} ));
		ll.add(Arrays.asList(new Object[]{ "add_groupsearch_negative",   "ipagroupsearchfields", 		"測試資源",		"invalid 'groupsearch': The character u'\\u6e2c' is not allowed."} ));
		ll.add(Arrays.asList(new Object[]{ "add_groupobjectclasses_negative",   "ipagroupobjectclasses-0", 	"測試資源",		"objectclass 測試資源 not found"} ));
		return ll;
	}
}
