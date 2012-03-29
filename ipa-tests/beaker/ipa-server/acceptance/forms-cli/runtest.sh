#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/forms-cli
#   Description: IPA DNS acceptance tests to test usage of kerberos forms.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Michael Gregg <mgregg@redhat.com>
#   Date  : Jan 21, 2011
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

PACKAGE="ipa-server"

# Init master var
export master=0;

hostname_s=$(hostname -s)

##########################################
#   test main 
#########################################

# Determine if this is a master

if [ "$MASTER" = "$HOSTNAME" ]; then 
	export master=1;
fi

rlJournalStart
    rlPhaseStartSetup "forms-cli startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

    rlPhaseEnd

# all testing should be with selinux enforcing!
#if [ $master -eq 1 ]; then
#	setenforce 0
#fi

	# Determine my IP address
	currenteth=$(route | grep ^default | awk '{print $8}')

	# get the ip address of that interface
	ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
	echo "Ip address is $ipaddr"
	ipoc1=$(echo $ipaddr | cut -d\. -f1) 
	ipoc2=$(echo $ipaddr | cut -d\. -f2) 
	ipoc3=$(echo $ipaddr | cut -d\. -f3) 
	ipoc4=$(echo $ipaddr | cut -d\. -f4) 

	rlPhaseStartTest "forms-cli-01: Destroy credentials"
		rlLog "Destroy kinit."
		rlRun "kdestroy" 0 "destroy any credentials that may already exist"
#		verifyErrorMsg "ipa dnsrecord-add $DOMAIN dns176 --ns-hostname=ns1.shanks.$DOMAIN" "ipa: ERROR: Nameserver 'ns1.shanks.$DOMAIN' does not have a corresponding A/AAAA record"

        rlPhaseEnd
	
	nfuser=tbokl
	jsonfile=/dev/shm/forms-cli-json.script
echo "{
    \"method\":\"user_add\",
   
\"params\":[[],{\"givenname\":\"tim\",\"sn\":\"user\",\"krbprincipalname\":\"$nfuser@$DOMAIN\",\"uid\":\"$nfuser\",\"all\":true}
    ],
    \"id\":1
}" > $jsonfile

	rlPhaseStartTest "forms-cli-02: Ensure that json script does not work without a valid session ID"
		outputf=/dev/shm/forms-tmp-out.txt
		curl -v -H "Content-Type:application/json" -H "Referer: https://$MASTER/ipa/xml" -H "Accept:application/json"  -H "Accept-Language:en" --cacert /etc/ipa/ca.crt -d  @$jsonfile -X POST -b "ipa_session=0e1fb49d6d46c237e9f3584c96467e1; httponly; Path=/ipa; secure" https://$MASTER/ipa/session/json &> $outputf 
		rlRun "grep 401\ Unauthorized $outputf" 0 "Make sure that the output of the curl request seems to have failed"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa user-find $nfuser" 1 "Make sure that admin is unable to find the new user $nfsuer"
		rlRun "kdestroy" 0 "destroy any credentials that may already exist"
	rlPhaseEnd

	loginfile=/dev/shm/loginfile.txt
	responsefile=/dev/shm/loginresponsefile.txt
	rlPhaseStartTest "forms-cli-03: ensure that you cannot get a valid session id with bad credentials."
		echo "user=admin&password=Badpw168" > $loginfile
		curl -v --dump-header $responsefile -k -H 'Content-Type: application/x-www-form-urlencoded' "https://$MASTER/ipa/session/login_password" -X POST -d @$loginfile
		rlRun "grep ipa_session= $responsefile" 1 "Make sure that the response header does not appear to have a session id in it"
	rlPhaseEnd

	rlPhaseStartTest "forms-cli-04: Get a valid session id with good credentials."
		echo "user=$ADMINID&password=$ADMINPW" > $loginfile
		curl -v --dump-header $responsefile -k -H 'Content-Type: application/x-www-form-urlencoded' https://$MASTER/ipa/session/login_password -X POST -d @$loginfile
		rlRun "grep ipa_session= $responsefile" 0 "Make sure that the response header contains a session id in it"
		sessionid=$(cat $responsefile | grep ipa_session | cut -d\  -f2 | cut -d\= -f2 | sed s/\;//g)
		export sessionid
		rlLog "new admin session ID is $sessionid"
	rlPhaseEnd
		
	rlPhaseStartTest "forms-cli-05: Create a new user with the aquired session id. ie, retry forms-cli-02 with valid credentials."
		curl -v -H "Content-Type:application/json" -H "Referer: https://$MASTER/ipa/xml" -H "Accept:application/json"  -H "Accept-Language:en" --cacert /etc/ipa/ca.crt -d  @$jsonfile -X POST -b "ipa_session=$sessionid; httponly; Path=/ipa; secure" https://$MASTER/ipa/session/json &> $outputf 
		rlLog "grep tim\ user $outputf" 0 "make sure that the user's name is in the output of the test command"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa user-find $nfuser" 0 "Make sure that admin is able to find the new user $nfsuer"
		rlRun "ipa user-del $nfuser" 0 "Delete the test user $nfsuer"
	rlPhaseEnd

	rlJournalPrintText
	report=/tmp/rhts.report.$RANDOM.txt
	makereport $report
	rhts-submit-log -l $report

rlJournalEnd
