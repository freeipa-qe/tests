package com.redhat.qe.ipa.sahi.tests.sudo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;
import com.redhat.qe.ipa.sahi.tests.sudo.SudoTests;

public class SudoTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(SudoTests.class.getName());
	public static SahiTasks sahiTasks = null;	
	private String userPage = "/ipa/ui/#navigation=policy&policy=sudo";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+userPage, true);
	}
	

	/*
	 * Add sudorule - for positive tests
	 */
	@Test (groups={"sudoruleAddTests"}, dataProvider="getSudoruleTestObjects")	
	public void testSudoruleadd(String testName, String cn) throws Exception {
		String expectedcn=cn;
		if (cn.length() == 0) {
			expectedcn=(cn).toLowerCase();
			log.fine("Expectedcn: " + expectedcn);
		}
		
		//verify sudo rule doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(expectedcn).exists(), "Verify sudorule " + expectedcn + " doesn't already exist");
		
		//new sudo rule can be added now
		SudoTasks.createSudorule(sahiTasks, cn);		
		
		//verify sudo rule was added successfully
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(expectedcn).exists(), "Added sudorule " + expectedcn + "  successfully");
	}
	

	/*
	 * Edit Sudorule - for positive tests
	 */
	@Test (groups={"sudoruleEditTests"}, dataProvider="getsudoruleEditTestObjects", dependsOnGroups={"sudoruleCommandAddTests"})	
	public void testsudoruleEdit(String testName, String cn, String description, String ipasudoopt) throws Exception {		
		//verify sudorule to be edited exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify sudorule " + cn + " to be edited exists");
		
		//add sudo option to this rule
		SudoTasks.modifySudorule(sahiTasks, cn, description, ipasudoopt);
		
		//verify changes	
		SudoTasks.verifySudoruledescUpdates(sahiTasks, cn, description, ipasudoopt);
		
	}
	
	/*
	 * Delete sudo rule - positive tests
	 * note: make sure tests that use testrule1 are run before testrule1 gets deleted here
	 */
	@Test (groups={"sudoruleDeleteTests"}, dataProvider="getSudoruleDeleteTestObjects", 
			dependsOnGroups={"sudoruleEditTests"})	
	public void testSudoruleDelete(String testName, String cn) throws Exception {
		//verify rule to be deleted exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify sudorule " + cn + "  to be deleted exists");
		
		//modify this sudo rule
		SudoTasks.deleteSudorule(sahiTasks, cn);
		
		//verify user is deleted
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Sudorule " + cn + "  deleted successfully");
	}
	
	/*
	 * Add Sudo Commands - positive tests
	 */
	@Test (groups={"sudoruleCommandAddTests"}, dataProvider="getSudoruleCommandAddTestObjects", 
			dependsOnGroups={"sudoruleAddTests"})	
			public void testSudoruleCommandAdd(String testName, String cn, String description) throws Exception {
				//verify command to be added doesn't exist
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify sudocommand " + cn + "  doesn't already exist");
				
				//new sudo rule command can be added now
				SudoTasks.createSudoruleCommandAdd(sahiTasks, cn, description);
				
				//verify sudo rule command was added successfully
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Added Sudorule Command " + cn + "  successfully");
	} 
	
	/*
	 * Del Sudo Commands - positive tests
	 */
	@Test (groups={"sudoruleCommandDelTests"}, dataProvider="getSudoruleCommandDelTestObjects", 
			dependsOnGroups={"sudoruleEditTests"})	
			public void testSudoruleCommandDel(String testName, String cn, String description) throws Exception {
				//verify command to be deleted exists
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify sudocommand " + cn + "  to be deleted exists");
				
				//new sudo rule command can be deleted now
				SudoTasks.deleteSudoruleCommandDel(sahiTasks, cn, description);
				
				//verify sudo rule command was added successfully
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Sudorule Command " + cn + "  deleted successfully");
	} 
	
	
	/*
	 * Add Sudo Command Groups - positive tests
	 */
	@Test (groups={"sudoruleCommandGroupAddTests"}, dataProvider="getSudoruleCommandGroupAddTestObjects", 
			dependsOnGroups={"sudoruleAddTests"})	
			public void testSudoruleCommandGroupAdd(String testName, String cn, String description) throws Exception {
				//verify command group to be added doesn't exist
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify sudocommand group " + cn + "  doesn't already exist");
				
				//new sudo rule command can be added now
				SudoTasks.createSudoruleCommandGroupAdd(sahiTasks, cn, description);
				
				//verify sudo command group was added successfully
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Added Sudo Command Group" + cn + "  successfully");
	} 
	
	/*
	 * Del Sudo Command Group - positive tests
	 */
	@Test (groups={"sudoruleCommandGroupDelTests"}, dataProvider="getSudoruleCommandGroupDelTestObjects", 
			dependsOnGroups={"sudoruleCommandGroupAddTests"})	
			public void testSudoruleCommandGroupDel(String testName, String cn, String description) throws Exception {
				//verify command group to be deleted exists
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify sudocommand group" + cn + "  to be deleted exists");
				
				//new sudo command group can be deleted now
				SudoTasks.deleteSudoruleCommandGroupDel(sahiTasks, cn, description);
				
				//verify sudo rule command group was added successfully
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Sudorule Command Group" + cn + "  deleted successfully");
	} 
	
	
	
	/*
	 * Search
	 */
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding sudo rules - for positive cases
	 */
	@DataProvider(name="getSudoruleTestObjects")
	public Object[][] getSudoruleTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleTestObjects());
	}
	protected List<List<Object>> createSudoruleTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   
		ll.add(Arrays.asList(new Object[]{ "create_sudorule",				"testrule1"	} ));
		/*
		ll.add(Arrays.asList(new Object[]{ "create_sudorule",				"testrule2"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudorule",				"testrule3"	} ));
		*/
		return ll;	
	}

	/*
	 * Data to be used when editing sudorule - for positive cases
	 */
	@DataProvider(name="getsudoruleEditTestObjects")
	public Object[][] getSudoruleCommandEditTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(editSudoruleCommandEditTestObjects());
	}
	protected List<List<Object>> editSudoruleCommandEditTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   			description						ipasudoopt
		ll.add(Arrays.asList(new Object[]{ "edit_sudorule1",		"testrule1",		"Test description for testrule1",	"/var/log/sudolog"	} ));
								        
		return ll;	
	}
	
	
	/*
	 * Data to be used when deleting sudo rules
	 */
	@DataProvider(name="getSudoruleDeleteTestObjects")
	public Object[][] getSudoruleDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteSudoruleTestObjects());
	}
	protected List<List<Object>> deleteSudoruleTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn              		
		ll.add(Arrays.asList(new Object[]{ "delete_good_sudorule",				"testrule1"     } ));
		/*
		ll.add(Arrays.asList(new Object[]{ "delete_good_sudorule",				"testrule2"     } ));
		ll.add(Arrays.asList(new Object[]{ "delete_good_sudorule",				"testrule3"     } ));
		*/        
		return ll;	
	}

	/*
	 * Data to be used when adding sudo rule commands - for positive cases
	 */
	@DataProvider(name="getSudoruleCommandAddTestObjects")
	public Object[][] getSudoruleCommandAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleCommandAddTestObjects());
	}
	protected List<List<Object>> createSudoruleCommandAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   			description
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/date",		"date command"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/cat",			"cat command"	} ));
		/*
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/find",		"find command"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/more",		"more command"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/usr/bin/less",	"less command"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/ln",			"symlink command"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/sleep",		"sleep command"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudorule_command",		"/bin/mkdir",		"mkdir command"	} ));
		*/
						   
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
		ll.add(Arrays.asList(new Object[]{ "delete_sudorule_command",		"/bin/cat",			"cat command"	} ));
		/*
		ll.add(Arrays.asList(new Object[]{ "delete_sudorule_command",		"/bin/find",		"find command"	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_sudorule_command",		"/bin/more",		"more command"	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_sudorule_command",		"/usr/bin/less",	"less command"	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_sudorule_command",		"/bin/ln",			"symlink command"	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_sudorule_command",		"/bin/sleep",		"sleep command"	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_sudorule_command",		"/bin/mkdir",		"mkdir command"	} ));
		*/	
		return ll;	
	}

	/*
	 * Data to be used when adding sudo command groups - for positive cases
	 */
	@DataProvider(name="getSudoruleCommandGroupAddTestObjects")
	public Object[][] getSudoruleCommandGroupAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSudoruleCommandGroupAddTestObjects());
	}
	protected List<List<Object>> createSudoruleCommandGroupAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn   			description
		ll.add(Arrays.asList(new Object[]{ "create_sudo_commandgroup",		"sudo group1",		"group1 with basic commands"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudo_commandgroup",		"sudo group2",		"group2 with basic commands"	} ));
		/*
		ll.add(Arrays.asList(new Object[]{ "create_sudo_commandgroup",		"sudo group3",		"group3 with basic commands"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudo_commandgroup",		"sudo group4",		"group4 with basic commands"	} ));
		ll.add(Arrays.asList(new Object[]{ "create_sudo_commandgroup",		"sudo group5",		"group5 with basic commands"	} ));
		*/
				        
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
		ll.add(Arrays.asList(new Object[]{ "delete_sudo_commandgroup",		"sudo group2",		"group2 with basic commands"	} ));
		/*
		ll.add(Arrays.asList(new Object[]{ "delete_sudo_commandgroup",		"sudo group3",		"group3 with basic commands"	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_sudo_commandgroup",		"sudo group4",		"group4 with basic commands"	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_sudo_commandgroup",		"sudo group5",		"group5 with basic commands"	} ));
		*/
				        
		return ll;	
	}
	
}
