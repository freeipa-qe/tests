/**
 * 
 */
package com.redhat.qe.ipa21.tests.group;

/**
 * Test UI for Identity - User Groups
 * @author nkrishnan
 *.
 */

import org.testng.annotations.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.redhat.qe.auto.selenium.*;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.auto.testng.TestScript;
import com.redhat.qe.ipa.base.SeleniumTestScript;
import com.redhat.qe.ipa21.tasks.CommonTasks;
import com.redhat.qe.ipa21.tasks.GroupTasks;


public class GroupTests extends TestScript{	

		public  ExtendedSelenium selenium = null;
		
		@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true)
		public void intialize() throws CloneNotSupportedException {		
			selenium = CommonTasks.sel();		
			selenium.open(SeleniumTestScript.ipaServerURL + "/ipa/ui/#identity=1&navigation=0");
			//selenium.open("/ipa/ui/#identity=1&navigation=0");
		}
		
		/*
		 * Add groups - for positive tests
		 */
		@Test (groups={"groupTests"}, dataProvider="getGroupTestObjects")	
		public void testGroupadd(String testName, String groupName, String description) throws Exception {
			// wait for the User Groups page to be loaded
			CommonTasks.waitForRefreshTillTextPresent(selenium, "Add");
			
			// wait for the groups to be listed before checking if the group to be added exists already
			CommonTasks.waitForRefresh(selenium);

			// verify group doesn't exist
			com.redhat.qe.auto.testng.Assert.assertFalse(selenium.isTextPresent(groupName), groupName + " was added in previous test");
			
			//new test group can be added now
			GroupTasks.createGroup(selenium, groupName, description);			
			
			CommonTasks.waitForRefresh(selenium);
			
			//verify group was added successfully
			com.redhat.qe.auto.testng.Assert.assertTrue(selenium.isTextPresent(groupName), groupName + " added successfully");
		}
		
		/*
		 * Data to be used when adding groups
		 */
		@DataProvider(name="getGroupTestObjects")
		public Object[][] getGroupTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createGroupTestObjects());
		}
		protected List<List<Object>> createGroupTestObjects() {
			
			List<List<Object>> ll = new ArrayList<List<Object>>();
			//String sLongName = "auto_" + tasks.generateRandomString(251);
			
	        //										testname					groupname              		description
			ll.add(Arrays.asList(new Object[]{ "create_good_group",				"auto_good", 				"Good group"  } ));
			ll.add(Arrays.asList(new Object[]{ "create_blankName",				"xxx", 						"Blank group" } ));
			//ll.add(Arrays.asList(new Object[]{ "create_MixedCase_group",		"MixedCaseGroup", 			"Mixed Case group"  } ));
			//ll.add(Arrays.asList(new Object[]{ "create_specialchar_group",		"$pecialCh@rGroup", 		"Special Char group"  } ));
	       // ll.add(Arrays.asList(new Object[]{ "create_nameTooLong", 			sLongName,  				"Long group name" } ));
	        
	        
			return ll;	
		}
		
		
		
	


}
