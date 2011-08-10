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
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks = SahiTestScript.getSahiTasks();	
		String url = System.getProperty("ipa.server.url")+dnsPage;
		System.out.println("navigate to: " + url);
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
	 * Add & Delete DNS reverse zone - positive tests
	 */
	@Test (groups={"dnsReverseZoneBaseTest"}, dataProvider="getDNSReverseZoneObjects")	
	public void reverseDNSZoneBaseTest(String testName, String zoneName, String authoritativeNameserver, String rootEmail) throws Exception {

		// dns reverse zone create & delete
		DNSTasks.addDNSReversezone(sahiTasks, zoneName, authoritativeNameserver, rootEmail);
		Assert.assertTrue(sahiTasks.link(zoneName).exists(),"assert new zone in the zone list");
		DNSTasks.delDNSReversezone(sahiTasks, zoneName);
		Assert.assertFalse(sahiTasks.link(zoneName).exists(),"assert new zone not in the zone list");
	}//dnsAcceptanceTest
	
	/*
	 * Modify dns zone setting fields
	 */
	@Test (groups={"dnsZoneSettingsTest"}, dataProvider="getDNSSettings")	
	public void dnsZoneSettingsTest(String testName, String zoneName, String fieldName, String fieldValue) throws Exception {
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneSettingsModification(sahiTasks, zoneName, fieldName, fieldValue);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click();
	}//dnsZoneSettingsTest
	
	/*
	 * Modify dns zone record fields
	 */
	@Test (groups={"dnsZoneRecordsTest"}, dataProvider="getDNSRecords", dependsOnGroups="addDNSZoneTest")	
	public void dnsZoneRecordsTest(String testName, String zoneName,String authoritativeNameserver, String rootEmail,
									String record_name, String record_data, String record_type) throws Exception {

		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneRecordsModification(sahiTasks, zoneName,record_name,record_data,record_type);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").click(); 
		
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
		ll.add(Arrays.asList(new Object[]{"dns record A test","sahi_zone_001",
										"idnssoamname","modified.dhcp-121.sjc.redhat.com"}));
		
		// FIXME: Rest of them need double confirm
		// need append more data here
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
											"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
											"a_recordtest","10.0.0.2","A"}));
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
											"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
											"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA"}));
		
		//FIXME: the following data need double confirm
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"a6_recordtest","48 0::0 subscriber-bar.ip6.isp2.baz.","A6"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"afsdb_recordtest","dhcp-121.sjc.redhat.com","AFSDB"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"apl_recordtest","1:224.0.0.0","APL"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"cert_recordtest","PGP FDASFDSAFDAfdafdafdsaWfdasfdasfff4324535435wefdsgdft43dgdf==","CERT"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"cname_recordtest","also-dhcp-118.sjc.redhat.com","CNAME"}));
		
//		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
//				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
//				"dhcid_recordtest","AAIBY2/AuCccgoJbsaxcQc9TUapptP69lOjxfNuVAA2kjEA=","DHCID"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"dlv_recordtest","30CC4B8F36687D3C2B7FD64448C167295875DE5486BBCCE4E36CDA52","DLV"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"dname_recordtest","bar.dhcp-121.sjc.redhat.com","DNAME"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"dnskey_recordtest","AQPSKmynfzW4kyBv015MUG2DeIQ3Cbl+BBZH4b/0PY1kxkmvHjcZc8nokfzj31GajIQKY+5CptLr3buXA10hWqTkF7H6RfoRqXQeogmMHfpftf6zMv1LyBUgia7za6ZEzOJBOztyvhjL742iU/TpPSEDhm2SNKLijfUppn1UaNvv4w==","DNSKEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"ds_recordtest","60485 5 1 ( 2BB183AF5F22588179A53B0A98631FAD1A292118 )","DS"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"hip_recordtest","2 200100107B1A74DF365639CC39F1D578AwEAAbdxyhNuSutc5EMzxTs9LBPCIkOFH8cIvM4p9+LrV4e19WzK00+CI6zBCQTdtWsuxKbWIy87UOoJTwkUs7lBu+Upr1gsNrut79ryra+bSRGQb1slImA8YVJyuIDsj7kwzG7jnERNqnWxZ48AWkskmdHaVDP4BcelrTI3rMXdXF5D","HIP"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"ipseckey_recordtest","IPSECKEY ( 10 1 2 192.0.2.38 AQNRU3mG7TVTO2BkR47usntb102uFJtugbo6BSGvgqt4AQ== )","IPSECKEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"key_recordtest","AIYADP8d3zYNyQwW2EM4wXVFdslEJcUx/fxkfBeH1El4ixPFhpfHFElxbvKoWmvjDTCmfiYy2X+8XpFjwICHc398kzWsTMKlxovpz2FnCTM=","KEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"kx_recordtest","2345 sjc.redhat.com","KX"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"loc_recordtest","42 21 54 N 71 06 18 W -24m 30m","LOC"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"mx_recordtest","MaileXchangeTest","MX"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"naptr_recordtest","urn:cid:.","NAPTR"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"ns_recordtest","dhcp-121.sjc.redhat.com","NS"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"nsec_recordtest","host.example.com. (A MX RRSIG NSEC TYPE1234 )","NSEC"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"nsec3_recordtest","1 1 12 aabbccdd (35mthgpgcu1qg68fab165klnsnk3dpvl MX RRSIG )","NSEC3"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"nsec3param_recordtest","1 0 12 aabbccdd","NSEC3PARAM"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"ptr_recordtest","SJS.REDHAT.COM.","PTR"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"rrsig_recordtest","HINFO 7 2 3600 20150420235959 20051021000000 (40430 example.  KimG+rDd+7VA1zRsu0ITNAQUTRlpnsmqWrihFRnU+bRa93v2e5oFNFYCs3Rqgv62K93N7AhW6Jfqj/8NzWjvKg== )","RRSIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"rp_recordtest","owner.dhcp-121.sjc.redhat.com","RP"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"sig_recordtest","","SIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"spf_recordtest","v=spf1 +mx a:colo.example.com/28 -all","SPF"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"srv_recordtest","1 0 9 server.example.com.","SRV"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"sshfp_recordtest","2 1 123456789abcdef67890123456789abcdef67890","SSHFP"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"ta_recordtest"," 60485 5 1 ( 2BB183AF5F22588179A53B0A98631FAD1A292118 )","TA"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"tkey_recordtest","","TKEY"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
				"tsig_recordtest","","TSIG"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				"sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com", 
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
				//testName,  zoneName,  authoritativeNameserver,  rootEmail	
				"dns zone test", "sahi_zone_001","dhcp-121.sjc.redhat.com","root.dhcp-121.sjc.redhat.com"} )); 
		return ll;	
	}//Data provider: createDNSReverseZoneObjects 
	
}//class DNSTest
