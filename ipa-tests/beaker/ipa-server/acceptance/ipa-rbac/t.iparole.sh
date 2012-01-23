# Role Based Access Control has 3 sets of clis: role, role and role
#  this will cover role 

iparoleTests() {
    setup
    iparole_add
    iparole_add_member
    iparole_add_privilege
    iparole_del
    iparole_find
    iparole_mod
    iparole_remove_member
    iparole_remove_privilege
    iparole_show
    cleanup
}

setup()
{
    rlPhaseStartTest "Setup - add users and groups"
       rlRun "kinitAs $ADMINID $ADMINPW"
    rlPhaseEnd
}


