#############################################
# this is a testcase file for user-cli test #
#############################################

t_addusertest_envsetup()
{
    rlPhaseStartTest "setup environment for addusertest" # sort=100
        rlLog "kinit as admin"
        kinitAs $admin $adminpassword
        if [ $? -ne 0 ];then
            rlFail "kinit as $admin failed"
        else
            rlPass "kinit as $admin success"
        fi
    rlPhaseEnd
} #t_addusertest_envsetup

t_addusertest_envcleanup()
{
    rlPhaseStartTest "clean up enviroment for addusertest" # sort=199
        kinitAs $admin $adminpassword
        rlRun "ipa user-del $superuser" 0 "delete $superuser account"
        rlRun "ipa user-del $lusr " 0 "delete $lusr account"
        rlLog "run kdestroy to clean up all ticket"
        rlRun "/usr/kerberos/bin/kdestroy" 0 "remove all kinit tickets"
        if [ $? -ne 0 ];then
            rlFail "kinit as admin failed"
        else
            rlPass "kinit as admin success"
        fi
    rlPhaseEnd
} #t_addusertest_envcleanup

t_addusersetup()
{
    rlPhaseStartTest "add user setup" # sort=101
        rlRun "ipa user-add --first=$superuserfirst \
                            --last=$superuserlast \
                            --uid=$uid \
                            --gecos=$superusergecos \
                            --home=$superuserhome \
                            --principal=$superuserprinc \
                            --phone=$phone \
                            --mobil=$mobil \
                            --pager=$pager \
                            --fafx=$fax \
                            --street=\"$street\" \
                            --email=$superuseremail $superuser" \
                            0 \
                            "add user into ipa server"
    rlPhaseEnd
} #t_addusersetup


t_adduserverify()
{
    rlPhaseStartTest "verify the newly added user account" # sort=102
        rlRun "ipa user-find $superuser | grep $superuserfirst" 0 "check user firstname"
        rlRun "ipa user-find $superuser | grep $superuserlast" 0 "check last name"
        rlRun "ipa user-find --all $superuser | grep $superusergecos" 0 "check gecos"
        rlRun "ipa user-find $superuser | grep $superuserhome" 0 "check home directory"
        rlRun "ipa user-find --all $superuser | grep \"$superuserprinc\" " 0 "check principal"
        rlRun "ipa user-find --all $superuser | grep \"$superuseremail\" " 0 "check user email"
        rlRun "ipa user-find --all $superuser | grep \"Telephone Number\" | grep \"$phone\" " 0 "check phone number"
        rlRun "ipa user-find --all $superuser | grep \"Mobile Telephone Number\" | grep \"$mobil\" " 0 "check mobil number"
        rlRun "ipa user-find --all $superuser | grep \"Pager Number\" | grep \"$phone\" " 0 "check pager number"
        rlRun "ipa user-find --all $superuser | grep \"Fax Number\" | grep \"$fax\" " 0 "check fax number"

    rlPhaseEnd
} #t_adduserverify

t_userfind()
{
# test user-find : this should run right after t_adduserverify, which is right after t_addusersetup
    rlPhaseStartTest "user-find: use newly added user account to verify the find command" 
        # call same function to verify 
        #              user-find option               output field         expected value
        userfind_field_check "--login=\"$superuser\" "         "User login"         "$superuser"
        userfind_field_check "--first=\"$superuserfirst\" "    "First name"         "$superuserfirst"
        userfind_field_check "--last=\"$superuserlast\" "      "Last login"         "$superuserlast"
        userfind_field_check "--homedir=\"$superuserhome\" "   "Home directory"     "$superuserhome"
        userfind_field_check "--gecos=\"$superusergecos\" "    "GECOS field"        "$superusergecos"
        userfind_field_check "--shell=\"$shell\" "             "Login shell"        "$shell" # default
        userfind_field_check "--principal=\"$superuserprinc\"" "Kerberos principal" "$superuserprinc"
        userfind_field_check "--email=\"$superuserlast\" "     "Email address"      "$superuseremail"
        userfind_field_check "--uid=\"$uid\" "                 "UID"                "$uid"
        userfind_field_check "--street=\"$street\" "           "Street address"     "$street"
        userfind_field_check "--phone=\"$phone\" "             "Telephone Number"   "$phone"
        userfind_field_check "--mobil=\"$mobil\" "             "Mobile Telephone"   "$mobil"
        userfind_field_check "--pager=\"$pager\" "             "Pager Number"       "$pager"
        userfind_field_check "--fax=\"$fax\" "                 "Fax Number"         "$fax"
        userfind_field_check "--whoami "                       "User login"         "admin" #--whoami does not take any value, it reads the kerberos ticket information
    rlPhaseEnd
    
} #t_userfind

t_negative_adduser()
{
    rlPhaseStartTest "Negative test case: Add duplicated user should fail"  # sort=103 
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
    rlPhaseStartTest "Add user for account lock-unlock test" # sort=104
        rlRun   "ipa user-add --first=$superuserfirst --last=$superuserlast $lusr" \
                0 \
                "add user $lusr for lock-unlock test" 0 "add user for accout lock-unlock test"
        rlRun   "ipa user-find $lusr | grep $lusr" 0 "search for the newly created account"

        # set initial password, and we change it right away
        initialpw="thisjunk10"
        rlRun "echo $initialpw | ipa user-mod --password $lusr" 0 "set initial pasword"
        FirstKinitAs $lusr $initialpw $lusrpw
        if [ $? -ne 0 ]; then
            rlFail "ERROR - kinit failed "
        else
            rlPass "Success - kinit at first time with password [$lusrpw] success"
            rlLog "user account for lock-unlokc test created"
        fi
    rlPhaseEnd
} #t_addlockuser

t_lockuser()
{
    rlPhaseStartTest "Lock User" # sort=105
        # re-kinit as admin, since only admin can lock-unlock user account
        kinitAs $admin $adminpassword
        rlRun "ipa user-disable $lusr" 0 "perform user account locking"
        if [ $? -ne 0 ];then 
            rlFail "ERROR - ipa user-disable failed "
        else
            rlLog "Lock user success"
            kinitAs $lusr $lusrpw
            if [ $? -ne 0 ];then 
                rlPass "kinit as $lusr failed as expected"
            else
                rlFail "kinit as $lusr success when fail expected "
            fi
        fi
    rlPhaseEnd
} # t_lockuser

t_unlockuser()
{
    rlPhaseStartTest "Unlock User" # sort=106
        kinitAs $admin $adminpassword
        rlRun "ipa user-enable $lusr"
        if [ $? -ne 0 ];then 
            rlFail "ERROR - ipa user-disable failed "
        else
            kinitAs $lusr $lusrpw
            if [ $? -ne 0 ];then 
                rlFail "ERROR - kinit as $lusr failed after unlock. expect success "
            else
                rlPass "Success - kinit as $lusr success as expected"
            fi
        fi
    rlPhaseEnd
} #t_unlockuser

t_moduser_envsetup()
{
    rlPhaseStartTest "Add User - Define Only Required Attributes" # sort=200
        rlRun "/usr/kerberos/bin/kdestroy" 0 "remove all kinit tickets"
        kinitAs $admin $adminpassword
        rlRun "ipa user-add --first=superuserfirst --last=superuserlast $musr" 0 "add test user account"
        rlRun "ipa user-find $musr | grep $musr" 0 "confirm the existance of test account"
    rlPhaseEnd
} #t_moduser_envsetup

t_moduser_envcleanup()
{
    rlPhaseStartTest "clean up env for moduser test" # sort=299
        rlRun "ipa user-del $musr" 0 "remove test user account [$musr]"
        rlRun "/usr/kerberos/bin/kdestroy" 0 "remove all kinit tickets"
    rlPhaseEnd
} #t_moduser_envcleanup

t_modfirstname()
{
    rlPhaseStartTest "Modify First Name" # sort=201
        rlRun "ipa user-mod --first=$mfirst $musr" 0 "modify first name"
        rlRun "ipa user-show --all $musr | grep $mfirst" 0 "check the mfirst to verify"
    rlPhaseEnd
} #t_modfirstname

t_modlastname()
{
    rlPhaseStartTest "Modify Last Name" # sort=202
        rlRun "ipa user-mod --last=$mlast $musr" 0 "modify the last name"
        rlRun "ipa user-show --all $musr | grep $mlast" 0 "check last name"
    rlPhaseEnd
} #t_modlastname

t_modemail()
{
     rlPhaseStartTest "Modify email" # sort=203
        rlRun "ipa user-mod --email=\'$memail\' $musr" 0 "modify email"
        rlRun "ipa user-show --all $musr | grep $memail" 0 "check email"
    rlPhaseEnd
} #t_modemail

t_modprinc()
{
    rlPhaseStartTest "Modify principal" # sort=204
        rlRun "ipa user-mod --principal=$mprinc $musr" 0 "modify principal"
        rlRun "ipa user-show --all $musr | grep $mprinc" 0 "check principal"
    rlPhaseEnd   
} #t_modprinc

t_modhome()
{
    rlPhaseStartTest "Modify home directory" # sort=205
        rlRun "ipa user-mod --home=\'$mhome\' $musr" 0 "modify home directory"
        rlRun "ipa user-show --all $musr | grep $mhome" 0 "check home directory"
    rlPhaseEnd   
} #t_modhome

t_modgecos()
{
    rlPhaseStartTest "Modify gecos" # sort=206
        rlRun "ipa user-mod --gecos=$mgecos $musr" 0 "modify gecos"
        rlRun "ipa user-show --all $musr | grep $mgecos" 0 "check gecos"
    rlPhaseEnd   
} #t_modgecos

t_moduid()
{
   rlPhaseStartTest "Modify uid" # sort=207
        rlRun "ipa user-mod --uid=$muid $musr" 0 "modify uid"
        rlRun "ipa user-show --all $musr | grep $muid" 0 "check uid"
    rlPhaseEnd   
} #t_moduid

t_modstreet()
{
    rlPhaseStartTest "Modify street" # sort=208
        rlRun "ipa user-mod --street=\"$mstreet\" $musr" 0 "modify street info"
        rlRun "ipa user-show --all $musr | grep \"$mstreet\"" 0 "check street info"
    rlPhaseEnd   
} #t_modstreet

t_modshell()
{
    rlPhaseStartTest "Modify street" # sort=209
        rlRun "ipa user-mod --shell=\'$mshell\' $musr" 0 "modify shell"
        rlRun "ipa user-show --all $musr | grep '$mshell'" 0 "check shell"
    rlPhaseEnd   
} #t_modshell

t_deluser()
{
    rlPhaseStartTest "delete user"  # sort=400
        rlLog "simple user deletion test already included into adduser test and moduser test, i will test --continue option here "
        kinitAs $admin $adminpassword
        rlRun "ipa user-add testuser0001 --first=test --last=user0001" 0 "add test account testuser0001"
        rlRun "ipa user-add testuser0002 --first=test --last=user0002" 0 "add test account testuser0001"
        rlRun "ipa user-add testuser0003 --first=test --last=user0003" 0 "add test account testuser0001"
        rlRun "ipa user-del --continue testuserNotExist001 testuser0001 testuserNotExist002 testuser0002 testuserNotExist003 testuser0003" 0 "delete users"
        for ac in testuser0001 testuser0002 testuser0003
        do
            if ipa user-find testuser | grep $ac
            then
                rlFail "expect the account [$ac] to be deleted but it is exist"
            else
                rlPass "account [$ac] deleted as expected"
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

t_showusertest_envsetup()
{
    rlPhaseStartTest "show user test env setup" # sort=300
        kinitAs $admin $adminpassword
        if [ $? -ne 0 ];then
            rlFail "kinit as $admin failed, test can not continue"
        else
            rlLog "kinit as $admin success, now create a testing account"
        fi
        rlRun "ipa user-add --first=$sfirst --last=$slast $suser" 0 "add test user account"
        rlRun "ipa user-find $suser | grep $suser" 0 "confirm the existance of test account"
    rlPhaseEnd
} # t_showusertest_envsetup

t_showusertest_envcleanup()
{
    rlPhaseStartTest "show user test env cleanup" # sort=399
        rlRun "/usr/kerberos/bin/kdestroy" 0 "remove all kinit tickets"
        kinitAs $admin $adminpassword 
        rlRun "ipa user-del $suser"
    rlPhaseEnd
} #t_showusetest_envcleanup

t_showall()
{
    rlPhaseStartTest "test --all option of command: ipa user-show" # sort=301
        tmp=/tmp/ipa.showall.$RANDOM.out
        datafile="/iparhts/acceptance/ipa-user-cli/data.showall.fields.txt"
        rlRun "ipa user-show --all $suser > $tmp" 0 "output --all to [$tmp]"
        for field in `cat $datafile`
        do
            rlAssertGrep "$field" $tmp 
        done
        rlAssertGrep "Last name: $slast" $tmp
        rlAssertGrep "First name: $sfirst" $tmp
        rm -f $tmp
    rlPhaseEnd
} #t_showall

t_showraw()
{
    rlPhaseStartTest "test --raw option of command: ipa user-show" # sort=302
        tmp=/tmp/ipa.showraw.$RANDOM.out
        datafile="/iparhts/acceptance/ipa-user-cli/data.showraw.fields.txt"
        rlRun "ipa user-show --raw $suser > $tmp" 0 "output --all to [$tmp]"
        for field in `cat $datafile`
        do
            rlAssertGrep "$field" $tmp
        done
        rlAssertGrep "sn: $slast" $tmp
        rlAssertGrep "givenname: $sfirst" $tmp
        rm -f $tmp
    rlPhaseEnd
} #t_showraw

