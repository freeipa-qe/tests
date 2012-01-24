# Role Based Access Control has 3 sets of clis: permission, privilege and role
#  this will cover permission 

########################
# testsuite
########################
ipapermissionTests() {
    setup
    cleanup
    ipapermission_add
#    ipapermission_del
#    ipapermission_find
#    ipapermission_show_rights
#    ipapermission_mod

#    cleanup
}

########################
# setup
########################
setup()
{
    rlPhaseStartTest "Setup - add users and groups"
       rlRun "kinitAs $ADMINID $ADMINPW"
       rlRun "addGroup testgroup groupone" 0 "adding test group"
    rlPhaseEnd
}


########################
# cleanup
########################
cleanup()
{
    permissionName1="ManageUser1"
    permissionName2="ManageUser2"
    permissionName3="ManageUser3"
    permissionName4="ManageGroup1"
    permissionName5="ManageHost1"
    permissionNameBUG="ManageUser"
    rlPhaseStartTest "Cleanup - delete permissions added for this test suite"
     rlRun "deletePermission $permissionName1" 0 "Deleting $permissionName1"
     rlRun "deletePermission $permissionName2" 0 "Deleting $permissionName2"
     rlRun "deletePermission $permissionName3" 0 "Deleting $permissionName3"
     rlRun "deletePermission $permissionName4" 0 "Deleting $permissionName4"
     rlRun "deletePermission $permissionName5" 0 "Deleting $permissionName5"
     #TODO: This permission shouldn't be added, and so will not be available 
     # for deleting, after bug 783502 is fixed.
     rlRun "deletePermission $permissionNameBUG" 0 "Deleting $permissionNameBUG"
#     rlRun "deleteGroup groupone" 0 "Deleting groupone"
    rlPhaseEnd

}


#############################################
#  test: ipapermission-add 
#############################################
ipapermission_add()
{
#   ipapermission_add_positive
   ipapermission_add_negative
}


##################################################
#  test: ipapermission-add: Positive Tests
##################################################
ipapermission_add_positive()
{
   ipapermission_params_user_type
   ipapermission_params_group_filter
   ipapermission_params_host_subtree
#  ipapermission_params_service_targetgroup
#  ipapermission_params_hostgroup_type
#  ipapermission_params_netgroup_filter
#  ipapermission_params_dnsrecord_subtree
}

################################################
#  test: ipapermission-add: Positive: Type User 
################################################
ipapermission_params_user_type()
{
    permissionRights="read"
    permissionTarget="--type=user"
    permissionTargetToVerify=`echo $permissionTarget | sed 's/--type=//'`

    permissionName="ManageUser1"
    permissionAttr="carlicense,description"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1001: add permission for type user, with multiple attr"
     rlRun "addPermission $permissionName $permissionRights $permissionTarget --attr=$permissionAttr" 0 "Adding $permissionName"
     verifyPermissionTypeAttr $permissionName $permissionRights $permissionTargetToVerify $permissionAttr   $objectclass
   rlPhaseEnd

   permissionName="ManageUser2"
   permissionRights="read,write"
   rlPhaseStartTest "ipa-permission-cli-1002: add permission for type user, with multiple attr, and multiple permissions"
     rlRun "addPermission $permissionName $permissionRights $permissionTarget --attr=$permissionAttr" 0 "Adding $permissionName"
     verifyPermissionTypeAttr $permissionName $permissionRights $permissionTargetToVerify $permissionAttr $objectclass
   rlPhaseEnd

   permissionName="ManageUser3"
   permissionAddAttr="--addattr\ attrs=audio"
   rlPhaseStartTest "ipa-permission-cli-1003: add permission for type user, with multiple attr, multiple permissions, and add an attribute (bug 782861)"
     rlRun "addPermission $permissionName $permissionRights $permissionTarget --attr=$permissionAttr $permissionAddAttr" 0 "Adding $permissionName"
     verifyPermissionTypeAttr $permissionName $permissionRights $permissionTargetToVerify $permissionAttr $objectclass
     verifyPermissionRawTypeAttr $permissionName $permissionRights $permissionTargetToVerify $permissionAttr,audio $objectclass
   rlPhaseEnd


   #TODO: Add with type and memberof
}


################################################
#  test: ipapermission-add: Positive: Filter Group 
################################################
ipapermission_params_group_filter()
{
    permissionRights="write"
    permissionTarget="--filter=\(\&\(!\(objectclass=posixgroup\)\)\(objectclass=ipausergroup\)\)"
    permissionTargetToVerify=`echo $permissionTarget | sed 's/--filter=//'`

    permissionName="ManageGroup1"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1004: add permission using filter for groups"
     rlRun "addPermission $permissionName $permissionRights $permissionTarget" 0 "Adding $permissionName"
     verifyPermissionFilter $permissionName $permissionRights $permissionTargetToVerify $objectclass
   rlPhaseEnd

}



##################################################
#  test: ipapermission-add: Positive: Subtree Host 
##################################################
ipapermission_params_host_subtree()
{

    permissionRights="write"
    permissionTarget="--subtree=cn=computers,cn=accounts,dc=testrelm,dc=com"
    permissionTargetToVerify=`echo $permissionTarget | sed 's/--subtree=//'`
    permissionMemberOf="groupone"
    permissionName="ManageHost1"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1005: add permission using subtree for hosts"
     rlRun "addPermission $permissionName $permissionRights $permissionTarget --memberof=$permissionMemberOf" 0 "Adding $permissionName"
     verifyPermissionSubtree $permissionName $permissionRights $permissionTargetToVerify $permissionMemberOf $objectclass
   rlPhaseEnd

}



##################################################
#  test: ipapermission-add: Negative Tests
##################################################
ipapermission_add_negative()
{
#   ipapermission_add_invalidright
#   ipapermission_add_invalidattr
#   ipapermission_add_invalidtype
#   ipapermission_add_multipletarget
   ipapermission_add_invalidmemberof
#   ipapermission_add_invalidfilter
#   ipapermission_add_invalidsubtree
#   ipapermission_add_invalidtargetgroup 
#   ipapermission_add_invalidaddattr
#   ipapermission_add_invalidsetattr
#   ipapermission_add_duplicateperm
}

###################################################
#  test: ipapermission-add: Negative: Invalid Right
###################################################
ipapermission_add_invalidright()
{

    permissionRights="reads"
    permissionTarget="--type=user"

    permissionName="ManageUser"
    permissionAttr="carlicense,description"

   rlPhaseStartTest "ipa-permission-cli-1005: add permission with invalid right" 
     command="addPermission $permissionName $permissionRights $permissionTarget --attr=$permissionAttr" 
     expmsg="ipa: ERROR: invalid 'permissions': \"$permissionRights\" is not a valid permission"
     rlRun "$command > /tmp/ipapermission_invalidright.log 2>&1" 1 "Verify error message for $permissionRights"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidright.log"
   rlPhaseEnd
}


###################################################
#  test: ipapermission-add: Negative: Invalid Attr 
###################################################
ipapermission_add_invalidattr()
{
    permissionRights="read"
    permissionTarget="--type=user"

    permissionName="ManageUser"
    permissionAttr="invalidattr"

   rlPhaseStartTest "ipa-permission-cli-1006: add permission with invalid attr" 
     command="addPermission $permissionName $permissionRights $permissionTarget --attr=$permissionAttr" 
     expmsg="ipa: ERROR: targetattr \"$permissionAttr\" does not exist in schema. Please add attributeTypes \"$permissionAttr\" to schema if necessary." 
     rlRun "$command > /tmp/ipapermission_invalidattr1.log 2>&1" 1 "Verify error message for $permissionAttr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidattr1.log"
   rlPhaseEnd

   permissionAttr="ipaclientversion"

   rlPhaseStartTest "ipa-permission-cli-1007: add permission with invalid attr for the type being added (bug 783502)" 
     command="addPermission $permissionName $permissionRights $permissionTarget --attr=$permissionAttr" 
     expmsg="ipa: ERROR: attribute \"$permissionAttr\" not allowed"
     rlRun "$command > /tmp/ipapermission_invalidattr2.log 2>&1" 1 "Verify error message for $permissionAttr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidattr2.log"
   rlPhaseEnd

}

######################################################
#  test: ipapermission-add: Negative: Multiple Targets 
######################################################
ipapermission_add_multipletarget()
{
    permissionRights="read"
    permissionTarget1="--type=user"
    permissionTarget2="\ --subtree=cn=users,cn=accounts,dc=testrelm,dc=com"   
    permissionTarget3="\ --filter=\(givenname=xyz\)"

    permissionName="ManageUser"
    permissionAttr="carlicense"

   rlPhaseStartTest "ipa-permission-cli-1008: add permission with multiple targets - type & subtree" 
     command="addPermission $permissionName $permissionRights $permissionTarget1$permissionTarget2 --attr=$permissionAttr" 
     expmsg="ipa: ERROR: invalid 'target': type, filter, subtree and targetgroup are mutually exclusive"
     rlRun "$command > /tmp/ipapermission_multipletargets1.log 2>&1" 1 "Verify error message for $permissionAttr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_multipletargets1.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-permission-cli-1009: add permission with multiple targets - type & filter" 
     command="addPermission $permissionName $permissionRights $permissionTarget1$permissionTarget3 --attr=$permissionAttr" 
     expmsg="ipa: ERROR: invalid 'target': type, filter, subtree and targetgroup are mutually exclusive"
     rlRun "$command > /tmp/ipapermission_multipletargets2.log 2>&1" 1 "Verify error message for $permissionAttr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_multipletargets2.log"
   rlPhaseEnd

}


######################################################
#  test: ipapermission-add: Negative: Invalid Memberof 
######################################################
ipapermission_add_invalidmemberof()
{

    permissionRights="write"
    permissionTarget="--subtree=cn=computers,cn=accounts,dc=testrelm,dc=com"
    permissionMemberOf="nonexistentgroup"
    permissionName="ManageHost"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1005: add permission using nonexistent memberof group (bug 784329)"
     command="addPermission $permissionName $permissionRights $permissionTarget --memberof=$permissionMemberOf"
     expmsg="ipa: ERROR: "
     rlRun "$command > /tmp/ipapermission_invalidmemberof1.log 2>&1" 1 "Verify error message for $permissionMemberOf"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidmemberof1.log"
     #TODO: When bug fixed...do not have to delete
     rlRun "deletePermission $permissionName" 0 "Deleting $permissionName"
   rlPhaseEnd

   rlPhaseStartTest "ipa-permission-cli-1005: add permission using missing memberof group"
     command="addPermission $permissionName $permissionRights $permissionTarget --memberof"
     expmsg="ipa: error: --memberof option requires an argument"
     rlRun "$command > /tmp/ipapermission_invalidmemberof2.log 2>&1" 2 "Verify error message for $permissionMemberOf"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidmemberof2.log"
   rlPhaseEnd


   rlPhaseStartTest "ipa-permission-cli-1005: add permission using blank memberof group (bug 783475)"
     command="addPermission $permissionName $permissionRights $permissionTarget --memberof=\"\""
     expmsg="ipa: error: Better error message than an internal error has occurred " 
     rlRun "$command > /tmp/ipapermission_invalidmemberof3.log 2>&1" 1 "Verify error message for $permissionMemberOf"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidmemberof3.log"
   rlPhaseEnd

}




######################################################
#  test: ipapermission-add: Negative: Invalid Filter
######################################################
ipapermission_add_invalidfilter()
{
    permissionRights="write"
    permissionTarget="--filter=\(\&\(!\(objectclass\)\)\(objectclass=ipausergroup\)\)"

    permissionName="ManageGroup"

   rlPhaseStartTest "ipa-permission-cli-1010: add permission using invalid filter for groups"
     command="addPermission $permissionName $permissionRights $permissionTarget"
     expmsg="ipa: ERROR: Bad search filter"
     rlRun "$command > /tmp/ipapermission_invalidfilter.log 2>&1" 1 "Verify error message for $filter"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidfilter.log"
   rlPhaseEnd


}


#ipapermission_params_user()
#{
#
#}
#
#ipapermission_params_group()
#{
#
#}
#
#ipapermission_params_host()
#{
#
#}
#
#ipapermission_params_service()
#{
#
#}
#
#ipapermission_params_hostgroup()
#{
#
#}
#
#ipapermission_params_netgroup()
#{
#
#}
#
#ipapermission_params_dnsrecord()
#{
#
#}
#
#ipapermission_add_permlist()
#{
#
#}
#
#ipapermission_add_attrlist()
#{
#
#}
#
#
#
##############################################
##  test: ipapermission-del 
##############################################
#ipapermission_del()
#{
#}
#
#
##############################################
##  test: ipapermission-find 
##############################################
#ipapermission_find()
#{
#} 
#
#
##############################################
#    TODO: Bug 782847 prompts for all attr when running mod
#    so will come back to these tests.
##  test: ipapermission-mod
##############################################
#ipapermission_mod()
#{
#}
#
#
##############################################
##  test: ipapermission-show 
##############################################
#ipapermission_show()
#{
#}
#
#
