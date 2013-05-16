package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;

import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;



public class DNSTasks {
	private static Logger log = Logger.getLogger(HostTasks.class.getName());
	/*
	 * Add DNS zone
	 * @param browser 
	 * @param zoneName
	 * @param authoritativeNameserver
	 * @param rootEmail
	 */
	public static void negativeTests(SahiTasks browser,String expectedError)
	{
		if (browser.span(expectedError).exists())
		{
			log.info ("Required field msg appears, usually this means missing data input");
			browser.button("Cancel").click();
			
		}
		 else if (browser.div(expectedError).exists())
		{
			log.info("IPA error dialog appears:: ExpectedError ::"+expectedError);
			// there will be two cancel button here
			browser.button("Cancel").click();
			browser.button("Cancel").click();
			
		}
	}
	
	public static void addDNSzone(SahiTasks browser, String zoneName, String authoritativeNameserver, String rootEmail) {
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(zoneName);
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail); 
		browser.button("Add").click();  
		// self-check
		Assert.assertTrue(browser.link(zoneName).exists(),"assert "+zoneName+"  in the zone list");
	}//addDNSzone
	
	/*
	 * dNSzoneEnableDisable
	 */
	public static void dNSzoneEnableDisable(SahiTasks browser, String zoneName,String linkToCkick,String expectedMsg,String status) {
		//browser.checkbox(zoneName).click();
		browser.checkbox(zoneName).click();
		browser.span(linkToCkick).click();	
		Assert.assertTrue(browser.div(expectedMsg).exists(),"Expected Message :: "+expectedMsg);
		browser.button("OK").click();
		Assert.assertTrue(browser.div(status).near(browser.div(zoneName)).exists(),"Verify DNSZone is "+status+" sucessfully");
		browser.checkbox(zoneName).click();
			
	}
	
	
	
	/*
	 * DNS Zone add and another
	 */
	
	public static void addandanotherDNSzone(SahiTasks browser, String zoneName1, String authoritativeNameserver, String rootEmail,String zoneName2) {
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(zoneName1);
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail); 
		browser.button("Add and Add Another").click(); 
		browser.textbox("idnsname").setValue(zoneName2);
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail); 
		browser.button("Add").click();  
		// self-check
		Assert.assertTrue(browser.link(zoneName1).exists(),"assert "+zoneName1+"  in the zone list");
		Assert.assertTrue(browser.link(zoneName2).exists(),"assert "+zoneName2+"  in the zone list");
	}
	
	/*
	 * DNS Zone Add and cancel
	 */
	public static void add_then_cancel_DNSzone(SahiTasks browser, String zoneName, String authoritativeNameserver, String rootEmail) {
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(zoneName);
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail); 
		browser.button("Cancel").click();  
		// self-check
		Assert.assertFalse(browser.link(zoneName).exists(),"assert "+zoneName+" not in the zone list");
	}
	
	 /*
	  * Add DNS Zone negativeTest
	  */
	
	
	public static void addDNSzoneNegativeTest(SahiTasks browser, String zoneName, String authoritativeNameserver, String rootEmail, String expectedError) {
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(zoneName);
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail);
		browser.button("Add").click();  
		
		DNSTasks.negativeTests(browser, expectedError);
		
		// self-check
		if(!zoneName.equals("")&&(!authoritativeNameserver.equals(""))&&(!rootEmail.equals("")&&(!zoneName.equals("sahi.dns.test.zone"))))
		Assert.assertFalse(browser.link(zoneName).exists(),"assert "+zoneName+" not in the zone list");
	}
	
	
	/*
	 * DNS zone add and edit
	 * This tests covers DNS Zone add_and_edit, add_and_edit Record type, add and  add_and_another Record type, edit Record type, update Record type, update without modify Record type, delete  Record type , Expand and collapse test
	 */
	public static void dnsZone_addandedit(SahiTasks browser, String zoneName, String authoritativeNameserver, String rootEmail,
			String first_record_name, String first_record_data, String first_record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
			String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11,
			
			String second_record_name, String second_record_data, String second_record_type,String sec_other_data1, String sec_other_data2,String sec_other_data3,String sec_other_data4,String sec_other_data5,
			String sec_other_data6,String sec_other_data7,String sec_other_data8,String sec_other_data9,String sec_other_data10,String sec_other_data11,
			
			String third_record_name, String third_record_data, String third_record_type,String third_other_data1, String third_other_data2,String third_other_data3,String third_other_data4,String third_other_data5,
			String third_other_data6,String third_other_data7,String third_other_data8,String third_other_data9,String third_other_data10,String third_other_data11,
			
			String edit_record_name, String edit_record_data, String edit_record_type,String edit_other_data1, String edit_other_data2,String edit_other_data3,String edit_other_data4,String edit_other_data5,
			String edit_other_data6,String edit_other_data7,String edit_other_data8,String edit_other_data9,String edit_other_data10,String edit_other_data11,String cdata_or_expectedMsg){
		
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(zoneName);
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail);
		browser.button("Add and Edit").click();
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(first_record_name);
		browser.select("record_type").choose(first_record_type);
		DNSTasks.recordType(browser, first_record_data, first_record_type, other_data1, other_data2, other_data3, other_data4, other_data5, other_data6, other_data7, other_data8, other_data9, other_data10, other_data11);
		browser.button("Add and Edit").click();
		
		if(second_record_type.equals("A"))
		{
		browser.span("Add").in(browser.div("DeleteAdd").near(browser.tableHeader("IP Address").near(browser.table("search-table").near(browser.label("A:"))))).click();
		browser.textbox("a_part_ip_address").setValue(second_record_data);
		browser.button("Add and Add Another").click();
		browser.textbox("a_part_ip_address").setValue(third_record_data);
		browser.button("Add").click();
		Assert.assertTrue(browser.div(second_record_data).exists(),"successfully A_Record added");
		browser.link("Edit").near(browser.div(second_record_data)).click();
		browser.button("Update").click();
		//clicking update without modify
		Assert.assertTrue(browser.div(cdata_or_expectedMsg).exists(),"Verified expected message");
		//verifying retry button
		browser.button("Retry").click();
		browser.button("Cancel").near(browser.button("Retry")).click();
		browser.link("Edit").near(browser.div(second_record_data)).click();
		browser.textbox("a_part_ip_address").setValue(edit_record_data);
		browser.button("Update").click();
		Assert.assertTrue(browser.div(edit_record_data).exists(),"successfully A_Record updated");
		browser.checkbox("arecord").click();
		browser.span("Delete").in(browser.div("DeleteAdd").near(browser.tableHeader("IP Address").near(browser.table("search-table").near(browser.label("A:"))))).click();
		browser.button("Delete").click();
		Assert.assertFalse(browser.div(edit_record_data).exists(),"All A_Record deleted");
		}
		
		if(second_record_type.equals("AAAA"))
		{
			browser.span("Add").in(browser.div("DeleteAdd").near(browser.tableHeader("IP Address").near(browser.table("search-table").near(browser.label("AAAA:"))))).click();
			browser.textbox("aaaa_part_ip_address").setValue(second_record_data);
			browser.button("Add and Add Another").click();
			browser.textbox("aaaa_part_ip_address").setValue(third_record_data);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(second_record_data).exists(),"successfully AAAA_Record added");
			browser.link("Edit").near(browser.div(second_record_data)).click();
			browser.textbox("aaaa_part_ip_address").setValue(edit_record_data);
			browser.button("Update").click();
			browser.checkbox("aaaarecord").click();
			browser.span("Delete").in(browser.div("DeleteAdd").near(browser.tableHeader("IP Address").near(browser.table("search-table").near(browser.label("AAAA:"))))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All AAAA_Record deleted");
		}
		
		if(second_record_type.equals("A6"))
		{
			browser.span("Add").in(browser.div("DeleteAdd").near(browser.div("Record data"))).click();
			browser.textbox("a6_part_data").setValue(second_record_data);
			browser.button("Add and Add Another").click();
			browser.textbox("a6_part_data").setValue(third_record_data);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(second_record_data).exists(),"successfully A6_Record added");
			browser.link("Edit").near(browser.div(second_record_data)).click();
			browser.textbox("a6_part_data").setValue(edit_record_data);
			browser.button("Update").click();
			browser.checkbox("a6record").click();
			browser.span("Delete").in(browser.div("DeleteAdd").near(browser.div("Record data"))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All A6_Record deleted");
		}
		
		if(second_record_type.equals("AFSDB"))
		{
		
		browser.span("Add").in(browser.div("DeleteAdd").near(browser.tableHeader("Hostname").near(browser.tableHeader("Subtype")))).click();
		DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
		browser.button("Add and Add Another").click();
		DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
		browser.button("Add").click();
		Assert.assertTrue(browser.div(second_record_data).exists(),"successfully AFSDB_Record added");
		browser.link("Edit").near(browser.div(second_record_data)).click();
		browser.button("Update").click();
		//clicking update without modify
		Assert.assertTrue(browser.div(cdata_or_expectedMsg).exists(),"Verified expected message");
		//verifying retry button
		browser.button("Retry").click();
		browser.button("Cancel").near(browser.button("Retry")).click();
		browser.link("Edit").near(browser.div(second_record_data)).click();
		DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
		browser.button("Update").click();
		Assert.assertTrue(browser.div(edit_record_data).exists(),"successfully AFSDB_Record updated");
		browser.checkbox("afsdbrecord").click();
		browser.span("Delete").in(browser.div("DeleteAdd").near(browser.tableHeader("Hostname").near(browser.tableHeader("Subtype")))).click();
		browser.button("Delete").click();
		Assert.assertFalse(browser.div(edit_record_data).exists(),"All AFSDB_Record deleted");
		}
		
		if(second_record_type.equals("CERT"))
		{
			browser.span("Add").in(browser.div("DeleteAdd").near(browser.tableHeader("Algorithm"))).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(second_record_data).exists(),"successfully CERT_Record added");
			browser.link("Edit").near(browser.div(second_record_data)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("certrecord").click();
			browser.span("Delete").in(browser.div("DeleteAdd").near(browser.tableHeader("Algorithm"))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All CERT_Record deleted");
		}
		
		if(second_record_type.equals("CNAME"))
		{
			browser.span("Add").in(browser.div("DeleteAdd").near(browser.tableHeader("Hostname"))).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(second_record_data).exists(),"successfully CNAME_Record added");
			browser.link("Edit").near(browser.div(second_record_data)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("cnamerecord").click();
			browser.span("Delete").in(browser.div("DeleteAdd").near(browser.tableHeader("Hostname"))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All CNAME_Record deleted");
			
		}
		
		if(second_record_type.equals("DNAME"))
		{
			browser.span("Add").in(browser.div("DeleteAdd").near(browser.tableHeader("Target").near(browser.table("search-table").near(browser.label("DNAME:"))))).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(second_record_data).exists(),"successfully DNAME_Record added");
			browser.link("Edit").near(browser.div(second_record_data)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("dnamerecord").click();
			browser.span("Delete").in(browser.div("DeleteAdd").near(browser.tableHeader("Target").near(browser.table("search-table").near(browser.label("DNAME:"))))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All DNAME_Record deleted");
		
		}
		
		if(second_record_type.equals("DS"))
		{
			browser.span("Add").near(browser.tableHeader("Digest Type")).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(sec_other_data1).exists(),"successfully DS_Record added");
			browser.link("Edit").near(browser.div(sec_other_data1)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("dsrecord").click();
			browser.span("Delete").near(browser.tableHeader("Digest Type")).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All DS_Record deleted");
		}
		
		if(second_record_type.equals("KEY"))
		{
			browser.span("Add").near(browser.tableHeader("Algorithm").near(browser.tableHeader("Protocol"))).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(sec_other_data1).exists(),"successfully Key_Record added");
			browser.link("Edit").near(browser.div(sec_other_data1)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("keyrecord").click();
			browser.span("Delete").near(browser.tableHeader("Algorithm").near(browser.tableHeader("Protocol"))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All Key_Record deleted");
		}
		
		if(second_record_type.equals("KX"))
		{
			browser.span("Add").near(browser.tableHeader("Exchanger").near(browser.tableHeader("Preference").near(browser.table("search-table").near(browser.label("KX:"))))).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(sec_other_data1).exists(),"successfully KX_Record added");
			browser.link("Edit").near(browser.div(sec_other_data1)).click();
			browser.button("Update").click();
			//clicking update without modify
			Assert.assertTrue(browser.div(cdata_or_expectedMsg).exists(),"Verified expected message");
			//verifying retry button
			browser.button("Retry").click();
			browser.button("Cancel").near(browser.button("Retry")).click();
			browser.link("Edit").near(browser.div(sec_other_data1)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("kxrecord").click();
			browser.span("Delete").near(browser.tableHeader("Exchanger").near(browser.tableHeader("Preference").near(browser.table("search-table").near(browser.label("KX:"))))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All KX_Record deleted");
			
		}
		
		if(second_record_type.equals("LOC"))
		{
			browser.span("Add").near(browser.tableHeader("Record data").near(browser.table("search-table").near(browser.label("LOC:")))).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(cdata_or_expectedMsg).exists(),"successfully LOC_Record added");
			browser.link("Edit").near(browser.div(cdata_or_expectedMsg)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("locrecord").click();
			browser.span("Delete").near(browser.tableHeader("Record data").near(browser.table("search-table").near(browser.label("LOC:")))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(cdata_or_expectedMsg).exists(),"All LOC_Record deleted");
			
			
		}
		
		if(second_record_type.equals("MX"))
		{
			browser.span("Add").near(browser.tableHeader("Exchanger")).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(sec_other_data1).exists(),"successfully MX_Record added");
			browser.link("Edit").near(browser.div(sec_other_data1)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("mxrecord").click();
			browser.span("Delete").near(browser.tableHeader("Exchanger")).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All MX_Record deleted");
		}
		
		if(second_record_type.equals("NAPTR"))
		{
			browser.span("Add").near(browser.tableHeader("Record data").near(browser.table("search-table").near(browser.label("NAPTR:")))).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(cdata_or_expectedMsg).exists(),"successfully NAPTR_Record added");
			browser.link("Edit").near(browser.div(cdata_or_expectedMsg)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("naptrrecord").click();
			browser.span("Delete").near(browser.tableHeader("Record data").near(browser.table("search-table").near(browser.label("NAPTR:")))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(cdata_or_expectedMsg).exists(),"All NAPTR_Record deleted");
		}
		
		if(second_record_type.equals("NS"))
		{
			browser.span("Add").near(browser.tableHeader("Hostname").near(browser.table("search-table").near(browser.label("NS:")))).click();	
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(second_record_data).exists(),"successfully NS_Record added");
			browser.link("Edit").near(browser.div(second_record_data)).click();
			browser.button("Update").click();
			//clicking update without modify
			Assert.assertTrue(browser.div(cdata_or_expectedMsg).exists(),"Verified expected message");
			//verifying retry button
			browser.button("Retry").click();
			browser.button("Cancel").near(browser.button("Retry")).click();
			browser.link("Edit").near(browser.div(second_record_data)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("nsrecord").click();
			browser.span("Delete").near(browser.tableHeader("Hostname").near(browser.table("search-table").near(browser.label("NS:")))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(second_record_data).exists(),"All NS_Record deleted");
		}
		
		if(second_record_type.equals("NSEC"))
		{
			browser.span("Add").near(browser.tableHeader("Type Map")).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(second_record_data).exists(),"successfully NSEC_Record added");
			browser.link("Edit").near(browser.div(second_record_data)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("nsecrecord").click();
			browser.span("Delete").near(browser.tableHeader("Type Map")).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All NSEC_Record deleted");
		}
		
		if(second_record_type.equals("PTR"))
		{
			browser.span("Add").near(browser.tableHeader("Hostname").near(browser.table("search-table").near(browser.label("PTR:")))).click();	
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(second_record_data).exists(),"successfully PTR_Record added");
			browser.link("Edit").near(browser.div(second_record_data)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("ptrrecord").click();
			browser.span("Delete").near(browser.tableHeader("Hostname").near(browser.table("search-table").near(browser.label("PTR:")))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All PTR_Record deleted");
			
		}
		
		if(second_record_type.equals("RRSIG"))
		{
			browser.span("Add").near(browser.tableHeader("Record data").near(browser.table("search-table").near(browser.label("RRSIG:")))).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(cdata_or_expectedMsg).exists(),"successfully RRSIG_Record added");
			browser.link("Edit").near(browser.div(cdata_or_expectedMsg)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("rrsigrecord").click();
			browser.span("Delete").near(browser.tableHeader("Record data").near(browser.table("search-table").near(browser.label("RRSIG:")))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(cdata_or_expectedMsg).exists(),"All RRSIG_Record deleted");
		}
		
		if(second_record_type.equals("SIG"))
		{
			browser.span("Add").near(browser.tableHeader("Record data").near(browser.table("search-table").near(browser.label("SIG:")))).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(cdata_or_expectedMsg).exists(),"successfully SIG_Record added");
			browser.link("Edit").near(browser.div(cdata_or_expectedMsg)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("sigrecord").click();
			browser.span("Delete").near(browser.tableHeader("Record data").near(browser.table("search-table").near(browser.label("SIG:")))).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(cdata_or_expectedMsg).exists(),"All SIG_Record deleted");
		}
		
		if(second_record_type.equals("SRV"))
		{
			browser.span("Add").near(browser.tableHeader("Target")).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(second_record_data).exists(),"successfully SRV_Record added");
			browser.link("Edit").near(browser.div(second_record_data)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("srvrecord").click();
			browser.span("Delete").near(browser.tableHeader("Target")).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All SRV_Record deleted");
		}
		
		if(second_record_type.equals("SSHFP"))
		{
			browser.span("Add").near(browser.tableHeader("Fingerprint Type")).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(sec_other_data1).exists(),"successfully SSHFP_Record added");
			browser.link("Edit").near(browser.div(sec_other_data1)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("sshfprecord").click();
			browser.span("Delete").near(browser.tableHeader("Fingerprint Type")).click();;
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All SSHFP_Record deleted");
		}
		
		if(second_record_type.equals("TXT"))
		{
			browser.span("Add").near(browser.tableHeader("Text Data")).click();
			DNSTasks.recordType(browser, second_record_data, second_record_type,sec_other_data1,sec_other_data2,sec_other_data3, sec_other_data4, sec_other_data5,sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
			browser.button("Add and Add Another").click();
			DNSTasks.recordType(browser,third_record_data,third_record_type,third_other_data1,third_other_data2,third_other_data3,third_other_data4,third_other_data5,third_other_data6,third_other_data7,third_other_data8,third_other_data9,third_other_data10,third_other_data11);
			browser.button("Add").click();
			Assert.assertTrue(browser.div(second_record_data).exists(),"successfully TXT_Record added");
			browser.link("Edit").near(browser.div(second_record_data)).click();
			DNSTasks.recordType(browser,edit_record_data,edit_record_type,edit_other_data1,edit_other_data2,edit_other_data3,edit_other_data4,edit_other_data5,edit_other_data6,edit_other_data7,edit_other_data8,edit_other_data9,edit_other_data10,edit_other_data11);
			browser.button("Update").click();
			browser.checkbox("txtrecord").click();
			browser.span("Delete").near(browser.tableHeader("Text Data")).click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.div(edit_record_data).exists(),"All TXT_Record deleted");
			
		// Expand and collapse test
			System.out.println("Expand and collapse test");
			browser.span("Collapse All").click();
			browser.waitFor(2000);
			//Verify no data is visible
			Assert.assertFalse(browser.label("Record name:").isVisible(),"No Record name is visible");
			browser.span("Expand All").click();
			browser.waitFor(1000);
			//Verify data is visible
			Assert.assertTrue(browser.label("Record name:").isVisible(),"All record type is visiable");
			browser.heading2("Identity Settings").click();
			browser.waitFor(1000);
			//Verify no data is visible
			Assert.assertFalse(browser.label("Record name:").isVisible(),"When Identity Settings section is clicked, can't see its contents");
			//Verify data is visible
			Assert.assertTrue(browser.label("A:").isVisible(),"All Standard Record Types is visiable");
			browser.heading2("Standard Record Types").click();
			browser.waitFor(1000);
			//Verify no data is visible
			Assert.assertFalse(browser.label("A:").isVisible(),"When Standard Record Types section is clicked, can't see its contents");
			//Verify data is visible
			Assert.assertTrue(browser.label("A6:").isVisible(),"All Other Record Types is visiable");
			browser.heading2("Other Record Types").click();
			browser.waitFor(1000);
			//Verify no data is visible
			Assert.assertFalse(browser.label("A6:").isVisible(),"When other Record Types section is clicked, can't see its contents");			
		}
	
		//browser.link("DNS Zones").under(browser.div("DNS ZonesDNS Global ConfigurationDNS Resource Records")).click();
		browser.link("DNS Zones").near(browser.div("facet no-facet-tabs")).click();
		browser.span("Refresh").click();
		browser.waitFor(1000);
		browser.checkbox(zoneName).click();
		browser.span("Delete").click();
		browser.button("Delete").click();
		browser.span("Refresh").click();
}
	/*
	 * DNS Record Type Negative Test
	 */
	public static void recordTypeNegativeTest(SahiTasks browser, String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
			String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11,String expectedError) {
		
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(record_name); 
		browser.select("record_type").choose(record_type);
		
		DNSTasks.recordType(browser, record_data, record_type, other_data1, other_data2, other_data3, other_data4, other_data5, other_data6, other_data7, other_data8, other_data9, other_data10, other_data11);
					
		browser.button("Add").click(); 
		
		DNSTasks.negativeTests(browser, expectedError);
	}
	
	
	/*
	 * Add DNS zone
	 * @param browser - sahi browser instance 
	 * @param zoneName - dns zone name (to be deleted) 
	 */
	public static void delDNSzone(SahiTasks browser, String zoneName) { 
		browser.checkbox(zoneName).click();
		browser.span("Delete").click();
		browser.button("Delete").click(); 
		
		// self-check
		Assert.assertFalse(browser.link(zoneName).exists(),"assert "+zoneName+" not in the zone list"); 
	}//delDNSzone
	
	/*
	 * Add DNS reverse zone
	 * @param browser 
	 * @param reverseZoneName - 
	 * @param authoritativeNameserver -  authoritative nameserver
	 * @param rootEmail - email address for root
	 */
	public static void addDNSReversezone(SahiTasks browser, String zoneIP, String reverseZoneName,String authoritativeNameserver, String rootEmail) {
		browser.span("Add").click();
		browser.radio("dnszone_name_type2").click();
		browser.textbox("name_from_ip").setValue(zoneIP);
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail); 
		browser.button("Add").click();  
	}//addDNSResersezone
	
	/*
	 * DNS Reverse Zone add and another
	 */
	public static void addAndAnotherDNSReversezone(SahiTasks browser, String zoneIP1, String reverseZoneName1,String authoritativeNameserver, String rootEmail,String zoneIP2, String reverseZoneName2) {
	browser.span("Add").click();
	
	browser.radio("dnszone_name_type2").click();
	
	browser.textbox("name_from_ip").setValue(zoneIP1);
	browser.textbox("idnssoamname").setValue(authoritativeNameserver);
	browser.textbox("idnssoarname").setValue(rootEmail); 
	browser.button("Add and Add Another").click();
	browser.textbox("name_from_ip").setValue(zoneIP2);
	browser.textbox("idnssoamname").setValue(authoritativeNameserver);
	browser.textbox("idnssoarname").setValue(rootEmail); 
	browser.button("Add").click();
	Assert.assertTrue(browser.link(reverseZoneName1).exists(),"assert new zone in the zone list");
	Assert.assertTrue(browser.link(reverseZoneName2).exists(),"assert new zone in the zone list");
	}
	
	/*
	 *AddReverse Zone  Negative Test
	 */
	
	public static void addDNSReversezoneNegativeTest(SahiTasks browser, String zoneIP,String authoritativeNameserver, String rootEmail,String expectedError) {
		browser.span("Add").click();
		browser.radio("dnszone_name_type2").click();
		browser.textbox("name_from_ip").setValue(zoneIP);
		browser.textbox("idnssoamname").setValue(authoritativeNameserver);
		browser.textbox("idnssoarname").setValue(rootEmail); 
		browser.button("Add").click();  
		DNSTasks.negativeTests(browser, expectedError);
	}
	
	/*
	 * Add DNS zone
	 * @param browser 
	 * @param hostname - reverse dns zone name (that to be deleted 
	 */
	public static void delDNSReversezone(SahiTasks browser, String reverseZoneName) {
		browser.checkbox(reverseZoneName).click();
		browser.span("Delete").click();
		browser.button("Delete").click(); 
	}//delDNSReversezone
	
	/*
	 * addad new method for record type
	 */
	public static void recordType( SahiTasks browser , String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
			String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11)
	{
		if(record_type.equals("A"))
		{
			browser.textbox("a_part_ip_address").setValue(record_data);
		}
		
		if(record_type.equals("AAAA"))
		{
			browser.textbox("aaaa_part_ip_address").setValue(record_data);
		}
		
		if(record_type.equals("A6"))
		{
			browser.textbox("a6_part_data").setValue(record_data);
		}

		if(record_type.equals("AFSDB"))
		{
			String subtype=other_data1;
			browser.textbox("afsdb_part_subtype").setValue(subtype);
			browser.textbox("afsdb_part_hostname").setValue(record_data);
		}

		if(record_type.equals("CERT"))
		{
			String type=other_data1;
			String key=other_data2;
			String algo=other_data3;
			browser.textbox("cert_part_type").setValue(type);
			browser.textbox("cert_part_key_tag").setValue(key);
			browser.textbox("cert_part_algorithm").setValue(algo);
			browser.textarea("cert_part_certificate_or_crl").setValue(record_data);
			
		}

		if(record_type.equals("CNAME"))
		{
			browser.textbox("cname_part_hostname").setValue(record_data);
		}

		if(record_type.equals("DNAME"))
		{
			browser.textbox("dname_part_target").setValue(record_data);
		}

		if(record_type.equals("DS"))
		{
			String key=other_data1;
			String algo=other_data2;
			String digest_type=other_data3;
			String digest=record_data;
			browser.textbox("ds_part_key_tag").setValue(key);
			browser.textbox("ds_part_algorithm").setValue(algo);
			browser.textbox("ds_part_digest_type").setValue(digest_type);
			browser.textarea("ds_part_digest").setValue(digest);
			
		}

		if(record_type.equals("KEY"))
		{
			String flag=other_data1;
			String protocol=other_data2;
			String algo=other_data3;
			String pub_key=record_data;
			browser.textbox("key_part_flags").setValue(flag);
			browser.textbox("key_part_protocol").setValue(protocol);
			browser.textbox("key_part_algorithm").setValue(algo);
			browser.textarea("key_part_public_key").setValue(pub_key);
			
		}

		if(record_type.equals("KX"))
		{
			String excha=record_data;
			String pref=other_data1;
			browser.textbox("kx_part_preference").setValue(pref);
			browser.textbox("kx_part_exchanger").setValue(excha);
			
		}

		if(record_type.equals("LOC"))
		{
			String deg_lat=record_data;
			String min_lat=other_data1;
			String sec_lat=other_data2;
			String n=other_data3;
			String deg_lon=other_data4;
			String min_lon=other_data5;
			String sec_lon=other_data6;
			String w=other_data7;
			String alti=other_data8;
			String size=other_data9;
			String horiz_pre=other_data10;
			String vert_pre=other_data11;
			
			browser.textbox("loc_part_lat_deg").setValue(deg_lat);
			browser.textbox("loc_part_lat_min").setValue(min_lat);
			browser.textbox("loc_part_lat_sec").setValue(sec_lat);
			browser.radio(n).near(browser.label("N")).click();
			browser.textbox("loc_part_lon_deg").setValue(deg_lon);
			browser.textbox("loc_part_lon_min").setValue(min_lon);
			browser.textbox("loc_part_lon_sec").setValue(sec_lon);
			browser.radio(w).near(browser.label("W")).click();
			browser.textbox("loc_part_altitude").setValue(alti);
			browser.textbox("loc_part_size").setValue(size);
			browser.textbox("loc_part_h_precision").setValue(horiz_pre);
			browser.textbox("loc_part_v_precision").setValue(vert_pre);
			
		}

		if(record_type.equals("MX"))
		{
			String excha=record_data;
			String pref=other_data1;
			browser.textbox("mx_part_preference").setValue(pref);
			browser.textbox("mx_part_exchanger").setValue(excha);
		}

		if(record_type.equals("NAPTR"))
		{
			String servic=record_data;
			String order=other_data1;
			String pref=other_data2;
			String flag=other_data3;
			String reg_exp=other_data4;
			String replace=other_data5;
			browser.textbox("naptr_part_order").setValue(order);
			browser.textbox("naptr_part_preference").setValue(pref);
			browser.select("naptr_part_flags").choose(flag);
			browser.label("Flags:").click();
			browser.textbox("naptr_part_service").setValue(servic);
			browser.textbox("naptr_part_regexp").setValue(reg_exp);
			browser.textbox("naptr_part_replacement").setValue(replace);
			
		}

		if(record_type.equals("NS"))
		{
			browser.textbox("ns_part_hostname").setValue(record_data);
		}

		if(record_type.equals("NSEC"))
		{
			String domain=record_data;
			String type_map=other_data1;
			browser.textbox("nsec_part_next").setValue(domain);
			browser.textbox("nsec_part_types").setValue(type_map);
			
		}

		if(record_type.equals("PTR"))
		{
			browser.textbox("ptr_part_hostname").setValue(record_data);
		}

		if(record_type.equals("RRSIG"))
		{
			String type=record_data;
			String algo=other_data1;
			String label=other_data2;
			String ttl=other_data3;
			String sign_exp=other_data4;
			String sign_inc=other_data5;
			String key_tag=other_data6;
			String sign_name=other_data7;
			String sign=other_data8;			
			browser.select("rrsig_part_type_covered").choose(type);
			browser.textbox("rrsig_part_algorithm").setValue(algo);
			browser.textbox("rrsig_part_labels").setValue(label);
			browser.textbox("rrsig_part_original_ttl").setValue(ttl);
			browser.textbox("rrsig_part_signature_expiration").setValue(sign_exp);
			browser.textbox("rrsig_part_signature_inception").setValue(sign_inc);
			browser.textbox("rrsig_part_key_tag").setValue(key_tag);
			browser.textbox("rrsig_part_signers_name").setValue(sign_name);
			browser.textarea("rrsig_part_signature").setValue(sign);
			
		}

		if(record_type.equals("SIG"))
		{
			String type=record_data;
			String algo=other_data1;
			String label=other_data2;
			String ttl=other_data3;
			String sign_exp=other_data4;
			String sign_inc=other_data5;
			String key_tag=other_data6;
			String sign_name=other_data7;
			String sign=other_data8;
			browser.select("sig_part_type_covered").choose(type);
			browser.textbox("sig_part_algorithm").setValue(algo);
			browser.textbox("sig_part_labels").setValue(label);
			browser.textbox("sig_part_original_ttl").setValue(ttl);
			browser.textbox("sig_part_signature_expiration").setValue(sign_exp);
			browser.textbox("sig_part_signature_inception").setValue(sign_inc);
			browser.textbox("sig_part_key_tag").setValue(key_tag);
			browser.textbox("sig_part_signers_name").setValue(sign_name);
			browser.textarea("sig_part_signature").setValue(sign);
			
		}
		
		if(record_type.equals("SRV"))
		{
			String priority=other_data1;
			String weight=other_data2;
			String port=other_data3;
			String target=record_data;
			browser.textbox("srv_part_priority").setValue(priority);
			browser.textbox("srv_part_weight").setValue(weight);
			browser.textbox("srv_part_port").setValue(port);
			browser.textbox("srv_part_target").setValue(target);
			
		}

		if(record_type.equals("SSHFP"))
		{
			String algo=other_data1;
			String fp_type=other_data2;
			String fp=record_data;
			browser.textbox("sshfp_part_algorithm").setValue(algo);
			browser.textbox("sshfp_part_fp_type").setValue(fp_type);
			browser.textarea("sshfp_part_fingerprint").setValue(fp);
			
		}

		if(record_type.equals("TXT"))
		{
			browser.textbox("txt_part_data").setValue(record_data);
		}			
		
	}
	
	/**/
	 
	/*
	 * Modify DNS zone record: Add one record
	 * @param browser 
	 * @param record_name
	 * @param record_data
	 * @param record_type
	 */
	public static void zoneRecords_add_NegativeTest(SahiTasks browser, String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
			String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11,String expected_msg){
		// assume the page is already in the dns modification page
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(record_name); 
		browser.select("record_type").choose(record_type);
		
		DNSTasks.recordType(browser, record_data, record_type, other_data1, other_data2, other_data3, other_data4, other_data5, other_data6, other_data7, other_data8, other_data9, other_data10, other_data11);
					
		browser.button("Add").click(); 
		if (browser.div("/IPA Error */").exists()){
			log.info("IPA error dialog appears, usually this is data format error");
			// there will be two cancel button here
			browser.button("Cancel").click();
			browser.button("Cancel").click();
			//Assert.assertTrue(false, "ipa error ( dialog )occurs");
		}else if (browser.span("Required field").exists()){
			log.info ("Required field msg appears, usually this means missing data input");
			log.info(expected_msg);
			browser.button("Cancel").click();
			//Assert.assertTrue(false, "missing required field");
		}else{
			// self-check to verify the newly added record
			Assert.assertTrue(browser.link(record_name).exists(),"ensure new record name: (" + record_name + ") in the list");
			// delete the newly created record
			browser.checkbox(record_name).click();
			browser.link("Delete").click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.link(record_name).exists(),"delete newly created record: (" + record_name + ")"); 
		} 
	}//zoneRecords_add
	 
	 /**/
	
	
	
	/*
	 * Modify DNS zone record: Add one record
	 * @param browser 
	 * @param record_name
	 * @param record_data
	 * @param record_type
	 */
	public static void zoneRecords_add(SahiTasks browser, String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
			String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11){
		// assume the page is already in the dns modification page
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(record_name); 
		browser.select("record_type").choose(record_type);
		
		DNSTasks.recordType(browser, record_data, record_type, other_data1, other_data2, other_data3, other_data4, other_data5, other_data6, other_data7, other_data8, other_data9, other_data10, other_data11);
					
		browser.button("Add").click(); 
		if (browser.div("/IPA Error */").exists()){
			log.info("IPA error dialog appears, usually this is data format error");
			// there will be two cancel button here
			browser.button("Cancel").click();
			browser.button("Cancel").click();
			//Assert.assertTrue(false, "ipa error ( dialog )occurs");
		}else if (browser.span("Required field").exists()){
			log.info ("Required field msg appears, usually this means missing data input");
			browser.button("Cancel").click();
			//Assert.assertTrue(false, "missing required field");
		}else{
			// self-check to verify the newly added record
			Assert.assertTrue(browser.link(record_name).exists(),"ensure new record name: (" + record_name + ") in the list");
			// delete the newly created record
			browser.checkbox(record_name).click();
			browser.link("Delete").click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.link(record_name).exists(),"delete newly created record: (" + record_name + ")"); 
		} 
	}//zoneRecords_add
	
	/*
	 * Modify DNS zone record : "Add and Add another"
	 * @param browser 
	 * @param record_name
	 * @param record_data
	 * @param record_type
	 */
	public static void zoneRecords_addandaddanother(SahiTasks browser, 
													String first_record_name, String first_record_data, String first_record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
													String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11,
													
													String second_record_name, String second_record_data, String second_record_type,String sec_other_data1, String sec_other_data2,String sec_other_data3,String sec_other_data4,String sec_other_data5,
													String sec_other_data6,String sec_other_data7,String sec_other_data8,String sec_other_data9,String sec_other_data10,String sec_other_data11){
		// assume the page is already in the dns modification page
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(first_record_name); 
		browser.select("record_type").choose(first_record_type);
		DNSTasks.recordType(browser, first_record_data, first_record_type, other_data1, other_data2, other_data3, other_data4, other_data5, other_data6, other_data7, other_data8, other_data9, other_data10, other_data11);
		
		browser.button("Add and Add Another").click(); 
		
		// after click this button, we should stay in the same dialog box. so we can continue add the second one. 
		browser.textbox("idnsname").setValue(second_record_name); 
		browser.select("record_type").choose(second_record_type);
		
		
		DNSTasks.recordType(browser, second_record_data, second_record_type, sec_other_data1, sec_other_data2, sec_other_data3, sec_other_data4, sec_other_data5, sec_other_data6, sec_other_data7, sec_other_data8, sec_other_data9, sec_other_data10, sec_other_data11);
		
		browser.button("Add and Add Another").click();
		
		// after click the same button the second time, we shouls still stay in the same dialog, we can now "cancel" it
		browser.button("Cancel").click();
		
		if (browser.div("/IPA Error */").exists()){
			log.info("IPA error dialog appears, usually this is data format error");
			// there will be two cancel button here
			browser.button("Cancel").click();
			browser.button("Cancel").click();
			//Assert.assertTrue(false, "ipa error ( dialog )occurs");
		}else if (browser.span("Required field").exists()){
			log.info ("Required field msg appears, usually this means missing data input");
			browser.button("Cancel").click();
			//Assert.assertTrue(false, "missing required field");
		}else{
			// self-check to verify the newly added record
			if  (browser.link(first_record_name).exists()){
				log.info("new record name: (" + first_record_name + ") found in the list");  
				//delete this record
				browser.checkbox(first_record_name).click();
				browser.link("Delete").click();
				browser.button("Delete").click();
				Assert.assertFalse(browser.link(first_record_name).exists(),"assert new record name: (" + second_record_name + ") in the list"); 

			}else{
				Assert.fail("new record name: (" + first_record_name + ") NOT found in the list"); 
			}
			if (browser.link(second_record_name).exists()){
				log.info("assert new record name: (" + second_record_name + ") in the list");
				//delete this record 
				browser.checkbox(second_record_name).click();
				browser.link("Delete").click();
				browser.button("Delete").click(); 
				Assert.assertFalse(browser.link(second_record_name).exists(),"assert new record name: (" + second_record_name + ") in the list"); 
			}else{
				Assert.fail("new record name: (" + second_record_name + ") NOT found in the list"); 
			}  
		}//if no error detected  
	}
	
	/*
	 * Modify DNS zone record: Add one record and switch to Edit mode
	 * @param browser 
	 * @param record_name
	 * @param record_data
	 * @param record_type
	 */
	public static void zoneRecords_addandedit(SahiTasks browser, String rZoneName,String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
			String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11){
		// assume the page is already in the dns modification page
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(record_name); 
		browser.select("record_type").choose(record_type);
		DNSTasks.recordType(browser, record_data, record_type, other_data1, other_data2, other_data3, other_data4, other_data5, other_data6, other_data7, other_data8, other_data9, other_data10, other_data11);
		browser.button("Add and Edit").click();  
		
		//we are now suppose to be in detail editing page
		if (browser.heading3("DNS Resource Record: " + record_name).exists()){
			log.info("verified: we are in record detail editing mode");
			// go back to zone record list
			//browser.link("DNS Zones").in(browser.div("content nav-space-3")).click();
			browser.link(rZoneName).click();
			browser.span("Refresh").click();
			// self-check to verify the newly added record
			Assert.assertTrue(browser.link(record_name).exists(),"ensure new record name: (" + record_name + ") in the list");
			// delete the newly created record
			browser.checkbox(record_name).click();
			browser.link("Delete").click();
			browser.button("Delete").click();
			Assert.assertFalse(browser.link(record_name).exists(),"delete newly created record: (" + record_name + ")");
		
		}
		
		//Notes from yi zhang: we don't care about how this record is being edited, as long as we are in the right place.
		// 						verifying the functionality of this page would be another test case. 
	
	}//zoneRecords_addandedit
	
	/*
	 * Modify DNS zone record: Add one record and switch to Edit mode
	 * @param browser 
	 * @param record_name
	 * @param record_data
	 * @param record_type
	 */
	public static void zoneRecords_add_then_cancel(SahiTasks browser, String record_name, String record_data, String record_type,String other_data1, String other_data2,String other_data3,String other_data4,String other_data5,
			String other_data6,String other_data7,String other_data8,String other_data9,String other_data10,String other_data11){
		// assume the page is already in the dns modification page
		browser.span("Add").click();
		browser.textbox("idnsname").setValue(record_name); 
		browser.select("record_type").choose(record_type);
		DNSTasks.recordType(browser, record_data, record_type, other_data1, other_data2, other_data3, other_data4, other_data5, other_data6, other_data7, other_data8, other_data9, other_data10, other_data11);
		browser.button("Cancel").click();   
		Assert.assertFalse(browser.link(record_data).exists(),"make sure the data does not get into ipa server");  
	
	}//zoneRecords_add_then_cancel
	
	
	/*
	 * Modify dns zone settings
	 * @param browser  
	 * @param zoneName - dns zone name
	 * @param fieldName - dns setting field type name 
	 * @param fieldValue - dns setting field value
	 */
		
	public static void zoneSettingsModification_SoaAndClass(SahiTasks browser, String zoneName,String reverseZoneName, String fieldName, String fieldValue) {
		// get into setting page
				browser.link("Settings").click();
		// save the original value
					String originalValue = browser.textbox(fieldName).getValue();
		
		// test for undo
		if(fieldName.equals("dnsclass"))
		{
			browser.textbox("dnsclass").click();
			browser.select("list").choose(fieldValue);
		}
		else
		{
			browser.textbox(fieldName).setValue(fieldValue);	
		}
		
		browser.span("undo").click(); 
		String undoValue = browser.textbox(fieldName).getValue();
		
		// check undo value with original value
		if (originalValue.equals(undoValue)){
			log.info("Undo works");
		}else{
			log.info("Undo failed");
			Assert.fail("Undo failed");
		}
		
		// test for reset
		if(fieldName.equals("dnsclass"))
		{
			browser.textbox("dnsclass").click();
			browser.select("list").choose(fieldValue);
		}
		else
		{
			browser.textbox(fieldName).setValue(fieldValue);	
		}
	
		browser.span("Reset").click(); 
		String resetValue = browser.textbox(fieldName).getValue();
		// check undo value with original value
		if (originalValue.equals(resetValue)){
			log.info("Reset works");
		}else{
			log.info("Reset failed");
			Assert.fail("Reset failed");
		}
		
		// test for update
		if(fieldName.equals("dnsclass"))
		{
			browser.textbox("dnsclass").click();
			browser.select("list").choose(fieldValue);
		}
		else
		{
			browser.textbox(fieldName).setValue(fieldValue);	
		}
		
		browser.span("Update").click();
		if (browser.div("error_dialog").exists()){ 
			String errormsg = browser.div("error_dialog").getText(); 
			log.info("ERROR update failed: " + errormsg);
			Assert.fail("Update failed");
			browser.button("Cancel").click(); 
			
		}else { 
			String updateValue = browser.textbox(fieldName).getValue();
			// check update value with original value
			if (fieldValue.equals(updateValue)){
				log.info("Update works, updated value matches");
			}else{
				log.info("Update failed, updated value does not match with passin value");
				Assert.fail("Update failed, passin:"+fieldValue + " actual field :"+updateValue);
			}
		}// if no error appears, it should pass
	}
	
	
	
	
	/*
	 * bindUpdatepolicy
	 */
	public static void zoneSettingsModification_bindUpdatePolicy(SahiTasks browser, String zoneName,String reverseZoneName, String fieldName, String fieldValue) {
		// get into setting page
				browser.link("Settings").click();
		// save the original value
		String originalValue = browser.textarea(fieldName).getValue();
		
		browser.textarea(fieldName).setValue(fieldValue);	
		browser.span("undo").click(); 
		String undoValue = browser.textarea(fieldName).getValue();
		
		// check undo value with original value
		if (originalValue.equals(undoValue)){
			log.info("Undo works");
		}else{
			log.info("Undo failed");
			Assert.fail("Undo failed");
		}
		
		// test for reset
			browser.textarea(fieldName).setValue(fieldValue);	
		browser.span("Reset").click(); 
		String resetValue = browser.textarea(fieldName).getValue();
		// check undo value with original value
		if (originalValue.equals(resetValue)){
			log.info("Reset works");
		}else{
			log.info("Reset failed");
			Assert.fail("Reset failed");
		}
		
		// test for update
		
			browser.textarea(fieldName).setValue(fieldValue);	
		
		//browser.textbox(fieldName).setValue(fieldValue);
		browser.span("Update").click();
		if (browser.div("error_dialog").exists()){ 
			String errormsg = browser.div("error_dialog").getText(); 
			log.info("ERROR update failed: " + errormsg);
			Assert.fail("Update failed");
			browser.button("Cancel").click(); 
			
		}else { 
			String updateValue = browser.textarea(fieldName).getValue();
			// check update value with original value
			if (fieldValue.equals(updateValue)){
				log.info("Update works, updated value matches");
			}else{
				log.info("Update failed, updated value does not match with passin value");
				Assert.fail("Update failed, passin:"+fieldValue + " actual field :"+updateValue);
			}
		}// if no error appears, it should pass
	}
	
		/*
		 * radio
		 */
	public static void zoneSettingsModification_dynamicUpdateAndPolicy(SahiTasks browser, String zoneName,String reverseZoneName, String fieldName, String fieldValue) {
		// get into setting page
				browser.link("Settings").click();
				
				browser.radio(fieldName).click();
				browser.span("undo").click();
				Assert.assertFalse(browser.radio(fieldName).checked(),"Undo works");
				
				
				browser.radio(fieldName).click();
				browser.span("Reset").click();
				Assert.assertFalse(browser.radio(fieldName).checked(),"Reset works");
				
				
				browser.radio(fieldName).click();
				browser.span("Update").click();
				String expectedmsg="Are you sure you want to proceed with the action.";
				browser.expectConfirm(expectedmsg, true);
				Assert.assertTrue(browser.radio(fieldName).checked(),"Update Works");
				
				
				//restore default setting
				browser.radio(fieldValue).click();
				browser.span("Update").click();
				browser.expectConfirm(expectedmsg, true);
				
	}
	/*
	 * query forwarder trans
	 */
	
	/*public static void addField(SahiTasks browser,String fieldName)
	{
		if(fieldName.equals("idnsallowquery-0"))
		{
		browser.link("Add").click();
		}
		if(fieldName.equals("idnsallowtransfer-0"))
		{
		browser.link("Add").near(browser.label("Allow transfer:")).click();
		}		
		if(fieldName.equals("idnsforwarders-0"))
		{
			browser.link("Add").near(browser.label("Zone forwarders:")).click();
		}
		
	}*/
	
	public static void zoneSettingsModification_queryAndTransfer(SahiTasks browser, String zoneName,String reverseZoneName, String fieldName, String fieldValue) {
		// get into setting page
				browser.link("Settings").click();
				//String originalValue = browser.textbox(fieldName).getValue();
				
				if(fieldName.equals("idnsforwarders-0"))
				{
					browser.link("Add").near(browser.label("Zone forwarders:")).click();
				}
				//DNSTasks.addField(browser, fieldName);
				browser.textbox(fieldName).setValue(fieldValue);
				browser.span("undo").click();
				log.info("Undo works");
				
				
				if(fieldName.equals("idnsforwarders-0"))
				{
					browser.link("Add").near(browser.label("Zone forwarders:")).click();
				}
				//DNSTasks.addField(browser, fieldName);
				browser.textbox(fieldName).setValue(fieldValue);
				browser.span("undo all").click();
				log.info("Undoall works");
				
				
				if(fieldName.equals("idnsforwarders-0"))
				{
					browser.link("Add").near(browser.label("Zone forwarders:")).click();
				}
			//	DNSTasks.addField(browser, fieldName);			
				browser.textbox(fieldName).setValue(fieldValue);
				browser.span("Update").click();
				browser.expectConfirm("Are you sure you want to proceed with the action.", true);
				log.info("Update works");
				
				browser.link("Delete").near(browser.textbox(fieldName)).click();
				browser.span("Reset").click();
				log.info("Reset works");
				browser.link("Delete").near(browser.textbox(fieldName)).click();
				browser.span("Update").click();
				browser.expectConfirm("Are you sure you want to proceed with the action.", true);
				log.info("Delete Works");
				
			/*	log.info("Restoring Default values");
				DNSTasks.addField(browser, fieldName);
				browser.textbox(fieldName).setValue(originalValue);
				browser.span("Update").click();*/
	
	
	}
	
	
	public static void dnsZoneAllowPTRSync(SahiTasks browser, String zoneName,String reverseZoneName, String fieldName, String fieldValue) 
	{
		String expectedMsg = fieldValue;
		browser.link("Settings").click();
		browser.checkbox("idnsallowsyncptr").click();
		browser.span("undo").click();
		Assert.assertFalse(browser.checkbox("idnsallowsyncptr").checked(),"Undo works successfully");
		browser.checkbox("idnsallowsyncptr").click();
		browser.span("Reset").click();
		Assert.assertFalse(browser.checkbox("idnsallowsyncptr").checked(),"Reset works successfully");
		browser.checkbox("idnsallowsyncptr").click();
		browser.link("DNS Global Configuration").click();
		//without saving changes...
		browser.div(expectedMsg).click();
		log.info("IPA error dialog appears:: ExpectedMsg ::"+expectedMsg);
		browser.button("Reset").click();
		browser.link("DNS Zones").click();
		Assert.assertFalse(browser.checkbox("idnsallowsyncptr").checked(),"Allow PTR sync: not checked");
		browser.checkbox("idnsallowsyncptr").click();
		browser.span("Update").click();
		browser.link("DNS Global Configuration").click();
		browser.link("DNS Zones").click();
		Assert.assertTrue(browser.checkbox("idnsallowsyncptr").checked(),"Update works successfully");
		//restore Default setting
		browser.checkbox("idnsallowsyncptr").click();
		browser.span("Update").click();
	}
	
	/*
	 * DNS Setting Negative Test
	 */
	public static void textBoxOrTextArea(SahiTasks browser, String fieldName,String fieldValue)
	{
	if(!fieldName.equals("idnsupdatepolicy"))
	{
		browser.textbox(fieldName).setValue(fieldValue);
	}
	else 
	{
		browser.textarea(fieldName).setValue(fieldValue);
	}
	}
	
	public static void dnsZoneNegativeSetting(SahiTasks browser, String zoneName, String reverseZoneName,String fieldName, String fieldValue, String expectedError1, String expectedError2) 
	{
		browser.link("Settings").click();
		DNSTasks.textBoxOrTextArea(browser, fieldName, fieldValue);
		browser.span("Update").click();
		browser.expectConfirm("Are you sure you want to proceed with the action.", true);
		if (browser.span(expectedError1).exists())
		{
			log.info ("Required field msg appears:: "+expectedError1);
			//browser.span("undo").click();
			
		}
		if (browser.div(expectedError2).exists())
		{
			//log.info("IPA error dialog appears:: ExpectedError ::"+expectedError2);
			if((browser.button("Cancel").isVisible()))
			{
				log.info("IPA error dialog appears:: ExpectedError ::"+expectedError2);
				browser.button("Cancel").click();
			}
			else
			{
				log.info("IPA error dialog appears:: ExpectedError ::"+expectedError2);
				browser.button("OK").click();			
			}
		}
		
		browser.span("Refresh").click();
	}
	
	
	
	/*
	 * enable disable
	 */
	public static void DNSZoneEnable_Disable(SahiTasks browser, String zoneName) 
	{
	
	    
	    browser.link("Settings").click();
	    browser.select("action").choose("Disable");
	    browser.span("Apply").click();
	    browser.navigateTo(CommonTasks.dnsPage, true);
	    Assert.assertTrue(browser.div("Disabled").near(browser.div(zoneName)).exists(),"Verify DNSZone is disabled sucessfully");
	    browser.link(zoneName).click();
	    browser.link("Settings").click();
	    browser.select("action").choose("Enable");
	    browser.span("Apply").click();
	    browser.navigateTo(CommonTasks.dnsPage, true);
	    Assert.assertTrue(browser.div("Enabled").near(browser.div(zoneName)).exists(),"Verify DNSZone is enabled sucessfully");
	    browser.link(zoneName).click();
	    browser.link("Settings").click();
	    browser.select("action").choose("Delete");
     	browser.span("Apply").click();
		Assert.assertFalse(browser.link(zoneName).exists(), "Verify DNSZone " + zoneName + " deleted successfully");
	
	
	}
	
	/*
	 * Add DNS forward address for a host
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 */
	public static void addRecord(SahiTasks sahiTasks, String zone, String name, String type, String data) {
		sahiTasks.link(zone).click();
		sahiTasks.button("Add").click();
		sahiTasks.textbox("idnsname").setValue(name);
		sahiTasks.select("dns-record-type").choose(type);
		sahiTasks.textarea("record_data").setValue(data);
		sahiTasks.button("Add").click();
	}
	
	/*
	 * Add DNS forward address for a host
	 * @param sahiTasks 
	 * @param hostname - hostname
	 * @param ipadr -  ipaddress
	 */
	// mvarun : updated verifyRecord task because it is used in Hosts tests(hostAddDNSTest)
	
	
	public static void verifyRecord(SahiTasks sahiTasks, String zone, String name, String recordtype, String data, String exists) {
        sahiTasks.link(zone).click();
        if (exists == "YES")
        {
            com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(name).exists(), "Verify record " + name + " of type " + recordtype + " exists");
            sahiTasks.link(name).click();
            Assert.assertTrue(sahiTasks.checkbox(data).near(sahiTasks.label(recordtype + ":")).exists(),  "Verify record " + name + " has record type " + recordtype + " with a value of " + data);
        }
        else
        {
            com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(name).exists(), "Verify record " + name + " of type " + recordtype + " does NOT exists");
        }       
        sahiTasks.link("DNS Zones").in(sahiTasks.div("content nav-space-3")).click();
    }
	
	
	
	/*
	 * Delete DNS reverse address for a host
	 * @param sahiTasks 
	 * @param ptr - ptr
	 */
	public static void deleteRecord(SahiTasks browser, String zone, String name) {
		browser.link(zone).click();
		browser.checkbox(name).click();
		browser.link("Delete").click();
		browser.button("Delete").click();
		browser.link("DNS Zones").in(browser.div("content nav-space-3")).click();
	}
	
	
	
	/*////////////////////////////////////
	 *     DNS GLOABAL FOWARDERS        // 
	 *///////////////////////////////////
	
	/*
	 * @param globalForwarders1 : IPv4 address
	 * @param globalForwarders2 : IPv6 address
	 */
	
	
	
	public static void addDNSGlobalForwarders(SahiTasks browser, String globalForwarders1,String globalForwarders2) 
	{
		
		browser.link("Add").click();
		browser.textbox("idnsforwarders-0").setValue(globalForwarders1);
		browser.span("undo").click();
		Assert.assertFalse(browser.span("undo").isVisible(),"Undo Works successfully");
		browser.link("Add").click();
		browser.textbox("idnsforwarders-0").setValue(globalForwarders1);
		browser.link("Add").click();
		browser.textbox("idnsforwarders-1").setValue(globalForwarders2);
		browser.span("undo all").click();
		Assert.assertFalse(browser.span("undo all").isVisible(),"Undo all Works successfully");
		browser.link("Add").click();
		browser.textbox("idnsforwarders-0").setValue(globalForwarders1);
		browser.span("Reset").click();
		Assert.assertFalse(browser.span("undo all").isVisible(),"Reset Works successfully");
		browser.link("Add").click();
		browser.textbox("idnsforwarders-0").setValue(globalForwarders1);
		browser.link("Add").click();
		browser.textbox("idnsforwarders-1").setValue(globalForwarders2);
		browser.span("Update").click();
				
   }
	
	
	/*
	 * @param globalForwarders1 : IPv4 address
	 * @param globalForwarders2 : IPv6 address
	 */
	
	public static void delDNSGlobalForwarders(SahiTasks browser,String globalForwarders1,String globalForwarders2) 
	{
		browser.link("Delete").click();
		browser.span("undo").click();
		Assert.assertFalse(browser.span("undo").isVisible(),"Undo Works successfully");
		Assert.assertEquals(browser.textbox("idnsforwarders-0").value(), globalForwarders2, "Verified IPv6 Forwarder not deleted");
		browser.link("Delete").click();
		browser.link("Delete").click();
		browser.span("undo all").click();
		Assert.assertFalse(browser.span("undo all").isVisible(),"Undo all Works successfully");
		Assert.assertEquals(browser.textbox("idnsforwarders-1").value(), globalForwarders2, "Verified IPv6 Forwarder not deleted");
		Assert.assertEquals(browser.textbox("idnsforwarders-0").value(), globalForwarders1, "Verified IPv4 Forwarder not deleted");
		browser.link("Delete").click();
		browser.link("Delete").click();
		browser.span("Reset").click();
		Assert.assertFalse(browser.span("undo all").isVisible(),"Reset Works successfully");
		Assert.assertEquals(browser.textbox("idnsforwarders-1").value(), globalForwarders2, "Verified IPv6 Forwarder not deleted");
		Assert.assertEquals(browser.textbox("idnsforwarders-0").value(), globalForwarders1, "Verified IPv4 Forwarder not deleted");
		browser.link("Delete").click();
		browser.link("Delete").click();
		browser.span("Update").click();
		Assert.assertFalse(browser.link("Delete").isVisible(),"Forwaredrs Deleted successfully");
	}
	/*
	 * Add invalid Global Forwarders
	 */
	
	/*
	 * @param expectedError - the error thrown when an invalid Forwarder is being attempted to be added
	 */
	public static void addForwardersNegativeTests(SahiTasks browser,String globalForwarders,String expectedError) 
	{
		browser.link("Add").click();
		browser.textbox("idnsforwarders-0").setValue(globalForwarders);
		browser.span(expectedError).exists();
			log.info ("invalid Global Forwarder data entered "+expectedError+"");
		browser.span("Refresh").click();
		log.info("Refresh works successfully");
	}
	
	/*
	 * Allow PTR Sync
	 */
	
	public static void allowPTRSync(SahiTasks browser,String expectedMsg) 
	{
		browser.checkbox("idnsallowsyncptr").click();
		browser.span("undo").click();
		Assert.assertFalse(browser.checkbox("idnsallowsyncptr").checked(),"Undo works successfully");
		browser.checkbox("idnsallowsyncptr").click();
		browser.span("Reset").click();
		Assert.assertFalse(browser.checkbox("idnsallowsyncptr").checked(),"Reset works successfully");
		browser.checkbox("idnsallowsyncptr").click();
		browser.link("DNS Zones").click();
		//without saving changes...
		browser.div(expectedMsg).click();
		log.info("IPA error dialog appears:: ExpectedMsg ::"+expectedMsg);
		browser.button("Reset").click();
		browser.link("DNS Global Configuration").click();
		Assert.assertFalse(browser.checkbox("idnsallowsyncptr").checked(),"Allow PTR sync: not checked");
		browser.checkbox("idnsallowsyncptr").click();
		browser.span("Update").click();
		browser.link("DNS Zones").click();
		browser.link("DNS Global Configuration").click();
		Assert.assertTrue(browser.checkbox("idnsallowsyncptr").checked(),"Update works successfully");
		//restore Default setting
		browser.checkbox("idnsallowsyncptr").click();
		browser.span("Update").click();
	}
	
	public static void forwardPolicy(SahiTasks browser,String expectedMsg) 
	{
	/*	if (!System.getProperty("os.name").startsWith("Windows")){
		
			browser.radio("idnsforwardpolicy-1-1").click();
			browser.span("undo").click();
			Assert.assertFalse(browser.radio("idnsforwardpolicy-1-1").checked(), "Changes to Forward only are Undo.....Undo works successfully");
			browser.radio("idnsforwardpolicy-1-1").click();
			browser.link("DNS Zones").click();
			//without saving changes...
			browser.div(expectedMsg).click();
			log.info("IPA error dialog appears:: ExpectedMsg ::"+expectedMsg);
			browser.button("Cancel").click();
			browser.span("Reset").click();
			Assert.assertFalse(browser.radio("idnsforwardpolicy-1-1").checked(), "Changes to Forward only are Reset.....Reset works successfully");
			browser.radio("idnsforwardpolicy-1-1").click();
			browser.link("DNS Zones").click();
			//without saving changes...
			browser.div(expectedMsg).click();
			log.info("IPA error dialog appears:: ExpectedMsg ::"+expectedMsg);
			browser.button("Update").click();
			browser.link("DNS Global Configuration").click();
			Assert.assertTrue(browser.radio("idnsforwardpolicy-1-1").checked(), "Dialogbox Update works successfully.....Changes to Forward only are Updated");
			browser.radio("idnsforwardpolicy-1-0").click();
			browser.span("Update").click();
			Assert.assertTrue(browser.radio("idnsforwardpolicy-1-0").checked(), "Changes to Forward First are Updated....Update works successfully");
		}else{
			browser.radio("idnsforwardpolicy-47-1").click();
			browser.span("undo").click();
			Assert.assertFalse(browser.radio("idnsforwardpolicy-47-1").checked(), "Changes to Forward only are Undo.....Undo works successfully");
			browser.radio("idnsforwardpolicy-47-1").click();
			browser.link("DNS Zones").click();
			//without saving changes...
			browser.div(expectedMsg).click();
			log.info("IPA error dialog appears:: ExpectedMsg ::"+expectedMsg);
			browser.button("Cancel").click();
			browser.span("Reset").click();
			Assert.assertFalse(browser.radio("idnsforwardpolicy-47-1").checked(), "Changes to Forward only are Reset.....Reset works successfully");
			browser.radio("idnsforwardpolicy-47-1").click();
			browser.link("DNS Zones").click();
			//without saving changes...
			browser.div(expectedMsg).click();
			log.info("IPA error dialog appears:: ExpectedMsg ::"+expectedMsg);
			browser.button("Update").click();
			browser.link("DNS Global Configuration").click();
			Assert.assertTrue(browser.radio("idnsforwardpolicy-47-1").checked(), "Dialogbox Update works successfully.....Changes to Forward only are Updated");
			browser.radio("idnsforwardpolicy-47-0").click();
			browser.span("Update").click();
			Assert.assertTrue(browser.radio("idnsforwardpolicy-47-0").checked(), "Changes to Forward First are Updated....Update works successfully");
		} */
		browser.radio("idnsforwardpolicy-1-1").click();
		browser.span("undo").click();
		Assert.assertFalse(browser.radio("idnsforwardpolicy-1-1").checked(), "Changes to Forward only are Undo.....Undo works successfully");
		browser.radio("idnsforwardpolicy-1-1").click();
		browser.link("DNS Zones").click();
		//without saving changes...
		browser.div(expectedMsg).click();
		log.info("IPA error dialog appears:: ExpectedMsg ::"+expectedMsg);
		browser.button("Cancel").click();
		browser.span("Reset").click();
		Assert.assertFalse(browser.radio("idnsforwardpolicy-1-1").checked(), "Changes to Forward only are Reset.....Reset works successfully");
		browser.radio("idnsforwardpolicy-1-1").click();
		browser.link("DNS Zones").click();
		//without saving changes...
		browser.div(expectedMsg).click();
		log.info("IPA error dialog appears:: ExpectedMsg ::"+expectedMsg);
		browser.button("Update").click();
		browser.link("DNS Global Configuration").click();
		Assert.assertTrue(browser.radio("idnsforwardpolicy-1-1").checked(), "Dialogbox Update works successfully.....Changes to Forward only are Updated");
		browser.radio("idnsforwardpolicy-1-0").click();
		browser.span("Update").click();
		Assert.assertTrue(browser.radio("idnsforwardpolicy-1-0").checked(), "Changes to Forward First are Updated....Update works successfully");
	}
	
	public static void zoneRefreshNegativeTests(SahiTasks browser, String zoneRefreshInterval, String expectedError1, String expectedError2) 
	{
		browser.textbox("idnszonerefresh").setValue(zoneRefreshInterval);
		browser.span("Update").click();
		if (browser.div(expectedError2).exists())
		{
			log.info("IPA error dialog appears:: ExpectedError ::"+expectedError2);
			browser.button("OK").click();			
		}
		if (browser.span(expectedError1).exists())
		{
			log.info ("Required field msg appears:: "+expectedError1);
			browser.span("undo").click();
			
		}
		browser.span("Refresh").click();
	}
	
	
	public static void zoneRefreshPositiveTests(SahiTasks browser, String zoneRefreshInterval) 
	{
		String originalValue = browser.textbox("idnszonerefresh").getValue();
		// test for undo
		browser.textbox("idnszonerefresh").setValue(zoneRefreshInterval);
		browser.span("undo").click(); 
		String undoValue = browser.textbox("idnszonerefresh").getValue();
		// check undo value with original value
		if (originalValue.equals(undoValue)){
			log.info("Undo works");
		}else{
			log.info("Undo failed");
			Assert.fail("Undo failed");
		}
		// test for reset
		
		browser.textbox("idnszonerefresh").setValue(zoneRefreshInterval);
		browser.span("Reset").click(); 
		String resetValue = browser.textbox("idnszonerefresh").getValue();
		// check undo value with original value
		if (originalValue.equals(resetValue)){
			log.info("Reset works");
		}else{
			log.info("Reset failed");
			Assert.fail("Reset failed");
		}
		// test for update
		browser.textbox("idnszonerefresh").setValue(zoneRefreshInterval);
		browser.span("Update").click();
		String updateValue = browser.textbox("idnszonerefresh").getValue();
		// check update value with original value
		if (zoneRefreshInterval.equals(updateValue)){
			log.info("Update works, updated value matches");
		}else{
			log.info("Update failed, updated value does not match with passin value");
			Assert.fail("Update failed, passin:"+zoneRefreshInterval + " actual field :"+updateValue);
		}
		//Restoring default vale
		browser.textbox("idnszonerefresh").setValue(" ");
		browser.textbox("idnszonerefresh").setValue("");
		browser.span("Update").click();
	}
	
	public static void expandCollapseDNSConfig(SahiTasks browser) 
	{
		browser.span("Collapse All").click();
		browser.waitFor(2000);
		Assert.assertFalse(browser.label("Allow PTR sync:").isVisible(),"Collapse All :: Verified contents are not visiable");
		browser.span("Expand All").click();
		browser.waitFor(5000);
		Assert.assertTrue(browser.label("Allow PTR sync:").isVisible(),"Expand All :: Verified contents are visiable");
	}
	
	
}// Class: DNSTasks

