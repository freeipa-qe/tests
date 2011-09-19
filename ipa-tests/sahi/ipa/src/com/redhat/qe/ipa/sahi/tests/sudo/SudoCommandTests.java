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

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SudoTasks;

public class SudoCommandTests extends SahiTestScript {
	private static Logger log = Logger.getLogger(SudoCommandTests.class.getName());
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.setStrictVisibilityCheck(true);
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
				SudoTasks.createSudoruleCommandAdd(sahiTasks, cn, description, "Add");
				
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
				SudoTasks.createSudoruleCommandAdd(sahiTasks, cn, description, "Cancel");
				
				//verify sudo rule command was not added
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Sudo Command " + cn + "  was not added");
	} 
	
	/*
	 * Cancel Del Sudo Commands - positive tests
	 */
	@Test (groups={"sudoCommandCancelDelTests"}, dataProvider="getSudoruleCommandDelTestObjects", dependsOnGroups={"sudoCommandAddTests"})	
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
	@Test (groups={"sudoCommandDelTests"}, dataProvider="getSudoruleCommandDelTestObjects", dependsOnGroups={"sudoCommandAddTests", "sudoCommandCancelDelTests"})	
			public void testSudoCommandDel(String testName, String cn, String description) throws Exception {
				//verify command to be deleted exists
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(cn).exists(), "Verify sudocommand " + cn + "  to be deleted exists");
				
				//new sudo rule command can be deleted now
				SudoTasks.deleteSudo(sahiTasks, cn, "Delete");
				
				//verify sudo rule command was added successfully
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(cn).exists(), "Sudorule Command " + cn + "  deleted successfully");
	} 
	
	
	@AfterClass (groups={"cleanup"}, description="Delete objects created for this test suite", alwaysRun=true)
	public void cleanup() throws CloneNotSupportedException {
		String[] sudoCommandTestObjects = {"/bin/date",
 										//	"/bin/cat",
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
}
