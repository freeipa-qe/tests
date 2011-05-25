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
BASE=`hostname -f | sed 's/\./,dc=/g' | cut -d "," -f 2,3,4,5,6,7,8,9,10`

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
	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=707133"
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


##################################################################################
############### ipa sudocmd command test cases ##################################
##################################################################################

sudocmd_001() {

rlPhaseStartTest "sudocmd_001: ipa sudocmd help."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa help sudocmd > $TmpDir/sudocmd_001.txt 2>&1"
	rlAssertGrep "sudocmd-add   Create new sudo command." "$TmpDir/sudocmd_001.txt"
	rlAssertGrep "sudocmd-del   Delete sudo command." "$TmpDir/sudocmd_001.txt"
	rlAssertGrep "sudocmd-find  Search for commands." "$TmpDir/sudocmd_001.txt"
	rlAssertGrep "sudocmd-mod   Modify command." "$TmpDir/sudocmd_001.txt"
	rlAssertGrep "sudocmd-show  Display sudo command." "$TmpDir/sudocmd_001.txt"
	rlRun "cat $TmpDir/sudocmd_001.txt"

rlPhaseEnd
}

sudocmd_002() {

rlPhaseStartTest "sudocmd_002: ipa help sudocmd-add"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa help sudocmd-add > $TmpDir/sudocmd_002.txt 2>&1 "
	rlAssertGrep "Purpose: Create new sudo command." "$TmpDir/sudocmd_002.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudocmd-add COMMAND \[options\]" "$TmpDir/sudocmd_002.txt"
	rlAssertGrep "\-h, \--help     show this help message and exit" "$TmpDir/sudocmd_002.txt"
	rlAssertGrep "\--desc=STR     A description of this command" "$TmpDir/sudocmd_002.txt"
	rlAssertGrep "\--addattr=STR  Add an attribute/value pair. Format is attr=value." "$TmpDir/sudocmd_002.txt"
	rlAssertGrep "\--setattr=STR  Set an attribute to a name/value pair. Format is attr=value." "$TmpDir/sudocmd_002.txt"
	rlAssertGrep "\--all          Retrieve and print all attributes from the server." "$TmpDir/sudocmd_002.txt"
	rlAssertGrep "\--raw          Print entries as stored on the server." "$TmpDir/sudocmd_002.txt"
	rlRun "cat $TmpDir/sudocmd_002.txt"

rlPhaseEnd
}

sudocmd_003() {

rlPhaseStartTest "sudocmd_003: ipa sudocmd-add commamd"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa sudocmd-add /bin/ls > $TmpDir/sudocmd_003.txt 2>&1"
	rlAssertGrep "Added sudo command \"/bin/ls\"" "$TmpDir/sudocmd_003.txt"
	rlAssertGrep "Sudo Command: /bin/ls" "$TmpDir/sudocmd_003.txt"
	rlRun "cat $TmpDir/sudocmd_003.txt"

rlPhaseEnd
}

sudocmd_004() {

rlPhaseStartTest "sudocmd_004: ipa sudocmd-mod command"

	rlRun "ipa sudocmd-mod /bin/ls --desc=\"listing files and folders\" > $TmpDir/sudocmd_004.txt 2>&1"
	rlAssertGrep "Modified sudo command \"/bin/ls\"" "$TmpDir/sudocmd_004.txt"
	rlAssertGrep "Sudo Command: /bin/ls" "$TmpDir/sudocmd_004.txt"
	rlAssertGrep "Description: listing files and folders" "$TmpDir/sudocmd_004.txt"

rlPhaseEnd
}

sudocmd_005() {

rlPhaseStartTest "sudocmd_005: ipa sudocmd-find command"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa sudocmd-find /bin/ls > $TmpDir/sudocmd_005.txt 2>&1"
	rlAssertGrep "1 sudo command matched" "$TmpDir/sudocmd_005.txt"
	rlAssertGrep "Sudo Command: /bin/ls" "$TmpDir/sudocmd_005.txt"
	rlAssertGrep "Number of entries returned 1" "$TmpDir/sudocmd_005.txt"
	rlAssertGrep "Description: listing files and folders" "$TmpDir/sudocmd_005.txt"
	rlRun "cat $TmpDir/sudocmd_005.txt"

rlPhaseEnd
}

sudocmd_006() {

rlPhaseStartTest "sudocmd_006: ipa sudocmd-find command --all"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa sudocmd-find /bin/ls --all > $TmpDir/sudocmd_006.txt 2>&1"
	rlAssertGrep "1 sudo command matched" "$TmpDir/sudocmd_006.txt"
	rlAssertGrep "dn: sudocmd=/bin/ls,cn=sudocmds,cn=sudo,$BASE" "$TmpDir/sudocmd_006.txt"
	rlAssertGrep "Description: listing files and folders" "$TmpDir/sudocmd_006.txt"
	rlAssertGrep "Sudo Command: /bin/ls" "$TmpDir/sudocmd_006.txt"
	rlAssertGrep "ipauniqueid: " "$TmpDir/sudocmd_006.txt"
	rlAssertGrep "objectclass: ipaobject, ipasudocmd" "$TmpDir/sudocmd_006.txt"
	rlRun "cat $TmpDir/sudocmd_006.txt"

rlPhaseEnd
}

sudocmd_007() {

rlPhaseStartTest "sudocmd_007: ipa sudocmd-find command --all --raw"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
        rlRun "ipa sudocmd-find /bin/ls --all --raw > $TmpDir/sudocmd_007.txt 2>&1"
	rlAssertGrep "dn: sudocmd=/bin/ls,cn=sudocmds,cn=sudo,$BASE" "$TmpDir/sudocmd_007.txt"
	rlAssertGrep "description: listing files and folders" "$TmpDir/sudocmd_007.txt"
	rlAssertGrep "sudocmd: /bin/ls" "$TmpDir/sudocmd_007.txt"
	rlAssertGrep "objectclass: ipaobject" "$TmpDir/sudocmd_007.txt"
	rlAssertGrep "objectclass: ipasudocmd" "$TmpDir/sudocmd_007.txt"
	rlAssertGrep "ipauniqueid:" "$TmpDir/sudocmd_007.txt"
	rlRun "cat $TmpDir/sudocmd_007.txt"

rlPhaseEnd
}


sudocmd_008() {

rlPhaseStartTest "sudocmd_008: ipa sudocmd-show command --rights --all"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa sudocmd-show /bin/ls --right --all > $TmpDir/sudocmd_008.txt 2>&1"
	rlAssertGrep "dn: sudocmd=/bin/ls,cn=sudocmds,cn=sudo,$BASE" "$TmpDir/sudocmd_008.txt"
	rlAssertGrep "Description: listing files and folders" "$TmpDir/sudocmd_008.txt"
	rlAssertGrep "Sudo Command: /bin/ls" "$TmpDir/sudocmd_008.txt"
	rlAssertGrep "attributelevelrights: {'description': u'rscwo', 'memberof': u'rsc', 'aci': u'rscwo', 'ipauniqueid': u'rsc', 'sudocmd': u'rscwo', 'nsaccountlock': u'rscwo'}" "$TmpDir/sudocmd_008.txt"
	rlAssertGrep "objectclass: ipaobject, ipasudocmd" "$TmpDir/sudocmd_008.txt"
	rlAssertGrep "ipauniqueid:" "$TmpDir/sudocmd_008.txt"
	rlAssertGrep "" "$TmpDir/sudocmd_008.txt"
	rlRun "cat $TmpDir/sudocmd_008.txt"

rlPhaseEnd
}

sudocmd_009() {

rlPhaseStartTest "sudocmd_009: ipa sudocmd-mod: add another command."

	rlRun "ipa sudocmd-mod /bin/ls --addattr=\"sudocmd=/bin/df\" > $TmpDir/sudocmd_009.txt 2>&1" 1
	rlAssertGrep "ipa: ERROR: sudocmd: Only one value allowed." "$TmpDir/sudocmd_009.txt"

rlPhaseEnd
}

sudocmd_010() {

rlPhaseStartTest "sudocmd_010: ipa sudocmd-del command"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa sudocmd-del /bin/ls > $TmpDir/sudocmd_010.txt 2>&1"
	rlAssertGrep "Deleted sudo command \"/bin/ls\"" "$TmpDir/sudocmd_010.txt"

rlPhaseEnd
}


##################################################################################
############### ipa sudocmdgroup command test cases ##############################
##################################################################################

sudocmdgroup_001() {

rlPhaseStartTest "sudocmdgroup_001: ipa help sudocmdgroup"

        rlRun "ipa help sudocmdgroup > $TmpDir/sudocmdgroup_001.txt 2>&1"
        rlAssertGrep "sudocmdgroup-add            Create new sudo command group." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-add-member     Add members to sudo command group." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-del            Delete sudo command group." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-find           Search for sudo command groups." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-mod            Modify group." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-remove-member  Remove members from sudo command group." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-show           Display sudo command group." "$TmpDir/sudocmdgroup_001.txt"

rlPhaseEnd
}


sudocmdgroup_002() {

rlPhaseStartTest "sudocmdgroup_002: ipa sudocmdgroup-add group"

	rlRun "ipa  sudocmdgroup-add sudogrp1 --desc=\"sudo group1\" > $TmpDir/sudocmdgroup_002.txt 2>&1"
	rlAssertGrep "Added sudo command group \"sudogrp1\"" "$TmpDir/sudocmdgroup_002.txt"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_002.txt"
	rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_002.txt"

rlPhaseEnd
}


sudocmdgroup_003() {

rlPhaseStartTest "sudocmdgroup_003: ipa sudocmdgroup-add-member --sudocmds=commands sudogrp"

	rlRun "ipa sudocmd-add /bin/ls"
	rlRun "ipa sudocmdgroup-add-member --sudocmds=/bin/ls sudogrp1 > $TmpDir/sudocmdgroup_003.txt 2>&1"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_003.txt"
	rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_003.txt"
	rlAssertGrep "Member Sudo commands: /bin/ls" "$TmpDir/sudocmdgroup_003.txt"
	rlAssertGrep "Number of members added 1" "$TmpDir/sudocmdgroup_003.txt"
	rlRun "cat $TmpDir/sudocmdgroup_003.txt"

rlPhaseEnd
}


sudocmdgroup_004() {

rlPhaseStartTest "sudocmdgroup_004: ipa sudocmdgroup-add-member --sudocmds=commands again to sudogrp"

	rlRun "ipa sudocmd-add /bin/df"
	rlRun "ipa sudocmdgroup-add-member --sudocmds=/bin/df sudogrp1 > $TmpDir/sudocmdgroup_004.txt 2>&1"
        rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_004.txt"
        rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_004.txt"
        rlAssertGrep "Member Sudo commands: /bin/ls, /bin/df" "$TmpDir/sudocmdgroup_004.txt"
        rlAssertGrep "Number of members added 1" "$TmpDir/sudocmdgroup_004.txt"
        rlRun "cat $TmpDir/sudocmdgroup_004.txt"

rlPhaseEnd
}


sudocmdgroup_005() {

rlPhaseStartTest "sudocmdgroup_005: ipa sudocmdgroup-remove-member --sudocmds=commands sudogrp"

	rlRun "ipa sudocmdgroup-remove-member --sudocmds=/bin/df sudogrp1 > $TmpDir/sudocmdgroup_005.txt 2>&1"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_005.txt"
	rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_005.txt"
	rlAssertGrep "Member Sudo commands: /bin/ls" "$TmpDir/sudocmdgroup_005.txt"
	rlAssertGrep "Number of members removed 1" "$TmpDir/sudocmdgroup_005.txt"
	rlRun "cat $TmpDir/sudocmdgroup_005.txt"

rlPhaseEnd
}


sudocmdgroup_006() {

rlPhaseStartTest "sudocmdgroup_006: ipa sudocmdgroup-remove-member --sudocmds=commands again from sudogrp"

	rlRun "ipa sudocmdgroup-remove-member --sudocmds=/bin/ls sudogrp1 > $TmpDir/sudocmdgroup_006.txt 2>&1"
        rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_006.txt"
        rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_006.txt"
        rlAssertGrep "Number of members removed 1" "$TmpDir/sudocmdgroup_005.txt"
        rlRun "cat $TmpDir/sudocmdgroup_006.txt"

rlPhaseEnd
}

sudocmdgroup_007() {

rlPhaseStartTest "sudocmdgroup_007: ipa sudocmdgroup-add-member --sudocmds=multiplecommands to sudogrp"

	rlRun "ipa sudocmdgroup-add-member --sudocmds=/bin/df,/bin/ls sudogrp1  > $TmpDir/sudocmdgroup_007.txt 2>&1"
        rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_007.txt"
        rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_007.txt"
        rlAssertGrep "Member Sudo commands: /bin/df, /bin/ls" "$TmpDir/sudocmdgroup_007.txt"
        rlAssertGrep "Number of members added 2" "$TmpDir/sudocmdgroup_007.txt"
        rlRun "cat $TmpDir/sudocmdgroup_007.txt"

rlPhaseEnd
}

sudocmdgroup_008() {

rlPhaseStartTest "sudocmdgroup_008: ipa sudocmdgroup-remove-member --sudocmds=multiplecommands from sudogrp"

	rlRun "ipa sudocmdgroup-remove-member --sudocmds=/bin/df,/bin/ls sudogrp1 > $TmpDir/sudocmdgroup_008.txt 2>&1"
        rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_008.txt"
        rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_008.txt"
        rlAssertGrep "Number of members removed 2" "$TmpDir/sudocmdgroup_008.txt"
	rlRun "cat $TmpDir/sudocmdgroup_008.txt"

rlPhaseEnd
}


sudocmdgroup_009() {

rlPhaseStartTest "sudocmdgroup_009: ipa sudocmdgroup-find"

	rlRun "ipa sudocmdgroup-add-member --sudocmds=/bin/df,/bin/ls sudogrp1"
	rlRun "ipa sudocmdgroup-find > $TmpDir/sudocmdgroup_009.txt 2>&1"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_009.txt"
	rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_009.txt"
	rlAssertGrep "Member Sudo commands: /bin/df, /bin/ls" "$TmpDir/sudocmdgroup_009.txt"
	rlAssertGrep "Number of entries returned 1" "$TmpDir/sudocmdgroup_009.txt"
	rlRun "cat $TmpDir/sudocmdgroup_009.txt"

rlPhaseEnd
}


sudocmdgroup_010() {

rlPhaseStartTest "sudocmdgroup_010: ipa sudocmdgroup-find sudogrp"

	rlRun "ipa sudocmdgroup-find sudogrp1 > $TmpDir/sudocmdgroup_010.txt 2>&1"
        rlAssertGrep "1 sudo command group matched" "$TmpDir/sudocmdgroup_010.txt"
	rlAssertGrep "Sudo Command Group: sudogrp" "$TmpDir/sudocmdgroup_010.txt"
        rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_010.txt"
        rlAssertGrep "Member Sudo commands: /bin/df, /bin/ls" "$TmpDir/sudocmdgroup_010.txt"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudocmdgroup_010.txt"
	rlRun "cat $TmpDir/sudocmdgroup_010.txt"

rlPhaseEnd
}

sudocmdgroup_011() {

rlPhaseStartTest "sudocmdgroup_011: ipa sudocmdgroup-show sudogrp1"

	rlRun "ipa sudocmdgroup-show sudogrp1  > $TmpDir/sudocmdgroup_011.txt 2>&1"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_011.txt"
	rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_011.txt"
	rlAssertGrep "Member Sudo commands: /bin/df, /bin/ls" "$TmpDir/sudocmdgroup_011.txt"
	rlRun "cat $TmpDir/sudocmdgroup_011.txt"

rlPhaseEnd
}


sudocmdgroup_012() {

rlPhaseStartTest "sudocmdgroup_012: ipa sudocmdgroup-find sudogrp --all --raw"

	rlRun "ipa sudocmdgroup-find sudogrp1 --raw --all > $TmpDir/sudocmdgroup_012.txt 2>&1"
	rlAssertGrep "dn: cn=sudogrp1,cn=sudocmdgroups,cn=sudo,$BASE" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "cn: sudogrp1" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "description: sudo group1" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "member: sudocmd=/bin/df,cn=sudocmds,cn=sudo,$BASE" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "member: sudocmd=/bin/ls,cn=sudocmds,cn=sudo,$BASE" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "ipauniqueid: " "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "objectclass: ipaobject" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "objectclass: ipasudocmdgrp" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "objectclass: groupOfNames" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "objectclass: top" "$TmpDir/sudocmdgroup_012.txt"
	rlRun "cat $TmpDir/sudocmdgroup_012.txt"

rlPhaseEnd
}


sudocmdgroup_013() {

rlPhaseStartTest "sudocmdgroup_013: ipa sudocmdgroup-mod sudogrp1 --addattr"

	rlRun "ipa sudocmdgroup-mod sudogrp1 --addattr member=sudocmd=/bin/vi,cn=sudocmds,cn=sudo,$BASE > $TmpDir/sudocmdgroup_013.txt"
	rlAssertGrep "Modified sudo command group \"sudogrp1\"" "$TmpDir/sudocmdgroup_013.txt"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_013.txt"
	rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_013.txt"
	rlAssertGrep "Member Sudo commands: /bin/df, /bin/ls, /bin/vi" "$TmpDir/sudocmdgroup_013.txt"
	rlRun "cat $TmpDir/sudocmdgroup_013.txt"

rlPhaseEnd
}


sudocmdgroup_014() {

rlPhaseStartTest "sudocmdgroup_014: ipa sudocmdgroup-mod sudogrp1 --setattr"

	rlRun "ipa sudocmdgroup-mod sudogrp1 --setattr member=sudocmd=/bin/dd,cn=sudocmds,cn=sudo,$BASE > $TmpDir/sudocmdgroup_014.txt"
	rlAssertGrep "Modified sudo command group \"sudogrp1\"" "$TmpDir/sudocmdgroup_014.txt"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_014.txt"
	rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_014.txt"
	rlAssertGrep "Member Sudo commands: /bin/dd" "$TmpDir/sudocmdgroup_014.txt"
	rlRun "cat $TmpDir/sudocmdgroup_014.txt"

rlPhaseEnd
}


sudocmdgroup_015() {

rlPhaseStartTest "sudocmdgroup_015: ipa sudocmdgroup-del sudogrp1"

	rlRun "ipa sudocmd-del /bin/ls"
	rlRun "ipa sudocmd-del /bin/df"
	rlRun "ipa sudocmdgroup-del sudogrp1 > $TmpDir/sudocmdgroup_015.txt"
	rlAssertGrep "Deleted sudo command group \"sudogrp1\"" "$TmpDir/sudocmdgroup_015.txt"
	rlRun "cat $TmpDir/sudocmdgroup_015.txt"

rlPhaseEnd
}


##################################################################################
############### ipa sudorule command test cases ##################################
##################################################################################

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
