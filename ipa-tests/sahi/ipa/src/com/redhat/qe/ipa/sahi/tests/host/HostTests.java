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
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	public static SahiTasks sahiTasks = null;	
	private String hostPage = "/ipa/ui/#identity=host&navigation=identity";
	private String dnsPage = "/ipa/ui/#identity=dnszone&navigation=policy";
	private String domain = System.getProperty("ipa.server.domain");
	
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
	public void testHostAddAndEdit(String testName, String hostname, String ipadr, String description, String local, String location, String platform, String os) throws Exception {
		String lowerdn = hostname.toLowerCase();
		
		//verify host doesn't exist
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(lowerdn).exists(), "Verify host " + hostname + " doesn't already exist");
		
		//add and edit new host
		HostTasks.addHostAndEdit(sahiTasks, hostname, ipadr, description, local, location, platform, os);
		

		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		//verify host was added
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(lowerdn).exists(), "Added host " + hostname + "  successfully");
		
		//verify all host fields
		HostTasks.verifyHostSettings(sahiTasks, hostname, description, local, location, platform, os);
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		HostTasks.deleteHost(sahiTasks, hostname);
	}
	
	/*
	 * delete hosts
	 */
	@Test (groups={"deleteHostTests"}, dataProvider="getHostDeleteTestObjects",  dependsOnGroups="addHostTests")	
	public void testHostDelete(String testName, String fqdn) throws Exception {
		//verify host exists
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(fqdn).exists(), "Verify host " + fqdn + " already exist");
		
		//delete new host
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
			HostTasks.addHost(sahiTasks, hostname, ipadr);

			//new test user can be added now
			HostTasks.addInvalidHost(sahiTasks, hostname, ipadr, expectedError);
			
			//clean up remove duplicate host
			HostTasks.deleteHost(sahiTasks, hostname);
		}
		
		else {
			//new test host can be added now
			sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
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
		ll.add(Arrays.asList(new Object[]{ "add_host_lowercase",		"myhost1."+domain,		"" } ));
		ll.add(Arrays.asList(new Object[]{ "add_host_uppercase",		"MYHOST2."+domain,		"" } ));
		ll.add(Arrays.asList(new Object[]{ "add_host_mixedcase",		"MyHost3."+domain, 		"" } ));
		ll.add(Arrays.asList(new Object[]{ "externaldns_host",			"external.example", 	"" } ));
		ll.add(Arrays.asList(new Object[]{ "add_host_tilde",			"test~"+domain, 		"" } ));
		ll.add(Arrays.asList(new Object[]{ "add_host_dash",				"test-"+domain, 		"" } ));
		        
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
		ll.add(Arrays.asList(new Object[]{ "delete_host_lowercase",		"myhost1."+domain 	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_host_uppercase",		"myhost2."+domain 	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_host_mixedcase",		"myhost3."+domain 	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_host_externaldns",	"external.example" 	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_host_tilde",			"test~"+domain     	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_host_dash",			"test-"+domain		} ));
		        
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
		ll.add(Arrays.asList(new Object[]{ "missing_host_and_domain",		"test", 				"",					"invalid 'hostname': Fully-qualified hostname required"		} ));
		ll.add(Arrays.asList(new Object[]{ "invalidipadr_alpha_chars",		"test."+domain, 		"null",				"invalid 'ip_address': invalid IP address"				} ));
		ll.add(Arrays.asList(new Object[]{ "invalidipadr_too_many_octets",	"test."+domain, 		"10.10.10.10.10",	"invalid 'ip_address': invalid IP address"		} ));	
		ll.add(Arrays.asList(new Object[]{ "invalidipadr_bad_octects",		"test."+domain, 		"999.999.999.999",	"invalid 'ip_address': invalid IP address"		} ));
		ll.add(Arrays.asList(new Object[]{ "invalidipadr_special_chars",	"test."+domain, 		"~.&.#.^",			"invalid 'ip_address': invalid IP address"		} ));
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
		ll.add(Arrays.asList(new Object[]{ "addhost_dnsArecord_exists",		"validdns."+domain, 			"10.10.10.10",		 "10.10" } ));
		ll.add(Arrays.asList(new Object[]{ "addhost_nodns_force",			"myhost1.", 		"" 										 } ));
		ll.add(Arrays.asList(new Object[]{ "missing_hostname",				"ddd."+domain, 	"10.10.10.10" } ));	        
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
		
        //										testname					hostname			ipadr		description								local								location						platform	os
		ll.add(Arrays.asList(new Object[]{ "add_and_edit_host",			"myhost1."+domain,		"",		 	"MY host descipta098yhf;  jkhrtoryt",	"314 Littleton Road, Westford, MA",	"3rd Floor under Jenny's Desk",	"x86_64",	"Fedora 15" } ));
		        
		return ll;	
	}
}
