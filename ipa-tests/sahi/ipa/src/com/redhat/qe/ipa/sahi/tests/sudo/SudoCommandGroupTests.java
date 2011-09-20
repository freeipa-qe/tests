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
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;

public class SudoCommandGroupTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(SudoCommandGroupTests.class.getName());
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.setStrictVisibilityCheck(true);
		sahiTasks.navigateTo(commonTasks.sudoCommandGroupPage, true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&sudocmdgroup-facet=search" ;
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.sudoCommandGroupPage, true);
		}		
	}		
	

	/*
	 * Add Sudo Command Groups - positive tests
	 */
	@Test (groups={"sudoruleCommandGroupAddTests"}, dataProvider="getSudoruleCommandGroupAddTestObjects")	
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
	@Test (groups={"sudoCommandGroupCancelAddTests"}, description="Add but Cancel Adding Sudo Rule", dataProvider="getSudoCommandGroupCancelAddTestObjects")	
	public void testSudoCommandGroupCancelAdd(String testName, String cn, String description) throws Exception {
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn.toLowerCase()).exists(), "Verify Sudo Command Group " + cn + " doesn't already exist");
		
		//new test rule can be added now
		SudoTasks.createSudoCommandGroupAdd(sahiTasks, cn, description,  "Cancel");
		
		//verify rule was not added
		Assert.assertFalse(sahiTasks.link(cn.toLowerCase()).exists(), "Verify Sudo Command Group " + cn + "  was not added");
	}
	
	/*
	 * Cancel Del Sudo Command Group - positive tests
	 */
	@Test (groups={"sudoCommandGroupCancelDelTests"}, dataProvider="getSudoruleCommandGroupDelTestObjects",  dependsOnGroups={"sudoruleCommandGroupAddTests"})	
			public void testSudoCommandGroupCancelDel(String testName, String cn, String description) throws Exception {
				//verify command group to be deleted exists
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Verify sudocommand group" + cn + "  to be deleted exists");
				
				//new sudo command group can be deleted now
				SudoTasks.deleteSudoCommandGroupDel(sahiTasks, cn, description, "Cancel");
				
				//verify sudo rule command group was not deleted
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Sudorule Command Group" + cn + "  was not deleted");
	} 
	
	/*
	 * Del Sudo Command Group - positive tests
	 */
	@Test (groups={"sudoCommandGroupDelTests"}, dataProvider="getSudoruleCommandGroupDelTestObjects", dependsOnGroups={"sudoruleCommandGroupAddTests", "sudoruleCommandGroupCancelDelTests"})	
			public void testSudoCommandGroupDel(String testName, String cn, String description) throws Exception {
				//verify command group to be deleted exists
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn.toLowerCase()).exists(), "Verify sudocommand group" + cn + "  to be deleted exists");
				
				//new sudo command group can be deleted now
				SudoTasks.deleteSudoCommandGroupDel(sahiTasks, cn, description, "Delete");
				
				//verify sudo rule command group was added successfully
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn.toLowerCase()).exists(), "Sudorule Command Group" + cn + "  deleted successfully");
	} 
	

	/*
	 * Add, and then add another Sudo Rule
	 */
	@Test (groups={"sudoCommandGroupAddAndAddAnotherTests"}, description="Add and Add Another Sudo Command Group", dataProvider="getSudoCommandGroupAddAndAddAnotherTestObjects")	
	public void testSudoCommandGroupAddAndAddAnother(String testName, String cn1, String cn2, String desc) throws Exception {		
		Assert.assertFalse(sahiTasks.link(cn1.toLowerCase()).exists(), "Verify Sudo Command Group " + cn1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(cn2.toLowerCase()).exists(), "Verify Sudo Command Group " + cn2 + " doesn't already exist");
		
		SudoTasks.addSudoCommandGroupThenAddAnother(sahiTasks, cn1, cn2, desc);
		
		Assert.assertTrue(sahiTasks.link(cn1.toLowerCase()).exists(), "Added Sudo Command Group " + cn1 + "  successfully");
		Assert.assertTrue(sahiTasks.link(cn2.toLowerCase()).exists(), "Added Sudo Command Group " + cn2 + "  successfully");
	}
	
	// Add and edit
	
	// Cancel adding a member
	
	// Add 3 members
	
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
	@Test (groups={"invalidSudoCommanGroupModifyTests"}, dataProvider="getSudoruleCommandGroupInvalidModifyTestObjects",  dependsOnGroups={"sudoruleCommandGroupAddTests"})	
	public void testInvalidSudoCommandModify(String testName, String cn, String description, String expectedError) throws Exception {
		
		SudoTasks.modifySudoruleCommandGroupWithInvalidSetting(sahiTasks, cn, description, expectedError);
	}
	
	
	
	@Test (groups={"invalidSudoCommanGroupAddTests"}, dataProvider="getSudoruleCommandGroupInvalidAddTestObjects")
	public void testInvalidSudoCommandAdd(String testName, String cn, String description, String expectedError) throws Exception {
		
		SudoTasks.createInvalidSudoCommandGroup(sahiTasks, cn, description, expectedError);
	}
	
	
		
	@Test (groups={"invalidSudoCommanGroupAddRequiredFieldTests"}, dataProvider="getSudoRuleCommandGroupRequiredFieldTestObjects")
	public void testInvalidSudoCommandAddRequiredFieldTest(String testName, String cn,String expectedError) throws Exception {
		
		SudoTasks.createSudoCommandGroupWithRequiredField(sahiTasks, cn, "", expectedError);
	}
	
	
	
	/*
	 * Delete multiple Sudo Rules
	 */
	@Test (groups={"sudoCommandGroupMultipleDeleteTests"}, description="Delete Multiple Rules", dataProvider="getMultipleSudoCommandGroupTestObjects", 
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
				"Sudo Group 3"
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
		ll.add(Arrays.asList(new Object[]{ "sudo_commandgroup",				"sudo group1",				"group1 with basic commands"	} ));
		ll.add(Arrays.asList(new Object[]{ "sudo_commandgroup_long",		"abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789",	"long group name"      } ));
		ll.add(Arrays.asList(new Object[]{ "sudo_commandgroup_specialchar",	"S@ud*o#Ru?le", 			"group with special char - in De$c"      } ));
		
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
		ll.add(Arrays.asList(new Object[]{ "sudo_commandgroup",				"Sudo Group 2",				"cancel adding this group"	} ));
		
		return ll;	
	}

	/*
	 * Data to be used when deleting sudo command groups - for positive cases
	 */
	@DataProvider(name="getSudoruleCommandGroupDelTestObjects")
	public Object[][] getSudoruleCommandGroupDelTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteSudoruleCommandGroupDelTestObjects());
	}
	protected List<List<Object>> deleteSudoruleCommandGroupDelTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   			description
		ll.add(Arrays.asList(new Object[]{ "delete_sudo_commandgroup",		"sudo group1",		"group1 with basic commands"	} ));
					        
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding sudo command groups - for positive cases
	 */
	@DataProvider(name="getSudoruleCommandGroupInvalidModifyTestObjects")
	public Object[][] getSudoruleCommandGroupInvalidModifyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleCommandGroupInvalidModifyTestObjects());
	}
	protected List<List<Object>> createSudoruleCommandGroupInvalidModifyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			cn   				description		expected error
		ll.add(Arrays.asList(new Object[]{ "sudo_commandgroup",		"sudo group1",		"", 			"Input form contains invalid or missing values."	} ));
		
		return ll;	
	}
	
	
	@DataProvider(name="getSudoruleCommandGroupInvalidAddTestObjects")
	public Object[][] getSudoruleCommandGroupInvalidAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleCommandGroupInvalidAddTestObjects());
	}
	protected List<List<Object>> createSudoruleCommandGroupInvalidAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname												cn   						description
		ll.add(Arrays.asList(new Object[]{ "sudo_commandgroup_with trailing_space_in_desc",				"sudo group2",				"Description with trailing space ",		"invalid 'desc': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "sudo_commandgroup_with leading_space_in_desc",				"sudo group2",				" Description with leading space",		"invalid 'desc': Leading and trailing spaces are not allowed"      } ));
		ll.add(Arrays.asList(new Object[]{ "sudo_commandgroup_with leading_space_in_name",				" sudo group2",				"Name with leading space",				"invalid 'sudocmdgroup_name': Leading and trailing spaces are not allowed"      } ));
		ll.add(Arrays.asList(new Object[]{ "sudo_commandgroup_with trailing_space_in_name",				"sudo group2 ",				"Name with trailing space",				"invalid 'sudocmdgroup_name': Leading and trailing spaces are not allowed"      } ));
		
		
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
		
        //										testname							cn					expected_Error   
		ll.add(Arrays.asList(new Object[]{ "create_blank_sudocommandgroup",			"",					"Required field"      } ));
		
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
		
        //										testname							cn1					cn2					desc   
		ll.add(Arrays.asList(new Object[]{ "create_two_good_sudocommandgroups",		"Sudo Group 2",		"Sudo Group 3", 	"testing sudo groups"  } ));
		
		return ll;	
	}
	
	
	
	/*
	 * Data to be used when deleting multiple rules 
	 */
	@DataProvider(name="getMultipleSudoCommandGroupTestObjects")
	public Object[][] getMultipleSudoCommandGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteMultipleSudoCommandGroupTestObject());
	}
	protected List<List<Object>> deleteMultipleSudoCommandGroupTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname							cn1					cn2					   
		ll.add(Arrays.asList(new Object[]{ "create_two_good_sudocommandgroups",		"Sudo Group 2",		"Sudo Group 3" } ));
		
		return ll;	
	}

}
