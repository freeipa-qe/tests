package com.redhat.qe.ipa21.tasks;

import static org.testng.Assert.fail;

import com.redhat.qe.auto.selenium.Element;
import com.redhat.qe.auto.selenium.ExtendedSelenium;
import com.redhat.qe.ipa.base.SeleniumTestScript;



public class CommonTasks {
	
	public static Element networkActivityIndicator = new Element("//span[@id='header-network-activity-indicator']");
	
	
	public static ExtendedSelenium sel(){
		return SeleniumTestScript.selenium;
	}
	
	public static void waitForRefresh(ExtendedSelenium selenium) {
		for (int second = 0;; second++) {
			if (second >= 60) fail("timeout");
			try { 
				if (!selenium.isVisible(networkActivityIndicator)) 
					break; 
			}
			catch (Exception e) {}
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
	
	
	public static void waitForRefreshTillTextPresent(ExtendedSelenium selenium, String textPresent) {
		for (int second = 0;; second++) {
			if (second >= 60) fail("timeout");
			try { 
				if (!selenium.isVisible(networkActivityIndicator)) 
					break; 
			}
			catch (Exception e) {}
			
			try { if (selenium.isTextPresent(textPresent)) break; } catch (Exception e) {} 
			
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
	
	
	/*
	public String generateRandomString(int iCharCount) {
    	RandomData rd1 = new RandomData(iCharCount);
        return rd1.toString();
    } */

	public static void kinitAsAdmin(String admin, String password) {
		
	}
}
