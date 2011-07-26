package com.redhat.qe.ipa.sahi.tasks;

import com.redhat.qe.ipa.sahi.tasks.SahiTasks; 


public class GroupTasks {
        
    /*
     * Add a Group, the purpose of this is to provide a public interface to other test suite to create a new group.
     * @param sahiTasks 
     * @param groupName - user group name
     * @param groupDescription - group description
     * @param posix - YES or NO
     * @param button - Add or Cancel
     */
    public static void addGroup(SahiTasks sahiTasks, String groupname, String description, String posix, String gidnumber, String button) {
        sahiTasks.span("Add[1]").click();
        sahiTasks.textbox("cn").setValue(groupname);
        sahiTasks.textbox("description").setValue(description);
        
        if(posix == "NO"){
        	sahiTasks.checkbox("posix").click();
        }
        else {
        	com.redhat.qe.auto.testng.Assert.assertTrue(sahiTasks.checkbox("posix").checked(), "Group will be a posix group.");
        }
        
        sahiTasks.textbox("gidnumber").setValue(gidnumber);
        sahiTasks.button(button).click();
        
    }
    
    /*
     * Delete a Group, the purpose of this is to provide a public interface to other test suite to create a new group.
     * @param sahiTasks 
     * @param groupName - user group name
     * @param button - Delete or Cancel
     */
    public static void deleteGroup(SahiTasks sahiTasks, String groupname, String button) {
        sahiTasks.checkbox(groupname).click();
        sahiTasks.span("Delete[1]").click();
        sahiTasks.button(button).click();
        
        if(button == "Cancel"){
        	//uncheck the group name box
        	sahiTasks.checkbox(groupname).click();
        }
    }
    
}

