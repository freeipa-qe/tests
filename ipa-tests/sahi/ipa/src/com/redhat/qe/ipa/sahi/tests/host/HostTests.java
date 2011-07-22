package com.redhat.qe.ipa.sahi.tests.host;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.DNSTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;


public class HostTests extends SahiTestScript{
	public static SahiTasks sahiTasks = null;	
	private String hostPage = "/ipa/ui/#identity=host&navigation=identity";
	private String dnsPage = "/ipa/ui/#identity=dnszone&navigation=policy";
	private String domain = System.getProperty("ipa.server.domain");
	private String csr = "MIIBcDCB2gIBADAxMRMwEQYDVQQKEwpRRS5MQUIuSVBBMRowGAYDVQQDExFteWhv"+ "\n" + "c3QucWUubGFiLmlwYTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA4lXS4N0r"+ "\n" + "lvJOwhv7eZdWLoaH5BwNoNgBObTAde4MYRejx75f3Ovo+8WVChRs/xDemDPGfWj0"+ "\n" + "9BW4BDXpX0Vaa3N4akIfKoxDnYckZlifuHxbyrZB9XX8eAZDMwtBzi30elEp5Cf5"+ "\n" + "SWMJ9WBOoXu/YCC58aegXKJjPXLlzvrIoEsCAwEAAaAAMA0GCSqGSIb3DQEBBQUA"+ "\n" + "A4GBABK4TVlwNx4LzQvX/rgfqWTv33iIgkPFY4TsXiR2XL74HAhDDk5JYJM3DGHP"+ "\n" + "4Si7E/vX6ea6IZuNAul0koIJtT2etUo8oebOKQPFb1F1AY+h6sW/QC3DH20hT85H"+ "\n" + "KhPLOBcjOSY/T9M4eu5xsjVtzqZMJCdFKFRg9pLBUrCZhu3Z";
	private String badcsr = "MIIBcDCB2gIBADAxMRMwEQYDVQQKEwpRRS5MQUIuSVBBMRowGAYDVQQDExFteWdhv"+ "\n" + "c3QucWUubGFiLmlYTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA4lXS4N0r"+ "\n" + "lvJOwhv7eZdWLoaH5BwNoNgBObTAde4MYRejx75f3Ovo+8WVChRs/xDemDPGfWj0"+ "\n" + "9BW4BDXpX0Vaa3N4akIfKoxDnYckZlifuHxbyrZB9XX8eAZDMwtBzi30elEp5Cf5"+ "\n" + "SWMJ9WBOoXu/YIFOCC58aegXKJjPXLlzvrIoEsCAwEAAaAAMA0GCSqGSIb3DQEBBQUA"+ "\n" + "A4GBABK4TVlwNx4LzQvX/rgfqWTv33iIgkPFY4TLsXiR2XL74HAhDDk5JYJM3DGHP"+ "\n" + "4Si7E/vX6ea6IZuNAul0koIJtT2etUo8oebOKQPFb1F1AY+h6sW/QC3DH20hT85H"+ "\n" + "KhPLOBcjOSY/T9M4u5xsjVtzqZMJCdFKFRg9pLBUrCZhu3Z";
	private String wronghostcsr = "MIIBbDCB1gIBADAtMRMwEQYDVQQKEwpRRS5MQUIuSVBBMRYwFAYDVQQDEw1ob3N0"+ "\n" +"LnRlc3RyZWxtMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDvu8wcVthKZCa/"+ "\n" +"KZ30fKPC1jMZ+PUXE/xJNfKVKG9olVSswk4RG8AD0yCApMJ5u6yXU4pT6RbxVHFg"+ "\n" +"X4xA1e006HIdOKrw5pcKhndMyc21rFaUVb66P8z7FXqiVvx3imgZrbM6rr1rfXvH"+ "\n" +"xTeTwL20Lor5Ym9ypajxGTU7IDaXMwIDAQABoAAwDQYJKoZIhvcNAQEFBQADgYEA"+ "\n" +"1IwWyrFEkXuT1vbiDU1urfSazFObEnMUR4vvIraEdhKqJySq9gB/F3j7h+EomKna"+ "\n" +"+G55hsJN7Ct0dhHks0MVIydCnSj364n2vLtfvidn1OgTYOqg4bWTmIMa/ejyV6pX"+ "\n" +"+tYey0wVg+uXyqSPZr/ZJZtmqkKIzCkzrMpxYDlUNk0=";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
	}

	/*
	 * Add hosts - for positive tests
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
	 * Add and add another host - for positive tests
	 */
	@Test (groups={"addAndAddAnotherHostTests"}, dataProvider="getAddAndAddAnotherHostTests")	
	public void testHostForceAdd(String testName, String hostname1, String hostname2, String hostname3) throws Exception {
		String [] hostnames = {hostname1, hostname2, hostname3};
		for (String hostname : hostnames){
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(hostname).exists(), "Verify host " + hostname + " doesn't already exist");
		}

		//add new host
		HostTasks.addAndAddAnotherHost(sahiTasks, hostname1, hostname2, hostname3);
		
		for (String hostname : hostnames){
			//verify host was added
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(hostname).exists(), "Added host " + hostname + "  successfully");
		}
	}
	
	/*
	 * delete multiple hosts
	 */
	@Test (groups={"deleteMultipleHostTests"}, dataProvider="deleteMultipleHostsTests",  dependsOnGroups="addAndAddAnotherHostTests")	
	public void testDeleteMultipleHosts(String testName, String hostname1, String hostname2, String hostname3) throws Exception {
		String [] hostnames = {hostname1, hostname2, hostname3};
		for (String hostname : hostnames) {
			//verify host exists
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(hostname).exists(), "Verify host " + hostname + " already exist");
		}
		//delete new host
		HostTasks.deleteHost(sahiTasks, hostnames);
		for (String hostname : hostnames) {
			//verify host was deleted
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(hostname).exists(), "Deleted host " + hostname + "  successfully");
		}
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
	 * Modify host fields
	 */
	@Test (groups={"modifyHostTests"}, dataProvider="getModifyHostTestObjects")	
	public void testHostAddAndEdit(String testName, String hostname, String ipadr, String field, String value) throws Exception {
		
		//add the host
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(hostname).exists(), "Verify host " + hostname + " doesn't already exist");
		HostTasks.addHost(sahiTasks, hostname, ipadr);
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(hostname).exists(), "Added host " + hostname + "  successfully");
		
		//modify the host
		HostTasks.modifyHost(sahiTasks, hostname, field, value);
		
		//verify all host field
		HostTasks.verifyHostField(sahiTasks, hostname, field, value);
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		HostTasks.deleteHost(sahiTasks, hostname);
	}
	
	/*
	 * Set host OTP
	 */
	@Test (groups={"otpHostTests"}, dataProvider="getOTPHostTestObjects")	
	public void testHostAddAndEdit(String testName, String hostname, String ipadr, String otp ) throws Exception {
		
		//add the host
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(hostname).exists(), "Verify host " + hostname + " doesn't already exist");
		HostTasks.addHost(sahiTasks, hostname, ipadr);
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(hostname).exists(), "Added host " + hostname + "  successfully");
		
		//modify the host
		HostTasks.modifyHost(sahiTasks, hostname, otp);
		
		//verify all host field
		HostTasks.verifyHostField(sahiTasks, hostname, "otp", otp);
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		HostTasks.deleteHost(sahiTasks, hostname);
	}
	
	/*
	 * Undo Modify 
	 */
	@Test (groups={"undoModifyHostTests"}, dataProvider="getUndoModifyHostTestObjects")	
	public void tesUndoModifyHost(String testName, String hostname, String ipadr, String olddesc, String newdesc, String oldlocal, String newlocal, String oldlocation, String newlocation, String oldplatform, String newplatform, String oldos, String newos ) throws Exception {
		
		//add the host
		com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(hostname).exists(), "Verify host " + hostname + " doesn't already exist");
		HostTasks.addHostAndEdit(sahiTasks, hostname, ipadr, olddesc, oldlocal, oldlocation, oldplatform, oldos);
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(hostname).exists(), "Added host " + hostname + "  successfully");
		
		//modify the host
		HostTasks.undoModifyHost(sahiTasks, hostname, olddesc, newdesc, oldlocal, newlocal, oldlocation, newlocation, oldplatform, newplatform, oldos, newos);
		
		//verify all host field
		HostTasks.verifyHostSettings(sahiTasks, hostname, olddesc, oldlocal, oldlocation, oldplatform, oldos);
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		HostTasks.deleteHost(sahiTasks, hostname);
	}
	
	/*
	 * Set Managed By test
	 */
	@Test (groups={"setManagedByHostTests"}, dataProvider="getSetManageByHostTests")	
	public void testManagedByHost(String testName, String managed, String managedby, String exists, String button ) throws Exception {
		if (testName == "set_managedby_cancel"){
			// add managed host
			HostTasks.addHost(sahiTasks, managed, "");
			// add managed by host
			HostTasks.addHost(sahiTasks, managedby, "");
		}
		
		HostTasks.setManagedByHost(sahiTasks, managed, managedby, button);
		
		// verify managed by host
		HostTasks.verifyManagedByHost(sahiTasks, managed, managedby, exists);
	}
	
	/*
	 * Remove Managed By test
	 */
	@Test (groups={"removeManagedByHostTests"}, dataProvider="getRemoveManageByHostTests",  dependsOnGroups="setManagedByHostTests")	
	public void testRemoveManagedByHost(String testName, String managed, String managedby, String exists, String button ) throws Exception {
	
		HostTasks.setManagedByHost(sahiTasks, managed, managedby, "Enroll");

		HostTasks.removeManagedByHost(sahiTasks, managed, managedby, button);
		
		// verify managed by host
		HostTasks.verifyManagedByHost(sahiTasks, managed, managedby, exists);
		
		if (testName == "remove_managedby_delete"){
			//delete the hosts
			String [] hostnames = {managed, managedby};
			HostTasks.deleteHost(sahiTasks, hostnames);
		}
	}
	
	/*
	 * Certificate Tests
	 */
	@Test (groups={"hostCertificateTests"}, dataProvider="getHostCertificateTests")	
	public void testHostCertificates(String testName, String hostname, String reason ) throws Exception {
		// add managed host
		HostTasks.addHost(sahiTasks, hostname, "");
		
		// add request certificate
		HostTasks.addHostCertificate(sahiTasks, hostname, csr);
		
		// verify valid certificate
		HostTasks.verifyHostCertificate(sahiTasks, hostname);
		
		// cancel hold certificate
		HostTasks.revokeHostCertificate(sahiTasks, hostname, "Certificate Hold", "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, hostname);
		
		// put certificate on hold
		HostTasks.revokeHostCertificate(sahiTasks, hostname, "Certificate Hold", "Revoke");
		HostTasks.verifyHostCertificate(sahiTasks, hostname, "Hold", "Certificate Hold");
		
		// cancel restore certificate
		HostTasks.restoreHostCertificate(sahiTasks, hostname, "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, hostname, "Hold", "Certificate Hold");
		
		//restore certificate
		HostTasks.restoreHostCertificate(sahiTasks, hostname, "Restore");
		HostTasks.verifyHostCertificate(sahiTasks, hostname);
		
		//cancel revoking certificate
		HostTasks.revokeHostCertificate(sahiTasks, hostname, reason, "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, hostname);
		
		//revoke certificate
		HostTasks.revokeHostCertificate(sahiTasks, hostname, reason, "Revoke");
		HostTasks.verifyHostCertificate(sahiTasks, hostname, "Revoked", reason);
		
		// cancel request for new certificate
		HostTasks.newHostCertificate(sahiTasks, hostname, csr, "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, hostname, "Revoked", reason);
		
		// request for new certificate
		HostTasks.newHostCertificate(sahiTasks, hostname, csr, "Issue");
		HostTasks.verifyHostCertificate(sahiTasks, hostname);
		
		//delete the host
		HostTasks.deleteHost(sahiTasks, hostname);
		
	}
	
	/*
	 * Invalid Certificate Request Tests
	 */
	@Test (groups={"hostInvalidCSRTests"}, dataProvider="getInvalidHostCSRTestObjects")	
	public void testHostInvalidCSR(String testName, String hostname, String csr, String expectedError ) throws Exception {
		// add host
		HostTasks.addHost(sahiTasks, hostname, "");
		
		// add request certificate
		HostTasks.invalidHostCSR(sahiTasks, hostname, csr, expectedError);
		
		// deleted host
		HostTasks.deleteHost(sahiTasks, hostname);
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
	
	/*
	 * Data to be used when adding and adding additional hosts - for positive cases
	 */
	@DataProvider(name="getAddAndAddAnotherHostTests")
	public Object[][] getAddAndAddAnotherHostTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddAndAddAnotherHostTestObjects());
	}
	protected List<List<Object>> createAddAndAddAnotherHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				hostname1			hostname2			hostname3
		ll.add(Arrays.asList(new Object[]{ "add_and_add_another_host",	"myhost1."+domain,	 "myhost2."+domain, "myhost3."+domain } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when deleting multiple hosts
	 */
	@DataProvider(name="deleteMultipleHostsTests")
	public Object[][] getDeleteMultipleHostsTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDeleteMultipleHostsTestObjects());
	}
	protected List<List<Object>> createDeleteMultipleHostsTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				hostname1			hostname2			hostname3
		ll.add(Arrays.asList(new Object[]{ "delete_multiple_hosts",	"myhost1."+domain,	 "myhost2."+domain, "myhost3."+domain } ));
		        
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
	 * Data to be used when modifying hosts - for positive tests
	 */
	@DataProvider(name="getModifyHostTestObjects")
	public Object[][] getModifyHostTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createModifyHostTestObjects());
	}
	protected List<List<Object>> createModifyHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					hostname        		ipadr		field  					value
		ll.add(Arrays.asList(new Object[]{ "modify_description",			"desc."+domain, 		"",			"description",			"My new host value - abcdefghijklmnopqrstuvwxyz 1234567890"	} ));
		ll.add(Arrays.asList(new Object[]{ "modify_local",					"local."+domain, 		"",			"local",				"United States - Massachusetts - Westford"	} ));
		ll.add(Arrays.asList(new Object[]{ "modify_location",				"location."+domain, 	"",			"location",				"West Wing - Lab 41 - Rack 143"		} ));	
		ll.add(Arrays.asList(new Object[]{ "modify_platform",				"platform."+domain, 	"", 		"platform",				"ppc64"	} ));
		ll.add(Arrays.asList(new Object[]{ "modify_os",						"os."+domain, 			"",			"os",					"Red Hat Enterprise Linux 6 Update 1"		} ));
		return ll;	
	}
	
	/*
	 * Data to be used when setting OTP for hosts - for positive tests
	 */
	@DataProvider(name="getOTPHostTestObjects")
	public Object[][] getOTPHostTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createOTPHostTestObjects());
	}
	protected List<List<Object>> createOTPHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					hostname        			ipadr		otp
		ll.add(Arrays.asList(new Object[]{ "OTP_alpha",						"alpha."+domain, 			"",			"kjfghaoihetoiharitharighp"	} ));
		ll.add(Arrays.asList(new Object[]{ "OTP_numeric",					"numeric."+domain, 			"",			"20892750975047735451"	} ));
		ll.add(Arrays.asList(new Object[]{ "OTP_alphanumeric",				"alphanumeric."+domain, 	"",			"kjasdoa58gshoty7475p759burtsyrta436756878"		} ));	
		ll.add(Arrays.asList(new Object[]{ "OTP_special_chars",				"special."+domain, 			"", 		"#$%^&()&(^%$*^$+"	} ));
		ll.add(Arrays.asList(new Object[]{ "OTP_mixed",						"mixed."+domain, 			"",			"#kajfa8ga89pajh0b6q<ejt} j&b7q9nbti*"		} ));
		return ll;	
	}
	
	/*
	 * Data to be used when undoing host modifications - for positive tests
	 */
	@DataProvider(name="getUndoModifyHostTestObjects")
	public Object[][] getUndoModifyHostTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUndoModifyHostTestObjects());
	}
	protected List<List<Object>> createUndoModifyHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				hostname        	ipadr		olddesc  					newdesc																oldlocal				newlocal						oldlocationoldplatform		newlocation	newplatform		oldos			newos
		ll.add(Arrays.asList(new Object[]{ 		"modify_description",	"undo."+domain, 	"",			"Old description",			"My new host value $#* - abcdefghijklmnopqrstuvwxyz 1234567890",	"Boston Massachusetts",	"Mountain View, California",	"Lab 10 - Building 3",		"Basement Lab - Rack 150 - number 13",		"ia64",			"x86_64",		"Fedora 15",	"Red Hat Enterprise Linux 6.0 Client"	} ));
		return ll;	
	}
	
	
	/*
	 * Data to be used when setting managed host - for positive cases
	 */
	@DataProvider(name="getSetManageByHostTests")
	public Object[][] getSetManageHostTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createSetManageHostTestObjects());
	}
	protected List<List<Object>> createSetManageHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				managed				 managedby					exists	button
		ll.add(Arrays.asList(new Object[]{ "set_managedby_cancel",			"managed."+domain,	 "managedby."+domain, 	"No",	"Cancel" } ));
		ll.add(Arrays.asList(new Object[]{ "set_managedby_enroll",			"managed."+domain,	 "managedby."+domain, 	"Yes",	"Enroll" } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when removing managed host - for positive cases
	 */
	@DataProvider(name="getRemoveManageByHostTests")
	public Object[][] getRemoveManageHostTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createRemoveManageHostTestObjects());
	}
	protected List<List<Object>> createRemoveManageHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				managed				 managedby				exists	button
		ll.add(Arrays.asList(new Object[]{ "remove_managedby_cancel",	"managed."+domain,	 "managedby."+domain, 	"Yes",	"Cancel" } ));
		ll.add(Arrays.asList(new Object[]{ "remove_managedby_delete",	"managed."+domain,	 "managedby."+domain, 	"No",	"Delete" } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used for host certificate tests - for positive cases
	 */
	@DataProvider(name="getHostCertificateTests")
	public Object[][] getHostCertificateTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostCertificateTestObjects());
	}
	protected List<List<Object>> createHostCertificateTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname							hostname			reason
		ll.add(Arrays.asList(new Object[]{ "add_view_hold_revoke_new_certificate",	"myhost.qe.lab.ipa", 	"Key Compromise"  } ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used for invalid CSR tests - for negative cases
	 */
	@DataProvider(name="getInvalidHostCSRTestObjects")
	public Object[][] getInvalidHostCSRTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidHostCSRTestObjects());
	}
	protected List<List<Object>> createInvalidHostCSRTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					hostname        		csr   			expectedError
		ll.add(Arrays.asList(new Object[]{ "csr_blank",				"myhost.qe.lab.ipa", 		"",				"Certificate operation cannot be completed: Failure decoding Certificate Signing Request" } ));
		ll.add(Arrays.asList(new Object[]{ "csr_invalid_format",		"myhost.qe.lab.ipa", 		badcsr,			"Base64 decoding failed: Incorrect padding"	} ));
		ll.add(Arrays.asList(new Object[]{ "csr_wrong_host",			"myhost.qe.lab.ipa", 		wronghostcsr,	"Insufficient access: hostname in subject of request 'host.testrelm' does not match principal hostname 'myhost.qe.lab.ipa'"	} ));	
		return ll;	
	}
}
