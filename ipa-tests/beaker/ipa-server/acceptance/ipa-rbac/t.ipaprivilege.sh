# Role Based Access Control has 3 sets of clis: privilege, privilege and role
#  this will cover privilege

ipaprivilegeTests() {
    setup
    ipaprivilege_add
    ipaprivilege_add_permission
    ipaprivilege_del
    ipaprivilege_find
    ipaprivilege_mod
    ipaprivilege_remove_permission
    ipaprivilege_show
 
    # Bug 742327: Check available privileges to see if they have permissions added.
   
    cleanup
}

setup()
{
    rlPhaseStartTest "Setup - add users and groups"
       rlRun "kinitAs $ADMINID $ADMINPW"
    rlPhaseEnd
}


