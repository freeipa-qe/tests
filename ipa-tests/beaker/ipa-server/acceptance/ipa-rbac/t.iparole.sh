# Role Based Access Control has 3 sets of clis: permission, privilege and role
#  this will cover role 

########################
# testsuite
########################
iparoleTests() {
    cleanupRolesTests
    iparole_check
    iparole_add
    iparole_add_member
    iparole_remove_member
    iparole_add_privilege
    iparole_remove_privilege
    iparole_del
    iparole_show
    iparole_find
    iparole_mod
#    cleanupRolesTests
}

########################
# cleanup
########################
cleanupRolesTests()
{
    kinitAs $ADMINID $ADMINPW
    roleName="Host Admin"
    rlRun "deleteRole \"$roleName\"" 0 "Deleting $roleName"
     roleName="Hostgroup Admin"
    rlRun "deleteRole \"$roleName\"" 0 "Deleting $roleName"
     roleName="Netgroup Admin"
    rlRun "deleteRole \"$roleName\"" 0 "Deleting $roleName"
     roleName="Hostgroup Admin with seeAlso"
    rlRun "deleteRole \"$roleName\"" 0 "Deleting $roleName"
     roleName="Hostgroup Admin with seeAlso"
    rlRun "deleteRole \"$roleName\"" 0 "Deleting $roleName"
     roleName="Hostgroup Admin with multiple seeAlso"
    rlRun "deleteRole \"$roleName\"" 0 "Deleting $roleName"
    privilegeName1="user administrators"
    privilegeName2="group administrators,hbac administrator"
    privilegeName3="u,r stuff"
    privilegeList="$privilegeName1,$privilegeName2"
    rlRun "removePrivilegeFromRole \"$privilegeList\" \"$roleName\""
    rlRun "deletePrivilege \"$privilegeName3\""
     privilegeName="modify group membership"
    rlRun "addPrivilegeToRole \"$privilegeName\" \"$roleName\"" 
    roleName="helpdesk"
    rlRun "modifyRole \"$roleName\" \"desc\" \"helpdesk\"" 0 "Modify $roleName to original desc"
    rlRun "modifyRole \"$roleName\" \"delattr\" \"seeAlso=cn=HostgroupCLI\"" 0 "Modify $roleName to delete seeAlso attr"
}


##############################################################
# Verify Roles provided by IPA have privileges assigned 
##############################################################
iparole_check()
{

   rlPhaseStartTest "ipa-role-cli-1001 - Check IPA provided Roles have assigned Privileges" 
     ipa role-find | grep "Role name" | cut -d ":" -f2 > $TmpDir/iparole_check.log
     while read roleName 
     do
       command="ipa role-show \"$roleName\" --all"
       expPermission="Privileges:"
       rlRun "$command > $TmpDir/iparole_priv.log" 0 "Verify $roleName has privileges"
       rlAssertGrep "$expPermission" "$TmpDir/iparole_priv.log"
     done < "$TmpDir/iparole_check.log"
   rlPhaseEnd

}



#############################################
#  test: iparole-add 
#############################################
iparole_add()
{

   iparole_add_positive
   iparole_add_negative
}


#############################################
#  test: iparole-add: Positive Tests  
#############################################
iparole_add_positive()
{
 rlRun "kinitAs $ADMINID $ADMINPW"

   rlPhaseStartTest "ipa-role-cli-1002 - add role" 
    roleName="Host Admin"
    roleDesc="Host Admin"
    rlRun "addRole \"$roleName\" \"$roleDesc\"" 0 "Adding role: $roleName"
    rlRun "verifyRoleTargetAttr \"$roleName\" \"$roleDesc\" "
   rlPhaseEnd


   rlPhaseStartTest "ipa-role-cli-1003 - add role - raw"
     roleName="Hostgroup Admin"
     roleDesc="Hostgroup Admin"
     command="ipa role-add \"$roleName\" --desc \"$roleDesc\" --all --raw"
     rlRun "$command > $TmpDir/iparole_addraw.log" 0 "Verify Role add with raw"
     objectclassOccurences=`rlAssertGrep "objectclass:" "$TmpDir/iparole_addraw.log" -c | cut -d ":" -f1`

     if [ "$objectclassOccurences" = 3 ]; then
        rlPass "Found expected objectclasses for $roleName"
     else
        rlFail "Did not find expected objectclasses for $roleName"
     fi
    rlPhaseEnd

   rlPhaseStartTest "ipa-role-cli-1004 - add role - all"
     roleName="Netgroup Admin"
     roleDesc="Netgroup Admin"
     command="ipa role-add \"$roleName\" --desc \"$roleDesc\" --all"
     rlRun "$command > $TmpDir/iparole_addraw.log" 0 "Verify Role add with raw"
     objectclassOccurences=`rlAssertGrep "objectclass:" "$TmpDir/iparole_addraw.log" -c | cut -d ":" -f1`

     if [ "$objectclassOccurences" = 1 ]; then
        rlPass "Found expected objectclass for $roleName"
     else
        rlFail "Did not find expected objectclass for $roleName"
     fi
    rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1005 - add role with comma" 
    roleName="Hostgroup, Netgroup - Admin"
    roleDesc="Hostgroup, Netgroup - Admin"
    rlRun "addRole \"$roleName\" \"$roleDesc\"" 0 "Adding $roleName"
    rlRun "verifyRoleAttr \"$roleName\" \"Role name\" \"$roleName\" " 0 "Verify Role Name"
    rlRun "verifyRoleAttr \"$roleName\" \"Description\" \"$roleDesc\" " 0 "Verify Role Desc"
   rlPhaseEnd


   rlPhaseStartTest "ipa-role-cli-1006 - add role with setattr" 
     roleName="Hostgroup Admin with seeAlso"
     roleDesc="Hostgroup Admin with seeAlso"
     attr="--setattr=\"seeAlso=cn=HostgroupCLI\""
     rlRun "addRole \"$roleName\" \"$roleDesc\" $attr" 0 "Adding $roleName"
    rlRun "verifyRoleTargetAttr \"$roleName\" \"$roleDesc\" \"\" "
    rlRun "verifyRoleAttr \"$roleName\" \"seeAlso\" \"cn=HostgroupCLI\" " 
   rlPhaseEnd


   rlPhaseStartTest "ipa-role-cli-1007 - add role with addattr" 
     roleName="Hostgroup Admin with multiple seeAlso"
     roleDesc="Hostgroup Admin with multiple seeAlso"
     attr="--addattr=\"seeAlso=cn=HostgroupCLI\"\ --addattr=\"seeAlso=cn=HostCLI\""
     rlRun "addRole \"$roleName\" \"$roleDesc\" $attr" 0 "Adding $roleName"
    rlRun "verifyRoleTargetAttr \"$roleName\" \"$roleDesc\" \"\" "
    rlRun "verifyRoleAttr \"$roleName\" \"seeAlso\" \"cn=HostgroupCLI, cn=HostCLI\" " 
   rlPhaseEnd
}

#############################################
#  test: iparole-add: Negative Tests  
#############################################
iparole_add_negative()
{

rlLog "Role - add - negative"
   rlPhaseStartTest "ipa-role-cli-1008 - add role with missing name" 
     roleName=""
     roleDesc="Host Admin"
     command="addRole \"$roleName\" \"$roleDesc\""
     expmsg="ipa: ERROR: 'name' is required"
     rlRun "$command > $TmpDir/iparole_noname.log 2>&1" 0 "Verify error message for missing rolename"
     rlAssertGrep "$expmsg" "$TmpDir/iparole_noname.log"
   rlPhaseEnd


   rlPhaseStartTest "ipa-role-cli-1009 - add role with blank setattr (bug 783543)" 
     roleName="Hostgroup Admin with blank seeAlso"
     roleDesc="Hostgroup Admin with blank seeAlso"
     attr="--setattr=\"\""
     command="addRole \"$roleName\" \"$roleDesc\" $attr"
     expmsg="ipa: error: Better error message than an internal error has occurred " 
     rlRun "$command > $TmpDir/iparole_blankattr.log 2>&1" 1 "Verify error message for $roleName"
     rlAssertGrep "$expmsg" "$TmpDir/iparole_blankattr.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-role-cli-1010 - add role with invalid setattr" 
     roleName="Hostgroup Admin with invalid seeAlso"
     roleDesc="Hostgroup Admin with invalid seeAlso"
     attr="--setattr=\"xyz=XYZ\""
     command="addRole \"$roleName\" \"$roleDesc\" $attr"
     expmsg="ipa: ERROR: attribute \"xyz\" not allowed"
     rlRun "$command > $TmpDir/iparole_invalidattr1.log 2>&1" 0 "Verify error message for $roleName"
     rlAssertGrep "$expmsg" "$TmpDir/iparole_invalidattr1.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-role-cli-1011 - add role with invalid addattr" 
     roleName="Hostgroup Admin with invalid seeAlso"
     roleDesc="Hostgroup Admin with invalid seeAlso"
     attr="--addattr=\"xyz=XYZ\""
     command="addRole \"$roleName\" \"$roleDesc\" $attr"
     expmsg="ipa: ERROR: attribute \"xyz\" not allowed"
     rlRun "$command > $TmpDir/iparole_invalidattr2.log 2>&1" 0 "Verify error message for $roleName"
     rlAssertGrep "$expmsg" "$TmpDir/iparole_invalidattr2.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-role-cli-1012 - add role with blank desc" 
     roleName="Host Admin with blank desc"
     roleDesc=""
     command="addRole \"$roleName\" \"$roleDesc\""
     expmsg="ipa: ERROR: 'desc' is required"
     rlRun "$command > $TmpDir/iparole_blankdesc.log 2>&1" 0 "Verify error message for $roleName"
     rlAssertGrep "$expmsg" "$TmpDir/iparole_blankdesc.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-role-cli-1013 - add duplicate role" 
     roleName="Host Admin"
     roleDesc="Host Admin"
     command="addRole \"$roleName\" \"$roleDesc\""
     expmsg="ipa: ERROR: role with name \"$roleName\" already exists"
     rlRun "$command > $TmpDir/iparole_duplicaterole.log 2>&1" 0 "Verify error message for $roleName"
     rlAssertGrep "$expmsg" "$TmpDir/iparole_duplicaterole.log"
   rlPhaseEnd
}


#############################################
#  test: iparole-add-member
#############################################
iparole_add_member()
{
  iparole_add_member_positive
  iparole_add_member_negative
}


#############################################
#  test: iparole-add-member: Positive Tests  
#############################################
iparole_add_member_positive()
{
  rlRun "kinitAs $ADMINID $ADMINPW"

  rlPhaseStartTest "ipa-role-cli-1014 - add one user member using --all" 
    login="testuseradmin"
    firstname="testuseradmin"
    lastname="testuseradmin"
    password="Secret123"
    rlRun "create_ipauser $login $firstname $lastname $password" 
    rlRun "kinitAs $ADMINID $ADMINPW"
    roleName="helpdesk"
    type="users"
    command="addMemberToRole \"$roleName\" $type $login all"
    expAttr="Member users: $login"
    rlRun "$command > $TmpDir/iparole_usermemberTorole.log 2>&1" 0 "Add user member to role"
    rlAssertGrep "$expAttr" "$TmpDir/iparole_usermemberTorole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1015 - add one group member using --raw" 
    groupName="testgroupadmin"
    groupDesc="testgroupadmin"
    rlRun "addGroup $groupName $groupDesc"
    roleName="helpdesk"
    type="groups"
    command="addMemberToRole \"$roleName\" $type $groupName raw"
    expAttr="member: cn=testgroupadmin,cn=groups,cn=accounts,dc=testrelm,dc=com"
    rlRun "$command > $TmpDir/iparole_groupmemberTorole.log 2>&1" 0 "Add group member to role"
    rlAssertGrep "$expAttr" "$TmpDir/iparole_groupmemberTorole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1016 - add multiple user members" 
    login1="testuseradmin1"
    firstname1="testuseradmin1"
    lastname1="testuseradmin1"
    password1="Secret123"
    rlRun "create_ipauser $login1 $firstname1 $lastname1 $password1" 
    login2="testuseradmin2"
    firstname2="testuseradmin2"
    lastname2="testuseradmin2"
    password2="Secret123"
    rlRun "create_ipauser $login2 $firstname2 $lastname2 $password2" 
    login3="testuseradmin3"
    firstname3="testuseradmin3"
    lastname3="testuseradmin3"
    password3="Secret123"
    rlRun "create_ipauser $login3 $firstname3 $lastname3 $password3" 
    rlRun "kinitAs $ADMINID $ADMINPW"
    roleName="helpdesk"
    type="users"
    memberlist="$login1,$login2,$login3"
    rlRun "addMemberToRole \"$roleName\" $type "$memberlist" all" 0 "Add multiple user members to role"
    rlRun "verifyRoleAttr \"$roleName\" \"Member users\" \"$login, $login1, $login2, $login3\" " 
  rlPhaseEnd


  rlPhaseStartTest "ipa-role-cli-1017 - add multiple group members" 
    groupName1="testgroupadmin1"
    groupDesc1="testgroupadmin1"
    groupName2="testgroupadmin2"
    groupDesc2="testgroupadmin2"
    groupName3="testgroupadmin3"
    groupDesc3="testgroupadmin3"
    rlRun "addGroup $groupName1 $groupDesc1"
    rlRun "addGroup $groupName2 $groupDesc2"
    rlRun "addGroup $groupName3 $groupDesc3"
    roleName="helpdesk"
    type="groups"
    memberlist="$groupName1,$groupName2,$groupName3"
    rlRun "addMemberToRole \"$roleName\" $type "$memberlist" all" 0 "Add multiple group members to role"
    rlRun "verifyRoleAttr \"$roleName\" \"Member groups\" \"$groupName, $groupName1, $groupName2, $groupName3\" " 
  rlPhaseEnd



  rlPhaseStartTest "ipa-role-cli-1018 - add multiple host members" 
    hostName1="testhostadmin1.testrelm.com"
    hostName2="testhostadmin2.testrelm.com"
    hostName3="testhostadmin3.testrelm.com"
    rlRun "addHost $hostName1"
    rlRun "addHost $hostName2"
    rlRun "addHost $hostName3"
    roleName="helpdesk"
    type="hosts"
    memberlist="$hostName1,$hostName2,$hostName3"
    rlRun "addMemberToRole \"$roleName\" $type "$memberlist" all" 0 "Add multiple host members to role"
    rlRun "verifyRoleAttr \"$roleName\" \"Member hosts\" \"$hostName1, $hostName2, $hostName3\" " 
  rlPhaseEnd


  rlPhaseStartTest "ipa-role-cli-1019 - add multiple hostgroup members" 
    hostgroupName1="testhostgroupadmin1"
    hostgroupDesc1="testhostgroupadmin1"
    hostgroupName2="testhostgroupadmin2"
    hostgroupDesc2="testhostgroupadmin2"
    hostgroupName3="testhostgroupadmin3"
    hostgroupDesc3="testhostgroupadmin3"
    rlRun "addHostGroup $hostgroupDesc1 $hostgroupName1"
    rlRun "addHostGroup $hostgroupDesc2 $hostgroupName2"
    rlRun "addHostGroup $hostgroupDesc3 $hostgroupName3"
    roleName="helpdesk"
    type="hostgroups"
    memberlist="$hostgroupName1,$hostgroupName2,$hostgroupName3"
    rlRun "addMemberToRole \"$roleName\" $type "$memberlist" all" 0 "Add multiple host members to role"
    rlRun "verifyRoleAttr \"$roleName\" \"Member host-groups\" \"$hostgroupName1, $hostgroupName2, $hostgroupName3\" " 
  rlPhaseEnd


  rlPhaseStartTest "ipa-role-cli-1020 - add user and host member" 
    login="testuseradmin4"
    firstname="testuseradmin4"
    lastname="testuseradmin4"
    password="Secret123"
    typeusers="users"
    rlRun "create_ipauser $login $firstname $lastname $password" 
    rlRun "kinitAs $ADMINID $ADMINPW"
    hostName="testhostadmin.testrelm.com"
    typehosts="hosts"
    rlRun "addHost $hostName"
    roleName="helpdesk"
    expAttrUser="member: uid=testuseradmin4,cn=users,cn=accounts,dc=testrelm,dc=com"
    expAttrHost="member: fqdn=testhostadmin.testrelm.com,cn=computers,cn=accounts,dc=testrelm,dc=com"
    command="addMemberToRole \"$roleName\" $typeusers $login raw $typehosts $hostName"
    rlRun "$command > $TmpDir/iparole_userhostmemberTorole.log 2>&1" 0 "Add user member to role"
    rlAssertGrep "$expAttrUser" "$TmpDir/iparole_userhostmemberTorole.log"
    rlAssertGrep "$expAttrUser" "$TmpDir/iparole_userhostmemberTorole.log"
  rlPhaseEnd
}


#############################################
#  test: iparole-add-member: Negative Tests  
#############################################
iparole_add_member_negative()
{

  rlRun "kinitAs $ADMINID $ADMINPW"

  rlPhaseStartTest "ipa-role-cli-1021 - add nonexistent user member" 
    login="nonexistentuser"
    roleName="helpdesk"
    type="users"
    command="addMemberToRole \"$roleName\" $type $login all"
    expAttr1="member user: $login: no such entry"
    expAttr2="Number of members added 0"
    rlRun "$command > $TmpDir/iparole_usermemberTorole.log 2>&1" 0 "Add user member to role"
    rlAssertGrep "$expAttr1" "$TmpDir/iparole_usermemberTorole.log"
    rlAssertGrep "$expAttr2" "$TmpDir/iparole_usermemberTorole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1022 - add missing user member" 
    login=""
    roleName="helpdesk"
    type="users"
    command="addMemberToRole \"$roleName\" $type $login all"
    expAttr="Number of members added 0"
    rlRun "$command > $TmpDir/iparole_usermemberTorole.log 2>&1" 0 "Add user member to role"
    rlAssertGrep "$expAttr" "$TmpDir/iparole_usermemberTorole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1023 - add nonexistent group member" 
    groupName="nonexistentgroup"
    roleName="helpdesk"
    type="groups"
    command="addMemberToRole \"$roleName\" $type $groupName all"
    expAttr1="member group: $groupName: no such entry"
    expAttr2="Number of members added 0"
    rlRun "$command > $TmpDir/iparole_groupmemberTorole.log 2>&1" 0 "Add group member to role"
    rlAssertGrep "$expAttr1" "$TmpDir/iparole_groupmemberTorole.log"
    rlAssertGrep "$expAttr2" "$TmpDir/iparole_groupmemberTorole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1024 - add duplicate group member" 
    groupName="testgroupadmin"
    roleName="helpdesk"
    type="groups"
    command="addMemberToRole \"$roleName\" $type $groupName all"
    expAttr1="member group: $groupName: This entry is already a member"
    expAttr2="Number of members added 0"
    rlRun "$command > $TmpDir/iparole_groupmemberTorole.log 2>&1" 0 "Add group member to role"
    rlAssertGrep "$expAttr1" "$TmpDir/iparole_groupmemberTorole.log"
    rlAssertGrep "$expAttr2" "$TmpDir/iparole_groupmemberTorole.log"
  rlPhaseEnd


  rlPhaseStartTest "ipa-role-cli-1025 - add nonexistent host member" 
    hostName="nonexistenthost.testrelm.com"
    roleName="helpdesk"
    type="hosts"
    command="addMemberToRole \"$roleName\" $type $hostName all"
    expAttr1="member host: $hostName: no such entry"
    expAttr2="Number of members added 0"
    rlRun "$command > $TmpDir/iparole_hostmemberTorole.log 2>&1" 0 "Add host member to role"
    rlAssertGrep "$expAttr1" "$TmpDir/iparole_hostmemberTorole.log"
    rlAssertGrep "$expAttr2" "$TmpDir/iparole_hostmemberTorole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1026 - add nonexistent hostgroup member" 
    hostgroupName="nonexistenthostgroup"
    roleName="helpdesk"
    type="hostgroups"
    command="addMemberToRole \"$roleName\" $type $hostgroupName all"
    expAttr1="member host group: $hostgroupName: no such entry"
    expAttr2="Number of members added 0"
    rlRun "$command > $TmpDir/iparole_hostgroupmemberTorole.log 2>&1" 0 "Add hostgroup member to role"
    rlAssertGrep "$expAttr1" "$TmpDir/iparole_hostgroupmemberTorole.log"
    rlAssertGrep "$expAttr2" "$TmpDir/iparole_hostgroupmemberTorole.log"
  rlPhaseEnd
}


#############################################
#  test: iparole-remove-member
#############################################
iparole_remove_member()
{
   iparole_remove_member_positive
   iparole_remove_member_negative
}

#############################################
#  test: iparole-remove-member: Postive tests
#############################################
iparole_remove_member_positive()
{
    roleName="helpdesk"
  rlPhaseStartTest "ipa-role-cli-1027 - remove user members" 
    type="users"
    login="testuseradmin"
    login1="testuseradmin1"
    login2="testuseradmin2"
    login3="testuseradmin3"
    login4="testuseradmin4"
    memberlist="$login,$login1,$login2,$login3,$login4"
    command="removeMemberFromRole $memberlist \"$roleName\" $type raw"
    rlRun "$command > $TmpDir/iparole_removeusermemberfromrole.log 2>&1" 0 "Remove user members"
    rlAssertNotGrep "member: uid=testuseradmin,cn=users,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removeusermemberfromrole.log"
    rlAssertNotGrep "member: uid=testuseradmin1,cn=users,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removeusermemberfromrole.log"
    rlAssertNotGrep "member: uid=testuseradmin2,cn=users,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removeusermemberfromrole.log"
    rlAssertNotGrep "member: uid=testuseradmin3,cn=users,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removeusermemberfromrole.log"
    rlAssertNotGrep "member: uid=testuseradmin4,cn=users,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removeusermemberfromrole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1028 - remove group members" 
    groupName="testgroupadmin"
    groupName1="testgroupadmin1"
    groupName2="testgroupadmin2"
    groupName3="testgroupadmin3"
    type="groups"
    memberlist="$groupName,$groupName1,$groupName2,$groupName3"
    command="removeMemberFromRole $memberlist \"$roleName\" $type raw"
    rlRun "$command > $TmpDir/iparole_removegroupmemberfromrole.log 2>&1" 0 "Remove group members"
    rlAssertNotGrep "member: cn=testgroupadmin,cn=groups,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removegroupmemberfromrole.log"
    rlAssertNotGrep "member: cn=testgroupadmin1,cn=groups,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removegroupmemberfromrole.log"
    rlAssertNotGrep "member: cn=testgroupadmin2,cn=groups,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removegroupmemberfromrole.log"
    rlAssertNotGrep "member: cn=testgroupadmin3,cn=groups,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removegroupmemberfromrole.log"
    rlRun "deleteGroup $groupName" 0 "Delete $groupName"
    rlRun "deleteGroup $groupName1" 0 "Delete $groupName1"
    rlRun "deleteGroup $groupName2" 0 "Delete $groupName2"
    rlRun "deleteGroup $groupName3" 0 "Delete $groupName3"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1029 - remove host members" 
    hostName="testhostadmin.testrelm.com"
    hostName1="testhostadmin1.testrelm.com"
    hostName2="testhostadmin2.testrelm.com"
    hostName3="testhostadmin3.testrelm.com"
    memberlist="$hostName,$hostName1,$hostName2,$hostName3"
    type="hosts"
    command="removeMemberFromRole $memberlist \"$roleName\" $type"
    rlRun "$command > $TmpDir/iparole_removehostmemberfromrole.log 2>&1" 0 "Remove host members"
    rlAssertNotGrep "member: fqdn=testhostadmin.testrelm.com,cn=computers,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removehostmemberfromrole.log"
    rlAssertNotGrep "member: fqdn=testhostadmin1.testrelm.com,cn=computers,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removehostmemberfromrole.log"
    rlAssertNotGrep "member: fqdn=testhostadmin2.testrelm.com,cn=computers,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removehostmemberfromrole.log"
    rlAssertNotGrep "member: fqdn=testhostadmin3.testrelm.com,cn=computers,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removehostmemberfromrole.log"
    rlRun "deleteHost $hostName"
    rlRun "deleteHost $hostName1"
    rlRun "deleteHost $hostName2"
    rlRun "deleteHost $hostName3"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1030 - remove hostgroup members" 
    hostgroupName1="testhostgroupadmin1"
    hostgroupName2="testhostgroupadmin2"
    hostgroupName3="testhostgroupadmin3"
    type="hostgroups"
    memberlist="$hostgroupName1,$hostgroupName2,$hostgroupName3"
    command="removeMemberFromRole $memberlist \"$roleName\" $type"
    rlRun "$command > $TmpDir/iparole_removehostgroupmemberfromrole.log 2>&1" 0 "Remove host members"
    rlAssertNotGrep "member: cn=testhostgroupadmin1,cn=hostgroups,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removehostgroupmemberfromrole.log"
    rlAssertNotGrep "member: cn=testhostgroupadmin2,cn=hostgroups,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removehostgroupmemberfromrole.log"
    rlAssertNotGrep "member: cn=testhostgroupadmin3,cn=hostgroups,cn=accounts,dc=testrelm,dc=com" "$TmpDir/iparole_removehostgroupmemberfromrole.log"
    rlRun "deleteHostGroup $hostgroupName1" 0 "Delete $hostgroupName1"
    rlRun "deleteHostGroup $hostgroupName2" 0 "Delete $hostgroupName2"
    rlRun "deleteHostGroup $hostgroupName3" 0 "Delete $hostgroupName3"
  rlPhaseEnd

}


#############################################
#  test: iparole-remove-member: Negative tests
#############################################
iparole_remove_member_negative()
{
    roleName="helpdesk"
  rlPhaseStartTest "ipa-role-cli-1031 - remove blank hostgroup members" 
    type="hostgroups"
    command="removeMemberFromRole \"\" \"$roleName\" $type"
    expMsg="Number of members removed 0"
    rlRun "$command > $TmpDir/iparole_removeblankhostgroupmemberfromrole.log 2>&1" 0 "Remove host members"
    rlAssertGrep "$expMsg" "$TmpDir/iparole_removeblankhostgroupmemberfromrole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1032 - remove missing group members" 
    groupName=""
    type="hostgroups"
    command="removeMemberFromRole \"$groupName\" \"$roleName\" $type"
    expMsg="Number of members removed 0"
    rlRun "$command > $TmpDir/iparole_removemissinggroupmemberfromrole.log 2>&1" 0 "Remove host members"
    rlAssertGrep "$expMsg" "$TmpDir/iparole_removemissinggroupmemberfromrole.log"
  rlPhaseEnd
}



#############################################
#  test: iparole-add-privilege
#############################################
iparole_add_privilege()
{
  iparole_add_privilege_positive
  iparole_add_privilege_negative
}

#############################################
#  test: iparole-add-privilege: Positive tests
#############################################
iparole_add_privilege_positive()
{
  rlRun "kinitAs $ADMINID $ADMINPW"

  rlPhaseStartTest "ipa-role-cli-1033 - add privilege to role --all" 
     privilegeName="user administrators"
     roleName="helpdesk"
     command="addPrivilegeToRole \"$privilegeName\" \"$roleName\" all" 
     expPriv="Privileges: user administrators, modify users and reset passwords, modify group membership"
     rlRun "$command > $TmpDir/iparole_privilegeTorole.log 2>&1" 0 "Adding privilege to role"
     rlAssertGrep "$expPriv" "$TmpDir/iparole_privilegeTorole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1034 - add multiple privileges to role --raw" 
     privilegeName="group administrators,hbac administrator"
     roleName="helpdesk"
     command="addPrivilegeToRole \"$privilegeName\" \"$roleName\" raw" 
     expPriv1="memberof_privilege: group administrators"
     expPriv2="memberof_privilege: hbac administrator"
     rlRun "$command > $TmpDir/iparole_multipleprivilegeTorole.log 2>&1" 0 "Adding privilege to role"
     rlAssertGrep "$expPriv1" "$TmpDir/iparole_multipleprivilegeTorole.log"
     rlAssertGrep "$expPriv2" "$TmpDir/iparole_multipleprivilegeTorole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1035 - add privilege with comma in name to role (bug 797565)" 
     privilegeName="u,r stuff"
     privilegeDesc="privilege with comma in name"
     rlRun "addPrivilege \"$privilegeName\" \"$privilegeDesc\"" 0 "Adding privilege: $privilegeName"
     command="addPrivilegeToRole \"$privilegeName\" \"$roleName\" raw"
     expPriv="memberof_privilege: u,r stuff"
     rlRun "$command > $TmpDir/iparole_privilegewithcommaTorole.log 2>&1"  0 "Adding privilege to role"
     rlAssertGrep "$expPriv" "$TmpDir/iparole_privilegewithcommaTorole.log"
  rlPhaseEnd


}


#############################################
#  test: iparole-add-privilege: Negative tests
#############################################
iparole_add_privilege_negative()
{
  rlRun "kinitAs $ADMINID $ADMINPW"
 
  rlPhaseStartTest "ipa-role-cli-1036 - add duplicate privilege to role"
     privilegeName="user administrators"
     roleName="helpdesk"
     command="addPrivilegeToRole \"$privilegeName\" \"$roleName\" all"  
     expPriv1="privilege: $privilegeName: This entry is already a member"
     expPriv2="Number of privileges added 0"
     rlRun "$command > $TmpDir/iparole_duplicateprivilegeTorole.log 2>&1" 0 "Adding privilege to role"
     rlAssertGrep "$expPriv1" "$TmpDir/iparole_duplicateprivilegeTorole.log"
     rlAssertGrep "$expPriv2" "$TmpDir/iparole_duplicateprivilegeTorole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1037 - add missing privilege to role"
     privilegeName="nonexistent"
     roleName="helpdesk"
     command="addPrivilegeToRole \"$privilegeName\" \"$roleName\" all"  
     expPriv1="privilege: $privilegeName: privilege not found"
     exppriv2="Number of privileges added 0"
     rlRun "$command > $TmpDir/iparole_missingprivilegeTorole.log 2>&1" 0 "Adding privilege to role"
     rlAssertGrep "$expPriv1" "$TmpDir/iparole_missingprivilegeTorole.log"
     rlAssertGrep "$expPriv2" "$TmpDir/iparole_missingprivilegeTorole.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1038 - add no privilege to role (bug 783475)"
     privilegeName=""
     roleName="helpdesk"
     command="addPrivilegeToRole \"$privilegeName\" \"$roleName\" all"  
     expmsg="ipa: error: Better error message than an internal error has occurred "
     rlRun "$command > $TmpDir/iparole_noprivilegeTorole.log 2>&1" 0 "Adding privilege to role"
     rlAssertGrep "$expmsg" "$TmpDir/iparole_noprivilegeTorole.log"
  rlPhaseEnd
}



#############################################
#  test: iparole-remove-privilege: Negative tests
#############################################
iparole_remove_privilege()
{

  rlRun "kinitAs $ADMINID $ADMINPW"
  
   rlPhaseStartTest "ipa-role-cli-1039 - remove multiple privileges from role --raw"
     roleName="helpdesk"
     privilegeList="group administrators,hbac administrator"
     command="removePrivilegeFromRole \"$privilegeList\" \"$roleName\" raw"
     expPriv1="memberof_privilege: group administrators"
     expPriv2="memberof_privilege: hbac administrator"
     expMsg="Number of privileges removed 2"
     rlRun "$command > $TmpDir/iparole_removeprivilegelist.log 2>&1"  0 "Remove multiple privileges"
     rlAssertGrep "$expMsg" "$TmpDir/iparole_removeprivilegelist.log"
     rlAssertNotGrep "$expPriv1" "$TmpDir/iparole_removeprivilegelist.log"
     rlAssertNotGrep "$expPriv2" "$TmpDir/iparole_removeprivilegelist.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-role-cli-1040 - remove a user added privilege from role --all"
     roleName="helpdesk"
     privilegeName="user administrators"
     command="removePrivilegeFromRole \"$privilegeName\" \"$roleName\" all"
     expMsg="Number of privileges removed 1"
     expLeftPrivList="Privileges: modify users and reset passwords, modify group membership"
     rlRun "$command > $TmpDir/iparole_removeprivilege.log 2>&1"  0 "Remove multiple privileges"
     rlAssertGrep "$expMsg" "$TmpDir/iparole_removeprivilege.log"
     rlAssertGrep "$expLeftPrivList" "$TmpDir/iparole_removeprivilege.log"
   rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1041 - remove an existing privilege from role"
     roleName="helpdesk"
     privilegeName="modify group membership"
     command="removePrivilegeFromRole \"$privilegeName\" \"$roleName\" all"
     expMsg="Number of privileges removed 1"
     expLeftPrivList="Privileges: modify users and reset passwords"
     rlRun "$command > $TmpDir/iparole_removeexistingprivilege.log 2>&1"  0 "Remove multiple privileges"
     rlAssertGrep "$expMsg" "$TmpDir/iparole_removeexistingprivilege.log"
     rlAssertGrep "$expLeftPrivList" "$TmpDir/iparole_removeexistingprivilege.log"
   rlPhaseEnd
 
}


#############################################
#  test: iparole-del
#############################################
iparole_del()
{
  rlRun "kinitAs $ADMINID $ADMINPW"
    roleName="nonexistentrole"

    rlPhaseStartTest "ipa-role-cli-1042 - delete role - continue"
     command="ipa role-del \"$roleName\" --continue"
     expmsg="Failed to remove: $roleName"
     rlRun "$command > $TmpDir/iparole_delete.log 2>&1" 0 "Verify error message when deleting in continue mode"
     rlAssertGrep "$expmsg" "$TmpDir/iparole_delete.log"
    rlPhaseEnd

}


#############################################
#  test: iparole-show
#############################################
iparole_show()
{
  rlRun "kinitAs $ADMINID $ADMINPW"
  rlPhaseStartTest "ipa-role-cli-1043 - role show --raw"
     roleName="helpdesk"
    rlRun "verifyRoleAttr \"$roleName\" \"memberof\" \"cn=modify users and reset passwords,cn=privileges,cn=pbac,dc=testrelm,dc=com\" raw" 0 "Verify privilege"
    rlRun "verifyRoleAttr \"$roleName\" \"memberofindirect\" \"cn=change a user password,cn=permissions,cn=pbac,dc=testrelm,dc=com\" raw" 0 "Verify privilege"
   rlPhaseEnd

   rlPhaseStartTest "ipa-role-cli-1044: show role - rights"
    command="ipa role-show \"$roleName\" --all --rights"
    rlRun "$command > $TmpDir/iparole_showrights.log" 0 "Verify Role show with rights"
    rlAssertGrep "attributelevelrights:" "$TmpDir/iparole_showrights.log"
   rlPhaseEnd
}


#############################################
#  test: iparole-find 
#############################################
iparole_find()
{
  rlRun "kinitAs $ADMINID $ADMINPW"
  rlPhaseStartTest "role-find_1044 - --pkey-only test of ipa role"
        rlRun "kinitAs $ADMINID $ADMINPW"
        ipa_command_to_test="role"
        pkey_addstringa="--desc=test-role"
        pkey_addstringb="--desc=test-role"
        pkeyobja="trole"
        pkeyobjb="troleb"
        grep_string='Role\ name:'
        general_search_string=trole
        rlRun "pkey_return_check" 0 "running checks of --pkey-only in sudorule-find"
    rlPhaseEnd

    rlPhaseStartTest "ipa-role-cli-1045 - role find --name"
     criteria="--name=helpdesk"
     attribute="Role name"
     value="helpdesk"
     resultMsg="Number of entries returned 1"
     rlRun "findRole \"$criteria\" \"$attribute\" \"$value\" \"$resultMsg\" all" 0 "find role using \"$criteria\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-role-cli-1046 - role find --sizelimit"
     criteria="--sizelimit=2"
     resultMsg="Number of entries returned 2"
     rlRun "findRole \"$criteria\" \"$resultMsg\"" 0 "find role using \"$criteria\"" 
    rlPhaseEnd

    rlPhaseStartTest "ipa-role-cli-1047 - role find --desc (--raw)"
     criteria="--desc=Helpdesk"
     attribute="description"
     value="Helpdesk"
     resultMsg="Number of entries returned 1"
     rlRun "findRole \"$criteria\" \"$attribute\" \"$value\" \"$resultMsg\" raw" 0 "find role using \"$criteria\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-role-cli-1048 - role find missing name"
     criteria="--name="
     resultMsg="Number of entries returned 0"
     command="ipa role-find \"$criteria\""
     rlRun "$command > $TmpDir/iparole_findrolename.log 2>&1"  0 "find role using \"$criteria\""
     rlAssertNotGrep "$resultMsg" "$TmpDir/iparole_findrolename.log"
    rlPhaseEnd

    rlPhaseStartTest "ipa-role-cli-1049 - role find blank desc"
     criteria="--desc=\"\""
     resultMsg="Number of entries returned 0"
     command="ipa role-find \"$criteria\""
     rlRun "$command > $TmpDir/iparole_findroledesc.log 2>&1"  0 "find role using \"$criteria\""
     rlAssertNotGrep "$resultMsg" "$TmpDir/iparole_findroledesc.log"
    rlPhaseEnd
}


#############################################
#  test: iparole-mod 
#############################################
iparole_mod()
{
   iparole_mod_positive
   iparole_mod_negative
}


iparole_mod_positive()
{
  kinitAs $ADMINID $ADMINPW

  rlPhaseStartTest "ipa-role-cli-1050 - modify role's desc" 
    roleName="helpdesk"
    attr="desc"
    value="Helpdesk Updated"
    rlRun "modifyRole \"$roleName\" $attr \"$value\"" 0 "Modify $roleName to have updated desc"
    rlRun "verifyRoleAttr \"$roleName\" \"Description\" \"$value\" " 0 "Verify Role Desc"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1051 - modify role's name using setattr" 
    roleName="helpdesk"
    attr="setattr"
    value="cn=Helpdesk Updated"
    rlRun "modifyRole \"$roleName\" $attr \"$value\"" 0 "Modify $roleName to have new name"
    rlRun "verifyRoleAttr \"Helpdesk Updated\" \"Role name\" \"helpdesk updated\" " 0 "Verify Role Name"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1052 - modify role's name using rename" 
    roleName="helpdesk"
    attr="rename"
    value="helpdesk"
    rlRun "modifyRole \"helpdesk updated\" $attr \"$value\"" 0 "Modify $roleName to have original name back"
    roleName="helpdesk"
    rlRun "verifyRoleAttr \"$roleName\" \"Role name\" \"$value\" " 0 "Verify Role Name"
  rlPhaseEnd


  rlPhaseStartTest "ipa-role-cli-1053 - modify role's seeAlso using addattr" 
    roleName="helpdesk"
    attr="addattr"
    value="\"seeAlso=cn=HostgroupCLI\""
    rlRun "modifyRole \"$roleName\" $attr \"$value\"" 0 "Modify $roleName to have seeAlso attr"
    rlRun "verifyRoleAttr \"$roleName\" \"seealso\" \"cn=HostgroupCLI\" raw " 0 "Verify Role seeAlso"
    attr="addattr"
    value="\"seeAlso=cn=HostCLI\""
    rlRun "modifyRole \"$roleName\" $attr \"$value\"" 0 "Modify $roleName to have seeAlso attr"
    rlRun "verifyRoleAttr \"$roleName\" \"seealso\" \"cn=HostCLI\" raw" 0 "Verify Role seeAlso"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1054 - modify role's seeAlso using delattr (--rights)" 
    roleName="helpdesk"
    attr="delattr"
    value="\"seeAlso=cn=HostCLI\""
    command="modifyRole \"$roleName\" $attr \"$value\" rights"
    expAttr="seealso: cn=HostgroupCLI"
    rlRun "$command > $TmpDir/iparole_modifyroledelattr.log 2>&1"  0 "Modify $roleName to delete seeAlso attr"
    rlAssertGrep "$expAttr" "$TmpDir/iparole_modifyroledelattr.log"
    rlAssertGrep "attributelevelrights:" "$TmpDir/iparole_modifyroledelattr.log"
  rlPhaseEnd
}


iparole_mod_negative()
{
  kinitAs $ADMINID $ADMINPW
    roleName="helpdesk"

  rlPhaseStartTest "ipa-role-cli-1055 - mod role to addattr multiple attr when only one one value is allowed"
    attr="addattr"
    addDescription="description=AnotherDescriptionNotAllowed"
    command="modifyRole $roleName $attr $addDescription"
    expmsg="ipa: ERROR: description: Only one value allowed."
    rlRun "$command > $TmpDir/iparole_addmultipleattr.log 2>&1" 1 "Verify error message for $roleName"
    rlAssertGrep "$expmsg" "$TmpDir/iparole_addmultipleattr.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1056 - mod role to addattr with invalid syntax"
    attr="addattr"
    addOwner="owner=xyz"
    command="modifyRole $roleName $attr $addOwner"
    expmsg="ipa: ERROR: owner: value #0 invalid per syntax: Invalid syntax."
    rlRun "$command > $TmpDir/iparole_invalidsyntax.log 2>&1" 1 "Verify error message for $roleName"
    rlAssertGrep "$expmsg" "$TmpDir/iparole_invalidsyntax.log"
  rlPhaseEnd


  rlPhaseStartTest "ipa-role-cli-1057 - mod role to use blank desc"
    attr="desc"
    command="modifyRole $roleName $attr"
    expmsg="ipa: ERROR: 'desc' is required"
    rlRun "$command > $TmpDir/iparole_blankdesc.log 2>&1" 1 "Verify error message for $roleName"
    rlAssertGrep "$expmsg" "$TmpDir/iparole_blankdesc.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1058 - mod role to use blank rename"
    attr="rename"
    command="modifyRole $roleName $attr"
    expmsg="ipa: ERROR: invalid 'rename': can't be empty"
    rlRun "$command > $TmpDir/iparole_blankrename.log 2>&1" 1 "Verify error message for $roleName"
    rlAssertGrep "$expmsg" "$TmpDir/iparole_blankrename.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-role-cli-1059 - mod role to delattr required description"
    attr="delattr"
    roleDesc="description=Helpdesk Updated"
    command="modifyRole $roleName $attr $roleDesc"
    expmsg="ipa: ERROR: 'description' is required"
    rlRun "$command > $TmpDir/iparole_deldesc.log 2>&1" 1 "Verify error message for $roleName"
    rlAssertGrep "$expmsg" "$TmpDir/iparole_deldesc.log"
  rlPhaseEnd

}


