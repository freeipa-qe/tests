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
import com.redhat.qe.ipa.sahi.tasks.UserTasks;
import com.redhat.qe.auto.testng.*;

public class DNSGlobalconfigTests extends SahiTestScript{
	private static Logger log = Logger.getLogger(DNSTests.class.getName());
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		
		sahiTasks.navigateTo(commonTasks.dnsConfigPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		String currentURL = sahiTasks.fetch("top.location.href");
		CommonTasks.checkError(sahiTasks);
		if (!currentURL.equals(commonTasks.dnsConfigPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+ commonTasks.dnsConfigPage +")");
			sahiTasks.navigateTo(commonTasks.dnsConfigPage, true);
		}
	}
	/*
	 * Add Global Forwarders (Ipv4 and Ipv6)
	 */
	
	@Test (groups={"addGlobalForwarders"}, dataProvider="getGlobalForwardersObjects")	
	public void addGlobalForwardersTest(String testName, String globalForwarders1,String globalForwarders2) throws Exception
	{
		DNSTasks.addDNSGlobalForwarders(sahiTasks, globalForwarders1,globalForwarders2); 
		Assert.assertEquals(sahiTasks.textbox("idnsforwarders-0").value(), globalForwarders2, "Verified IPv6 Forwarder added successfully");
		Assert.assertEquals(sahiTasks.textbox("idnsforwarders-1").value(), globalForwarders1, "Verified IPv4 Forwarder added successfully");
	}
	
	/*
	 * Delete Global Forwarders (Ipv4 and Ipv6)
	 * 
	 */
	@Test (groups={"delGlobalForwarders"}, dataProvider="getGlobalForwardersObjects",dependsOnGroups=("addGlobalForwarders"))	
	public void delGlobalForwardersTest(String testName, String globalForwarders1,String globalForwarders2) throws Exception{
		
		DNSTasks.delDNSGlobalForwarders(sahiTasks, globalForwarders1,globalForwarders2); 
	}
	
	/*
	 * Add invalid Global Forwarders 
	 */
	
	
	@Test (groups={"addInvalidForwarders"},dataProvider="getInvalidForwarders",dependsOnGroups=("delGlobalForwarders"))
	public void addInvalidForwarders(String testName, String globalForwarders, String expectedError) throws Exception{
		DNSTasks.addForwardersNegativeTests(sahiTasks, globalForwarders, expectedError);
	}
	
	/*
	 * Allow PTR sync
	 */
	@Test (groups={"allowPTRSync"},dataProvider="getAllowPTR")	
	public void allowPTRSyncTest(String testName, String expectedMsg)throws Exception{
		DNSTasks.allowPTRSync(sahiTasks,expectedMsg);
	}
	/*
	 * Forward Policy Test
	 */
	@Test (groups={"forwardPolicy"},dataProvider="getForwardPolicy")	
	public void forwardPolicyTest(String testName, String expectedMsg)throws Exception{
		DNSTasks.forwardPolicy(sahiTasks,expectedMsg);
	}
	
	/*
	 * Zone Refresh Interval -Negative test
	 */
	
	@Test (groups={"zoneRefreshInterval_NegativeTest"},dataProvider="getNegativeZoneRefresh")	
	public void NegativeZoneRefreshTest(String testName, String zoneRefreshInterval, String expectederror1, String expectederror2)throws Exception{
		DNSTasks.zoneRefreshNegativeTests(sahiTasks,zoneRefreshInterval,expectederror1,expectederror2);
	}
	/*
	 * Zone Refresh Interval- Positive Test
	 */
	
	@Test (groups={"zoneRefreshInterval_PositiveTest"},dataProvider="getPositiveZoneRefresh",dependsOnGroups=("zoneRefreshInterval_NegativeTest"))	
	public void positiveZoneRefreshTests(String testName, String zoneRefreshInterval)throws Exception{
		DNSTasks.zoneRefreshPositiveTests(sahiTasks,zoneRefreshInterval);
	}
	
	@Test (groups={"ExpandCollapseDNSConfigTests"})
	public void testExpandCollapseDNSConfig() throws Exception {
		
		DNSTasks.expandCollapseDNSConfig(sahiTasks);		
		
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS            ***********
	 *******************************************************/

	/*
	 * Data to be used when adding hosts - for positive cases
	 */
	@DataProvider(name="getGlobalForwardersObjects")
	public Object[][] getGlobalForwardersObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createGlobalForwardersObjects());
	}
	protected List<List<Object>> createGlobalForwardersObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		ll.add(Arrays.asList(new Object[]{
				//testname                      globalForwarders1       globalForwarders2    
		        "IPv4_and_IPv6_fowarders",    "1.1.1.1",   "fe80::216:36ff:fe23:9aa1"}));
		
		return ll;	
	}
	
	@DataProvider(name="getInvalidForwarders")
	public Object[][] getInvalidForwarders() {
		return TestNGUtils.convertListOfListsTo2dArray(createInvalidForwardersObjects());
	}
	protected List<List<Object>> createInvalidForwardersObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		ll.add(Arrays.asList(new Object[]{
				//testname                      globalForwarders       ExcectedError    
		        "add_fowarders_Negative_test",    "aa",       "Not a valid IP address"}));
		
		return ll;	
	}
	
	
	@DataProvider(name="getAllowPTR")
	public Object[][] getAllowPTR() {
		return TestNGUtils.convertListOfListsTo2dArray(createAllowPTRObjects());
	}
	protected List<List<Object>> createAllowPTRObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		ll.add(Arrays.asList(new Object[]{
				//testname                             ExcectedMsg    
		        "Allow_PTR_Sync_Test",    "This page has unsaved changes. Please save or revert."}));
		
		return ll;	
	}
	
	@DataProvider(name="getForwardPolicy")
	public Object[][] getForwardPolicy() {
		return TestNGUtils.convertListOfListsTo2dArray(createForwardPolicyObjects());
	}
	protected List<List<Object>> createForwardPolicyObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		ll.add(Arrays.asList(new Object[]{
				//testname                             ExcectedMsg    
		        "Fowared_Policy_Test",    "This page has unsaved changes. Please save or revert."}));
		
		return ll;	
	}
	
	
	@DataProvider(name="getNegativeZoneRefresh")
	public Object[][] getNegativeZoneRefresh() {
		return TestNGUtils.convertListOfListsTo2dArray(createNegativeZoneRefreshObjects());
	}
	protected List<List<Object>> createNegativeZoneRefreshObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//			Testname		     ZoneRefreshInterval		ExpectedError1									ExpectedError2
		ll.add(Arrays.asList(new Object[]{
		        "Maximum_Value",        "2147483648",            "Maximum value is 2147483647",                 "Input form contains invalid or missing values."}));
		ll.add(Arrays.asList(new Object[]{
		        "Negative_Value",        "-1",                    "Minimum value is 0",                         "Input form contains invalid or missing values."}));
		ll.add(Arrays.asList(new Object[]{
		        "Blank_Value",            " ",                    "Minimum value is 0",                         "Input form contains invalid or missing values."}));
			
		return ll;	
	}
	
	
	@DataProvider(name="getPositiveZoneRefresh")
	public Object[][] getPositiveZoneRefresh() {
		return TestNGUtils.convertListOfListsTo2dArray(createPositiveZoneRefreshObjects());
	}
	protected List<List<Object>> createPositiveZoneRefreshObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		//			Testname		     ZoneRefreshInterval		
		ll.add(Arrays.asList(new Object[]{
		        "ZoneInterval_PositiveTest",        "30"}));
		return ll;	
	}
	
	
}
	


