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
    permissionName4="ManageUser4"
    permissionName5="ManageUser5"
    permissionName6="ManageGroup1"
    permissionName7="ManageGroup2"
    permissionName8="ManageHost1"
    permissionName9="ManageHostGroup1"
    permissionName10="ManageNetgroup1"
    permissionName11="ManageDNSRecord1"
    permissionName12="TestPermission"
    permissionNameBUG="ManageUser"
    rlPhaseStartTest "Cleanup - delete permissions added for this test suite"
     rlRun "deletePermission $permissionName1" 0 "Deleting $permissionName1"
     rlRun "deletePermission $permissionName2" 0 "Deleting $permissionName2"
     rlRun "deletePermission $permissionName3" 0 "Deleting $permissionName3"
     rlRun "deletePermission $permissionName4" 0 "Deleting $permissionName4"
     rlRun "deletePermission $permissionName5" 0 "Deleting $permissionName5"
     rlRun "deletePermission $permissionName6" 0 "Deleting $permissionName6"
     rlRun "deletePermission $permissionName7" 0 "Deleting $permissionName7"
     rlRun "deletePermission $permissionName8" 0 "Deleting $permissionName8"
     rlRun "deletePermission $permissionName9" 0 "Deleting $permissionName6"
     rlRun "deletePermission $permissionName10" 0 "Deleting $permissionName7"
     rlRun "deletePermission $permissionName11" 0 "Deleting $permissionName8"
     rlRun "deletePermission $permissionName12" 0 "Deleting $permissionName8"
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
   ipapermission_add_positive
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
   ipapermission_params_targetgroup
   ipapermission_params_hostgroup_type
   ipapermission_params_netgroup_filter
   ipapermission_params_dnsrecord_subtree
}

################################################
#  test: ipapermission-add: Positive: Type User 
################################################
ipapermission_params_user_type()
{
    permissionRights="write"
    permissionLocalTarget="--type=user"
    permissionLocalTargetToVerify=`echo $permissionLocalTarget | sed 's/--type=//'`

    permissionName="ManageUser1"
    permissionLocalAttr="carlicense,description"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1001: add permission for type user, with multiple attr"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionRights "Type" $permissionLocalTargetToVerify $permissionLocalAttr   $objectclass
   rlPhaseEnd

   permissionName="ManageUser2"
   permissionRights="read,write"
   rlPhaseStartTest "ipa-permission-cli-1002: add permission for type user, with multiple attr, and multiple permissions"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionRights "Type" $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
   rlPhaseEnd

   permissionName="ManageUser3"
   permissionAddAttr="--addattr=\"description=test\""
   rlPhaseStartTest "ipa-permission-cli-1003: add permission for type user, with multiple attr, multiple permissions, and add an attribute"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionRights "Type" $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
     verifyPermissionRawTypeAttr $permissionName $permissionRights $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
     rlRun "verifyPermissionAttr $permissionName raw \"description\" \"test\"" 0 "Verify Added Attr"
   rlPhaseEnd


   permissionName="ManageUser4"
   permissionAddAttr="--setattr=\"owner=cn=test\""
   rlPhaseStartTest "ipa-permission-cli-1004: add permission for type user, with multiple attr, multiple permissions, and set an attribute"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionRights "Type" $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
     verifyPermissionRawTypeAttr $permissionName $permissionRights $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
     rlRun "verifyPermissionAttr $permissionName raw \"owner\" \"cn=test\"" 0 "Verify Set Attr"
   rlPhaseEnd

   permissionName="ManageUser5"
   permissionAddAttr="--setattr=\"owner=cn=test\"\ --addattr=\"owner=cn=test2\""
   rlPhaseStartTest "ipa-permission-cli-1005: add permission for type user, with multiple attr, multiple permissions, and add and set multivalued attributes"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionRights "Type" $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
     verifyPermissionRawTypeAttr $permissionName $permissionRights $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
     rlRun "verifyPermissionAttr $permissionName raw \"owner\" \"cn=test\"" 0 "Verify Set Attr"
     rlRun "verifyPermissionAttr $permissionName raw \"owner\" \"cn=test2\"" 0 "Verify Set Attr"
   rlPhaseEnd

   #TODO: Add with type and memberof
}


################################################
#  test: ipapermission-add: Positive: Filter Group 
################################################
ipapermission_params_group_filter()
{
    permissionRights="write"
    permissionLocalTarget="--filter=\(\&\(!\(objectclass=posixgroup\)\)\(objectclass=ipausergroup\)\)"
    permissionLocalTargetToVerify=`echo $permissionLocalTarget | sed 's/--filter=//'`
    permissionLocalAttr="member"
    permissionName="ManageGroup1"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1006: add permission using filter for groups"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionRights "Filter" $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
   rlPhaseEnd

}



##################################################
#  test: ipapermission-add: Positive: Subtree Host 
##################################################
ipapermission_params_host_subtree()
{

    permissionRights="write"
    permissionLocalTarget="--subtree=cn=computers,cn=accounts,dc=testrelm,dc=com"
    permissionLocalTargetToVerify="ldap:\/\/\/`echo $permissionLocalTarget | sed 's/--subtree=//'`"
    permissionLocalMemberOf="groupone"
    permissionName="ManageHost1"
    permissionLocalAttr="nshostlocation"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1007: add permission using subtree for hosts"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget  $permissionLocalAttr --memberof=$permissionLocalMemberOf" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionRights "Subtree" $permissionLocalTargetToVerify $permissionLocalAttr $objectclass $permissionLocalMemberOf 
   rlPhaseEnd

}


##################################################
#  test: ipapermission-add: Positive: Targetgroup 
##################################################
ipapermission_params_targetgroup()
{

    permissionRights="write"
    permissionLocalTarget="--targetgroup=groupone"
    permissionLocalAttr="description"
    permissionLocalTargetToVerify=`echo $permissionLocalTarget | sed 's/--targetgroup=//'`
    permissionName="ManageGroup2"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1008: add permission using targetgroup"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionRights "Target\ group" $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
   rlPhaseEnd

}



##################################################
#  test: ipapermission-add: Positive: Type Hostgroup
##################################################
ipapermission_params_hostgroup_type()
{

    permissionRights="add,delete,write"
    permissionLocalTarget="--type=hostgroup"
    permissionLocalTargetToVerify=`echo $permissionLocalTarget | sed 's/--type=//'`

    permissionName="ManageHostgroup1"
    permissionLocalAttr="businessCategory,owner"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1009: add permission for type hostgroup, with multiple attr, and multiple permissions"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionRights "Type" $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
   rlPhaseEnd

}

  
##################################################
#  test: ipapermission-add: Positive: Netgroup filter 
##################################################
ipapermission_params_netgroup_filter()
{

    permissionRights="all"
    permissionLocalTarget="--filter=\"(objectclass=nisNetgroup)\""
    permissionLocalTargetToVerify=`echo $permissionLocalTarget | sed 's/--filter=//'`

    permissionName="ManageNetgroup1"
    permissionLocalAttr="memberNisNetgroup,nisNetgroupTriple,description"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1010: add permission for type netgroup, with multiple attr"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionRights "Filter" $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
   rlPhaseEnd



}



##################################################
#  test: ipapermission-add: Positive: Subtree DNSRecord
##################################################
ipapermission_params_dnsrecord_subtree()
{

    permissionRights="write"
    permissionLocalTarget="--subtree=idnsname=testrelm.com,cn=dns,dc=testrelm,dc=com"
    permissionLocalTargetToVerify="ldap:\/\/\/`echo $permissionLocalTarget | sed 's/--subtree=//'`"

    permissionName="ManageDNSRecord1"
    permissionLocalAttr="nSRecord,aRecord,idnsZoneActive"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1011: add permission for type dnsrecord, with multiple attrs"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionRights "Subtree" $permissionLocalTargetToVerify $permissionLocalAttr $objectclass
   rlPhaseEnd



}




##################################################
#  test: ipapermission-add: Negative Tests
##################################################
ipapermission_add_negative()
{
   ipapermission_add_invalidright
   ipapermission_add_invalidattr
   ipapermission_add_multipletarget
   ipapermission_add_missingtarget
   ipapermission_add_invalidmemberof
   ipapermission_add_invalidtype
   ipapermission_add_invalidfilter
   ipapermission_add_invalidsubtree
   ipapermission_add_invalidtargetgroup 
   ipapermission_add_missingaddsetattr
   ipapermission_add_invalidaddattr
   ipapermission_add_invalidsetattr
   ipapermission_add_duplicateperm
}

###################################################
#  test: ipapermission-add: Negative: Invalid Right
###################################################
ipapermission_add_invalidright()
{

    permissionRights="reads"
    permissionLocalTarget="--type=user"

    permissionName="ManageUser"
    permissionLocalAttr="carlicense,description"

   rlPhaseStartTest "ipa-permission-cli-1012: add permission with invalid right" 
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 
     expmsg="ipa: ERROR: invalid 'permissions': \"$permissionRights\" is not a valid permission"
     rlRun "$command > /tmp/ipapermission_invalidright1.log 2>&1" 1 "Verify error message for $permissionRights"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidright1.log"
   rlPhaseEnd

   permissionRights="\ "
   rlPhaseStartTest "ipa-permission-cli-1013: add permission with missing right" 
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 
     expmsg="ipa: ERROR: 'permissions' is required"
     rlRun "$command > /tmp/ipapermission_invalidright2.log 2>&1" 1 "Verify error message for missing right" 
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidright2.log"
   rlPhaseEnd

}


###################################################
#  test: ipapermission-add: Negative: Invalid Attr 
###################################################
ipapermission_add_invalidattr()
{
    permissionRights="read"
    permissionLocalTarget="--type=user"

    permissionName="ManageUser"
    permissionLocalAttr="invalidattr"

   rlPhaseStartTest "ipa-permission-cli-1014: add permission with invalid attr" 
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 
     expmsg="ipa: ERROR: targetattr \"$permissionLocalAttr\" does not exist in schema. Please add attributeTypes \"$permissionLocalAttr\" to schema if necessary." 
     rlRun "$command > /tmp/ipapermission_invalidattr1.log 2>&1" 1 "Verify error message for $permissionLocalAttr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidattr1.log"
   rlPhaseEnd

   permissionLocalAttr="ipaclientversion"

   rlPhaseStartTest "ipa-permission-cli-1015: add permission with invalid attr for the type being added (bug 783502)" 
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 
     expmsg="ipa: ERROR: attribute \"$permissionLocalAttr\" not allowed"
     rlRun "$command > /tmp/ipapermission_invalidattr2.log 2>&1" 1 "Verify error message for $permissionLocalAttr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidattr2.log"
   rlPhaseEnd

}

######################################################
#  test: ipapermission-add: Negative: Multiple Targets 
######################################################
ipapermission_add_multipletarget()
{
    permissionRights="read"
    permissionLocalTarget1="--type=user"
    permissionLocalTarget2="\ --subtree=cn=users,cn=accounts,dc=testrelm,dc=com"   
    permissionLocalTarget3="\ --filter=\(givenname=xyz\)"

    permissionName="ManageUser"
    permissionLocalAttr="carlicense"

   rlPhaseStartTest "ipa-permission-cli-1016: add permission with multiple targets - type & subtree" 
     command="addPermission $permissionName $permissionRights $permissionLocalTarget1$permissionLocalTarget2 $permissionLocalAttr" 
     expmsg="ipa: ERROR: invalid 'target': type, filter, subtree and targetgroup are mutually exclusive"
     rlRun "$command > /tmp/ipapermission_multipletargets1.log 2>&1" 1 "Verify error message for $permissionLocalAttr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_multipletargets1.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-permission-cli-1017: add permission with multiple targets - type & filter" 
     command="addPermission $permissionName $permissionRights $permissionLocalTarget1$permissionLocalTarget3 $permissionLocalAttr" 
     expmsg="ipa: ERROR: invalid 'target': type, filter, subtree and targetgroup are mutually exclusive"
     rlRun "$command > /tmp/ipapermission_multipletargets2.log 2>&1" 1 "Verify error message for $permissionLocalAttr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_multipletargets2.log"
   rlPhaseEnd

}


######################################################
#  test: ipapermission-add: Negative: Missing Target 
######################################################
ipapermission_add_missingtarget()
{

    permissionName="TestPermission"
    permissionLocalRights="write"
    permissionLocalTarget="--type"

   rlPhaseStartTest "ipa-permission-cli-1018: add permission with missing target for type" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget" 
     expmsg="ipa: error: --type option requires an argument"
     rlRun "$command > /tmp/ipapermission_missingtargets1.log 2>&1" 2 "Verify error message for missing target for Type"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_missingtargets1.log"
   rlPhaseEnd
   rlPhaseStartTest "ipa-permission-cli-1019: add permission with missing target for type (bug 783475)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget=" 
     expmsg="ipa: error: --type option requires an argument"
     rlRun "$command > /tmp/ipapermission_missingtargets2.log 2>&1" 1 "Verify error message for missing target for Type"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_missingtargets2.log"
   rlPhaseEnd

   permissionLocalTarget="--subtree"
   rlPhaseStartTest "ipa-permission-cli-1020: add permission with missing target for subtree" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget" 
     expmsg="ipa: error: --subtree option requires an argument"
     rlRun "$command > /tmp/ipapermission_missingtargets3.log 2>&1" 2 "Verify error message for missing target for subtree"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_missingtargets3.log"
   rlPhaseEnd
   rlPhaseStartTest "ipa-permission-cli-1021: add permission with missing target for subtree (bug 783475)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget=" 
     expmsg="ipa: error: --subtree option requires an argument"
     rlRun "$command > /tmp/ipapermission_missingtargets4.log 2>&1" 1 "Verify error message for missing target for subtree"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_missingtargets4.log"
   rlPhaseEnd

   permissionLocalTarget="--filter"
   rlPhaseStartTest "ipa-permission-cli-1022: add permission with missing target for filter" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget" 
     expmsg="ipa: error: --filter option requires an argument"
     rlRun "$command > /tmp/ipapermission_missingtargets5.log 2>&1" 2 "Verify error message for missing target for filter"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_missingtargets5.log"
   rlPhaseEnd
   rlPhaseStartTest "ipa-permission-cli-1023: add permission with missing target for filter (bug 783475)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget=" 
     expmsg="ipa: error: --filter option requires an argument"
     rlRun "$command > /tmp/ipapermission_missingtargets6.log 2>&1" 1 "Verify error message for missing target for filter"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_missingtargets6.log"
   rlPhaseEnd


}




######################################################
#  test: ipapermission-add: Negative: Invalid Memberof 
######################################################
ipapermission_add_invalidmemberof()
{

    permissionRights="write"
    permissionLocalTarget="--subtree=cn=computers,cn=accounts,dc=testrelm,dc=com"
    permissionMemberOf="nonexistentgroup"
    permissionName="ManageHost"
    permissionLocalAttr="nshostlocation"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1024: add permission using nonexistent memberof group (bug 784329)"
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr --memberof=$permissionMemberOf"
     expmsg="ipa: ERROR: "
     rlRun "$command > /tmp/ipapermission_invalidmemberof1.log 2>&1" 1 "Verify error message for $permissionMemberOf"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidmemberof1.log"
     #TODO: When bug fixed...do not have to delete
     rlRun "deletePermission $permissionName" 0 "Deleting $permissionName"
   rlPhaseEnd

   rlPhaseStartTest "ipa-permission-cli-1025: add permission using missing memberof group"
     command="addPermission $permissionName $permissionRights $permissionLocalTarget  $permissionLocalAttr --memberof"
     expmsg="ipa: error: --memberof option requires an argument"
     rlRun "$command > /tmp/ipapermission_invalidmemberof2.log 2>&1" 2 "Verify error message for $permissionMemberOf"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidmemberof2.log"
   rlPhaseEnd


   rlPhaseStartTest "ipa-permission-cli-1026: add permission using blank memberof group (bug 783475)"
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr --memberof=\"\""
     expmsg="ipa: error: Better error message than an internal error has occurred " 
     rlRun "$command > /tmp/ipapermission_invalidmemberof3.log 2>&1" 1 "Verify error message for $permissionMemberOf"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidmemberof3.log"
   rlPhaseEnd

}




######################################################
#  test: ipapermission-add: Negative: Invalid Type 
######################################################
ipapermission_add_invalidtype()
{
    permissionName="TestPermission"
    permissionLocalRights="write"
    permissionLocalTarget="--type=xyz"

   rlPhaseStartTest "ipa-permission-cli-1027: add permission using invalid type" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget"
     expmsg="ipa: ERROR: invalid 'type': must be one of (u'user', u'group', u'host', u'service', u'hostgroup', u'netgroup', u'dnsrecord')"
     rlRun "$command > /tmp/ipapermission_invalidtype.log 2>&1" 1 "Verify error message for invalid type"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidtype.log"
   rlPhaseEnd

}


######################################################
#  test: ipapermission-add: Negative: Invalid Filter
######################################################
ipapermission_add_invalidfilter()
{
    permissionRights="write"
    permissionLocalTarget="--filter=\(\&\(!\(objectclass\)\)\(objectclass=ipausergroup\)\)"
    permissionLocalAttr="description"
    permissionName="ManageGroup"

   rlPhaseStartTest "ipa-permission-cli-1028: add permission using invalid filter for groups"
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr "
     expmsg="ipa: ERROR: Bad search filter"
     rlRun "$command > /tmp/ipapermission_invalidfilter.log 2>&1" 1 "Verify error message for $filter"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidfilter.log"
   rlPhaseEnd


}


######################################################
#  test: ipapermission-add: Negative: Invalid Subtree 
######################################################
ipapermission_add_invalidsubtree()
{
    permissionLocalRights="write"
    permissionLocalTarget="--subtree=xyz"
    permissionName="TestPermission"

   rlPhaseStartTest "ipa-permission-cli-1029: add permission using invalid subtree"
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget"
     expmsg="ipa: ERROR: ACL Invalid Target Error"
     rlRun "$command > /tmp/ipapermission_invalidsubtree.log 2>&1" 1 "Verify error message for invalid subtree"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidsubtree.log"
   rlPhaseEnd

}


######################################################
#  test: ipapermission-add: Negative: Missing Add/Set Attr 
######################################################
ipapermission_add_missingaddsetattr()
{

    permissionName="TestPermission"
    permissionLocalRights="write"
    permissionLocalTarget="--type=hostgroup"
    permissionLocalAttr="carlicense"
    permissionAddAttr="--addattr"

   rlPhaseStartTest "ipa-permission-cli-1030: add permission with missing addattr value" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr" 
     expmsg="ipa: error: --addattr option requires an argument"
     rlRun "$command > /tmp/ipapermission_missingaddattr1.log 2>&1" 2 "Verify error message for missing addattr" 
     rlAssertGrep "$expmsg" "/tmp/ipapermission_missingaddattr1.log"
   rlPhaseEnd
   rlPhaseStartTest "ipa-permission-cli-1031: add permission with missing addattr value (bug 783475)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr=" 
     expmsg="ipa: error: --addattr option requires an argument"
     rlRun "$command > /tmp/ipapermission_missingaddattr2.log 2>&1" 2 "Verify error message for missing  addattr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_missingaddattr2.log"
   rlPhaseEnd

   permissionSetAttr="--setattr"

   rlPhaseStartTest "ipa-permission-cli-1032: add permission with missing setattr value" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr $permissionSetAttr" 
     expmsg="ipa: error: --setattr option requires an argument"
     rlRun "$command > /tmp/ipapermission_missingsetattr1.log 2>&1" 2 "Verify error message for missing setattr" 
     rlAssertGrep "$expmsg" "/tmp/ipapermission_missingsetattr1.log"
   rlPhaseEnd
   rlPhaseStartTest "ipa-permission-cli-1033: add permission with missing addattr value (bug 783475)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr=" 
     expmsg="ipa: error: --setattr option requires an argument"
     rlRun "$command > /tmp/ipapermission_missingsetattr2.log 2>&1" 2 "Verify error message for missing setattr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_missingsetattr2.log"
   rlPhaseEnd
}




######################################################
#  test: ipapermission-add: Negative: Invalid Add Attr 
######################################################
ipapermission_add_invalidaddattr()
{
   permissionName="TestPermission"
   permissionLocalTarget="--type=user"
   permissionLocalAttr="carlicense"
   permissionAddAttr="--addattr=\"xyz=test\""
   permissionLocalRights="write"

   rlPhaseStartTest "ipa-permission-cli-1034: add permission using invalid add attribute"
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr"
     expmsg="ipa: ERROR: attribute \"xyz\" not allowed"
     rlRun "$command > /tmp/ipapermission_invalidaddattr.log 2>&1" 1 "Verify error message for invalid addattr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidaddattr.log"
   rlPhaseEnd
}


######################################################
#  test: ipapermission-add: Negative: Invalid Set Attr 
######################################################
ipapermission_add_invalidsetattr()
{
   permissionName="TestPermission"
   permissionLocalTarget="--type=user"
   permissionLocalAttr="carlicense"
   permissionLocalRights="write"
   permissionAddAttr="--setattr=\"owner=test\""

   rlPhaseStartTest "ipa-permission-cli-1035: add permission using invalid setattr"
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr"
     expmsg="ipa: ERROR: owner: value #0 invalid per syntax: Invalid syntax."
     rlRun "$command > /tmp/ipapermission_invalidsetattr.log 2>&1" 1 "Verify error message for invalid setattr"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_invalidsetattr.log"
   rlPhaseEnd
}


######################################################
#  test: ipapermission-add: Negative: Duplicate permission 
######################################################
ipapermission_add_duplicateperm()
{
   permissionName="TestPermission"
   permissionLocalTarget="--type=dnsrecord"
   permissionLocalAttr="arecord"
   permissionLocalRights="write"

   rlPhaseStartTest "ipa-permission-cli-1036: add permission - duplicate"
     rlRun "addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr"
     expmsg="ipa: ERROR: This entry already exists"
     rlRun "$command > /tmp/ipapermission_duplicateperm.log 2>&1" 1 "Verify error message for duplicate permission"
     rlAssertGrep "$expmsg" "/tmp/ipapermission_duplicateperm.log"
   rlPhaseEnd
}


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
