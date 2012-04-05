package com.redhat.qe.ipa.sahi.tests.rbac;

import java.util.ArrayList;
import java.util.Arrays;
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
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.HBACTasks;
import com.redhat.qe.ipa.sahi.tasks.PermissionTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;
import com.redhat.qe.ipa.sahi.tests.group.GroupTests;


public class PermissionTests extends SahiTestScript {
		private static Logger log = Logger.getLogger(PermissionTests.class.getName());
		
		/*
		 * PreRequisite - 
		 */
		
		private String currentPage = "";
		private String alternateCurrentPage = "";
		
		//Group used in this testsuite
		private String groupName = "permissiontestgroup";
		private String groupDescription = "Group to be used for Permission tests";
		
		@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
		public void initialize() throws CloneNotSupportedException {
			sahiTasks.setStrictVisibilityCheck(true);
			
			System.out.println("Check CurrentPage: " + commonTasks.groupPage);
			sahiTasks.navigateTo(commonTasks.groupPage, true);
			if (!sahiTasks.link(groupName).exists())
				GroupTasks.createGroupService(sahiTasks, groupName, groupDescription, commonTasks.groupPage);
			
			sahiTasks.navigateTo(commonTasks.permissionPage, true);
			currentPage = sahiTasks.fetch("top.location.href");
			alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&permission-facet=search" ;
			
		}
		
		@BeforeMethod (alwaysRun=true)
		public void checkCurrentPage() {
		    String currentPageNow = sahiTasks.fetch("top.location.href");
		    CommonTasks.checkError(sahiTasks);
			if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
				System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
				sahiTasks.navigateTo(commonTasks.permissionPage, true);
			}		
		}
		
		/*
		 * Add permission - Type
		 */		
		@Test (groups={"permissionAddTypeTests"}, description="Add Permission with Type Specified", 
				dataProvider="permissionAddTypeTestObjects")	
		public void testPermissionTypeAdd(String testName, String cn, String right1, String right2, String right3, String type, 
				String attribute1, String attribute2, String attribute3) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");
			
			String attributes[] = {attribute1, attribute2, attribute3};
			String rights[] = {right1, right2, right3};
			//new permission can be added now
			PermissionTasks.createPermissionWithType(sahiTasks, cn, rights, type, attributes, "Add");
			
			//verify permission was added successfully
			CommonTasks.search(sahiTasks, cn);
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Added permission " + cn + "  successfully");
			CommonTasks.clearSearch(sahiTasks);
		}
		
		/*
		 * Add permission - Filter
		 */
		@Test (groups={"permissionAddFilterTests"}, description="Add Permission with Filter Specified", 
				dataProvider="permissionAddFilterTestObjects")	
		public void testPermissionFilterAdd(String testName, String cn, String right1, String right2, String right3, 
				String attribute1, String attribute2, String attribute3, String filter) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");
			
			String attributes[] = {attribute1, attribute2, attribute3};
			String rights[] = {right1, right2, right3};
			//new permission can be added now
			PermissionTasks.createPermissionWithFilter(sahiTasks, cn, rights, filter, attributes, "Add");
			
			//verify permission was added successfully
			CommonTasks.search(sahiTasks, cn);
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Added permission " + cn + "  successfully");
			CommonTasks.clearSearch(sahiTasks);
		}
		
		/*
		 * Add permission - Subtree
		 */
		@Test (groups={"permissionAddSubtreeTests"}, description="Add Permission with Subtree Specified", 
				dataProvider="permissionAddSubtreeTestObjects")	
		public void testPermissionSubtreeAdd(String testName, String cn, String right, String attribute1, String attribute2, 
				String attribute3, String memberOfGroup, String subtree) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");
			
			String attributes[] = {attribute1, attribute2, attribute3};
			String rights[] = {right};
			//new permission can be added now
			PermissionTasks.createPermissionWithSubtree(sahiTasks, cn, rights, subtree, attributes, memberOfGroup, "Add");
			
			//verify permission was added successfully
			CommonTasks.search(sahiTasks, cn);
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Added permission " + cn + "  successfully");
			CommonTasks.clearSearch(sahiTasks);
		}
		
		/*
		 * Add permission - Target group
		 */
		@Test (groups={"permissionAddTargetgroupTests"}, description="Add Permission with Targetgroup Specified", 
				dataProvider="permissionAddTargetgroupTestObjects")	
		public void testPermissionTargetgroupAdd(String testName, String cn, String right, String attribute, String memberOfGroup) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");
			
			String attributes[] = {attribute};
			String rights[] = {right};
			//new permission can be added now
			PermissionTasks.createPermissionWithTargetgroup(sahiTasks, cn, rights, attributes, memberOfGroup, "Add");
			
			//verify permission was added successfully
			CommonTasks.search(sahiTasks, cn);
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Added permission " + cn + "  successfully");
			CommonTasks.clearSearch(sahiTasks);
		}
		
		
		/*
		 * Add permission - Target group, and search for group
		 */
		@Test (groups={"permissionMemberOfAddTests"}, description="Add Permission and search for Targetgroup", 
				dataProvider="permissionMemberOfAddTestObjects")	
		public void testPermissionMemberOfAdd(String testName, String cn, String right, String attribute, String memberOfGroup) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");
			
			boolean missing=false;
			//new permission can be added now
			PermissionTasks.createPermissionWithSearchForMemberGroup(sahiTasks, cn, right, attribute, memberOfGroup, missing);
			
			//verify permission was added successfully
			CommonTasks.search(sahiTasks, cn);
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Added permission " + cn + "  successfully");
			CommonTasks.clearSearch(sahiTasks);
		}
		
		
		//TODO: Having trouble verifying - no groups are found when searching for non-existent groups
		/*
		 * Add permission - Target group, and search for nonexistent group
		 */
		@Test (groups={"permissionMissingMemberOfAddTests"}, description="Add Permission and search for nonexistent Targetgroup", 
				dataProvider="permissionMissingMemberOfAddTestObjects")	
		public void testPermissionMissingMemberOfAdd(String testName, String cn, String right, String attribute, String memberOfGroup) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");
			
			boolean missing=true;
			//new permission can be added now
			PermissionTasks.createPermissionWithSearchForMemberGroup(sahiTasks, cn, right, attribute, memberOfGroup, missing);
			
			//verify permission was added successfully
			CommonTasks.search(sahiTasks, cn);
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Added permission " + cn + "  successfully");
			CommonTasks.clearSearch(sahiTasks);
		}
		
		
		/*
		 * Add and Add another
		 */
		@Test (groups={"permissionAddAndAddAnotherTypeTests"}, description="Add Permission with Type Specified", 
				dataProvider="permissionAddAndAddAnotherTypeTestObjects")	
		public void testpermissionAddAndAddAnother(String testName, String cn1, String cn2, String right, String attribute, 
				String type) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn1).exists(), "Verify permission " + cn1 + " doesn't already exist");
			Assert.assertFalse(sahiTasks.link(cn2).exists(), "Verify permission " + cn2 + " doesn't already exist");
					
			//new permission can be added now
			PermissionTasks.addAndAddAnotherPermissionWithType(sahiTasks, cn1, cn2, right, type, attribute);
			
			//verify permission was added successfully
			CommonTasks.search(sahiTasks, cn1);
			Assert.assertTrue(sahiTasks.link(cn1).exists(), "Added permission " + cn1 + "  successfully");
			CommonTasks.search(sahiTasks, cn2);
			Assert.assertTrue(sahiTasks.link(cn2).exists(), "Added permission " + cn2 + "  successfully");
			CommonTasks.clearSearch(sahiTasks);
		}
		
		
		/*
		 * And and edit
		 */
		@Test (groups={"permissionAddAndEditTypeTests"}, description="Add Permission with Type Specified", 
				dataProvider="permissionAddAndEditTypeTestObjects")	
		public void testpermissionAddAndEdit(String testName, String cn, String right, String attribute, 
				String type, String rightToAdd) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");
					
			//new permission can be added now
			PermissionTasks.addAndEditPermissionWithType(sahiTasks, cn, right, type, attribute, rightToAdd, "Update");
			String rights[] = {right, rightToAdd};
			String attributes[]= {attribute};
			PermissionTasks.verifyPermissionType(sahiTasks, cn, rights, type, attributes);		
		}
		
		
		/*
		 * Add and Cancel permission - Filter
		 */
		@Test (groups={"permissionAddCancelFilterTests"}, description="Add Permission with Filter Specified", 
				dataProvider="permissionAddCancelFilterTestObjects")	
		public void testPermissionFilterAddCancel(String testName, String cn, String right, String attribute, String filter) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");
			
			String attributes[] = {attribute};
			String rights[] = {right};
			//new permission can be added now
			PermissionTasks.createPermissionWithFilter(sahiTasks, cn, rights, filter, attributes, "Cancel");
			
			//verify permission was not added 
			CommonTasks.search(sahiTasks, cn);
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Not added permission " + cn );
			CommonTasks.clearSearch(sahiTasks);
		}
		
		/*
		 * Add and Undo Attribute for a permission - Filter
		 */
		@Test (groups={"permissionAddFilterUndoAttributeTests"}, description="Add Permission with Filter Specified", 
				dataProvider="permissionAddFilterUndoAttributeTestObjects")	
		public void testPermissionAddFilterUndoAttribute(String testName, String cn, String right, String filter, String attributeUndo, String attribute) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");
			
			//new permission can be added now
			PermissionTasks.addPermissionWithFilterUndoAttribute(sahiTasks, cn, right, filter, attributeUndo, attribute, "Add");
			
			//verify permission was added 
			String rights[] = {right};
			String attributes[]= {attribute};
			PermissionTasks.verifyPermissionFilter(sahiTasks, cn, rights, filter, attributes);	
		}
		
		
		/*
		 * Add permission - Type - Negative tests
		 */
		@Test (groups={"permissionInvalidAddTypeTests"}, description="Add Invalid Permission with Type Specified", 
				dataProvider="permissionInvalidAddTypeTestObjects",
				dependsOnGroups="permissionAddTypeTests")	
		public void testPermissionTypeInvalidAdd(String testName, String cn, String right1, String right2, String right3, String type, 
				String attribute1, String attribute2, String attribute3, String expectedError) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");
			
			String attributes[] = {attribute1, attribute2, attribute3};
			String rights[] = {right1, right2, right3};
			//new permission can be added now
			PermissionTasks.createInvalidPermissionWithType(sahiTasks, cn, rights, type, attributes, expectedError);
		}
		
		
		
		/*
		 * Add permission - Type - Bug 807755
		 * When adding permissions for a type, attributes that are not allowed are listed
		 */
		@Test (groups={"permissionBug807755Tests"}, description="Verify Bug 807755 - When adding permissions for a type, attributes that are not allowed are listed", 
				dataProvider="permissionBug807755TestObjects")	
		public void testPermissionBug807755(String testName, String cn, String right, String type) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");			
			
			PermissionTasks.createPermissionBug807755(sahiTasks, cn, right, type);
			
			//verify permission was added successfully
			CommonTasks.search(sahiTasks, cn);
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Added permission " + cn + "  successfully");
			CommonTasks.clearSearch(sahiTasks);
		}
		
		
		/*
		 * Add permission - Type - Bug 783500
		 * [ipa webui] Permission has checkbox selected against no attribute
		 */
		@Test (groups={"permissionBug783500Tests"}, description="Verify Bug 783500 - [ipa webui] Permission has checkbox selected against no attribute", 
				dataProvider="permissionBug783500TestObjects")	
		public void testPermissionBug783500(String testName, String cn, String right, String type) throws Exception {		
			//verify permission doesn't exist
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");			
			
			String attributes[] = {""};
			String rights[] = {right};
			PermissionTasks.createPermissionWithType(sahiTasks, cn, rights, type, attributes, "Add");
			
			//verify permission was added successfully
			CommonTasks.search(sahiTasks, cn);
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Added permission " + cn + "  successfully");
			PermissionTasks.verifyPermissionBug783500(sahiTasks, cn);
			CommonTasks.clearSearch(sahiTasks);
		}
		
		
		
		/*
		 * Add Permissions - check required fields - for negative tests
		 */
		@Test (groups={"permissionRequiredFieldAddTests"}, description="Add Permission - missing required field",
				dataProvider="permissionRequiredFieldAddTestObjects")	
		public void testPermissionRequiredFieldAdd(String testName,  String type, String expectedError) throws Exception {
		
			PermissionTasks.createPermissionWithRequiredField(sahiTasks, type, expectedError);		
		}
		
		/*
		 * Expand/Collapse details of a Permission
		 */
		@Test (groups={"permissionExpandCollapseTests"}, description="Expand and Collapse details of a Permission", 
				dataProvider="permissionExpandCollapseTestObjects")
		public void testPermissionExpandCollapse(String testName, String cn) throws Exception {
			
			PermissionTasks.expandCollapsePermission(sahiTasks, cn);		
			
		}
		
		
		/*
		 * Edit the Settings for the Permission
		 */
		@Test (groups={"permissionModifyTests"}, description="Edit Settings for Permission",
				dataProvider="permissionModifyTestObjects")
		public void testPermissionModify(String testName, String cn, String right, String memberOfGroup, String type, String attribute) throws Exception {		
			//verify permission to be edited exists
			CommonTasks.search(sahiTasks, cn);
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Permission " + cn + " to be edited exists");
			
			//modify this permission
			PermissionTasks.modifyPermission(sahiTasks, cn, right, memberOfGroup, attribute);
			
			//verify changes
			String rights[] = {right};
			String attributes[]= {attribute};
			PermissionTasks.verifyPermissionType(sahiTasks, cn, rights, type, attributes);	
			
			PermissionTasks.undoResetUpdatePermission(sahiTasks, cn, "Permissions", right, "undo");
			PermissionTasks.undoResetUpdatePermission(sahiTasks, cn, "Member of group", memberOfGroup, "Reset");
			PermissionTasks.undoResetUpdatePermission(sahiTasks, cn, "Attributes", attribute, "Update");
			
			//Reset permissions to what was installed
			PermissionTasks.modifyPermission(sahiTasks, "Modify netgroup membership", "add", "", "");
			
			CommonTasks.clearSearch(sahiTasks);
		}
		
		
		/*
		 * Delete Multiple Permissions
		 */
		@Test (groups={"permissionMultipleDeleteTests"}, description="Add Permission and search for nonexistent Targetgroup", 
				dataProvider="permissionMultipleDeleteTestObjects",
				dependsOnGroups={"permissionAddTypeTests", "permissionAddFilterTests", "permissionAddSubtreeTests", "permissionInvalidAddTypeTests"})	
		public void testPermissionMultipleDelete(String testName, String searchString, String cn1, String cn2, String cn3) throws Exception {		
		    String cns[] = {cn1, cn2, cn3};
		    
		    PermissionTasks.deleteMultiplePermissions(sahiTasks, searchString, cns, "Delete");
		    
			//verify permission was deleted successfully		
			for (String cn : cns) {
				if (!cn.isEmpty()) {
					CommonTasks.search(sahiTasks, cn);
					Assert.assertFalse(sahiTasks.link(cn).exists(), "Deleted permission " + cn + "  successfully");
				}
			}
			CommonTasks.clearSearch(sahiTasks);
		}
		
		/*
		 * Cleanup after tests are run
		 */
		@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
		public void cleanup() throws CloneNotSupportedException {
			sahiTasks.navigateTo(commonTasks.groupPage, true);
			//Since memberships were checked previously, may not be in the front page for User Group
			if (sahiTasks.link("User Groups").in(sahiTasks.div("content")).exists())
				sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
			if (sahiTasks.link(groupName).exists())
				GroupTasks.deleteGroup(sahiTasks, groupName);
			
			sahiTasks.navigateTo(commonTasks.permissionPage, true);
			String[] permissionTestObjects = {"Manage User1",
					"Manage User2",	
					"Manage Hostgroup1",
					"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",
					"M~a@n$a#g$e % U^s&e*r? ] 1 [ {A",
					"Test < Permission > Bug",
					"Manage Group1",
					"Manage NetGroup1",
					"Manage Host1",	
					"Manage DNSRecord1",
					"Manage Group2",
					"Bug 807755_User1",
					"Bug 807755_Host",
					"Bug 807755_Service",
					"Bug 807755_Usergroup",
					"Bug 807755_Hostgroup",
					"Bug 807755_Netgroup",
					"Bug 807755_DNSRecord",
					"Bug 783500_Netgroup",
					"Manage Group3",
					"Manage Service1",
					"Manage Service2",
					"Manage DNSRecord2",
					"Manage Group4"
			};
			
			for (String permissionTestObject : permissionTestObjects) {
				log.fine("Cleaning Permission: " + permissionTestObject);
				PermissionTasks.deletePermission(sahiTasks, permissionTestObject, "Delete");
			} 
			
			
		}
		
		
		/*******************************************************
		 ************      DATA PROVIDERS     ******************
		 *******************************************************/
		/*
		 * Data to be used when going through pages
		 */
		@DataProvider(name="permissionPageTestObjects")
		public Object[][] getpermissionPageTestObjects() {
			String[][] permissions={
	        //	testname									cn  				right1,		right2,		right3,		Attribute1			Attribute2				Attribute3		Filter 			
			{ "page_permission_prev",			"Manage Group1",		"write",	"",			"",			"member", 			"description",			"",				"(&(!(objectclass=posixgroup))(objectclass=ipausergroup))"},
			{ "page_permission_next",			"Manage NetGroup1",		"write",	"add",		"delete",	"memberNisNetgroup", "nisNetgroupTriple",	"description",	"(objectclass=nisNetgroup)"} };
			
			return permissions;	
		}
		
		/*
		 * Data to be used when adding permissions - Type
		 */		
		@DataProvider(name="permissionAddTypeTestObjects")
		public Object[][] getPermissionAddTypeTestObjects() {
			String[][] permissions={
	        //	testname											cn  						right1,		right2,		right3,		Type		Attributes1			Attributes2		Attributes3 			
			{ "add_permission_type_user_with_multiple_attr",		"Manage User1",				"write",	"",			"",			"User",		"description",		"carlicense",	"photo"		},
			{ "add_permission_type_user_with_multiple_attr_right",	"Manage User2",				"write",	"add",		"",			"User",		"description",		"carlicense",	""		},
		//	{ "add_permission_type_hostgroup_bug783502",			"Manage Hostgroup1",		"write",	"add",		"delete",	"Host Group","businesscategory",	"owner",		""			},
			{ "add_permission_type_user_long",						"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",	"write",	"",			"",			"User Group","description",		"",				""			},
			{ "add_permission_type_user_specialchar",				"M~a@n$a#g$e % U^s&e*r? ] 1 [ {A",		"write",	"",			"",			"User",		"description",		"carlicense",	"photo"		} };
		//	{ "add_permission_type_user_bug807304",	 				"Test < Permission > Bug",	"write",	"",			"",			"User",		"description",		"carlicense",	"photo"		} };
	        
			return permissions;	
		}	
		
		/*
		 * Data to be used when adding permissions - Filter
		 */
		@DataProvider(name="permissionAddFilterTestObjects")
		public Object[][] getpermissionAddFilterTestObjects() {
			String[][] permissions={
	        //	testname									cn  				right1,		right2,		right3,		Attribute1			Attribute2				Attribute3		Filter 			
			{ "add_permission_filter_goodgroup",			"Manage Group1",		"write",	"",			"",			"member", 			"description",			"",				"(&(!(objectclass=posixgroup))(objectclass=ipausergroup))"},
			{ "add_permission_filter_goodnetgroup",			"Manage NetGroup1",		"write",	"add",		"delete",	"memberNisNetgroup", "nisNetgroupTriple",	"description",	"(objectclass=nisNetgroup)"} };
			
			return permissions;	
		}
		
		
		/*
		 * Data to be used when adding permissions - Subtree
		 */
		@DataProvider(name="permissionAddSubtreeTestObjects")
		public Object[][] getpermissionAddSubtreeTestObjects() {
			String[][] permissions={
	        //	testname									cn  				right,		Attribute1			Attribute2		Attribute3			MemberOfGroup				Subtree 			
			{ "add_permission_subtree_goodhost",			"Manage Host1",		"write",	"nshostlocation", 	"",				"",					"permissiontestgroup",		"cn=computers,cn=accounts,dc=testrelm,dc=com"},
			{ "add_permission_subtree_gooddnsrecord",		"Manage DNSRecord1","write",	"nSRecord",			"aRecord",		"idnsZoneActive",	"",							"idnsname=testrelm.com,cn=dns,dc=testrelm,dc=com"} };
			
			return permissions;	
		}
		
		/*
		 * Data to be used when adding permissions - Target group
		 */
		@DataProvider(name="permissionAddTargetgroupTestObjects")
		public Object[][] getpermissionAddTargetgroupTestObjects() {
			String[][] permissions={
	        //	testname									cn  				right,		Attribute			MemberOfGroup						
			{ "add_permission_targetgroup_goodgroup",		"Manage Group2",	"write",	"description", 		"permissiontestgroup"  } };
			
			return permissions;	
		}
		
		
		/*
		 * Data to be used when adding and editing permissions - Type
		 */
		@DataProvider(name="permissionAddAndEditTypeTestObjects")
		public Object[][] getpermissionAddAndEditTypeTestObjects() {
			String[][] permissions={
	        //	testname						cn						right,		Attribute			Type					Right To Add						
			{ "add_and_edit_permission",		"Manage DNSRecord2",	"write",	"srvrecord", 		"DNS Resource Record",	"add"  } };
			
			return permissions;	
		}
		
		/*
		 * Data to be used when adding multiple permissions - Type
		 */
		@DataProvider(name="permissionAddAndAddAnotherTypeTestObjects")
		public Object[][] getpermissionAddAndAddAnotherTypeTestObjects() {
			String[][] permissions={
	        //	testname							cn1					cn2  				right,		Attribute			Type						
			{ "add_and_add_another_permission",		"Manage Service1",	"Manage Service2",	"write",	"krbprincipalname", 		"Service"  } };
			
			return permissions;	
		}
		
		@DataProvider(name="permissionAddCancelFilterTestObjects")
		public Object[][] getpermissionAddCancelFilterTestObjects() {
			String[][] permissions={
	        //	testname									cn  				right1		Attribute1			Filter 			
			{ "add_permission_filter_cancel",			"Manage Group3",		"write",	"member", 			"(&(!(objectclass=posixgroup))(objectclass=ipausergroup))"} };
			
			return permissions;	
		}
		
		@DataProvider(name="permissionAddFilterUndoAttributeTestObjects")
		public Object[][] getpermissionAddFilterUndoAttributeTestObjects() {
			String[][] permissions={
	        //	testname									cn  				right1		Filter															AttributeUndo		Attribute			
			{ "add_permission_filter_cancel",			"Manage Group4",		"write",	"(&(!(objectclass=posixgroup))(objectclass=ipausergroup))",		"memberof", 		"member"			} };
			
			return permissions;	
		}
		
		
		/*
		 * Data to be used when adding permissions - Type - Negative tests
		 */
		@DataProvider(name="permissionInvalidAddTypeTestObjects")
		public Object[][] getPermissionInvalidAddTypeTestObjects() {
			String[][] permissions={
	        //	testname											cn  						right1,		right2,		right3,		Type		Attributes1			Attributes2		Attributes3 	Expected Error			
			{ "add_permission_type_user_duplicate",					"Manage User1",				"write",	"",			"",			"User",		"description",		"carlicense",	"photo",		"This entry already exists"		} }; 
		
			return permissions;	
		}

		/*
		 * Data to be used when adding permissions - Type - Bug 807755
		 */
		@DataProvider(name="permissionBug807755TestObjects")
		public Object[][] getpermissionBug807755TestObjects() {
			String[][] permissions={
			//	testname								cn  					right		Type		 			
			{ "add_permission_type_bug807755_User1",	"Bug 807755_User1",		"write",	"User"        },
			{ "add_permission_type_bug807755_Host",		"Bug 807755_Host",		"write",	"Host"        },
			{ "add_permission_type_bug807755_Service",	"Bug 807755_Service",	"write",	"Service"     },
			{ "add_permission_type_bug807755_Usergroup","Bug 807755_Usergroup",	"write",	"User Group"  },
			{ "add_permission_type_bug807755_Hostgroup","Bug 807755_Hostgroup",	"write",	"Host Group"   },
			{ "add_permission_type_bug807755_Netgroup",	"Bug 807755_Netgroup",	"write",	"Netgroup"    },
			{ "add_permission_type_bug807755_DNSRecord","Bug 807755_DNSRecord",	"write",	"DNS Resource Record"        } };
			
			return permissions;	
		}
		
		/*
		 * Data to be used when adding permissions - Type - Bug 807755
		 */
		@DataProvider(name="permissionBug783500TestObjects")
		public Object[][] getpermissionBug783500TestObjects() {
			String[][] permissions={
			//	testname									cn  					right		Type		 			
			{ "add_permission_type_bug783500_Netgroup",		"Bug 783500_Netgroup",	"write",	"Netgroup"        } };
			
			return permissions;	
		}
	
		/*
		 * Check for Required fields when adding permissions
		 */
		@DataProvider(name="permissionRequiredFieldAddTestObjects")
		public Object[][] getpermissionRequiredFieldAddTestObjects() {
			String[][] permissions={
	        //	testname									Type			Expected Error			
			{ "add__blank_permission_name_perm",			"Type",			"Required field"		},
			{ "add__blank_permission_name_perm_subtree",	"Subtree",		"Required field"		},
			{ "add__blank_permission_name_perm_filter",		"Filter",		"Required field"		},
			{ "add__blank_permission_name_perm_targetgrp",	"Target group",	"Required field"		}  }; 
		
			return permissions;	
		}
		
		/*
		 * Data to be used when adding permissions - Target group - search for existing group
		 */
		@DataProvider(name="permissionMemberOfAddTestObjects")
		public Object[][] getpermissionMemberOfAddTestObjects() {
			String[][] permissions={
			//	testname										cn  				right,		Attribute			MemberOfGroup			
			{ "add_permission_memberofgroup_searchexisting",	"Manage Group3",	"write",	"description", 		"permissiontestgroup"  } }; 
			
			return permissions;	
		}
		
		/*
		 * Data to be used when adding permissions - Target group - search for nonexistent group
		 */
		@DataProvider(name="permissionMissingMemberOfAddTestObjects")
		public Object[][] getpermissionMissingMemberOfAddTestObjects() {
			String[][] permissions={
			//	testname										cn  				right,		Attribute			MemberOfGroup			
			{ "add_permission_memberofgroup_searchnonexisting",	"Manage Group4",	"write",	"description", 		"nonexistentgroup" 	 } };
		
			return permissions;	
		}
		
		/*
		 * Data to be used when deleting multiple permissions
		 */
		@DataProvider(name="permissionMultipleDeleteTestObjects")
		public Object[][] getpermissionMultipleDeleteTestObjects() {
			String[][] permissions={
			//	testname								Search For		cn1  				cn2					cn3			
			{ "delete_permission_multiple_delete",		"Manage",		"Manage User1",		"Manage Group1",	"Manage Host1" 	 } };
		
			return permissions;	
		}
		
		/*
		 * Data to be used when expanding/collapsing permissions
		 */
		@DataProvider(name="permissionExpandCollapseTestObjects")
		public Object[][] getpermissionExpandCollapseTestObjects() {
			String[][] permissions={
			//	testname						cn						
			{ "collapse_expand_permission",		"Certificate Remove Hold" 	 } };
		
			return permissions;	
		}
		
		/*
		 * Data to be used when expanding/collapsing permissions
		 */
		@DataProvider(name="permissionModifyTestObjects")
		public Object[][] getpermissionModifyTestObjects() {
			String[][] permissions={
			//	testname				cn								right		Member Of Group			Type		Attribute		
			{ "edit_permission",		"Modify netgroup membership", 	"add",		"permissiontestgroup",	"Netgroup",	"description"	 } };
		
			return permissions;	
		}
}