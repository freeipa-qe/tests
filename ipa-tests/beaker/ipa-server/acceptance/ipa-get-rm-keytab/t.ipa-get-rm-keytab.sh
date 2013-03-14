#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-get-rm-keytabs
#   Description: ipa-getkeytab and ipa-rmkeytab acceptance tests
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  ipa-getkeytab	Get a keytab for a Kerberos principal
#  ipa-rmkeytab		Remove a kerberos principal from a keytab
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
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

TMP_KEYTAB="/opt/krb5.keytab"

setup() {
rlPhaseStartTest "Setup for getkeytab and rmkeytab tests"
	# check for packages
	for item in $PACKAGE1 $PACKAGE2 ; do
        	rpm -qa | grep $item
        	if [ $? -eq 0 ] ; then
                	rlPass "$item package is installed"
        	else
                	rlFail "$item package NOT found!"
        	fi
	done

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "create_ipauser $user1 $user1 $user1 $userpw"
	sleep 5
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "create_ipauser $user2 $user2 $user2 $userpw"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
rlPhaseEnd
}

getkeytab_001() {

rlPhaseStartTest "getkeytab_001: Testing the quiet mode command option."

	# getkeytab when kinit'ed as a different user"
	rlRun "kinitAs $user1 $userpw" 0 "kinit as $user1 user"
	rlRun "ipa-getkeytab --server $MASTER --principal $user2 --keytab $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1" 9
	MSG="Operation failed! Insufficient access rights"
	rlAssertGrep  "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

	# getkeytab when no credentials are found"
	rlRun "kdestroy" 0 "Destroying admin credentials"
	MSG="Kerberos User Principal not found. Do you have a valid Credential Cache?"
	rlRun "ipa-getkeytab --server $MASTER --principal $user1 --keytab $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1" 6
	rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

 	# getkeytab with quiet mode option enabled.
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
	rlRun "ipa-getkeytab -q --server $MASTER --principal $user1 --keytab $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1"
	if [ -s $TmpDir/getkeytab.out ]; then 
		rlFail "$TmpDir/getkeytab.out has contents, `cat $TmpDir/getkeytab.out`"
	else
		rlPass "$TmpDir/getkeytab.out is empty, as expected."
	fi
	
	# getkeytab without quiet mode option enabled.
	MSG="Keytab successfully retrieved and stored in: $TMP_KEYTAB"
	rlRun "ipa-getkeytab --server $MASTER --principal $user1 --keytab $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1"
	rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

rlPhaseEnd
}

getkeytab_002() {

rlPhaseStartTest "getkeytab_002: Testing the --server or the \"-s\" command option."

	rlRun "kdestroy"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

# Testing with "--server" & "-s" command options.
for i in "--server" "-s"; do
	# getkeytab when $MASTER is invalid
	rlRun "ipa-getkeytab $i invalid.ipaserver.com --principal $user1 --keytab $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1" 9
	MSG="SASL Bind failed"
	rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

	# getkeytab when $MASTER is valid
	rlRun "ipa-getkeytab $i $MASTER --principal $user1 --keytab $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1"
	MSG="Keytab successfully retrieved and stored in: $TMP_KEYTAB"
        rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"
done

rlPhaseEnd
}

getkeytab_003() {

rlPhaseStartTest "getkeytab_003: Testing the \"--principal\" or the \"-p\" command options."

# Testing with "--principal" and "-p" command options.
for i in "--principal" "-p"; do
	# getkeytab when $PRINC is invalid
	rlRun "ipa-getkeytab -s $MASTER $i user --keytab $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1" 9
	MSG="Operation failed\! PrincipalName not found"
	rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

	# getkeytab when $PRINC has invalid realm
	rlRun "ipa-getkeytab -s $MASTER $i $user1@INVALID.IPASERVER.REALM.COM --keytab $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1" 9
	MSG="Operation failed\! PrincipalName not found"
	rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

	# getkeytab when $PRINC has no realm
	rlRun "ipa-getkeytab -s $MASTER $i $user1 --keytab $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1"
        MSG="Keytab successfully retrieved and stored in: $TMP_KEYTAB"
        rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

	# getkeytab when $PRINC@RELM
	rlRun "ipa-getkeytab -s $MASTER $i $user1@$RELM --keytab $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1"
	MSG="Keytab successfully retrieved and stored in: $TMP_KEYTAB"
        rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"
done

rlPhaseEnd
}

getkeytab_004() {

rlPhaseStartTest "getkeytab_004: Testing the \"--keytab\" or the \"-k\" command options."

# Testing with "--keytab" and "-k" command options.

for i in "--keytab" "-k" ; do
	# getkeytab where $KEYTAB doesn't exist.
	if [ -f "$TMP_KEYTAB" ]; then
		rlRun "rm -f $TMP_KEYTAB"
	fi

	rlRun "ipa-getkeytab -s $MASTER --principal $user1 $i $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1"
        MSG="Keytab successfully retrieved and stored in: $TMP_KEYTAB"
        rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"
	rlAssertExists "$TMP_KEYTAB"

	rlRun "ipa-getkeytab -s $MASTER --principal $user1 $i $TMP_KEYTAB"
        rlAssertExists "$TMP_KEYTAB"
	rlRun "klist -ekt $TMP_KEYTAB | grep \"$RELM\" | wc -l > $TmpDir/getkeytab.out 2>&1"
	MSG="8"
	rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

        if [ -f "/opt/krb5.keytab.txt" ]; then
                rlRun "rm -f /opt/krb5.keytab.txt"
		rlRun "touch /opt/krb5.keytab.txt"
	else
		rlRun "touch /opt/krb5.keytab.txt"
        fi

        rlRun "ipa-getkeytab -s $MASTER --principal $user1 $i /opt/krb5.keytab.txt > $TmpDir/getkeytab.out 2>&1" 11
        MSG="Failed to add key to the keytab"
        rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

done
rlPhaseEnd
}

getkeytab_005() {

rlPhaseStartTest "getkeytab_005: Testing the \"-e\" (encryption types) command options."

	# Verifying the existing encryption types created in the default keytab durin ipa-client enrollment.
	rlRun "klist -ekt /etc/krb5.keytab > $TmpDir/keytab.out"
	rlAssertGrep "(aes256-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
	rlAssertGrep "(aes128-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
        rlAssertGrep "(des3-cbc-sha1)" "$TmpDir/keytab.out"
        rlAssertGrep "(arcfour-hmac)" "$TmpDir/keytab.out"
	rlRun "cat $TmpDir/keytab.out"


	# Testing for -e=aes256-cts
        if [ -f "$TMP_KEYTAB" ]; then
                rlRun "rm -f $TMP_KEYTAB"
        fi
	rlRun "ipa-getkeytab -s $MASTER -p $user1 -k $TMP_KEYTAB -e aes256-cts"
	rlRun "klist -ekt $TMP_KEYTAB > $TmpDir/keytab.out"
	rlAssertGrep "(aes256-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
	rlAssertNotGrep "(aes128-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
	rlAssertNotGrep "(des3-cbc-sha1)" "$TmpDir/keytab.out"
	rlAssertNotGrep "(arcfour-hmac)" "$TmpDir/keytab.out"
	rlRun "cat $TmpDir/keytab.out"
	rlRun "kinit -k -t $TMP_KEYTAB $user1"
	rlRun "kdestroy"
	rlRun "kinitAs $ADMINID $ADMINPW"


	# Testing for -e=aes128-cts
        if [ -f "$TMP_KEYTAB" ]; then
                rlRun "rm -f $TMP_KEYTAB"
        fi
	rlRun "ipa-getkeytab -s $MASTER -p $user1 -k $TMP_KEYTAB -e aes128-cts"
        rlRun "klist -ekt $TMP_KEYTAB > $TmpDir/keytab.out"
        rlAssertNotGrep "(aes256-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
        rlAssertGrep "(aes128-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
        rlAssertNotGrep "(des3-cbc-sha1)" "$TmpDir/keytab.out"
        rlAssertNotGrep "(arcfour-hmac)" "$TmpDir/keytab.out"
	rlRun "cat $TmpDir/keytab.out"
	rlRun "kinit -k -t $TMP_KEYTAB $user1"
	rlRun "kdestroy"
	rlRun "kinitAs $ADMINID $ADMINPW"


        # Testing for -e=arcfour-hmac
        if [ -f "$TMP_KEYTAB" ]; then
                rlRun "rm -f $TMP_KEYTAB"
        fi
        rlRun "ipa-getkeytab -s $MASTER -p $user1 -k $TMP_KEYTAB -e arcfour-hmac"
        rlRun "klist -ekt $TMP_KEYTAB > $TmpDir/keytab.out"
        rlAssertNotGrep "(aes256-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
        rlAssertNotGrep "(aes128-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
        rlAssertNotGrep "(des3-cbc-sha1)" "$TmpDir/keytab.out"
        rlAssertGrep "(arcfour-hmac)" "$TmpDir/keytab.out"
	rlRun "cat $TmpDir/keytab.out"
	rlRun "kinit -k -t $TMP_KEYTAB $user1"
	rlRun "kdestroy"
	rlRun "kinitAs $ADMINID $ADMINPW"


        # Testing for -e=des3-hmac-sha1
        if [ -f "$TMP_KEYTAB" ]; then
                rlRun "rm -f $TMP_KEYTAB"
        fi
        rlRun "ipa-getkeytab -s $MASTER -p $user1 -k $TMP_KEYTAB -e des3-hmac-sha1"
        rlRun "klist -ekt $TMP_KEYTAB > $TmpDir/keytab.out"
        rlAssertNotGrep "(aes256-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
        rlAssertNotGrep "(aes128-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
        rlAssertGrep "(des3-cbc-sha1)" "$TmpDir/keytab.out"
        rlAssertNotGrep "(arcfour-hmac)" "$TmpDir/keytab.out"
	rlRun "cat $TmpDir/keytab.out"
	rlRun "kinit -k -t $TMP_KEYTAB $user1"
	rlRun "kdestroy"
	rlRun "kinitAs $ADMINID $ADMINPW"

        # Testing for -e=invalid
        if [ -f "$TMP_KEYTAB" ]; then
                rlRun "rm -f $TMP_KEYTAB"
        fi
        rlRun "ipa-getkeytab -s $MASTER -p $user1 -k $TMP_KEYTAB -e invalid > $TmpDir/keytab.out 2>&1" 8
	MSG="Warning unrecognized encryption type"
	rlAssertGrep "$MSG" "$TmpDir/keytab.out"
	rlRun "cat $TmpDir/keytab.out"
        rlAssertNotExists "$TMP_KEYTAB"

	# des is no longer supported or available
	# Testing for -e=des-cbc-md5 (unsupported)
        #if [ -f "$TMP_KEYTAB" ]; then
        #        rlRun "rm -f $TMP_KEYTAB"
        #fi
        #rlRun "ipa-getkeytab -s $MASTER -p $user1 -k $TMP_KEYTAB -e des-cbc-md5 > $TmpDir/keytab.out 2>&1"
        #rlRun "klist -ekt $TMP_KEYTAB > $TmpDir/keytab.out"
        #rlAssertNotGrep "(aes256-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
        #rlAssertNotGrep "(aes128-cts-hmac-sha1-96)" "$TmpDir/keytab.out"
        #rlAssertNotGrep "(des3-cbc-sha1)" "$TmpDir/keytab.out"
        #rlAssertNotGrep "(arcfour-hmac)" "$TmpDir/keytab.out"
	#rlAssertGrep "(des-cbc-md5)" "$TmpDir/keytab.out"
        #rlRun "cat $TmpDir/keytab.out"
	#rlRun "kinit -k -t $TMP_KEYTAB $user1" 1 "Key table entry not found while getting initial credentials"
	#rlRun "kdestroy"
	#rlRun "kinitAs $ADMINID $ADMINPW"

rlPhaseEnd
}

getkeytab_006() {

rlPhaseStartTest "getkeytab_006: Testing the \"-P\" and the \"--password\" command options."


        if [ -f "$TMP_KEYTAB" ]; then
                rlRun "rm -f $TMP_KEYTAB"
        fi

	rlRun "kinitAs $ADMINID $ADMINPW" 0
	expfile=$TmpDir/kinit.exp
	rm -rf $expfile
	echo 'set timeout 30
set force_conservative 0
set send_slow {1 .1}' > $expfile
	echo "spawn ipa-getkeytab -s $MASTER -p $user1 -k $TMP_KEYTAB --password" >> $expfile
	echo 'match_max 100000' >> $expfile
	echo 'expect "*: "' >> $expfile
	echo 'sleep .5' >> $expfile
	echo "send -s -- \"$userpw\"" >> $expfile
	echo 'send -s -- "\r"' >> $expfile
	echo 'expect "*: "' >> $expfile
	echo 'sleep .5' >> $expfile
	echo "send -s -- \"$userpw\"" >> $expfile
	echo 'send -s -- "\r"' >> $expfile
	echo 'expect eof ' >> $expfile

	/usr/bin/expect $expfile
	rlRun "kinitAs $user1 $userpw"

	rlRun "ipa-getkeytab -s $MASTER -p $user1 -k $TMP_KEYTAB" 
	rlRun "kinitAs $user1 $userpw" 1


        if [ -f "$TMP_KEYTAB" ]; then
                rlRun "rm -f $TMP_KEYTAB"
        fi

	rlRun "kinitAs $ADMINID $ADMINPW" 0
        expfile=$TmpDir/kinit.exp
        rm -rf $expfile
        echo 'set timeout 30
set force_conservative 0
set send_slow {1 .1}' > $expfile
        echo "spawn ipa-getkeytab -s $MASTER -p $user1 -k $TMP_KEYTAB -P" >> $expfile
        echo 'match_max 100000' >> $expfile
        echo 'expect "*: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo "send -s -- \"$userpw\"" >> $expfile
        echo 'send -s -- "\r"' >> $expfile
        echo 'expect "*: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo "send -s -- \"$userpw\"" >> $expfile
        echo 'send -s -- "\r"' >> $expfile
        echo 'expect eof ' >> $expfile

        /usr/bin/expect $expfile
        rlRun "kinitAs $user1 $userpw"

        rlRun "ipa-getkeytab -s $MASTER -p $user1 -k $TMP_KEYTAB"
        rlRun "kinitAs $user1 $userpw" 1


rlPhaseEnd
}

getkeytab_007() {

rlPhaseStartTest "getkeytab_007: Testing \"--binddn\" and \"--bindpw\" command options."

	rlRun "kdestroy" 0 "Destroying admin credentials."
        MSG="Kerberos User Principal not found. Do you have a valid Credential Cache?"
        rlRun "ipa-getkeytab --server $MASTER --principal $user1 --keytab $TMP_KEYTAB > $TmpDir/getkeytab.out 2>&1" 6
        rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

	rlRun "ipa-getkeytab --server localhost --principal $user1 --keytab $TMP_KEYTAB -D \"cn=Directory Manager\" -w \"$userpw\" > $TmpDir/getkeytab.out 2>&1"
        MSG="Keytab successfully retrieved and stored in: $TMP_KEYTAB"
        rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

	rlRun "ipa-getkeytab --server localhost --principal $user1 --keytab $TMP_KEYTAB -D \" \" -w \"$userpw\" > $TmpDir/getkeytab.out 2>&1" 9
        MSG="Anonymous Binds are not allowed"
        rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

        rlRun "ipa-getkeytab --server localhost --principal $user1 --keytab $TMP_KEYTAB -D \"cn=Directory Manager\" -w \" \" > $TmpDir/getkeytab.out 2>&1" 9
        MSG="Simple bind failed"
        rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

        rlRun "ipa-getkeytab --server localhost --principal $user1 --keytab $TMP_KEYTAB -D \"cn=Directory Manager\" > $TmpDir/getkeytab.out 2>&1" 10
	MSG="Bind password required when using a bind DN."
	rlAssertGrep "$MSG" "$TmpDir/getkeytab.out"
	rlRun "cat $TmpDir/getkeytab.out"

rlPhaseEnd
}


rmkeytab_001() {

rlPhaseStartTest "rmkeytab_001: Testing the \"-p\" command option."
	
	rlRun "kinitAs $ADMINID $ADMINPW" 0
	rlRun "ipa-rmkeytab -p invalidprinc -k $TMP_KEYTAB > $TmpDir/rmkeytab.out 2>&1" 5
	MSG="principal not found"
	rlAssertGrep "$MSG" "$TmpDir/rmkeytab.out"
	rlRun "cat $TmpDir/rmkeytab.out"

	rlRun "ipa-getkeytab --server $MASTER --principal $user1 --keytab $TMP_KEYTAB" 0 "Getting keytab..."
	rlRun "ipa-rmkeytab -p $user1 -k $TMP_KEYTAB > $TmpDir/rmkeytab.out 2>&1"
	MSG="Removing principal $user1"
	rlAssertGrep "$MSG" "$TmpDir/rmkeytab.out"
	rlRun "cat $TmpDir/rmkeytab.out"
	rlRun "klist -ekt $TMP_KEYTAB > $TmpDir/keytab.out"
	rlAssertNotGrep "$user1" "$TmpDir/keytab.out"

rlPhaseEnd
}

rmkeytab_002() {

rlPhaseStartTest "rmkeytab_002: Testing the \"-r\" command option."

	rlRun "kinitAs $ADMINID $ADMINPW" 0
	rlRun "ipa-getkeytab --server $MASTER --principal $user1 --keytab $TMP_KEYTAB" 0 "Getting keytab..."
        rlRun "ipa-rmkeytab -r $RELM -k $TMP_KEYTAB > $TmpDir/rmkeytab.out 2>&1"
	rlRun "cat $TmpDir/rmkeytab.out"
        MSG="Removing principal $user1@$RELM"
        rlAssertGrep "$MSG" "$TmpDir/rmkeytab.out"
        rlRun "klist -ekt $TMP_KEYTAB > $TmpDir/keytab.out"
        rlAssertNotGrep "$user1@$RELM" "$TmpDir/keytab.out"

rlPhaseEnd
}

rmkeytab_003() {

rlPhaseStartTest "rmkeytab_003: Testing the \"-k\" command option."

	rlRun "kinitAs $ADMINID $ADMINPW" 0
        rlRun "ipa-getkeytab --server $MASTER --principal $user1 --keytab $TMP_KEYTAB" 0 "Getting keytab..."
        rlRun "ipa-rmkeytab -p $user1 -k /opt/invalid.keytab > $TmpDir/rmkeytab.out 2>&1" 3
	rlRun "cat $TmpDir/rmkeytab.out"
        MSG="Failed to open keytab"
        rlAssertGrep "$MSG" "$TmpDir/rmkeytab.out"

rlPhaseEnd
}

cleanup() {
rlPhaseStartTest "Clean up for getkeytab and rmkeytab tests"
	rlRun "kinitAs $ADMINID $ADMINPW" 0
	rlRun "ipa user-del $user1"
	sleep 5
	rlRun "ipa user-del $user2"
	rlRun "kdestroy" 0 "Destroying admin credentials."

        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
rlPhaseEnd
}
