#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-host-add-cli
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-add-host    Add target hosts and hostgroups to an SELinux User Map rule.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Asha Akkiangady <aakkiang@redhat.com>
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
. /opt/rhqa_ipa/ipa-host-cli-lib.sh
. /opt/rhqa_ipa/ipa-group-cli-lib.sh
. /opt/rhqa_ipa/ipa-hostgroup-cli-lib.sh
. /opt/rhqa_ipa/ipa-hbac-cli-lib.sh
. /opt/rhqa_ipa/ipa-selinuxusermap-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

########################################################################
# Test Suite Globals
########################################################################

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`
basedn=`getBaseDN`

selinuxusermap1="testselinuxusermap1"
selinuxusermap2="testselinuxusermap2"
selinuxusermap3="testselinuxusermap3"
selinuxusermap4="testselinuxusermap4"
selinuxusermap5="testselinuxusermap5"
selinuxusermap6="testselinuxusermap6"

default_selinuxuser="unconfined_u:s0-s0:c0.c1023"
host1="devhost."$DOMAIN
host2="qe-blade-00008."$DOMAIN
host3="switch."$DOMAIN
host4="qe-blade-0005."$DOMAIN
host5="qe-blade-0006."$DOMAIN
hostgroup1="dev_hosts"
hostgroup2="ipaqe_hosts"
hostgroup3="csqe_hosts"
hostgroup4="dsqe_hosts"
hostgroup5="desktopqe_hosts"

########################################################################

run_selinuxusermap_add_host_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-host-add-cli-startup: Create temp directory and Kinit"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	# add host for testing
        rlRun "addHost $host1" 0 "SETUP: Adding host $host1 for testing."
        rlRun "addHost $host2" 0 "SETUP: Adding host $host2 for testing."
        rlRun "addHost $host3" 0 "SETUP: Adding host $host3 for testing."
        # add host group for testing
        rlRun "addHostGroup $hostgroup1 $hostgroup1" 0 "SETUP: Adding host group $hostgroup1 for testing."
        rlRun "addHostGroup $hostgroup2 $hostgroup2" 0 "SETUP: Adding host group $hostgroup2 for testing."
        rlRun "addHostGroup $hostgroup3 $hostgroup3" 0 "SETUP: Adding host group $hostgroup3 for testing."
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-configtest: ipa help selinuxusermap-add-host"
	rlRun "ipa help selinuxusermap-add-host > $TmpDir/selinuxusermap-add-host_cfg.out"
	rlRun "cat $TmpDir/selinuxusermap-add-host_cfg.out"
	rlAssertGrep "Purpose: Add target hosts and hostgroups to an SELinux User Map rule." "$TmpDir/selinuxusermap-add-host_cfg.out"
	rlAssertGrep "Usage: ipa \[global-options\] selinuxusermap-add-host NAME \[options\]" "$TmpDir/selinuxusermap-add-host_cfg.out"
	rlAssertGrep "Positional arguments:
  NAME              Rule name" "$TmpDir/selinuxusermap-add-host_cfg.out"
	rlAssertGrep "\-h, \--help        show this help message and exit" "$TmpDir/selinuxusermap-add-host_cfg.out"
	rlAssertGrep "\--all             Retrieve and print all attributes from the server. Affects
                    command output." "$TmpDir/selinuxusermap-add-host_cfg.out"
	rlAssertGrep "\--raw             Print entries as stored on the server. Only affects output
                    format." "$TmpDir/selinuxusermap-add-host_cfg.out"
	rlAssertGrep "\--hosts=STR       comma-separated list of hosts to add" "$TmpDir/selinuxusermap-add-host_cfg.out"
	rlAssertGrep "\--hostgroups=STR  comma-separated list of host groups to add" "$TmpDir/selinuxusermap-add-host_cfg.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-001: Add a host to the se-linux usermap"
	rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Add a selinuxusermap"	
	rlRun "ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap1" 0 "Add host $host1 to selinuxusermap"
	rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Verifying selinuxusermap was added with given selinuxuser"
	rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-add-host-001.out" 0 "Show selinuxusermap"
	rlAssertGrep "Hosts: $host1" "$TmpDir/selinuxusermap-add-host-001.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-002: Add a duplicate host to the se-linux usermap"
	rlRun "ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap1 >  $TmpDir/selinuxusermap-host-add-002.out" 1 "Add host $host1 to selinuxusermap again"
	rlAssertGrep "member host: $host1: This entry is already a member" "$TmpDir/selinuxusermap-host-add-002.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-003:  Remove hosts from the se-linux usermap"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1 $selinuxusermap1" 0 "Delete host from selinuxusermap"
	rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-add-host-003.out" 0 "Show selinuxusermap"
	rlAssertNotGrep "Hosts: $host1" "$TmpDir/selinuxusermap-add-host-003.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-004: Add multiple hosts to the se-linux usermap - all hosts added successfully"
        rlRun "ipa selinuxusermap-add-host --hosts=$host1,$host2,$host3 $selinuxusermap1" 0 "Add hosts $host1 $host2 $host3 to selinuxusermap"
        rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-add-host-004.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-add-host-004.out"
        rlAssertGrep "Hosts: $host1, $host2, $host3" "$TmpDir/selinuxusermap-add-host-004.out"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1,$host2,$host3 $selinuxusermap1" 0 "Delete host from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-005: Add multiple hosts to the se-linux usermap - not all hosts added successfully"
        rlRun "ipa selinuxusermap-add-host --hosts=$host1,$host4,$host2,$host3,$host5 $selinuxusermap1 > $TmpDir/selinuxusermap-host-add-005.out" 1 "Add hosts $host1 $host4 $host2 $host3 $host5 to selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-host-add-005.out"
	rlAssertGrep  "member host: $host4: no such entry" "$TmpDir/selinuxusermap-host-add-005.out"
	rlAssertGrep  "member host: $host5: no such entry" "$TmpDir/selinuxusermap-host-add-005.out"
	rlAssertGrep "Number of members added 3" "$TmpDir/selinuxusermap-host-add-005.out"
        rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-add-host-show-005.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-add-host-show-005.out"
        rlAssertGrep "Hosts: $host1, $host2, $host3" "$TmpDir/selinuxusermap-add-host-show-005.out"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1,$host2,$host3 $selinuxusermap1" 0 "Delete hosts from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-006: Add host Category - unknown"
        rlRun "ipa selinuxusermap-add-host --hosts=bad $selinuxusermap1 >  $TmpDir/selinuxusermap-host-add-006.out" 1 "Add unknown host to selinuxusermap"
	rlAssertGrep "member host: bad: no such entry" "$TmpDir/selinuxusermap-host-add-006.out"
	rlAssertGrep "Number of members added 0" "$TmpDir/selinuxusermap-host-add-006.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-007: Add host to a unkown selinuxusermap "
	command="ipa selinuxusermap-add-host --hosts=$host1 unknown"
	expmsg="ipa: ERROR: unknown: SELinux User Map rule not found"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify add host to a unknown selinuxusermap fails"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-008: Add a host group to the se-linux usermap"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap2" 0 "Add a selinuxusermap"
        rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1 $selinuxusermap2" 0 "Add host group $hostgroup1 to selinuxusermap"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap2" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-add-host-008.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-add-host-008.out"
        rlAssertGrep "Host Groups: $hostgroup1" "$TmpDir/selinuxusermap-add-host-008.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-009: Add a duplicate host  group to the se-linux usermap"
        rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1 $selinuxusermap2 >  $TmpDir/selinuxusermap-host-add-009.out" 1 "Add host $hostgroup1 to selinuxusermap again"
	rlRun "cat $TmpDir/selinuxusermap-host-add-009.out"
        rlAssertGrep "member host group: $hostgroup1: This entry is already a member" "$TmpDir/selinuxusermap-host-add-009.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-010:  Remove host group from the se-linux usermap"
        rlRun "ipa selinuxusermap-remove-host --hostgroups=$hostgroup1 $selinuxusermap2" 0 "Delete host group from selinuxusermap"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-add-host-010.out" 0 "Show selinuxusermap"
        rlAssertNotGrep "Host Groups: $hostgroup1" "$TmpDir/selinuxusermap-add-host-010.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-011: Add multiple host groups to the se-linux usermap - all hostgroups added successfully"
        rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1,$hostgroup2,$hostgroup3  $selinuxusermap2" 0 "Add host groups $hostgroup1 $hostgroup2 $hostgroup3 to $selinuxusermap2"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-add-host-011.out" 0 "Show $selinuxusermap2"
        rlRun "cat $TmpDir/selinuxusermap-add-host-011.out"
        rlAssertGrep "Host Groups: $hostgroup1, $hostgroup2, $hostgroup3" "$TmpDir/selinuxusermap-add-host-011.out"
        rlRun "ipa selinuxusermap-remove-host --hostgroups=$hostgroup1,$hostgroup2,$hostgroup3 $selinuxusermap2" 0 "Delete host group from selinuxusermap"
    rlPhaseEnd

   rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-012: Add multiple host groups to the se-linux usermap - not all host groups added successfully"
        rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1,$hostgroup4,$hostgroup2,$hostgroup3,$hostgroup5 $selinuxusermap2 > $TmpDir/selinuxusermap-host-add-012.out" 1 "Add host groups $hostgroup1 $hostgroup4 $hostgroup2 $hostgroup3 $hostgroup5 to $selinuxusermap2"
        rlRun "cat $TmpDir/selinuxusermap-host-add-012.out"
        rlAssertGrep  "member host group: $hostgroup4: no such entry" "$TmpDir/selinuxusermap-host-add-012.out"
        rlAssertGrep  "member host group: $hostgroup5: no such entry" "$TmpDir/selinuxusermap-host-add-012.out"
        rlAssertGrep "Number of members added 3" "$TmpDir/selinuxusermap-host-add-012.out"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-add-host-show-012.out" 0 "Show selinuxusermap"
        rlRun "cat $TmpDir/selinuxusermap-add-host-show-012.out"
        rlAssertGrep "Host Groups: $hostgroup1, $hostgroup2, $hostgroup3" "$TmpDir/selinuxusermap-add-host-show-012.out"
        rlRun "ipa selinuxusermap-remove-host --hostgroups=$hostgroup1,$hostgroup2,$hostgroup3 $selinuxusermap2" 0 "Delete host group from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-013: Add host group Category - unknown"
        rlRun "ipa selinuxusermap-add-host --hostgroups=bad $selinuxusermap2 >  $TmpDir/selinuxusermap-host-add-013.out" 1 "Add unknown host group to selinuxusermap"
        rlAssertGrep "member host group: bad: no such entry" "$TmpDir/selinuxusermap-host-add-013.out"
        rlAssertGrep "Number of members added 0" "$TmpDir/selinuxusermap-host-add-013.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-014: Add host group to a unkown selinuxusermap"
        command="ipa selinuxusermap-add-host --hostgroups=$hostgroup1 unknown"
        expmsg="ipa: ERROR: unknown: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify add host to a unknown selinuxusermap fails"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-015: Add host with all available attributes"
	rlRun "ipa selinuxusermap-add --selinuxuser=\"guest_u:s0\" $selinuxusermap3" 0 "Add a selinuxusermap"
        rlRun "ipa selinuxusermap-add-host --hosts=$host1 --hostgroups=$hostgroup1,$hostgroup2 --all --raw $selinuxusermap3 > $TmpDir/selinuxusermap-host-add-015.out" 0 "Add host $host1 and host group $hostgroup1 to selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-host-add-015.out"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-host-add-015.out"
        rlAssertGrep "memberhost: fqdn=$host1,cn=computers,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-add-015.out"
        rlAssertGrep "memberhost: cn=$hostgroup1,cn=hostgroups,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-add-015.out"
        rlAssertGrep "memberhost: cn=$hostgroup2,cn=hostgroups,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-add-015.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-host-add-015.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-host-add-015.out"
        rlRun "ipa selinuxusermap-show $selinuxusermap3 > $TmpDir/selinuxusermap-add-host-show-015.out" 0 "Show selinuxusermap"
        rlRun "cat $TmpDir/selinuxusermap-add-host-show-015.out"
        rlAssertGrep "Hosts: $host1" "$TmpDir/selinuxusermap-add-host-show-015.out"
        rlAssertGrep "Host Groups: $hostgroup1, $hostgroup2" "$TmpDir/selinuxusermap-add-host-show-015.out"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1 $selinuxusermap3" 0 "Delete host from selinuxusermap"
        rlRun "ipa selinuxusermap-remove-host --hostgroups=$hostgroup1,$hostgroup2 $selinuxusermap3" 0 "Delete host groups from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-016: Add a host with a empty string"
	rlRun "ipa selinuxusermap-add-host --hosts=\"\" $selinuxusermap3 > $TmpDir/selinuxusermap-host-add-016.out" 0 "Add host with empty string to selinuxusermap"
	rlAssertGrep "Number of members added 0" "$TmpDir/selinuxusermap-host-add-016.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-017: Add a host groups with a empty string"
        rlRun "ipa selinuxusermap-add-host --hostgroups=\"\" $selinuxusermap3 > $TmpDir/selinuxusermap-host-add-017.out" 0 "Add host group with empty string to selinuxusermap"
        rlAssertGrep "Number of members added 0" "$TmpDir/selinuxusermap-host-add-017.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-018: Add a host with --all option"
        rlLog "Executing:  ipa selinuxusermap-add-host --hosts=$host1 --all $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-host --hosts=$host1 --all $selinuxusermap3  > $TmpDir/selinuxusermap-host-add-018.out" 0 "Add a host with --all option"
        rlAssertGrep "Rule name: $selinuxusermap3" "$TmpDir/selinuxusermap-host-add-018.out"
        rlAssertGrep "objectclass: ipaassociation, ipaselinuxusermap" "$TmpDir/selinuxusermap-host-add-018.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/selinuxusermap-host-add-018.out"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1 $selinuxusermap3" 0 "Clean-up: Delete host from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-019: Add a host with --raw option without --all"
        rlLog "Executing:  ipa selinuxusermap-add-host --hosts=$host1 --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-host --hosts=$host1 --raw $selinuxusermap3  > $TmpDir/selinuxusermap-host-add-019.out" 0 "Add a host with --raw option"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-host-add-019.out"
        rlAssertGrep "memberhost: fqdn=$host1,cn=computers,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-add-019.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/selinuxusermap-host-add-019.out"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1 $selinuxusermap3" 0 "Clean-up: Delete host from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-020: Add a host with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-add-host --hosts=$host1 --all --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-host --hosts=$host1 --all --raw $selinuxusermap3  > $TmpDir/selinuxusermap-host-add-020.out" 0 "Add a host with --all --raw option"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-host-add-020.out"
        rlAssertGrep "memberhost: fqdn=$host1,cn=computers,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-add-020.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-host-add-020.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-host-add-020.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/selinuxusermap-host-add-020.out"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1 $selinuxusermap3" 0 "Clean-up: Delete host from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-021: Add a host group with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-add-host --hostgroups=$hostgroup1 --all --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1 --all --raw $selinuxusermap3  > $TmpDir/selinuxusermap-host-add-021.out" 0 "Add a host group with --all --raw option"
	rlRun "cat $TmpDir/selinuxusermap-host-add-021.out"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-host-add-021.out"
        rlAssertGrep "memberhost: cn=$hostgroup1,cn=hostgroups,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-add-021.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-host-add-021.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-host-add-021.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/selinuxusermap-host-add-021.out"
        rlRun "ipa selinuxusermap-remove-host --hostgroups=$hostgroup1 $selinuxusermap3" 0 "Clean-up: Delete host group from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-022: Add a host when selinuxusermap already has a hbacrule defined"
	rlRun "ipa hbacrule-add rule1"
	rlRun "ipa hbacrule-add-host rule1 --hosts=$host1"
	rlRun "ipa hbacrule-add-sourcehost rule1 --hosts=$host1"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=rule1 $selinuxusermap4"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=rule1 $selinuxusermap4" 0 "Add a selinuxusermap with hbacrule"
        rlRun "findSelinuxusermap $selinuxusermap4" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap4" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "findSelinuxusermapByOption hbacrule rule1 $selinuxusermap4" 0 "Verifying selinuxusermap was added with given HbacRule"
	command="ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap4"
        expmsg="ipa: ERROR: HBAC rule and local members cannot both be set"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify add host to a unknown selinuxusermap fails"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-023:  Selinux user map rule sets all users to xguest_u:s0 on the new host"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\xguest_u:s0\" --usercat=all $selinuxusermap5"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"xguest_u:s0\" --usercat=all $selinuxusermap5" 0 "Add a selinuxusermap with --usercat all"
        rlRun "findSelinuxusermap $selinuxusermap5" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "findSelinuxusermapByOption selinuxuser \"xguest_u:s0\" $selinuxusermap5" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "findSelinuxusermapByOption usercat all $selinuxusermap5" 0 "Verifying selinuxusermap was added with usercat"
        rlLog "Executing:ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap5"
        rlRun "ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap5 > $TmpDir/selinuxusermap-host-add-023.out" 0 "Add a host to selinuxusermap"
	rlLog "cat $TmpDir/selinuxusermap-host-add-023.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/selinuxusermap-host-add-023.out"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1 $selinuxusermap5" 0 "Clean-up: Delete host from selinuxusermap"
    rlPhaseEnd

     rlPhaseStartTest "ipa-selinuxusermap-host-add-cli-024: Add host group and a host that's is part of the hostgroup to the se-linux usermap"
	rlRun "ipa hostgroup-add-member --hosts=$host1 $hostgroup1" 0 "Add $host1 to $hostgroup1"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap6" 0 "Add a selinuxusermap"
        rlRun "ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap6" 0 "Add host $host1 to selinuxusermap"
        rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1 $selinuxusermap6" 0 "Add host group $hostgroup1 to selinuxusermap"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap6" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "ipa selinuxusermap-show $selinuxusermap6 > $TmpDir/selinuxusermap-add-host-024.out" 0 "Show selinuxusermap"
        rlRun "cat $TmpDir/selinuxusermap-add-host-024.out"
	rlAssertGrep "Hosts: $host1" "$TmpDir/selinuxusermap-add-host-024.out"
        rlAssertGrep "Host Groups: $hostgroup1" "$TmpDir/selinuxusermap-add-host-024.out"
	rlRun "ipa hostgroup-remove-member --hosts=$host1 $hostgroup1" 0 "Clean-up: Remove $host1 from $hostgroup1"
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-selinuxusermap-host-add-cli-cleanup: Destroying admin credentials."
	# delete selinux user 
	for item in $selinuxusermap1 $selinuxusermap2 $selinuxusermap3 $selinuxusermap4 $selinuxusermap5 $selinuxusermap6; do
		rlRun "ipa selinuxusermap-del $item" 0 "CLEANUP: Deleting selinuxuser $item"
	done
	for item in $host1 $host2 $host3; do
		rlRun "deleteHost $item" 0 "Deleting Host associated with rule."
	done
	for item in $hostgroup1 $hostgroup2 $hostgroup3; do
		rlRun "deleteHostGroup $item" 0 "Deleting Host Group associated with rule."
	done
	rlRun "deleteHBACRule rule1" 0 "Deleting hbac rule1"
	rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing temp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
