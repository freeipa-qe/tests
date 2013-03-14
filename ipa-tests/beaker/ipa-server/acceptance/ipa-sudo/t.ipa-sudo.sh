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
# sudorule-add-option            Add an option to the Sudo Rule.
# sudorule-add-runasgroup        Add group for Sudo to execute as.
# sudorule-add-runasuser         Add user for Sudo to execute as.
# sudorule-add-user              Add users and groups affected by Sudo Rule.
# sudorule-del                   Delete Sudo Rule.
# sudorule-disable               Disable a Sudo Rule.
# sudorule-enable                Enable a Sudo Rule.
# sudorule-find                  Search for Sudo Rule.
# sudorule-mod                   Modify Sudo Rule.
# sudorule-remove-allow-command  Remove commands and sudo command groups affected by Sudo Rule.
# sudorule-remove-deny-command   Remove commands and sudo command groups affected by Sudo Rule.
# sudorule-remove-host           Remove hosts and hostgroups affected by Sudo Rule.
# sudorule-remove-option         Remove an option from Sudo Rule.
# sudorule-remove-runasgroup     Remove group for Sudo to execute as.
# sudorule-remove-runasuser      Remove user for Sudo to execute as.
# sudorule-remove-user           Remove users and groups affected by Sudo Rule.
# sudorule-show                  Display Sudo Rule.
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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

########################################################################
# Test Suite Globals
########################################################################

RELM=`echo $RELM | tr "[a-z]" "[A-Z]"`

########################################################################
user1="user1"
user2="user2"
userpw="Secret123"

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
basedn=`getBaseDN`

setup() {
rlPhaseStartTest "Setup for sudo sanity tests"

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
	#rlRun "echo -n Secret123 > $TmpDir/passwd.txt"
	#rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=707133"
	#rlRun "ipa-nis-manage -y $TmpDir/passwd.txt enable"
	#rlRun "ipactl restart"

rlPhaseEnd
}

sudo_001() {

rlPhaseStartTest "sudo_001: ipa sudo help."
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"

	rlRun "ipa help sudo > $TmpDir/sudo_001.txt 2>&1"
	rlAssertGrep "sudorule      Sudo Rules" "$TmpDir/sudo_001.txt"
	rlAssertGrep "sudocmdgroup  Groups of Sudo Commands" "$TmpDir/sudo_001.txt"
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
	rlAssertGrep "sudocmd-add   Create new Sudo Command." "$TmpDir/sudocmd_001.txt"
	rlAssertGrep "sudocmd-del   Delete Sudo Command." "$TmpDir/sudocmd_001.txt"
	rlAssertGrep "sudocmd-find  Search for Sudo Commands." "$TmpDir/sudocmd_001.txt"
	rlAssertGrep "sudocmd-mod   Modify Sudo Command." "$TmpDir/sudocmd_001.txt"
	rlAssertGrep "sudocmd-show  Display Sudo Command." "$TmpDir/sudocmd_001.txt"
	rlRun "cat $TmpDir/sudocmd_001.txt"

rlPhaseEnd
}

sudocmd_002() {

rlPhaseStartTest "sudocmd_002: ipa help sudocmd-add"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa help sudocmd-add > $TmpDir/sudocmd_002.txt 2>&1 "
	rlAssertGrep "Purpose: Create new Sudo Command." "$TmpDir/sudocmd_002.txt"
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
	rlAssertGrep "Added Sudo Command \"/bin/ls\"" "$TmpDir/sudocmd_003.txt"
	rlAssertGrep "Sudo Command: /bin/ls" "$TmpDir/sudocmd_003.txt"
	rlRun "cat $TmpDir/sudocmd_003.txt"

rlPhaseEnd
}

sudocmd_004() {

rlPhaseStartTest "sudocmd_004: ipa sudocmd-mod command"

	rlRun "ipa sudocmd-mod /bin/ls --desc=\"listing files and folders\" > $TmpDir/sudocmd_004.txt 2>&1"
	rlAssertGrep "Modified Sudo Command \"/bin/ls\"" "$TmpDir/sudocmd_004.txt"
	rlAssertGrep "Sudo Command: /bin/ls" "$TmpDir/sudocmd_004.txt"
	rlAssertGrep "Description: listing files and folders" "$TmpDir/sudocmd_004.txt"
	rlRun "cat $TmpDir/sudocmd_004.txt"

rlPhaseEnd
}

sudocmd_005() {

rlPhaseStartTest "sudocmd_005: ipa sudocmd-find command"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa sudocmd-find /bin/ls > $TmpDir/sudocmd_005.txt 2>&1"
	rlAssertGrep "1 Sudo Command matched" "$TmpDir/sudocmd_005.txt"
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
	rlAssertGrep "1 Sudo Command matched" "$TmpDir/sudocmd_006.txt"
	rlAssertGrep "dn: sudocmd=/bin/ls,cn=sudocmds,cn=sudo,$basedn" "$TmpDir/sudocmd_006.txt"
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
	rlAssertGrep "dn: sudocmd=/bin/ls,cn=sudocmds,cn=sudo,$basedn" "$TmpDir/sudocmd_007.txt"
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
	rlAssertGrep "dn: sudocmd=/bin/ls,cn=sudocmds,cn=sudo,$basedn" "$TmpDir/sudocmd_008.txt"
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
	rlAssertGrep "Deleted Sudo Command \"/bin/ls\"" "$TmpDir/sudocmd_010.txt"
	rlRun "cat $TmpDir/sudocmd_010.txt"

rlPhaseEnd
}


##################################################################################
############### ipa sudocmdgroup command test cases ##############################
##################################################################################

sudocmdgroup_001() {

rlPhaseStartTest "sudocmdgroup_001: ipa help sudocmdgroup"

        rlRun "ipa help sudocmdgroup > $TmpDir/sudocmdgroup_001.txt 2>&1"
        rlAssertGrep "sudocmdgroup-add            Create new Sudo Command Group." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-add-member     Add members to Sudo Command Group." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-del            Delete Sudo Command Group." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-find           Search for Sudo Command Groups." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-mod            Modify Sudo Command Group." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-remove-member  Remove members from Sudo Command Group." "$TmpDir/sudocmdgroup_001.txt"
        rlAssertGrep "sudocmdgroup-show           Display Sudo Command Group." "$TmpDir/sudocmdgroup_001.txt"
	rlRun "cat $TmpDir/sudocmdgroup_001.txt"

rlPhaseEnd
}


sudocmdgroup_002() {

rlPhaseStartTest "sudocmdgroup_002: ipa sudocmdgroup-add group"

	rlRun "ipa sudocmdgroup-add sudogrp1 --desc=\"sudo group1\" > $TmpDir/sudocmdgroup_002.txt 2>&1"
	rlAssertGrep "Added Sudo Command Group \"sudogrp1\"" "$TmpDir/sudocmdgroup_002.txt"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_002.txt"
	rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_002.txt"
	rlRun "cat $TmpDir/sudocmdgroup_002.txt"

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
        rlAssertGrep "1 Sudo Command Group matched" "$TmpDir/sudocmdgroup_010.txt"
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
	rlAssertGrep "dn: cn=sudogrp1,cn=sudocmdgroups,cn=sudo,$basedn" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "cn: sudogrp1" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "description: sudo group1" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "member: sudocmd=/bin/df,cn=sudocmds,cn=sudo,$basedn" "$TmpDir/sudocmdgroup_012.txt"
	rlAssertGrep "member: sudocmd=/bin/ls,cn=sudocmds,cn=sudo,$basedn" "$TmpDir/sudocmdgroup_012.txt"
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

	rlRun "ipa sudocmdgroup-mod sudogrp1 --addattr member=sudocmd=/bin/vi,cn=sudocmds,cn=sudo,$basedn > $TmpDir/sudocmdgroup_013.txt"
	rlAssertGrep "Modified Sudo Command Group \"sudogrp1\"" "$TmpDir/sudocmdgroup_013.txt"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/sudocmdgroup_013.txt"
	rlAssertGrep "Description: sudo group1" "$TmpDir/sudocmdgroup_013.txt"
	rlAssertGrep "Member Sudo commands: /bin/df, /bin/ls, /bin/vi" "$TmpDir/sudocmdgroup_013.txt"
	rlRun "cat $TmpDir/sudocmdgroup_013.txt"

rlPhaseEnd
}


sudocmdgroup_014() {

rlPhaseStartTest "sudocmdgroup_014: ipa sudocmdgroup-mod sudogrp1 --setattr"

	rlRun "ipa sudocmdgroup-mod sudogrp1 --setattr member=sudocmd=/bin/dd,cn=sudocmds,cn=sudo,$basedn > $TmpDir/sudocmdgroup_014.txt"
	rlAssertGrep "Modified Sudo Command Group \"sudogrp1\"" "$TmpDir/sudocmdgroup_014.txt"
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
	rlAssertGrep "Deleted Sudo Command Group \"sudogrp1\"" "$TmpDir/sudocmdgroup_015.txt"
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
	rlAssertGrep "sudorule-add-option            Add an option to the Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-add-runasgroup        Add group for Sudo to execute as." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-add-runasuser         Add users and groups for Sudo to execute as." "$TmpDir/sudorule_001.txt"
	rlLog "Covers test https://bugzilla.redhat.com/show_bug.cgi?id=711705"
	rlAssertGrep "sudorule-add-user              Add users and groups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-del                   Delete Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-disable               Disable a Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-enable                Enable a Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-find                  Search for Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-mod                   Modify Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-allow-command  Remove commands and sudo command groups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-deny-command   Remove commands and sudo command groups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-host           Remove hosts and hostgroups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-option         Remove an option from Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-runasgroup     Remove group for Sudo to execute as." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-runasuser      Remove users and groups for Sudo to execute as." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-remove-user           Remove users and groups affected by Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "sudorule-show                  Display Sudo Rule." "$TmpDir/sudorule_001.txt"
	rlAssertGrep "uid=sudo,cn=sysaccounts,cn=etc,dc=example,dc=com" "$TmpDir/sudorule_001.txt"
	rlAssertGrep "LDAPTLS_CACERT=/etc/ipa/ca.crt /usr/bin/ldappasswd -S -W -h ipa.example.com -ZZ -D \"cn=Directory Manager\" uid=sudo,cn=sysaccounts,cn=etc,dc=example,dc=com" "$TmpDir/sudorule_001.txt"
	rlRun "cat $TmpDir/sudorule_001.txt"

rlPhaseEnd
}

sudorule_add_000() {

rlPhaseStartTest "sudorule_add_000: ipa help sudorule-add."

	rlRun "ipa help sudorule-add > $TmpDir/sudorule_add_000.txt 2>&1"
	rlAssertGrep "Purpose: Create new Sudo Rule." "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-add SUDORULE-NAME \[options\]" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\-h, \--help            show this help message and exit" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--desc=STR            Description" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--usercat=\['all'\]     User category the rule applies to" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--hostcat=\['all'\]     Host category the rule applies to" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--cmdcat=\['all'\]      Command category the rule applies to" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--runasusercat=\['all'\]" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "RunAs User category the rule applies to" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--runasgroupcat=\['all'\]" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "RunAs Group category the rule applies to" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--externaluser=STR    External User the rule applies to (sudorule-find only)" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--runasexternaluser=STR" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "External User the commands can run as (sudorule-find" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--runasexternalgroup=STR" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "External Group the commands can run as (sudorule-find" "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--addattr=STR         Add an attribute/value pair. Format is attr=value." "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--setattr=STR         Set an attribute to a name/value pair." "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--all                 Retrieve and print all attributes from the server." "$TmpDir/sudorule_add_000.txt"
	rlAssertGrep "\--raw                 Print entries as stored on the server." "$TmpDir/sudorule_add_000.txt"

	rlRun "cat $TmpDir/sudorule_add_000.txt"

rlPhaseEnd
}

sudorule_add_001() {

rlPhaseStartTest "sudorule_add_001: Add new sudo rule."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa sudorule-add sudorule1 > $TmpDir/sudorule_add_001.txt 2>&1"
	rlAssertGrep "Added Sudo Rule \"sudorule1\"" "$TmpDir/sudorule_add_001.txt"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule_add_001.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule_add_001.txt"
	rlRun "cat $TmpDir/sudorule_add_001.txt"
	rlRun "/usr/bin/ldapsearch -x -h localhost -D \"cn=Directory Manager\" -w Secret123 -b cn=sudorule1,ou=sudoers,$basedn > $TmpDir/sudorule_add_001.txt 2>&1"
	rlAssertGrep "dn: cn=sudorule1,ou=sudoers,$basedn" "$TmpDir/sudorule_add_001.txt"
	rlAssertGrep "objectClass: sudoRole" "$TmpDir/sudorule_add_001.txt"
	rlAssertGrep "cn: sudorule1" "$TmpDir/sudorule_add_001.txt"
	rlRun "cat $TmpDir/sudorule_add_001.txt"
	rlRun "ipa sudorule-del sudorule1"

rlPhaseEnd
}


sudorule_add_002() {


rlPhaseStartTest "sudorule_add_002: ipa sudorule-add  sudorule"

	rlRun "ipa sudorule-add  sudorule1 > $TmpDir/sudorule_add_002.txt 2>&1"
	rlAssertGrep "Added Sudo Rule \"sudorule1\"" "$TmpDir/sudorule_add_002.txt"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule_add_002.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule_add_002.txt"
	rlRun "cat $TmpDir/sudorule_add_002.txt"
	rlRun "ipa sudorule-del sudorule1"

rlPhaseEnd
}

sudorule_add_003() {

rlPhaseStartTest "sudorule_add_003: ipa  sudorule-add --desc=desc sudorule"

	rlRun "ipa sudorule-add --desc=\"sudo rule 1\" sudorule1 > $TmpDir/sudorule_add_003.txt 2>&1"
        rlAssertGrep "Added Sudo Rule \"sudorule1\"" "$TmpDir/sudorule_add_003.txt"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule_add_003.txt"
        rlAssertGrep "Description: sudo rule 1" "$TmpDir/sudorule_add_003.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule_add_003.txt"
	rlRun "cat $TmpDir/sudorule_add_003.txt"
	rlRun "ipa sudorule-del sudorule1"

rlPhaseEnd
}

sudorule_add_004() {

rlPhaseStartTest "sudorule_add_004: ipa sudorule-add sudorule1 --desc=desc --usercat"

	rlRun "ipa sudorule-add sudorule1 --desc=\"sudo rule 1\" --usercat=all > $TmpDir/sudorule_add_004.txt 2>&1"
	rlAssertGrep "Added Sudo Rule \"sudorule1\"" "$TmpDir/sudorule_add_004.txt"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule_add_004.txt"
	rlAssertGrep "Description: sudo rule 1" "$TmpDir/sudorule_add_004.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule_add_004.txt"
	rlAssertGrep "User category: all" "$TmpDir/sudorule_add_004.txt"
	rlRun "cat $TmpDir/sudorule_add_004.txt"
	rlRun "ipa sudorule-del sudorule1"

rlPhaseEnd
}

sudorule_add_005() {

rlPhaseStartTest "sudorule_add_005: ipa sudorule-add sudorule1 --desc=desc --usercat --hostcat"

	rlRun "ipa sudorule-add sudorule1 --desc=\"sudo rule 1\" --usercat=all --hostcat=all > $TmpDir/sudorule_add_005.txt 2>&1"
        rlAssertGrep "Added Sudo Rule \"sudorule1\"" "$TmpDir/sudorule_add_005.txt"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule_add_005.txt"
        rlAssertGrep "Description: sudo rule 1" "$TmpDir/sudorule_add_005.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule_add_005.txt"
        rlAssertGrep "User category: all" "$TmpDir/sudorule_add_005.txt"
        rlAssertGrep "Host category: all" "$TmpDir/sudorule_add_005.txt"
	rlRun "cat $TmpDir/sudorule_add_005.txt"
        rlRun "ipa sudorule-del sudorule1"

rlPhaseEnd
}


sudorule_add_006() {

rlPhaseStartTest "sudorule_add_006: ipa sudorule-add sudorule1 --desc=desc --usercat --hostcat --cmdcat"

	rlRun "ipa sudorule-add sudorule1 --desc=\"sudo rule 1\" --usercat=all --hostcat=all --cmdcat=all > $TmpDir/sudorule_add_006.txt 2>&1"
        rlAssertGrep "Added Sudo Rule \"sudorule1\"" "$TmpDir/sudorule_add_006.txt"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule_add_006.txt"
        rlAssertGrep "Description: sudo rule 1" "$TmpDir/sudorule_add_006.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule_add_006.txt"
        rlAssertGrep "User category: all" "$TmpDir/sudorule_add_006.txt"
        rlAssertGrep "Host category: all" "$TmpDir/sudorule_add_006.txt"
        rlAssertGrep "Command category: all" "$TmpDir/sudorule_add_006.txt"
	rlRun "cat $TmpDir/sudorule_add_006.txt"
        rlRun "ipa sudorule-del sudorule1"

rlPhaseEnd
}

sudorule_add_007() {

rlPhaseStartTest "sudorule_add_007: ipa sudorule-add sudorule1 --desc=desc --usercat --hostcat --cmdcat --runasusercat"

        rlRun "ipa sudorule-add sudorule1 --desc=\"sudo rule 1\" --usercat=all --hostcat=all --cmdcat=all --runasusercat=all > $TmpDir/sudorule_add_007.txt 2>&1"
        rlAssertGrep "Added Sudo Rule \"sudorule1\"" "$TmpDir/sudorule_add_007.txt"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule_add_007.txt"
        rlAssertGrep "Description: sudo rule 1" "$TmpDir/sudorule_add_007.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule_add_007.txt"
        rlAssertGrep "User category: all" "$TmpDir/sudorule_add_007.txt"
        rlAssertGrep "Host category: all" "$TmpDir/sudorule_add_007.txt"
        rlAssertGrep "Command category: all" "$TmpDir/sudorule_add_007.txt"
        rlAssertGrep "RunAs User category: all" "$TmpDir/sudorule_add_007.txt"
        rlRun "cat $TmpDir/sudorule_add_007.txt"
        rlRun "ipa sudorule-del sudorule1"

rlPhaseEnd
}

sudorule_add_008() {

# The following comments are because of https://fedorahosted.org/freeipa/ticket/1320
# In short: --externaluser option is depricated.

rlPhaseStartTest "sudorule_add_008: ipa sudorule-add sudorule1 --desc=desc --usercat --hostcat --cmdcat --runasusercat --externaluser"

        rlRun "ipa sudorule-add sudorule1 --desc=\"sudo rule 1\" --usercat=all --hostcat=all --cmdcat=all --runasusercat=all --externaluser=all > $TmpDir/sudorule_add_008.txt 2>&1" 1
#        rlAssertGrep "Added sudo rule \"sudorule1\"" "$TmpDir/sudorule_add_008.txt"
#        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule_add_008.txt"
#        rlAssertGrep "Description: sudo rule 1" "$TmpDir/sudorule_add_008.txt"
#        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule_add_008.txt"
#        rlAssertGrep "User category: all" "$TmpDir/sudorule_add_008.txt"
#        rlAssertGrep "Host category: all" "$TmpDir/sudorule_add_008.txt"
#        rlAssertGrep "Command category: all" "$TmpDir/sudorule_add_008.txt"
#        rlAssertGrep "RunAs User category: all" "$TmpDir/sudorule_add_008.txt"
#        rlAssertGrep "External User: all" "$TmpDir/sudorule_add_008.txt"

	rlAssertGrep "ipa: ERROR: invalid 'externaluser': this option has been deprecated." "$TmpDir/sudorule_add_008.txt"

        rlRun "cat $TmpDir/sudorule_add_008.txt"
        rlRun "ipa sudorule-del sudorule1" 2

rlPhaseEnd
}

sudorule_add_009() {

# The following comments are because of https://fedorahosted.org/freeipa/ticket/1320
# In short: --externaluser option is depricated.

rlPhaseStartTest "sudorule_add_009: ipa sudorule-add sudorule1 --desc=desc --usercat --hostcat --cmdcat --runasusercat --externaluser --all --raw"

	rlRun "ipa sudorule-add sudorule1 --desc=\"sudo rule 1\" --usercat=all --hostcat=all --cmdcat=all --runasusercat=all --externaluser=all --all --raw > $TmpDir/sudorule_add_009.txt 2>&1" 1
#        rlAssertGrep "Added sudo rule \"sudorule1\"" "$TmpDir/sudorule_add_009.txt"
#        rlAssertGrep "dn: ipauniqueid=" "$TmpDir/sudorule_add_009.txt"
#        rlAssertGrep "cn: sudorule1" "$TmpDir/sudorule_add_009.txt"
#        rlAssertGrep "description: sudo rule 1" "$TmpDir/sudorule_add_009.txt"
#        rlAssertGrep "ipaenabledflag: TRUE" "$TmpDir/sudorule_add_009.txt"
#        rlAssertGrep "usercategory: all" "$TmpDir/sudorule_add_009.txt"
#        rlAssertGrep "hostcategory: all" "$TmpDir/sudorule_add_009.txt"
#        rlAssertGrep "cmdcategory: all" "$TmpDir/sudorule_add_009.txt"
#        rlAssertGrep "ipasudorunasusercategory: all" "$TmpDir/sudorule_add_009.txt"
#        rlAssertGrep "externaluser: all" "$TmpDir/sudorule_add_009.txt"
#        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/sudorule_add_009.txt"
#        rlAssertGrep "objectclass: ipasudorule" "$TmpDir/sudorule_add_009.txt"

        rlAssertGrep "ipa: ERROR: invalid 'externaluser': this option has been deprecated." "$TmpDir/sudorule_add_009.txt"

        rlRun "cat $TmpDir/sudorule_add_009.txt"
	rlRun "ipa sudorule-del sudorule1" 2

rlPhaseEnd
}


sudorule-add-allow-command_001() {

rlPhaseStartTest "sudorule-add-allow-command_001: ipa sudorule-add-allow-command sudorule1 --sudocmds --sudocmdgroups"

	# Adding sudo commands for further tests.
	rlRun "ipa sudocmd-add /bin/ls"
	rlRun "ipa sudocmd-add /bin/df"
	rlRun "ipa sudocmdgroup-add sudogrp1 --desc=\"group 1\""
	rlRun "ipa sudocmdgroup-add sudogrp2 --desc=\"group 2\""
	rlRun "ipa sudorule-add sudorule1 --desc=\"sudo rule 1\""

	rlRun "ipa sudorule-add-allow-command sudorule1 --sudocmds=/bin/ls --sudocmdgroups=sudogrp1 > $TmpDir/sudorule-add-allow-command_001.txt 2>&1"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-add-allow-command_001.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-add-allow-command_001.txt"
	rlAssertGrep "Sudo Allow Commands: /bin/ls" "$TmpDir/sudorule-add-allow-command_001.txt"
	rlAssertGrep "Sudo Allow Command Groups: sudogrp1" "$TmpDir/sudorule-add-allow-command_001.txt"
	rlAssertGrep "Number of members added 2" "$TmpDir/sudorule-add-allow-command_001.txt"
	rlRun "cat $TmpDir/sudorule-add-allow-command_001.txt"

rlPhaseEnd
}

sudorule-remove-allow-command_001() {

rlPhaseStartTest "sudorule-remove-allow-command_001: ipa sudorule-remove-allow-command sudorule1 --sudocmds --sudocmdgroups"

        rlRun "ipa sudorule-remove-allow-command sudorule1 --sudocmds=/bin/ls --sudocmdgroups=sudogrp1 > $TmpDir/sudorule-remove-allow-command_001.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-remove-allow-command_001.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-remove-allow-command_001.txt"
        rlAssertGrep "Number of members removed 2" "$TmpDir/sudorule-remove-allow-command_001.txt"
        rlRun "cat $TmpDir/sudorule-remove-allow-command_001.txt"

rlPhaseEnd
}


sudorule-add-allow-command_002() {

rlPhaseStartTest "sudorule-add-allow-command_002: ipa sudorule-add-allow-command sudorule1 --sudocmds=multiple-commands --sudocmdgroups=multiple-groups"

	rlRun "ipa sudorule-add-allow-command sudorule1 --sudocmds=/bin/ls,/bin/df --sudocmdgroups=sudogrp1,sudogrp2 > $TmpDir/sudorule-add-allow-command_002.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-add-allow-command_002.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-add-allow-command_002.txt"
        rlAssertGrep "Sudo Allow Commands: /bin/ls, /bin/df" "$TmpDir/sudorule-add-allow-command_002.txt"
	rlAssertGrep "Sudo Allow Command Groups: sudogrp1, sudogrp2" "$TmpDir/sudorule-add-allow-command_002.txt"
        rlAssertGrep "Number of members added 4" "$TmpDir/sudorule-add-allow-command_002.txt"
        rlRun "cat $TmpDir/sudorule-add-allow-command_002.txt"

rlPhaseEnd
}


sudorule-remove-allow-command_002() {

rlPhaseStartTest "sudorule-remove-allow-command_002: ipa sudorule-remove-allow-command sudorule1 --sudocmds=multiple-commands --sudocmdgroups=multiple-groups"

        rlRun "ipa sudorule-remove-allow-command sudorule1 --sudocmds=/bin/ls,/bin/df --sudocmdgroups=sudogrp1,sudogrp2 > $TmpDir/sudorule-remove-allow-command_002.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-remove-allow-command_002.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-remove-allow-command_002.txt"
        rlAssertGrep "Number of members removed 4" "$TmpDir/sudorule-remove-allow-command_002.txt"
        rlRun "cat $TmpDir/sudorule-remove-allow-command_002.txt"

	rlRun "ipa sudorule-del sudorule1"
	rlRun "ipa sudocmd-del /bin/ls"
	rlRun "ipa sudocmd-del /bin/df"
	rlRun "ipa sudocmdgroup-del sudogrp1"
	rlRun "ipa sudocmdgroup-del sudogrp2"
rlPhaseEnd
}


sudorule-add-allow-command_003() {

rlPhaseStartTest "sudorule-add-allow-command_003: ipa help sudorule-add-allow-command"

	rlRun "ipa help sudorule-add-allow-command > $TmpDir/sudorule-add-allow-command_003.txt 2>&1"
	rlAssertGrep "Purpose: Add commands and sudo command groups affected by Sudo Rule." "$TmpDir/sudorule-add-allow-command_003.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-add-allow-command SUDORULE-NAME \[options\]" "$TmpDir/sudorule-add-allow-command_003.txt"
	rlAssertGrep "\-h, \--help           show this help message and exit" "$TmpDir/sudorule-add-allow-command_003.txt"
	rlAssertGrep "\--all                Retrieve and print all attributes from the server." "$TmpDir/sudorule-add-allow-command_003.txt"
	rlAssertGrep "\--raw                Print entries as stored on the server." "$TmpDir/sudorule-add-allow-command_003.txt"
	rlAssertGrep "\--sudocmds=STR       comma-separated list of sudo commands to add" "$TmpDir/sudorule-add-allow-command_003.txt"
	rlAssertGrep "\--sudocmdgroups=STR  comma-separated list of sudo command groups to add" "$TmpDir/sudorule-add-allow-command_003.txt"
	rlRun "cat $TmpDir/sudorule-add-allow-command_003.txt"

rlPhaseEnd
}

sudorule-remove-allow-command_003() {

rlPhaseStartTest "sudorule-remove-allow-command_003: ipa help sudorule-remove-allow-command"

        rlRun "ipa help sudorule-remove-allow-command > $TmpDir/sudorule-remove-allow-command_003.txt 2>&1"
        rlAssertGrep "Purpose: Remove commands and sudo command groups affected by Sudo Rule." "$TmpDir/sudorule-remove-allow-command_003.txt"
        rlAssertGrep "Usage: ipa \[global-options\] sudorule-remove-allow-command SUDORULE-NAME \[options\]" "$TmpDir/sudorule-remove-allow-command_003.txt"
	rlAssertGrep "\-h, \--help           show this help message and exit" "$TmpDir/sudorule-remove-allow-command_003.txt"
        rlAssertGrep "\--all                Retrieve and print all attributes from the server." "$TmpDir/sudorule-remove-allow-command_003.txt"
        rlAssertGrep "\--raw                Print entries as stored on the server." "$TmpDir/sudorule-remove-allow-command_003.txt"
        rlAssertGrep "\--sudocmds=STR       comma-separated list of sudo commands to remove" "$TmpDir/sudorule-remove-allow-command_003.txt"
        rlAssertGrep "\--sudocmdgroups=STR  comma-separated list of sudo command groups to remove" "$TmpDir/sudorule-remove-allow-command_003.txt"

        rlRun "cat $TmpDir/sudorule-remove-allow-command_003.txt"

rlPhaseEnd
}


sudorule-add-host_001() {

rlPhaseStartTest "sudorule-add-host_001: Add host help to sudorule."

	rlRun "ipa help sudorule-add-host > $TmpDir/sudorule-add-host_001.txt 2>&1"
	rlAssertGrep "Purpose: Add hosts and hostgroups affected by Sudo Rule." "$TmpDir/sudorule-add-host_001.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-add-host SUDORULE-NAME \[options\]" "$TmpDir/sudorule-add-host_001.txt"
	rlAssertGrep "\-h, \--help        show this help message and exit" "$TmpDir/sudorule-add-host_001.txt"
	rlAssertGrep "\--all             Retrieve and print all attributes from the server." "$TmpDir/sudorule-add-host_001.txt"
	rlAssertGrep "\--raw             Print entries as stored on the server." "$TmpDir/sudorule-add-host_001.txt"
	rlAssertGrep "\--hosts=STR       comma-separated list of hosts to add" "$TmpDir/sudorule-add-host_001.txt"
	rlAssertGrep "\--hostgroups=STR  comma-separated list of host groups to add" "$TmpDir/sudorule-add-host_001.txt"
	rlRun "cat $TmpDir/sudorule-add-host_001.txt"

rlPhaseEnd
}

sudorule-add-host_002() {

rlPhaseStartTest "sudorule-add-host_002: Add host to sudorule."

	rlRun "ipa sudorule-add sudorule1"

	rlRun "ipa sudorule-add-host sudorule1 --hosts=test1.example.com > $TmpDir/sudorule-add-host_002.txt 2>&1"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-add-host_002.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-add-host_002.txt"
	rlAssertGrep "External host: test1.example.com" "$TmpDir/sudorule-add-host_002.txt"
	rlAssertGrep "Number of members added 1" "$TmpDir/sudorule-add-host_002.txt"
	rlRun "cat $TmpDir/sudorule-add-host_002.txt"

rlPhaseEnd
}


sudorule-add-host_003() {

rlPhaseStartTest "sudorule-add-host_003: Add muliple hosts to sudorule."

        rlRun "ipa sudorule-add-host sudorule1 --hosts=test2.example.com,test3.example2.com > $TmpDir/sudorule-add-host_003.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-add-host_003.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-add-host_003.txt"
        rlAssertGrep "External host: test1.example.com, test2.example.com, test3.example2.com" "$TmpDir/sudorule-add-host_003.txt"
        rlAssertGrep "Number of members added 2" "$TmpDir/sudorule-add-host_003.txt"
        rlRun "cat $TmpDir/sudorule-add-host_003.txt"

rlPhaseEnd
}

sudorule-add-host_004() {

rlPhaseStartTest "sudorule-add-host_004: Add hostgroup to sudorule."

	rlRun "ipa hostgroup-add hostgroup1 --desc=\"hostgroup 1\""
	rlRun "ipa hostgroup-add hostgroup2 --desc=\"hostgroup 2\""
	rlRun "ipa hostgroup-add hostgroup3 --desc=\"hostgroup 3\""
	rlRun "ipa hostgroup-add hostgroup4 --desc=\"hostgroup 4\""
	rlRun "ipa hostgroup-add hostgroup5 --desc=\"hostgroup 5\""

	rlRun "ipa sudorule-add-host sudorule1 --hostgroups=hostgroup1  > $TmpDir/sudorule-add-host_004.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-add-host_004.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-add-host_004.txt"
        rlAssertGrep "Host Groups: hostgroup1" "$TmpDir/sudorule-add-host_004.txt"
        rlAssertGrep "Number of members added 1" "$TmpDir/sudorule-add-host_004.txt"
        rlRun "cat $TmpDir/sudorule-add-host_004.txt"

rlPhaseEnd
}


sudorule-add-host_005() {

rlPhaseStartTest "sudorule-add-host_005: Add multiple hostgroups to sudorule."

	rlRun "ipa sudorule-add-host sudorule1 --hostgroups=hostgroup2,hostgroup3 > $TmpDir/sudorule-add-host_005.txt 2>&1"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-add-host_005.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-add-host_005.txt"
	rlAssertGrep "Host Groups: hostgroup1, hostgroup2, hostgroup3" "$TmpDir/sudorule-add-host_005.txt"
	rlAssertGrep "Number of members added 2" "$TmpDir/sudorule-add-host_005.txt"
	rlRun "cat $TmpDir/sudorule-add-host_005.txt"

rlPhaseEnd
}

sudorule-add-host_006() {

rlPhaseStartTest "sudorule-add-host_006: Add both host and hostgroup to sudorule."

	rlRun "ipa sudorule-add-host sudorule1 --hosts=test4.example.com,test5.example --hostgroups=hostgroup4,hostgroup5 > $TmpDir/sudorule-add-host_006.txt 2>&1"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-add-host_006.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-add-host_006.txt"
	rlAssertGrep "Host Groups: hostgroup1, hostgroup2, hostgroup3, hostgroup4, hostgroup5" "$TmpDir/sudorule-add-host_006.txt"
	rlAssertGrep "External host: test1.example.com, test2.example.com, test3.example2.com, test4.example.com, test5.example" "$TmpDir/sudorule-add-host_006.txt"
	rlAssertGrep "Number of members added 4" "$TmpDir/sudorule-add-host_006.txt"
	rlRun "cat $TmpDir/sudorule-add-host_006.txt"

rlPhaseEnd
}

sudorule-remove-host_001() {

rlPhaseStartTest "sudorule-remove-host_001: Remove host help to sudorule."

	rlRun "ipa help sudorule-remove-host > $TmpDir/sudorule-remove-host_001.txt 2>&1"
	rlAssertGrep "Purpose: Remove hosts and hostgroups affected by Sudo Rule." "$TmpDir/sudorule-remove-host_001.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-remove-host SUDORULE-NAME \[options\]" "$TmpDir/sudorule-remove-host_001.txt"
	rlAssertGrep "\-h, \--help        show this help message and exit" "$TmpDir/sudorule-remove-host_001.txt"
	rlAssertGrep "\--all             Retrieve and print all attributes from the server." "$TmpDir/sudorule-remove-host_001.txt"
	rlAssertGrep "\--raw             Print entries as stored on the server." "$TmpDir/sudorule-remove-host_001.txt"
	rlAssertGrep "\--hosts=STR       comma-separated list of hosts to remove" "$TmpDir/sudorule-remove-host_001.txt"
	rlAssertGrep "\--hostgroups=STR  comma-separated list of host groups to remove" "$TmpDir/sudorule-remove-host_001.txt"
	rlRun "cat $TmpDir/sudorule-remove-host_001.txt"

rlPhaseEnd
}


sudorule-remove-host_002() {

rlPhaseStartTest "sudorule-remove-host_002: Remove host from sudorule."

	rlRun "ipa sudorule-remove-host sudorule1 --hosts=test1.example.com > $TmpDir/sudorule-remove-host_002.txt 2>&1"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-remove-host_002.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-remove-host_002.txt"
	rlLog "Verifying https://bugzilla.redhat.com/show_bug.cgi?id=709645"
	rlAssertGrep "External host: test2.example.com, test3.example2.com" "$TmpDir/sudorule-remove-host_002.txt"
	rlAssertGrep "Host Groups: hostgroup1, hostgroup2, hostgroup3" "$TmpDir/sudorule-remove-host_002.txt"
	rlAssertGrep "Number of members removed 1" "$TmpDir/sudorule-remove-host_002.txt"
	rlRun "cat $TmpDir/sudorule-remove-host_002.txt"

rlPhaseEnd
}

sudorule-remove-host_003() {

rlPhaseStartTest "sudorule-remove-host_003: Remove multiple hosts from sudorule."

	rlRun "ipa sudorule-remove-host sudorule1 --hosts=test2.example.com,test3.example2.com --all > $TmpDir/sudorule-remove-host_003.txt 2>&1"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-remove-host_003.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-remove-host_003.txt"
	rlLog "Verifying https://bugzilla.redhat.com/show_bug.cgi?id=709665"
	rlAssertNotGrep "test2.example.com" "$TmpDir/sudorule-remove-host_003.txt" 1
	rlAssertNotGrep "test3.example2.com" "$TmpDir/sudorule-remove-host_003.txt" 1
	rlAssertGrep "test5.example" "$TmpDir/sudorule-remove-host_003.txt" 
	rlAssertGrep "test4.example.com" "$TmpDir/sudorule-remove-host_003.txt" 
	rlAssertGrep "Host Groups: hostgroup1, hostgroup2, hostgroup3" "$TmpDir/sudorule-remove-host_003.txt"
	rlAssertGrep "Number of members removed 2" "$TmpDir/sudorule-remove-host_003.txt"
	rlRun "cat $TmpDir/sudorule-remove-host_003.txt"

rlPhaseEnd
}


sudorule-remove-host_004() {

rlPhaseStartTest "sudorule-remove-host_004: Remove hostgroup from sudorule."

	rlRun "ipa sudorule-remove-host sudorule1 --hostgroup=hostgroup1 > $TmpDir/sudorule-remove-host_004.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-remove-host_004.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-remove-host_004.txt"
        rlAssertGrep "Host Groups: hostgroup2, hostgroup3" "$TmpDir/sudorule-remove-host_004.txt"
        rlAssertGrep "Number of members removed 1" "$TmpDir/sudorule-remove-host_004.txt"
        rlRun "cat $TmpDir/sudorule-remove-host_004.txt"

rlPhaseEnd
}


sudorule-remove-host_005() {

rlPhaseStartTest "sudorule-remove-host_005: Remove multiple hostgroup from sudorule."

	rlRun "ipa sudorule-remove-host sudorule1 --hostgroup=hostgroup2,hostgroup3 > $TmpDir/sudorule-remove-host_005.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-remove-host_005.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-remove-host_005.txt"
	rlAssertGrep "Number of members removed 2" "$TmpDir/sudorule-remove-host_005.txt"

rlPhaseEnd
}

sudorule-remove-host_006() {

rlPhaseStartTest "sudorule-remove-host_006: Remove both host and hostgroup from sudorule."

        rlRun "ipa sudorule-remove-host sudorule1 --hosts=test4.example.com,test5.example --hostgroups=hostgroup4,hostgroup5 > $TmpDir/sudorule-remove-host_006.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-remove-host_006.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-remove-host_006.txt"
        rlAssertGrep "Number of members removed 4" "$TmpDir/sudorule-remove-host_006.txt"
        rlRun "cat $TmpDir/sudorule-add-host_006.txt"

	rlRun "ipa hostgroup-del hostgroup1"
	rlRun "ipa hostgroup-del hostgroup2"
	rlRun "ipa hostgroup-del hostgroup3"
	rlRun "ipa hostgroup-del hostgroup4"
	rlRun "ipa hostgroup-del hostgroup5"

rlPhaseEnd
}


sudorule_enable_flag_001() {


rlPhaseStartTest "sudorule_enable_flag_001: ipa sudorule-disable sudorulename"

	rlRun "ipa sudorule-add sudorule5"

	rlRun "ipa sudorule-disable sudorule5 > $TmpDir/sudorule_enable_flag_001.txt 2>&1"
	rlAssertGrep "Disabled Sudo Rule \"sudorule5\"" "$TmpDir/sudorule_enable_flag_001.txt"
	rlRun "cat $TmpDir/sudorule_enable_flag_001.txt"
	rlRun "ipa sudorule-find sudorule5 --all --raw > $TmpDir/sudorule_enable_flag_001.txt"
	rlAssertGrep "ipaenabledflag: FALSE" "$TmpDir/sudorule_enable_flag_001.txt"
	rlRun "cat $TmpDir/sudorule_enable_flag_001.txt"

rlPhaseEnd
}


sudorule_enable_flag_002() {

rlPhaseStartTest "sudorule_enable_flag_002: ipa sudorule-enable sudorulename"

	rlRun "ipa sudorule-enable sudorule5 > $TmpDir/sudorule_enable_flag_002.txt 2>&1"
        rlAssertGrep "Enabled Sudo Rule \"sudorule5\"" "$TmpDir/sudorule_enable_flag_002.txt"
        rlRun "cat $TmpDir/sudorule_enable_flag_002.txt"
        rlRun "ipa sudorule-find sudorule5 --all --raw > $TmpDir/sudorule_enable_flag_002.txt"
        rlAssertGrep "ipaenabledflag: TRUE" "$TmpDir/sudorule_enable_flag_002.txt"
        rlRun "cat $TmpDir/sudorule_enable_flag_002.txt"

	rlRun "ipa sudorule-del sudorule5"

rlPhaseEnd
}


sudorule-add-user_001() {

rlPhaseStartTest "sudorule-add-user_001: ipa help sudorule-add-user"

	rlRun "ipa help sudorule-add-user > $TmpDir/sudorule-add-user_001.txt 2>&1"
	rlAssertGrep "Purpose: Add users and groups affected by Sudo Rule." "$TmpDir/sudorule-add-user_001.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-add-user SUDORULE-NAME \[options\]" "$TmpDir/sudorule-add-user_001.txt"
	rlAssertGrep "\-h, \--help    show this help message and exit" "$TmpDir/sudorule-add-user_001.txt"
	rlAssertGrep "\--all         Retrieve and print all attributes from the server." "$TmpDir/sudorule-add-user_001.txt"
	rlAssertGrep "\--raw         Print entries as stored on the server." "$TmpDir/sudorule-add-user_001.txt"
	rlAssertGrep "\--users=STR   comma-separated list of users to add" "$TmpDir/sudorule-add-user_001.txt"
	rlAssertGrep "\--groups=STR  comma-separated list of groups to add" "$TmpDir/sudorule-add-user_001.txt"
	rlRun "cat $TmpDir/sudorule-add-user_001.txt"

rlPhaseEnd
}

sudorule-add-user_002() {

rlPhaseStartTest "sudorule-add-user_002: ipa sudorule-add-user sudorule --users"

	rlRun "ipa sudorule-add-user sudorule1 --users=tuser1,tuser2,tuser3,tuser4 > $TmpDir/sudorule-add-user_002.txt 2>&1"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-add-user_002.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-add-user_002.txt"
	rlAssertGrep "External User: tuser1, tuser2, tuser3, tuser4" "$TmpDir/sudorule-add-user_002.txt"
	rlAssertGrep "Number of members added 4" "$TmpDir/sudorule-add-user_002.txt"
	rlRun "cat $TmpDir/sudorule-add-user_002.txt"

rlPhaseEnd
}


sudorule-add-user_003() {

rlPhaseStartTest "sudorule-add-user_003: ipa sudorule-add-user sudorule --groups"

	rlRun "ipa group-add group7 --desc=group7"
	rlRun "ipa group-add group8 --desc=group8"
	rlRun "ipa group-add group9 --desc=group9"

	rlRun "ipa sudorule-add-user sudorule1 --groups=group7,group8,group9 > $TmpDir/sudorule-add-user_003.txt 2>&1"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-add-user_003.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-add-user_003.txt"
	rlAssertGrep "Groups: group7, group8, group9" "$TmpDir/sudorule-add-user_003.txt"
	rlRun "cat $TmpDir/sudorule-add-user_003.txt"

rlPhaseEnd
}


sudorule-remove-user_001() {

rlPhaseStartTest "sudorule-remove-user_001: ipa help sudorule-remove-user"

        rlRun "ipa help sudorule-remove-user > $TmpDir/sudorule-remove-user_001.txt 2>&1"
        rlAssertGrep "Purpose: Remove users and groups affected by Sudo Rule." "$TmpDir/sudorule-remove-user_001.txt"
        rlAssertGrep "Usage: ipa \[global-options\] sudorule-remove-user SUDORULE-NAME \[options\]" "$TmpDir/sudorule-remove-user_001.txt"
        rlAssertGrep "\-h, \--help    show this help message and exit" "$TmpDir/sudorule-remove-user_001.txt"
        rlAssertGrep "\--all         Retrieve and print all attributes from the server." "$TmpDir/sudorule-remove-user_001.txt"
        rlAssertGrep "\--raw         Print entries as stored on the server." "$TmpDir/sudorule-remove-user_001.txt"
        rlAssertGrep "\--users=STR   comma-separated list of users to remove" "$TmpDir/sudorule-remove-user_001.txt"
        rlAssertGrep "\--groups=STR  comma-separated list of groups to remove" "$TmpDir/sudorule-remove-user_001.txt"
        rlRun "cat $TmpDir/sudorule-remove-user_001.txt"

rlPhaseEnd
}

sudorule-remove-user_002() {

rlPhaseStartTest "sudorule-remove-user_002: ipa sudorule-remove-user sudorule --users"
        
        rlRun "ipa sudorule-remove-user sudorule1 --users=tuser1,tuser2,tuser3,tuser4 > $TmpDir/sudorule-remove-user_002.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-remove-user_002.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-remove-user_002.txt"
#        rlAssertGrep "External User: user1, user2, user3, user4" "$TmpDir/sudorule-remove-user_002.txt"
        rlAssertGrep "Number of members removed 4" "$TmpDir/sudorule-remove-user_002.txt"
        rlRun "cat $TmpDir/sudorule-remove-user_002.txt"

rlPhaseEnd
}


sudorule-remove-user_003() {

rlPhaseStartTest "sudorule-remove-user_003: ipa sudorule-remove-user sudorule --groups"

        rlRun "ipa sudorule-remove-user sudorule1 --groups=group7,group8,group9 > $TmpDir/sudorule-remove-user_003.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-remove-user_003.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-remove-user_003.txt"
        rlRun "cat $TmpDir/sudorule-remove-user_003.txt"

        rlRun "ipa group-del group7"
        rlRun "ipa group-del group8"
        rlRun "ipa group-del group9"

rlPhaseEnd
}


sudorule-show_001() {

rlPhaseStartTest "sudorule-show_001: ipa help sudorule-show"

	rlRun "ipa help sudorule-show > $TmpDir/sudorule-show_001.txt 2>&1"
	rlAssertGrep "Purpose: Display Sudo Rule." "$TmpDir/sudorule-show_001.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-show SUDORULE-NAME \[options\]" "$TmpDir/sudorule-show_001.txt"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/sudorule-show_001.txt"
	rlAssertGrep "\--rights    Display the access rights of this entry (requires \--all)." "$TmpDir/sudorule-show_001.txt"
	rlAssertGrep "\--all       Retrieve and print all attributes from the server." "$TmpDir/sudorule-show_001.txt"
	rlAssertGrep "\--raw       Print entries as stored on the server." "$TmpDir/sudorule-show_001.txt"
	rlRun "cat $TmpDir/sudorule-show_001.txt"

rlPhaseEnd
}


sudorule-show_002() {

rlPhaseStartTest "sudorule-show_002: ipa sudorule-show sudorule"

	rlRun "ipa sudorule-show sudorule1 > $TmpDir/sudorule-show_002.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-show_002.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-show_002.txt"
	rlRun "cat $TmpDir/sudorule-show_002.txt"

rlPhaseEnd
}

sudorule-show_003() {

rlPhaseStartTest "sudorule-show_003: ipa sudorule-show sudorule --all"

	rlRun "ipa sudorule-show sudorule1 --all > $TmpDir/sudorule-show_003.txt 2>&1"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-show_003.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-show_003.txt"
	rlAssertGrep "objectclass: ipaassociation, ipasudorule"  "$TmpDir/sudorule-show_003.txt"
        rlRun "cat $TmpDir/sudorule-show_003.txt"

rlPhaseEnd
}

sudorule-show_004() {

rlPhaseStartTest "sudorule-show_004: ipa sudorule-show sudorule --all --rights"

	rlRun "ipa sudorule-show sudorule1 --all --rights > $TmpDir/sudorule-show_004.txt 2>&1"
	rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-show_004.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-show_004.txt"
        rlAssertGrep "objectclass: ipaassociation, ipasudorule"  "$TmpDir/sudorule-show_004.txt"
	rlAssertGrep "attributelevelrights: {'sudonotafter': u'rscwo', 'cn': u'rscwo', 'hostmask': u'rscwo', 'memberuser': u'rscwo', 'memberallowcmd': u'rscwo', 'sudonotbefore': u'rscwo', 'ipasudorunas': u'rscwo', 'cmdcategory': u'rscwo', 'ipasudoopt': u'rscwo', 'nsaccountlock': u'rscwo', 'ipasudorunasextuser': u'rscwo', 'externaluser': u'rscwo', 'memberhost': u'rscwo', 'description': u'rscwo', 'externalhost': u'rscwo', 'hostcategory': u'rscwo', 'ipauniqueid': u'rsc', 'ipaenabledflag': u'rscwo', 'ipasudorunasgroup': u'rscwo', 'sudoorder': u'rscwo', 'ipasudorunasgroupcategory': u'rscwo', 'ipasudorunasextgroup': u'rscwo', 'aci': u'rscwo', 'memberdenycmd': u'rscwo', 'usercategory': u'rscwo', 'ipasudorunasusercategory': u'rscwo'}" "$TmpDir/sudorule-show_004.txt"
        rlRun "cat $TmpDir/sudorule-show_004.txt"

rlPhaseEnd
}

sudorule-show_005() {

rlPhaseStartTest "sudorule-show_005: ipa sudorule-show sudorule --all --raw"

	rlRun "ipa sudorule-show sudorule1 --all --raw > $TmpDir/sudorule-show_005.txt 2>&1"
	rlAssertGrep "cn: sudorule1" "$TmpDir/sudorule-show_005.txt"
	rlAssertGrep "ipaenabledflag: TRUE" "$TmpDir/sudorule-show_005.txt"
	rlAssertGrep "objectclass: ipaassociation" "$TmpDir/sudorule-show_005.txt"
	rlAssertGrep "objectclass: ipasudorule" "$TmpDir/sudorule-show_005.txt"
	rlRun "cat $TmpDir/sudorule-show_005.txt"

rlPhaseEnd
}


sudorule-add-option_001() {

rlPhaseStartTest "sudorule-add-option_001: ipa help sudorule-add-option"

	rlRun "ipa help sudorule-add-option > $TmpDir/sudorule-add-option_001.txt 2>&1"
	rlAssertGrep "Purpose: Add an option to the Sudo Rule." "$TmpDir/sudorule-add-option_001.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-add-option SUDORULE-NAME \[options\]" "$TmpDir/sudorule-add-option_001.txt"
	rlAssertGrep "\-h, \--help        show this help message and exit" "$TmpDir/sudorule-add-option_001.txt"
	rlAssertGrep "\--sudooption=STR  Sudo Option" "$TmpDir/sudorule-add-option_001.txt"
	rlRun "cat $TmpDir/sudorule-add-option_001.txt"

rlPhaseEnd
}


sudorule-add-option_002() {

rlPhaseStartTest "sudorule-add-option_002: ipa sudorule-add-option sudorule1 --sudooption=logfile=/var/log/sudolog"

        rlRun "ipa sudorule-add-option sudorule1 --sudooption=\"logfile=/var/log/sudolog\" > $TmpDir/sudorule-add-option_002.txt 2>&1"
        rlAssertGrep "Added option \"logfile=/var/log/sudolog\" to Sudo Rule \"sudorule1\"" "$TmpDir/sudorule-add-option_002.txt"
        rlRun "cat $TmpDir/sudorule-add-option_002.txt"

        rlRun "ipa sudorule-find sudorule1 --all > $TmpDir/sudorule-add-option_002.txt 2>&1"
        rlAssertGrep "Sudo Option: logfile=/var/log/sudolog" "$TmpDir/sudorule-add-option_002.txt"
        rlRun "cat $TmpDir/sudorule-add-option_002.txt"

rlPhaseEnd
}


sudorule-add-option_003() {

rlPhaseStartTest "sudorule-add-option_003: ipa sudorule-add-option --sudooption=env_keep"

        rlRun "ipa sudorule-add-option sudorule1 --sudooption=\"env_keep = LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE\" > $TmpDir/sudorule-add-option_003.txt  2>&1"
        rlAssertGrep "Added option \"env_keep = LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE\" to Sudo Rule \"sudorule1\"" "$TmpDir/sudorule-add-option_003.txt"
        rlRun "cat $TmpDir/sudorule-add-option_003.txt"

        rlRun "ipa sudorule-find sudorule1 --all > $TmpDir/sudorule-add-option_003.txt 2>&1"
        rlAssertGrep "Sudo Option: logfile=/var/log/sudolog, env_keep = LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE" "$TmpDir/sudorule-add-option_003.txt"
        rlRun "cat $TmpDir/sudorule-add-option_003.txt"

rlPhaseEnd
}


sudorule-add-option_004() {

rlPhaseStartTest "sudorule-add-option_004: ipa sudorule-add-option --sudooption=!authenticate"

        rlRun "ipa sudorule-add-option sudorule1 --sudooption='!authenticate' > $TmpDir/sudorule-add-option_004.txt 2>&1"
        rlAssertGrep "Added option" "$TmpDir/sudorule-add-option_004.txt"
        rlRun "cat $TmpDir/sudorule-add-option_004.txt"

        rlRun "ipa sudorule-find sudorule1 --all > $TmpDir/sudorule-add-option_004.txt 2>&1"
        rlAssertGrep "Sudo Option: logfile=/var/log/sudolog, env_keep = LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE, !authenticate" "$TmpDir/sudorule-add-option_004.txt"
        rlRun "cat $TmpDir/sudorule-add-option_004.txt"

rlPhaseEnd
}


sudorule-remove-option_001() {

rlPhaseStartTest "sudorule-remove-option_001: ipa help sudorule-remove-option"

        rlRun "ipa help sudorule-remove-option > $TmpDir/sudorule-remove-option_001.txt 2>&1"
        rlAssertGrep "Purpose: Remove an option from Sudo Rule." "$TmpDir/sudorule-remove-option_001.txt"
        rlAssertGrep "Usage: ipa \[global-options\] sudorule-remove-option SUDORULE-NAME \[options\]" "$TmpDir/sudorule-remove-option_001.txt"
        rlAssertGrep "\-h, \--help        show this help message and exit" "$TmpDir/sudorule-remove-option_001.txt"
        rlAssertGrep "\--sudooption=STR  Sudo Option" "$TmpDir/sudorule-remove-option_001.txt"
        rlRun "cat $TmpDir/sudorule-remove-option_001.txt"

rlPhaseEnd
}


sudorule-remove-option_002() {

rlPhaseStartTest "sudorule-remove-option_002: ipa sudorule-remove-option sudorule1 --sudooption=\"logfile=/var/log/sudolog\""

        rlRun "ipa sudorule-remove-option sudorule1 --sudooption=logfile=/var/log/sudolog > $TmpDir/sudorule-remove-option_002.txt 2>&1"
        rlAssertGrep "Removed option \"logfile=/var/log/sudolog\" from Sudo Rule \"sudorule1\"" "$TmpDir/sudorule-remove-option_002.txt"
        rlRun "cat $TmpDir/sudorule-remove-option_002.txt"

rlPhaseEnd
}


sudorule-remove-option_003() {

rlPhaseStartTest "sudorule-remove-option_003: ipa sudorule-remove-option --sudooption=env_keep"

        rlRun "ipa sudorule-remove-option sudorule1 --sudooption=\"env_keep = LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE\" > $TmpDir/sudorule-remove-option_003.txt  2>&1"
        rlAssertGrep "Removed option \"env_keep = LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE\" from Sudo Rule \"sudorule1\"" "$TmpDir/sudorule-remove-option_003.txt"
        rlRun "cat $TmpDir/sudorule-remove-option_003.txt"

rlPhaseEnd
}


sudorule-remove-option_004() {

rlPhaseStartTest "sudorule-remove-option_004: ipa sudorule-remove-option --sudooption=!authenticate"

        rlRun "ipa sudorule-remove-option sudorule1 --sudooption='!authenticate' > $TmpDir/sudorule-remove-option_004.txt 2>&1"
        rlAssertGrep "Removed option \"!authenticate\" from Sudo Rule \"sudorule1\"" "$TmpDir/sudorule-remove-option_004.txt"
        rlRun "cat $TmpDir/sudorule-remove-option_004.txt"
	rlRun "ipa sudorule-del sudorule1"

rlPhaseEnd
}



sudorule-add-runasuser_001() {

rlPhaseStartTest "sudorule-add-runasuser_001: ipa help sudorule-add-runasuser"

	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=711705"
	rlRun "ipa help sudorule-add-runasuser > $TmpDir/sudorule-add-runasuser_001.txt 2>&1"
	rlAssertGrep "Purpose: Add users and groups for Sudo to execute as." "$TmpDir/sudorule-add-runasuser_001.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-add-runasuser SUDORULE-NAME \[options\]" "$TmpDir/sudorule-add-runasuser_001.txt"
	rlAssertGrep "\-h, \--help    show this help message and exit" "$TmpDir/sudorule-add-runasuser_001.txt"
	rlAssertGrep "\--all         Retrieve and print all attributes from the server." "$TmpDir/sudorule-add-runasuser_001.txt"
	rlAssertGrep "\--raw         Print entries as stored on the server." "$TmpDir/sudorule-add-runasuser_001.txt"
	rlAssertGrep "\--users=STR   comma-separated list of users to add" "$TmpDir/sudorule-add-runasuser_001.txt"
	rlAssertGrep "\--groups=STR  comma-separated list of groups to add" "$TmpDir/sudorule-add-runasuser_001.txt"
	rlRun "cat $TmpDir/sudorule-add-runasuser_001.txt"

rlPhaseEnd
}


sudorule-add-runasuser_002() {

rlPhaseStartTest "sudorule-add-runasuser_002: ipa sudorule-add-runasuser --users"

	rlRun "ipa user-add sudouser1 --first=sudo --last=user1"
	rlRun "ipa user-add sudouser2 --first=sudo --last=user2"
	rlRun "ipa sudorule-add rule1"

	rlRun "ipa sudorule-add-runasuser rule1 --users=sudouser1,sudouser2 > $TmpDir/sudorule-add-runasuser_002.txt 2>&1"
	rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-add-runasuser_002.txt"
	rlAssertGrep "RunAs Users: sudouser1, sudouser2" "$TmpDir/sudorule-add-runasuser_002.txt"
	rlAssertGrep "Number of members added 2" "$TmpDir/sudorule-add-runasuser_002.txt"
	rlRun "cat $TmpDir/sudorule-add-runasuser_002.txt"

        rlRun "ipa user-del sudouser1"
        rlRun "ipa user-del sudouser2"
        rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}


sudorule-add-runasuser_003() {

rlPhaseStartTest "sudorule-add-runasuser_003: ipa sudorule-add-runasuser --groups"

        rlRun "ipa group-add sudogrp1 --desc=grp1"
        rlRun "ipa group-add sudogrp2 --desc=grp2"
        rlRun "ipa sudorule-add rule1"

	rlRun "ipa sudorule-add-runasuser rule1 --groups=sudogrp1,sudogrp2 > $TmpDir/sudorule-add-runasuser_003.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-add-runasuser_003.txt"
	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=710253"
        rlAssertGrep "Groups of RunAs Users: sudogrp1, sudogrp2" "$TmpDir/sudorule-add-runasuser_003.txt"
	rlAssertGrep "Number of members added 2" "$TmpDir/sudorule-add-runasuser_003.txt"
	rlRun "cat $TmpDir/sudorule-add-runasuser_003.txt"

	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=713385"
	rlRun "ipa sudorule-find rule1 --all > $TmpDir/sudorule-add-runasuser_003.txt 2>&1"
	rlAssertGrep "Groups of RunAs Users: sudogrp1, sudogrp2" "$TmpDir/sudorule-add-runasuser_003.txt"
	rlRun "cat $TmpDir/sudorule-add-runasuser_003.txt"

        rlRun "ipa sudorule-del rule1"
	rlRun "ipa group-del sudogrp1"
	rlRun "ipa group-del sudogrp2"

rlPhaseEnd
}


sudorule-remove-runasuser_001() {

rlPhaseStartTest "sudorule-remove-runasuser_001: ipa sudorule-remove-runasuser --help"

	rlRun "ipa help sudorule-remove-runasuser > $TmpDir/sudorule-remove-runasuser_001.txt 2>&1"

	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=713374"
	rlAssertGrep "Purpose: Remove users and groups for Sudo to execute as." "$TmpDir/sudorule-remove-runasuser_001.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-remove-runasuser SUDORULE-NAME \[options\]" "$TmpDir/sudorule-remove-runasuser_001.txt"
	rlAssertGrep "\-h, \--help    show this help message and exit" "$TmpDir/sudorule-remove-runasuser_001.txt"
	rlAssertGrep "\--all         Retrieve and print all attributes from the server." "$TmpDir/sudorule-remove-runasuser_001.txt"
	rlAssertGrep "\--raw         Print entries as stored on the server." "$TmpDir/sudorule-remove-runasuser_001.txt"
	rlAssertGrep "\--users=STR   comma-separated list of users to remove" "$TmpDir/sudorule-remove-runasuser_001.txt"
	rlAssertGrep "\--groups=STR  comma-separated list of groups to remove" "$TmpDir/sudorule-remove-runasuser_001.txt"
	rlRun "cat $TmpDir/sudorule-remove-runasuser_001.txt"

rlPhaseEnd
}


sudorule-remove-runasuser_002() {

rlPhaseStartTest "sudorule-remove-runasuser_002: ipa sudorule-remove-runasuser --users"

        rlRun "ipa user-add sudouser1 --first=sudo --last=user1"
        rlRun "ipa user-add sudouser2 --first=sudo --last=user2"
        rlRun "ipa sudorule-add rule1"
        rlRun "ipa sudorule-add-runasuser rule1 --users=sudouser1,sudouser2"


	rlRun "ipa sudorule-remove-runasuser rule1 --users=sudouser1,sudouser2 > $TmpDir/sudorule-remove-runasuser_002.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-remove-runasuser_002.txt"
        rlAssertGrep "Number of members removed 2" "$TmpDir/sudorule-remove-runasuser_002.txt"
        rlRun "cat $TmpDir/sudorule-add-runasuser_002.txt"

        rlRun "ipa user-del sudouser1"
        rlRun "ipa user-del sudouser2"
        rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}


sudorule-remove-runasuser_003() {

rlPhaseStartTest "sudorule-remove-runasuser_003: ipa sudorule-remove-runasuser --groups"

        rlRun "ipa group-add sudogrp1 --desc=grp1"
        rlRun "ipa group-add sudogrp2 --desc=grp2"
        rlRun "ipa sudorule-add rule1"
        rlRun "ipa sudorule-add-runasuser rule1 --groups=sudogrp1,sudogrp2"

	rlRun "ipa sudorule-remove-runasuser rule1 --groups=sudogrp1,sudogrp2 > $TmpDir/sudorule-remove-runasuser_003.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-remove-runasuser_003.txt"
        rlAssertGrep "Number of members removed 2" "$TmpDir/sudorule-remove-runasuser_003.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasuser_003.txt"

        rlRun "ipa sudorule-del rule1"
        rlRun "ipa group-del sudogrp1"
        rlRun "ipa group-del sudogrp2"

rlPhaseEnd
}


sudorule-remove-runasuser_004() {

rlPhaseStartTest "sudorule-remove-runasuser_004: ipa sudorule-remove-runasuser --groups=single group"

        rlRun "ipa group-add sudogrp1 --desc=grp1"
        rlRun "ipa group-add sudogrp2 --desc=grp2"
        rlRun "ipa sudorule-add rule1"
        rlRun "ipa sudorule-add-runasuser rule1 --groups=sudogrp1,sudogrp2"

	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=713380"
        rlRun "ipa sudorule-remove-runasuser rule1 --groups=sudogrp1 > $TmpDir/sudorule-remove-runasuser_004.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-remove-runasuser_004.txt"
	rlAssertGrep "Groups of RunAs Users: sudogrp2" "$TmpDir/sudorule-remove-runasuser_004.txt"
        rlAssertGrep "Number of members removed 1" "$TmpDir/sudorule-remove-runasuser_004.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasuser_004.txt"


        rlRun "ipa sudorule-del rule1"
        rlRun "ipa group-del sudogrp1"
        rlRun "ipa group-del sudogrp2"

rlPhaseEnd
}

sudorule-remove-runasuser_005() {

rlPhaseStartTest "sudorule-remove-runasuser_005: ipa sudorule-remove-runasuser --users=single user"

        rlRun "ipa user-add sudouser1 --first=sudo --last=user1"
        rlRun "ipa user-add sudouser2 --first=sudo --last=user2"
        rlRun "ipa sudorule-add rule1"
        rlRun "ipa sudorule-add-runasuser rule1 --users=sudouser1,sudouser2"


        rlRun "ipa sudorule-remove-runasuser rule1 --users=sudouser1 > $TmpDir/sudorule-remove-runasuser_005.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-remove-runasuser_005.txt"
	rlAssertGrep "RunAs Users: sudouser2" "$TmpDir/sudorule-remove-runasuser_005.txt"
        rlAssertGrep "Number of members removed 1" "$TmpDir/sudorule-remove-runasuser_005.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasuser_005.txt"

	rlRun "ipa sudorule-find rule1 --all > $TmpDir/sudorule-remove-runasuser_005.txt 2>&1"
	rlAssertGrep "RunAs Users: sudouser2" "$TmpDir/sudorule-remove-runasuser_005.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasuser_005.txt"

        rlRun "ipa user-del sudouser1"
        rlRun "ipa user-del sudouser2"
        rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}


sudorule-add-runasgroup_001() {

rlPhaseStartTest "sudorule-add-runasgroup_001: ipa help sudorule-add-runasgroup"

	rlRun "ipa help sudorule-add-runasgroup > $TmpDir/sudorule-add-runasgroup_001.txt 2>&1"
	rlAssertGrep "Purpose: Add group for Sudo to execute as." "$TmpDir/sudorule-add-runasgroup_001.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-add-runasgroup SUDORULE-NAME \[options\]" "$TmpDir/sudorule-add-runasgroup_001.txt"
	rlAssertGrep "\-h, \--help    show this help message and exit" "$TmpDir/sudorule-add-runasgroup_001.txt"
	rlAssertGrep "\--all         Retrieve and print all attributes from the server." "$TmpDir/sudorule-add-runasgroup_001.txt"
	rlAssertGrep "\--raw         Print entries as stored on the server." "$TmpDir/sudorule-add-runasgroup_001.txt"
	rlAssertGrep "\--groups=STR  comma-separated list of groups to add" "$TmpDir/sudorule-add-runasgroup_001.txt"
	rlRun "cat $TmpDir/sudorule-add-runasgroup_001.txt"

rlPhaseEnd
}

sudorule-add-runasgroup_002() {

rlPhaseStartTest "sudorule-add-runasgroup_002: ipa sudorule-add-runasgroup rule1 --groups --all --raw"

	rlRun "ipa sudorule-add rule1"
	rlRun "ipa sudorule-add-runasgroup rule1 --groups=tgroup1 > $TmpDir/sudorule-add-runasgroup_002.txt 2>&1"
	rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-add-runasgroup_002.txt"
	rlAssertGrep "RunAs External Group: tgroup1" "$TmpDir/sudorule-add-runasgroup_002.txt"
	rlAssertGrep "Number of members added 1" "$TmpDir/sudorule-add-runasgroup_002.txt"
	rlRun "cat $TmpDir/sudorule-add-runasgroup_002.txt"

	rlRun "ipa sudorule-add-runasgroup rule1 --groups=tgroup2 --all > $TmpDir/sudorule-add-runasgroup_002.txt 2>&1"
	rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "RunAs External Group: tgroup1, tgroup2" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-add-runasgroup_002.txt"

	rlRun "ipa sudorule-add-runasgroup rule1 --groups=tgroup3 --all --raw > $TmpDir/sudorule-add-runasgroup_002.txt 2>&1"
        rlAssertGrep "cn: rule1" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasextgroup: tgroup1" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasextgroup: tgroup2" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasextgroup: tgroup3" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-add-runasgroup_002.txt"

	rlRun "ipa group-add sudogrp1 --desc=grp1"
	rlRun "ipa group-add sudogrp2 --desc=grp2"
	rlRun "ipa group-add sudogrp3 --desc=grp3"
	rlRun "ipa group-add sudogrp4 --desc=grp4"
	rlRun "ipa group-add sudogrp5 --desc=grp5"
	rlRun "ipa group-add sudogrp6 --desc=grp6"

        rlRun "ipa sudorule-add-runasgroup rule1 --groups=sudogrp1 > $TmpDir/sudorule-add-runasgroup_002.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "RunAs Groups: sudogrp1" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "Number of members added 1" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-add-runasgroup_002.txt"

        rlRun "ipa sudorule-add-runasgroup rule1 --groups=sudogrp2 --all > $TmpDir/sudorule-add-runasgroup_002.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-add-runasgroup_002.txt"
	rlLog "Verified regression bug https://bugzilla.redhat.com/show_bug.cgi?id=728118"
        rlAssertGrep "RunAs Groups: sudogrp1, sudogrp2" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-add-runasgroup_002.txt"

        rlRun "ipa sudorule-add-runasgroup rule1 --groups=sudogrp3 --all --raw > $TmpDir/sudorule-add-runasgroup_002.txt 2>&1"
        rlAssertGrep "cn: rule1" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasgroup: cn=sudogrp1,cn=groups,cn=accounts," "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasgroup: cn=sudogrp2,cn=groups,cn=accounts," "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasgroup: cn=sudogrp3,cn=groups,cn=accounts," "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-add-runasgroup_002.txt"

	rlRun "ipa sudorule-add-runasgroup rule1 --groups=tgroup4,tgroup5,tgroup6 > $TmpDir/sudorule-add-runasgroup_002.txt 2>&1"
	rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-add-runasgroup_002.txt"
	rlAssertGrep "RunAs External Group: tgroup1, tgroup2, tgroup3, tgroup4, tgroup5, tgroup6" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "Number of members added 3" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-add-runasgroup_002.txt"

        rlRun "ipa sudorule-add-runasgroup rule1 --groups=sudogrp4,sudogrp5,sudogrp6 > $TmpDir/sudorule-add-runasgroup_002.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "RunAs Groups: sudogrp1, sudogrp2, sudogrp3, sudogrp4, sudogrp5, sudogrp6" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlAssertGrep "Number of members added 3" "$TmpDir/sudorule-add-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-add-runasgroup_002.txt"

rlPhaseEnd
}

sudorule-remove-runasgroup_001() {

rlPhaseStartTest "sudorule-remove-runasgroup_001: ipa help sudorule-remove-runasgroup"

	rlRun "ipa help sudorule-remove-runasgroup > $TmpDir/sudorule-remove-runasgroup_001.txt 2>&1"
	rlAssertGrep "Purpose: Remove group for Sudo to execute as." "$TmpDir/sudorule-remove-runasgroup_001.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-remove-runasgroup SUDORULE-NAME \[options\]" "$TmpDir/sudorule-remove-runasgroup_001.txt"
	rlAssertGrep "\-h, \--help    show this help message and exit" "$TmpDir/sudorule-remove-runasgroup_001.txt"
        rlAssertGrep "\--all         Retrieve and print all attributes from the server." "$TmpDir/sudorule-remove-runasgroup_001.txt"
        rlAssertGrep "\--groups=STR  comma-separated list of groups to remove" "$TmpDir/sudorule-remove-runasgroup_001.txt"
	rlRun "cat $TmpDir/sudorule-remove-runasgroup_001.txt"

rlPhaseEnd
}


sudorule-remove-runasgroup_002() {

rlPhaseStartTest "sudorule-remove-runasgroup_002: ipa sudorule-remove-runasgroup --groups --all --raw"

        rlRun "ipa sudorule-remove-runasgroup rule1 --groups=tgroup1 > $TmpDir/sudorule-remove-runasgroup_002.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "Number of members removed 1" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasgroup_002.txt"

        rlRun "ipa sudorule-remove-runasgroup rule1 --groups=tgroup2 --all > $TmpDir/sudorule-remove-runasgroup_002.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "objectclass: ipaassociation, ipasudorule" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "Number of members removed 1" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasgroup_002.txt"

        rlRun "ipa sudorule-remove-runasgroup rule1 --groups=tgroup3 --all --raw > $TmpDir/sudorule-remove-runasgroup_002.txt 2>&1"
        rlAssertGrep "cn: rule1" "$TmpDir/sudorule-remove-runasgroup_002.txt"
	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=713481"
        rlAssertNotGrep "ipasudorunasextgroup: tgroup3" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasextgroup: tgroup4" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasextgroup: tgroup5" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasextgroup: tgroup6" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasgroup_002.txt"

        rlRun "ipa sudorule-remove-runasgroup rule1 --groups=sudogrp1 > $TmpDir/sudorule-remove-runasgroup_002.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "Number of members removed 1" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasgroup_002.txt"

        rlRun "ipa sudorule-remove-runasgroup rule1 --groups=sudogrp2 --all > $TmpDir/sudorule-remove-runasgroup_002.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "RunAs Groups: sudogrp3, sudogrp4, sudogrp5, sudogrp6" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasgroup_002.txt"

        rlRun "ipa sudorule-remove-runasgroup rule1 --groups=sudogrp3 --all --raw > $TmpDir/sudorule-remove-runasgroup_002.txt 2>&1"
        rlAssertGrep "cn: rule1" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasgroup: cn=sudogrp4,cn=groups,cn=accounts," "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasgroup: cn=sudogrp5,cn=groups,cn=accounts," "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "ipasudorunasgroup: cn=sudogrp6,cn=groups,cn=accounts," "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasgroup_002.txt"

        rlRun "ipa sudorule-remove-runasgroup rule1 --groups=tgroup4,tgroup5,tgroup6 > $TmpDir/sudorule-remove-runasgroup_002.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "Number of members removed 3" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasgroup_002.txt"

        rlRun "ipa sudorule-remove-runasgroup rule1 --groups=sudogrp4,sudogrp5,sudogrp6 > $TmpDir/sudorule-remove-runasgroup_002.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlAssertGrep "Number of members removed 3" "$TmpDir/sudorule-remove-runasgroup_002.txt"
        rlRun "cat $TmpDir/sudorule-remove-runasgroup_002.txt"


	rlRun "ipa group-del sudogrp1"
	rlRun "ipa group-del sudogrp2"
	rlRun "ipa group-del sudogrp3"
	rlRun "ipa group-del sudogrp4"
	rlRun "ipa group-del sudogrp5"
	rlRun "ipa group-del sudogrp6"
	rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}


sudorule-mod_001() {

rlPhaseStartTest "sudorule-mod_001: ipa help sudorule-mod"

	rlRun "ipa help sudorule-mod > $TmpDir/sudorule-mod_001.txt 2>&1"
	rlAssertGrep "Purpose: Modify Sudo Rule." "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-mod SUDORULE-NAME \[options\]" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\-h, \--help            show this help message and exit" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--desc=STR            Description" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--usercat=\['all'\]     User category the rule applies to" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--hostcat=\['all'\]     Host category the rule applies to" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--cmdcat=\['all'\]      Command category the rule applies to" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--runasusercat=\['all'\]" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "RunAs User category the rule applies to" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--runasgroupcat=\['all'\]" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "RunAs Group category the rule applies to" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--externaluser=STR    External User the rule applies to (sudorule-find only)" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--runasexternaluser=STR" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "External User the commands can run as (sudorule-find" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--runasexternalgroup=STR" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "External Group the commands can run as (sudorule-find" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--addattr=STR         Add an attribute/value pair. Format is attr=value." "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--setattr=STR         Set an attribute to a name/value pair." "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--rights              Display the access rights of this entry" "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--all                 Retrieve and print all attributes from the server." "$TmpDir/sudorule-mod_001.txt"
	rlAssertGrep "\--raw                 Print entries as stored on the server." "$TmpDir/sudorule-mod_001.txt"
	rlRun "cat $TmpDir/sudorule-mod_001.txt"

rlPhaseEnd
}


sudorule-mod_002() {

rlPhaseStartTest "sudorule-mod_002: ipa sudorule-mod --desc"

	rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"

	rlRun "ipa sudorule-mod rule1 --desc=\"sudorule rule 1\" > $TmpDir/sudorule-mod_002.txt 2>&1"
	rlAssertGrep "Description: sudorule rule 1" "$TmpDir/sudorule-mod_002.txt"
	rlRun "ipa sudorule-find rule1 --all --raw | grep \"description: sudorule rule 1\""

	rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}

sudorule-mod_003() {

rlPhaseStartTest "sudorule-mod_003: ipa sudorule-mod --usercat"

        rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"

	rlRun "ipa sudorule-mod rule1 --usercat=all > $TmpDir/sudorule-mod_003.txt 2>&1"
	rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-mod_003.txt"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-mod_003.txt"
        rlAssertGrep "User category: all" "$TmpDir/sudorule-mod_003.txt"
	rlRun "cat $TmpDir/sudorule-mod_003.txt"

        rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}

sudorule-mod_004() {

rlPhaseStartTest "sudorule-mod_004: ipa sudorule-mod --hostcat"

        rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"

	rlRun "ipa sudorule-mod rule1 --hostcat=all > $TmpDir/sudorule-mod_004.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-mod_004.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-mod_004.txt"
        rlAssertGrep "Host category: all" "$TmpDir/sudorule-mod_004.txt"
        rlRun "cat $TmpDir/sudorule-mod_004.txt"

        rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}

sudorule-mod_005() {

rlPhaseStartTest "sudorule-mod_005: ipa sudorule-mod --cmdcat"

        rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"

        rlRun "ipa sudorule-mod rule1 --hostcat=all > $TmpDir/sudorule-mod_005.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-mod_005.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-mod_005.txt"
        rlAssertGrep "Host category: all" "$TmpDir/sudorule-mod_005.txt"
        rlRun "cat $TmpDir/sudorule-mod_005.txt"

        rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}

sudorule-mod_006() {

rlPhaseStartTest "sudorule-mod_006: ipa sudorule-mod --runasusercat"

        rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"

        rlRun "ipa sudorule-mod rule1 --runasusercat=all > $TmpDir/sudorule-mod_006.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-mod_006.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-mod_006.txt"
        rlAssertGrep "RunAs User category: all" "$TmpDir/sudorule-mod_006.txt"
        rlRun "cat $TmpDir/sudorule-mod_006.txt"

        rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}

sudorule-mod_007() {

rlPhaseStartTest "sudorule-mod_007: ipa sudorule-mod --runasgroupcat"

        rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"

        rlRun "ipa sudorule-mod rule1 --runasusercat=all > $TmpDir/sudorule-mod_007.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-mod_007.txt"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/sudorule-mod_007.txt"
        rlAssertGrep "RunAs User category: all" "$TmpDir/sudorule-mod_007.txt"
        rlRun "cat $TmpDir/sudorule-mod_007.txt"

        rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}

sudorule-mod_008() {

rlPhaseStartTest "sudorule-mod_008: ipa sudorule-mod --externaluser"

# The following comments are because of https://fedorahosted.org/freeipa/ticket/1320
# In short: --externaluser option is depricated.

        rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"

	rlRun "ipa sudorule-mod rule1 --externaluser=test1,test2 > $TmpDir/sudorule-mod_008.txt 2>&1" 1
	rlAssertGrep "ipa: ERROR: invalid 'externaluser': this option has been deprecated." "$TmpDir/sudorule-mod_008.txt"
#	rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-mod_008.txt"
#	rlAssertGrep "External User: test1,test2" "$TmpDir/sudorule-mod_008.txt"
	rlRun "cat $TmpDir/sudorule-mod_008.txt"

	rlLog "https://bugzilla.redhat.com/show_bug.cgi?id=713069"
#	rlRun "ipa sudorule-find rule1 --all --raw > $TmpDir/sudorule-mod_008.txt 2>&1"
#	rlAssertGrep "externaluser: test1" "$TmpDir/sudorule-mod_008.txt"
#	rlAssertGrep "externaluser: test2" "$TmpDir/sudorule-mod_008.txt"
	rlRun "cat $TmpDir/sudorule-mod_008.txt"

        rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}


sudorule-mod_009() {

rlPhaseStartTest "sudorule-mod_009: ipa sudorule-mod --runasexternaluser"

# The following comments are because of https://fedorahosted.org/freeipa/ticket/1320
# In short: --externaluser option is depricated.

        rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"
	rlRun "ipa sudorule-add-runasuser rule1 --users=extuser1,extuser2,extuser3"
	rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextuser: extuser1\""
	rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextuser: extuser2\""
	rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextuser: extuser3\""

	rlRun "ipa sudorule-mod rule1 --runasexternaluser=extuser2,extuser3,extuser4 > $TmpDir/sudorule-mod_009.txt 2>&1" 1
	rlAssertGrep "ipa: ERROR: invalid 'runasexternaluser': this option has been deprecated." "$TmpDir/sudorule-mod_009.txt"
	
	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=711667"
#	 rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextuser: extuser2\""
#        rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextuser: extuser3\""
#        rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextuser: extuser4\""

	rlRun "ipa sudorule-find rule1 --runasexternaluser=extuser1"
	rlRun "ipa sudorule-find rule1 --runasexternaluser=extuser2"
	rlRun "ipa sudorule-find rule1 --runasexternaluser=extuser3"

        rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}


sudorule-mod_010() {

rlPhaseStartTest "sudorule-mod_010: ipa sudorule-mod --runasexternalgroup"

# The following comments are because of https://fedorahosted.org/freeipa/ticket/1320
# In short: --externaluser option is depricated.

        rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"
        rlRun "ipa sudorule-add-runasgroup rule1 --groups=extgrp1,extgrp2,extgrp3"
        rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextgroup: extgrp1\""
        rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextgroup: extgrp2\""
        rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextgroup: extgrp3\""
        rlRun "ipa sudorule-find rule1 --all --raw"

        rlRun "ipa sudorule-mod rule1 --runasexternalgroup=extgrp2,extgrp3,extgrp4 > $TmpDir/sudorule-mod_010.txt 2>&1" 1
	rlAssertGrep "ipa: ERROR: invalid 'runasexternalgroup': this option has been deprecated." "$TmpDir/sudorule-mod_010.txt"

	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=711671"
#        rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextgroup: extgrp2\""
#        rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextgroup: extgrp3\""
#        rlRun "ipa sudorule-find rule1 --all --raw | grep \"ipasudorunasextgroup: extgrp4\""

	rlRun "ipa sudorule-find rule1 --runasexternalgroup=extgrp1"
        rlRun "ipa sudorule-find rule1 --runasexternalgroup=extgrp2"
        rlRun "ipa sudorule-find rule1 --runasexternalgroup=extgrp3"

        rlRun "ipa sudorule-find rule1 --all --raw"

        rlRun "ipa sudorule-del rule1"
        
rlPhaseEnd
}

sudorule-mod_011() {

rlPhaseStartTest "sudorule-mod_011: ipa sudorule-mod --setattr"

# The following comments are because of https://fedorahosted.org/freeipa/ticket/1320
# In short: --externaluser option is depricated.

        rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"

	rlRun "ipa sudorule-add-user rule1 --users=test1"
	#rlRun "ipa sudorule-mod rule1 --setattr=externaluser=test2 > $TmpDir/sudorule-mod_011.txt 2>&1" 1

	verifyErrorMsg "ipa sudorule-mod rule1 --setattr=externaluser=test2" "ipa: ERROR: invalid 'externaluser': this option has been deprecated."

#	rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-mod_011.txt"
#	rlAssertGrep "External User: test2" "$TmpDir/sudorule-mod_011.txt"
	#rlAssertGrep "ipa: ERROR: invalid 'externaluser': this option has been deprecated." "$TmpDir/sudorule-mod_011.txt"
	#rlRun "cat $TmpDir/sudorule-mod_011.txt"

#	rlRun "ipa sudorule-find rule1 --all --raw > $TmpDir/sudorule-mod_011.txt 2>&1"
#	rlAssertGrep "externaluser: test2" "$TmpDir/sudorule-mod_011.txt"
#	rlRun "cat $TmpDir/sudorule-mod_011.txt"

        rlRun "ipa sudorule-del rule1"

rlPhaseEnd
}


sudorule-mod_012() {

rlPhaseStartTest "sudorule-mod_012: ipa sudorule-mod --addattr"

        rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"
  	rlRun "ipa user-add sudorule11 --first=sudo --last=rule11"

 	rlRun "ipa sudorule-mod rule1 --addattr=\"memberuser=uid=sudorule11,cn=users,cn=accounts,$basedn\" > $TmpDir/sudorule-mod_012.txt 2>&1" 
	rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-mod_012.txt"
	rlAssertGrep "Users: sudorule11" "$TmpDir/sudorule-mod_012.txt"
	rlRun "cat $TmpDir/sudorule-mod_012.txt"

	rlRun "ipa sudorule-find rule1 --all --raw > $TmpDir/sudorule-mod_012.txt 2>&1"
	rlAssertGrep " memberuser: uid=sudorule11,cn=users,cn=accounts,$basedn" "$TmpDir/sudorule-mod_012.txt"
	rlRun "cat $TmpDir/sudorule-mod_012.txt"

        rlRun "ipa sudorule-del rule1"
	rlRun "ipa user-del sudorule11"

rlPhaseEnd
}

sudorule-mod_013() {

rlPhaseStartTest "sudorule-mod_013: ipa sudorule-mod --rights --all"

        rlRun "ipa sudorule-add --desc=\"rule 1\" rule1"
	rlRun "ipa user-add sudorule11 --first=sudo --last=rule11"

        rlRun "ipa sudorule-mod rule1 --addattr=\"memberuser=uid=sudorule11,cn=users,cn=accounts,$basedn\" --rights --all > $TmpDir/sudorule-mod_013.txt 2>&1"
        rlAssertGrep "Rule name: rule1" "$TmpDir/sudorule-mod_013.txt"
        rlAssertGrep "Users: sudorule11" "$TmpDir/sudorule-mod_013.txt"
        rlAssertGrep "attributelevelrights: {'sudonotafter': u'rscwo', 'cn': u'rscwo', 'hostmask': u'rscwo', 'memberuser': u'rscwo', 'memberallowcmd': u'rscwo', 'sudonotbefore': u'rscwo', 'ipasudorunas': u'rscwo', 'cmdcategory': u'rscwo', 'ipasudoopt': u'rscwo', 'nsaccountlock': u'rscwo', 'ipasudorunasextuser': u'rscwo', 'externaluser': u'rscwo', 'memberhost': u'rscwo', 'description': u'rscwo', 'externalhost': u'rscwo', 'hostcategory': u'rscwo', 'ipauniqueid': u'rsc', 'ipaenabledflag': u'rscwo', 'ipasudorunasgroup': u'rscwo', 'sudoorder': u'rscwo', 'ipasudorunasgroupcategory': u'rscwo', 'ipasudorunasextgroup': u'rscwo', 'aci': u'rscwo', 'memberdenycmd': u'rscwo', 'usercategory': u'rscwo', 'ipasudorunasusercategory': u'rscwo'}" "$TmpDir/sudorule-mod_013.txt"
        rlRun "cat $TmpDir/sudorule-mod_013.txt"

        rlRun "ipa sudorule-del rule1"
        rlRun "ipa user-del sudorule11"

rlPhaseEnd
}

sudorule-find_001() {

rlPhaseStartTest "sudorule-find_001: ipa help sudorule-find"

        rlRun "ipa help sudorule-find > $TmpDir/sudorule-find_001.txt 2>&1"
        rlAssertGrep "Purpose: Search for Sudo Rule." "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "Usage: ipa \[global-options\] sudorule-find \[CRITERIA\] \[options\]" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\-h, \--help            show this help message and exit" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--sudorule-name=STR   Rule name" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--desc=STR            Description" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--usercat=\['all'\]     User category the rule applies to" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--hostcat=\['all'\]     Host category the rule applies to" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--runasusercat=\['all'\]" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "RunAs User category the rule applies to" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--runasgroupcat=\['all'\]" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "RunAs Group category the rule applies to" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--externaluser=STR    External User the rule applies to" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--runasexternaluser=STR" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "External User the commands can run as" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--runasexternalgroup=STR" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "External Group the commands can run as" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--timelimit=INT       Time limit of search in seconds" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--sizelimit=INT       Maximum number of entries returned" "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--all                 Retrieve and print all attributes from the server." "$TmpDir/sudorule-find_001.txt"
        rlAssertGrep "\--raw                 Print entries as stored on the server." "$TmpDir/sudorule-find_001.txt"
        rlRun "cat $TmpDir/sudorule-find_001.txt"

rlPhaseEnd
}

sudorule-find_002() {

rlPhaseStartTest "sudorule-find_002: ipa sudorule-find --sudorule-name"

	rlRun "ipa sudorule-add --desc=\"sudo rule1\" sudorule1"
	rlRun "ipa sudorule-find --sudorule-name=sudorule1 > $TmpDir/sudorule-find_002.txt 2>&1"
	rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_002.txt"
	rlRun "cat $TmpDir/sudorule-find_002.txt"
	rlRun "ipa sudorule-del sudorule1"

rlPhaseEnd
}

sudorule-find_003() {

rlPhaseStartTest "sudorule-find_003: ipa sudorule-find --desc"

	rlRun "ipa sudorule-add --desc=\"sudo rule9\" sudorule9"
	rlRun "ipa sudorule-add --desc=\"sudo rule10\" sudorule10"

	rlRun "ipa sudorule-find --desc=\"sudo rule9\" > $TmpDir/sudorule-find_003.txt 2>&1"
        rlAssertGrep "Rule name: sudorule9" "$TmpDir/sudorule-find_003.txt"
	rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_003.txt"
        rlRun "cat $TmpDir/sudorule-find_003.txt"

	rlRun "ipa sudorule-del  sudorule9"
	rlRun "ipa sudorule-del  sudorule10"
rlPhaseEnd
}

sudorule-find_004() {
 
rlPhaseStartTest "sudorule-find_004: ipa sudorule-find --usercat"
 
        rlRun "ipa sudorule-add sudorule1"
        rlRun "ipa sudorule-add sudorule2"
        rlRun "ipa sudorule-mod sudorule1 --usercat=all"
 
        rlRun "ipa sudorule-find --usercat=all > $TmpDir/sudorule-find_004.txt 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_004.txt"
        rlRun "cat $TmpDir/sudorule-find_004.txt"
 
        rlRun "ipa sudorule-find --usercat=all --all > $TmpDir/sudorule-find_004.txt"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-find_004.txt"
        rlAssertGrep "User category: all" "$TmpDir/sudorule-find_004.txt"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_004.txt"
        rlRun "cat $TmpDir/sudorule-find_004.txt"
 
        rlRun "ipa sudorule-del  sudorule1"
        rlRun "ipa sudorule-del  sudorule2"
rlPhaseEnd
}



sudorule-find_005() {
 
rlPhaseStartTest "sudorule-find_005: ipa sudorule-find --hostcat"
 
        rlRun "ipa sudorule-add sudorule1"
        rlRun "ipa sudorule-add sudorule2"
        rlRun "ipa sudorule-mod sudorule1 --hostcat=all"
 
        rlRun "ipa sudorule-find --hostcat=all > $TmpDir/sudorule-find_005.txt 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_005.txt"
        rlRun "cat $TmpDir/sudorule-find_005.txt"
 
        rlRun "ipa sudorule-find --hostcat=all --all > $TmpDir/sudorule-find_005.txt"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-find_005.txt"
        rlAssertGrep "Host category: all" "$TmpDir/sudorule-find_005.txt"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_005.txt"
        rlRun "cat $TmpDir/sudorule-find_005.txt"
 
        rlRun "ipa sudorule-del  sudorule1"
        rlRun "ipa sudorule-del  sudorule2"
rlPhaseEnd
}


sudorule-find_006() {
 
rlPhaseStartTest "sudorule-find_006: ipa sudorule-find --cmdcat"
 
        rlRun "ipa sudorule-add sudorule1"
        rlRun "ipa sudorule-add sudorule2"
        rlRun "ipa sudorule-mod sudorule1 --cmdcat=all"
 
        rlRun "ipa sudorule-find --cmdcat=all > $TmpDir/sudorule-find_006.txt 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_006.txt"
        rlRun "cat $TmpDir/sudorule-find_006.txt"
 
        rlRun "ipa sudorule-find sudorule1 --all > $TmpDir/sudorule-find_006.txt"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-find_006.txt"
        rlAssertGrep "Command category: all" "$TmpDir/sudorule-find_006.txt"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_006.txt"
        rlRun "cat $TmpDir/sudorule-find_006.txt"
 
        rlRun "ipa sudorule-del  sudorule1"
        rlRun "ipa sudorule-del  sudorule2"
rlPhaseEnd
}


sudorule-find_007() {
 
rlPhaseStartTest "sudorule-find_007: ipa sudorule-find --runasusercat"
 
        rlRun "ipa sudorule-add sudorule1"
        rlRun "ipa sudorule-add sudorule2"
        rlRun "ipa sudorule-mod sudorule1 --runasusercat=all"
 
        rlRun "ipa sudorule-find --runasusercat=all > $TmpDir/sudorule-find_007.txt 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_007.txt"
        rlRun "cat $TmpDir/sudorule-find_007.txt"
 
        rlRun "ipa sudorule-find --runasusercat=all --all > $TmpDir/sudorule-find_007.txt"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-find_007.txt"
        rlAssertGrep "RunAs User category: all" "$TmpDir/sudorule-find_007.txt"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_007.txt"
        rlRun "cat $TmpDir/sudorule-find_007.txt"
 
        rlRun "ipa sudorule-del  sudorule1"
        rlRun "ipa sudorule-del  sudorule2"
rlPhaseEnd
}

sudorule-find_008() {
 
rlPhaseStartTest "sudorule-find_008: ipa sudorule-find --runasgroupcat"
 
        rlRun "ipa sudorule-add sudorule1"
        rlRun "ipa sudorule-add sudorule2"
        rlRun "ipa sudorule-mod sudorule1 --runasgroupcat=all"
 
        rlRun "ipa sudorule-find --runasgroupcat=all > $TmpDir/sudorule-find_008.txt 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_008.txt"
        rlRun "cat $TmpDir/sudorule-find_008.txt"
 
        rlRun "ipa sudorule-find --runasgroupcat=all --all > $TmpDir/sudorule-find_008.txt"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-find_008.txt"
        rlAssertGrep "RunAs Group category: all" "$TmpDir/sudorule-find_008.txt"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_008.txt"
        rlRun "cat $TmpDir/sudorule-find_008.txt"
 
        rlRun "ipa sudorule-del  sudorule1"
        rlRun "ipa sudorule-del  sudorule2"
rlPhaseEnd
}


sudorule-find_009() {
 
rlPhaseStartTest "sudorule-find_009: ipa sudorule-find --externaluser"
 
        rlRun "ipa sudorule-add sudorule1"
        rlRun "ipa sudorule-add sudorule2"
        rlRun "ipa sudorule-add-user sudorule1 --users=testinguser1,testinguser2"
 
        rlRun "ipa sudorule-find --externaluser=testinguser1 > $TmpDir/sudorule-find_009.txt 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_009.txt"
        rlRun "cat $TmpDir/sudorule-find_009.txt"
 
        rlRun "ipa sudorule-find --externaluser=testinguser2 > $TmpDir/sudorule-find_009.txt 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_009.txt"
        rlRun "cat $TmpDir/sudorule-find_009.txt"
 
        rlRun "ipa sudorule-find --externaluser=testinguser1 --all > $TmpDir/sudorule-find_009.txt"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-find_009.txt"
        rlAssertGrep "External User: testinguser2, testinguser1" "$TmpDir/sudorule-find_009.txt"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_009.txt"
        rlRun "cat $TmpDir/sudorule-find_009.txt"
 
        rlRun "ipa sudorule-del  sudorule1"
        rlRun "ipa sudorule-del  sudorule2"
 
rlPhaseEnd
}


sudorule-find_010() {
 
rlPhaseStartTest "sudorule-find_010: ipa sudorule-find --runasexternaluser"
 
        rlRun "ipa sudorule-add sudorule1"
        rlRun "ipa sudorule-add sudorule2"
        rlRun "ipa sudorule-add-runasuser sudorule1 --users=testinguser3,testinguser4"
 
        rlRun "ipa sudorule-find --runasexternaluser=testinguser3 > $TmpDir/sudorule-find_010.txt 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_010.txt"
        rlRun "cat $TmpDir/sudorule-find_010.txt"
 
        rlRun "ipa sudorule-find --runasexternaluser=testinguser4 > $TmpDir/sudorule-find_010.txt 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_010.txt"
        rlRun "cat $TmpDir/sudorule-find_010.txt"
 
        rlRun "ipa sudorule-find --runasexternaluser=testinguser3 --all > $TmpDir/sudorule-find_010.txt"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-find_010.txt"
        rlAssertGrep "RunAs External User: testinguser3, testinguser4" "$TmpDir/sudorule-find_010.txt"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_010.txt"
        rlRun "cat $TmpDir/sudorule-find_010.txt"
 
        rlRun "ipa sudorule-del  sudorule1"
        rlRun "ipa sudorule-del  sudorule2"
 
rlPhaseEnd
}


sudorule-find_011() {
 
rlPhaseStartTest "sudorule-find_011: ipa sudorule-find --runasexternalgroup"
 
        rlRun "ipa sudorule-add sudorule1"
        rlRun "ipa sudorule-add sudorule2"
        rlRun "ipa sudorule-add-runasgroup sudorule1 --groups=testinggroup3,testinggroup4"
 
        rlRun "ipa sudorule-find --runasexternalgroup=testinggroup3 > $TmpDir/sudorule-find_011.txt 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_011.txt"
        rlRun "cat $TmpDir/sudorule-find_011.txt"
 
        rlRun "ipa sudorule-find --runasexternalgroup=testinggroup4 > $TmpDir/sudorule-find_011.txt 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_011.txt"
        rlRun "cat $TmpDir/sudorule-find_011.txt"
 
        rlRun "ipa sudorule-find --runasexternalgroup=testinggroup3 --all > $TmpDir/sudorule-find_011.txt"
        rlAssertGrep "Rule name: sudorule1" "$TmpDir/sudorule-find_011.txt"
        rlAssertGrep "RunAs External Group: testinggroup3, testinggroup4" "$TmpDir/sudorule-find_011.txt"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_011.txt"
        rlRun "cat $TmpDir/sudorule-find_011.txt"
 
        rlRun "ipa sudorule-del  sudorule1"
        rlRun "ipa sudorule-del  sudorule2"
 
rlPhaseEnd
}

sudorule-find_012() {
# The output of sudorule-find with --timelimit option is inconsistent to be included in
# automation.
 
rlPhaseStartTest "sudorule-find_012: ipa sudorule-find --timelimit"
 
        rlRun "ipa sudorule-add sudorule1"
        rlRun "ipa sudorule-add sudorule2"
 
 
 
 
 
 
        rlRun "ipa sudorule-del  sudorule1"
        rlRun "ipa sudorule-del  sudorule2"
 
rlPhaseEnd
}


sudorule-find_013() {

rlPhaseStartTest "sudorule-find_013: ipa sudorule-find --sizelimit"

        rlRun "ipa sudorule-add sudorule1"
        rlRun "ipa sudorule-add sudorule2"
        rlRun "ipa sudorule-add sudorule3"
        rlRun "ipa sudorule-add sudorule4"
        rlRun "ipa sudorule-add sudorule5"


	rlRun "ipa sudorule-find --sizelimit=1 > $TmpDir/sudorule-find_013.txt 2>&1"
	rlAssertGrep "Number of entries returned 1" "$TmpDir/sudorule-find_013.txt"
	rlRun "cat $TmpDir/sudorule-find_013.txt"

        rlRun "ipa sudorule-find --sizelimit=2 > $TmpDir/sudorule-find_013.txt 2>&1"
        rlAssertGrep "Number of entries returned 2" "$TmpDir/sudorule-find_013.txt"
        rlRun "cat $TmpDir/sudorule-find_013.txt"

        rlRun "ipa sudorule-find --sizelimit=4 > $TmpDir/sudorule-find_013.txt 2>&1"
        rlAssertGrep "Number of entries returned 4" "$TmpDir/sudorule-find_013.txt"
        rlRun "cat $TmpDir/sudorule-find_013.txt"

        rlRun "ipa sudorule-find --sizelimit=5 > $TmpDir/sudorule-find_013.txt 2>&1"
        rlAssertGrep "Number of entries returned 5" "$TmpDir/sudorule-find_013.txt"
        rlRun "cat $TmpDir/sudorule-find_013.txt"

        rlRun "ipa sudorule-del  sudorule1"
        rlRun "ipa sudorule-del  sudorule2"
        rlRun "ipa sudorule-del  sudorule3"
        rlRun "ipa sudorule-del  sudorule4"
        rlRun "ipa sudorule-del  sudorule5"

rlPhaseEnd
}

sudorule-find_014() {
rlPhaseStartTest "sudorule-find_014: --pkey-only test of sudorule"
	ipa_command_to_test="sudorule"
	pkey_addstringa=""
	pkey_addstringb=""
	pkeyobja="sudorule1"
	pkeyobjb="sudorule2"
	grep_string='Rule\ name'
	general_search_string=sudorule
	rlRun "pkey_return_check" 0 "running checks of --pkey-only in sudorule-find"
    rlPhaseEnd

}
sudorule_del_001() {

rlPhaseStartTest "sudorule_del_001: ipa help sudodel"

	rlRun "ipa help sudorule-del > $TmpDir/sudorule_del_001.txt 2>&1"
	rlAssertGrep "Purpose: Delete Sudo Rule." "$TmpDir/sudorule_del_001.txt"
	rlAssertGrep "Usage: ipa \[global-options\] sudorule-del SUDORULE-NAME... \[options\]" "$TmpDir/sudorule_del_001.txt"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/sudorule_del_001.txt"
	rlAssertGrep "\--continue  Continuous mode: Don't stop on errors." "$TmpDir/sudorule_del_001.txt"
	rlRun "cat $TmpDir/sudorule_del_001.txt"

rlPhaseEnd
}

sudorule_del_002() {

rlPhaseStartTest "sudorule_del_002: Del new sudo rule."

	rlRun "ipa sudorule-add sudorule1"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa sudorule-del sudorule1"
	rlRun "sleep 10"
	rlRun "/usr/bin/ldapsearch -x -h localhost -D \"cn=Directory Manager\" -w Secret123 -b cn=sudorule1,ou=sudoers,$basedn" 32

rlPhaseEnd
}


sudorule_del_003() {

rlPhaseStartTest "sudorule_del_003: Del sudo rule with --continue option."

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa sudorule-add sudorule2"
	rlRun "ipa sudorule-del invalidrule sudorule2 > $TmpDir/sudorule_del_003.txt 2>&1" 2
	rlAssertGrep "ipa: ERROR: invalidrule: Sudo Rule not found" "$TmpDir/sudorule_del_003.txt" -i
	rlRun "cat $TmpDir/sudorule_del_003.txt"
	rlRun "ipa sudorule-find sudorule2"
	rlRun "ipa sudorule-del invalidrule sudorule2 --continue > $TmpDir/sudorule_del_003.txt 2>&1"
	rlAssertGrep "Failed to remove: invalidrule" "$TmpDir/sudorule_del_003.txt" -i
	rlRun "ipa sudorule-find sudorule2" 1
	rlRun "cat $TmpDir/sudorule_del_003.txt"

rlPhaseEnd
}



cleanup() {
rlPhaseStartTest "Clean up for sudo sanity tests"

	rlRun "kinitAs $ADMINID $ADMINPW" 0
	rlRun "ipa user-del $user1"
	sleep 5
	rlRun "ipa user-del $user2"
	rlRun "rm -fr /tmp/krb5cc_*_*"
	rlRun "ipa sudocmd-find" 1
	rlRun "ipa sudocmdgroup-find" 1
	rlRun "ipa sudorule-find" 1
	rlRun "kdestroy" 0 "Destroying admin credentials."

	# disabling NIS
	#rlRun "echo -n Secret123 > $TmpDir/passwd.txt"
	#rlRun "ipa-nis-manage -y $TmpDir/passwd.txt disable"
	#rlRun "ipactl restart"

        #rlRun "popd"
        #rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
rlPhaseEnd
}


