# Role Based Access Control has 3 sets of clis: role, role and role
#  this will cover role 

iparoleTests() {
    setupRolesTests
    iparole_check
#    iparole_add
#    iparole_add_member
#    iparole_add_privilege
#    iparole_del
#    iparole_find
#    iparole_mod
#    iparole_remove_member
#    iparole_remove_privilege
#    iparole_show
#    cleanup
}

setupRolesTests()
{
    rlPhaseStartTest "Setup - add users and groups"
       rlRun "kinitAs $ADMINID $ADMINPW"
    rlPhaseEnd
}


##############################################################
# Verify Roles provided by IPA have privileges assigned 
##############################################################
iparole_check()
{

   rlPhaseStartTest "ipa-role-cli-1001: Check IPA provided Roles have assigned Privileges" 
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
