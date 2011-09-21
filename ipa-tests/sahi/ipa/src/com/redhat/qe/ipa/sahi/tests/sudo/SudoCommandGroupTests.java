package com.redhat.qe.ipa.sahi.tests.sudo;

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
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;

public class SudoCommandGroupTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(SudoCommandGroupTests.class.getName());
	
	/*
	 * PreRequisite - 
	 */
	
	//Sudo Command used in this testsuite
	private String lsCommandName = "/bin/ls";
	private String lsCommandDescription = "testing ls command for Sudo";
	private String vimCommandName = "/usr/bin/vim";
	private String vimCommandDescription = "testing vim command for Sudo";
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.setStrictVisibilityCheck(true);
		
		sahiTasks.navigateTo(commonTasks.sudoCommandPage, true);
		if (!sahiTasks.link(lsCommandName).exists()) 
			SudoTasks.createSudoCommandAdd(sahiTasks, lsCommandName, lsCommandDescription, "Add");
		if (!sahiTasks.link(vimCommandName).exists()) 
			SudoTasks.createSudoCommandAdd(sahiTasks, vimCommandName, vimCommandDescription, "Add");
		
		
		sahiTasks.navigateTo(commonTasks.sudoCommandGroupPage, true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&sudocmdgroup-facet=search" ;
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			CommonTasks.checkError(sahiTasks);
			log.fine("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.sudoCommandGroupPage, true);
		}		
	}		
	

	/*
	 * Add Sudo Command Groups
	 */
	@Test (groups={"sudoCommandGroupAddTests"}, description="Add Sudo Command Groups", 
			dataProvider="getSudoruleCommandGroupAddTestObjects")	
			public void testSudoCommandGroupAdd(String testName, String cn, String description) throws Exception {
				//verify command group to be added doesn't exist
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn.toCharArray()).exists(), "Verify sudocommand group " + cn + "  doesn't already exist");
				
				//new sudo rule command can be added now
				SudoTasks.createSudoCommandGroupAdd(sahiTasks, cn, description, "Add");
				
				//verify sudo command group was added successfully
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Added Sudo Command Group" + cn + "  successfully");
	} 
	
	/*
	 * Add, but Cancel adding SudoRule
	 */
	@Test (groups={"sudoCommandGroupCancelAddTests"}, description="Add but Cancel Adding Sudo Command Group", 
			dataProvider="getSudoCommandGroupCancelAddTestObjects")	
	public void testSudoCommandGroupCancelAdd(String testName, String cn, String description) throws Exception {
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn.toLowerCase()).exists(), "Verify Sudo Command Group " + cn + " doesn't already exist");
		
		//new test rule can be added now
		SudoTasks.createSudoCommandGroupAdd(sahiTasks, cn, description,  "Cancel");
		
		//verify rule was not added
		Assert.assertFalse(sahiTasks.link(cn.toLowerCase()).exists(), "Verify Sudo Command Group " + cn + "  was not added");
	}
	
	/*
	 * Cancel Del Sudo Command Group
	 */
	@Test (groups={"sudoCommandGroupCancelDelTests"}, description="Cancel deleting a Sudo Command Group", 
			dataProvider="getSudoCommandGroupCancelDelTestObjects",  
			dependsOnGroups={"sudoCommandGroupAddTests"})	
			public void testSudoCommandGroupCancelDel(String testName, String cn) throws Exception {
				//verify command group to be deleted exists
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Verify sudocommand group" + cn + "  to be deleted exists");
				
				//new sudo command group can be deleted now
				SudoTasks.deleteSudoCommandGroupDel(sahiTasks, cn, "Cancel");
				
				//verify sudo rule command group was not deleted
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Sudorule Command Group" + cn + "  was not deleted");
	} 
	
	/*
	 * Del Sudo Command Group 
	 */
	@Test (groups={"sudoCommandGroupDelTests"}, description="Delete a Sudo Command Group",
			dataProvider="getSudoCommandGroupDelTestObjects", 
			dependsOnGroups={"sudoCommandGroupAddTests", "sudoCommandGroupCancelDelTests"})	
			public void testSudoCommandGroupDel(String testName, String cn) throws Exception {
				//verify command group to be deleted exists
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Verify sudocommand group" + cn + "  to be deleted exists");
				
				//new sudo command group can be deleted now
				SudoTasks.deleteSudoCommandGroupDel(sahiTasks, cn, "Delete");
				
				//verify sudo rule command group was added successfully
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn.toLowerCase()).exists(), "Sudorule Command Group" + cn + "  deleted successfully");
	} 
	

	/*
	 * Add, and then add another Sudo Rule
	 */
	@Test (groups={"sudoCommandGroupAddAndAddAnotherTests"}, description="Add and Add Another Sudo Command Group", 
			dataProvider="getSudoCommandGroupAddAndAddAnotherTestObjects")	
	public void testSudoCommandGroupAddAndAddAnother(String testName, String cn1, String cn2, String desc) throws Exception {		
		Assert.assertFalse(sahiTasks.link(cn1.toLowerCase()).exists(), "Verify Sudo Command Group " + cn1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(cn2.toLowerCase()).exists(), "Verify Sudo Command Group " + cn2 + " doesn't already exist");
		
		SudoTasks.addSudoCommandGroupThenAddAnother(sahiTasks, cn1, cn2, desc);
		
		Assert.assertTrue(sahiTasks.link(cn1.toLowerCase()).exists(), "Added Sudo Command Group " + cn1 + "  successfully");
		Assert.assertTrue(sahiTasks.link(cn2.toLowerCase()).exists(), "Added Sudo Command Group " + cn2 + "  successfully");
	}
	
	
	/*
	 * Add, and edit Sudo command group
	 */	
	@Test (groups={"sudoCommandGroupAddAndEditTests"}, description="Add and Edit a Sudo Command Group",  
			dataProvider="getAddAndEditSudoCommandGroupTestObjects")	
	public void testSudoCommandGroupAddAndEdit(String testName, String cn, String description) throws Exception {
		
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify Command Group " + cn + " doesn't already exist");
		
		//new test rule can be added now
		SudoTasks.addAndEditSudoCommandGroup(sahiTasks, cn, description, lsCommandName);				
		
		//verify changes	
		SudoTasks.verifySudoCommandGroupUpdates(sahiTasks, cn, description, lsCommandName);
	}

	
	
	// Cancel adding a member
	
	// Add 3 members
	
	/*
	 * Enroll a Sudo command to a sudo command group
	 * 
	 */
	@Test (groups={"sudoCommandGroupEnrollTests"},  description="Enroll a Command into a Command Group", 
			dataProvider="getEnrollIntoSudoCommandGroupTestObjects", 
			dependsOnGroups={"sudoCommandGroupAddAndEditTests", "sudoCommandGroupCancelEnrollTests"})	
	public void testSudoCommandGroupEnroll(String testName, String command) throws Exception {
		
		//verify command exists
		Assert.assertTrue(sahiTasks.link(command).exists(), "Verify Command " + command + " exists");
		
		// Enroll command
		//SudoTasks.enrollCommandInCommandGroup(sahiTasks, command, commandGroup, "Enroll");
		
		// Verify membership
		//SudoTasks.verifySudoCommandMembership(sahiTasks, command, commandGroup, true);
		
	}
	

	
	
	// Add a member again
	
	// Cancel removing a member
	
	// Remove a member
	
	// Add a member in 2 groups
	
	// Edit group and navigate back and forth
	
	// Remove member from one group, then another
		
	// Edit - undo/reset/update
	
	// Search
	// expand-Collapse
	
	
	
	/*
	 * negative modify command group characters tests
	 */
	@Test (groups={"invalidSudoCommanGroupModifyTests"}, description="Verify error when adding invalid Sudo Command Group",
			dataProvider="getSudoCommandGroupInvalidModifyTestObjects",  
			dependsOnGroups={"sudoCommandGroupAddTests"})	
	public void testInvalidSudoCommandModify(String testName, String cn, String description, String expectedError) throws Exception {
		
		SudoTasks.modifySudoruleCommandGroupWithInvalidSetting(sahiTasks, cn, description, expectedError);
	}
	
	
	
	@Test (groups={"invalidSudoCommanGroupAddTests"}, description="Verify error when adding invalid Sudo Command Group", 
			dataProvider="getSudoruleCommandGroupInvalidAddTestObjects")
	public void testInvalidSudoCommandAdd(String testName, String cn, String description, String expectedError) throws Exception {
		
		SudoTasks.createInvalidSudoCommandGroup(sahiTasks, cn, description, expectedError);
	}
	
	
		
	@Test (groups={"invalidSudoCommanGroupAddRequiredFieldTests"}, description="Verify error when adding blank Sudo Command group",
			dataProvider="getSudoRuleCommandGroupRequiredFieldTestObjects")
	public void testInvalidSudoCommandAddRequiredFieldTest(String testName, String cn,String expectedError) throws Exception {
		
		SudoTasks.createSudoCommandGroupWithRequiredField(sahiTasks, cn, "", expectedError);
	}
	
	
	
	/*
	 * Delete multiple Sudo Rules
	 */
	@Test (groups={"sudoCommandGroupMultipleDeleteTests"}, description="Delete Multiple Rules", 
			dataProvider="getDeleteMultipleSudoCommandGroupTestObjects", 
			dependsOnGroups={"sudoCommandGroupAddAndAddAnotherTests"})		
	public void testMultipleSudoCommandGroupDelete(String testName, String cn1, String cn2) throws Exception {	
		String cns[] = {cn1.toLowerCase(), cn2.toLowerCase()};
		
		
		//verify rule to be deleted exists
		for (String cn : cns) {
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Sudo Rule " + cn + "  to be deleted exists");
		}			
		//mark this rule for deletion
		SudoTasks.chooseMultiple(sahiTasks, cns);		
		SudoTasks.deleteMultiple(sahiTasks);
	}
	
	

	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException {
		String[] sudoCommandGroupTestObjects = {"S@ud*o#Ru?le",		
				"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",
				"sudo group1",
				"Sudo Group 2",
				"Sudo Group 3",
				"Dev Sudo Group"
				} ;

		//verify rules were found
		for (String sudoCommandGroupTestObject : sudoCommandGroupTestObjects) {
			if (sahiTasks.link(sudoCommandGroupTestObject.toLowerCase()).exists()){
				log.fine("Cleaning Sudo Rule: " + sudoCommandGroupTestObject);
				SudoTasks.deleteSudo(sahiTasks, sudoCommandGroupTestObject.toLowerCase(), "Delete");
			}			
		} 
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	/*
	 * Data to be used when adding sudo command groups - for positive cases
	 */
	@DataProvider(name="getSudoruleCommandGroupAddTestObjects")
	public Object[][] getSudoruleCommandGroupAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleCommandGroupAddTestObjects());
	}
	protected List<List<Object>> createSudoruleCommandGroupAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   						description
		ll.add(Arrays.asList(new Object[]{ "Add Sudo Command Group - good",				"sudo group1",				"group1 with basic commands"	} ));
		ll.add(Arrays.asList(new Object[]{ "Add Sudo Command Group - long",				"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",	"long group name"      } ));
		ll.add(Arrays.asList(new Object[]{ "Add Sudo Command Group - Special Char",		"S@ud*o#Ru?le", 			"group with special char - in De$c"      } ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when cancelling adding sudo command groups - for positive cases
	 */
	@DataProvider(name="getSudoCommandGroupCancelAddTestObjects")
	public Object[][] getSudoCommandGroupCancelAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoCommandGroupCancelAddTestObjects());
	}
	protected List<List<Object>> createSudoCommandGroupCancelAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   						description
		ll.add(Arrays.asList(new Object[]{ "Add but Cancel Adding Sudo Command Group",				"Sudo Group 2",				"cancel adding this group"	} ));
		
		return ll;	
	}

	/*
	 * Data to be used when canceling deleting sudo command groups 
	 */
	@DataProvider(name="getSudoCommandGroupCancelDelTestObjects")
	public Object[][] getSudoCommandGroupCancelDelTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteSudoruleCommandGroupCancelDelTestObjects());
	}
	protected List<List<Object>> deleteSudoruleCommandGroupCancelDelTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname								cn   			
		ll.add(Arrays.asList(new Object[]{ "Cancel deleting a Sudo Command Group",		"sudo group1"	} ));
					        
		return ll;	
	}
	
	/*
	 * Data to be used when deleting sudo command groups
	 */
	@DataProvider(name="getSudoCommandGroupDelTestObjects")
	public Object[][] getSudoCommandGroupDelTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteSudoruleCommandGroupDelTestObjects());
	}
	protected List<List<Object>> deleteSudoruleCommandGroupDelTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   			
		ll.add(Arrays.asList(new Object[]{ "Delete a Sudo Command Group",	"sudo group1"	} ));
					        
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding sudo command groups - for positive cases
	 */
	@DataProvider(name="getSudoCommandGroupInvalidModifyTestObjects")
	public Object[][] getSudoCommandGroupInvalidModifyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoCommandGroupInvalidModifyTestObjects());
	}
	protected List<List<Object>> createSudoCommandGroupInvalidModifyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname													cn   				description		expected error
		ll.add(Arrays.asList(new Object[]{ "Verify error when editing a Command Group to have blank desc",	"sudo group1",		"", 			"Input form contains invalid or missing values."	} ));
		
		return ll;	
	}
	
	
	@DataProvider(name="getSudoruleCommandGroupInvalidAddTestObjects")
	public Object[][] getSudoruleCommandGroupInvalidAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleCommandGroupInvalidAddTestObjects());
	}
	protected List<List<Object>> createSudoruleCommandGroupInvalidAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname																cn   						description
		//TODO : duplicate group
		ll.add(Arrays.asList(new Object[]{ "Verify error when adding Command Group with trailing space in desc",		"sudo group2",				"Description with trailing space ",		"invalid 'desc': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "Verify error when adding Command Group with leading space in desc",			"sudo group2",				" Description with leading space",		"invalid 'desc': Leading and trailing spaces are not allowed"      } ));
		ll.add(Arrays.asList(new Object[]{ "Verify error when adding Command Group with leading space in name",			" sudo group2",				"Name with leading space",				"invalid 'sudocmdgroup_name': Leading and trailing spaces are not allowed"      } ));
		ll.add(Arrays.asList(new Object[]{ "Verify error when adding Command Group with trailing space in name",		"sudo group2 ",				"Name with trailing space",				"invalid 'sudocmdgroup_name': Leading and trailing spaces are not allowed"      } ));
		
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding rules with required fields 
	 */
	@DataProvider(name="getSudoRuleCommandGroupRequiredFieldTestObjects")
	public Object[][] getSudoRuleCommandGroupRequiredFieldTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoRuleCommandGroupRequiredFieldTestObject());
	}
	protected List<List<Object>> createSudoRuleCommandGroupRequiredFieldTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname											cn					expected_Error   
		ll.add(Arrays.asList(new Object[]{ "Verify error when adding blank Sudo Command group",		"",					"Required field"      } ));
		
		return ll;	
	}
	

	/*
	 * Data to be used when adding rules 
	 */
	@DataProvider(name="getSudoCommandGroupAddAndAddAnotherTestObjects")
	public Object[][] getSudoCommandGroupAddAndAddAnotherTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoCommandGroupAndAddAnotherTestObject());
	}
	protected List<List<Object>> createSudoCommandGroupAndAddAnotherTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname								cn1					cn2					desc   
		ll.add(Arrays.asList(new Object[]{ "Add and Add Another Sudo Command Group",	"Sudo Group 2",		"Sudo Group 3", 	"testing sudo groups"  } ));
		
		return ll;	
	}
	
	
	
	/*
	 * Data to be used when deleting multiple rules 
	 */
	@DataProvider(name="getDeleteMultipleSudoCommandGroupTestObjects")
	public Object[][] getDeleteMultipleSudoCommandGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteMultipleSudoCommandGroupTestObject());
	}
	protected List<List<Object>> deleteMultipleSudoCommandGroupTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn1					cn2					   
		ll.add(Arrays.asList(new Object[]{ "Delete Multiple Rules",		"Sudo Group 2",		"Sudo Group 3" } ));
		
		return ll;	
	}

	
	/*
	 * Data to be used when adding and editing a sudo command 
	 */
	@DataProvider(name="getAddAndEditSudoCommandGroupTestObjects")
	public Object[][] getAddAndEditSudoCommandGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddAndEditSudoCommandGroupTestObjects());
	}
	protected List<List<Object>> createAddAndEditSudoCommandGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname							cn					desc  			
		ll.add(Arrays.asList(new Object[]{ "Add and Edit a Sudo Command Group",		"Dev Sudo Group",	"sudo command group for dev"	} ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when  enrolling a command
	 */
	@DataProvider(name="getEnrollIntoSudoCommandGroupTestObjects")
	public Object[][] getEnrollIntoSudoCommandGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createEnrollIntoSudoCommandGroupTestObjects());
	}
	protected List<List<Object>> createEnrollIntoSudoCommandGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname								cn				 			
		ll.add(Arrays.asList(new Object[]{ "Enroll a Command into a Command Group",		"/bin/ln"	} ));
		
		return ll;	
	}
	
	
}
