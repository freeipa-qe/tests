# Role Based Access Control has 3 sets of clis: privilege, privilege and role
#  this will cover privilege

ipaprivilegeTests() {
    cleanupPrivilegesTest
    setupPrivilegesTest
    ipaprivilege_add
#    ipaprivilege_add_permission
#    ipaprivilege_del
#    ipaprivilege_find
#    ipaprivilege_mod
#    ipaprivilege_remove_permission
#    ipaprivilege_show
 
    # Bug 742327: Check available privileges to see if they have permissions added.
   
#    cleanup
}

setupPrivilegesTest()
{
    rlPhaseStartTest "Setup - add users and groups"
       rlRun "kinitAs $ADMINID $ADMINPW"
    rlPhaseEnd
}



########################
# cleanup
########################
cleanupPrivilegesTest()
{
 rlRun "kinitAs $ADMINID $ADMINPW"
 rlRun "deletePrivilege \"Add User\""
 privilegeName="Add User with owner"
 rlRun "deletePrivilege \"$privilegeName\""
 privilegeName="Add User with multiple owner"
 rlRun "deletePrivilege \"$privilegeName\""

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
 rlRun "kinitAs $ADMINID $ADMINPW"

   rlPhaseStartTest "ipa-privilege-cli-1001: add privilege" 
    privilegeName="Add User"
    privilegeDesc="Add User"
    rlRun "addPrivilege \"$privilegeName\" \"$privilegeDesc\"" 0 "Adding $privilegeName"
#     verifyPrivilege $privilegeName $privilegeDesc 
   rlPhaseEnd

   rlPhaseStartTest "ipa-privilege-cli-1001: add privilege with setattr" 
     privilegeName="Add User with owner"
     privilegeDesc="Add User with owner"
     attr="--setattr=\"owner=cn=ABC\""
     rlRun "addPrivilege \"$privilegeName\" \"$privilegeDesc\" $attr" 0 "Adding $privilegeName"
   rlPhaseEnd

   rlPhaseStartTest "ipa-privilege-cli-1001: add privilege with addattr" 
     privilegeName="Add User with multiple owner"
     privilegeDesc="Add User with multiple owner"
     attr="--addattr=\"owner=cn=XYZ\" --addattr=\"owner=cn=ZZZ\""
    rlRun "addPrivilege \"$privilegeName\" \"$privilegeDesc\"  \"$attr\"" 0 "Adding $privilegeName"
   rlPhaseEnd
}


##################################################
#  test: ipaprivilege-add: Positive Tests
##################################################
ipaprivilege_add_negative()
{

rlLog "Negative privilege tests"
}

