package com.redhat.qe.ipa.sahi.tests.hbac;

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
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.HBACTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.NetgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;
public class HBACRunTests extends SahiTestScript {
	
	private static Logger log = Logger.getLogger(HBACRunTests.class.getName());
		
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	private String domain = System.getProperty("ipa.server.domain");
	private String apple1 = "apple";
	private String banana1 = "banana";
	private String [] hostnames = {apple1, banana1};
	private String fqdn0 = apple1 + "." + domain;
	private String fqdn1 = banana1 + "." + domain;
		
	
	private String user1 = "hbacrunuser945";
	private String user2 = "hbacrunuser6348";
	private String [] hbacrunuser = {user1, user2};
	private String [] users = {user1, user2};
	
	private String rulename1 = "smtp";
	private String rulename2 = "denial";
	private String [] hbacrule = {rulename1, rulename2};
	private String [] rulename = {rulename1, rulename2};
	private String ad = "admins";
	
	
	private String servicename = "smtp";
	private String servicename2 = "smtp1";
	private String [] servicenames = {servicename, servicename2};
	private String newservicename = "ftp";
	private String dec = "adding http service for HBAC";
		
		
		
	
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		sahiTasks.setStrictVisibilityCheck(true);
		currentPage = sahiTasks.fetch("top.location.href");
		alternateCurrentPage = sahiTasks.fetch("top.location.href") + "&hbactestv -facet=search" ;
		
		//add Identity hosts 
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		for (String hostname : hostnames) {
			HostTasks.addHost(sahiTasks, hostname, commonTasks.getIpadomain(), "");
		}
		
		//add Identity users
		sahiTasks.navigateTo(commonTasks.userPage, true);
		for (String username : users){
			UserTasks.createUser(sahiTasks, username, username, username, "Add");
		} 
		
		// add HBACService
		sahiTasks.navigateTo(commonTasks.hbacServicePage, true);
		for (String sname : servicenames)
		{
				HBACTasks.addHBACService(sahiTasks, sname, dec, "Add");
		}
		
		
		// add HBACRule
		sahiTasks.navigateTo(commonTasks.hbacPage, true);
		for (String rule : rulename)
		{
			
			if (rule.equals(rulename1))
			{			
			  
				HBACTasks.addAndEditHBACRuleHost(sahiTasks, rule, user1, fqdn1, rule, fqdn0);
								
			}
			else
			{
				HBACTasks.addHBACRule(sahiTasks, rule, "Add");
				HBACTasks.modifyHBACRuleWhoSectionMemberList(sahiTasks, rule, ad, ad);
				HBACTasks.modifyHBACMemberList(sahiTasks, rule);
				
			}
		}
		
		sahiTasks.navigateTo(commonTasks.hbacTest, true);
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	
		//delete hosts
		final String [] delhosts = {apple1 + "." + domain, banana1 + "." + domain};
		sahiTasks.navigateTo(commonTasks.hostPage, true);
		HostTasks.deleteHost(sahiTasks, delhosts);
		
		//delete users
		sahiTasks.navigateTo(commonTasks.userPage, true);
		for (String username : users){
			UserTasks.deleteUser(sahiTasks, username);
		}
		
		// delete HBACService
		sahiTasks.navigateTo(commonTasks.hbacServicePage, true);
		for (String sname : servicenames){
			HBACTasks.deleteHBAC(sahiTasks, sname, "Delete");
		}
		
		// delete HBACRule
		sahiTasks.navigateTo(commonTasks.hbacPage, true);
		for (String rule : rulename){
			HBACTasks.deleteHBAC(sahiTasks, rule, "Delete");
		}
		
		
		
	}
	
	/*
	 * HBAC Run Test  - for positive test	
	 */
	@Test (groups={"hbacRunTests"}, description="Positive Test for HBAC Test", dataProvider="getHBACRunTestObjects")
	public void testHBACTest(String testName, String user,String servicename, String rules, String expectedResult) throws Exception 
	{
		if(testName.equals("wrong_accessing"))
		{
			HBACTasks.testHBACRunTest(sahiTasks,user,fqdn0,servicename,fqdn0,rules,expectedResult);
		}
		else
		{
			HBACTasks.testHBACRunTest(sahiTasks,user,fqdn1,servicename,fqdn0,rules,expectedResult);
		}
		
		sahiTasks.navigateTo(commonTasks.hbacTest, true);
	}
	
	/*
	 * Add Run Test - check required fields - for negative tests
	 */	
	@Test (groups={"hbacRequiredFieldRunTests"}, description="HBAC Run Test - missing required field", dataProvider="getHBACRunRequiredFieldTestObjects")
	public void testHBACRunRequiredFieldTest(String testName, String user,String hostname1, String servicename, String hostname2, String rules, String expectedError) throws Exception 
		{
			HBACTasks.createRunTestWithRequiredField (sahiTasks,user,hostname1,servicename,hostname2,rules,expectedError);
			
			sahiTasks.navigateTo(commonTasks.hbacTest, true);
		}
	/*
	 * Modify Run Test - by using previous button - for positive tests  
	 */
	
	@Test (groups={"hbacModifyRunTests"}, description="HBAC Run Test - missing required field", dataProvider="getHBACModifyRunTestObjects")
	public void testModifyRunTest(String testName, String user,String servicename, String rules, String rules1, String servicename1, String user1, String expectedResult) throws Exception 
		{
			HBACTasks.createModifyRunTest (sahiTasks,user,fqdn0,servicename,fqdn1,rules,rules1,fqdn0,servicename1,fqdn1,user1,expectedResult);
			
			sahiTasks.navigateTo(commonTasks.hbacTest, true);
		}
	/*
	 * search
	 */
	
	@Test (groups={"hbacSearchTests"}, description="HBAC search Test - search for who,accessing,via-service,from", dataProvider="getHBACSearchTestObjects")
	public void testUserSearch(String testName, String user, String targethost, String service, String sourcehost,String multipleResult) throws Exception {
		
		HBACTasks.searchTest(sahiTasks, user, targethost, service, sourcehost, multipleResult);
		
				
		sahiTasks.navigateTo(commonTasks.hbacTest, true);
	}
	
	/*
	 * External Specification
	 */
	
	@Test (groups={"hbacExternalSpecificationTests"}, description="HBAC External Specification Test - Adding specify external user,host,service", dataProvider="getHBACExternalSpecificationObjects")
	public void testExternalSpecificationTest(String testName, String user, String targethost, String service, String sourcehost,String rule, String expectedResult) throws Exception 
		{
			HBACTasks.externalSpecificationTest (sahiTasks, user, targethost, service, sourcehost, rule, expectedResult);
			
			sahiTasks.navigateTo(commonTasks.hbacTest, true);
		}
	/*
	 * HBAC Rule include Enable and Disable Test
	 */
	@Test (groups={"hbacRuleIncludeTests"}, description="Positive Test for rule enable and disable", dataProvider="getHBACRuleIncludeTestObjects")
	public void testHBACRuleTest(String testName, String user,String servicename, String include,String rule1,String rule2, String rule3, String expectedResult) throws Exception 
	{
		
			HBACTasks.testRuleIncludeTest(sahiTasks,user,fqdn1,servicename,fqdn0,include,rule1,rule2,rule3,expectedResult);
			sahiTasks.navigateTo(commonTasks.hbacTest, true);
	}
		
	/*
	 * HBAC Rule Matched and Unmatched Test
	 */
	
	@Test (groups={"hbacRuleMatchTests"}, description="Positive Test for Matching and unmatching", dataProvider="getHBACRuleMatchObjects")
	public void testHBACRuleMatchTest(String testName, String user,String servicename, String match, String unmatch, String rulename1, String rulename2,String rulename3,  String expectedResult) throws Exception 
	{
		
			HBACTasks.testRuleMatchTest(sahiTasks,user,fqdn1,servicename,fqdn0,match,unmatch,rulename1,rulename2,rulename3,expectedResult);
			sahiTasks.navigateTo(commonTasks.hbacTest, true);
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	/*
	 * Data to be used for "Run" test. 
	 */
	
	@DataProvider(name="getHBACRunTestObjects")
	public Object[][] getHBACRunTestObjects(){
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRunTestObjects());
		
	}
	protected List<List<Object>> createHBACRunTestObjects(){
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
		//                                  testName			  user		  	service   rules	     expectedResult
		ll.add(Arrays.asList(new Object[]{"positive_test",   "hbacrunuser945",   "smtp",  "smtp",   "Access Granted"}));
		ll.add(Arrays.asList(new Object[]{"wrong_who",       "hbacrunuser6348",  "smtp",  "smtp",   "Access Denied"}));
		ll.add(Arrays.asList(new Object[]{"wrong_accessing", "hbacrunuser945",   "smtp",  "smtp",   "Access Denied"}));
		ll.add(Arrays.asList(new Object[]{"wrong_viaservice","hbacrunuser945",   "ftp",   "smtp",   "Access Denied"}));
		ll.add(Arrays.asList(new Object[]{"wrong_rule",      "hbacrunuser945",   "smtp",  "denial", "Access Denied"}));
		return ll;
	}
	
/*
 * Data to be use for "Required Field Test" : Positive test
 */
	@DataProvider(name="getHBACRunRequiredFieldTestObjects")
	public Object[][] getHBACRunRequiredFieldTestObjects(){
		return TestNGUtils.convertListOfListsTo2dArray(createRequiredFieldTestObjects());
		
	}
	protected List<List<Object>> createRequiredFieldTestObjects(){
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
		//                                  testName			    user          	       hostName1  						service           hostName2  				  rules	            				   expectedError
		ll.add(Arrays.asList(new Object[]{"deselect_who",  	         "",         		"banana.lab.eng.pnq.redhat.com",    "smtp",     "apple.lab.eng.pnq.redhat.com",   "smtp",     "Input form contains invalid or missing values.Missing values: User name"}));
    	ll.add(Arrays.asList(new Object[]{"deselect_accessing",  "hbacrunuser945",              "",     				    "smtp",     "apple.lab.eng.pnq.redhat.com",   "smtp",     "Input form contains invalid or missing values.Missing values: Target host"}));
		ll.add(Arrays.asList(new Object[]{"deselect_viaservices","hbacrunuser945",      "banana.lab.eng.pnq.redhat.com",     "",        "apple.lab.eng.pnq.redhat.com",   "smtp",     "Input form contains invalid or missing values.Missing values: Service"}));
		ll.add(Arrays.asList(new Object[]{"deselect_from",       "hbacrunuser945",      "banana.lab.eng.pnq.redhat.com",    "smtp",        "",               			  "smtp",     "Input form contains invalid or missing values.Missing values: Source host"}));
		ll.add(Arrays.asList(new Object[]{"deselect_all",           "",  		 		        "",   						 "",           "",        				      "smtp",     "Input form contains invalid or missing values.Missing values: User nameTarget hostServiceSource host"}));
		return ll;
	}
	
	/*
	 * Data to be use for "Modify Run Test" : Positive Test
	 */
	@DataProvider(name="getHBACModifyRunTestObjects")
	public Object[][] getHBACModifyRunTestObjects(){
		return TestNGUtils.convertListOfListsTo2dArray(createHBACModifyRunTestObjects());
		
	}
	protected List<List<Object>> createHBACModifyRunTestObjects(){
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
		//                                  testName			  			user		  	service    rules	  rules    service      user        expectedResult
		ll.add(Arrays.asList(new Object[]{"prev_button_positive_test",   "hbacrunuser6348",   "ftp",  "denial",  "smtp",   "smtp", "hbacrunuser945", "Access Granted"}));
		
		return ll;
	}
	
	/*
	 * Data to be used when searching : Positive Test
	 */
	@DataProvider(name="getHBACSearchTestObjects")
	public Object[][] getHBACSearchTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACSearchTestObjects());
	}
	protected List<List<Object>> createHBACSearchTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				user       			 target_host 					service			 source_host				multiple_result1	       		
		ll.add(Arrays.asList(new Object[]{ "search_who",			  "hbacrunuser945",			"" , 						   "",				"",							""		} ));
		ll.add(Arrays.asList(new Object[]{ "search_accessing",		      "",				"banana.lab.eng.pnq.redhat.com",   "",				"",    						""		} ));
		ll.add(Arrays.asList(new Object[]{ "search_viaservice",	          "",					"",							  "smtp",			"",			      		    "smtp1" } ));
		ll.add(Arrays.asList(new Object[]{ "search_from",				  "",				    "",								"",	         "apple.lab.eng.pnq.redhat.com", ""     } ));     
		return ll;	
	}
	
	/*
	 * Data to be use for "External Specification Test" : Positive Test
	 */
	@DataProvider(name="getHBACExternalSpecificationObjects")
	public Object[][] getHBACExternalSpecificationObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACExternalSpecificationObjects());
	}
	protected List<List<Object>> createHBACExternalSpecificationObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									    testname											user       					 target_host 					service			    source_host				  rule  			expected_result	       		
		ll.add(Arrays.asList(new Object[]{ "specify_external_user_hosts,service",			    "redhatuser",			"zeta.lab.eng.pnq.redhat.com" , 		 "ftpd",	"tera.lab.eng.pnq.redhat.com",	"allow_all",   	    "Access Granted"	} ));
		return ll;	
	}
	
	/*
	 * Data to be use for "RuleInclude Test" : Positive Test
	 */


	@DataProvider(name="getHBACRuleIncludeTestObjects")
	public Object[][] getHBACRuleIncludeTestObjects(){
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleIncludeTestObjects());
		
	}
	protected List<List<Object>> createHBACRuleIncludeTestObjects(){
		List<List<Object>> ll = new ArrayList<List<Object>>();
			
		//                                  testName				  user		  		service   include       rule1	     rule2	  rule3     expectedResult
		ll.add(Arrays.asList(new Object[]{"Include_enable_test",   "hbacrunuser945",  	 "smtp",  "enabled",  "allow_all",	"denial", "smtp",  "Access Granted"}));
		ll.add(Arrays.asList(new Object[]{"Include_disable_test",   "hbacrunuser945", 	  "smtp",  "disabled", "No entries.",			"", 	"",	     "Access Denied"}));
		return ll;
	}
	
	/*
	 * Data to be use for "Rule Match and unmatch Test" : Positive Test
	 */
	@DataProvider(name="getHBACRuleMatchObjects")
	public Object[][] getHBACRuleMatchObjects(){
		return TestNGUtils.convertListOfListsTo2dArray(createHBACRuleMatchObjects());
		
	}
	protected List<List<Object>> createHBACRuleMatchObjects(){
		List<List<Object>> ll = new ArrayList<List<Object>>();
			
		//                                  testName				 		   user		    service     match    	un_match      rulename1    rulename2  rulename3     expectedResult
		ll.add(Arrays.asList(new Object[]{"Rule_Matched_and_Unmatched_test",  "admin",  	 "smtp",  "matched",   "unmatched",   "allow_all",	"denial",    "smtp",  "Access Granted"}));
		return ll;
	}
	
}