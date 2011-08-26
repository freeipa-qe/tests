package com.redhat.qe.ipa.sahi.tests.hbac;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.HBACTasks;
import com.redhat.qe.ipa.sahi.tests.user.UserTests;

public class HBACServiceGroupTests extends SahiTestScript{
private static Logger log = Logger.getLogger(UserTests.class.getName());
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks.navigateTo(commonTasks.hbacServiceGroupPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&hbacsvcgroup-facet=search" ;
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    System.out.println("CurrentPageNow: " + currentPageNow);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.hbacServicePage, true);
		}		
	}
	
	/*
	 * Add a HBACService
	 */
	@Test (groups={"hbacServiceGroupAddTests"}, dataProvider="getHBACServiceGroupTestObjects")	
	public void testHBACServiceGroupAdd(String testName, String cn, String description) throws Exception {
		//verify rule doesn't exist
		Assert.assertFalse(sahiTasks.link(cn).exists(), "Verify HBAC Service " + cn + " doesn't already exist");
		
		HBACTasks.addHBACServiceGroup(sahiTasks, cn, description, "Add");
		
		//verify rule were added
		Assert.assertTrue(sahiTasks.link(cn).exists(), "Added HBAC Service Group " + cn + "  successfully");
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding HBAC Service 
	 */
	@DataProvider(name="getHBACServiceGroupTestObjects")
	public Object[][] getHBACServiceGroupTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACServiceGroupTestObjects());
	}
	protected List<List<Object>> createHBACServiceGroupTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					cn			description
		ll.add(Arrays.asList(new Object[]{ "good_hbacservicegroup",			"web",		"testing http service group for HBAC"      } ));
		ll.add(Arrays.asList(new Object[]{ "long_hbacservicegroup",			"web2",		"testing https service group for HBAC"      } ));
		
		return ll;	
	}
	
}
