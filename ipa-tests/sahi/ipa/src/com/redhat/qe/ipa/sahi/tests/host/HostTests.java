package com.redhat.qe.ipa.sahi.tests.host;

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
import com.redhat.qe.ipa.sahi.tasks.HostTasks;

public class HostTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(HostTests.class.getName());
	public static SahiTasks sahiTasks = null;	
	private String userPage = "/ipa/ui/#identity=host&navigation=identity";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+userPage, true);
	}
	

	/*
	 * Force add hosts - for positive tests
	 */
	@Test (groups={"hostForceAddFQDNTests"}, dataProvider="getHostFQDNTestObjects")	
	public void testHostForceAddFQDN(String testName, String fqdn) throws Exception {
		//verify host doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(fqdn).exists(), "Verify host " + fqdn + " doesn't already exist");
		
		//add new host
		HostTasks.forceCreateHostFQDN(sahiTasks, fqdn);
		
		//verify host was added
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(fqdn).exists(), "Added host " + fqdn + "  successfully");
	}
	
	/*
	 * delete hosts
	 */
	@Test (groups={"hostDeleteTests"}, dataProvider="getHostDeleteTestObjects")	
	public void testHostDelete(String testName, String fqdn) throws Exception {
		//verify host exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(fqdn).exists(), "Verify host " + fqdn + " already exist");
		
		//add new host
		HostTasks.deleteHost(sahiTasks, fqdn);
		
		//verify host was deleted
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(fqdn).exists(), "Added host " + fqdn + "  successfully");
	}
	
	/*
	 * Add host - for negative tests
	 */
	@Test (groups={"invalidhostForceAddTests"}, dataProvider="getInvalidHostTestObjects",  dependsOnGroups="hostAddTests")	
	public void testInvalidUseradd(String testName, String hostname, String domain, String fqdn, String ipadr, String expectedError) throws Exception {
		//new test user can be added now
		HostTasks.createInvalidHostForce(sahiTasks, hostname, domain, ipadr, expectedError);		
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding hosts - for positive cases
	 */
	@DataProvider(name="getHostFQDNTestObjects")
	public Object[][] getHostFQDNTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostFQDNTestObjects());
	}
	protected List<List<Object>> createHostFQDNTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					fqdn				
		ll.add(Arrays.asList(new Object[]{ "create_host_lowercase",		"myhost1.testrelm"} ));
		ll.add(Arrays.asList(new Object[]{ "create_host_uppercase",		"myhost2.testrelm"} ));
		ll.add(Arrays.asList(new Object[]{ "create_host_mixedcase",		"myhost3.testrelm"} ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when adding hosts - for positive cases - none FQDN
	 */
	@DataProvider(name="getHostTestObjects")
	public Object[][] getHostTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostTestObjects());
	}
	protected List<List<Object>> createHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					hostname        domain			fqdn				
		ll.add(Arrays.asList(new Object[]{ "create_host_lowercase",			"myhost1", 		"testrelm",		"myhost1.testrelm"} ));
		ll.add(Arrays.asList(new Object[]{ "create_host_uppercase",			"MYHOST2", 		"testrelm",		"myhost2.testrelm"} ));
		ll.add(Arrays.asList(new Object[]{ "create_host_mixedcase",			"mYHost3", 		"testrelm",		"myhost3.testrelm"} ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when deleting hosts - for positive cases
	 */
	@DataProvider(name="getHostDeleteTestObjects")
	public Object[][] getHostDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostDeleteTestObjects());
	}
	protected List<List<Object>> createHostDeleteTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				fqdn				
		ll.add(Arrays.asList(new Object[]{ "delete_host_lowercase",		"myhost1.testrelm"} ));
		ll.add(Arrays.asList(new Object[]{ "create_host_uppercase",		"myhost2.testrelm"} ));
		ll.add(Arrays.asList(new Object[]{ "create_host_mixedcase",		"myhost3.testrelm"} ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when adding hosts - for negative cases
	 */
	@DataProvider(name="getInvalidHostTestObjects")
	public Object[][] getInvalidHostTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidHostTestObjects());
	}
	protected List<List<Object>> createInvalidHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					hostname        domain			fqdn			ipadr   expectedError
		ll.add(Arrays.asList(new Object[]{ "missing_domain_name",			"myhost1", 		"",				"myhost1",		"",		"invalid 'hostname': Fully-qualified hostname required"		} ));
		ll.add(Arrays.asList(new Object[]{ "missing_hostname",				"", 			"testrelm",		"testrelm",		"",		"invalid 'hostname': Fully-qualified hostname required"		} ));	        
		return ll;	
	}
}
