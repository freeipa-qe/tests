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
import com.redhat.qe.ipa.sahi.tasks.DNSTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;

public class HostTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(HostTests.class.getName());
	public static SahiTasks sahiTasks = null;	
	private String hostPage = "/ipa/ui/#identity=host&navigation=identity";
	private String dnsPage = "/ipa/ui/#identity=dnszone&navigation=policy";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
	}
	

	/*
	 * Force add hosts - for positive tests
	 */
	@Test (groups={"addHostTests"}, dataProvider="getHostTestObjects")	
	public void testHostForceAdd(String testName, String fqdn, String ipadr) throws Exception {
		//verify host doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(fqdn).exists(), "Verify host " + fqdn + " doesn't already exist");
		
		//add new host
		HostTasks.addHost(sahiTasks, fqdn, ipadr);
		
		String lowerdn = fqdn.toLowerCase();

		//verify host was added
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(lowerdn).exists(), "Added host " + fqdn + "  successfully");
	}
	
	/*
	 * Add and edit hosts - for positive tests
	 */
	@Test (groups={"addAndEditHostTests"}, dataProvider="getAddEditHostTestObjects")	
	public void testHostAddAndEdit(String testName, String hostname, String ipadr, String description) throws Exception {
		String lowerdn = hostname.toLowerCase();
		
		//verify host doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(lowerdn).exists(), "Verify host " + hostname + " doesn't already exist");
		
		//add and edit new host
		HostTasks.addHostAndEdit(sahiTasks, hostname, ipadr, description);
		

		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		//verify host was added
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(lowerdn).exists(), "Added host " + hostname + "  successfully");
		
		//verify all host fields
		HostTasks.verifyHostSettings(sahiTasks, hostname, description);
	}
	
	/*
	 * delete hosts
	 */
	@Test (groups={"deleteHostTests"}, dataProvider="getHostDeleteTestObjects",  dependsOnGroups="addHostTests")	
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
	@Test (groups={"invalidhostAddTests"}, dataProvider="getInvalidHostTestObjects")	
	public void testInvalidHostadd(String testName, String hostname, String ipadr, String expectedError) throws Exception {
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		
		if (testName == "duplicate_hostname"){
			//add a host for duplicate testing
			HostTasks.addHost(sahiTasks, hostname, "");

			//new test user can be added now
			HostTasks.addInvalidHost(sahiTasks, hostname, ipadr, expectedError);
			
			//clean up remove duplicate host
			HostTasks.deleteHost(sahiTasks, "duplicate.testrelm");
		}
		
		else {
			//new test user can be added now
			HostTasks.addInvalidHost(sahiTasks, hostname, ipadr, expectedError);
		
			sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		
			// check if host was added , if it was delete it
			if (sahiTasks.exists(sahiTasks.link(hostname))) {
				HostTasks.deleteHost(sahiTasks, hostname);
				String[] components = hostname.split ("\\.");
				String shortname = components[0];
			
				sahiTasks.navigateTo(System.getProperty("ipa.server.url")+dnsPage, true);
				DNSTasks.deleteArecord(sahiTasks, shortname);
			}
		}
	}
	
	/*
	 * delete hosts
	 */
	@Test (groups={"dnsHostTests"}, dataProvider="getHostDNSTestObjects")	
	public void testHostDelete(String testName, String hostname, String ipadr, String ptr) throws Exception {

		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+dnsPage, true);
		DNSTasks.addArecord(sahiTasks, hostname, ipadr);
		
		//add new host
		HostTasks.addHost(sahiTasks, hostname, ipadr);
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+dnsPage, true);
		DNSTasks.addPTRrecord(sahiTasks, hostname, ptr);
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding hosts - for positive cases
	 */
	@DataProvider(name="getHostTestObjects")
	public Object[][] getHostFQDNTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostTestObjects());
	}
	protected List<List<Object>> createHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					fqdn				ipadr
		ll.add(Arrays.asList(new Object[]{ "create_host_lowercase",		"myhost1.testrelm",		"" } ));
		ll.add(Arrays.asList(new Object[]{ "create_host_uppercase",		"MYHOST2.TESTRELM",		"" } ));
		ll.add(Arrays.asList(new Object[]{ "create_host_mixedcase",		"MyHost3.testrelm", 	"" } ));
		ll.add(Arrays.asList(new Object[]{ "externaldns_host",			"external.example", 	"" } ));
		        
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
		ll.add(Arrays.asList(new Object[]{ "delete_host_lowercase",		"myhost1.testrelm" } ));
		ll.add(Arrays.asList(new Object[]{ "delete_host_uppercase",		"myhost2.testrelm" } ));
		ll.add(Arrays.asList(new Object[]{ "delete_host_mixedcase",		"myhost3.testrelm" } ));
		ll.add(Arrays.asList(new Object[]{ "delete_host_externaldns",	"external.example" } ));
		        
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
		
        //										testname					hostname        		ipadr   			expectedError
		ll.add(Arrays.asList(new Object[]{ "duplicate_hostname",			"duplicate.testrelm", 	"9.9.9.9",			"host with name \"duplicate.testrelm\" already exists"		} ));
		ll.add(Arrays.asList(new Object[]{ "missing_host_and_domain",		"myhost1", 				"",					"invalid 'hostname': Fully-qualified hostname required"		} ));
		ll.add(Arrays.asList(new Object[]{ "missing_domain_name",			"myhost1.", 			"",					"Host does not have corresponding DNS A record"		} ));
		//ll.add(Arrays.asList(new Object[]{ "invalidipadr_hostname",			"ddd.testrelm", 		"10.10.10.10",		"The host was added but the DNS update failed with: DNS reverse zone for IP address 10.10.10.10 not found"		} ));	
		//ll.add(Arrays.asList(new Object[]{ "duplicate_ipaddress",			"aaa.testrelm", 		"10.10.10.10",		"This IP address is already assigned."		} ));
		return ll;	
	}

/*
 * Data to be used for DNS hosts
 */
	@DataProvider(name="getHostDNSTestObjects")
	public Object[][] getHostDNSTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostDNSTestObjects());
	}
	protected List<List<Object>> createHostDNSTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
	
		//										testname					hostname        				ipadr   			ptr
		ll.add(Arrays.asList(new Object[]{ "addhost_dnsArecord_exists",		"validdns.testrelm", 			"10.10.10.10",		 "10.10" } ));
		ll.add(Arrays.asList(new Object[]{ "addhost_nodns_force",			"myhost1.", 		"" 										 } ));
		ll.add(Arrays.asList(new Object[]{ "missing_hostname",				"ddd.testrelm", 	"10.10.10.10" } ));	        
		return ll;	
	}
	
	/*
	 * Data to be used when adding and editing hosts - for positive cases
	 */
	@DataProvider(name="getAddEditHostTestObjects")
	public Object[][] getAddEditHostFQDNTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddEditHostTestObjects());
	}
	protected List<List<Object>> createAddEditHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					hostname			ipadr		description							
		ll.add(Arrays.asList(new Object[]{ "add_and_edit_host",			"myhost1.testrelm",		"",		 	"MY host descipta098yhf;  jkhrtoryt"	} ));
		        
		return ll;	
	}
}
