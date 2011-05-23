#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-sudo
#   Description: sudo test cases
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#
# sudorule-add                   Create new Sudo Rule.
# sudorule-add-allow-command     Add commands and sudo command groups affected by Sudo Rule.
# sudorule-add-deny-command      Add commands and sudo command groups affected by Sudo Rule.
# sudorule-add-host              Add hosts and hostgroups affected by Sudo Rule.
# sudorule-add-option            Add an option to the Sudo rule.
# sudorule-add-runasgroup        Add group for Sudo to execute as.
# sudorule-add-runasuser         Add user for Sudo to execute as.
# sudorule-add-user              Add users and groups affected by Sudo Rule.
# sudorule-del                   Delete Sudo Rule.
# sudorule-disable               Disable a Sudo rule.
# sudorule-enable                Enable a Sudo rule.
# sudorule-find                  Search for Sudo Rule.
# sudorule-mod                   Modify Sudo Rule.
# sudorule-remove-allow-command  Remove commands and sudo command groups affected by Sudo Rule.
# sudorule-remove-deny-command   Remove commands and sudo command groups affected by Sudo Rule.
# sudorule-remove-host           Remove hosts and hostgroups affected by Sudo Rule.
# sudorule-remove-option         Remove an option from Sudo rule.
# sudorule-remove-runasgroup     Remove group for Sudo to execute as.
# sudorule-remove-runasuser      Remove user for Sudo to execute as.
# sudorule-remove-user           Remove users and groups affected by Sudo Rule.
# sudorule-show                  Dispaly Sudo Rule.
#
# sudocmdgroup-add            	 Create new sudo command group.
# sudocmdgroup-add-member     	 Add members to sudo command group.
# sudocmdgroup-del            	 Delete sudo command group.
# sudocmdgroup-find           	 Search for sudo command groups.
# sudocmdgroup-mod           	 Modify group.
# sudocmdgroup-remove-member  	 Remove members from sudo command group.
# sudocmdgroup-show           	 Display sudo command group.
#
# sudocmd-add   		 Create new sudo command.
# sudocmd-del   		 Delete sudo command.
# sudocmd-find  		 Search for commands.
# sudocmd-mod   		 Modify command.
# sudocmd-show  	    	 Display sudo command.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
#   Date: Mon May  9 20:56:29 IST 2011
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
mount_homedir="/ipahome"

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"

setup() {
rlPhaseStartTest "Setup for sudo configuration tests"

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
	rlRun "ipa-nis-manage -y $TmpDir/passwd.txt enable"
	rlRun "ipactl restart"

rlPhaseEnd
}

sudo_001() {

rlPhaseStartTest "sudo_001: ipa sudo help."

	rlRun "ipa help sudo > $TmpDir/sudo_001.txt 2>&1"
	rlAssertGrep "sudorule      Sudo (su \"do\") allows a system administrator to delegate authority to" "$TmpDir/sudo_001.txt"
	rlAssertGrep "sudocmdgroup  Groups of Sudo commands" "$TmpDir/sudo_001.txt"
	rlAssertGrep "sudocmd       Sudo Commands" "$TmpDir/sudo_001.txt"
	rlRun "cat $TmpDir/sudo_001.txt"

rlPhaseEnd
}

sudorule_001() {

rlPhaseStartTest "sudorule_001: ipa sudorule help."


	rlRun "ipa help sudorule > $TmpDir/sudorule_001.txt 2>&1"
	rlAssertGrep "sudorule-add                   Create new Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-add-allow-command     Add commands and sudo command groups affected by Sudo Rule" "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-add-deny-command      Add commands and sudo command groups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-add-host              Add hosts and hostgroups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-add-option            Add an option to the Sudo rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-add-runasgroup        Add group for Sudo to execute as." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-add-runasuser         Add user for Sudo to execute as." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-add-user              Add users and groups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-del                   Delete Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-disable               Disable a Sudo rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-enable                Enable a Sudo rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-find                  Search for Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-mod                   Modify Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-allow-command  Remove commands and sudo command groups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-deny-command   Remove commands and sudo command groups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-host           Remove hosts and hostgroups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-option         Remove an option from Sudo rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-runasgroup     Remove group for Sudo to execute as." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-runasuser      Remove user for Sudo to execute as." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-user           Remove users and groups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-show                  Dispaly Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "uid=sudo,cn=sysaccounts,cn=etc,dc=example,dc=com" "$TmpDir/sudorule_001.txt"
	rlAssertGrep "LDAPTLS_CACERT=/etc/ipa/ca.crt /usr/bin/ldappasswd -S -W -h ipa.example.com -ZZ -D \"cn=Directory Manager\" uid=sudo,cn=sysaccounts,cn=etc,dc=example,dc=com" "$TmpDir/sudorule_001.txt"
	rlRun "cat $TmpDir/sudo_002.txt"

rlPhaseEnd
}

sudorule_add_001() {

rlPhaseStartTest "sudorule_add_001: Add new sudo rule."

	BASE=`hostname -f | sed 's/\./,dc=/g' | cut -d "," -f 2,3,4,5,6,7,8,9,10`
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa sudorule-add testrule1 > $TmpDir/sudorule_add_001.txt 2>&1"
	rlAssertGrep "Added sudo rule \"testrule1\"" "$TmpDir/sudorule_add_001.txt"
	rlAssertGrep "Rule name: testrule1" "$TmpDir/sudorule_add_001.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule_add_001.txt"
	rlRun "cat $TmpDir/sudorule_add_001.txt"
	rlRun "/usr/bin/ldapsearch -x -h localhost -D \"cn=Directory Manager\" -w Secret123 -b cn=testrule1,ou=sudoers,$BASE > $TmpDir/sudorule_add_001.txt 2>&1"
	rlAssertGrep "dn: cn=testrule1,ou=sudoers,$BASE" "$TmpDir/sudorule_add_001.txt"
	rlAssertGrep "objectClass: sudoRole" "$TmpDir/sudorule_add_001.txt"
	rlAssertGrep "cn: testrule1" "$TmpDir/sudorule_add_001.txt"
	rlRun "cat $TmpDir/sudorule_add_001.txt"

rlPhaseEnd
}


sudorule_del_001() {

rlPhaseStartTest "sudorule_del_003: Del new sudo rule."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa sudorule-del testrule1"
	rlRun "/usr/bin/ldapsearch -x -h localhost -D \"cn=Directory Manager\" -w Secret123 -b cn=testrule1,ou=sudoers,$BASE" 32

rlPhaseEnd
}

cleanup() {
rlPhaseStartTest "Clean up for automount configuration tests"

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
rlPhaseEnd
}
