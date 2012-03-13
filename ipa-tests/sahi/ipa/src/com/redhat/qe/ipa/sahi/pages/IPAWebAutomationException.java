package com.redhat.qe.ipa.sahi.pages;

public class IPAWebAutomationException extends Exception {

	private static final long serialVersionUID = 1L;
	protected String pageName;
	protected String tag;
	protected String id;
	protected String msg;
	
	public IPAWebAutomationException(){
		super();
	} 
	
	public String getIPAMessage() {return msg;}
}
