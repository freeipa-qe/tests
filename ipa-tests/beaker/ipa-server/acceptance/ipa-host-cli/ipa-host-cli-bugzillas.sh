#/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-host-cli
#   Description: IPA host CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   The following bugzillas are to be tested:
#   https://bugzilla.redhat.com/show_bug.cgi?id=807388
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Michael Gregg <mgregg@redhat.com>
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

bugzillas() {

rlPhaseStartTest "ipa-host-bugzilla-001: BZ807388 - Error message has not a user friendly 'u' character in it."
	# Test for https://bugzilla.redhat.com/show_bug.cgi?id=807388
	cmd="ipa host-add --ip-address=2620:52:0:41c9:ffff:ff:fea:98eda mytestIPv6host.$RELM"
	expmsg="ipa: ERROR: invalid 'ip_address': failed to detect a valid IP address from '2620:52:0:41c9:ffff:ff:fea:98eda'"
	rlLog "Executing $cmd, expecting $expmsg"
	rlRun "verifyErrorMsg \"$cmd\" \"$expmsg\"" 0 "Verify expected error message as per BZ 807388. The message should not return the \"u'2620\" bit"
	ipa host-del mytestIPv6host.$RELM
rlPhaseEnd

rlPhaseStartTest "ipa-host-bugzilla-002: BZ827392 - Random password characters should be limited."
	# Test for https://bugzilla.redhat.com/show_bug.cgi?id=827392
	# get the ip address of that interface
	ipaddr=$(hostname -i)
	rlLog "Ip address is $ipaddr"
	ipoc1=$(echo $ipaddr | cut -d\. -f1)
	ipoc2=$(echo $ipaddr | cut -d\. -f2)
	ipoc3=$(echo $ipaddr | cut -d\. -f3)
	ipoc4=$(echo $ipaddr | cut -d\. -f4)
	thost="thost332.$DOMAIN"
	
	firstip=243
	ipa dnsrecord-find $DOMAIN | grep $ipoc1.$ipoc2.$ipoc3.$firstip
	if [ $? -eq 0 ]; then 
		rlLog "$ipoc1.$ipoc2.$ipoc3.$firstip seems taken, trying 1 ip higher"
		let firstip=$firstip+1
		ipa dnsrecord-find $DOMAIN | grep $ipoc1.$ipoc2.$ipoc3.$firstip
		if [ $? -eq 0 ]; then 
			rlLog "$ipoc1.$ipoc2.$ipoc3.$firstip seems taken, trying 1 ip higher"
			let firstip=$firstip+1
			ipa dnsrecord-find $DOMAIN | grep $ipoc1.$ipoc2.$ipoc3.$firstip
			if [ $? -eq 0 ]; then 
				rlLog "$ipoc1.$ipoc2.$ipoc3.$firstip seems taken, trying 1 ip higher"
				let firstip=$firstip+1
				ipa dnsrecord-find $DOMAIN | grep $ipoc1.$ipoc2.$ipoc3.$firstip
				if [ $? -eq 0 ]; then 
					rlLog "$ipoc1.$ipoc2.$ipoc3.$firstip seems taken, failing"
					rlFail "No avaliable IP's. Perhaps I need to rewrite this test."
				fi
			fi
		fi
	fi

	# Create dns entries for new test host for use later in this test
	ipa host-add --ip-address=$ipoc1.$ipoc2.$ipoc3.$firstip $thost
	ipa host-del $thost
	
	# generate some random password, then look for bad chars in them
	iteration=0
	while [ $iteration -lt 10 ]; do
		thispassword=$(ipa host-add --random $thost | grep password | sed s/\ \ //g | cut -d\  -f3)
		rlLog "Checking for bad characters in the random password $thispassword"
		rlRun "checkpass" 0 "Check to make sure that no unfriendly characters do not exist in the generated random password."
		ipa host-del $thost
		let iteration=$iteration+1
	done

rlPhaseEnd

}

# Function to be used in BZ 827392 test
checkpass () {
	rlLog "passed var was $1"
        echo $1 | grep "'" &> /dev/null
        if [ $? -eq 0 ]; then
                rlLog "' char detected"
		return 1
        fi
        echo $1 | grep '\\' &> /dev/null
        if [ $? -eq 0 ]; then
                rlLog "\ char detected"
		return 1
        fi
        echo $1 | grep '\$' &> /dev/null
        if [ $? -eq 0 ]; then
                rlLog "$ char detected"
		return 1
        fi
        echo $1 | grep '"' &> /dev/null
        if [ $? -eq 0 ]; then
                rlLog '" char detected'
		return 1
        fi
	return 0
}

