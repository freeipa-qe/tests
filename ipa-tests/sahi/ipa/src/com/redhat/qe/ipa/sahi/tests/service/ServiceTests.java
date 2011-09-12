package com.redhat.qe.ipa.sahi.tests.service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
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
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.ServiceTasks;


public class ServiceTests extends SahiTestScript {
	private static Logger log = Logger.getLogger(ServiceTests.class.getName());
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	private String reversezone = "";
	private String domain = "";
	
	private String mytesthost = "";
	private String realm = "";
	
	private String testservice = "";
	
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
		String ipaddr = ipprefix + "199";
		
		testservice = "SRVC" + "/" + mytesthost + "@" + realm;
		mytesthost = "servicehost" + "." + domain;
		
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		HostTasks.addHost(sahiTasks, "servicehost", domain, ipaddr);
		
		sahiTasks.navigateTo(commonTasks.servicePage, true);
		ServiceTasks.addCustomService(sahiTasks, "SRVC", mytesthost, false);
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		HostTasks.deleteHost(sahiTasks, mytesthost, "YES");
		
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkCurrentPage() {
	    String currentPageNow = sahiTasks.fetch("top.location.href");
		if (!currentPageNow.equals(currentPage) && !currentPageNow.equals(alternateCurrentPage)) {
			CommonTasks.checkError(sahiTasks);
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
		
		String [] defaultservices = { "cifs" + "/" + mytesthost + "@" + realm, "DNS" + "/" + mytesthost + "@" + realm, "ftp" + "/" + mytesthost + "@" + realm, "HTTP" + "/" + mytesthost + "@" + realm, "imap" + "/" + mytesthost + "@" + realm, "ldap" + "/" + mytesthost + "@" + realm, "libvirt" + "/" + mytesthost + "@" + realm, "nfs" + "/" + mytesthost + "@" + realm, "qpidd" + "/" + mytesthost + "@" + realm, "smtp" + "/" + mytesthost + "@" + realm };
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
	@Test (groups={"serviceAddCertificateTests"}, dataProvider="getServiceAddCertificateTestObjects")	
	public void testserviceAddCertificate(String testName, String button, boolean certexists) throws Exception {
		
		//Get CSR for host hosting service
		String csr = CommonTasks.generateCSR(mytesthost);
		
		// add request certificate
		ServiceTasks.addServiceCertificate(sahiTasks, testservice, csr, button);
		
		// verify cancel adding certificate
		ServiceTasks.verifyServiceCertificate(sahiTasks, testservice, certexists);

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
		ll.add(Arrays.asList(new Object[]{ 	"add_service_canel",	"cifs", 	"Cancel"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_cifs_service",		"cifs", 	"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_DNS_service",		"DNS", 		"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_ftp_service",		"ftp", 		"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_HTTP_service",		"HTTP", 	"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_imap_service",		"imap", 	"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_ldap_service",		"ldap", 	"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_libvirt_service",	"libvirt", 	"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_nfs_service",		"nfs", 		"Add"  } ));
		ll.add(Arrays.asList(new Object[]{ 	"add_apidd_service",	"qpidd", 	"Add"  } ));
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
	 * Data to be used when deleting multiple services
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

}
