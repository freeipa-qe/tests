#############################################
# this is a testcase file for user-cli test #
#############################################

t_addusertest_envsetup()
{
    rlPhaseStartTest "setup environment for addusertest"
        rlLog "kinit as admin"
        Kinit $admin $adminpassword
        if [ $? -ne 0 ];then
            rlFail "kinit as $admin failed"
        else
            rlPass "kinit as $admin success"
        fi
    rlPhaseEnd
} #t_addusertest_envsetup

t_addusertest_envcleanup()
{
    rlPhaseStartTest "clean up enviroment for addusertest"
        #KinitAs $admin $adminpassword
        rlRun "echo $adminpassword | kinit $admin" 0 "re-kinit as $admin"
        rlRun "ipa user-del $superuser" 0 "delete $superuser account"
        rlRun "ipa user-del $lusr " 0 "delete $lusr account"
        rlLog "run kdestroy to clean up all ticket"
        Kdestroy
        if [ $? -ne 0 ];then
            rlFail "kinit as admin failed"
        else
            rlPass "kinit as admin success"
        fi
    rlPhaseEnd
} #t_addusertest_envcleanup

t_addusersetup()
{
    rlPhaseStartTest "add user setup"
        rlRun "ipa user-add --first=$superuserfirst \
                            --last=$superuserlast \
                            --gecos=$superusergecos \
                            --home=$superuserhome \
                            --principal=$superuserprinc \
                            --email=$superuseremail $superuser" \
                            0 \
                            "add user into ipa server"
    rlPhaseEnd
} #t_addusersetup

t_adduserverify()
{
    rlPhaseStartTest "verify the newly added user account"
        rlRun "ipa user-find $superuser | grep $superuserfirst" 0 "check user firstname"
        rlRun "ipa user-find $superuser | grep $superuserlast" 0 "check last name"
        rlRun "ipa user-find --all $superuser | grep $superusergecos" 0 "check gecos"
        rlRun "ipa user-find $superuser | grep $superuserhome" 0 "check home directory"
        rlRun "ipa user-find --all $superuser | grep \"$superuserprinc\" " 0 "check principal"
        rlRun "ipa user-find --all $superuser | grep \"$superuseremail\" " 0 "check user email"
    rlPhaseEnd
} #t_adduserverify

t_negative_adduser()
{
    rlPhaseStartTest "Negative test case: Add duplicated user should fail"    
        rlLog "START  Add Duplication User - Negative"
        rlRun "ipa user-add --first=$superuserfirst \
                            --last=$superuserlast \
                            --gecos=$superusergecos \
                            --home=$superuserhome \
                            --principal=$superuserprinc \
                            --email=$superuseremail $superuser" \
                            1 \
                            "add duplicated user expected to fail"
    rlPhaseEnd
} #t_negative_adduser

t_addlockuser()
{
    rlPhaseStartTest "Add user - Set Password - Kinit"
        rlRun "ipa user-add --first=$superuserfirst --last=$superuserlast $lusr" 0 "add user $lusr for lock-unlock test" 0 "add user for accout lock-unlock test"
        rlRun "ipa user-find $lusr | grep $lusr" 0 "search for the newly created account"
        # Set up the password of the new user so that they can kinit later
        #SetUserPassword $lusr pw
        #if [ $? -ne 0 ]; then
        #    rlFail "ERROR - SetUserPassword failed "
        #    rlPhaseEnd
        #    return
        #fi

        initialpw="thisjunk10"
        rlRun "echo $initialpw | ipa user-mod --password $lusr" 0 "set initial pasword"
        FirstKinitAs $lusr $initialpw $lusrpw
        if [ $? -ne 0 ]; then
            rlFail "ERROR - kinit failed "
            rlPhaseEnd
            return
        fi
        rlPass "user account for lock-unlokc test created"
    rlPhaseEnd
} #t_addlockuser

t_lockuser()
{
    rlPhaseStartTest "Lock User"
        # re-kinit as admin, since only admin can lock-unlock user account
        #kinitAs $admin $adminpassword
        rlRun "echo $adminpassword | kinit $admin" 0 "re-kinit as $admin"
        rlRun "ipa user-lock $lusr" 0 "perform user account locking"
        if [ $? -ne 0 ];then 
            rlFail "ERROR - ipa user-lock failed "
        else
            rlLog "Lock user success"
            kinitAs $lusr $lusrpw
            if [ $? -ne 0 ];then 
                rlPass"kinit as $lusr failed as expected"
            else
                rlFail "kinit as $lusr success when fail expected "
            fi
        fi
    rlPhaseEnd
} # t_lockuser

t_unlockuser()
{
    rlPhaseStartTest "Unlock User"
        #kinitAs $admin $adminpassword
        rlRun "echo $adminpassword | kinit $admin" 0 "re-kinit as $admin"
        rlRun "ipa user-unlock $lusr"
        if [ $? -ne 0 ];then 
            rlFail "ERROR - ipa user-lock failed "
        else
            kinitAs $s $lusr $lusrpw
            if [ $? -ne 0 ];then 
                rlFail "ERROR - kinit as $lusr failed after unlock. expect success "
            else
                rlPass "Success - kinit as $lusr success as expected"
            fi
        fi
    rlPhaseEnd
} #t_unlock

t_moduser_envsetup()
{
    rlPhaseStartTest "Add User - Define Only Required Attributes"
        Kdestroy
        Kinit $admin $adminpassword
        rlRun "ipa user-add --first=superuserfirst --last=superuserlast $musr" 0 "add test user account"
        rlRun "ipa user-find $musr | grep $musr" 0 "confirm the existance of test account"
    rlPhaseEnd
} #t_moduser_envsetup

t_moduser_envcleanup()
{
    rlPhaseStartTest "clean up env for moduser test"
        rlRun "ipa user-del $musr" 0 "remove test user account [$musr]"
        Kdestroy
    rlPhaseEnd
} #t_moduser_envcleanup

t_modfirstname()
{
    rlPhaseStartTest "Modify First Name"
        rlRun "ipa user-mod --first=$mfirst $musr" 0 "modify first name"
        rlRun "ipa user-show --all $musr | grep $mfirst" 0 "check the mfirst to verify"
    rlPhaseEnd
} #t_modfirstname

t_modlastname()
{
    rlPhaseStartTest "Modify Last Name"
        rlRun "ipa user-mod --last=$mlast $musr" 0 "modify the last name"
        rlRun "ipa user-show --all $musr | grep $mlast" 0 "check last name"
    rlPhaseEnd
} #t_modlastname

t_modemail()
{
     rlPhaseStartTest "Modify email"
        rlRun "ipa user-mod --email=\'$memail\' $musr" 0 "modify email"
        rlRun "ipa user-show --all $musr | grep $memail" 0 "check email"
    rlPhaseEnd
} #t_modemail

t_modprinc()
{
    rlPhaseStartTest "Modify principal"
        rlRun "ipa user-mod --principal=$mprinc $musr" 0 "modify principal"
        rlRun "ipa user-show --all $musr | grep $mprinc" 0 "check principal"
    rlPhaseEnd   
} #t_modprinc

t_modhome()
{
    rlPhaseStartTest "Modify home directory"
        rlRun "ipa user-mod --home=\'$mhome\' $musr" 0 "modify home directory"
        rlRun "ipa user-show --all $musr | grep $mhome" 0 "check home directory"
    rlPhaseEnd   
} #t_modhome

t_modgecos()
{
    rlPhaseStartTest "Modify gecos"
        rlRun "ipa user-mod --gecos=$mgecos $musr" 0 "modify gecos"
        rlRun "ipa user-show --all $musr | grep $mgecos" 0 "check gecos"
    rlPhaseEnd   
} #t_modgecos

t_moduid()
{
   rlPhaseStartTest "Modify uid"
        rlRun "ipa user-mod --uid=$muid $musr" 0 "modify uid"
        rlRun "ipa user-show --all $musr | grep $muid" 0 "check uid"
    rlPhaseEnd   
} #t_moduid

t_modstreet()
{
    rlPhaseStartTest "Modify street"
        rlRun "ipa user-mod --street=\"$mstreet\" $musr" 0 "modify street info"
        rlRun "ipa user-show --all $musr | grep \"$mstreet\"" 0 "check street info"
    rlPhaseEnd   
} #t_modstreet

t_modshell()
{
    rlPhaseStartTest "Modify street"
        rlRun "ipa user-mod --shell=\'$mshell\' $musr" 0 "modify shell"
        rlRun "ipa user-show --all $musr | grep '$mshell'" 0 "check shell"
    rlPhaseEnd   
} #t_modshell

t_deluser()
{
    rlPhaseStartTest "delete user" 
        rlPass "user deletion test already included into adduser test and moduser test, simple log pass here"
    rlPhaseEnd
} #t_deluser


t_modgroup()
{
#FIXME: Should this one in different test suite, like group-cli test?    
#       I haven't do anything on this part for now, including the next 
#       test case: t_modgroup2
    if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
    rlLog "START  Modify Group Membership"
    

        rlRun "ipa group-add --desc=\"group that the user in the user-mod will include\" $mgroup1"
        if [ $? -ne 0 ]
        then
                rlLog "ERROR - ipa group-add failed "
                myresult=FAIL
        fi

        rlRun "ipa group-find $mgroup1"
        if [ $? -ne 0 ]
        then
                rlLog "ERROR - Search for group $mgroup1 failed "
                myresult=FAIL
        fi

    rlRun "ipa group-add-member --users $musr $mgroup1"
    if [ $? -ne 0 ]
    then 
        rlLog "ERROR - ipa user-mod failed "
        rlLog "ERROR possibly related to https://bugzilla.redhat.com/show_bug.cgi?id=502114"
        myresult=FAIL
    fi

    rlRun "ipa group-show --all $mgroup1 | grep '$musr'"
    if [ $? -ne 0 ]
    then
        rlLog "ERROR - Search for $musr in $mgroup1 failed failed "
        myresult=FAIL
    fi

    result $myresult
    rlLog "END $tet_thistest"
} #t_modgroup

t_modgroup2()
{
    
    if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
    rlLog "START  Modify Second Group Membership"
    

        rlRun "ipa group-add --desc=\"group2 that the user in the user-mod will include\" $mgroup2"
        if [ $? -ne 0 ]
        then
                rlLog "ERROR - ipa group-add failed "
                myresult=FAIL
        fi

        rlRun "ipa group-find $mgroup2"
        if [ $? -ne 0 ]
        then
                rlLog "ERROR - Search for group $mgroup2 failed "
                myresult=FAIL
        fi

    rlRun "ipa group-add-member --users $musr $mgroup2"
    if [ $? -ne 0 ]
    then 
        rlLog "ERROR - ipa user-mod failed "
        rlLog "ERROR possibly related to ttps://bugzilla.redhat.com/show_bug.cgi?id=502114"
        myresult=FAIL
    fi

    rlRun "ipa group-show --all $mgroup1 | grep '$musr'"
    if [ $? -ne 0 ]
    then
        rlLog "ERROR - Search for $musr in $mgroup1 failed failed "
        myresult=FAIL
    fi

    rlRun "ipa group-show --all $mgroup2 | grep '$musr'"
    if [ $? -ne 0 ]
    then
        rlLog "ERROR - Search for $musr in $mgroup2 failed failed "
        myresult=FAIL
    fi

    result $myresult
    rlLog "END $tet_thistest"
} #t_modgroup2

