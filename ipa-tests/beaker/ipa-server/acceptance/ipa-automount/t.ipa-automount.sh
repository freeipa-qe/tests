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
direct_mount="/direct_mount"
#RELM="RHTS-ENG-BRQ-REDHAT-COM"
basedn=`getBaseDN`

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"

setup() {
rlPhaseStartTest "Setup for automount configuration tests"
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

rlPhaseStartTest "automount_001: Schema file check."

	rlRun "rlAssertExists /etc/dirsrv/slapd-$RELM/schema/60autofs.ldif"

rlPhaseEnd
}

automount_002() {

rlPhaseStartTest "automount_002: ipa help automount."

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

rlPhaseStartTest "ipa help automountkey-add"

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

rlPhaseStartTest "automount_004: ipa help automountkey-del"

        rlRun "ipa help automountkey-del > $TmpDir/automount_004.out"

        rlAssertGrep "Usage: ipa \[global-options\] automountkey-del AUTOMOUNTLOCATION AUTOMOUNTMAP \[options\]" "$TmpDir/automount_004.out"
        rlAssertGrep "\-h, \--help     show this help message and exit" "$TmpDir/automount_004.out"
        rlAssertGrep "\--continue     Continuous mode: Don't stop on errors." "$TmpDir/automount_004.out"
        rlAssertGrep "\--key=IA5STR   Automount key name." "$TmpDir/automount_004.out"
        rlAssertGrep "\--info=IA5STR  Mount information" "$TmpDir/automount_004.out"

	rlRun "cat $TmpDir/automount_004.out"

rlPhaseEnd
}

automount_005() {

rlPhaseStartTest "automount_005: ipa help automountkey-find"

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

rlPhaseStartTest "automount_006: ipa help automountkey-mod"

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

rlPhaseStartTest "automount_007: ipa help automountkey-show"

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

rlPhaseStartTest "automount_008: ipa help automountlocation-add"

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

rlPhaseStartTest "automount_009: ipa help automountlocation-del"

	rlRun "ipa help automountlocation-del > $TmpDir/automount_009.out 2>&1"

	rlAssertGrep "Purpose: Delete an automount location." "$TmpDir/automount_009.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountlocation-del LOCATION... \[options\]" "$TmpDir/automount_009.out"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/automount_009.out"
	rlAssertGrep "\--continue  Continuous mode: Don't stop on errors." "$TmpDir/automount_009.out"

	rlRun "cat $TmpDir/automount_009.out"

rlPhaseEnd
}

automount_010() {

rlPhaseStartTest "automount_010: ipa help automountlocation-find"

	rlRun "ipa help automountlocation-find > $TmpdDir/automount_010.out 2>&1"

	rlAssertGrep "Purpose: Search for an automount location." "$TmpdDir/automount_010.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountlocation-find \[CRITERIA\] \[options\]" "$TmpdDir/automount_010.out"
	rlAssertGrep "\-h, \--help       show this help message and exit" "$TmpdDir/automount_010.out"
	rlAssertGrep "\--location=STR   Automount location name." "$TmpdDir/automount_010.out"
	rlAssertGrep "\--timelimit=INT  Time limit of search in seconds" "$TmpdDir/automount_010.out"
	rlAssertGrep "\--sizelimit=INT  Maximum number of entries returned" "$TmpdDir/automount_010.out"
	rlAssertGrep "\--all            Retrieve and print all attributes from the server." "$TmpdDir/automount_010.out"
	rlAssertGrep "\--raw            Print entries as stored on the server." "$TmpdDir/automount_010.out"

	rlRun "cat $TmpdDir/automount_010.out"

rlPhaseEnd
}

automount_011() {

rlPhaseStartTest "automount_011: ipa help automountlocation-import"

	rlRun "ipa help automountlocation-import > $TmpDir/automount_011.out 2>&1"

	rlAssertGrep "Purpose: Import automount files for a specific location." "$TmpDir/automount_011.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountlocation-import LOCATION MASTERFILE \[options\]" "$TmpDir/automount_011.out"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/automount_011.out"
	rlAssertGrep "\--continue  Continuous operation mode." "$TmpDir/automount_011.out"

	rlRun "cat $TmpDir/automount_011.out"

rlPhaseEnd
}

automount_012() {

rlPhaseStartTest "automount_012: ipa help automountlocation-show"

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

rlPhaseStartTest "automount_013: ipa help automountlocation-tofiles"

	rlRun "ipa help automountlocation-tofiles > $TmpDir/automount_013.out 2>&1"

	rlAssertGrep "Purpose: Generate automount files for a specific location." "$TmpDir/automount_013.out"
	rlAssertGrep "Usage: ipa \[global-options\] automountlocation-tofiles LOCATION \[options\]" "$TmpDir/automount_013.out"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/automount_012.out"

	rlRun "cat $TmpDir/automount_013.out"

rlPhaseEnd
}

automount_014() {

rlPhaseStartTest "automount_014: ipa help automountmap-add"

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

rlPhaseStartTest "automount_015: ipa help automountmap-add-indirect"

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

rlPhaseStartTest "automount_016: ipa help automountmap-del"

	rlRun "ipa help automountmap-del > $TmpDir/automount_016.out 2>&1"

        rlAssertGrep "Purpose: Delete an automount map." "$TmpDir/automount_016.out"
        rlAssertGrep "Usage: ipa \[global-options\] automountmap-del AUTOMOUNTLOCATION MAP... \[options\]" "$TmpDir/automount_016.out"
        rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/automount_016.out"
        rlAssertGrep "\--continue  Continuous mode: Don't stop on errors." "$TmpDir/automount_016.out"

	rlRun "cat $TmpDir/automount_016.out"

rlPhaseEnd
}

automount_017() {

rlPhaseStartTest "automount_017: ipa help automountmap-find"

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

rlPhaseStartTest "automount_018: ipa help automountmap-mod"

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

rlPhaseStartTest "automount_019: ipa help automountmap-show"

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

rlPhaseStartTest "automount_location_add_001: ipa automountlocation-add LOCATION"

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

rlPhaseStartTest "automount_location_add_002: ipa automountlocation-add LOCATION --all"

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

rlPhaseStartTest "automount_location_add_003: ipa automountlocation-add LOCATION --all --raw"

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

rlPhaseStartTest "automount_location_find_001: ipa automountlocation-find"

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

rlPhaseStartTest "automount_location_find_002: ipa automountlocation-find LOCATION"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountlocation-find pune > $TmpDir/automount_location_find_002.out 2>&1"
        rlAssertGrep "Location: pune" "$TmpDir/automount_location_find_002.out"
	rlAssertGrep "Number of entries returned 1" "$TmpDir/automount_location_find_002.out"

	rlRun "cat $TmpDir/automount_location_find_002.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_find_003() {

rlPhaseStartTest "automount_location_find_003: ipa automountlocation-find --location"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountlocation-find --location=pune > $TmpDir/automount_location_find_003.out 2>&1"
        rlAssertGrep "Location: pune" "$TmpDir/automount_location_find_003.out"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/automount_location_find_003.out"

	rlRun "cat $TmpDir/automount_location_find_003.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_find_004() {

rlPhaseStartTest "automount_location_find_004: ipa automountlocation-find --location --all"

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

rlPhaseStartTest "automount_location_find_005: ipa automountlocation-find --location --all --raw"

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

automount_location_show_001() {

rlPhaseStartTest "automount_location_show_001: ipa automountlocation-show LOCATION"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountlocation-show pune > $TmpDir/automount_location_show_001.out 2>&1"
	rlAssertGrep "Location: pune" "$TmpDir/automount_location_show_001.out"

	rlRun "cat $TmpDir/automount_location_show_001.out"
	rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automount_location_show_002() {

rlPhaseStartTest "automount_location_show_002: ipa automountlocation-show LOCATION --all"

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

rlPhaseStartTest "automount_location_show_003: ipa automountlocation-show LOCATION --all --raw"

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

rlPhaseStartTest "automount_location_show_004: ipa automountlocation-show LOCATION --all --raw --rights"

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

rlPhaseStartTest "automountmap_add_001: ipa automountmap-add LOCATION MAP"

	rlRun "ipa automountlocation-add pune"

	rlRun "ipa automountmap-add pune auto.pune > $TmpDir/automountmap_add_001.out 2>&1"
	rlAssertGrep "Added automount map \"auto.pune\"" "$TmpDir/automountmap_add_001.out"
	rlAssertGrep "Map: pune.map" "$TmpDir/automountmap_add_001.out"

	rlRun "cat $TmpDir/automountmap_add_001.out"
	rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_add_002() {

rlPhaseStartTest "automountmap_add_002: ipa automountmap-add LOCATION MAP --all"

	rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountmap-add pune auto.pune --all > $TmpDir/automountmap_add_002.out 2>&1"
        rlAssertGrep "Added automount map \"auto.pune\"" "$TmpDir/automountmap_add_002.out"
	rlAssertGrep "dn: automountmapname=auto.pune,cn=pune,cn=automount,$basedn" "$TmpDir/automountmap_add_002.out"
        rlAssertGrep "automountmapname: auto.pune" "$TmpDir/automountmap_add_002.out"
        rlAssertGrep "objectclass: automountmap, top" "$TmpDir/automountmap_add_002.out"

        rlRun "cat $TmpDir/automountmap_add_002.out"
        rlRun "ipa automountlocation-del pune"

rlPhaseEnd
}

automountmap_add_003() {

rlPhaseStartTest "automountmap_add_003: ipa automountmap-add LOCATION MAP --all --raw"

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

rlPhaseStartTest "automountmap_add_004: ipa automountmap-add LOCATION MAP --all --raw --desc"

        rlRun "ipa automountlocation-add pune"

        rlRun "ipa automountmap-add pune auto.pune --all --raw --desc=\"pune automount map\" > > $TmpDir/automountmap_add_004.out 2>&1"
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




automount_location_del_001() {

rlPhaseStartTest "automount_location_del_001: ipa automountlocation-del LOCATION - BZ 723778"

	rlRun "ipa automountlocation-add pune"
	rlRun "ipa automountlocation-del pune > $TmpDir/automount_location_del.out 2>&1"
	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug?id=723778"
	rlAssertGrep "Deleted automount location \"pune\"" "$TmpDir/automount_location_del.out"

        rlRun "cat $TmpDir/automount_location_del.out"

rlPhaseEnd
}

automount_location_del_002() {

rlPhaseStartTest "automount_location_del_002: ipa automountlocation-del LOCATION"

	rlRun "ipa automountlocation-add pune"
	rlRun "ipa automountlocation-del pune"
        rlRun "ldapsearch -LLL -x -h localhost  -b cn=pune,cn=automount,$basedn > $TmpDir/automount_location_del.out 2>&1" 32
        
        rlAssertNotGrep "dn: cn=pune,cn=automount,dc=rhts,dc=eng,dc=brq,dc=redhat,dc=com" "$TmpDir/automount_location_del.out"
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

cleanup() {
rlPhaseStartTest "Clean up for automount configuration tests"
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
