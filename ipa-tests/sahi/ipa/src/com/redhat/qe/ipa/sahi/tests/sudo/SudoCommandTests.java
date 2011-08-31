package com.redhat.qe.ipa.sahi.tests.sudo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

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
			sahiTasks.navigateTo(commonTasks.hbacPage, true);
		}		
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
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
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
}
