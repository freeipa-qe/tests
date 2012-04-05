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
import com.redhat.qe.ipa.sahi.tasks.PermissionTasks;
import com.redhat.qe.ipa.sahi.tasks.PrivilegeTasks;

public class PrivilegeTests extends SahiTestScript{	
	private static Logger log = Logger.getLogger(PrivilegeTests.class.getName());
	/*
	 * PreRequisite - 
	 */
	
	private String currentPage = "";
	private String alternateCurrentPage = "";

	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.setStrictVisibilityCheck(true);
		sahiTasks.navigateTo(commonTasks.privilegePage, true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&privilege-facet=search" ;		
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.privilegePage, true);
		}		
	}
	
	/*
	 * Add Privilege
	 */		
	@Test (groups={"privilegeAddTests"}, description="Add Privilege", 
			dataProvider="privilegeAddTestObjects")	
	public void testprivilegeAddTest(String testName, String name, String description) throws Exception {		
		//verify privilege doesn't exist
		Assert.assertFalse(sahiTasks.link(name).exists(), "Verify privilege " + name + " doesn't already exist");
		
		//new privilege can be added now
		PrivilegeTasks.addPrivilege(sahiTasks, name, description, "Add");
		
		//verify privilege was added successfully
		CommonTasks.search(sahiTasks, name);
		Assert.assertTrue(sahiTasks.link(name).exists(), "Added privilege " + name + "  successfully");
		CommonTasks.clearSearch(sahiTasks);
	}
	
	/*
	 * Add and Add another
	 */
	@Test (groups={"privilegeAddAndAddAnotherTests"}, description="Add and Add another privilege", 
			dataProvider="privilegeAddAndAddAnotherTestObjects")	
	public void testprivilegeAddAndAddAnother(String testName, String name1,  String description1, String name2,
			String description2) throws Exception {		
		//verify privilege doesn't exist
		Assert.assertFalse(sahiTasks.link(name1).exists(), "Verify privilege " + name1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(name2).exists(), "Verify privilege " + name2 + " doesn't already exist");
				
		//new privilege can be added now
		PrivilegeTasks.addAndAddAnotherPrivilege(sahiTasks, name1, name2, description1, description2);
		
		//verify privilege was added successfully
		CommonTasks.search(sahiTasks, name1);
		Assert.assertTrue(sahiTasks.link(name1).exists(), "Added privilege " + name1 + "  successfully");
		CommonTasks.search(sahiTasks, name2);
		Assert.assertTrue(sahiTasks.link(name2).exists(), "Added privilege " + name2 + "  successfully");
		CommonTasks.clearSearch(sahiTasks);
	}
	
	
	/*
	 * And and edit
	 */
	@Test (groups={"privilegeAddAndEditTests"}, description="Add and Edit Privilege", 
			dataProvider="privilegeAddAndEditTestObjects")	
	public void testprivilegeAddAndEdit(String testName, String name, String description, String newdescription) throws Exception {		
		//verify privilege doesn't exist
		Assert.assertFalse(sahiTasks.link(name).exists(), "Verify privilege " + name + " doesn't already exist");
				
		//new privilege can be added now
		PrivilegeTasks.addAndEditPrivilege(sahiTasks, name, description, newdescription);
		
		//verify privilege was added successfully
		CommonTasks.search(sahiTasks, name);
		Assert.assertTrue(sahiTasks.link(name).exists(), "Added privilege " + name + "  successfully");
		PrivilegeTasks.verifyPrivilege(sahiTasks, name, newdescription);		
	}
	
	
	/*
	 * Add and Cancel Privilege
	 */
	@Test (groups={"privilegeAddCancelTests"}, description="Add and Cancel Privilege", 
			dataProvider="privilegeAddCancelTestObjects")	
	public void testprivilegeAddCancel(String testName, String name, String description) throws Exception {		
		//verify privilege doesn't exist
		Assert.assertFalse(sahiTasks.link(name).exists(), "Verify privilege " + name + " doesn't already exist");
		
		//new privilege can be added now
		PrivilegeTasks.addPrivilege(sahiTasks, name, description, "Cancel");
		
		//verify privilege was not added 
		CommonTasks.search(sahiTasks, name);
		Assert.assertFalse(sahiTasks.link(name).exists(), "Not added privilege " + name );
		CommonTasks.clearSearch(sahiTasks);
	}
	
	
    /*
	 * Edit - Undo/Reset/Update the Settings for the Privilege
	 */
	@Test (groups={"privilegeModifyTests"}, description="Edit - Undo/Reset/Update Settings for Privilege",
			dataProvider="privilegeModifyTestObjects")
	public void testprivilegeModify(String testName, String name, String description, String newDescription, String buttonToClick) throws Exception {		
		//verify privilege to be edited exists
		CommonTasks.search(sahiTasks, name);
		Assert.assertTrue(sahiTasks.link(name).exists(), "Verify Privilege " + name + " to be edited exists");
				
		PrivilegeTasks.undoResetUpdatePrivilege(sahiTasks, name, description, newDescription, buttonToClick);
		
		//reset description back, if updated
		if (buttonToClick.equals("Update")) {
			PrivilegeTasks.undoResetUpdatePrivilege(sahiTasks, name, newDescription, description, buttonToClick);
		}
		
		CommonTasks.clearSearch(sahiTasks);
	}
	

	/*
	 * Add Privilege - Negative tests
	 */
	@Test (groups={"privilegeInvalidAddTests"}, description="Add Invalid Privilege", 
			dataProvider="privilegeInvalidAddTestObjects",
			dependsOnGroups="privilegeAddTests")	
	public void testPrivilegeInvalidAddTests(String testName, String name, String description, String expectedError) throws Exception {		
		
		
		//new privilege should not be added
		PrivilegeTasks.addInvalidPrivilege(sahiTasks, name, description, expectedError);
	}
	

	/*
	 * Add Privilege - check required fields - for negative tests
	 */
	@Test (groups={"privilegeRequiredFieldAddTests"}, description="Add Privilege - missing required field",
			dataProvider="privilegeRequiredFieldAddTestObjects")	
	public void testprivilegeRequiredFieldAdd(String testName,  String name, String description, 
			String expectedError) throws Exception {
	
		PrivilegeTasks.addPrivilegeWithRequiredField(sahiTasks, name, description, expectedError);	
	}
	
	/*
	 * Expand/Collapse details of a Privilege
	 */
	@Test (groups={"privilegeExpandCollapseTests"}, description="Expand and Collapse details of a Privilege", 
			dataProvider="privilegeExpandCollapseTestObjects")
	public void testprivilegeExpandCollapse(String testName, String name) throws Exception {
		
		PrivilegeTasks.expandCollapsePermission(sahiTasks, name);		
		
	}
	
	/*
	 * Delete Multiple Privileges
	 */
	@Test (groups={"privilegeMultipleDeleteTests"}, description="Delete Multiple Privileges", 
			dataProvider="privilegeMultipleDeleteTestObjects",
			dependsOnGroups={"privilegeAddTests", "privilegeInvalidAddTests", "privilegeAddAndAddAnotherTests"})	
	public void testPermissionMultipleDelete(String testName, String searchString, String name1, String name2, String name3) throws Exception {		
	    String names[] = {name1, name2, name3};
	    
	    PrivilegeTasks.deleteMultiplePrivilege(sahiTasks, searchString, names, "Delete");
	    
		//verify permission was deleted successfully		
		for (String name : names) {
			if (!name.isEmpty()) {
				CommonTasks.search(sahiTasks, name);
				Assert.assertFalse(sahiTasks.link(name).exists(), "Deleted privilege " + name + "  successfully");
			}
		}
		CommonTasks.clearSearch(sahiTasks);
	}
	
	/*
	 * Cleanup after tests are run
	 */
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException {
		sahiTasks.navigateTo(commonTasks.privilegePage, true);
		String[] privilegeTestObjects = {"Add User",
				"Add User, Group",
				"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",
				"A~d`d! U@s#e$r%,^ G&r*o(u)p- T_e+s=t a{n[d]m}o'r:e? a/n<d.a>g|a\\in",
				"Add Group1",
				"Add Group2",
				"Add Host",
		};
		
		for (String privilegeTestObject : privilegeTestObjects) {
			log.fine("Cleaning Privilege: " + privilegeTestObject);
			CommonTasks.search(sahiTasks, privilegeTestObject);
			PrivilegeTasks.deletePrivilege(sahiTasks, privilegeTestObject, "Delete");
		} 
		CommonTasks.clearSearch(sahiTasks);
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	/*
	 * Data to be used when adding privilege
	 */		
	@DataProvider(name="privilegeAddTestObjects")
	public Object[][] getPrivilegeAddTestObjects() {
		String[][] privileges={
        //	testname							Name			Description   			
		{ "add_privilege",						"Add User",			"Add User"	},
		{ "add_privilege_with_comma_in_name",	"Add User, Group",	"Add User, Group"	},
		{ "add_privilege_with_long_name",		"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",	"Long Name"	},
		{ "add_privilege_with_specialchar",		"A~d`d! U@s#e$r%,^ G&r*o(u)p- T_e+s=t a{n[d]m}o'r:e? a/n<d.a>g|a\\in",	"Special Char!"	}
		};
        
		return privileges;	
	}
	
	/*
	 * Data to be used when adding and then adding another privilege
	 */		
	@DataProvider(name="privilegeAddAndAddAnotherTestObjects")
	public Object[][] getPrivilegeAddAndAddAnotherTestObjects() {
		String[][] privileges={
        //	testname							Name1			Description1		Name2			Description2  			
		{ "add_and_add_another_privilege",		"Add Group1",	"Add Group1",		"Add Group2",	"Add Group2"	} };
        
		return privileges;	
	}	
	
	/*
	 * Data to be used when adding and then editing privilege
	 */		
	@DataProvider(name="privilegeAddAndEditTestObjects")
	public Object[][] getPprivilegeAddAndEditTestObjects() {
		String[][] privileges={
        //	testname					Name			Description			New Description  			
		{ "add_and_edit_privilege",		"Add Host",		"Add Host",			"Add Host in Add And Edit test" 	} };
        
		return privileges;	
	}	
	
	/*
	 * Data to be used when adding and then canceling privilege
	 */		
	@DataProvider(name="privilegeAddCancelTestObjects")
	public Object[][] getPrivilegeAddCancelTestObjects() {
		String[][] privileges={
        //	testname					Name				Description			  			
		{ "add_and_edit_privilege",		"Add Hostgroup",	"Add Hostgroup" 	} };
        
		return privileges;	
	}
	
	/*
	 * Data to be used when adding invalid privilege
	 */		
	@DataProvider(name="privilegeInvalidAddTestObjects")
	public Object[][] getPrivilegeInvalidAddTestObjects() {
		String[][] privileges={
        //	testname							Name			Description  	Expected Error 			
		{ "add_duplicate_privilege",			"Add User",		"Add User",		"privilege with name \"Add User\" already exists"	} };
        
		return privileges;	
	}
	
	/*
	 * Data to be used when adding privilege with missing required fields
	 */		
	@DataProvider(name="privilegeRequiredFieldAddTestObjects")
	public Object[][] getprivilegeRequiredFieldAddTestObjects() {
		String[][] privileges={
        //	testname							Name			Description  		Expected Error 			
		{ "add_privilege_missing_name",			"",				"Add Netgroup", 	"Required field"	},
		{ "add_privilege_missing_description",	"Add Netgroup",	"",					"Required field"	}};
        
		return privileges;	
	}
	
	/*
	 * Data to be used when deleting multiple privilege 
	 */		
	@DataProvider(name="privilegeMultipleDeleteTestObjects")
	public Object[][] getprivilegeMultipleDeleteTestObjects() {
		String[][] privileges={
        //	testname							Search String	Name1		Name2			Name3			  				
		{ "delete_multiple_privilege",			"Add",			"Add User", "Add Group1",	"Add Group2"	} };
        
		return privileges;	
	}
	
	/*
	 * Data to be used when deleting multiple privilege 
	 */		
	@DataProvider(name="privilegeExpandCollapseTestObjects")
	public Object[][] getprivilegeExpandCollapseTestObjects() {
		String[][] privileges={
        //	testname							Name			  				
		{ "expand_collapse_privilege",			"Automount Administrators"	} };
        
		return privileges;	
	}
	
	/*
	 * Data to be used when modifying privilege 
	 */		
	@DataProvider(name="privilegeModifyTestObjects")
	public Object[][] getprivilegeModifyTestObjects() {
		String[][] privileges={
        //	testname					Name						Existing description		New Description					Button To Click			  				
		{ "modify_privilege_undo",		"DNS Administrators",		"DNS Administrators",		"DNS Administrators Updated",	"undo"	},
		{ "modify_privilege_reset",		"Group Administrators",		"Group Administrators",		"Group Administrators Updated",	"Reset"	},
		{ "modify_privilege_update",	"Host Enrollment",			"Host Enrollment",			"Host Enrollment Updated",		"Update"	} };
        
		return privileges;	
	}
	
	
	}
	