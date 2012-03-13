package com.redhat.qe.ipa.sahi.pages;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class IPAWebPage {

	protected SahiTasks browser;
	protected String url;
	protected Hashtable<String,ArrayList<String>> testQueues;
	protected String backLink;
	protected String duplicateErrorMsgStartsWith;
	protected String duplicateErrorMsgEndsWith ="already exists";
	
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
		}
		
		if (! originalValue.equals(currentValue) & editModeVerifyString.equals(currentValue))
		{
			verified = true;
			browser.span("undo").click();
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
		for (String uiElement:uiElements)
		{
			String[] elementID = uiElement.split(":"); 
			String tag = elementID[0];
			String id = elementID[1]; 
			String value = factory.getValue(pageName, tag, id); 
			fillDataInElement(monitor, pageName,tag,id,value);
		} 
	}

	private void fillDataInElement(IPAWebTestMonitor monitor,String pageName,String tag, String id, String value) throws IPAWebAutomationActionNotDefinedException 
	{ 
		monitor.setCurrentTestData(pageName + ":" + tag + ":" + id + ":" + value);
		if (tag.equals("textbox"))
			browser.textbox(id).setValue(value);
		else if (tag.equals("textarea"))
			browser.textarea(id).setValue(value);
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
				browser.textbox(id).click();
				browser.select("list").choose(value);
			}else
				throw new IPAWebAutomationActionNotDefinedException(pageName, tag, id);
		}
		else{
			throw new IPAWebAutomationActionNotDefinedException(pageName, tag, id);
		}
	}
}
