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
	nfgroup=lookgt
	dnsrecname=formtnamedns
	ipaddressa="33.44.55.66"
	ipaddressb="99.88.77.66"
	badipaddressa="333.111.222.444"
	jsonfile=/dev/shm/forms-cli-json.script
	jsonfilegrp=/dev/shm/forms-cli-json-grp.script
	jsonfilegrpdel=/dev/shm/forms-cli-json-grp-del.script
	jsondnsadda=/dev/shm/forms-cli-add-dnsa.script
	jsondnsaddb=/dev/shm/forms-cli-add-dnsb.script
	badjsondnsadda=/dev/shm/forms-cli-add-badjsondnsadda.script
	jsondnsdela=/dev/shm/forms-cli-del-dnsa.script

echo "{
    \"method\":\"user_add\",
   
\"params\":[[],{\"givenname\":\"tim\",\"sn\":\"user\",\"krbprincipalname\":\"$nfuser@$DOMAIN\",\"uid\":\"$nfuser\",\"all\":true}
    ],
    \"id\":1
}" > $jsonfile

echo "{
    \"method\":\"group_add\",
\"params\":[[],{\"cn\":\"$nfgroup\",\"givenname\":\"newgg\",\"sn\":\"group\",\"krbprincipalname\":\"$nfgroup@$DOMAIN\",\"gid\":\"7765\",\"description\":\"test-desc\",\"all\":true}
    ],
    \"id\":1}" >$jsonfilegrp

echo "{
    \"method\":\"group_del\",
\"params\":[[],{\"cn\":\"$nfgroup\",\"all\":true}
    ],
    \"id\":1}" >$jsonfilegrpdel

echo "{
    \"method\":\"dnsrecord_add\",
\"params\":[[],{\"dnszoneidnsname\":\"$DOMAIN\",\"idnsname\":\"$dnsrecname\",\"arecord\":\"$ipaddressa\"}
    ],
    \"id\":1}" > $jsondnsadda

echo "{
    \"method\":\"dnsrecord_del\",
\"params\":[[],{\"dnszoneidnsname\":\"$DOMAIN\",\"idnsname\":\"$dnsrecname\",\"arecord\":\"$ipaddressa\"}
    ],
    \"id\":1}" > $jsondnsdela

echo "{
    \"method\":\"dnsrecord_add\",
\"params\":[[],{\"dnszoneidnsname\":\"$DOMAIN\",\"idnsname\":\"$dnsrecname\",\"arecord\":\"$ipaddressb\"}
    ],
    \"id\":1}" > $jsondnsaddb

echo "{
    \"method\":\"dnsrecord_add\",
\"params\":[[],{\"dnszoneidnsname\":\"$DOMAIN\",\"idnsname\":\"$dnsrecname\",\"arecord\":\"$badipaddressa\"}
    ],
    \"id\":1}" > $badjsondnsadda


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

	rlPhaseStartTest "forms-cli-04: attempt to create a new group with bad credentials."
		kdestroy
		curl -v -H "Content-Type:application/json" -H "Referer: https://$MASTER/ipa/xml" -H "Accept:application/json"  -H "Accept-Language:en" --cacert /etc/ipa/ca.crt -d  @$jsonfilegrp -X POST -b "ipa_session=1234567890; httponly; Path=/ipa; secure" https://$MASTER/ipa/session/json &> $outputf 
		rlLog "cat $outputf | grep Added\ group | grep $nfgroup" 1 "make sure that the groups name is not in the output of the test command"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa group-find $nfgroup" 1 "Make sure that admin is not able to find the new group $nfgroup"
	rlPhaseEnd

	rlPhaseStartTest "forms-cli-05: Get a valid session id with good credentials."
		echo "user=$ADMINID&password=$ADMINPW" > $loginfile
		echo "curl -v --dump-header $responsefile -k -H 'Content-Type: application/x-www-form-urlencoded' https://$MASTER/ipa/session/login_password -X POST -d @$loginfile"
		curl -v --dump-header $responsefile -k -H 'Content-Type: application/x-www-form-urlencoded' https://$MASTER/ipa/session/login_password -X POST -d @$loginfile
		rlRun "grep ipa_session= $responsefile" 0 "Make sure that the response header contains a session id in it"
		sessionid=$(cat $responsefile | grep ipa_session | cut -d\  -f2 | cut -d\= -f2 | sed s/\;//g)
		export sessionid
		rlLog "new admin session ID is $sessionid"
	rlPhaseEnd

	rlPhaseStartTest "forms-cli-06: Create a new user with the aquired session id. ie, retry forms-cli-02 with valid credentials."
		echo "url -v -H \"Content-Type:application/json\" -H \"Referer: https://$MASTER/ipa/xml\" -H \"Accept:application/json\"  -H \"Accept-Language:en\" --cacert /etc/ipa/ca.crt -d  @$jsonfile -X POST -b \"ipa_session=$sessionid; httponly; Path=/ipa; secure\" https://$MASTER/ipa/session/json"
		curl -v -H "Content-Type:application/json" -H "Referer: https://$MASTER/ipa/xml" -H "Accept:application/json"  -H "Accept-Language:en" --cacert /etc/ipa/ca.crt -d  @$jsonfile -X POST -b "ipa_session=$sessionid; httponly; Path=/ipa; secure" https://$MASTER/ipa/session/json &> $outputf 
		rlLog "grep tim\ user $outputf" 0 "make sure that the users name is in the output of the test command"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa user-find $nfuser" 0 "Make sure that admin is able to find the new user $nfsuer"
		rlRun "ipa user-del $nfuser" 0 "Delete the test user $nfsuer"
	rlPhaseEnd

	rlPhaseStartTest "forms-cli-07: Create a new group with the aquired session id. ie, retry forms-cli-03 with valid credentials."
		kdestroy
		curl -v -H "Content-Type:application/json" -H "Referer: https://$MASTER/ipa/xml" -H "Accept:application/json"  -H "Accept-Language:en" --cacert /etc/ipa/ca.crt -d  @$jsonfilegrp -X POST -b "ipa_session=$sessionid; httponly; Path=/ipa; secure" https://$MASTER/ipa/session/json &> $outputf 
		rlLog "cat $outputf | grep Added\ group | grep $nfgroup" 0 "make sure that the groups name is in the output of the test command"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa group-find $nfgroup" 0 "Make sure that admin is able to find the new group $nfgroup"
	rlPhaseEnd

	rlPhaseStartTest "forms-cli-08: Delete the group created in the last step using valid credentials in a form."
		kdestroy
		curl -v -H "Content-Type:application/json" -H "Referer: https://$MASTER/ipa/xml" -H "Accept:application/json"  -H "Accept-Language:en" --cacert /etc/ipa/ca.crt -d  @$jsonfilegrpdel -X POST -b "ipa_session=$sessionid; httponly; Path=/ipa; secure" https://$MASTER/ipa/session/json &> $outputf 
		rlLog "cat $outputf | grep Deleted group | grep $nfgroup" 0 "make sure that the groups name is listed as deleted in the output of the test command"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa group-find $nfgroup" 1 "Make sure that admin is not able to find the new group $nfgroup"
	rlPhaseEnd

	rlPhaseStartTest "forms-cli-09: Add a good A record with forms based authentication."
		kdestroy
		curl -v -H "Content-Type:application/json" -H "Referer: https://$MASTER/ipa/xml" -H "Accept:application/json"  -H "Accept-Language:en" --cacert /etc/ipa/ca.crt -d  @$jsondnsadda -X POST -b "ipa_session=$sessionid; httponly; Path=/ipa; secure" https://$MASTER/ipa/session/json &> $outputf 
		rlLog "cat $outputf | grep idnsname | grep $dnsrecname" 0 "make sure that the new dns name seems to be in the add output"
		rlLog "cat $outputf | grep $ipaddressa" 0 "make sure that the new ipaddress seems to be in the add output"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
ipa dnsrecord-find $DOMAIN $dnsrecname
		rlRun "ipa dnsrecord-find $DOMAIN $dnsrecname | grep $ipaddressa" 0 "Make sure that the new ipa address seems to be in the server"
	rlPhaseEnd

	rlPhaseStartTest "forms-cli-10: Add a second good A record with forms based authentication."
		kdestroy
		echo "curl -v -H \"Content-Type:application/json\" -H \"Referer: https://$MASTER/ipa/xml\" -H \"Accept:application/json\" -H \"Accept-Language:en\" --cacert /etc/ipa/ca.crt -d  @$jsondnsaddb -X POST -b \"ipa_session=$sessionid; httponly; Path=/ipa; secure\" https://$MASTER/ipa/session/json"
		curl -v -H "Content-Type:application/json" -H "Referer: https://$MASTER/ipa/xml" -H "Accept:application/json"  -H "Accept-Language:en" --cacert /etc/ipa/ca.crt -d  @$jsondnsaddb -X POST -b "ipa_session=$sessionid; httponly; Path=/ipa; secure" https://$MASTER/ipa/session/json &> $outputf 
		rlLog "cat $outputf | grep idnsname | grep $dnsrecname" 0 "make sure that the new dns name seems to be in the add output"
		rlLog "cat $outputf | grep $ipaddressa" 0 "make sure that the original ipaddress seems to be in the add output"
		rlLog "cat $outputf | grep $ipaddressb" 0 "make sure that the new ipaddress seems to be in the add output"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa dnsrecord-find $DOMAIN $dnsrecname | grep $ipaddressa" 0 "Make sure that the original ip address seems to be in the server"
		rlRun "ipa dnsrecord-find $DOMAIN $dnsrecname | grep $ipaddressb" 0 "Make sure that the new ip address seems to be in the server"
	rlPhaseEnd

	rlPhaseStartTest "forms-cli-11: Try to add a bad ip a record with forma based auth."
		kdestroy
		curl -v -H "Content-Type:application/json" -H "Referer: https://$MASTER/ipa/xml" -H "Accept:application/json"  -H "Accept-Language:en" --cacert /etc/ipa/ca.crt -d  @$badjsondnsadda -X POST -b "ipa_session=$sessionid; httponly; Path=/ipa; secure" https://$MASTER/ipa/session/json &> $outputf 
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa dnsrecord-find $DOMAIN $dnsrecname | grep $ipaddressa" 0 "Make sure that the first original ip address seems to be in the server"
		rlRun "ipa dnsrecord-find $DOMAIN $dnsrecname | grep $ipaddressb" 0 "Make sure that the second original ip address seems to be in the server"
		rlRun "ipa dnsrecord-find $DOMAIN $dnsrecname | grep $badipaddressa" 1 "Make sure that the bad ip address isn't on the server"
	rlPhaseEnd

	rlPhaseStartTest "forms-cli-12: Delete A record with forms based authentication."
		kdestroy
		curl -v -H "Content-Type:application/json" -H "Referer: https://$MASTER/ipa/xml" -H "Accept:application/json"  -H "Accept-Language:en" --cacert /etc/ipa/ca.crt -d  @$jsondnsdela -X POST -b "ipa_session=$sessionid; httponly; Path=/ipa; secure" https://$MASTER/ipa/session/json &> $outputf 
		rlLog "cat $outputf | grep $ipaddressa" 0 "make sure that the first original ipaddress seems to be in the add output"
		rlLog "cat $outputf | grep $ipaddressb" 0 "make sure that the second original ipaddress seems to be in the add output"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa dnsrecord-find $DOMAIN $dnsrecname | grep $ipaddressa" 1 "Make sure that the original ip address has been removed the server"
		rlRun "ipa dnsrecord-find $DOMAIN $dnsrecname | grep $ipaddressb" 0 "Make sure that the new ip address seems to be in the server"
		rlRun "ipa dnsrecord-find $DOMAIN $dnsrecname | grep $badipaddressa" 1 "Make sure that the bad ip address isn't on the server"
		rlRun "ipa dnsrecord-del $DOMAIN $dnsrecname --a-rec=$ipaddressb" 0 "cleanup the second added a record."
	rlPhaseEnd

	rlJournalPrintText
	report=/tmp/rhts.report.$RANDOM.txt
	makereport $report
	rhts-submit-log -l $report

rlJournalEnd
