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
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;

/*
 * Comments from review: 
 * 53. SudoCommandTests.testMultipleSudoCommandDelete should verify the
deletion. //done
 */

public class SudoCommandTests extends SahiTestScript {
	private static Logger log = Logger.getLogger(SudoCommandTests.class.getName());
	
	/*
	 * PreRequisite - 
	 */
	// Sudo Command group used in this testsuite
	private String commandGroup = "symlink";
	private String description = "testing group of link commands";
	
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.setStrictVisibilityCheck(true);
		
		//Add the sudo command group, if not available
		sahiTasks.navigateTo(commonTasks.sudoCommandGroupPage, true);
		if (!sahiTasks.link(commandGroup).exists()) {
			SudoTasks.createSudoCommandGroupAdd(sahiTasks, commandGroup, description, "Add");
		}
		
		
		sahiTasks.navigateTo(commonTasks.sudoCommandPage, true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&sudocmd-facet=search" ;
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			//CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.sudoCommandPage, true);
		}		
	}
	
	
	/*
	 * Add Sudo Commands - positive tests
	 */
	@Test (groups={"sudoCommandAddTests"}, description="Add a Sudo Command",  
			dataProvider="getSudoCommandAddTestObjects")	
	public void testSudoCommandAdd(String testName, String cn, String description) throws Exception {
				//verify command to be added doesn't exist
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify sudocommand " + cn + "  doesn't already exist");
				
				//new sudo rule command can be added now
				SudoTasks.createSudoCommandAdd(sahiTasks, cn, description, "Add");
				
				//verify sudo rule command was added successfully
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Added Sudorule Command " + cn + "  successfully");
	} 
	
	/*
	 * Cancel Add Sudo Commands - positive tests
	 */
	@Test (groups={"sudoCommandCancelAddTests"}, description="Cancel adding a Sudo Command", 
			dataProvider="getSudoCommandCancelAddTestObjects")	
	public void testSudoCommandCancelAdd(String testName, String cn, String description) throws Exception {
				//verify command to be added doesn't exist
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify sudocommand " + cn + "  doesn't already exist");
				
				//new sudo rule command can be added now
				SudoTasks.createSudoCommandAdd(sahiTasks, cn, description, "Cancel");
				
				//verify sudo rule command was not added
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Sudo Command " + cn + "  was not added");
	} 
	
	/*
	 * Cancel Del Sudo Commands - positive tests
	 */
	@Test (groups={"sudoCommandCancelDelTests"}, description="Cancel deleting a Sudo command",  
			dataProvider="getSudoruleCommandCancelDelTestObjects", 
			dependsOnGroups={"sudoCommandAddTests"})	
	public void testSudoCommandCancelDel(String testName, String cn) throws Exception {
				//verify command to be deleted exists
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify sudocommand " + cn + "  to be deleted exists");
				
				//new sudo rule command can be deleted now
				SudoTasks.deleteSudo(sahiTasks, cn, "Cancel");
				
				//verify sudo rule command was not deleted
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Sudorule Command " + cn + "  was not deleted");
	} 
	
	/*
	 * Del Sudo Commands - positive tests
	 */
	@Test (groups={"sudoCommandDelTests"},  description="Delete a Sudo command", 
			dataProvider="getSudoruleCommandDelTestObjects", 
			dependsOnGroups={"sudoCommandAddTests", "sudoCommandCancelDelTests", "invalidSudoCommandAddTests"})	
	public void testSudoCommandDel(String testName, String cn) throws Exception {
				//verify command to be deleted exists
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify sudocommand " + cn + "  to be deleted exists");
				
				//new sudo rule command can be deleted now
				SudoTasks.deleteSudo(sahiTasks, cn, "Delete");
				
				//verify sudo rule command was added successfully
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Sudorule Command " + cn + "  deleted successfully");
	} 
	
	

	/*
	 * Add, and then add another Sudo Command
	 */
	@Test (groups={"sudoCommandAddAndAddAnotherTests"},  description="Add and Add another Sudo command",  
			dataProvider="getAddAndAddAnotherSudoCommandGroupTestObjects")	
	public void testSudoCommandAddAndAddAnother(String testName, String cn1, String cn2) throws Exception {		
		Assert.assertFalse(sahiTasks.link(cn1).exists(), "Verify Sudo Command  " + cn1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(cn2).exists(), "Verify Sudo Command  " + cn2 + " doesn't already exist");
		
		SudoTasks.addSudoCommandThenAddAnother(sahiTasks, cn1, cn2);
		
		Assert.assertTrue(sahiTasks.link(cn1).exists(), "Added Sudo Command  " + cn1 + "  successfully");
		Assert.assertTrue(sahiTasks.link(cn2).exists(), "Added Sudo Command  " + cn2 + "  successfully");
	}
	
	/*
	 * Add, and edit Sudo command
	 */	
	@Test (groups={"sudoCommandAddAndEditTests"}, description="Add and Edit a Sudo command",  
			dataProvider="getAddAndEditSudoCommandTestObjects")	
	public void testSudoCommandAddAndEdit(String testName, String cn, String description) throws Exception {
		
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify Command " + cn + " doesn't already exist");
		
		//new test rule can be added now
		SudoTasks.addAndEditSudoCommand(sahiTasks, cn, description);				
		
		//verify changes	
		SudoTasks.verifySudoCommandUpdates(sahiTasks, cn, description);
	}

	
	/*
	 * Cancel enrolling a Sudo command to a sudo command group
	 * 
	 */
	@Test (groups={"sudoCommandCancelEnrollTests"},  description="Cancel enrolling a Command into a Command Group", 
			dataProvider="getCancelEnrollSudoCommandTestObjects", 
			dependsOnGroups={"sudoCommandAddAndEditTests"})	
	public void testSudoCommandCancelEnroll(String testName, String command) throws Exception {
		
		//verify command exists
		Assert.assertTrue(sahiTasks.link(command).exists(), "Verify Command " + command + " exists");
		
		// Enroll command, but cancel
		SudoTasks.enrollCommandInCommandGroup(sahiTasks, command, commandGroup, "Cancel");
		
		// Verify membership
		SudoTasks.verifySudoCommandMembership(sahiTasks, command, commandGroup, false);
		
	}
		
	
	/*
	 * Enroll a Sudo command to a sudo command group
	 * 
	 */
	@Test (groups={"sudoCommandEnrollTests"},  description="Enroll a Command into a Command Group", 
			dataProvider="getEnrollSudoCommandTestObjects", 
			dependsOnGroups={"sudoCommandAddAndEditTests", "sudoCommandCancelEnrollTests"})	
	public void testSudoCommandEnroll(String testName, String command) throws Exception {
		
		//verify command exists
		Assert.assertTrue(sahiTasks.link(command).exists(), "Verify Command " + command + " exists");
		
		// Enroll command
		SudoTasks.enrollCommandInCommandGroup(sahiTasks, command, commandGroup, "Enroll");
		
		// Verify membership
		SudoTasks.verifySudoCommandMembership(sahiTasks, command, commandGroup, true);
		
	}
	

	
	/*
	 * Cancel deleting a Sudo command from a sudo command group
	 * 
	 */
	@Test (groups={"sudoCommandCancelDeleteEnrolledTests"},  description="Cancel deleting an enrolled command from its group",
			dataProvider="getCancelDelEnrolledSudoCommandTestObjects",
			dependsOnGroups={"sudoCommandAddAndEditTests", "sudoCommandEnrollTests"})	
	public void testSudoCommandCancelDeleteEnrolled(String testName, String command) throws Exception {
		
		//verify command exists
		Assert.assertTrue(sahiTasks.link(command).exists(), "Verify Command " + command + " exists");
		
		// Enroll command
		SudoTasks.deleteCommandFromCommandGroup(sahiTasks, command, commandGroup, "Cancel");
		
		// Verify membership
		SudoTasks.verifySudoCommandMembership(sahiTasks, command, commandGroup, true);
		
	}
	

	/*
	 * Delete a Sudo command from a sudo command group
	 * 
	 */
	@Test (groups={"sudoCommandDeleteEnrolledTests"},  description="Delete an enrolled command from its group", 
			dataProvider="getDeleteEnrolledSudoCommandTestObjects",
			dependsOnGroups={"sudoCommandAddAndEditTests", "sudoCommandEnrollTests", "sudoCommandCancelDeleteEnrolledTests"})	
	public void testSudoCommandDeleteEnrolled(String testName, String command) throws Exception {
		
		//verify command exists
		Assert.assertTrue(sahiTasks.link(command).exists(), "Verify Command " + command + " exists");
		
		// Enroll command
		SudoTasks.deleteCommandFromCommandGroup(sahiTasks, command, commandGroup, "Delete");
		
		// Verify membership
		SudoTasks.verifySudoCommandMembership(sahiTasks, command, commandGroup, false);
		
	}
	
	
	/*
	 *  modify command   description to blank - positive
	 */
	@Test (groups={"sudoCommandModifySettingsTests"},  description="Edit a Sudo Command, and update its description to be blank", 
			dataProvider="getSudoCommandModifyTestObjects", 
			dependsOnGroups={"sudoCommandAddAndEditTests"})	
	public void testSudoCommandModifySettings(String testName, String cn, String description) throws Exception {
		
		SudoTasks.modifySudoCommandSettings(sahiTasks, cn, description);
		//verify changes	
		SudoTasks.verifySudoCommandUpdates(sahiTasks, cn, description);
	}
	
	
	/*
	 * invalid add
	 */
	@Test (groups={"invalidSudoCommandAddTests"},  description="Verify error when adding invalid Sudo Command",
			dataProvider="getSudoCommandInvalidAddTestObjects", 
			dependsOnGroups={"sudoCommandAddTests"})
	public void testInvalidSudoCommandAdd(String testName, String cn, String description, String expectedError) throws Exception {
		
		SudoTasks.createInvalidSudoCommand(sahiTasks, cn, description, expectedError);
	}
	
	
	/*
	 * Add Commands - check required fields - for negative tests
	 */
	@Test (groups={"sudoCommandRequiredFieldAddTests"}, description="Add blank Command", 
			dataProvider="getSudoCommandRequiredFieldTestObjects")	
	public void testSudoCommandRequiredFieldAdd(String testName, String cn, String expectedError) throws Exception {
		//new test user can be added now
		SudoTasks.createWithRequiredFieldMissing(sahiTasks, cn, "sudocmd", expectedError);		
	}
	
	
	
	/*
	 * search
	 */
	
	/*
	 * expand/collapse
	 */
	
	/*
	 * Delete multiple Sudo Rules
	 */
	@Test (groups={"sudoCommandMultipleDeleteTests"}, description="Delete Multiple Sudo Commands", dataProvider="getMultipleDelSudoCommandGroupTestObjects", 
			dependsOnGroups={"sudoCommandAddAndAddAnotherTests"})		
	public void testMultipleSudoCommandDelete(String testName, String cn1, String cn2) throws Exception {	
		String cns[] = {cn1, cn2};
		
		
		//verify command to be deleted exists
		for (String cn : cns) {
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Sudo Rule " + cn + "  to be deleted exists");
		}			
		//mark this rule for deletion
		SudoTasks.chooseMultiple(sahiTasks, cns);		
		SudoTasks.deleteMultiple(sahiTasks);
		
		//verify comamnds were deleted
		for (String cn : cns) {
			Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify Sudo Rule " + cn + "  was deleted successfully");
		}
		
	}
	// Add a command to a command group
	
	
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException {
		String[] sudoCommandTestObjects = {"/bin/date",
 										//	"/bin/cat",
										"/bin/find",
										"/bin/more",
										"/usr/bin/less",
										"/bin/ln",
										"/b@i&n?/~d:a?t+e-",
										"/home/abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789/bin/date"
												} ;

		//verify rules were found
		for (String sudoCommandTestObject : sudoCommandTestObjects) {
			if (sahiTasks.link(sudoCommandTestObject).exists()){
				log.fine("Cleaning Sudo Rule: " + sudoCommandTestObject);
				SudoTasks.deleteSudo(sahiTasks, sudoCommandTestObject, "Delete");
			}			
		} 
		
		sahiTasks.navigateTo(commonTasks.sudoCommandGroupPage, true);
		if (sahiTasks.link(commandGroup).exists())
			SudoTasks.deleteSudoCommandGroupDel(sahiTasks, commandGroup, "Delete");
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	/*
	 * Data to be used when adding sudo rule commands - for positive cases
	 */
	@DataProvider(name="")
	public Object[][] getSudoCommandAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoCommandAddTestObjects());
	}
	protected List<List<Object>> createSudoCommandAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			cn   					desc	
		ll.add(Arrays.asList(new Object[]{ "add_command_good",				"/bin/date", 			"testing date command"	} ));
		ll.add(Arrays.asList(new Object[]{ "add_command_long",				"/home/abcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789ANDAGAINabcdefghijklmnopqrstuvwxyz123456789/bin/date", 	"testing long date command"	} ));
		ll.add(Arrays.asList(new Object[]{ "add_command_special_char",		"/b@i&n?/~d:a?t+e-", 	"testing date command with special char"	} ));
		
	//	ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/cat", 	"testing cat command"	} ));
		/*
		
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/sleep",		"sleep command"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/mkdir",		"mkdir command"	} ));
		*/
						   
		return ll;	
	}

	
	/*
	 * Data to be used when adding sudo rule commands - for positive cases
	 */
	@DataProvider(name="getSudoCommandCancelAddTestObjects")
	public Object[][] getSudoCommandCancelAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoCommandCancelAddTestObjects());
	}
	protected List<List<Object>> createSudoCommandCancelAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			cn   			desc
		ll.add(Arrays.asList(new Object[]{ "cancel_add_command",	"/bin/find",	"testing find command"	} ));
								   
		return ll;	
	}
	

	/*
	 * Data to be used when cancelling deleting sudo commands 
	 */
	@DataProvider(name="getSudoruleCommandCancelDelTestObjects")
	public Object[][] getSudoruleCommandCancelDelTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleCommandCancelDelTestObjects());
	}
	protected List<List<Object>> createSudoruleCommandCancelDelTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname		cn   				
		ll.add(Arrays.asList(new Object[]{ "cancel_delete_command",		"/bin/date"	} ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when deleting sudo rule commands - for positive cases
	 */
	@DataProvider(name="getSudoruleCommandDelTestObjects")
	public Object[][] getSudoruleCommandDelTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleCommandDelTestObjects());
	}
	protected List<List<Object>> createSudoruleCommandDelTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			cn   				
		ll.add(Arrays.asList(new Object[]{ "delete_single_command",		"/bin/date"	} ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when testing with multiple sudo commands - for positive cases
	 */
	@DataProvider(name="getAddAndAddAnotherSudoCommandGroupTestObjects")
	public Object[][] getAddAndAddAnotherSudoCommandGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddAndAddAnotherSudoCommandTestObjects());
	}
	protected List<List<Object>> createAddAndAddAnotherSudoCommandTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn1					cn2   			
		ll.add(Arrays.asList(new Object[]{ "add_and_add_another_command",		"/bin/more",		"/usr/bin/less"	} ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when testing with multiple sudo commands - for positive cases
	 */
	@DataProvider(name="getMultipleDelSudoCommandGroupTestObjects")
	public Object[][] getMultipleDelSudoCommandGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createMultipleDelSudoCommandTestObjects());
	}
	protected List<List<Object>> createMultipleDelSudoCommandTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn1					cn2   			
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_commands",		"/bin/more",		"/usr/bin/less"	} ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when adding and editing a sudo command 
	 */
	@DataProvider(name="getAddAndEditSudoCommandTestObjects")
	public Object[][] getAddAndEditSudoCommandTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddAndEditSudoCommandTestObjects());
	}
	protected List<List<Object>> createAddAndEditSudoCommandTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn					desc  			
		ll.add(Arrays.asList(new Object[]{ "add_and_edit_command",		"/bin/ln",			"symlink command"	} ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when cancelling enrolling a command
	 */
	@DataProvider(name="getCancelEnrollSudoCommandTestObjects")
	public Object[][] getCancelEnrollSudoCommandTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createCancelEnrollSudoCommandTestObjects());
	}
	protected List<List<Object>> createCancelEnrollSudoCommandTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname										cn				 			
		ll.add(Arrays.asList(new Object[]{ "cancel_enrolling_command_into_group",		"/bin/ln"	} ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when  enrolling a command
	 */
	@DataProvider(name="getEnrollSudoCommandTestObjects")
	public Object[][] getEnrollSudoCommandTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createEnrollSudoCommandTestObjects());
	}
	protected List<List<Object>> createEnrollSudoCommandTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname							cn				 			
		ll.add(Arrays.asList(new Object[]{ "enroll_command_into_group",		"/bin/ln"	} ));
		
		return ll;	
	}
	
	

	/*
	 * Data to be used when  cancelling deleting an enrolled command
	 */
	@DataProvider(name="getCancelDelEnrolledSudoCommandTestObjects")
	public Object[][] getCancelDelEnrolledSudoCommandTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createCancelDelEnrolledSudoCommandTestObjects());
	}
	protected List<List<Object>> createCancelDelEnrolledSudoCommandTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname										cn				 			
		ll.add(Arrays.asList(new Object[]{ "cancel_deleting_enrolled_command_from_group",		"/bin/ln"	} ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when deleting an enrolled command
	 */
	@DataProvider(name="getDeleteEnrolledSudoCommandTestObjects")
	public Object[][] getDeleteEnrolledSudoCommandTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDeleteEnrolledSudoCommandTestObjects());
	}
	protected List<List<Object>> createDeleteEnrolledSudoCommandTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname								cn				 			
		ll.add(Arrays.asList(new Object[]{ "delete_enrolled_command_from_group",		"/bin/ln"	} ));
		
		return ll;	
	}
	
	
	
	
	@DataProvider(name="getSudoCommandInvalidAddTestObjects")
	public Object[][] getSudoCommandInvalidAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoCommandInvalidAddTestObjects());
	}
	protected List<List<Object>> createSudoCommandInvalidAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname									cn   						description
		ll.add(Arrays.asList(new Object[]{ "add_duplicate_command",							"/bin/date",				"Duplicate command",					"sudo command with name \"/bin/date\" already exists"	} ));
		ll.add(Arrays.asList(new Object[]{ "add_command_invalid_desc_trailing_space",		"/bin/find",				"Description with trailing space ",		"invalid 'desc': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "add_command_invalid_desc_leading_space",		"/bin/find",				" Description with leading space",		"invalid 'desc': Leading and trailing spaces are not allowed"      } ));
		ll.add(Arrays.asList(new Object[]{ "add_command_invalid_name_leading_space",		" /bin/find",				"Name with leading space",				"invalid 'command': Leading and trailing spaces are not allowed"      } ));
		ll.add(Arrays.asList(new Object[]{ "add_command_invalid_name_trailing_space",		"/bin/find ",				"Name with trailing space",				"invalid 'command': Leading and trailing spaces are not allowed"      } ));
		
		
		return ll;	
	}
	

	/*
	 * Data to be used when adding commands with required fields 
	 */
	@DataProvider(name="getSudoCommandRequiredFieldTestObjects")
	public Object[][] getSudoCommandRequiredFieldTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoCommandRequiredFieldTestObject());
	}
	protected List<List<Object>> createSudoCommandRequiredFieldTestObject() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				cn					expected_Error   
		ll.add(Arrays.asList(new Object[]{ "add_blank_command",			"",					"Required field"      } ));
		
		return ll;	
	}
	
	
	
	/*
	 * Data to be used when adding sudo command groups - for positive cases
	 */
	@DataProvider(name="getSudoCommandModifyTestObjects")
	public Object[][] getSudoCommandInvalidModifyTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoCommandInvalidModifyTestObjects());
	}
	protected List<List<Object>> createSudoCommandInvalidModifyTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname								cn   		description		
		ll.add(Arrays.asList(new Object[]{ "edit_command_update_with_blank_desc",		"/bin/ln",		""      	} ));
		
		return ll;	
	}
}
