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
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.PrivilegeTasks;
import com.redhat.qe.ipa.sahi.tasks.RoleTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;

public class RoleTests extends SahiTestScript {
	private static Logger log = Logger.getLogger(RoleTasks.class.getName());
	
	/*
	 * PreRequisite - 
	 */
	
	//User used in this testsuite
	private String uid = "roleusr";
	private String givenName = "RoleUser";
	private String sn = "Test";
	
	//Group used in this testsuite
	private String groupName = "rolegrp";
	private String groupDescription = "Group to be used for Role tests";
	
	//Host  used in this testsuite
	private String domain = System.getProperty("ipa.server.domain");
	private String hostname = "rolehost";
	private String fqdn = hostname + "." + domain;
	private String ipadr = "";
	
	//Hostgroup used in this testsuite
	private String hostgroupName = "rolehostgroup";
	private String description = "Hostgroup to be used for Role tests";
	
	
	
	private String currentPage = "";
	private String alternateCurrentPage = "";

	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.setStrictVisibilityCheck(true);
		
		//add new user, user group, host, host group
		System.out.println("Check CurrentPage: " + commonTasks.userPage);
		sahiTasks.navigateTo(commonTasks.userPage, true);
		if (!sahiTasks.link(uid).exists())
			UserTasks.createUser(sahiTasks, uid, givenName, sn, "Add");

		System.out.println("Check CurrentPage: " + commonTasks.groupPage);
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		if (!sahiTasks.link(groupName).exists())
			GroupTasks.createGroupService(sahiTasks, groupName, groupDescription, commonTasks.groupPage);
		
		System.out.println("Check CurrentPage: " + commonTasks.hostPage);
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		if (!sahiTasks.link(fqdn.toLowerCase()).exists())
			HostTasks.addHost(sahiTasks, hostname, commonTasks.getIpadomain(), ipadr);
		
		System.out.println("Check CurrentPage: " + commonTasks.hostgroupPage);
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		if (!sahiTasks.link(hostgroupName).exists()) {
			HostgroupTasks.addHostGroup(sahiTasks, hostgroupName, description, "Add");
		} 
		
		
		sahiTasks.navigateTo(commonTasks.rolePage, true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&role-facet=search" ;
		//previous tests cases in privileges has left roles page in IT Specialist,need to click backlink in Win
		if (sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).exists())
			sahiTasks.link("Roles").in(sahiTasks.div("content nav-space-3")).click();
		
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
	 * Add Role
	 */		
	@Test (groups={"roleAddTests"}, description="Add Role", 
			dataProvider="roleAddTestObjects")	
	public void testRoleAdd(String testName, String name, String description) throws Exception {
		
		//verify role doesn't exist
		Assert.assertFalse(sahiTasks.link(name).exists(), "Verify Role " + name + " doesn't already exist");
		
		//new role can be added now
		RoleTasks.addRole(sahiTasks, name, description, "Add");
		
		//verify role was added successfully
		CommonTasks.search(sahiTasks, name);
		Assert.assertTrue(sahiTasks.link(name).exists(), "Added Role " + name + "  successfully");
		CommonTasks.clearSearch(sahiTasks);
	}
	
	/*
	 * Add and Add another
	 */
	@Test (groups={"roleAddAndAddAnotherTests"}, description="Add and Add another role", 
			dataProvider="roleAddAndAddAnotherTestObjects")	
	public void testroleAddAndAddAnother(String testName, String name1,  String description1, String name2,
			String description2) throws Exception {		
		//verify role doesn't exist
		Assert.assertFalse(sahiTasks.link(name1).exists(), "Verify role " + name1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(name2).exists(), "Verify role " + name2 + " doesn't already exist");
				
		//new role can be added now
		RoleTasks.addAndAddAnotherRole(sahiTasks, name1, name2, description1, description2);
		
		//verify role was added successfully
		CommonTasks.search(sahiTasks, name1);
		Assert.assertTrue(sahiTasks.link(name1).exists(), "Added role " + name1 + "  successfully");
		CommonTasks.search(sahiTasks, name2);
		Assert.assertTrue(sahiTasks.link(name2).exists(), "Added role " + name2 + "  successfully");
		CommonTasks.clearSearch(sahiTasks);
	}
	
	
	/*
	 * And and edit
	 */
	@Test (groups={"roleAddAndEditTests"}, description="Add and Edit Role", 
			dataProvider="roleAddAndEditTestObjects")	
	public void testroleAddAndEdit(String testName, String name, String description, String newdescription) throws Exception {		
		//verify role doesn't exist
		Assert.assertFalse(sahiTasks.link(name).exists(), "Verify role " + name + " doesn't already exist");
				
		//new role can be added now
		RoleTasks.addAndEditRole(sahiTasks, name, description, newdescription);
		
		//verify role was added successfully
		CommonTasks.search(sahiTasks, name);
		Assert.assertTrue(sahiTasks.link(name).exists(), "Added role " + name + "  successfully");
		RoleTasks.verifyRole(sahiTasks, name, newdescription);		
	}
	
	
	/*
	 * Add and Cancel Role
	 */
	@Test (groups={"roleAddCancelTests"}, description="Add and Cancel Role", 
			dataProvider="roleAddCancelTestObjects")	
	public void testroleAddCancel(String testName, String name, String description) throws Exception {		
		//verify role doesn't exist
		Assert.assertFalse(sahiTasks.link(name).exists(), "Verify role " + name + " doesn't already exist");
		
		//new role can be added now
		RoleTasks.addRole(sahiTasks, name, description, "Cancel");
		
		//verify role was not added 
		CommonTasks.search(sahiTasks, name);
		Assert.assertFalse(sahiTasks.link(name).exists(), "Not added role " + name );
		CommonTasks.clearSearch(sahiTasks);
	}
	
    /*
	 * Edit - Undo/Reset/Update the Settings for the Role
	 */
	@Test (groups={"roleModifyTests"}, description="Edit - Undo/Reset/Update Settings for Role",
			dataProvider="roleModifyTestObjects")
	public void testroleModify(String testName, String name, String description, String newDescription, String buttonToClick) throws Exception {		
		//verify role to be edited exists
		CommonTasks.search(sahiTasks, name);
		Assert.assertTrue(sahiTasks.link(name).exists(), "Verify Role " + name + " to be edited exists");
				
		RoleTasks.undoResetUpdateRole(sahiTasks, name, description, newDescription, buttonToClick);
		
		//reset description back, if updated
		if (buttonToClick.equals("Update")) {
			RoleTasks.undoResetUpdateRole(sahiTasks, name, newDescription, description, buttonToClick);
		}
		
		CommonTasks.clearSearch(sahiTasks);
	}
	

	/*
	 * Edit - but do not save the Settings for the Role
	 */
	@Test (groups={"roleModifyNotSavedTests"}, description="Edit - But do not save Settings for Role",
			dataProvider="roleModifyNotSavedTestObjects")
	public void testroleModifyNotSaved(String testName, String name, String description, String newDescription, String buttonToClick) throws Exception {		
		//verify role to be edited exists
		CommonTasks.search(sahiTasks, name);
		Assert.assertTrue(sahiTasks.link(name).exists(), "Verify Role " + name + " to be edited exists");
				
		RoleTasks.modifyRoleButNotSave(sahiTasks, name, description, newDescription, buttonToClick);
		
		CommonTasks.clearSearch(sahiTasks);
	}
	
	/*
	 * Add Role - Negative tests
	 */
	@Test (groups={"roleInvalidAddTests"}, description="Add Invalid Role", 
			dataProvider="roleInvalidAddTestObjects",
			dependsOnGroups="roleAddTests")	
	public void testRoleInvalidAddTests(String testName, String name, String description, String expectedError) throws Exception {		
				
		//new role should not be added
		RoleTasks.addInvalidRole(sahiTasks, name, description, expectedError);
	}
	
	
	/*
	 * Modify Role - Negative tests
	 */
	@Test (groups={"roleInvalidModifyTests"}, description="Modify Role with Invalid data", 
			dataProvider="roleInvalidModifyTestObjects")	
	public void testRoleInvalidModifyTests(String testName, String name, String description, String expectedError) throws Exception {		
		CommonTasks.search(sahiTasks, name);
		Assert.assertTrue(sahiTasks.link(name).exists(), "Verify Role " + name + " to be edited exists");
		
		//new role should not be added
		RoleTasks.modifyInvalidRole(sahiTasks, name, description, expectedError);
		CommonTasks.clearSearch(sahiTasks);
	}
	
	/*
	 * Add Role - check required fields - for negative tests
	 */
	@Test (groups={"roleRequiredFieldAddTests"}, description="Add Role - missing required field",
			dataProvider="roleRequiredFieldAddTestObjects")	
	public void testroleRequiredFieldAdd(String testName,  String name, String description, 
			String expectedError) throws Exception {
	
		RoleTasks.addRoleWithRequiredField(sahiTasks, name, description, expectedError);	
	}
	
	/*
	 * Expand/Collapse details of a Role
	 */
	@Test (groups={"roleExpandCollapseTests"}, description="Expand and Collapse details of a Role", 
			dataProvider="roleExpandCollapseTestObjects")
	public void testroleExpandCollapse(String testName, String name) throws Exception {
		
		RoleTasks.expandCollapseRole(sahiTasks, name);		
		
	}
	
	/*
	 * And a role, add or cancel to add privileges
	 */
	@Test (groups={"roleAddAndAddPrivilegeTests"}, description="Add Role and Add Privileges to it", 
			dataProvider="roleAddAndAddPrivilegeTestObjects")	
	public void testroleAddAndAddPrivilege(String testName, String name, String description, String searchString, 
			String privilege1, String privilege2, String buttonToClick) throws Exception {		
		//verify role doesn't exist
		Assert.assertFalse(sahiTasks.link(name).exists(), "Verify role " + name + " doesn't already exist");
				
		String privileges[]={privilege1, privilege2};
		//new role can be added now
		RoleTasks.addRoleAddPrivileges(sahiTasks, name, description, searchString, privileges, buttonToClick);
		
		//verify role was added successfully
		CommonTasks.search(sahiTasks, name);
		Assert.assertTrue(sahiTasks.link(name).exists(), "Added role " + name + "  successfully");
		String privilegesToVerify[] = {privilege1, privilege2};
		if (buttonToClick.equals("Add")) {
			RoleTasks.verifyRoleMemberOfPrivilege(sahiTasks, name, "Privileges", privilegesToVerify, true);
			RoleTasks.verifyRoleMembershipInPrivilege(sahiTasks, name, privilegesToVerify);
		}
		else
			RoleTasks.verifyRoleMemberOfPrivilege(sahiTasks, name, "Privileges", privilegesToVerify, false);
	}
	
	
	/*
	 * And a role, select/deselect then add privileges
	 */
	@Test (groups={"roleAddAndSelectDeselectPrivilegeTests"}, description="Add Role and Select/Deselect to Add Privilege to it", 
			dataProvider="roleAddAndSelectDeselectPrivilegeTestObjects")	
	public void testRoleAddAndSelectDeselectPrivilege(String testName, String name, String description, String privilege1, 
			String privilege2) throws Exception {		
		//verify role doesn't exist
		Assert.assertFalse(sahiTasks.link(name).exists(), "Verify role " + name + " doesn't already exist");
				
		//new role can be added now
		RoleTasks.addRoleSelectDeselectPrivilegesToAdd(sahiTasks, name, description, privilege1, privilege2);
		
		//verify privilege was added successfully
		CommonTasks.search(sahiTasks, name);
		Assert.assertTrue(sahiTasks.link(name).exists(), "Added privilege " + name + "  successfully");
		String privileges[] = {privilege1};		
		RoleTasks.verifyRoleMemberOfPrivilege(sahiTasks, name, "Privileges", privileges, true);		
	}
	
	
	
	/*
	 * And a role, add user/group/host/hostgroup members
	 */
	@Test (groups={"roleAddAndAddMembersTests"}, description="Add Role and Add Members to it", 
			dataProvider="roleAddAndAddMembersTestObjects")	
	public void testRoleAddAndAddMembers(String testName, String name, String description, String type, String member) throws Exception {		
		//verify role doesn't exist
		Assert.assertFalse(sahiTasks.link(name).exists(), "Verify role " + name + " doesn't already exist");
				
		//new role can be added now
		RoleTasks.addRoleAddMember(sahiTasks, name, description, type, member);
		
		//verify role was added successfully
		CommonTasks.search(sahiTasks, name);
		Assert.assertTrue(sahiTasks.link(name).exists(), "Added role " + name + "  successfully");
		RoleTasks.verifyMembership(sahiTasks, name, type, member);
	}
	
	/*
	 * Delete Multiple Roles
	 */
	@Test (groups={"roleMultipleDeleteTests"}, description="Delete Multiple Roles", 
			dataProvider="roleMultipleDeleteTestObjects",
			dependsOnGroups={"roleAddTests", "roleInvalidAddTests", "roleAddAndAddAnotherTests"})	
	public void testPermissionMultipleDelete(String testName, String searchString, String name1, String name2, String name3) throws Exception {		
	    String names[] = {name1, name2, name3};
	    
	    RoleTasks.deleteMultipleRole(sahiTasks, searchString, names, "Delete");
	    
		//verify permission was deleted successfully		
		for (String name : names) {
			if (!name.isEmpty()) {
				CommonTasks.search(sahiTasks, name);
				Assert.assertFalse(sahiTasks.link(name).exists(), "Deleted role " + name + "  successfully");
			}
		}
		CommonTasks.clearSearch(sahiTasks);
	}
	
	/*
	 * Cleanup after tests are run
	 */
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException {
		//delete user, user group, host, host group added for this suite
		sahiTasks.navigateTo(commonTasks.userPage, true);
		//Since memberships were checked previously, may not be in the front page for User
		if (sahiTasks.link("Users").in(sahiTasks.div("content nav-space-3")).exists())
			sahiTasks.link("Users").in(sahiTasks.div("content nav-space-3")).click();
		if (sahiTasks.link(uid).exists())
			UserTasks.deleteUser(sahiTasks, uid);

		sahiTasks.navigateTo(commonTasks.groupPage, true);
		//Since memberships were checked previously, may not be in the front page for User Group
		if (sahiTasks.link("User Groups").in(sahiTasks.div("content nav-space-3")).exists())
			sahiTasks.link("User Groups").in(sahiTasks.div("content nav-space-3")).click();
		if (sahiTasks.link(groupName).exists())
			GroupTasks.deleteGroup(sahiTasks, groupName);
		
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		//Since memberships were checked previously, may not be in the front page for Hosts
		if (sahiTasks.link("Hosts").in(sahiTasks.div("content nav-space-3")).exists())
			sahiTasks.link("Hosts").in(sahiTasks.div("content nav-space-3")).click();
		if (sahiTasks.link(fqdn.toLowerCase()).exists())
			HostTasks.deleteHost(sahiTasks, fqdn);
		
		sahiTasks.navigateTo(commonTasks.hostgroupPage, true);
		//Since memberships were checked previously, may not be in the front page for Host Groups
		if (sahiTasks.link("Host Groups").in(sahiTasks.div("content nav-space-3")).exists())
			sahiTasks.link("Host Groups").in(sahiTasks.div("content nav-space-3")).click();
		if (sahiTasks.link(hostgroupName).exists())
			HostgroupTasks.deleteHostgroup(sahiTasks, hostgroupName, "Delete");
		
		
		sahiTasks.navigateTo(commonTasks.rolePage, true);
		String[] roleTestObjects = {"User TestRole",
									"User, Group TestRole",
									"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",
									"A~d`d! U@s#e$r%,^ G&r*o(u)p- T_e+s=t a{n[d]m}o'r:e? r/n<o.a>l|e\\in",
									"Group1 TestRole",
									"Group2 TestRole",
									"Host TestRole",
									"Hostgroup TestRole",	
									"Group3 TestRole",
									"Host1 TestRole",
									"HBAC TestRole",
									"TestRole1",
									"TestRole2",
									"TestRole3",
									"TestRole4"
		};
		
		for (String roleTestObject : roleTestObjects) {
			log.fine("Cleaning Role: " + roleTestObject);
			CommonTasks.search(sahiTasks, roleTestObject);
			RoleTasks.deleteRole(sahiTasks, roleTestObject, "Delete");
		} 
		CommonTasks.clearSearch(sahiTasks);
	}
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	/*
	 * Data to be used when adding roles
	 */		
	@DataProvider(name="roleAddTestObjects")
	public Object[][] getRoleAddTestObjects() {
		String[][] roles={
        //	testname						Name					Description   			
		{ "add_role",						"User TestRole",		"User TestRole"	},
		{ "add_role_with_comma_in_name",	"User, Group TestRole",	"User, Group TestRole"	},
	    { "add_role_with_long_name",		"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",	"Long Name"	},
		{ "add_role_with_specialchar",		"A~d`d! U@s#e$r%,^ G&r*o(u)p- T_e+s=t a{n[d]m}o'r:e? r/n<o.a>l|e\\in",	"Special Char!"	}
		};
        
		return roles;	
	}
	
	
	/*
	 * Data to be used when adding and then adding another role
	 */		
	@DataProvider(name="roleAddAndAddAnotherTestObjects")
	public Object[][] getRoleAddAndAddAnotherTestObjects() {
		String[][] roles={
        //	testname						Name1				Description1			Name2				Description2  			
		{ "add_and_add_another_role",		"Group1 TestRole",	"Group1 TestRole",		"Group2 TestRole",	"Group2 TestRole"	} };
        
		return roles;	
	}	
	
	/*
	 * Data to be used when adding and then editing role
	 */		
	@DataProvider(name="roleAddAndEditTestObjects")
	public Object[][] getRoleAddAndEditTestObjects() {
		String[][] roles={
        //	testname				Name				Description			New Description  			
		{ "add_and_edit_role",		"Host TestRole",	"Host TestRole",	"Add Host in Add And Edit test" 	} };
        
		return roles;	
	}	
	
	/*
	 * Data to be used when adding and then canceling role
	 */		
	@DataProvider(name="roleAddCancelTestObjects")
	public Object[][] getRoleAddCancelTestObjects() {
		String[][] roles={
        //	testname					Name				Description			  			
		{ "add_and_cancel_role",		"Hostgroup TestRole",	"Hostgroup TestRole" 	} };
        
		return roles;	
	}
	
	/*
	 * Data to be used when modifying role 
	 */		
	@DataProvider(name="roleModifyTestObjects")
	public Object[][] getroleModifyTestObjects() {
		String[][] roles={
        //	testname					Name						Existing description		New Description						Button To Click			  				
		{ "modify_role_undo",		"IT Security Specialist",		"IT Security Specialist",	"IT Security Specialist Updated",	"undo"	},
		{ "modify_role_reset",		"IT Specialist",				"IT Specialist",			"IT Specialist Updated",			"Reset"	},
		{ "modify_role_update",		"Security Architect",			"Security Architect",		"Security Architect Updated",		"Update"	} };
        
		return roles;	
	}
	
	/*
	 * Data to be used when modifying, but not saving role 
	 */		
	@DataProvider(name="roleModifyNotSavedTestObjects")
	public Object[][] getroleModifyNotSavedTestObjects() {
		String[][] roles={
        //	testname						Name						Existing description							New Description							Button To Click			  				
		{ "modify_role_notsaved_update",	"User Administrator",		"Responsible for creating Users and Groups",	"User Administrators Updated",			"Update"	},
		{ "modify_role_notsaved_reset",		"helpdesk",					"Helpdesk",										"helpdesk Updated",						"Reset"		},
		{ "modify_role_notsaved_cancel",	"IT Security Specialist",	"IT Security Specialist",						"IT Security Specialist Updated",		"Cancel"	} };
        
		return roles;	
	}
	
	/*
	 * Data to be used when adding invalid role
	 */		
	@DataProvider(name="roleInvalidAddTestObjects")
	public Object[][] getRoleInvalidAddTestObjects() {
		String[][] roles={	
        //	testname							Name					Description  		Expected Error 			
		{ "add_duplicate_role",					"User TestRole",		"User TestRole",	"role with name \"User TestRole\" already exists"	},
		{ "add_role_with_leading_space_name",	" Netgroup TestRole",	"Netgroup TestRole",		"invalid 'name': Leading and trailing spaces are not allowed"	},
		{ "add_role_with_trailing_space_name",	"Netgroup TestRole ",	"Netgroup TestRole",		"invalid 'name': Leading and trailing spaces are not allowed"	},
		{ "add_role_with_leading_space_desc",	"Netgroup TestRole",	" Netgroup TestRole",	"invalid 'desc': Leading and trailing spaces are not allowed"	},
		{ "add_role_with_trailing_space_desc",	"Netgroup TestRole",	"Netgroup TestRole ",	"invalid 'desc': Leading and trailing spaces are not allowed"	} };
        
		return roles;	
	}
	
	/*
	 * Data to be used when modifying role with invalid data
	 */		
	@DataProvider(name="roleInvalidModifyTestObjects")
	public Object[][] getRoleInvalidModifyTestObjects() {
		String[][] roles={
        //	testname									Name				Description  			Expected Error 			
		{ "modify_blank_role",						"User Administrator",	"",						"Input form contains invalid or missing values."	},
		{ "modify_role_with_leading_space_desc",	"Security Architect",	" Security Architect",	"invalid 'desc': Leading and trailing spaces are not allowed"	},
		{ "modify_role_with_trailing_space_desc",	"Security Architect",	"Security Architect ",	"invalid 'desc': Leading and trailing spaces are not allowed"	} };
        
		return roles;	
	}
	
	
	/*
	 * Data to be used when adding role with missing required fields
	 */		
	@DataProvider(name="roleRequiredFieldAddTestObjects")
	public Object[][] getroleRequiredFieldAddTestObjects() {
		String[][] roles={
        //	testname						Name				Description  		Expected Error 			
		{ "add_role_missing_name",			"",					"Sudo TestRole", 	"Required field"	},
		{ "add_role_missing_description",	"Sudo TestRole",	"",					"Required field"	}};
        
		return roles;	
	}
	
	
	/*
	 * Data to be used when expanding/collapsing a role 
	 */		
	@DataProvider(name="roleExpandCollapseTestObjects")
	public Object[][] getroleExpandCollapseTestObjects() {
		String[][] roles={
        //	testname					Name			  				
		{ "expand_collapse_role",		"IT Security Specialist"	} };
        
		return roles;	
	}
	
	/*
	 * Data to be used when deleting multiple role 
	 */		
	@DataProvider(name="roleMultipleDeleteTestObjects")
	public Object[][] getroleMultipleDeleteTestObjects() {
		String[][] roles={
        //	testname				Search String	Name1				Name2				Name3			  				
		{ "delete_multiple_role",	"TestRole",		"User TestRole", 	"Group1 TestRole",	"Group2 TestRole"	} };
        
		return roles;	
	}
	
	/*
	 * Data to be used when adding and then editing role
	 */		
	@DataProvider(name="roleAddAndAddPrivilegeTestObjects")
	public Object[][] getRoleAddAndAddPrivilegeTestObjects() {
		String[][] roles={
        //	testname						Name					Description			SearchString	Privilege1					Privilege2					Button		  			
		{ "add_role_add_privilege",			"Group3 TestRole",		"Group3 TestRole",	"group",		"Modify Group membership",	"Group Administrators",		"Add" 	} ,
		{ "add_role_add_privilege_cancel",	"Host1 TestRole",		"Host1 TestRole",	"Host",			"Host Administrators",		"Host Enrollment",			"Cancel" } };
        
		return roles;	
	}	
	
	/*
	 * Data to be used when adding role, then selecting/deselcting privileges
	 */		
	@DataProvider(name="roleAddAndSelectDeselectPrivilegeTestObjects")
	public Object[][] getRoleAddAndSelectDeselectPrivilegeTestObjects() {
		String[][] roles={
        //	testname								Name				Description			Privilege1				Privilege2					  			
		{ "add_role_select_deselect_privilege",		"HBAC TestRole",	"HBAC TestRole",	"HBAC Administrator",	"Delegation Administrator"	} };
        
		return roles;	
	}	
	
	/*
	 * Data to be used when adding role, adding members
	 */		
	@DataProvider(name="roleAddAndAddMembersTestObjects")
	public Object[][] getRoleAddAndAddMembersTestObjects() {
		String[][] roles={
        //	testname							Name			Description		Type			Member					  			
		{ "add_role_add_user",					"TestRole1",	"TestRole1",	"Users",		"roleusr"	} ,
		{ "add_role_add_group",					"TestRole2",	"TestRole2",	"Groups",		"rolegrp"	},
		{ "add_role_add_host",					"TestRole3",	"TestRole3",	"Hosts",		fqdn.toLowerCase()	},
		{ "add_role_add_hostgroup_bug812109",	"TestRole4",	"TestRole4",	"HostGroups",	"rolehostgroup"	} };
        
		return roles;	
	}	
	
}
