package com.redhat.qe.ipa.sahi.tests.dns;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.DNSTasks;
import com.redhat.qe.auto.testng.*;

public class DNSTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(DNSTests.class.getName());
	
	public static String dnszone= "sahi_dns_testzone_001";
	
	public static String reversezone= ""; 
	public static String dummyHost="" ; 
	
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		
		sahiTasks.navigateTo(commonTasks.dnsPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		
		//TODO: nkrishnan: yi...is this right?
		reversezone= commonTasks.getReversezone();
		dummyHost= "dummyhost." + CommonTasks.ipadomain;
			
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		String currentURL = sahiTasks.fetch("top.location.href");
		//TODO: yi: check for the alternateDNSpage url as well
		if (!currentURL.equals(commonTasks.dnsPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+ commonTasks.dnsPage +")");
			sahiTasks.navigateTo(commonTasks.dnsPage, true);
		}
	}//checkURL
	
	/*
	 * Add & Delete DNS zone - positive tests
	 */
	@Test (groups={"dnsZoneBaseTest"}, dataProvider="getDNSZoneObjects")	
	public void dnsZoneBaseTest(String testName, String zoneName, String authoritativeNameserver, String rootEmail) throws Exception {
		//dns zone create & delete
		DNSTasks.addDNSzone(sahiTasks, zoneName, authoritativeNameserver, rootEmail); 
		DNSTasks.delDNSzone(sahiTasks, zoneName);
	}
	
	/*
	 * Add DNS zone - positive tests
	 */
	@Test (groups={"addDNSZoneTest"}, dataProvider="getDNSZoneObjects")	
	public void addDNSZoneTest(String testName, String zoneName, String authoritativeNameserver, String rootEmail) throws Exception {
		//dns zone create 
		DNSTasks.addDNSzone(sahiTasks, zoneName, authoritativeNameserver, rootEmail); 
	}//addDNSZoneTest
	
	/*
	 * Add DNS zone - positive tests
	 */
	@Test (groups={"delDNSZoneTest"}, dataProvider="getDNSZoneObjects")	
	public void delDNSZoneTest(String testName, String zoneName, String authoritativeNameserver, String rootEmail) throws Exception {
		//dns zone delete 
		DNSTasks.delDNSzone(sahiTasks, zoneName); 
	}//delDNSZoneTest

	/*
	 * Modify dns zone setting fields
	 */
	@Test (groups={"dnsZoneSettingsTest"}, dataProvider="getDNSSettings")	
	public void dnsZoneSettingsTest(String testName, String zoneName, String fieldName, String fieldValue) throws Exception {
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneSettingsModification(sahiTasks, zoneName, fieldName, fieldValue);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click();
		if (sahiTasks.span("Dirty").exists()){
			log.info("Dirty dialog detected, will click reset to make it continue");
			// some failed changes might occurred, need some protection here
			sahiTasks.button("Reset").click(); //Reset will bring user back to DNS zone list
		}else{
			log.info("no 'Dirty' dialog detected, test continue well");
		} 
	}//dnsZoneSettingsTest
	
	/*
	 * Test for add one dns zone record
	 */
	@Test (groups={"dnsZoneRecordsTest_add"}, dataProvider="getDNSRecords", dependsOnGroups="addDNSZoneTest")	
	public void dnsZoneRecordsTest_add(String testName, String zoneName,String reverseZoneName, String authoritativeNameserver, String rootEmail,
									String record_name, String record_data, String record_type) throws Exception {
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneRecords_add(sahiTasks,record_name,record_data,record_type); 
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click();  
	}//dnsZoneRecordsTest
	
	/*
	 * Modify dns zone record fields
	 */
	@Test (groups={"dnsZoneRecordsTest_addandaddanother"}, dataProvider="getDNSRecords_addanother", dependsOnGroups="addDNSZoneTest")	
	public void dnsZoneRecordsTest_addandaddanother(String testName, String zoneName,String reverseZoneName, String authoritativeNameserver, String rootEmail,
									String first_record_name, String first_record_data, String first_record_type,
									String second_record_name, String second_record_data, String second_record_type) throws Exception {
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneRecords_addandaddanother(sahiTasks,first_record_name,first_record_data,first_record_type,
														second_record_name, second_record_data, second_record_type); 
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click();  
	}//dnsZoneRecordsTest_addandaddanother
	
	/*
	 * Modify dns zone record fields : and one new record and switch to editing mode immediately 
	 */
	@Test (groups={"dnsZoneRecordsTest_addandaddedit"}, dataProvider="getDNSRecords", dependsOnGroups="addDNSZoneTest")	
	public void dnsZoneRecordsTest_addandaddedit(String testName, String zoneName,String reverseZoneName, String authoritativeNameserver, String rootEmail,
									String record_name, String record_data, String record_type) throws Exception { 
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneRecords_addandedit(sahiTasks,record_name,record_data,record_type); 
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click();  
	}//dnsZoneRecordsTest_addandaddedit
	
	/*
	 * Modify dns zone record fields : and one new record and switch to editing mode immediately 
	 */
	@Test (groups={"dnsZoneRecordsTest_add_then_cancel"}, dataProvider="getDNSRecords", dependsOnGroups="addDNSZoneTest")	
	public void dnsZoneRecordsTest_add_then_cancel(String testName, String zoneName,String reverseZoneName, String authoritativeNameserver, String rootEmail,
									String record_name, String record_data, String record_type) throws Exception {
		
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneRecords_add_then_cancel(sahiTasks,record_name,record_data,record_type); 
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click();  
	}//dnsZoneRecordsTest_add_then_cancel
	
	
	/////////////////////////////////////////////////////////////////////////
	//                                                                     //
	// 							reverse zone test                          //
	//                                                                     //
	/////////////////////////////////////////////////////////////////////////
	
	/*
	 * Add & Delete DNS reverse zone - positive tests
	 */
	@Test (groups={"dnsReverseZoneBaseTest"}, dataProvider="getReverseDNSZoneObjects")	
	public void reverseDNSZoneBaseTest(String testName, String zoneIP, String reverseZoneName, String authoritativeNameserver, String rootEmail) throws Exception {

		// dns reverse zone create & delete
		DNSTasks.addDNSReversezone(sahiTasks, zoneIP, authoritativeNameserver, rootEmail);
		Assert.assertTrue(sahiTasks.link(reverseZoneName).exists(),"assert new zone in the zone list");
		DNSTasks.delDNSReversezone(sahiTasks, reverseZoneName);
		Assert.assertFalse(sahiTasks.link(reverseZoneName).exists(),"assert new zone not in the zone list");
	}//reverseDNSZoneBaseTest
	
	/*
	 * Add  DNS reverse zone - positive tests
	 */
	@Test (groups={"addReverseDNSZone"}, dataProvider="getReverseDNSZoneObjects")	
	public void addReverseDNSZone(String testName, String zoneIP, String reverseZoneName, String authoritativeNameserver, String rootEmail) throws Exception {
		// dns reverse zone create & delete
		DNSTasks.addDNSReversezone(sahiTasks, zoneIP, authoritativeNameserver, rootEmail);
		Assert.assertTrue(sahiTasks.link(reverseZoneName).exists(),"assert new zone in the zone list");
	}//reverseDNSZoneBaseTest
	
	/*
	 * Delete DNS reverse zone - positive tests
	 */
	@Test (groups={"deleteReverseDNSZone"}, dataProvider="getReverseDNSZoneObjects")	
	public void deleteReverseDNSZone(String testName, String zoneIP, String reverseZoneName, String authoritativeNameserver, String rootEmail) throws Exception {
 		DNSTasks.delDNSReversezone(sahiTasks, reverseZoneName);
		Assert.assertFalse(sahiTasks.link(reverseZoneName).exists(),"assert new zone not in the zone list");
	}//deleteReverseDNSZone
	
	
	/*
	 * Modify reverse dns zone record fields
	 */ 	
	@Test (groups={"reverseDNSZoneRecordsTest_add"}, dataProvider="getDNSRecords", dependsOnGroups="addReverseDNSZone")	
	public void reverseDNSZoneRecordsTest_add(	String testName, String zoneName,String reverseZoneName, 
											String authoritativeNameserver, String rootEmail,
											String record_name, String record_data, String record_type) throws Exception {
 
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(reverseZoneName).click();
		// performing the test
		DNSTasks.zoneRecords_add(sahiTasks, record_name,record_data,record_type);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click();
	}//reverseDNSZoneRecordsTest_add
	
	/*
	 * Modify reverse dns zone record fields : add one record and then add another record immediately
	 */ 	
	@Test (groups={"reverseDNSZoneRecordsTest_addandaddanother"}, dataProvider="getDNSRecords", dependsOnGroups="addReverseDNSZone")	
	public void reverseDNSZoneRecordsTest_addandaddanother(	String testName, String zoneName,String reverseZoneName, 
											String authoritativeNameserver, String rootEmail,
											String first_record_name,  String first_record_data,  String first_record_type,
											String second_record_name, String second_record_data, String second_record_type
											) throws Exception {
 
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(reverseZoneName).click();
		// performing the test
		DNSTasks.zoneRecords_addandaddanother(sahiTasks, first_record_name, first_record_data, first_record_type,
														 second_record_name,second_record_data,second_record_type);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click();
	}//reverseDNSZoneRecordsTest_addandaddanother
	
	/*
	 * Modify reverse dns zone record fields : add one record then get into editing mode immediately 
	 */ 	
	@Test (groups={"reverseDNSZoneRecordsTest_addandedit"}, dataProvider="getDNSRecords", dependsOnGroups="addReverseDNSZone")	
	public void reverseDNSZoneRecordsTest_addandedit(	String testName, String zoneName,String reverseZoneName, 
											String authoritativeNameserver, String rootEmail,
											String record_name, String record_data, String record_type) throws Exception {
 
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(reverseZoneName).click();
		// performing the test
		DNSTasks.zoneRecords_addandedit(sahiTasks, record_name,record_data,record_type);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click();
	}//reverseDNSZoneRecordsTest_addandedit
	
	
	/*
	 * Modify reverse dns zone record fields: add and then cancel
	 */ 	
	@Test (groups={"reverseDNSZoneRecordsTest_add_then_cancel"}, dataProvider="getDNSRecords", dependsOnGroups="addReverseDNSZone")	
	public void reverseDNSZoneRecordsTest_add_then_cancel(	String testName, String zoneName,String reverseZoneName, 
											String authoritativeNameserver, String rootEmail,
											String record_name, String record_data, String record_type) throws Exception {
 
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(reverseZoneName).click();
		// performing the test
		DNSTasks.zoneRecords_add_then_cancel(sahiTasks, record_name,record_data,record_type);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click();
	}//reverseDNSZoneRecordsTest_add_then_cancel
	
	/*
	 * Modify dns reverse zone settings fields
	 */
	@Test (groups={"reverseDNSZoneSettingsTest"}, dataProvider="getDNSSettings")	
	public void reverseDNSZoneSettingsTest(String testName, String zoneName, String reverseZoneName, String fieldName, String fieldValue) throws Exception {
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(reverseZoneName).click();
		// performing the test
		DNSTasks.zoneSettingsModification(sahiTasks, reverseZoneName, fieldName, fieldValue);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click();
		if (sahiTasks.span("Dirty").exists()){
			log.info("Dirty dialog detected, will click reset to make it continue");
			// some failed changes might occurred, need some protection here
			sahiTasks.button("Reset").click(); //Reset will bring user back to DNS zone list
		}else{
			log.info("no 'Dirty' dialog detected, test continue well");
		} 
	}//reverseDNSZoneSettingsTest
	
	
	/*******************************************************
	 ************      DATA PROVIDERS     ***********
	 *******************************************************/

	/*
	 * Data to be used when adding hosts - for positive cases
	 */
	@DataProvider(name="getDNSZoneObjects")
	public Object[][] getDNSZoneObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSZoneObjects());
	}
	protected List<List<Object>> createDNSZoneObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		ll.add(Arrays.asList(new Object[]{
				// testName,  zoneName,  authoritativeNameserver,  rootEmail	
				"dns zone test", DNSTests.dnszone,DNSTests.dummyHost,"root." + DNSTests.dummyHost} ));  
		return ll;	
	}//Data provider: getDNSZoneObjects
	
	@DataProvider(name="getDNSSettings")
	public Object[][] getDNSSettings(){
		return TestNGUtils.convertListOfListsTo2dArray(createDNSSettings());
	}
	protected List<List<Object>> createDNSSettings(){
		List<List<Object>> ll = new ArrayList<List<Object>>();
		// testName, zoneName, authoritativeNameserver, rootEmail,record_name, record_data, record_type
		ll.add(Arrays.asList(new Object[]{"dns settings test: soa name",DNSTests.dnszone,DNSTests.reversezone,
				"idnssoamname","modified.dhcp-121.sjc.redhat.com"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings test: soa r name ",DNSTests.dnszone,DNSTests.reversezone,
				"idnssoarname","email.dhcp-121.sjc.redhat.com"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: soa serial",DNSTests.dnszone,DNSTests.reversezone,
				"idnssoaserial","2147483646"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa refresh time",DNSTests.dnszone,DNSTests.reversezone,
				"idnssoarefresh","2400"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa retry time",DNSTests.dnszone,DNSTests.reversezone,
				"idnssoaretry","600"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa expire time",DNSTests.dnszone,DNSTests.reversezone,
				"idnssoaexpire","243544645"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa minimum time",DNSTests.dnszone,DNSTests.reversezone,
				"idnssoaminimum","2400"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: ttl: time to live",DNSTests.dnszone,DNSTests.reversezone,
				"dnsttl","1323324324"}));
		
		// I should have negative data for class here
		ll.add(Arrays.asList(new Object[]{"dns settings: class",DNSTests.dnszone,DNSTests.reversezone,
				"dnsclass","IN"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class",DNSTests.dnszone,DNSTests.reversezone,
				"dnsclass","CS"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class",DNSTests.dnszone,DNSTests.reversezone,
				"dnsclass","CH"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class",DNSTests.dnszone,DNSTests.reversezone,
				"dnsclass","HS"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: allow dynamic update",DNSTests.dnszone,
				"idnsallowdynupdate","TRUE"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: update policy",DNSTests.dnszone,
				"idnsupdatepolicy","grant SJC.REDHAT.COM krb5-self * AAAA; grant SJC.REDHAT.COM krb5-self * A;"}));
		return ll;
	}//createDNSSettings
	
	@DataProvider(name="getDNSRecords")
	public Object[][] getDNSRecords() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSRecords());
	}
	protected List<List<Object>> createDNSRecords() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		// testName, zoneName, authoritativeNameserver, rootEmail,record_name, record_data, record_type
		ll.add(Arrays.asList(new Object[]{"dns record A test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"a_recordtest","10.0.0.2","A"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record A6 test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"a6_recordtest","48 0::0 subscriber-bar.ip6.isp2.baz.","A6"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AFSDB test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"afsdb_recordtest",DNSTests.dummyHost,"AFSDB"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record APL test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"apl_recordtest","1:224.0.0.0","APL"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record CERT test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"cert_recordtest","PGP FDASFDSAFDAfdafdafdsaWfdasfdasfff4324535435wefdsgdft43dgdf==","CERT"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record CNAME test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"cname_recordtest","also-dhcp-118.sjc.redhat.com","CNAME"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DHCID test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"dhcid_recordtest","AAIBY2/AuCccgoJbsaxcQc9TUapptP69lOjxfNuVAA2kjEA=","DHCID"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DLV test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"dlv_recordtest","30CC4B8F36687D3C2B7FD64448C167295875DE5486BBCCE4E36CDA52","DLV"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DNAME test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"dname_recordtest","bar.dhcp-121.sjc.redhat.com","DNAME"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DNSKEY test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"dnskey_recordtest","AQPSKmynfzW4kyBv015MUG2DeIQ3Cbl+BBZH4b/0PY1kxkmvHjcZc8nokfzj31GajIQKY+5CptLr3buXA10hWqTkF7H6RfoRqXQeogmMHfpftf6zMv1LyBUgia7za6ZEzOJBOztyvhjL742iU/TpPSEDhm2SNKLijfUppn1UaNvv4w==","DNSKEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DS test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"ds_recordtest","60485 5 1 ( 2BB183AF5F22588179A53B0A98631FAD1A292118 )","DS"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record HIP test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"hip_recordtest","2 200100107B1A74DF365639CC39F1D578AwEAAbdxyhNuSutc5EMzxTs9LBPCIkOFH8cIvM4p9+LrV4e19WzK00+CI6zBCQTdtWsuxKbWIy87UOoJTwkUs7lBu+Upr1gsNrut79ryra+bSRGQb1slImA8YVJyuIDsj7kwzG7jnERNqnWxZ48AWkskmdHaVDP4BcelrTI3rMXdXF5D","HIP"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record IPSECKEY test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"ipseckey_recordtest","IPSECKEY ( 10 1 2 192.0.2.38 AQNRU3mG7TVTO2BkR47usntb102uFJtugbo6BSGvgqt4AQ== )","IPSECKEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record KEY test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"key_recordtest","AIYADP8d3zYNyQwW2EM4wXVFdslEJcUx/fxkfBeH1El4ixPFhpfHFElxbvKoWmvjDTCmfiYy2X+8XpFjwICHc398kzWsTMKlxovpz2FnCTM=","KEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record KX test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"kx_recordtest","2345 sjc.redhat.com","KX"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record LOC test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"loc_recordtest","42 21 54 N 71 06 18 W -24m 30m","LOC"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record MX test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"mx_recordtest","MaileXchangeTest","MX"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NAPTR test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"naptr_recordtest","urn:cid:.","NAPTR"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NS test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"ns_recordtest",DNSTests.dummyHost,"NS"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"nsec_recordtest","host.example.com. (A MX RRSIG NSEC TYPE1234 )","NSEC"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC3 test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"nsec3_recordtest","1 1 12 aabbccdd (35mthgpgcu1qg68fab165klnsnk3dpvl MX RRSIG )","NSEC3"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC3PARAM test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"nsec3param_recordtest","1 0 12 aabbccdd","NSEC3PARAM"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record PTR test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"ptr_recordtest","SJS.REDHAT.COM.","PTR"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record RRSIG test", 
				DNSTests.dnszone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"rrsig_recordtest","HINFO 7 2 3600 20150420235959 20051021000000 (40430 example.  KimG+rDd+7VA1zRsu0ITNAQUTRlpnsmqWrihFRnU+bRa93v2e5oFNFYCs3Rqgv62K93N7AhW6Jfqj/8NzWjvKg== )","RRSIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record RP test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"rp_recordtest","owner.dhcp-121.sjc.redhat.com","RP"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SIG test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"sig_recordtest","","SIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SPF test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"spf_recordtest","v=spf1 +mx a:colo.example.com/28 -all","SPF"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SRV test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"srv_recordtest","1 0 9 server.example.com.","SRV"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SSHFP test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"sshfp_recordtest","2 1 123456789abcdef67890123456789abcdef67890","SSHFP"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record TA test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"ta_recordtest"," 60485 5 1 ( 2BB183AF5F22588179A53B0A98631FAD1A292118 )","TA"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record TKEY test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"tkey_recordtest","","TKEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record TSIG test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"tsig_recordtest","","TSIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record TXT test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"txt_recordtest","MOE     MB      A.ISI.EDU.","TXT"})); 
		
		return ll;	
	}//Data provider: getDNSRecords
	
	@DataProvider(name="getDNSRecords_addanother")
	public Object[][] getDNSRecords_addanother() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSRecords_addanother());
	}
	protected List<List<Object>> createDNSRecords_addanother() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		// testName, zoneName, authoritativeNameserver, rootEmail,record_name, record_data, record_type
		ll.add(Arrays.asList(new Object[]{"dns record A test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"a_recordtest","10.0.0.2","A" ,
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record A6 test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"a6_recordtest","48 0::0 subscriber-bar.ip6.isp2.baz.","A6",
				"afsdb_recordtest",DNSTests.dummyHost,"AFSDB"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record APL test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"apl_recordtest","1:224.0.0.0","APL"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record CERT test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"cert_recordtest","PGP FDASFDSAFDAfdafdafdsaWfdasfdasfff4324535435wefdsgdft43dgdf==","CERT",
				"cname_recordtest","also-dhcp-118.sjc.redhat.com","CNAME"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DHCID test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"dhcid_recordtest","AAIBY2/AuCccgoJbsaxcQc9TUapptP69lOjxfNuVAA2kjEA=","DHCID"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DLV test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"dlv_recordtest","30CC4B8F36687D3C2B7FD64448C167295875DE5486BBCCE4E36CDA52","DLV",
				"dname_recordtest","bar.dhcp-121.sjc.redhat.com","DNAME"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DNSKEY test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"dnskey_recordtest","AQPSKmynfzW4kyBv015MUG2DeIQ3Cbl+BBZH4b/0PY1kxkmvHjcZc8nokfzj31GajIQKY+5CptLr3buXA10hWqTkF7H6RfoRqXQeogmMHfpftf6zMv1LyBUgia7za6ZEzOJBOztyvhjL742iU/TpPSEDhm2SNKLijfUppn1UaNvv4w==","DNSKEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DS test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"ds_recordtest","60485 5 1 ( 2BB183AF5F22588179A53B0A98631FAD1A292118 )","DS",
				"hip_recordtest","2 200100107B1A74DF365639CC39F1D578AwEAAbdxyhNuSutc5EMzxTs9LBPCIkOFH8cIvM4p9+LrV4e19WzK00+CI6zBCQTdtWsuxKbWIy87UOoJTwkUs7lBu+Upr1gsNrut79ryra+bSRGQb1slImA8YVJyuIDsj7kwzG7jnERNqnWxZ48AWkskmdHaVDP4BcelrTI3rMXdXF5D","HIP"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record IPSECKEY test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"ipseckey_recordtest","IPSECKEY ( 10 1 2 192.0.2.38 AQNRU3mG7TVTO2BkR47usntb102uFJtugbo6BSGvgqt4AQ== )","IPSECKEY",
				"key_recordtest","AIYADP8d3zYNyQwW2EM4wXVFdslEJcUx/fxkfBeH1El4ixPFhpfHFElxbvKoWmvjDTCmfiYy2X+8XpFjwICHc398kzWsTMKlxovpz2FnCTM=","KEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record KX test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"kx_recordtest","2345 sjc.redhat.com","KX",
				"loc_recordtest","42 21 54 N 71 06 18 W -24m 30m","LOC"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record MX test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"mx_recordtest","MaileXchangeTest","MX"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NAPTR test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"naptr_recordtest","urn:cid:.","NAPTR",
				"ns_recordtest",DNSTests.dummyHost,"NS"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"nsec_recordtest","host.example.com. (A MX RRSIG NSEC TYPE1234 )","NSEC"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC3 test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"nsec3_recordtest","1 1 12 aabbccdd (35mthgpgcu1qg68fab165klnsnk3dpvl MX RRSIG )","NSEC3",
				"nsec3param_recordtest","1 0 12 aabbccdd","NSEC3PARAM"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record PTR test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"ptr_recordtest","SJS.REDHAT.COM.","PTR",
				"rrsig_recordtest","HINFO 7 2 3600 20150420235959 20051021000000 (40430 example.  KimG+rDd+7VA1zRsu0ITNAQUTRlpnsmqWrihFRnU+bRa93v2e5oFNFYCs3Rqgv62K93N7AhW6Jfqj/8NzWjvKg== )","RRSIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record RP test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"rp_recordtest","owner.dhcp-121.sjc.redhat.com","RP",
				"sig_recordtest","","SIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SPF test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"spf_recordtest","v=spf1 +mx a:colo.example.com/28 -all","SPF",
				"srv_recordtest","1 0 9 server.example.com.","SRV"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SSHFP test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"sshfp_recordtest","2 1 123456789abcdef67890123456789abcdef67890","SSHFP",
				"ta_recordtest"," 60485 5 1 ( 2BB183AF5F22588179A53B0A98631FAD1A292118 )","TA"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record TKEY test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"tkey_recordtest","tkeyvalue","TKEY",
				"tsig_recordtest","tsigvalue","TSIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record TXT test", 
				DNSTests.dnszone,DNSTests.reversezone,DNSTests.dummyHost,"root." + DNSTests.dummyHost, 
				"tkey_recordtest","tkeyvalue","TKEY",
				"txt_recordtest","MOE     MB      A.ISI.EDU.","TXT"})); 
		
		return ll;	
	}//Data provider: getDNSRecords
	
	
	/*
	 * Data to be used when adding hosts - for positive cases
	 */
	@DataProvider(name="getReverseDNSZoneObjects")
	public Object[][] getReverseDNSZoneObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createReverseDNSZoneObjects());
	}
	protected List<List<Object>> createReverseDNSZoneObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
		ll.add(Arrays.asList(new Object[]{
				// testName,  zoneIP,  reverseZoneName,  authoritativeNameserver,  rootEmail	
				"dns reverse zone test", "10.0.0.1",DNSTests.reversezone ,DNSTests.dummyHost,"root." + DNSTests.dummyHost} )); 
		return ll;	
	}//Data provider: getReverseDNSZoneObjects 
	
}//class DNSTest
