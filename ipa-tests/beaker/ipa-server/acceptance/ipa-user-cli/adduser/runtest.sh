#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-user-cli
#   Description: IPA user cli acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#   user-add     Add a new user.
#   user-del     Delete a user.
#   user-find    Search for users.
#   user-lock    Lock a user account.
#   user-mod     Modify a user.
#   user-show    Display information about a user.
#   user-unlock  Unlock a user account.
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

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup "ipa-user-cli-add-startup: Check for ipa-server package"
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit ad administrator"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-001: Add User"
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

    rlPhaseStartTest "ipa-user-cli-add-002: Verify New User"
	rlRun "verifyUserAttr $superuser \"First name\" $superuserfirst" 0 "Verify user's first name"
	rlRun "verifyUserAttr $superuser \"Last name\" $superuserlast" 0 "Verify user's last name"
	rlRun "verifyUserAttr $superuser \"GECOS field\" \"$superusergecos\"" 0 "Verify user's gecos"
	rlRun "verifyUserAttr $superuser \"Home directory\" $superuserhome" 0 "Verify user's home directory"
	rlRun "verifyUserAttr $superuser \"Kerberos principal\" $superuserprinc" 0 "Verify user's princal name"
	rlRun "verifyUserAttr $superuser \"Email address\" $superuseremail" 0 "Verify user's email"
	rlRun "verifyUserAttr $superuser \"Telephone Number\" \"$mphone\"" 0 "Verify user's phone number"
	rlRun "verifyUserAttr $superuser \"Mobile Telephone Number\" \"$mmobile\"" 0 "Verify user's mobile phone number"
	rlRun "verifyUserAttr $superuser \"Pager Number\" \"$mpager\"" 0 "Verify user's pager number"
	rlRun "verifyUserAttr $superuser \"Fax Number\" \"$mfax\"" 0 "Verify user's fax number"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-003: Add Duplicate User"
        command="ipa user-add --first=$superuserfirst --last=$superuserlast $superuser"
        expmsg="ipa: ERROR: user with name \"$superuser\" already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-004: Lock User"
        rlRun   "ipa user-add --first=$superuserfirst --last=$superuserlast $lusr" 0 "add user for accout lock-unlock test"
        rlRun   "ipa user-find $lusr | grep $lusr" 0 "search for the newly created account"

        # set initial password, and we change it right away
        initialpw="thisjunk10"
        rlRun "echo $initialpw | ipa user-mod --password $lusr" 0 "set initial pasword"
        FirstKinitAs $lusr $initialpw $lusrpw
        if [ $? -ne 0 ]; then
            rlFail "ERROR - kinit failed "
        else
            rlPass "Success - kinit at first time with password [$lusrpw] success"
        fi

        kinitAs $ADMINID $ADMINPW
        rlRun "ipa user-disable $lusr" 0 "perform user account locking"
        if [ $? -ne 0 ];then
            rlFail "ERROR - ipa user-disable failed "
        else
            rlRun "verifyUserAttr $lusr \"Account disabled\" True" 0 "Verify user's account disabled status"
            kinitAs $lusr $lusrpw
            if [ $? -ne 0 ];then
                rlPass "kinit as $lusr failed as expected"
            else
                rlFail "kinit as $lusr success when fail expected "
            fi
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-005: Lock a locked user"
	kinitAs $ADMINID $ADMINPW
        command="ipa user-disable $lusr"
        expmsg="ipa: ERROR: This entry is already disabled"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-006: Unlock User"
        rlRun "ipa user-enable $lusr"
        if [ $? -ne 0 ];then
            rlFail "ERROR - ipa user-enable failed "
        else
	    rlRun "verifyUserAttr $lusr \"Account disabled\" False" 0 "Verify user's account disabled status"
            kinitAs $lusr $lusrpw
            if [ $? -ne 0 ];then
                rlFail "ERROR - kinit as $lusr failed after unlock. expect success "
            else
                rlPass "Success - kinit as $lusr success as expected"
            fi
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-007: user find --whoami"
	tmpfile=/tmp/whoami.txt
	ipa user-find --whoami > $tmpfile
	rlRun "cat $tmpfile | grep \"User login: $lusr\"" 0 "Verify User login"
	rlRun "cat $tmpfile | grep \"First name: $superuserfirst\"" 0 "Verify First name"
	rlRun "cat $tmpfile | grep \"Last name: $superuserlast\"" 0 "Verify Last name"
	rlRun "cat $tmpfile | grep \"Home directory: /home/$lusr\"" 0 "Verify home directory"
	rlRun "cat $tmpfile | grep \"Login shell: /bin/sh\"" 0 "Verify Login shell"
	rlRun "cat $tmpfile | grep \"Account disabled: False\"" 0 "Verify account status"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-008: Unlock an unlocked user"
	kinitAs $ADMINID $ADMINPW
        command="ipa user-enable $lusr"
        expmsg="ipa: ERROR: This entry is already enabled"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-009: Over Max username length"
        command="ipa user-add --first=test --last=test abcdefghijklmnopqrstuvwxyx12345678"
        expmsg="ipa: ERROR: invalid 'login': can be at most 32 characters"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-010: Invalid username character - #"
        command="ipa user-add --first=test --last=test abcd#"
        expmsg="ipa: ERROR: invalid 'login': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-011: Invalid username character - @"
        command="ipa user-add --first=test --last=test abcd@"
        expmsg="ipa: ERROR: invalid 'login': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-012: Invalid username character - *"
        command="ipa user-add --first=test --last=test abcd*"
        expmsg="ipa: ERROR: invalid 'login': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-013: Invalid username character - ?"
        command="ipa user-add --first=test --last=test abcd?"
        expmsg="ipa: ERROR: invalid 'login': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-014: uid 0"
        command="ipa user-add --first=uid0 --last=uid0 --uid=0 uid0"
        expmsg="ipa: ERROR: invalid 'uid': must be at least 1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	ipa user-del uid0
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-015: Add 10 users and test find returns limit of 5"
        i=1
        while [ $i -le 10 ] ; do
                ipa user-add --first=user$i --last=user$i user$i
                let i=$i+1
        done

	# find should return up to the maxlimit set
	rlRun "ipa config-mod --searchrecordslimit=5" 0 "Set search records limit to 5"
        ipa user-find > /tmp/userfind.out
        result=`cat /tmp/userfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "5 users returned as expected with no size limit set"
        else
                rlFail "Number of users returned is not as expected.  GOT: $number EXP: 5"
        fi

    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-016: find 0 users"
        ipa user-find --sizelimit=0 > /tmp/userfind.out
        result=`cat /tmp/userfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 13 ] ; then
                rlPass "All users returned as expected with size limit of 0"
        else
                rlFail "Number of users returned is not as expected.  GOT: $number EXP: 13"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-017: find 7 users"
        ipa user-find --sizelimit=7 > /tmp/userfind.out
        result=`cat /tmp/userfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 7 ] ; then
                rlPass "Number of users returned as expected with size limit of 7"
        else
                rlFail "Number of users returned is not as expected.  GOT: $number EXP: 7"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-018: find 9 users"
        ipa user-find --sizelimit=9 > /tmp/userfind.out
        result=`cat /tmp/userfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 9 ] ; then
                rlPass "Number of users returned as expected with size limit of 9"
        else
                rlFail "Number of userss returned is not as expected.  GOT: $number EXP: 9"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-019: find more users than exist"
        ipa user-find --sizelimit=30 > /tmp/userfind.out
        result=`cat /tmp/userfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 13 ] ; then
                rlPass "All users returned as expected with size limit of 30"
        else
                rlFail "Number of users returned is not as expected.  GOT: $number EXP: 13"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-020: find users - size limit not an integer"
        expmsg="ipa: ERROR: invalid 'sizelimit': must be an integer"
        command="ipa user-find --sizelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa user-find --sizelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-021: find users - time limit 0"
        ipa user-find --timelimit=0 > /tmp/userfind.out
        result=`cat /tmp/userfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "5 users returned as expected with time limit of 0"
        else
                rlFail "Number of users returned is not as expected.  GOT: $number EXP: 5"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-022: find users - time limit not an integer"
        expmsg="ipa: ERROR: invalid 'timelimit': must be an integer"
        command="ipa user-find --timelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa host-find --timelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-023: find users by first and last name"
        ipa user-find --first=user6 > /tmp/userfind.out
        result=`cat /tmp/userfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 1 ] ; then
                rlPass "Number of users returned as expected with --first=user6 - 1"
        else
                rlFail "Number of users returned is not as expected.  GOT: $number EXP: 1"
        fi

        ipa user-find --last=user10 > /tmp/userfind.out
        result=`cat /tmp/userfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 1 ] ; then
                rlPass "Number of users returned as expected with --last=user10 - 1"
        else
                rlFail "Number of users returned is not as expected.  GOT: $number EXP: 1"
        fi

    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-024: find users by shell"
        ipa user-find --shell=/bin/sh > /tmp/userfind.out
        result=`cat /tmp/userfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "Number of users returned as expected with --shell=/bin/sh - 5"
        else
                rlFail "Number of users returned is not as expected.  GOT: $number EXP: 5"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-025: Delete Users"
	i=1
        while [ $i -le 10 ] ; do
                ipa user-del user$i
		command="ipa user-show user$i"
                expmsg="ipa: ERROR: user$i: user not found"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - user$i shouldn't exist"
                let i=$i+1
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-026: no --continue - first user doesn't exist"
	command="ipa user-del testuser1 $lusr"
	expmsg="ipa: ERROR: testuser1: user not found"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - no --continue first user in list doesn't exist"
	rlRun "ipa user-show $lusr" 0 "Verify $lusr still exists."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-027: no --continue - second user doesn't exist"
	rlRun "ipa user-del $lusr testuser1 $superuser" 2 "delete users no --continue second user in list doesn't exist"
	command="ipa user-show $lusr"
	expmsg="ipa: ERROR: $lusr: user not found"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - no --continue first user should have been deleted."
	rlRun "ipa user-show $superuser" 0 "Verify $superuser still exists - third user in list"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-028: --continue - first user in list doesn't exist"
    	for item in user1 user2 user3 user4; do
		rlRun "ipa user-add --first=$item --last=$item $item" 0 "Adding some test users"
    	done

  	rlRun "ipa user-del --continue testuser1 user1" 0 "First user in delete list doesn't exist"
        command="ipa user-show user1"
        expmsg="ipa: ERROR: user1: user not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - second user should still have been deleted"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-029: --continue - second user in list doesn't exist"
        rlRun "ipa user-del --continue user2 testuser1 user3 user4" 0 "First user in delete list doesn't exist"
	for item in user2 user3 user3 ; do
        	command="ipa user-show $item"
        	expmsg="ipa: ERROR: $item: user not found"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - users should have been deleted"
	done

	# issue with --continue when one of the users do not exist it isn't working so deleting them for now
	ipa user-del user1 user3 user4
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-030: Add user - group with same name already exists"
	rlRun "addGroup johnny johnny" 0 "Adding a test group"
	command="ipa user-add --first=johnny --last=johnny johnny"
	expmsg="ipa: ERROR: Unable to create private group. A group 'johnny' already exists."
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
	# clean up
	ipa group-del johnny
	# just in case
	ipa user-del johnny
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-031: Add user with --password"
	rlRun "addUserWithPassword Jenny Galipeau jennyg newpassword" 0 "Adding user with initial password assigned."
	rlRun "FirstKinitAs jennyg newpassword fo0m4nchU" 0 "Testing kerberos authentication"
	kinitAs $ADMINID $ADMINPW
	# delete the user
	ipa user-del jennyg
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-032: setattr on RDN when user doesn't exist - trac ticket 558"	
        expmsg="ipa: ERROR: test1: user not found"
        command="ipa user-mod --setattr=uid=test2 test1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
    rlPhaseEnd

#  Disabling this test for now, causing beaker-lib to crash
    rlPhaseStartTest "ipa-user-cli-add-033: size limit too large - bugzilla 643182"
        expmsg="ipa: ERROR: invalid 'sizelimit': can be at most 2147483647"
        command="ipa user-find --sizelimit=20000000000"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - size limit too large."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-034: show user that doesn't exist - bugzilla 569735"
	myuser=baduser
        expmsg="ipa: ERROR: $myuser: user not found"
        command="ipa user-show $myuser"
	rlRun "$command" 2 "Check that return code is 2"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - show user that doesn't exist."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-035: Add user with principal not in the IPA realm"
        expmsg="ipa: ERROR: The realm for the principal does not match the realm for this IPA server"
        command="ipa user-add --first=princ --last=user --principal=puser@WRONG puser"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - principal not in IPA server realm."
    rlPhaseEnd

     rlPhaseStartTest "ipa-user-cli-add-036: test of random password generation with user-add"
	rusr="36user"
	newpassword=$(ipa user-add --first fnaml --last lastn --random $rusr | grep Random\ password | cut -d: -f2 | sed s/\ //g)	
	FirstKinitAs $rusr $newpassword fo0m4nchU
        if [ $? -ne 0 ]; then
            rlFail "ERROR - kinit failed to kinit as $rusr using password $newpassword"
        else
            rlPass "Success - kinit at first time with password [$newpassword] success"
        fi
        kinitAs $ADMINID $ADMINPW
	ipa user-del $rusr&
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-037: check of --pkey-only in user add"
	ipa_command_to_test="user"
	pkey_addstringa="--first fnamla --last lastna"
	pkey_addstringb="--first fnamlb --last lastnb"
	pkeyobja="39user"
	pkeyobjb="39userb"
	grep_string='User\ login'
	general_search_string=$pkeyobja
	rlRun "pkey_return_check" 0 "running checks of --pkey-only in group-find"
    rlPhaseEnd

    rlPhaseStartTest "bug748110: At times setting password fails with Confidentiality required: Operation requires a secure connection. errro"
	rlLog "Verifies https://bugzilla.redhat.com/show_bug.cgi?id=748110"

	rlRun "cp /etc/openldap/ldap.conf /var/tmp/" 0 "Backup /etc/openldap/ldap.conf"
	echo "sasl_secprops minssf=0,maxssf=0" >> /etc/openldap/ldap.conf

	rlRun "service httpd restart"
	rlRun "tcpdump -i lo -w /tmp/snoop &"
	rlRun "ipa user-show admin"
	rlRun "tcpdump -i lo -r /tmp/snoop -s 8192 -X > /tmp/bug748110-tcpdump.txt 2>&1"

	rlAssertNotGrep "cn=users" "/tmp/bug748110-tcpdump.txt"
	rlAssertNotGrep "cn=accounts" "/tmp/bug748110-tcpdump.txt"

	rlRun "mv -f /var/tmp/ldap.conf /etc/openldap/ldap.conf" 0 "Restoring /etc/openldap/ldap.conf" 
	rlRun "service httpd restart"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-038: Negative  Test of --in-groups in user-find"
	ipa user-add --first=fname --last=lname uuu
	ipa group-add --desc=desc1 ggg
	rlRun "ipa user-find --in-groups=ggg | grep User\ login: | grep uuu" 1 "Making sure that user uuu does not come back when searching --in-groups=ggg"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-039: Positive Test of --in-groups in user-find"
	ipa group-add-member --users=uuu ggg
	rlRun "ipa user-find --in-groups=ggg | grep User\ login: | grep uuu" 0 "Making sure that user uuu comes back when searching --in-groups=ggg"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-040: Negative Test of --not-in-groups in user-find"
	ipa user-add --first=fname --last=lname tusera
	rlRun "ipa user-find --not-in-groups=ggg | grep User\ login: | grep ggg" 1 "Making sure that user ggg does not come back when searching --not-in-groups=ggg"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-add-041: Positive test of --not-in-groups in user-find"
	rlRun "ipa user-find --not-in-groups=ggg | grep User\ login: | grep tusera" 0 "Making sure that user tusera comes back when searching --not-in-groups=ggg"
	ipa group-del ggg
	ipa user-del uuu
	ipa user-del tusera
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-user-cli-add-cleanup"
	rlRun "ipa config-mod --searchrecordslimit=100" 0 "set default search records limit back to default"
        rlRun "ipa user-del $superuser " 0 "delete $superuser account"
    rlPhaseEnd

rlJournalPrintText
report=$TmpDir/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
