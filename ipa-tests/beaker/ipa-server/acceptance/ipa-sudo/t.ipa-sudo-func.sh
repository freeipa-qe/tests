#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-sudo
#   Description: sudo functional test cases
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
#   Date: Thu Jun 16 12:48:21 IST 2011
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2010 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# The following have been tested:
#
# Functional:
#
# "Bug 711786: sudorunasgroup automatically picks up incorrect value while adding a sudorunasuser.
# sudorule-add-allow-command_func001: Allowed commands available from sudo client
# sudorule-add-allow-commandgrp_func001: Add command groups available for sudo client
# sudorule-remove-allow-command_func001: Remove commands available from sudo client
# sudorule-remove-allow-commandgrp_func001: Remove command groups available from sudo client
# sudorule-add-deny-command_func001: Deny commands available for sudo client
# sudorule-remove-deny-command_func001: Deny commands removed from sudo client
# sudorule-add-deny-commandgrp_func001: Deny command groups available for sudo client
# sudorule-remove-deny-commandgrp_func001: Remove denied command groups from sudo client
# sudorule-add-host_func001: Adding host and verifying from sudo client.
# sudorule-remove-host_func001: removing host and verifying from sudo client.
# sudorule-add-hostgrp_func001: Adding hostgroup and verifying from sudo client.
# sudorule-remove-hostgrp_func001: Removing hostgroup and verifying from sudo client.
# sudorule-add-option_func001: Adding sudo option /var/log/sudolog and verifying from sudo client.
# sudorule-add-option_func002: Adding sudo option env_keep and verifying from sudo client.
# sudorule-add-option_func003: Adding sudo option !authenticate and verifying from sudo client.
# sudorule-remove-option_func001: Removing sudo option /var/log/sudolog and verifying from sudo client.
# sudorule-remove-option_func002: Removing sudo option env_keep and verifying from sudo client.
# sudorule-remove-option_func003: Removing sudo option !authenticate and verifying from sudo client.
# sudorule-add-runasuser_func001: Adding RunAs user and verifying from sudo client.
# sudorule-remove-runasuser_func001: Removing RunAs user and verifying from sudo client.
# sudorule-add-runasuser_func002: Adding RunAs group and verifying from sudo client.
# sudorule-remove-runasuser_func002: Removing RunAs group and verifying from sudo client.
# sudorule-add-runasuser_func003: Adding comma-separated list of RunAs user and verifying from sudo client.
# sudorule-remove-runasuser_func003: Removing comma-separated list of RunAs user and verifying from sudo client.
# sudorule-add-runasuser_func004: Adding comma-separated list of RunAs group and verifying from sudo client.
# sudorule-remove-runasuser_func004: Removing comma-separated list of RunAs group and verifying from sudo client.
# Bug 719009: sudorule-add-runasuser does not match valid users when --users=ALL.
# sudorule-remove-runasuser_func005: Removing the special value ALL from runasusers and verifying from sudo client.
# sudorule-add-runasgroup_func001: Adding RunAs group and verifying from sudo client.
# sudorule-remove-runasgroup_func001: Removing RunAs group and verifying from sudo client.
# sudorule-disable_func001: Disabling sudorule and verifying from sudo client.
# sudorule-enable_func001: Enabling sudorule and verifying from sudo client.
# 
# Negative:
# Bug 710601: ipa sudorule-add accepts blank spaces as sudorule name.
# Bug 710598: ipa sudocmdgroup-add accepts blank spaces as sudocmdgroup name.
# Bug 710592: ipa sudocmd-add accepts blank spaces as sudo commands.
# Bug 710245: Removed option from Sudo rule message is displayed even when the given option doesn't exist.
# Bug 710240 - Added option to Sudo rule message is displayed even when the given option already exists.
# 


# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################

INSTANCE=`echo $RELM | sed 's/\./-/g'`

########################################################################
user1="user1"
user2="user2"
user3="user3"
userpw="Secret123"
bindpw="bind123"

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
basedn=`getBaseDN`

func_setup() {
rlPhaseStartTest "Setup for sudo functional tests"

        # check for packages
        for item in $PACKAGE1 $PACKAGE2 ; do
                rpm -qa | grep $item
                if [ $? -eq 0 ] ; then
                        rlPass "$item package is installed"
                else
                        rlFail "$item package NOT found!"
                fi
        done

        # kinit as admin and creating users
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
        rlRun "create_ipauser $user1 $user1 $user1 $userpw"
        sleep 5
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "create_ipauser $user2 $user2 $user2 $userpw"
	sleep 5
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "create_ipauser $user3 $user3 $user3 $userpw"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"

	# Add the machine with the hostname in $1 to the sshknown hosts file.
	AddToKnownHosts $MASTER	
        # stopping firewall
        rlRun "service iptables stop"

        # enabling NIS
#        rlRun "echo -n Secret123 > $TmpDir/passwd.txt"
#        rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=707133"
#        rlRun "ipa-nis-manage -y $TmpDir/passwd.txt enable"
#        rlRun "ipactl restart"

	# The following changes are because of changes in sudo package which now
	# searches for /etc/nslcd.conf for sudo maps. 
	# https://bugzilla.redhat.com/show_bug.cgi?id=709235

	if [ $distro_variant = Fedora ]; then
		rlLog "Distro variant detected is $distro_variant"
		rlRun "yum install nss_ldap -y"
	else
		rlLog "Distro variant detected is $distro_variant"
		rlRun "yum install nss-pam-ldapd -y"
	fi


SUDO_LDAP_CONF_PATH=`/usr/bin/sudo -V | grep 'ldap.conf path' | cut -d " " -f 3`

cat > $SUDO_LDAP_CONF_PATH << EOF
bind_policy soft
sudoers_base ou=SUDOers,$basedn
binddn uid=sudo,cn=sysaccounts,cn=etc,$basedn
bindpw $bindpw
ssl no

tls_cacertfile /etc/ipa/ca.crt
tls_checkpeer yes
bind_timelimit 5
timelimit 15
sudoers_debug 5
BASE cn=ng,cn=alt,$basedn
TLS_CACERTDIR /etc/ipa
uri ldap://$MASTER
EOF

	rlRun "cat $SUDO_LDAP_CONF_PATH"
	rlRun "LDAPTLS_CACERT=/etc/ipa/ca.crt"
	rlRun "export LDAPTLS_CACERT"

cat > $TmpDir/bindchpwd.exp << EOF
#!/usr/bin/expect

set timeout 30
spawn /usr/bin/ldappasswd -S -W -h $MASTER -ZZ -D "$ROOTDN" uid=sudo,cn=sysaccounts,cn=etc,$basedn
match_max 100000
expect "*: "
send -- "$bindpw\r"
expect "*: "
send -- "$bindpw\r"
expect "*: "
send -- "$ROOTDNPWD\r"
send -- "\r"
expect eof
EOF

	rlFileBackup /var/log/dirsrv/slapd-$INSTANCE/errors
	rlRun "> /var/log/dirsrv/slapd-$INSTANCE/errors"

	rlRun "chmod 755 $TmpDir/bindchpwd.exp"
	rlRun "$TmpDir/bindchpwd.exp" 0 "Setting sudo binddn password"

	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=712109"
	rlAssertNotGrep "Entry \"uid=sudo,cn=sysaccounts,cn=etc,$basedn\" -- attribute \"krbExtraData\" not allowed" "/var/log/dirsrv/slapd-$INSTANCE/errors"
	rlFileRestore /var/log/dirsrv/slapd-$INSTANCE/errors

	rlAssertNotGrep "sudoers" "/etc/nsswitch.conf"
		if [ $? = 0 ]; then
			rlFileBackup /etc/nsswitch.conf
			rlRun "echo \"sudoers:    ldap\" >> /etc/nsswitch.conf"
		fi

	rlRun "grep ^[^#] /etc/nsswitch.conf"

rlPhaseEnd
}


#######################################################################################################################
############
############ 		FUNCTIONAL TESTS START HERE ...
############
#######################################################################################################################


bug711786() {

rlPhaseStartTest "Bug 711786: sudorunasgroup automatically picks up incorrect value while adding a sudorunasuser."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ipa user-add shanks --first=shanks --last=r"
	rlRun "ipa sudorule-add rule1"
	rlRun "ipa sudorule-add-runasuser rule1 --users=shanks"
	rlRun "/usr/bin/ldapsearch -x -h $MASTER -D \"$ROOTDN\" -w $ROOTDNPWD -b cn=rule1,ou=sudoers,$basedn > $TmpDir/bug711786.ldif"

	rlAssertNotGrep "sudorunasgroup: shanks r" "$TmpDir/bug711786.ldif"
	rlRun "cat $TmpDir/bug711786.ldif"

	rlRun "ipa sudorule-del rule1"
	rlRun "ipa user-del shanks"

rlPhaseEnd
}

sudorule-add-allow-command_func001() {

rlPhaseStartTest "sudorule-add-allow-command_func001: Allowed commands available from sudo client"

#set up for fcuntional tests
sudorun_withusr() {
cat > $TmpDir/sudo_list.exp << EOF
#!/usr/bin/expect -f

set timeout 30
set send_slow {1 .1}
match_max 100000
spawn ssh -o StrictHostKeyChecking=no -l $1 $MASTER
expect "*: "
send -s "$userpw\r"
expect "*$ "
send -s "sudo -l \r"
expect "$1: "
send -s "$userpw\r"
expect "*$ "
send -s "sudo -u user2 /bin/date > $sudoout 2>&1 \r"
expect "$1: "
send -s "$userpw\r"
expect eof
EOF

chmod 755 $TmpDir/sudo_list.exp
cat $TmpDir/sudo_list.exp
$TmpDir/sudo_list.exp
cat $sudoout
}

sudo_list() {

sudoout=/tmp/sudo_list.out

cat > $TmpDir/sudo_list.exp << EOF
#!/usr/bin/expect -f

set timeout 30
set send_slow {1 .1}
match_max 100000

spawn ssh -o StrictHostKeyChecking=no -l $1 $MASTER
expect "*: "
send -s "$userpw\r"
expect "*$ "
send -s "sudo -l > $sudoout 2>&1 \r"
expect "$1: "
send -s "$userpw\r"
expect eof
EOF

chmod 755 $TmpDir/sudo_list.exp
cat $TmpDir/sudo_list.exp
$TmpDir/sudo_list.exp
cat $sudoout
}


sudo_list_wo_passwd() {

sudoout=/tmp/sudo_list.out

cat > $TmpDir/sudo_list.exp << EOF
#!/usr/bin/expect -f

set timeout 30
set send_slow {1 .1}
match_max 100000

spawn ssh -o StrictHostKeyChecking=no -l $1 $MASTER
expect "*: "
send -s "$userpw\r"
expect "*$ "
send -s "sudo -l > $sudoout 2>&1 \r"
expect eof
EOF

chmod 755 $TmpDir/sudo_list.exp
cat $TmpDir/sudo_list.exp
$TmpDir/sudo_list.exp
cat $sudoout
}



        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	rlRun "authconfig --enablemkhomedir --updateall"
	rlRun "ipa sudocmd-add /bin/mkdir"
	rlRun "ipa sudocmd-add /bin/date"
	rlRun "ipa sudocmd-add /bin/df"
	rlRun "ipa sudocmd-add /bin/touch"
	rlRun "ipa sudocmd-add /bin/rm"
	rlRun "ipa sudocmd-add /bin/uname"
	rlRun "ipa sudocmd-add /bin/hostname"
	rlRun "ipa sudocmd-add /bin/rmdir"
	rlRun "ipa sudocmdgroup-add sudogrp1 --desc=sudogrp1"
	rlRun "ipa sudocmdgroup-add-member sudogrp1 --sudocmds=/bin/date,/bin/touch,/bin/uname"
	rlRun "ipa sudorule-add sudorule1"
	rlRun "ipa sudorule-add-host  sudorule1 --hosts=$MASTER"
	rlRun "ipa sudorule-add-user sudorule1 --users=user1"

	rlRun "ipa sudorule-add-allow-command --sudocmds=/bin/mkdir sudorule1"
        rlRun "sudo_list user1"
	rlAssertGrep "sudo: user_matches=1" "$sudoout"
	rlAssertGrep "sudo: host_matches=1" "$sudoout"
	rlAssertGrep "sudo: ldap sudoHost '$MASTER' ... MATCH" "$sudoout"
	rlAssertGrep "User user1 may run the following commands on this host:" "$sudoout"
	rlAssertGrep "(root) /bin/mkdir" "$sudoout"
	rlRun "cat $sudoout"

	rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-add-allow-commandgrp_func001() {

rlPhaseStartTest "sudorule-add-allow-commandgrp_func001: Add command groups available for sudo client"

	rlRun "ipa sudorule-add-allow-command --sudocmdgroups=sudogrp1 sudorule1"
        rlRun "sudo_list user1"
	rlAssertGrep "sudo: user_matches=1" "$sudoout"
	rlAssertGrep "sudo: host_matches=1" "$sudoout"
	rlAssertGrep "sudo: ldap sudoHost '$MASTER' ... MATCH" "$sudoout"
	rlAssertGrep "User user1 may run the following commands on this host:" "$sudoout"
	rlAssertGrep "(root) /bin/mkdir" "$sudoout"
	rlRun "cat $sudoout"

	rlRun "rm -fr $sudoout"

rlPhaseEnd
}


sudorule-remove-allow-command_func001() {

rlPhaseStartTest "sudorule-remove-allow-command_func001: Remove commands available from sudo client"

	rlRun "ipa sudorule-remove-allow-command --sudocmds=/bin/mkdir sudorule1"
        rlRun "sudo_list user1"
	rlAssertGrep "sudo: user_matches=1" "$sudoout"
	rlAssertGrep "sudo: host_matches=1" "$sudoout"
	rlAssertGrep "sudo: ldap sudoHost '$MASTER' ... MATCH" "$sudoout"
	rlAssertNotGrep "/bin/mkdir" "$sudoout"
	rlRun "cat $sudoout"

	rlRun "rm -fr $sudoout"

rlPhaseEnd
}


sudorule-remove-allow-commandgrp_func001() {

rlPhaseStartTest "sudorule-remove-allow-commandgrp_func001: Remove command groups available from sudo client"

	rlRun "ipa sudorule-remove-allow-command --sudocmdgroups=sudogrp1 sudorule1"
        rlRun "sudo_list user1"
	rlAssertGrep "sudo: user_matches=1" "$sudoout"
	rlAssertGrep "sudo: host_matches=1" "$sudoout"
	rlAssertGrep "sudo: ldap sudoHost '$MASTER' ... MATCH" "$sudoout"
	rlAssertNotGrep "/bin/mkdir" "$sudoout"
	rlRun "cat $sudoout"

	rlRun "rm -fr $sudoout"

rlPhaseEnd
}


sudorule-add-deny-command_func001() {

rlPhaseStartTest "sudorule-add-deny-command_func001: Deny commands available for sudo client"

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	rlRun "ipa sudorule-add-deny-command --sudocmds=/bin/mkdir sudorule1"
        rlRun "sudo_list user1"
	rlAssertGrep "sudo: user_matches=1" "$sudoout"
	rlAssertGrep "sudo: host_matches=1" "$sudoout"
	rlAssertGrep "sudo: ldap sudoHost '$MASTER' ... MATCH" "$sudoout"
	rlAssertGrep "User user1 may run the following commands on this host:" "$sudoout"
	rlAssertGrep "(root) !/bin/mkdir" "$sudoout"
	rlRun "cat $sudoout"

	rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-remove-deny-command_func001() {

rlPhaseStartTest "sudorule-remove-deny-command_func001: Deny commands removed from sudo client"

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-remove-deny-command --sudocmds=/bin/mkdir sudorule1"
        rlRun "sudo_list user1"
        rlAssertGrep "sudo: user_matches=1" "$sudoout"
        rlAssertGrep "sudo: host_matches=1" "$sudoout"
        rlAssertGrep "sudo: ldap sudoHost '$MASTER' ... MATCH" "$sudoout"
        rlAssertNotGrep "(root) !/bin/mkdir" "$sudoout"
        rlRun "cat $sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-add-deny-commandgrp_func001() {

rlPhaseStartTest "sudorule-add-deny-commandgrp_func001: Deny command groups available for sudo client"

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	rlRun "ipa sudorule-add-deny-command --sudocmdgroups=sudogrp1 sudorule1"
        rlRun "sudo_list user1"
	rlAssertGrep "sudo: user_matches=1" "$sudoout"
	rlAssertGrep "sudo: host_matches=1" "$sudoout"
	rlAssertGrep "sudo: ldap sudoHost '$MASTER' ... MATCH" "$sudoout"
	rlAssertGrep "User user1 may run the following commands on this host:" "$sudoout"
	rlAssertGrep "(root) !/bin/date, !/bin/touch, !/bin/uname" "$sudoout"
	rlRun "cat $sudoout"

	rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-remove-deny-commandgrp_func001() {

rlPhaseStartTest "sudorule-remove-deny-commandgrp_func001: Remove denied command groups from sudo client"

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	rlRun "ipa sudorule-remove-deny-command --sudocmdgroups=sudogrp1 sudorule1"
        rlRun "sudo_list user1"
	rlAssertGrep "sudo: user_matches=1" "$sudoout"
	rlAssertGrep "sudo: host_matches=1" "$sudoout"
	rlAssertGrep "sudo: ldap sudoHost '$MASTER' ... MATCH" "$sudoout"
	rlAssertNotGrep "(root) !/bin/mkdir" "$sudoout"
	rlRun "cat $sudoout"

	rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-add-host_func001() {

rlPhaseStartTest "sudorule-add-host_func001: Adding host and verifying from sudo client."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	rlRun "ipa sudorule-add-host sudorule1 --hosts=test.example.com"
	rlRun "sudo_list user1"
	rlAssertGrep "sudo: ldap sudoHost 'test.example.com' ... not" "$sudoout"
	rlRun "cat $sudoout"

	rlRun "rm -fr $sudoout"

rlPhaseEnd
}


sudorule-remove-host_func001() {

rlPhaseStartTest "sudorule-remove-host_func001: removing host and verifying from sudo client."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	rlRun "ipa sudorule-remove-host sudorule1 --hosts=test.example.com"
	rlRun "sudo_list user1"
	rlAssertNotGrep "sudo: ldap sudoHost 'test.example.com' ... not" "$sudoout"
	rlRun "cat $sudoout"

	rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-add-hostgrp_func001() {

rlPhaseStartTest "sudorule-add-hostgrp_func001: Adding hostgroup and verifying from sudo client."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	domain=`hostname -d`
	rlRun "domainname $domain"
	rlRun "rm -fr /var/lib/sss/db/cache_*"
	rlRun "service sssd restart"
	sleep 5

	rlRun "ipa hostgroup-add hostgrp1 --desc=test_hostgrp"
	rlRun "ipa sudorule-remove-host sudorule1 --hosts=$MASTER"
	rlRun "ipa hostgroup-add-member hostgrp1 --hosts=$MASTER"

	rlRun "ipa sudorule-add-host sudorule1 --hostgroup=hostgrp1"
	sleep 5
	# Commenting the following test as it is generating false failures and 
	# the related functional test "grep for +hostgrp1" passess. 
	# rlRun "getent netgroup hostgrp1"

	rlRun "sudo_list user1"
	rlAssertGrep "sudo: ldap sudoHost '+hostgrp1' ... MATCH" "$sudoout"
	
	rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-remove-hostgrp_func001() {

rlPhaseStartTest "sudorule-remove-hostgrp_func001: Removing hostgroup and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ipa sudorule-remove-host sudorule1 --hostgroup=hostgrp1"
        rlRun "ipa hostgroup-del hostgrp1"

	rlRun "rm -fr /var/lib/sss/db/cache_*"
        rlRun "service sssd restart"
	sleep 5
	rlRun "getent -s sss passwd user1"

        rlRun "sudo_list user1"
        rlAssertNotGrep "sudo: ldap sudoHost '+hostgrp1' ... MATCH" "$sudoout"
        
	rlRun "ipa sudorule-add-host sudorule1 --hosts=$MASTER"
        rlRun "rm -fr $sudoout"

rlPhaseEnd
}



sudorule-add-option_func001() {

rlPhaseStartTest "sudorule-add-option_func001: Adding sudo option /var/log/sudolog and verifying from sudo client."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-add-option sudorule1 --sudooption=logfile=/var/log/sudolog"
	rlRun "sudo_list user1"
	rlAssertGrep "sudo: ldap sudoOption: 'logfile=/var/log/sudolog'" "$sudoout"
	rlRun "cat $sudoout"

	rlRun "rm -fr $sudoout"

rlPhaseEnd
}


sudorule-add-option_func002() {

rlPhaseStartTest "sudorule-add-option_func002: Adding sudo option env_keep and verifying from sudo client."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-add-option sudorule1 --sudooption=\"env_keep = LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE\""
        rlRun "sudo_list user1"
        rlAssertGrep "sudo: ldap sudoOption: 'env_keep = LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE'" "$sudoout"
        rlRun "cat $sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}


sudorule-add-option_func003() {

rlPhaseStartTest "sudorule-add-option_func003: Adding sudo option !authenticate and verifying from sudo client."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-add-option sudorule1 --sudooption='!authenticate'"
        rlRun "sudo_list_wo_passwd user1"
        rlAssertGrep "sudo: ldap sudoOption: '!authenticate'" "$sudoout"
        rlRun "cat $sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-remove-option_func001() {

rlPhaseStartTest "sudorule-remove-option_func001: Removing sudo option /var/log/sudolog and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-remove-option sudorule1 --sudooption=logfile=/var/log/sudolog"
        rlRun "sudo_list user1"
        rlAssertNotGrep "sudo: ldap sudoOption: 'logfile=/var/log/sudolog'" "$sudoout"
        rlRun "cat $sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}


sudorule-remove-option_func002() {

rlPhaseStartTest "sudorule-remove-option_func002: Removing sudo option env_keep and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-remove-option sudorule1 --sudooption=\"env_keep = LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE\""
        rlRun "sudo_list user1"
        rlAssertNotGrep "sudo: ldap sudoOption: 'env_keep = LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE'" "$sudoout"
        rlRun "cat $sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-remove-option_func003() {

rlPhaseStartTest "sudorule-remove-option_func003: Removing sudo option !authenticate and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-remove-option sudorule1 --sudooption='!authenticate'"
        rlRun "sudo_list_wo_passwd user1"
        rlAssertNotGrep "sudo: ldap sudoOption: '!authenticate'" "$sudoout"
        rlRun "cat $sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-add-runasuser_func001() {

rlPhaseStartTest "sudorule-add-runasuser_func001: Adding RunAs user and verifying from sudo client."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa sudorule-add-allow-command --sudocmdgroups=sudogrp1 sudorule1"

        rlRun "ipa sudorule-add-runasuser sudorule1 --users=$user2"
	rlRun "sudo_list user1"
	rlAssertGrep "(user2) /bin/date, /bin/touch, /bin/uname" "$sudoout"

	rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-remove-runasuser_func001() {

rlPhaseStartTest "sudorule-remove-runasuser_func001: Removing RunAs user and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-remove-runasuser sudorule1 --users=$user2"
        rlRun "sudo_list user1"
        rlAssertNotGrep "(user2) /bin/date, /bin/touch, /bin/uname" "$sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-add-runasuser_func002() {

rlPhaseStartTest "sudorule-add-runasuser_func002: Adding RunAs group and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-add-runasuser sudorule1 --groups=$user2"
        rlRun "sudo_list user1"
        rlAssertGrep "(%user2) /bin/date, /bin/touch, /bin/uname" "$sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-remove-runasuser_func002() {

rlPhaseStartTest "sudorule-remove-runasuser_func002: Removing RunAs group and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-remove-runasuser sudorule1 --groups=$user2"
        rlRun "sudo_list user1"
        rlAssertNotGrep "(%user2) /bin/date, /bin/touch, /bin/uname" "$sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-add-runasuser_func003() {

rlPhaseStartTest "sudorule-add-runasuser_func003: Adding comma-separated list of RunAs user and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-add-runasuser sudorule1 --users=$user2,$user3"
        rlRun "sudo_list user1"
        rlAssertGrep "(user2, user3) /bin/date, /bin/touch, /bin/uname" "$sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-remove-runasuser_func003() {

rlPhaseStartTest "sudorule-remove-runasuser_func003: Removing comma-separated list of RunAs user and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-remove-runasuser sudorule1 --users=$user2,$user3"
        rlRun "sudo_list user1"
        rlAssertNotGrep "(user2, user3) /bin/date, /bin/touch, /bin/uname" "$sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-add-runasuser_func004() {

rlPhaseStartTest "sudorule-add-runasuser_func004: Adding comma-separated list of RunAs group and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-add-runasuser sudorule1 --groups=$user2,$user3"
        rlRun "sudo_list user1"
        rlAssertGrep "(%user2, %user3) /bin/date, /bin/touch, /bin/uname" "$sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-remove-runasuser_func004() {

rlPhaseStartTest "sudorule-remove-runasuser_func004: Removing comma-separated list of RunAs group and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-remove-runasuser sudorule1 --groups=$user2,$user3"
        rlRun "sudo_list user1"
        rlAssertNotGrep "(%user2, %user3) /bin/date, /bin/touch, /bin/uname" "$sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}


sudorule-add-runasuser_func005() {

rlPhaseStartTest "Bug 719009: sudorule-add-runasuser does not match valid users when --users=ALL. "

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

# Commenting the next line since we are covering the cli in verifyErrorMsg which follows immediately.
#	rlRun "ipa sudorule-add-runasuser sudorule1 --users=ALL"
	verifyErrorMsg "ipa sudorule-add-runasuser sudorule1 --users=ALL" "ipa: ERROR: invalid 'runas-user': RunAsUser does not accept 'ALL' as a user name"

# The following comments are result of https://bugzilla.redhat.com/show_bug.cgi?id=782976
#        rlRun "sudorun_withusr user1"
#        rlAssertGrep "sudo: ldap sudoRunAsUser 'all' ... MATCH" "$sudoout"
#        rlAssertNotGrep "is not allowed to execute" "$sudoout"

#        rlRun "rm -fr $sudoout"
#	 rlRun "cat $sudoout"

        rlRun "ipa sudorule-remove-runasuser sudorule1 --users=ALL" 1

rlPhaseEnd
}
                                                                                                                                           
sudorule-remove-runasuser_func005() {

rlPhaseStartTest "sudorule-remove-runasuser_func005: Removing the special value ALL from runasusers and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa sudorule-add-runasuser sudorule1 --users=ALL"

        rlRun "ipa sudorule-remove-runasuser sudorule1 --users=ALL"

        rlRun "sudorun_withusr user1"
        rlAssertNotGrep "sudo: ldap sudoRunAsUser 'all' ... MATCH" "$sudoout"
        rlAssertGrep "sudo: host_matches=1" "$sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}


sudorule-add-runasgroup_func001() {

rlPhaseStartTest "sudorule-add-runasgroup_func001: Adding RunAs group and verifying from sudo client."

# The following comments are result of https://bugzilla.redhat.com/show_bug.cgi?id=782976

	rlLog "Bug 719009: sudorule-add-runasuser does not match valid users when --users=ALL."
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
#        rlRun "ipa sudorule-add-runasgroup sudorule1 --groups=ALL"

        verifyErrorMsg "ipa sudorule-add-runasgroup sudorule1 --groups=ALL" "ipa: ERROR: invalid 'runas-group': RunAsGroup does not accept 'ALL' as a group name"

#sudorun_withgrp() {
#cat > $TmpDir/sudo_list.exp << EOF
##!/usr/bin/expect -f
#
#set timeout 30
#set send_slow {1 .1}
#match_max 100000
#
#spawn ssh -o StrictHostKeyChecking=no -l $1 $MASTER
#expect "*: "
#send -s "$userpw\r"
#expect "*$ "
#send -s "sudo -l \r"
#expect "$1: "
#send -s "$userpw\r"
#expect "*$ "
#send -s "sudo -u root -g $1 /bin/date > $sudoout 2>&1 \r"
#expect "$1: "
#send -s "$userpw\r"
#expect eof
#EOF
#
#chmod 755 $TmpDir/sudo_list.exp
#cat $TmpDir/sudo_list.exp
#$TmpDir/sudo_list.exp
#cat $sudoout
#}
#
#	rlRun "sudorun_withgrp user1"
#        rlAssertGrep "sudo: ldap sudoRunAsGroup 'all' ... MATCH" "$sudoout"
#	rlAssertNotGrep "is not allowed to execute" "$sudoout"
#
#        rlRun "rm -fr $sudoout"
#	rlRun "cat $sudoout"
#        rlRun "ipa sudorule-remove-runasgroup sudorule1 --groups=ALL"

rlPhaseEnd
}

sudorule-remove-runasgroup_func001() {

rlPhaseStartTest "sudorule-remove-runasgroup_func001: Removing RunAs group and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ipa sudorule-add-runasgroup sudorule1 --groups=ALL"

        rlRun "ipa sudorule-remove-runasgroup sudorule1 --groups=ALL"
        rlRun "sudo_list user1"
        rlAssertNotGrep "sudo: ldap sudoRunAsGroup 'all'" "$sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}


sudorule-disable_func001() {

rlPhaseStartTest "sudorule-disable_func001: Disabling sudorule and verifying from sudo client."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	rlRun "rm -fr /var/lib/sss/db/cache_*"
        rlRun "service sssd restart"
	sleep 5

	rlRun "ipa sudorule-find"
	rlRun "ipa sudorule-show sudorule1"
        rlRun "ipa sudorule-disable sudorule1"
        rlRun "sudo_list user1"
        rlAssertGrep "user1 is not in the sudoers file.  This incident will be reported." "$sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}

sudorule-enable_func001() {

rlPhaseStartTest "sudorule-enable_func001: Enabling sudorule and verifying from sudo client."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudorule-enable sudorule1"
        rlRun "sudo_list user1"
        rlAssertGrep "(root) /bin/date, /bin/touch, /bin/uname" "$sudoout"

        rlRun "rm -fr $sudoout"

rlPhaseEnd
}




cleanup-func() {

rlPhaseStartTest "sudo func cleanup"
#clean up for functional tests
	rlRun "ipa sudocmd-del /bin/mkdir"
	rlRun "ipa sudocmd-del /bin/date"
	rlRun "ipa sudocmd-del /bin/df"
	rlRun "ipa sudocmd-del /bin/touch"
	rlRun "ipa sudocmd-del /bin/rm"
	rlRun "ipa sudocmd-del /bin/uname"
	rlRun "ipa sudocmd-del /bin/hostname"
        rlRun "ipa sudocmd-del  /bin/rmdir"
        rlRun "ipa sudocmdgroup-del  sudogrp1"
	rlRun "ipa sudorule-del sudorule1"

rm -fr /var/lib/sss/db/cache_lab.eng.pnq.redhat.com.ldb 
rm -fr /tmp/krb5cc_1*
rm -fr /tmp/sudo_list.out 
service sssd restart


rlPhaseEnd
}
 


#######################################################################################################################
############
############ 		NEGATIVE TESTS START HERE ...
############
#######################################################################################################################




bug710601() {


rlPhaseStartTest "Bug 710601: ipa sudorule-add accepts blank spaces as sudorule name."

	rlRun "ipa sudorule-add \" \" > $TmpDir/bug710601.txt 2>&1" 1
	rlAssertNotGrep "Added sudo rule \" \"" "$TmpDir/bug710601.txt"

	rlRun "cat $TmpDir/bug710601.txt"
	rlRun "ipa sudorule-del \" \"" 2

rlPhaseEnd
}


bug710598() {

rlPhaseStartTest "Bug 710598: ipa sudocmdgroup-add accepts blank spaces as sudocmdgroup name."

	rlRun "ipa sudocmdgroup-add \" \" --desc=blankcmdgroup > $TmpDir/bug710598.txt 2>&1" 1
        rlAssertNotGrep "Added sudo command group \" \"" "$TmpDir/bug710598.txt"

	rlRun "cat $TmpDir/bug710598.txt"
	rlRun "ipa sudocmdgroup-del \" \"" 2

rlPhaseEnd
}


bug710592() {

rlPhaseStartTest "Bug 710592: ipa sudocmd-add accepts blank spaces as sudo commands."

	rlRun "ipa sudocmd-add \" \" > $TmpDir/bug710592.txt 2>&1" 1
	rlAssertNotGrep "Added sudo command \" \"" "$TmpDir/bug710592.txt"

	rlRun "cat $TmpDir/bug710592.txt"
	rlRun "ipa sudocmd-del \" \"" 2

rlPhaseEnd
}

bug710245() {

rlPhaseStartTest "Bug 710245: Removed option from Sudo rule message is displayed even when the given option doesn't exist."

	rlRun "ipa sudorule-add rule1"

	rlRun "ipa sudorule-remove-option rule1 --sudooption=invalid > $TmpDir/bug710245.txt 2>&1" 1
	rlAssertNotGrep "Removed option \"invalid\" from Sudo rule \"rule1\"" "$TmpDir/bug710245.txt"

	rlRun "cat $TmpDir/bug710245.txt"
	rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}

bug710240() {

rlPhaseStartTest "Bug 710240 - Added option to Sudo rule message is displayed even when the given option already exists."

	rlRun "ipa sudorule-add rule1"
	rlRun "ipa sudorule-add-option rule1 --sudooption=always_set_home"

	rlRun "ipa sudorule-add-option rule1 --sudooption=always_set_home > $TmpDir/bug710240.txt 2>&1" 1
	rlAssertNotGrep "Added option \"always_set_home\" to Sudo rule \"rule1\"" "$TmpDir/bug710240.txt"

	rlRun "cat $TmpDir/bug710240.txt"
	rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}


func_cleanup() {
rlPhaseStartTest "Clean up for sudo functional tests"

        rlRun "kinitAs $ADMINID $ADMINPW" 0
        rlRun "ipa user-del $user1"
        sleep 5
        rlRun "ipa user-del $user2"
	sleep 5
	rlRun "ipa user-del $user3"
        rlRun "kdestroy" 0 "Destroying admin credentials."

        # disabling NIS
        rlRun "echo -n Secret123 > $TmpDir/passwd.txt"
        rlRun "ipa-nis-manage -y $TmpDir/passwd.txt disable"
        rlRun "ipactl restart"

        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"

	rlRun "rm -f /etc/nss_ldap.conf"
	rlFileRestore /etc/nsswitch.conf
rlPhaseEnd
}

