package com.redhat.qe.ipa.sahi.tests.host;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import org.testng.annotations.AfterClass;

import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.DNSTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;


public class HostTests extends SahiTestScript{
	public static SahiTasks sahiTasks = null;	
	private String hostPage = "/ipa/ui/#identity=host&navigation=identity";
	private String dnsPage = "/ipa/ui/#dns=dnszone&identity=dns&navigation=identity";
	private String domain = System.getProperty("ipa.server.domain");
	private String reversezone = System.getProperty("ipa.server.reversezone");
	
	//MIIBbDCB1gIBADAtMREwDwYDVQQKEwhURVNUUkVMTTEYMBYGA1UEAxMPbXlob3N0
	//LnRlc3RyZWxtMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDdegHkkCMdcET1
	//a+q+Edxn4KA5bcXMZeu2yjqokHFqRDNtdB6aLmec20XoW6kt9/lZDf47Mcm23M1H
	//xyJC+u5F0clbU7ojdaxbRqhO/D1MHDiLEH87VPqd6fhwDiV92tkWh68gKxEW29u/
	//COJcscYFf9X37jowYlYENY1i9mxjywIDAQABoAAwDQYJKoZIhvcNAQEFBQADgYEA
	//r9wrR2dn+b07GYfL1nIFsWryp1sb4pO8rr5UmGPNPQLVmm8zih25UKK96/yxe50w
	//z0mZoPCN6phMkHVNhINHa5laOsXwsLg+7aLfQEoOu1XWbWuNAjDA14g+JPB8wzlm
	//980PmlW3kOiJEA6EIzrTEhr5UiXSkv1yEevYNABK9Ys=
	private String csr = "MIIBbDCB1gIBADAtMREwDwYDVQQKEwhURVNUUkVMTTEYMBYGA1UEAxMPbXlob3N0"+ "\n" + "LnRlc3RyZWxtMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDdegHkkCMdcET1"+ "\n" + "a+q+Edxn4KA5bcXMZeu2yjqokHFqRDNtdB6aLmec20XoW6kt9/lZDf47Mcm23M1H"+ "\n" + "xyJC+u5F0clbU7ojdaxbRqhO/D1MHDiLEH87VPqd6fhwDiV92tkWh68gKxEW29u/"+ "\n" + "COJcscYFf9X37jowYlYENY1i9mxjywIDAQABoAAwDQYJKoZIhvcNAQEFBQADgYEA"+ "\n" + "r9wrR2dn+b07GYfL1nIFsWryp1sb4pO8rr5UmGPNPQLVmm8zih25UKK96/yxe50w"+ "\n" + "z0mZoPCN6phMkHVNhINHa5laOsXwsLg+7aLfQEoOu1XWbWuNAjDA14g+JPB8wzlm"+ "\n" + "980PmlW3kOiJEA6EIzrTEhr5UiXSkv1yEevYNABK9Ys=";
	private String badcsr = "MIIBcDCB2gIBADAxMRMwEQYDVQQKEwpRRS5MQUIuSVBBMRowGAYDVQQDExFteWdhv"+ "\n" + "c3QucWUubGFiLmlYTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA4lXS4N0r"+ "\n" + "lvJOwhv7eZdWLoaH5BwNoNgBObTAde4MYRejx75f3Ovo+8WVChRs/xDemDPGfWj0"+ "\n" + "9BW4BDXpX0Vaa3N4akIfKoxDnYckZlifuHxbyrZB9XX8eAZDMwtBzi30elEp5Cf5"+ "\n" + "SWMJ9WBOoXu/YIFOCC58aegXKJjPXLlzvrIoEsCAwEAAaAAMA0GCSqGSIb3DQEBBQUA"+ "\n" + "A4GBABK4TVlwNx4LzQvX/rgfqWTv33iIgkPFY4TLsXiR2XL74HAhDDk5JYJM3DGHP"+ "\n" + "4Si7E/vX6ea6IZuNAul0koIJtT2etUo8oebOKQPFb1F1AY+h6sW/QC3DH20hT85H"+ "\n" + "KhPLOBcjOSY/T9M4u5xsjVtzqZMJCdFKFRg9pLBUrCZhu3Z";
	private String wronghostcsr = "MIIBbDCB1gIBADAtMRMwEQYDVQQKEwpRRS5MQUIuSVBBMRYwFAYDVQQDEw1ob3N0"+ "\n" +"LnRlc3RyZWxtMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDvu8wcVthKZCa/"+ "\n" +"KZ30fKPC1jMZ+PUXE/xJNfKVKG9olVSswk4RG8AD0yCApMJ5u6yXU4pT6RbxVHFg"+ "\n" +"X4xA1e006HIdOKrw5pcKhndMyc21rFaUVb66P8z7FXqiVvx3imgZrbM6rr1rfXvH"+ "\n" +"xTeTwL20Lor5Ym9ypajxGTU7IDaXMwIDAQABoAAwDQYJKoZIhvcNAQEFBQADgYEA"+ "\n" +"1IwWyrFEkXuT1vbiDU1urfSazFObEnMUR4vvIraEdhKqJySq9gB/F3j7h+EomKna"+ "\n" +"+G55hsJN7Ct0dhHks0MVIydCnSj364n2vLtfvidn1OgTYOqg4bWTmIMa/ejyV6pX"+ "\n" +"+tYey0wVg+uXyqSPZr/ZJZtmqkKIzCkzrMpxYDlUNk0=";
	
	private String testhost = "myhost."+domain;
	private String undotesthost = "undohost."+domain;
	private String olddescription = "Old description";
	private String oldlocal = "Boston Massachusetts";
	private String oldlocation = "Basement Lab - Rack 150 - number 13";
	private String oldplatform = "ia64";
	private String oldos = "Fedora 15";
	private String managed = "managed." + domain;
	private String managedby = "managedby."+domain;
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		
		//add the test hosts
		HostTasks.addHost(sahiTasks, testhost, "");
		HostTasks.addHostAndEdit(sahiTasks, undotesthost, "", olddescription, oldlocal, oldlocation, oldplatform, oldos);
		HostTasks.addHost(sahiTasks, managed, "");
		HostTasks.addHost(sahiTasks, managedby, "");
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	
		String [] delhosts = {testhost, undotesthost, managed, managedby };
		//delete the hosts
		HostTasks.deleteHost(sahiTasks, delhosts);
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

		//add new hosts
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
		//delete the hosts
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
		
		//verify host was added
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(lowerdn).exists(), "Added host " + hostname + "  successfully");
		
		//verify all host fields
		HostTasks.verifyHostSettings(sahiTasks, hostname, description, local, location, platform, os);
		
		HostTasks.deleteHost(sahiTasks, hostname);
	}
	
	/*
	 * Modify host fields
	 */
	@Test (groups={"modifyHostTests"}, dataProvider="getModifyHostTestObjects")	
	public void testHostAddAndEdit(String testName, String ipadr, String field, String value) throws Exception {
		
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(testhost).exists(), "Host " + testhost + "  exists");
		
		//modify the host
		HostTasks.modifyHost(sahiTasks, testhost, field, value);
		
		//verify all host field
		HostTasks.verifyHostField(sahiTasks, testhost, field, value);
		
	}
	
	/*
	 * Set host OTP
	 */
	@Test (groups={"otpHostTests"}, dataProvider="getOTPHostTestObjects")	
	public void testHostOTP(String testName, String otp ) throws Exception {
		
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(testhost).exists(), "Host " + testhost + "  exists");
		
		//modify the host
		HostTasks.modifyHostOTP(sahiTasks, testhost, otp);
		
		//TODO need to verify otp is set when bug is fixed that shows there is an existing OTP
		//verify all host field
		//sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		//HostTasks.verifyHostField(sahiTasks, hostname, "otp", otp);
	
	}
	
	/*
	 * Undo Modify 
	 */
	@Test (groups={"undoModifyHostTests"}, dataProvider="getUndoModifyHostTestObjects")	
	public void tesUndoModifyHost(String testName, String olddesc, String newdesc, String oldlocal, String newlocal, String oldlocation, String newlocation, String oldplatform, String newplatform, String oldos, String newos ) throws Exception {
		
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(undotesthost).exists(),  undotesthost + "  exists");
		
		//modify the host
		HostTasks.undoModifyHost(sahiTasks, undotesthost, olddesc, newdesc, oldlocal, newlocal, oldlocation, newlocation, oldplatform, newplatform, oldos, newos);
		
		//verify all host field
		HostTasks.verifyHostSettings(sahiTasks, undotesthost, olddesc, oldlocal, oldlocation, oldplatform, oldos);
		
	}
	
	/*
	 * Set Managed By test
	 */
	@Test (groups={"setManagedByHostTests"}, dataProvider="getSetManageByHostTests")	
	public void testManagedByHost(String testName, String exists, String button ) throws Exception {
		
		HostTasks.setManagedByHost(sahiTasks, managed, managedby, button);
		
		// verify managed by host
		HostTasks.verifyManagedByHost(sahiTasks, managed, managedby, exists);
		
	}
	
	/*
	 * Remove Managed By test
	 */
	@Test (groups={"removeManagedByHostTests"}, dataProvider="getRemoveManageByHostTests",  dependsOnGroups="setManagedByHostTests" )	
	public void testRemoveManagedByHost(String testName, String exists, String button ) throws Exception {

		HostTasks.removeManagedByHost(sahiTasks, managed, managedby, button);
		
		// verify managed by host
		HostTasks.verifyManagedByHost(sahiTasks, managed, managedby, exists);

	}
	
	/*
	 * Certificate Tests
	 */
	@Test (groups={"hostCertificateTests"}, dataProvider="getHostCertificateTests")	
	public void testHostCertificates(String testName, String reason ) throws Exception {
		
		// add request certificate
		HostTasks.addHostCertificate(sahiTasks, testhost, csr);
		
		// verify valid certificate
		HostTasks.verifyHostCertificate(sahiTasks, testhost);
		
		// cancel hold certificate
		HostTasks.revokeHostCertificate(sahiTasks, testhost, "Certificate Hold", "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, testhost);
		
		// put certificate on hold
		HostTasks.revokeHostCertificate(sahiTasks, testhost, "Certificate Hold", "Revoke");
		HostTasks.verifyHostCertificate(sahiTasks, testhost, "Hold", "Certificate Hold");
		
		// cancel restore certificate
		HostTasks.restoreHostCertificate(sahiTasks, testhost, "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, testhost, "Hold", "Certificate Hold");
		
		//restore certificate
		HostTasks.restoreHostCertificate(sahiTasks, testhost, "Restore");
		HostTasks.verifyHostCertificate(sahiTasks, testhost);
		
		//cancel revoking certificate
		HostTasks.revokeHostCertificate(sahiTasks, testhost, reason, "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, testhost);
		
		//revoke certificate
		HostTasks.revokeHostCertificate(sahiTasks, testhost, reason, "Revoke");
		HostTasks.verifyHostCertificate(sahiTasks, testhost, "Revoked", reason);
		
		// cancel request for new certificate
		HostTasks.newHostCertificate(sahiTasks, testhost, csr, "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, testhost, "Revoked", reason);
		
		// request for new certificate
		HostTasks.newHostCertificate(sahiTasks, testhost, csr, "Issue");
		HostTasks.verifyHostCertificate(sahiTasks, testhost);
		
	}
	
	/*
	 * Invalid Certificate Request Tests
	 */
	@Test (groups={"hostInvalidCSRTests"}, dataProvider="getInvalidHostCSRTestObjects")	
	public void testHostInvalidCSR(String testName, String csr, String expectedError ) throws Exception {
		
		// add request certificate
		HostTasks.invalidHostCSR(sahiTasks, testhost, csr, expectedError);
		
	}

	/*
	 * Add host - for negative tests
	 */
	@Test (groups={"invalidhostAddTests"}, dataProvider="getInvalidHostTestObjects")	
	public void testInvalidHostadd(String testName, String hostname, String ipadr, String expectedError) throws Exception {
		
		if (testName == "duplicate_hostname"){
			HostTasks.addInvalidHost(sahiTasks, hostname, ipadr, expectedError);
		}
		else {
			HostTasks.addInvalidHost(sahiTasks, hostname, ipadr, expectedError);
			
		}
	}
	
	/*
	 * Host Add DNS tests
	 */
	@Test (groups={"hostAddDNSTests"}, dataProvider="getHostAddDNSTestObjects")	
	public void testHostAddDNS(String testName, String hostname, String ipend, String updatedns ) throws Exception {
		String [] dcs = reversezone.split("\\.");
		String ipprefix = dcs[2] + "." + dcs[1] + "." + dcs[0] + ".";
		String ipaddr = ipprefix + ipend;
		String fqdn = hostname + "." + domain;
		
		// add host
		HostTasks.addHost(sahiTasks, fqdn, ipaddr);
		
		// verify host was added
		com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(fqdn).exists(), "Added host " + fqdn + "  successfully");
		
		// verify host link to dns and dns records
		HostTasks.verifyHostDNSLink(sahiTasks, fqdn, "YES");
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+dnsPage, true);
		DNSTasks.verifyRecord(sahiTasks, domain, hostname, "arecord", ipaddr, "YES");
		DNSTasks.verifyRecord(sahiTasks, reversezone, ipend, "ptrrecord", fqdn + ".", "YES");
		
		// deleted host
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
		HostTasks.deleteHost(sahiTasks, fqdn, updatedns);
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+dnsPage, true);
		if( updatedns == "YES"){
			DNSTasks.verifyRecord(sahiTasks, domain, hostname, "arecord", ipaddr, "NO");
			DNSTasks.verifyRecord(sahiTasks, reversezone, ipend, "ptrrecord", fqdn + ".", "NO");
		}
		else{
			DNSTasks.verifyRecord(sahiTasks, domain, hostname, "arecord", ipaddr, "YES");
			DNSTasks.verifyRecord(sahiTasks, reversezone, ipend, "ptrrecord", fqdn + ".", "YES");
			DNSTasks.deleteRecord(sahiTasks, domain, hostname);
			DNSTasks.deleteRecord(sahiTasks, reversezone, ipend);
			
		}
		
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+hostPage, true);
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
		ll.add(Arrays.asList(new Object[]{ "add_host_tilde",			"test~."+domain, 		"" } ));
		ll.add(Arrays.asList(new Object[]{ "add_host_dash",				"test-."+domain, 		"" } ));
		        
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
		ll.add(Arrays.asList(new Object[]{ "delete_host_tilde",			"test~."+domain     	} ));
		ll.add(Arrays.asList(new Object[]{ "delete_host_dash",			"test-."+domain		} ));
		        
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
		ll.add(Arrays.asList(new Object[]{ "duplicate_hostname",			testhost, 				"",					"host with name \""+ testhost +"\" already exists"	} ));
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
		
        //										testname				ipadr		field  					value
		ll.add(Arrays.asList(new Object[]{ "modify_description",		"",			"description",			"My new host value - abcdefghijklmnopqrstuvwxyz 1234567890"	} ));
		ll.add(Arrays.asList(new Object[]{ "modify_local",				"",			"local",				"United States - Massachusetts - Westford"	} ));
		ll.add(Arrays.asList(new Object[]{ "modify_location",			"",			"location",				"West Wing - Lab 41 - Rack 143"		} ));	
		ll.add(Arrays.asList(new Object[]{ "modify_platform",			"", 		"platform",				"ppc64"	} ));
		ll.add(Arrays.asList(new Object[]{ "modify_os",					"",			"os",					"Red Hat Enterprise Linux 6 Update 1"		} ));
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
		
        //										testname			otp
		ll.add(Arrays.asList(new Object[]{ "OTP_alpha",				"kjfghaoihetoiharitharighp"	} ));
		ll.add(Arrays.asList(new Object[]{ "OTP_numeric",			"20892750975047735451"	} ));
		ll.add(Arrays.asList(new Object[]{ "OTP_alphanumeric",		"kjasdoa58gshoty7475p759burtsyrta436756878"		} ));	
		ll.add(Arrays.asList(new Object[]{ "OTP_special_chars",		"#$%^&()&(^%$*^$+"	} ));
		ll.add(Arrays.asList(new Object[]{ "OTP_mixed",				"#kajfa8ga89pajh0b6q<ejt} j&b7q9nbti*"		} ));
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
		
        //										testname				exists	button
		ll.add(Arrays.asList(new Object[]{ "set_managedby_cancel",		"No",	"Cancel" } ));
		ll.add(Arrays.asList(new Object[]{ "set_managedby_enroll",		"Yes",	"Enroll" } ));
		        
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
		
        //										testname				exists	button
		ll.add(Arrays.asList(new Object[]{ "remove_managedby_cancel",	"Yes",	"Cancel" } ));
		ll.add(Arrays.asList(new Object[]{ "remove_managedby_delete",	"No",	"Delete" } ));
		        
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
		
        //										testname							reason
		ll.add(Arrays.asList(new Object[]{ "add_view_hold_revoke_new_certificate",	"Key Compromise"  } ));
		        
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
		
        //										testname			csr   			expectedError
		ll.add(Arrays.asList(new Object[]{ "csr_blank",				"",				"Certificate operation cannot be completed: Failure decoding Certificate Signing Request" } ));
		ll.add(Arrays.asList(new Object[]{ "csr_invalid_format",	badcsr,			"Base64 decoding failed: Incorrect padding"	} ));
		ll.add(Arrays.asList(new Object[]{ "csr_wrong_host",		wronghostcsr,	"Insufficient access: hostname in subject of request 'host.testrelm' does not match principal hostname '" + testhost + "'"	} ));	
		return ll;	
	}
	
	/*
	 * Data to be used for host DNS tests 
	 */
	@DataProvider(name="getHostAddDNSTests")
	public Object[][] getHostAddDNSTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostAddDNSTestObjects());
	}
	protected List<List<Object>> createHostAddDNSTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname						hostname		 ip address end		updatedns
		ll.add(Arrays.asList(new Object[]{ "host_add_del_updatedns",			"dnshost",  		"99",			 	"YES" } ));
		ll.add(Arrays.asList(new Object[]{ "host_add_del_noupdatedns",			"dnshost",  		"99",				"NO" } ));
		        
		return ll;	
	}
	
}
