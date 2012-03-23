package com.redhat.qe.ipa.sahi.pages;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class IPAWebPage implements StandardTest{

	protected SahiTasks browser;
	protected String url;
	protected Hashtable<String,ArrayList<String>> testQueues;
	protected String backLink;
	protected String duplicateErrorMsgStartsWith;
	protected String duplicateErrorMsgEndsWith ="already exists";
	
	protected String addPage;
	protected String addNegativePage;
	protected String duplicatePage;
	protected String modifyPage;
	protected String modifyNegativePage;
	protected String delPage;
	
	private TestDataFactory factory;
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
		this.registerTestCases("modify", standardModTestCases);
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
		try {
			addSingleNewEntry(monitor, addPage);
			monitor.pass();
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor addAndAddAnother(IPAWebTestMonitor monitor){
		int numOfEntries = 3;
		try {
			addMultipleNewEntries(monitor, addPage, numOfEntries);
			monitor.pass();
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
		try {
			addNewEntryThenEdit(monitor,addPage);
			monitor.pass();
		} catch (IPAWebAutomationException e) {
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}

	@Override
	public IPAWebTestMonitor addThenCancel(IPAWebTestMonitor monitor){
		try {
			addNewEntryThenCancelOperation(monitor, addPage);
			monitor.pass();
		} catch (IPAWebAutomationException e) {
			e.printStackTrace();
			monitor.fail(e);
		}
		return monitor;
	}

	@Override
	public IPAWebTestMonitor addNegativeDuplicate(IPAWebTestMonitor monitor) {
		try {
			addSingleNewEntry(monitor, duplicatePage);
			addSingleNewEntry(monitor, duplicatePage);
			
			// check error dialog box
			if (browser.div("error_dialog").exists()){
				String errorMsg = browser.div("error_dialog").getText();
				if (errorMsg.startsWith(duplicateErrorMsgStartsWith) && errorMsg.endsWith(duplicateErrorMsgEndsWith))
					monitor.pass();
				else
					monitor.fail("Error dialog triggered, but no desired error msg found");
				closePopUpDialog();
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
		closePopUpDialog();
		return monitor;
	}

	@Override
	public IPAWebTestMonitor addNegative(IPAWebTestMonitor monitor){
		String pageName = addNegativePage;
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
		}
		return match;
	}

	@Override
	public IPAWebTestMonitor modify(IPAWebTestMonitor monitor) {
		// get into editing mode
		String pageName = modifyPage;
		String testAccount = factory.getModifyTestAccount(pageName);
		if (testAccount != null && browser.link(testAccount).exists())
		{
			browser.link(testAccount).click();
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
				String afterUpdate = setElementValue(monitor, pageName,tag,id,value);
				if (browser.div("error_dialog").exists())
				{
					String errorMessage = browser.div("error_dialog").getText();
					monitor.fail("error on 'Update', error dialog appears, dialog says:(" + errorMessage + ")");
					browser.button("Cancel").click();
					browser.span("undo").click();
				}else{ 
					if (afterUpdate.equals(value)) 
						monitor.pass("after 'Update', new value being set, test pass");
					else
						monitor.fail("after 'Update', new value not assigned to element, test failed");
				}
			} 
			browser.link(backLink).click();
			if (browser.span("Unsaved Changes").exists())
			{
				monitor.fail("there is 'Unsaved Changes', it is not suppose to happen, need find out why");
				browser.button("Reset").click();
			}
		}else{
			monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
		} 
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor modifyNegative(IPAWebTestMonitor monitor) {
		// get into editing mode
		String pageName = modifyNegativePage;
		String testAccount = factory.getModifyTestAccount(pageName);
		if (testAccount != null && browser.link(testAccount).exists())
		{
			browser.link(testAccount).click();
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
				}else{ 
					monitor.fail("error dialog does not appear, expect[" + expectedErrorMsg + "]");
				}
			} 
			browser.link(backLink).in(browser.span("back-link")).click();
			if (browser.span("Unsaved Changes").exists()) 
				browser.button("Reset").click();
		}else{
			monitor.fail("test account for page ["+ pageName + "] not defined or link does not exist");
		} 
		return monitor; 
	}
	
	@Override
	public IPAWebTestMonitor deleteSingle(IPAWebTestMonitor monitor){ 
		try {
			deleteSingleEntry(monitor, delPage);
			monitor.pass();
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		} 
		return monitor;
	}
	
	@Override
	public IPAWebTestMonitor deleteMultiple(IPAWebTestMonitor monitor){
		int numOfEntries = 5;
		try {
			deleteMultipleEntry(monitor, delPage, numOfEntries);
			monitor.pass();
		} catch (IPAWebAutomationException e) { 
			e.printStackTrace();
			monitor.fail(e);
		} catch (Exception e){
			monitor.fail(e);
		}
		return monitor;
	}
	
	////////////////////////////////// generic UI operation  /////////////////////////////
	
	protected void closePopUpDialog()
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
		{// pasword policy
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
		closePopUpDialog(); 
	}
	
	protected void addMultipleNewEntries(IPAWebTestMonitor monitor, String pageName, int numOfEntries) throws IPAWebAutomationException
	{ 
		browser.span("Add").click(); 
		for (int i=0; i< numOfEntries ; i++)
		{ 
			fillDataIntoPage(monitor,pageName);
			browser.button("Add and Add Another").click();
		}
		browser.button("Cancel").click();
	}
	
	protected void deleteSingleEntry(IPAWebTestMonitor monitor,String pageName) throws IPAWebAutomationException
	{
		fillDataIntoPage(monitor,pageName);
		browser.span("Delete").click(); 
		browser.button("Delete").click();
	}
	
	protected void deleteMultipleEntry(IPAWebTestMonitor monitor,String pageName, int numOfEntries) throws IPAWebAutomationException
	{ 
		for (int i=0;i< numOfEntries;i++)
			fillDataIntoPage(monitor,pageName);
		browser.span("Delete").click(); 
		browser.button("Delete").click();
	}
	
	protected void fillDataIntoPage(IPAWebTestMonitor monitor, String pageName) throws IPAWebAutomationActionNotDefinedException
	{
		ArrayList<String> uiElements = factory.getUIELements(pageName);
		StringBuffer testData = new StringBuffer();
		for (String uiElement:uiElements)
		{
			String[] elementID = uiElement.split(":"); 
			String tag = elementID[0];
			String id = elementID[1]; 
			String value = factory.getValue(pageName, tag, id); 
			testData.append(value + " & ");
			fillDataInElement(monitor, pageName,tag,id,value);
		}
		monitor.setCurrentTestData(pageName,"{" + testData.substring(0,testData.length()-3) + "}");
	}
	
	private String[] fillDataInElement(IPAWebTestMonitor monitor,String pageName,String tag, String id, String value) throws IPAWebAutomationActionNotDefinedException 
	{
		String before = null;
		String after = null; 
		if (tag.equals("textbox")){
			if (browser.textbox(id).under(browser.table("section-table")).exists()) // for Add permission in IPA Server tab
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
			browser.password(id).setValue(value);
		}
		else if (tag.equals("checkbox")){
			if (id.equals("fqdn")) 
				value = value + "."+ CommonTasks.ipadomain; 
			if (id.equals("krbprincipalname"))
				value = value + "/" + CommonTasks.ipafqdn + "@" + CommonTasks.realm;
			
			if (value.equals("check")){
				if (! browser.checkbox(id).checked())
					browser.checkbox(id).check();
			}else if (value.equals("uncheck")){
				if (browser.checkbox(id).checked())
					browser.checkbox(id).uncheck();
			}else
				browser.checkbox(value).check(); // default behave
		}
		else if (tag.equals("radio") && value.equals("check"))
			browser.radio(id).check();
		else if (tag.equals("radio") && value.equals("uncheck"))
			browser.radio(id).uncheck();
		else if (tag.equals("select"))
		{
			if (browser.textbox(id).exists()){
				before = browser.textbox(id).getValue();
				browser.textbox(id).click();
				browser.select("list").choose(value);
				after = browser.textbox(id).getValue();
			}else
				throw new IPAWebAutomationActionNotDefinedException(pageName, tag, id);
		}
		else{
			throw new IPAWebAutomationActionNotDefinedException(pageName, tag, id);
		}
		return new String[] {before, after};
	}
	
	private String readElementValue(IPAWebTestMonitor monitor,String pageName,String tag, String id, String value)
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
			browser.password(id).setValue(value);
		}
		else
			elementValue = "";
		
		return elementValue;
	}
	
	private String setElementValue(IPAWebTestMonitor monitor,String pageName,String tag, String id, String value) 
	{ 
		String after = null;
		if (tag.equals("textbox")){
			if (browser.textbox(id).under(browser.table("section-table")).exists()) // for Add permission in IPA Server tab
			{	
				browser.textbox(id).under(browser.table("section-table")).setValue(value);
				after = browser.textbox(id).under(browser.table("section-table")).getValue();
			}else{
				browser.textbox(id).setValue(value);
				after = browser.textbox(id).getValue();
			}
		}else if (tag.equals("textarea")){
			browser.textarea(id).setValue(value);
			after = browser.textarea(id).getValue();
		}else if (tag.equals("select")){
			if (browser.textbox(id).exists()){
				browser.textbox(id).click();
				browser.select("list").choose(value);
				after = browser.textbox(id).getValue();
			}
		}else if (tag.equals("password")){
			browser.password(id).setValue(value);
			after = browser.password(id).getValue();
		}
		else{
			after = "";
		}
		return after;
	}
}
