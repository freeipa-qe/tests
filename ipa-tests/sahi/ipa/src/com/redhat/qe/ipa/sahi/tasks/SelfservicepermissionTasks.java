package com.redhat.qe.ipa.sahi.tasks;

public class SelfservicepermissionTasks {

	public static void addSelfservicePermission(SahiTasks browser, String permissionName, String[] attrs) {
		CommonHelper.addSelfservicePermission(browser, permissionName, attrs); 
	}

	public static void deletePermission(SahiTasks browser, String permissionName) {
		CommonHelper.deleteEntry(browser, permissionName);
	}

}
