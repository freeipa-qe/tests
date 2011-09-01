package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 
import com.redhat.qe.ipa.sahi.tests.group.GroupTests;


public class GroupTasks {
    private static Logger log = Logger.getLogger(GroupTasks.class.getName());
     
    /*
     * Add a Group
     * @param sahiTasks 
     * @param groupName - user group name
     * @param groupDescription - group description
     */
    public static void addGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {
        sahiTasks.span("Add").click();
        sahiTasks.textbox("cn").setValue(groupName);
        sahiTasks.textbox("description").setValue(groupDescription);
        sahiTasks.button("Add").click();
    }
    
    /*
     * Delete a Group
     * @param sahiTasks 
     * @param groupname - name of group to delete
     */
    public static void deleteGroup(SahiTasks sahiTasks, String groupName) {
    	sahiTasks.checkbox(groupName).click();
        sahiTasks.link("Delete").click();
        sahiTasks.button("Delete").click();
    }
    
    /*
     * Delete a Group
     * @param sahiTasks 
     * @param groupnames - array of group names to delete
     */
    public static void deleteGroup(SahiTasks sahiTasks, String [] groupnames) {
    	for (String groupname : groupnames) {
    		sahiTasks.checkbox(groupname).click();
    	}
        sahiTasks.link("Delete").click();
        sahiTasks.button("Delete").click();
    }
    
    /*
	 * verify members
	 * @param sahiTasks
	 * @param groupname - name of user group
	 * @param membertype - user or usergroup
	 * @param name - name of member to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members YES if they should be
	 */
	public static void verifyMembers(SahiTasks sahiTasks, String groupName, String membertype, String name, String exists) {
		sahiTasks.link(groupName).click();
		if (membertype == "user"){
			sahiTasks.link("member_user").click();
		}
		if (membertype == "usergroup"){
			sahiTasks.link("member_group").click();
		}	

		if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(name).exists(), membertype + " " + name + " is a member of user group " + groupName);
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(name).exists(), membertype + " " + name + " is NOT member of user group " + groupName);
		}

		sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
	}
    
    /*
	 * verify members
	 * @param sahiTasks
	 * @param groupname - name of user group
	 * @param membertype - user or usergroup
	 * @param names - array of names to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members YES if they should be
	 */
	public static void verifyMembers(SahiTasks sahiTasks, String groupName, String membertype, String [] names, String exists) {
		sahiTasks.link(groupName).click();
		if (membertype == "user"){
			sahiTasks.link("member_user").click();
		}
		if (membertype == "usergroup"){
			sahiTasks.link("member_group").click();
		}	
		for (String name : names) {
			if (exists == "YES"){
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(name).exists(), membertype + " " + name + " is a member of user group " + groupName);
			}
			else {
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(name).exists(), membertype + " " + name + " is NOT member of user group " + groupName);
			}
		}
		sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify member of
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param memberoftype - usergroups, netgroups, roles, hbacrules or sudorules
	 * @param names - array of group or rule names to verify
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members of the enroll type - YES if they should be
	 */
	public static void verifyMemberOf(SahiTasks sahiTasks, String groupName, String memberoftype, String [] grprulenames, String type, String exists) {
		sahiTasks.link(groupName).click();
		if (memberoftype == "usergroups"){
			sahiTasks.link("memberof_hostgroup").click();
		}
		if (memberoftype == "netgroups"){
			sahiTasks.link("memberof_netgroup").click();
		}
		if (memberoftype == "roles"){
			sahiTasks.link("memberof_rule").click();
		}
		if (memberoftype == "hbacrules"){
			sahiTasks.link("memberof_hbacrule").click();
		}
		if (memberoftype == "sudorules"){
			sahiTasks.link("memberof_sudorule").click();
		}
		sahiTasks.radio(type).click();
		
		for (String grprulename : grprulenames) {
			if (exists == "YES"){
				com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(grprulename).exists(), "User group " + groupName + " is a memberof " + memberoftype + ": " + grprulename);
			}
			else {
				com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(grprulename).exists(), "User group " + groupName + " is NOT a memberof " + memberoftype + ": " + grprulename);
			}
		}
		sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
	}
	
	/*
	 * verify member of
	 * @param sahiTasks
	 * @param groupname - name of host group
	 * @param memberoftype - usergroups, netgroups, roles, hbacrules or sudorules
	 * @param name - name of rule or group that user group to verify member of
	 * @param type - direct or indirect
	 * @param exists - whether or not they should be members of the enroll type - YES if they should be
	 */
	public static void verifyMemberOf(SahiTasks sahiTasks, String groupName, String memberoftype, String grprulename,
			String type, String exists, boolean onPage) {
		if (!onPage) 
			sahiTasks.link(groupName).click();
		if (memberoftype == "usergroups"){
			sahiTasks.link("memberof_hostgroup").click();
		}
		if (memberoftype == "netgroups"){
			sahiTasks.link("memberof_netgroup").click();
		}
		if (memberoftype == "roles"){
			sahiTasks.link("memberof_rule").click();
		}
		if (memberoftype == "hbacrules"){
			sahiTasks.link("memberof_hbacrule").click();
		}
		if (memberoftype == "sudorules"){
			sahiTasks.link("memberof_sudorule").click();
		}
		sahiTasks.radio(type).click();
		
		if (exists == "YES"){
			com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.link(grprulename).exists(), "User group " + groupName + " is a memberof " + memberoftype + ": " + grprulename);
		}
		else {
			com.redhat.qe.auto.testng.Assert.assertFalse(sahiTasks.link(grprulename).exists(), "User group " + groupName + " is NOT a memberof " + memberoftype + ": " + grprulename);
		}

		if (!onPage) 
			sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
		
	}
    
    /*
     * Create a Group, the purpose of this is to provide a public interface to other test suite to create a new group.
     * @param sahiTasks 
     * @param groupName - user group name
     * @param groupDescription - group description
     */
    public static void createGroupService(SahiTasks sahiTasks, String groupName, String groupDescription, String originalURL) {
	// negative to group creation page, but there might be a bug here	
    	//TODO: yi: navigate in tests before starting task
    	//sahiTasks.navigateTo(GroupTests.groupPage, true);
        sahiTasks.span("Add").click();
        sahiTasks.textbox("cn").setValue(groupName);
        sahiTasks.textbox("description").setValue(groupDescription);
        sahiTasks.button("Add").click();

	// go back to caller url
    	sahiTasks.navigateTo(originalURL, true);

    }//createGroupService


    /*
     * Test for: Simple add Group
     * @param sahiTasks 
     * @param groupName - user group name
     * @param groupDescription - group description
     */
    public static void simpleAddGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {

        //sahiTasks.link("User Groups").click();
        sahiTasks.span("Add").click();
        sahiTasks.textbox("cn").setValue("auto_sahi_java_001");
        sahiTasks.textbox("description").setValue("auto sahi 001 in java");
        sahiTasks.button("Add").click();
        sahiTasks.checkbox("auto_sahi_java_001").click();
        sahiTasks.link("Delete").click();
        sahiTasks.button("Delete").click();
        
    }// simpleAddGroup


    /*
     * Test for: add and add another Group
     * @param sahiTasks 
     * @param groupName - user group name
     * @param groupDescription - group description
     */
    public static void addAndAddAnotherGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {
            // over all, this test case will covering the following scenario:
            // 1. ensure "add and add another group" works
            // 2. ensure "add and add another group" can be canceled 
            // 3. ensure deletion of one group works
            // 4. ensure deletion can be canceled
            // 5. ensure deletion of multiple groups works
            // the reasons to contain "deletion" test step are: 
            //        (1) ensure the clean data exit, make sure no left over data that cause other test suite to fail or fake success 
            //        (2) ensure the success of  adding groups
        
            // this test contains the following logic/page flow path:
            // add user group -> fill the form to create a new user group -> click "add and add another" to retain the same dialog and continue add 
            // --> after add total 3 new user groups, click "cancel" to go back to main user group page
            // --> then start to delete the newly created user groups: click the first one and delete it : sahi_auto_addandaddanother_001
            // --> select the second one, but click "cancel" to NOT delete it, in UI, the second one is still in "selected" status (sahi_auto_addandaddanother_002)
            // --> then select the third one, at this point, there will be total 2 newly created user groups being selected"
            // --> click "delete" to delete the remaining two newly created user groups (sahi_auto_addandaddanother_002, sahi_auto_addandaddanother_003)
        
            // get into add user group page
            //sahiTasks.link("User Groups").click();
            
            // enter simple add group dialog, and add the first user group: sahi_auto_addandaddanother_001
            sahiTasks.link("Add").click();
            sahiTasks.textbox("cn").setValue("sahi_auto_addandaddanother_001");
            sahiTasks.textbox("description").setValue("sahi auto, add and add another 001");
            
            // click Add and Add Another to create a new group without leave the current dialog , this the main purpose of this test case
            sahiTasks.button("Add and Add Another").click();    
            sahiTasks.textbox("cn").setValue("sahi_auto_addandaddanother_002");
            sahiTasks.textbox("description").setValue("sahi auto, add and add another 002");
            sahiTasks.checkbox("posix").click();
            
            // add another user group
            sahiTasks.button("Add and Add Another").click();
            sahiTasks.textbox("cn").setValue("sahi_auto_addandaddanother_003");
            sahiTasks.textbox("description").setValue("sahi auto, add and add another 003");
            sahiTasks.checkbox("posix").click();
            
            // finally cancel to go back to main user group page
            sahiTasks.button("Add and Add Another").click();
            sahiTasks.button("Cancel").click();
                
            // deletion test starts here: 
            //                    test 1: single deletion test
            sahiTasks.checkbox("sahi_auto_addandaddanother_001").click();
            sahiTasks.link("Delete").near(sahiTasks.link("Add")).click();
            sahiTasks.button("Delete").click();
            
            //                    test 2: single deletion canceling test    
            sahiTasks.checkbox("sahi_auto_addandaddanother_002").click();
            sahiTasks.link("Delete").click();
            sahiTasks.button("Cancel").click();

            //                    test 3: multiple  deletion test
            sahiTasks.checkbox("sahi_auto_addandaddanother_003").click();
            sahiTasks.link("Delete").click();
            sahiTasks.button("Delete").click(); 

    }// addAndAddAnotherGroup


    /*
     * Test for: add and edit Group
     * @param sahiTasks 
     * @param groupName - user group name
     * @param groupDescription - group description
     */
    public static void addAndEditGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {
        // overall , this test will cover the following scenario:
        //    1. create a new default (posix) user group and immediately move to editing page, make one change and go back
        //    2. create a new non-posix user group and immediately move to editing page, make one change and go back
        //    3. create a new default (posix) user group and immediately move to editing page, make change, undo the change and go back
        //    4. delete above 3 newly created group to ensure the success of creation
        // the reasons to contain "deletion" test step are: 
        //        (1) ensure the clean data exit, make sure no left over data that cause other test suite to fail or fake success 
        //        (2) ensure the success of adding groups
        
        // Navigate to create user group page
        //sahiTasks.link("User Groups").click();
        
        // add first group
        //sahiTasks.link("Add").click();
        sahiTasks.link("Add").click();

        sahiTasks.textbox("cn").near(sahiTasks.label("Group name:")).setValue("sahi_auto_add_and_edit_001");
        sahiTasks.textbox("description").near(sahiTasks.label("Description:")).setValue("sahi auto, add and edit 001");
        
        // confirm first group adding and move to edit page for this group
        sahiTasks.button("Add and Edit").click();
        
        // do some minimum editing to ensure page navigation is what we are intend to do
        sahiTasks.link("Settings").click();
        sahiTasks.textbox("description").setValue("sahi auto, add and edit 001, modified");
        sahiTasks.link("Update").click();
        
        // go back to use group list page
        sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
        
        // add another user group, this time, it would be non-posix group
        sahiTasks.link("Add").click();
        sahiTasks.textbox("cn").near(sahiTasks.label("Group name:")).setValue("sahi_auto_add_and_edit_002");
        sahiTasks.textbox("description").near(sahiTasks.label("Description:")).setValue("sahi auto, add and edit 002");
        sahiTasks.checkbox("posix").click();
        
        // confirm second group adding and go to editing page
        sahiTasks.button("Add and Edit").click();
        
        // do some minimum editing to ensure page navigation is what we are intend to do
        sahiTasks.link("Settings").click();
        sahiTasks.textbox("description").setValue("sahi auto, add and edit 002, modified");
        sahiTasks.link("Update").click();
        
        // go back to user group list page
        sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
        
        // add third user group
        sahiTasks.link("Add").click();
        sahiTasks.textbox("cn").near(sahiTasks.label("Group name:")).setValue("sahi_auto_add_and_edit_003");
        sahiTasks.textbox("description").near(sahiTasks.label("Description:")).setValue("sahi auto, add and edit 003");
        
        // confirm add and move to edit page
        sahiTasks.button("Add and Edit").click();
        
        // make change to description, and reset the change
        sahiTasks.link("Settings").click();
        sahiTasks.textbox("description").setValue("sahi, auto, 003, modified");
        sahiTasks.link("Reset").click();
        
        // go back to user group list page
        sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
         
        // select the newly created 3 user groups and delete all of them -- to confirm the success of previous creation
        sahiTasks.checkbox("sahi_auto_add_and_edit_001").click();
        sahiTasks.checkbox("sahi_auto_add_and_edit_002").click();
        sahiTasks.checkbox("sahi_auto_add_and_edit_003").click();
        sahiTasks.link("Delete").click();
        sahiTasks.button("Delete").click();

    }// addAndEditGroup


    /*
     * Test for: add and edit Group
     * @param sahiTasks 
     * @param groupName - user group name
     * @param groupDescription - group description
     */
    public static void editGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {
        // overall , this test will cover the following scenario:
        //    1. enroll and delete user member from user group
        //    2. enroll and delete user group member from user group
        //    3. change settings for user group: 
        //        (1) description settings, (2) GID settings
        //        each above settings will test in 3 sub scenario: 
    	//				(1) update modification, (2) undo modification, (3) reset modification
        //    4. enroll and delete user group member_of relation
        //    5. enroll and delete roles member_of relation
        // the reasons to contain "deletion" test step are: 
        //        (1) ensure the clean data exit, make sure no left over data that cause other test suite to fail or fake success 
        //        (2) ensure the success of adding groups
        
    	// get into user group list
    	//sahiTasks.link("User Groups").click();
    	try{
    	// create a default group for testing
    	sahiTasks.link("Add").click();
    	sahiTasks.textbox("cn").setValue("sahi_editgroup_001_default");
    	sahiTasks.textbox("description").setValue("sahi auto, use all default setting to create add group");
    	sahiTasks.button("Add").click();

    	// start editing test
    	sahiTasks.link("sahi_editgroup_001_default").click();
    	
    	// add user member, then delete it
    	sahiTasks.link("Enroll").click();
    	sahiTasks.checkbox("admin").click();
    	sahiTasks.link(">>").click();
    	sahiTasks.button("Enroll").click();
    	sahiTasks.checkbox("admin").click();
    	sahiTasks.link("Delete").near(sahiTasks.link("Enroll")).click();
    	sahiTasks.button("Delete").click();

    	// add group member, then delete it
    	sahiTasks.link("member_group").click(); 
    	sahiTasks.span("Enroll").click();
    	sahiTasks.checkbox("ipausers").click(); 
    	sahiTasks.span(">>").click();
    	sahiTasks.button("Enroll").click();
    	sahiTasks.checkbox("ipausers").click();
    	sahiTasks.span("Delete").click();
    	sahiTasks.button("Delete").click();
    	
    	// change setting of group
    	sahiTasks.link("details").click();
    	//		change group description and GID, apply changes with "Update"
    	sahiTasks.textbox("description").setValue("sahi auto, use all default setting to create add group, modified");
    	sahiTasks.textbox("gidnumber").setValue("100000001");
    	sahiTasks.link("Update").click();
    	//		change group settings, revoke changes via "undo"
    	sahiTasks.textbox("description").setValue("sahi auto, use all default setting to create add group, modified, modified, use undo");
    	sahiTasks.span("undo").click();
    	sahiTasks.textbox("gidnumber").setValue("100000011");
    	sahiTasks.span("undo").click();
    	//		change group settings, revoke changes via "reset"
    	sahiTasks.textbox("description").setValue("sahi auto, use all default setting to create add group, modified, use reset");
    	sahiTasks.link("Reset").click();
    	sahiTasks.textbox("gidnumber").setValue("100000021");
    	sahiTasks.link("Reset").click();
    	
    	// 		member_of: add current group as member of another group, then remove this relationship
    	sahiTasks.link("memberof_group").click();
    	sahiTasks.link("Enroll").click();
    	//sahiTasks.link("Enroll").click();
    	//sahiTasks.checkbox("select[11]").click();
    	sahiTasks.checkbox("ipausers").click();
    	sahiTasks.span(">>").click();
    	sahiTasks.button("Enroll").click();
    	sahiTasks.checkbox("ipausers").click();
    	//sahiTasks.span("Delete").click();
    	//sahiTasks.button("Delete").click();
    	
    	//		member_of: add current group as member of role group, then remove this relationship
    	sahiTasks.link("memberof_role").click();
    	sahiTasks.link("Enroll").click();
    	sahiTasks.checkbox("helpdesk").click();
    	sahiTasks.span(">>").click();
    	sahiTasks.button("Enroll").click();
    	sahiTasks.checkbox("helpdesk").click();
    	sahiTasks.span("Delete").click();
    	sahiTasks.button("Delete").click();

    	//go back to user group list, remove this test group, (data clean up)
    	//sahiTasks.link("User Groups[13]").click();
        //sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();
    	sahiTasks.link("User Groups").in(sahiTasks.span("back-link")).click();
    	sahiTasks.checkbox("sahi_editgroup_001_default").click();
    	sahiTasks.span("Delete").click();
    	sahiTasks.button("Delete").click(); 
    	}catch (net.sf.sahi.client.ExecutionException e){
    		log.config("exception throw, check below");
    		e.printStackTrace();
    	}
    }// editGroup
    
    /*
     * Test for: add and edit Group
     * @param sahiTasks 
     * @param groupName - user group name
     * @param groupDescription - group description
     */
    public static void membershipGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {
        // overall , this test will cover the following scenario:
        //    1. enroll and delete user member from user group
        //    2. enroll and delete user group member from user group
        //    3. change settings for user group: 
        //        (1) description settings, (2) GID settings
        //        each above settings will test in 3 sub scenario: 
    	//				(1) update modification, (2) undo modification, (3) reset modification
        //    4. enroll and delete user group member_of relation
        //    5. enroll and delete roles member_of relation
        // the reasons to contain "deletion" test step are: 
        //        (1) ensure the clean data exit, make sure no left over data that cause other test suite to fail or fake success 
        //        (2) ensure the success of adding groups
    	
    	// create total 4 users for membership test
    	sahiTasks.navigateTo(System.getProperty("ipa.server.url")+"#identity=user&navigation=identity", true); 
    	sahiTasks.link("Add").click();
    	sahiTasks.textbox("givenname").setValue("test");
    	sahiTasks.textbox("sn").setValue("sahi0011");
    	sahiTasks.button("Add").click();
    	sahiTasks.link("Add").click();
    	sahiTasks.textbox("givenname").setValue("test");
    	sahiTasks.textbox("sn").setValue("sahi0012");
    	sahiTasks.button("Add").click();
    	sahiTasks.link("Add").click();
    	sahiTasks.textbox("givenname").setValue("test");
    	sahiTasks.textbox("sn").setValue("sahi0021");
    	sahiTasks.button("Add").click();
    	sahiTasks.link("Add").click();
    	sahiTasks.textbox("givenname").setValue("test");
    	sahiTasks.textbox("sn").setValue("sahi0022");
    	sahiTasks.button("Add").click();
    	
    	// go to group page to create new 2 user groups
    	sahiTasks.navigateTo(System.getProperty("ipa.server.url")+GroupTests.groupPage, true);
    	sahiTasks.link("User Groups").click();
    	sahiTasks.link("Add").click();
    	sahiTasks.textbox("cn").setValue("sahigrp_0100");
    	sahiTasks.textbox("description").setValue("sahi group, level 1, 0100");
    	sahiTasks.button("Add").click();
    	sahiTasks.link("Add").click();
    	sahiTasks.textbox("cn").setValue("sahigrp_0200");
    	sahiTasks.textbox("description").setValue("sahi group, level 2, 0200");
    	sahiTasks.button("Add").click();
    	
    	// enroll user tsahi0011 tsahi0012 under group: sahigrp_0100
    	sahiTasks.link("sahigrp_0100").click();
    	sahiTasks.link("Enroll").click();
    	sahiTasks.checkbox("tsahi0011").click();
    	sahiTasks.checkbox("tsahi0012").click();
    	sahiTasks.link(">>").click();
    	sahiTasks.button("Enroll").click();
    	
    	// go back to user group list page
    	sahiTasks.link("User Groups").in(sahiTasks.div("content")).click(); 

	// enroll user tsahi0021 and tsahi0022 under group: sahigrp_0200
    	sahiTasks.link("sahigrp_0200").click();
    	sahiTasks.link("Enroll").click();
    	sahiTasks.checkbox("tsahi0021").click();
    	sahiTasks.checkbox("tsahi0022").click();
    	sahiTasks.link(">>").click();
    	sahiTasks.button("Enroll").click();
    	
    	// go back to user group list page
    	sahiTasks.link("User Groups").in(sahiTasks.div("content")).click(); 

	// enroll group sahigrp_0200 as member of sahigrp_0100 
    	sahiTasks.link("sahigrp_0100").click();
    	sahiTasks.link("member_group").click();
    	sahiTasks.link("Enroll").click();
    	sahiTasks.checkbox("sahigrp_0200").click();
    	sahiTasks.link(">>").click();
    	sahiTasks.button("Enroll").click(); 

	// ehcdk the direct member of group sahigrp_0100, there should be only 2
    	sahiTasks.link("member_user").click();
    	//sahiTasks.link("sahigrp_0100").click();
    	sahiTasks.radio("direct").click(); 
    	
	com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.checkbox("tsahi0011").exists(), "Verifying direct member: " + "tsahi0011");
	com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.checkbox("tsahi0012").exists(), "Verifying direct member: " + "tsahi0012");

	
    	sahiTasks.radio("indirect").click(); 
	com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.checkbox("tsahi0021").exists(), "Verifying indirect member: " + "tsahi0021");
	com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.checkbox("tsahi0022").exists(), "Verifying indirect member: " + "tsahi0022");

	// data clean up
	// remove groups
        sahiTasks.link("User Groups").in(sahiTasks.div("content")).click();

    	sahiTasks.checkbox("sahigrp_0100").click();
    	sahiTasks.checkbox("sahigrp_0200").click();
    	sahiTasks.link("Delete").click();
    	sahiTasks.button("Delete").click();

	// remove users
    	sahiTasks.navigateTo(System.getProperty("ipa.server.url")+"#identity=user&navigation=identity", true); 

    	sahiTasks.checkbox("tsahi0011").click();
    	sahiTasks.checkbox("tsahi0012").click();
    	sahiTasks.checkbox("tsahi0021").click();
    	sahiTasks.checkbox("tsahi0022").click();
    	sahiTasks.link("Delete").click();
    	sahiTasks.button("Delete").click();
    	
    }// membershipGroup
    
    /*
     * Create a Many Groups and then delete them, covers all essential function under Group operations
     * @param sahiTasks 
     */
    public static void smokeTest(SahiTasks sahiTasks) {

            //sahiTasks.link("User Groups").click();
            sahiTasks.link("Add").click();
            sahiTasks.textbox("cn").setValue("sahi_auto_001");
            sahiTasks.textbox("description").setValue("automatic group by sahi 001");
            sahiTasks.button("Add").click();
            sahiTasks.link("Add").click();
            sahiTasks.textbox("cn").setValue("sahi_auto_add_and_add_another_001");
            sahiTasks.textbox("description").setValue("add and add another 001");
            sahiTasks.button("Add and Add Another").click();
            sahiTasks.textbox("cn").setValue("sahi_atuo_add_and_add_another_002");
            sahiTasks.textbox("description").setValue("sahi automatic, add and add another 002");
            sahiTasks.button("Add and Add Another").click();
            sahiTasks.textbox("cn").setValue("sahi-auto-add_and_edit");
            sahiTasks.textbox("description").setValue("sahi automatic add and edit");
            sahiTasks.button("Add and Edit").click();
            sahiTasks.link("User Groups[2]").click();
            sahiTasks.link("Settings[1]").click();
            sahiTasks.textbox("description").setValue("sahi automatic add and edit, modified");
            sahiTasks.link("Update").click();
            sahiTasks.link("User Groups[7]").click();
            sahiTasks.link("Add").click();
            sahiTasks.textbox("cn").near(sahiTasks.label("Group name:")).setValue("sahi_auto_add_and_cancel");
            sahiTasks.textbox("description").near(sahiTasks.label("Description:")).setValue("sahi auto, add and cancel");
            sahiTasks.button("Cancel").click();
            sahiTasks.checkbox("select[6]").click();
            sahiTasks.checkbox("select[7]").click();
            sahiTasks.checkbox("select[8]").click();
            sahiTasks.checkbox("select[9]").click();
            sahiTasks.link("Delete[1]").click();
            //sahiTasks.button("Delete").click(); 
    }// smokeTest
    
}//class Group Tasks

