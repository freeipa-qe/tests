package com.redhat.qe.ipa.sahi.tasks;

import java.util.logging.Logger;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 


public class GroupTasks {
    private static Logger log = Logger.getLogger(GroupTasks.class.getName());
        
    /*
     * Create a Group, the purpose of this is to provide a public interface to other test suite to create a new group.
     * @param sahiTasks 
     * @param groupName - user group name
     * @param groupDescription - group description
     */
    public static void createGroupService(SahiTasks sahiTasks, String groupName, String groupDescription) {
        // FIXME: i need a way to navigate to this create group page, then, after create a new group success, i need redirect the web page to where it starts
        sahiTasks.link("User Groups").click();
        sahiTasks.span("ui-icon add-icon[1]").click();
        sahiTasks.textbox("cn").setValue(groupName);
        sahiTasks.textbox("description").setValue(groupDescription);
        sahiTasks.button("Add").click();
        
    }//createGroupService


    /*
     * Test for: Simple add Group
     * @param sahiTasks 
     * @param groupName - user group name
     * @param groupDescription - group description
     */
    public static void simpleAddGroup(SahiTasks sahiTasks, String groupName, String groupDescription) {

        sahiTasks.link("User Groups").click();
        sahiTasks.span("ui-icon add-icon[1]").click();
        sahiTasks.textbox("cn").setValue("auto_sahi_java_001");
        sahiTasks.textbox("description").setValue("auto sahi 001 in java");
        sahiTasks.button("Add").click();
        sahiTasks.checkbox("select[4]").click();
        sahiTasks.link("Delete[1]").click();
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
            sahiTasks.link("User Groups").click();
            
            // enter simple add group dialog, and add the first user group: sahi_auto_addandaddanother_001
            sahiTasks.link("Add[1]").click();
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
            sahiTasks.checkbox("select[6]").click();
            sahiTasks.link("Delete[1]").click();
            sahiTasks.button("Delete").click();
            
            //                    test 2: single deletion canceling test    
            sahiTasks.checkbox("select[6]").click();
            sahiTasks.link("Delete[1]").click();
            sahiTasks.button("Cancel").click();

            //                    test 3: multiple  deletion test
            sahiTasks.checkbox("select[7]").click();
            sahiTasks.link("Delete[1]").click();
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
        sahiTasks.link("User Groups").click();
        
        // add first group
        sahiTasks.link("Add[1]").click();
        sahiTasks.textbox("cn").setValue("sahi_auto_add_and_edit_001");
        sahiTasks.textbox("description").setValue("sahi auto, add and edit 001");
        
        // confirm first group adding and move to edit page for this group
        sahiTasks.button("Add and Edit").click();
        
        // do some minimum editing to ensure page navigation is what we are intend to do
        sahiTasks.link("Settings").click();
        sahiTasks.textbox("description").setValue("sahi auto, add and edit 001, modified");
        sahiTasks.link("Update").click();
        
        // go back to use group list page
        sahiTasks.link("User Groups[4]").click();
        
        // add another user group, this time, it would be non-posix group
        sahiTasks.link("Add[1]").click();
        sahiTasks.textbox("cn[1]").setValue("sahi_auto_add_and_edit_002");
        sahiTasks.textbox("description[1]").setValue("sahi auto, add and edit 002");
        sahiTasks.checkbox("posix").click();
        
        // confirm second group adding and go to editing page
        sahiTasks.button("Add and Edit").click();
        
        // do some minimum editing to ensure page navigation is what we are intend to do
        sahiTasks.link("Settings").click();
        sahiTasks.textbox("description").setValue("sahi auto, add and edit 002, modified");
        sahiTasks.link("Update").click();
        
        // go back to user group list page
        sahiTasks.link("User Groups[4]").click();
        
        // add third user group
        sahiTasks.link("Add[1]").click();
        sahiTasks.textbox("cn[1]").setValue("sahi_auto_add_and_edit_003");
        sahiTasks.textbox("description[1]").setValue("sahi auto, add and edit 003");
        
        // confirm add and move to edit page
        sahiTasks.button("Add and Edit").click();
        
        // make change to description, and reset the change
        sahiTasks.link("Settings").click();
        sahiTasks.textbox("description").setValue("sahi, auto, 003, modified");
        sahiTasks.link("Reset").click();
        
        // go back to user group list page
        sahiTasks.link("User Groups[4]").click();
        
        // select the newly created 3 user groups and delete all of them -- to confirm the success of previous creation
        sahiTasks.checkbox("select[6]").click();
        sahiTasks.checkbox("select[7]").click();
        sahiTasks.checkbox("select[8]").click();
        sahiTasks.link("Delete[1]").click();
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
    	sahiTasks.link("User Groups").click();
    	
    	// create a default group for testing
    	sahiTasks.link("Add[1]").click();
    	sahiTasks.textbox("cn").setValue("sahi_editgroup_001_default");
    	sahiTasks.textbox("description").setValue("sahi auto, use all default setting to create add group");
    	sahiTasks.button("Add").click();

    	// start editing test
    	sahiTasks.link("sahi_editgroup_001_default").click();
    	
    	// add user member, then delete it
    	sahiTasks.link("Enroll").click();
    	sahiTasks.checkbox("select[9]").click();
    	sahiTasks.link(">>").click();
    	sahiTasks.button("Enroll").click();
    	sahiTasks.checkbox("select[8]").click();
    	sahiTasks.link("Delete[2]").click();
    	sahiTasks.button("Delete").click();
    	
    	// add group member, then delete it
    	sahiTasks.link("User Groups[2]").click();
    	sahiTasks.link("Enroll[1]").click();
    	sahiTasks.checkbox("select[10]").click();
    	sahiTasks.link(">>").click();
    	sahiTasks.button("Enroll").click();
    	sahiTasks.checkbox("select[9]").click();
    	sahiTasks.link("Delete[3]").click();
    	sahiTasks.button("Delete").click();
    	
    	// change setting of group
    	sahiTasks.link("Settings[1]").click();
    	//		change group description and GID, apply changes with "Update"
    	sahiTasks.textbox("description").setValue("sahi auto, use all default setting to create add group, modified");
    	sahiTasks.textbox("gidnumber").setValue("100000001");
    	sahiTasks.link("Update").click();
    	//		change group settings, revoke changes via "undo"
    	sahiTasks.textbox("description").setValue("sahi auto, use all default setting to create add group, modified, modified, use undo");
    	sahiTasks.span("undo[1]").click();
    	sahiTasks.textbox("gidnumber").setValue("100000011");
    	sahiTasks.span("undo[2]").click();
    	//		change group settings, revoke changes via "reset"
    	sahiTasks.textbox("description").setValue("sahi auto, use all default setting to create add group, modified, use reset");
    	sahiTasks.link("Reset").click();
    	sahiTasks.textbox("gidnumber").setValue("100000021");
    	sahiTasks.link("Reset").click();
    	
    	// 		member_of: add current group as member of another group, then remove this relationship
    	sahiTasks.link("User Groups[9]").click();
    	sahiTasks.link("Enroll[2]").click();
    	sahiTasks.checkbox("select[11]").click();
    	sahiTasks.link(">>").click();
    	sahiTasks.button("Enroll").click();
    	sahiTasks.checkbox("select[10]").click();
    	sahiTasks.link("Delete[4]").click();
    	sahiTasks.button("Delete").click();
    	
    	//		member_of: add current group as member of role group, then remove this relationship
    	sahiTasks.link("Roles[4]").click();
    	sahiTasks.link("Enroll[3]").click();
    	sahiTasks.checkbox("select[14]").click();
    	sahiTasks.link(">>").click();
    	sahiTasks.button("Enroll").click();
    	sahiTasks.checkbox("select[11]").click();
    	sahiTasks.link("Delete[5]").click();
    	sahiTasks.button("Delete").click();

    	//go back to user group list, remove this test group, (data clean up)
    	sahiTasks.link("User Groups[13]").click();
    	sahiTasks.checkbox("select[6]").click();
    	sahiTasks.link("Delete[1]").click();
    	sahiTasks.button("Delete").click(); 
    	
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
    	sahiTasks.link("User Groups").click();
    	sahiTasks.link("Add[1]").click();
    	sahiTasks.textbox("cn").setValue("sahigrp_0100");
    	sahiTasks.textbox("description").setValue("sahi group, level 1, 0100");
    	sahiTasks.button("Add").click();
    	sahiTasks.link("Add[1]").click();
    	sahiTasks.textbox("cn").setValue("sahigrp_0200");
    	sahiTasks.textbox("description").setValue("sahi group, level 2, 0200");
    	sahiTasks.button("Add").click();
    	sahiTasks.link("sahigrp_0100").click();
    	sahiTasks.link("Enroll").click();
    	sahiTasks.checkbox("select[15]").click();
    	sahiTasks.checkbox("select[16]").click();
    	sahiTasks.link(">>").click();
    	sahiTasks.button("Enroll").click();
    	sahiTasks.link("User Groups[1]").click();
    	sahiTasks.link("sahigrp_0200").click();
    	sahiTasks.link("Enroll").click();
    	sahiTasks.checkbox("select[17]").click();
    	sahiTasks.checkbox("select[18]").click();
    	sahiTasks.link(">>").click();
    	sahiTasks.button("Enroll").click();
    	sahiTasks.link("User Groups[1]").click();
    	sahiTasks.link("sahigrp_0100").click();
    	sahiTasks.link("User Groups[2]").click();
    	sahiTasks.link("Enroll[1]").click();
    	sahiTasks.checkbox("select[20]").click();
    	sahiTasks.link(">>").click();
    	sahiTasks.button("Enroll").click();
    	sahiTasks.heading3("user group: sahigrp_0100[1]").click();
    	sahiTasks.link("User Groups[4]").click();
    	sahiTasks.link("sahigrp_0100").click();
    	sahiTasks.radio("type[1]").click(); 
    	
    	sahiTasks.link("User Groups (1)").click();
    	sahiTasks.link("User Groups[3]").click();
    	sahiTasks.checkbox("select[11]").click();
    	sahiTasks.link("Delete[1]").click();
    	sahiTasks.button("Delete").click();
    	sahiTasks.link("sahigrp_0100").click();
    	sahiTasks.radio("type").click();
    	sahiTasks.table("search-table content-table scrollable[3]").mouseOver();

    	sahiTasks.link("User Groups[2]").click();
    	sahiTasks.link("User Groups[4]").click();
    	sahiTasks.checkbox("select[10]").click();
    	sahiTasks.link("Delete[1]").click();
    	sahiTasks.button("Delete").click();
    	
    	sahiTasks.checkbox("select[2]").click();
    	sahiTasks.checkbox("select[3]").click();
    	sahiTasks.checkbox("select[4]").click();
    	sahiTasks.checkbox("select[5]").click();
    	sahiTasks.link("Delete").click();
    	sahiTasks.button("Delete").click();
    	
    }// editGroup
    /*
     * Create a Many Groups and then delete them, covers all essential function under Group operations
     * @param sahiTasks 
     */
    public static void smokeTest(SahiTasks sahiTasks) {

            sahiTasks.link("User Groups").click();
            sahiTasks.link("Add[1]").click();
            sahiTasks.textbox("cn").setValue("sahi_auto_001");
            sahiTasks.textbox("description").setValue("automatic group by sahi 001");
            sahiTasks.button("Add").click();
            sahiTasks.link("Add[1]").click();
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
            sahiTasks.link("Add[1]").click();
            sahiTasks.textbox("cn[1]").setValue("sahi_auto_add_and_cancel");
            sahiTasks.textbox("description[1]").setValue("add then cancle, it should not exist");
            sahiTasks.button("Cancel").click();
            sahiTasks.checkbox("select[6]").click();
            sahiTasks.checkbox("select[7]").click();
            sahiTasks.checkbox("select[8]").click();
            sahiTasks.checkbox("select[9]").click();
            sahiTasks.link("Delete[1]").click();
            //sahiTasks.button("Delete").click(); 
    }// smokeTest
    
}//class Group Tasks

