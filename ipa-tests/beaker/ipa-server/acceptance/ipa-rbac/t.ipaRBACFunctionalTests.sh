# Role Based Access Control has 3 sets of clis: privilege, privilege and role
#  this will cover the functional tests 

ipaRBACFunctionalTests() {
    cleanup
    setup
    test01
    test04
#    test05
    test06
}

setup()
{
    rlPhaseStartTest "Setup - add users and groups"
        rlRun "kinitAs $ADMINID $ADMINPW"
       # user for test01
       login="testuserhelpdesk"
       firstname="testUserHelpdesk"
       lastname="testUserHelpdesk"
       password="Secret123"
       rlRun "create_ipauser $login $firstname $lastname $password"
       login="test"
       firstname="test"
       lastname="test"
       password="Secret123"
       rlRun "create_ipauser $login $firstname $lastname $password"
       # user for test04
       login="testgroupdescadmin"
       firstname="testgroupdescadmin"
       lastname="testgroupdescadmin"
       password="Secret123"
       rlRun "create_ipauser $login $firstname $lastname $password"
       rlRun "kinitAs $ADMINID $ADMINPW"
       groupName="groupone"
       groupDesc="groupone"
       rlRun "addGroup $groupName $groupDesc"
       # user for test06
       login="testuseraddadmin"
       firstname="testUserAddAdmin"
       lastname="testUserAddAdmin"
       password="Secret123"
       rlRun "create_ipauser $login $firstname $lastname $password"
       
    rlPhaseEnd
}


cleanup()
{
  rlRun "kinitAs $ADMINID $ADMINPW"
  privilegeName="Add User"
  rlRun "deletePrivilege \"$privilegeName\"" 0 "Deleting $privilegeName"
  privilegeName="Modify Group Desc"
  rlRun "deletePrivilege \"$privilegeName\"" 0 "Deleting $privilegeName"
  roleName="Test User Admin"
  rlRun "deleteRole \"$roleName\"" 0 "Deleting $roleName"
  roleName="Test Group Desc Admin"
  rlRun "deleteRole \"$roleName\"" 0 "Deleting $roleName"
  login="one"
  rlRun "delete_ipauser $login" 0 "Deleting $login"
  login="two"
  rlRun "delete_ipauser $login" 0 "Deleting $login"
  groupName="groupone"
  rlRun "deleteGroup $groupName" 0 "Deleting $groupName"
  permissionName="ManageGroupDescAndUsers"
  rlRun "ipa permission-del \"$permissionName\"" 0 "Deleting permission: $permissionName"
  privilegeName="Modify Group Desc And Users"
  rlRun "deletePrivilege \"$privilegeName\"" 0 "Deleting $privilegeName"
  roleName="Test Group Desc And User Admin"
  rlRun "deleteRole \"$roleName\"" 0 "Deleting $roleName"
}

# Scenario:
# User with Helpdesk Role should - 
# - not be to update users in Adminstrator group's password
# - not be able new user
# - be able to upadet user attr
# - be able to reset a user's password 
test01()
{ 
   rlPhaseStartTest "ipa-rbac-1001 - Set up user with HelpDesk Role - Cannot reset admin's password" 
       rlRun "kinitAs $ADMINID $ADMINPW"
      login="testuserhelpdesk"
      password="Secret123"
      roleName="helpdesk"
      type="users"
      rlRun "addMemberToRole $login \"$roleName\" $type" 0 "Adding member to role $roleName"
      # kinit as testuserhelpdesk
      rlRun "kinitAs $login $password" 0 "kinit as $login"
      # change admin password - cannot
      adminLogin="admin"
      newPwd="Secret456"
      command="echo $newPwd | ipa passwd $adminLogin"
      expmsg="ipa: ERROR: Insufficient access: Insufficient access rights"
      rlRun "$command > $TmpDir/ipaRBAC_test01_1.log 2>&1" 1 "Verify error message when $login updates $adminLogin's password (bug 773759)"  
     rlAssertGrep "$expmsg" "$TmpDir/ipaRBAC_test01_1.log"
   rlPhaseEnd

    # HelpDesk - can modify group memberships, modify users, reset password
    # this user should be allowed to modify a user's lastname, reset password, but cannot add or delete this user
   rlPhaseStartTest "ipa-rbac-1001 - Set up user with HelpDesk Role - Cannot add new user" 
      # add a user - cannot
      newLogin="two"
      newFirstName="two"
      newLastName="two"
      newInitPwd="two"
      command="ipa user-add --first=$newFirstName --last=$newLastName $newLogin"
      expmsg="ipa: ERROR: Insufficient access: Insufficient 'add' privilege to add the entry 'uid=two,cn=users,cn=accounts,dc=testrelm,dc=com'."
      rlRun "$command > $TmpDir/ipaRBAC_test01_2.log 2>&1" 1 "Verify error message when $login adds a new user"
     rlAssertGrep "$expmsg" "$TmpDir/ipaRBAC_test01_2.log"
   rlPhaseEnd

      # update a lastname - can
   rlPhaseStartTest "ipa-rbac-1001 - Set up user with HelpDesk Role - Can update user attr" 
      testLogin="test"
      attrToUpdate="last"
      newLastName="testtest"
      rlRun "modifyUser $testLogin $attrToUpdate $newLastName" 0 "Verify $login can modify $testLogin's lastname"
   rlPhaseEnd

      # change user password - can
   rlPhaseStartTest "ipa-rbac-1001 - Set up user with HelpDesk Role - Can reset a user's password (bug 773759)" 
      newPwd="testtest"
      rlRun "echo $newPwd | ipa passwd $testLogin" 0 "Verify $login can reset $testlogin's password"
   rlPhaseEnd

    # this user can add a user to another group, but cannot add or update a group
    # this user cannot list available hostgroups or netgroups, cannot delete them 
}

#test02()
#{

  # ipa permission-add ModifyGroupDescription --permissions=write --type=group --attr=description
  # ipa permission-add ModifyGroupBusinessCategory --permissions=write --type=group --attr=businesscategory
  # ipa privilege-add "Group Modifier"
  # ipa privilege-add-permission "Group Desc Modifier"
  # and add ModifyGroupDescription, ModifyGroupBusinessCategory
  # ipa role-add "TestGroupRole"
  # ipa role-add-privilege GroupRole and add "Group Modifier"
  # add user, and assign the role
  # Add a group for this test
  # kinit as this user
  # ipa group-mod --desc "group two after update"  grouptwo
  # ipa group-mod --addattr businesscategory=NK grouptwo
  # ipa group-mod --addattr seealso=NK grouptwo
  # ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'seeAlso' attribute of entry 'cn=grouptwo,cn=groups,cn=accounts,dc=testrelm'.


#}

#test03()
#{

# similar to above, but using filter, instead of type
# permission should be -
# ipa permission-show AAA --all
#   dn: cn=aaa,cn=permissions,cn=pbac,dc=testrelm,dc=com
#   Permission name: AAA
#   Permissions: write, add
#   Filter: (businesscategory=*)
#   Granted to Privilege: aaa
#   memberindirect: cn=aaa,cn=roles,cn=accounts,dc=testrelm,dc=com,
#         uid=one,cn=users,cn=accounts,dc=testrelm,dc=com
#   objectclass: groupofnames, ipapermission, top
#}

test04()
{
   rlPhaseStartTest "ipa-rbac-1001 - Set up role for user to allow updating groupone's desc"
      rlRun "kinitAs $ADMINID $ADMINPW"
      permissionRights="write"
      permissionLocalTarget="--targetgroup=groupone"
      permissionLocalAttr="description"
     permissionName="ManageGroupDescAndUsers"
      rlRun "addPermission \"$permissionName\" $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"

      privilegeName="Modify Group Desc And Users"
      privilegeDesc="Modify Group Desc And Users"
      rlRun "addPrivilege \"$privilegeName\" \"$privilegeDesc\"" 0 "Adding privilege: $privilegeName"
      rlRun "addPermissionToPrivilege \"$permissionName\" \"$privilegeName\"" 0 "Add permission to privilege"
     roleName="Test Group Desc Admin"
      roleDesc="Test Group Desc Admin"
      rlRun "addRole \"$roleName\" \"$roleDesc\"" 0 "Adding role: $roleName"
      rlRun "addPrivilegeToRole \"$privilegeName\" \"$roleName\"" 0 "Adding privilege to role"
      login="testgroupdescadmin"
      password="Secret123"
      type="users"
      rlRun "addMemberToRole $login \"$roleName\" $type" 0 "Adding member to role"
      rlRun "kinitAs $login $password" 0 "kinit as $login"
      # group-mod the desc for groupone
      attr="desc"
      newDescription="Updated Group One"
      rlRun "modifyGroup $groupName $attr \"$newDescription\"" 0 "Verify $login can update $groupName's description"
      #test to add user two to groupone - cannot
  rlPhaseEnd
#  add members to this group, nor update desc for group two

   rlPhaseStartTest "ipa-rbac-1001 - Modify role to allow adding members to groupone"
      rlRun "kinitAs $ADMINID $ADMINPW"
      attr="attrs"
      value="description,member"
      rlRun "modifyPermission $permissionName $attr $value"  
      attr="setattr"
      value="cn=Test Group Desc And User Admin"
      rlRun "modifyRole \"$roleName\" $attr \"$value\"" 0 "Modify $roleName to have new name"
      #test to add user two to groupone - can
   rlPhaseEnd
   
}

#test05()
#{
# verify bug xxx
# for the roles in 
# ipa role-find | grep "Role name" | cut -d ":" -f2
# go through each to verify it has privileges added
# do same for privileges to verify it has permissions added.

#}



#test05()
#{
# ipa permission-add AAA --memberof=groupone --permissions=write --attr=carlicense
# groupone has user one
# with this permission, user can edit one's carlicense
# and nothing else


#}

# Scenario:
# User's role allows to add a new user to the default group - ipausers
# Verify User can add a new user, but cannot change its lastname or password
test06()
{
  privilegeName="Add User"
  privilegeDesc="Add User"
  permissionList="Add user to default group,Add Users"
  roleName="Test User Admin"
  roleDesc="Test User Admin"
  type="users"
  login="testuseraddadmin"
  password="Secret123"

   rlPhaseStartTest "ipa-rbac-1001 - Set up role for user to allow only adding a user - Can add a user"
      rlRun "kinitAs $ADMINID $ADMINPW"
      rlRun "addPrivilege \"$privilegeName\" \"$privilegeDesc\"" 0 "Adding privilege: $privilegeName"
      rlRun "addPermissionToPrivilege \"$permissionList\" \"$privilegeName\"" 0 "Add permission to privilege"
      rlRun "addRole \"$roleName\" \"$roleDesc\"" 0 "Adding role: $roleName"
      rlRun "addPrivilegeToRole \"$privilegeName\" \"$roleName\"" 0 "Adding privilege to role"
      rlRun "addMemberToRole $login \"$roleName\" $type" 0 "Adding member to role"

      # kinit as testuseraddadmin
      rlRun "kinitAs $login $password" 0 "kinit as $login"
      # add a user - should
      newLogin="one"
      newFirstName="one"
      newLastName="one"
      newInitPwd="one"
      rlRun "addUserWithPassword $newFirstName $newLastName $newLogin $newInitPwd" 0 "Add a new user as $login" 
   rlPhaseEnd

      # update a username - cannot
   rlPhaseStartTest "ipa-rbac-1001 - Set up role for user to allow only adding a user - Cannot update user attr"
      attrToUpdate="last"
      newLastName="oneone"
      command="modifyUser $newLogin $attrToUpdate $newLastName"
      expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'sn' attribute of entry 'uid=one,cn=users,cn=accounts,dc=testrelm,dc=com'"
      rlRun "$command > $TmpDir/ipaRBAC_test06_1.log 2>&1" 1 "Verify error message when $login updates $newLogin's lastname" 
     rlAssertGrep "$expmsg" "$TmpDir/ipaRBAC_test06_1.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-rbac-1001 - Set up role for user to allow only adding a user - Cannot reset user password"
      # change user password - cannot
      newPwd="oneone"
      command="echo $newPwd | ipa passwd $newLogin"
      expmsg="ipa: ERROR: Insufficient access: Insufficient access rights"
      rlRun "$command > $TmpDir/ipaRBAC_test06_2.log 2>&1" 1 "Verify error message when $login updates $newLogin's password" 
     rlAssertGrep "$expmsg" "$TmpDir/ipaRBAC_test06_2.log"
   rlPhaseEnd
}
