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
	lastname="$username"
        #lastname=`dataGenerator "lastname" $curlen`
    fi
    if [ "$firstname" = "" ];then
	firstname="$username"
        #firstname=`dataGenerator "firstname" $curlen`
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
    rlLog "Creating User: ipa user-add \"$username\" --first \"$firstname\" --last  \"$lastname\" $othercondition"
    ipa user-add --first=$firstname --last=$lastname $othercondition $username
    #rlRun "echo \"$password\" |\
    #       ipa user-add \"$username\" \
    #                    --first \"$firstname\" \
    #                    --last  \"$lastname\" \
    #                    $othercondition \
    #                    --password 2>&1 >/dev/null" \
    #      $expected "create test user account [$username]"
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
    echo $ADMINPW | kinit $ADMINID 2>&1 >/dev/null
} #KinitAsAdmin

clear_kticket()
{
    kdestroy 2>&1 >/dev/null
} #clear_kticket

set_systime()
{
#set system time with given string
# expected input: + 86400 <== set system time to one day later
#                 - 86400 <== set system time to one day before
    local offset=$1
    local before=`date`
    local now
    local desiredtime
    local after
    now=`date "+%s"`
    desiredtime=`echo "$now $offset" | bc`
    date "+%a %b %e %H:%M:%S %Y" -s "`perl -le "print scalar localtime $desiredtime"`"
    after=`date`
    echo "[set system time] before set systime [$before]"
    echo "[set system time] after  set systime [$after]"
    echo "[set system time] offset [$offset] seconds"
} # set_systime

restore_systime()
{
#restore system time by sync with ntp server
#    rlRun "service ntpd stop" 0 "Stopping local ntpd service to sync with external source"
    ntpdate $NTPSERVER
#    rlRun "service ntpd start" 0 "Starting local ntpd service again"
} # restore_systime


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
			  --emaildomain=$default_config_emaildomain \
			  --pwdexpnotify=$default_config_ipapwdexpadvnotify " \
            0 "set ipa config back to default"
    #clear_kticket - annoying!
} # restore_ipaconfig
