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
	
	
	private String servicename = "smtp1";
	private String servicename2 = "smtp2";
	private String servicename3 = "smtp";
	private String [] servicenames = {servicename, servicename2,servicename3};
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
			  
				HBACTasks.addAndEditHBACRuleHost(sahiTasks, rule, user1, fqdn1, servicename, fqdn0);
								
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
		//sahiTasks.link("HBAC Rules").in(sahiTasks.div("content")).click();//xdong		
		for (String rule : rulename){
			HBACTasks.deleteHBAC(sahiTasks, rule, "Delete");
		}
		
		
		
	}
	
	/*
	 * HBAC Run Test  - for positive and Negative tests	
	 */
	@Test (groups={"hbacRunTests"}, description="Run based on Positive and Negative Tests for HBAC Test", dataProvider="getHBACRunTestObjects")
	public void testHBACTest(String testName, String user,String servicename, String rules,String mrule1, String mrule2,String mrule3,
							 String unmrule1, String unmrule2,String unmrule3,String expectedResult) throws Exception 
	{
		if(testName.equals("wrong_accessing"))
		{
			HBACTasks.testHBACRunTest(sahiTasks,user,fqdn0,servicename,fqdn0,rules,mrule1,mrule2,mrule3,unmrule1,unmrule2,unmrule3,expectedResult);
		}
		else
		{
			HBACTasks.testHBACRunTest(sahiTasks,user,fqdn1,servicename,fqdn0,rules,mrule1,mrule2,mrule3,unmrule1,unmrule2,unmrule3,expectedResult);
		}
		
		sahiTasks.navigateTo(commonTasks.hbacTest, true);
	}
	
	/*
	 * Add Run Test - check required fields - for negative tests
	 */	
	@Test (groups={"hbacRequiredFieldRunTests"}, description="HBAC Run Test - missing required field", dataProvider="getHBACRunRequiredFieldTestObjects")
	public void testHBACRunRequiredFieldTest(String testName, String user,String hostname1, String servicename, String hostname2, String rules, String expectedError1,String expectedError2) throws Exception 
		{
			HBACTasks.createRunTestWithRequiredField (sahiTasks,user,hostname1,servicename,hostname2,rules,expectedError1,expectedError2);
			
			sahiTasks.navigateTo(commonTasks.hbacTest, true);
		}
	/*
	 * Modify Run Test - by using previous button - for positive tests  
	 */
	
	@Test (groups={"hbacModifyRunTests"}, description="HBAC Run Test - missing required field", dataProvider="getHBACModifyRunTestObjects")
	public void testModifyRunTest(String testName, String user,String servicename, String rules, String rules1, String servicename1, String user1,String mrule1, String mrule2,String mrule3, String expectedResult) throws Exception 
		{
			HBACTasks.createModifyRunTest (sahiTasks,user,fqdn0,servicename,fqdn1,rules,rules1,fqdn0,servicename1,fqdn1,user1,mrule1,mrule2,mrule3,expectedResult);
			
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
	public void testExternalSpecificationTest(String testName, String user, String targethost, String service, String sourcehost,String rule,String mrule1, String mrule2,String mrule3,
			 String unmrule1, String unmrule2,String unmrule3, String expectedResult) throws Exception 
		{
			HBACTasks.externalSpecificationTest (sahiTasks, user, targethost, service, sourcehost, rule,mrule1,mrule2,mrule3,unmrule1,unmrule2,unmrule3, expectedResult);
			
			sahiTasks.navigateTo(commonTasks.hbacTest, true);
		}
	/*
	 * HBAC Rule include Enable and Disable Test
	 */
	@Test (groups={"hbacRuleIncludeTests"}, description="Rune based on Positive and Negative Tests for rule enable and disable", dataProvider="getHBACRuleIncludeTestObjects")
	public void testHBACRuleTest(String testName, String user,String servicename ,String rule, String expectedResult1, String expectedResult2, String expectedResult3,
			String mrule1a, String mrule2a,String mrule3a, String unmrule1a, String unmrule2a,String unmrule3a,
			String mrule1b, String mrule2b,String mrule3b, String unmrule1b, String unmrule2b,String unmrule3b,
			String mrule1c, String mrule2c,String mrule3c, String unmrule1c, String unmrule2c,String unmrule3c) throws Exception 
	{
		if (testName.equals("Rule_enabled_service_smtp1_Test"))
		{
			System.out.println("In this test rule 'smtp'is enabled. In this rule(smtp) via-service used is 'smtp1'");
			HBACTasks.testRuleIncludeTest(sahiTasks,user,fqdn1,servicename,fqdn0,rule,expectedResult1,expectedResult2,expectedResult3,
					mrule1a,mrule2a,mrule3a,unmrule1a,unmrule2a,unmrule3a,
					mrule1b,mrule2b,mrule3b,unmrule1b,unmrule2b,unmrule3b,
					mrule1c,mrule2c,mrule3c,unmrule1c,unmrule2c,unmrule3c);	
		}
		if(testName.equals("Rule_disabled_service_smtp1_Test"))
		{
			//changing smtp rule enable to rule disable
			System.out.println("In this test rule 'smtp'is disable. In this rule(smtp) via-service used is 'smtp1'");
		    sahiTasks.link("HBAC Rules").click();
		    sahiTasks.link("smtp").click();
		    //sahiTasks.radio("ipaenabledflag-1-1").click();
		    sahiTasks.select("action").choose("Disable");
		    sahiTasks.span("Apply").click();
		    //sahiTasks.span("Update").click();
		    sahiTasks.navigateTo(commonTasks.hbacPage, true);//mvarun
		    sahiTasks.link("HBAC Test").click();
		    HBACTasks.testRuleIncludeTest(sahiTasks,user,fqdn1,servicename,fqdn0,rule,expectedResult1,expectedResult2,expectedResult3,
					mrule1a,mrule2a,mrule3a,unmrule1a,unmrule2a,unmrule3a,
					mrule1b,mrule2b,mrule3b,unmrule1b,unmrule2b,unmrule3b,
					mrule1c,mrule2c,mrule3c,unmrule1c,unmrule2c,unmrule3c);	
		}
		if(testName.equals("Rule_disabled_service_smtp2_Test"))
		{
			System.out.println("In this test rule 'smtp'is disable. In this rule(smtp) via-service used is 'smtp2'");
			//changing via-service smtp1 to smtp2.
			//deleting smtp1
			sahiTasks.link("HBAC Rules").click();
			sahiTasks.link(rule).click();
			sahiTasks.checkbox("memberservice_hbacsvc").near(sahiTasks.row("smtp1")).click();//mvarun
			if(sahiTasks.tableHeader("Services DeleteAdd").exists())
			{
				sahiTasks.span("Delete").near(sahiTasks.tableHeader("Services DeleteAdd")).click();//for IE
			}
			else
			{
				sahiTasks.span("Delete").near(sahiTasks.tableHeader("ServicesDeleteAdd")).click();//for fireFox
			}
			
			sahiTasks.button("Delete").click();
			sahiTasks.link("HBAC Rules").in(sahiTasks.div("content nav-space-3")).click();
			//adding smtp2
			String searchString = "smtp2";
			String searchResult[] = {"smtp2" };
			HBACTasks.modifyHBACRuleViaServiceSection_forHBACTest(sahiTasks, rule, searchString, searchResult);
			sahiTasks.link("HBAC Test").click();
		    HBACTasks.testRuleIncludeTest(sahiTasks,user,fqdn1,servicename,fqdn0,rule,expectedResult1,expectedResult2,expectedResult3,
					mrule1a,mrule2a,mrule3a,unmrule1a,unmrule2a,unmrule3a,
					mrule1b,mrule2b,mrule3b,unmrule1b,unmrule2b,unmrule3b,
					mrule1c,mrule2c,mrule3c,unmrule1c,unmrule2c,unmrule3c);	
		}
		if(testName.equals("Rule_enabled_service_smtp2_Test"))
		{
			System.out.println("In this test rule 'smtp'is enabled. In this rule(smtp) via-service used is 'smtp2'");
			//changing smtp rule disable to rule enable
			sahiTasks.link("HBAC Rules").click();
		    sahiTasks.link("smtp").click();
		    //sahiTasks.radio("ipaenabledflag-1-0").click();
		    //sahiTasks.span("Update").click();
		    sahiTasks.select("action").choose("Enable");
		    sahiTasks.span("Apply").click();
		    sahiTasks.navigateTo(commonTasks.hbacPage, true);//mvarun
		    sahiTasks.link("HBAC Test").click();		    
		    HBACTasks.testRuleIncludeTest(sahiTasks,user,fqdn1,servicename,fqdn0,rule,expectedResult1,expectedResult2,expectedResult3,
					mrule1a,mrule2a,mrule3a,unmrule1a,unmrule2a,unmrule3a,
					mrule1b,mrule2b,mrule3b,unmrule1b,unmrule2b,unmrule3b,
					mrule1c,mrule2c,mrule3c,unmrule1c,unmrule2c,unmrule3c);	
		    //restore default settings 
		    System.out.println("restoring default setting");
		    sahiTasks.link("HBAC Rules").click();
			sahiTasks.link(rule).click();
			sahiTasks.checkbox("memberservice_hbacsvc").near(sahiTasks.row("smtp2")).click();
			if(sahiTasks.tableHeader("Services DeleteAdd").exists())
			{
				sahiTasks.span("Delete").near(sahiTasks.tableHeader("Services DeleteAdd")).click();//for IE
			}
			else
			{
				sahiTasks.span("Delete").near(sahiTasks.tableHeader("ServicesDeleteAdd")).click();//for fireFox
			}
			sahiTasks.button("Delete").click();
			sahiTasks.link("HBAC Rules").in(sahiTasks.div("content nav-space-3")).click();
			String searchString = "smtp1";
			String searchResult[] = {"smtp1"};
			HBACTasks.modifyHBACRuleViaServiceSection_forHBACTest(sahiTasks, rule, searchString, searchResult);
		}
		
		
			sahiTasks.navigateTo(commonTasks.hbacTest, true);
	}
		
	/*
	 * HBAC Rule Matched and Unmatched Test
	 */
	
	@Test (groups={"hbacRuleMatchTests"}, description="Positive Test for Matching and unmatching", dataProvider="getHBACRuleMatchObjects")
	public void testHBACRuleMatchTest(String testName, String user,String servicename, String match, String unmatch, String mrule1, String mrule2,String mrule3,String unmrule1, String unmrule2,String unmrule3,String expectedResult) throws Exception 
	{
		
			HBACTasks.testRuleMatchTest(sahiTasks,user,fqdn1,servicename,fqdn0,match,unmatch,mrule1,mrule2,mrule3,unmrule1,unmrule2,unmrule3,expectedResult);
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
		
		//                                  testName			  user		  	service   rules	    mrule1   		 mrule2 	 mrule3		 unmrule1		 unmrule2		unmrule3      expectedResult
		ll.add(Arrays.asList(new Object[]{"positive_test",   "hbacrunuser945",   "smtp1",  "smtp",   "smtp",			   "",			"",			"",				"",				"",		 "Access Granted"}));
		ll.add(Arrays.asList(new Object[]{"wrong_who",       "hbacrunuser6348",  "smtp1",  "smtp", 	  "",			 	"",			"",			"",				"",				"smtp",  "Access Denied"}));
		ll.add(Arrays.asList(new Object[]{"wrong_accessing", "hbacrunuser945",   "smtp1",  "smtp", 	  "",				"",			"",			"",				"",				"smtp",  "Access Denied"}));
		ll.add(Arrays.asList(new Object[]{"wrong_viaservice","hbacrunuser945",   "ftp",   "smtp", 	  "",				"",			"",			"",				"",				"smtp",  "Access Denied"}));
		ll.add(Arrays.asList(new Object[]{"wrong_rule",      "hbacrunuser945",   "smtp1",  "denial",	  "",				"",			"",			"",				"",				"denial", "Access Denied"}));
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
		
		//                                  testName			    user          	       hostName1  						service           hostName2  				  rules	            				   expectedError1(for firefox)																			expectedError2(for IE)
		ll.add(Arrays.asList(new Object[]{"deselect_who",  	         "",         		"banana."+domain,   				"smtp1",     "apple."+domain,  				 "smtp",     "Input form contains invalid or missing values.Missing values: User name",     								"Input form contains invalid or missing values. Missing values: User name"}));//xdong
    	ll.add(Arrays.asList(new Object[]{"deselect_accessing",  "hbacrunuser945",              "",     				    "smtp1",      "apple."+domain, 				 "smtp",     "Input form contains invalid or missing values.Missing values: Target host", 									"Input form contains invalid or missing values. Missing values: Target host"}));
		ll.add(Arrays.asList(new Object[]{"deselect_viaservices","hbacrunuser945",      "banana."+domain,    				 "",         "apple."+domain,  				 "smtp",     "Input form contains invalid or missing values.Missing values: Service",      								    "Input form contains invalid or missing values. Missing values: Service"}));
		ll.add(Arrays.asList(new Object[]{"deselect_from",       "hbacrunuser945",      "banana."+domain,   				 "smtp1",        "",               			 "smtp",     "Input form contains invalid or missing values.Missing values: Source host"   ,								"Input form contains invalid or missing values. Missing values: Source host"}));
		ll.add(Arrays.asList(new Object[]{"deselect_all",           "",  		 		        "",   						 "",           "",        				      "smtp",     "Input form contains invalid or missing values.Missing values: User name Target host Service Source host",   "Input form contains invalid or missing values. Missing values: User name Target host Service Source host"}));//xdong
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
		
		//                                  testName			  			user		  	service    rules	  rules    service      user        mrule1   		 mrule2 	 mrule3		expectedResult
		ll.add(Arrays.asList(new Object[]{"prev_button_positive_test",   "hbacrunuser6348",   "ftp",  "denial",  "smtp",   "smtp1", "hbacrunuser945","smtp",			   "",			"",    "Access Granted"}));
		
		return ll;
	}
	
	/*
	 * Data to be used when searching : Positive and Negative Test
	 */
	@DataProvider(name="getHBACSearchTestObjects")
	public Object[][] getHBACSearchTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createHBACSearchTestObjects());
	}
	protected List<List<Object>> createHBACSearchTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname				   user       			 target_host 					service			 source_host				multiple_result1	       		
	    ll.add(Arrays.asList(new Object[]{ "search_who",			       "hbacrunuser945",			"" , 						   "",				"",							""		} ));
		ll.add(Arrays.asList(new Object[]{ "Negative_search_who",			  "varun",			        "" , 						   "",				"",							""		} ));
		ll.add(Arrays.asList(new Object[]{ "search_accessing",		          "",				"banana."+domain,                      "",				"",    						""		} ));
		ll.add(Arrays.asList(new Object[]{ "Negative_search_accessing",		   "",				"zeta."+domain,                        "",				"",    						""		} ));
		ll.add(Arrays.asList(new Object[]{ "search_viaservice",	               "",					"",							     "smtp",			"",			      		    "smtp2" } ));
		ll.add(Arrays.asList(new Object[]{ "Negative_search_viaservice",	    "",					"",							     "ffd",			"",			      		        "" } ));
		ll.add(Arrays.asList(new Object[]{ "search_from",				        "",				      "",								"",	         "apple."+domain,                 ""     } ));     
		ll.add(Arrays.asList(new Object[]{ "Negative_search_from",				  "",				    "",								"",	         "tera."+domain,                ""     } ));
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
		
        //									    testname											user       					 target_host 					service			    source_host				  rule 	    mrule1   		 mrule2 	 mrule3		 unmrule1		 unmrule2		unmrule3 			expected_result	       		
		//ll.add(Arrays.asList(new Object[]{ "positive_specify_external_user_hosts,service",	    "redhatuser",			       "zeta."+domain , 				 "ftpd",	    "tera."+domain,	          "allow_all", "allow_all",		   "",			"",			"",				"",				"",		    	    "Access Granted"	} ));
		ll.add(Arrays.asList(new Object[]{ "specify_external_user_hosts,service_test",      	    "fedorauser",			       "yotta."+domain , 				 "ftpd",	    "peta."+domain,	           "",        "allow_all",		   "",			"",	     "denial",    		"smtp",				"",		   	        "Access Granted"	} ));
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
																																												 //(mrule= Matched rule  and   unmrule= Unmatched Rule)											
		//                                  testName						    user		 service   	rule    expectedResult1rule1    expectedResult2		expectedResult3      mrule1a  mrule2a	mrule3a     unmrule1a 	unmrule2a   unmrule3a   mrule1b    mrule2b	mrule3b     unmrule1b 	unmrule2b   unmrule3b   mrule1c       mrule2c   	mrule3c     unmrule1c 	unmrule2c   unmrule3c
       	ll.add(Arrays.asList(new Object[]{"Rule_enabled_service_smtp1_Test", "hbacrunuser945","smtp1",  "smtp",    "Access Granted"      ,"Access Denied",    "Access Granted",   "smtp",    "",      ""           ,""          ,""       ,""         ,""        ,""      ,""         ,""           ,""         ,""     ,"smtp"       ,"allow_all"    ,""        ,"denial"      ,""       ,""}));
		ll.add(Arrays.asList(new Object[]{"Rule_disabled_service_smtp1_Test","hbacrunuser945","smtp1",  "smtp"    ,"Access Granted"      ,"Access Granted"    ,"Access Granted"   ,"smtp"   ,""      ,""          , ""          ,""       ,""         ,"smtp"    ,""      ,""         ,""           ,""         ,""     ,"allow_all"  ,""             ,""        ,"denial"      ,""       ,""}));
		ll.add(Arrays.asList(new Object[]{"Rule_disabled_service_smtp2_Test","hbacrunuser945","smtp1"  ,"smtp"    ,"Access Denied"       ,"Access Denied"     ,"Access Granted"   ,""       ,""      ,""          , "smtp"      ,""       ,""         , ""       ,""      ,""         ,"smtp"       ,""         ,""     ,"allow_all"  ,""             ,""        ,"denial"      ,""       ,""}));
		ll.add(Arrays.asList(new Object[]{"Rule_enabled_service_smtp2_Test", "hbacrunuser945","smtp1"  ,"smtp"    ,"Access Denied"       ,"Access Denied"     ,"Access Granted"   ,""       ,""      ,""          , "smtp"      ,""       ,""         , ""       ,""      ,""         ,""           ,""         ,""     ,"allow_all"  ,""             ,""        ,"denial"      ,"smtp"   ,""}));
		
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
			
		//                                  testName				 		   user		    service     match    	un_match      mrule1   		 mrule2 	 mrule3		 unmrule1		 unmrule2		unmrule3    expectedResult
		ll.add(Arrays.asList(new Object[]{"Rule_Matched_and_Unmatched_test",  "admin",  	 "smtp1",  "matched",   "unmatched",   "allow_all",	"denial",     "",		  "smtp",	        "",		    	"",     "Access Granted"}));

		return ll;
	}
	
}
