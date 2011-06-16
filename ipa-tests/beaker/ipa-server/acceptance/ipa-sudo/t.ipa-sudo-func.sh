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

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################

RELM=`echo $RELM | tr "[a-z]" "[A-Z]"`

########################################################################
user1="user1"
user2="user2"
userpw="Secret123"
bindpw="bind123"

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
BASE=`hostname -f | sed 's/\./,dc=/g' | cut -d "," -f 2,3,4,5,6,7,8,9,10`
DSINST=`hostname -f | sed 's/\./-/g' | cut -d "-" -f 2,3,4,5,6,7,8,9,10 | tr "[a-z]" "[A-Z]"`

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
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	
        # stopping firewall
        rlRun "service iptables stop"

        # enabling NIS
        rlRun "echo -n Secret123 > $TmpDir/passwd.txt"
        rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=707133"
        rlRun "ipa-nis-manage -y $TmpDir/passwd.txt enable"
        rlRun "ipactl restart"

cat > /etc/nss_ldap.conf << EOF
bind_policy soft
sudoers_base ou=SUDOers,$BASE
binddn uid=sudo,cn=sysaccounts,cn=etc,$BASE
bindpw $bindpw
ssl no

tls_cacertfile /etc/ipa/ca.crt
tls_checkpeer yes
bind_timelimit 5
timelimit 15
sudoers_debug 5
BASE cn=ng,cn=alt,$BASE
TLS_CACERTDIR /etc/ipa
uri ldap://$HOSTNAME
EOF

	rlRun "LDAPTLS_CACERT=/etc/ipa/ca.crt"
	rlRun "export LDAPTLS_CACERT"

cat > $TmpDir/bindchpwd.exp << EOF
#!/usr/bin/expect

set timeout 30
spawn /usr/bin/ldappasswd -S -W -h $HOSTNAME -ZZ -D "$ROOTDN" uid=sudo,cn=sysaccounts,cn=etc,$BASE
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

	rlFileBackup /var/log/dirsrv/slapd-$DSINST/errors
	rlRun "> /var/log/dirsrv/slapd-$DSINST/errors"

	rlRun "chmod 755 $TmpDir/bindchpwd.exp"
	rlRun "$TmpDir/bindchpwd.exp" 0 "Setting sudo binddn password"

	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=712109"
	rlAssertNotGrep "Entry \"uid=sudo,cn=sysaccounts,cn=etc,$BASE\" -- attribute \"krbExtraData\" not allowed" "/var/log/dirsrv/slapd-$DSINST/errors"
	rlFileRestore /var/log/dirsrv/slapd-$DSINST/errors

	rlAssertNotGrep "sudoers" "/etc/nsswitch.conf"
		if [ $? = 0 ]; then
			rlFileBackup /etc/nsswitch.conf
			rlRun "echo \"sudoers:    ldap\" >> /etc/nsswitch.conf"
		fi


rlPhaseEnd
}


bug711786() {

rlPhaseStartTest "Bug 711786: sudorunasgroup automatically picks up incorrect value while adding a sudorunasuser."

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ipa user-add shanks --first=shanks --last=r"
	rlRun "ipa sudorule-add rule1"
	rlRun "ipa sudorule-add-runasuser rule1 --users=shanks"
	rlRun "/usr/bin/ldapsearch -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b cn=rule1,ou=sudoers,$BASE > $TmpDir/bug711786.ldif"

	rlAssertNotGrep "sudorunasgroup: shanks r" "$TmpDir/bug711786.ldif"
	rlRun "cat $TmpDir/bug711786.ldif"

	rlRun "ipa sudorule-del rule1"
	rlRun "ipa user-del shanks"

rlPhaseEnd
}




#######################################################################################################################
############
############ 		NEGATIVE TESTS START HERE ...
############
#######################################################################################################################

bug710601() {


rlPhaseStartTest "Bug 710601: ipa sudorule-add accepts blank spaces as sudorule name."

	rlRun "ipa sudorule-add \" \" > $TmpDir/bug710601.txt 2>&1"
	rlAssertNotGrep "Added sudo rule \" \"" "$TmpDir/bug710601.txt"

	rlRun "cat $TmpDir/bug710601.txt"
	rlRun "ipa sudorule-del \" \""

rlPhaseEnd
}


bug710598() {

rlPhaseStartTest "Bug 710598: ipa sudocmdgroup-add accepts blank spaces as sudocmdgroup name."

	rlRun "ipa sudocmdgroup-add \" \" --desc=blankcmdgroup > $TmpDir/bug710598.txt 2>&1"
        rlAssertNotGrep "Added sudo command group \" \"" "$TmpDir/bug710598.txt"

	rlRun "cat $TmpDir/bug710598.txt"
	rlRun "ipa sudocmdgroup-del \" \""

rlPhaseEnd
}


bug710592() {

rlPhaseStartTest "Bug 710592: ipa sudocmd-add accepts blank spaces as sudo commands."

	rlRun "ipa sudocmd-add \" \" > $TmpDir/bug710592.txt 2>&1"
	rlAssertNotGrep "Added sudo command \" \"" "$TmpDir/bug710592.txt"

	rlRun "cat $TmpDir/bug710592.txt"
	rlRun "ipa sudocmd-del \" \""

rlPhaseEnd
}

bug710245() {

rlPhaseStartTest "Bug 710245: Removed option from Sudo rule message is displayed even when the given option doesn't exist."

	rlRun "ipa sudorule-add rule1"

	rlRun "ipa sudorule-remove-option rule1 --sudooption=invalid > $TmpDir/bug710245.txt 2>&1"
	rlAssertNotGrep "Removed option \"invalid\" from Sudo rule \"rule1\"" "$TmpDir/bug710245.txt"

	rlRun "cat $TmpDir/bug710245.txt"
	rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}

bug710240() {

rlPhaseStartTest "Bug 710240 - Added option to Sudo rule message is displayed even when the given option already exists."

	rlRun "ipa sudorule-add rule1"
	rlRun "ipa sudorule-add-option rule1 --sudooption=always_set_home"

	rlRun "ipa sudorule-add-option rule1 --sudooption=always_set_home > $TmpDir/bug710240.txt 2>&1"
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
        rlRun "kdestroy" 0 "Destroying admin credentials."

        # enabling NIS
        rlRun "echo -n Secret123 > $TmpDir/passwd.txt"
        rlRun "ipa-nis-manage -y $TmpDir/passwd.txt disable"
        rlRun "ipactl restart"

        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"

	rlRun "rm -f /etc/nss_ldap.conf"
	rlFileRestore /etc/nsswitch.conf
rlPhaseEnd
}

