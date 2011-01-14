#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-dns
#   Description: IPA DNS acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Michael Gregg <mgregg@redhat.com>
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
    rlPhaseStartSetup "nis-cli startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

	rlPhaseStartTest "Installing rpcbind yptools"
		yum -y install wget rpcbind
	rlPhaseEnd

if [ $master -eq 1 ]; then
	setenforce 0
fi

	
	# Determine my IP address
	currenteth=$(route | grep ^default | awk '{print $8}')
	# get the ip address of that interface
	ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
	echo "Ip address is $ipaddr"
	ipoc1=$(echo $ipaddr | cut -d\. -f1) 
	ipoc2=$(echo $ipaddr | cut -d\. -f2) 
	ipoc3=$(echo $ipaddr | cut -d\. -f3) 
	ipoc4=$(echo $ipaddr | cut -d\. -f4) 
	echo "IP is $ipoc1 . $ipoc2 . $ipoc3 . $ipoc4"

	rlPhaseStartTest "ipa-dns-01: create a new fake host to test dns add during replica prepare"
		newip=$ipoc4+1
		ipa-replica-prepare -p $ADMINPW --ip-address=$ipoc1.$ipoc2.$ipoc3.$newip newfakehost$newip.$DOMAIN
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-02: ensure that the forward ip of the new fakehost was created in dns correctly with ping"
		rlRun "ping -c 1 newfakehost$newip.$DOMAIN" 0 "Checking to ensure that the forward for the new fake host was created in dns"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-03: ensure that the forward ip of the new fakehost was created in dns correctly with dig"
		rlRun "dig newfakehost$newip.$DOMAIN | grep $ipoc1.$ipoc2.$ipoc3.$newip" 0 "Checking to ensure that dig returns the correct ip address"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-04: ensure that the reverse entry of the new fakehost was created in dns correctly with dig"
		rlRun "dig -x $ipoc1.$ipoc2.$ipoc3.$newip | grep newfakehost$newip.$DOMAIN" 0 "Checking to ensure that reverse of newfakehost$newip.$DOMAIN is set up correctly"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-05: ensure that the forward ip of the new fakehost is resolvable by dnsrecord-show"
		rlRun "ipa dnsrecord-show $DOMAIN newfakehost$newip" 0 "Checking to ensure that ipa dns-show seems to think that the entry exists"
	rlPhaseEnd

# incomplete
	rlPhaseStartTest "ipa-dns-06: ensure that the reverse ip of the new fakehost is resolvable by dns-show"
		rlRun "ipa dns-sh $DOMAIN newfakehost$newip" 0 "Checking to ensure that ipa dnsrecord-show gives the reverse for fakehost"
	rlPhaseEnd

	
	rlPhaseStartTest "ipa-dns-07: create a new zone"
		rlRun "ipa dnsrecord-show $DOMAIN newfakehost$newip" 0 "Checking to ensure that ipa dns-show seems to think that the entry exists"
	rlPhaseEnd


    makereport
rlJournalEnd


 
# manifest:
# teststuie   : ipasample
    ## testset: _lifetime
        ### testcase: minlife_nolimit 
            #### comment : this is to test for minimum of password history
            #### data-loop : minage
            #### data-no-loop : pwusername pwinintial_password
        ### testcase: _minlife_somelimit
            #### comment: set password life time to 0
            #### data-loop: 
            #### data-no-loop : pwusername pwinitial_password
        ### testcase: _minlife_negative
            #### comment: negative test case for minimum password life
            #### data-loop: minage
            #### data-no-loop : pwusername pwinitial_password
        ### testcase: _minlife_verify
            #### comment: verify the changes
            #### data-loop: minage
            #### data-no-loop : pwusername pwinitial_password
    ## testset: pwhistory
        ### testcase: _defaultvalue
            #### comment: verifyt the default value
            #### data-loop: size day 
            #### data-no-loop:  admin adminpassword
        ### testcase: _lowbound
            #### comment: check the lower bound of value range
            #### data-loop:  size day expired
            #### data-no-loop: 
        ### testcase: password_history_negative
            #### comment: do negative test on history of password
            #### data-loop:  size day expired newpw
            #### data-no-loop: admin adminpassword
