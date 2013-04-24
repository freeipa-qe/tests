#!/bin/sh

########################################################################
#  IPA SERVER SHARED LIBRARY
#######################################################################
# Includes:
#	kinitAs
#	FirstKinitAs
#       os_nslookup
#       os_getdomainname
#	getBaseDN
#	verifyErrorMsg
#	AddToKnowHosts
#	setAttribute
#	addAttribute
#       create_ipauser
#       delete_ipauser
#       fixResolv
# 	ssh_auth_success
# 	ssh_auth_failure
#	ftp_auth_success
#	ftp_auth_failure
#	interactive
#	remoteExec
#	pkey_return_check
#       getReverseZone_IPv6
#	ipa_quick_uninstall
#	check_coredump
#   submit_log
#   submit_logs
#	rlDistroDiff
#   unindent
######################################################################
cat /etc/redhat-release | grep "5\.[0-9]"
if [ $? -eq 0 ] ; then
	KINITEXEC=/usr/kerberos/bin/kinit
else
	KINITEXEC=/usr/bin/kinit
fi
#######################################################################
# kinitAs Usage:
#       kinitAs <username> <password>
#####################################################################
kinitAs()
{
   local username=$1
   local password=$2
   local rc=0
   local expfile=/tmp/kinit.exp
   local outfile=/tmp/kinitAs.out

   rm -rf $expfile
   echo 'set timeout 30
set force_conservative 0
set send_slow {1 .1}' > $expfile
   echo "spawn $KINITEXEC -V $username" >> $expfile
   echo 'match_max 100000' >> $expfile
   echo 'expect "*: "' >> $expfile
   echo 'sleep .5' >> $expfile
   echo "send -s -- \"$password\"" >> $expfile
   echo 'send -s -- "\r"' >> $expfile
   echo 'expect eof ' >> $expfile

   kdestroy;/usr/bin/expect $expfile
   
   # verify credentials
   klist > $outfile
   grep $username $outfile
   if [ $? -ne 0 ] ; then
	rlLog "ERROR: kinit as $username with password $password failed."
	rc=1
   else
	rlLog "kinit as $username with password $password was successful."
   fi
   return $rc
}  

#######################################################################
# FirstKinitAs Usage:
#       FirstKinitAs <username> <initial_password> <new_password>
#####################################################################
FirstKinitAs()
{
    local username=$1
    local password=$2
    local newpassword=$3
    local rc=0
    local expfile=/tmp/kinit.exp
    local outfile=/tmp/kinitAs.out

    rm -rf $expfile
    echo 'set timeout 30
set send_slow {1 .1}' > $expfile
    echo "spawn $KINITEXEC -V $username" >> $expfile
    echo 'match_max 100000' >> $expfile
    echo 'expect "*: "' >> $expfile
    echo 'sleep .5' >> $expfile
    echo "send -s -- \"$password\"" >> $expfile
    echo 'send -s -- "\r"' >> $expfile
    echo 'expect "*: "' >> $expfile
    echo 'sleep .5' >> $expfile
    echo "send -s -- \"$newpassword\"" >> $expfile
    echo 'send -s -- "\r"' >> $expfile
    echo 'expect "*: "' >> $expfile
    echo 'sleep .5' >> $expfile
    echo "send -s -- \"$newpassword\"" >> $expfile
    echo 'send -s -- "\r"' >> $expfile
    echo 'expect eof ' >> $expfile

    kdestroy;/usr/bin/expect $expfile

    # verify credentials
    klist > $outfile
    grep $username $outfile
    if [ $? -ne 0 ] ; then
        rlLog "ERROR: kinit as $username with new password $newpassword failed."
        rc=1
    else
        rlLog "kinit as $username with new password $newpassword was successful."
    fi
    return $rc
} #FirstKinitAs

#######################################################################
# os_nslookup Usage:
#       os_nslookup
#####################################################################
os_nslookup()
{
local h=$1
case $ARCH in
        "Linux "*)
                rval=`nslookup -sil $h`
                if [ `expr "$rval" : "server can't find"` -gt 0 ]; then
                        tmpdn=`domainname -f`
                        echo "Name: $tmpdn"
                        tmpaddr=`/sbin/ifconfig -a | egrep inet | egrep -v 127.0.0.1 | egrep -v inet6 | awk '{print $2}' | awk -F: '{print $2}'`
                        echo "Addr: $tmpaddr"
                else
                        nslookup -sil $h
                fi
                ;;
        *)
                nslookup $h
                ;;
esac
}

#######################################################################
# os_getdomainname Usage:
#       mydomain=`os_getdomainname`
#####################################################################

os_getdomainname()
{
   local mydn=`hostname | nslookup 2> /dev/null | grep 'Name:' | cut -d"." -f2-`
   if [ "$mydn" = "" ]; then
     mydn=`hostname -f |  cut -d"." -f2-`
   fi
   echo "$mydn"
}

#######################################################################
# getBaseDN Usage:
#       basedn=`getBaseDN`
#####################################################################
getBaseDN()
{
  local domain=`os_getdomainname`
  echo dc=$domain > /tmp/domain.out
  local basedn=`cat /tmp/domain.out | sed -e 's/\./,dc=/g'`

  echo "$basedn"
}

#########################################################################
# verifyErrorMsg Usage:
#	verifyErrorMsg <command> <expected_msg>
#######################################################################

verifyErrorMsg()
{
   local command=$1
   local expmsg=$2
   local rc=0

   rm -rf /tmp/errormsg.out /tmp/errormsg_clean.out
   rlLog "Executing: $command"
   $command
   rc=$?
   if [ $rc -eq 0 ] ; then
        rlLog "ERROR: Expected \"$command\" to fail."
        rc=1
   else
	rlLog "\"$command\" failed as expected."
        $command 2> /tmp/errormsg.out
	sed 's/"//g' /tmp/errormsg.out > /tmp/errormsg_clean.out
        actual=`cat /tmp/errormsg_clean.out`
        if [[ "$actual" = "$expmsg" ]] ; then
                rlPass "Error message as expected: $actual"
		return 0
        else
                rlFail "ERROR: Message not as expected. GOT: $actual  EXP: $expmsg"
                return 1
        fi
  fi

  return $rc
}

#########################################################################
# AddToKnownHosts
#   Add the machine with the hostname in $1 to the sshknown hosts file.
#   This sub will also remove any entries for the defined hostname from 
#    known hosts before completing. This sub assumes that the shared libs are 
#    installed, this should set up id_rsa and id_dsa in the root's .ssh dir
#   Usage: AddToKnownHosts <fullhostname>
#   Returns 1 if $1 is empty
#   Returns 0 if everything seems to have worked.
#######################################################################
AddToKnownHosts()
{
	TET_TMP_DIR=/opt/rhqa_ipa
	if [ "$1" != "" ]; then 
		rlLog "creating expect file to add $1 to known hosts file"
		export SHELL="/bin/bash"
		echo '#!/usr/bin/expect -f
set timeout 30
set send_slow {1 .1}
spawn $env(SHELL)
match_max 100000' > $TET_TMP_DIR/setup-ssh-remote.exp
		echo "send -s -- \"ssh root@$1 'ls /'\"" >> $TET_TMP_DIR/setup-ssh-remote.exp
		echo "expect \"*'ls /'\"" >> $TET_TMP_DIR/setup-ssh-remote.exp
		echo 'sleep .1
send -s -- "\r"
expect "*Are you sure you want to continue connecting (yes/no)? "
sleep .1
send -s "yes\r"
#expect "*"
expect eof' >> $TET_TMP_DIR/setup-ssh-remote.exp
		chmod 755 $TET_TMP_DIR/setup-ssh-remote.exp
		rlLog "Running expect script to add $1 to known hosts file"
		# Clearing known_hosts file of previous entries
		if [ ! -d ~/.ssh ]; then
			mkdir -p ~/.ssh
			chmod 600 ~/.ssh
		fi
		cat ~/.ssh/known_hosts | grep -v $1 > /opt/rhqa_ipa/known_hosts
		cat /opt/rhqa_ipa/known_hosts > ~/.ssh/known_hosts
		chmod 600 ~/.ssh/known_hosts
		chmod 777 $TET_TMP_DIR/setup-ssh-remote.exp
		expect $TET_TMP_DIR/setup-ssh-remote.exp &> /opt/rhqa_ipa/ssh-known-setup-update.txt
		return 0
	else
		rlLog "AddToKnownHosts called improperly, please see shared lib for usage"
		return 1
	fi
}

#######################################################################
# setAttribute Usage:
#       setAttribute <topic> <attribute> <value> <object>
# Example:
#	setAttribute host location "Lab 3" jennyv2.bos.redhat.com
#####################################################################

setAttribute()
{
	local topic=$1
		local attr=$2
		local value=$3
		local object=$4
		local rc=0

		rlLog "Executing: ipa $topic-mod --setattr $attr=\"$value\" $object"
		ipa $topic-mod --setattr $attr="$value" $object
		rc=$?
		if [ $rc -ne 0 ] ; then
			rlLog "ERROR: Failed to set value for attribute $attr."
				rc=1
		else
			rlLog "Successfully set attribute $attr to \"$value\""
				fi

				return $rc
} #setAttribute

#######################################################################
# addAttribute Usage:
#       addAttribute <topic> <attribute> <value> <object>
# Example:
#       addAttribute host location "Lab 3" jennyv2.bos.redhat.com
#####################################################################

addAttribute()
{
	local topic=$1
		local attr=$2
		local value=$3
		local object=$4
		local rc=0

		rlLog "Executing: ipa $topic-mod --addattr $attr=\"$value\" $object"
		ipa $topic-mod --addattr $attr="$value" $object
		rc=$?
		if [ $rc -ne 0 ] ; then
			rlLog "ERROR: Failed to add additional attribute value for attribute $attr."
				rc=1
		else
			rlLog "Successfully added additional attribute $attr with value \"$value\""
				fi
				return $rc
} #addAttribute

#############################################################################
# makereport Usage: (generates summary report)
#	makereport <full_path_and_name_for_report_location>
#############################################################################

makereport()
{
    check_coredump
    local report=$1
    if [ -n "$report" ];then
        touch $report
    else
        if [ ! -w "$report" ];then
            report=/tmp/rhts.report.$RANDOM.txt
            touch $report
        else
            touch $report
        fi
    fi
    # capture the result and make a simple report
    local total=`rlJournalPrintText | grep "RESULT" | wc -l`
    local unfinished=`rlJournalPrintText | grep "RESULT" | grep "\[unfinished\]" | wc -l`
    local pass=`rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]" | wc -l`
    local fail=`rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]" | wc -l`
    local abort=`rlJournalPrintText | grep "RESULT" | grep "\[  ABORT   \]" | wc -l`
    if rlJournalPrintText | grep "^:: \[   FAIL   \] :: RESULT: $" 
    then
        total=$((total-1))
        fail=$((fail-1))
    fi
    echo "========================== Final Pass/Fail Report ===========================" > $report
    echo "  Test Date: `date` " >> $report
    echo "     Total : [$total] "  >> $report
    echo "     Passed: [$pass] "   >> $report
    echo "     Failed: [$fail] "   >> $report
    echo " Unfinished: [$unfinished] "   >> $report
    echo "     Abort : [$abort]"   >> $report
    echo "     Crash : [$crashes]" >> $report
    echo " ---------------------------------------------------------" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]"| grep -v "^:: \[   FAIL   \] :: RESULT: $" | sed -e 's/:/ /g' -e 's/RESULT//g'  >> $report
    echo "" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[unfinished\]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[  ABORT   \]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "===========================[$report]===============================" >> $report
    cat $report
    echo "[`date`] test summary report saved as: $report"
    echo ""
} #makereport

############################################################################
# getReverseZone Usage: (returns reverse zone)
#	rzone=`getReverseZone`
###########################################################################

getReverseZone()
{
	rzonedn=`ipa dnszone-find | grep "Zone name:" | grep arpa`
		if [ $? -eq 0 ] ; then
			rzone=`echo $rzonedn | cut -d ":" -f 2`
		else
			rlLog "WARNING: No Reverse DNS zone found"
				rc=1
				fi

				echo $rzone
				return $rc
} #getReverseZone


KinitAsAdmin()
{
	echo $ADMINPW | $KINITEXEC $ADMINID 2>&1 >/dev/null
} #KinitAsAdmin

Kcleanup()
{ #clear all kerberos tickets
    kdestroy 2>&1 >/dev/null
} #Kcleanup

KinitAsUser()
{
    local userlogin=$1
    local password=$2
    echo $password | $KINITEXEC $userlogin 2>&1 >/dev/null
} #KinitAsUser

create_ipauser()
{
    local login=$1
    local firstname=$2
    local lastname=$3
    local password=$4
    local dummypw="dummy123@ipa.com"

    if [ "$login" = "" ];then
        login="ipatest${RANDOM}"
    fi
    if [ "$firstname" = "" ];then
        firstname="fName${RANDOM}"
    fi
    if [ "$lastname" = "" ];then
        lastname="lName${RANDOM}"
    fi
    if [ "$password" = "" ];then
        password="testpw123@ipa.com"
    fi

    rlLog "create ipa user: [$login], firstname: [$firstname], lastname: [$lastname]  password: [$password]"
    ipauser_exist $login
    if [ $? = 0 ]
    then
        delete_ipauser $login
    fi
    rlLog "create ipa user: [$login], password: [$password]"
    KinitAsAdmin
    
    rlRun "echo $dummypw |\
           ipa user-add $login \
                        --first $firstname\
                        --last  $lastname\
                        --password " \
          0 "add test user account"
          #0 "add test user account" 2>&1 >/dev/null
    # set test account password 
    #FirstKinitAs $login $dummypw $password 2>&1 >/dev/null
    sleep 2  # adding sleep think that first kinit hits slave sometimes and the user is not replicated yet.
    FirstKinitAs $login $dummypw $password 
    /usr/bin/kdestroy 2>&1 >/dev/null #clear admin's kerberos ticket
    echo $login
} #create_ipauser

delete_ipauser()
{
    local login=$1
    ipauser_exist $login
    if [ $? = 0 ]
    then
        KinitAsAdmin
        rlRun "ipa user-del $login" 0 "delete account [$login]"
        /usr/bin/kdestroy 2>&1 >/dev/null #clear admin's kerberos ticket
    else
        rlLog "account [$login] does not exist, do nothing"
    fi
} #delete_ipauser

ipauser_exist()
{
# return 0 if user exist
# return 1 if user account does NOT exist
    local login=$1
    if [ ! -z "$login" ]
    then
        KinitAsAdmin
        if ipa user-find $login| grep -i "User login: $login$" 2>&1 >/dev/null
        then
            #rlLog "find [$login] in ipa server"
            return 0
        else
            #rlLog "didn't find [$login]"
            return 1
        fi
    else
        return 1 # when login value not given, return not found
    fi
} #ipauser_exist

#######################################################################
# execManageNGPPlugin Usage:
#       execManageNGPPlugin "NGP Definition" <enable | disable | status>
# 
#####################################################################

execManageNGPPlugin()
{
   local entry="NGP Definition"
   local option=$1
   local outfile=/tmp/plugin.out

   rlLog "Executing /usr/sbin/ipa-managed-entries --entry=\"$entry\" $option"
   /usr/sbin/ipa-managed-entries --entry="$entry" $option

   /usr/sbin/ipa-managed-entries --entry="$entry" status 2>&1 > $outfile
   status=`cat $outfile`
   rlLog "NPG Plugin Status: $status"
}


#######################################################################
# fixResolv
# This copies resolv.conf to a backup location, then modifies the 
# contentes of the main resolv.conf to point at the MASTER server
# mgregg 2-17-2010
#######################################################################
fixResolv()
{
	rm -f /opt/rhqa_ipa/ipa-resolv.conf-backup
	cat /etc/resolv.conf > /opt/rhqa_ipa/ipa-resolv.conf-backup
	if [ $MASTER ]; then
		ipofmaster=`ping $MASTER -c 1 | grep PING | sed s/\(//g | sed s/\)//g | cut -d\  -f3`
		sed -i s/^nameserver/#nameserver/g /etc/resolv.conf
		sed -i s/^search/#search/g /etc/resolv.conf
		echo "nameserver $ipofmaster" >> /etc/resolv.conf
		echo "search $DOMAIN" >> /etc/resolv.conf
		return 0
	else
		echo "ERROR - MASTER not set in env"
		return 1
	fi
}





###################################################################
# qaRun
#  In an an error condition, this checks the return code received, 
#  and if that matches the expected, then checks the message.
#  This method greps for the error messsage - so only 
#  partial expected message can be checked.
#
#  $1 the command to run
#  $2 the temp file to use to write the output of command to
#  $3 the expected retun code when the command runs
#  $4 expected messages to verify the output. A list of these 
#  $5 a comment to indicate what the command does
#  $6 set the debug flag, by passing the parameter as "debug" 
#     (without the quotes)
###################################################################
qaRun()
{
    local cmd="$1"
    local out="$2"
    local expectCode="$3"
    local expectMsg="$4"
    local comment="$5"
    local debug=$6
    rlLog "cmd=[$cmd]"
    rlLog "expect [$expectCode], out=[$out]"
    rlLog "$comment"
    
    $1 >& $out
    actualCode=$?
    if [ "$actualCode" = "$expectCode" ];then
        rlLog "return code matches, now check the message"
        if grep -i "$expectMsg" $out 2>&1 >/dev/null
        then 
            rlPass "expected return code and msg matches"
        else
            rlFail "return code matches,but message does not match expection";
            debug="debug"
        fi
    else
        rlFail "expect [$expectCode] actual [$actualCode]"
        debug="debug"
    fi
    # if debug is defined
    if [ "$debug" = "debug" ];then
        echo "--------- expected msg ---------"
        echo "[$expectMsg]"
        echo "========== execution output ==============="
        cat $out
        echo "============== end of output =============="
    fi
} #checkErrorMsg


####################################################################
## ssh_auth_success
## Usage: ssh_auth_success user password host

ssh_auth_success()
   {
        {
user=$1
passwd=$2
host=$3

    expect -f - <<-EOF | grep -C 77 '^login successful'
            spawn ssh -q -o StrictHostKeyChecking=no -l "$user" $host echo 'login successful'
            expect {
                    "*assword: " {
                    send -- "$passwd\r"
                            }
                   }
            expect eof
EOF


if [ $? = 0 ]; then
	rlPass "Authentication successful for $user, as expected"
	else   
        rlFail "ERROR: Authentication failed for $user, expected success."
fi
        }
   }


####################################################################
## ssh_auth_failure
## Usage: ssh_auth_failure user password host

ssh_auth_failure()
   {
        {
user=$1
passwd=$2
host=$3

    expect -f - <<-EOF | grep -C 77 '^login successful'
           spawn ssh -q -o StrictHostKeyChecking=no -l "$user" $host echo 'login successful'
           expect {
                  "*assword: " {
                   send -- "$passwd\r"
                           }
                  }
           expect eof
EOF


if [ $? = 0 ]; then
	rlFail "ERROR: Authentication success for $user, expected failure."
        else
        rlPass "Authentication failed for $user, as expected"
fi
        }
   }


####################################################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ftp_auth_success
# Usage: ftp_auth_success user password host
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ftp_auth_success()
   {
        {

           ftp -inv $3 > /tmp/ftplog << EOF
           user $1 $2
           quit
EOF

           grep "Login successful." /tmp/ftplog
           if [ $? = 0 ]; then
                rlPass "Authentication successful, as expected"
           else
                rlFail "ERROR: Authentication failed."
           fi
        }
   }

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ftp_auth_failure
# Usage: ftp_auth_failure user password host
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ftp_auth_failure()
   {
        {

           ftp -inv $3 > /tmp/ftplog << EOF
           user $1 $2
           quit
EOF

           grep "Login successful." /tmp/ftplog
           if [ $? = 0 ]; then
                rlFail "ERROR: Authentication success."
           else
                rlPass "Authentication failed, as expected"
           fi
        }
   }

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# interactive
# Usage: interactive ipa command option
# 
# This constructs a expect file which is then executed so as to cover
# ipa commands interactive testing.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

interactive() {

count=2

expfile=/tmp/interactive.exp
expout=/tmp/interactive.out

rm -rf $expfile $expout

echo 'set timeout 30
set send_slow {1 .1}' > $expfile
echo "spawn $1 $2" >> $expfile
echo 'match_max 100000' >> $expfile

while [ $count -lt $# ]; do
        let count=count+1
	        echo 'expect "*: "' >> $expfile
	        echo 'sleep .5' >> $expfile
	        eval "echo \"send -s -- \"\$$count\"\"" >> $expfile
	        echo 'send -s -- "\r"' >> $expfile
done
	        echo 'send -s -- "\r"' >> $expfile

echo 'expect eof ' >> $expfile

	echo "Constructed expect file is:"
		/bin/cat $expfile
	echo ""
		/usr/bin/expect $expfile >> $expout 2>&1
	echo ""
	echo "Interactive command output:"
		/bin/cat $expout
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# remoteExec
# Usage: remoteExec user hostname password command
# 
# This constructs a expect file which is then executed so as to execute 
# any remote command on the specified hostname.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

remoteExec() {

expfile=/tmp/remote_exec.exp
expout=/tmp/remote_exec.out

rm -rf $expfile $expout

expfile=/tmp/remote_exec.exp
expout=/tmp/remote_exec.out

rm -rf $expfile $expout

echo 'set timeout 30
set send_slow {1 .1}' > $expfile
	echo "spawn ssh -l $1 $2" >> $expfile
	echo 'match_max 100000' >> $expfile
	echo 'sleep 3' >> $expfile
	echo 'expect "*: "' >> $expfile
	echo "send \"$3\"" >> $expfile
	echo 'send "\r"' >> $expfile
	echo 'sleep 3' >> $expfile
	echo 'expect "*# "' >> $expfile
	echo "send \"$4\"" >> $expfile
	echo 'send "\r"' >> $expfile
	echo 'expect eof ' >> $expfile

		rlRun "/usr/bin/expect $expfile >> $expout 2>&1"

	# for verbosity
	rlRun "cat $expfile"
        rlRun "cat $expout"
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# pkey_return_check
	# Check that the pkey-only option seems to function of the ipa *-find cli option
	# Required inputs are:
	# ipa_command_to_test: This is the command we are testing, (user, group, service)
	# pkey_addstringa: will be used as ipa $ipa_command_to_test-add $addstring $pkeyobja
	# pkey_addstringb: will be used as ipa $ipa_command_to_test-add $addstring $pkeyobjb
	# pkeyobja - This is the username/groupname/object to create. this object must come up in 
	#      the resuts when a find search string is run against "general-find-string".
	#      This user/object must not exist on the system
	# pkeyobjb - This is a second username/groupname/object to create. This object must also 
	#      come up in the resuts when a find search string is run against "general-find-string"
	#      This user/object must not exist on the system
	# grep_string - This is the specific string that denotes the line to look for in the 
	#      "ipa *-find --pkey-only" output
	# general_search_string - This string will be used as "ipa *-find --pkey-only $general_search_string"
	#      Searching this way must return both pkeyobja and pkeyobjb.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pkey_return_check()
{
	creturn=0
	rlLog "executing ipa $ipa_command_to_test-add $pkey_addstringa $pkeyobja"
	ipa $ipa_command_to_test-add $pkey_addstringa $pkeyobja
	ipa $ipa_command_to_test-add $pkey_addstringb $pkeyobjb
	rlLog "executing ipa $ipa_command_to_test-find --pkey-only $pkeyobja | grep $grep_string | grep $pkeyobja"
	rlRun "ipa $ipa_command_to_test-find --pkey-only $pkeyobja | grep $grep_string | grep $pkeyobja" 0 "make sure the $ipa_command_to_test is returned when the --pkey-only option is specified"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --pkey-only $general_search_string | grep $grep_string | grep $pkeyobja" 0 "make sure the $ipa_command_to_test is returned when the --pkey-only option is specified"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --pkey-only $general_search_string | grep $grep_string | grep $pkeyobjb" 0 "make sure the $ipa_command_to_test is returned when the --pkey-only option is specified"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-del $pkeyobja" 0 "deleting the first object from this test ($pkeyobja)"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-del $pkeyobjb" 0 "deleting the first object from this test ($pkeyobjb)"
	let creturn=$creturn+$?
	return $creturn
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# in_roles_return_check
	# Check that the in-role and not-in-role option seems to function in the ipa *-find cli option
	# Required inputs are:
	# ipa_command_to_test: This is the command we are testing, (user, group, service)
	# role_addstringa: will be used as ipa $ipa_command_to_test-add $addstring $pkeyobja
	# role_addstringb: will be used as ipa $ipa_command_to_test-add $addstring $pkeyobjb
	# role_addstringc: will be used as ipa $ipa_command_to_test-add $addstring $pkeyobjc
	# roleobja - This is the username/groupname/object to create. this object must come up in 
	#      the resuts when a find search string is run against "general-find-string".
	#      This user/object must not exist on the system
	# roleobjb - This is a second username/groupname/object to create. This object must also 
	#      come up in the resuts when a find search string is run against "general-find-string"
	#      This user/object must not exist on the system
	# roleobjc - This is a second username/groupname/object to create. This object must also 
	#      come up in the resuts when a find search string is run against "general-find-string"
	#      This user/object must not exist on the system
	# grep_string - This is the specific string that denotes the line to look for in the 
	#      "ipa *-find --pkey-only" output
	# general_search_string - This string will be used as "ipa *-find --pkey-only $general_search_string"
	#      Searching this way must return both pkeyobja and pkeyobjb.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
in_roles_return_check()
{
	creturn=0
	role1=trolea
	role2=troleb
	rlLog "executing ipa $ipa_command_to_test-add $role_addstringa $roleobja"
	membertype=$(echo "$ipa_command_to_test"s)
	ipa $ipa_command_to_test-add $role_addstringa $roleobja
	ipa $ipa_command_to_test-add $role_addstringb $roleobjb
	ipa $ipa_command_to_test-add $role_addstringb $roleobjc
	rlRun "ipa role-add --desc=desc1 $role1" 0 "adding $role1"
	rlRun "ipa role-add --desc=desc1 $role2" 0 "adding $role2"
	rlRun "ipa role-add-member --$membertype=$roleobja $role1" 0 "adding $roleobja to role $role1"
	rlRun "ipa role-add-member --$membertype=$roleobjc $role1" 0 "adding $roleobjc to role $role1"

	rlLog "executing ipa $ipa_command_to_test-find --in-roles $role1 | grep $grep_string | grep $roleobja"
	rlRun "ipa $ipa_command_to_test-find --in-roles $role1 | grep $grep_string | grep $roleobja" 0 "make sure roleobja is returned when the --in-roles option is specifing searching in role1"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --in-roles $role1 | grep $grep_string | grep $roleobjc" 0 "make sure roleobjc is returned when the --in-roles option is specifing searching in role1"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --in-roles $role1 | grep $grep_string | grep $roleobjb" 1 "make sure roleobjb is not returned when the --in-roles option is specifing searching in role1"
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role1 | grep $grep_string | grep $roleobjb" 0 "make sure roleobjb is returned when the --not-in-roles option is specifing searching in role1"
	let creturn=$creturn+$?
echo "ipa $ipa_command_to_test-find --not-in-roles $role1 | grep $grep_string | grep $roleobja"
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role1 | grep $grep_string | grep $roleobja" 1 "make sure roleobja is not returned when the --not-in-roles option is specifing searching in role1"
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role1 | grep $grep_string | grep $roleobjc" 1 "make sure roleobjc is not returned when the --not-in-roles option is specifing searching in role1"
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role2 | grep $grep_string | grep $roleobja" 0 "make sure roleobja is returned when the --not-in-roles option is specifing searching in role2 after roleobjc was removed from role"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role2 | grep $grep_string | grep $roleobjb" 0 "make sure roleobjb is returned when the --not-in-roles option is specifing searching in role2 after roleobjc was removed from role"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role2 | grep $grep_string | grep $roleobjc" 0 "make sure roleobjc is returned when the --not-in-roles option is specifing searching in role2 after roleobjc was removed from role"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --in-roles $role2 | grep $grep_string | grep $roleobja" 1 "make sure roleobja is not returned when the --in-roles option is specifing searching in role2 after roleobjc was removed from role"
	rlRun "ipa $ipa_command_to_test-find --in-roles $role2 | grep $grep_string | grep $roleobjb" 1 "make sure roleobjb is not returned when the --in-roles option is specifing searching in role2 after roleobjc was removed from role"
	rlRun "ipa $ipa_command_to_test-find --in-roles $role2 | grep $grep_string | grep $roleobjc" 1 "make sure roleobjc is not returned when the --in-roles option is specifing searching in role2 after roleobjc was removed from role"
	rlRun "ipa role-remove-member --$membertype=$roleobjc $role1" 0 "removing roleobjc from role1"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role1 | grep $grep_string | grep $roleobja" 1 "make sure roleobja is not returned when the --not-in-roles option is specifing searching in role1 after roleobjc was removed from role"
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role1 | grep $grep_string | grep $roleobjc" 0 "make sure roleobjc is returned when the --not-in-roles option is specifing searching in role1 after roleobjc was removed from role"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role1 | grep $grep_string | grep $roleobjb" 0 "make sure roleobjb is returned when the --not-in-roles option is specifing searching in role1 after roleobjc was removed from role"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role2 | grep $grep_string | grep $roleobja" 0 "make sure roleobja is returned when the --not-in-roles option is specifing searching in role2 after roleobjc was removed from role"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role2 | grep $grep_string | grep $roleobjb" 0 "make sure roleobjb is returned when the --not-in-roles option is specifing searching in role2 after roleobjc was removed from role"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --not-in-roles $role2 | grep $grep_string | grep $roleobjc" 0 "make sure roleobjc is returned when the --not-in-roles option is specifing searching in role2 after roleobjc was removed from role"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-find --in-roles $role2 | grep $grep_string | grep $roleobja" 1 "make sure roleobja is not returned when the --in-roles option is specifing searching in role2 after roleobjc was removed from role"
	rlRun "ipa $ipa_command_to_test-find --in-roles $role2 | grep $grep_string | grep $roleobjb" 1 "make sure roleobjb is not returned when the --in-roles option is specifing searching in role2 after roleobjc was removed from role"
	rlRun "ipa $ipa_command_to_test-find --in-roles $role2 | grep $grep_string | grep $roleobjc" 1 "make sure roleobjc is not returned when the --in-roles option is specifing searching in role2 after roleobjc was removed from role"
	rlRun "ipa role-del $role1" 0 "Removing role 1"
	rlRun "ipa role-del $role2" 0 "Removing role 2"
	rlRun "ipa $ipa_command_to_test-del $roleobja" 0 "deleting the first object from this test ($roleobja)"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-del $roleobjb" 0 "deleting the first object from this test ($roleobjb)"
	let creturn=$creturn+$?
	rlRun "ipa $ipa_command_to_test-del $roleobjc" 0 "deleting the first object from this test ($roleobjc)"
	let creturn=$creturn+$?
	return $creturn
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# getReverseZone_IPv6
# Usage: getReverseZone_IPv6 IPv6-address
#
# This constructs a reverse zone value for an IPv6 address
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
getReverseZone_IPv6()
{
        local ipv6addr=$1
        rc=0
        rlLog "IPv6 address is $ipv6addr"
        if [ ipv6addr ] ; then
          octet_1=$(echo $ipv6addr | awk -F : '{print $1}')
          octet_2=$(echo $ipv6addr | awk -F : '{print $2}')
          octet_3=$(echo $ipv6addr | awk -F : '{print $3}')
          octet_4=$(echo $ipv6addr | awk -F : '{print $4}')
          rzonedn_ipv6=""
          for item in $octet_4 $octet_3 $octet_2 $octet_1 ; do
                while [ ${#item} -lt 4 ]
                do
                     item="0"$item
                done
                for (( i=4; $i >= 1; i-- ))
                do
                        digit=$(echo $item | cut -c $i)
                        rzonedn_ipv6=$rzonedn_ipv6$digit"."
                done
          done
          rzonedn_ipv6=$rzonedn_ipv6"ip6.arpa."
          rlLog "Reverse zone: $rzonedn_ipv6"
        else
          rlLog "WARNING: No IPv6 address found, Reverse DNS zone is not calculated."
          rc=1
        fi
        echo "$rzonedn_ipv6"
        return $rc
} #getReverseZone_IPv6

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ipa_quick_uninstall
#   Usage: ipa_quick_uninstall
#
# This will uninstall IPA and related components.  It makes some key 
# assumptions about filenames for backups and yum repos.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ipa_quick_uninstall(){
	
	# Uninstall/unconfigure IPA
	if [ -f /usr/sbin/ipa-server-install ]; then
		rlRun "ipa-server-install --uninstall -U" 0
	fi
	if [ -f /usr/sbin/ipa-client-install ]; then
		rlRun "ipa-client-install --uninstall -U" 0,2
	fi

	if [ -d /var/lib/pki-ca ]; then
		rlLog "Looks like pki needs to be cleaned up..."
		rlRun "pkiremove -pki_instance_root=/var/lib -pki_instance_name=pki-ca --force"
		rlRun "yum -y reinstall pki-selinux"
	fi

	if [ -d /var/lib/ipa ]; then
		rlRun "/bin/rm -rf /var/lib/ipa/"
	fi
	if [ -d /var/lib/ipa-client ]; then
		rlRun "/bin/rm -rf /var/lib/ipa-client/"
	fi
	rlRun "ls /var/lib/sss/pubconf/kdcinfo.$RELM" 2 "Make sure that uninstall removed /var/lib/sss/pubconf/kdcinfo.$RELM. Bug BZ 829070"
	rlRun "ps -ef|grep -v grep|grep sssd" 1 "Make sure that sssd appears to be stopped as per BZ 830598"
	if [ -d /var/lib/sss/ ]; then
		rlRun "/bin/rm -rf /var/lib/sss/"
	fi
	if [ -d /var/log/dirsrv/ ]; then
		rlRun "/bin/rm -rf /usr/share/ipa"
	fi
	if [ -d /var/log/dirsrv/ ]; then
		rlRun "/bin/rm -rf /var/log/dirsrv/*"
	fi
	if [ -f /tmp/krb5cc_0 ]; then
		rlRun "/bin/rm -f /tmp/krb5cc_0"
	fi
	if [ -f /tmp/krb5cc_48 ]; then
		rlRun "/bin/rm -f /tmp/krb5cc_48"
	fi
	if [ -f /etc/ipa/ca.crt ]; then
		rlRun "/bin/rm -f /etc/ipa/ca.crt"
	fi
	if [ -f /etc/krb5.keytab ]; then
		rlRun "/bin/rm -f /etc/krb5.keytab"
	fi

	rlLog "pushd /etc/yum.repos.d"
	pushd /etc/yum.repos.d
	if [ ! -d /etc/yum.repos.d/deleted ]; then
		rlRun "mkdir deleted"
	fi	
	for repo in $(ls -1 *.repo|egrep -v "^beaker|^cobbler|^redhat.repo|^rhel-source.repo|^fedora"); do
		rlRun "/bin/mv -f $repo deleted/"
	done	
	rlLog "popd"
	popd

	rlRun "yum clean all"
	if [ -f /etc/hosts.ipabackup ]; then
		rlRun "/bin/cp -f /etc/hosts.ipabackup /etc/hosts"
	fi
	if [ -f /etc/hosts.ipabackup ]; then
		rlRun "/bin/rm -f /etc/hosts.ipabackup"
	fi
	if [ -f /etc/sysconfig/network-ipabackup ]; then
		rlRun "/bin/cp -f /etc/sysconfig/network-ipabackup /etc/sysconfig/network"
		rlRun "/bin/rm -f /etc/sysconfig/network-ipabackup"
	fi
	if [ -f /etc/resolv.conf.ipabackup ]; then
		rlRun "/bin/cp -f /etc/resolv.conf.ipabackup /etc/resolv.conf"
		rlRun "/bin/rm -f /etc/resolv.conf.ipabackup"
	fi
	. /etc/sysconfig/network
	rlRun "hostname $HOSTNAME"

	CERTCHK=$(certutil -L -d /etc/pki/nssdb 2>/dev/null |grep "IPA CA"|wc -l)
	if [ $CERTCHK -gt 0 ]; then
		rlLog "Found left over Certificate in NSS DB...removing"
		rlRun "certutil -D -d /etc/pki/nssdb -n 'IPA CA'"
	fi

    #rlRun "service certmonger stop"
    #if [ -d /var/lib/certmonger ]; then
    #    rlRun "rm -rf /var/lib/certmonger"
    #fi

} #ipa_quick_uninstall 

ipa_quick_remove()
{
    yum_opts="--rpmverbosity=debug"
    rlRun "yum -y remove 'ipa*' '389-ds-base*' bind krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl httpd httpd-tools"
    rlRun "yum -y remove sssd libipa_hbac krb5-server certmonger slapi-nis sssd-client 'pki*' 'tomcat6*' mod_nss"
    rlRun "yum -y remove memcached python-memcached"
    rlRun "yum -y remove libldb libsss_autofs"
    rlRun "yum -y downgrade krb5-devel krb5-libs bind-*"
    rlRun "yum -y downgrade curl nss* openldap* libselinux* nspr* libcurl*"
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# check_coredump
#   Usage: check_coredump
#
# This will check for any coredump messages in abrt output and try to 
# generate backtrace.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
check_coredump(){

	if [ ! -f /usr/bin/abrt-cli ]; then
		echo "abrt-cli not found...exiting $FUNCNAME"
		return 1
	fi

	/usr/bin/abrt-cli list | grep Directory |  awk '{print $2}'
	crashes=`/usr/bin/abrt-cli list | grep Directory |  awk '{print $2}' | wc -l`
	if [ $crashes -ne 0 ]; then
		echo "Crash detected."
		for dir in `/usr/bin/abrt-cli list | grep Directory |  awk '{print $2}'`; do
			cd $dir
			/usr/bin/abrt-action-install-debuginfo -v;
			/usr/bin/abrt-action-generate-backtrace -v;
			/usr/bin/rhts-submit-log -l backtrace
			/usr/bin/reporter-mailx -v
		done
	else
		echo "No crash detected."
	fi


} #check_coredump

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# submit_log
#   Usage: submit_log <logfilename>
#
# This will backup and submit a log file to beaker.  The backup file
# submitted is named $LOGFILE.$DATE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
submit_log(){
	if [ $# -ne 1 ]; then
		echo "Usage: $FUNCNAME <log filename>"
		return 1
	fi
	
	if [ ! -d /tmp/logbackups ]; then
		mkdir /tmp/logbackups
	fi
	local DATE=$(date +%Y%m%d-%H%M%S)
	local LOGFILE=$1
	#local LOGBACK=$(echo $LOGFILE|sed -e 's/\//,/g' -e "s/^/\/tmp\/logbackups\/$(hostname -s)/").$DATE
	local LOGBACK=$LOGFILE.$DATE
	if [ -f $LOGFILE ]; then
		rlLog "Backing up and submitting $LOGFILE"
		cp $LOGFILE $LOGBACK
		rhts-submit-log -l $LOGBACK
	else
		rlLog "Cannot file $LOGFILE"	
	fi
}	

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# submit_logs
#   Usage: submit_logs
#
# This will rhts-submit various/all IPA related log files to beaker for 
# debugging, troubleshooting, and/or record keeping
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
submit_logs(){
	INSTANCE=$(echo $RELM|sed 's/\./-/g')
	submit_log /var/log/ipaserver-install.log
	submit_log /var/log/ipareplica-install.log
	submit_log /var/log/ipaclient-install.log
	submit_log /var/log/ipaserver-uninstall.log
	submit_log /var/log/ipaclient-uninstall.log
	submit_log /var/log/ipaupgrade.log			
	submit_log /var/log/httpd/error_log
	submit_log /var/log/dirsrv/slapd-$INSTANCE/errors
	submit_log /var/log/dirsrv/slapd-PKI-IPA/errors
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Usage: rlDistroDiff <case_name>
#
# This can be used to exec as per detected distro.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
rlDistroDiff() {

        os_fedora() {
                case "$var" in

                clear_ccdir) # As part of clean-up, removing credential cache dirs
                        rlRun "rm -fvr `ls -d /run/user/* | grep -v root`";
                        ;;

                ipa_pkg_check)
                        rlAssertRpm freeipa-server
                        rlAssertRpm freeipa-admintools
                        rlAssertRpm freeipa-client
                        ;;

                keyctl)
                        rlRun "keyctl purge user"
                        ;;

 		dirsrv_svc_restart)
 			rlRun "systemctl restart dirsrv.target"
 			;;
                esac
                }

        os_rhel() {
                case "$var" in

                clear_ccdir) # As part of clean-up, removing credential cache dirs
                        rlRun "rm -fr /tmp/krb5cc_*_*";
                        ;;

                ipa_pkg_check)
                        rlAssertRpm ipa-server
                        rlAssertRpm ipa-admintools
                        rlAssertRpm ipa-client
                        ;;
                 dirsrv_svc_restart)
                         rlRun "service dirsrv restart"
                         ;;
                esac
                }


        cat /etc/redhat-release | grep "Fedora"
        if [ $? -eq 0 ] ; then
                FLAVOR="Fedora"
                var=$1
                os_fedora
        else
                FLAVOR="RedHat"
                var=$1
                os_rhel
        fi

}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# unindent function useful for here-strings (and/or here-docs)
# unindent > /path/to/file <<<"\
#     this will all be left 
#     justified when it's read in"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
function unindent()
{ 
    sed -e 's/^[[:space:]]*//'
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
