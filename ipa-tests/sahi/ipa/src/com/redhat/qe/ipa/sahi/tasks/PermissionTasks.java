package com.redhat.qe.ipa.sahi.tasks;


import java.util.logging.Logger;

import com.redhat.qe.auto.testng.Assert;
import com.redhat.qe.ipa.sahi.tasks.SahiTasks;

public class PermissionTasks {
	private static Logger log = Logger.getLogger(PermissionTasks.class.getName());

	public static void createPermissionWithType(SahiTasks sahiTasks, String cn, String[] rights, String type, String[] attributes, String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		for (String right : rights) {
			if (!right.isEmpty()) {
				sahiTasks.checkbox(right).click();
			}
		}
		sahiTasks.select("target").choose("Type");
		sahiTasks.select("type").choose(type);
		for (String attribute : attributes) {
			if (!attribute.isEmpty()) {
			   sahiTasks.checkbox(attribute).click();
			}
		}
		sahiTasks.button(buttonToClick).click();
	}
	
	public static void createInvalidPermissionWithType(SahiTasks sahiTasks, String cn, String[] rights, String type, String[] attributes, String expectedError) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		if (cn.contains("^"))
			Assert.assertTrue(sahiTasks.span(expectedError).near(sahiTasks.textbox("cn")).exists(), "Verified expected error for name " + cn);
		else{
			for (String right : rights) {
				if (!right.isEmpty()) {
					sahiTasks.checkbox(right).click();
				}
			}
			sahiTasks.select("target").choose("Type");
			sahiTasks.select("type").choose(type);
			for (String attribute : attributes) {
				if (!attribute.isEmpty()) {
				   sahiTasks.checkbox(attribute).click();
				}
			}
			sahiTasks.button("Add").click();
			
			Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error when adding invalid rule " + cn);
			sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
			sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
		}		
	}
	
	
	public static void createPermissionWithFilter(SahiTasks sahiTasks, String cn, String[] rights, String filter, String[] attributes, String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		for (String right : rights) {
			if (!right.isEmpty()) {
				sahiTasks.checkbox(right).click();
			}
		}
		sahiTasks.select("target").choose("Filter");
		sahiTasks.textbox("filter[1]").setValue(filter);
		int i=0;
		for (String attribute : attributes) {
			if (!attribute.isEmpty()) {
				sahiTasks.link("Add[1]").click();
				sahiTasks.textbox("attrs_multi-" + i).setValue(attribute);
				i++;
			}
		}
		sahiTasks.button(buttonToClick).click();
	}
	
	
	/*
	 * create permission with subtree
	 */
	public static void createPermissionWithSubtree(SahiTasks sahiTasks, String cn, String[] rights, String subtree, String[] attributes, String memberOfGroup, String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		for (String right : rights) {
			if (!right.isEmpty()) {
				sahiTasks.checkbox(right).click();
			}
		}
		sahiTasks.select("target").choose("Subtree");
		sahiTasks.span("icon combobox-icon").click();
		sahiTasks.select("list").choose(memberOfGroup);
		sahiTasks.textarea("subtree").setValue(subtree);
		
		int i=0;
		for (String attribute : attributes) {
			if (!attribute.isEmpty()) {
				sahiTasks.link("Add[1]").click();
				sahiTasks.textbox("attrs_multi-" + i).setValue(attribute);
				i++;
			}
		}
		
		sahiTasks.button(buttonToClick).click();
	}


	public static void createPermissionWithTargetgroup(SahiTasks sahiTasks, String cn, String[] rights, String[] attributes, String memberOfGroup, String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		for (String right : rights) {
			if (!right.isEmpty()) {
				sahiTasks.checkbox(right).click();
			}
		}
		sahiTasks.select("target").choose("Target group");
		sahiTasks.span("icon combobox-icon").click();
		sahiTasks.select("list").choose(memberOfGroup);
		for (String attribute : attributes) {
			if (!attribute.isEmpty()) {
			   sahiTasks.checkbox(attribute).click();
			}
		}
		sahiTasks.button(buttonToClick).click();		
	}
	
	
	/**
	 * Delete a Permission
	 * @param sahiTasks
	 * @param cn - the rule to be deleted
	 * @param buttonToClick - Possible values - "Delete" or "Cancel"
	 */
	public static void deletePermission(SahiTasks sahiTasks, String cn, String buttonToClick) {
		CommonTasks.search(sahiTasks, cn);
		if (sahiTasks.link(cn).exists()){
			sahiTasks.checkbox(cn).click();
			sahiTasks.link("Delete").click();
			sahiTasks.button(buttonToClick).click();
			
			
			if (buttonToClick.equals("Cancel")) {
				sahiTasks.checkbox(cn).click();
			}
		}
		
		CommonTasks.clearSearch(sahiTasks);
	}

	public static void createPermissionBug807755(SahiTasks sahiTasks, String cn, String right, String type) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.checkbox(right).click();
		sahiTasks.select("target").choose("Type");
		sahiTasks.select("type").choose(type);
		//Choose all attributes listed
		sahiTasks.checkbox("on[1]").click();
		sahiTasks.button("Add").click();
	}

	public static void createPermissionWithRequiredField(SahiTasks sahiTasks, String type, String expectedError) {
		sahiTasks.span("Add").click();
		sahiTasks.select("target").choose(type);
		sahiTasks.button("Add").click();
		Assert.assertTrue(sahiTasks.span(expectedError).near(sahiTasks.textbox("cn")).exists(), "Verified expected error for missing name");
		Assert.assertTrue(sahiTasks.span(expectedError).near(sahiTasks.checkbox("delete")).exists(), "Verified expected error for missing permission");
		if (type.equals("Filter")) {
			Assert.assertTrue(sahiTasks.span(expectedError).near(sahiTasks.textbox("filter[1]")).exists(), "Verified expected error for missing filter");
		} else if (type.equals("Subtree")) {
			Assert.assertTrue(sahiTasks.span(expectedError).near(sahiTasks.textarea("subtree")).exists(), "Verified expected error for missing subtree");
		}  else if (type.equals("Target group")) {
			Assert.assertTrue(sahiTasks.span(expectedError).near(sahiTasks.textbox("targetgroup")).exists(), "Verified expected error for missing target group");
		}  
		sahiTasks.button("Cancel").near(sahiTasks.button("Add and Edit")).click();
		
	}

	public static void createPermissionWithSearchForMemberGroup(SahiTasks sahiTasks, String cn, String right,
			String attribute, String memberOfGroup, boolean missing) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);		
		sahiTasks.checkbox(right).click();	
		sahiTasks.select("target").choose("Target group");
		sahiTasks.span("icon combobox-icon").click();
		sahiTasks.textbox("filter[1]").setValue(memberOfGroup);
		sahiTasks.span("icon search-icon[1]").click();
		if (missing)
		{
			//Assert.assertFalse(sahiTasks.select("list").containsText("a"), "Verified search did not bring any options");
		//Assert.assertTrue(sahiTasks.select("list").fetch().length(), "Verified search did not bring any options");
		System.out.println("NAMITA 1 " + sahiTasks.fetch(sahiTasks.select("list")));
		}
		else	{
			System.out.println("NAMITA 2 " + sahiTasks.fetch(sahiTasks.select("list")));
			//Assert.assertFalse(sahiTasks.select("list").fetch().isEmpty(), "Verified search listed selected options");
			sahiTasks.select("list").choose(memberOfGroup);			
		
		}
		sahiTasks.button("Add").click();		
	}

	public static void deleteMultiplePermissions(SahiTasks sahiTasks, String searchString, String[] cns, String buttonToClick) {
		CommonTasks.search(sahiTasks, searchString);
		for (String cn : cns) {
			if (!cn.isEmpty()) {
				sahiTasks.checkbox(cn).click();
			}
		}	
		sahiTasks.span("Delete").click();
		sahiTasks.button(buttonToClick).click();
		CommonTasks.clearSearch(sahiTasks);
	}

	public static void addAndAddAnotherPermissionWithType(SahiTasks sahiTasks,	String cn1, String cn2, 
			String right, String type, String attribute) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn1);		
		sahiTasks.checkbox(right).click();		
		sahiTasks.select("target").choose("Type");
		sahiTasks.select("type").choose(type);		
		sahiTasks.checkbox(attribute).click();
		sahiTasks.button("Add and Add Another").click();
		Assert.assertTrue(sahiTasks.div("Permission successfully added").exists(), "Verified confirmation message");
		sahiTasks.textbox("cn").setValue(cn2);		
		sahiTasks.checkbox(right).click();		
		sahiTasks.select("target").choose("Type");
		sahiTasks.select("type").choose(type);		
	    sahiTasks.checkbox(attribute).click();
		sahiTasks.button("Add").click();
	}

	public static void addAndEditPermissionWithType(SahiTasks sahiTasks, String cn, String right, String type, 
			String attribute, String rightToAdd, String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);		
		sahiTasks.checkbox(right).click();		
		sahiTasks.select("target").choose("Type");
		sahiTasks.select("type").choose(type);		
		sahiTasks.checkbox(attribute).click();
		sahiTasks.button("Add and Edit").click();
		sahiTasks.checkbox(rightToAdd).click();
		sahiTasks.span(buttonToClick).click();
	}
	
	public static void verifyPermissionType(SahiTasks sahiTasks, String cn, String[] rights, String type, String[] attributes, String memberOfGroup) {
		if (sahiTasks.link(cn).exists()) {
			sahiTasks.link(cn).click();
			// https://fedorahosted.org/freeipa/ticket/2875 
			sahiTasks.span("Refresh").click();
			for (String right : rights) {
				if (!right.isEmpty()) {
					Assert.assertTrue(sahiTasks.checkbox(right).checked(), "Verified permission " + right + " is checked for " + cn );
					//sahiTasks.checkbox(right).click();
				}
				
			}	
			if (!type.isEmpty())
				Assert.assertEquals(type, sahiTasks.select("type").selectedText(), "Verified type " + type + " for " + cn);
			for (String attribute : attributes) {
				if (!attribute.isEmpty() && (!attribute.equals("none"))) {
					Assert.assertTrue(sahiTasks.checkbox(attribute).checked(), "Verified attribute " + attribute + " is checked for " + cn );
					//sahiTasks.checkbox(attribute).click();
				}
			}
			if (!memberOfGroup.isEmpty()){
				Assert.assertEquals(memberOfGroup, sahiTasks.textbox("memberof").value());
				//sahiTasks.textbox("memberof").setValue("");
			}
			//sahiTasks.span("Update").click();
			sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
		}
	}
	
	public static void verifyPermissionFilter(SahiTasks sahiTasks, String cn, String[] rights, String filter, String[] attributes) {
		CommonTasks.search(sahiTasks, cn);
		if (sahiTasks.link(cn).exists()) {
			sahiTasks.link(cn).click();
			sahiTasks.span("Refresh").click();
			for (String right : rights) {
				if (!right.isEmpty()) {
					Assert.assertTrue(sahiTasks.checkbox(right).checked(), "Verified permission " + right + " is checked for " + cn );
				}
			}	
			Assert.assertEquals(filter, sahiTasks.textbox("filter").value(), "Verified filter " + filter + " for " + cn);
			int i=0;
			for (String attribute : attributes) {
				if (!attribute.isEmpty()) {
					Assert.assertEquals(attribute, sahiTasks.textbox("attrs_multi-" + i).value());
					i++;
				}
			}
			sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
			if(sahiTasks.button("Reset").exists())
				sahiTasks.button("Reset").click();
			CommonTasks.clearSearch(sahiTasks);
		}
	}

	public static void addPermissionWithFilterUndoAttribute(SahiTasks sahiTasks, String cn, String right, String filter,
			String attributeUndo, String attribute, String buttonToClick) {
		sahiTasks.span("Add").click();
		sahiTasks.textbox("cn").setValue(cn);
		sahiTasks.checkbox(right).click();
		sahiTasks.select("target").choose("Filter");
		sahiTasks.textbox("filter[1]").setValue(filter);		
		sahiTasks.link("Add[1]").click();
		sahiTasks.textbox("attrs_multi-0" ).setValue(attributeUndo);
		sahiTasks.link("Add[1]").click();
		sahiTasks.textbox("attrs_multi-1" ).setValue(attributeUndo);
		sahiTasks.span("undo").click();
		sahiTasks.span("undo").click();
		sahiTasks.link("Add[1]").click();
		sahiTasks.textbox("attrs_multi-0" ).setValue(attribute);
		sahiTasks.button(buttonToClick).click();		
	}
	
	public static void expandCollapsePermission(SahiTasks sahiTasks, String cn) {
		CommonTasks.search(sahiTasks, cn);
		if (sahiTasks.link(cn).exists()) {
			sahiTasks.link(cn).click();
			
			sahiTasks.span("Collapse All").click();
			sahiTasks.waitFor(1000);
	
			//Verify no data is visible
			Assert.assertFalse(sahiTasks.checkbox("write").exists(), "No data is visible");
			
			
			sahiTasks.heading2("Target").click();
			//Verify only data for account settings is displayed
			Assert.assertTrue(sahiTasks.label("Member of group:").exists(), "Verified Target available for Permisison " + cn);
			
			
			sahiTasks.span("Expand All").click();
			sahiTasks.waitFor(1000);
			//Verify data is visible
			Assert.assertTrue(sahiTasks.checkbox("write").checked(), "Now Data is visible");
			
			sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
			if(sahiTasks.button("Reset").exists())
				sahiTasks.button("Reset").click();
		}
		CommonTasks.clearSearch(sahiTasks);
	}

	public static void modifyPermission(SahiTasks sahiTasks, String cn, String right, String memberOfGroup, String attribute) {
		sahiTasks.link(cn).click();
		if (!right.isEmpty()) 
			sahiTasks.checkbox(right).click();
		if (!memberOfGroup.isEmpty()) {
			sahiTasks.span("icon combobox-icon").click();
			sahiTasks.select("list").choose(memberOfGroup);
		}
		if (!attribute.isEmpty() && (!attribute.equals("none")))
			sahiTasks.checkbox(attribute).click();
		//deselect all attr
		if (attribute.equals("none")) {
			sahiTasks.checkbox("on").click();
			sahiTasks.checkbox("on").click();
		}
		sahiTasks.span("Update").click();	
		sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
		//win specific ::error showed up because of ticket3028 ,and when hitting the backlink ,it will say unsaved changes ,have to click reset in win .otherwise it will lead to upcoming failures 
	    if (sahiTasks.span("Reset[1]").exists()) {
	    	sahiTasks.span("Reset[1]").click();
	    	sahiTasks.span("Cancel").click();
	    }
	}
	
	public static void invalidModifyPermission(SahiTasks sahiTasks, String cn, String right, String type, String expectedError) {
		sahiTasks.link(cn).click();
		if (!right.isEmpty()) 
			sahiTasks.checkbox(right).click();
		if (!type.isEmpty())
			sahiTasks.select("type").choose(type);
	
		sahiTasks.span("Update").click();	
		
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error for " + cn);
		if (sahiTasks.button("OK").exists())
			sahiTasks.button("OK").click();
		else
			sahiTasks.button("Cancel").near(sahiTasks.button("Retry")).click();
		sahiTasks.span("Reset").click();
		sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
	}

	public static void undoResetUpdatePermission(SahiTasks sahiTasks, String cn, String dataToUpdate, String data, String buttonToClick) {
		sahiTasks.link(cn).click();
		if (dataToUpdate.equals("Permissions")) {
			sahiTasks.checkbox(data).click();
		} else if (dataToUpdate.equals("Member of group")) {
			sahiTasks.span("icon combobox-icon").click();
			sahiTasks.select("list").choose("");
		} else if (dataToUpdate.equals("Attributes")) {
			sahiTasks.checkbox(data).click();
		}
		sahiTasks.span(buttonToClick).click();
		
		if ( (buttonToClick.equals("undo")) || (buttonToClick.equals("Reset")) ) {
			if (dataToUpdate.equals("Permissions")) {
				Assert.assertTrue(sahiTasks.checkbox(data).checked(), "Permission " +  data  + " is checked");
			} else if (dataToUpdate.equals("Member of group")) {
				Assert.assertEquals(data, sahiTasks.textbox("memberof").value());
			} else if (dataToUpdate.equals("Attributes")) {
				Assert.assertTrue(sahiTasks.checkbox(data).checked(), "Attribute " +  data  + " is checked");
			}
		} else {
			if (dataToUpdate.equals("Permissions")) {
				Assert.assertFalse(sahiTasks.checkbox(data).checked(), "Permission " +  data  + " is not checked");
			} else if (dataToUpdate.equals("Member of group")) {
				Assert.assertEquals("", sahiTasks.textbox("memberof").value());
			} else if (dataToUpdate.equals("Attributes")) {
				Assert.assertFalse(sahiTasks.checkbox(data).checked(), "Attribute " +  data  + " is not checked");
			}
		}
        
		sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
	}

	public static void verifyPermissionBug783500(SahiTasks sahiTasks, String cn) {
		if (sahiTasks.link(cn).exists()) {
			sahiTasks.link(cn).click();
			
			Assert.assertFalse(sahiTasks.checkbox("attrs").checked(), "Verified "+ sahiTasks.checkbox("attrs").text());
			int i=1;
			while  (sahiTasks.checkbox("attrs["+i+"]").exists()) {
				if (sahiTasks.checkbox("attrs["+i+"]").checked()) {
					Assert.fail("Found attribute selected " + sahiTasks.checkbox("attrs["+i+"]").text());
				} else {
					System.out.println("NAMITA: Verified attr: " + sahiTasks.checkbox("attrs["+i+"]").text());
				}				
				i++;
			}
			sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
		}
		
	}

	public static void addPermissionAddPrivilege(SahiTasks sahiTasks, String cn, String[] rights, String type,  String[] privileges, String buttonToClick) {
		if (!type.isEmpty()) {
			sahiTasks.span("Add").click();
			sahiTasks.textbox("cn").setValue(cn);
			for (String right : rights) {
				if (!right.isEmpty()) {
					sahiTasks.checkbox(right).click();
				}
			}
			sahiTasks.select("target").choose("Type");
			sahiTasks.select("type").choose(type);
			sahiTasks.button("Add and Edit").click();
		} else {
			sahiTasks.link(cn).click();
		}
		
	
		sahiTasks.link("member_privilege").click();
	
		sahiTasks.span("Add").click();
		
		for (String privilege : privileges) {
			if (!privilege.isEmpty()) {
				sahiTasks.textbox("filter").setValue(privilege);
				sahiTasks.span("Find").click();
				sahiTasks.checkbox(privilege).click();
				sahiTasks.span(">>").click();
			}
		}
		
		sahiTasks.button(buttonToClick).click();
		sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
	}

	
	public static void verifyPermissionMembership(SahiTasks sahiTasks, String cn, String[] members, boolean exists) {
		sahiTasks.link(cn).click();
		sahiTasks.link("member_privilege").click();
		for (String member : members) {
			if (!member.isEmpty()) {
				if (exists){
					Assert.assertTrue(sahiTasks.link(member).exists(), "Verified " + member + " is listed for " + cn );
				}	
				else {
					Assert.assertFalse(sahiTasks.link(member).exists(), "Verified " + member + " is not listed for " + cn );
				}
			}
		}	
		sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
	}
	
	
	public static void  deleteMemberFromPermission(SahiTasks sahiTasks, String cn, String[] members, 
			String allOrOne, String buttonToClick) {
		sahiTasks.link(cn).click();
		sahiTasks.link("member_privilege").click();
		if (allOrOne.equals("All")) {
			sahiTasks.checkbox("cn").check();
		} else {
			for (String member : members) {
				if (!member.isEmpty()) {
					sahiTasks.checkbox(member).check();
				}
			}
		}
				
		sahiTasks.span("Delete").click();
		sahiTasks.button(buttonToClick).click();
		sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();		
	}

	public static void RevertChanges(SahiTasks sahiTasks, String cn, String right, String attribute) {
		CommonTasks.search(sahiTasks, cn);
		if (sahiTasks.link(cn).exists()) {
			sahiTasks.link(cn).click();
			sahiTasks.span("Refresh").click();
			if(sahiTasks.checkbox(right).checked())
				sahiTasks.checkbox(right).click();
			if(sahiTasks.checkbox(attribute).checked())
				sahiTasks.checkbox(attribute).click();
			if(sahiTasks.span("icon combobox-icon").exists()){
			sahiTasks.span("icon combobox-icon").click();
			sahiTasks.select("list").choose("");
			}
			sahiTasks.span("Update").click();
			sahiTasks.link("Permissions").in(sahiTasks.div("content nav-space-3")).click();
			CommonTasks.clearSearch(sahiTasks);
		}
		
	}
	
	
}
