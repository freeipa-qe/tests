package com.redhat.qe.ipa.sahi.pages;

import java.util.*;

import java.util.logging.Logger;

import com.redhat.qe.ipa.sahi.tasks.CommonTasks;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 
import com.sun.corba.se.impl.orb.ParserTable.TestAcceptor1;
//import com.redhat.qe.ipa.sahi.*;
public class IPAServerPageDelegation extends IPAWebPage{

	private static Logger log = Logger.getLogger(IPAServerPageDelegation.class.getName());
	private static String url = CommonTasks.delegationPage;
	
	public IPAServerPageDelegation (SahiTasks browser, String testPropertyFile)
	{
		super(browser, url, testPropertyFile);
		backLink = "Delegations";
		duplicateErrorMsgStartsWith = "This entry";
		testAccount="";
		
		addPage = "Add Delegation";
		addSpecialPage="Add Special Delegation";
		addLongPage="Add Long Delegation";
		duplicatePage = "Add Duplicate Delegation";
		addNegativePage="Add Negative Delegation";
		modifySettingsPage="Modify Delegation Settings";
		modifyUpdateResetCancelPage="Modify Delegation UpdateResetCancel";
		modifyNegativePage="Modify Delegation Negative";
		searchPage="Search Delegation";
		delPage = "Delete Delegation"; 
		addUserPage="Add User";
		addGroupPage="Add Group";
		editDelegatedUserNegative="Edit Delegated User Negative";
		editDelegatedUserDisplayName="Edit Delegated User DisplayName";
		editDelegatedUserEmail="Edit Delegated User Email";
		checkDisplayName="Check Display Name";
		checkEmail1="Check Email1";
		checkEmail2="Check Email2";
		checkEmail3="Check Email3";
		deleteDelegationNonstandard="Delete Delegation Nonstandard";
		deleteUserNonStandard="Delete User NonStandard";
		EditUndelegatedUser="Edit Undelegated User";
		deleteGroupNonStandard="Delete Group NonStandard";
		addUserDelegationPage="Add User Delegation";
		userToGroupPage="Add User to UserGroup";
		memberuserToMemberGroupPage="Add MemberUser to MemberUserGroup";
		loginUser="Login Username";
		loginOldPassword="Login Old Password";
		loginNewPassword="Login New Password";
		
		registerStandardTestCases();
		registerTestCases("nonStandardUserDelegation", EditUserDelegationTestCases);
		System.out.println("New instance of " + IPAServerPageDelegation.class.getName() + " is ready");
	}

}
