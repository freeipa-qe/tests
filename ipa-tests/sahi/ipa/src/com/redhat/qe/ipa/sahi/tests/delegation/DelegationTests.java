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
import com.redhat.qe.ipa.sahi.tests.automember.AutomemberUserGroupTests;
import com.redhat.qe.ipa.sahi.tests.group.GroupTests;

public class DelegationTests extends SahiTestScript {
	private static Logger log = Logger.getLogger(GroupTests.class.getName());
	String[] users = {"delegationuser1","delegationmemberuser1","delegationmemberuser2"};
  	String[] groups = {"delegationgroup1","delegationmembergroup1","delegationmembergroup2"};
	
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true)
	public void initialize() throws CloneNotSupportedException {	
		
		log.info("Opening browser");
		sahiTasks.open();
		log.info("Accessing: IPA Server URL");
		sahiTasks.setStrictVisibilityCheck(true);
      	CommonTasks.formauth(sahiTasks, "admin", "Secret123");
      	
      	      	
      	//add users for delegation
		sahiTasks.navigateTo(commonTasks.userPage, true);
		for (String username : users){
			UserTasks.createUser(sahiTasks,username,username,username,username,username,"Add");
		} 
		
		//add groups for delegation
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		for (String groupname : groups){
			String groupDescription = groupname + " description";
			GroupTasks.addGroup(sahiTasks, groupname, groupDescription);
		} 
		
		//add user to group 
		sahiTasks.navigateTo(commonTasks.userPage, true);
		for(int i=0;i<3;i++){
			sahiTasks.link(users[i]).click();
			sahiTasks.link("memberof_group").click();
			sahiTasks.span("Add").click();
			sahiTasks.checkbox(groups[i]).click();
			sahiTasks.span(">>").click();
			sahiTasks.button("Add").click();
			sahiTasks.link("Users").in(sahiTasks.div("content")).click();;
		}
	}
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	

		//delete users for delegation
    	sahiTasks.navigateTo(commonTasks.userPage, true);
    	for (String username : users) {
    	 	UserTasks.deleteUser(sahiTasks, username);
    		Assert.assertFalse(sahiTasks.link(username).exists(),"after 'Delete', user does NOT exists");
    	}
		
		//delete groups for delegation
    	sahiTasks.navigateTo(commonTasks.groupPage, true);
    	for (String usergroup : groups) {
    		GroupTasks.deleteGroup(sahiTasks, usergroup);
    		Assert.assertFalse(sahiTasks.link(usergroup).exists(),"after 'Delete', usergroup does NOT exists");
    	}
	}
	
	////////////////////////////////////////////////
	//                test cases                  //
	////////////////////////////////////////////////
	
	@Test (groups={"add"}, description="Delegation Add Single",
			dataProvider="getDelegationAddSingleObjects")	
	public void testDelegationAddSingle(String testName,String delegationName,String groupName,String memberGroup,String attribute) throws Exception {
		sahiTasks.navigateTo(commonTasks.delegationPage, true);
		//verify delegation doesn't exist
		Assert.assertFalse(sahiTasks.link(delegationName).exists(), "Verify delegation " + delegationName + " doesn't already exist");
		//Add delegation : no permission checked,different group and member group,single attribute 
		DelegationTasks.delegation_AddSingle(sahiTasks,delegationName,groupName,memberGroup,attribute);		
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
	public void testDelegationAddThenCancel(String testName,String delegationName,String permissionType,String groupName,String memberGroup,String attribute) throws Exception {
		sahiTasks.navigateTo(commonTasks.delegationPage, true);
		//verify delegation doesn't exist
		Assert.assertFalse(sahiTasks.link(delegationName).exists(), "Verify delegation " + delegationName + " doesn't already exist");
		//Add delegation then cancel
		DelegationTasks.delegation_AddThenCancel(sahiTasks, delegationName, permissionType, groupName, memberGroup, attribute);		
		//verify delegation was canceled successfully 
		Assert.assertFalse(sahiTasks.link(delegationName).exists(), "Verify delegation " + delegationName + " doesn't already exist");
	}
	
	@Test (groups={"addLong"}, description="Delegation Add Long", 
			dataProvider="getDelegationAddLongObjects",dependsOnGroups="add")	
	
	public void testDelegationAddLong(String testName,String delegationName,String permissionType,String groupName,String memberGroup,String attribute) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	    	Assert.assertFalse(sahiTasks.link(delegationName).exists(),"before 'Add', delegation does NOT exists");
	    	DelegationTasks.delegation_AddLong(sahiTasks,delegationName,permissionType,groupName,memberGroup,attribute);
	    	Assert.assertTrue(sahiTasks.link(delegationName).exists(),"after 'Add', delegation exists");	    
	}
	
	@Test (groups={"addNegative"}, description="Delegation Add Negative Required Field",dataProvider="getDelegationAddNegativeObjects",dependsOnGroups="add")	
	
	public void testDelegationAddNegativeRequiredField(String testName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	    	DelegationTasks.delegation_AddNegativeRequiredField(sahiTasks);
	    	Assert.assertTrue(sahiTasks.span("Required field").exists(), "Verified Expected Error Message");
	    	sahiTasks.button("Cancel").click();
	}
	
	@Test (groups={"addNegative"}, description="Delegation Add Negative Name",dataProvider="getDelegationAddNegativeNameObjects",dependsOnGroups="add")	
	
	public void testDelegationAddNegativeName(String testName,String permissionType,String groupName,String memberGroup,String attribute) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	String[] delegationNames = {"a:;'<>.?/(ACL Syntax Error)", " " + "delegation007(invalid 'name': Leading and trailing spaces are not allowed)", "delegation007(invalid 'name': Leading and trailing spaces are not allowed)" + " "};
	       	for(String delegationName : delegationNames){
	       		DelegationTasks.delegation_AddNegativeName(sahiTasks,delegationName, permissionType, groupName, memberGroup, attribute);
	       		Assert.assertTrue(sahiTasks.div("error_dialog").exists(), "Verified Expected Error Message");
	       		sahiTasks.button("Cancel[1]").click();
	       		sahiTasks.button("Cancel").click();
	       	}
	}
	
	@Test (groups={"addDuplicate"}, description="Delegation Add Duplicate", 
			dataProvider="getDelegationAddDuplicateObjects",dependsOnGroups="add")	
	
	public void testDelegationAddDuplicate(String testName,String delegationName,String permissionType,String groupName,String memberGroup,String attribute) throws Exception {
	       	//add and add another delegation user group rule and verify the bug
	    	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	    	Assert.assertFalse(sahiTasks.link(delegationName).exists(),"before 'Add', delegation does NOT exists");
	    	DelegationTasks.delegation_AddDuplicate(sahiTasks,delegationName,permissionType,groupName,memberGroup,attribute);
	    	Assert.assertTrue(sahiTasks.link(delegationName).exists(),"after 'Add', delegation exists");	    
	}
	
	@Test (groups={"modify"}, description="Delegation Generic Edit",dataProvider="getDelegationGenericEditObjects",dependsOnGroups="add")	
	
	public void testDelegationGenericEdit(String testName,String delegationName,String permissionType,String groupName,String memberGroup,String attribute) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	DelegationTasks.delegation_AddSingle(sahiTasks,delegationName,groupName,memberGroup,attribute);
	       	sahiTasks.link(delegationName).click();
	       	DelegationTasks.delegation_GenericEdit(sahiTasks,delegationName,permissionType,groupName,memberGroup,attribute);
	}
	
	@Test (groups={"modify with no delegation"}, description="Unable To Edit Userinfo With No Delegation",dataProvider="getUnableToEditUserinfoWithNoDelegationObjects",dependsOnGroups="add")	
	
	public void testEditUserinfoWithNoDelegation(String testName,String undelegatedUser,String userToBeEdited) throws Exception {
			CommonTasks.formauthNewUser(sahiTasks, undelegatedUser, undelegatedUser,"Secret123");
			sahiTasks.link("Users").in(sahiTasks.div("content")).click();
			DelegationTasks.delegation_EditUserinfoWithNoDelegation(sahiTasks,userToBeEdited);
			CommonTasks.formauth(sahiTasks, "admin", "Secret123");
	}
		
	@Test (groups={"modify with delegation"}, description="Edit Valid Userinfo With Delegation",dataProvider="getEditValidUserinfoWithDelegationObjects",dependsOnGroups={"add","modify with no delegation"})	
	
	public void testEditUserinfoWithDelegation(String testName,String delegationName,String permissionType, String groupName,String memberGroup,String attribute1,String attribute2,String delegatedUser,String userToBeEdited1,String userToBeEdited2,String displayNameToUpdate,String emailToUpdate) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	DelegationTasks.delegation_EditUserinfoWithDelegation(sahiTasks,delegationName,permissionType,groupName,memberGroup,attribute1,attribute2,delegatedUser,userToBeEdited1,userToBeEdited2,displayNameToUpdate,emailToUpdate);
	       	CommonTasks.formauth(sahiTasks, "admin", "Secret123");
	}
	
	@Test (groups={"search"}, description="Delegation Search",dataProvider="getDelegationSearchObjects",dependsOnGroups={"add","modify with no delegation","modify with delegation"})	
	
	public void testDelegationSearch(String testName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	//upper case insensitive
	    	String delegationNames[]={"delegation001","DELEGATION002"};
	    	for (String delegationName:delegationNames) {
	       	   	CommonTasks.search(sahiTasks,delegationName);
	       	   	Assert.assertTrue(sahiTasks.link(delegationName.toString().toLowerCase()).exists(),"search result found as expected");
	       	   	CommonTasks.clearSearch(sahiTasks);
	    	}
	}
	
	@Test (groups={"searchNegative"}, description="Delegation Search Negative",dataProvider="getDelegationSearchNegativeObjects",dependsOnGroups={"add","modify with no delegation","modify with delegation"})	
	
	public void testDelegationSearchNegative(String testName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	String delegationNames[]={"nonexistent", "w", "'<,>.?/", "delegation001" + " ", " " + "delegation001"};
	    	for (String delegationName:delegationNames) {
	    		CommonTasks.search(sahiTasks,delegationName);
	    		if(sahiTasks.div("error_dialog").exists()){
	    			String errormsg = sahiTasks.div("error_dialog").getText(); 
	    			Assert.assertEquals("invalid 'criteria': Leading and trailing spaces are not allowed",errormsg); 
	    			sahiTasks.button("Cancel").click();
	    		}
	    		Assert.assertFalse(sahiTasks.link(delegationName).exists(),"search result not found as expected");
	    		CommonTasks.clearSearch(sahiTasks);
	    	}
	}
	
	@Test (groups={"delete"}, description="Delegation Delete Single",dataProvider="getDelegationDeleteSingleObjects",dependsOnGroups={"add","modify with no delegation","modify with delegation","addDuplicate","addLong","addNegative","search","searchNegative"})	
	
	public void testDelegationDeleteSingle(String testName,String delegationName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	CommonTasks.search(sahiTasks,delegationName);
	       	Assert.assertTrue(sahiTasks.link(delegationName).exists(),"delegation rule exists before delete");
	       	DelegationTasks.delegation_DeleteSingle(sahiTasks,delegationName);
	       	Assert.assertFalse(sahiTasks.link(delegationName).exists(),"delegation rule not exist after delete");
	       	CommonTasks.clearSearch(sahiTasks);
	}
	
	@Test (groups={"delete"}, description="Delegation Delete Multiple",dataProvider="getDelegationDeleteMultipleObjects",dependsOnGroups={"add","modify with no delegation","modify with delegation","addDuplicate","addLong","addNegative","search","searchNegative"})	
	
	public void testDelegationDeleteMultiple(String testName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.delegationPage, true);
	       	String delegationNames[]={"delegation002","delegation003","delegation004","delegation006","veryveryveryveryveryveryveryveryveryveryveryveryveryveryveryveryveryveryveryveryverylongname","delegationduplicate001","group1_membergroup1"};
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
		
        //									testName        delegationName      groupName       memberGroup    attribute			
		ll.add(Arrays.asList(new Object[]{ "add single",   "delegation001",     "editors",      "ipausers",  "audio" } ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationAddAndAddAnotherObjects")
	public Object[][] getDelegationAddAndAddAnotherObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationAddAndAddAnotherObjects());
	}
	protected List<List<Object>> createDelegationAddAndAddAnotherObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName		 	  delegationName1 permissionType1 groupName1  memberGroup1     attribute1       delegationName2   permissionType2  groupName2  memberGroup2 attribute2
		ll.add(Arrays.asList(new Object[]{ "add and add another", "delegation002",    "read",    "editors",    "ipausers",   "businesscategory",  "delegation003",     "write",     "editors",  "ipausers", "carlicense"} ));
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
		
        //									   testName       delegationName permissionType groupName memberGroup attribute			
		ll.add(Arrays.asList(new Object[]{ "add then cancel", "delegation005",    "write",     "editors", "ipausers", "destinationindicator"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationAddLongObjects")
	public Object[][] getDelegationAddLongObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationAddLongObjects());
	}
	protected List<List<Object>> createDelegationAddLongObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									   testName       delegationName permissionType groupName memberGroup attribute			
		ll.add(Arrays.asList(new Object[]{    "add long", "veryveryveryveryveryveryveryveryveryveryveryveryveryveryveryveryveryveryveryveryverylongname",   "write", "editors", "ipausers", "audio"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationAddNegativeObjects")
	public Object[][] getDelegationAddNegativeObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationAddNegativeObjects());
	}
	protected List<List<Object>> createDelegationAddNegativeObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName			              
		ll.add(Arrays.asList(new Object[]{ "add negative" } ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationAddNegativeNameObjects")
	public Object[][] getDelegationAddNegativeNameObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationAddNegativeNameObjects());
	}
	protected List<List<Object>> createDelegationAddNegativeNameObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									   testName          permissionType groupName memberGroup  attribute			
		ll.add(Arrays.asList(new Object[]{ "add negative name",    "write",     "editors", "ipausers", "audio"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationAddDuplicateObjects")
	public Object[][] getDelegationAddDuplicateObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationAddDuplicateObjects());
	}
	protected List<List<Object>> createDelegationAddDuplicateObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName	       delegationName	         permissionType groupName memberGroup  attribute		
		ll.add(Arrays.asList(new Object[]{ "add duplicate", "delegationduplicate001",      "write",          "editors", "ipausers",  "audio"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationGenericEditObjects")
	public Object[][] getDelegationGenericEditObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationGenericEditObjects());
	}
	protected List<List<Object>> createDelegationGenericEditObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //                            		 testName	       delegationName	 permissionType  groupName memberGroup  attribute		
		ll.add(Arrays.asList(new Object[]{ "generic edit",    "delegation006",      "write",          "editors", "ipausers",  "audio"} ));
		return ll;	
	}
	
	@DataProvider(name="getUnableToEditUserinfoWithNoDelegationObjects")
	public Object[][] getUnableToEditUserinfoWithNoDelegationbjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createUnableToEditUserinfoWithNoDelegationObjects());
	}
	protected List<List<Object>> createUnableToEditUserinfoWithNoDelegationObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //                            		                testName                       undelegatedUser     userToBeEdited		
		ll.add(Arrays.asList(new Object[]{ "unable to edit user info with no delegation", "delegationuser1", "delegationmemberuser1"} ));
		return ll;	
	}
	
	@DataProvider(name="getEditValidUserinfoWithDelegationObjects")
	public Object[][] getEditValidUserinfoWithDelegationObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createEditValidUserinfoWithDelegationObjects());
	}
	protected List<List<Object>> createEditValidUserinfoWithDelegationObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //                            		       testName                         delegationName         permissionType      groupName              memberGroup       attribute1   attribute2  delegatedUser        userToBeEdited1         userToBeEdited2      displayNameToUpdate  emailToUpdate		
		ll.add(Arrays.asList(new Object[]{ "edit valid userinfo with delegation", "group1_membergroup1",     "write",     "delegationgroup1", "delegationmembergroup1","displayname",  "mail",  "delegationuser1", "delegationmemberuser1","delegationmemberuser2","displayNameToUpdate","emailToUpdate@testrelm.com"} ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationSearchObjects")
	public Object[][] getDelegationSearchObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationSearchObjects());
	}
	protected List<List<Object>> createDelegationSearchObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName					              
		ll.add(Arrays.asList(new Object[]{ "search positive"} ));
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
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationDeleteSingleObjects());
	}
	protected List<List<Object>> createDelegationDeleteSingleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName	   delegationName			              
		ll.add(Arrays.asList(new Object[]{ "delete single",   "delegation001" } ));
		return ll;	
	}
	
	@DataProvider(name="getDelegationDeleteMultipleObjects")
	public Object[][] getDelegationDeleteMultipleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createDelegationDeleteMultipleObjects());
	}
	protected List<List<Object>> createDelegationDeleteMultipleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName				              
		ll.add(Arrays.asList(new Object[]{ "delete multiple"} ));
		return ll;	
	}
}	