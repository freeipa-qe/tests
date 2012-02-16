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
######################################################################
KINITEXEC=/usr/bin/kinit
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
                rlLog "Error message as expected: $actual"
		return 0
        else
                rlLog "ERROR: Message not as expected. GOT: $actual  EXP: $expmsg"
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
	TET_TMP_DIR=/dev/shm
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
		cat ~/.ssh/known_hosts | grep -v $1 > /dev/shm/known_hosts
		cat /dev/shm/known_hosts > ~/.ssh/known_hosts
		chmod 600 ~/.ssh/known_hosts
		chmod 777 $TET_TMP_DIR/setup-ssh-remote.exp
		expect $TET_TMP_DIR/setup-ssh-remote.exp &> /dev/shm/ssh-known-setup-update.txt
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
	local report=$1
# some modification here: make report work even the TmpDir removed
		if [ -n "$report" ];then
# this overwriting the existing report
#report=/tmp/rhts.report.$RANDOM.txt
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
					local pass=`rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]" | wc -l`
					local fail=`rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]" | wc -l`
					local abort=`rlJournalPrintText | grep "RESULT" | grep "\[  ABORT   \]" | wc -l`
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
	rm -f /dev/shm/ipa-resolv.conf-backup
	cat /etc/resolv.conf > /dev/shm/ipa-resolv.conf-backup
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


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
