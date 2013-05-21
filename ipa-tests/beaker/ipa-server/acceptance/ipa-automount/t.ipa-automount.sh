#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-automount
#   Description: automount configuration tests for autofs
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  automountkey-add           Create a new automount key.
#  automountkey-del           Delete an automount key.
#  automountkey-find          Search for an automount key.
#  automountkey-mod           Modify an automount key.
#  automountkey-show          Display an automount key.
#  automountlocation-add      Create a new automount location.
#  automountlocation-del      Delete an automount location.
#  automountlocation-find     Search for an automount location.
#  automountlocation-import   Import automount files for a specific location. 
	# No sanity tests for automountlocation-import.
#  automountlocation-show     Display an automount location.
#  automountlocation-tofiles  Generate automount files for a specific location.
	# No sanity tests for automountlocation-tofiles.
#  automountmap-add           Create a new automount map.
#  automountmap-add-indirect  Create a new indirect mount point.
#  automountmap-del           Delete an automount map.
#  automountmap-find          Search for an automount map.
#  automountmap-mod           Modify an automount map.
#  automountmap-show          Display an automount map.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
#   Date: Mon May  9 20:56:29 IST 2011 (Initial check-in)
#   Date: Mon Jul 18 05:15:51 EDT 2011 
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
mount_homedir="/ipahome"
direct_mount="/direct_mount"
#RELM="RHTS-ENG-BRQ-REDHAT-COM"
basedn=`getBaseDN`

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"

setup() {
rlPhaseStartSetup "Setup for automount configuration tests"
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
rlPhaseEnd
}

automount_001() {

rlPhaseStartTest "ipa-automount-001: Schema file check."
	INSTANCE=`echo $RELM | sed 's/\./-/g'`
	SCHEMAFILE="/etc/dirsrv/slapd-$INSTANCE/schema/60autofs.ldif"
	rlLog "Schema file :: $SCHEMAFILE"
	rlRun "rlAssertExists $SCHEMAFILE"

rlPhaseEnd
}

automount_002() {

rlPhaseStartTest "ipa-automount-002: ipa help automount."

	rlRun "ipa help automount > $TmpDir/automount_002.out 2>&1"
	rlAssertGrep "Create a named location, \"Baltimore\":" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountlocation-add baltimore" "$TmpDir/automount_002.out"
	rlAssertGrep "Display the new location:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountlocation-show baltimore" "$TmpDir/automount_002.out"
	rlAssertGrep "Find available locations:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountlocation-find" "$TmpDir/automount_002.out"
	rlAssertGrep "Remove a named automount location:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountlocation-del baltimore" "$TmpDir/automount_002.out"
	rlAssertGrep "Show what the automount maps would look like if they were in the filesystem:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountlocation-tofiles baltimore" "$TmpDir/automount_002.out"
	rlAssertGrep "Import an existing configuration into a location:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountlocation-import baltimore /etc/auto.master" "$TmpDir/automount_002.out"
	rlAssertGrep "Create a new map, \"auto.share\":" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountmap-add baltimore auto.share" "$TmpDir/automount_002.out"
	rlAssertGrep "Display the new map:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountmap-show baltimore auto.share" "$TmpDir/automount_002.out"
	rlAssertGrep "Find maps in the location baltimore:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountmap-find baltimore" "$TmpDir/automount_002.out"
	rlAssertGrep "Remove the auto.share map:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountmap-del baltimore auto.share" "$TmpDir/automount_002.out"
	rlAssertGrep "Create a new key for the auto.share map in location baltimore." "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountkey-add baltimore auto.master --key=/share --info=auto.share" "$TmpDir/automount_002.out"
	rlAssertGrep "Create a new key for our auto.share map, an NFS mount for man pages:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountkey-add baltimore auto.share --key=man --info=\"-ro,soft,rsize=8192,wsize=8192 ipa.example.com:/shared/man\"" "$TmpDir/automount_002.out"
	rlAssertGrep "Find all keys for the auto.share map:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountkey-find baltimore auto.share" "$TmpDir/automount_002.out"
	rlAssertGrep "Find all direct automount keys:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountkey-find baltimore --key=/-" "$TmpDir/automount_002.out"
	rlAssertGrep "Remove the man key from the auto.share map:" "$TmpDir/automount_002.out"
	rlAssertGrep "ipa automountkey-del baltimore auto.share --key=man" "$TmpDir/automount_002.out"
	rlAssertGrep "automountkey-add           Create a new automount key." "$TmpDir/automount_002.out"
	rlAssertGrep "automountkey-del           Delete an automount key." "$TmpDir/automount_002.out"
	rlAssertGrep "automountkey-find          Search for an automount key." "$TmpDir/automount_002.out"
	rlAssertGrep "automountkey-mod           Modify an automount key." "$TmpDir/automount_002.out"
	rlAssertGrep "automountkey-show          Display an automount key." "$TmpDir/automount_002.out"
	rlAssertGrep "automountlocation-add      Create a new automount location." "$TmpDir/automount_002.out"
	rlAssertGrep "automountlocation-find     Search for an automount location." "$TmpDir/automount_002.out"
	rlAssertGrep "automountlocation-import   Import automount files for a specific location." "$TmpDir/automount_002.out"
	rlAssertGrep "automountlocation-show     Display an automount location." "$TmpDir/automount_002.out"
	rlAssertGrep "automountlocation-tofiles  Generate automount files for a specific location." "$TmpDir/automount_002.out"
	rlAssertGrep "automountmap-add           Create a new automount map." "$TmpDir/automount_002.out"
	rlAssertGrep "automountmap-add-indirect  Create a new indirect mount point." "$TmpDir/automount_002.out"
	rlAssertGrep "automountmap-del           Delete an automount map." "$TmpDir/automount_002.out"
	rlAssertGrep "automountmap-find          Search for an automount map." "$TmpDir/automount_002.out"
	rlAssertGrep "automountmap-mod           Modify an automount map." "$TmpDir/automount_002.out"
	rlAssertGrep "automountmap-show          Display an automount map." "$TmpDir/automount_002.out"

	rlRun "cat $TmpDir/automount_002.out"

rlPhaseEnd
}

automount_003() {

rlPhaseStartTest "ipa-automount-003: help automountkey-add"

	rlRun "ipa help automountkey-add > $TmpDir/automount_003.out"

	rlAssertGrep "Purpose: Create a new automount key." "$TmpDir/automount_003.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountkey-add AUTOMOUNTLOCATION AUTOMOUNTMAP \[options\]" "$TmpDir/automount_003.out"
	rlAssertGrep "\-h, \--help     show this help message and exit" "$TmpDir/automount_003.out"
	rlAssertGrep "\--key=IA5STR   Automount key name." "$TmpDir/automount_003.out"
	rlAssertGrep "\--info=IA5STR  Mount information" "$TmpDir/automount_003.out"
	rlAssertGrep "\--addattr=STR  Add an attribute/value pair. Format is attr=value." "$TmpDir/automount_003.out"
	rlAssertGrep "\--setattr=STR  Set an attribute to a name/value pair. Format is attr=value." "$TmpDir/automount_003.out"
	rlAssertGrep "\--all          Retrieve and print all attributes from the server." "$TmpDir/automount_003.out"
	rlAssertGrep "\--raw          Print entries as stored on the server." "$TmpDir/automount_003.out"

	rlRun "cat $TmpDir/automount_003.out"

rlPhaseEnd
}

automount_004() {

rlPhaseStartTest "ipa-automount-004: ipa help automountkey-del"

        rlRun "ipa help automountkey-del > $TmpDir/automount_004.out"

        rlAssertGrep "Usage: ipa \[global-options\] automountkey-del AUTOMOUNTLOCATION AUTOMOUNTMAP \[options\]" "$TmpDir/automount_004.out"
        rlAssertGrep "\-h, \--help     show this help message and exit" "$TmpDir/automount_004.out"
	rlLog "Verifies https://bugzilla.redhat.com/show_bug.cgi?id=726123"
        rlAssertNotGrep "\--continue     Continuous mode: Don't stop on errors." "$TmpDir/automount_004.out"
        rlAssertGrep "\--key=IA5STR   Automount key name." "$TmpDir/automount_004.out"
        rlAssertGrep "\--info=IA5STR  Mount information" "$TmpDir/automount_004.out"

	rlRun "cat $TmpDir/automount_004.out"

rlPhaseEnd
}

automount_005() {

rlPhaseStartTest "ipa-automount-005: ipa help automountkey-find"

	rlRun "ipa help automountkey-find > $TmpDir/automount_005.out"

	rlAssertGrep "Purpose: Search for an automount key." "$TmpDir/automount_005.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountkey-find AUTOMOUNTLOCATION AUTOMOUNTMAP \[CRITERIA\] \[options\]" "$TmpDir/automount_005.out"
	rlAssertGrep "\-h, \--help       show this help message and exit" "$TmpDir/automount_005.out"
	rlAssertGrep "\--key=IA5STR     Automount key name." "$TmpDir/automount_005.out"
	rlAssertGrep "\--info=IA5STR    Mount information" "$TmpDir/automount_005.out"
	rlAssertGrep "\--timelimit=INT  Time limit of search in seconds" "$TmpDir/automount_005.out"
	rlAssertGrep "\--sizelimit=INT  Maximum number of entries returned" "$TmpDir/automount_005.out"
	rlAssertGrep "\--all            Retrieve and print all attributes from the server." "$TmpDir/automount_005.out"
	rlAssertGrep "\--raw            Print entries as stored on the server." "$TmpDir/automount_005.out"

	rlRun "cat $TmpDir/automount_005.out"

rlPhaseEnd
}

automount_006() {

rlPhaseStartTest "ipa-automount-006: ipa help automountkey-mod"

	rlRun "ipa help automountkey-mod > $TmpDir/automount_006.out 2>&1"

	rlAssertGrep "Purpose: Modify an automount key." "$TmpDir/automount_006.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountkey-mod AUTOMOUNTLOCATION AUTOMOUNTMAP \[options\]" "$TmpDir/automount_006.out"
	rlAssertGrep "\-h, \--help        show this help message and exit" "$TmpDir/automount_006.out"
	rlAssertGrep "\--key=IA5STR      Automount key name." "$TmpDir/automount_006.out"
	rlAssertGrep "\--info=IA5STR     Mount information" "$TmpDir/automount_006.out"
	rlAssertGrep "\--addattr=STR     Add an attribute/value pair. Format is attr=value." "$TmpDir/automount_006.out"
	rlAssertGrep "\--setattr=STR     Set an attribute to a name/value pair." "$TmpDir/automount_006.out"
	rlAssertGrep "\--rights          Display the access rights of this entry (requires \--all)." "$TmpDir/automount_006.out"
	rlAssertGrep "\--newinfo=IA5STR  New mount information" "$TmpDir/automount_006.out"
	rlAssertGrep "\--all             Retrieve and print all attributes from the server." "$TmpDir/automount_006.out"
	rlAssertGrep "\--raw             Print entries as stored on the server." "$TmpDir/automount_006.out"
	rlAssertGrep "\--rename=STR      Rename the automount key object" "$TmpDir/automount_006.out"

	rlRun "cat $TmpDir/automount_006.out"

rlPhaseEnd
}

automount_007() {

rlPhaseStartTest "ipa-automount-007: ipa help automountkey-show"

	rlRun "ipa help automountkey-show > $TmpDir/automount_007.out 2>&1"

        rlAssertGrep "Purpose: Display an automount key." "$TmpDir/automount_007.out"
        rlAssertGrep "Usage: ipa \[global-options\] automountkey-show AUTOMOUNTLOCATION AUTOMOUNTMAP \[options\]" "$TmpDir/automount_007.out"
        rlAssertGrep "\-h, \--help     show this help message and exit" "$TmpDir/automount_007.out"
        rlAssertGrep "\--rights       Display the access rights of this entry (requires --all)." "$TmpDir/automount_007.out"
        rlAssertGrep "\--key=IA5STR   Automount key name." "$TmpDir/automount_007.out"
        rlAssertGrep "\--info=IA5STR  Mount information" "$TmpDir/automount_007.out"
        rlAssertGrep "\--all          Retrieve and print all attributes from the server." "$TmpDir/automount_007.out"
        rlAssertGrep "\--raw          Print entries as stored on the server." "$TmpDir/automount_007.out"

	rlRun "cat $TmpDir/automount_007.out"

rlPhaseEnd
}

automount_008() {

rlPhaseStartTest "ipa-automount-008: ipa help automountlocation-add"

	rlRun "ipa help automountlocation-add > $TmpDir/automount_008.out 2>&1"
	
	rlAssertGrep "Purpose: Create a new automount location." "$TmpDir/automount_008.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountlocation-add LOCATION \[options\]" "$TmpDir/automount_008.out"
	rlAssertGrep "\-h, \--help     show this help message and exit" "$TmpDir/automount_008.out"
	rlAssertGrep "\--addattr=STR  Add an attribute/value pair. Format is attr=value." "$TmpDir/automount_008.out"
	rlAssertGrep "\--setattr=STR  Set an attribute to a name/value pair." "$TmpDir/automount_008.out"
	rlAssertGrep "\--all          Retrieve and print all attributes from the server." "$TmpDir/automount_008.out"
	rlAssertGrep "\--raw          Print entries as stored on the server." "$TmpDir/automount_008.out"
	rlAssertGrep "" "$TmpDir/automount_008.out"

	rlRun "cat $TmpDir/automount_008.out"

rlPhaseEnd
}

automount_009() {

rlPhaseStartTest "ipa-automount-009: ipa help automountlocation-del"

	rlRun "ipa help automountlocation-del > $TmpDir/automount_009.out 2>&1"

	rlAssertGrep "Purpose: Delete an automount location." "$TmpDir/automount_009.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountlocation-del LOCATION... \[options\]" "$TmpDir/automount_009.out"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/automount_009.out"
	rlAssertGrep "\--continue  Continuous mode: Don't stop on errors." "$TmpDir/automount_009.out"

	rlRun "cat $TmpDir/automount_009.out"

rlPhaseEnd
}

automount_010() {

rlPhaseStartTest "ipa-automount-010: ipa help automountlocation-find"

	rlRun "ipa help automountlocation-find > $TmpDir/automount_010.out 2>&1"

	rlAssertGrep "Purpose: Search for an automount location." "$TmpDir/automount_010.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountlocation-find \[CRITERIA\] \[options\]" "$TmpDir/automount_010.out"
	rlAssertGrep "\-h, \--help       show this help message and exit" "$TmpDir/automount_010.out"
	rlAssertGrep "\--location=STR   Automount location name." "$TmpDir/automount_010.out"
	rlAssertGrep "\--timelimit=INT  Time limit of search in seconds" "$TmpDir/automount_010.out"
	rlAssertGrep "\--sizelimit=INT  Maximum number of entries returned" "$TmpDir/automount_010.out"
	rlAssertGrep "\--all            Retrieve and print all attributes from the server." "$TmpDir/automount_010.out"
	rlAssertGrep "\--raw            Print entries as stored on the server." "$TmpDir/automount_010.out"
	rlAssertGrep "\--pkey-only      Results should contain primary key attribute only" "$TmpDir/automount_010.out"

	rlRun "cat $TmpDir/automount_010.out"

rlPhaseEnd
}

automount_011() {

rlPhaseStartTest "ipa-automount-011: ipa help automountlocation-import"

	rlRun "ipa help automountlocation-import > $TmpDir/automount_011.out 2>&1"

	rlAssertGrep "Purpose: Import automount files for a specific location." "$TmpDir/automount_011.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountlocation-import LOCATION MASTERFILE \[options\]" "$TmpDir/automount_011.out"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/automount_011.out"
	rlAssertGrep "\--continue  Continuous operation mode." "$TmpDir/automount_011.out"

	rlRun "cat $TmpDir/automount_011.out"

rlPhaseEnd
}

automount_012() {

rlPhaseStartTest "ipa-automount-012: ipa help automountlocation-show"

	rlRun "ipa help automountlocation-show > $TmpDir/automount_012.out 2>&1"

	rlAssertGrep "Purpose: Display an automount location." "$TmpDir/automount_012.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountlocation-show LOCATION \[options\]" "$TmpDir/automount_012.out"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/automount_012.out"
	rlAssertGrep "\--rights    Display the access rights of this entry (requires --all)." "$TmpDir/automount_012.out"
	rlAssertGrep "\--all       Retrieve and print all attributes from the server." "$TmpDir/automount_012.out"
	rlAssertGrep "\--raw       Print entries as stored on the server." "$TmpDir/automount_012.out"

	rlRun "cat $TmpDir/automount_012.out"

rlPhaseEnd
}

automount_013() {

rlPhaseStartTest "ipa-automount-013: ipa help automountlocation-tofiles"

	rlRun "ipa help automountlocation-tofiles > $TmpDir/automount_013.out 2>&1"

	rlAssertGrep "Purpose: Generate automount files for a specific location." "$TmpDir/automount_013.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountlocation-tofiles LOCATION \[options\]" "$TmpDir/automount_013.out"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/automount_012.out"

	rlRun "cat $TmpDir/automount_013.out"

rlPhaseEnd
}

automount_014() {

rlPhaseStartTest "ipa-automount-014: ipa help automountmap-add"

	rlRun "ipa help automountmap-add > $TmpDir/automount_014.out  2>&1"

        rlAssertGrep "Purpose: Create a new automount map." "$TmpDir/automount_014.out"
        rlAssertGrep "Usage: ipa \[global-options\] automountmap-add AUTOMOUNTLOCATION MAP \[options\]" "$TmpDir/automount_014.out"
        rlAssertGrep "\-h, \--help     show this help message and exit" "$TmpDir/automount_014.out"
        rlAssertGrep "\--desc=STR     Description" "$TmpDir/automount_014.out"
        rlAssertGrep "\--addattr=STR  Add an attribute/value pair. Format is attr=value." "$TmpDir/automount_014.out"
        rlAssertGrep "\--setattr=STR  Set an attribute to a name/value pair. Format is attr=value." "$TmpDir/automount_014.out"
        rlAssertGrep "\--all          Retrieve and print all attributes from the server." "$TmpDir/automount_014.out"
        rlAssertGrep "\--raw          Print entries as stored on the server." "$TmpDir/automount_014.out"

	rlRun "cat $TmpDir/automount_014.out"

rlPhaseEnd
}

automount_015() {

rlPhaseStartTest "ipa-automount-015: ipa help automountmap-add-indirect"

	rlRun "ipa help automountmap-add-indirect > $TmpDir/automount_015.out 2>&1"

	rlAssertGrep "Purpose: Create a new indirect mount point." "$TmpDir/automount_015.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountmap-add-indirect AUTOMOUNTLOCATION MAP \[options\]" "$TmpDir/automount_015.out"
	rlAssertGrep "\-h, \--help       show this help message and exit" "$TmpDir/automount_015.out"
	rlAssertGrep "\--desc=STR       Description" "$TmpDir/automount_015.out"
	rlAssertGrep "\--addattr=STR    Add an attribute/value pair. Format is attr=value." "$TmpDir/automount_015.out"
	rlAssertGrep "\--setattr=STR    Set an attribute to a name/value pair." "$TmpDir/automount_015.out"
	rlAssertGrep "\--mount=STR      Mount point" "$TmpDir/automount_015.out"
	rlAssertGrep "\--parentmap=STR  Name of parent automount map (default: auto.master)." "$TmpDir/automount_015.out"
	rlAssertGrep "\--all            Retrieve and print all attributes from the server." "$TmpDir/automount_015.out"
	rlAssertGrep "\--raw            Print entries as stored on the server." "$TmpDir/automount_015.out"

	rlRun "cat $TmpDir/automount_015.out"

rlPhaseEnd
}

automount_016() {

rlPhaseStartTest "ipa-automount-016: ipa help automountmap-del"

	rlRun "ipa help automountmap-del > $TmpDir/automount_016.out 2>&1"

        rlAssertGrep "Purpose: Delete an automount map." "$TmpDir/automount_016.out"
        rlAssertGrep "Usage: ipa \[global-options\] automountmap-del AUTOMOUNTLOCATION MAP... \[options\]" "$TmpDir/automount_016.out"
        rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/automount_016.out"
        rlAssertGrep "\--continue  Continuous mode: Don't stop on errors." "$TmpDir/automount_016.out"

	rlRun "cat $TmpDir/automount_016.out"

rlPhaseEnd
}

automount_017() {

rlPhaseStartTest "ipa-automount-017: ipa help automountmap-find"

	rlRun "ipa help automountmap-find > $TmpDir/automount_017.out 2>&1"

        rlAssertGrep "Purpose: Search for an automount map." "$TmpDir/automount_017.out"
        rlAssertGrep "Usage: ipa \[global-options\] automountmap-find AUTOMOUNTLOCATION \[CRITERIA\] \[options\]" "$TmpDir/automount_017.out"
        rlAssertGrep "\-h, \--help       show this help message and exit" "$TmpDir/automount_017.out"
        rlAssertGrep "\--map=IA5STR     Automount map name." "$TmpDir/automount_017.out"
        rlAssertGrep "\--desc=STR       Description" "$TmpDir/automount_017.out"
        rlAssertGrep "\--timelimit=INT  Time limit of search in seconds" "$TmpDir/automount_017.out"
        rlAssertGrep "\--sizelimit=INT  Maximum number of entries returned" "$TmpDir/automount_017.out"
        rlAssertGrep "\--all            Retrieve and print all attributes from the server." "$TmpDir/automount_017.out"
        rlAssertGrep "\--raw            Print entries as stored on the server." "$TmpDir/automount_017.out"

	rlRun "cat $TmpDir/automount_017.out"

rlPhaseEnd
}

automount_018() {

rlPhaseStartTest "ipa-automount-018: ipa help automountmap-mod"

	rlRun "ipa help automountmap-mod > $TmpDir/automount_018.out 2>&1"

        rlAssertGrep "Purpose: Modify an automount map." "$TmpDir/automount_018.out"
        rlAssertGrep "Usage: ipa \[global-options\] automountmap-mod AUTOMOUNTLOCATION MAP \[options\]" "$TmpDir/automount_018.out"
        rlAssertGrep "\-h, \--help     show this help message and exit" "$TmpDir/automount_018.out"
        rlAssertGrep "\--desc=STR     Description" "$TmpDir/automount_018.out"
        rlAssertGrep "\--addattr=STR  Add an attribute/value pair. Format is attr=value." "$TmpDir/automount_018.out"
        rlAssertGrep "\--setattr=STR  Set an attribute to a name/value pair. Format is attr=value." "$TmpDir/automount_018.out"
        rlAssertGrep "\--rights       Display the access rights of this entry (requires --all)." "$TmpDir/automount_018.out"
        rlAssertGrep "\--all          Retrieve and print all attributes from the server." "$TmpDir/automount_018.out"
        rlAssertGrep "\--raw          Print entries as stored on the server." "$TmpDir/automount_018.out"

	rlRun "cat $TmpDir/automount_018.out"

rlPhaseEnd
}

automount_019() {

rlPhaseStartTest "ipa-automount-019: ipa help automountmap-show"

	rlRun "ipa help automountmap-show > $TmpDir/automount_019.out 2>&1"

        rlAssertGrep "Purpose: Display an automount map." "$TmpDir/automount_019.out"
        rlAssertGrep "Usage: ipa \[global-options\] automountmap-show AUTOMOUNTLOCATION MAP \[options\]" "$TmpDir/automount_019.out"
        rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/automount_019.out"
        rlAssertGrep "\--rights    Display the access rights of this entry (requires --all)." "$TmpDir/automount_019.out"
        rlAssertGrep "\--all       Retrieve and print all attributes from the server." "$TmpDir/automount_019.out"
        rlAssertGrep "\--raw       Print entries as stored on the server." "$TmpDir/automount_019.out"

rlPhaseEnd
}



##############################################
### SANITY TESTS START HERE...
##############################################

automount_location_add_001() {

rlPhaseStartTest "ipa-automount-location-add-001: ipa automountlocation-add LOCATION"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 

	rlRun "ipa automountlocation-add pune > $TmpDir/automount_location_001.out 2>&1"
	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=723781"
	rlAssertGrep "Added automount location \"pune\"" "$TmpDir/automount_location_001.out"
	rlAssertGrep "Location: pune" "$TmpDir/automount_location_001.out"
        rlRun "cat $TmpDir/automount_location_001.out"

	rlRun "ldapsearch -LLL -x -h localhost  -b cn=pune,cn=automount,$basedn > $TmpDir/automount_location_001.out 2>&1"

	rlAssertGrep "dn: cn=pune,cn=automount,$basedn" "$TmpDir/automount_location_001.out"
	rlAssertGrep "dn: automountmapname=auto.master,cn=pune,cn=automount," "$TmpDir/automount_location_001.out"
	rlAssertGrep "automountMapName: auto.master" "$TmpDir/automount_location_001.out"
	rlAssertGrep "dn: automountmapname=auto.direct,cn=pune,cn=automount," "$TmpDir/automount_location_001.out"
	rlAssertGrep "automountMapName: auto.direct" "$TmpDir/automount_location_001.out"
	rlAssertGrep "dn: description=/- auto.direct,automountmapname=auto.master,cn=pune" "$TmpDir/automount_location_001.out"
	rlAssertGrep "automountKey: /-" "$TmpDir/automount_location_001.out"
	rlAssertGrep "automountInformation: auto.direct" "$TmpDir/automount_location_001.out"
	rlAssertGrep "description: /- auto.direct" "$TmpDir/automount_location_001.out"

	rlRun "cat $TmpDir/automount_location_001.out"
	rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_add_002() {

rlPhaseStartTest "ipa-automount-location-add-002: ipa automountlocation-add LOCATION --all"

	rlRun "ipa automountlocation-add pune --all > $TmpDir/automount_location_002.out 2>&1"

	rlAssertGrep "Added automount location \"pune\"" "$TmpDir/automount_location_002.out"
	rlAssertGrep "dn: cn=pune,cn=automount,$basedn" "$TmpDir/automount_location_002.out"
	rlAssertGrep "Location: pune" "$TmpDir/automount_location_002.out"
	rlAssertGrep "objectclass: nscontainer, top" "$TmpDir/automount_location_002.out"

        rlRun "cat $TmpDir/automount_location_002.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_add_003() {

rlPhaseStartTest "ipa-automount-location-add-003: ipa automountlocation-add LOCATION --all --raw"

	rlRun "ipa automountlocation-add pune --all --raw > $TmpDir/automount_location_003.out 2>&1"

        rlAssertGrep "Added automount location \"pune\"" "$TmpDir/automount_location_003.out"
        rlAssertGrep "dn: cn=pune,cn=automount,$basedn" "$TmpDir/automount_location_003.out"
        rlAssertGrep "cn: pune" "$TmpDir/automount_location_003.out"
        rlAssertGrep "objectclass: nscontainer" "$TmpDir/automount_location_003.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automount_location_003.out"

        rlRun "cat $TmpDir/automount_location_003.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_find_001() {

rlPhaseStartTest "ipa-automount-location-find-001: ipa automountlocation-find"

	rlRun "ipa automountlocation-add pune"

	rlRun "ipa automountlocation-find > $TmpDir/automount_location_find_001.out 2>&1"
	rlAssertGrep "Location: default" "$TmpDir/automount_location_find_001.out"
	rlAssertGrep "Location: pune" "$TmpDir/automount_location_find_001.out"
	rlAssertGrep "Number of entries returned 2" "$TmpDir/automount_location_find_001.out"

	rlRun "cat $TmpDir/automount_location_find_001.out"
	rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_find_002() {

rlPhaseStartTest "ipa-automount-location-find-002: ipa automountlocation-find LOCATION"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountlocation-find pune > $TmpDir/automount_location_find_002.out 2>&1"
        rlAssertGrep "Location: pune" "$TmpDir/automount_location_find_002.out"
	rlAssertGrep "Number of entries returned 1" "$TmpDir/automount_location_find_002.out"

	rlRun "cat $TmpDir/automount_location_find_002.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_find_003() {

rlPhaseStartTest "ipa-automount-location-find-003: ipa automountlocation-find --location"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountlocation-find --location=pune > $TmpDir/automount_location_find_003.out 2>&1"
        rlAssertGrep "Location: pune" "$TmpDir/automount_location_find_003.out"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/automount_location_find_003.out"

	rlRun "cat $TmpDir/automount_location_find_003.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_find_004() {

rlPhaseStartTest "ipa-automount-location-find-004: ipa automountlocation-find --location --all"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountlocation-find --location=pune --all > $TmpDir/automount_location_find_004.out 2>&1"
        rlAssertGrep "dn: cn=pune,cn=automount,$basedn" "$TmpDir/automount_location_find_004.out"
	rlAssertGrep "Location: pune" "$TmpDir/automount_location_find_004.out"
	rlAssertGrep "objectclass: nscontainer, top" "$TmpDir/automount_location_find_004.out"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/automount_location_find_004.out"

	rlRun "cat $TmpDir/automount_location_find_004.out"
	rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_find_005() {

rlPhaseStartTest "ipa-automount-location-find-005: ipa automountlocation-find --location --all --raw"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountlocation-find --location=pune --all --raw > $TmpDir/automount_location_find_005.out 2>&1"
        rlAssertGrep "dn: cn=pune,cn=automount,$basedn" "$TmpDir/automount_location_find_005.out"
        rlAssertGrep "cn: pune" "$TmpDir/automount_location_find_005.out"
        rlAssertGrep "objectclass: nscontainer" "$TmpDir/automount_location_find_005.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automount_location_find_005.out"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/automount_location_find_005.out"

	rlRun "cat $TmpDir/automount_location_find_005.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_find_006() {

rlPhaseStartTest "ipa-automount-location-find-006: ipa automountlocation-find --pkey-only positive test"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountlocation-find --location=pune --pkey-only > $TmpDir/automount_location_find_006.out 2>&1"
        rlAssertGrep "Location:" "$TmpDir/automount_location_find_006.out"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/automount_location_find_006.out"

	rlRun "cat $TmpDir/automount_location_find_006.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_show_001() {

rlPhaseStartTest "ipa-automount-location-show-001: ipa automountlocation-show LOCATION"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountlocation-show pune > $TmpDir/automount_location_show_001.out 2>&1"
	rlAssertGrep "Location: pune" "$TmpDir/automount_location_show_001.out"

	rlRun "cat $TmpDir/automount_location_show_001.out"
	rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_show_002() {

rlPhaseStartTest "ipa-automount-location-show-002: ipa automountlocation-show LOCATION --all"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountlocation-show pune --all > $TmpDir/automount_location_show_002.out 2>&1"
        rlAssertGrep "dn: cn=pune,cn=automount,$basedn" "$TmpDir/automount_location_show_002.out"
        rlAssertGrep "objectclass: nscontainer, top" "$TmpDir/automount_location_show_002.out"
        rlAssertGrep "Location: pune" "$TmpDir/automount_location_show_002.out"

	rlRun "cat $TmpDir/automount_location_show_002.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_show_003() {

rlPhaseStartTest "ipa-automount-location-show-003: ipa automountlocation-show LOCATION --all --raw"

        rlRun "ipa automountlocation-add pune"

	rlRun "ipa automountlocation-show pune --all --raw > $TmpDir/automount_location_show_003.out 2>&1"
	rlAssertGrep "dn: cn=pune,cn=automount,$basedn" "$TmpDir/automount_location_show_003.out"
        rlAssertGrep "objectclass: nscontainer" "$TmpDir/automount_location_show_003.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automount_location_show_003.out"
        rlAssertGrep "cn: pune" "$TmpDir/automount_location_show_003.out"

	rlRun "cat $TmpDir/automount_location_show_003.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_show_004() {

rlPhaseStartTest "ipa-automount-location-show-004: ipa automountlocation-show LOCATION --all --raw --rights"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountlocation-show pune --all --raw --rights > $TmpDir/automount_location_show_004.out 2>&1"
	rlAssertGrep "dn: cn=pune,cn=automount,$basedn" "$TmpDir/automount_location_show_004.out"
	rlAssertGrep "cn: pune" "$TmpDir/automount_location_show_004.out"
        rlAssertGrep "objectclass: nscontainer" "$TmpDir/automount_location_show_004.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automount_location_show_004.out"
        rlAssertGrep "attributelevelrights: {'objectclass': u'rscwo', 'aci': u'rscwo', 'cn': u'rscwo', 'nsaccountlock': u'rscwo'}" "$TmpDir/automount_location_show_004.out"

        rlRun "cat $TmpDir/automount_location_show_004.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_add_001() {

rlPhaseStartTest "ipa-automountmap-add-001: ipa automountmap-add LOCATION MAP"

	rlRun "ipa automountlocation-add pune"

	rlRun "ipa automountmap-add pune auto.pune > $TmpDir/automountmap_add_001.out 2>&1"
	rlAssertGrep "Added automount map \"auto.pune\"" "$TmpDir/automountmap_add_001.out"
	rlAssertGrep "Map: auto.pune" "$TmpDir/automountmap_add_001.out"

	rlRun "cat $TmpDir/automountmap_add_001.out"
	rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_add_002() {

rlPhaseStartTest "ipa-automountmap-add-002: ipa automountmap-add LOCATION MAP --all"

	rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountmap-add pune auto.pune --all > $TmpDir/automountmap_add_002.out 2>&1"
        rlAssertGrep "Added automount map \"auto.pune\"" "$TmpDir/automountmap_add_002.out"
	rlAssertGrep "dn: automountmapname=auto.pune,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_add_002.out"
        rlAssertGrep "Map: auto.pune" "$TmpDir/automountmap_add_002.out"
        rlAssertGrep "objectclass: automountmap, top" "$TmpDir/automountmap_add_002.out"

        rlRun "cat $TmpDir/automountmap_add_002.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_add_003() {

rlPhaseStartTest "ipa-automountmap-add-003: ipa automountmap-add LOCATION MAP --all --raw"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountmap-add pune auto.pune --all --raw > $TmpDir/automountmap_add_003.out 2>&1"
        rlAssertGrep "Added automount map \"auto.pune\"" "$TmpDir/automountmap_add_003.out"
	rlAssertGrep "dn: automountmapname=auto.pune,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_add_003.out"
        rlAssertGrep "automountmapname: auto.pune" "$TmpDir/automountmap_add_003.out"
        rlAssertGrep "objectclass: automountmap" "$TmpDir/automountmap_add_003.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automountmap_add_003.out"

        rlRun "cat $TmpDir/automountmap_add_003.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_add_004() {

rlPhaseStartTest "ipa-automountmap-add-004: ipa automountmap-add LOCATION MAP --all --raw --desc"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountmap-add pune auto.pune --all --raw --desc=\"pune automount map\" > $TmpDir/automountmap_add_004.out 2>&1"
        rlAssertGrep "Added automount map \"auto.pune\"" "$TmpDir/automountmap_add_004.out"
        rlAssertGrep "dn: automountmapname=auto.pune,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_add_004.out"
        rlAssertGrep "automountmapname: auto.pune" "$TmpDir/automountmap_add_004.out"
	rlAssertGrep "description: pune automount map" "$TmpDir/automountmap_add_004.out"
        rlAssertGrep "objectclass: automountmap" "$TmpDir/automountmap_add_004.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automountmap_add_004.out"

        rlRun "cat $TmpDir/automountmap_add_004.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_add_005() {

rlPhaseStartTest "ipa-automountmap-add-005: ipa automountmap-add-indirect LOCATION MAP --mount"

	rlRun "ipa automountlocation-add pune"

	rlRun "ipa automountmap-add-indirect pune punechild.map --mount=/usr/share/man > $TmpDir/automountmap_add_005.out 2>&1"
	rlAssertGrep "Added automount map \"punechild.map\"" "$TmpDir/automountmap_add_005.out"
	rlAssertGrep "Map: punechild.map" "$TmpDir/automountmap_add_005.out"

	rlRun "cat $TmpDir/automountmap_add_005.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_add_006() {

rlPhaseStartTest "ipa-automountmap-add-006: ipa automountmap-add-indirect LOCATION MAP --mount --parentmap"

	rlRun "ipa automountlocation-add pune"
	rlRun "ipa automountmap-add pune pune.map"

        rlRun "ipa automountmap-add-indirect pune punechild.map --mount=usr/share/man --parentmap=pune.map > $TmpDir/automountmap_add_006.out"
	rlAssertGrep "Added automount map \"punechild.map\"" "$TmpDir/automountmap_add_006.out"
	rlAssertGrep "Map: punechild.map" "$TmpDir/automountmap_add_006.out"

        rlRun "cat $TmpDir/automountmap_add_006.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_add_007() {

rlPhaseStartTest "ipa-automountmap-add-007: ipa automountmap-add-indirect LOCATION MAP --mount --parentmap --all"

        rlRun "ipa automountlocation-add pune"
        rlRun "ipa automountmap-add pune pune.map"

        rlRun "ipa automountmap-add-indirect pune punechild.map --mount=usr/share/man --parentmap=pune.map --all > $TmpDir/automountmap_add_007.out"
	rlAssertGrep "dn: automountmapname=punechild.map,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_add_007.out"
	rlAssertGrep "Map: punechild.map" "$TmpDir/automountmap_add_007.out"
	rlAssertGrep "objectclass: automountmap, top" "$TmpDir/automountmap_add_007.out"

        rlRun "cat $TmpDir/automountmap_add_007.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_add_008() {

rlPhaseStartTest "ipa-automountmap-add-008: ipa automountmap-add-indirect LOCATION MAP --mount --parentmap --all --raw"

	rlRun "ipa -d automountlocation-add pune"
        rlRun "ipa -d automountmap-add pune pune.map"

        rlRun "ipa -d automountmap-add-indirect pune punechild.map --mount=usr/share/man --parentmap=pune.map --all --raw > $TmpDir/automountmap_add_008.out"
	rlAssertGrep "dn: automountmapname=punechild.map,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_add_008.out"
	rlAssertGrep "automountmapname: punechild.map" "$TmpDir/automountmap_add_008.out"
	rlAssertGrep "objectclass: automountmap" "$TmpDir/automountmap_add_008.out"
	rlAssertGrep "objectclass: top" "$TmpDir/automountmap_add_008.out"

        rlRun "cat $TmpDir/automountmap_add_008.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_find_001() {

rlPhaseStartTest "ipa-automountmap-find-001: ipa automountmap-find AUTOMOUNTLOCATION"

	# Setup for automountmap-find.
	rlRun "ipa automountlocation-add pune"
        rlRun "ipa automountmap-add pune pune.map"
        rlRun "ipa automountmap-add pune pune2.map"
        rlRun "ipa automountmap-add pune pune3.map"

	rlRun "ipa automountmap-find pune > $TmpDir/automountmap_find_001.out 2>&1"
	rlAssertGrep "5 automount maps matched" "$TmpDir/automountmap_find_001.out"
	rlAssertGrep "Map: auto.direct" "$TmpDir/automountmap_find_001.out"
	rlAssertGrep "Map: auto.master" "$TmpDir/automountmap_find_001.out"
	rlAssertGrep "Map: pune.map" "$TmpDir/automountmap_find_001.out"
	rlAssertGrep "Map: pune2.map" "$TmpDir/automountmap_find_001.out"
	rlAssertGrep "Map: pune3.map" "$TmpDir/automountmap_find_001.out"
	rlAssertGrep "Number of entries returned 5" "$TmpDir/automountmap_find_001.out"

	rlRun "cat $TmpDir/automountmap_find_001.out"

rlPhaseEnd
}

automountmap_find_002() {

rlPhaseStartTest "ipa-automountmap-find-002: ipa automountmap-find AUTOMOUNTLOCATION MAP"

	rlRun "ipa automountmap-find pune --map=pune.map > $TmpDir/automountmap_find_002.out 2>&1"
	rlAssertGrep "1 automount map matched" "$TmpDir/automountmap_find_002.out"
	rlAssertGrep "Map: pune.map" "$TmpDir/automountmap_find_002.out"
	rlAssertGrep "Number of entries returned 1" "$TmpDir/automountmap_find_002.out"

        rlRun "cat $TmpDir/automountmap_find_002.out"

rlPhaseEnd
}

automountmap_find_003() {

rlPhaseStartTest "ipa-automountmap-find-003: ipa automountmap-find AUTOMOUNTLOCATION MAP --all"

        rlRun "ipa automountmap-find pune --map=pune.map --all > $TmpDir/automountmap_find_003.out 2>&1"
        rlAssertGrep "1 automount map matched" "$TmpDir/automountmap_find_003.out"
        rlAssertGrep "dn: automountmapname=pune.map,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_find_003.out"
	rlAssertGrep "Map: pune.map" "$TmpDir/automountmap_find_003.out"
	rlAssertGrep "objectclass: automountmap, top" "$TmpDir/automountmap_find_003.out"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/automountmap_find_003.out"

	rlRun "cat $TmpDir/automountmap_find_003.out"

rlPhaseEnd
}

automountmap_find_004() {

rlPhaseStartTest "ipa-automountmap-find-004: ipa automountmap-find AUTOMOUNTLOCATION MAP --all --raw"

	rlRun "ipa automountmap-find pune --map=pune.map --all --raw > $TmpDir/automountmap_find_004.out 2>&1"
        rlAssertGrep "1 automount map matched" "$TmpDir/automountmap_find_004.out"
        rlAssertGrep "dn: automountmapname=pune.map,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_find_004.out"
        rlAssertGrep "automountmapname: pune.map" "$TmpDir/automountmap_find_004.out"
        rlAssertGrep "objectclass: automountmap" "$TmpDir/automountmap_find_004.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automountmap_find_004.out"
	rlAssertGrep "Number of entries returned 1" "$TmpDir/automountmap_find_004.out"

        rlRun "cat $TmpDir/automountmap_find_004.out"

rlPhaseEnd
}

automountmap_find_005() {

rlPhaseStartTest "ipa-automountmap-find-005: ipa automountmap-find AUTOMOUNTLOCATION MAP --all --raw --sizelimit"

	rlRun "ipa automountmap-find pune --all --raw --sizelimit=2 > $TmpDir/automountmap_find_005.out 2>&1"

        rlAssertGrep "2 automount maps matched" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "dn: automountmapname=auto.direct,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "automountmapname: auto.direct" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "objectclass: automountmap" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "dn: automountmapname=auto.master,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "automountmapname: auto.master" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "objectclass: automountmap" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "Number of entries returned 2" "$TmpDir/automountmap_find_005.out"

	rlRun "cat $TmpDir/automountmap_find_005.out"

	rlRun "ipa automountmap-find pune --all --raw --sizelimit=3 > $TmpDir/automountmap_find_005.out 2>&1"

	rlAssertGrep "3 automount maps matched" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "dn: automountmapname=auto.direct,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "automountmapname: auto.direct" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "objectclass: automountmap" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "dn: automountmapname=auto.master,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "automountmapname: auto.master" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "objectclass: automountmap" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automountmap_find_005.out"
	rlAssertGrep "dn: automountmapname=pune.map,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_find_005.out"
	rlAssertGrep "automountmapname: pune.map" "$TmpDir/automountmap_find_005.out"
        rlAssertGrep "objectclass: automountmap" "$TmpDir/automountmap_find_005.out"
	rlAssertGrep "objectclass: top" "$TmpDir/automountmap_find_005.out"
	rlAssertGrep "Number of entries returned 3" "$TmpDir/automountmap_find_005.out"

	rlRun "cat $TmpDir/automountmap_find_005.out"

rlPhaseEnd
}

automountmap_find_006() {

rlPhaseStartTest "ipa-automountmap-find-006: ipa automountmap-find AUTOMOUNTLOCATION MAP --pkey-only positive test."

	rlRun "ipa automountmap-find pune --map=pune.map --pkey-only > $TmpDir/automountmap_find_006.out 2>&1"
        rlAssertGrep "1 automount map matched" "$TmpDir/automountmap_find_006.out"
        rlAssertGrep "Map: auto.direct" "$TmpDir/automountmap_find_006.out"
        rlAssertGrep "Map: auto.master" "$TmpDir/automountmap_find_006.out"
        rlAssertGrep "Map: pune.map" "$TmpDir/automountmap_find_006.out"

        rlRun "cat $TmpDir/automountmap_find_006.out"

        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_show_001() {

rlPhaseStartTest "ipa-automountmap-show-001: ipa automountmap-show LOCATION MAP"
	ipa automountlocation-del pune

        # Setup for automountmap-show.
	rlRun "ipa automountlocation-add pune"
	rlRun "ipa automountmap-add pune pune.map --desc=\"map file for pune location\""

	rlRun "ipa automountmap-show pune pune.map > $TmpDir/automountmap_show_001.out 2>&1"
	rlAssertGrep "Map: pune.map" "$TmpDir/automountmap_show_001.out"
	rlAssertGrep "Description: map file for pune location" "$TmpDir/automountmap_show_001.out"

	rlRun "cat $TmpDir/automountmap_show_001.out"

rlPhaseEnd
}

automountmap_show_002() {

rlPhaseStartTest "ipa-automountmap-show-002: ipa automountmap-show LOCATION MAP --all"

	rlRun "ipa automountmap-show pune pune.map --all > $TmpDir/automountmap_show_002.out 2>&1"
	rlAssertGrep "dn: automountmapname=pune.map,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_show_002.out"
	rlAssertGrep "Map: pune.map" "$TmpDir/automountmap_show_002.out"
	rlAssertGrep "Description: map file for pune location" "$TmpDir/automountmap_show_002.out"
        rlAssertGrep "objectclass: automountmap, top" "$TmpDir/automountmap_show_002.out"

	rlRun "cat $TmpDir/automountmap_show_002.out"

rlPhaseEnd
}

automountmap_show_003() {

rlPhaseStartTest "ipa-automountmap-show-003: ipa automountmap-show LOCATION MAP --all --raw"

	rlRun "ipa automountmap-show pune pune.map --all --raw > $TmpDir/automountmap_show_003.out 2>&1"
        rlAssertGrep "dn: automountmapname=pune.map,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_show_003.out"
        rlAssertGrep "automountmapname: pune.map" "$TmpDir/automountmap_show_003.out"
        rlAssertGrep "description: map file for pune location" "$TmpDir/automountmap_show_003.out"
        rlAssertGrep "objectclass: automountmap" "$TmpDir/automountmap_show_003.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automountmap_show_003.out"

	rlRun "cat $TmpDir/automountmap_show_003.out"
	rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountkey_add_001() {

rlPhaseStartTest "ipa-automountkey-add-001: ipa automountkey-add LOCATION MASTERMAP --key --info"

	rlRun "ipa automountlocation-add baltimore"
	rlRun "ipa automountmap-add baltimore auto.baltimore"

	# Create a new key for the auto.share map in location baltimore. This ties
	# the map we previously created to auto.master.

	rlRun "ipa automountkey-add baltimore auto.master --key=/share --info=auto.share > $TmpDir/automountkey_add_001.out 2>&1"
	rlLog "Verifies bug https://bugzilla.redhat.com/show_bug.cgi?id=725763"
	rlAssertGrep "Added automount key \"/share\"" "$TmpDir/automountkey_add_001.out"
	rlAssertGrep "Key: /share" "$TmpDir/automountkey_add_001.out"
	rlAssertGrep "Mount information: auto.share" "$TmpDir/automountkey_add_001.out"

	rlRun "cat $TmpDir/automountkey_add_001.out"
	rlRun "ipa automountlocation-del baltimore"

rlPhaseEnd
}

automountkey_add_002() {

rlPhaseStartTest "ipa-automountkey-add-002: ipa automountkey-add LOCATION MASTERMAP --key --info --all"

	rlRun "ipa automountlocation-add baltimore"
        rlRun "ipa automountmap-add baltimore auto.baltimore"

        # Create a new key for the auto.share map in location baltimore. This ties
        # the map we previously created to auto.master.

        rlRun "ipa automountkey-add baltimore auto.master --key=/share --info=auto.share --all > $TmpDir/automountkey_add_002.out 2>&1"
	rlAssertGrep "Added automount key \"/share\"" "$TmpDir/automountkey_add_002.out"
	rlAssertGrep "dn: description=/share,automountmapname=auto.master,cn=baltimore,cn=automount,$basedn" "$TmpDir/automountkey_add_002.out"
	rlAssertGrep "Key: /share" "$TmpDir/automountkey_add_002.out"
	rlAssertGrep "Mount information: auto.share" "$TmpDir/automountkey_add_002.out"
	rlAssertGrep "description: /share" "$TmpDir/automountkey_add_002.out"
	rlAssertGrep "objectclass: automount, top" "$TmpDir/automountkey_add_002.out"

        rlRun "cat $TmpDir/automountkey_add_002.out"
        rlRun "ipa automountlocation-del baltimore"

rlPhaseEnd
}

automountkey_add_003() {

rlPhaseStartTest "ipa-automountkey-add-003: ipa automountkey-add LOCATION MASTERMAP --key --info --all --raw"

        rlRun "ipa automountlocation-add baltimore"
        rlRun "ipa automountmap-add baltimore auto.baltimore"

        # Create a new key for the auto.share map in location baltimore. This ties
        # the map we previously created to auto.master.

        rlRun "ipa automountkey-add baltimore auto.master --key=/share --info=auto.share --all --raw > $TmpDir/automountkey_add_003.out 2>&1"
	rlAssertGrep "dn: description=/share,automountmapname=auto.master,cn=baltimore,cn=automount,$basedn" "$TmpDir/automountkey_add_003.out"
	rlAssertGrep "automountkey: /share" "$TmpDir/automountkey_add_003.out"
	rlAssertGrep "automountinformation: auto.share" "$TmpDir/automountkey_add_003.out"
	rlAssertGrep "description: /share" "$TmpDir/automountkey_add_003.out"
	rlAssertGrep "objectclass: automount" "$TmpDir/automountkey_add_003.out"
	rlAssertGrep "objectclass: top" "$TmpDir/automountkey_add_003.out"

        rlRun "cat $TmpDir/automountkey_add_003.out"
        rlRun "ipa automountlocation-del baltimore"

rlPhaseEnd
}

automountkey_mod_001() {

rlPhaseStartTest "ipa-automountkey-mod-001: ipa automountkey-mod LOCATION MAP --key --rename --info --newinfo"

        rlRun "ipa automountlocation-add baltimore"
	rlRun "ipa automountkey-add baltimore auto.master --key=/share --info=auto.share"

	rlRun "ipa automountkey-mod baltimore auto.master --key=/share --rename=/ipashare --info=auto.share --newinfo=auto.ipashare > $TmpDir/automountkey_mod_001.out 2>&1"
	rlLog "Verifies bug https://bugzilla.redhat.com/show_bug.cgi?id=726028"
	rlAssertNotGrep "Key: /share" "$TmpDir/automountkey_mod_001.out"
	rlAssertGrep "Key: /ipashare" "$TmpDir/automountkey_mod_001.out"
	rlAssertGrep "Mount information: auto.ipashare" "$TmpDir/automountkey_mod_001.out"

	rlRun "cat $TmpDir/automountkey_mod_001.out"
	rlRun "ipa automountlocation-del baltimore"

rlPhaseEnd
}

automountkey_mod_002() {

rlPhaseStartTest "ipa-automountkey-mod-002: ipa automountkey-mod LOCATION MAP MAP --key --rename --info --newinfo --all"

	rlRun "ipa automountlocation-add baltimore"
        rlRun "ipa automountkey-add baltimore auto.master --key=/share --info=auto.share"

        rlRun "ipa automountkey-mod baltimore auto.master --key=/share --rename=/ipashare --info=auto.share --newinfo=auto.ipashare --all > $TmpDir/automountkey_mod_002.out 2>&1"
	rlAssertNotGrep "Key: /share" "$TmpDir/automountkey_mod_002.out"
	rlAssertGrep "Key: /ipashare" "$TmpDir/automountkey_mod_002.out"
	rlAssertGrep "Mount information: auto.ipashare" "$TmpDir/automountkey_mod_002.out"
	rlAssertGrep "description: /ipashare" "$TmpDir/automountkey_mod_002.out"
	rlAssertGrep "objectclass: automount, top" "$TmpDir/automountkey_mod_002.out"

	rlRun "cat $TmpDir/automountkey_mod_002.out"
	rlRun "ipa automountlocation-del baltimore"

rlPhaseEnd
}

automountkey_mod_003() {

rlPhaseStartTest "ipa-automountkey-mod-003: ipa automountkey-mod LOCATION MAP MAP --key --rename --info --newinfo --all --raw"

        rlRun "ipa automountlocation-add baltimore"
        rlRun "ipa automountkey-add baltimore auto.master --key=/share --info=auto.share"

        rlRun "ipa automountkey-mod baltimore auto.master --key=/share --rename=/ipashare --info=auto.share --newinfo=auto.ipashare --all --raw > $TmpDir/automountkey_mod_003.out 2>&1"
	rlAssertGrep "automountkey: /ipashare" "$TmpDir/automountkey_mod_003.out"
	rlAssertGrep "automountinformation: auto.ipashare" "$TmpDir/automountkey_mod_003.out"
	rlAssertGrep "description: /ipashare" "$TmpDir/automountkey_mod_003.out"
	rlAssertGrep "objectclass: automount" "$TmpDir/automountkey_mod_003.out"
	rlAssertGrep "objectclass: top" "$TmpDir/automountkey_mod_003.out"

	rlRun "cat $TmpDir/automountkey_mod_003.out"
	rlRun "ipa automountlocation-del baltimore"

rlPhaseEnd
}

automountkey_mod_004() {

rlPhaseStartTest "ipa-automountkey-mod-004: ipa automountkey-mod LOCATION MAP MAP --key --rename --info --newinfo --all --raw --rights"

        rlRun "ipa automountlocation-add baltimore"
        rlRun "ipa automountkey-add baltimore auto.master --key=/share --info=auto.share"

        rlRun "ipa automountkey-mod baltimore auto.master --key=/share --rename=/ipashare --info=auto.share --newinfo=auto.ipashare --all --raw --rights > $TmpDir/automountkey_mod_004.out 2>&1"
        rlAssertGrep "automountkey: /ipashare" "$TmpDir/automountkey_mod_004.out"
        rlAssertGrep "automountinformation: auto.ipashare" "$TmpDir/automountkey_mod_004.out"
        rlAssertGrep "attributelevelrights: {'description': u'rscwo', 'objectclass': u'rscwo', 'aci': u'rscwo', 'nsaccountlock': u'rscwo', 'automountkey': u'rscwo', 'automountinformation': u'rscwo'}" "$TmpDir/automountkey_mod_004.out"
        rlAssertGrep "description: /ipashare" "$TmpDir/automountkey_mod_004.out"
        rlAssertGrep "objectclass: automount" "$TmpDir/automountkey_mod_004.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automountkey_mod_004.out"

        rlRun "cat $TmpDir/automountkey_mod_004.out"
        rlRun "ipa automountlocation-del baltimore"

rlPhaseEnd
}

automountkey_find_001() {

rlPhaseStartTest "ipa-automountkey-find-001: ipa automountkey-find LOCATION MAP"

	rlRun "ipa automountlocation-add baltimore"
        rlRun "ipa automountkey-add baltimore auto.master --key=/share --info=auto.share"

	rlRun "ipa automountkey-find baltimore auto.master > $TmpDir/automountkey_find_001.out 2>&1"
	rlAssertGrep "2 automount keys matched" "$TmpDir/automountkey_find_001.out"
	rlAssertGrep "Key: /-" "$TmpDir/automountkey_find_001.out"
	rlAssertGrep "Mount information: auto.direct" "$TmpDir/automountkey_find_001.out"
	rlAssertGrep "Key: /share" "$TmpDir/automountkey_find_001.out"
	rlAssertGrep "Mount information: auto.share" "$TmpDir/automountkey_find_001.out"

	rlRun "cat $TmpDir/automountkey_find_001.out"

rlPhaseEnd
}

automountkey_find_002() {

rlPhaseStartTest "ipa-automountkey-find-002: ipa automountkey-find LOCATION MAP --all"

	rlRun "ipa automountkey-find baltimore auto.master --all > $TmpDir/automountkey_find_002.out 2>&1"
        rlAssertGrep "2 automount keys matched" "$TmpDir/automountkey_find_002.out"
        rlAssertGrep "dn: description=/- auto.direct,automountmapname=auto.master,cn=baltimore,cn=automount,$basedn" "$TmpDir/automountkey_find_002.out"
	rlAssertGrep "Key: /-" "$TmpDir/automountkey_find_002.out"
	rlAssertGrep "Mount information: auto.direct" "$TmpDir/automountkey_find_002.out"
	rlAssertGrep "description: /- auto.direct" "$TmpDir/automountkey_find_002.out"
	rlAssertGrep "objectclass: automount, top" "$TmpDir/automountkey_find_002.out"
	rlAssertGrep "dn: description=/share,automountmapname=auto.master,cn=baltimore,cn=automount,$basedn" "$TmpDir/automountkey_find_002.out"
	rlAssertGrep "Key: /share" "$TmpDir/automountkey_find_002.out"
	rlAssertGrep "Mount information: auto.share" "$TmpDir/automountkey_find_002.out"
	rlAssertGrep "description: /share" "$TmpDir/automountkey_find_002.out"
	rlAssertGrep "objectclass: automount, top" "$TmpDir/automountkey_find_002.out"
	rlAssertGrep "Number of entries returned 2" "$TmpDir/automountkey_find_002.out"

	rlRun "cat $TmpDir/automountkey_find_002.out"

rlPhaseEnd
}

automountkey_find_003() {

rlPhaseStartTest "ipa-automountkey-find-003: ipa automountkey-find LOCATION MAP --all --raw"

	rlRun "ipa automountkey-find baltimore auto.master --all --raw > $TmpDir/automountkey_find_003.out 2>&1"
        rlAssertGrep "2 automount keys matched" "$TmpDir/automountkey_find_003.out"
        rlAssertGrep "dn: description=/- auto.direct,automountmapname=auto.master,cn=baltimore,cn=automount,$basedn" "$TmpDir/automountkey_find_003.out"
	rlAssertGrep "automountkey: /-" "$TmpDir/automountkey_find_003.out"
	rlAssertGrep "automountinformation: auto.direct" "$TmpDir/automountkey_find_003.out"
	rlAssertGrep "description: /- auto.direct" "$TmpDir/automountkey_find_003.out"
	rlAssertGrep "objectclass: automount" "$TmpDir/automountkey_find_003.out"
	rlAssertGrep "objectclass: top" "$TmpDir/automountkey_find_003.out"
	rlAssertGrep "dn: description=/share,automountmapname=auto.master,cn=baltimore,cn=automount,$basedn" "$TmpDir/automountkey_find_003.out"
	rlAssertGrep "automountkey: /share" "$TmpDir/automountkey_find_003.out"
	rlAssertGrep "automountinformation: auto.share" "$TmpDir/automountkey_find_003.out"
	rlAssertGrep "description: /share" "$TmpDir/automountkey_find_003.out"
	rlAssertGrep "objectclass: automount" "$TmpDir/automountkey_find_003.out"
	rlAssertGrep "objectclass: top" "$TmpDir/automountkey_find_003.out"

	rlRun "cat $TmpDir/automountkey_find_003.out"

rlPhaseEnd
}

automountkey_find_004() {

rlPhaseStartTest "ipa-automountkey-find-004: ipa automountkey-find LOCATION MAP --all --sizelimit"

	rlRun "ipa automountkey-find baltimore auto.master --all --sizelimit=1 > $TmpDir/automountkey_find_004.out 2>&1"
	rlAssertGrep "1 automount key matched" "$TmpDir/automountkey_find_004.out"
	rlAssertGrep "dn: description=/- auto.direct,automountmapname=auto.master,cn=baltimore,cn=automount,$basedn" "$TmpDir/automountkey_find_004.out"
	rlAssertGrep "Key: /-" "$TmpDir/automountkey_find_004.out"
	rlAssertGrep "Mount information: auto.direct" "$TmpDir/automountkey_find_004.out"
	rlAssertGrep "description: /- auto.direct" "$TmpDir/automountkey_find_004.out"
	rlAssertGrep "objectclass: automount, top" "$TmpDir/automountkey_find_004.out"
	rlAssertGrep "Number of entries returned 1" "$TmpDir/automountkey_find_004.out"

	rlRun "cat $TmpDir/automountkey_find_004.out"

rlPhaseEnd
}

automountkey_find_005() {

rlPhaseStartTest "ipa-automountkey-find-005: ipa automountkey-find LOCATION MAP --all --key"

	rlRun "ipa automountkey-find baltimore auto.master --all --key=/share > $TmpDir/automountkey_find_005.out 2>&1"
	rlAssertGrep "1 automount key matched" "$TmpDir/automountkey_find_005.out"
	rlAssertGrep "Key: /share" "$TmpDir/automountkey_find_005.out"
	rlAssertGrep "Mount information: auto.share" "$TmpDir/automountkey_find_005.out"
	rlAssertGrep "Number of entries returned 1" "$TmpDir/automountkey_find_005.out"

	rlRun "cat $TmpDir/automountkey_find_005.out"

rlPhaseEnd
}

automountkey_find_006() {

rlPhaseStartTest "ipa-automountkey-find-006: ipa automountkey-find LOCATION MAP --all --info"

	rlRun "ipa automountkey-find baltimore auto.master --all --info=auto.share > $TmpDir/automountkey_find_006.out 2>&1"
        rlAssertGrep "1 automount key matched" "$TmpDir/automountkey_find_006.out"
        rlAssertGrep "Key: /share" "$TmpDir/automountkey_find_006.out"
        rlAssertGrep "Mount information: auto.share" "$TmpDir/automountkey_find_006.out"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/automountkey_find_006.out"

        rlRun "cat $TmpDir/automountkey_find_006.out"

rlPhaseEnd
}

automountkey_show_001() {

rlPhaseStartTest "ipa-automountkey-show-001: ipa automountkey-show LOCATION MAP --key"

        rlRun "ipa automountkey-show baltimore auto.master --key=/share > $TmpDir/automountkey_show_001.out 2>&1"
        rlAssertGrep "Key: /share" "$TmpDir/automountkey_show_001.out"
        rlAssertGrep "Mount information: auto.share" "$TmpDir/automountkey_show_001.out"

	rlRun "cat $TmpDir/automountkey_show_001.out"

rlPhaseEnd
}

automountkey_show_002() {

rlPhaseStartTest "ipa-automountkey-show-002: ipa automountkey-show LOCATION MAP --key --info"

	rlRun "ipa automountkey-show baltimore auto.master --key=/share --info=auto.share > $TmpDir/automountkey_show_002.out 2>&1"
        rlAssertGrep "Key: /share" "$TmpDir/automountkey_show_002.out"
        rlAssertGrep "Mount information: auto.share" "$TmpDir/automountkey_show_002.out"

	rlRun "cat $TmpDir/automountkey_show_002.out"

rlPhaseEnd
}

automountkey_show_003() {

rlPhaseStartTest "ipa-automountkey-show-003: ipa automountkey-show LOCATION MAP --key --info --all"

	rlRun "ipa automountkey-show baltimore auto.master --key=/share --info=auto.share --all > $TmpDir/automountkey_show_003.out 2>&1"
        rlAssertGrep " dn: description=/share,automountmapname=auto.master,cn=baltimore,cn=automount,$basedn" "$TmpDir/automountkey_show_003.out"
        rlAssertGrep "Key: /share" "$TmpDir/automountkey_show_003.out"
        rlAssertGrep "Mount information: auto.share" "$TmpDir/automountkey_show_003.out"
        rlAssertGrep "description: /share" "$TmpDir/automountkey_show_003.out"
        rlAssertGrep "objectclass: automount, top" "$TmpDir/automountkey_show_003.out"

	rlRun "cat $TmpDir/automountkey_show_003.out"

rlPhaseEnd
}

automountkey_show_004() {

rlPhaseStartTest "ipa-automountkey-show-004: ipa automountkey-show LOCATION MAP --key --info --all --raw"

        rlRun "ipa automountkey-show baltimore auto.master --key=/share --info=auto.share --all --raw > $TmpDir/automountkey_show_004.out 2>&1"
        rlAssertGrep "dn: description=/share,automountmapname=auto.master,cn=baltimore,cn=automount,$basedn" "$TmpDir/automountkey_show_004.out"
        rlAssertGrep "automountkey: /share" "$TmpDir/automountkey_show_004.out"
        rlAssertGrep "automountinformation: auto.share" "$TmpDir/automountkey_show_004.out"
        rlAssertGrep "description: /share" "$TmpDir/automountkey_show_004.out"
        rlAssertGrep "objectclass: automount" "$TmpDir/automountkey_show_004.out"
        rlAssertGrep "objectclass: top" "$TmpDir/automountkey_show_004.out"

	rlRun "cat $TmpDir/automountkey_show_004.out"

rlPhaseEnd
}

automountkey_show_005() {

rlPhaseStartTest "ipa-automountkey-show-005: ipa automountkey-show LOCATION MAP --key --info --all --raw --rights"

        rlRun "ipa automountkey-show baltimore auto.master --key=/share --info=auto.share --all --raw --rights > $TmpDir/automountkey_show_005.out 2>&1"
	rlAssertGrep "dn: description=/share,automountmapname=auto.master,cn=baltimore,cn=automount,$basedn" "$TmpDir/automountkey_show_005.out"
	rlAssertGrep "automountkey: /share" "$TmpDir/automountkey_show_005.out"
	rlAssertGrep "automountinformation: auto.share" "$TmpDir/automountkey_show_005.out"
	rlAssertGrep "attributelevelrights: {'description': u'rscwo', 'objectclass': u'rscwo', 'aci': u'rscwo', 'nsaccountlock': u'rscwo', 'automountkey': u'rscwo', 'automountinformation': u'rscwo'}" "$TmpDir/automountkey_show_005.out"
	rlAssertGrep "description: /share" "$TmpDir/automountkey_show_005.out"
	rlAssertGrep "objectclass: automount" "$TmpDir/automountkey_show_005.out"
	rlAssertGrep "objectclass: top" "$TmpDir/automountkey_show_005.out"

	rlRun "cat $TmpDir/automountkey_show_005.out"
	rlRun "ipa automountlocation-del baltimore"

rlPhaseEnd
}

automount_location_del_001() {

rlPhaseStartTest "ipa-automountlocation-del-001: ipa automountlocation-del LOCATION - BZ 723778"

	rlRun "ipa automountlocation-add pune"
	rlRun "ipa automountlocation-del pune > $TmpDir/automount_location_del.out 2>&1"
	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug?id=723778"
	rlAssertGrep "Deleted automount location \"pune\"" "$TmpDir/automount_location_del.out"

        rlRun "cat $TmpDir/automount_location_del.out"

rlPhaseEnd
}

automount_location_del_002() {

rlPhaseStartTest "ipa-automountlocation-del-002: ipa automountlocation-del LOCATION"

	rlRun "ipa automountlocation-add pune"
	rlRun "ipa automountlocation-del pune"
        rlRun "ldapsearch -LLL -x -h localhost  -b cn=pune,cn=automount,$basedn > $TmpDir/automount_location_del.out 2>&1" 32
        
        rlAssertNotGrep "dn: cn=pune,cn=automount,$basedn" "$TmpDir/automount_location_del.out"
        rlAssertNotGrep "dn: automountmapname=auto.master,cn=pune,cn=automount," "$TmpDir/automount_location_del.out"
        rlAssertNotGrep "automountMapName: auto.master" "$TmpDir/automount_location_del.out"
        rlAssertNotGrep "dn: automountmapname=auto.direct,cn=pune,cn=automount," "$TmpDir/automount_location_del.out"
        rlAssertNotGrep "automountMapName: auto.direct" "$TmpDir/automount_location_del.out"
        rlAssertNotGrep "dn: description=/- auto.direct,automountmapname=auto.master,cn=pune" "$TmpDir/automount_location_del.out"
        rlAssertNotGrep "automountKey: /-" "$TmpDir/automount_location_del.out"
        rlAssertNotGrep "automountInformation: auto.direct" "$TmpDir/automount_location_del.out"
        rlAssertNotGrep "description: /- auto.direct" "$TmpDir/automount_location_del.out"

        rlRun "cat $TmpDir/automount_location_del.out"


rlPhaseEnd
}

automountkey_del() {

rlPhaseStartTest "ipa-automountkey-del-001: ipa automountkey-del AUTOMOUNTLOCATION AUTOMOUNTMAP"

	rlRun "ipa automountlocation-add baltimore"
	rlRun "ipa automountkey-add baltimore auto.master --key=/share --info=-rw"

	rlRun "ipa automountkey-del baltimore auto.master --key=/share --info=-rw > $TmpDir/automountkey_del.out 2>&1"
	rlAssertGrep "Deleted automount key \"/share\"" "$TmpDir/automountkey_del.out"
	rlRun "cat $TmpDir/automountkey_del.out"

	rlRun "ipa automountkey-del baltimore auto.master --key=/share --info=-rw > $TmpDir/automountkey_del.out 2>&1" 2
	rlAssertGrep "ipa: ERROR: no such entry" "$TmpDir/automountkey_del.out"
	rlRun "cat $TmpDir/automountkey_del.out"

	rlRun "ipa automountlocation-del baltimore"

rlPhaseEnd
}

automountmap_del() {

rlPhaseStartTest "ipa-automountmap-del-001: ipa automountmap-del LOCATION MAP"

        rlRun "ipa automountlocation-add baltimore"
	rlRun "ipa automountmap-add baltimore auto.map1"
	rlRun "ipa automountmap-add baltimore auto.map2"

	rlRun "ipa automountmap-del baltimore auto.map1 > $TmpDir/automountmap_del.out 2>&1"
	rlAssertGrep "Deleted automount map \"auto.map1\"" "$TmpDir/automountmap_del.out"
	rlRun "cat $TmpDir/automountmap_del.out"

	rlRun "ipa automountmap-del baltimore auto.map1 auto.map2 > $TmpDir/automountmap_del.out 2>&1" 2
        rlAssertGrep "ipa: ERROR: auto.map1: automount map not found" "$TmpDir/automountmap_del.out"
        rlRun "cat $TmpDir/automountmap_del.out"

        rlRun "ipa automountmap-del baltimore auto.map1 auto.map2 --continue > $TmpDir/automountmap_del.out 2>&1"
        rlAssertGrep "Deleted automount map \"auto.map2\"" "$TmpDir/automountmap_del.out"
	rlAssertGrep "Failed to remove: auto.map1" "$TmpDir/automountmap_del.out"

rlPhaseEnd
}

bz725433() {

rlPhaseStartTest "ipa-automount-bugzilla-001: bz725433 automountmap gets added even though the return code is 1"

	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=725433"
	rlRun "ipa automountlocation-del baltimore"

	rlRun "ipa automountlocation-add baltimore"
        rlRun "ipa automountmap-add baltimore auto.share"
	rlRun "ipa automountkey-add baltimore auto.master --key=/share --info=auto.share"
	rlRun "ipa automountmap-add-indirect baltimore auto.share2 --mount=/usr/share/man"
	rlRun "ipa automountmap-add-indirect baltimore auto.share3 --mount=/usr/share/man" 1

	rlRun "/usr/bin/ldapsearch  -LLL -x -h localhost -D \"cn=Directory Manager\" -w Secret123 -b $basedn \"(&(objectclass=automountmap)(automountMapName=auto.share3))\" | grep auto.share3" 1

	rlRun "ipa automountlocation-del baltimore"

rlPhaseEnd
}

bz726725() {

rlPhaseStartTest "ipa-automount-bugzilla-002: bz726725 Error message states 'automountmapautomountmapname' while add/mod/del automountkey with empty automountmap name."

	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=726725"

	rlRun "ipa automountlocation-add pune"

	rlRun "interactive ipa automountkey-add pune"
	rlAssertGrep "ipa: ERROR: 'automountmap' is required" "/tmp/interactive.out"

	rlRun "interactive ipa automountkey-del pune"
	rlAssertGrep "ipa: ERROR: 'automountmap' is required" "/tmp/interactive.out"

	rlRun "interactive ipa automountkey-mod pune"
	rlAssertGrep "ipa: ERROR: 'automountmap' is required" "/tmp/interactive.out"

	rlRun "interactive ipa automountkey-find pune"
	rlAssertGrep "ipa: ERROR: 'automountmap' is required" "/tmp/interactive.out"

	rlRun "interactive ipa automountkey-show pune"
	rlAssertGrep "ipa: ERROR: 'automountmap' is required" "/tmp/interactive.out"

	rlRun "ipa automountlocation-del pune"
}

bz726722() {

rlPhaseStartTest "ipa-automount-bugzilla-003: bz726722 Error message states 'automountlocationcn' while add/mod/del automountmap or automountkey with empty location."

	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=726722"

	rlRun "interactive ipa automountmap-add"
	rlAssertGrep "ipa: ERROR: 'automountlocation' is required" "/tmp/interactive.out"

	rlRun "interactive ipa automountkey-add"
	rlAssertGrep "ipa: ERROR: 'automountlocation' is required" "/tmp/interactive.out"

	rlRun "interactive ipa automountmap-del"
	rlAssertGrep "ipa: ERROR: 'automountlocation' is required" "/tmp/interactive.out"

	rlRun "interactive ipa automountkey-del"
	rlssertGrep "ipa: ERROR: 'automountlocation' is required" "/tmp/interactive.out"
}


cleanup() {
rlPhaseStartCleanup "Clean up for automount configuration tests"
	rlRun "kinitAs $ADMINID $ADMINPW" 0
	rlRun "ipa user-del $user1"
	sleep 5
	rlRun "ipa user-del $user2"
	rlRun "kdestroy" 0 "Destroying admin credentials."

        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlRun "rm -fr /tmp/krb5_1*"
rlPhaseEnd
}
