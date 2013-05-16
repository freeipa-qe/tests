package com.redhat.qe.ipa.sahi.tests.automember;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.auto.testng.TestNGUtils;
import com.redhat.qe.ipa.sahi.base.SahiTestScript;
import com.redhat.qe.ipa.sahi.tasks.AutomemberTasks;
import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.GroupTasks;
import com.redhat.qe.ipa.sahi.tests.group.GroupTests;

public class AutomemberUserGroupTests extends SahiTestScript {
	private static Logger log = Logger.getLogger(GroupTests.class.getName()); 
	private static String [] usergroups = {"devel", "defgroup", "bug846754_grp", "a_grp", "b_grp", "bug818258_grp"};
		
	@BeforeClass (groups={"init"}, description="Initialize app for this test suite run", alwaysRun=true)
	public void initialize() throws CloneNotSupportedException {	
		
		//log.info("kinit as admin");
		//Assert.assertTrue(CommonTasks.kinitAsAdmin(), "Logged in successfully as admin");
		
		log.info("Opening browser");
		sahiTasks.open();
		log.info("Accessing: IPA Server URL");
		sahiTasks.setStrictVisibilityCheck(true);
        CommonTasks.formauth(sahiTasks, "admin", "Secret123");
		
	
		//add groups for automember
		sahiTasks.navigateTo(commonTasks.groupPage, true);
		for (String groupname : usergroups){
			String groupDescription = groupname + " description";
			GroupTasks.addGroup(sahiTasks, groupname, groupDescription);
		} 
		
	} 
	
	@AfterClass (groups={"cleanup"}, description="Delete objects added for the tests", alwaysRun=true)
	public void cleanup() throws Exception {	

		//delete automember usergroup
    	sahiTasks.navigateTo(commonTasks.groupPage, true);
    	for (String usergroup : usergroups) {
    	//Assert.assertTrue(sahiTasks.link(usergroup).exists(),"before 'Delete', usergroup exists"); except addthencancel 
    		GroupTasks.deleteGroup(sahiTasks, usergroup);
    		Assert.assertFalse(sahiTasks.link(usergroup).exists(),"after 'Delete', usergroup does NOT exists");
    	}
			
	}


    ////////////////////////////////////////////////
	//                test cases                  //
	////////////////////////////////////////////////
	
	@Test (groups={"add"}, description="Automember Add Single",
			dataProvider="getAutomemberAddSingleObjects")	
	public void testAutomemberAddSingle(String testName, String groupName) throws Exception {
		sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
		//verify automember doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify automember " + groupName + " doesn't already exist");
		//Add automember
		AutomemberTasks.automember_AddSingle(sahiTasks, groupName);		
		//verify automember was added successfully 
		Assert.assertTrue(sahiTasks.link(groupName).exists(), "Added automember " + groupName + "  successfully");
	}
	
	@Test (groups={"add"}, description="Automember Add and Add Another",
			dataProvider="getAutomemberAddAndAddAnotherObjects")	
	public void testAutomemberAddAndAddAnother(String testName, String groupName1,String groupName2) throws Exception {
		sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
		//verify automember doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName1).exists(), "Verify automember " + groupName1 + " doesn't already exist");
		Assert.assertFalse(sahiTasks.link(groupName2).exists(), "Verify automember " + groupName2 + " doesn't already exist");
		//Add automember
		AutomemberTasks.automember_AddAndAddAnother(sahiTasks, groupName1,groupName2);		
		//verify automember was added successfully 
		Assert.assertTrue(sahiTasks.link(groupName1).exists(), "Added automember " + groupName1 + "  successfully");
		Assert.assertTrue(sahiTasks.link(groupName2).exists(), "Added automember " + groupName2 + "  successfully");
	}
	
	@Test (groups={"add"}, description="Automember Add and Edit",
			dataProvider="getAutomemberAddAndEditObjects")	
	public void testAutomemberAddAndEdit(String testName, String groupName) throws Exception {
		sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
		//verify automember doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify automember " + groupName + " doesn't already exist");
		//Add automember
		AutomemberTasks.automember_AddAndEdit(sahiTasks, groupName);
		sahiTasks.link("User group rules").in(sahiTasks.div("content nav-space-3")).click();
		//verify automember was added successfully 
		sahiTasks.span("Refresh").click();
		Assert.assertTrue(sahiTasks.link(groupName).exists(), "Added automember " + groupName + "  successfully");
		
	}
	
	@Test (groups={"add"}, description="Automember Add Then Cancel",
			dataProvider="getAutomemberAddThenCancelObjects")	
	public void testAutomemberAddThenCancel(String testName, String groupName) throws Exception {
		sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
		//verify automember doesn't exist
		Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify automember " + groupName + " doesn't already exist");
		//Add automember then cancel
		AutomemberTasks.automember_AddThenCancel(sahiTasks, groupName);		
		//verify automember was canceled successfully 
		Assert.assertFalse(sahiTasks.link(groupName).exists(), "Verify automember " + groupName + " doesn't already exist");
	}
	
	@Test (groups={"addNegative"}, description="Automember Add Negative Required Field",dependsOnGroups="add")	
	
	public void testAutomemberAddNegativeRequiredField() throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	    	AutomemberTasks.automember_AddNegativeRequiredField(sahiTasks);
	    	Assert.assertTrue(sahiTasks.span("Required field").exists(), "Verified Expected Error Message");
	    	sahiTasks.button("Cancel").click();
	}
	
	@Test (groups={"addDuplicate"}, description="Automember Add Duplicate Bug 818258 -Missing Specified Name In Error Msg", 
			dataProvider="getAutomemberAddDuplicateMissingSpecifiedNameBug818258TestObjects",dependsOnGroups="add")	
	
	public void testAutomemberAddDuplicateMissingSpecifiedName_Bug818258(String testName,String groupName) throws Exception {
	       	//add and add another automember user group rule and verify the bug
	    	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	    	Assert.assertFalse(sahiTasks.link(groupName).exists(),"before 'Add', usergroup role does NOT exists");
	    	AutomemberTasks.automember_AddDuplicate(sahiTasks,groupName);
	    	Assert.assertTrue(sahiTasks.link(groupName).exists(),"after 'Add', usergroup role exists");	    
	}
	
	
	@Test (groups={"modify_Condition1"}, description="Automember Condition Add Single",dataProvider="getAutomemberConditionAddSingleObjects",dependsOnGroups="add")	
	
	public void testAutomemberConditionAddSingle(String testName,String groupName,String attribute,String expression) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	       	sahiTasks.link(groupName).click();
	       	Assert.assertFalse(sahiTasks.div(attribute).exists(), "Verified Condition Not Exist Before Add");
	    	AutomemberTasks.automember_ConditionAddSingle(sahiTasks,testName,attribute,expression);
	    	Assert.assertTrue(sahiTasks.div(attribute).exists(), "Verified Condition Added Successfully");
	    	sahiTasks.link("User group rules").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	@Test (groups={"modify_Condition1"}, description="Automember Condition Add And Add Another",dataProvider="getAutomemberConditionAddAndAddAnotherObjects",dependsOnGroups="add")	
		
	public void testAutomemberConditionAddAndAddAnother(String testName,String groupName,String attribute1,String attribute2,String expression1,String expression2) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	       	sahiTasks.link(groupName).click();
	       	Assert.assertFalse(sahiTasks.div(attribute1).exists(), "Verified Condition Not Exist Before Add");
	       	Assert.assertFalse(sahiTasks.div(attribute2).exists(), "Verified Condition Not Exist Before Add");
	       	AutomemberTasks.automember_ConditionAddAndAddAnother(sahiTasks,testName,attribute1,attribute2,expression1,expression2);
	    	Assert.assertTrue(sahiTasks.div(attribute1).exists(), "Verified Condition Added Successfully");
	    	Assert.assertTrue(sahiTasks.div(attribute2).exists(), "Verified Condition Added Successfully");
	    	sahiTasks.link("User group rules").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	@Test (groups={"modify_Condition1"}, description="Automember Condition Add Then Cancel",dataProvider="getAutomemberConditionAddThenCancelObjects",dependsOnGroups="add")	
	
	public void testAutomemberConditionAddThenCancel(String testName,String groupName,String attribute,String expression) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	       	sahiTasks.link(groupName).click();
	       	Assert.assertFalse(sahiTasks.div(attribute).exists(), "Verified Condition Not Exist Before Add");
	       	AutomemberTasks.automember_ConditionAddThenCancel(sahiTasks,testName,attribute,expression);
	    	Assert.assertFalse(sahiTasks.div(attribute).exists(), "Verified Condition Add Cancelled Successfully");
	    	sahiTasks.link("User group rules").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	@Test (groups={"modify_Condition"}, description="Automember Condition Delete Single",dataProvider="getAutomemberConditionDeleteSingleObjects",dependsOnGroups={"add","modify_Condition1"})	
	
	public void testAutomemberConditionDeleteSingle(String testName,String groupName,String attribute,String expression) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	       	sahiTasks.link(groupName).click();
	       	Assert.assertTrue(sahiTasks.div(attribute).exists(), "Verified Condition Exist Before Delete");
	    	AutomemberTasks.automember_ConditionDeleteSingle(sahiTasks,testName,attribute,expression);
	    	Assert.assertFalse(sahiTasks.div(attribute).exists(), "Verified Condition Deleted Successfully");
	    	sahiTasks.link("User group rules").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	@Test (groups={"modify_Condition"}, description="Automember Condition Delete Multiple",dataProvider="getAutomemberConditionDeleteMultipleObjects",dependsOnGroups={"add","modify_Condition1"})	
	
	public void testAutomemberConditionDeleteMultiple(String testName,String groupName,String attribute1,String attribute2,String expression1,String expression2) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	       	sahiTasks.link(groupName).click();
	       	Assert.assertTrue(sahiTasks.div(attribute1).exists(), "Verified Condition Exist Before Delete");
	       	Assert.assertTrue(sahiTasks.div(attribute2).exists(), "Verified Condition Exist Before Delete");
	    	AutomemberTasks.automember_ConditionDeleteMultiple(sahiTasks,testName,attribute1,attribute2,expression1,expression2);
	    	Assert.assertFalse(sahiTasks.div(attribute1).exists(), "Verified Condition Deleted Successfully");
	    	Assert.assertFalse(sahiTasks.div(attribute2).exists(), "Verified Condition Deleted Successfully");
	    	sahiTasks.link("User group rules").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	@Test (groups={"modify"}, description="Automember Default User Group",dataProvider="getAutomemberDefaultGroupObjects",dependsOnGroups="add")	
	
	public void testAutomemberDefaultGroup(String testName,String groupName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	       	Assert.assertEquals(sahiTasks.textbox("automemberdefaultgroup").getValue(),"");
	       	AutomemberTasks.automember_DefaultGroup(sahiTasks,groupName);
	    	Assert.assertEquals(sahiTasks.textbox("automemberdefaultgroup").getValue(),"");

	}
	
	@Test (groups={"modify"}, description="Automember Generic Edit",dataProvider="getAutomemberGenericEditObjects",dependsOnGroups={"add","modify_Condition1","modify_Condition"})	
	
	public void testAutomemberGenericEdit(String testName,String groupName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	       	sahiTasks.link(groupName).click();
	       	AutomemberTasks.automember_GenericEdit(sahiTasks,testName,groupName);
	}
	
	@Test (groups={"search"}, description="Automember Search",dataProvider="getAutomemberSearchObjects",dependsOnGroups="add")	
	
	public void testAutomemberSearch(String testName,String groupName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	       	CommonTasks.search(sahiTasks,groupName);
	       	Assert.assertTrue(sahiTasks.link(groupName).exists(),"search result found as expected");
	       	CommonTasks.clearSearch(sahiTasks);
	}
	
	@Test (groups={"searchNegative"}, description="Automember Search Negative",dataProvider="getAutomemberSearchNegativeObjects",dependsOnGroups="add")	
	
	public void testAutomemberSearchNegativeBug846754(String testName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	       	String groupNames[]={"nonexistent", "n", "'<,>.?/", AutomemberUserGroupTests.usergroups[2] + " ", " " + AutomemberUserGroupTests.usergroups[2]};
	    	for (String groupName:groupNames) {
	    		CommonTasks.search(sahiTasks,groupName);
	    		Assert.assertFalse(sahiTasks.link(groupName).exists(),"search result not found as expected");
	    		CommonTasks.clearSearch(sahiTasks);
	    	}
	}
	
	@Test (groups={"delete"}, description="Automember Delete Single",dataProvider="getAutomemberDeleteSingleObjects",dependsOnGroups={"add","modify","addDuplicate","search","searchNegative"})	
	
	public void testAutomemberDeleteSingle(String testName,String groupName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	       	CommonTasks.search(sahiTasks,groupName);
	       	Assert.assertTrue(sahiTasks.link(groupName).exists(),"automember rule exists before delete");
	       	AutomemberTasks.automember_DeleteSingle(sahiTasks,groupName);
	       	Assert.assertTrue(sahiTasks.link(groupName).exists(),"automember rule exists before delete");
	       	CommonTasks.clearSearch(sahiTasks);
	}
	
	@Test (groups={"delete"}, description="Automember Delete Multiple",dataProvider="getAutomemberDeleteMulitpleObjects",dependsOnGroups={"add","modify","addDuplicate","search","searchNegative"})	
	
	public void testAutomemberDeleteMultiple(String testName) throws Exception {
	       	sahiTasks.navigateTo(commonTasks.automemberUserGroupPage, true);
	       	String groupNames[]={AutomemberUserGroupTests.usergroups[0],AutomemberUserGroupTests.usergroups[1],AutomemberUserGroupTests.usergroups[2],AutomemberUserGroupTests.usergroups[3],AutomemberUserGroupTests.usergroups[5]};
	       	AutomemberTasks.automember_DeleteMultiple(sahiTasks,groupNames);
	       	for (String groupName:groupNames) {
	       		Assert.assertFalse(sahiTasks.link(groupName).exists(),"automember rules don't exist after delete");
	       	}	
	}
	
	/*******************************************************
	 ************      DATA PROVIDERS     ******************
	 *******************************************************/
	
	@DataProvider(name="getAutomemberAddSingleObjects")
	public Object[][] getAutomemberAddSingleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberAddSingleObjects());
	}
	protected List<List<Object>> createAutomemberAddSingleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName		 	   groupName			
		ll.add(Arrays.asList(new Object[]{ "add single",   AutomemberUserGroupTests.usergroups[0]} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberAddAndAddAnotherObjects")
	public Object[][] getAutomemberAddAndAddAnotherObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberAddAndAddAnotherObjects());
	}
	protected List<List<Object>> createAutomemberAddAndAddAnotherObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName		 	                groupName1			                     groupName2
		ll.add(Arrays.asList(new Object[]{ "add and add another",   AutomemberUserGroupTests.usergroups[1], AutomemberUserGroupTests.usergroups[2]} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberAddAndEditObjects")
	public Object[][] getAutomemberAddAndEditObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberAddAndEditObjects());
	}
	protected List<List<Object>> createAutomemberAddAndEditObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName		 	                groupName			
		ll.add(Arrays.asList(new Object[]{ "add and edit user group rules",   AutomemberUserGroupTests.usergroups[3]} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberAddThenCancelObjects")
	public Object[][] getAutomemberAddThenCancelObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberAddThenCancelObjects());
	}
	protected List<List<Object>> createAutomemberAddThenCancelObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName		 	   groupName			
		ll.add(Arrays.asList(new Object[]{ "add then cancel",   AutomemberUserGroupTests.usergroups[4]} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberAddDuplicateMissingSpecifiedNameBug818258TestObjects")
	public Object[][] getAutomemberAddDuplicateMissingSpecifiedNameBug818258TestObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberAddDuplicateMissingSpecifiedNameBug818258TestObjects());
	}
	protected List<List<Object>> createAutomemberAddDuplicateMissingSpecifiedNameBug818258TestObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									testName		 	   groupName			
		ll.add(Arrays.asList(new Object[]{ "add duplicate",   AutomemberUserGroupTests.usergroups[5]} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberConditionAddSingleObjects")
	public Object[][] getAutomemberConditionAddSingleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberConditionAddSingleObjects());
	}
	protected List<List<Object>> createAutomemberConditionAddSingleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									  testName          groupName                           attribute     expression			
		ll.add(Arrays.asList(new Object[]{ "Inclusive",   AutomemberUserGroupTests.usergroups[0],    "audio",       "audio"} ));
		ll.add(Arrays.asList(new Object[]{ "Exclusive",   AutomemberUserGroupTests.usergroups[0],    "businesscategory",  "businesscategory"} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberConditionAddAddAddAnotherObjects")
	public Object[][] getAutomemberConditionAddAndAddAnotherObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberConditionAddAndAddAnotherObjects());
	}
	protected List<List<Object>> createAutomemberConditionAddAndAddAnotherObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									  testName          groupName                           attribute1       attribute2      expression1	expression2		
		ll.add(Arrays.asList(new Object[]{ "Inclusive",   AutomemberUserGroupTests.usergroups[0],    "carlicense",       "cn",      "carlicense",      "cn"}));
		ll.add(Arrays.asList(new Object[]{ "Exclusive",   AutomemberUserGroupTests.usergroups[0],   "departmentnumber", "description", "departmentnumber","description"} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberConditionAddThenCancelObjects")
	public Object[][] getAutomemberConditionAddThenCancelObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberConditionAddThenCancelObjects());
	}
	protected List<List<Object>> createAutomemberConditionAddThenCancelObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									  testName          groupName                           attribute               expression			
		ll.add(Arrays.asList(new Object[]{ "Inclusive",   AutomemberUserGroupTests.usergroups[0], "destinationindicator", "destinationindicator"} ));
		ll.add(Arrays.asList(new Object[]{ "Exclusive",   AutomemberUserGroupTests.usergroups[0],   "displayname",        "displayname"} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberConditionDeleteSingleObjects")
	public Object[][] getAutomemberConditionDeleteSingleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberConditionDeleteSingleObjects());
	}
	protected List<List<Object>> createAutomemberConditionDeleteSingleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									  testName          groupName                           attribute             expression			
		ll.add(Arrays.asList(new Object[]{ "Inclusive",   AutomemberUserGroupTests.usergroups[0],    "audio" ,             "audio"} ));
		ll.add(Arrays.asList(new Object[]{ "Exclusive",   AutomemberUserGroupTests.usergroups[0],   "businesscategory", "businesscategory"} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberConditionDeleteMultipleObjects")
	public Object[][] getAutomemberConditionDeleteMultipleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberConditionDeleteMultipleObjects());
	}
	protected List<List<Object>> createAutomemberConditionDeleteMultipleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									  testName          groupName                           attribute1       attribute2      expression1	expression2			
		ll.add(Arrays.asList(new Object[]{ "Inclusive",   AutomemberUserGroupTests.usergroups[0],    "carlicense",       "cn",      "carlicense",      "cn"} ));
		ll.add(Arrays.asList(new Object[]{ "Exclusive",   AutomemberUserGroupTests.usergroups[0],   "departmentnumber", "description", "departmentnumber","description"} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberDefaultGroupObjects")
	public Object[][] getAutomemberDefaultGroupObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberDefaultGroupObjects());
	}
	protected List<List<Object>> createAutomemberDefaultGroupObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName		 	             groupName			
		ll.add(Arrays.asList(new Object[]{ "modify default user group",   AutomemberUserGroupTests.usergroups[1]} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberGenericEditObjects")
	public Object[][] getAutomemberGenericEditObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberGenericEditObjects());
	}
	protected List<List<Object>> createAutomemberGenericEditObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName		 	             groupName			              
		ll.add(Arrays.asList(new Object[]{ "User group rules",   AutomemberUserGroupTests.usergroups[2]} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberSearchObjects")
	public Object[][] getAutomemberSearchObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberSearchObjects());
	}
	protected List<List<Object>> createAutomemberSearchObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName		 	             groupName			              
		ll.add(Arrays.asList(new Object[]{ "search positive",   AutomemberUserGroupTests.usergroups[3]} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberSearchNegativeObjects")
	public Object[][] getAutomemberSearchNegativeObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberSearchNegativeObjects());
	}
	protected List<List<Object>> createAutomemberSearchNegativeObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName			              
		ll.add(Arrays.asList(new Object[]{ "search negative" } ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberDeleteSingleObjects")
	public Object[][] getAutomemberDeleteSingleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberGenericEditObjects());
	}
	protected List<List<Object>> createAutomemberDeleteSingleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName		 	             groupName			              
		ll.add(Arrays.asList(new Object[]{ "delete single",   AutomemberUserGroupTests.usergroups[0]} ));
		return ll;	
	}
	
	@DataProvider(name="getAutomemberDeleteMultipleObjects")
	public Object[][] getAutomemberDeleteMultipleObjects() {
		return TestNGUtils.convertListOfListsTo2dArray(createAutomemberGenericEditObjects());
	}
	protected List<List<Object>> createAutomemberDeleteMultipleObjects() {		
		List<List<Object>> ll = new ArrayList<List<Object>>();
		
        //									     testName				              
		ll.add(Arrays.asList(new Object[]{ "delete multiple"} ));
		return ll;	
	}
}