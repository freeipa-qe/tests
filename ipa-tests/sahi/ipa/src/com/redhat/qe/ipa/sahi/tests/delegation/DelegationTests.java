package com.redhat.qe.ipa.sahi.tests.delegation;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.AfterClass;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.pages.IPAWebAutomation;
import com.redhat.qe.ipa.sahi.tasks.DelegationTasks;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tasks.HostTasks;
import com.redhat.qe.ipa.sahi.tasks.HostgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.NetgroupTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;
import com.redhat.qe.ipa.sahi.tasks.UserTasks;
import com.redhat.qe.ipa.sahi.tests.group.GroupTests;

public class DelegationTests extends SahiTestScript {
	private static Logger log = Logger.getLogger(GroupTests.class.getName());
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true)
	public void initialize() throws CloneNotSupportedException {	
		
		//log.info("kinit as admin");
		//Assert.assertTrue(CommonTasks.kinitAsAdmin(), "Logged in successfully as admin");
		
		log.info("Opening browser");
		sahiTasks.open();
		log.info("Accessing: IPA Server URL");
		sahiTasks.setStrictVisibilityCheck(true);
      	CommonTasks.formauth(sahiTasks, "admin", "Secret123");
				
	}
	
	////////////////////////////////////////////////
	//                test cases                  //
	////////////////////////////////////////////////
	
	@Test (groups={"add"}, description="Delegation Add Single",
			dataProvider="getDelegationAddSingleObjects")	
	public void testDelegationAddSingle(String testName,String delegationName,String permissionType,String groupName,String memberGroup,String attribute) throws Exception {
		sahiTasks.navigateTo(commonTasks.delegationPage, true);
		//verify delegation doesn't exist
		Assert.assertFalse(sahiTasks.link(delegationName).exists(), "Verify delegation " + delegationName + " doesn't already exist");
		//Add delegation : no permission checked,different group and member group,single attribute 
		DelegationTasks.delegation_AddSingle(sahiTasks,delegationName,permissionType,groupName,memberGroup,attribute);		
		//verify delegation was added successfully 
		Assert.assertTrue(sahiTasks.link(delegationName).exists(), "Added delegation " + delegationName + "  successfully");
	}
	
	@Test (groups={"add"}, description="Delegation Add and Add Another",
			dataProvider="getDelegationAddAndAddAnotherObjects")	
	public void testDelegationAddAndAddAnother(String testName, String delegationName1,String permissionType1,String groupName1,String memberGroup1,String attribute1,String delegationName2,String permissionType2,String groupName2,String memberGroup2,String attribute2) throws Exception {
		sahiTasks.navigateTo(commonTasks.delegationPage, true);
		//verify delegation doesn't exist
		Assert.assertFalse(sahiTasks.link(delegationName1).exists(), "Verify delegation " + delegationName1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(delegationName2).exists(), "Verify delegation " + delegationName2 + " doesn't already exist");
		//Add delegation1 :read checked,different group and member group,single attribute
		//Add delegation2 :write checked,different group and memember group,single attribute
		DelegationTasks.delegation_AddAndAddAnother(sahiTasks,delegationName1,permissionType1,groupName1,memberGroup1,attribute1,delegationName2,permissionType2,groupName2,memberGroup2,attribute2);		
		//verify delegation was added successfully 
		Assert.assertTrue(sahiTasks.link(delegationName1).exists(), "Added delegation " + delegationName1 + "  successfully");
		Assert.assertTrue(sahiTasks.link(delegationName2).exists(), "Added delegation " + delegationName2 + "  successfully");
	}
	
	@Test (groups={"add"}, description="Delegation Add and Edit",
			dataProvider="getDelegationAddAndEditObjects")	
	public void testDelegationAddAndEdit(String testName, String delegationName,String permissionType1,String permissionType2,String groupName,String memberGroup,String attribute1,String attribute2) throws Exception {
		sahiTasks.navigateTo(commonTasks.delegationPage, true);
		//verify delegation doesn't exist
		Assert.assertFalse(sahiTasks.link(delegationName).exists(), "Verify delegation " + delegationName + " doesn't already exist");
		//Add delegation : both checked,same group and member group,multiple attributes
		//verify all characters in edit mode
		DelegationTasks.delegation_AddAndEdit(sahiTasks, delegationName, permissionType1,permissionType2,groupName, memberGroup, attribute1, attribute2);
		sahiTasks.link("Delegations").in(sahiTasks.div("content")).click();
		//verify delegation was added successfully 
		sahiTasks.span("Refresh").click();
		Assert.assertTrue(sahiTasks.link(delegationName).exists(), "Added delegation " + delegationName + "  successfully");
		
	}
	
	@Test (groups={"add"}, description="Delegation Add Then Cancel",
			dataProvider="getDelegationAddThenCancelObjects")	
	public void testDelegationAddThenCancel(String testName, String delegationName) throws Exception {
		sahiTasks.navigateTo(commonTasks.delegationPage, true);
		//verify delegation doesn't exist
		Assert.assertFalse(sahiTasks.link(delegationName).exists(), "Verify delegation " + delegationName + " doesn't already exist");
		//Add delegation then cancel
		DelegationTasks.delegation_AddThenCancel(sahiTasks, delegationName);		
		//verify delegation was canceled successfully 
		Assert.assertFalse(sahiTasks.link(delegationName).exists(), "Verify delegation " + delegationName + " doesn't already exist");
	}
	
	@Test (groups={"addNegative"}, description="delegation Add Negative Required Field",dependsOnGroups="add")	
	
	public void testDelegationAddNegativeRequiredField() throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	    	DelegationTasks.delegation_AddNegativeRequiredField(sahiTasks);
	    	Assert.assertTrue(sahiTasks.span("Required field").exists(), "Verified Expected Error Message");
	    	sahiTasks.button("Cancel").click();
	}
	
	@Test (groups={"addDuplicate"}, description="delegation Add Duplicate Bug 818258 -Missing Specified Name In Error Msg", 
			dataProvider="getDelegationAddDuplicateMissingSpecifiedNameBug818258TestObjects",dependsOnGroups="add")	
	
	public void testDelegationAddDuplicateMissingSpecifiedName_Bug8182581(String testName,String delegationName) throws Exception {
	       	//add and add another delegation user group rule and verify the bug
	    	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	    	Assert.assertFalse(sahiTasks.link(delegationName).exists(),"before 'Add', usergroup role does NOT exists");
	    	DelegationTasks.delegation_AddDuplicate(sahiTasks,delegationName);
	    	Assert.assertTrue(sahiTasks.link(delegationName).exists(),"after 'Add', usergroup role exists");	    
	}
	
	
	@Test (groups={"modify"}, description="delegation Condition Add Single",dataProvider="getDelegationConditionAddSingleObjects",dependsOnGroups="add")	
	
	public void testDelegationConditionAddSingle(String testName,String delegationName,String attribute,String expression) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	sahiTasks.link(delegationName).click();
	       	Assert.assertFalse(sahiTasks.div(attribute).exists(), "Verified Condition Not Exist Before Add");
	    	DelegationTasks.delegation_ConditionAddSingle(sahiTasks,testName,attribute,expression);
	    	Assert.assertTrue(sahiTasks.div(attribute).exists(), "Verified Condition Added Successfully");
	    	sahiTasks.link("User group rules").in(sahiTasks.div("content")).click();
	}
	
	@Test (groups={"modify"}, description="delegation Condition Add And Add Another",dataProvider="getDelegationConditionAddAndAddAnotherObjects",dependsOnGroups="add")	
		
	public void testDelegationConditionAddAndAddAnother(String testName,String delegationName,String attribute1,String attribute2,String expression1,String expression2) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	sahiTasks.link(delegationName).click();
	       	Assert.assertFalse(sahiTasks.div(attribute1).exists(), "Verified Condition Not Exist Before Add");
	       	Assert.assertFalse(sahiTasks.div(attribute2).exists(), "Verified Condition Not Exist Before Add");
	       	DelegationTasks.delegation_ConditionAddAndAddAnother(sahiTasks,testName,attribute1,attribute2,expression1,expression2);
	    	Assert.assertTrue(sahiTasks.div(attribute1).exists(), "Verified Condition Added Successfully");
	    	Assert.assertTrue(sahiTasks.div(attribute2).exists(), "Verified Condition Added Successfully");
	    	sahiTasks.link("User group rules").in(sahiTasks.div("content")).click();
	}
	
	@Test (groups={"modify"}, description="delegation Condition Add Then Cancel",dataProvider="getDelegationConditionAddThenCancelObjects",dependsOnGroups="add")	
	
	public void testDelegationConditionAddThenCancel(String testName,String delegationName,String attribute,String expression) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	sahiTasks.link(delegationName).click();
	       	Assert.assertFalse(sahiTasks.div(attribute).exists(), "Verified Condition Not Exist Before Add");
	       	DelegationTasks.delegation_ConditionAddThenCancel(sahiTasks,testName,attribute,expression);
	    	Assert.assertFalse(sahiTasks.div(attribute).exists(), "Verified Condition Add Cancelled Successfully");
	    	sahiTasks.link("User group rules").in(sahiTasks.div("content")).click();
	}
	
	@Test (groups={"modify"}, description="delegation Condition Delete Single",dataProvider="getDelegationConditionDeleteSingleObjects",dependsOnGroups="add")	
	
	public void testDelegationConditionDeleteSingle(String testName,String delegationName,String attribute,String expression) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	sahiTasks.link(delegationName).click();
	       	Assert.assertTrue(sahiTasks.div(attribute).exists(), "Verified Condition Exist Before Delete");
	    	DelegationTasks.delegation_ConditionDeleteSingle(sahiTasks,testName,attribute,expression);
	    	Assert.assertFalse(sahiTasks.div(attribute).exists(), "Verified Condition Deleted Successfully");
	    	sahiTasks.link("User group rules").in(sahiTasks.div("content")).click();
	}
	
	@Test (groups={"modify"}, description="delegation Condition Delete Multiple",dataProvider="getDelegationConditionDeleteMultipleObjects",dependsOnGroups="add")	
	
	public void testDelegationConditionDeleteMultiple(String testName,String delegationName,String attribute1,String attribute2,String expression1,String expression2) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	sahiTasks.link(delegationName).click();
	       	Assert.assertTrue(sahiTasks.div(attribute1).exists(), "Verified Condition Exist Before Delete");
	       	Assert.assertTrue(sahiTasks.div(attribute2).exists(), "Verified Condition Exist Before Delete");
	    	DelegationTasks.delegation_ConditionDeleteMultiple(sahiTasks,testName,attribute1,attribute2,expression1,expression2);
	    	Assert.assertFalse(sahiTasks.div(attribute1).exists(), "Verified Condition Deleted Successfully");
	    	Assert.assertFalse(sahiTasks.div(attribute2).exists(), "Verified Condition Deleted Successfully");
	    	sahiTasks.link("User group rules").in(sahiTasks.div("content")).click();
	}
	
	@Test (groups={"modify"}, description="delegation Default User Group",dataProvider="getDelegationDefaultGroupObjects",dependsOnGroups="add")	
	
	public void testDelegationDefaultGroup(String testName,String delegationName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	Assert.assertEquals(sahiTasks.textbox("delegationdefaultgroup").getValue(),"");
	       	DelegationTasks.delegation_DefaultGroup(sahiTasks,delegationName);
	    	Assert.assertEquals(sahiTasks.textbox("delegationdefaultgroup").getValue(),"");

	}
	
	@Test (groups={"modify"}, description="delegation Generic Edit",dataProvider="getDelegationGenericEditObjects",dependsOnGroups="add")	
	
	public void testDelegationGenericEdit(String testName,String delegationName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	sahiTasks.link(delegationName).click();
	       	DelegationTasks.delegation_GenericEdit(sahiTasks,testName,delegationName);
	}
	
	@Test (groups={"search"}, description="delegation Search",dataProvider="getDelegationSearchObjects",dependsOnGroups="add")	
	
	public void testDelegationSearch(String testName,String delegationName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	CommonTasks.search(sahiTasks,delegationName);
	       	Assert.assertTrue(sahiTasks.link(delegationName).exists(),"search result found as expected");
	       	CommonTasks.clearSearch(sahiTasks);
	}
	
	@Test (groups={"searchNegative"}, description="delegation Search Negative",dataProvider="getDelegationSearchNegativeObjects",dependsOnGroups="add")	
	
	public void testDelegationSearchNegativeBug846754(String testName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	String delegationNames[]={"nonexistent", "n", "'<,>.?/", delegationUserGroupTests.usergroups[2] + " ", " " + delegationUserGroupTests.usergroups[2]};
	    	for (String delegationName:delegationNames) {
	    		CommonTasks.search(sahiTasks,delegationName);
	    		Assert.assertFalse(sahiTasks.link(delegationName).exists(),"search result not found as expected");
	    		CommonTasks.clearSearch(sahiTasks);
	    	}
	}
	
	@Test (groups={"delete"}, description="delegation Delete Single",dataProvider="getDelegationDeleteSingleObjects",dependsOnGroups={"add","modify","addDuplicate","search","searchNegative"})	
	
	public void testDelegationDeleteSingle(String testName,String delegationName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	CommonTasks.search(sahiTasks,delegationName);
	       	Assert.assertTrue(sahiTasks.link(delegationName).exists(),"delegation rule exists before delete");
	       	DelegationTasks.delegation_DeleteSingle(sahiTasks,delegationName);
	       	Assert.assertTrue(sahiTasks.link(delegationName).exists(),"delegation rule exists before delete");
	       	CommonTasks.clearSearch(sahiTasks);
	}
	
	@Test (groups={"delete"}, description="delegation Delete Multiple",dataProvider="getDelegationDeleteMulitpleObjects",dependsOnGroups={"add","modify","addDuplicate","search","searchNegative"})	
	
	public void testDelegationDeleteMultiple(String testName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	String delegationNames[]={delegationUserGroupTests.usergroups[0],delegationUserGroupTests.usergroups[1],delegationUserGroupTests.usergroups[2],delegationUserGroupTests.usergroups[3],delegationUserGroupTests.usergroups[5]};
	       	DelegationTasks.delegation_DeleteMultiple(sahiTasks,delegationNames);
	       	for (String delegationName:delegationNames) {
	       		Assert.assertFalse(sahiTasks.link(delegationName).exists(),"delegation rules don't exist after delete");
	       	}	
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	@DataProvider(name="getDelegationAddSingleObjects")
	public Object[][] getDelegationAddSingleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationAddSingleObjects());
	}
	protected List<List<Object>> createDelegationAddSingleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName        delegationName     permissionType   groupName   memberGroup attribute			
		ll.add(Arrays.asList(new Object[]{ "add single",   "delegation001",         "",        "editors",  "ipausers",  "audio" } ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationAddAndAddAnotherObjects")
	public Object[][] getDelegationAddAndAddAnotherObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationAddAndAddAnotherObjects());
	}
	protected List<List<Object>> createDelegationAddAndAddAnotherObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName		 	  delegationName1 permissionType1 groupName1  memberGroup1     attribute1       delegationName2   permissionType2  groupName2  memberGroup2 attribute2
		ll.add(Arrays.asList(new Object[]{ "add and add another", "delegation002",    "read",    "editors", "ipausers",   "businesscategory",  "delegation003",     "write",     "editors",  "ipausers", "carlicense"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationAddAndEditObjects")
	public Object[][] getDelegationAddAndEditObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationAddAndEditObjects());
	}
	protected List<List<Object>> createDelegationAddAndEditObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									  testName		 delegationName	 permissionType1 permissionType2 groupName memberGroup     attribute1      attribute2		
		ll.add(Arrays.asList(new Object[]{ "add and edit",  "delegation004",     "read",        "write",     "editors", "editors", "departmentnumber","description"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationAddThenCancelObjects")
	public Object[][] getDelegationAddThenCancelObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationAddThenCancelObjects());
	}
	protected List<List<Object>> createDelegationAddThenCancelObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName		 	   delegationName			
		ll.add(Arrays.asList(new Object[]{ "add then cancel",   delegationUserGroupTests.usergroups[4]} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationAddDuplicateMissingSpecifiedNameBug818258TestObjects")
	public Object[][] getDelegationAddDuplicateMissingSpecifiedNameBug818258TestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationAddDuplicateMissingSpecifiedNameBug818258TestObjects());
	}
	protected List<List<Object>> createDelegationAddDuplicateMissingSpecifiedNameBug818258TestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName		 	   delegationName			
		ll.add(Arrays.asList(new Object[]{ "add duplicate",   delegationUserGroupTests.usergroups[5]} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationConditionAddSingleObjects")
	public Object[][] getDelegationConditionAddSingleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationConditionAddSingleObjects());
	}
	protected List<List<Object>> createDelegationConditionAddSingleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									  testName          delegationName                           attribute     expression			
		ll.add(Arrays.asList(new Object[]{ "Inclusive",   delegationUserGroupTests.usergroups[0],    "audio",       "audio"} ));
		ll.add(Arrays.asList(new Object[]{ "Exclusive",   delegationUserGroupTests.usergroups[0],    "businesscategory",  "businesscategory"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationConditionAddAddAddAnotherObjects")
	public Object[][] getDelegationConditionAddAndAddAnotherObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationConditionAddAndAddAnotherObjects());
	}
	protected List<List<Object>> createDelegationConditionAddAndAddAnotherObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									  testName          delegationName                           attribute1       attribute2      expression1	expression2		
		ll.add(Arrays.asList(new Object[]{ "Inclusive",   delegationUserGroupTests.usergroups[0],    "carlicense",       "cn",      "carlicense",      "cn"}));
		ll.add(Arrays.asList(new Object[]{ "Exclusive",   delegationUserGroupTests.usergroups[0],   "departmentnumber", "description", "departmentnumber","description"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationConditionAddThenCancelObjects")
	public Object[][] getDelegationConditionAddThenCancelObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationConditionAddThenCancelObjects());
	}
	protected List<List<Object>> createDelegationConditionAddThenCancelObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									  testName          delegationName                           attribute               expression			
		ll.add(Arrays.asList(new Object[]{ "Inclusive",   delegationUserGroupTests.usergroups[0], "destinationindicator", "destinationindicator"} ));
		ll.add(Arrays.asList(new Object[]{ "Exclusive",   delegationUserGroupTests.usergroups[0],   "displayname",        "displayname"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationConditionDeleteSingleObjects")
	public Object[][] getDelegationConditionDeleteSingleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationConditionDeleteSingleObjects());
	}
	protected List<List<Object>> createDelegationConditionDeleteSingleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									  testName          delegationName                           attribute             expression			
		ll.add(Arrays.asList(new Object[]{ "Inclusive",   delegationUserGroupTests.usergroups[0],    "audio" ,             "audio"} ));
		ll.add(Arrays.asList(new Object[]{ "Exclusive",   delegationUserGroupTests.usergroups[0],   "businesscategory", "businesscategory"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationConditionDeleteMultipleObjects")
	public Object[][] getDelegationConditionDeleteMultipleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationConditionDeleteMultipleObjects());
	}
	protected List<List<Object>> createDelegationConditionDeleteMultipleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									  testName          delegationName                           attribute1       attribute2      expression1	expression2			
		ll.add(Arrays.asList(new Object[]{ "Inclusive",   delegationUserGroupTests.usergroups[0],    "carlicense",       "cn",      "carlicense",      "cn"} ));
		ll.add(Arrays.asList(new Object[]{ "Exclusive",   delegationUserGroupTests.usergroups[0],   "departmentnumber", "description", "departmentnumber","description"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationDefaultGroupObjects")
	public Object[][] getDelegationDefaultGroupObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationDefaultGroupObjects());
	}
	protected List<List<Object>> createDelegationDefaultGroupObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName		 	             delegationName			
		ll.add(Arrays.asList(new Object[]{ "modify default user group",   delegationUserGroupTests.usergroups[1]} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationGenericEditObjects")
	public Object[][] getDelegationGenericEditObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationGenericEditObjects());
	}
	protected List<List<Object>> createDelegationGenericEditObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName		 	             delegationName			              
		ll.add(Arrays.asList(new Object[]{ "User group rules",   delegationUserGroupTests.usergroups[2]} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationSearchObjects")
	public Object[][] getDelegationSearchObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationSearchObjects());
	}
	protected List<List<Object>> createDelegationSearchObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName		 	             delegationName			              
		ll.add(Arrays.asList(new Object[]{ "search positive",   delegationUserGroupTests.usergroups[3]} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationSearchNegativeObjects")
	public Object[][] getDelegationSearchNegativeObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationSearchNegativeObjects());
	}
	protected List<List<Object>> createDelegationSearchNegativeObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName			              
		ll.add(Arrays.asList(new Object[]{ "search negative" } ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationDeleteSingleObjects")
	public Object[][] getDelegationDeleteSingleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationGenericEditObjects());
	}
	protected List<List<Object>> createDelegationDeleteSingleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName		 	             delegationName			              
		ll.add(Arrays.asList(new Object[]{ "delete single",   delegationUserGroupTests.usergroups[0]} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationDeleteMultipleObjects")
	public Object[][] getDelegationDeleteMultipleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationGenericEditObjects());
	}
	protected List<List<Object>> createDelegationDeleteMultipleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName				              
		ll.add(Arrays.asList(new Object[]{ "delete multiple"} ));
		return ll;	
	}
}	