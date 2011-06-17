/**
 * 
 */
package com.redhat.qe.ipa21.tests.host;

/**
 * Test UI for Identity - User Groups
 * @author jgalipea
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
import com.redhat.qe.ipa21.tasks.HostTasks;
import com.redhat.qe.ipa21.tasks.UserTasks;


public class HostTests extends TestScript{	

		public  ExtendedSelenium selenium = null;
		
		@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true)
		public void intialize() throws CloneNotSupportedException {		
			selenium = CommonTasks.sel();		
			selenium.open(SeleniumTestScript.ipaServerURL + "/ipa/ui/#identity=host&navigation=identity");
			//selenium.open("/ipa/ui/#identity=1&navigation=0");
		}
		
		/*
		 * Force Add Host
		 */
		@Test (groups={"hostAddTests"}, dataProvider="getHostAddTestObjects")	
		public void testForceAddHost(String testName, String hostName) throws Exception {
			// wait for the User Groups page to be loaded
			CommonTasks.waitForRefreshTillTextPresent(selenium, "Add");
			
			// wait for the hosts to be listed before checking if the host to be added exists already
			CommonTasks.waitForRefresh(selenium);

			// verify host doesn't exist
			com.redhat.qe.auto.testng.Assert.assertFalse(selenium.isTextPresent(hostName), hostName + " was added in previous test");
			
			//new test host can be added now
			HostTasks.forceAddHost(selenium, hostName);		
			String lower = hostName.toLowerCase();
			
			CommonTasks.waitForRefresh(selenium);
			
			//verify host was added successfully
			com.redhat.qe.auto.testng.Assert.assertTrue(selenium.isTextPresent(lower), hostName + " added successfully");
			
			//delete host
			//HostTasks.deleteHost(selenium, hostName);
			
			//verify host was deleted successfully
			//com.redhat.qe.auto.testng.Assert.assertFalse(selenium.isTextPresent(hostName), hostName + " added successfully");
		}
		
		@Test (groups={"hostEditTests"}, dataProvider="getHostEditTestObjects")	
		public void testHostEditDescription(String testName, String hostName, String hostDescription) throws Exception {
			//selenium.open(SeleniumTestScript.ipaServerURL + "/ipa/ui/#identity=host&navigation=identity");
			// wait for the Host page to be loaded
			CommonTasks.waitForRefreshTillTextPresent(selenium, "Add");
			
			// wait for the users to be listed before checking if the hosts to be added exists already
			CommonTasks.waitForRefresh(selenium);

			// verify host be edited exists
			com.redhat.qe.auto.testng.Assert.assertTrue(selenium.isTextPresent(hostName), hostName + " is available for editing");
			
			//modify this host
			HostTasks.modifyHost(selenium, hostName, hostDescription);
			CommonTasks.waitForRefresh(selenium);
			
			com.redhat.qe.auto.testng.Assert.assertTrue(selenium.isTextPresent(hostDescription), hostName + " description " + hostDescription + "modified successfully.");
			
			selenium.click("css=span.back-link");
			
			com.redhat.qe.auto.testng.Assert.assertTrue(selenium.isTextPresent(hostDescription), hostName + " description " + hostDescription + "on host list page.");
		}
		
		/*
		 * Data to be used when adding hosts
		 */
		@DataProvider(name="getHostAddTestObjects")
		public Object[][] getHostAddTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createHostAddTestObjects());
		}
		protected List<List<Object>> createHostAddTestObjects() {
			
			List<List<Object>> ll = new ArrayList<List<Object>>();
			//String sLongName = "auto_" + tasks.generateRandomString(251);
			
	        //										testname					hostname      	
			ll.add(Arrays.asList(new Object[]{ "force_addhost_nodns",			"myhost1.testrelm" } ));
			ll.add(Arrays.asList(new Object[]{ "force_addhost_uppercase",	    "MYHOST2.testrelm" } ));
			ll.add(Arrays.asList(new Object[]{ "force_addhost_mixedcase",		"MyHost3.testrelm" } ));
	        
			return ll;	
		}
		
		@DataProvider(name="getHostEditTestObjects")
		public Object[][] getHostEditTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createHostEditTestObjects());
		}
		protected List<List<Object>> createHostEditTestObjects() {
			
			List<List<Object>> ll = new ArrayList<List<Object>>();
			//String sLongName = "auto_" + tasks.generateRandomString(251);
			
	        //										testname					hostname      			hostDescription
			ll.add(Arrays.asList(new Object[]{ "edit_host1_desc",			"myhost1.testrelm",		"my new description" } ));
			ll.add(Arrays.asList(new Object[]{ "edit_host2_desc",		    "MYHOST2.testrelm",		"my New Decscription" } ));
			ll.add(Arrays.asList(new Object[]{ "edit_host3_desc",			"MyHost3.testrelm",		"MY NEW DESCRIPTION" } ));
	        
			return ll;	
		}
}
