# called by t.ipaconfig.sh

string_exist_infile(){
    local string=$1
    local file=$2
    if [ ! -z "$string" ] && [ -f $file ];then
        found=`grep "$string" $file 2>&1`
        if [ $? = 0 ] ; then
            rlPass "found [$found] in [$file]"
        else
            rlFail "not found [$found] in [$file]"
        fi
    fi
} #string_exist

create_ipauser()
{
    local expected=$1
    local username=$2
    local firstname=$3
    local lastname=$4
    local password=$5
    local othercondition=$6
    local curlen=`getrandomint 1 $default_config_usernamelength`

    if [ "$username" = "" ];then
        username=`dataGenerator "username" $curlen`
    fi
    if [ "$lastname" = "" ];then
        lastname=`dataGenerator "lastname" $curlen`
    fi
    if [ "$firstname" = "" ];then
        firstname=`dataGenerator "firstname" $curlen`
    fi
    if [ "$password" = "" ];then
        password=`dataGenerator "password" 8`
    fi

    #rlLog "create ipa user: username=[$username],first=[$firstname],last=[$lastname], password=[$password]"
    user_exist $username
    if [ $? = 0 ]
    then
        delete_ipauser $username
    fi
    KinitAsAdmin
    rlRun "echo \"$password\" |\
           ipa user-add \"$username\" \
                        --first \"$firstname\" \
                        --last  \"$lastname\" \
                        $othercondition \
                        --password 2>&1 >/dev/null" \
          $expected "create test user account [$username]"
    clear_kticket
} # create_ipauser

delete_ipauser()
{
    local username=$1
    KinitAsAdmin
    rlRun "ipa user-del \"$username\" 2>&1 >/dev/null" 0 "delete test account [$username]"
    clear_kticket
} # delete_ipauser

user_exist()
{
# return 0 if user exist
# return 1 if user account does NOT exist
    local userlogin=$1
    local out=$TmpDir/userexist.$RANDOM.out
    if [ ! -z "$userlogin" ]
    then
        KinitAsAdmin
        ipa user-find \"$userlogin\" > $out
        clear_kticket
        if grep -i "User login: $userlogin$" $out 2>&1 >/dev/null
        then
            #rlLog "find [$userlogin] in ipa server"
            rm $out
            return 0
        else
            #rlLog "didn't find [$userlogin]"
            rm $out
            return 1
        fi
    else
        return 1 # when login value not given, return not found
    fi
    rm $out
} #user_exist

KinitAsAdmin()
{
    # simple kinit function
    echo $adminpassword | kinit $admin 2>&1 >/dev/null
    #rlRun "echo $adminpassword | kinit $admin"
} #KinitAsAdmin

makereport()
{
    # capture the result and make a simple report
    total=`rlJournalPrintText | grep "RESULT" | wc -l`
    pass=`rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]" | wc -l`
    fail=`rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]" | wc -l`
    abort=`rlJournalPrintText | grep "RESULT" | grep "\[  ABORT   \]" | wc -l`
    report=$TmpDir/rhts.report.$RANDOM.txt
    echo "================ final pass/fail report =================" > $report
    echo "   Test Date: `date` " >> $report
    echo "   Total : [$total] "  >> $report
    echo "   Passed: [$pass] "   >> $report
    echo "   Failed: [$fail] "   >> $report
    echo "   Abort : [$abort]"   >> $report
    echo "---------------------------------------------------------" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[  ABORT   \]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "=========================================================" >> $report
    echo "report saved as: $report"
    cat $report
}

clear_kticket()
{
    kdestroy 2>&1 >/dev/null
} #clear_kticket

restore_ipaconfig()
{
    KinitAsAdmin
    rlRun "ipa config-mod --maxusername=$default_config_usernamelength \
                          --homedirectory=$default_config_homebase \
                          --defaultshell=$default_config_shell \
                          --defaultgroup=$default_config_usergroup \
                          --searchtimelimit=$default_config_timelimit \
                          --searchrecordslimit=$default_config_sizelimit \
                          --usersearch=$default_config_usersearchfields \
                          --groupsearch=$default_config_groupsearchfields \
                          --enable-migration=$default_config_migrationmode \
                          --subject=$default_config_certsubjectbase " \
            0 "set ipa config back to default"
    clear_kticket
} # restore_ipaconfig
