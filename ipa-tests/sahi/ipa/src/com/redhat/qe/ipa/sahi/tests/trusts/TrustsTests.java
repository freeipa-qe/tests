package com.redhat.qe.ipa.sahi.tests.trusts;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.TrustsTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;


/*
 * TODO:
 1.mvarun : trustsAddAndAnotherTests :: Have to provide different domain names for adding trusts
 2.mvarun-add Negative test : trustsAddNegativeTests :: duplicate trust test should be added.
 3.mvarun- add test :: pre-shared-password test should be added. 
 
 
 
 
 */

public class TrustsTests extends SahiTestScript{
private static Logger log = Logger.getLogger(TrustsTests.class.getName());
	
	private String currentPage = "";
	private String alternateCurrentPage = "";
	
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true, dependsOnGroups="setup")
	public void initialize() throws CloneNotSupportedException {	
		
		sahiTasks.navigateTo(commonTasks.trustsPage, true);
		sahiTasks.setStrictVisibilityCheck(true);
	}
	
	@BeforeMethod (alwaysRun=true)
	public void checkURL(){
		String currentURL = sahiTasks.fetch("top.location.href");
		CommonTasks.checkError(sahiTasks);
		if (!currentURL.equals(commonTasks.trustsPage)){
			log.info("current url=("+currentURL + "), is not a starting position, move to url=("+ commonTasks.trustsPage +")");
			sahiTasks.navigateTo(commonTasks.trustsPage, true);
		}
	}
	
	
	@Test (groups={"trustsAddTests"}, dataProvider="getTrustsAddTestObjects",dependsOnGroups={"trustsAddAndCancelTests","trustsAddNegativeTests","trustsAddAndAnotherTests","trustsAddAndEditTests"})	
	
	public void testTrustsAdd(String testName, String realmName, String account,String password,String buttonToClick ) throws Exception {
		//verify Trust doesn't already exist
		Assert.assertFalse(sahiTasks.link(realmName).exists(), "Verify RealmName " + realmName + " doesn't already exist");
		//new trust can be added now
		TrustsTasks.addTrusts(sahiTasks,realmName,account,password,buttonToClick);
		//verify trust was added successfully
		Assert.assertTrue(sahiTasks.link(realmName).exists(), "Added RealmName " + realmName + " successfully");
	}
	
	//TODO : 2 
	 
@Test (groups={"trustsAddNegativeTests"}, dataProvider="getTrustsAddNegativeTestObjects")	
	
	public void testTrustsAddNegative(String testName, String realmName, String account,String password,String expectedError,String buttonToClick ) throws Exception {
		//new Negative Trust can be added now
		TrustsTasks.addNegativeTrusts(sahiTasks,realmName,account,password,expectedError,buttonToClick);
		//verify trust was not added successfully
		if(!realmName.equals(""))
		{
				Assert.assertFalse(sahiTasks.link(realmName).exists(), "Verify RealmName " + realmName + " doesn't added");
		}
	}
	
	
	
@Test (groups={"trustsAddAndCancelTests"}, dataProvider="getTrustsAddAndCancelTestObjects")	
	
	public void testTrustsAddAndCancel(String testName, String realmName, String account,String password,String buttonToClick ) throws Exception {
		//verify Trust doesn't already exist
		Assert.assertFalse(sahiTasks.link(realmName).exists(), "Verify RealmName " + realmName + " doesn't already exist");
		//new Trust can be added now
		TrustsTasks.addTrusts(sahiTasks,realmName,account,password,buttonToClick);
		//verify trust was Canceled successfully
		Assert.assertFalse(sahiTasks.link(realmName).exists(), "Verify RealmName " + realmName + " doesn't added");
	}

/*
 * TODO : 1
 */
@Test (groups={"trustsAddAndAnotherTests"}, dataProvider="getTrustsAddAndAnotherTestObjects")	

	public void testTrustsAddAndAnother(String testName, String firstRealmName, String firstAccount,String firstPassword,String firstButtonToClick,String secondRealmName, String secondAccount,String secondPassword,String secondButtonToClick,String buttonToClick3 ) throws Exception {
	//new trust can be added now
	TrustsTasks.addAndAddAnotheTrusts(sahiTasks,firstRealmName,firstAccount,firstPassword,firstButtonToClick,secondRealmName,secondAccount,secondPassword,secondButtonToClick);
	//verify trust was added successfully
	Assert.assertTrue(sahiTasks.link(firstRealmName).exists(), "Added RealmName " + firstRealmName + " successfully");
	Assert.assertTrue(sahiTasks.link(secondRealmName).exists(), "Added RealmName " + secondRealmName + " successfully");
	//delete trust 
	TrustsTasks.deleteTrusts(sahiTasks, firstRealmName,buttonToClick3);
}
 

@Test (groups={"trustsAddAndEditTests"}, dataProvider="getTrustsAddAndEditTestObjects")	

public void testTrustsAddAndEdit(String testName, String realmName, String account,String password,String buttonToClick,String domainNBName,String domainSecurity,String trustDirection,String trustType,String buttonToClick1 ) throws Exception {
	//verify Trust doesn't already exist
	Assert.assertFalse(sahiTasks.link(realmName).exists(), "Verify RealmName " + realmName + " doesn't already exist");
	//new trust can be added now
	TrustsTasks.addTrusts(sahiTasks,realmName,account,password,buttonToClick);
	//verify Setting
	TrustsTasks.VerifySetting(sahiTasks,realmName,domainNBName,domainSecurity,trustDirection,trustType);
	sahiTasks.span("Refresh").click();
	//verify trust was added successfully
	Assert.assertTrue(sahiTasks.link(realmName).exists(), "Added RealmName " + realmName + " successfully");
	//Delete trust
	TrustsTasks.deleteTrusts(sahiTasks, realmName,buttonToClick1);
	//verify Trust is deleted
	Assert.assertFalse(sahiTasks.link(realmName).exists(), "RealmName " + realmName + "  deleted successfully");
		
}
	
@Test (groups={"trustsSettingTests"}, dataProvider="getTrustsSettingTestObjects",dependsOnGroups="trustsAddTests")	

public void testTrustsAddAndEdit(String testName, String realmName,String domainNBName,String domainSecurity,String trustDirection,String trustType) throws Exception {
	sahiTasks.link(realmName).click();
	//verify Setting
	TrustsTasks.VerifySetting(sahiTasks,realmName,domainNBName,domainSecurity,trustDirection,trustType);
	//verify 
	Assert.assertTrue(sahiTasks.link(realmName).exists(), "Verified Trust Setting successfully");
		
}

@Test (groups={"trustsExpandCollapseTests"}, dataProvider="getTrustsExpandCollapseTestObjects",dependsOnGroups="trustsAddTests")	

public void testTrustsExpandCollapse(String testName, String realmName) throws Exception {
	sahiTasks.link(realmName).click();
	TrustsTasks.expandCollapseTest(sahiTasks);
}
		

	
@Test (groups={"trustsdeleteTests"}, dataProvider="getTrustsDeleteTestObjects",dependsOnGroups={"trustsAddTests","trustsAddAndCancelTests","trustsdeleteAndCancelTests","trustsSettingTests","trustsExpandCollapseTests"})	
	
	public void testTrustsDelete(String testName, String realmName,String buttonToClick) throws Exception {
		//verify Trust to be deleted exists
		Assert.assertTrue(sahiTasks.link(realmName).exists(), "Verify RealmName " + realmName + "  to be deleted exists");
		
		//modify this Trust
		TrustsTasks.deleteTrusts(sahiTasks, realmName,buttonToClick);
		
		//verify Trust is deleted
		Assert.assertFalse(sahiTasks.link(realmName).exists(), "RealmName " + realmName + "  deleted successfully");
		
	}
	
	
@Test (groups={"trustsdeleteAndCancelTests"}, dataProvider="getTrustsDeleteAndCancelTestObjects",dependsOnGroups={"trustsAddTests"})	
	
	public void testTrustsDeleteAndCancel(String testName, String realmName,String buttonToClick) throws Exception {
		//verify Trust to be deleted exists
		Assert.assertTrue(sahiTasks.link(realmName).exists(), "Verify RealmName " + realmName + "  to be deleted exists");
		
		//modify this Trust
		TrustsTasks.deleteTrusts(sahiTasks, realmName,buttonToClick);
		
		//verify Trust is not deleted
		Assert.assertTrue(sahiTasks.link(realmName).exists(), "RealmName " + realmName + "  Not deleted successfully");
		
	}


	
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	/*
	 * Data to be used when adding Trusts
	 */
	
	@DataProvider(name="getTrustsAddTestObjects")
	public Object[][] getTrustsAddTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(addTrustsTestObjects());
	}
	protected List<List<Object>> addTrustsTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname	realmName	    account		  password	    buttonToClick	              		
		ll.add(Arrays.asList(new Object[]{ "add_trusts",	"ipaqe.com",  "administrator", "Secret123",  	"Add"   } ));
		        
		return ll;	
	}
	
	
	/*
	 * Data to be used when negative add trusts
	 */
	@DataProvider(name="getTrustsAddNegativeTestObjects")
	public Object[][] getTrustsAddNegativeTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(addNegativeTrustsTestObjects());
	}
	protected List<List<Object>> addNegativeTrustsTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname	              realmName	        account		     password	     expectedError                                                      buttonToClick	              		
		ll.add(Arrays.asList(new Object[]{ "wrong_domain",	                "newipaqe.com",   "administrator", "Secret123",  "IPA Error 4001close"                                                  		,"Add"   } ));
		ll.add(Arrays.asList(new Object[]{ "domain_with_leadingspace",   	" newipaqe.com",  "administrator", "Secret123",  "invalid 'realm': Leading and trailing spaces are not allowed"          		,"Add"   } ));
		ll.add(Arrays.asList(new Object[]{ "domain_with_traillingspace",	"newipaqe.com ",  "administrator", "Secret123",  "invalid 'realm': Leading and trailing spaces are not allowed"     	        ,"Add"   } ));
		ll.add(Arrays.asList(new Object[]{ "domain_with_blankspace",	      "",             "administrator", "Secret123",  "Required field"                             							       	,"Add"   } ));
		
		ll.add(Arrays.asList(new Object[]{ "wrong_Account",	                "ipaqe.com",      "administrators", "Secret123",  "Insufficient access: CIFS server ipaindia.ipaqe.com denied your credentials" ,"Add"   } ));
		ll.add(Arrays.asList(new Object[]{ "Account_with_leadingspace",   	"ipaqe.com",      " administrator", "Secret123",  "invalid 'realm': Leading and trailing spaces are not allowed"          		,"Add"   } ));
		ll.add(Arrays.asList(new Object[]{ "Account_with_traillingspace",	"ipaqe.com ",     "administrator ", "Secret123",  "invalid 'realm': Leading and trailing spaces are not allowed"            	,"Add"   } ));
		ll.add(Arrays.asList(new Object[]{ "Account_with_blankspace",	    "ipaqe.com",      "",               "Secret123",  "Required field"                             							   		,"Add"   } ));
		
		ll.add(Arrays.asList(new Object[]{ "wrong_Password",	            "ipaqe.com",      "administrator",  "Secret1234",  "Insufficient access: CIFS server ipaindia.ipaqe.com denied your credentials","Add"   } ));
		ll.add(Arrays.asList(new Object[]{ "password_with_blankspace",	    "ipaqe.com",       "administrator", "",  "Required field"                             							      		  	,"Add"   } ));
		         
		return ll;	
	}
	
	
	
	

	/*
	 * Data to be used when add and cancel Trusts
	 */
	

	@DataProvider(name="getTrustsAddAndCancelTestObjects")
	public Object[][] getTrustsAddAndCancelTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(addAndCancelTrustsTestObjects());
	}
	protected List<List<Object>> addAndCancelTrustsTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname        	realmName	    account		  password	    buttonToClick	              		
		ll.add(Arrays.asList(new Object[]{ "addAndCancel_trusts",	"ipaqe.com",  "administrator", "Secret123",  	"Cancel"   } ));
		        
		return ll;	
	}
	
	
	/*
	 * Data to be used when add and add another trust
	 */
	@DataProvider(name="getTrustsAddAndAnotherTestObjects")
	public Object[][] getTrustsAddAndAnotherTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(addTrustsAddAndAnotherTestObjects());
	}
	protected List<List<Object>> addTrustsAddAndAnotherTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname	realmName1	    account1		  password1	    buttonToClick1 			   realmName2	    account2	  password2        buttonToClick2     		buttonToClick3
		ll.add(Arrays.asList(new Object[]{ "add_trusts1",	"ipaqe.com",  "administrator", "Secret123",  	"Add and Add Another",	"ipaqe.com",  "administrator", "Secret123",  	"Add"   			,"Delete"} ));
		
		        
		return ll;	
	}
	
	/*
	 * Data to be used when add and Edit trust
	 */
		
	@DataProvider(name="getTrustsAddAndEditTestObjects")
	public Object[][] getTrustsAddAndEditTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(addAndEditTrustsTestObjects());
	}
	protected List<List<Object>> addAndEditTrustsTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname	realmName	    account		  password	    buttonToClick 		domainNBName          domainSecurity						trustDirection			trustType	              		
		ll.add(Arrays.asList(new Object[]{ "add_trusts",	"ipaqe.com",  "administrator", "Secret123",  	"Add and Edit",  "IPAQE",      "S-1-5-21-2048782538-2375889789-2933420090",  "Two-way trust",  "Active Directory domain","Delete"} ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when verify trust setting
	 */
	
	@DataProvider(name="getTrustsSettingTestObjects")
	public Object[][] getTrustsSettingTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createTrustsSettingTestObjects());
	}
	protected List<List<Object>> createTrustsSettingTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname	       realmName	  domainNBName          domainSecurity						trustDirection			trustType	              		
		ll.add(Arrays.asList(new Object[]{ "trusts_Setting_test",	"ipaqe.com",  "IPAQE",      "S-1-5-21-2048782538-2375889789-2933420090",  "Two-way trust",  "Active Directory domain"} ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when add and Edit trust
	 */
	@DataProvider(name="getTrustsExpandCollapseTestObjects")
	public Object[][] getTrustsExpandCollapseTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createTrustsExpandCollapseTestObjects());
	}
	protected List<List<Object>> createTrustsExpandCollapseTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname	               realmName	               		
		ll.add(Arrays.asList(new Object[]{ "trusts_ExpandCollapse_test",	"ipaqe.com"} ));
		        
		return ll;	
	}
	
	/*
	 * Data to be used when deleting Trusts
	 */
	@DataProvider(name="getTrustsDeleteTestObjects")
	public Object[][] getTrustsDeleteTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteTrustsTestObjects());
	}
	protected List<List<Object>> deleteTrustsTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					realmName    buttonToClick          		
		ll.add(Arrays.asList(new Object[]{ "delete_single_trusts",			"ipaqe.com",  "Delete"   } ));
		        
		return ll;	
	}
	
	
	/*
	 * Data to be used when deleting Trusts
	 */
	@DataProvider(name="getTrustsDeleteAndCancelTestObjects")
	public Object[][] getTrustsDeleteAndCancelTestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(deleteAndCancelTrustsTestObjects());
	}
	protected List<List<Object>> deleteAndCancelTrustsTestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //										testname					realmName    buttonToClick          		
		ll.add(Arrays.asList(new Object[]{ "deleteAndCancel_trusts",			"ipaqe.com",    "Cancel" } ));
		        
		return ll;	
	}
	
}