package com.redhat.qe.ipa.sahi.tests.host;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import org.testng.annotations.AfterClass;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.DNSTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.ServiceTasks;


public class HostTests extends SahiTestScript{

	private String domain = "";
	private String reversezone = "";
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	private String badcsr = "MIIBcDCB2gIBADAxMRMwEQYDVQQKEwpRRS5MQUIuSVBBMRowGAYDVQQDExFteWdhv"+ "\n" + "c3QucWUubGFiLmlYTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA4lXS4N0r"+ "\n" + "lvJOwhv7eZdWLoaH5BwNoNgBObTAde4MYRejx75f3Ovo+8WVChRs/xDemDPGfWj0"+ "\n" + "9BW4BDXpX0Vaa3N4akIfKoxDnYckZlifuHxbyrZB9XX8eAZDMwtBzi30elEp5Cf5"+ "\n" + "SWMJ9WBOoXu/YIFOCC58aegXKJjPXLlzvrIoEsCAwEAAaAAMA0GCSqGSIb3DQEBBQUA"+ "\n" + "A4GBABK4TVlwNx4LzQvX/rgfqWTv33iIgkPFY4TLsXiR2XL74HAhDDk5JYJM3DGHP"+ "\n" + "4Si7E/vX6ea6IZuNAul0koIJtT2etUo8oebOKQPFb1F1AY+h6sW/QC3DH20hT85H"+ "\n" + "KhPLOBcjOSY/T9M4u5xsjVtzqZMJCdFKFRg9pLBUrCZhu3Z";
	private String wronghostcsr = "MIIBbDCB1gIBADAtMRMwEQYDVQQKEwpRRS5MQUIuSVBBMRYwFAYDVQQDEw1ob3N0"+ "\n" +"LnRlc3RyZWxtMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDvu8wcVthKZCa/"+ "\n" +"KZ30fKPC1jMZ+PUXE/xJNfKVKG9olVSswk4RG8AD0yCApMJ5u6yXU4pT6RbxVHFg"+ "\n" +"X4xA1e006HIdOKrw5pcKhndMyc21rFaUVb66P8z7FXqiVvx3imgZrbM6rr1rfXvH"+ "\n" +"xTeTwL20Lor5Ym9ypajxGTU7IDaXMwIDAQABoAAwDQYJKoZIhvcNAQEFBQADgYEA"+ "\n" +"1IwWyrFEkXuT1vbiDU1urfSazFObEnMUR4vvIraEdhKqJySq9gB/F3j7h+EomKna"+ "\n" +"+G55hsJN7Ct0dhHks0MVIydCnSj364n2vLtfvidn1OgTYOqg4bWTmIMa/ejyV6pX"+ "\n" +"+tYey0wVg+uXyqSPZr/ZJZtmqkKIzCkzrMpxYDlUNk0=";
	
	private String testhost = "myhost";
	private String undotesthost = "undohost";
	private String olddescription = "Old description";
	private String oldlocal = "Boston Massachusetts";
	private String oldlocation = "Basement Lab - Rack 150 - number 13";
	private String oldplatform = "ia64";
	private String oldos = "Fedora 15";
	private String managed = "managed";
	private String managedby = "managedby";
	private String testprincipal = "";
	private String realm = "";
;	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		
		domain = commonTasks.getIpadomain();
		reversezone = commonTasks.getReversezone();
		
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&host-facet=search" ;
		
		realm = domain.toUpperCase();
		testprincipal = "host" + "/" + testhost + "." + domain + "@" + realm;
		
		
		//add the test hosts
		HostTasks.addHost(sahiTasks, testhost, domain, "");
		HostTasks.addHostAndEdit(sahiTasks, domain, undotesthost, "", olddescription, oldlocal, oldlocation, oldplatform, oldos);
		HostTasks.addHost(sahiTasks, managed, domain, "");
		HostTasks.addHost(sahiTasks,managedby, domain, "");
		
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	
		String [] delhosts = {testhost + "." + domain, undotesthost + "." + domain, managed + "." + domain, managedby + "." + domain };
		//delete the hosts
		HostTasks.deleteHost(sahiTasks, delhosts);
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.hostPage, true);
		}		
	}

	/*
	 * Add hosts - for positive tests
	 */
	@Test (groups={"addHostTests"}, dataProvider="getHostTestObjects")	
	public void testHostForceAdd(String testName, String hostname, String ipadr) throws Exception {
		String fqdn = hostname + "." + domain;
		String lowerdn = fqdn.toLowerCase();
		
		//verify host doesn't exist
		Assert.assertFalse(sahiTasks.link(lowerdn).exists(), "Verify host " + fqdn + " doesn't already exist");
		
		//add new host
		HostTasks.addHost(sahiTasks, hostname, domain, ipadr);

		//verify host was added
		Assert.assertTrue(sahiTasks.link(lowerdn).exists(), "Added host " + fqdn + "  successfully");
	}
	
	
	/*
	 * Add hosts to select dns zone from drop down- for positive tests
	 */
	@Test (groups={"addHostBz751529Tests"}, dataProvider="getAddHostTestObjects")	
	public void testAddHostForceAdd(String testName, String hostname, String ipadr) throws Exception {
		String fqdn = hostname + domain;
		String lowerdn = fqdn.toLowerCase();
		   
		    //verify host doesn't exist
			Assert.assertFalse(sahiTasks.link(lowerdn).exists(), "Verify host " + fqdn + " doesn't already exist");
			
			//add new host
			HostTasks.addHostBz751529(sahiTasks, hostname, domain, ipadr);

			//verify host was added
			Assert.assertTrue(sahiTasks.link(lowerdn).exists(), "Added host " + fqdn + "  successfully");
		}
		
		
	
	
	/*
	 * delete hosts
	 */
	@Test (groups={"deleteHostTests"}, dataProvider="getHostDeleteTestObjects",  dependsOnGroups={"addHostTests", "addHostBz751529Tests"})	
	public void testHostDelete(String testName, String fqdn) throws Exception {
		
		//verify host exists
		Assert.assertTrue(sahiTasks.link(fqdn).exists(), "Verify host " + fqdn + " already exist");
		
		//delete new host
		HostTasks.deleteHost(sahiTasks, fqdn);
		
		//verify host was deleted
		Assert.assertFalse(sahiTasks.link(fqdn).exists(), "Added host " + fqdn + "  successfully");
	}
	
	/*
	 * Add and add another host - for positive tests
	 */
	@Test (groups={"addAndAddAnotherHostTests"}, dataProvider="getAddAndAddAnotherHostTests", dependsOnGroups="deleteHostTests")	
	public void testHostForceAdd(String testName, String hostname1, String hostname2, String hostname3) throws Exception {
		String [] hostnames = {hostname1, hostname2, hostname3};
		for (String hostname : hostnames){
			Assert.assertFalse(sahiTasks.link(hostname + "." + domain).exists(), "Verify host " + hostname + " doesn't already exist");
		}

		//add new hosts
		HostTasks.addAndAddAnotherHost(sahiTasks, hostname1, hostname2, hostname3, domain);
		
		for (String hostname : hostnames){
			//verify host was added
			Assert.assertTrue(sahiTasks.link(hostname+"."+domain).exists(), "Added host " + hostname + "  successfully");
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
			Assert.assertTrue(sahiTasks.link(hostname).exists(), "Verify host " + hostname + " already exist");
		}
		//delete the hosts
		HostTasks.deleteHost(sahiTasks, hostnames);
		
		for (String hostname : hostnames) {
			//verify host was deleted
			Assert.assertFalse(sahiTasks.link(hostname).exists(), "Deleted host " + hostname + "  successfully");
		}
	}
	
	/*
	 * Add and edit hosts - for positive tests
	 */
	@Test (groups={"addAndEditHostTests"}, dataProvider="getAddEditHostTestObjects")	
	public void testHostAddAndEdit(String testName, String hostname, String ipadr, String description, String local, String location, String platform, String os) throws Exception {
		String fqdn = hostname + "." + domain;
		String lowerdn = fqdn.toLowerCase();
		
		//verify host doesn't exist
		Assert.assertFalse(sahiTasks.link(lowerdn).exists(), "Verify host " + hostname + " doesn't already exist");
		
		//add and edit new host
		HostTasks.addHostAndEdit(sahiTasks, domain, hostname, ipadr, description, local, location, platform, os);
		
		//verify host was added
		Assert.assertTrue(sahiTasks.link(lowerdn).exists(), "Added host " + hostname + "  successfully");
		
		//verify all host fields
		HostTasks.verifyHostSettings(sahiTasks, lowerdn, description, local, location, platform, os);
		
		HostTasks.deleteHost(sahiTasks, lowerdn);
	}
	
	/*
	 * Modify host fields
	 */
	@Test (groups={"modifyHostTests"}, dataProvider="getModifyHostTestObjects")	
	public void testModifyHost(String testName, String field, String value) throws Exception {
		String fqdn = testhost + "." + domain;
		Assert.assertTrue(sahiTasks.link(fqdn).exists(), "Host " + testhost + "  exists");
		
		//modify the host
		HostTasks.modifyHost(sahiTasks, fqdn, field, value);
		
		//verify all host field
		HostTasks.verifyHostField(sahiTasks, fqdn, field, value);
		
	}
	
	/*
	 * Set host OTP
	 */
	@Test (groups={"otpHostTests"}, dataProvider="getOTPHostTestObjects")	
	public void testHostOTP(String testName, String otp, boolean set, boolean verifyset, String button) throws Exception {
		String fqdn = testhost + "." + domain;
		Assert.assertTrue(sahiTasks.link(fqdn).exists(), "Host " + fqdn + "  exists");
		
		//modify the host
		HostTasks.modifyHostOTP(sahiTasks, fqdn, otp, set, button);
		
		//verify all host otp settings
		HostTasks.verifyHostOTP(sahiTasks, fqdn, verifyset);
	
	}
	
	/*
	 * Undo Modify 
	 */
	@Test (groups={"undoModifyHostTests"}, dataProvider="getUndoModifyHostTestObjects")	
	public void tesUndoModifyHost(String testName, String newdesc, String newlocal, String newlocation, String newplatform, String newos ) throws Exception {
		String fqdn = undotesthost + "." + domain;
		Assert.assertTrue(sahiTasks.link(fqdn).exists(),  fqdn + "  exists");
		
		//modify the host
		HostTasks.undoModifyHost(sahiTasks, fqdn, newdesc, newlocal, newlocation, newplatform, newos);
		
		//verify all host field
		HostTasks.verifyHostSettings(sahiTasks, fqdn, olddescription, oldlocal, oldlocation, oldplatform, oldos);
	}
	
	/*
	 * Set Managed By test
	 */
	@Test (groups={"setManagedByHostTests"}, dataProvider="getSetManageByHostTests")	
	public void testManagedByHost(String testName, String exists, String button ) throws Exception {
		String managed_fqdn = managed + "." + domain;
		String managedby_fqdn = managedby + "." + domain;
		
		HostTasks.setManagedByHost(sahiTasks, managed_fqdn, managedby_fqdn, button);
		
		// verify managed by host
		HostTasks.verifyManagedByHost(sahiTasks, managed_fqdn, managedby_fqdn, exists);
		
	}
	
	/*
	 * Remove Managed By test
	 */
	@Test (groups={"removeManagedByHostTests"}, dataProvider="getRemoveManageByHostTests",  dependsOnGroups="setManagedByHostTests" )	
	public void testRemoveManagedByHost(String testName, String exists, String button ) throws Exception {
		String managed_fqdn = managed + "." + domain;
		String managedby_fqdn = managedby + "." + domain;
		
		HostTasks.removeManagedByHost(sahiTasks, managed_fqdn, managedby_fqdn, button);
		
		// verify managed by host
		HostTasks.verifyManagedByHost(sahiTasks, managed_fqdn, managedby_fqdn, exists);

	}
	
	/*
	 * Certificate Tests
	 */
	@Test (groups={"hostCertificateTests"}, dataProvider="getHostCertificateTests")	
	public void testHostCertificates(String testName, String reason ) throws Exception {
		String fqdn = testhost + "." + domain;
		//Get CSR for testhost
		String csr = CommonTasks.generateCSR(fqdn);
		
		// add request certificate
		HostTasks.addHostCertificate(sahiTasks, fqdn, csr);
		
		// verify valid certificate
		HostTasks.verifyHostCertificate(sahiTasks, fqdn);
		
		// cancel hold certificate
		HostTasks.revokeHostCertificate(sahiTasks, fqdn, "Certificate Hold", "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, fqdn);
		
		// put certificate on hold
		HostTasks.revokeHostCertificate(sahiTasks, fqdn, "Certificate Hold", "Revoke");
		HostTasks.verifyHostCertificate(sahiTasks, fqdn, "Hold", "Certificate Hold");
		
		// cancel restore certificate
		HostTasks.restoreHostCertificate(sahiTasks, fqdn, "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, fqdn, "Hold", "Certificate Hold");
		
		//restore certificate
		HostTasks.restoreHostCertificate(sahiTasks, fqdn, "Restore");
		HostTasks.verifyHostCertificate(sahiTasks, fqdn);
		
		//cancel revoking certificate
		HostTasks.revokeHostCertificate(sahiTasks, fqdn, reason, "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, fqdn);
		
		//revoke certificate
		HostTasks.revokeHostCertificate(sahiTasks, fqdn, reason, "Revoke");
		HostTasks.verifyHostCertificate(sahiTasks, fqdn, "Revoked", reason);
		
		// cancel request for new certificate
		HostTasks.newHostCertificate(sahiTasks, fqdn, csr, "Cancel");
		HostTasks.verifyHostCertificate(sahiTasks, fqdn, "Revoked", reason);
		
		// request for new certificate
		HostTasks.newHostCertificate(sahiTasks, fqdn, csr, "Issue");
		HostTasks.verifyHostCertificate(sahiTasks, fqdn);
		
	}
	
	/*
	 * Invalid Certificate Request Tests
	 */
	@Test (groups={"hostInvalidCSRTests"}, dataProvider="getInvalidHostCSRTestObjects")	
	public void testHostInvalidCSR(String testName, String csr, String expectedError ) throws Exception {
		
		String fqdn = testhost + "." + domain;
		// add request certificate
		HostTasks.invalidHostCSR(sahiTasks, fqdn, csr, expectedError);
		
	}

	/*
	 * Add host - for negative tests
	 */
	@Test (groups={"invalidhostAddTests"}, dataProvider="getInvalidHostTestObjects")	
	public void testInvalidHostadd(String testName, String hostname, String hostdomain, String ipadr, String expectedError) throws Exception {
		boolean requiredFieldTest=false;
		if (testName.startsWith("missing")|| testName.startsWith("Invalid")) 
			requiredFieldTest=true;
		HostTasks.addInvalidHost(sahiTasks, hostname, hostdomain, ipadr, expectedError, requiredFieldTest);

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
        HostTasks.addHost(sahiTasks, hostname, domain, ipaddr);
       
        // verify host was added
        Assert.assertTrue(sahiTasks.link(fqdn).exists(), "Added host " + fqdn + "  successfully");
       
        // verify host link to dns and dns records
        HostTasks.verifyHostDNSLink(sahiTasks, fqdn, "YES");
        sahiTasks.navigateTo(commonTasks.dnsPage, true);
        DNSTasks.verifyRecord(sahiTasks, domain, hostname, "A", ipaddr, "YES");
        DNSTasks.verifyRecord(sahiTasks, reversezone, ipend, "PTR", fqdn + ".", "YES");
       
        // deleted host
        sahiTasks.navigateTo(commonTasks.hostPage, true);
        HostTasks.deleteHost(sahiTasks, fqdn, updatedns);
       
        sahiTasks.navigateTo(commonTasks.dnsPage, true);
        if( updatedns == "YES"){
            DNSTasks.verifyRecord(sahiTasks, domain, hostname, "A", ipaddr, "NO");
            DNSTasks.verifyRecord(sahiTasks, reversezone, ipend, "PTR", fqdn + ".", "NO");
        }
        else{
            DNSTasks.verifyRecord(sahiTasks, domain, hostname, "A", ipaddr, "YES");
            DNSTasks.verifyRecord(sahiTasks, reversezone, ipend, "PTR", fqdn + ".", "YES");
            DNSTasks.deleteRecord(sahiTasks, domain, hostname);
            DNSTasks.deleteRecord(sahiTasks, reversezone, ipend);
           
        }
       
        sahiTasks.navigateTo(commonTasks.hostPage, true);
    }
	
	
	
	/*
	 * host get keytab tests
	 */
	@Test (groups={"hostGetKeytabTests"}, dataProvider="getHostGetKeytabTestObjects")	
	public void testgetHostKeytab(String testName ) throws Exception {
		String fqdn = testhost + "." + domain;
		String keytabfile = "/tmp/" + testhost + ".keytab";
		// verify host does not have a keytab
		HostTasks.verifyHostKeytab(sahiTasks, fqdn, false);
		
		//  provision a keytab for the service
		CommonTasks.getPrincipalKeytab(testprincipal, keytabfile);
		
		// verify service has a keytab
		HostTasks.verifyHostKeytab(sahiTasks, fqdn, true);
	}
	
	/*
	 * host remove keytab tests
	 */
	@Test (groups={"hostRemoveKeytabTests"}, dataProvider="getHostRemoveKeytabTestObjects", dependsOnGroups="hostGetKeytabTests" )	
	public void testremoveHostKeytab(String testName ) throws Exception {
		String fqdn = testhost + "." + domain;
		//  unprovision keytab
		HostTasks.deleteHostKeytab(sahiTasks, fqdn, "Unprovision");
		// verify service has a keytab
		HostTasks.verifyHostKeytab(sahiTasks, fqdn, false);
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
		
        //										testname				hostname		ipadr
		ll.add(Arrays.asList(new Object[]{ "add_host_lowercase",		"myhost1",		"" } ));
		ll.add(Arrays.asList(new Object[]{ "add_host_uppercase",		"MYHOST2",		"" } ));
		ll.add(Arrays.asList(new Object[]{ "add_host_mixedcase",		"MyHost3", 		"" } ));
		//ll.add(Arrays.asList(new Object[]{ "add_host_bz751529",         "myhost4.",     "" } ));
	
		        
		return ll;	
	}
	
	
	
	/*
	 * Data to be used when adding hosts to select dns zone from drop down- for positive cases
	 */
	@DataProvider(name="getAddHostTestObjects")
	public Object[][] getAddHostFQDNTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddHostTestObjects());
	}
	protected List<List<Object>> createAddHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				hostname		ipadr
		
		ll.add(Arrays.asList(new Object[]{ "add_host_bz751529",         "myhost4.",     "" } ));
	
		        
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
		ll.add(Arrays.asList(new Object[]{ "add_host_bz751529",		    "myhost4."+domain 	} ));
		
		        
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
		
        //										testname			hostname		ipadr		description								local								location						platform	os
		ll.add(Arrays.asList(new Object[]{ "add_and_edit_host",		"myhost1",		"",		 	"MY host descipta098yhf;  jkhrtoryt",	"314 Littleton Road, Westford, MA",	"3rd Floor under Jenny's Desk",	"x86_64",	"Fedora 15" } ));
		        
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
		
        //										testname				hostname1		hostname2		hostname3
		ll.add(Arrays.asList(new Object[]{ "add_and_add_another_host",	"myhost1",	 	"myhost2", 		"myhost3" } ));
		        
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
		
        //										testname					hostname     hostdomain    	ipadr   			expectedError
		ll.add(Arrays.asList(new Object[]{ "add_host_dash",				    "test-", 	  domain,    	"",					"invalid 'hostname': invalid domain-name: only letters, numbers, and - are allowed. - must not be the DNS label character" } ));
		ll.add(Arrays.asList(new Object[]{ "missing_hostname",				"", 	 	 domain,		"",					"Required field"} ));
	    ll.add(Arrays.asList(new Object[]{ "missing_domainname",			"mytest.", 	 "",			"",					"Required field"} ));
		ll.add(Arrays.asList(new Object[]{ "Invalid_ipadr_alpha_chars",		"test",		 domain, 		"null",				"Not a valid IP address"	} ));
		ll.add(Arrays.asList(new Object[]{ "Invalid_ipadr_too_many_octets",	"test",		 domain, 		"10.10.10.10.10",	"Not a valid IP address"	} ));	
		ll.add(Arrays.asList(new Object[]{ "Invalid_ipadr_bad_octects",		"test",		 domain, 		"999.999.999.999",	"Not a valid IP address"	} ));
		ll.add(Arrays.asList(new Object[]{ "Invalid_ipadr_special_chars",   "test",		 domain, 		"~.&.#.^",			"Not a valid IP address"	} ));
		ll.add(Arrays.asList(new Object[]{ "duplicate_hostname",			testhost,	     domain, 		"",					"host with name \""+ testhost + "." + domain + "\" already exists"	} ));
		ll.add(Arrays.asList(new Object[]{ "begining_space_hostname",		" " + "testing",  domain,		"",				"invalid 'hostname': Leading and trailing spaces are not allowed"} ));
		ll.add(Arrays.asList(new Object[]{ "ending_space_hostname",			"testing" + " ",  domain,		"",				"invalid 'hostname': invalid domain-name: only letters, numbers, and - are allowed. - must not be the DNS label character"} ));
		ll.add(Arrays.asList(new Object[]{ "add_host_tilde",	       		"test~", 	     domain,		"",					"invalid 'hostname': invalid domain-name: only letters, numbers, and - are allowed. - must not be the DNS label character"} ));
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
		
        //										testname			field  					value
		ll.add(Arrays.asList(new Object[]{ "modify_description",	"description",			"My new host value - abcdefghijklmnopqrstuvwxyz 1234567890"	} ));
		ll.add(Arrays.asList(new Object[]{ "modify_local",			"local",				"United States - Massachusetts - Westford"	} ));
		ll.add(Arrays.asList(new Object[]{ "modify_location",		"location",				"West Wing - Lab 41 - Rack 143"		} ));	
		ll.add(Arrays.asList(new Object[]{ "modify_platform",		"platform",				"ppc64"	} ));
		ll.add(Arrays.asList(new Object[]{ "modify_os",				"os",					"Red Hat Enterprise Linux 6 Update 1"		} ));
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
		
        //										testname			otp												set			verifyset		button
		ll.add(Arrays.asList(new Object[]{ "cancel_set_otp",		"kjfghaoihetoiharitharighp",					false,  	false,			"Cancel" } ));
		ll.add(Arrays.asList(new Object[]{ "set_OTP_alpha",			"kjfghaoihetoiharitharighp",					false,		true,			"Set OTP" } ));
		ll.add(Arrays.asList(new Object[]{ "set_OTP_numeric",		"20892750975047735451",							true,		true,			"Reset OTP"	} ));
		ll.add(Arrays.asList(new Object[]{ "set_OTP_alphanumeric",	"kjasdoa58gshoty7475p759burtsyrta436756878",	true,		true,			"Reset OTP" } ));	
		ll.add(Arrays.asList(new Object[]{ "set_OTP_special_chars",	"#$%^&()&(^%$*^$+",								true,		true,			"Reset OTP"	} ));
		ll.add(Arrays.asList(new Object[]{ "set_OTP_mixed",			"#kajfa8ga89pajh0b6q<ejt} j&b7q9nbti*",			true,		true,			"Reset OTP"	} ));
		ll.add(Arrays.asList(new Object[]{ "cancel_reset_otp",		"blahblahcancel",								true,		true,			"Cancel"	} ));
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
		
        //										testname		newdesc																newlocal						newlocation								newplatform		newos	
		ll.add(Arrays.asList(new Object[]{ 		"test_undo",	"My new host value $#* - abcdefghijklmnopqrstuvwxyz 1234567890",	"Mountain View, California",	"Third Floor Lab - Row 16 - Rack 122",	"x86_64",		"Red Hat Enterprise Linux 6.0 Client"	} ));
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
		ll.add(Arrays.asList(new Object[]{ "set_managedby_enroll",		"Yes",	"Add" } ));
		        
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
		ll.add(Arrays.asList(new Object[]{ "csr_wrong_host",		wronghostcsr,	"Insufficient access: hostname in subject of request 'host.testrelm' does not match principal hostname '" + testhost + "." + domain + "'" } ));	
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
	
	/*
	 * Data to be used provisioning keytab for host
	 */
	@DataProvider(name="getHostGetKeytabTestObjects")
	public Object[][] getHostGetKeytabTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostGetKeytabTestObjects());
	}
	protected List<List<Object>> createHostGetKeytabTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname					
		ll.add(Arrays.asList(new Object[]{ 	"provision_host_keytab" } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used deleting keytab for service
	 */
	@DataProvider(name="getHostRemoveKeytabTestObjects")
	public Object[][] getHostRemoveKeytabTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHostRemoveKeytabTestObjects());
	}
	protected List<List<Object>> createHostRemoveKeytabTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname					
		ll.add(Arrays.asList(new Object[]{ 	"unprovision_host_keytab" } ));
		
		return ll;	
	}
	
}
