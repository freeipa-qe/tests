package com.redhat.qe.ipa.sahi.tests.dns;

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
import com.redhat.qe.ipa.sahi.tasks.DNSTasks;

public class DNSTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(DNSTests.class.getName());
	public static SahiTasks sahiTasks = null;	
	public static String dnsPage = "/ipa/ui/#dns=dnszone&identity=dns&navigation=identity"; 
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="firefoxSetup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		sahiTasks.navigateTo(System.getProperty("ipa.server.url")+dnsPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
	}
	
	/*
	 * Add & Delete DNS zone - positive tests
	 */
	@Test (groups={"baseTest"}, dataProvider="getDNSObjects")	
	public void dnsBaseTest(String testName, String zoneName, String authoritativeNameserver, String rootEmail) throws Exception {

		if (DNSTasks.addDNSzone(sahiTasks, zoneName, authoritativeNameserver, rootEmail)){
			DNSTasks.delDNSzone(sahiTasks, zoneName, authoritativeNameserver, rootEmail);
		}else{
			System.out.println("create new DNS zone failed");
		}
		/* not ready
		if (DNSTasks.addDNSReversezone(sahiTasks, zone, name, type, data)){
			DNSTasks.delDNSReversezone(sahiTasks, zone, name, type, data);
		}else{
			System.out.println("create new DNS Reverse zone failed");
		}
		*/
	}//dnsAcceptanceTest
	
	/*
	 * Modify dns zone record fields
	 */
	@Test (groups={"DNSZoneSettingsModificationTest"}, dataProvider="getDNSObjects", dependsOnGroups="baseTest")	
	public void dnsZoneSettingsTest(String testName, String zoneName) throws Exception {

		DNSTasks.zoneSettingsModification(sahiTasks, zoneName);
		 
	}//dnsZoneSettingsTest
	
	/*
	 * Modify dns zone settings fields
	 */
	@Test (groups={"DNSZoneRecordsTest"}, dataProvider="getDNSObjects", dependsOnGroups="baseTest")	
	public void dnsZoneRecordsTest(String testName, String zoneName) throws Exception {

		DNSTasks.zoneRecordsModification(sahiTasks, zoneName);
		 
	}//dnsZoneRecordsTest
	
	/*
	 * Modify dns reverse zone record fields
	 */
	@Test (groups={"DNSReverseZoneRecordsModificationTest"}, dataProvider="getDNSObjects", dependsOnGroups="baseTest")	
	public void dnsReverseZoneRecordsTest(String testName, String reverseZoneName) throws Exception {

		DNSTasks.reverseZoneRecordsModification(sahiTasks, reverseZoneName);
		 
	}//dnsReverseZoneRecordsTest
	
	/*
	 * Modify dns reverse zone settings fields
	 */
	@Test (groups={"DNSReverseZoneSettingsModificaionTest"}, dataProvider="getDNSObjects", dependsOnGroups="baseTest")	
	public void dnsReverseZoneSettingsTest(String testName, String reverseZoneName) throws Exception {

		DNSTasks.reverseZoneSettingsModification(sahiTasks, reverseZoneName);
		 
	}//dnsReverseZoneSettingsTest
	
	/*******************************************************
	 ************      DATA PROVIDERS     ***********
	 *******************************************************/

	/*
	 * Data to be used when adding hosts - for positive cases
	 */
	@DataProvider(name="getDNSObjects")
	public Object[][] getDNSObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSObjects());
	}
	protected List<List<Object>> createDNSObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //	 testName,  zoneName,  authoritativeNameserver,  rootEmail				
		ll.add(Arrays.asList(new Object[]{"dns zone test", "sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com"} )); 
		        
		return ll;	
	}//createDNSObject
	
	@DataProvider(name="getZoneObjects")
	public Object[][] getZoneObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSObjects());
	}
	protected List<List<Object>> createZoneObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //	 testName,  zoneName				
		ll.add(Arrays.asList(new Object[]{ "adddns","sahi_zone_001"} )); 
		        
		return ll;	
	}//createDNSObject
	
}//class DNSTest
