package com.redhat.qe.ipa.sahi.tasks;

import java.util.Random;

import com.redhat.qe.ipa.sahi.tasks.*;

public class CommonHelper { 
	////////////////////////////////// generic add & delete operation ///////////////////
	public static void addEntry(SahiTasks browser, String existingEntry)
	{
		browser.link("Add").click(); 
		browser.checkbox(existingEntry).check();
		browser.span(">>").click();
		browser.button("Add").click();  
	}
	
	public static void addEntry(SahiTasks browser, String[] existingEntry)
	{
		browser.link("Add").click(); 
		for (String name:existingEntry)
			browser.checkbox(name).check();
		browser.span(">>").click();
		browser.button("Add").click();
	}
	
	public static void addViaSearch(SahiTasks browser,String filter, String cnValue) {
		browser.link("Add").click();
		browser.textbox("filter").setValue(filter); 
		browser.span("Find").click();
		browser.checkbox(cnValue).check();
		browser.span(">>").click();
		browser.button("Add").click();  
	}

	public static void addNewEntry(SahiTasks browser, String newEntryCNValue)
	{
		browser.span("Add").click();
		browser.textbox("cn").setValue(newEntryCNValue); 
		browser.button("Add").click();
	}
	
	public static void addNewEntry(SahiTasks browser, String[] newEntryCNValues)
	{
		browser.span("Add").click();
		for(String cn:newEntryCNValues)
		{
			browser.textbox("cn").setValue(cn); 
			browser.button("Add and Add Another").click();
		}
		browser.button("Cancel").click();
	}
	
	public static void addNewEntry(SahiTasks browser, String newEntryCNValue, String newEntryDescValue)
	{
		browser.span("Add").click();
		browser.textbox("cn").setValue(newEntryCNValue);
		browser.textarea("description").setValue(newEntryDescValue);
		browser.button("Add").click();
	}
	
	public static void deleteEntry(SahiTasks browser, String cnValue)
	{
		browser.checkbox(cnValue).click(); 
		browser.span("Delete").click(); 
		browser.button("Delete").click();
	}
	
	public static void deleteEntry(SahiTasks browser, String[] cnValues)
	{
		for (String cn: cnValues) 
			browser.checkbox(cn).click(); 
		browser.span("Delete").click(); 
		browser.button("Delete").click();
	}

	/////////////////////////// get single random element from an array ///////////////////////////
	public static String getSingle(Random random, String[] data)
	{
		int size = data.length; 
		int randomIndex = Math.abs(random.nextInt()) % (size-1);
		String single =  data[randomIndex];
		return single;
	}
	
	public static String getMultiple(Random random, int maxPick, String[] data)
	{ 
		int size = data.length;
		if (maxPick > size-1)
			maxPick = size -1;
		StringBuffer sb = new StringBuffer(); 
		for (int i=0;i<maxPick;i++)
		{
			int randomIndex = Math.abs(random.nextInt()) % (size-1);
			String pick = data[randomIndex];
			sb.append(pick + ",");
		}
		String ret = sb.substring(0,sb.length() -1);
		return ret;
	}
	
	public static String getAll(String[] data)
	{
		StringBuffer sb = new StringBuffer();
		for (String item:data)
			sb.append(item + ",");
		String ret = sb.substring(0,sb.length() -1);
		return ret;
	}
}
