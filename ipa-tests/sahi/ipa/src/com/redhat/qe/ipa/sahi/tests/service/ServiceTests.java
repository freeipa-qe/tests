package com.redhat.qe.ipa.sahi.tests.service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.ServiceTasks;


public class ServiceTests extends SahiTestScript {
	private static Logger log = Logger.getLogger(ServiceTests.class.getName());
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	private String reversezone = "";
	private String domain = "";
	
	private String mytesthost = "";
	private String mytesthost2 = "";
	private String nodnshost = "";
	private String realm = "";
	private String testservice = "";
	private String testprincipal ="";
	private String csr ="";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {
		sahiTasks.navigateTo(commonTasks.servicePage, true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&service-facet=search" ;
		sahiTasks.setStrictVisibilityCheck(true);
		
		domain = commonTasks.getIpadomain();
		reversezone = commonTasks.getReversezone();
		realm = domain.toUpperCase();
		
		//add host and service
		String [] dcs = reversezone.split("\\.");
		String ipprefix = dcs[2] + "." + dcs[1] + "." + dcs[0] + ".";
		String ipaddr1 = ipprefix + "199";
		String ipaddr2 = ipprefix + "200";
		
		testservice = "libvirt";
		mytesthost = "servicehost1" + "." + domain;
		mytesthost2 = "servicehost2" + "." + domain;
		nodnshost = "nodns" + "." + domain;
		testprincipal = testservice + "/" + mytesthost + "@" + realm;
		
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		HostTasks.addHost(sahiTasks, "servicehost1", domain, ipaddr1);
		HostTasks.addHost(sahiTasks, "servicehost2", domain, ipaddr2);
		HostTasks.addHost(sahiTasks, "nodns", domain, "");
		
		sahiTasks.navigateTo(commonTasks.servicePage, true);
		ServiceTasks.addCustomService(sahiTasks, "SRVC", mytesthost, false);
		
		//Get CSR for host hosting service
		csr = CommonTasks.generateCSR(mytesthost);
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		HostTasks.deleteHost(sahiTasks, mytesthost, "YES");
		HostTasks.deleteHost(sahiTasks, mytesthost2, "YES");
		HostTasks.deleteHost(sahiTasks, nodnshost, "NO");
		
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
	    CommonTasks.checkError(sahiTasks);
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			//CommonTasks.checkError(sahiTasks);
			System.out.println("Not on expected Page....navigating back from : " + currentPageNow);
			sahiTasks.navigateTo(commonTasks.servicePage, true);
		}		
	}
	
	/*
	 * Add services
	 */
	@Test (groups={"serviceAddTests"}, dataProvider="getServiceAddTestObjects")	
	public void testServiceAdd(String testName, String srvtype, String button) throws Exception {
		String servicename = srvtype + "/" + mytesthost + "@" + realm;
		
		//verify service is not already there
		Assert.assertFalse(sahiTasks.link(servicename).exists(), "Verify service " + servicename + " does not already exist.");
		
		// add service
		ServiceTasks.addService(sahiTasks, srvtype, mytesthost, false, button);
		
		//verify service add
		if ( button == "Cancel")
			Assert.assertFalse(sahiTasks.link(servicename).exists(), "Verify service " + servicename + " does not exist when add is canceled.");
		else
			Assert.assertTrue(sahiTasks.link(servicename).exists(), "Verify service " + servicename + " exists.");
	}
	
	/*
	 * Add custom service 
	 */
	@Test (groups={"customServiceAddTests"}, dataProvider="getCustomServiceAddTestObjects")	
	public void testCustomServiceAdd(String testName, String customservice) throws Exception {
		String servicename = customservice + "/" + mytesthost + "@" + realm;
		
		//verify service is not already there
		Assert.assertFalse(sahiTasks.link(servicename).exists(), "Verify service " + servicename + " does not already exist.");
		
		// add service
		ServiceTasks.addCustomService(sahiTasks, customservice, mytesthost, false );
		
		//verify service add
		Assert.assertTrue(sahiTasks.link(servicename).exists(), "Verify service " + servicename + " exists.");
	}
	
	/*
	 * Add custom service 
	 */
	@Test (groups={"forceServiceAddTests"}, dataProvider="getForceServiceAddTestObjects")	
	public void testForceServiceAdd(String testName) throws Exception {
		String servicename = "HTTP/" + nodnshost + "@" + realm;
		
		// add service - force
		ServiceTasks.addCustomService(sahiTasks, "HTTP", nodnshost, true );
		
		//verify service add
		Assert.assertTrue(sahiTasks.link(servicename).exists(), "Verify service " + servicename + " exists.");
		
		// delete the service added
		ServiceTasks.deleteService(sahiTasks, servicename, "Delete");
	}
	/*
	 * delete single service 
	 */
	@Test (groups={"deleteSingleServiceTests"}, dataProvider="getDeleteSingleServiceTestObjects",  dependsOnGroups="customServiceAddTests")	
	public void testDeleteSingleService(String testName, String serviceprinc, String button) throws Exception {
		String servicename = serviceprinc + "/" + mytesthost + "@" + realm;
		
		//verify service exists
		Assert.assertTrue(sahiTasks.link(servicename).exists(), "Verify service " + servicename + "  exist.");
		
		// delete the service
		ServiceTasks.deleteService(sahiTasks, servicename, button);
		
		//verify service delete
		if ( button == "Cancel")
			Assert.assertTrue(sahiTasks.link(servicename).exists(), "Verify service " + servicename + " still exists when delete is canceled.");
		else
			Assert.assertFalse(sahiTasks.link(servicename).exists(), "Verify service " + servicename + " does not exist.");
	}
	
	/*
	 * delete multple service
	 */
	@Test (groups={"deleteMultipleServiceTests"}, dataProvider="getDeleteMultipleServiceTestObjects",  dependsOnGroups="serviceAddTests")	
	public void testDeleteMultipleService(String testName) throws Exception {
		
		String [] defaultservices = { "cifs" + "/" + mytesthost + "@" + realm, "DNS" + "/" + mytesthost + "@" + realm, "ftp" + "/" + mytesthost + "@" + realm, "HTTP" + "/" + mytesthost + "@" + realm, "imap" + "/" + mytesthost + "@" + realm, "ldap" + "/" + mytesthost + "@" + realm, "nfs" + "/" + mytesthost + "@" + realm, "qpidd" + "/" + mytesthost + "@" + realm, "smtp" + "/" + mytesthost + "@" + realm };
		for (String servicename : defaultservices){
			//verify service exists
			Assert.assertTrue(sahiTasks.link(servicename).exists(), "Verify service " + servicename + "  exist.");
		}
		
		// delete the service
		ServiceTasks.deleteService(sahiTasks, defaultservices);
		
		//verify service delete
		for (String servicename : defaultservices){
			Assert.assertFalse(sahiTasks.link(servicename).exists(), "Verify service " + servicename + " does not exist.");
		}
	}
	
	/*
	 * Add Service Certificate Tests
	 */
	@Test (groups={"serviceAddCertificateTests"}, dataProvider="getServiceAddCertificateTestObjects", dependsOnGroups="serviceAddTests")	
	public void testserviceAddCertificate(String testName, String button, boolean certexists) throws Exception {
		
		// add request certificate
		ServiceTasks.addServiceCertificate(sahiTasks, testprincipal, csr, button);
		
		// verify cancel adding certificate
		ServiceTasks.verifyServiceCertificate(sahiTasks, testprincipal, certexists);

	}
	
	/*
	 * Add Service Certificate Tests
	 */
	@Test (groups={"serviceHoldCertificateTests"}, dataProvider="getServiceHoldCertificateTestObjects",  dependsOnGroups="serviceAddCertificateTests")	
	public void testserviceHoldCertificate(String testName, String button ) throws Exception {
		
		//  request certificate
		ServiceTasks.revokeServiceCertificate(sahiTasks, testprincipal, "Certificate Hold", button);
		
		// verify certificate status
		if (button == "Cancel"){
			ServiceTasks.verifyServiceCertificate(sahiTasks, testprincipal, true);
		}
		else {
			ServiceTasks.verifyServiceCertificateStatus(sahiTasks, testprincipal, "Hold", "Certificate Hold");
		}

	}
	
	/*
	 * Restore Service Certificate Tests
	 */
	@Test (groups={"serviceRestoreCertificateTests"}, dataProvider="getServiceRestoreCertificateTestObjects",  dependsOnGroups="serviceHoldCertificateTests")	
	public void testserviceRestoreCertificate(String testName, String button ) throws Exception {
		
		//  request certificate
		ServiceTasks.restoreServiceCertificate(sahiTasks, testprincipal, button);
		
		// verify certificate status
		if (button == "Cancel"){
			ServiceTasks.verifyServiceCertificateStatus(sahiTasks, testprincipal, "Hold", "Certificate Hold");
		}
		else {
			ServiceTasks.verifyServiceCertificate(sahiTasks, testprincipal, true);
		}

	}
	
	/*
	 * Revoke Service Certificate Tests
	 */
	@Test (groups={"serviceRevokeCertificateTests"}, dataProvider="getServiceRevokeCertificateTestObjects",  dependsOnGroups="serviceRestoreCertificateTests")	
	public void testserviceRevokeCertificate(String testName, String button ) throws Exception {
		String reason = "Privilege Withdrawn";
		
		//  request certificate
		ServiceTasks.revokeServiceCertificate(sahiTasks, testprincipal, reason, button);
		
		// verify certificate status
		if (button == "Cancel"){
			ServiceTasks.verifyServiceCertificate(sahiTasks, testprincipal, true);
		}
		else {
			ServiceTasks.verifyServiceCertificateStatus(sahiTasks, testprincipal, "Revoked", reason);
			
		}
	}

		/*
		 * Add managed by host
		 */
		@Test (groups={"serviceAddManagedByHostTests"}, dataProvider="getServiceAddManagedByHostTestObjects")	
		public void testserviceAddManagedByHost(String testName, String button, boolean exists ) throws Exception {
			
			// Add managed by host
			ServiceTasks.addManagedByHost(sahiTasks, testprincipal, mytesthost2, button);
			
			// verify managed by host
			ServiceTasks.verifyManagedByHost(sahiTasks, testprincipal, mytesthost2, exists);

		}
		
		/*
		 * Remove managed by host
		 */
		@Test (groups={"serviceRemoveManagedByHostTests"}, dataProvider="getServiceRemoveManagedByHostTestObjects",  dependsOnGroups={"serviceAddManagedByHostTests", "serviceAddTests"})	
		public void testserviceRemoveManagedByHost(String testName, String button, boolean exists ) throws Exception {
			
			//  remove managed by host
			ServiceTasks.removeManagedByHost(sahiTasks, testprincipal, mytesthost2, button);
			
			// verify managed by host
			ServiceTasks.verifyManagedByHost(sahiTasks, testprincipal, mytesthost2, exists);
		}
		
		/*
		 * Service get keytab tests
		 */
		@Test (groups={"serviceGetKeytabTests"}, dataProvider="getServiceGetKeytabTestObjects")	
		public void testgetServiceKeytab(String testName ) throws Exception {
			String keytabfile = "/tmp/" + mytesthost + ".keytab";
			// verify service does not have a keytab
			ServiceTasks.verifyServiceKeytab(sahiTasks, testprincipal, false);
			
			//  provision a keytab for the service
			CommonTasks.getPrincipalKeytab(testprincipal, keytabfile);
			
			// verify service has a keytab
			ServiceTasks.verifyServiceKeytab(sahiTasks, testprincipal, true);
		}
		
		/*
		 * Service remove keytab tests
		 */
		@Test (groups={"serviceRemoveKeytabTests"}, dataProvider="getServiceRemoveKeytabTestObjects", dependsOnGroups={"serviceGetKeytabTests", "serviceAddTests"} )	
		public void testremoveServiceKeytab(String testName ) throws Exception {
			
			//  unprovision keytab
			ServiceTasks.deleteServiceKeytab(sahiTasks, testprincipal, "Unprovision");
			// verify service has a keytab
			ServiceTasks.verifyServiceKeytab(sahiTasks, testprincipal, false);
		}
		
		/*
		 * Add invalid service tests
		 */
		@Test (groups={"invalidserviceAddTests"}, dataProvider="getInvalidServiceTestObjects")	
		public void testInvalidServiceadd(String testName, String hostname, String servicename, String expectedError) throws Exception {
			boolean requiredFieldTest=false;
			if (testName.contains("missing"))
					requiredFieldTest=true;
			ServiceTasks.addInvalidService(sahiTasks, hostname, servicename, expectedError, requiredFieldTest);

		}
		
		/*
		 *Service Search Tests
		 */
		@Test (groups={"serviceSearchTests"}, dataProvider="getServiceSearchTestObjects")	
		public void testServiceSearch(String testName, String searchString) throws Exception {
			String [] myservices = {"smtp1", "smtp15", "smtp5", "smtp57"};
			String smtp1princ = "smtp1" + "/" + mytesthost + "@" + realm;
			String smtp15princ = "smtp15" + "/" + mytesthost + "@" + realm;
			String smtp5princ = "smtp5" + "/" + mytesthost + "@" + realm;
			String smtp57princ = "smtp57" + "/" + mytesthost + "@" + realm;
			String [] myserviceprincs = {smtp1princ, smtp15princ, smtp5princ, smtp57princ};
			
			if ( searchString == "smtp"){
				for (String myservice : myservices){
					ServiceTasks.addCustomService(sahiTasks, myservice, mytesthost, false);
				}
			}
			
			CommonTasks.search(sahiTasks, searchString);
				
			if (searchString == "smtp"){
				for (String myservprinc : myserviceprincs){
					Assert.assertTrue(sahiTasks.link(myservprinc).exists(), "Searched and found service " + myservprinc + "  successfully.");
				}
			}
			
			if (searchString == "smtp1"){
				Assert.assertTrue(sahiTasks.link(smtp1princ).exists(), "Searched and found service " + smtp1princ + "  successfully.");
				Assert.assertTrue(sahiTasks.link(smtp15princ).exists(), "Searched and found service " + smtp15princ + "  successfully.");
				Assert.assertFalse(sahiTasks.link(smtp5princ).exists(), "Search did not find service " + smtp5princ + ".");
				Assert.assertFalse(sahiTasks.link(smtp57princ).exists(), "Search did not find service " + smtp57princ + ".");
			}
			
			if (searchString == "smtp5"){
				Assert.assertTrue(sahiTasks.link(smtp5princ).exists(), "Searched and found service " + smtp5princ + "  successfully");
				Assert.assertTrue(sahiTasks.link(smtp57princ).exists(), "Searched and found service " + smtp57princ + "  successfully");
				Assert.assertFalse(sahiTasks.link(smtp1princ).exists(), "Search did not find service " + smtp1princ + ".");
				Assert.assertFalse(sahiTasks.link(smtp15princ).exists(), "Search did not find service " + smtp15princ + ".");
			}
			
			CommonTasks.clearSearch(sahiTasks);
			
			if (searchString == "smtp5"){
				ServiceTasks.deleteService(sahiTasks, myserviceprincs);
			}
		}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding services - for positive cases
	 */
	@DataProvider(name="getServiceAddTestObjects")
	public Object[][] getServiceAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createServiceAddTestObjects());
	}
	protected List<List<Object>> createServiceAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname				srvtype    	button   
		ll.add(Arrays.asList(new Object[]{ 	"add_service_cancel",	"cifs", 	"Cancel"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_cifs_service",		"cifs", 	"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_DNS_service",		"DNS", 		"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_ftp_service",		"ftp", 		"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_HTTP_service",		"HTTP", 	"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_imap_service",		"imap", 	"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_ldap_service",		"ldap", 	"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_libvirt_service",	"libvirt", 	"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_nfs_service",		"nfs", 		"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_qpidd_service",	"qpidd", 	"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_smtp_service",		"smtp", 	"Add"  } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding a custom service
	 */
	@DataProvider(name="getCustomServiceAddTestObjects")
	public Object[][] getCustomServiceAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createCustomServiceAddTestObjects());
	}
	protected List<List<Object>> createCustomServiceAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname				customservice
		ll.add(Arrays.asList(new Object[]{ 	"add_custom_service",	"CUSTOM" } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when force adding a service
	 */
	@DataProvider(name="getForceServiceAddTestObjects")
	public Object[][] getForceServiceAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createForceServiceAddTestObjects());
	}
	protected List<List<Object>> createForceServiceAddTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname		
		ll.add(Arrays.asList(new Object[]{ 	"force_add_service" } ));
		
		return ll;	
	}
	
	/*
	 * Data to be deleting single service
	 */
	@DataProvider(name="getDeleteSingleServiceTestObjects")
	public Object[][] getDeleteSingleServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDeleteSingleServiceTestObjects());
	}
	protected List<List<Object>> createDeleteSingleServiceTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname					servicename		button
		ll.add(Arrays.asList(new Object[]{ 	"cancel_delete_service",	"CUSTOM",		"Cancel" } ));
		ll.add(Arrays.asList(new Object[]{ 	"delete_single_service",	"CUSTOM",		"Delete" } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when adding service certificate
	 */
	@DataProvider(name="getServiceAddCertificateTestObjects")
	public Object[][] getServiceAddCertificateTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createServiceAddCertificateTestObjects());
	}
	protected List<List<Object>> createServiceAddCertificateTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname							  button		certexists
		ll.add(Arrays.asList(new Object[]{ 	"cancel_new_certificate_request",	  "Cancel",		false } ));
		ll.add(Arrays.asList(new Object[]{ 	"new_valid_certificate_request",	  "Issue",		true } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used when deleting multiple services
	 */
	@DataProvider(name="getDeleteMultipleServiceTestObjects")
	public Object[][] getDeleteMultipleServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDeleteMultipleServiceTestObjects());
	}
	protected List<List<Object>> createDeleteMultipleServiceTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname				
		ll.add(Arrays.asList(new Object[]{ 	"delete_multiple_service" } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used holding certificate
	 */
	@DataProvider(name="getServiceHoldCertificateTestObjects")
	public Object[][] getServiceHoldCertificateTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createServiceHoldCertificateTestObjects());
	}
	protected List<List<Object>> createServiceHoldCertificateTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname							  button	
		ll.add(Arrays.asList(new Object[]{ 	"cancel_hold_certificate",	  		 "Cancel" } ));
		ll.add(Arrays.asList(new Object[]{ 	"hold_certificate",	  				 "Revoke"   } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used restoring certificate
	 */
	@DataProvider(name="getServiceRestoreCertificateTestObjects")
	public Object[][] getServiceRestoreCertificateTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createServiceRestoreCertificateTestObjects());
	}
	protected List<List<Object>> createServiceRestoreCertificateTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname							  button	
		ll.add(Arrays.asList(new Object[]{ 	"cancel_restore_certificate",	  	  "Cancel" } ));
		ll.add(Arrays.asList(new Object[]{ 	"restore_certificate",	  			  "Restore"   } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used revoking certificate
	 */
	@DataProvider(name="getServiceRevokeCertificateTestObjects")
	public Object[][] getServiceRevokeCertificateTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createServiceRevokeCertificateTestObjects());
	}
	protected List<List<Object>> createServiceRevokeCertificateTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname							  button	
		ll.add(Arrays.asList(new Object[]{ 	"cancel_revoke_certificate",	  	  "Cancel" } ));
		ll.add(Arrays.asList(new Object[]{ 	"revoke_certificate",	  			  "Revoke"   } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used adding manaaged by host
	 */
	@DataProvider(name="getServiceAddManagedByHostTestObjects")
	public Object[][] getServiceAddManagedByHostTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createServiceAddManagedByHostTestObjects());
	}
	protected List<List<Object>> createServiceAddManagedByHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname							  button		exists
		ll.add(Arrays.asList(new Object[]{ 	"cancel_adding_managedby_host",	  	  "Cancel",		 false	} ));
		ll.add(Arrays.asList(new Object[]{ 	"add_managedby_host",	  			  "Add",		 true   } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used removing manaaged by host
	 */
	@DataProvider(name="getServiceRemoveManagedByHostTestObjects")
	public Object[][] getServiceRemoveManagedByHostTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createServiceRemoveManagedByHostTestObjects());
	}
	protected List<List<Object>> createServiceRemoveManagedByHostTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname							  button		exists
		ll.add(Arrays.asList(new Object[]{ 	"cancel_removing_managedby_host",	  "Cancel",		 true	} ));
		ll.add(Arrays.asList(new Object[]{ 	"remove_managedby_host",	  		  "Delete",		 false   } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used provisioning keytab for service
	 */
	@DataProvider(name="getServiceGetKeytabTestObjects")
	public Object[][] getServiceGetKeytabTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createServiceGetKeytabTestObjects());
	}
	protected List<List<Object>> createServiceGetKeytabTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname					
		ll.add(Arrays.asList(new Object[]{ 	"provision_service_keytab" } ));
		//TODO :: Add when bug is fixed - https://bugzilla.redhat.com/show_bug.cgi?id=818665
		//ll.add(Arrays.asList(new Object[]{ 	"cancel_provision_service_keytab" } ));
		
		return ll;	
	}
	
	/*
	 * Data to be used deleting keytab for service
	 */
	@DataProvider(name="getServiceRemoveKeytabTestObjects")
	public Object[][] getServiceRemoveKeytabTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createServiceRemoveKeytabTestObjects());
	}
	protected List<List<Object>> createServiceRemoveKeytabTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testname					
		ll.add(Arrays.asList(new Object[]{ 	"unprovision_service_keytab" } ));
		//TODO :: Add when bug is fixed - https://bugzilla.redhat.com/show_bug.cgi?id=818665
		//ll.add(Arrays.asList(new Object[]{ 	"cancel_unprovision_service_keytab" } ));
		return ll;	
	}
	
	/*
	 * Data to be used when adding services - for negative cases
	 */
	 @DataProvider(name="getInvalidServiceTestObjects")
	public Object[][] getInvalidServiceTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidServiceTestObjects());
	}
	protected List<List<Object>> createInvalidServiceTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					hostname     	servicename    expectedError
		ll.add(Arrays.asList(new Object[]{ "add_service_missing_hostname",	"", 	 		 "HTTP",			"Required field"} ));
		ll.add(Arrays.asList(new Object[]{ "add_service_no_DNS_for host",	nodnshost, 		 "JUNK",			"Host does not have corresponding DNS A record"} ));
		ll.add(Arrays.asList(new Object[]{ "add_service_missing_service_name",	mytesthost,		 		"",				"Required field"	} ));

		return ll;	
	}
	
	/*
	 * Data to be used when searching for services
	 */
	@DataProvider(name="getServiceSearchTestObjects")
	public Object[][] getServiceSearchTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createServiceSearchTestObjects());
	}
	protected List<List<Object>> createServiceSearchTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname			searchString
		ll.add(Arrays.asList(new Object[]{ "search_service_test1",	"smtp" } ));
		ll.add(Arrays.asList(new Object[]{ "search_service_test2",	"smtp1" } ));
		ll.add(Arrays.asList(new Object[]{ "search_service_test1",	"smtp5" } ));

		return ll;	
	}

}
