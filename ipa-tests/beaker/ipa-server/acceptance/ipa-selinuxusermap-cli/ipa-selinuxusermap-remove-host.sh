#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-host-remove-cli
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-remove-host    Remove target hosts and hostgroups from an SELinux User Map rule.
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

default_selinuxuser="unconfined_u:s0-s0:c0.c1023"
host1="devhost."$DOMAIN
host2="qe-blade-0008."$DOMAIN
host3="switch."$DOMAIN
host4="qe-blade-0005."$DOMAIN
host5="qe-blade-0006."$DOMAIN
hostgroup1="dev_hosts"
hostgroup2="ipaqe_hosts"
hostgroup3="csqe_hosts"
hostgroup4="dsqe_hosts"
hostgroup5="desktopqe_hosts"

########################################################################

run_selinuxusermap_remove_host_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-host-remove-cli-startup: Create temp directory and Kinit"
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

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-configtest: ipa help selinuxusermap-remove-host"
	rlRun "ipa help selinuxusermap-remove-host > $TmpDir/selinuxusermap-remove-host_cfg.out"
	rlRun "cat $TmpDir/selinuxusermap-remove-host_cfg.out"
	rlAssertGrep "Purpose: Remove target hosts and hostgroups from an SELinux User Map rule." "$TmpDir/selinuxusermap-remove-host_cfg.out"
	rlAssertGrep "Usage: ipa \[global-options\] selinuxusermap-remove-host NAME \[options\]" "$TmpDir/selinuxusermap-remove-host_cfg.out"
	rlAssertGrep "Positional arguments:
  NAME              Rule name" "$TmpDir/selinuxusermap-remove-host_cfg.out"
	rlAssertGrep "\-h, \--help        show this help message and exit" "$TmpDir/selinuxusermap-remove-host_cfg.out"
	rlAssertGrep "\--all             Retrieve and print all attributes from the server. Affects
                    command output." "$TmpDir/selinuxusermap-remove-host_cfg.out"
	rlAssertGrep "\--raw             Print entries as stored on the server. Only affects output
                    format." "$TmpDir/selinuxusermap-remove-host_cfg.out"
	rlAssertGrep "\--hosts=STR       comma-separated list of hosts to remove" "$TmpDir/selinuxusermap-remove-host_cfg.out"
	rlAssertGrep "\--hostgroups=STR  comma-separated list of host groups to remove" "$TmpDir/selinuxusermap-remove-host_cfg.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-001: Remove a host from the se-linux usermap"
	rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Add a selinuxusermap"	
	rlRun "ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap1" 0 "Add host $host1 to selinuxusermap"
	rlRun "ipa selinuxusermap-remove-host --hosts=$host1 $selinuxusermap1 > $TmpDir/selinuxusermap-remove-host-001.out" 0 "Remove host $host1 from selinuxusermap"
	rlAssertNotGrep "Hosts: $host1" "$TmpDir/selinuxusermap-remove-host-001.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-002: Remove a host that does not exit from a selinuxusermap"
	rlRun "ipa selinuxusermap-remove-host --hosts=$host1 $selinuxusermap1 >  $TmpDir/selinuxusermap-host-remove-002.out" 1 "Remove host $host1 from selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-host-remove-002.out"
	rlAssertGrep "member host: $host1: This entry is not a member" "$TmpDir/selinuxusermap-host-remove-002.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-003: Remove multiple hosts from  the se-linux usermap - all hosts removed successfully"
        rlRun "ipa selinuxusermap-add-host --hosts=$host1,$host2,$host3 $selinuxusermap1" 0 "Add hosts $host1 $host2 $host3 to selinuxusermap"
        rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-remove-host-003.out" 0 "Show selinuxusermap"
        rlAssertGrep "Hosts: $host1, $host2, $host3" "$TmpDir/selinuxusermap-remove-host-003.out"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1,$host2,$host3 $selinuxusermap1" 0 "Remove hosts from selinuxusermap"
        rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-remove-host-003_2.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-remove-host-003_2.out"
        rlAssertNotGrep "Hosts: $host1, $host2, $host3" "$TmpDir/selinuxusermap-remove-host-003_2.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-004: Remove multiple hosts from the se-linux usermap - not all hosts removed successfully"
        rlRun "ipa selinuxusermap-add-host --hosts=$host1,$host2,$host3  $selinuxusermap1 > $TmpDir/selinuxusermap-host-remove-004.out" 0 "Add hosts $host1 $host2 $host3 to selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-host-remove-004.out"
	rlAssertGrep "Number of members added 3" "$TmpDir/selinuxusermap-host-remove-004.out"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1,$host4,$host2,$host3,$host5 $selinuxusermap1 > $TmpDir/selinuxusermap-host-remove-004_2.out" 1 "Remove hosts $host1 $host4 $host2 $host3 $host5 from selinuxusermap"
	rlRun "cat  $TmpDir/selinuxusermap-host-remove-004_2.out"
	rlAssertGrep  "member host: $host4: This entry is not a member" "$TmpDir/selinuxusermap-host-remove-004_2.out"
	rlAssertGrep  "member host: $host5: This entry is not a member" "$TmpDir/selinuxusermap-host-remove-004_2.out"
	rlAssertGrep "Number of members removed 3" "$TmpDir/selinuxusermap-host-remove-004_2.out"
        rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-remove-host-show-004_3.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-remove-host-show-004_3.out"
        rlAssertNotGrep "Hosts: $host1, $host2, $host3" "$TmpDir/selinuxusermap-remove-host-show-004_3.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-005: Remove a host from selinuxusermap that's not associted with selinuxusermap"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1 $selinuxusermap1 >  $TmpDir/selinuxusermap-host-remove-005.out" 1 "Remove host $host1 from selinuxusermap"
	rlAssertGrep "member host: $host1: This entry is not a member" "$TmpDir/selinuxusermap-host-remove-005.out"
	rlAssertGrep "Number of members removed 0" "$TmpDir/selinuxusermap-host-remove-005.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-006: Remove host from a unkown selinuxusermap "
	command="ipa selinuxusermap-remove-host --hosts=$host1 unknown"
	expmsg="ipa: ERROR: unknown: SELinux User Map rule not found"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify add host to a unknown selinuxusermap fails"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-007: Remove host group from the se-linux usermap"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap2" 0 "Add a selinuxusermap"
        rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1 $selinuxusermap2" 0 "Add host group $hostgroup1 to selinuxusermap"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap2" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-host-remove-007.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-host-remove-007.out"
        rlAssertGrep "Host Groups: $hostgroup1" "$TmpDir/selinuxusermap-host-remove-007.out"
	rlRun "ipa selinuxusermap-remove-host --hostgroups=$hostgroup1 $selinuxusermap2" 0 "Remove host group $hostgroup1 from selinuxusermap"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-host-remove-007_2.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-host-remove-007_2.out"
        rlAssertNotGrep "Host Groups: $hostgroup1" "$TmpDir/selinuxusermap-host-remove-007_2.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-008: Remove a host group that does not exist"
        rlRun "ipa selinuxusermap-remove-host --hostgroups=$hostgroup1 $selinuxusermap2 >  $TmpDir/selinuxusermap-host-remove-008.out" 1 "Add host $hostgroup1 to selinuxusermap again"
	rlRun "cat $TmpDir/selinuxusermap-host-remove-008.out"
        rlAssertGrep "member host group: $hostgroup1: This entry is not a member" "$TmpDir/selinuxusermap-host-remove-008.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-009: Remove multiple host groups from the se-linux usermap - all hostgroups removed successfully"
        rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1,$hostgroup2,$hostgroup3  $selinuxusermap2" 0 "Add host groups $hostgroup1 $hostgroup2 $hostgroup3 to $selinuxusermap2"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-add-host-009.out" 0 "Show $selinuxusermap2"
        rlRun "cat $TmpDir/selinuxusermap-add-host-009.out"
        rlAssertGrep "Host Groups: $hostgroup1, $hostgroup2, $hostgroup3" "$TmpDir/selinuxusermap-add-host-009.out"
        rlRun "ipa selinuxusermap-remove-host --hostgroups=$hostgroup1,$hostgroup2,$hostgroup3 $selinuxusermap2" 0 "Remove host groups from selinuxusermap"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-add-host-009_2.out" 0 "Show $selinuxusermap2"
        rlRun "cat $TmpDir/selinuxusermap-add-host-009_2.out"
        rlAssertNotGrep "Host Groups: $hostgroup1, $hostgroup2, $hostgroup3" "$TmpDir/selinuxusermap-add-host-009_2.out"
    rlPhaseEnd

   rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-010: Remove multiple host groups from the se-linux usermap - not all host groups removed successfully"
        rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1,$hostgroup2,$hostgroup3 $selinuxusermap2" 0 "Add host groups $hostgroup1 $hostgroup2 $hostgroup3 to $selinuxusermap2"
        rlRun "ipa selinuxusermap-remove-host --hostgroups=$hostgroup1,$hostgroup4,$hostgroup2,$hostgroup3,$hostgroup5 $selinuxusermap2 > $TmpDir/selinuxusermap-host-remove-010.out" 1 "Remove host groups $hostgroup1 $hostgroup4 $hostgroup2 $hostgroup3 $hostgroup5 from $selinuxusermap2"
        rlRun "cat $TmpDir/selinuxusermap-host-remove-010.out"
        rlAssertGrep  "member host group: $hostgroup4: This entry is not a member" "$TmpDir/selinuxusermap-host-remove-010.out"
        rlAssertGrep  "member host group: $hostgroup5: This entry is not a member" "$TmpDir/selinuxusermap-host-remove-010.out"
        rlAssertGrep "Number of members removed 3" "$TmpDir/selinuxusermap-host-remove-010.out"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-add-host-show-010.out" 0 "Show selinuxusermap"
        rlRun "cat $TmpDir/selinuxusermap-add-host-show-010.out"
        rlAssertNotGrep "Host Groups: $hostgroup1, $hostgroup2, $hostgroup3" "$TmpDir/selinuxusermap-add-host-show-010.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-011: Remove host group Category - unknown"
        rlRun "ipa selinuxusermap-remove-host --hostgroups=bad $selinuxusermap2 >  $TmpDir/selinuxusermap-host-remove-011.out" 1 "Remove unknown host group from selinuxusermap"
        rlAssertGrep "member host group: bad: This entry is not a member" "$TmpDir/selinuxusermap-host-remove-011.out"
        rlAssertGrep "Number of members removed 0" "$TmpDir/selinuxusermap-host-remove-011.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-012: Remove host group from an unkown selinuxusermap"
        command="ipa selinuxusermap-remove-host --hostgroups=$hostgroup1 unknown"
        expmsg="ipa: ERROR: unknown: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify add host to a unknown selinuxusermap fails"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-013: Remove host with all available attributes"
	rlRun "ipa selinuxusermap-add --selinuxuser=\"guest_u:s0\" $selinuxusermap3" 0 "Add a selinuxusermap"
        rlRun "ipa selinuxusermap-add-host --hosts=$host1 --hostgroups=$hostgroup1,$hostgroup2 --all --raw $selinuxusermap3" 0 "Add host $host1 and host group $hostgroup1 $hostgroup2 to selinuxusermap"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1 --hostgroups=$hostgroup1,$hostgroup2 --all --raw $selinuxusermap3 > $TmpDir/selinuxusermap-host-remove-013.out" 0 "Remove host $host1 and host group $hostgroup1 $hostgroup2 from selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-host-remove-013.out"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-host-remove-013.out"
        rlAssertNotGrep "memberhost: fqdn=$host1,cn=computers,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-remove-013.out"
        rlAssertNotGrep "memberhost: cn=$hostgroup1,cn=hostgroups,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-remove-013.out"
        rlAsserNottGrep "memberhost: cn=$hostgroup2,cn=hostgroups,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-remove-013.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-host-remove-013.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-host-remove-013.out"
        rlRun "ipa selinuxusermap-show $selinuxusermap3 > $TmpDir/selinuxusermap-add-host-show-013.out" 0 "Show selinuxusermap"
        rlRun "cat $TmpDir/selinuxusermap-add-host-show-013.out"
        rlAssertNotGrep "Hosts: $host1" "$TmpDir/selinuxusermap-add-host-show-013.out"
        rlAssertNotGrep "Host Groups: $hostgroup1, $hostgroup2" "$TmpDir/selinuxusermap-add-host-show-013.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-014: Remove a host with a empty string"
	rlRun "ipa selinuxusermap-remove-host --hosts=\"\" $selinuxusermap3 > $TmpDir/selinuxusermap-host-remove-014.out" 0 "Remove host with empty string from selinuxusermap"
	rlAssertGrep "Number of members removed 0" "$TmpDir/selinuxusermap-host-remove-014.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-015: Remove a host groups with a empty string"
        rlRun "ipa selinuxusermap-remove-host --hostgroups=\"\" $selinuxusermap3 > $TmpDir/selinuxusermap-host-remove-015.out" 0 "Remove host group with empty string from selinuxusermap"
        rlAssertGrep "Number of members removed 0" "$TmpDir/selinuxusermap-host-remove-015.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-016: Remove a host with --all option"
        rlLog "Executing:  ipa selinuxusermap-add-host --hosts=$host1 --all $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-host --hosts=$host1 --all $selinuxusermap3" 0 "Add a host with --all option"
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1 --all $selinuxusermap3  > $TmpDir/selinuxusermap-host-remove-016.out" 0 "Remove a host with --all option"
        rlAssertGrep "Rule name: $selinuxusermap3" "$TmpDir/selinuxusermap-host-remove-016.out"
        rlAssertGrep "objectclass: ipaassociation, ipaselinuxusermap" "$TmpDir/selinuxusermap-host-remove-016.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/selinuxusermap-host-remove-016.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-017: Remove a host with --raw option without --all"
        rlLog "Executing:  ipa selinuxusermap-add-host --hosts=$host1 --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-host --hosts=$host1 --raw $selinuxusermap3" 0 "Add a host"
        rlLog "Executing:  ipa selinuxusermap-remove-host --hosts=$host1 --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1 --raw $selinuxusermap3  > $TmpDir/selinuxusermap-host-remove-017.out" 0 "Remove a host with --raw option"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-host-remove-017.out"
        rlAsserNottGrep "memberhost: fqdn=$host1,cn=computers,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-remove-017.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/selinuxusermap-host-remove-017.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-018: Remove a host with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-add-host --hosts=$host1 --all --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-host --hosts=$host1 --all --raw $selinuxusermap3" 0 "Add a host with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-remove-host --hosts=$host1 --all --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-remove-host --hosts=$host1 --all --raw $selinuxusermap3  > $TmpDir/selinuxusermap-host-remove-018.out" 0 "Remove a host with --all --raw option"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-host-remove-018.out"
        rlAssertNotGrep "memberhost: fqdn=$host1,cn=computers,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-remove-018.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-host-remove-018.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-host-remove-018.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/selinuxusermap-host-remove-018.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-host-remove-cli-019: Remove a host group with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-add-host --hostgroups=$hostgroup1 --all --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1 --all --raw $selinuxusermap3" 0 "Add a host group with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-remove-host --hostgroups=$hostgroup1 --all --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-remove-host --hostgroups=$hostgroup1 --all --raw $selinuxusermap3  > $TmpDir/selinuxusermap-host-remove-019.out" 0 "Remove a host group with --all --raw option"
	rlRun "cat $TmpDir/selinuxusermap-host-remove-019.out"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-host-remove-019.out"
        rlAssertNotGrep "memberhost: cn=$hostgroup1,cn=hostgroups,cn=accounts,$basedn" "$TmpDir/selinuxusermap-host-remove-019.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-host-remove-019.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-host-remove-019.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/selinuxusermap-host-remove-019.out"
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-selinuxusermap-host-remove-cli-cleanup: Destroying admin credentials."
	# delete selinux user 
	for item in $selinuxusermap1 $selinuxusermap2 $selinuxusermap3 ; do
		rlRun "ipa selinuxusermap-del $item" 0 "CLEANUP: Deleting selinuxuser $item"
	done
	for item in $host1 $host2 $host3; do
		rlRun "deleteHost $item" 0 "Deleting Host associated with rule."
	done
	for item in $hostgroup1 $hostgroup2 $hostgroup3; do
		rlRun "deleteHostGroup $item" 0 "Deleting Host Group associated with rule."
	done
	rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing temp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
