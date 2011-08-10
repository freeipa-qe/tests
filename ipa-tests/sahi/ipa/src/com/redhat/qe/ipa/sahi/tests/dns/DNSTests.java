package com.redhat.qe.ipa.sahi.tests.dns;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.DNSTasks;
import com.redhat.qe.auto.testng.*;

public class DNSTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(DNSTests.class.getName());
	public static SahiTasks sahiTasks = null;	
	public static String dnsPage = "/ipa/ui/#dns=dnszone&identity=dns&navigation=identity"; 
	public static String url = System.getProperty("ipa.server.url")+dnsPage;
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();
		sahiTasks.navigateTo(url, true);
		sahiTasks.setStrictVisibilityCheck(true);
	}
	
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
		sahiTasks.navigateTo(url, true);
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
	 * Modify dns zone record fields
	 */
	@Test (groups={"dnsZoneRecordsTest"}, dataProvider="getDNSRecords", dependsOnGroups="addDNSZoneTest")	
	public void dnsZoneRecordsTest(String testName, String zoneName,String reverseZoneName, String authoritativeNameserver, String rootEmail,
									String record_name, String record_data, String record_type) throws Exception {
		sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneRecordsModification(sahiTasks,record_name,record_data,record_type);
		// go back to dns zone list, prepare for next test
		//sahiTasks.link("DNS Zones").click(); 
		
	}//dnsZoneRecordsTest
	
	////////////////////////////////////////////////////////////////////////
	// reverse zone test 
	/////////////////////////////////////////////////////////////////////////
	
	/*
	 * Add & Delete DNS reverse zone - positive tests
	 */
	@Test (groups={"dnsReverseZoneBaseTest"}, dataProvider="getDNSReverseZoneObjects")	
	public void reverseDNSZoneBaseTest(String testName, String zoneIP, String reverseZoneName, String authoritativeNameserver, String rootEmail) throws Exception {

		// dns reverse zone create & delete
		DNSTasks.addDNSReversezone(sahiTasks, zoneIP, authoritativeNameserver, rootEmail);
		Assert.assertTrue(sahiTasks.link(reverseZoneName).exists(),"assert new zone in the zone list");
		DNSTasks.delDNSReversezone(sahiTasks, reverseZoneName);
		Assert.assertFalse(sahiTasks.link(reverseZoneName).exists(),"assert new zone not in the zone list");
	}//reverseDNSZoneBaseTest
	
	/*
	 * Add & Delete DNS reverse zone - positive tests
	 */
	@Test (groups={"addReverseDNSZone"}, dataProvider="getDNSReverseZoneObjects")	
	public void addReverseDNSZone(String testName, String zoneIP, String reverseZoneName, String authoritativeNameserver, String rootEmail) throws Exception {
		// dns reverse zone create & delete
		DNSTasks.addDNSReversezone(sahiTasks, zoneIP, authoritativeNameserver, rootEmail);
		Assert.assertTrue(sahiTasks.link(reverseZoneName).exists(),"assert new zone in the zone list");
	}//reverseDNSZoneBaseTest
	
	/*
	 * Add & Delete DNS reverse zone - positive tests
	 */
	@Test (groups={"deleteReverseDNSZone"}, dataProvider="getDNSReverseZoneObjects")	
	public void deleteReverseDNSZone(String testName, String zoneIP, String reverseZoneName, String authoritativeNameserver, String rootEmail) throws Exception {
 		DNSTasks.delDNSReversezone(sahiTasks, reverseZoneName);
		Assert.assertFalse(sahiTasks.link(reverseZoneName).exists(),"assert new zone not in the zone list");
	}//deleteReverseDNSZone
	
	
	/*
	 * Modify dns reverse zone record fields
	 */ 	
	@Test (groups={"dnsReverseZoneRecordsTest"}, dataProvider="getDNSRecords", dependsOnGroups="addReverseDNSZone")	
	public void dnsReverseZoneRecordsTest(	String testName, String zoneName,String reverseZoneName, 
											String authoritativeNameserver, String rootEmail,
											String record_name, String record_data, String record_type) throws Exception {
 
		sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(reverseZoneName).click();
		// performing the test
		DNSTasks.zoneRecordsModification(sahiTasks, record_name,record_data,record_type);
	}//dnsReverseZoneRecordsTest
	
	/*
	 * Modify dns reverse zone settings fields
	 */
	@Test (groups={"dnsReverseZoneSettingsTest"}, dataProvider="getDNSSettings")	
	public void dnsReverseZoneSettingsTest(String testName, String zoneName, String reverseZoneName, String fieldName, String fieldValue) throws Exception {
		sahiTasks.navigateTo(url, true);
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
	}//dnsZoneSettingsTest
	
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
				"dns zone test", "sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com"} ));  
		return ll;	
	}//Data provider: getDNSZoneObjects
	
	@DataProvider(name="getDNSSettings")
	public Object[][] getDNSSettings(){
		return TestNGUtils.convertListOfListsTo2dArray(createDNSSettings());
	}
	protected List<List<Object>> createDNSSettings(){
		List<List<Object>> ll = new ArrayList<List<Object>>();
		// testName, zoneName, authoritativeNameserver, rootEmail,record_name, record_data, record_type
		ll.add(Arrays.asList(new Object[]{"dns settings test: soa name","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"idnssoamname","modified.dhcp-121.sjc.redhat.com"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings test: soa r name ","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"idnssoarname","email.dhcp-121.sjc.redhat.com"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: soa serial","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"idnssoaserial","2147483646"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa refresh time","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"idnssoarefresh","2400"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa retry time","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"idnssoaretry","600"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa expire time","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"idnssoaexpire","243544645"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa minimum time","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"idnssoaminimum","2400"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: ttl: time to live","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"dnsttl","1323324324"}));
		
		// I should have negative data for class here
		ll.add(Arrays.asList(new Object[]{"dns settings: class","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"dnsclass","IN"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"dnsclass","CS"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"dnsclass","CH"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class","sahi_zone_001","1.0.0.10.in-addr.arpa.",
				"dnsclass","HS"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: allow dynamic update","sahi_zone_001",
				"idnsallowdynupdate","TRUE"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: update policy","sahi_zone_001",
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
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"a_recordtest","10.0.0.2","A"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record A6 test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"a6_recordtest","48 0::0 subscriber-bar.ip6.isp2.baz.","A6"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AFSDB test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"afsdb_recordtest","dhcp-121.sjc.redhat.com","AFSDB"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record APL test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"apl_recordtest","1:224.0.0.0","APL"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record CERT test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"cert_recordtest","PGP FDASFDSAFDAfdafdafdsaWfdasfdasfff4324535435wefdsgdft43dgdf==","CERT"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record CNAME test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"cname_recordtest","also-dhcp-118.sjc.redhat.com","CNAME"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DHCID test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"dhcid_recordtest","AAIBY2/AuCccgoJbsaxcQc9TUapptP69lOjxfNuVAA2kjEA=","DHCID"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DLV test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"dlv_recordtest","30CC4B8F36687D3C2B7FD64448C167295875DE5486BBCCE4E36CDA52","DLV"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DNAME test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"dname_recordtest","bar.dhcp-121.sjc.redhat.com","DNAME"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DNSKEY test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"dnskey_recordtest","AQPSKmynfzW4kyBv015MUG2DeIQ3Cbl+BBZH4b/0PY1kxkmvHjcZc8nokfzj31GajIQKY+5CptLr3buXA10hWqTkF7H6RfoRqXQeogmMHfpftf6zMv1LyBUgia7za6ZEzOJBOztyvhjL742iU/TpPSEDhm2SNKLijfUppn1UaNvv4w==","DNSKEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DS test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"ds_recordtest","60485 5 1 ( 2BB183AF5F22588179A53B0A98631FAD1A292118 )","DS"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record HIP test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"hip_recordtest","2 200100107B1A74DF365639CC39F1D578AwEAAbdxyhNuSutc5EMzxTs9LBPCIkOFH8cIvM4p9+LrV4e19WzK00+CI6zBCQTdtWsuxKbWIy87UOoJTwkUs7lBu+Upr1gsNrut79ryra+bSRGQb1slImA8YVJyuIDsj7kwzG7jnERNqnWxZ48AWkskmdHaVDP4BcelrTI3rMXdXF5D","HIP"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record IPSECKEY test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"ipseckey_recordtest","IPSECKEY ( 10 1 2 192.0.2.38 AQNRU3mG7TVTO2BkR47usntb102uFJtugbo6BSGvgqt4AQ== )","IPSECKEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record KEY test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"key_recordtest","AIYADP8d3zYNyQwW2EM4wXVFdslEJcUx/fxkfBeH1El4ixPFhpfHFElxbvKoWmvjDTCmfiYy2X+8XpFjwICHc398kzWsTMKlxovpz2FnCTM=","KEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record KX test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"kx_recordtest","2345 sjc.redhat.com","KX"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record LOC test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"loc_recordtest","42 21 54 N 71 06 18 W -24m 30m","LOC"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record MX test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"mx_recordtest","MaileXchangeTest","MX"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NAPTR test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"naptr_recordtest","urn:cid:.","NAPTR"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NS test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"ns_recordtest","dhcp-121.sjc.redhat.com","NS"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"nsec_recordtest","host.example.com. (A MX RRSIG NSEC TYPE1234 )","NSEC"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC3 test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"nsec3_recordtest","1 1 12 aabbccdd (35mthgpgcu1qg68fab165klnsnk3dpvl MX RRSIG )","NSEC3"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC3PARAM test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"nsec3param_recordtest","1 0 12 aabbccdd","NSEC3PARAM"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record PTR test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"ptr_recordtest","SJS.REDHAT.COM.","PTR"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record RRSIG test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"rrsig_recordtest","HINFO 7 2 3600 20150420235959 20051021000000 (40430 example.  KimG+rDd+7VA1zRsu0ITNAQUTRlpnsmqWrihFRnU+bRa93v2e5oFNFYCs3Rqgv62K93N7AhW6Jfqj/8NzWjvKg== )","RRSIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record RP test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"rp_recordtest","owner.dhcp-121.sjc.redhat.com","RP"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SIG test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"sig_recordtest","","SIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SPF test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"spf_recordtest","v=spf1 +mx a:colo.example.com/28 -all","SPF"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SRV test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"srv_recordtest","1 0 9 server.example.com.","SRV"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SSHFP test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"sshfp_recordtest","2 1 123456789abcdef67890123456789abcdef67890","SSHFP"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record TA test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"ta_recordtest"," 60485 5 1 ( 2BB183AF5F22588179A53B0A98631FAD1A292118 )","TA"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record TKEY test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"tkey_recordtest","","TKEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record TSIG test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"tsig_recordtest","","TSIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record TXT test", 
				"sahi_zone_001","1.0.0.10.in-addr.arpa.","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"txt_recordtest","MOE     MB      A.ISI.EDU.","TXT"})); 
		
		return ll;	
	}//Data provider: getDNSRecords
	
	
	/*
	 * Data to be used when adding hosts - for positive cases
	 */
	@DataProvider(name="getDNSReverseZoneObjects")
	public Object[][] getDNSReverseZoneObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSReverseZoneObjects());
	}
	protected List<List<Object>> createDNSReverseZoneObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
		ll.add(Arrays.asList(new Object[]{
				// testName,  zoneIP,  reverseZoneName,  authoritativeNameserver,  rootEmail	
				"dns reverse zone test", "10.0.0.1","1.0.0.10.in-addr.arpa." ,"dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com"} )); 
		return ll;	
	}//Data provider: createDNSReverseZoneObjects 
	
}//class DNSTest
