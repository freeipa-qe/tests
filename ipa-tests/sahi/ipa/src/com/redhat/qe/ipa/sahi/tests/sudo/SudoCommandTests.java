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
import com.redhat.qe.ipa.sahi.tasks.HBACTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;

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
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.sudoCommandPage, true);
		}		
	}
	
	
	/*
	 * Add Sudo Commands - positive tests
	 */
	@Test (groups={"sudoCommandAddTests"}, dataProvider="getSudoCommandAddTestObjects")	
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
	@Test (groups={"sudoCommandCancelAddTests"}, dataProvider="getSudoCommandCancelAddTestObjects")	
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
	@Test (groups={"sudoCommandCancelDelTests"}, dataProvider="getSudoruleCommandDelTestObjects", 
			dependsOnGroups={"sudoCommandAddTests"})	
	public void testSudoCommandCancelDel(String testName, String cn, String description) throws Exception {
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
	@Test (groups={"sudoCommandDelTests"}, dataProvider="getSudoruleCommandDelTestObjects", 
			dependsOnGroups={"sudoCommandAddTests", "sudoCommandCancelDelTests", "invalidSudoCommandAddTests", "invalidSudoCommandModifyTests"})	
	public void testSudoCommandDel(String testName, String cn, String description) throws Exception {
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
	@Test (groups={"sudoCommandAddAndAddAnotherTests"}, description="Add and Add Another Sudo Command", dataProvider="getMultipleSudoCommandGroupTestObjects")	
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
	@Test (groups={"sudoCommandAddAndEditTests"}, dataProvider="getSingleSudoCommandTestObjects")	
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
	@Test (groups={"sudoCommandCancelEnrollTests"}, dataProvider="getSingleSudoCommandTestObjects", 
			dependsOnGroups={"sudoCommandAddAndEditTests"})	
	public void testSudoCommandCancelEnroll(String testName, String command, String desc) throws Exception {
		
		//verify command exists
		Assert.assertTrue(sahiTasks.link(command).exists(), "Verify Command " + command + " exists");
		
		// Enroll command
		SudoTasks.enrollCommandInCommandGroup(sahiTasks, command, commandGroup, "Cancel");
		
		// Verify membership
		SudoTasks.verifySudoCommandMembership(sahiTasks, command, commandGroup, false);
		
	}
		
	
	/*
	 * Enroll a Sudo command to a sudo command group
	 * 
	 */
	@Test (groups={"sudoCommandEnrollTests"}, dataProvider="getSingleSudoCommandTestObjects", 
			dependsOnGroups={"sudoCommandAddAndEditTests", "sudoCommandCancelEnrollTests"})	
	public void testSudoCommandEnroll(String testName, String command, String desc) throws Exception {
		
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
	@Test (groups={"sudoCommandCancelDeleteEnrolledTests"}, dataProvider="getSingleSudoCommandTestObjects",
			dependsOnGroups={"sudoCommandAddAndEditTests", "sudoCommandEnrollTests"})	
	public void testSudoCommandCancelDeleteEnrolled(String testName, String command,  String desc) throws Exception {
		
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
	@Test (groups={"sudoCommandDeleteEnrolledTests"}, dataProvider="getSingleSudoCommandTestObjects",
			dependsOnGroups={"sudoCommandAddAndEditTests", "sudoCommandEnrollTests"})	
	public void testSudoCommandDeleteEnrolled(String testName, String command, String desc) throws Exception {
		
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
	@Test (groups={"sudoCommandModifySettingsTests"}, dataProvider="getSudoCommandModifyTestObjects", 
			dependsOnGroups={"sudoCommandAddAndEditTests"})	
	public void testSudoCommandModifySettings(String testName, String cn, String description) throws Exception {
		
		SudoTasks.modifySudoCommandSettings(sahiTasks, cn, description);
		//verify changes	
		SudoTasks.verifySudoCommandUpdates(sahiTasks, cn, description);
	}
	
	
	/*
	 * invalid add
	 */
	@Test (groups={"invalidSudoCommandAddTests"}, dataProvider="getSudoCommandInvalidAddTestObjects", 
			dependsOnGroups={"sudoCommandAddTests"})
	public void testInvalidSudoCommandAdd(String testName, String cn, String description, String expectedError) throws Exception {
		
		SudoTasks.createInvalidSudoCommand(sahiTasks, cn, description, expectedError);
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
	@Test (groups={"sudoCommandMultipleDeleteTests"}, description="Delete Multiple Rules", dataProvider="getMultipleSudoCommandGroupTestObjects", 
			dependsOnGroups={"sudoCommandAddAndAddAnotherTests"})		
	public void testMultipleSudoCommandDelete(String testName, String cn1, String cn2) throws Exception {	
		String cns[] = {cn1, cn2};
		
		
		//verify rule to be deleted exists
		for (String cn : cns) {
			Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify Sudo Rule " + cn + "  to be deleted exists");
		}			
		//mark this rule for deletion
		SudoTasks.chooseMultiple(sahiTasks, cns);		
		SudoTasks.deleteMultiple(sahiTasks);
	}
	// Add a command to a command group
	
	
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException {
		String[] sudoCommandTestObjects = {"/bin/date",
 										//	"/bin/cat",
										"/bin/find",
										"/bin/more",
										"/usr/bin/less",
										"/bin/ln"
												} ;

		//verify rules were found
		for (String sudoCommandTestObject : sudoCommandTestObjects) {
			if (sahiTasks.link(sudoCommandTestObject.toLowerCase()).exists()){
				log.fine("Cleaning Sudo Rule: " + sudoCommandTestObject);
				SudoTasks.deleteSudo(sahiTasks, sudoCommandTestObject.toLowerCase(), "Delete");
			}			
		} 
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
		
        //										testname					cn   			desc	
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/date", 	"testing date command"	} ));
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
		
        //										testname					cn   			desc
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/find",	"testing find command"	} ));
								   
		return ll;	
	}
	
	/*
	 * Data to be used when adding sudo rule commands - for positive cases
	 */
	@DataProvider(name="getSudoCommandCancelDeleteTestObjects")
	public Object[][] getSudoCommandCancelDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoCommandCancelDeleteTestObjects());
	}
	protected List<List<Object>> createSudoCommandCancelDeleteTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   			
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/date"	} ));
								   
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
		
        //										testname					cn   			description
		ll.add(Arrays.asList(new Object[]{ "delete_sudorule_command",		"/bin/date",		"date command"	} ));
	//	ll.add(Arrays.asList(new Object[]{ "delete_sudorule_command",		"/bin/cat",			"cat command"	} ));
		
		return ll;	
	}
	
	
	/*
	 * Data to be used when testing with multiple sudo commands - for positive cases
	 */
	@DataProvider(name="getMultipleSudoCommandGroupTestObjects")
	public Object[][] getMultipleSudoCommandGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createMultipleSudoCommandTestObjects());
	}
	protected List<List<Object>> createMultipleSudoCommandTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn1					cn2   			
		ll.add(Arrays.asList(new Object[]{ "multiple_sudo_command",		"/bin/more",		"/usr/bin/less"	} ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when testing with single sudo command - for positive cases
	 */
	@DataProvider(name="getSingleSudoCommandTestObjects")
	public Object[][] getSingleSudoCommandTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSingleSudoCommandTestObjects());
	}
	protected List<List<Object>> createSingleSudoCommandTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn				desc  			
		ll.add(Arrays.asList(new Object[]{ "single_sudo_command",		"/bin/ln",			"symlink command"	} ));
		
		return ll;	
	}
	
	
	@DataProvider(name="getSudoCommandInvalidAddTestObjects")
	public Object[][] getSudoCommandInvalidAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoCommandInvalidAddTestObjects());
	}
	protected List<List<Object>> createSudoCommandInvalidAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname												cn   						description
		ll.add(Arrays.asList(new Object[]{ "duplicate_sudo_command",								"/bin/date",				"Duplicate command",					"sudo command with name \"/bin/date\" already exists"	} ));
		ll.add(Arrays.asList(new Object[]{ "sudo_command_with trailing_space_in_desc",				"/bin/find",				"Description with trailing space ",		"invalid 'desc': Leading and trailing spaces are not allowed"	} ));
		ll.add(Arrays.asList(new Object[]{ "sudo_command_with leading_space_in_desc",				"/bin/find",				" Description with leading space",		"invalid 'desc': Leading and trailing spaces are not allowed"      } ));
		ll.add(Arrays.asList(new Object[]{ "sudo_command_with leading_space_in_name",				" /bin/find",				"Name with leading space",				"invalid 'command': Leading and trailing spaces are not allowed"      } ));
		ll.add(Arrays.asList(new Object[]{ "sudo_command_with trailing_space_in_name",				"/bin/find ",				"Name with trailing space",				"invalid 'command': Leading and trailing spaces are not allowed"      } ));
		
		
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
		
        //										testname			cn   		description		
		ll.add(Arrays.asList(new Object[]{ "sudo_command",		"/bin/ln",		""      	} ));
		
		return ll;	
	}
}
