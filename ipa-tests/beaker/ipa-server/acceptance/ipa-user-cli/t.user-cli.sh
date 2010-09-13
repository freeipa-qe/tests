#############################################
# this is a testcase file for user-cli test #
#############################################

t_addusersetup()
{
    rlPhaseStartTest "add user setup"

        rlRun "ipa user-add --first=$superuserfirst \
                            --last=$superuserlast \
                            --gecos=$superusergecos \
                            --home=$superuserhome \
                            --principal=$superuserprinc \
                            --email=$superuseremail $superuser"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-add failed "
            rlFail
        else
            rlLog "ipa user-add returned success"
            rlPass
        fi

    rlPhaseEnd
} #t_addusersetup

t_adduserverify()
{
    rlPhaseStartTest "verify the newly added user account"
        rlLog "verify the first name"
        rlRun "ipa user-find $superuser | grep $superuserfirst"
         if [ $? -ne 0 ];then 
            rlLog "user firstname does not match"
            rlFail
            return
        else
            rlLog "user firstname matches"
        fi

        rlLog "verify the last name"
        rlRun "ipa user-find $superuser | grep $superuserlast"
         if [ $? -ne 0 ];then 
            rlLog "user lastname does not match"
            rlFail
            return
        else
            rlLog "user lastname matches"
        fi
 
        rlLog "verify the gecos"
        rlRun "ipa user-find $superuser | grep $superusergecos"
         if [ $? -ne 0 ];then 
            rlLog "user gecos does not match"
            rlFail
            return
        else
            rlLog "user gecos matches"
        fi
 
        rlLog "verify the home"
        rlRun "ipa user-find $superuser | grep $superuserhome"
         if [ $? -ne 0 ];then 
            rlLog "user home does not match"
            rlFail
            return
        else
            rlLog "user home matches"
        fi

        rlLog "verify the principal name"
        rlRun "ipa user-find $superuser | grep $superuserprinc"
         if [ $? -ne 0 ];then 
            rlLog "user principal does not match"
            rlFail
            return
        else
            rlLog "user principal matches"
        fi

        rlLog "verify the email"
        rlRun "ipa user-find $superuser | grep $superuseremail"
         if [ $? -ne 0 ];then 
            rlLog "user email does not match"
            rlFail
            return
        else
            rlLog "user email matches"
        fi


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
                            --email=$superuseremail $superuser"
        if [ $? -eq 0 ];then 
            rlLog "ERROR - ipa user-add passed when it should not"
            rlFail
            return
        else 
            rlLog "Good, duplicated user can not be added"
            rlPass
        fi
    rlPhaseEnd
} #t_negative_adduser

t_addlockuser
{
    rlPhaseStartTest
        rlLog "START  Add user - Set Password - Kinit"
        rlRun "ipa user-add --first=$superuserfirst --last=$superuserlast $lusr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-add failed "
            rlFail
            return #FIXME : not sure if this is a necessary step
        fi
        rlRun "ipa user-find $lusr | grep id | grep $lusr"
        if [ $? -ne 0 ];then
            rlLog "ERROR - Search for created user failed "
            rlFail
            return
        fi
        # Set up the password of the new user so that they can kinit later
        SetUserPassword M1 $lusr pw
        if [ $? -ne 0 ]; then
            rlLog "ERROR - SetUserPassword failed "
            rlFail
            return
        fi

        KinitAsFirst M1 $lusr pw $lusrpw
        if [ $? -ne 0 ]; then
            rlLog "ERROR - kinit failed "
            rlFail
            return
        fi
        rlLog "user account for lock-unlokc test created"
        rlPass
    rlPhaseEnd
} #t_addlockuser

t_lockuser()
{
    rlPhaseStartTest    
        rlLog "START  Lock User"
        rlRun "ipa user-lock $lusr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-lock failed "
            rlFail
        else
            rlLog "Luck user success"
            KinitAs $s $lusr $lusrpw
            if [ $? -eq 0 ];then 
                rlLog "ERROR - kinit as $lusr worked  when it should not have"
                rlFail
            else
                rlLog "user account locked confirmed"
                rlPass
            fi
        fi
    rlPhaseEnd
} # t_lockuser

t_unlockuser()
{
    rlPhaseStartTest 
        rlLog "START  Unlock User"
        rlRun "ipa user-unlock $lusr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-lock failed "
            rlFail
        else
            KinitAs $s $lusr $lusrpw
            if [ $? -ne 0 ];then 
                rlLog "ERROR - kinit as $lusr failed "
                rlFail
            else
                rlLog "Success - kinit as $lusr success"
                rlPass
            fi
        fi
    rlPhaseEnd
} #t_unlock

t_addmoduser()
{
    rlPhaseStartEnd    
        rlLog "START  Add User - Define Only Required Attributes"
        rlRun "ipa user-add --first=superuserfirst --last=superuserlast $musr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-add failed "
            rlFail
        else
            rlRun "ipa user-find $musr | grep id | grep $musr"
            if [ $? -ne 0 ];then
                rlLog "ERROR - Search for created user failed "
                rlFail
            else
                rlLog "Success, uer found"
                rlPass
            fi
        fi
    rlPhaseEnd
} #t_addmoduser

t_modfirstname()
{
    rlPhaseStartStart 
        rlLog "START  Modify First Name"
        rlRun "ipa user-mod --first=$mfirst $musr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-mod failed "
            rlFail
        else
            rlRun "ipa user-show --all $musr | grep $mfirst"
            if [ $? -ne 0 ];then
                rlLog "ERROR - Search for created user failed "
                rlFail
            else
                rlLog "Success"
                rlPass
            fi
        fi
    rlPhaseEnd
} #t_modfirstname

t_modlastname()
{
    rlPhaseStartStart 
        rlLog "START  Modify Last Name"
        rlRun "ipa user-mod --last=$mlast $musr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-mod failed "
            rlFail
        else
            rlRun "ipa user-show --all $musr | grep $mlast"
            if [ $? -ne 0 ];then
                rlLog "ERROR - Search for created user failed "
                rlFail
            else
                rlLog "Success"
                rlPass
            fi
        fi
    rlPhaseEnd
} #t_modlastname

t_modemail()
{
     rlPhaseStartStart 
        rlLog "START  Modify email"
        rlRun "ipa user-mod --email=\'$memail\' $musr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-mod failed "
            rlFail
        else
            rlRun "ipa user-show --all $musr | grep $memail"
            if [ $? -ne 0 ];then
                rlLog "ERROR - Search for created user failed "
                rlFail
            else
                rlLog "Success"
                rlPass
            fi
        fi
    rlPhaseEnd
} #t_modemail

t_modprinc()
{
    rlPhaseStartStart 
        rlLog "START  Modify principal"
        rlRun "ipa user-mod --principal=$mprinc $musr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-mod failed "
            rlFail
        else
            rlRun "ipa user-show --all $musr | grep $mprinc"
            if [ $? -ne 0 ];then
                rlLog "ERROR - Search for created user failed "
                rlFail
            else
                rlLog "Success"
                rlPass
            fi
        fi
    rlPhaseEnd   
} #t_modprinc

t_modhome()
{
    rlPhaseStartStart 
        rlLog "START  Modify home directory"
        rlRun "ipa user-mod --home=\'$mhome\' $musr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-mod failed "
            rlFail
        else
            rlRun "ipa user-show --all $musr | grep $mhome"
            if [ $? -ne 0 ];then
                rlLog "ERROR - Search for created user failed "
                rlFail
            else
                rlLog "Success"
                rlPass
            fi
        fi
    rlPhaseEnd   
} #t_modhome

t_modgecos()
{
    rlPhaseStartStart 
        rlLog "START  Modify gecos"
        rlRun "ipa user-mod --gecos=$mgecos $musr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-mod failed "
            rlFail
        else
            rlRun "ipa user-show --all $musr | grep $mgecos"
            if [ $? -ne 0 ];then
                rlLog "ERROR - Search for created user failed "
                rlFail
            else
                rlLog "Success"
                rlPass
            fi
        fi
    rlPhaseEnd   
} #t_modgecos

t_moduid()
{
   rlPhaseStartStart 
        rlLog "START  Modify uid"
        rlRun "ipa user-mod --uid=$muid $musr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-mod failed "
            rlFail
        else
            rlRun "ipa user-show --all $musr | grep $muid"
            if [ $? -ne 0 ];then
                rlLog "ERROR - Search for created user failed "
                rlFail
            else
                rlLog "Success"
                rlPass
            fi
        fi
    rlPhaseEnd   
} #t_moduid

t_modstreet()
{
    rlPhaseStartStart 
        rlLog "START  Modify street"
        rlRun "ipa user-mod --street=\"$mstreet\" $musr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-mod failed "
            rlFail
        else
            rlRun "ipa user-show --all $musr | grep \"$mstreet\""
            if [ $? -ne 0 ];then
                rlLog "ERROR - Search for created user failed "
                rlFail
            else
                rlLog "Success"
                rlPass
            fi
        fi
    rlPhaseEnd   
} #t_modstreet

t_modshell()
{
    rlPhaseStartStart 
        rlLog "START  Modify street"
        rlRun "ipa user-mod --shell=\'$mshell\' $musr"
        if [ $? -ne 0 ];then 
            rlLog "ERROR - ipa user-mod failed "
            rlFail
        else
            rlRun "ipa user-show --all $musr | grep '$mshell'"
            if [ $? -ne 0 ];then
                rlLog "ERROR - Search for created user failed "
                rlFail
            else
                rlLog "Success"
                rlPass
            fi
        fi
    rlPhaseEnd   
} #t_modshell

t_deluser()
{
    rlPhaseStartTest    
        rlLog "START  Delete User"
        for user in "$superuser $musr $lusr"
        do
            rlRun "ipa user-del $user"
            if [ $? -ne 0 ];then
                rlLog "ERROR - Deleting user $user failed "
                rlFail
            else
                rlRun "ipa user-find $user"
                if [ $? -eq 0 ];then
                    rlLog "ERROR - Search for deleted user was successful  when is should not have"
                    rlLog "ERROR possibly related to https://bugzilla.redhat.com/show_bug.cgi?id=504021"
                    rlFail
                else
                    rlLog "Success: user $superuser deleted"
                    rlPass
                fi
            fi
        done
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

