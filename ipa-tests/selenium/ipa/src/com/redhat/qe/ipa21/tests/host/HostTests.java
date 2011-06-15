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


public class HostTests extends TestScript{	

		public  ExtendedSelenium selenium = null;
		
		@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true)
		public void intialize() throws CloneNotSupportedException {		
			selenium = CommonTasks.sel();		
			selenium.open(SeleniumTestScript.ipaServerURL + "/ipa/ui/#identity=2&navigation=0");
			//selenium.open("/ipa/ui/#identity=1&navigation=0");
		}
		
		/*
		 * Force Add/Delete Host
		 */
		@Test (groups={"hostTests"}, dataProvider="getHostTestObjects")	
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
		
		/*
		 * Data to be used when adding groups
		 */
		@DataProvider(name="getHostTestObjects")
		public Object[][] getHostTestObjects() {
			return TestNGUtils.convertListOfListsTo2dArray(createHostTestObjects());
		}
		protected List<List<Object>> createHostTestObjects() {
			
			List<List<Object>> ll = new ArrayList<List<Object>>();
			//String sLongName = "auto_" + tasks.generateRandomString(251);
			
	        //										testname					hostname      
			ll.add(Arrays.asList(new Object[]{ "force_addhost_nodns",			"myhost1.testrelm" } ));
			ll.add(Arrays.asList(new Object[]{ "force_addhost_uppercase",			"MYHOST2.testrelm" } ));
			ll.add(Arrays.asList(new Object[]{ "force_addhost_mixedcase",			"MyHost3.testrelm" } ));
	        
			return ll;	
		}
}
