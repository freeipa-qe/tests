# Role Based Access Control has 3 sets of clis: permission, privilege and role
#  this will cover permission 

########################
# testsuite
########################
ipapermissionTests() {
    setupPermissionTests
    ipapermission_add
    ipapermission_show_rights
    ipapermission_del_continue
    ipapermission_find
    ipapermission_mod
    cleanupPermissionTests
}

########################
# setup
########################
setupPermissionTests()
{
   rlRun "kinitAs $ADMINID $ADMINPW"
   groupName="groupone"
   groupDesc="groupone"
   rlRun "addGroup $groupName $groupDesc"
}


########################
# cleanup
########################
cleanupPermissionTests()
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
    permissionName13="APermission"
    #permissionNameBUG="ManageUser"
    permissionName783502="ManageUser_783502"
    rlRun "deletePermission $permissionName1" 0 "Deleting $permissionName1"
    rlRun "deletePermission $permissionName2" 0 "Deleting $permissionName2"
    rlRun "deletePermission $permissionName3" 0 "Deleting $permissionName3"
    rlRun "deletePermission $permissionName4" 0 "Deleting $permissionName4"
    rlRun "deletePermission $permissionName5" 0 "Deleting $permissionName5"
    rlRun "deletePermission $permissionName6" 0 "Deleting $permissionName6"
    rlRun "deletePermission $permissionName7" 0 "Deleting $permissionName7"
    rlRun "deletePermission $permissionName8" 0 "Deleting $permissionName8"
    rlRun "deletePermission $permissionName9" 0 "Deleting $permissionName9"
    rlRun "deletePermission $permissionName10" 0 "Deleting $permissionName10"
    rlRun "deletePermission $permissionName11" 0 "Deleting $permissionName11"
    rlRun "deletePermission $permissionName12" 0 "Deleting $permissionName12"
    rlRun "deletePermission $permissionName13" 0 "Deleting $permissionName13"
    rlRun "deletePermission $permissionName783502" 0 "Deleting $permissionName783502"
    rlRun "deleteGroup groupone" 0 "Deleting groupone"
    ipa permission-mod --permissions=add  "add Automount keys" --attrs= 
#NAMITA
    ipa permission-mod --attrs=userpassword --attrs=krbprincipalkey --attrs=sambalmpassword --attrs=sambantpassword --attrs=passwordhistory --all "Change a user password"
    ipa permission-mod --type=netgroup "Remove Netgroups"
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
    permissionRights="--permissions=write"
    permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalTarget="--type=user"
    permissionLocalTargetToVerify=`echo $permissionLocalTarget | sed 's/--type=//'`

    permissionName="ManageUser1"
    permissionLocalAttr="--attr=carlicense --attr=description"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1001 - add permission for type user, with multiple attr"
     rlRun "addPermission $permissionName \"$permissionRights\" $permissionLocalTarget \"$permissionLocalAttr\"" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Type" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass
   rlPhaseEnd

   permissionName="ManageUser2"
   permissionRights="--permissions=read --permissions=write"
   permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalAttr="--attr=carlicense --attr=description"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`
   rlPhaseStartTest "ipa-permission-cli-1003 - add permission for type user, with multiple attr, and multiple permissions"
     rlRun "addPermission $permissionName \"$permissionRights\" $permissionLocalTarget \"$permissionLocalAttr\"" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Type" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass
   rlPhaseEnd

   permissionName="ManageUser3"
   permissionAddAttr="--addattr=\"description=test\""
   permissionRights="--permissions=read --permissions=write"
   permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalAttr="--attr=carlicense --attr=description"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`
   rlPhaseStartTest "ipa-permission-cli-1004 - add permission for type user, with multiple attr, multiple permissions, and add an attribute"
     rlRun "addPermission $permissionName \"$permissionRights\" $permissionLocalTarget \"$permissionLocalAttr\" $permissionAddAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Type" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass
     verifyPermissionRawTypeAttr $permissionName $objectclass
     rlRun "verifyPermissionAttr $permissionName raw \"description\" \"test\"" 0 "Verify Added Attr"
   rlPhaseEnd


   permissionName="ManageUser4"
   permissionAddAttr="--setattr=\"owner=cn=test\""
   permissionRights="--permissions=read --permissions=write"
   permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalAttr="--attr=carlicense --attr=description"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`
   rlPhaseStartTest "ipa-permission-cli-1005 - add permission for type user, with multiple attr, multiple permissions, and set an attribute"
     rlRun "addPermission $permissionName \"$permissionRights\" $permissionLocalTarget \"$permissionLocalAttr\" $permissionAddAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Type" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass
     verifyPermissionRawTypeAttr $permissionName $objectclass
     rlRun "verifyPermissionAttr $permissionName raw \"owner\" \"cn=test\"" 0 "Verify Set Attr"
   rlPhaseEnd

   permissionName="ManageUser5"
   permissionAddAttr="--setattr=\"owner=cn=test\"\ --addattr=\"owner=cn=test2\""
   permissionRights="--permissions=read --permissions=write"
   permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalAttr="--attr=carlicense --attr=description"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`
   rlPhaseStartTest "ipa-permission-cli-1006 - add permission for type user, with multiple attr, multiple permissions, and add and set multivalued attributes"
     rlRun "addPermission $permissionName \"$permissionRights\" $permissionLocalTarget \"$permissionLocalAttr\" $permissionAddAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Type" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass
     verifyPermissionRawTypeAttr $permissionName $objectclass
     rlRun "verifyPermissionAttr $permissionName raw \"owner\" \"cn=test\"" 0 "Verify Set Attr"
     rlRun "verifyPermissionAttr $permissionName raw \"owner\" \"cn=test2\"" 0 "Verify Set Attr"
   rlPhaseEnd


    permissionRights="--permissions=read"
    permissionLocalTarget="--type=user"
    permissionName="ManageUser_783502"
    permissionLocalAttr="--attr=ipaclientversion"
   rlPhaseStartTest "ipa-permission-cli-1016 - add permission with invalid attr for the type being added (bug 783502)" 
     rlRun "addPermission $permissionName \"$permissionRights\" $permissionLocalTarget \"$permissionLocalAttr\"" 0 "Verify bz 783502 for $permissionLocalAttr" 
     rlRun "verifyPermissionAttr \"$permissionName\" all \"Permission name\" \"$permissionName\"" 0 "Verify Permissions"
   rlPhaseEnd
   #TODO: Add with type and memberof
}


################################################
#  test: ipapermission-add: Positive: Filter Group 
################################################
ipapermission_params_group_filter()
{
    permissionRights="--permissions=write"
    permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalTarget="--filter=\(\&\(!\(objectclass=posixgroup\)\)\(objectclass=ipausergroup\)\)"
    permissionLocalTargetToVerify=`echo $permissionLocalTarget | sed 's/--filter=//'`
    permissionLocalAttr="--attr=member"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionName="ManageGroup1"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1007 - add permission using filter for groups"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Filter" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass
   rlPhaseEnd

}



##################################################
#  test: ipapermission-add: Positive: Subtree Host 
##################################################
ipapermission_params_host_subtree()
{

    permissionRights="--permissions=write"
    permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalTarget="--subtree=cn=computers,cn=accounts,dc=testrelm,dc=com"
    permissionLocalTargetToVerify="ldap:\/\/\/`echo $permissionLocalTarget | sed 's/--subtree=//'`"
    permissionLocalMemberOf="groupone"
    permissionName="ManageHost1"
    permissionLocalAttr="--attr=nshostlocation"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1008 - add permission using subtree for hosts"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget  $permissionLocalAttr --memberof=$permissionLocalMemberOf" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Subtree" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass $permissionLocalMemberOf 
   rlPhaseEnd

    permissionName="ManageHost2"
    permissionRights="--permissions=write"
    permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
   rlPhaseStartTest "ipa-permission-cli-1027 - add permission using blank memberof group (bug 783475)"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr --memberof=\"\""  0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Subtree" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass 
   rlPhaseEnd

    permissionName="ManageHost3"
    permissionRights="--permissions=write"
    permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
   rlPhaseStartTest "ipa-permission-cli-1028 - add permission using blank memberof group (bug 783543)"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr --memberof=" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Subtree" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass 
   rlPhaseEnd

    rlRun "deletePermission ManageHost2" 0 "Deleting ManageHost2"
    rlRun "deletePermission ManageHost3" 0 "Deleting ManageHost3"
}


##################################################
#  test: ipapermission-add: Positive: Targetgroup 
##################################################
ipapermission_params_targetgroup()
{

    permissionRights="--permissions=write"
    permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalTarget="--targetgroup=groupone"
    permissionLocalTargetToVerify=`echo $permissionLocalTarget | sed 's/--targetgroup=//'`
    permissionLocalAttr="--attr=description"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionName="ManageGroup2"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1009 - add permission using targetgroup"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Target\ group" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass
   rlPhaseEnd

}



##################################################
#  test: ipapermission-add: Positive: Type Hostgroup
##################################################
ipapermission_params_hostgroup_type()
{

    permissionRights="--permissions=add --permissions=delete --permissions=write"
    permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalTarget="--type=hostgroup"
    permissionLocalTargetToVerify=`echo $permissionLocalTarget | sed 's/--type=//'`

    permissionName="ManageHostgroup1"
    permissionLocalAttr="--attr=businessCategory --attr=owner"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1010 - add permission for type hostgroup, with multiple attr, and multiple permissions (bug 783502 - side effect)"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Type" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass
   rlPhaseEnd

}

  
##################################################
#  test: ipapermission-add: Positive: Netgroup filter 
##################################################
ipapermission_params_netgroup_filter()
{
    permissionRights="--permissions=all"
    permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalTarget="--filter=\"(objectclass=nisNetgroup)\""
    permissionLocalTargetToVerify=`echo $permissionLocalTarget | sed 's/--filter=//'`

    permissionName="ManageNetgroup1"
    permissionLocalAttr="--attr=memberNisNetgroup --attr=nisNetgroupTriple --attr=description"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1011 - add permission for type netgroup, with multiple attr"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Filter" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass
   rlPhaseEnd
}



##################################################
#  test: ipapermission-add: Positive: Subtree DNSRecord
##################################################
ipapermission_params_dnsrecord_subtree()
{

    permissionRights="--permissions=write"
    permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalTarget="--subtree=idnsname=testrelm.com,cn=dns,dc=testrelm,dc=com"
    permissionLocalTargetToVerify="ldap:\/\/\/`echo $permissionLocalTarget | sed 's/--subtree=//'`"

    permissionName="ManageDNSRecord1"
    permissionLocalAttr="--attr=nSRecord --attr=aRecord --attr=idnsZoneActive"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1012 - add permission for type dnsrecord, with multiple attrs"
     rlRun "addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     verifyPermissionTargetAttr $permissionName $permissionVerifyRights "Subtree" $permissionLocalTargetToVerify $permissionVerifyAttr $objectclass
   rlPhaseEnd
}




##################################################
#  test: ipapermission-add: Negative Tests
##################################################
ipapermission_add_negative()
{
   ipapermission_add_invalidname
   ipapermission_add_invalidright
   ipapermission_add_invalidattr
   ipapermission_add_multipletarget
   ipapermission_add_missingtarget
   ipapermission_add_invalidmemberof
   ipapermission_add_invalidtype
   ipapermission_add_invalidfilter
   ipapermission_add_invalidsubtree
#   ipapermission_add_invalidtargetgroup 
   ipapermission_add_missingaddsetattr
   ipapermission_add_invalidaddattr
   ipapermission_add_invalidsetattr
   ipapermission_add_duplicateperm
}

###################################################
#  test: ipapermission-add: Negative: Invalid Name
###################################################
ipapermission_add_invalidname()
{
    permissionRights="--permissions=write"
    permissionLocalTarget="--type=user"
    permissionName="Test\<Permission"
    permissionLocalAttr="--attr=carlicense --attr=description"

   rlPhaseStartTest "ipa-permission-cli-1002 - add permission for type user, where name contains '<' (Bug 807304)"
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr"
     expmsg="ipa: ERROR: invalid 'name': May only contain letters, numbers, -, _, and space"
     rlRun "$command > $TmpDir/ipapermission_invalidname.log 2>&1" 1 "Verify error message for $permissionRights"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidname.log"
   rlPhaseEnd
}

###################################################
#  test: ipapermission-add: Negative: Invalid Right
###################################################
ipapermission_add_invalidright()
{

    permissionRights="--permissions=reads"
    permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalTarget="--type=user"

    permissionName="ManageUser"
    permissionLocalAttr="--attr=carlicense --attr=description"

   rlPhaseStartTest "ipa-permission-cli-1013 - add permission with invalid right" 
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 
     expmsg="ipa: ERROR: invalid 'permissions': \"$permissionVerifyRights\" is not a valid permission"
     rlRun "$command > $TmpDir/ipapermission_invalidright1.log 2>&1" 1 "Verify error message for $permissionRights"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidright1.log"
   rlPhaseEnd

   permissionRights="--permissions=\ "
   rlPhaseStartTest "ipa-permission-cli-1014 - add permission with missing right" 
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 
     expmsg="ipa: ERROR: 'permissions' is required"
     rlRun "$command > $TmpDir/ipapermission_invalidright2.log 2>&1" 1 "Verify error message for missing right" 
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidright2.log"
   rlPhaseEnd

}


###################################################
#  test: ipapermission-add: Negative: Invalid Attr 
###################################################
ipapermission_add_invalidattr()
{
    permissionRights="--permissions=read"
    permissionLocalTarget="--type=user"

    permissionName="ManageUser"
    permissionLocalAttr="--attr=invalidattr"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attr=/,/g' | sed 's/^,//' | sed 's/ //g'`

   rlPhaseStartTest "ipa-permission-cli-1015 - add permission with invalid attr" 
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr" 
     expmsg="ipa: ERROR: targetattr \"$permissionVerifyAttr\" does not exist in schema." 
     rlRun "$command > $TmpDir/ipapermission_invalidattr1.log 2>&1" 1 "Verify error message for $permissionVerifyAttr"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidattr1.log"
   rlPhaseEnd



}

######################################################
#  test: ipapermission-add: Negative: Multiple Targets 
######################################################
ipapermission_add_multipletarget()
{
    permissionRights="--permissions=read"
    permissionLocalTarget1="--type=user"
    permissionLocalTarget2="\ --subtree=cn=users,cn=accounts,dc=testrelm,dc=com"   
    permissionLocalTarget3="\ --filter=\(givenname=xyz\)"

    permissionName="ManageUser"
    permissionLocalAttr="--attr=carlicense"

   rlPhaseStartTest "ipa-permission-cli-1017 - add permission with multiple targets - type & subtree" 
     command="addPermission $permissionName $permissionRights $permissionLocalTarget1$permissionLocalTarget2 $permissionLocalAttr" 
     expmsg="ipa: ERROR: invalid 'target': type, filter, subtree and targetgroup are mutually exclusive"
     rlRun "$command > $TmpDir/ipapermission_multipletargets1.log 2>&1" 1 "Verify error message for $permissionLocalAttr"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_multipletargets1.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-permission-cli-1018 - add permission with multiple targets - type & filter" 
     command="addPermission $permissionName $permissionRights $permissionLocalTarget1$permissionLocalTarget3 $permissionLocalAttr" 
     expmsg="ipa: ERROR: invalid 'target': type, filter, subtree and targetgroup are mutually exclusive"
     rlRun "$command > $TmpDir/ipapermission_multipletargets2.log 2>&1" 1 "Verify error message for $permissionLocalAttr"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_multipletargets2.log"
   rlPhaseEnd

}


######################################################
#  test: ipapermission-add: Negative: Missing Target 
######################################################
ipapermission_add_missingtarget()
{

    permissionName="TestPermission"
    permissionLocalRights="--permissions=write"
    permissionLocalTarget="--type"

   rlPhaseStartTest "ipa-permission-cli-1019 - add permission with missing target for type" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget" 
     expmsg="ipa: error: --type option requires an argument"
     rlRun "$command > $TmpDir/ipapermission_missingtargets1.log 2>&1" 2 "Verify error message for missing target for Type"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_missingtargets1.log"
   rlPhaseEnd
   rlPhaseStartTest "ipa-permission-cli-1020 - add permission with missing target for type (bug 783475)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget=" 
     expmsg="ipa: ERROR: invalid 'target': at least one of: type, filter, subtree, targetgroup, attrs or memberof are required"
     rlRun "$command > $TmpDir/ipapermission_missingtargets2.log 2>&1" 1 "Verify error message for missing target for Type"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_missingtargets2.log"
   rlPhaseEnd

   permissionLocalTarget="--subtree"
   rlPhaseStartTest "ipa-permission-cli-1021 - add permission with missing target for subtree" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget" 
     expmsg="ipa: error: --subtree option requires an argument"
     rlRun "$command > $TmpDir/ipapermission_missingtargets3.log 2>&1" 2 "Verify error message for missing target for subtree"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_missingtargets3.log"
   rlPhaseEnd
   rlPhaseStartTest "ipa-permission-cli-1022 - add permission with missing target for subtree (bug 783475)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget=" 
     expmsg="ipa: ERROR: invalid 'target': at least one of: type, filter, subtree, targetgroup, attrs or memberof are required"
     rlRun "$command > $TmpDir/ipapermission_missingtargets4.log 2>&1" 1 "Verify error message for missing target for subtree"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_missingtargets4.log"
   rlPhaseEnd

   permissionLocalTarget="--filter"
   rlPhaseStartTest "ipa-permission-cli-1023 - add permission with missing target for filter" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget" 
     expmsg="ipa: error: --filter option requires an argument"
     rlRun "$command > $TmpDir/ipapermission_missingtargets5.log 2>&1" 2 "Verify error message for missing target for filter"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_missingtargets5.log"
   rlPhaseEnd
   rlPhaseStartTest "ipa-permission-cli-1024 - add permission with missing target for filter (bug 783475)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget=" 
     expmsg="ipa: ERROR: invalid 'target': at least one of: type, filter, subtree, targetgroup, attrs or memberof are required"
     rlRun "$command > $TmpDir/ipapermission_missingtargets6.log 2>&1" 1 "Verify error message for missing target for filter"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_missingtargets6.log"
   rlPhaseEnd


}




######################################################
#  test: ipapermission-add: Negative: Invalid Memberof 
######################################################
ipapermission_add_invalidmemberof()
{

    permissionRights="--permissions=write"
    permissionLocalTarget="--subtree=cn=computers,cn=accounts,dc=testrelm,dc=com"
    permissionMemberOf="nonexistentgroup"
    permissionName="ManageHost"
    permissionLocalAttr="--attr=nshostlocation"
    objectclass="groupofnames,ipapermission,top"

   rlPhaseStartTest "ipa-permission-cli-1025 - add permission using nonexistent memberof group (bug 784329)"
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr --memberof=$permissionMemberOf"
     expmsg="ipa: ERROR: $permissionMemberOf: group not found"
     rlRun "$command > $TmpDir/ipapermission_invalidmemberof1.log 2>&1" 2 "Verify error message for $permissionMemberOf"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidmemberof1.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-permission-cli-1026 - add permission using missing memberof group"
     command="addPermission $permissionName $permissionRights $permissionLocalTarget  $permissionLocalAttr --memberof"
     expmsg="ipa: error: --memberof option requires an argument"
     rlRun "$command > $TmpDir/ipapermission_invalidmemberof2.log 2>&1" 2 "Verify error message for $permissionMemberOf"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidmemberof2.log"
   rlPhaseEnd



}




######################################################
#  test: ipapermission-add: Negative: Invalid Type 
######################################################
ipapermission_add_invalidtype()
{
    permissionName="TestPermission"
    permissionLocalRights="--permissions=write"
    permissionLocalTarget="--type=xyz"

   rlPhaseStartTest "ipa-permission-cli-1029 - add permission using invalid type" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget"
     expmsg="ipa: ERROR: invalid 'type': must be one of 'user', 'group', 'host', 'service', 'hostgroup', 'netgroup', 'dnsrecord'"
     rlRun "$command > $TmpDir/ipapermission_invalidtype.log 2>&1" 1 "Verify error message for invalid type"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidtype.log"
   rlPhaseEnd

}


######################################################
#  test: ipapermission-add: Negative: Invalid Filter
######################################################
ipapermission_add_invalidfilter()
{
    permissionRights="--permissions=write"
    permissionLocalTarget="--filter=\(\&\(!\(objectclass\)\)\(objectclass=ipausergroup\)\)"
    permissionLocalAttr="--attr=description"
    permissionName="ManageGroup"

   rlPhaseStartTest "ipa-permission-cli-1030 - add permission using invalid filter for groups"
     command="addPermission $permissionName $permissionRights $permissionLocalTarget $permissionLocalAttr "
     expmsg="ipa: ERROR: Bad search filter"
     rlRun "$command > $TmpDir/ipapermission_invalidfilter.log 2>&1" 1 "Verify error message for $filter"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidfilter.log"
   rlPhaseEnd


}


######################################################
#  test: ipapermission-add: Negative: Invalid Subtree 
######################################################
ipapermission_add_invalidsubtree()
{
    permissionLocalRights="--permissions=write"
    permissionLocalTarget="--subtree=xyz"
    permissionName="TestPermission"

   rlPhaseStartTest "ipa-permission-cli-1031 - add permission using invalid subtree - bz 893108"
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget"
     expmsg="ipa: ERROR: invalid 'subtree': invalid DN (malformed RDN string = \"xyz\")"
     rlRun "$command > $TmpDir/ipapermission_invalidsubtree.log 2>&1" 1 "Verify error message for invalid subtree"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidsubtree.log"
   rlPhaseEnd

}


######################################################
#  test: ipapermission-add: Negative: Missing Add/Set Attr 
######################################################
ipapermission_add_missingaddsetattr()
{

    permissionName="TestPermission"
    permissionLocalRights="--permissions=write"
    permissionLocalTarget="--type=hostgroup"
    permissionLocalAttr="--attr=carlicense"
    permissionAddAttr="--addattr"

   rlPhaseStartTest "ipa-permission-cli-1032 - add permission with missing addattr value (bug 816574)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr" 
     expmsg="ipa: error: --addattr option requires an argument"
     rlRun "$command > $TmpDir/ipapermission_missingaddattr1.log 2>&1" 2 "Verify error message for missing addattr" 
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_missingaddattr1.log"
   rlPhaseEnd
   rlPhaseStartTest "ipa-permission-cli-1033 - add permission with missing addattr value (bug 816574)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr"
     expmsg="ipa: error: --addattr option requires an argument"
     rlRun "$command > $TmpDir/ipapermission_missingaddattr2.log 2>&1" 2 "Verify error message for missing  addattr"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_missingaddattr2.log"
   rlPhaseEnd

   permissionSetAttr="--setattr"

   rlPhaseStartTest "ipa-permission-cli-1034 - add permission with missing setattr value (bug 816574)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr $permissionSetAttr" 
     expmsg="ipa: error: --setattr option requires an argument"
     rlRun "$command > $TmpDir/ipapermission_missingsetattr1.log 2>&1" 2 "Verify error message for missing setattr" 
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_missingsetattr1.log"
   rlPhaseEnd
   rlPhaseStartTest "ipa-permission-cli-1035 - add permission with missing addattr value (bug 816574)" 
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr $permissionSetAttr"
     expmsg="ipa: error: --setattr option requires an argument"
     rlRun "$command > $TmpDir/ipapermission_missingsetattr2.log 2>&1" 2 "Verify error message for missing setattr"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_missingsetattr2.log"
   rlPhaseEnd
}




######################################################
#  test: ipapermission-add: Negative: Invalid Add Attr 
######################################################
ipapermission_add_invalidaddattr()
{
   permissionName="TestPermission"
   permissionLocalTarget="--type=user"
   permissionLocalAttr="--attr=carlicense"
   permissionAddAttr="--addattr=\"xyz=test\""
   permissionLocalRights="--permissions=write"

   rlPhaseStartTest "ipa-permission-cli-1036 - add permission using invalid add attribute"
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr"
     expmsg="ipa: ERROR: attribute \"xyz\" not allowed"
     rlRun "$command > $TmpDir/ipapermission_invalidaddattr.log 2>&1" 1 "Verify error message for invalid addattr"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidaddattr.log"
   rlPhaseEnd
}


######################################################
#  test: ipapermission-add: Negative: Invalid Set Attr 
######################################################
ipapermission_add_invalidsetattr()
{
   permissionName="TestPermission"
   permissionLocalTarget="--type=user"
   permissionLocalAttr="--attr=carlicense"
   permissionLocalRights="--permissions=write"
   permissionAddAttr="--setattr=\"owner=test\""

   rlPhaseStartTest "ipa-permission-cli-1037 - add permission using invalid setattr"
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr $permissionAddAttr"
     expmsg="ipa: ERROR: owner: value #0 invalid per syntax: Invalid syntax."
     rlRun "$command > $TmpDir/ipapermission_invalidsetattr.log 2>&1" 1 "Verify error message for invalid setattr"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidsetattr.log"
   rlPhaseEnd
}


######################################################
#  test: ipapermission-add: Negative: Duplicate permission 
######################################################
ipapermission_add_duplicateperm()
{
   permissionName="TestPermission"
   permissionLocalTarget="--type=dnsrecord"
   permissionLocalAttr="--attr=arecord"
   permissionLocalRights="--permissions=write"

   rlPhaseStartTest "ipa-permission-cli-1038 - add permission - duplicate"
     rlRun "addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr" 0 "Adding $permissionName"
     command="addPermission $permissionName $permissionLocalRights $permissionLocalTarget $permissionLocalAttr"
     expmsg="ipa: ERROR: This entry already exists"
     rlRun "$command > $TmpDir/ipapermission_duplicateperm.log 2>&1" 1 "Verify error message for duplicate permission"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_duplicateperm.log"
   rlPhaseEnd
}

#############################################
#  test: ipapermission-show: rights 
#############################################
ipapermission_show_rights()
{
 # This will check rights for ManageUser5, added in ipapermission_add - ipapermission_add_positive - ipapermission_params_user_type 
     permissionName="ManageUser5"
     attributeLevelRights="{\'member\': u\'rscwo\', \'seealso\': u\'rscwo\', \'ipapermissiontype\': u\'rscwo\', \'cn\': u\'rscwo\', \'businesscategory\': u\'rscwo\', \'objectclass\': u\'rscwo\', \'memberof\': u\'rscwo\', \'aci\': u\'rscwo\', \'subtree\': u\'rscwo\', \'o\': u\'rscwo\', \'filter\': u\'rscwo\', \'attrs\': u\'rscwo\', \'owner\': u\'rscwo\', \'group\': u\'rscwo\', \'ou\': u\'rscwo\', \'targetgroup\': u\'rscwo\', \'type\': u\'rscwo\', \'permissions\': u\'rscwo\', \'nsaccountlock\': u\'rscwo\', \'description\': u\'rscwo\'}"


   rlPhaseStartTest "ipa-permission-cli-1039 - show permission - rights"
     rlRun "verifyPermissionAttr $permissionName all \"attributelevelrights\" $attributeLevelRights \"--rights\"" 0 "Verify Added Attr"
   rlPhaseEnd
   
}



#############################################
#  test: ipapermission-del : continue
#############################################
ipapermission_del_continue()
{
    permissionName="TestPermissions"

    rlPhaseStartTest "ipa-permission-cli-1040 - delete permission - continue"
     command="ipa permission-del $permissionName --continue"
     expmsg="Failed to remove: $permissionName"
     rlRun "$command > $TmpDir/ipapermission_delete.log 2>&1" 0 "Verify error message when deleting in continue mode" 
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_delete.log"
    rlPhaseEnd

}


#############################################
#  test: ipapermission-find 
#############################################

ipapermission_find()
{
   ipapermission_find_name
   ipapermission_find_permissions
   ipapermission_find_attrs
   ipapermission_find_type
   ipapermission_find_memberof
   ipapermission_find_filter
   ipapermission_find_subtree
   ipapermission_find_targetgroup
   ipapermission_find_timelimit # Add manual test - read DS log
   ipapermission_find_all_raw
   ipapermission_find_multiplefilters
   ipapermission_find_pkey_only
   # No Negative tests. If bad value is passed for the option, no permissions are found.
   # And if it is left blank, internal error is thrown - for which bug 783475 is logged.
}


##################################################
#  test: ipapermission-find: Positive: name
##################################################
ipapermission_find_name()
{
    value="--name=ManageUser1"
    permissions="ManageUser1"

    rlPhaseStartTest "ipa-permission-cli-1041 - find permission using --name (bug 785251)"
      rlRun "findPermissionByOption $value \"all\" $permissions" 0 "Verify permissions are found for --$option=$value"
    rlPhaseEnd

    value="--name=\ "
    rlPhaseStartTest "ipa-permission-cli-1042 - find permission using invalid --name (bug 785251)"
      command="findPermissionByOption $value \"all\" $permissions"
      expmsg="Number of entries returned 0"
      rlRun "ipa permission-find --name=\  --all > $TmpDir/ipapermission_invalidname.log 2>&1" 1 "Verify error message for invalid $option"
      rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidname.log"
      rlRun "cat $TmpDir/ipapermission_invalidname.log"
    rlPhaseEnd
}


##################################################
#  test: ipapermission-find: Positive: permissions
##################################################
ipapermission_find_permissions()
{
    value="--permissions=all"
    permissions="ManageNetgroup1"

    rlPhaseStartTest "ipa-permission-cli-1043 - find permission - --permissions"
      rlRun "findPermissionByOption $value \"all\" $permissions" 0 "Verify permissions are found for --$option=$value"
    rlPhaseEnd

    value="--permissions=xyz"
    rlPhaseStartTest "ipa-permission-cli-1044 - find permission using invalid --permissions (bug 785257)"
      #command="findPermissionByOption $value \"all\" $permissions"
      command="ipa permission-find --permissions=$value --all"
      expmsg="Number of entries returned 0"
      rlRun "$command > $TmpDir/ipapermission_invalidpermission-1044.log 2>&1" 1 "Verify return message for invalid $option"
      rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidpermission-1044.log"
      rlRun "cat $TmpDir/ipapermission_invalidpermission-1044.log"
    rlPhaseEnd
}



##################################################
#  test: ipapermission-find: Positive: attrs
##################################################
ipapermission_find_attrs()
{
    value="--attrs=krbprincipalkey --attrs=krblastpwdchange"
    permissions1="\"Manage host keytab\""
    permissions2="\"Manage service keytab\""

    rlPhaseStartTest "ipa-permission-cli-1045 - find permission - --attrs"
      rlRun "findPermissionByOption \"$value\" \"all\" $permissions1 $permissions2" 0 "Verify permissions are found for --$option=$value"
    rlPhaseEnd
}


##################################################
#  test: ipapermission-find: Positive: type 
##################################################
ipapermission_find_type()
{
    value="--type=dnsrecord"
    permissions1="\"add dns entries\""
    permissions2="\"remove dns entries\""
    permissions3="\"update dns entries\""
    permissions4="\"TestPermission\""

    rlPhaseStartTest "ipa-permission-cli-1046 - find permission - --type"
      rlRun "findPermissionByOption $value \"all\" $permissions1 $permissions2 $permissions3 $permissions4" 0 "Verify permissions are found for --$option=$value"
    rlPhaseEnd
}



##################################################
#  test: ipapermission-find: Positive: memberof 
##################################################
ipapermission_find_memberof()
{
    value="--memberof=groupone"
    permissions="ManageHost1"

    rlPhaseStartTest "ipa-permission-cli-1047 - find permission - --memberof"
      rlRun "findPermissionByOption $value \"all\" $permissions" 0 "Verify permissions are found for --$option=$value"
    rlPhaseEnd
}

##################################################
#  test: ipapermission-find: Positive: filter 
##################################################
ipapermission_find_filter()
{
    value="--filter=\(\&\(!\(objectclass=posixgroup\)\)\(objectclass=ipausergroup\)\)"
    permissions="ManageGroup1"

    rlPhaseStartTest "ipa-permission-cli-1048 - find permission - --filter"
      rlRun "findPermissionByOption $value \"all\" $permissions" 0 "Verify permissions are found for --$option=$value"
    rlPhaseEnd
}



##################################################
#  test: ipapermission-find: Positive: subtree 
##################################################
ipapermission_find_subtree()
{
    option="subtree"
    value="--subtree=cn=computers,cn=accounts,dc=testrelm,dc=com"
    local value2="ldap:///fqdn=*,cn=computers,cn=accounts,dc=testrelm,dc=com"
    permissions="ManageHost1"

    rlPhaseStartTest "ipa-permission-cli-1049 - find permission - --subtree (bug 785254)"
      # Note that we don't do validation on search terms so we aren't going to report whether a subtree is valid or not, 
      # just which entries match.	
      rlRun "findPermissionByOption $value \"all\" $permissions" 1 "No permissions matched - as expected."
      #rlRun "findPermissionByOption $option $value2 \"all\" $permissions" 0 "Verify permissions are found for --subtree=$value2"
      rlRun "ipa permission-find --subtree=ldap:///fqdn=*,cn=computers,cn=accounts,dc=testrelm,dc=com --all" 0 "Verify permissions are found for --subtree=$value2"
      rlRun "ipa permission-find --subtree=$value2"
    rlPhaseEnd
}

##################################################
#  test: ipapermission-find: Positive: targetgroup 
##################################################
ipapermission_find_targetgroup()
{
    value="--targetgroup=ipausers"
    permissions="\"Add user to default group\""

    rlPhaseStartTest "ipa-permission-cli-1050 - find permission - --targetgroup (bz 893827)"
      rlRun "findPermissionByOption $value \"all\" $permissions" 0 "Verify permissions are found for --$option=$value"
    rlPhaseEnd
}



##################################################
#  test: ipapermission-find: Positive: Multiple Filters 
##################################################
ipapermission_find_multiplefilters()
{

    numberOfOptions="3"
    value1="--attrs=description"
    value2="--permissions=write"
    value3="--type=user"
    permissions1="ManageUser1"
    permissions2="ManageUser2"
    permissions3="ManageUser3"
    permissions4="ManageUser4"
    permissions5="ManageUser5"
    permissions6="\"Modify Users\""

    rlPhaseStartTest "ipa-permission-cli-1051 - find permission - --attrs --permissions --type"
      rlRun "findPermissionByMultipleOptions $numberOfOptions $value1 $value2 $value3 $permissions1 $permissions2 $permissions3 $permissions4 $permissions5 $permissions6" 0 "Verify permissions are found"
    rlPhaseEnd


    numberOfOptions="4"
    value4="--sizelimit=3"
    rlPhaseStartTest "ipa-permission-cli-1052 - find permission - --attrs --permissions --type --sizelimit (bug 785257)"
      rlRun "findPermissionByMultipleOptions $numberOfOptions $value1 $value2 $value3 $value4" 0 "Verify permissions are found"
      value4="2" # Lower the number of values 
      rlRun "findPermissionByMultipleOptions $numberOfOptions $option1 $value1 $option2 $value2 $option3 $value3 $option4 $value4" 0 "Verify setting permissions to a lower number does not return all of the above values"
    rlPhaseEnd
}

##################################################
#  test: ipapermission_find_pkey_only
##################################################
ipapermission_find_pkey_only()
{
    rlPhaseStartTest "ipa-permission-cli-1053 - find permission --pkey-only test of ipa permission"
	rlRun "kinitAs $ADMINID $ADMINPW"
	ipa_command_to_test="permission"
	pkey_addstringa="--permissions=write --type=user --attrs=description"
	pkey_addstringb="--permissions=write --type=user --attrs=description"
	pkeyobja="tperm"
	pkeyobjb="tpermb"
	grep_string='Permission\ name'
	general_search_string=tperm
	rlRun "pkey_return_check" 0 "running checks of --pkey-only in permission-find"
    rlPhaseEnd

}

##################################################
#  test: ipapermission-find: Positive: all/raw 
##################################################
ipapermission_find_all_raw()
{
#    localOption="memberof"
    localValue="--memberof=groupone"
    permissions="ManageHost1"
    permissionRights="--permissions=write"
    permissionVerifyRights=`echo $permissionRights | sed 's/--permissions=/,/g' | sed 's/^,//' | sed 's/ //g'`
    permissionLocalTarget="--subtree=cn=computers,cn=accounts,dc=testrelm,dc=com"
    permissionLocalTargetToVerify="ldap:\/\/\/`echo $permissionLocalTarget | sed 's/--subtree=//'`"
    permissionLocalMemberOf="--memberof=groupone"
    permissionLocalAttr="--attrs=nshostlocation"
    permissionVerifyAttr=`echo $permissionLocalAttr | sed 's/--attrs=/,/g' | sed 's/^,//' | sed 's/ //g'`

   rlPhaseStartTest "ipa-permission-cli-1054 - verify permission attrs after a find --all"
      rlRun "findPermissionByOption $localValue \"all\" $permissions" 0 "Verify permissions are found for $permissions"
      verifyPermissionFindOptions $permissions $permissionVerifyRights "Subtree" $permissionLocalTargetToVerify $permissionVerifyAttr $permissionLocalMemberOf 
   rlPhaseEnd

   rlPhaseStartTest "ipa-permission-cli-1055 - verify permission attrs after a find --raw (bug 785259)"
      rlRun "findPermissionByOption $localOption $localValue \"raw\" $permissions" 0 "Verify permissions are found for $permissions"
   #   verifyPermissionFindOptions $permissions $permissionRights "Subtree" $permissionLocalTargetToVerify $permissionLocalAttr $permissionLocalMemberOf 
   rlPhaseEnd
}


##############################################
#   Bug 782847 prompts for all attr when running mod
##  test: ipapermission-mod
##############################################

ipapermission_mod()
{
   ipapermission_mod_positive
   ipapermission_mod_negative
}

ipapermission_mod_positive()
{
   rlLog "Add a dummy permission to modify"
   permissionName="APermission"
   permissionRights="write"
   permissionTarget="--type=user"
   permissionAttr="description"
  rlRun "addPermission $permissionName $permissionRights $permissionTarget $permissionAttr" 0 "Adding $permissionName"


   rlPhaseStartTest "ipa-permission-cli-1056 - modify permission --permissions (bz 893850)"
     permissionName="Add Automount Keys"
     attr="permissions"
     value="add,write"
     restOfRequiredCommand="--attrs="
     rlRun "modifyPermission \"$permissionName\" $attr $value $restOfRequiredCommand"
     rlRun "verifyPermissionAttr \"$permissionName\" all \"Permissions\" \"$value\"" 0 "Verify Permissions"
   rlPhaseEnd 

  rlPhaseStartTest "ipa-permission-cli-1057 - modify permission --attrs (bug 817909)"
     permissionName="Change a user password"
     attr="attrs"
     value="userpassword,krbprincipalkey,sambalmpassword,passwordhistory"
     rlRun "modifyPermission \"$permissionName\" $attr $value"
     rlRun "verifyPermissionAttr \"$permissionName\" all \"Attributes\" \"$value\"" 0 "Verify Permissions"
   rlPhaseEnd

  rlPhaseStartTest "ipa-permission-cli-1058 - modify permission --type"
     permissionName="Remove Netgroups"
     attr="type"
     value="dnsrecord"
     rlRun "modifyPermission \"$permissionName\" $attr $value"
     rlRun "verifyPermissionAttr \"$permissionName\" all \"Type\" \"$value\"" 0 "Verify Permissions"
   rlPhaseEnd

   #TODO - Combination of bug 783502 & 782861 - is causing issues writing testcase - revisit.
   rlPhaseStartTest "ipa-permission-cli-1059 - modify permission --setattr (bug 782861)"
     permissionName="APermission"
     attr="setattr"
     value="description=NewDescription"
     restOfRequiredCommand="--attrs="
     rlRun "modifyPermission \"$permissionName\" $attr $value $restOfRequiredCommand"
     rlRun "verifyPermissionAttr \"$permissionName\" all \"Description\" \"NewDescription\"" 0 "Verify Permissions"
   rlPhaseEnd

# affected by Bug 782847
   rlPhaseStartTest "ipa-permission-cli-1060 - modify permission --rename (bug 805478 and Bug 782847)"
     permissionName="APermission"
     attr="rename"
     value="ABCPermission"
     restOfRequiredCommand="--attrs= --permissions=write --type=user"
     rlRun "modifyPermission \"$permissionName\" $attr $value"
     rlRun "verifyPermissionAttr \"$value\" all \"Permission name\" \"ABCPermission\"" 0 "Verify Permissions"
   rlPhaseEnd

   rlPhaseStartTest "ipa-permission-cli-1063 - modify permission  --type - for which chosen attr are invalid"
     permissionName="Modify Users"
     attr="type"
     value="hostgroup"
     rlRun "modifyPermission \"$permissionName\" $attr $value" 0 "Modify permission to be of different type, keeping original attributes"
     rlRun "verifyPermissionAttr \"$permissionName\" all \"Type\" \"$value\"" 0 "Verify Permissions"
   rlPhaseEnd

#   #TODO: Bug - Uncomment later   
#   ipa permission-mod --rename=APermission "ABCPermission"

}


ipapermission_mod_negative()
{
   rlPhaseStartTest "ipa-permission-cli-1061 - modify permission invalid --permissions"
     permissionName="Add Automount Keys"
     attr="permissions"
     value="xyz"
     restOfRequiredCommand="--attrs="
     command="modifyPermission \"$permissionName\" $attr $value $restOfRequiredCommand"
     expMsg="ipa: ERROR: invalid 'permissions': \"$value\" is not a valid permission"
     rlRun "$command > $TmpDir/ipapermission_invalidpermission.log 2>&1" 1 "Verify error message for invalid permission"
     rlAssertGrep "$expMsg" "$TmpDir/ipapermission_invalidpermission.log"
   rlPhaseEnd 

  rlPhaseStartTest "ipa-permission-cli-1062 - modify permission invalid attrs (bug 817909)"
     permissionName="Change a user password"
     attr="attrs"
     value="xyz"
     #command="modifyPermission \"$permissionName\" $attr \"$value\""
     command="ipa permission-mod --attrs=\"$value\" \"$permissionName\""
     expMsg="ipa: ERROR: attribute(s) \"$value\" not allowed"
     rlRun "$command > $TmpDir/ipapermission_invalidattr.log 2>&1" 1 "Verify error message for invalid attr"
     rlAssertGrep "$expMsg" "$TmpDir/ipapermission_invalidattr.log"
   rlPhaseEnd


   rlPhaseStartTest "ipa-permission-cli-1064 - modify permission invalid --type"
     permissionName="Modify Users"
     attr="type"
     value="users"
     command="modifyPermission \"$permissionName\" $attr $value"
#     command="ipa permission-mod --type=\"$value\" \"$permissionName\""
     expmsg="ipa: ERROR: invalid 'type': must be one of 'user', 'group', 'host', 'service', 'hostgroup', 'netgroup', 'dnsrecord'"
     rlRun "$command > $TmpDir/ipapermission_invalidtype2.log 2>&1" 1 "Verify error message for invalid type"
     rlAssertGrep "$expmsg" "$TmpDir/ipapermission_invalidtype2.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-permission-cli-1065 - modify permission --addattr - to add multivalue to single valued attr - (bug 782861)"
     permissionName="APermission"
     attr="addattr"
     value="description=NewDescriptionAgain"
     restOfRequiredCommand="--attrs="
     command="modifyPermission \"$permissionName\" $attr $value $restOfRequiredCommand"
     expMsg="ipa: ERROR: - not allowed"
     rlRun "ipa permission-add \"$permissionName\" --permissions=write --type=user --attr=description"
     rlRun "$command > $TmpDir/ipapermission_invalidaddattr.log 2>&1" 1 "Verify error message for invalid addattr"
     rlAssertGrep "$expMsg" "$TmpDir/ipapermission_invalidaddattr.log"
   rlPhaseEnd
}
