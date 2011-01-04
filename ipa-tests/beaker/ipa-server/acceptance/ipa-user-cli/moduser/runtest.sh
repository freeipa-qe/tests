#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-user-cli/moduser
#   Description: IPA user cli acceptance tests - Modify User
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#   user-mod     Modify a user.
#   user-show    Display information about a user.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Yi Zhang <yzhang@redhat.com>
#   Date  : Sept 10, 2010
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

# Include data-driven test data file:
. ./data.user-cli.acceptance

# Include rhts and ipa environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/env.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/lib.user-cli.sh
. /dev/shm/ipa-group-cli-lib.sh


BASEDN="dc=$RELM"
GROUPRDN="cn=groups,cn=accounts,"
GROUPDN="$GROUPRDN$BASEDN"
echo "GROUPDN is $USERDN"
echo "Server is $MASTER"

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup "ipa-user-cli-mod-startup: Check for ipa-admintools, kinit as admin and add test user"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
        kinitAs $ADMINID $ADMINPW
        if [ $? -ne 0 ];then
            rlFail "kinit as $ADMINID failed"
        else
            rlPass "kinit as $ADMINID success"
        fi
        rlRun "ipa user-add --first=$superuserfirst \
                            --last=$superuserlast \
                            --gecos=$superusergecos \
                            --home=$superuserhome \
                            --principal=$superuserprinc \
                            --email=$superuseremail \
			    --phone="$mphone" \
			    --mobile="$mmobile" \
			    --pager="$mpager" \
			    --fax="$mfax" $superuser" \
                            0 \
                            "Adding user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-001: Modify User's First Name"
	rlRun "modifyUser $superuser first newfirstname" 0 "Modifying user"
	rlRun "verifyUserAttr $superuser \"First name\" newfirstname" 0 "Verify user's first name"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-002: Modify User's Last Name"
        rlRun "modifyUser $superuser last newlastname" 0 "Modifying user"
        rlRun "verifyUserAttr $superuser \"Last name\" newlastname" 0 "Verify user's last name"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-003: Modify User's Home Directory"
        rlRun "modifyUser $superuser homedir /home/new" 0 "Modifying user"
        rlRun "verifyUserAttr $superuser \"Home directory\" /home/new" 0 "Verify user's home directory"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-004: Modify User's GECOS"
        rlRun "modifyUser $superuser gecos \"newfirst newlast\"" 0 "Modifying user"
        rlRun "verifyUserAttr $superuser \"GECOS field\" \"newfirst newlast\"" 0 "Verify user's last name"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-005: Modify User's Login Shell"
        rlRun "modifyUser $superuser shell /bin/csh" 0 "Modifying user"
        rlRun "verifyUserAttr $superuser \"Login shell\" /bin/csh" 0 "Verify user's login shell"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-006: Modify User's Email Address"
        rlRun "modifyUser $superuser email new@my.company.com" 0 "Modifying user"
        rlRun "verifyUserAttr $superuser \"Email address\" new@my.company.com" 0 "Verify user's email address"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-007: Modify User's Street"
        rlRun "modifyUser $superuser street \"200 Broadway Ave\"" 0 "Modifying user"
        rlRun "verifyUserAttr $superuser \"Street address\" \"200 Broadway Ave\"" 0 "Verify user's street address"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-008: Modify User's UID Number"
        rlRun "modifyUser $superuser uid 25252525" 0 "Modifying user"
        rlRun "verifyUserAttr $superuser UID 25252525" 0 "Verify user's uid"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-009: Modify User's Phone Number"
        rlRun "modifyUser $superuser phone \"111 111 1111\"" 0 "Modifying user"
        rlRun "verifyUserAttr $superuser \"Telephone Number\" \"111 111 1111\"" 0 "Verify user's phone number"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-010: Modify User's Mobile Phone Number"
        rlRun "modifyUser $superuser mobile \"444 444 4444\"" 0 "Modifying user"
        rlRun "verifyUserAttr $superuser \"Mobile Telephone Number\" \"444 444 4444\"" 0 "Verify user's mobile phone number"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-011: Modify User's Pager Number"
        rlRun "modifyUser $superuser pager \"000 000 0000\"" 0 "Modifying user"
        rlRun "verifyUserAttr $superuser \"Pager Number\" \"000 000 0000\"" 0 "Verify user's pager number"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-012: Modify User's Fax Number"
        rlRun "modifyUser $superuser fax \"555 123 5678\"" 0 "Modifying user"
        rlRun "verifyUserAttr $superuser \"Fax Number\" \"555 123 5678\"" 0 "Verify user's phone number"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-013: setattr on First Name"
	rlRun "setAttribute user givenname fred $superuser" 0 "Setting givenname"
	rlRun "verifyUserAttr $superuser \"First name\" fred" 0 "Verify user's first name"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-014: addattr on First Name"
        command="ipa user-mod --addattr givenname=second $superuser"
        expmsg="ipa: ERROR: givenname: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-015: setattr on Last Name"
        rlRun "setAttribute user sn smith $superuser" 0 "Setting sn"
        rlRun "verifyUserAttr $superuser \"Last name\" smith" 0 "Verify user's last name"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-016: addattr on Last Name"
        command="ipa user-mod --addattr sn=second $superuser"
        expmsg="ipa: ERROR: sn: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-017: setattr on Home Directory"
        rlRun "setAttribute user homedirectory /home/fred $superuser" 0 "Setting homedirectory"
        rlRun "verifyUserAttr $superuser \"Home directory\" /home/fred" 0 "Verify user's home directory"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-018: addattr on Home Directory"
        command="ipa user-mod --addattr homedirectory=/home/second $superuser"
        expmsg="ipa: ERROR: homedirectory: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-019: setattr on GECOS"
        rlRun "setAttribute user gecos \"Fred Smith\" $superuser" 0 "Setting gecos"
        rlRun "verifyUserAttr $superuser \"GECOS field\" \"Fred Smith\"" 0 "Verify user's gecos"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-020: addattr on GECOS"
        command="ipa user-mod --addattr gecos=SmithFred $superuser"
        expmsg="ipa: ERROR: gecos: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-021: setattr on Login Shell"
        rlRun "setAttribute user loginshell /bin/bash $superuser" 0 "Setting loginshell"
        rlRun "verifyUserAttr $superuser \"Login shell\" /bin/bash" 0 "Verify user's login shell"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-022: addattr on Login Shell"
        command="ipa user-mod --addattr loginshell=/bin/ksh $superuser"
        expmsg="ipa: ERROR: loginshell: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-023: setattr on Email Address"
        rlRun "setAttribute user mail fred@abc.net $superuser" 0 "Setting email"
        rlRun "verifyUserAttr $superuser \"Email address\" fred@abc.net" 0 "Verify user's email address"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-024: addattr on Email Address"
	rlRun "addAttribute user mail fsmith@abcd.com $superuser" 0 "Adding additional email"
	rlRun "verifyUserAttr $superuser \"Email address\" fsmith@abcd.com" 0 "Verify user's email address"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-025: setattr on Street Address"
        rlRun "setAttribute user street \"100 ABC Way\" $superuser" 0 "Setting street address"
        rlRun "verifyUserAttr $superuser \"Street address\" \"100 ABC Way\"" 0 "Verify user's street address"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-026: addattr on Street Address"
        command="ipa user-mod --addattr street=\"2ndStreet\" $superuser"
        expmsg="ipa: ERROR: street: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-027: addattr and setattr on memberof"
        attr="memberof"
        group1="cn=bogus,$GROUPDN"
        group2="cn=bogus2,$GROUPDN"
        command="ipa user-mod --setattr $attr=\"$group1\" $superuser"
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry 'uid=$superuser,cn=users,cn=accounts,dc=$RELM'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --addattr $attr=\"$group2\" $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-028: setattr and addattr on dn"
        command="ipa user-mod --setattr dn=mynewDN $superuser"
        expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --addattr dn=anothernewDN $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-029: setattr and addattr on cn"
        rlRun "setAttribute user cn \"Fredrick Smith\" $superuser" 0 "Setting cn"
        rlRun "verifyUserAttr $superuser cn \"Fredrick Smith\"" 0 "Verify user's cn"
        rlRun "addAttribute user cn \"Smithie\" $superuser" 0 "Setting cn"
        rlRun "verifyUserAttr $superuser cn \"Fredrick Smith, Smithie\"" 0 "Verify user's cn"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-030: setattr and addattr on member"
	command="ipa user-mod --setattr member=\"uid=admin,cn=users,cn=accounts,dc=$RELM\" $superuser"
        expmsg="ipa: ERROR: attribute \"member\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
	command="ipa user-mod --addattr member=\"uid=admin,cn=users,cn=accounts,dc=$RELM\" $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-031: setattr and addattr on ipauniqueid"
        command="ipa user-mod --setattr ipauniqueid=mynew-unique-id $superuser"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --addattr ipauniqueid=another-new-unique-id $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-032: setattr and addattr on invalid attribute"
        command="ipa user-mod --setattr bad=test $superuser"
        expmsg="ipa: ERROR: attribute \"bad\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --setattr bad=test $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-033: setattr and addattr krbPwdPolicyReference"
        command="ipa user-mod --setattr krbPwdPolicyReference=test $superuser"
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'krbPwdPolicyReference' attribute of entry 'uid=$superuser,cn=users,cn=accounts,dc=$RELM'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --setattr krbPwdPolicyReference=test $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-034: setattr and addattr krbPrincipalName"
        command="ipa user-mod --setattr krbPrincipalName=test $superuser"
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'krbPrincipalName' attribute of entry 'uid=$superuser,cn=users,cn=accounts,dc=$RELM'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --setattr krbPrincipalName=test $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-035: setattr and addattr on User Private Group's gidNumber"
	command="ipa group-mod --setattr gidNumber=12345678 $superuser"
	expmsg="ipa: ERROR: Server is unwilling to perform: Modifying a mapped attribute  in a managed entry is not allowed. The \"gidNumber\" attribute is mapped for this entry."
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
	expmsg="ipa: ERROR: gidnumber: Only one value allowed."
	command="ipa group-mod --addattr gidNumber=12345678 $superuser"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-036: setattr and addattr nsAccountLock"
        command="ipa user-mod --setattr nsAccountLock=true $superuser"
        expmsg="ipa: ERROR: attribute \"nsAccountLock\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --addattr nsAccountLock=test $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-037: setattr on uidNumber and Verify UPG gidNumber now matches"
	rlRun "setAttribute user uidNumber 99999999 $superuser" 0 "setattr on uidNumber"
	rlRun "verifyUserAttr $superuser UID 99999999" 0 "Verify user's uidNumber"
	rlRun "verifyGroupAttr $superuser GID 99999999" 0 "Verify private group's gidNumber"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-038: setattr and add addattr on telephoneNumber"
        rlRun "setAttribute user telephoneNumber 111-111-1111 $superuser" 0 "Setting phone number"
        rlRun "verifyUserAttr $superuser \"Telephone Number\" 111-111-1111" 0 "Verify user's phone number"
	for item in 222-222-2222 333-333-3333 444-444-4444 ; do
		rlRun "addAttribute user telephoneNumber $item $superuser" 0 "Adding phone numbers"
	done
	rlRun "verifyUserAttr $superuser \"Telephone Number\" \"111-111-1111, 222-222-2222, 333-333-3333, 444-444-4444\"" 0 "Verifying phone numbers"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-039: setattr and add addattr on mobile"
        rlRun "setAttribute user mobile 111-111-1111 $superuser" 0 "Setting setting mobile number"
        rlRun "verifyUserAttr $superuser \"Mobile Telephone Number\" 111-111-1111" 0 "Verify user's mobile phone number"
        for item in 222-222-2222 333-333-3333 444-444-4444 ; do
                rlRun "addAttribute user mobile $item $superuser" 0 "Adding mobile phone numbers"
        done
        rlRun "verifyUserAttr $superuser \"Mobile Telephone Number\" \"111-111-1111, 222-222-2222, 333-333-3333, 444-444-4444\"" 0 "Verifying mobile phone numbers"
    rlPhaseEnd 

    rlPhaseStartTest "ipa-user-cli-mod-040: setattr and add addattr on fax"
        rlRun "setAttribute user facsimileTelephoneNumber 111-111-1111 $superuser" 0 "Setting fax number"
        rlRun "verifyUserAttr $superuser \"Fax Number\" 111-111-1111" 0 "Verify user's fax number"
        for item in 222-222-2222 333-333-3333 444-444-4444 ; do
                rlRun "addAttribute user facsimileTelephoneNumber $item $superuser" 0 "Adding fax numbers"
        done
        rlRun "verifyUserAttr $superuser \"Fax Number\" \"111-111-1111, 222-222-2222, 333-333-3333, 444-444-4444\"" 0 "Verifying fax numbers"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-041: setattr and add addattr on pager"
        rlRun "setAttribute user pager 111-111-1111 $superuser" 0 "Setting pager number"
        rlRun "verifyUserAttr $superuser \"Pager Number\" 111-111-1111" 0 "Verify user's pager number"
        for item in 222-222-2222 333-333-3333 444-444-4444 ; do
                rlRun "addAttribute user pager $item $superuser" 0 "Adding pager numbers"
        done
        rlRun "verifyUserAttr $superuser \"Pager Number\" \"111-111-1111, 222-222-2222, 333-333-3333, 444-444-4444\"" 0 "Verifying pager numbers"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-042: uid 0"
        command="ipa user-mod --setattr uidNumber=0 $superuser"
        expmsg="ipa: ERROR: uid 0 not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --uid=0 $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --uid."
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-user-cli-mod-cleanup"
        rlRun "ipa user-del $superuser" 0 "delete $superuser account"
    rlPhaseEnd

rlJournalPrintText
report=$TmpDir/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
