# Role Based Access Control has 3 sets of clis: privilege, privilege and role
#  this will cover privilege

ipaprivilegeTests() {
 kinitAs $ADMINID $ADMINPW
    ipaprivilege_check
    ipaprivilege_add
    ipaprivilege_add_permission
    ipaprivilege_remove_permission
    ipaprivilege_del_continue
    ipaprivilege_show
    ipaprivilege_mod
    ipaprivilege_find
    cleanupPrivilegesTest
}

########################
# cleanup
########################
cleanupPrivilegesTest()
{
 kinitAs $ADMINID $ADMINPW
 deletePrivilege \"Add User\"
 privilegeName="Add User with owner"
 deletePrivilege \"$privilegeName\"
 privilegeName="Add User with multiple owner"
 deletePrivilege \"$privilegeName\"
 privilegeName="Add User, Group"
 deletePrivilege \"$privilegeName\"
 privilegeName="Modify User"
 deletePrivilege \"$privilegeName\"
 privilegeName="Modify Group"
 deletePrivilege \"$privilegeName\"
 privilegeName="Add User with blank attr"
 deletePrivilege \"$privilegeName\"
}


##############################################################
# Verify Privileges provided by IPA have permissions assigned 
##############################################################
ipaprivilege_check()
{

   rlPhaseStartTest "ipa-privilege-cli-1001: Check IPA provided Privileges have assigned Permissions (bz742327, bz893186)" 
     ipa privilege-find | grep "Privilege name" | cut -d ":" -f2 > $TmpDir/ipaprivilege_check.log
     while read privilegeName 
     do
       command="ipa privilege-show \"$privilegeName\" --all"
       expPermission="Permissions:"
       rlRun "$command > $TmpDir/ipaprivilege_perm.log" 0 "Verify $privilegeName has permissions"
       rlAssertGrep "$expPermission" "$TmpDir/ipaprivilege_perm.log"
     done < "$TmpDir/ipaprivilege_check.log"
   rlPhaseEnd

}




#############################################
#  test: ipaprivilege-add 
#############################################
ipaprivilege_add()
{
   ipaprivilege_add_positive
   ipaprivilege_add_negative
}


##################################################
#  test: ipaprivilege-add: Positive Tests
##################################################
ipaprivilege_add_positive()
{
   kinitAs $ADMINID $ADMINPW

   rlPhaseStartTest "ipa-privilege-cli-1002: add privilege" 
    privilegeName="Add User"
    privilegeDesc="Add User"
    rlRun "addPrivilege \"$privilegeName\" \"$privilegeDesc\"" 0 "Adding $privilegeName"
    rlRun "verifyPrivilegeTargetAttr \"$privilegeName\" \"$privilegeDesc\" \"\"  "
   rlPhaseEnd

  rlPhaseStartTest "ipa-privilege-cli-1003: add privilege with comma" 
    privilegeName="Add User, Group"
    privilegeDesc="Add User, Group"
    rlRun "addPrivilege \"$privilegeName\" \"$privilegeDesc\"" 0 "Adding $privilegeName"
    rlRun "verifyPrivilegeAttr \"$privilegeName\" \"Privilege name\" \"$privilegeName\" " 0 "Verify Privilege Name"
    rlRun "verifyPrivilegeAttr \"$privilegeName\" \"Description\" \"$privilegeDesc\" " 0 "Verify Privilege Desc"
   rlPhaseEnd

   rlPhaseStartTest "ipa-privilege-cli-1004: add privilege with setattr" 
     privilegeName="Add User with owner"
     privilegeDesc="Add User with owner"
     attr="--setattr=\"owner=cn=ABC\""
     rlRun "addPrivilege \"$privilegeName\" \"$privilegeDesc\" $attr" 0 "Adding $privilegeName"
    rlRun "verifyPrivilegeTargetAttr \"$privilegeName\" \"$privilegeDesc\" \"\" "
    rlRun "verifyPrivilegeAttr \"$privilegeName\" \"owner\" \"cn=ABC\" " 
   rlPhaseEnd

   rlPhaseStartTest "ipa-privilege-cli-1005: add privilege with addattr" 
     privilegeName="Add User with multiple owner"
     privilegeDesc="Add User with multiple owner"
     attr="--addattr=\"owner=cn=XYZ\" --addattr=\"owner=cn=ZZZ\""
    rlRun "addPrivilege \"$privilegeName\" \"$privilegeDesc\"  \"$attr\"" 0 "Adding $privilegeName"
    rlRun "verifyPrivilegeTargetAttr \"$privilegeName\" \"$privilegeDesc\" \"\""
    rlRun "verifyPrivilegeAttr \"$privilegeName\" \"owner\" \"cn=ZZZ, cn=XYZ\" " 
   rlPhaseEnd

   rlPhaseStartTest "ipa-privilege-cli-1006: add privilege - raw"
     privilegeName="Modify User"
     privilegeDesc="Modify User"
     command="ipa privilege-add \"$privilegeName\" --desc \"$privilegeDesc\" --all --raw"
     rlRun "$command > $TmpDir/ipaprivilege_addraw.log" 0 "Verify Privilege add with raw"
     objectclassOccurences=`rlAssertGrep "objectClass:" "$TmpDir/ipaprivilege_addraw.log" -c | cut -d ":" -f1`

     if [ "$objectclassOccurences" = 3 ]; then
        rlPass "Found expected objectclasses for $privilegeName"
     else
        rlFail "Did not find expected objectclasses for $privilegeName"
     fi
    rlPhaseEnd

   rlPhaseStartTest "ipa-privilege-cli-1007: add privilege - all"
     privilegeName="Modify Group"
     privilegeDesc="Modify Group"
     command="ipa privilege-add \"$privilegeName\" --desc \"$privilegeDesc\" --all"
     rlRun "$command > $TmpDir/ipaprivilege_addall.log" 0 "Verify Privilege add with all"
     objectclassOccurences=`rlAssertGrep "objectclass:" "$TmpDir/ipaprivilege_addall.log" -c | cut -d ":" -f1`

     if [ "$objectclassOccurences" = 1 ]; then
        rlPass "Found expected objectclass for $privilegeName"
     else
        rlFail "Did not find expected objectclass for $privilegeName"
     fi
    rlPhaseEnd

}


##################################################
#  test: ipaprivilege-add: Negative Tests
##################################################
ipaprivilege_add_negative()
{

rlLog "Negative privilege tests"
   rlPhaseStartTest "ipa-privilege-cli-1008: add privilege with invalid setattr" 
     privilegeName="Add User with invalid attr"
     privilegeDesc="Add User with invalid attr"
     attr="--setattr=\"xyz=XYZ\""
     command="addPrivilege \"$privilegeName\" \"$privilegeDesc\" $attr"
     expmsg="ipa: ERROR: attribute \"xyz\" not allowed"
     rlRun "$command > $TmpDir/ipaprivilege_invalidattr1.log 2>&1" 1 "Verify error message for $privilegeName"
     rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_invalidattr1.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-privilege-cli-1009: add privilege with invalid addattr" 
     privilegeName="Add User with invalid attr"
     privilegeDesc="Add User with invalid attr"
     attr="--addattr=\"xyz=XYZ\""
     command="addPrivilege \"$privilegeName\" \"$privilegeDesc\" $attr"
     expmsg="ipa: ERROR: attribute \"xyz\" not allowed"
     rlRun "$command > $TmpDir/ipaprivilege_invalidattr2.log 2>&1" 1 "Verify error message for $privilegeName"
     rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_invalidattr2.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-privilege-cli-1010: add privilege with blank setattr (bug 816574)" 
     privilegeName="Add User with blank attr"
     privilegeDesc="Add User with blank attr"
     attr="--setattr=\"\""
     command="addPrivilege \"$privilegeName\" \"$privilegeDesc\" $attr"
     expmsg="Added privilege \"Add User with blank attr\""
     rlRun "$command > $TmpDir/ipaprivilege_blankattr.log 2>&1" 0 "Verify $privilegeName privilege is added successfully"
     rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_blankattr.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-privilege-cli-1011: add privilege with blank desc" 
     privilegeName="Add User with blank desc"
     privilegeDesc="\"\""
     command="addPrivilege \"$privilegeName\" \"$privilegeDesc\""
     expmsg="ipa: ERROR: 'desc' is required"
     rlRun "$command > $TmpDir/ipaprivilege_blankdesc.log 2>&1" 1 "Verify error message for $privilegeName"
     rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_blankdesc.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-privilege-cli-1012: add duplicate privilege" 
    privilegeName="Add User"
    privilegeDesc="Add User"
    command="addPrivilege \"$privilegeName\" \"$privilegeDesc\""
     expmsg="ipa: ERROR: privilege with name \"$privilegeName\" already exists"
     rlRun "$command > $TmpDir/ipaprivilege_duplicateprivilege.log 2>&1" 1 "Verify error message for $privilegeName"
     rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_duplicateprivilege.log"
   rlPhaseEnd
}


#############################################
#  test: ipaprivilege-add-permission 
#############################################
ipaprivilege_add_permission()
{
   ipaprivilege_add_permission_positive
   ipaprivilege_add_permission_negative
}


##################################################
#  test: ipaprivilege-add-permission: Postive Tests
##################################################
ipaprivilege_add_permission_positive()
{

  rlPhaseStartTest "ipa-privilege-cli-1013: add multiple permissions to privilege" 
    privilegeName="Add User"
    permissionList="--permission=\"Delete HBAC rule\" --permission=\"Modify HBAC rule\" --permission=\"Add HBAC rule\""
    permissionVerifyList=`echo $permissionList | sed 's/--permission=/,/g' | sed 's/^,//'`
    rlRun "addPermissionToPrivilege $permissionList \"$privilegeName\"" 0 "Adding $permissionList to $privilegeName"
    rlRun "verifyPrivilegeAttr \"$privilegeName\" Permissions $permissionVerifyList " 0 "Verify Permissions for a Privilege"
  rlPhaseEnd

  rlPhaseStartTest "ipa-privilege-cli-1014: add permission to IPA-provided privilege" 
    privilegeName="HBAC Administrator"
    permissionList="--permission=add groups"
    expectedPermissionList="Add Groups, Manage HBAC service group membership, Manage HBAC rule membership, Add HBAC services, Delete HBAC rule, Modify HBAC rule, Delete HBAC service groups, Delete HBAC services, Add HBAC rule, Add HBAC service groups"
    rlRun "addPermissionToPrivilege \"$permissionList\" \"$privilegeName\"" 0 "Adding $permissionList to $privilegeName"
    rlRun "verifyPrivilegeAttr \"$privilegeName\" \"Permissions\" \"$expectedPermissionList\" " 0 "Verify Permissions for a Privilege"
  rlPhaseEnd

}



##################################################
#  test: ipaprivilege-add-permission: Negative Tests
##################################################
ipaprivilege_add_permission_negative()
{

  rlPhaseStartTest "ipa-privilege-cli-1015: add nonexistent permission to privilege" 
    privilegeName="Add User"
    permissionList="--permission=\"non-existent permission\""
    permissionVerifyList=`echo $permissionList | sed 's/--permission=//g'`
    permissionVerifyList2=`echo $permissionVerifyList | sed 's/\"//g'`
    command="addPermissionToPrivilege $permissionList \"$privilegeName\""
    expmsg="permission: $permissionVerifyList2: permission not found"
    rlRun "$command > $TmpDir/ipaprivilege_nonexistentperm1.log 2>&1" 0 "Verify error message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_nonexistentperm1.log"
  rlPhaseEnd


  rlPhaseStartTest "ipa-privilege-cli-1016: add duplicate permission to privilege" 
    privilegeName="Add User"
    permissionList="--permission=\"add hbac rule\""
    permissionVerifyList=`echo $permissionList | sed 's/--permission=//g'`
    permissionVerifyList2=`echo $permissionVerifyList | sed 's/\"//g'`
    command="addPermissionToPrivilege $permissionList \"$privilegeName\""
    expmsg="permission: $permissionVerifyList2: This entry is already a member"
    rlRun "$command > $TmpDir/ipaprivilege_nonexistentperm2.log 2>&1" 0 "Verify error message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_nonexistentperm2.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-privilege-cli-1017: add permission to nonexistent privilege" 
    privilegeName="nonexistent privilege"
    permissionList="--permission=\"add hbac rule\""
    command="addPermissionToPrivilege $permissionList \"$privilegeName\""
    expmsg="ipa: ERROR: $privilegeName: privilege not found"
    rlRun "$command > $TmpDir/ipaprivilege_nonexistentperm3.log 2>&1" 0 "Verify error message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_nonexistentperm3.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-privilege-cli-1018: add blank permission to privilege (bug 816624)" 
    privilegeName="Add User"
    permissionList=""
    command="addPermissionToPrivilege $permissionList \"$privilegeName\""
    expmsg="Number of permissions added 0"
    rlRun "$command > $TmpDir/ipaprivilege_nonexistentperm4.log 2>&1" 0 "Verify message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_nonexistentperm4.log"
    rlRun "cat $TmpDir/ipaprivilege_nonexistentperm4.log"
  rlPhaseEnd

}



#############################################
#  test: ipaprivilege-remove-permission 
#############################################
ipaprivilege_remove_permission()
{
   ipaprivilege_remove_permission_positive
   ipaprivilege_remove_permission_negative
}

ipaprivilege_remove_permission_positive()
{
  rlPhaseStartTest "ipa-privilege-cli-1019: remove multiple permissions to privilege" 
    privilegeName="Add User"
    permissionList="--permission=add hbac rule --permission=delete hbac rule"
    expectedPermissionListLeftForPrivilege="modify hbac rule"
    rlRun "removePermissionFromPrivilege \"$permissionList\" \"$privilegeName\"" 0 "Removing $permissionList from $privilegeName"
    rlRun "verifyPrivilegeAttr \"$privilegeName\" \"Permissions\" \"$expectedPermissionListLeftForPrivilege\" " 0 "Verify Permissions for a Privilege"
  rlPhaseEnd

  rlPhaseStartTest "ipa-privilege-cli-1020: remove permission from IPA-provided privilege (permission added by user)" 
    privilegeName="HBAC Administrator"
    permissionList="--permission=add groups"
    expectedPermissionListLeftForPrivilege="Manage HBAC service group membership, Manage HBAC rule membership, Add HBAC services, Delete HBAC rule, Modify HBAC rule, Delete HBAC service groups, Delete HBAC services, Add HBAC rule, Add HBAC service groups"
    rlRun "removePermissionFromPrivilege \"$permissionList\" \"$privilegeName\"" 0 "Removing $permissionList from $privilegeName"
    rlRun "verifyPrivilegeAttr \"$privilegeName\" \"Permissions\" \"$expectedPermissionListLeftForPrivilege\" " 0 "Verify Permissions for a Privilege"
  rlPhaseEnd

  rlPhaseStartTest "ipa-privilege-cli-1021: remove permission from IPA-provided privilege (bug 797916)" 
    privilegeName="HBAC Administrator"
    permissionList="--permission=add hbac rule"
    expectedPermissionListLeftForPrivilege="delete hbac rule, modify hbac rule, manage hbac rule membership, add hbac services, delete hbac services, add hbac service groups, delete hbac service groups, manage hbac service group membership"
    expectedPermissionListLeftForPrivilege="Manage HBAC service group membership, Manage HBAC rule membership, Add HBAC services, Delete HBAC rule, Modify HBAC rule, Delete HBAC service groups, Delete HBAC services, Add HBAC service groups"
    rlRun "removePermissionFromPrivilege \"$permissionList\" \"$privilegeName\"" 0 "Removing $permissionList from $privilegeName"
    rlRun "verifyPrivilegeAttr \"$privilegeName\" \"Permissions\" \"$expectedPermissionListLeftForPrivilege\" " 0 "Verify Permissions for a Privilege"
  rlPhaseEnd
}


ipaprivilege_remove_permission_negative()
{
  rlPhaseStartTest "ipa-privilege-cli-1022: remove nonexistent permission from privilege" 
    privilegeName="Add User"
    permissionList="--permission=non-existent permission"
    command="removePermissionFromPrivilege \"$permissionList\" \"$privilegeName\""
    expmsg="permission: $permissionList: permission not found"
    rlRun "$command > $TmpDir/ipaprivilege_nonexistentperm.log 2>&1" 0 "Verify error message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_nonexistentperm.log"
  rlPhaseEnd


  rlPhaseStartTest "ipa-privilege-cli-1023: remove permission from nonexistent privilege" 
    privilegeName="nonexistent privilege"
    permissionList="--permission=add hbac rule"
    command="removePermissionFromPrivilege \"$permissionList\" \"$privilegeName\""
    expmsg="ipa: ERROR: $privilegeName: privilege not found"
    rlRun "$command > $TmpDir/ipaprivilege_nonexistentperm.log 2>&1" 0 "Verify error message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_nonexistentperm.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-privilege-cli-1024: remove blank permission from privilege (bug 816624)" 
    privilegeName="Add User"
    permissionList=""
    command="removePermissionFromPrivilege \"$permissionList\" \"$privilegeName\""
    expmsg="Number of permissions removed 0"
    rlRun "$command > $TmpDir/ipaprivilege_nonexistentperm.log 2>&1" 0 "Verify number of permissions removed is 0"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_nonexistentperm.log"
  rlPhaseEnd

}

#############################################
#  test: ipaprivilege-del : continue
#############################################
ipaprivilege_del_continue()
{
    privilegeName="nonexistent privilege"

    rlPhaseStartTest "ipa-privilege-cli-1025: delete privilege - continue"
     command="ipa privilege-del \"$privilegeName\" --continue"
     expmsg="Failed to remove: $privilegeName"
     rlRun "$command > $TmpDir/ipaprivilege_delete.log 2>&1" 0 "Verify error message when deleting in continue mode"
     rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_delete.log"
    rlPhaseEnd

}


#############################################
#  test: ipaprivilege-show 
#############################################
ipaprivilege_show()
{
   privilegeName="Host Group Administrators"

    rlPhaseStartTest "ipa-privilege-cli-1026: show privilege - raw (bz 893718-pilnser)"
     command="ipa privilege-show \"$privilegeName\" --all --raw"
     rlRun "$command > $TmpDir/ipaprivilege_showraw.log" 0 "Verify Privilege show with raw"
     memberindirectOccurences=`rlAssertGrep "memberindirect:" "$TmpDir/ipaprivilege_showraw.log" -c | cut -d ":" -f1`
     memberofOccurences=`rlAssertGrep "memberof:" "$TmpDir/ipaprivilege_showraw.log" -c | cut -d ":" -f1`
     objectclassOccurences=`rlAssertGrep "objectclass:" "$TmpDir/ipaprivilege_showraw.log" -c | cut -d ":" -f1`

     if [ "$memberindirectOccurences" = 1  -a "$memberofOccurences" = 4 -a "$objectclassOccurences" = 3 ]; then
        rlPass "Found expected raw attributes for $privilegeName"
     else
        rlFail "Did not find expected raw attributes for $privilegeName"
     fi
    rlPhaseEnd


    rlPhaseStartTest "ipa-privilege-cli-1027: show privilege - rights"
     command="ipa privilege-show \"$privilegeName\" --all --rights"
     rlRun "$command > $TmpDir/ipaprivilege_showrights.log" 0 "Verify Privilege show with raw"
     rlAssertGrep "attributelevelrights:" "$TmpDir/ipaprivilege_showrights.log"
    rlPhaseEnd
}


#############################################
#  test: ipaprivilege-mod
#############################################
ipaprivilege_mod()
{
   ipaprivilege_mod_positive
   ipaprivilege_mod_negative
}


#############################################
#  test: ipaprivilege-mod: Positive
#############################################
ipaprivilege_mod_positive()
{
   privilegeName="Netgroups Administrators"

  rlPhaseStartTest "ipa-privilege-cli-1028: mod privilege desc" 
    newPrivilegeDesc="NetgroupsAdmin"
    attr="desc"
    rlRun "modifyPrivilege \"$privilegeName\" $attr \"$newPrivilegeDesc\""
    rlRun "verifyPrivilegeAttr \"$privilegeName\" \"Description\" \"$newPrivilegeDesc\" " 0 "Verify New Privilege Desc"
  rlPhaseEnd
   
  rlPhaseStartTest "ipa-privilege-cli-1029: rename privilege" 
    newPrivilegeName="NetgroupsAdmin"
    attr="rename"
    rlRun "modifyPrivilege \"$privilegeName\" $attr \"$newPrivilegeName\""
    rlRun "verifyPrivilegeAttr \"$newPrivilegeName\" \"Privilege name\" \"$newPrivilegeName\" " 0 "Verify New Privilege Name"
  rlPhaseEnd


  privilegeName="NetgroupsAdmin"
  rlPhaseStartTest "ipa-privilege-cli-1030: mod privilege to use addattr" 
    attr1="addattr"
    addOwner1="owner=cn=abc"
    attr2="addattr"
    addOwner2="owner=cn=def"
    rlRun "modifyPrivilege \"$privilegeName\" $attr1 $addOwner1 $attr2 $addOwner2"
    rlRun "verifyPrivilegeAttr \"$privilegeName\" \"owner\" \"cn=def, cn=abc\" " 0 "Verify added owner for Privilege"
  rlPhaseEnd


  # Cleanup changes made:
    attr1="desc"
    privilegeDesc="NetgroupsAdministrators"
    attr2="delattr"
    delOwner1="owner=cn=abc"
    attr3="delattr"
    delOwner2="owner=cn=def"
  
    #Cleanup
    modifyPrivilege \"$privilegeName\" $attr1 $privilegeDesc $attr2 $delOwner1 $attr2 $delOwner2
}

#############################################
#  test: ipaprivilege-mod: Negative
#############################################
ipaprivilege_mod_negative()
{
  privilegeName="NetgroupsAdmin"

  rlPhaseStartTest "ipa-privilege-cli-1031: mod privilege to addattr multiple attr when only one one value is allowed" 
    attr="addattr"
    addDescription="description=AnotherDescriptionNotAllowed"
    command="modifyPrivilege $privilegeName $attr $addDescription"
    expmsg="ipa: ERROR: description: Only one value allowed."
    rlRun "$command > $TmpDir/ipaprivilege_addmultipleattr.log 2>&1" 1 "Verify error message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_addmultipleattr.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-privilege-cli-1032: mod privilege to addattr with invalid syntax" 
    attr="addattr"
    addOwner="owner=xyz"
    command="modifyPrivilege $privilegeName $attr $addOwner"
    expmsg="ipa: ERROR: owner: Invalid syntax."
## in f18 - seeing error    expmsg="ipa: ERROR: owner: value #0 invalid per syntax: Invalid syntax."
    rlRun "$command > $TmpDir/ipaprivilege_invalidsyntax.log 2>&1" 1 "Verify error message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_invalidsyntax.log"
  rlPhaseEnd


  rlPhaseStartTest "ipa-privilege-cli-1033: mod privilege to use blank desc"
    attr="desc"
    command="modifyPrivilege $privilegeName $attr"
    expmsg="ipa: ERROR: 'desc' is required"
    rlRun "$command > $TmpDir/ipaprivilege_blankdesc.log 2>&1" 1 "Verify error message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_blankdesc.log"
  rlPhaseEnd

  rlPhaseStartTest "ipa-privilege-cli-1034: mod privilege to use blank rename"
    attr="rename"
    command="modifyPrivilege $privilegeName $attr"
    expmsg="ipa: ERROR: invalid 'rename': can't be empty"
    rlRun "$command > $TmpDir/ipaprivilege_blankrename.log 2>&1" 1 "Verify error message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_blankrename.log"
  rlPhaseEnd


  rlPhaseStartTest "ipa-privilege-cli-1035: mod privilege to rename to same name"
    attr="rename"
    command="modifyPrivilege $privilegeName $attr $privilegeName"
    expmsg="ipa: ERROR: no modifications to be performed"
    rlRun "$command > $TmpDir/ipaprivilege_samerename.log 2>&1" 1 "Verify error message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_samerename.log"
  rlPhaseEnd



  rlPhaseStartTest "ipa-privilege-cli-1036: mod privilege to delattr required description"
    attr="delattr"
    privilegeDesc="description=NetgroupsAdministrators"
    command="modifyPrivilege $privilegeName $attr $privilegeDesc"
    expmsg="ipa: ERROR: 'description' is required"
    rlRun "$command > $TmpDir/ipaprivilege_deldesc.log 2>&1" 1 "Verify error message for $privilegeName"
    rlAssertGrep "$expmsg" "$TmpDir/ipaprivilege_deldesc.log"
  rlPhaseEnd


   #Cleanup
   ipa privilege-mod --rename="Netgroups Administrators" NetgroupsAdmin
}



#############################################
#  test: ipaprivilege-find
#############################################
ipaprivilege_find()
{
    rlPhaseStartTest "ipa-privilege-cli-1037: --pkey-only test of ipa privilege"
	rlRun "kinitAs $ADMINID $ADMINPW"
	ipa_command_to_test="privilege"
	pkey_addstringa="--desc=test-priv"
	pkey_addstringb="--desc=test-priv"
	pkeyobja="tpriv"
	pkeyobjb="tprivb"
	grep_string='Privilege\ name'
	general_search_string=tpriv
	rlRun "pkey_return_check" 0 "running checks of --pkey-only in privilege-find"
    rlPhaseEnd

    rlPhaseStartTest "ipa-privilege-cli-1038: privilege find --name"
     criteria="--name=Automount Administrators"
     attribute="Privilege name"
     value="Automount Administrators"
     resultMsg="Number of entries returned 1"
     rlRun "findPrivilege \"$criteria\" \"$attribute\" \"$value\" \"$resultMsg\" all" 0 "find privilege using \"$criteria\""
    rlPhaseEnd

   
    rlPhaseStartTest "ipa-privilege-cli-1039: privilege find --desc (--raw)"
     criteria="--desc=Automount Administrators"
     attribute="description"
     value="Automount Administrators"
     resultMsg="Number of entries returned 1"
     rlRun "findPrivilege \"$criteria\" \"$attribute\" \"$value\" \"$resultMsg\" raw" 0 "find privilege using \"$criteria\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-privilege-cli-1040: privilege find --sizelimit"
     criteria="--sizelimit=2"
     resultMsg="Number of entries returned 2"
     rlRun "findPrivilege \"$criteria\" \"$resultMsg\"" 0 "find privilege using \"$criteria\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-privilege-cli-1041: privilege find  - missing name"
     criteria="--name="
     resultMsg="Number of entries returned 0"
     command="ipa privilege-find \"$criteria\""
     rlRun "$command > $TmpDir/iparole_findprivilegename.log 2>&1"  0 "find privilege using \"$criteria\""
     rlAssertNotGrep "$resultMsg" "$TmpDir/iparole_findprivilegename.log"
    rlPhaseEnd

    rlPhaseStartTest "ipa-privilege-cli-1042: privilege find - blank desc"
     criteria="--desc=\"\""
     resultMsg="Number of entries returned 0"
     command="ipa privilege-find \"$criteria\""
     rlRun "$command > $TmpDir/iparole_findprivilegedesc.log 2>&1"  0 "find privilege using \"$criteria\""
     rlAssertNotGrep "$resultMsg" "$TmpDir/iparole_findprivilegedesc.log" 0 "find privilege using \"$criteria\""
    rlPhaseEnd
}
