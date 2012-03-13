package com.redhat.qe.ipa.sahi.pages;

public class IPAWebAutomationActionNotDefinedException extends IPAWebAutomationException {

	private static final long serialVersionUID = 1L;

	public IPAWebAutomationActionNotDefinedException(String pageName, String tag, String id){
		super();
		this.pageName = pageName;
		this.tag = tag;
		this.id = id;
		msg = "[IPAWebAutomationActionNotDefinedException] Value OR Action Not defined: page=["+pageName+"] tag=["+tag+"] id=["+id+"]"; 
	}
	
}
