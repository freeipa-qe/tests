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

	
	zone=newzone
	email="ipaqa@redhat.com"
	serial=2010010701
	refresh=300
	retry=100
	expire=1200
	minimum=30
	maximum=300
	TTL=50
	badnum=12345678901234
	rlPhaseStartTest "ipa-dns-07: create a new zone"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl $zone" 0 "Checking to ensure that ipa thinks that it can create a zone"
	rlPhaseEnd

# Neg zone add test cases
	rlPhaseStartTest "ipa-dns-08: try to create a new zone using a bad serial number"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$badnum --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl zone" 1 "trying to create a zone using a bad serial number"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-09: try to create a new zone using a bad refresh"
		rlRun "ipa dnszone-add --name-server=$ipaddr--admin-email=$email --serial=$serial --refresh=$badnum --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl zone" 1 "trying to create a zone using a bad refresh"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-10: try to create a new zone using a bad retry"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$badnum --expire=$expire --minimum=$minimum --ttl=$ttl zone" 1 "trying to create a zone using a bad retry"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-11: try to create a new zone using a bad expire"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$badnum --minimum=$minimum --ttl=$ttl zone" 1 "trying to create a zone using a bad expire"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-12: try to create a new zone using a bad minimum"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$badnum --ttl=$ttl zone" 1 "trying to create a zone using a bad minimum"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-13: try to create a new zone using a bad ttl"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$badnum zone" 1 "trying to create a zone using a bad ttl"
	rlPhaseEnd

# End neg add test cases

	rlPhaseStartTest "ipa-dns-14: checking to ensure that the new zone got created with the correct name-server"
		rlRun "ipa dnszone-find $zone | grep $ipaddr" 0 "checking to ensure that the new zone got created with the correct name-server"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-15: checking to ensure that the new zone got created with the correct email"
		rlRun "ipa dnszone-find $zone | grep $email" 0 "checking to ensure that the new zone got created with the correct email"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-16: checking to ensure that the new zone got created with the correct serial number"
		rlRun "ipa dnszone-find $zone | grep $serial" 0 "checking to ensure that the new zone got created with the correct serial number"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-17: checking to ensure that the new zone got created with the correct refresh"
		rlRun "ipa dnszone-find $zone | grep $refresh" 0 "checking to ensure that the new zone got created with the correct "
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-18: checking to ensure that the new zone got created with the correct retry"
		rlRun "ipa dnszone-find $zone | grep $retry" 0 "checking to ensure that the new zone got created with the correct retry"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-19: checking to ensure that the new zone got created with the correct expire"
		rlRun "ipa dnszone-find $zone | grep $expire" 0 "checking to ensure that the new zone got created with the correct expire"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-20: checking to ensure that the new zone got created with the correct minimum"
		rlRun "ipa dnszone-find $zone | grep $minimum" 0 "checking to ensure that the new zone got created with the correct minimum"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-21: checking to ensure that the new zone got created with the correct ttl"
		rlRun "ipa dnszone-find $zone | grep $ttl" 0 "checking to ensure that the new zone got created with the correct ttl"
	rlPhaseEnd

	a="1.2.3.4"
	a2="1.2.3.4,2.3.4.5"
	aaaa="fec0:0:a10:6000:10:16ff:fe98:193"
	afsdb="green.femto.edu."
	
	  --a-rec=LIST          comma-separated list of A records
  --aaaa-rec=LIST       comma-separated list of AAAA records
  --a6-rec=LIST         comma-separated list of A6 records
  --afsdb-rec=LIST      comma-separated list of AFSDB records
  --apl-rec=LIST        comma-separated list of APL records
  --cert-rec=LIST       comma-separated list of CERT records
  --cname-rec=LIST      comma-separated list of CNAME records
  --dhcid-rec=LIST      comma-separated list of DHCID records
  --dlv-rec=LIST        comma-separated list of DLV records
  --dname-rec=LIST      comma-separated list of DNAME records
  --dnskey-rec=LIST     comma-separated list of DNSKEY records
  --ds-rec=LIST         comma-separated list of DS records
  --hinfo-rec=LIST      comma-separated list of HINFO records
  --hip-rec=LIST        comma-separated list of HIP records
  --ipseckey-rec=LIST   comma-separated list of IPSECKEY records
  --key-rec=LIST        comma-separated list of KEY records
  --kx-rec=LIST         comma-separated list of KX records
  --loc-rec=LIST        comma-separated list of LOC records
  --md-rec=LIST         comma-separated list of MD records
  --minfo-rec=LIST      comma-separated list of MINFO records
  --mx-rec=LIST         comma-separated list of MX records
  --naptr-rec=LIST      comma-separated list of NAPTR records
  --ns-rec=LIST         comma-separated list of NS records
  --nsec-rec=LIST       comma-separated list of NSEC records
  --nsec3-rec=LIST      comma-separated list of NSEC3 records
  --nsec3param-rec=LIST
                        comma-separated list of NSEC3PARAM records
  --nxt-rec=LIST        comma-separated list of NXT records
  --ptr-rec=LIST        comma-separated list of PTR records
  --rrsig-rec=LIST      comma-separated list of RRSIG records
  --rp-rec=LIST         comma-separated list of RP records
  --sig-rec=LIST        comma-separated list of SIG records
  --spf-rec=LIST        comma-separated list of SPF records
  --srv-rec=LIST        comma-separated list of SRV records
  --sshfp-rec=LIST      comma-separated list of SSHFP records
  --ta-rec=LIST         comma-separated list of TA records
  --tkey-rec=LIST       comma-separated list of TKEY records
  --tsig-rec=LIST       comma-separated list of TSIG records
  --txt-rec=LIST        comma-separated list of TXT records

	rlPhaseStartTest "ipa-dns-22: add record type A with one record"
		rlRun "ipa drecord-add " 0 "add record type"
	rlPhaseEnd

    makereport
rlJournalEnd


 
