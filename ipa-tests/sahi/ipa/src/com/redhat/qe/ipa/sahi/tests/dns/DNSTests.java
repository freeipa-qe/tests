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
	
	public static String dnszone= "sahi.dns.test.zone";
	public static String dnszone2= "202.65.10.in-addr.arpa.";
	public static String zoneIP="10.65.222.0/24";
	public static String reversezone= ""; 
	public static String dummyHost="" ; 
	public static String nameserver1="";
	public static String nameserver2="";
	public static String nameserver="";
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		
		sahiTasks.navigateTo(commonTasks.dnsPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
		
		 //reversezone= commonTasks.getReversezone();
		reversezone="222.65.10.in-addr.arpa.";
		dummyHost= "dummyhost." + CommonTasks.ipadomain;
		nameserver1=CommonTasks.getIpafqdn();
		nameserver2=".";
		nameserver=nameserver1.concat(nameserver2);
			
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		String currentURL = sahiTasks.fetch("top.location.href");
		//TODO: yi: check for the alternateDNSpage url as well
		CommonTasks.checkError(sahiTasks);
		if (!currentURL.equals(commonTasks.dnsPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+ commonTasks.dnsPage +")");
			sahiTasks.navigateTo(commonTasks.dnsPage, true);
		//win specific:if don't click OK for validation error, when enable/disable dns zones ,the click OK for that method will misclick the OK for validation error. 
			if(sahiTasks.div("validation_error").exists()){
			sahiTasks.span("OK").click();
			}
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
	@Test (groups={"addDNSZoneTest"}, dataProvider="getDNSZoneObjects",dependsOnGroups={"add_then_cancel_DNSZoneTest","dnsZoneSettingsEnableDisableTest" })	
	public void addDNSZoneTest(String testName, String zoneName, String authoritativeNameserver, String rootEmail) throws Exception {
		DNSTasks.addDNSzone(sahiTasks, zoneName, authoritativeNameserver, rootEmail); 
	}//addDNSZoneTest
	
	
	/*
	 *DNS zone - EnableDisable Test 
	 */
	@Test (groups={"zoneEnableDisableTest"}, dataProvider="getDNSZoneEnableDisableObjects",dependsOnGroups={"addDNSZoneTest"})	
	public void dNSZoneEnableDisableTest(String testName, String zoneName,String linkToCkick,String expectedMsg,String status) throws Exception {
		
		DNSTasks.dNSzoneEnableDisable(sahiTasks, zoneName,linkToCkick,expectedMsg,status);
		
	}
	
	/*
	 * Add and Another DNS Zone
	 */
	@Test (groups={"addandanotherDNSZoneTest"}, dataProvider="getaddandanotherDNSZoneObjects",dependsOnGroups={"zoneEnableDisableTest"})	
	public void addandanotherDNSZoneTest(String testName, String zoneName1, String authoritativeNameserver, String rootEmail,String zoneName2) throws Exception {
		DNSTasks.addandanotherDNSzone(sahiTasks, zoneName1, authoritativeNameserver, rootEmail,zoneName2); 
	}
	
	
	/*
	 * Add and cancel
	 */
	
	@Test (groups={"add_then_cancel_DNSZoneTest"}, dataProvider="getDNSZoneObjects" )	
	public void add_then_cancel_DNSZoneTest(String testName, String zoneName, String authoritativeNameserver, String rootEmail) throws Exception {
		DNSTasks.add_then_cancel_DNSzone(sahiTasks, zoneName, authoritativeNameserver, rootEmail); 
	}
	
	
	/*
	 * Delete DNS zone - positive tests
	 */
	@Test (groups={"delDNSZoneTest"}, dataProvider="getdelDNSZoneObjects",dependsOnGroups={"addDNSZoneTest","addandanotherDNSZoneTest","dnsZone_addandedit","recordType_NegativeTest","dnsZoneRecordsTest_add","dnsZoneRecordsTest_addandaddanother","dnsZoneRecordsTest_addandaddedit","dnsZoneRecordsTest_add_then_cancel","dnsZoneSettingsTest","dnsZoneSettingsNagativeTest","zoneEnableDisableTest"})	
	public void delDNSZoneTest(String testName, String zoneName, String authoritativeNameserver, String rootEmail) throws Exception {
		DNSTasks.delDNSzone(sahiTasks, zoneName); 
	}
	
	/*
	 * Add DNS Test - Negative Test
	 */
	@Test (groups={"addDNSZoneNegativeTest"}, dataProvider="getDNSZoneNegativeObjects" ,dependsOnGroups={"addDNSZoneTest","zoneEnableDisableTest"})	
	public void addNegativeDNSZoneTest(String testName, String zoneName, String authoritativeNameserver, String rootEmail, String expectedError) throws Exception {
		DNSTasks.addDNSzoneNegativeTest(sahiTasks, zoneName, authoritativeNameserver, rootEmail,expectedError); 
	}
	
	
	
	/*
	 * add and edit zone
	 * 
	 *  This tests covers DNS Zone add_and_edit, add_and_edit Record type, add and  add_and_another Record type, edit Record type, update Record type, update without modify Record type, delete  Record type , Expand and collapse test
	 */
	//,dependsOnGroups={"addDNSZoneTest","addandanotherDNSZoneTest","addDNSZoneNegativeTest"}
	 @Test (groups={"dnsZone_addandedit"}, dataProvider="getDNSZone_edit",dependsOnGroups={"zoneEnableDisableTest"})	
		public void dnsZone_addandaddedit(String testName, String zoneName, String authoritativeNameserver, String rootEmail,
										String first_record_name, String first_record_data, String first_record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
										String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11,
										
										String second_record_name, String second_record_data, String second_record_type,String sec_other_data1, String sec_other_data2,String sec_other_data3,String sec_other_data4,String sec_other_data5,
										String sec_other_data6,String sec_other_data7,String sec_other_data8,String sec_other_data9,String sec_other_data10,String sec_other_data11,
										
										String third_record_name, String third_record_data, String third_record_type,String third_other_data1, String third_other_data2,String third_other_data3,String third_other_data4,String third_other_data5,
										String third_other_data6,String third_other_data7,String third_other_data8,String third_other_data9,String third_other_data10,String third_other_data11,
										
										String edit_record_name, String edit_record_data, String edit_record_type,String edit_other_data1, String edit_other_data2,String edit_other_data3,String edit_other_data4,String edit_other_data5,
										String edit_other_data6,String edit_other_data7,String edit_other_data8,String edit_other_data9,String edit_other_data10,String edit_other_data11,String expectedMsg) throws Exception {
		 	System.out.println("*************************************************************************");
		 // This tests covers DNS Zone add_and_edit, add_and_edit Record type, add and  add_and_another Record type, edit Record type, update Record type, update without modify Record type, delete  Record type , Expand and collapse test           
			DNSTasks.dnsZone_addandedit(sahiTasks,zoneName,authoritativeNameserver,rootEmail, 
															first_record_name,first_record_data,first_record_type,other_data1,other_data2,other_data3, other_data4, other_data5,
															other_data6, other_data7, other_data8, other_data9, other_data10, other_data11,
															
															second_record_name, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,
															sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11,
															
															third_record_name,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,
															third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11,
															
															edit_record_name,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,
															edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11,expectedMsg); 
			// go back to dns zone list, prepare for next test
			sahiTasks.link("DNS Zones").click();  
		} 
	
	/*
	 * Negative Record Type 
	 */

	 @Test (groups={"recordType_NegativeTest"}, dataProvider="getDNSNegativeRecordType",dependsOnGroups={"addDNSZoneTest","zoneEnableDisableTest"})	
		public void dnsRecordType_NegativeTest(String testName, String zoneName, String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
										String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11,String expectedError)throws Exception {
			sahiTasks.link(zoneName).click();
			DNSTasks.recordTypeNegativeTest(sahiTasks,record_name,record_data,record_type,other_data1,other_data2,other_data3, other_data4, other_data5,
					other_data6, other_data7, other_data8, other_data9, other_data10, other_data11,expectedError); 
			
		 
		 
			// go back to dns zone list, prepare for next test
			sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click(); 
		}	 
	
	/*
	 * Modify dns zone setting fields
	 */
	 
	  //
	@Test (groups={"dnsZoneSettingsTest"}, dataProvider="getDNSSettings", dependsOnGroups={"addDNSZoneTest","zoneEnableDisableTest","dnsZoneRecordsTest_add_then_cancel"})	
	public void dnsZoneSettingsTest(String testName, String testNameGroup, String zoneName, String reverseZoneName,String fieldName, String fieldValue) throws Exception {
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		if(testNameGroup.equals("SOA&class"))
		{
			DNSTasks.zoneSettingsModification_SoaAndClass(sahiTasks, zoneName, reverseZoneName,fieldName, fieldValue);
		}
		if(testNameGroup.equals("Bind Update policy"))
		{
			DNSTasks.zoneSettingsModification_bindUpdatePolicy(sahiTasks, zoneName, reverseZoneName,fieldName, fieldValue);
		}
		if(testNameGroup.equals("Dynamic Update&Policy"))
		{
			DNSTasks.zoneSettingsModification_dynamicUpdateAndPolicy(sahiTasks, zoneName, reverseZoneName,fieldName, fieldValue);
		}
		
		if(testNameGroup.equals("Query&Transfer"))
		{
			DNSTasks.zoneSettingsModification_queryAndTransfer(sahiTasks, zoneName, reverseZoneName,fieldName, fieldValue);
		}
		
		if(testNameGroup.equals("PTR Sync"))
		{
			DNSTasks.dnsZoneAllowPTRSync(sahiTasks, zoneName, reverseZoneName,fieldName, fieldValue);
		}		
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click(); 
		if (sahiTasks.span("Dirty").exists()){
			log.info("Dirty dialog detected, will click reset to make it continue");
			// some failed changes might occurred, need some protection here
			sahiTasks.button("Reset").click(); //Reset will bring user back to DNS zone list
		}else{
			log.info("no 'Dirty' dialog detected, test continue well");
		} 
	}//dnsZoneSettingsTest
	
	
	/*
	 * negative test
	 */
	@Test (groups={"dnsZoneSettingsNagativeTest"}, dataProvider="getDNSSettings_Negative", dependsOnGroups={"addDNSZoneTest","zoneEnableDisableTest"})	
	public void testDnsZoneSettingsNagative(String testName, String zoneName, String reverseZoneName,String fieldName, String fieldValue, String expectedError1, String expectedError2) throws Exception {
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		DNSTasks.dnsZoneNegativeSetting(sahiTasks,zoneName,reverseZoneName,fieldName,fieldValue,expectedError1,expectedError2);
		// performing the test
	}
	
	
	
	
	/*
	 * DNS Zone Setting-Enable And Disable
	 */
	
	@Test (groups={"dnsZoneSettingsEnableDisableTest"}, dataProvider="getDNSSettingsEnableDisableObject")	
	public void dnsZoneSettingsEnableAndDisableTest(String testName, String zoneName,String authoritativeNameserver, String rootEmail) throws Exception {
		
		DNSTasks.addDNSzone(sahiTasks, zoneName, authoritativeNameserver, rootEmail);
		sahiTasks.link(zoneName).click();
		DNSTasks.DNSZoneEnable_Disable(sahiTasks,zoneName);
	
	}
	
	/*
	 * Negative Test for add dns zone record
	 */
	
	@Test (groups={"dnsZoneRecordsNegativeTest_add"}, dataProvider="getNegativeDNSRecords", dependsOnGroups={"addDNSZoneTest","zoneEnableDisableTest"})	
	public void dnsZoneRecordsNegativeTest_add(String testName, String zoneName,String reverseZoneName, String authoritativeNameserver, String rootEmail,
									String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
									String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11,String expected_msg) throws Exception {
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneRecords_add_NegativeTest(sahiTasks,record_name,record_data,record_type,other_data1,other_data2,other_data3, other_data4, other_data5,
									other_data6, other_data7, other_data8, other_data9, other_data10, other_data11,expected_msg); 
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click();
		
	}
	
	
	
	/**/
	
	/*
	 * Test for add one dns zone record
	 */
	@Test (groups={"dnsZoneRecordsTest_add"}, dataProvider="getDNSRecords", dependsOnGroups={"addDNSZoneTest","zoneEnableDisableTest","dnsZoneRecordsNegativeTest_add"})	
	public void dnsZoneRecordsTest_add(String testName, String zoneName,String reverseZoneName, String authoritativeNameserver, String rootEmail,
									String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
									String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11) throws Exception {
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneRecords_add(sahiTasks,record_name,record_data,record_type,other_data1,other_data2,other_data3, other_data4, other_data5,
									other_data6, other_data7, other_data8, other_data9, other_data10, other_data11); 
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click();
		
	}
	
	/*
	 * Modify dns zone record fields
	 */
	 @Test (groups={"dnsZoneRecordsTest_addandaddanother"}, dataProvider="getDNSRecords_addanother", dependsOnGroups={"addDNSZoneTest","zoneEnableDisableTest"})	
	public void dnsZoneRecordsTest_addandaddanother(String testName, String zoneName,String reverseZoneName, String authoritativeNameserver, String rootEmail,
									String first_record_name, String first_record_data, String first_record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
									String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11,
									
									String second_record_name, String second_record_data, String second_record_type,String sec_other_data1, String sec_other_data2,String sec_other_data3,String sec_other_data4,String sec_other_data5,
									String sec_other_data6,String sec_other_data7,String sec_other_data8,String sec_other_data9,String sec_other_data10,String sec_other_data11) throws Exception {
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneRecords_addandaddanother(sahiTasks,first_record_name,first_record_data,first_record_type,other_data1,other_data2,other_data3, other_data4, other_data5,
														other_data6, other_data7, other_data8, other_data9, other_data10, other_data11,
														second_record_name, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,
														sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11); 
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click();  
	} 
	
	/*
	 * Modify dns zone record fields : and one new record and switch to editing mode immediately 
	 */
	@Test (groups={"dnsZoneRecordsTest_addandaddedit"}, dataProvider="getDNSRecords", dependsOnGroups={"addDNSZoneTest","zoneEnableDisableTest"})	
	public void dnsZoneRecordsTest_addandaddedit(String testName, String zoneName,String reverseZoneName, String authoritativeNameserver, String rootEmail,
									String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
									String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11) throws Exception { 
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneRecords_addandedit(sahiTasks,zoneName,record_name,record_data,record_type, other_data1, other_data2, other_data3, other_data4, other_data5, other_data6, other_data7, other_data8, other_data9, other_data10, other_data11); 
		// go back to dns zone list, prepare for next test
		//sahiTasks.link("DNS Zones").under(sahiTasks.div("DNS ZonesDNS Global ConfigurationDNS Resource Records")).click();
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	/*
	 * Modify dns zone record fields : and one new record and switch to editing mode immediately 
	 */
	@Test (groups={"dnsZoneRecordsTest_add_then_cancel"}, dataProvider="getDNSRecords_AddAndCancel", dependsOnGroups={"addDNSZoneTest","zoneEnableDisableTest"})	
	public void dnsZoneRecordsTest_add_then_cancel(String testName, String zoneName,String reverseZoneName, String authoritativeNameserver, String rootEmail,
									String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
			    					String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11) throws Exception {
		// get into DNS zone record modification page
		sahiTasks.link(zoneName).click();
		// performing the test
		DNSTasks.zoneRecords_add_then_cancel(sahiTasks,record_name,record_data,record_type, other_data1, other_data2, other_data3, other_data4, other_data5, other_data6, other_data7, other_data8, other_data9, other_data10, other_data11); 
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click();
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
		DNSTasks.addDNSReversezone(sahiTasks, zoneIP,reverseZoneName, authoritativeNameserver, rootEmail);
		Assert.assertTrue(sahiTasks.link(reverseZoneName).exists(),"assert new zone in the zone list");
		DNSTasks.delDNSReversezone(sahiTasks, reverseZoneName);
		Assert.assertFalse(sahiTasks.link(reverseZoneName).exists(),"assert new zone not in the zone list");
	}//reverseDNSZoneBaseTest
	
	
	/*
	 * Add  DNS reverse zone - positive tests
	 */
	
	
	
  @Test (groups={"addReverseDNSZone"}, dataProvider="getReverseDNSZoneObjects")	
	public void addReverseDNSZone(String testName, String zoneIP, String reverseZoneName, String authoritativeNameserver, String rootEmail) throws Exception {
		DNSTasks.addDNSReversezone(sahiTasks, zoneIP, reverseZoneName,authoritativeNameserver, rootEmail);
		Assert.assertTrue(sahiTasks.link(reverseZoneName).exists(),"assert new zone in the zone list");
	}
	
  
  /*
   * add and another
   */
  @Test (groups={"addandanother_ReverseDNSZone"}, dataProvider="getAddAndAnotherReverseDNSZoneObjects")	
	public void addAndAnotherReverseDNSZone(String testName, String zoneIP1, String reverseZoneName1, String authoritativeNameserver, String rootEmail,String zoneIP2, String reverseZoneName2) throws Exception {
		DNSTasks.addAndAnotherDNSReversezone(sahiTasks, zoneIP1, reverseZoneName1,authoritativeNameserver, rootEmail,zoneIP2, reverseZoneName2);
		
	}
	
  
	/*
	 * Delete DNS reverse zone - positive tests
	 */
	@Test (groups={"deleteReverseDNSZone"}, dataProvider="getDelReverseDNSZoneObjects", dependsOnGroups={"addReverseDNSZone","addandanother_ReverseDNSZone","reverseDNSZoneRecordsTest_add","reverseDNSZoneRecordsTest_addandaddanother","reverseDNSZoneRecordsTest_addandedit","reverseDNSZoneRecordsTest_add_then_cancel","dnsReverseZoneSettingsTest","dnsReverseSettingsNagativeTest"})	
	public void deleteReverseDNSZone(String testName, String zoneIP, String reverseZoneName, String authoritativeNameserver, String rootEmail) throws Exception {
 		DNSTasks.delDNSReversezone(sahiTasks, reverseZoneName);
		Assert.assertFalse(sahiTasks.link(reverseZoneName).exists(),"assert new zone not in the zone list");
	}
	
/*
 * Add Reverse Zone - Negative Test
 */
	@Test (groups={"addReverseDNSZoneNegativeTest"}, dataProvider="getReverseDNSZoneNegativeTestObjects")	
	public void addReverseDNSZoneNegativeTest(String testName, String zoneIP,String authoritativeNameserver, String rootEmail,String expectedError) throws Exception {
		// dns reverse zone create & delete
		DNSTasks.addDNSReversezoneNegativeTest(sahiTasks, zoneIP,authoritativeNameserver, rootEmail,expectedError );
		}//reverseDNSZoneBaseTest
	
	/*
	 * Modify reverse dns zone record fields
	 */ 
	@Test (groups={"reverseDNSZoneRecordsTest_add"}, dataProvider="getReverseDNSRecords", dependsOnGroups="addReverseDNSZone")	
	public void reverseDNSZoneRecordsTest_add(	String testName, String zoneName,String reverseZoneName, 
											String authoritativeNameserver, String rootEmail,
											String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
											String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11) throws Exception {
 		sahiTasks.link(reverseZoneName).click();
		// performing the test
		DNSTasks.zoneRecords_add(sahiTasks, record_name,record_data,record_type,other_data1,other_data2,other_data3, other_data4, other_data5,
				other_data6, other_data7, other_data8, other_data9, other_data10, other_data11);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click(); 
	}
	
	/*
	 * Modify reverse dns zone record fields : add one record and then add another record immediately
	 */ 	
	@Test (groups={"reverseDNSZoneRecordsTest_addandaddanother"}, dataProvider="getReverseDNSRecords_addanother", dependsOnGroups="addReverseDNSZone")	
	public void reverseDNSZoneRecordsTest_addandaddanother(	String testName, String zoneName,String reverseZoneName, String authoritativeNameserver, String rootEmail,
															String first_record_name, String first_record_data, String first_record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
															String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11,
			
															String second_record_name, String second_record_data, String second_record_type,String sec_other_data1, String sec_other_data2,String sec_other_data3,String sec_other_data4,String sec_other_data5,
															String sec_other_data6,String sec_other_data7,String sec_other_data8,String sec_other_data9,String sec_other_data10,String sec_other_data11	) throws Exception {
      	sahiTasks.link(reverseZoneName).click();
		// performing the test
		DNSTasks.zoneRecords_addandaddanother(sahiTasks,first_record_name,first_record_data,first_record_type,other_data1,other_data2,other_data3, other_data4, other_data5,
														other_data6, other_data7, other_data8, other_data9, other_data10, other_data11,
														second_record_name, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,
														sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click();
	}    
	
	/*
	 * Modify reverse dns zone record fields : add one record then get into editing mode immediately 
	 */ 	
	@Test (groups={"reverseDNSZoneRecordsTest_addandedit"}, dataProvider="getReverseDNSRecordAddAndEdit", dependsOnGroups="addReverseDNSZone")	
	public void reverseDNSZoneRecordsTest_addandedit(	String testName, String zoneName,String reverseZoneName, 
											String authoritativeNameserver, String rootEmail,
											String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
											String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11) throws Exception {
 		// get into DNS zone record modification page
		sahiTasks.link(reverseZoneName).click();
		// performing the test
		DNSTasks.zoneRecords_addandedit(sahiTasks,reverseZoneName,record_name,record_data,record_type, other_data1, other_data2, other_data3, other_data4, other_data5, other_data6, other_data7, other_data8, other_data9, other_data10, other_data11);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click(); 
	}//reverseDNSZoneRecordsTest_addandedit  
	
	
	/*
	 * Modify reverse dns zone record fields: add and then cancel
	 */ 	
	@Test (groups={"reverseDNSZoneRecordsTest_add_then_cancel"}, dataProvider="getDNSRecords_AddAndCancel", dependsOnGroups="addReverseDNSZone")	
	public void reverseDNSZoneRecordsTest_add_then_cancel(	String testName, String zoneName,String reverseZoneName, 
											String authoritativeNameserver, String rootEmail,
											String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
											String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11) throws Exception {
 		// get into DNS zone record modification page
		sahiTasks.link(reverseZoneName).click();
		// performing the test
		DNSTasks.zoneRecords_add_then_cancel(sahiTasks, record_name,record_data,record_type, other_data1, other_data2, other_data3, other_data4, other_data5, other_data6, other_data7, other_data8, other_data9, other_data10, other_data11);
		// go back to dns zone list, prepare for next test
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click(); 
	}//reverseDNSZoneRecordsTest_add_then_cancel 
	
	/*
	 * Modify dns reverse zone settings fields
	 */
	@Test (groups={"dnsReverseZoneSettingsTest"}, dataProvider="getDNSSettings", dependsOnGroups="addReverseDNSZone")	
	public void reverseDNSZoneSettingsTest(String testName,String testNameGroup, String zoneName,String reverseZoneName, String fieldName, String fieldValue) throws Exception {
		//sahiTasks.navigateTo(url, true);
		// get into DNS zone record modification page
		sahiTasks.link(reverseZoneName).click();
		
		
		// performing the test
		if(testNameGroup.equals("SOA&class"))
		{
			DNSTasks.zoneSettingsModification_SoaAndClass(sahiTasks, zoneName, reverseZoneName,fieldName, fieldValue);
		}
		if(testNameGroup.equals("Bind Update policy"))
		{
			DNSTasks.zoneSettingsModification_bindUpdatePolicy(sahiTasks, zoneName, reverseZoneName,fieldName, fieldValue);
		}
		if(testNameGroup.equals("Dynamic Update&Policy"))
		{
			DNSTasks.zoneSettingsModification_dynamicUpdateAndPolicy(sahiTasks, zoneName, reverseZoneName,fieldName, fieldValue);
		}
		
		if(testNameGroup.equals("Query&Transfer"))
		{
			DNSTasks.zoneSettingsModification_queryAndTransfer(sahiTasks, zoneName, reverseZoneName,fieldName, fieldValue);
		}
		
		if(testNameGroup.equals("PTR Sync"))
		{
			DNSTasks.dnsZoneAllowPTRSync(sahiTasks, zoneName, reverseZoneName,fieldName, fieldValue);
		}		
		// go back to dns zone list, prepare for next test
		
		
		sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click(); 
		if (sahiTasks.span("Dirty").exists()){
			log.info("Dirty dialog detected, will click reset to make it continue");
			// some failed changes might occurred, need some protection here
			sahiTasks.button("Reset").click(); //Reset will bring user back to DNS zone list
		}else{
			log.info("no 'Dirty' dialog detected, test continue well");
		} 
				
	}
	
	@Test (groups={"dnsReverseSettingsNagativeTest"}, dataProvider="getDNSSettings_Negative", dependsOnGroups="addReverseDNSZone")	
	public void testDnsReverseSettingsNagative(String testName, String zoneName, String reverseZoneName,String fieldName, String fieldValue, String expectedError1, String expectedError2) throws Exception {
		// get into DNS zone record modification page
		sahiTasks.link(reverseZoneName).click();
		DNSTasks.dnsZoneNegativeSetting(sahiTasks,zoneName,reverseZoneName,fieldName,fieldValue,expectedError1,expectedError2);
		// performing the test
	}
	
	
	
	
	
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
				"dns zone test", DNSTests.dnszone,nameserver,"root." + DNSTests.dummyHost} ));  
		ll.add(Arrays.asList(new Object[]{
				"dns zone test", DNSTests.dnszone2,nameserver,"root." + DNSTests.dummyHost} ));  
		return ll;	
	}
	
	/*
	 * getDNSZoneEnableDisableObjects
	 */
	@DataProvider(name="getDNSZoneEnableDisableObjects")
	public Object[][] getDNSZoneEnableDisableObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSZoneEnableDisableObjects());
	}
	protected List<List<Object>> createDNSZoneEnableDisableObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		ll.add(Arrays.asList(new Object[]{
				// testName,  zoneName
				"dns zone Disable", DNSTests.dnszone,"Disable","Are you sure you want to disable selected entries?","Disabled"} ));
		ll.add(Arrays.asList(new Object[]{
				"dns zone Enable ", DNSTests.dnszone,"Enable","Are you sure you want to enable selected entries?","Enabled"} ));
		return ll;	
	}
	
	/*
	 * Add and another DNS Zone
	 */
	@DataProvider(name="getaddandanotherDNSZoneObjects")
	public Object[][] getaddandanotherDNSZoneObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createaddandanotherDNSZoneObjects());
	}
	protected List<List<Object>> createaddandanotherDNSZoneObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		ll.add(Arrays.asList(new Object[]{
				// testName,                        zoneName1,     authoritativeNameserver,  rootEmail,             zoneName2	
				"add and another dns zone test", "zeta.dns.test.zone",nameserver,     "root." + DNSTests.dummyHost,"tera.dns.test.zone"} ));  
		
		return ll;	
	}
	
	
	
	@DataProvider(name="getDNSSettings")
	public Object[][] getDNSSettings(){
		if (!System.getProperty("os.name").startsWith("Windows"))
			return TestNGUtils.convertListOfListsTo2dArray(createDNSSettings());
		else
			return TestNGUtils.convertListOfListsTo2dArray(createDNSSettings_win());
	}
	protected List<List<Object>> createDNSSettings(){
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
	 ll.add(Arrays.asList(new Object[]{"dns settings test: soa name","SOA&class",DNSTests.dnszone,reversezone,
			"idnssoamname","margo.test.com."}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings test: soa r name","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoarname","email.dhcp-121.sjc.redhat.com."}));
		
			ll.add(Arrays.asList(new Object[]{"dns settings: soa serial","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoaserial","2147483646"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa refresh time","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoarefresh","2400"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa retry time","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoaretry","600"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa expire time","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoaexpire","243544645"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa minimum time","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoaminimum","2400"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: ttl: time to live","SOA&class",DNSTests.dnszone,reversezone,
				"dnsttl","1323324324"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class","SOA&class",DNSTests.dnszone,reversezone,
				"dnsclass","IN"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class","SOA&class",DNSTests.dnszone,reversezone,
				"dnsclass","CS"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class","SOA&class",DNSTests.dnszone,reversezone,
				"dnsclass","CH"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class","SOA&class",DNSTests.dnszone,reversezone,
				"dnsclass","HS"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: allow dynamic update","Dynamic Update&Policy",DNSTests.dnszone,reversezone,
				"idnsallowdynupdate-1-0","idnsallowdynupdate-1-1"}));
				
		ll.add(Arrays.asList(new Object[]{"dns settings: update policy","Bind Update policy",DNSTests.dnszone,reversezone,
				"idnsupdatepolicy","grant SJC.REDHAT.COM krb5-self * AAAA; grant SJC.REDHAT.COM krb5-self * A;"}));
		
		
		ll.add(Arrays.asList(new Object[]{"dns settings: allow query","Query&Transfer",DNSTests.dnszone,reversezone,
				"idnsallowquery-0","1.1.1.1"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: allow Transfer","Query&Transfer",DNSTests.dnszone,reversezone,
				"idnsallowtransfer-0","2.2.2.2"}));
				
		ll.add(Arrays.asList(new Object[]{"dns settings: allow Transfer","Query&Transfer",DNSTests.dnszone,reversezone,
				"idnsforwarders-0","3.3.3.3"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: forward Policy","Dynamic Update&Policy",DNSTests.dnszone,reversezone,
				"idnsforwardpolicy-2-1","idnsforwardpolicy-2-0"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: Allow_PTR_Sync_Test","PTR Sync",DNSTests.dnszone,reversezone,
				"","This page has unsaved changes. Please save or revert."}));
		
		return ll;
		
	}
	
	protected List<List<Object>> createDNSSettings_win(){
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
	  ll.add(Arrays.asList(new Object[]{"dns settings test: soa name","SOA&class",DNSTests.dnszone,reversezone,
			"idnssoamname","margo.test.com."}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings test: soa r name","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoarname","email.dhcp-121.sjc.redhat.com."}));
		
			ll.add(Arrays.asList(new Object[]{"dns settings: soa serial","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoaserial","2147483646"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa refresh time","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoarefresh","2400"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa retry time","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoaretry","600"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa expire time","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoaexpire","243544645"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: soa minimum time","SOA&class",DNSTests.dnszone,reversezone,
				"idnssoaminimum","2400"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: ttl: time to live","SOA&class",DNSTests.dnszone,reversezone,
				"dnsttl","1323324324"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class","SOA&class",DNSTests.dnszone,reversezone,
				"dnsclass","IN"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class","SOA&class",DNSTests.dnszone,reversezone,
				"dnsclass","CS"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class","SOA&class",DNSTests.dnszone,reversezone,
				"dnsclass","CH"}));
		ll.add(Arrays.asList(new Object[]{"dns settings: class","SOA&class",DNSTests.dnszone,reversezone,
				"dnsclass","HS"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: allow dynamic update","Dynamic Update&Policy",DNSTests.dnszone,reversezone,
				"idnsallowdynupdate-3-0","idnsallowdynupdate-3-1"}));
				
		ll.add(Arrays.asList(new Object[]{"dns settings: update policy","Bind Update policy",DNSTests.dnszone,reversezone,
				"idnsupdatepolicy","grant SJC.REDHAT.COM krb5-self * AAAA; grant SJC.REDHAT.COM krb5-self * A;"}));
		
		
		ll.add(Arrays.asList(new Object[]{"dns settings: allow query","Query&Transfer",DNSTests.dnszone,reversezone,
				"idnsallowquery-0","1.1.1.1"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: allow Transfer","Query&Transfer",DNSTests.dnszone,reversezone,
				"idnsallowtransfer-0","2.2.2.2"}));
				
		ll.add(Arrays.asList(new Object[]{"dns settings: allow Transfer","Query&Transfer",DNSTests.dnszone,reversezone,
				"idnsforwarders-0","3.3.3.3"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: forward Policy","Dynamic Update&Policy",DNSTests.dnszone,reversezone,
				"idnsforwardpolicy-4-1","idnsforwardpolicy-4-0"}));
		
		ll.add(Arrays.asList(new Object[]{"dns settings: Allow_PTR_Sync_Test","PTR Sync",DNSTests.dnszone,reversezone,
				"","This page has unsaved changes. Please save or revert."}));
		
		return ll;
		
	}
	
	//getDNSSettings_Negative 
	
	@DataProvider(name="getDNSSettings_Negative")
	public Object[][] getDNSSettings_Negative(){
		return TestNGUtils.convertListOfListsTo2dArray(createDNSSettings_Negative());
		
	}
	protected List<List<Object>> createDNSSettings_Negative(){
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
	  ll.add(Arrays.asList(new Object[]{"dns settings test: soa serial_wrongInput",DNSTests.dnszone,reversezone,
			"idnssoaserial","abc","Must be an integer","Input form contains invalid or missing values."}));
	  ll.add(Arrays.asList(new Object[]{"dns settings test: soa serial_minValue",DNSTests.dnszone,reversezone,
				"idnssoaserial","-1","Minimum value is 1","invalid 'refresh': must be at least 0"}));
	  ll.add(Arrays.asList(new Object[]{"dns settings test: soa serial_maxValue",DNSTests.dnszone,reversezone,
				"idnssoaserial","2147483648","Maximum value is 2147483647","Input form contains invalid or missing values."}));
	  
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa refresh_time_wrongInput",DNSTests.dnszone,reversezone,
				"idnssoarefresh","xyz","Must be an integer","Input form contains invalid or missing values."}));
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa refresh_time_minValue",DNSTests.dnszone,reversezone,
				"idnssoarefresh","-2","Minimum value is 1","invalid 'refresh': must be at least 0"}));
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa refresh_time_maxValue",DNSTests.dnszone,reversezone,
				"idnssoarefresh","2147483648","Maximum value is 2147483647","Input form contains invalid or missing values."}));
	  
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa retry_time_wrongInput",DNSTests.dnszone,reversezone,
				"idnssoaretry","abc","Must be an integer","Input form contains invalid or missing values."}));
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa retry_time_minValue",DNSTests.dnszone,reversezone,
				"idnssoaretry","-45","","invalid 'retry': must be at least 0"}));
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa retry_time_maxValue",DNSTests.dnszone,reversezone,
				"idnssoaretry","2147483648","Maximum value is 2147483647","Input form contains invalid or missing values."}));
	  
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa expire_time_wrongInput",DNSTests.dnszone,reversezone,
				"idnssoaexpire","abc","Must be an integer","Input form contains invalid or missing values."}));
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa expire_time_minValue",DNSTests.dnszone,reversezone,
				"idnssoaexpire","-60","","invalid 'expire': must be at least 0"}));
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa expire_time_maxValue",DNSTests.dnszone,reversezone,
				"idnssoaexpire","2147483648","Maximum value is 2147483647","Input form contains invalid or missing values."}));
	  
	  
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa minimum_time_wrongInput",DNSTests.dnszone,reversezone,
				"idnssoaminimum","qwert","Must be an integer","Input form contains invalid or missing values."}));
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa minimum_time_minValue",DNSTests.dnszone,reversezone,
				"idnssoaminimum","-10","","invalid 'minimum': must be at least 0"}));
	  ll.add(Arrays.asList(new Object[]{"dns settings: soa minimum_time_maxValue",DNSTests.dnszone,reversezone,
				"idnssoaminimum","2147483648","Maximum value is 10800","Input form contains invalid or missing values."}));
		
		
	  ll.add(Arrays.asList(new Object[]{"dns settings: ttl: time_to_live_wrongInput",DNSTests.dnszone,reversezone,
				"dnsttl","asdf","Must be an integer","Input form contains invalid or missing values."}));
	  ll.add(Arrays.asList(new Object[]{"dns settings: ttl: time_to_live_maxValue",DNSTests.dnszone,reversezone,
				"dnsttl","2147483648","Maximum value is 2147483647","Input form contains invalid or missing values."}));
	  
	  ll.add(Arrays.asList(new Object[]{"dns settings:BIND_Update_policy_With_leading_space",DNSTests.dnszone,reversezone,
			  "idnsupdatepolicy"," grant SJC.REDHAT.COM ;","invalid 'update_policy': Leading and trailing spaces are not allowed",""}));	  
	  ll.add(Arrays.asList(new Object[]{"dns settings:BIND_Update_policy_With_trailing_space",DNSTests.dnszone,reversezone,
			  "idnsupdatepolicy","grant SJC.REDHAT.COM ; ","invalid 'update_policy': Leading and trailing spaces are not allowed",""}));
	  	
	  ll.add(Arrays.asList(new Object[]{"dns settings: allow query_invalid _address",DNSTests.dnszone,reversezone,
				"idnsallowquery-0","a","Not a valid network address","Input form contains invalid or missing values."}));
	  ll.add(Arrays.asList(new Object[]{"dns settings: allow query_invalid_query",DNSTests.dnszone,reversezone,
				"idnsallowquery-0","1","","invalid 'allow_query': failed to detect a valid IP address from u'1'"}));
	 
		ll.add(Arrays.asList(new Object[]{"dns settings: allow Transfer_invalid _address",DNSTests.dnszone,reversezone,
				"idnsallowtransfer-0","a","Not a valid network address","Input form contains invalid or missing values."}));
		ll.add(Arrays.asList(new Object[]{"dns settings: allow Transfer_invalid_query",DNSTests.dnszone,reversezone,
				"idnsallowtransfer-0","1","","invalid 'allow_transfer': failed to detect a valid IP address from u'1'"}));
	  
	  
	  return ll;
		
	}
	
	
	
	@DataProvider(name="getDNSSettingsEnableDisableObject")
	public Object[][] getDNSSettingsEnableDisableObject() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSSettingsEnableDisableObjects());
	}
	protected List<List<Object>> createDNSSettingsEnableDisableObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		ll.add(Arrays.asList(new Object[]{
				// testName,  zoneName,  authoritativeNameserver,  rootEmail	
				"dns zone test", "examples.dns.test.zone",nameserver,"root." + DNSTests.dummyHost} ));  
		
		return ll;	
	}
	
	
	 
	@DataProvider(name="getNegativeDNSRecords")
	public Object[][] getNegativeDNSRecords() {
		return TestNGUtils.convertListOfListsTo2dArray(createNegativeDNSRecords());
	}
	protected List<List<Object>> createNegativeDNSRecords() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
			
		// testName,  zoneName, reverse_zone,authoritativeNameserver,rootEmail,recordName,recordData,recordType,otherData 1....otherData 11   
				
		ll.add(Arrays.asList(new Object[]{"dns record LOC negative test_Bug817878", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"loc_recordtest","42","LOC","21", "60777777777777", "N", "71", "06", "9999999999999", "W", "2000", "2", "4", "567","Maximum value is 59.999"}));
		
		return ll;	
	}
	 
	
	@DataProvider(name="getDNSRecords")
	public Object[][] getDNSRecords() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSRecords());
	}
	protected List<List<Object>> createDNSRecords() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
			
		// testName,  zoneName, reverse_zone,authoritativeNameserver,rootEmail,recordName,recordData,recordType,otherData 1....otherData 11   
		ll.add(Arrays.asList(new Object[]{"dns record A test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"a_recordtest","10.0.0.2","A","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record A6 test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"a6_recordtest","48 0::0 subscriber-bar.ip6.isp2.baz.","A6","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AFSDB test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"afsdb_recordtest",DNSTests.dummyHost,"AFSDB","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record CERT test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"cert_recordtest","PGP FDASFDSAFDAfdafdafdsaWfdasfdasfff4324535435wefdsgdft43dgdf==","CERT","1","1","1","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record CNAME test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"cname_recordtest","also-dhcp-118.sjc.redhat.com","CNAME","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DNAME test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"dname_recordtest","bar.dhcp-121.sjc.redhat.com","DNAME","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DS test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"ds_recordtest","asdf","DS","2","1","3","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record KEY test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"key_recordtest","AAAAB3NzaC1yc2EAAAABIwAAAQEApyb3ETzqAdduxDhOpODkohBKoqM4nKnGcss","KEY","1","1","1","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record KX test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"kx_recordtest","sjc.redhat.com","KX","10","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record LOC test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"loc_recordtest","42","LOC","21", "54", "N", "71", "06", "18", "W", "2000", "2", "4", "567"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record MX test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"mx_recordtest","zetaprime.lab.eng.pnq.redhat.com","MX","10","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NAPTR test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"naptr_recordtest","E2U+sip","NAPTR","100","10","P","!^.*$!sip:customer-service@example.com!","test","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NS test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"ns_recordtest",nameserver+".","NS","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"nsec_recordtest","host.example.com","NSEC","SOA","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record PTR test", 
				DNSTests.dnszone2,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"ptr_recordtest","skyfire.lab.eng.pnq.redhat.com","PTR","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record RRSIG test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"rrsig_recordtest","RRSIG","RRSIG", "7", "2", "3600", "20150420235959", "20051021000000", "40430", "mvarun",  "KimG+rDd+7VA1zRsu0ITNAQUTRlpnsmqWrihFRnU+bRa93v2e5oFNFYCs3Rqgv62K93N7AhW6Jfqj/8NzWjvKg==","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SIG test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"sig_recordtest","SSHFP","SIG","1","1","60","20120501010101","20120201010101","9","shanks","123456789","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SRV test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"srv_recordtest","server.example.com","SRV", "0", "100" ,"389","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SSHFP test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"sshfp_recordtest","123456789abcdef67890123456789abcdef67890","SSHFP","2","1","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record TXT test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"txt_recordtest","MOE     MB      A.ISI.EDU.","TXT","","","","","","","","","","",""})); 
		
		return ll;	
	}
	
	/*
	 * DNS Zone add and cancel
	 */
	
	@DataProvider(name="getDNSRecords_AddAndCancel")
	public Object[][] getDNSRecords_AddAndCancel() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSRecords_AddAndCancel());
	}
	protected List<List<Object>> createDNSRecords_AddAndCancel() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
			
		// testName,  zoneName, reverse_zone,authoritativeNameserver,rootEmail,recordName,recordData,recordType,otherData 1....otherData 11   
		ll.add(Arrays.asList(new Object[]{"dns record A test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"a_recordtest","10.0.0.2","A","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AAAA test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record A6 test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"a6_recordtest","48 0::0 subscriber-bar.ip6.isp2.baz.","A6","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record AFSDB test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"afsdb_recordtest",DNSTests.dummyHost,"AFSDB","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record CERT test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"cert_recordtest","PGP FDASFDSAFDAfdafdafdsaWfdasfdasfff4324535435wefdsgdft43dgdf==","CERT","1","1","1","","","","","","","",""}));
					
		return ll;	
	}
	
	
	
	
	
	/*
	 * DNSRecord Add And Another
	 */
	
	@DataProvider(name="getDNSRecords_addanother")
	public Object[][] getDNSRecords_addanother() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSRecords_addanother());
	}
	protected List<List<Object>> createDNSRecords_addanother() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		// testName,  zoneName, reverse_zone,authoritativeNameserver,rootEmail,recordName,recordData,recordType,otherData 1....otherData 11
		ll.add(Arrays.asList(new Object[]{"dns record A and AAAA test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"a_recordtest","10.0.0.2","A","","","","","","","","","","","" ,
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record A6 and AFSDB test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"a6_recordtest","48 0::0 subscriber-bar.ip6.isp2.baz.","A6","","","","","","","","","","","",
				"afsdb_recordtest",DNSTests.dummyHost,"AFSDB","","","","","","","","","","",""})); 
		
				
		ll.add(Arrays.asList(new Object[]{"dns record CERT and CNAME test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"cert_recordtest","PGP FDASFDSAFDAfdafdafdsaWfdasfdasfff4324535435wefdsgdft43dgdf==","CERT","1","1","1","","","","","","","","",
				"cname_recordtest","also-dhcp-118.sjc.redhat.com","CNAME","","","","","","","","","","",""}));   
		
		ll.add(Arrays.asList(new Object[]{"dns record DNAME and DS test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"dname_recordtest","bar.dhcp-121.sjc.redhat.com","DNAME","","","","","","","","","","","",
				"ds_recordtest","asdf","DS","2","1","3","","","","","","","",""})); 
		
		ll.add(Arrays.asList(new Object[]{"dns record KEY and MX test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"key_recordtest","AAAAB3NzaC1yc2EAAAABIwAAAQEApyb3ETzqAdduxDhOpODkohBKoqM4nKnGcss","KEY","1","1","1","","","","","","","","",
				"mx_recordtest","zetaprime.lab.eng.pnq.redhat.com","MX","10","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record KX and LOC test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"kx_recordtest","sjc.redhat.com","KX","10","","","","","","","","","","",
				"loc_recordtest","42","LOC","21", "54", "N", "71", "06", "18", "W", "2000", "2", "4", "567"}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NAPTR and NS test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"naptr_recordtest","E2U+sip","NAPTR","100","10","P","!^.*$!sip:customer-service@example.com!","test","","","","","","",
				"ns_recordtest",nameserver,"NS","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC and PTR test", 
				DNSTests.dnszone2,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"nsec_recordtest","host.example.com","NSEC","SOA","","","","","","","","","","",
				"ptr_recordtest","skyfire.lab.eng.pnq.redhat.com","PTR","","","","","","","","","","",""}));  
		
		ll.add(Arrays.asList(new Object[]{"dns record RRSIG and SIG test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"rrsig_recordtest","RRSIG","RRSIG", "7", "2", "3600", "20150420235959", "20051021000000", "40430", "mvarun",  "KimG+rDd+7VA1zRsu0ITNAQUTRlpnsmqWrihFRnU+bRa93v2e5oFNFYCs3Rqgv62K93N7AhW6Jfqj/8NzWjvKg==","","","",
				"sig_recordtest","SSHFP","SIG","1","1","60","20120501010101","20120201010101","9","shanks","123456789","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SRV and SSHFP test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"srv_recordtest","server.example.com","SRV", "0", "100" ,"389","","","","","","","","",
				"sshfp_recordtest","123456789abcdef67890123456789abcdef67890","SSHFP","2","1","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NS and TXT test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"ns_recordtest",nameserver,"NS","","","","","","","","","","","",
				"txt_recordtest","MOE     MB      A.ISI.EDU.","TXT","","","","","","","","","","",""}));
		
		return ll;	
	}
	
	
	
	
	
	/*
	 * Add DNS Zone - Negative Test
	 */
	
	@DataProvider(name="getDNSZoneNegativeObjects")
	public Object[][] getDNSZoneNegativeObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSZoneNegativeObjects());
	}
	protected List<List<Object>> createDNSZoneNegativeObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
		ll.add(Arrays.asList(new Object[]{
				// testName,             			        zoneName,                           authoritativeNameserver,        rootEmail	                expectedError
				"dns_zone_name_with_leading_Space", " example.dns.test.zone"                     ,nameserver,"root." + DNSTests.dummyHost, "invalid 'name': Leading and trailing spaces are not allowed"} )); 
		ll.add(Arrays.asList(new Object[]{
				"dns_zone_name_with_trailing_Space", "example.dns.test.zone "                    ,nameserver,"root." + DNSTests.dummyHost, "invalid 'name': Leading and trailing spaces are not allowed"} ));
		ll.add(Arrays.asList(new Object[]{
				"dns_zone_name_with_Special_char",    "!@#$%"                                    ,nameserver,"root." + DNSTests.dummyHost, "invalid 'name': only letters, numbers, and - are allowed. DNS label may not start or end with -"} ));
		ll.add(Arrays.asList(new Object[]{
				"dns_long_zone_name" ,            "longgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg.dns.test.zone",nameserver,"root." + DNSTests.dummyHost, "invalid 'name': DNS label cannot be longer that 63 characters"} ));
		ll.add(Arrays.asList(new Object[]{		
				"dns_zone_name_with_blank_Space",		 ""				                          ,nameserver,"root." + DNSTests.dummyHost, "Required field"} ));
		ll.add(Arrays.asList(new Object[]{		
				"name_server_with_blank_Space",		 "example.dns.test.zone"				                          ,"","root." + DNSTests.dummyHost, "Required field"} ));
		ll.add(Arrays.asList(new Object[]{
				"dns_duplicate_zone_name",         DNSTests.dnszone                               ,nameserver,"root." + DNSTests.dummyHost,"DNS zone with name \"sahi.dns.test.zone\" already exists"} ));  
		ll.add(Arrays.asList(new Object[]{
				"name_server_with_leading_Space", "example.dns.test.zone"                    ," bluesteak.lab.eng.pnq.redhat.com","root." + DNSTests.dummyHost, "invalid 'name_server': Leading and trailing spaces are not allowed"} ));
		ll.add(Arrays.asList(new Object[]{
				"name_server_with_trailing_Space", "example.dns.test.zone"                    ,"bluesteak.lab.eng.pnq.redhat.com ","root." + DNSTests.dummyHost, "invalid 'name_server': Leading and trailing spaces are not allowed"} ));
		ll.add(Arrays.asList(new Object[]{
				"wrong_name_server",              "example.dns.test.zone"                    ,"bluesteak.redhat.com","root." + DNSTests.dummyHost, "Nameserver 'bluesteak.redhat.com' does not have a corresponding A/AAAA record"} ));
	    ll.add(Arrays.asList(new Object[]{
				"admin_email_with_leading_Space", "example.dns.test.zone"                    ,nameserver," root.dummyhost.lab.eng.pnq.redhat.com", "invalid 'admin_email': Leading and trailing spaces are not allowed"} ));
		ll.add(Arrays.asList(new Object[]{
				"admin_email_with_trailing_Space", "example.dns.test.zone"                    ,nameserver,"root.dummyhost.lab.eng.pnq.redhat.com ", "invalid 'admin_email': Leading and trailing spaces are not allowed"} ));
		ll.add(Arrays.asList(new Object[]{
				"wrong_admin_email",               "example.dns.test.zone"                    ,nameserver,"root!&#$"                              , "invalid 'admin_email': missing address domain"} ));
		ll.add(Arrays.asList(new Object[]{
				"wrong_admin_email_with_toomany_@@","example.dns.test.zone"                    ,nameserver,"root@@@redhat.com"                              , "invalid 'admin_email': too many '@' characters"} ));
		return ll;	
	}
	
	/*
	 * DNS add and edit
	 */
	
	@DataProvider(name="getDNSZone_edit")
	public Object[][] getDNSZone_edit() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSZone_edit());
	}
	protected List<List<Object>> createDNSZone_edit() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		// testName, zoneName, authoritativeNameserver, rootEmail,record_name, record_data, record_type
		ll.add(Arrays.asList(new Object[]{"Zone_edit_A ", "example.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","","",
				"a_recordtest","10.0.0.2","A","","","","","","","","","","","" ,
				"a_recordtest","10.1.1.1","A","","","","","","","","","","","",
				"a_recordtest","10.1.1.3","A","","","","","","","","","","","","no modifications to be performed"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_AAAA", "example.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"a_recordtest","10.0.0.2","A","","","","","","","","","","","" ,
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","","",
				"aaaa_recordtest","fe80::216:36ff:fe23:8aa1","AAAA","","","","","","","","","","","",
				"aaaa_recordtest","fe80::216:36ff:fe23:7aa1","AAAA","","","","","","","","","","","","no modifications to be performed"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_A6", "demo.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"a_recordtest","10.0.0.3","A","","","","","","","","","","","" ,
				"a6_recordtest","48 0::0 subscriber-bar.ip6.isp2.baz.","A6","","","","","","","","","","","",
				"a6_recordtest","47 0::0 subscriber-bar.ip6.isp2.baz.","A6","","","","","","","","","","","",
				"a6_recordtest","45 0::0 subscriber-bar.ip6.isp2.baz.","A6","","","","","","","","","","","","no modifications to be performed"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_AFSDB", "demo.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"a_recordtest","10.0.0.4","A","","","","","","","","","","","" ,
				"afsdb_recordtest","bumblebee.lab.eng.pnq.redhat.com","AFSDB","1","","","","","","","","","","",
				"afsdb_recordtest","zeta.lab.eng.pnq.redhat.com","AFSDB","2","","","","","","","","","","",
				"afsdb_recordtest","tera.lab.eng.pnq.redhat.com","AFSDB","3","","","","","","","","","","","no modifications to be performed"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_CERT", "demo.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"a_recordtest","10.0.0.4","A","","","","","","","","","","","" ,
				"cert_recordtest","1","CERT","1","1","1","","","","","","","","",
				"cert_recordtest","2","CERT","2","2","2","","","","","","","","",
				"cert_recordtest","3","CERT","3","3","3","","","","","","","","","no modifications to be performed"}));
		
	ll.add(Arrays.asList(new Object[]{"Zone_edit_CNAME ", "200.65.10.in-addr.arpa.",nameserver,"root." + DNSTests.dummyHost,				 
				
				"ptr_recordtest","skyfire.lab.eng.pnq.redhat.com.","PTR","","","","","","","","","","","",
				"cname_recordtest","also-dhcp-118.sjc.redhat.com","CNAME","","","","","","","","","","","",
				"cname_recordtest","zetaprime.lab.eng.pnq.redhat.com","CNAME","","","","","","","","","","","",
				"cname_recordtest","bumblebee.lab.eng.pnq.redhat.com","CNAME","","","","","","","","","","","","no modifications to be performed"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_DNAME", "demo.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"a_recordtest","10.0.0.4","A","","","","","","","","","","","" ,
				"dname_recordtest","bumblebee.lab.eng.pnq.redhat.com","DNAME","","","","","","","","","","","",
				"dname_recordtest","zetaprime.lab.eng.pnq.redhat.com","DNAME","","","","","","","","","","","",
				"dname_recordtest","bar.dhcp-121.sjc.redhat.com","DNAME","","","","","","","","","","","","no modifications to be performed"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_DS ", "example.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","","",
				"ds_recordtest","asdf","DS","2","1","3","","","","","","","","",
				"ds_recordtest","lkjj","DS","2","2","3","","","","","","","","",
				"ds_recordtest","xyza","DS","3","1","3","","","","","","","","","no modifications to be performed"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_KEY", "demo.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"a_recordtest","10.0.0.4","A","","","","","","","","","","","" ,
				"key_recordtest","AAAAB3NzaC1yc2EAAAABIwAAAQEApyb3ETzqAdduxDhOpODkohBKoqM4nKnGcss","KEY","1","1","1","","","","","","","","",
				"key_recordtest","AAAAB3NzaC1yc2EAAAABIwAAAQEApyb3ETzqAdduxDhOpODkohBKoqM4nKnGcss","KEY","1","2","1","","","","","","","","",
				"key_recordtest","AAAAB3NzaC1yc2EAAAABIwAAAQEApyb3ETzqAdduxDhOpODkohBKoqM4nKnGcss","KEY","1","1","2","","","","","","","","","no modifications to be performed"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_KX ", "example.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","","",
				"kx_recordtest","sjc.redhat.com","KX","20","","","","","","","","","","",
				"kx_recordtest","sjc.redhat.com","KX","30","","","","","","","","","","",
				"kx_recordtest","sjc.redhat.com","KX","10","","","","","","","","","","","no modifications to be performed"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_LOC", "demo.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"a_recordtest","10.0.0.4","A","","","","","","","","","","","" ,
				"loc_recordtest","42","LOC","21", "54", "N", "71", "11", "18", "W", "2000", "2", "4", "567",
				"loc_recordtest","39","LOC","41", "24", "N", "51", "11", "12", "W", "3000", "3", "5", "347",
				"loc_recordtest","40","LOC","31", "34", "N", "41", "11", "22", "W", "1000", "7", "3", "577","42 21 54.000 N 71 11 18.000 W 2000.00 2.00 4.00 567.00"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_MX ", "example.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","","",
				"mx_recordtest","tera.lab.eng.pnq.redhat.com","MX","11","","","","","","","","","","",
				"mx_recordtest","blue.lab.eng.pnq.redhat.com","MX","14","","","","","","","","","","",
				"mx_recordtest","zetaprime.lab.eng.pnq.redhat.com","MX","10","","","","","","","","","","","no modifications to be performed"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_NAPTR", "demo.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"a_recordtest","10.0.0.4","A","","","","","","","","","","","" ,
				"naptr_recordtest","E2U+sip","NAPTR","130","12","P","!^.*$!sip:customer-service@example.com!","test","","","","","","",
				"naptr_recordtest","E2U+sip","NAPTR","140","11","P","!^.*$!sip:customer-service@example.com!","test","","","","","","",
				"naptr_recordtest","E2U+sip","NAPTR","100","10","P","!^.*$!sip:customer-service@example.com!","test","","","","","","","130 12 P E2U+sip !^.*$!sip:customer-service@example.com! test"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_NS ", "example.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","","",
				"ns_recordtest","margo.test.com.","NS","","","","","","","","","","","",
				"ns_recordtest","ipaqa64vmb.test.com.","NS","","","","","","","","","","","",
				"ns_recordtest","zetaprime.test.com.","NS","","","","","","","","","","","","no modifications to be performed"}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_NSEC", "demo.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"a_recordtest","10.0.0.4","A","","","","","","","","","","","" ,
				"nsec_recordtest","host.example.com","NSEC","SOA","","","","","","","","","","",
				"nsec_recordtest","secondhost.example.com","NSEC","A","","","","","","","","","","",
				"nsec_recordtest","newhost.example.com","NSEC","AAAA","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_PTR ", "200.65.10.in-addr.arpa.",nameserver,"root." + DNSTests.dummyHost,				 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","","",
				"ptr_recordtest","skyfire.lab.eng.pnq.redhat.com.","PTR","","","","","","","","","","","",
				"ptr_recordtest","redeye.lab.eng.pnq.redhat.com.","PTR","","","","","","","","","","","",
				"ptr_recordtest","skyfall.lab.eng.pnq.redhat.com.","PTR","","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_RRSIG ", "example.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","","",
				"rrsig_recordtest","RRSIG","RRSIG", "7", "2", "3600", "20150420235959", "20051021000000", "40430", "mvarun",  "KimG+rDd+7VA1zRsu0ITNAQUTRlpnsmqWrihFRnU+bRa93v2e5oFNFYCs3Rqgv62K93N7AhW6Jfqj/8NzWjvKg==","","","",
				"rrsig_recordtest","RRSIG","RRSIG", "7", "2", "3600", "20150420235959", "20051021000000", "40430", "yizhang",  "KimG+rDd+7VA1zRsu0ITNAQUTRlpnsmqWrihFRnU+bRa93v2e5oFNFYCs3Rqgv62K93N7AhW6Jfqj/8NzWjvKg==","","","",
				"rrsig_recordtest","RRSIG","RRSIG", "6", "3", "3600", "20150420235959", "20051021000000", "40430", "nkrishnan",  "KimG+rDd+7VA1zRsu0ITNAQUTRlpnsmqWrihFRnU+bRa93v2e5oFNFYCs3Rqgv62K93N7AhW6Jfqj/8NzWjvKg==","","","","RRSIG 7 2 3600 20150420235959 20051021000000 40430 mvarun KimG+rDd+7VA1zRsu0ITNAQUTRlpnsmqWrihFRnU+bRa93v2e5oFNFYCs3Rqgv62K93N7AhW6Jfqj/8NzWjvKg=="}));
				
		ll.add(Arrays.asList(new Object[]{"Zone_edit_SIG", "demo.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"a_recordtest","10.0.0.4","A","","","","","","","","","","","" ,
				"sig_recordtest","SSHFP","SIG","1","1","60","20120501010101","20120201010101","9","shanks","123456789","","","",
				"sig_recordtest","SSHFP","SIG","2","1","40","20110102040102","20110303050101","9","mvarun","123456789","","","",
				"sig_recordtest","SSHFP","SIG","3","1","50","20120501010101","20120201010101","8","nkrishnan","123456789","","","","SSHFP 1 1 60 20120501010101 20120201010101 9 shanks 123456789"}));
				
		ll.add(Arrays.asList(new Object[]{"Zone_edit_SRV ", "example.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","","",
				"srv_recordtest","server.example.com","SRV", "0", "100" ,"389","","","","","","","","",
				"srv_recordtest","blue.example.com","SRV", "1", "80" ,"380","","","","","","","","",
				"srv_recordtest","newserver.example.com","SRV", "0", "90" ,"389","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_SSHFP", "demo.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"a_recordtest","10.0.0.4","A","","","","","","","","","","","" ,
				"sshfp_recordtest","123456789abcdef67890123456789abcdef67890","SSHFP","2","1","","","","","","","","","",
				"sshfp_recordtest","123456789abcdef67890123456789abcdef67890","SSHFP","3","1","","","","","","","","","",
				"sshfp_recordtest","123456789abcdef67890123456789abcdef67890","SSHFP","1","1","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"Zone_edit_TXT_And_Expand_collapse_test ", "example.dns.test.zone",nameserver,"root." + DNSTests.dummyHost,				 
				"aaaa_recordtest","fe80::216:36ff:fe23:9aa1","AAAA","","","","","","","","","","","",
				"txt_recordtest","text","TXT","","","","","","","","","","","",
				"txt_recordtest","simple text","TXT","","","","","","","","","","","",
				"txt_recordtest","MOE     MB      A.ISI.EDU.","TXT","","","","","","","","","","","",""}));
				
		return ll;	
	}
	
	
	/*
	 * Add DNS Record Type - Negative Test
	 */
	@DataProvider(name="getDNSNegativeRecordType")
	public Object[][] getDNSNegativeRecordType() {
		return TestNGUtils.convertListOfListsTo2dArray(createDNSNegativeRecordType());
	}
	protected List<List<Object>> createDNSNegativeRecordType() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
			
		
		ll.add(Arrays.asList(new Object[]{"record_name_with_blankspace", 
				DNSTests.dnszone,"","10.0.0.2","A","","","","","","","","","","","","Required field"}));
		ll.add(Arrays.asList(new Object[]{"record_name_with_leadingSpace", 
				DNSTests.dnszone," arecord","10.0.0.2","A","","","","","","","","","","","","invalid 'name': Leading and trailing spaces are not allowed"}));
		ll.add(Arrays.asList(new Object[]{"record_name_with_trailingSpace", 
				DNSTests.dnszone,"arecord ","10.0.0.2","A","","","","","","","","","","","","invalid 'name': Leading and trailing spaces are not allowed"}));
		ll.add(Arrays.asList(new Object[]{"record_name_with_trailingSpace", 
				DNSTests.dnszone,"longaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaarecord","10.0.0.2","A","","","","","","","","","","","","invalid 'name': DNS label cannot be longer that 63 characters"}));
		ll.add(Arrays.asList(new Object[]{"wrong_ipv4_address", 
				DNSTests.dnszone,"","10.0.0","A","","","","","","","","","","","","Not a valid IPv4 address"}));
		ll.add(Arrays.asList(new Object[]{"wrong_ipv6_address", 
				DNSTests.dnszone,"aaaa_recordtest","12.1.11.1","AAAA","","","","","","","","","","","","Not a valid IPv6 address"}));
		ll.add(Arrays.asList(new Object[]{"wrong_CertificateType", 
				DNSTests.dnszone,"cert_recordtest","PGP FDASFDSAFDAfdafdafdsaWfdasfdasfff4324535435wefdsgdft43dgdf==","CERT","a","1","1","","","","","","","","","Must be an integer"}));
		ll.add(Arrays.asList(new Object[]{"wrong_KeyTag", 
				DNSTests.dnszone,"cert_recordtest","PGP FDASFDSAFDAfdafdafdsaWfdasfdasfff4324535435wefdsgdft43dgdf==","CERT","1","k","1","","","","","","","","","Must be an integer"}));
		ll.add(Arrays.asList(new Object[]{"wrong_Algorithm", 
				DNSTests.dnszone,"cert_recordtest","PGP FDASFDSAFDAfdafdafdsaWfdasfdasfff4324535435wefdsgdft43dgdf==","CERT","1","1","a","","","","","","","","","Must be an integer"}));
		ll.add(Arrays.asList(new Object[]{"wrong_TypeMap", 
				DNSTests.dnszone,"nsec_recordtest","host.example.com","NSEC","SOss","","","","","","","","","","","error_dialog"}));
		
		
		
		return ll;	
	}
	
	
	
	/*
	 * delete DNS zone
	 */
	
	@DataProvider(name="getdelDNSZoneObjects")
	public Object[][] getdelDNSZoneObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createdelDNSZoneObjects());
	}
	protected List<List<Object>> createdelDNSZoneObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		ll.add(Arrays.asList(new Object[]{
				// testName,  zoneName,  authoritativeNameserver,  rootEmail	
				"deleting_dns zone", DNSTests.dnszone,nameserver,"root." + DNSTests.dummyHost} ));  
		ll.add(Arrays.asList(new Object[]{
				// testName,  zoneName,  authoritativeNameserver,  rootEmail	
				"deleting_dns zone", DNSTests.dnszone2,nameserver,"root." + DNSTests.dummyHost} ));  
		ll.add(Arrays.asList(new Object[]{
				// testName,  zoneName,  authoritativeNameserver,  rootEmail	
				"deleting_dns zone","zeta.dns.test.zone",nameserver,"root." + DNSTests.dummyHost} ));  
		ll.add(Arrays.asList(new Object[]{
				// testName,  zoneName,  authoritativeNameserver,  rootEmail	
				"deleting_dns zone", "tera.dns.test.zone",nameserver,"root." + DNSTests.dummyHost} )); 
		return ll;	
	}
	
	
	
	/*////////////////////////////////////////////////////////
	 *                                                      //
	 *           DNS REVERSE ZONE DATA PROVIDER             //          
	 *                                                      //      
	 *////////////////////////////////////////////////////////
	
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
				// testName,              zoneIP,        reverszonename ,          authoritativeNameserver,        rootEmail	
				"dns reverse zone test", zoneIP, 	   reversezone, nameserver,           "root." + DNSTests.dummyHost} )); 
		return ll;	
	}//Data provider: getReverseDNSZoneObjects 
	
	/*
	 * Add And Another DNS Reverse Zone
	 */
	@DataProvider(name="getAddAndAnotherReverseDNSZoneObjects")
	public Object[][] getAddAndAnotherReverseDNSZoneObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAddAndAnotherReverseDNSZoneObjects());
	}
	protected List<List<Object>> createAddAndAnotherReverseDNSZoneObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
		ll.add(Arrays.asList(new Object[]{
				// testName,              zoneIP,        reverszonename ,          authoritativeNameserver,        rootEmail	
				"Add and Another dns reverse zone test", "10.35.213.0/24",  "213.35.10.in-addr.arpa.", nameserver,           "root." + DNSTests.dummyHost, "10.35.214.0/24",  "214.35.10.in-addr.arpa."} )); 
		
		return ll;	
	}//
	
	
	/*
	 *reverseDNSZoneRecordsTest_add 
	 */
	@DataProvider(name="getReverseDNSRecords")
	public Object[][] getReverseDNSRecords() {
		return TestNGUtils.convertListOfListsTo2dArray(createReverseDNSRecords());
	}
	protected List<List<Object>> createReverseDNSRecords() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
			
		// testName,  zoneName, reverse_zone,authoritativeNameserver,rootEmail,recordName,recordData,recordType,otherData 1....otherData 11   
		
			
		ll.add(Arrays.asList(new Object[]{"dns record MX test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"mx_recordtest","zetaprime.lab.eng.pnq.redhat.com","MX","10","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NAPTR test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"naptr_recordtest","E2U+sip","NAPTR","100","10","P","!^.*$!sip:customer-service@example.com!","test","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NS test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"ns_recordtest",nameserver+".","NS","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"nsec_recordtest","host.example.com","NSEC","SOA","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record PTR test", 
				DNSTests.dnszone2,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
		     	"ptr_recordtest","skyfire.lab.eng.pnq.redhat.com","PTR","","","","","","","","","","",""}));
						
		return ll;	
	}
	/*
	 * reverseDNS Record add and another 
	 */
	@DataProvider(name="getReverseDNSRecords_addanother")
	public Object[][] getReverseDNSRecords_addanother() {
		return TestNGUtils.convertListOfListsTo2dArray(createReverseDNSRecords_addanother());
	}
	protected List<List<Object>> createReverseDNSRecords_addanother() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		// testName,  zoneName, reverse_zone,authoritativeNameserver,rootEmail,recordName,recordData,recordType,otherData 1....otherData 11
				
		ll.add(Arrays.asList(new Object[]{"dns record NAPTR and NS test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"naptr_recordtest","E2U+sip","NAPTR","100","10","P","!^.*$!sip:customer-service@example.com!","test","","","","","","",
				"ns_recordtest",nameserver,"NS","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NSEC and PTR test", 
				DNSTests.dnszone2,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"nsec_recordtest","host.example.com","NSEC","SOA","","","","","","","","","","",
				"ptr_recordtest","skyfire.lab.eng.pnq.redhat.com","PTR","","","","","","","","","","",""}));  
		
		ll.add(Arrays.asList(new Object[]{"dns record RRSIG and SIG test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"rrsig_recordtest","RRSIG","RRSIG", "7", "2", "3600", "20150420235959", "20051021000000", "40430", "mvarun",  "KimG+rDd+7VA1zRsu0ITNAQUTRlpnsmqWrihFRnU+bRa93v2e5oFNFYCs3Rqgv62K93N7AhW6Jfqj/8NzWjvKg==","","","",
				"sig_recordtest","SSHFP","SIG","1","1","60","20120501010101","20120201010101","9","shanks","123456789","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record SRV and SSHFP test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"srv_recordtest","server.example.com","SRV", "0", "100" ,"389","","","","","","","","",
				"sshfp_recordtest","123456789abcdef67890123456789abcdef67890","SSHFP","2","1","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record NS and TXT test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"ns_recordtest",nameserver,"NS","","","","","","","","","","","",
				"txt_recordtest","MOE     MB      A.ISI.EDU.","TXT","","","","","","","","","","",""}));
		
		return ll;	
	}
	
	/*
	 * ReverseDnsZoneRecordAddAndEdit
	 */
	@DataProvider(name="getReverseDNSRecordAddAndEdit")
	public Object[][] getReverseDNSRecordAddAndEdit() {
		return TestNGUtils.convertListOfListsTo2dArray(createReverseDNSRecordAddAndEdit());
	}
	protected List<List<Object>> createReverseDNSRecordAddAndEdit() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
			
		// testName,  zoneName, reverse_zone,authoritativeNameserver,rootEmail,recordName,recordData,recordType,otherData 1....otherData 11   
				
		ll.add(Arrays.asList(new Object[]{"dns record CNAME test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"cname_recordtest","also-dhcp-118.sjc.redhat.com","CNAME","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DNAME test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"dname_recordtest","bar.dhcp-121.sjc.redhat.com","DNAME","","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record DS test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"ds_recordtest","asdf","DS","2","1","3","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record KEY test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"key_recordtest","AAAAB3NzaC1yc2EAAAABIwAAAQEApyb3ETzqAdduxDhOpODkohBKoqM4nKnGcss","KEY","1","1","1","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record KX test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"kx_recordtest","sjc.redhat.com","KX","10","","","","","","","","","",""}));
		
		ll.add(Arrays.asList(new Object[]{"dns record LOC test", 
				DNSTests.dnszone,DNSTests.reversezone,nameserver,"root." + DNSTests.dummyHost, 
				"loc_recordtest","42","LOC","21", "54", "N", "71", "06", "18", "W", "2000", "2", "4", "567"}));
		
		
		
		return ll;	
	}
	
	
	/*
	 * Delete DNS Reverse Zone
	 */
	@DataProvider(name="getDelReverseDNSZoneObjects")
	public Object[][] getDelReverseDNSZoneObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelReverseDNSZoneObjects());
	}
	protected List<List<Object>> createDelReverseDNSZoneObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
		ll.add(Arrays.asList(new Object[]{
				// testName,              zoneIP,        reverszonename ,          authoritativeNameserver,        rootEmail	
				"Delete dns reverse zone test001", zoneIP, 	   reversezone, nameserver,           "root." + DNSTests.dummyHost} )); 
		ll.add(Arrays.asList(new Object[]{
				"Delete dns reverse zone test002", "10.35.213.0/24",  "213.35.10.in-addr.arpa.", nameserver,           "root." + DNSTests.dummyHost} )); 
		ll.add(Arrays.asList(new Object[]{
				"Delete dns reverse zone test003", "10.35.214.0/24",  "214.35.10.in-addr.arpa.", nameserver,           "root." + DNSTests.dummyHost} )); 
		return ll;	
	}
	
	/*
	 * Add DNS Reverse Zone - Negative Test
	 */
	@DataProvider(name="getReverseDNSZoneNegativeTestObjects")
	public Object[][] getReverseDNSZoneNegativeTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createReverseDNSZoneNegativeTestObjects());
	}
	protected List<List<Object>> createReverseDNSZoneNegativeTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();  
		 
		ll.add(Arrays.asList(new Object[]{
				"dns reverse zone with blank space", "",        nameserver,           "root." + DNSTests.dummyHost,"Required field"} )); 
		ll.add(Arrays.asList(new Object[]{
				"dns reverse zone with wrong IP", "10.35.214",  nameserver,           "root." + DNSTests.dummyHost,"Not a valid network address"} )); 
		return ll;
	}
	
	
	
}//class DNSTest
