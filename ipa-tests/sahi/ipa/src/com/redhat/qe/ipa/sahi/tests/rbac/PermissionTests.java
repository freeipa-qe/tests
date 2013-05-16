package com.redhat.qe.ipa.sahi.tests.rbac;

/*
 * Review comments:
 * Permissions:

2) Possibly more data for different target types in
add_permission_type_{type}_xxx, add_permission_filter_xxx,
add_permission_targetgroup_xxx, add_permission_subtree_xxx. Especialy
test if all offer attrs can be added or if table is missing some (for
type and targetgroup). Same for editing. Some of it may be covered by
testing for 807755. 
// nk: 807755 tests to see if all the attr provided are for the type
// and if other attr are listed - it will throw error.
// once bug is fixed - other attr will not be available to choose...so cannot test that

3)  add_permission_type and add_permission_subtree can also have a
memberof' option (in formlabeled as 'Member of group')
//nk: permissionModifyTests has test for permission_type; added for subtree

4) add: no required check for rights //nk:it is available at createPermissionWithRequiredField()
5) no required checks in edit // nk: done
6) missing test for privileges tab (member_privilege) //nk: done


Some general thoughts, not neccessary missing in this test suite:
I think that they may be nicely covered by Yi's new testing framework.

a) Test if all required attributes in add or details page cause error if
not entered/cleared (assuming all other required are valid).
//nk: when doing add - is available at createPermissionWithRequiredField()
//nk: when doing details - done

b) Check clearing of all non required attrs if previously set. Reason -
server may have required attributes which may be not marked as required
in UI, but they may not be required in add because they have default value.
// nk: attributes are not required
// if attr is not specified, permission does not allow that attribute to be read/updated/deleted
// done: Add a test in modify to clear attr and update

c) general tests for member, memberof,... tabs:
    1) add one, multiple // nk: done
    2) delete one, multiple // nk: done
    3) simulate concurrent add/delete and expect error. In details: open
two windows which don't share session, use forms login, in both window
open add dialog and select same value, in both windows click add - the
latter should cause error. Similar for remove. I'm not sure if your
testing environment can do that. //nk: TODO : will look into it....
 */

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
import com.redhat.qe.ipa.sahi.tasks.PermissionTasks;
import com.redhat.qe.ipa.sahi.tasks.PrivilegeTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;


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
			PermissionTasks.verifyPermissionType(sahiTasks, cn, rights, type, attributes, "");		
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
		* Find Permission with 'dns' filter - Bug 815364
		* Search 
		*/
		@Test (groups={"permissionBug815364Tests"}, description="Verify Bug 815364 - Search for permission with 'dns' as the filter, cases are not correct for some of the permissions", 
				dataProvider="permissionBug815364TestObjects")	
		public void testPermissionBug815364(String testName, String filter) throws Exception {		
			CommonTasks.search(sahiTasks, filter);		
			String[] dnsEntries={"Read DNS Entries", "add dns entries", "remove dns entries", "update dns entries", "Write DNS Configuration"};
			for(String dns:dnsEntries){
					Assert.assertTrue(sahiTasks.link(dns).exists(), "" + dns + " exists");
			}
			CommonTasks.clearSearch(sahiTasks);
		}
		
		/*
		 * Attribute does not Refresh when Type is changed - Bug 811207 
		 */
		@Test (groups={"permissionBug811207Tests"}, description="Verify Bug 811207 - Attributes does not Refresh when Type is changed", 
				dataProvider="permissionBug811207TestObjects")	
		public void testPermissionBug811207(String testName, String cn, String right, String type1, String type2, String buttonToClick) throws Exception {		
			sahiTasks.navigateTo(commonTasks.permissionPage, true);
			String attributes[] = {"description"};
			String rights[] = {right};
			PermissionTasks.createPermissionWithType(sahiTasks, cn, rights, type1, attributes, buttonToClick);
			CommonTasks.search(sahiTasks, cn);
			sahiTasks.link(cn).click();
			if(sahiTasks.select("type").exists())
				sahiTasks.select("type").choose("Service");
			Assert.assertFalse(sahiTasks.checkbox("description").exists(), "Attributes have been refreshed when type changed");
			sahiTasks.span("Reset").click();
			sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
			
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
			PermissionTasks.verifyPermissionType(sahiTasks, cn, rights, type, attributes, memberOfGroup);	
			
			PermissionTasks.undoResetUpdatePermission(sahiTasks, cn, "Permissions", right, "undo");
			PermissionTasks.undoResetUpdatePermission(sahiTasks, cn, "Member of group", memberOfGroup, "Reset");
			if (!attribute.equals("none") && (!attribute.isEmpty()))
				PermissionTasks.undoResetUpdatePermission(sahiTasks, cn, "Attributes", attribute, "Update");
			
			if(cn.equals("Modify netgroup membership"))
				PermissionTasks.RevertChanges(sahiTasks,cn,right,attribute);
			
			CommonTasks.clearSearch(sahiTasks);
		}
		
		
		/*
		 * Edit the Settings for the Permission with Invalid values
		 */
		@Test (groups={"permissionInvalidModifyTests"}, description="Edit Settings for Permission with invalid values",
				dataProvider="permissionInvalidModifyTestObjects")
		public void testPermissionInvalidModify(String testName, String cn, String right, String type, String expectedError) throws Exception {		
			//verify permission to be edited exists
			CommonTasks.search(sahiTasks, cn);
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Permission " + cn + " to be edited exists");
			
			//modify this permission
			PermissionTasks.invalidModifyPermission(sahiTasks, cn, right, type, expectedError);
			
			CommonTasks.clearSearch(sahiTasks);
		}
		
		/*
		 * Add a permission, add or cancel to add privilege
		 */
		@Test (groups={"permissionAddAndAddPrivilegesTests"}, description="Add Permission and Add Privileges to it", 
				dataProvider="permissionAddAndAddPrivilegesTestObjects")	
		public void testPermissionAddAndAddPrivileges(String testName, String cn, String right1, String right2, String type,
				 String privilege1, String privilege2, String buttonToClick) throws Exception {		
			//verify permission doesn't exist
			CommonTasks.search(sahiTasks, cn);
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify permission " + cn + " doesn't already exist");
					
			String rights[] = {right1, right2};
			String privileges[] = {privilege1, privilege2};
			//new permission can be added now
			PermissionTasks.addPermissionAddPrivilege(sahiTasks, cn, rights, type,  privileges, buttonToClick);
			sahiTasks.span("Refresh").click();
			//verify privilege was added successfully
			CommonTasks.search(sahiTasks, cn);
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Added permission " + cn + "  successfully");
			String privilegesToVerify[] = {privilege1, privilege2};
			if (buttonToClick.equals("Add")) {
				PermissionTasks.verifyPermissionMembership(sahiTasks, cn, privilegesToVerify, true);
			}
			else
				PermissionTasks.verifyPermissionMembership(sahiTasks, cn, privilegesToVerify, false);
			CommonTasks.clearSearch(sahiTasks);
				
		}
		
		
		/*
		 * For a permission, delete privilege
		 */
		@Test (groups={"permissionDeleteMemberTests"}, description="Delete Member from a Permission", 
				dataProvider="permissionDeleteMemberTestObjects",
				dependsOnGroups={"permissionAddAndAddPrivilegesTests"} )	
		public void testPermissionDeleteMember(String testName, String cn,  String member1,	String member2, 
				String allOrOne, String buttonToClick) throws Exception {
			CommonTasks.search(sahiTasks, cn);
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Permission " + cn + "  exists");			
			
			
			String members[] = {member1, member2};
			
			
			PermissionTasks.deleteMemberFromPermission(sahiTasks, cn, members, allOrOne, buttonToClick);
			
			//verify
			if (buttonToClick.equals("Cancel"))
				PermissionTasks.verifyPermissionMembership(sahiTasks, cn, members, true);
			else
				PermissionTasks.verifyPermissionMembership(sahiTasks, cn, members, false);
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
			if (sahiTasks.link("User Groups").in(sahiTasks.div("content nav-space-3")).exists())
				sahiTasks.link("User Groups").in(sahiTasks.div("content nav-space-3")).click();
			if (sahiTasks.link(groupName).exists())
				GroupTasks.deleteGroup(sahiTasks, groupName);
			
			sahiTasks.navigateTo(commonTasks.permissionPage, true);
			String[] permissionTestObjects = {"Manage User1",
					"Manage User2",	
					"Manage Hostgroup1",
					"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",
					"Manage_User-",
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
					"Manage Group4",
					"Manage SELinux",
					"Manage Sudo",
					"Manage Automount",
					"Bug811207_permission"
			};
			
			for (String permissionTestObject : permissionTestObjects) {
				log.fine("Cleaning Permission: " + permissionTestObject);
				PermissionTasks.deletePermission(sahiTasks, permissionTestObject, "Delete");
			} 
			
			//Reset permissions to what was installed
			sahiTasks.navigateTo(commonTasks.permissionPage, true);
			CommonTasks.search(sahiTasks, "Modify netgroup membership");
			sahiTasks.link("Modify netgroup membership").click();
			sahiTasks.checkbox("add").click();
			sahiTasks.span("icon combobox-icon").click();
			sahiTasks.select("list").choose("");
			sahiTasks.checkbox("description").click();
			sahiTasks.span("Update").click();	
			sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
			
			sahiTasks.navigateTo(commonTasks.permissionPage, true);
			CommonTasks.search(sahiTasks, "Remove Automount keys");
			sahiTasks.link("Remove Automount keys").click();
			sahiTasks.checkbox("add").click();
			sahiTasks.span("icon combobox-icon").click();
			sahiTasks.select("list").choose("");
			sahiTasks.span("Update").click();	
			sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
			//win specific ::error showed up because of ticket3028 ,and when hitting the backlink ,it will say unsaved changes ,have to click reset in win .otherwise it will lead to upcoming failures 
		    if (sahiTasks.span("Reset[1]").exists()) {
		    	sahiTasks.span("Reset[1]").click();
		    	sahiTasks.span("Cancel").click();
		    }
			
			sahiTasks.navigateTo(commonTasks.permissionPage, true);
			CommonTasks.search(sahiTasks, "Enroll a host");
			sahiTasks.link("Enroll a host").click();
			sahiTasks.checkbox("objectclass").click();
			sahiTasks.span("Update").click();	
			sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
			
			sahiTasks.navigateTo(commonTasks.permissionPage, true);
			CommonTasks.clearSearch(sahiTasks);
			PermissionTasks.RevertChanges(sahiTasks, "Modify netgroup membership", "add", "description");
		}
		
		
		/*******************************************************
		 ************      DATA PROVIDERS     ******************
		 *******************************************************/
		/*
		 * TODO: Add test for paging
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
			{ "add_permission_type_hostgroup_bug783502",			"Manage Hostgroup1",		"write",	"add",		"delete",	"Host Group","businesscategory",	"owner",		""			},
			{ "add_permission_type_user_long",						"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",	"write",	"",			"",			"User Group","description",		"",				""			},
			{ "add_permission_type_user_dash_underscore",			"Manage_User-",				"write",	"",			"",			"User",		"description",		"carlicense",	""	}};
			//won't fix bug
			//{ "add_permission_type_user_bug807304",	 				"Test < Permission > Bug",	"write",	"",			"",			"User",		"description",		"carlicense",	"photo"		} };     
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
			{ "add_permission_filter_undo_attr",			"Manage Group4",		"write",	"(&(!(objectclass=posixgroup))(objectclass=ipausergroup))",		"memberof", 		"member"			} };
			
			return permissions;	
		}
		
		
		/*
		 * Data to be used when adding permissions - Type - Negative tests
		 */
		@DataProvider(name="permissionInvalidAddTypeTestObjects")
		public Object[][] getPermissionInvalidAddTypeTestObjects() {
			String[][] permissions={
	        //	testname								cn  								right1,		right2,		right3,		Type		Attributes1			Attributes2		Attributes3 	Expected Error			
			{ "add_permission_type_user_duplicate",		"Manage User1",						"write",	"",			"",			"User",		"description",		"carlicense",	"photo",		"This entry already exists"								},
			{ "add_permission_type_user_specialchar",	"M~a@n$a#g$e % U^s&e*r? ] 1 [ {A",	"write",	"",			"",			"User",		"description",		"carlicense",	"",				"May only contain letters, numbers, -, _, and space"	} 
			}; 
		
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
		 * Data to be used when searching permissions with filter 'dns' - Type - Bug 815364
		 */
		@DataProvider(name="permissionBug815364TestObjects")
		public Object[][] getpermissionBug815364TestObjects() {
			String[][] permissions={
			//	testname								filter  			 			
			{ "add_permission_type_bug815364_search",	"dns"        }	};
			
			return permissions;	
		}
		
		/*
		 * Data to be used when adding permissions - Type - Bug 811207
		 */
		@DataProvider(name="permissionBug811207TestObjects")
		public Object[][] getpermissionBug811207TestObjects() {
			String[][] permissions={
			//	testname					cn  					right		type1			type2		buttonToClick		 			
			{ "add_permission_type_bug811207_search",	"Bug811207_permission",	"write",	"User Group",	"Services",	"Add"   }	};
			
			return permissions;	
		}
		
		/*
+		 * Data to be used when adding permissions - Type - Bug 783500
+		 */
	
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
		 * Data to be used when editing permissions
		 */
		@DataProvider(name="permissionModifyTestObjects")
		public Object[][] getpermissionModifyTestObjects() {
			String[][] permissions={
			//	testname					cn								right		Member Of Group			Type		Attribute		
			{ "edit_permission",					"Modify netgroup membership", 	"add",		"ipausers",			"Netgroup",	"description"	 },
			{ "edit_permission_subtree_ticket3028",	"Remove Automount keys", 		"add",		"ipausers",				"",			""	 },
			{ "edit_permission_clear_attr",			"Enroll a host", 				"",			"",		"Host",			"none"	 } };
					 		
			return permissions;	
		}
		
		/*
		 * Data to be used when editing permissions with invalid data
		 */
		@DataProvider(name="permissionInvalidModifyTestObjects")
		public Object[][] getpermissionInvalidModifyTestObjects() {
			String[][] permissions={
			//	testname									cn									right		type		Expected Error		
			{ "edit_permission_with_no_rights",				"Add Services", 					"add",		"",			"Input form contains invalid or missing values."							 },
			{ "edit_permission_with_invalid_type_bz807755",	"Add krbPrincipalName to a host", 	"",			"Netgroup",	"invalid 'target': type, filter, subtree and targetgroup are mutually exclusive"								 },
			{ "edit_permission_with_invalid_type",			"Add krbPrincipalName to a host", 	"",			"Service",	"invalid 'target': type, filter, subtree and targetgroup are mutually exclusive"	 } };
		
			return permissions;	
		}
		
		
		/*
		 * Data to be used when editing permissions with invalid data
		 */
		@DataProvider(name="permissionAddAndAddPrivilegesTestObjects")
		public Object[][] getpermissionAddAndAddPrivilegesTestObjects() {
			String[][] permissions={
			// testName										 cn					right1	 right2		type	 		privilege1							privilege2					buttonToClick		
			{ "add_permission_add_one_privilege",			"Manage SELinux", 	"add",	 "",		"User",			"SELinux User Map Administrators", 	"", 						"Add" },
			{ "add_permission_add_multiple_privilege",		"Manage Sudo", 		"add",	 "",		"Service", 		"Sudo Administrator", 				"Service Administrators", 	"Add" },
			{ "add_permission_add_privilege_cancel",		"Manage Automount",	"write", "",		"User Group", 	"Automount Administrators", 		"", 						"Cancel"},
			};
		
			return permissions;	
		}
		
		
		/*
		 * Data to be used when deleting privilege from permission
		 */		
		@DataProvider(name="permissionDeleteMemberTestObjects")
		public Object[][] getpermissionDeleteMemberTestObjects() {
			String[][] permissions={
	        // testName  									name 				member1 							member2 					allOrOne 	buttonToClick					  			
			{ "add_permission_canceldelete_all_privilege",	"Manage Sudo",	 	"Sudo Administrator",				"Service Administrators",	"All",		"Cancel"	},
			{ "add_permission_delete_all_privilege",		"Manage Sudo",	 	"Sudo Administrator",				"Service Administrators",	"All",		"Delete"	},
			{ "add_permission_delete_one_privilege",		"Manage SELinux",	"SELinux User Map Administrators",	"",							"One",		"Delete"	},
			};
	        
			return permissions;	
		}	
}