package com.redhat.qe.ipa.sahi.pages;

import java.util.ArrayList;

import java.util.Hashtable;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.*;

public class IPAWebPage implements StandardTest{

	protected SahiTasks browser;
	protected CommonTasks commonTasks;
	protected String url;
	protected Hashtable<String,ArrayList<String>> testQueues;
	protected String backLink;
	protected String testAccount;
	protected String duplicateErrorMsgStartsWith;
	protected String duplicateErrorMsgEndsWith ="already exists";
	
	protected String addPage;
	protected String addSpecialPage;
	protected String addLongPage;
	protected String addNegativePage;
	protected String duplicatePage;
	protected String modifySettingsPage;
	protected String modifyUpdateResetCancelPage;
	protected String modifyNegativePage;
	protected String delPage; 
	protected String searchPage; 
	protected String addUserPage;
	protected String addGroupPage;
	protected String addUserDelegationPage;
	protected String loginUser;
	protected String loginOldPassword;
	protected String loginNewPassword;
	protected String memberuserToMemberGroupPage;
	protected String userToGroupPage;
	protected String editDelegatedUserNegative;
	protected String editDelegatedUserDisplayName;
	protected String editDelegatedUserEmail;
	protected String checkDisplayName;
	protected String checkEmail1;
	protected String checkEmail2;
	protected String checkEmail3;
	protected String deleteDelegationNonstandard;
	protected String deleteUserNonStandard;
	protected String deleteGroupNonStandard;
	protected String EditUndelegatedUser;
	protected ArrayList<String> testAccounts= new ArrayList<String>();
	protected String modifyConditionInclusiveAddPage;//xdong
	protected String modifyConditionInclusiveDeletePage;//xdong
	protected String modifyConditionExclusiveAddPage;//xdong
	protected String modifyConditionExclusiveDeletePage;//xdong
	protected String setDefaultGroupPage;//xdong
	
	
	protected TestDataFactory factory;
	private static Logger log = Logger.getLogger(IPAWebPage.class.getName());
	
	IPAWebPage(SahiTasks browser, String url, String testPropertyFile)
	{
		this.browser = browser;
		this.url = url;
		testQueues = new Hashtable<String,ArrayList<String>>();
		factory = TestDataFactory.instance(testPropertyFile);
		
	}
 
	public void ensureUrl(){ 
		String currentURL = browser.fetch("top.location.href"); 
		if (!currentURL.equals(url)){ 
			log.info("current url=(" + currentURL + "), is not a starting position, move to url=(" + url +")");
			browser.navigateTo(url, true);
		}
	}
	
	public ArrayList<String> getTestQueue(String queueName) {
		ArrayList<String> queue = null;
		if (testQueues.containsKey(queueName))
			queue = testQueues.get(queueName);
		else
			queue = new ArrayList<String>();
		return queue;
	} 
	
	protected void registerStandardTestCases()
	{
		this.registerTestCases("add", standardAddTestCases);
		//this.registerTestCases("modify", standardModTestCases);
		this.registerTestCases("search", standardSearchTestCases);
		this.registerTestCases("delete", standardDelTestCases);
	}
	
	protected void registerTestCases(String queueName, String[] testCases)
	{
		for (String testcase: testCases)
			registerTestCases(queueName, testcase); 
	}
	
	protected void registerTestCases(String queueName, String testCase)
	{
		if (testQueues.containsKey(queueName))
		{
			ArrayList<String> queue = testQueues.get(queueName);
			queue.add(testCase);
			testQueues.put(queueName, queue);
		}else{
			ArrayList<String> queue = new ArrayList<String>();
			queue.add(testCase);
			testQueues.put(queueName, queue);
		}
		System.out.println("Register Test Cases: add ["+testCase+"] into queue ["+queueName+"]");
	}
	
	////////////////////////////////// standard test cases   //////////////////////////////

	@Override
	public IPAWebTestMonitor addSingle(IPAWebTestMonitor monitor){
		String pageName = addPage;
		testAccounts.clear();
		if (pageName == null)
			return monitor;
		try {
			addSingleNewEntry(monitor, pageName);
			commonTasks.search(browser,testAccounts.get(0) );
			if(browser.link(testAccounts.get(0)).exists()){
				monitor.pass("Added and Verified Successfully");
			}
			else{
				monitor.fail("Add Failed");
			}
			commonTasks.clearSearch(browser);
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor addSpecial(IPAWebTestMonitor monitor){
		String pageName = addSpecialPage;
		testAccounts.clear();
		if (pageName == null)
			return monitor;
		try {
			addSingleNewEntry(monitor, pageName);
			commonTasks.search(browser,testAccounts.get(0) );
			if(browser.link(testAccounts.get(0)).exists()){
				monitor.pass("Added and Verified Successfully");
			}
			else{
				monitor.fail("Add Failed");
			}
			commonTasks.clearSearch(browser);
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor addLong(IPAWebTestMonitor monitor){
		String pageName = addLongPage;
		testAccounts.clear();
		if (pageName == null)
			return monitor;
		try {
			addSingleNewEntry(monitor, pageName);
			commonTasks.search(browser,testAccounts.get(0) );
			if(browser.link(testAccounts.get(0)).exists()){
				monitor.pass("Added and Verified Successfully");
			}
			else{
				monitor.fail("Add Failed");
			}
			commonTasks.clearSearch(browser);
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor addAndAddAnother(IPAWebTestMonitor monitor){
		String pageName = addPage;
		if (pageName == null)
			return monitor;
		testAccounts.clear();
		int numOfEntries = 2;
		try {
			addMultipleNewEntries(monitor, pageName, numOfEntries);
			for(int i=0;i<numOfEntries;i++){
				commonTasks.search(browser,testAccounts.get(i) );
				if(browser.link(testAccounts.get(i)).exists()){
					monitor.pass("Added and Verified Successfully");
				}
				else{
					monitor.fail("Add Failed");
				}
				commonTasks.clearSearch(browser);
			}	

		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		} catch (Exception e){
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}

	@Override
	public IPAWebTestMonitor addThenEdit(IPAWebTestMonitor monitor){ 
		String pageName = addPage;
		if (pageName == null)
			return monitor;
		try {
			addNewEntryThenEdit(monitor,pageName);
			monitor.pass();
		} catch (IPAWebAutomationException e) {
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}

	@Override
	public IPAWebTestMonitor addThenCancel(IPAWebTestMonitor monitor){
		String pageName = addPage;
		testAccounts.clear();
		if (pageName == null)
			return monitor;
		try {
			addNewEntryThenCancelOperation(monitor, pageName);
			commonTasks.search(browser,testAccounts.get(0) );
			if(browser.link(testAccounts.get(0)).exists()){
				monitor.fail("Add and Cancel Failed");
			}
			else{
				monitor.pass("Add and Cancel Passed");
			}
			commonTasks.clearSearch(browser);
		} catch (IPAWebAutomationException e) {
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}

	@Override
	public IPAWebTestMonitor addNegativeDuplicate(IPAWebTestMonitor monitor) {
		String pageName = duplicatePage;
		if (pageName == null)
			return monitor;
		
		try {
			addSingleNewEntry(monitor, pageName);
			addSingleNewEntry(monitor, pageName);
			
			// check error dialog box
			if (browser.div("error_dialog").exists()){
				String errorMsg = browser.div("error_dialog").getText();
				if (errorMsg.startsWith(duplicateErrorMsgStartsWith) && errorMsg.endsWith(duplicateErrorMsgEndsWith))
					monitor.pass();
				else
					monitor.fail("Error dialog triggered, but no desired error msg found");
				closeDialog();
			}else
				monitor.fail("No error dialog triggered");
			return monitor;
		} catch (IPAWebAutomationException e) {
			monitor.fail(e); 
			return monitor;
		}
	}

	@Override
	public IPAWebTestMonitor addNegativeRequiredFields(IPAWebTestMonitor monitor) {
		browser.span("Add").click();
		browser.button("Add").click(); 
		if (browser.span("Required field").exists())
			monitor.pass();
		else
			monitor.fail("No 'Required field' lable appears");
		closeDialog();
		return monitor;
	}

	@Override
	public IPAWebTestMonitor addNegative(IPAWebTestMonitor monitor){
		String pageName = addNegativePage;
		if (pageName == null)
			return monitor;
		
		while (factory.hasMoreTestData(pageName))
			addNegativeSingle(monitor, pageName); 
		return monitor;
	}
	
	private boolean verifyExpectedErrorMsg(ArrayList<String> expectedErrorMsgs) {
		boolean match=false;
		for (String expected:expectedErrorMsgs)
		{ 
			if (browser.span(expected).exists())
				match = true;
			else if(browser.div(expected).exists())
				match=true;
			else if(browser.div("error_dialog").getText().contains(expected)){
				match=true;
			}
		}
		return match;
	}
	

	@Override
	public IPAWebTestMonitor modify(IPAWebTestMonitor monitor) {
		String pageName = modifySettingsPage;
		if (pageName == null){
			monitor.fail("modify test page not defined:");
			return monitor;
		}
		
		testAccount = factory.getModifyTestAccount(pageName);
		if (testAccount != null && browser.link(testAccount).exists())
		{
			browser.link(testAccount).click();
			return executeModify(monitor, pageName);
		}else{
			monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
			return monitor;
		}  
	}
	 
	protected IPAWebTestMonitor executeModify(IPAWebTestMonitor monitor, String pageName) { 
			
		//test undo, reset and update
		ArrayList<String> uiElements = factory.getUIELements(pageName); 
		for (String uiElement:uiElements)
		{
			String[] elementID = uiElement.split(":"); 
			String tag = elementID[0];
			String id = elementID[1]; 
			String value = factory.getValue(pageName, tag, id); 
			
			// test 'undo' 
			String original = readElementValue(monitor, pageName,tag,id,value);
			setElementValue(monitor, pageName,tag,id,value);
			monitor.setCurrentTestData(pageName, "{" + tag + ":" + id + ":" + value + " 'undo'}");
			browser.span("undo").click();
			String afterUndo = readElementValue(monitor, pageName,tag,id,value);
			if (original.equals(afterUndo))
				monitor.pass("after undo, value being reset to original, test pass");
			else
				monitor.fail("after undo, value not being reset, test failed");
			
			// test 'Reset'
			setElementValue(monitor, pageName,tag,id,value);
			monitor.setCurrentTestData(pageName,  "{" + tag + ":" + id + ":" + value + " 'Reset'}");
			browser.span("Reset").click();
			String afterReset = readElementValue(monitor, pageName,tag,id,value);
			if (original.equals(afterReset))
				monitor.pass("after 'Reset', value being reset to original, test pass");
			else
				monitor.fail("after 'Reset', value not being reset, test failed");
			
			// test 'Update'
			setElementValue(monitor, pageName,tag,id,value);
			monitor.setCurrentTestData(pageName,  "{" + tag + ":" + id + ":" + value + " 'Update'}");
			browser.span("Update").click();
			String afterUpdate = readElementValue(monitor, pageName,tag,id,value); // reread to confirm the update result
			if (browser.div("error_dialog").exists())
			{
				String errorMessage = browser.div("error_dialog").getText();
				monitor.fail("error on 'Update', error dialog appears, dialog says:(" + errorMessage + ")");
				browser.button("Cancel").click();
				browser.span("undo").click();
			}else{ 
				if (afterUpdate !=null && afterUpdate.equals(value)) 
					monitor.pass("after 'Update', new value being set, test pass");
				else
					monitor.fail("after 'Update', new value not assigned to element, test failed");
			}
		} 
		
			browser.span("Collapse All").click();
			browser.waitFor(1000);
			if(browser.table("section-table").exists())
				monitor.fail("Collapse All Failed");
			else
				monitor.pass("Collapse All Passed");
			
			browser.span("Expand All").click();
			browser.waitFor(1000);
			if(browser.table("section-table").exists())
				monitor.pass("Expand All Passed");
			else
				monitor.fail("Expand All Failed");
			
		browser.link(backLink).near(browser.span(testAccount)).click();
		if (browser.span("Unsaved Changes").exists())
		{
			monitor.fail("there is 'Unsaved Changes', it is not suppose to happen, need find out why");
			browser.button("Reset").click();
		} 
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor modifyUpdateResetCancel(IPAWebTestMonitor monitor) {
		String pageName = modifyUpdateResetCancelPage;
		if (pageName == null){
			monitor.fail("modify test page not defined:");
			return monitor;
		}
		
		testAccount = factory.getModifyTestAccount(pageName);
		if (testAccount != null && browser.link(testAccount).exists())
		{
			browser.link(testAccount).click();
			return executeModifyUpdateResetCancel(monitor, pageName);
		}else{
			monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
			return monitor;
		}  
	}
	 
	protected IPAWebTestMonitor executeModifyUpdateResetCancel(IPAWebTestMonitor monitor, String pageName) { 
			
		//test undo, reset and update
		ArrayList<String> uiElements = factory.getUIELements(pageName); 
		for (String uiElement:uiElements)
		{
			String[] elementID = uiElement.split(":"); 
			String tag = elementID[0];
			String id = elementID[1]; 
			String value = factory.getValue(pageName, tag, id); 
			
			// test 'Cancel' 
			setElementValue(monitor, pageName,tag,id,value);
			monitor.setCurrentTestData(pageName, "{" + tag + ":" + id + ":" + value + " 'Cancel'}");
			browser.link(backLink).near(browser.span(testAccount)).click();
			browser.button("Cancel").click();
			if (browser.link(backLink).near(browser.span(testAccount)).exists())
				monitor.pass("after Cancel, Page remains Unchanged, Test Passed");
			else
				monitor.fail("after Cancel, Page Changed. Test Failed");
				
			// test 'Reset'
			setElementValue(monitor, pageName,tag,id,value);
			monitor.setCurrentTestData(pageName, "{" + tag + ":" + id + ":" + value + " 'Reset'}");
			browser.link(backLink).near(browser.span(testAccount)).click();
			browser.button("Reset").click();
			if (browser.link(backLink).near(browser.span(testAccount)).exists())
				monitor.fail("after Reset, Page remains Unchanged, Test Failed");
			else
				monitor.pass("after Reset, Page Changed. Test Passed");
			
			// test 'Update'
			testAccount = factory.getModifyTestAccount(pageName);
			if (testAccount != null && browser.link(testAccount).exists())
			{
				browser.link(testAccount).click();
			}
			
			setElementValue(monitor, pageName,tag,id,value);
			monitor.setCurrentTestData(pageName,  "{" + tag + ":" + id + ":" + value + " 'Update'}");
			if(browser.link(backLink).near(browser.span(testAccount)).exists()){
				browser.link(backLink).near(browser.span(testAccount)).click();
				browser.button("Update").click();
				
				if (browser.div("error_dialog").exists())
				{
					String errorMessage = browser.div("error_dialog").getText();
					monitor.fail("error on 'Update', error dialog appears, dialog says:(" + errorMessage + ")");
					browser.button("Cancel").click();
					browser.span("undo").click();
				}else{ 
					if (browser.link(backLink).near(browser.span(testAccount)).exists())
						monitor.fail("after Update, Page remains Unchanged, Test Failed");
					else
						monitor.pass("after Update, Page Changed. Test Passed");
				}
			}
		} 
		
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor modifyNegative(IPAWebTestMonitor monitor) {
		// get into editing mode
		String pageName = modifyNegativePage;
		if (pageName == null){
			monitor.fail("modifyNegativePage is not defined");
			return monitor;
		}
		
		testAccount = factory.getModifyTestAccount(pageName);
		if (testAccount != null && browser.link(testAccount).exists())
		{
			browser.link(testAccount).click();
			return executeModifyNegative(monitor, pageName);
		}else{
			monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
			return monitor;
		} 
	}
	
	protected IPAWebTestMonitor executeModifyNegative(IPAWebTestMonitor monitor, String pageName) {
		
		//test undo, reset and update
		ArrayList<String> uiElements = factory.getUIELements(pageName); 
		for (String uiElement:uiElements)
		{
			String[] elementID = uiElement.split(":"); 
			String tag = elementID[0];
			String id = elementID[1]; 
			String valueAndExpectedErrorMsg = factory.getValue(pageName, tag, id);
			String[] combined = factory.extractValues(valueAndExpectedErrorMsg); 
			String value = combined[0];
			String expectedErrorMsg = combined[1];
			
			// 'Update' with negative data and expect error dialog/message
			setElementValue(monitor, pageName,tag,id,value);
			monitor.setCurrentTestData(pageName,  "{" + tag + ":" + id + ":" + value + " 'Update'}");
			browser.span("Update").click();
			if (browser.div("error_dialog").exists())
			{
				String errorMessage = browser.div("error_dialog").getText();
				if (errorMessage.equals(expectedErrorMsg) || errorMessage.endsWith(expectedErrorMsg) || errorMessage.startsWith(expectedErrorMsg))
					monitor.pass("error dialog appears as expected, error message mathces: expect[" + expectedErrorMsg + "] actual ["+ errorMessage + "]");
				else
					monitor.fail("error dialog appears as expected, error message does NOT match. expect[" + expectedErrorMsg + "] actual ["+ errorMessage + "]");
				browser.button("Cancel").click();
				browser.span("undo").click();
			}
			else if(browser.div("Input form contains invalid or missing values.").exists())
			{	
				monitor.pass("error dialog appears as expected");
				browser.button("OK").click();
				browser.span("undo").click();
			}else{ 
				monitor.fail("error dialog does not appear, expect[" + expectedErrorMsg + "]");
				if(browser.button("OK").exists()){
					browser.button("OK").click();
				}
			}
		} 
		browser.link(backLink).in(browser.span("back-link")).click();
		if (browser.span("Unsaved Changes").exists()) 
			browser.button("Reset").click();
		
		return monitor; 
	}
	
	@Override
	public IPAWebTestMonitor searchPositive(IPAWebTestMonitor monitor){ 
		String pageName = searchPage;
		if (pageName == null)
			return monitor;
		int numofEntries=2;
		try {
			for(int i=0;i<numofEntries;i++){
				searchSingle(monitor, pageName);
				String searchString=browser.textbox("filter").getValue().toString().toLowerCase();
				if(browser.link(searchString).exists()){
					monitor.pass("Search single passed");
				}
				else{
					monitor.fail("Search Failed");
				}
			}
			browser.textbox("filter").setValue("");
			browser.span("icon search-icon").click(); 
			monitor.pass("Search all passed");
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		} 
		return monitor;
	}
	
	public IPAWebTestMonitor searchNegative(IPAWebTestMonitor monitor){ 
		String pageName = searchPage;
		if (pageName == null)
			return monitor;
		int numofEntries=3;
		try {
			for(int i=0;i<numofEntries;i++){
				searchSingle(monitor, pageName);
				if(browser.link(browser.textbox("filter").getValue()).exists()){
					monitor.fail("Search Negative Failed");
				}
				else{
					if(browser.div("error_dialog").exists()){
						closeDialog();
					}
					monitor.pass("Search Negative Passed");
					browser.textbox("filter").setValue("");
					browser.span("icon search-icon").click();
				}
			}
			
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		} 
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor deleteSingle(IPAWebTestMonitor monitor){ 
		String pageName = delPage;
		testAccounts.clear();
		if (pageName == null)
			return monitor;
		try {
			deleteSingleEntry(monitor, pageName);
			if(browser.link(testAccounts.get(0)).exists()){
				monitor.fail("Delete Failed");
			}
			else{
				monitor.pass("Delete Passed");
			}
			//commonTasks.clearSearch(browser);

		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		} 
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor deleteMultiple(IPAWebTestMonitor monitor){
		String pageName=delPage;
		testAccounts.clear();
		if (pageName == null)
			return monitor;
		
		int numOfEntries = 6;
		try {
			deleteMultipleEntry(monitor, pageName, numOfEntries);
			for(int i=0;i<numOfEntries;i++){
				commonTasks.search(browser,testAccounts.get(i) );
				if(browser.link(testAccounts.get(i)).exists()){
					monitor.fail("Delete Failed");
				}
				else{
					monitor.pass("Delete Passed");
				}
				commonTasks.clearSearch(browser);
			}

		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		} catch (Exception e){
			monitor.fail(e);
		}
		return monitor;
	}
	
	public IPAWebTestMonitor deleteNonStandard(IPAWebTestMonitor monitor){ 
		try {
			CommonTasks.formauth(browser, "admin", "Secret123");
			browser.navigateTo(commonTasks.delegationPage, true);
			String pageName = deleteDelegationNonstandard;
			if (pageName == null)
				return monitor;
			testAccounts.clear();
			deleteSingleEntry(monitor, pageName);
			if(browser.link(testAccounts.get(0)).exists()){
				monitor.fail("Delete Failed");
			}
			else{
				monitor.pass("Delete Passed");
			}
			testAccounts.clear();

			
			browser.navigateTo(commonTasks.userPage, true);
			pageName=deleteUserNonStandard;
			deleteMultipleEntry(monitor, pageName, 3);
			for(int i=0;i<3;i++){
				if(browser.link(testAccounts.get(i)).exists()){
					monitor.fail("Delete Failed");
				}
				else{
					monitor.pass("Delete Passed");
				}
			}

			browser.navigateTo(commonTasks.groupPage, true);
			pageName=deleteGroupNonStandard;
			deleteMultipleEntry(monitor, pageName, 2);
			for(int i=0;i<2;i++){
				if(browser.link(testAccounts.get(i)).exists()){
					monitor.fail("Delete Failed");
				}
				else{
					monitor.pass("Delete Passed");
				}
			}
			browser.navigateTo(commonTasks.delegationPage, true);
			
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		} 
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor addUserDelegation(IPAWebTestMonitor monitor){
		try {
			String pageName = addUserDelegationPage;
			if (pageName == null)
				return monitor;
			testAccounts.clear();
			CommonTasks.formauth(browser, "admin", "Secret123");
			browser.navigateTo(commonTasks.delegationPage,true);
			addSingleNewEntry(monitor, pageName);
			if(browser.link(testAccounts.get(0)).exists()){
				monitor.pass("Added and Verified Successfully");
			}
			else{
				monitor.fail("Add and Verify Failed");
			}

			pageName=loginUser;
			String userName=factory.getModifyTestAccount(pageName);
			pageName=loginOldPassword;
			String password=factory.getModifyTestAccount(pageName);
			CommonTasks.formauth(browser, userName, password);
			browser.link("Users").under(browser.div("Users")).click();
			pageName=editDelegatedUserDisplayName;
			testAccount=factory.getModifyTestAccount(pageName);
			if(browser.link(testAccount).exists()){
				browser.link(testAccount).click();		
				fillDataIntoPage(monitor, pageName);
				pageName=editDelegatedUserEmail;
				fillEmail(monitor, pageName);
				browser.span("Update").click();
				pageName=editDelegatedUserNegative;
				if(browser.link("action enabled").exists()){
					monitor.fail("User without Delegation - reset password: Test Failed");
				}
				browser.link("Users").under(browser.div("Users")).click();
				pageName=editDelegatedUserDisplayName;
				testAccount=factory.getModifyTestAccount(pageName);
				browser.link(testAccount).click();
				pageName=checkDisplayName;
				testAccount=factory.getModifyTestAccount(pageName);
				if(browser.textbox("displayname").getText().equals(testAccount)){
					monitor.pass("Display Name Update Passed");
				}
				pageName=checkEmail1;
				testAccount=factory.getModifyTestAccount(pageName);
				if(browser.textbox("mail-0").getText().equals(testAccount)){
					monitor.pass("" + testAccount + " Email Update Passed");
				}
				pageName=checkEmail2;
				testAccount=factory.getModifyTestAccount(pageName);
				if(browser.textbox("mail-1").getText().equals(testAccount)){
					monitor.pass("" + testAccount + " Email Update Passed");
				}
				pageName=checkEmail3;
				testAccount=factory.getModifyTestAccount(pageName);
				if(browser.textbox("mail-2").getText().equals(testAccount)){
					monitor.pass("" + testAccount + " Email Update Passed");
				}
			}
			int textboxCount=4;
			if(browser.textbox(textboxCount).exists()){
				monitor.fail("Attributes without permission are uneditable: Test Failed");
			}
			browser.link("Users").under(browser.div("Users")).click();
			pageName=EditUndelegatedUser;
			testAccount=factory.getModifyTestAccount(pageName);
			if(browser.link(testAccount).exists()){
				browser.link(testAccount).click();
				if(browser.textbox(0).exists()){
					monitor.fail("User without Delegation is not editable: Test Failed");
				}
			}
			
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor addUserGroup(IPAWebTestMonitor monitor){
		try {
			String pageName = addUserPage;
			int numofEntries=3;
			if (pageName == null)
				return monitor;
			browser.navigateTo(commonTasks.userPage,true);
			for(int i=0;i<numofEntries;i++){
				testAccounts.clear();
				addSingleNewEntry(monitor, pageName);
				if(browser.link(testAccounts.get(0)).exists()){
					monitor.pass("Added and Verified Successfully");
				}
				else{
					monitor.fail("Add and Verify Failed");
				}
			
			}

			pageName=addGroupPage;
			if (pageName == null)
				return monitor;
			browser.navigateTo(commonTasks.groupPage,true);
			numofEntries=2;
			for(int i=0;i<numofEntries;i++){
				testAccounts.clear();
				addSingleNewEntry(monitor, pageName);
				if(browser.link(testAccounts.get(0)).exists()){
					monitor.pass("Added and Verified Successfully");
				}
				else{
					monitor.fail("Add and Verify Failed");
				}
			}
			
			pageName=userToGroupPage;
			if (pageName == null)
				return monitor;
			testAccount=factory.getModifyTestAccount(pageName);
			testAccounts.clear();
			if(browser.link(testAccount).exists()){
				browser.link(testAccount).click();
				browser.link("member_user").click();
				assignUserToGroup(monitor, pageName);
				for(int i=0;i<testAccounts.size();i++){
					if(browser.link(testAccounts.get(i)).exists()){
						monitor.pass("Added and Verified Successfully");
					}
					else{
						monitor.fail("Add and Verify Failed");
					}
				}
				browser.link("User Groups").in(browser.div("content")).click();//xdong
			}
			browser.navigateTo(commonTasks.groupPage, true);
			pageName=memberuserToMemberGroupPage;
			if (pageName == null)
				return monitor;
			testAccounts.clear();
			testAccount=factory.getModifyTestAccount(pageName);
			if(browser.link(testAccount).exists()){
				browser.link(testAccount).click();
				browser.link("member_user").click();
				assignUserToGroup(monitor, pageName);
				for(int i=0;i<testAccounts.size();i++){
					if(browser.link(testAccounts.get(i)).exists()){
						monitor.pass("Added and Verified Successfully");
					}
					else{
						monitor.fail("Add and Verify Failed");
					}
				}
			}
			browser.navigateTo(commonTasks.delegationPage, true);
			
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor delegationNotAdded(IPAWebTestMonitor monitor){
		String pageName=loginUser;
		String userName=factory.getModifyTestAccount(pageName);
		pageName=loginOldPassword;
		String oldPassword=factory.getModifyTestAccount(pageName);
		pageName=loginNewPassword;
		String newPassword=factory.getModifyTestAccount(pageName);
		
		//CommonTasks.kinitAsNewUserFirstTime(userName, oldPassword, newPassword);
		CommonTasks.formauthNewUser(browser, userName,oldPassword, newPassword);
		//CommonTasks.formauth(browser, userName, newPassword);
		
		browser.link("Users").under(browser.div("Users")).click();
		
		pageName=editDelegatedUserNegative;
		testAccount=factory.getModifyTestAccount(pageName);
		if(browser.link(testAccount).exists()){
			browser.link(testAccount).click();
			if(browser.link("action enabled").exists()){
				monitor.fail("User without Delegation - reset password: Test Failed");
			}
			if(browser.textbox(0).exists()){
				monitor.fail("User without Delegation is not editable: Test Failed");
			}
		}
		monitor.pass();
		return monitor;
}
	
	
	////////////////////////////////// generic UI operation  /////////////////////////////
	
	protected void closeDialog()
	{
		if (browser.button("OK").exists())
			browser.button("OK").click();
		else if (browser.span("Cancel").exists())
			browser.span("Cancel").click();
		else if (browser.button("Cancel").exists())
			browser.button("Cancel").click();
		
		// if the dialog still exist, try the close mark (x)
		if (browser.button("Cancel").exists())
			browser.span("close").click();
		
		// if above  does not work, I am out of idea right now
	}
	
	protected boolean verifyInEditingMode()
	{
		boolean verified=false;
		boolean stringCompareRequired = true;
		String editModeVerifyString = "Verify In editing mode 28dkrj3290mjz.IR4AGKJ";
		String originalValue = null, currentValue = null;
		if (browser.textarea("description").exists())
		{
			originalValue = browser.textarea("description").getValue();
			browser.textarea("description").setValue(editModeVerifyString);
			currentValue = browser.textarea("description").getValue(); 
			
		}else if (browser.textbox("cn").exists())
		{// user under identity
			originalValue = browser.textbox("cn").getValue();
			browser.textbox("cn").setValue(editModeVerifyString);
			currentValue = browser.textbox("cn").getValue();
			
		}else if (browser.textbox("krbmaxpwdlife").exists())
		{// Password policy
			originalValue = browser.textbox("krbmaxpwdlife").getValue();
			browser.textbox("krbmaxpwdlife").setValue(editModeVerifyString);
			currentValue = browser.textbox("krbmaxpwdlife").getValue();
			
		}else if (browser.textbox("krbmaxrenewableage").exists())
		{// kerberos policy
			originalValue = browser.textbox("krbmaxrenewableage").getValue();
			browser.textbox("krbmaxrenewableage").setValue(editModeVerifyString);
			currentValue = browser.textbox("krbmaxrenewableage").getValue();
			
		}else if (browser.textbox("ipasearchrecordslimit").exists())
		{
			originalValue = browser.textbox("ipasearchrecordslimit").getValue();
			browser.textbox("ipasearchrecordslimit").setValue(editModeVerifyString);
			currentValue = browser.textbox("ipasearchrecordslimit").getValue();
		}
		else{
			// FIXME: need expend this if-else to cover more cases
			// not sure about: self service permission, delegations, ... use loose check as below
			if (browser.span("Refresh").exists())
				verified = true;
			stringCompareRequired = false; // there is no string to compare if we fall in here
		}
		if (stringCompareRequired)
		{
			if (! originalValue.equals(currentValue) & editModeVerifyString.equals(currentValue))
			{
				verified = true;
				browser.span("undo").click();
			}
		}
		return verified;
	}
	
	////////////////////////////////// generic add & delete operation ///////////////////
	protected void appendEntry(String existingEntry)
	{
		browser.link("Add").click(); 
		browser.checkbox(existingEntry).check();
		browser.span(">>").click();
		browser.button("Add").click();  
	}
	
	protected void appendViaSearch(String filter, String cnValue) 
	{
		browser.link("Add").click();
		browser.textbox("filter").setValue(filter); 
		browser.span("Find").click();
		browser.checkbox(cnValue).check();
		browser.span(">>").click();
		browser.button("Add").click();  
	}

	protected void addSingleNewEntry(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationException
	{  
			browser.span("Add").click();
			fillDataIntoPage(monitor,pageName);
			browser.button("Add").click();
			if(browser.button("OK").exists())//for new prompt "The host was added but the DNS update failed with: DNS reverse zone for IP address xxx not found  "in addhost
				browser.button("OK").click();
	}
	
	protected void assignUserToGroup(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationException
	{  
			browser.span("Add").click();
			fillDataIntoPage(monitor,pageName);
			browser.span(">>").click();
			browser.button("Add").click();
	}
	
	protected void addSingleNewEntryNegative(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationException
	{  
		browser.span("Add").click();
		fillDataIntoPage(monitor,pageName);
		browser.button("Add").click();
	}
	
	protected void addNewEntryThenEdit(IPAWebTestMonitor monitor,String pageName) throws IPAWebAutomationException
	{ 
		browser.span("Add").click();
		fillDataIntoPage(monitor,pageName);
		browser.button("Add and Edit").click();
		if (browser.link("Settings").exists())
			browser.link("Settings").click();
		boolean inEditingMode = verifyInEditingMode();
		if (!inEditingMode)
			monitor.fail("after click 'Add and Edit', we are not in edit mode");
	}
	
	protected void addNewEntryThenCancelOperation(IPAWebTestMonitor monitor,String pageName) throws IPAWebAutomationException
	{
		browser.span("Add").click();
		fillDataIntoPage(monitor,pageName);
		browser.button("Cancel").click(); 
	}
	
	protected void addNegativeSingle(IPAWebTestMonitor monitor, String pageName){ 
		browser.span("Add").click(); 
		StringBuffer testData = new StringBuffer();
		ArrayList<String> expectedErrorMsgs = new ArrayList<String>();
		ArrayList<String> uiElements = factory.getUIELements(pageName);
		for (String uiElement:uiElements)
		{
			String[] elementID = uiElement.split(":"); 
			String tag = elementID[0];
			String id = elementID[1]; 
			String valueAndExpectedErrorMsg = factory.getValue(pageName, tag, id);
			String[] combined = factory.extractValues(valueAndExpectedErrorMsg); 
			String value = combined[0];
			String expectedErrorMsg = combined[1];
			String errortype=combined[2];
			if(errortype != null){
				if(!errortype.equals("")){
					if(errortype.equals("l")){
						value=" " + value;
					}
					else if(errortype.equals("t")){
						value=value + " ";
					}
				}
			}
			setElementValue(monitor, pageName,tag,id,value); 
			testData.append(value + " & ");
			if (expectedErrorMsg != null)
				expectedErrorMsgs.add(expectedErrorMsg);
		}
		monitor.setCurrentTestData(pageName,  "{" + testData.substring(0,testData.length()-3)+ "}");
		browser.button("Add").click();
		boolean matches = verifyExpectedErrorMsg(expectedErrorMsgs);
		if (matches){
			monitor.pass("error message matches with expected");
		}else{
			monitor.fail("error message does NOT match with expected");
		}
		closeDialog(); 
	}
	
	protected void addMultipleNewEntries(IPAWebTestMonitor monitor, String pageName, int numOfEntries) throws IPAWebAutomationException
	{ 
		browser.span("Add").click(); 
		for (int i=0; i< numOfEntries ; i++)
		{ 
			fillDataIntoPage(monitor,pageName);
			browser.button("Add and Add Another").click();
			if(browser.button("OK").exists())//for new prompt "The host was added but the DNS update failed with: DNS reverse zone for IP address xxx not found  "in addhost
				browser.button("OK").click();
		}
		browser.button("Cancel").click();
	}
	
	protected void searchSingle(IPAWebTestMonitor monitor,String pageName) throws IPAWebAutomationException
	{
		fillDataIntoPage(monitor,pageName);
		browser.span("icon search-icon").click(); 
	}
	
	protected void deleteSingleEntry(IPAWebTestMonitor monitor,String pageName) throws IPAWebAutomationException
	{
		//commonTasks.search(browser,testAccounts.get(0));//for privilege and permission which has more than one page of entries that need to search out before deleting 
		fillDataIntoPage(monitor,pageName);
		browser.span("Delete").click(); 
		if(browser.checkbox("updatedns").exists())//for clear entries from DNS ,otherwise there will be a error prompt says"ipa addr. xxx is already assigned" in adding host with a already used ip addr. in last run.
			browser.checkbox("updatedns").click();
		browser.button("Delete").click();
		
	}
	
	protected void deleteMultipleEntry(IPAWebTestMonitor monitor,String pageName, int numOfEntries) throws IPAWebAutomationException
	{ 
		//for privilege and permission which has more than one page of entries that need to search out before deleting,how to do that?????
		for (int i=0;i< numOfEntries;i++)
			fillDataIntoPage(monitor,pageName);
		browser.span("Delete").click(); 
		if(browser.checkbox("updatedns").exists())//for clear entries from DNS ,otherwise there will be a error prompt says"ipa addr. xxx is already assigned" in adding host with a already used ip addr. in last run.
			browser.checkbox("updatedns").click();
		browser.button("Delete").click();
	}
	
	protected void fillDataIntoPage(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationActionNotDefinedException
	{
		ArrayList<String> uiElements = factory.getUIELements(pageName);
		ArrayList<String> expectedErrorMsgs = new ArrayList<String>();
		StringBuffer testData = new StringBuffer();
		int countelements=0;
		for (String uiElement:uiElements)
		{
			String[] elementID = uiElement.split(":"); 
			String tag = elementID[0];
			String id = elementID[1]; 
			String value = factory.getValue(pageName, tag, id);
			if(countelements==0){
				if(tag.equals("checkbox")){
					testAccounts.add(id);
				}
				else{
					testAccounts.add(value);
				}
			}
			if(pageName.equals(addNegativePage) || pageName.equals(searchPage)){
				if(value.charAt(value.length()-1)=='l'){
					value=value.substring(0,value.length()-1);
					value=" " + value;
				}
				else if(value.charAt(value.length()-1)=='t'){
					value=value.substring(0,value.length()-1);
					value=value + " ";
				}
			}
			testData.append(value + " & ");
			fillDataInElement(monitor, pageName,tag,id,value);
			countelements++;
		}
		monitor.setCurrentTestData(pageName,"{" + testData.substring(0,testData.length()-3) + "}");
		
	}
	
	protected void fillEmail(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationActionNotDefinedException
	{
		ArrayList<String> uiElements = factory.getUIELements(pageName);
		StringBuffer testData = new StringBuffer();
		for (String uiElement:uiElements)
		{
			browser.link("Add").under(browser.heading2("Contact Settings")).click();
			String[] elementID = uiElement.split(":"); 
			String tag = elementID[0];
			String id = elementID[1]; 
			String value = factory.getValue(pageName, tag, id);
			testData.append(value + " & ");
			fillDataInElement(monitor, pageName,tag,id,value);
		}
		monitor.setCurrentTestData(pageName,"{" + testData.substring(0,testData.length()-3) + "}");
		
	}
	protected String[] fillDataInElement(IPAWebTestMonitor monitor,String pageName,String tag, String id, String value) throws IPAWebAutomationActionNotDefinedException 
	{
		String before = null;
		String after = null; 
		if (tag.equals("textbox")){
			if ((browser.table("section-table").exists()) && (browser.textbox(id).under(browser.table("section-table")).exists())) // for Add permission in IPA Server tab
			{	
				before = browser.textbox(id).under(browser.table("section-table")).getValue();
				browser.textbox(id).under(browser.table("section-table")).setValue(value);
				after = browser.textbox(id).under(browser.table("section-table")).getValue();
			} 
			else{
				before = browser.textbox(id).getValue();
				browser.textbox(id).setValue(value);
				after = browser.textbox(id).getValue();
			}
		}
		else if (tag.equals("textarea"))
		{
			before = browser.textarea(id).getValue();
			browser.textarea(id).setValue(value);
			after = browser.textarea(id).getValue();
		}else if (tag.equals("password")){
			before = browser.password(id).getValue();
			browser.password(id).setValue(value);
			after = browser.password(id).getValue();
		}
		else if (tag.equals("checkbox")){
			//FIXME: not sure what value to set for checkbox
			if (id.equals("fqdn")) 
				value = value + "."+ CommonTasks.ipadomain; 
			if (id.equals("krbprincipalname"))
				value = value + "/" + CommonTasks.ipafqdn + "@" + CommonTasks.realm;
			
			if (value.equals("check")){
				if (! browser.checkbox(id).checked())
				{
					before="uncheck";
					browser.checkbox(id).check();
					after = "check";
				}else{
					before="check";
					after="check";
				}
			}else if (value.equals("uncheck")){
				if (browser.checkbox(id).checked())
				{
					before = "check";
					browser.checkbox(id).uncheck();
					after="uncheck";
				}else
				{
					before="uncheck";
					after="uncheck";
				}
			}else if (id.equals("automemberinclusiveregex")){ //xdong for automember condition delete all
				browser.checkbox("automemberinclusiveregex").check();//xdong for automember condition delete all
			}else if (id.equals("automemberexclusiveregex")){ //xdong for automember condition delete all
				browser.checkbox("automemberexclusiveregex").check(); //xdong for automember condition delete all
			}else
			{
				browser.checkbox(value).check(); // default behave
				after = value; //FIXME: not sure what would be correct value for check box, set it to value for now
								// this setting make DNS page -> settings -> forward policy work
			}
		}
		else if (tag.equals("radio") && value.equals("check")){
			browser.radio(id).check(); //FIXME: do we have "check" for radio button? but it works
			browser.radio(id).click();
			after = "check"; // FIXME: I don't know why IPA is so special, the click does not work, but check is
		}
		else if (tag.equals("radio") && value.equals("uncheck")){
			browser.radio(id).uncheck(); //FIXME: not sure if we have "uncheck" for radio button
			browser.radio(id).click();;
			after = "uncheck";
		}
		else if (tag.equals("select"))
		{
			if (browser.textbox(id).exists()){
				before = browser.textbox(id).getValue();
				browser.textbox(id).click();
				if(browser.textbox("automemberdefaultgroup").exists()){//xdong for set default group/hostgroup
				
					browser.span("icon search-icon").near(browser.textbox("automemberdefaultgroup")).click();
				}
				browser.select("list").choose(value);
				after = browser.textbox(id).getValue();
			}else if (browser.select(id).exists()) {//xdong for automember rule condition add
				before = browser.select(id).getValue();
				browser.select(id).click();
				browser.select("key").choose(value);
				after = browser.select(id).getValue();
			}else
				throw new IPAWebAutomationActionNotDefinedException(pageName, tag, id);
		
		}else{
			throw new IPAWebAutomationActionNotDefinedException(pageName, tag, id);
		}
		return new String[] {before, after};
	}
	
	
	
	protected String readElementValue(IPAWebTestMonitor monitor,String pageName,String tag, String id, String value)
	{ 
		String elementValue = null;
		if (tag.equals("textbox")){
			if (browser.textbox(id).under(browser.table("section-table")).exists()) // for Add permission in IPA Server tab
				elementValue = browser.textbox(id).under(browser.table("section-table")).getValue();
			else
				elementValue = browser.textbox(id).getValue(); 
		}
		else if (tag.equals("textarea"))
			elementValue = browser.textarea(id).getValue();
		else if (tag.equals("select")){
			if (browser.textbox(id).exists())
				elementValue = browser.textbox(id).getValue();
		}
		else if (tag.equals("password")){
			elementValue = browser.password(id).getValue();
		}
		else if (tag.equals("radio")){
			if (browser.radio(id).checked())
				elementValue = "check";
			else
				elementValue = "uncheck";
		}
		else if (tag.equals("checkbox")){
			if (browser.checkbox(id).checked())
				elementValue = "check";
			else
				elementValue = "uncheck";
		}
		else
			elementValue = "";
		
		return elementValue;
	}
	
	protected String setElementValue(IPAWebTestMonitor monitor,String pageName,String tag, String id, String value) 
	{ 
		String after=null;
		try{
			String[] beforeAndAfter = fillDataInElement(monitor, pageName,tag,id,value);
			after = beforeAndAfter[1];
		}catch (Exception e){}
		return after;
	}
	
//xdong
	
	@Override 
	public IPAWebTestMonitor modifyConditionInclusiveAddSingle(IPAWebTestMonitor monitor) {
		String pageName = modifyConditionInclusiveAddPage ;
		testAccounts.clear();
		if (pageName == null){
			monitor.fail("modify test page not defined:");
			return monitor;
		}
	
		String testAccount = factory.getModifyTestAccount(pageName);
		if (testAccount != null && browser.link(testAccount).exists())//testAccount example: user001
		{
			browser.link(testAccount).click();
			return executeModifyConditionInclusiveAddSingle(monitor, pageName);
		}else{
			monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
			return monitor;
		}  
	}
	
	
protected IPAWebTestMonitor executeModifyConditionInclusiveAddSingle(IPAWebTestMonitor monitor, String pageName) { 
		
		try {
			inclusiveAddSingle(monitor, pageName);
			if(browser.div(testAccounts.get(0)).exists()){
				monitor.pass("Added and Verified Successfully");
			}
			else{
				monitor.fail("Add Failed");
			}
			
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;	
	
	}


protected void inclusiveAddSingle(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationException
	{  
	
		browser.span("Add").near(browser.heading2("Inclusive")).click();
		fillDataIntoPage(monitor,pageName);
		browser.button("Add").click();
	}	

@Override 
public IPAWebTestMonitor modifyConditionInclusiveAddAndAddAnother(IPAWebTestMonitor monitor) {
	String pageName = modifyConditionInclusiveAddPage ;
	
	testAccounts.clear();
	if (pageName == null){
		monitor.fail("modify test page not defined:");
		return monitor;
	}

	String testAccount = factory.getModifyTestAccount(pageName);
	if (testAccount != null && browser.link(testAccount).exists())//testAccount example: user001
	{
		browser.link(testAccount).click();
		return executeModifyConditionInclusiveAddAndAddAnother(monitor, pageName);
	}else{
		monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
		return monitor;
	}  
}


protected IPAWebTestMonitor executeModifyConditionInclusiveAddAndAddAnother(IPAWebTestMonitor monitor, String pageName) { 
	
	int numOfEntries = 2;
	try {
		inclusiveAddAndAddAnother(monitor, pageName, numOfEntries);
		for(int i=0;i<numOfEntries;i++){
			if(browser.div(testAccounts.get(i)).exists()){
				monitor.pass("Added and Verified Successfully");
			}
			else{
				monitor.fail("Add Failed");
			}
		}	

	} catch (IPAWebAutomationException e) { 
		e.printStackTrace();
		monitor.fail(e);
	} catch (Exception e){
		e.printStackTrace();
		monitor.fail(e);
	}
	return monitor;
}


protected void inclusiveAddAndAddAnother(IPAWebTestMonitor monitor, String pageName, int numOfEntries) throws IPAWebAutomationException
{  
	browser.span("Add").near(browser.heading2("Inclusive")).click();
	for (int i=0; i< numOfEntries ; i++)
	{ 
		fillDataIntoPage(monitor,pageName);
		browser.button("Add and Add Another").click();
	}
	browser.button("Cancel").click();
}	


@Override 
public IPAWebTestMonitor modifyConditionInclusiveAddThenCancel(IPAWebTestMonitor monitor) {
	String pageName = modifyConditionInclusiveAddPage ;
	testAccounts.clear();
	if (pageName == null){
		monitor.fail("modify test page not defined:");
		return monitor;
	}

	String testAccount = factory.getModifyTestAccount(pageName);
	if (testAccount != null && browser.link(testAccount).exists())//testAccount example: user001
	{
		browser.link(testAccount).click();
		return executeModifyConditionInclusiveAddThenCancel(monitor, pageName);
	}else{
		monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
		return monitor;
	}  
}


protected IPAWebTestMonitor executeModifyConditionInclusiveAddThenCancel(IPAWebTestMonitor monitor, String pageName) { 
	
	
	try {
		inclusiveAddThenCancel(monitor, pageName);
		if(browser.div(testAccounts.get(0)).exists()){
			monitor.fail("Add Failed");
		}
		else{
			monitor.pass("Added and Verified Successfully");
		}
	} catch (IPAWebAutomationException e) {
		e.printStackTrace();
		monitor.fail(e);
	}
	return monitor;
}


protected void inclusiveAddThenCancel(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationException
{  
	browser.span("Add").near(browser.heading2("Inclusive")).click();
	fillDataIntoPage(monitor,pageName);
	browser.button("Cancel").click();
}	


@Override 
public IPAWebTestMonitor modifyConditionInclusiveDeleteSingle(IPAWebTestMonitor monitor) {
	String pageName = modifyConditionInclusiveDeletePage ;
	testAccounts.clear();
	if (pageName == null){
		monitor.fail("modify test page not defined:");
		return monitor;
	}

	String testAccount = factory.getModifyTestAccount(pageName);
	if (testAccount != null && browser.link(testAccount).exists())//testAccount example: user001
	{
		browser.link(testAccount).click();
		return executeModifyConditionInclusiveDeleteSingle(monitor, pageName);
	}else{
		monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
		return monitor;
	}  
}


protected IPAWebTestMonitor executeModifyConditionInclusiveDeleteSingle(IPAWebTestMonitor monitor, String pageName) { 
	
	try {
		inclusiveDeleteSingle(monitor, pageName);
		if(browser.div(testAccounts.get(0)).exists()){
			monitor.fail("Delete Failed");
		}
		else{
			monitor.pass("Deleted and Verified Successfully");
		}
		
	} catch (IPAWebAutomationException e) { 
		e.printStackTrace();
		monitor.fail(e);
	}
	return monitor;	

}


protected void inclusiveDeleteSingle(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationException
{  
	fillDataIntoPage(monitor,pageName);
	browser.span("Delete").near(browser.heading2("Inclusive")).click(); 
	browser.button("Delete").click();
	
}	


@Override 
public IPAWebTestMonitor modifyConditionInclusiveDeleteMultiple(IPAWebTestMonitor monitor) {
	String pageName = modifyConditionInclusiveDeletePage ;
	testAccounts.clear();
	if (pageName == null){
		monitor.fail("modify test page not defined:");
		return monitor;
	}

	String testAccount = factory.getModifyTestAccount(pageName);
	if (testAccount != null && browser.link(testAccount).exists())//testAccount example: user001
	{
		browser.link(testAccount).click();
		return executeModifyConditionInclusiveDeleteMultiple(monitor, pageName);
	}else{
		monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
		return monitor;
	}  
}


protected IPAWebTestMonitor executeModifyConditionInclusiveDeleteMultiple(IPAWebTestMonitor monitor, String pageName) { 
	
	int numOfEntries = 3;
	try {
		inclusiveDeleteMultiple(monitor, pageName, numOfEntries);
		for(int i=0;i<numOfEntries;i++){
			if(browser.div(testAccounts.get(i)).exists()){
				monitor.fail("Delete Failed");
			}
			else{
				monitor.pass("Delete Passed");
			}
		}

	} catch (IPAWebAutomationException e) { 
		e.printStackTrace();
		monitor.fail(e);
	} catch (Exception e){
		monitor.fail(e);
	}
	return monitor;
}


protected void inclusiveDeleteMultiple(IPAWebTestMonitor monitor, String pageName, int numOfEntries) throws IPAWebAutomationException
{  
	for (int i=0;i< numOfEntries;i++)
		fillDataIntoPage(monitor,pageName);
	browser.span("Delete").near(browser.heading2("Inclusive")).click(); 
	browser.button("Delete").click();
	
}	





@Override 
public IPAWebTestMonitor modifyConditionExclusiveAddSingle(IPAWebTestMonitor monitor) {
	String pageName = modifyConditionExclusiveAddPage ;
	testAccounts.clear();
	if (pageName == null){
		monitor.fail("modify test page not defined:");
		return monitor;
	}

	String testAccount = factory.getModifyTestAccount(pageName);
	if (testAccount != null && browser.link(testAccount).exists())//testAccount example: user001
	{
		browser.link(testAccount).click();
		return executeModifyConditionExclusiveAddSingle(monitor, pageName);
	}else{
		monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
		return monitor;
	}  
}


protected IPAWebTestMonitor executeModifyConditionExclusiveAddSingle(IPAWebTestMonitor monitor, String pageName) { 
	
	try {
		exclusiveAddSingle(monitor, pageName);
		if(browser.div(testAccounts.get(0)).exists()){
			monitor.pass("Added and Verified Successfully");
		}
		else{
			monitor.fail("Add Failed");
		}
		
	} catch (IPAWebAutomationException e) { 
		e.printStackTrace();
		monitor.fail(e);
	}
	return monitor;	

}


protected void exclusiveAddSingle(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationException
{  

	browser.span("Add").near(browser.heading2("Exclusive")).click();
	fillDataIntoPage(monitor,pageName);
	browser.button("Add").click();
}	

@Override 
public IPAWebTestMonitor modifyConditionExclusiveAddAndAddAnother(IPAWebTestMonitor monitor) {
String pageName = modifyConditionExclusiveAddPage ;

testAccounts.clear();
if (pageName == null){
	monitor.fail("modify test page not defined:");
	return monitor;
}

String testAccount = factory.getModifyTestAccount(pageName);
if (testAccount != null && browser.link(testAccount).exists())//testAccount example: user001
{
	browser.link(testAccount).click();
	return executeModifyConditionExclusiveAddAndAddAnother(monitor, pageName);
}else{
	monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
	return monitor;
}  
}


protected IPAWebTestMonitor executeModifyConditionExclusiveAddAndAddAnother(IPAWebTestMonitor monitor, String pageName) { 

int numOfEntries = 2;
try {
	exclusiveAddAndAddAnother(monitor, pageName, numOfEntries);
	for(int i=0;i<numOfEntries;i++){
		if(browser.div(testAccounts.get(i)).exists()){
			monitor.pass("Added and Verified Successfully");
		}
		else{
			monitor.fail("Add Failed");
		}
	}	

} catch (IPAWebAutomationException e) { 
	e.printStackTrace();
	monitor.fail(e);
} catch (Exception e){
	e.printStackTrace();
	monitor.fail(e);
}
return monitor;
}


protected void exclusiveAddAndAddAnother(IPAWebTestMonitor monitor, String pageName, int numOfEntries) throws IPAWebAutomationException
{  
browser.span("Add").near(browser.heading2("Exclusive")).click();
for (int i=0; i< numOfEntries ; i++)
{ 
	fillDataIntoPage(monitor,pageName);
	browser.button("Add and Add Another").click();
}
browser.button("Cancel").click();
}	


@Override 
public IPAWebTestMonitor modifyConditionExclusiveAddThenCancel(IPAWebTestMonitor monitor) {
String pageName = modifyConditionExclusiveAddPage ;
testAccounts.clear();
if (pageName == null){
	monitor.fail("modify test page not defined:");
	return monitor;
}

String testAccount = factory.getModifyTestAccount(pageName);
if (testAccount != null && browser.link(testAccount).exists())//testAccount example: user001
{
	browser.link(testAccount).click();
	return executeModifyConditionExclusiveAddThenCancel(monitor, pageName);
}else{
	monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
	return monitor;
}  
}


protected IPAWebTestMonitor executeModifyConditionExclusiveAddThenCancel(IPAWebTestMonitor monitor, String pageName) { 


try {
	exclusiveAddThenCancel(monitor, pageName);
	if(browser.div(testAccounts.get(0)).exists()){
		monitor.fail("Add Failed");
	}
	else{
		monitor.pass("Added and Verified Successfully");
	}
} catch (IPAWebAutomationException e) {
	e.printStackTrace();
	monitor.fail(e);
}
return monitor;
}


protected void exclusiveAddThenCancel(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationException
{  
browser.span("Add").near(browser.heading2("Exclusive")).click();
fillDataIntoPage(monitor,pageName);
browser.button("Cancel").click();
}	


@Override 
public IPAWebTestMonitor modifyConditionExclusiveDeleteSingle(IPAWebTestMonitor monitor) {
String pageName = modifyConditionExclusiveDeletePage ;
testAccounts.clear();
if (pageName == null){
	monitor.fail("modify test page not defined:");
	return monitor;
}

String testAccount = factory.getModifyTestAccount(pageName);
if (testAccount != null && browser.link(testAccount).exists())//testAccount example: user001
{
	browser.link(testAccount).click();
	return executeModifyConditionExclusiveDeleteSingle(monitor, pageName);
}else{
	monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
	return monitor;
}  
}


protected IPAWebTestMonitor executeModifyConditionExclusiveDeleteSingle(IPAWebTestMonitor monitor, String pageName) { 

try {
	exclusiveDeleteSingle(monitor, pageName);
	if(browser.div(testAccounts.get(0)).exists()){
		monitor.fail("Delete Failed");
	}
	
	else{
		monitor.pass("Deleted and Verified Successfully");
	}
	
} catch (IPAWebAutomationException e) { 
	e.printStackTrace();
	monitor.fail(e);
}
return monitor;	

}


protected void exclusiveDeleteSingle(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationException
{  
fillDataIntoPage(monitor,pageName);
browser.span("Delete").near(browser.heading2("Exclusive")).click(); 
browser.button("Delete").click();

}	


@Override 
public IPAWebTestMonitor modifyConditionExclusiveDeleteMultiple(IPAWebTestMonitor monitor) {
String pageName = modifyConditionExclusiveDeletePage ;
testAccounts.clear();
if (pageName == null){
	monitor.fail("modify test page not defined:");
	return monitor;
}

String testAccount = factory.getModifyTestAccount(pageName);
if (testAccount != null && browser.link(testAccount).exists())//testAccount example: user001
{
	browser.link(testAccount).click();
	return executeModifyConditionExclusiveDeleteMultiple(monitor, pageName);
}else{
	monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
	return monitor;
}  
}


protected IPAWebTestMonitor executeModifyConditionExclusiveDeleteMultiple(IPAWebTestMonitor monitor, String pageName) { 

int numOfEntries = 3;
try {
	exclusiveDeleteMultiple(monitor, pageName, numOfEntries);
	for(int i=0;i<numOfEntries;i++){
		if(browser.div(testAccounts.get(i)).exists()){
			monitor.fail("Delete Failed");
		}
		else{
			monitor.pass("Delete Passed");
		}
	}

} catch (IPAWebAutomationException e) { 
	e.printStackTrace();
	monitor.fail(e);
} catch (Exception e){
	monitor.fail(e);
}
return monitor;
}


protected void exclusiveDeleteMultiple(IPAWebTestMonitor monitor, String pageName, int numOfEntries) throws IPAWebAutomationException
{  
for (int i=0;i< numOfEntries;i++)
	fillDataIntoPage(monitor,pageName);
browser.span("Delete").near(browser.heading2("Exclusive")).click(); 
browser.button("Delete").click();

}	

@Override 
public IPAWebTestMonitor setDefaultGroup(IPAWebTestMonitor monitor) {
	String pageName = setDefaultGroupPage ;
	testAccounts.clear();
	if (pageName == null)
		return monitor;
	try {
		setDefault(monitor, pageName);
		if((browser.textbox("automemberdefaultgroup").value()).equals(testAccounts.get(0))){
			monitor.pass("Setdefault Passed");
		}
		else{
			monitor.fail("Set Failed");
		}
		
			
	} catch (IPAWebAutomationException e) { 
		e.printStackTrace();
		monitor.fail(e);
	}
	return monitor;
}



protected void setDefault(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationException
{  

	fillDataIntoPage(monitor,pageName);
	
}	

}