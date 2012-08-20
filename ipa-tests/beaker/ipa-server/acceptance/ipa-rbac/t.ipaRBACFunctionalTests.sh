# Role Based Access Control has 3 sets of clis: privilege, privilege and role
#  this will cover the functional tests 

#############################################
##          Variables                      ##
#############################################

##### For DNS Zone Permission tests
login1="dnsuser1"
password="Secret123"
ipaddr="$MASTER"
zone1="one.testrelm.com"
zone2="two.testrelm.com"
dnsPrivilege="DNSTestPrivilege"
dnsRole="DNSTestRole"

ipaRBACFunctionalTests() {
    setupRBACTests
    test01
    test04
#    test05
    test06
    testDNSPermissions
   cleanupRBACTests
}

setupRBACTests()
{
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
       
}


cleanupRBACTests()
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
      rlRun "addMemberToRole \"$roleName\" $type $login all" 0 "Adding member to role $roleName"
      # kinit as testuserhelpdesk
      rlRun "kinitAs $login $password" 0 "kinit as $login"
      # change admin password - cannot
      adminLogin="admin"
      newPwd="Secret456"
      command="echo $newPwd | ipa passwd $adminLogin"
      expmsg="ipa: ERROR: Insufficient access"
      rlRun "$command > $TmpDir/ipaRBAC_test01_1.log 2>&1" 1 "Verify error message when $login updates $adminLogin's password (bug 773759)"  
     rlAssertGrep "$expmsg" "$TmpDir/ipaRBAC_test01_1.log"
   rlPhaseEnd

    # HelpDesk - can modify group memberships, modify users, reset password
    # this user should be allowed to modify a user's lastname, reset password, but cannot add or delete this user
   rlPhaseStartTest "ipa-rbac-1002 - Set up user with HelpDesk Role - Cannot add new user" 
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
   rlPhaseStartTest "ipa-rbac-1003 - Set up user with HelpDesk Role - Can update user attr (bug 817915)" 
      testLogin="test"
      attrToUpdate="last"
      newLastName="testtest"
      rlRun "modifyUser $testLogin $attrToUpdate $newLastName" 0 "Verify $login can modify $testLogin's lastname"
   rlPhaseEnd

      # change user password - can
   rlPhaseStartTest "ipa-rbac-1004 - Set up user with HelpDesk Role - Can reset a user's password (bug 773759)" 
      newPwd="testtest"
      rlRun "echo $newPwd | ipa passwd $testLogin" 0 "Verify $login can reset $testLogin's password"
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
   rlPhaseStartTest "ipa-rbac-1005 - Set up role for user to allow updating groupone's desc"
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
      rlRun "addMemberToRole \"$roleName\" $type $login all" 0 "Adding member to role"
      rlRun "kinitAs $login $password" 0 "kinit as $login"
      # group-mod the desc for groupone
      attr="desc"
      newDescription="Updated Group One"
      rlRun "modifyGroup $groupName $attr \"$newDescription\"" 0 "Verify $login can update $groupName's description"
      #test to add user two to groupone - cannot
  rlPhaseEnd
#  add members to this group, nor update desc for group two

   rlPhaseStartTest "ipa-rbac-1006 - Modify role to allow adding members to groupone"
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

   rlPhaseStartTest "ipa-rbac-1007 - Set up role for user to allow only adding a user - Can add a user"
      rlRun "kinitAs $ADMINID $ADMINPW"
      rlRun "addPrivilege \"$privilegeName\" \"$privilegeDesc\"" 0 "Adding privilege: $privilegeName"
      rlRun "addPermissionToPrivilege \"$permissionList\" \"$privilegeName\"" 0 "Add permission to privilege"
      rlRun "addRole \"$roleName\" \"$roleDesc\"" 0 "Adding role: $roleName"
      rlRun "addPrivilegeToRole \"$privilegeName\" \"$roleName\"" 0 "Adding privilege to role"
      rlRun "addMemberToRole \"$roleName\" $type $login all" 0 "Adding member to role"

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
   rlPhaseStartTest "ipa-rbac-1008 - Set up role for user to allow only adding a user - Cannot update user attr"
      attrToUpdate="last"
      newLastName="oneone"
      command="modifyUser $newLogin $attrToUpdate $newLastName"
      expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'sn' attribute of entry 'uid=one,cn=users,cn=accounts,dc=testrelm,dc=com'"
      rlRun "$command > $TmpDir/ipaRBAC_test06_1.log 2>&1" 1 "Verify error message when $login updates $newLogin's lastname" 
     rlAssertGrep "$expmsg" "$TmpDir/ipaRBAC_test06_1.log"
   rlPhaseEnd

   rlPhaseStartTest "ipa-rbac-1009 - Set up role for user to allow only adding a user - Cannot reset user password"
      # change user password - cannot
      newPwd="oneone"
      command="echo $newPwd | ipa passwd $newLogin"
      expmsg="ipa: ERROR: Insufficient access"
      rlRun "$command > $TmpDir/ipaRBAC_test06_2.log 2>&1" 1 "Verify error message when $login updates $newLogin's password" 
     rlAssertGrep "$expmsg" "$TmpDir/ipaRBAC_test06_2.log"
   rlPhaseEnd
}

testDNSPermissions()
{
   dnsSetup
   testPerDomainDNS
   dnsCleanup
}

# Setup:
# Add 1 users, 2 zones
# add privilege, role
dnsSetup() 
{

       rlRun "kinitAs $ADMINID $ADMINPW"

       # add a test user
       firstname="dnsuser1"
       lastname="dnsuser1"
       create_ipauser $login1 $firstname $lastname $password

       # add two DNS Zones
       rlRun "kinitAs $ADMINID $ADMINPW"
       email="ipaqar.resdhat.com"
       ipa dnszone-add --name-server=$ipaddr $zone1 --admin-email=$email
       ipa dnszone-add --name-server=$ipaddr $zone2 --admin-email=$email

       # Add a new privilege to test
       ipa privilege-add $dnsPrivilege --desc=$dnsPrivilege

       # Add a new role to test
       ipa role-add $dnsRole --desc=$dnsRole

      # Add privilege to role
      addPrivilegeToRole "$dnsPrivilege" "$dnsRole"
       
}

dnsCleanup()
{
     rlRun "kinitAs $ADMINID $ADMINPW"
     ipa user-del $login1 
     ipa dnszone-del $zone1 $zone2
     ipa privilege-del $dnsPrivilege
     ipa role-del $dnsRole
}



# bug 801931/Per-domain DNS record permissions
testPerDomainDNS()
{ 
      rlLog "Executing: ipa dnszone-add-permission $zone1"
      rlRun "ipa dnszone-add-permission $zone1" 0 "Add permission to manage $zone1"
      dnsPermission="Manage DNS zone $zone1"
      rlRun "addPermissionToPrivilege \"$dnsPermission\" \"$dnsPrivilege\"" 0 "Add permission to privilege"
 
      type="users"
      rlRun "addMemberToRole \"$dnsRole\" $type $login1 all" 0 "Adding member to role $dnsRole"

      # kinit as dnsUser1
      rlRun "kinitAs $login1 $password" 0 "kinit as $login1"
      
      # user can list only one.testrelm.com
      
      rlPhaseStartTest "ipa-rbac-1010 - Can list zone managed by user" 
         rlRun "ipa dnszone-show $zone1 --all" 0 "$login1 can list $zone1"
      rlPhaseEnd

      rlPhaseStartTest "ipa-rbac-1011 - Cannot list zone not managed by user" 
          command="ipa dnszone-show $zone2"
          expmsg="ipa: ERROR: $zone2: DNS zone not found"
          rlRun "$command > $TmpDir/ipaDNSPermissionTest_show.log 2>&1" 2 "Verify error message when listing unauthorized zone"
          rlAssertGrep "$expmsg" "$TmpDir/ipaDNSPermissionTest_show.log"
      rlPhaseEnd

      rlPhaseStartTest "ipa-rbac-1012 - Cannot add permission for zone not managed by user" 
          command="ipa dnszone-add-permission $zone2"
          expmsg="ipa: ERROR: $zone2: DNS zone not found"
          rlRun "$command > $TmpDir/ipaDNSPermissionTest_addperm.log 2>&1" 2 "Verify error message when adding permission for unauthorized zone"
          rlAssertGrep "$expmsg" "$TmpDir/ipaDNSPermissionTest_addperm.log"
      rlPhaseEnd

      rlPhaseStartTest "ipa-rbac-1013 - Cannot add a new zone"
          testZone="testzone.testrelm.com"
          command="ipa dnszone-add --name-server=$ipaddr $testZone --admin-email=$email"
          expmsg="ipa: ERROR: Insufficient access: Insufficient 'add' privilege to add the entry 'idnsname=$testZone,cn=dns,dc=testrelm,dc=com'."
          rlRun "$command > $TmpDir/ipaDNSPermissionTest_add.log 2>&1" 1 "Verify error message when adding new zone" 
          rlAssertGrep "$expmsg" "$TmpDir/ipaDNSPermissionTest_add.log"
      rlPhaseEnd

      rlPhaseStartTest "ipa-rbac-1014 - Cannot delete zone managed by user"
          command="ipa dnszone-del $zone1"
          expmsg="ipa: ERROR: Insufficient access: Insufficient 'delete' privilege to delete the entry 'idnsname=$zone1,cn=dns,dc=testrelm,dc=com'."
          rlRun "$command > $TmpDir/ipaDNSPermissionTest_del.log 2>&1" 1 "Verify error message when deleting zone managed by user" 
          rlAssertGrep "$expmsg" "$TmpDir/ipaDNSPermissionTest_del.log"
      rlPhaseEnd

      rlPhaseStartTest "ipa-rbac-1015 - Cannot edit managedBy attr for zone managed by user"
          command="ipa dnszone-mod $zone1 --setattr=managedBy=\"uid=dnsuser2,cn=users,cn=accounts,dc=testrelm,dc=com\""
          expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'managedBy' attribute of entry 'idnsname=$zone1,cn=dns,dc=testrelm,dc=com'."
          rlRun "$command > $TmpDir/ipaDNSPermissionTest_managebyattr.log 2>&1" 1 "Verify error message when modifying managedby attr for zone managed by user" 
          rlAssertGrep "$expmsg" "$TmpDir/ipaDNSPermissionTest_managebyattr.log"
      rlPhaseEnd

      rlPhaseStartTest "ipa-rbac-1016 - Can enable/disable zone managed by user"
         rlRun "ipa dnszone-disable $zone1" 0 "$login1 can disable $zone1"
         rlRun "ipa dnszone-enable $zone1" 0 "$login1 can enable $zone1"
      rlPhaseEnd


      rlPhaseStartTest "ipa-rbac-1017 - Cannot enable/disable zone not managed by user"
          command="ipa dnszone-disable $zone2"
          expmsg="ipa: ERROR: no such entry"
          rlRun "$command > $TmpDir/ipaDNSPermissionTest_disable.log 2>&1" 2 "Verify error message when disabling zone not managed by user" 
          rlAssertGrep "$expmsg" "$TmpDir/ipaDNSPermissionTest_disable.log"
          command="ipa dnszone-enable $zone2"
          expmsg="ipa: ERROR: no such entry"
          rlRun "$command > $TmpDir/ipaDNSPermissionTest_enable.log 2>&1" 2 "Verify error message when enabling zone not managed by user" 
          rlAssertGrep "$expmsg" "$TmpDir/ipaDNSPermissionTest_enable.log"
      rlPhaseEnd

      rlPhaseStartTest "ipa-rbac-1018 - Can read Global configuration, but cannot modify it"
          rlRun "ipa dnsconfig-show" 0 "$login1 can read Global Configuration"
          command="ipa dnsconfig-mod --allow-sync-ptr=TRUE"
          expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'idnsAllowSyncPTR' attribute of entry 'cn=dns,dc=testrelm,dc=com'."
          rlRun "$command > $TmpDir/ipaDNSPermissionTest_config1.log 2>&1" 1 "Verify error message when updating global configuration for Allow PTR sync"
          rlAssertGrep "$expmsg" "$TmpDir/ipaDNSPermissionTest_config1.log"
          command="ipa dnsconfig-mod --forwarder=1.1.1.1"
          expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'idnsForwarders' attribute of entry 'cn=dns,dc=testrelm,dc=com'."
          rlRun "$command > $TmpDir/ipaDNSPermissionTest_config2.log 2>&1" 1 "Verify error message when  updating global configuration for Global forwarders" 
          rlAssertGrep "$expmsg" "$TmpDir/ipaDNSPermissionTest_config2.log"
      rlPhaseEnd


      rlPhaseStartTest "ipa-rbac-1019 - Can add/delete/modify/find DNS records" 
          arecordName="ARecord"
          arecord="1.1.1.1,2.2.2.2"
          arecordIP2="2.2.2.2"
          txtrecord="ABC"
          rlRun "ipa dnsrecord-add $zone1 $arecordName --a-rec $arecord" 0 "Add a A Record with ip - $arecord"
          rlRun "ipa dnsrecord-show $zone1 $arecordName | grep $arecordIP2 " 0 "Show the record, and verify A record with $arecord"
          rlRun "ipa dnsrecord-mod $zone1 $arecordName --txt-rec $txtrecord" 0 "Modify the record to add a TXT record"
          rlRun "ipa dnsrecord-find $zone1 $arecordName | grep $txtrecord" 0 "Find the record, verify TXT record"
          rlRun "ipa dnsrecord-del $zone1 $arecordName --a-rec $arecordIP2" 0 "Delete the A record - for one IP"
          rlRun "ipa dnsrecord-del $zone1 $arecordName --txt-rec $txtrecord" 0 "Delete the TXT rec"
          rlRun "ipa dnsrecord-show $zone1 $arecordName | grep $arecordIP2 " 1 "Show the record, and verify A record with $arecord is deleted"
          rlRun "ipa dnsrecord-show $zone1 $arecordName | grep $txtrecord " 1 "Show the record, and verify A record with $txtrecord is deleted"
      rlPhaseEnd

      rlPhaseStartTest "ipa-rbac-1020 - Cannot remove permission to manage this zone"
          command="ipa dnszone-remove-permission $zone1" 
          expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'managedBy' attribute of entry 'idnsname=$zone1,cn=dns,dc=testrelm,dc=com'."
          rlRun "$command > $TmpDir/ipaDNSPermissionTest_removeperm.log 2>&1" 1 "Verify error message whenremoving zone permission"
          rlAssertGrep "$expmsg" "$TmpDir/ipaDNSPermissionTest_removeperm.log"
      rlPhaseEnd

      rlPhaseStartTest "ipa-rbac-1021 - Verify can use dig to do DNS queries" 
            # add a host with an ip
            kinitAs $ADMINID $ADMINPW
            host1="hostfordnstest".$zone2
            rzone=`getReverseZone`
            rlLog "Reverse Zone: $rzone"
            if [ $rzone ] ; then
             oct=`echo $rzone | cut -d "i" -f 1`
             oct1=`echo $oct | cut -d "." -f 3`
             oct2=`echo $oct | cut -d "." -f 2`
             oct3=`echo $oct | cut -d "." -f 1`
             hostipaddr=$oct1.$oct2.$oct3.99
             ipa host-add --ip-address=$hostipaddr $host1
            else
             rlFail "Reverse DNS zone not found."
            fi
            kinitAs $login1 $password

           # use dig to lookup host added 
           rlRun "dig $host1 | grep $hostipaddr" 0 "Checking with dig to verify that actual DNS queries are still functional, when a permission is added to a zone"


           kinitAs $ADMINID $ADMINPW
           ipa host-del $host1 --updatedns 
           kinitAs $login1 $password
      rlPhaseEnd


      rlPhaseStartTest "ipa-rbac-1022 - User with permission removed can no longer access the zone" 
          rlRun "kinitAs $ADMINID $ADMINPW"
          rlLog "Executing: ipa dnszone-remove-permission $zone1"
          ipa dnszone-remove-permission $zone1
          kinitAs $login1 $password
          command="ipa dnszone-show $zone1"
          expmsg="ipa: ERROR: $zone1: DNS zone not found"
          rlRun "$command > $TmpDir/ipaDNSPermissionTest_showzonewithnoperm.log 2>&1" 2 "Verify error message when listing zone with no permission"
          rlAssertGrep "$expmsg" "$TmpDir/ipaDNSPermissionTest_showzonewithnoperm.log"
      rlPhaseEnd
}


#test05()
#{
# Check available DNS permissions:
# Read DNS Entries
#     User can list all zones
#     User cannot add/enable/disable/delete any zone
#     User cannot add/delete a record to a zone
# Write DNS configuration 
#   Need Read DNS Entries to see the list
#   Can modify Global config
# Add DNS Entries
#   Need Read DNS Entries to see the list
#   Can add zone
#   Cannot delete/enable/disable zone
#   Can add record
#   cannot modify dns record
# Remove DNS Entries
#   cannot disable/enable/add dns zone
#   can delete zone/record
#   cannot modify dns record
# Update DNS Entries
#   cannot add/delete zone
#   can disable/enable zone
#   cannot add record
#   can update a record - add/edit/delete
#}

