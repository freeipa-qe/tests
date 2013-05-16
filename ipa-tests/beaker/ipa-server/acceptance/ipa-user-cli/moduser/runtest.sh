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
#   Author: Asha Akkiangady <aakkiang@redhat.com>
#   Date  : Mar 28, 2012
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
. /opt/rhqa_ipa/env.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/lib.user-cli.sh
. /opt/rhqa_ipa/ipa-group-cli-lib.sh

GROUPRDN="cn=groups,cn=accounts,"
GROUPDN="$GROUPRDN$BASEDN"
echo "GROUPDN is $USERDN"
echo "Server is $MASTER"

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
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
                            --principal=$superuserprinc$RELM \
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
	rlRun "verifyUserAttr $superuser \"Email address\" \"fred@abc.net, fsmith@abcd.com\"" 0 "Verify user's email address"
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
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry 'uid=$superuser,cn=users,cn=accounts,$BASEDN'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --addattr $attr=\"$group2\" $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-028: setattr and addattr on dn"
        command="ipa user-mod --setattr dn=\"uid=mynewDN,cn=users,cn=accounts,$BASEDN\" $superuser"
        expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --addattr dn=\"uid=anothernewDN,cn=users,cn=accounts,$BASEDN\" $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
        command="ipa user-mod --setattr dn=mynewDN $superuser"
        expmsg="ipa: ERROR: dn: Invalid syntax."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for invalid DN syntax"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-029: setattr on cn"
        rlRun "setAttribute user cn \"Fredrick Smith\" $superuser" 0 "Setting cn"
        rlRun "verifyUserAttr $superuser \"Full name\" \"Fredrick Smith\"" 0 "Verify user's cn"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-030: addattr on cn"
	command="ipa user-mod --addattr cn=Smithie $superuser"
        expmsg="ipa: ERROR: cn: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."

    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-031: setattr and addattr on member"
	command="ipa user-mod --setattr member=\"uid=admin,cn=users,cn=accounts,dc=$DOMAIN\" $superuser"
        expmsg="ipa: ERROR: attribute \"member\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
	command="ipa user-mod --addattr member=\"uid=admin,cn=users,cn=accounts,dc=$DOMAIN\" $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-032: setattr and addattr on ipauniqueid"
        command="ipa user-mod --setattr ipauniqueid=mynew-unique-id $superuser"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --addattr ipauniqueid=another-new-unique-id $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-033: setattr and addattr on invalid attribute"
        command="ipa user-mod --setattr bad=test $superuser"
        expmsg="ipa: ERROR: attribute \"bad\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --setattr bad=test $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-034: setattr and addattr krbPwdPolicyReference"
        command="ipa user-mod --setattr krbPwdPolicyReference=\"uid=test,cn=users,cn=accounts,$BASEDN\" $superuser"
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'krbPwdPolicyReference' attribute of entry 'uid=$superuser,cn=users,cn=accounts,$BASEDN'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --setattr krbPwdPolicyReference=\"uid=test,cn=users,cn=accounts,$BASEDN\" $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
        command="ipa user-mod --setattr krbPwdPolicyReference=test $superuser"
        expmsg="ipa: ERROR: krbpwdpolicyreference: Invalid syntax."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for invalid syntax."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-035: setattr and addattr krbPrincipalName"
        command="ipa user-mod --setattr krbPrincipalName=test $superuser"
        #expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'krbPrincipalName' attribute of entry 'uid=$superuser,cn=users,cn=accounts,$BASEDN'."
        expmsg="ipa: ERROR: invalid 'krbprincipalname': attribute is not configurable"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --setattr krbPrincipalName=test $superuser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-036: setattr and addattr on User Private Group's gidNumber"
	command="ipa group-mod --setattr gidNumber=12345678 $superuser"
	expmsg="ipa: ERROR: Server is unwilling to perform: Modifying a mapped attribute  in a managed entry is not allowed. The \"gidNumber\" attribute is mapped for this entry."
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
	expmsg="ipa: ERROR: gidnumber: Only one value allowed."
	command="ipa group-mod --addattr gidNumber=12345678 $superuser"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-037: setattr nsAccountLock"
	for item in TRUE FALSE True False true false ; do
        	rlRun "ipa user-mod --setattr nsAccountLock=$item $superuser" 0 "Set user nsAccountLock to true"
		caseitem=`echo $item | tr "[A-Z]" "[a-z]"`
		if [[ "$caseitem" == "true" ]]	; then
			item="True"
		else
			item="False"
		fi
		rlLog "Checking nsAccountLock value : $item"
		rlRun "verifyUserAttr $superuser \"Account disabled\" $item" 0 "Verify user's nsAccountLock"
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-038: setattr and addattr nsAccountLock Invalid Value"
        command="ipa user-mod --setattr nsAccountLock=test $superuser"
        expmsg="ipa: ERROR: invalid 'nsaccountlock': must be True or False"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
	command="ipa user-mod --addattr nsAccountLock=test $superuser"
	expmsg="ipa: ERROR: nsaccountlock: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd


    rlPhaseStartTest "ipa-user-cli-mod-039: addattr nsAccountLock "
        command="ipa user-mod --addattr nsAccountLock=true $superuser"
        expmsg="ipa: ERROR: nsaccountlock: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-040: setattr on uidNumber and Verify UPG gidNumber now matches"
	rlRun "setAttribute user uidNumber 99999999 $superuser" 0 "setattr on uidNumber"
	rlRun "verifyUserAttr $superuser UID 99999999" 0 "Verify user's uidNumber"
	rlRun "verifyGroupAttr $superuser GID 99999999" 0 "Verify private group's gidNumber"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-041: setattr and add addattr on telephoneNumber"
        rlRun "setAttribute user telephoneNumber 111-111-1111 $superuser" 0 "Setting phone number"
        rlRun "verifyUserAttr $superuser \"Telephone Number\" 111-111-1111" 0 "Verify user's phone number"
	for item in 222-222-2222 333-333-3333 444-444-4444 ; do
		rlRun "addAttribute user telephoneNumber $item $superuser" 0 "Adding phone numbers"
	done
	rlRun "verifyUserAttr $superuser \"Telephone Number\" \"111-111-1111, 222-222-2222, 333-333-3333, 444-444-4444\"" 0 "Verifying phone numbers"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-042: setattr and add addattr on mobile"
        rlRun "setAttribute user mobile 111-111-1111 $superuser" 0 "Setting setting mobile number"
        rlRun "verifyUserAttr $superuser \"Mobile Telephone Number\" 111-111-1111" 0 "Verify user's mobile phone number"
        for item in 222-222-2222 333-333-3333 444-444-4444 ; do
                rlRun "addAttribute user mobile $item $superuser" 0 "Adding mobile phone numbers"
        done
        rlRun "verifyUserAttr $superuser \"Mobile Telephone Number\" \"111-111-1111, 222-222-2222, 333-333-3333, 444-444-4444\"" 0 "Verifying mobile phone numbers"
    rlPhaseEnd 

    rlPhaseStartTest "ipa-user-cli-mod-043: setattr and add addattr on fax"
        rlRun "setAttribute user facsimileTelephoneNumber 111-111-1111 $superuser" 0 "Setting fax number"
        rlRun "verifyUserAttr $superuser \"Fax Number\" 111-111-1111" 0 "Verify user's fax number"
        for item in 222-222-2222 333-333-3333 444-444-4444 ; do
                rlRun "addAttribute user facsimileTelephoneNumber $item $superuser" 0 "Adding fax numbers"
        done
        rlRun "verifyUserAttr $superuser \"Fax Number\" \"111-111-1111, 222-222-2222, 333-333-3333, 444-444-4444\"" 0 "Verifying fax numbers"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-044: setattr and add addattr on pager"
        rlRun "setAttribute user pager 111-111-1111 $superuser" 0 "Setting pager number"
        rlRun "verifyUserAttr $superuser \"Pager Number\" 111-111-1111" 0 "Verify user's pager number"
        for item in 222-222-2222 333-333-3333 444-444-4444 ; do
                rlRun "addAttribute user pager $item $superuser" 0 "Adding pager numbers"
        done
        rlRun "verifyUserAttr $superuser \"Pager Number\" \"111-111-1111, 222-222-2222, 333-333-3333, 444-444-4444\"" 0 "Verifying pager numbers"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-045: uid 0"
        command="ipa user-mod --setattr uidNumber=0 $superuser"
        expmsg="ipa: ERROR: invalid 'uidnumber': must be at least 1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa user-mod --uid=0 $superuser"
	expmsg="ipa: ERROR: invalid 'uid': must be at least 1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --uid."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-046: modify user's state"
        rlRun "ipa user-mod --state=MA $superuser" 0 "Setting user state"
        rlRun "verifyUserAttr $superuser \"State/Province\" MA" 0 "Verify user's state"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-047: modify user's postalcode - bug 692945"
        rlRun "ipa user-mod --postalcode=01730 $superuser" 0 "Setting user postalcode - code beginning with 0"
        rlRun "verifyUserAttr $superuser \"ZIP\" 01730" 0 "Verify user's postalcode"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-048: modify user's postalcode"
        rlRun "ipa user-mod --postalcode=99887111 $superuser" 0 "Setting user postalcode"
        rlRun "verifyUserAttr $superuser \"ZIP\" 99887111" 0 "Verify user's postalcode"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-049: modify user's city"
        rlRun "ipa user-mod --city=Bedford $superuser" 0 "Setting user city"
        rlRun "verifyUserAttr $superuser \"City\" Bedford" 0 "Verify user's city"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-050: modify user's orgunit"
        rlRun "ipa user-mod --orgunit=QE $superuser" 0 "Setting user orgunit"
        rlRun "verifyUserAttr $superuser \"Org. Unit\" QE" 0 "Verify user's orgunit"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-051: modify user's manager"
        # add a user to set as manager
        rlRun "ipa user-add --first=MY --last=Boss myboss" 0 "Add user to be set as manager."
        manager="myboss"
        rlRun "ipa user-mod --manager=\"$manager\" $superuser" 0 "Setting user boss"
        rlRun "verifyUserAttr $superuser \"Manager\" \"$manager\"" 0 "Verify user's boss"
	rlRun "ipa user-del myboss" 0 "Delete the boss user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-052: modify user's title"
        rlRun "ipa user-mod --title=engineer $superuser" 0 "Setting user title"
        rlRun "verifyUserAttr $superuser \"Job Title\" engineer" 0 "Verify user's title"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-053: modify user's carlicense"
        rlRun "ipa user-mod --carlicense=\"012 ABC\" $superuser" 0 "Setting user carlicense"
        rlRun "verifyUserAttr $superuser \"Car License\" \"012 ABC\"" 0 "Verify user's car license"
    rlPhaseEnd

     rlPhaseStartTest "ipa-user-cli-mod-054: test of random password generation with user-add"
	rusr="36user"
        kinitAs $ADMINID $ADMINPW
	ipa user-add --first fnaml --last lastn --random $rusr 
	newpassword=$(ipa user-mod --random $rusr | grep Random\ password | cut -d: -f2 | sed s/\ //g)	
	FirstKinitAs $rusr $newpassword fo0m4nchU
        if [ $? -ne 0 ]; then
            rlFail "ERROR - kinit failed to kinit as $rusr using password [$newpassword]"
        else
            rlPass "Success - kinit at first time with password [$newpassword] success"
        fi
        kinitAs $ADMINID $ADMINPW
	ipa user-del $rusr&
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-055: Rename user"
        rlRun "ipa user-mod --rename=$rename_user $superuser" 0 "Renaming user login to $rename_user"
        rlRun "verifyUserAttr $rename_user \"User login\" $rename_user " 0 "Verify user Login attribute."
        rlRun "ipa user-show $rename_user --all --raw | grep krbprincipalname | cut -d ":" -f2 | grep $rename_user" 0 "Verify krbprincipalname is renamed as well"
	command="ipa user-show $superuser"
        expmsg="ipa: ERROR: $superuser: user not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for $superuser"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-056: Rename user with a string of 32 characters (at most allowed)"
        rlRun "ipa user-mod --rename=$rename_maxlength $rename_user" 0 "Renaming user $rename_user login to $rename_maxlength"
        rlRun "verifyUserAttr $rename_maxlength \"User login\" $rename_maxlength" 0 "Verify user Login attribute."
        command="ipa user-show $rename_user"
        expmsg="ipa: ERROR: $rename_user: user not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for $rename_user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-057: Rename user with a string of 33 characters (more than allowed)"
        command="ipa user-mod --rename=$rename_exceedmax $rename_maxlength"
        expmsg="ipa: ERROR: invalid 'login': can be at most 32 characters"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --rename=$rename_exceedmax"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-058: Rename user with a invalid character - #"
        command="ipa user-mod --rename=newname# $rename_maxlength"
        expmsg="ipa: ERROR: invalid 'rename': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --rename=newname#"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-059: Rename user with a invalid character - @"
        command="ipa user-mod --rename=newname@ $rename_maxlength"
        expmsg="ipa: ERROR: invalid 'rename': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --rename=newname@"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-060: Rename user with a invalid character - *"
        command="ipa user-mod --rename=newname* $rename_maxlength"
        expmsg="ipa: ERROR: invalid 'rename': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --rename=newname*"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-061: Rename user with a invalid character - ?"
        command="ipa user-mod --rename=newname? $rename_maxlength"
        expmsg="ipa: ERROR: invalid 'rename': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --rename=newname?"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-062: Rename user with string containing letters, numbers, _, -, . and $"
	rlRun "ipa user-mod --rename=\"users_brand-new.name$34\" $rename_maxlength" 0 "Renaming user $rename_maxlength login to \"users_brand-new.name$34\""
        rlRun "verifyUserAttr \"users_brand-new.name$34\" \"User login\" \"users_brand-new.name$34\"" 0 "Verify user Login attribute."
        command="ipa user-show $rename_maxlength"
        expmsg="ipa: ERROR: $rename_maxlength: user not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for $rename_maxlength"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-063: Rename user and setattribute"
        rlRun "ipa user-mod --rename=$rename_user \"users_brand-new.name$34\" --setattr displayname=cl2" 0 "Renaming user to $rename_user login and setattribute display name."
        rlRun "verifyUserAttr $rename_user \"User login\" $rename_user" 0 "Verify user Login attribute."
        rlRun "verifyUserAttr $rename_user \"Display name\" cl2 " 0 "Verify user street attribute."
        command="ipa user-show \"users_brand-new.name$34\""
        expmsg="ipa: ERROR: \"users_brand-new.name$34\": user not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for \"users_brand-new.name$34\""
    rlPhaseEnd
	
    rlPhaseStartTest "ipa-user-cli-mod-064: Rename user with empty string."
        command="ipa user-mod --rename= $rename_user"
        expmsg="ipa: ERROR: invalid 'rename': can't be empty"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for empty string"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-065: Rename user with an existing user login."
        testuser="testuser-065"	
	rlRun "ipa user-add --first=$testuser \
                            --last=$superuserlast \
                            --gecos=$superusergecos \
                            --home=$superuserhome \
                            --principal=$superuserprinc$RELM \
                            --email=$superuseremail \
                            --phone="$mphone" \
                            --mobile="$mmobile" \
                            --pager="$mpager" \
                            --fax="$mfax" $testuser" \
                            0 \
                            "Adding user"
        command="ipa user-mod --rename=$testuser $rename_user"
        expmsg="ipa: ERROR: This entry already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for existing user login"
	rlRun "ipa user-del $testuser" 0 "Clean-up: delete $testuser account"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-066: Renaming a user updates user private group"
	newname="testuser-066"
        rlRun "verifyUserAttr $rename_user \"User login\" $rename_user " 0 "Verify user Login attribute for $rename_user."
	rlRun "ipa group-find --private $rename_user > /tmp/rename_upg0.out" 0 "Verifying private group before rename"
        rlAssertGrep "Number of entries returned 1" "/tmp/rename_upg0.out"
        rlAssertGrep "Group name: $rename_user" "/tmp/rename_upg0.out"
	user_gidnumber=`cat /tmp/rename_upg0.out | grep grep "GID" | cut -d " " -f 4`
 	rlLog "GID number for $rename_user is $user_gidnumber"
        rlLog "Executing: ipa user-mod --rename=$newname $rename_user" 0 "Renaming user login to $newname"
        rlRun "ipa user-mod --rename=$newname $rename_user" 0 "Renaming user login to $newname"
        rlRun "verifyUserAttr $newname \"User login\" $newname " 0 "Verify user Login attribute."
	rlRun "ipa group-find --private $newname > /tmp/rename_upg1.out" 0 "Verifying --rename updates user private group"
        rlAssertGrep "Number of entries returned 1" "/tmp/rename_upg1.out"
        rlAssertGrep "Group name: $newname" "/tmp/rename_upg1.out"
	rename_gidnumber=`cat /tmp/rename_upg1.out | grep grep "GID" | cut -d " " -f 4`
	if [ $user_gidnumber -eq $rename_gidnumber] ; then
		rlPass "Managed entries user's private group GID remains the same after renaming."
	else
		rlFail "User's private group GID number of $newname expected to be $user_gidnumber.  GOT: $rename_gidnumber"
	fi
	rlRun "ipa group-find --private $rename_user > /tmp/rename_upg2.out" 1 "Verifying after the rename old user is removed from the user private group"
        rlAssertGrep "Number of entries returned 0" "/tmp/rename_upg2.out"
        rlRun "ipa user-mod --rename=$rename_user $newname" 0 "Clean-up: rename to $rename_user"
    rlPhaseEnd
    
    rlPhaseStartTest "ipa-user-cli-mod-067: Negative - rename user with the same old name"
        command="ipa user-mod --rename=$rename_user $rename_user"
        rlAssertGrep "Group name: $newname" "/tmp/rename_upg1.out"
        expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for $rename_user"
	rlRun "ipa user-mod --rename=$superuser $rename_user" 0 "Clean-up: rename to $superuser"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-mod-068: Rename a user that does not exist"
	command="ipa user-mod --rename=new_user_name doesntexist"
	expmsg="ipa: ERROR: doesntexist: user not found"
 	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for user doesntexist"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "ipa user-del $superuser" 0 "delete $superuser account"
    rlPhaseEnd

rlJournalPrintText
report=$TmpDir/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
