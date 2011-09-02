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
