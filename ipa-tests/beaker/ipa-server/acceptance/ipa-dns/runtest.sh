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
#   Date  : Jan 21, 2011
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
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

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
		let newip=$ipoc4+1
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
		rlRun "ipa dnsrecord-show $DOMAIN newfakehost$newip" 0 "Checking to ensure that ipa dnsrecord-show seems to think that the entry exists"
	rlPhaseEnd

# incomplete
	rlPhaseStartTest "ipa-dns-06: ensure that the reverse ip of the new fakehost is resolvable by dnsrecord-show"
		rlRun "ipa dnsrecord-show $DOMAIN newfakehost$newip" 0 "Checking to ensure that ipa dnsrecord-show gives the reverse for fakehost"
	rlPhaseEnd

	ipaddr=`hostname`	
	zone=newzone
	email="ipaqar.redhat.com"
	serial=2010010701
	refresh=303
	retry=101
	expire=1202
	minimum=33
	ttl=55
	badnum=12345678901234
	loclat="121"
	loclong="59"
	loc="37 23 30.900 N $loclat $loclong 19.000 W 7.00m 100.00m 100.00m 2.00m"
	naptr='100 10 U E2U+msg !^.*$!mailto:info@example.com! .'
	
	rlPhaseStartTest "ipa-dns-07: create a new zone"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl $zone" 0 "Checking to ensure that ipa thinks that it can create a zone"
		rlRun "/usr/sbin/ipactl restart" 0 "Restarting IPA server"
	rlPhaseEnd

# Neg zone add test cases
	rlPhaseStartTest "ipa-dns-08: try to create a new zone using a bad serial number"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$badnum --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl zone" 1 "trying to create a zone using a bad serial number"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-09: try to create a new zone using a bad refresh"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$badnum --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl zone" 1 "trying to create a zone using a bad refresh"
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
		rlRun "ipa dnszone-find --all $zone | grep $ipaddr" 0 "checking to ensure that the new zone got created with the correct name-server"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-15: checking to ensure that the new zone got created with the correct email"
		rlRun "ipa dnszone-find --all $zone | grep $email" 0 "checking to ensure that the new zone got created with the correct email"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-16: checking to ensure that the new zone got created with the correct serial number"
		rlRun "ipa dnszone-find --all $zone | grep $serial" 0 "checking to ensure that the new zone got created with the correct serial number"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-17: checking to ensure that the new zone got created with the correct refresh"
		rlRun "ipa dnszone-find --all $zone | grep $refresh" 0 "checking to ensure that the new zone got created with the correct "
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-18: checking to ensure that the new zone got created with the correct retry"
		rlRun "ipa dnszone-find --all $zone | grep $retry" 0 "checking to ensure that the new zone got created with the correct retry"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-19: checking to ensure that the new zone got created with the correct expire"
		rlRun "ipa dnszone-find --all $zone | grep $expire" 0 "checking to ensure that the new zone got created with the correct expire"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-20: checking to ensure that the new zone got created with the correct minimum"
		rlRun "ipa dnszone-find --all $zone | grep $minimum" 0 "checking to ensure that the new zone got created with the correct minimum"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-21: checking to ensure that the new zone got created with the correct ttl"
		rlRun "ipa dnszone-find --all $zone | grep $ttl" 0 "checking to ensure that the new zone got created with the correct ttl"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-22: checking to with dig to ensure that the new zone got created with the correct name server"
		rlRun "dig $zone SOA | grep NS | grep $ipaddr" 0 "checking with dig to ensure that the new zone got created with the correct name server"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-23: checking to with dig to ensure that the new zone got created with the correct email"
		rlRun "dig $zone SOA | grep $email" 0 "checking with dig to ensure that the new zone got created with the correct email"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-24: checking to with dig to ensure that the new zone got created with the correct serial number"
		rlRun "dig $zone SOA | grep $serial" 0 "checking with dig to ensure that the new zone got created with the correct serial number"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-25: checking to with dig to ensure that the new zone got created with the correct refresh"
		rlRun "dig $zone SOA | grep $refresh" 0 "checking with dig to ensure that the new zone got created with the correct refresh"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-26: checking to with dig to ensure that the new zone got created with the correct retry interval"
		rlRun "dig $zone SOA | grep $retry" 0 "checking with dig to ensure that the new zone got created with the correct retry interval"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-27: checking to with dig to ensure that the new zone got created with the correct expire"
		rlRun "dig $zone SOA | grep $expire" 0 "checking with dig to ensure that the new zone got created with the correct expire"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-28: checking to with dig to ensure that the new zone got created with the correct minimum"
		rlRun "dig $zone SOA | grep $minimum" 0 "checking with dig to ensure that the new zone got created with the correct minimum"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-29: checking to with dig to ensure that the new zone got created with the correct ttl"
		rlRun "dig $zone SOA | grep $ttl" 0 "checking with dig to ensure that the new zone got created with the correct ttl"
	rlPhaseEnd


	a="1.2.3.4"
	a2="1.2.3.4,2.3.4.5"
	aaaa="fec0:0:a10:6000:10:16ff:fe98:193"
	aaaabad1="bada:aaaa:real:ly:bad:dude:extr:a"
	aaaabad2="aaaa:bbbb:cccc:dddd:eeee:fffff"
	afsdb="green.femto.edu."
	certa="PGP 0 0"
	cert="HC1AAH5t0b9xzRojScUBtVOUObTkFdb/tN81G2MmDL8AXr+tFlJ4J76cckH45wgSRVpIIiH6xdG8pifxp5+D2g=="
	cname="m.l.k."
	dname="bar.$zone."
	txt="none=1.2.3.4"
	mx="9.78.7.6"
	ptroctet="4.4.4"
	ptr="8"
	ptrvalue="in.awesome.domain."
	srva="0 100 389"
	srv="why.go.here.com."
	naptr='E2U+msg" "!^.*$!mailto:info@example.com!'
	kxpref1="12345678"
	kxbadpref1="-1"
	kxbadpref2="1233456789012345"
	
	# These values are all for creating the ptr zone
	ptrzone="$ptroctet.in-addr.arpa."
	# Bad ptr zone
	bptrzone="1.2.3.in-addr.arpa."
	pemail="ipaqar.redhat.com"
	pserial=2010010799
	prefresh=393
	pretry=191
	pexpire=1292
	pminimum=39
	pttl=59
	pbadnum=123456789012399

	# record additions and delettion test
	# Type A
	rlPhaseStartTest "ipa-dns-30: add record of type A"
		rlRun "ipa dnsrecord-add $zone allll --a-rec $a" 0 "add record type a"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-31: make sure that IPA saved record type A"
		rlRun "ipa dnsrecord-find $zone allll | grep $a" 0 "make sure ipa recieved record type A"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-32: make sure that dig can find the record type A"
		rlRun "dig allll.$zone | grep $a" 0 "make sure dig can find the A record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-33: delete record of type A"
		rlRun "ipa dnsrecord-del $zone allll --a-rec $a" 0 "delete record type a"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-34: make sure that IPA deleted record type A"
		rlRun "ipa dnsrecord-find $zone allll" 1 "make sure ipa deleted record type A"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-35: make sure that dig can not find the record type A"
		rlRun "dig allll.$zone A | grep $a" 1 "make sure dig can not find the A record"
	rlPhaseEnd

	# Type Multiple A's
	rlPhaseStartTest "ipa-dns-36: add record of type multiple A records"
		rlRun "ipa dnsrecord-add $zone aa2 --a-rec $a2" 0 "add record type a"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-37: make sure that IPA saved the first type A record"
		thisa=$(echo $a2 | sed s/,/\ /g | awk '{print $1}')
		rlRun "ipa dnsrecord-find $zone aa2 | grep $thisa" 0 "make sure ipa recieved record type A"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-38: make sure that dig can find the first a record"
		rlRun "dig aa2.$zone | grep $thisa" 0 "make sure dig finds the first A record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-39: make sure that IPA saved the second type A record"
		thisa=$(echo $a2 | sed s/,/\ /g | awk '{print $2}')
		rlRun "ipa dnsrecord-find $zone aa2 | grep $thisa" 0 "make sure ipa recieved second record type A"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-40: make sure that dig can find the second a record"
		rlRun "dig aa2.$zone | grep $thisa" 0 "make sure dig finds the first A record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-41: delete record of type multiple A"
		rlRun "ipa dnsrecord-del $zone aa2 --a-rec $a2" 0 "delete record type multiple a"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-42: make sure that IPA removed the first type A record"
		thisa=$(echo $a2 | sed s/,/\ /g | awk '{print $1}')
		rlRun "ipa dnsrecord-find $zone aa2 | grep $thisa" 1 "make sure ipa removed record type A"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-43: make sure that dig cannot find the first a record"
		rlRun "dig aa2.$zone | grep $thisa" 1 "make sure dig does not find the first A record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-44: make sure that IPA removed the second type A record"
		thisa=$(echo $a2 | sed s/,/\ /g | awk '{print $2}')
		rlRun "ipa dnsrecord-find $zone aa2 | grep $thisa" 1 "make sure ipa removed second record type A"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-45: make sure that dig can not find the second a record"
		rlRun "dig aa2.$zone | grep $thisa" 1 "make sure dig does not finds the first A record"
	rlPhaseEnd

	# Type AAAA
	rlPhaseStartTest "ipa-dns-46: add record of type AAAA"
		rlRun "ipa dnsrecord-add $zone aaaa --aaaa-rec='$aaaa'" 0 "add record type AAAA"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-47: make sure that IPA saved record type AAAA"
		rlRun "ipa dnsrecord-find $zone aaaa | grep $aaaa" 0 "make sure ipa recieved record type AAAA"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-48: make sure that dig can find the record type AAAA"
		rlRun "dig aaaa.$zone AAAA | grep $aaaa" 0 "make sure dig can find the AAAA record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-49: delete record of type AAAA"
		rlRun "ipa dnsrecord-del $zone aaaa --aaaa-rec $aaaa" 0 "delete record type AAAA"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-50: make sure that IPA deleted record type AAAA"
		rlRun "ipa dnsrecord-find $zone aaaa" 1 "make sure ipa deleted record type AAAA"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-51: make sure that dig can not find the record type AAAA"
		rlRun "dig aaaa.$zone AAAA | grep $aaaa" 1 "make sure dig can not find the AAAA record"
	rlPhaseEnd

	# There are negitive test cases for AAAA records starting at test #113

	# Type afsbd
	rlPhaseStartTest "ipa-dns-52: add record of type afsdb"
		rlRun "ipa dnsrecord-add $zone afsdb --afsdb-rec='0 $afsdb'" 0 "add record type afsdb"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-53: make sure that IPA saved record type afsdb"
		rlRun "ipa dnsrecord-find $zone afsdb | grep $afsdb" 0 "make sure ipa recieved record type afsdb"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-54: make sure that dig can find the record type afsdb"
		rlRun "dig afsdb.$zone AFSDB | grep $afsdb" 0 "make sure dig can find the afsdb record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-55: delete record of type afsdb"
		rlRun "ipa dnsrecord-del $zone afsdb --afsdb-rec='0 $afsdb'" 0 "delete record type afsdb"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-56: make sure that IPA deleted record type afsdb"
		rlRun "ipa dnsrecord-find $zone afsdb" 1 "make sure ipa deleted record type afsdb"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-57: make sure that dig can not find the record type afsdb"
		rlRun "dig afsdb.$zone AFSDB | grep $afsdb" 1 "make sure dig can not find the afsdb record"
	rlPhaseEnd

	# Type cname
	rlPhaseStartTest "ipa-dns-58: add record of type cname"
		rlRun "ipa dnsrecord-add $zone cname --cname-rec $cname" 0 "add record type cname"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-59: make sure that IPA saved record type cname"
		rlRun "ipa dnsrecord-find $zone cname | grep $cname" 0 "make sure ipa recieved record type cname"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-59: make sure that dig can find the record type cname"
		rlRun "dig cname.$zone CNAME | grep $cname" 0 "make sure dig can find the cname record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-60: delete record of type cname"
		rlRun "ipa dnsrecord-del $zone cname --cname-rec $cname" 0 "delete record type cname"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-61: make sure that IPA deleted record type cname"
		rlRun "ipa dnsrecord-find $zone cname" 1 "make sure ipa deleted record type cname"
	rlPhaseEnd

	sleep 5
	rlPhaseStartTest "ipa-dns-62: make sure that dig can not find the record type cname"
		rlRun "dig cname.$zone CNAME | grep $cname" 1 "make sure dig can not find the cname record"
	rlPhaseEnd

	# TXT Record
	rlPhaseStartTest "ipa-dns-63: add record of type txt"
		rlRun "ipa dnsrecord-add $zone txt --txt-rec $txt" 0 "add record type txt"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-64: make sure that IPA saved record type txt"
		rlRun "ipa dnsrecord-find $zone txt | grep $txt" 0 "make sure ipa recieved record type txt"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-65: make sure that dig can find the record type txt"
		rlRun "dig txt.$zone TXT | grep $txt" 0 "make sure dig can find the txt record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-67: delete record of type txt"
		rlRun "ipa dnsrecord-del $zone txt --txt-rec $txt" 0 "delete record type txt"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-68: make sure that IPA deleted record type txt"
		rlRun "ipa dnsrecord-find $zone txt" 1 "make sure ipa deleted record type txt"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-69: make sure that dig can not find the record type txt"
		rlRun "dig txt.$zone TXT | grep $txt" 1 "make sure dig can not find the txt record"
	rlPhaseEnd

	# SRV Record
	rlPhaseStartTest "ipa-dns-70: add record of type srv"
		rlRun "ipa dnsrecord-add $zone _srv --srv-rec '$srva $srv'" 0 "add record type srv"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-71: make sure that IPA saved record type srv"
		rlRun "ipa dnsrecord-find $zone _srv | grep $srv" 0 "make sure ipa recieved record type srv"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-72: make sure that dig can find the record type srv"
		rlRun "dig _srv.$zone SRV | grep $srv" 0 "make sure dig can find the srv record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-73: delete record of type srv"
		rlRun "ipa dnsrecord-del --del-all $zone _srv" 0 "delete record type srv"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-74: make sure that IPA deleted record type srv"
		rlRun "ipa dnsrecord-find $zone _srv" 1 "make sure ipa deleted record type srv"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-75: make sure that dig can not find the record type srv"
		rlRun "dig _srv.$zone SRV | grep $srv" 1 "make sure dig can not find the srv record"
	rlPhaseEnd

	# MX record 
	rlPhaseStartTest "ipa-dns-76: add record of type MX"
		rlRun "ipa dnsrecord-add $zone @ --mx-rec '10 $mx.'" 0 "add record type MX"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-77: make sure that IPA saved record type MX"
		rlRun "ipa dnsrecord-find $zone | grep $mx" 0 "make sure ipa recieved record type MX"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-78: make sure that dig can find the record type MX"
		rlRun "dig $zone MX | grep $mx" 0 "make sure dig can find the MX record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-79: delete record of type MX"
		rlRun "ipa dnsrecord-del $zone @ --mx-rec '10 $mx.'" 0 "delete record type MX"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-80: make sure that IPA deleted record type MX"
		rlRun "ipa dnsrecord-find $zone @ | grep $mx" 1 "make sure ipa deleted record type MX"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-81: make sure that dig can not find the record type MX"
		rlRun "dig $zone MX | grep $mx" 1 "make sure dig can not find the MX record"
	rlPhaseEnd

# Neg PTR zone add test cases
	rlPhaseStartTest "ipa-dns-82: try to create a new ptr zone using a bad serial number"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$pemail --serial=$pbadnum --refresh=$prefresh --retry=$pretry --expire=$pexpire --minimum=$pminimum --ttl=$pttl $bptrzone" 1 "trying to create a zone using a bad serial number"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-83: try to create a new zone using a bad refresh"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$pemail --serial=$pserial --refresh=$pbadnum --retry=$pretry --expire=$pexpire --minimum=$pminimum --ttl=$pttl $bptrzone" 1 "trying to create a zone using a bad refresh"
	rlPhaseEnd
# End Neg test cases

# Create a PTR zone
	rlPhaseStartTest "ipa-dns-84: try to create a new PTR zone"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$pemail --serial=$pserial --refresh=$prefresh --retry=$pretry --expire=$pexpire --minimum=$pminimum --ttl=$pttl $ptrzone" 0 "Creating a new PTR zone for use in following tests"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-85: checking to ensure that the new PTR zone got created with the correct name-server"
		rlRun "ipa dnszone-find --all $ptrzone | grep $ipaddr" 0 "checking to ensure that the new PTR zone got created with the correct name-server"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-86: checking to ensure that the new PTR zone got created with the correct email"
		rlRun "ipa dnszone-find --all $ptrzone | grep $pemail" 0 "checking to ensure that the new PTR zone got created with the correct email"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-87: checking to ensure that the new PTR zone got created with the correct serial number"
		rlRun "ipa dnszone-find --all $ptrzone | grep $pserial" 0 "checking to ensure that the new PTR zone got created with the correct serial number"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-88: checking to ensure that the new PTR zone got created with the correct refresh"
		rlRun "ipa dnszone-find --all $ptrzone | grep $prefresh" 0 "checking to ensure that the new PTR zone got created with the correct "
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-89: checking to ensure that the new PTR zone got created with the correct retry"
		rlRun "ipa dnszone-find --all $ptrzone | grep $pretry" 0 "checking to ensure that the new PTR zone got created with the correct retry"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-90: checking to ensure that the new PTR zone got created with the correct expire"
		rlRun "ipa dnszone-find --all $ptrzone | grep $pexpire" 0 "checking to ensure that the new PTR zone got created with the correct expire"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-91: checking to ensure that the new PTR zone got created with the correct minimum"
		rlRun "ipa dnszone-find --all $ptrzone | grep $pminimum" 0 "checking to ensure that the new PTR zone got created with the correct minimum"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-92: checking to ensure that the new PTR zone got created with the correct ttl"
		rlRun "ipa dnszone-find --all $ptrzone | grep $pttl" 0 "checking to ensure that the new PTR zone got created with the correct ttl"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-93: checking to with dig to ensure that the new PTR zone got created with the correct name server"
		rlRun "dig $ptrzone SOA | grep NS | grep $ipaddr" 0 "checking with dig to ensure that the new PTR zone got created with the correct name server"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-94: checking to with dig to ensure that the new PTR zone got created with the correct email"
		rlRun "dig $ptrzone SOA | grep $pemail" 0 "checking with dig to ensure that the new PTR zone got created with the correct email"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-95: checking to with dig to ensure that the new PTR zone got created with the correct serial number"
		rlRun "dig $ptrzone SOA | grep $pserial" 0 "checking with dig to ensure that the new PTR zone got created with the correct serial number"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-96: checking to with dig to ensure that the new PTR zone got created with the correct refresh"
		rlRun "dig $ptrzone SOA | grep $prefresh" 0 "checking with dig to ensure that the new PTR zone got created with the correct refresh"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-97: checking to with dig to ensure that the new PTR zone got created with the correct retry interval"
		rlRun "dig $ptrzone SOA | grep $pretry" 0 "checking with dig to ensure that the new PTR zone got created with the correct retry interval"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-98: checking to with dig to ensure that the new PTR zone got created with the correct expire"
		rlRun "dig $ptrzone SOA | grep $pexpire" 0 "checking with dig to ensure that the new PTR zone got created with the correct expire"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-99: checking to with dig to ensure that the new PTR zone got created with the correct minimum"
		rlRun "dig $ptrzone SOA | grep $pminimum" 0 "checking with dig to ensure that the new PTR zone got created with the correct minimum"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-100: checking to with dig to ensure that the new PTR zone got created with the correct ttl"
		rlRun "dig $ptrzone SOA | grep $pttl" 0 "checking with dig to ensure that the new PTR zone got created with the correct ttl"
	rlPhaseEnd

	# PTR record 
	rlPhaseStartTest "ipa-dns-101: add record of type PTR"
		rlRun "ipa dnsrecord-add $ptrzone $ptr --ptr-rec=$ptrvalue" 0 "add record type PTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-102: make sure that IPA saved record type PTR"
		rlRun "ipa dnsrecord-find $ptrzone $ptr | grep $ptrvalue" 0 "make sure ipa recieved record type PTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-103: make sure that dig can find the record type PTR"
		rlRun "dig -x $ptroctet.$ptr PTR | grep $ptrvalue" 0 "make sure dig can find the PTR record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-104: delete record of type PTR"
		rlRun "ipa dnsrecord-del $ptrzone $ptr --ptr-rec $ptrvalue" 0 "delete record type PTR"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-105: make sure that IPA deleted record type PTR"
		rlRun "ipa dnsrecord-find $ptrzone $ptr | grep $ptrvalue" 1 "make sure ipa deleted record type PTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-106: make sure that dig can not find the record type PTR"
		rlRun "dig -x $ptroctet.$ptr PTR | grep $ptrvalue" 1 "make sure dig can not find the PTR record"
	rlPhaseEnd

	# Type NAPTR
	rlPhaseStartTest "ipa-dns-107: add record of type NAPTR"
		echo "running ipa dnsrecord-add $zone naptr --naptr-rec '$naptr'"
		rlRun "ipa dnsrecord-add $zone naptr --naptr-rec '$naptr'" 0 "add record type NAPTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-108: make sure that IPA saved record type NAPTR"
		rlRun "ipa dnsrecord-find $zone naptr | grep '$naptr'" 0 "make sure ipa recieved record type NAPTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-109: make sure that dig can find the record type NAPTR"
		rlRun "dig naptr.$zone | grep $naptr" 0 "make sure dig can find the NAPTR record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-110: delete record of type NAPTR"
		rlRun "ipa dnsrecord-del $zone naptr --naptr-rec '$naptr'" 0 "delete record type NAPTR"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-111: make sure that IPA deleted record type NAPTR"
		rlRun "ipa dnsrecord-find $zone naptr" 1 "make sure ipa deleted record type NAPTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-112: make sure that dig can not find the record type NAPTR"
		rlRun "dig naptr.$zone NAPTR | grep '$naptr'" 1 "make sure dig can not find the NAPTR record"
	rlPhaseEnd


	# Neg AAAA tests
	rlPhaseStartTest "ipa-dns-113: add record of type bad AAAA"
		rlRun "ipa dnsrecord-add $zone aaaab --aaaa-rec $aaaabad1" 1 "add a bad record type AAAA"
	rlPhaseEnd
 	
	rlPhaseStartTest "ipa-dns-114: make sure that IPA did not save record type AAAA"
		rlRun "ipa dnsrecord-find $zone aaaab | grep $aaaabad1" 1 "make sure ipa did not record type AAAA"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-115: make sure that dig can not find the record type AAAA"
		rlRun "dig aaaab.$zone | grep $aaaabad1" 1 "make sure dig can not find the AAAA record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-116: add record of type bad AAAA"
		rlRun "ipa dnsrecord-add $zone aaaac --aaaa-rec $aaaabad2" 1 "add a bad record type AAAA"
	rlPhaseEnd
 	
	rlPhaseStartTest "ipa-dns-117: make sure that IPA did not save record type AAAA"
		rlRun "ipa dnsrecord-find $zone aaaac | grep $aaaabad2" 1 "make sure ipa did not record type AAAA"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-118: make sure that dig can not find the record type AAAA"
		rlRun "dig aaaac.$zone | grep $aaaabad2" 1 "make sure dig can not find the AAAA record"
	rlPhaseEnd

	# Type dname
	rlPhaseStartTest "ipa-dns-119: add record of type dname"
		rlRun "ipa dnsrecord-add $zone dname --dname-rec $dname" 0 "add record type dname"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-120: make sure that IPA saved record type dname"
		rlRun "ipa dnsrecord-find $zone dname | grep $dname" 0 "make sure ipa recieved record type dname"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-121: make sure that dig can find the record type dname"
		rlRun "dig dname.$zone DNAME | grep $dname" 0 "make sure dig can find the dname record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-122: delete record of type dname"
		rlRun "ipa dnsrecord-del $zone dname --dname-rec $dname" 0 "delete record type dname"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-123: make sure that IPA deleted record type dname"
		rlRun "ipa dnsrecord-find $zone dname" 1 "make sure ipa deleted record type dname"
	rlPhaseEnd

	sleep 5
	rlPhaseStartTest "ipa-dns-124: make sure that dig can not find the record type dname"
		rlRun "dig dname.$zone DNAME | grep $dname" 1 "make sure dig can not find the dname record"
	rlPhaseEnd

	# Type cert
	rlPhaseStartTest "ipa-dns-125: add record of type cert"
		rlRun "ipa dnsrecord-add $zone cert --cert-rec='$certa $cert'" 0 "add record type cert"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-126: make sure that IPA saved record type cert"
		rlRun "ipa dnsrecord-find $zone cert | grep $cert" 0 "make sure ipa recieved record type cert"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-127: make sure that dig can find the record type cert"
		rlRun "dig cert.$zone CERT | grep $cert" 0 "make sure dig can find the cert record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-128: delete record of type cert"
		rlRun "ipa dnsrecord-del $zone cert --cert-rec='$certa $cert'" 0 "delete record type cert"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-129: make sure that IPA deleted record type cert"
		rlRun "ipa dnsrecord-find $zone cert" 1 "make sure ipa deleted record type cert"
	rlPhaseEnd

	sleep 5
	rlPhaseStartTest "ipa-dns-130: make sure that dig can not find the record type cert"
		rlRun "dig cert.$zone CERT | grep $cert" 1 "make sure dig can not find the cert record"
	rlPhaseEnd


	# Type kx
	rlPhaseStartTest "ipa-dns-131: add record of type kx"
		rlRun "ipa dnsrecord-add $zone @ --kx-rec '$kxpref1 $a'" 0 "add record type kx"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-132: make sure that IPA saved record type kx"
		rlRun "ipa dnsrecord-find $zone @ | grep $kxpref1" 0 "make sure ipa recieved record type kx"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-133: make sure that dig can find the record type kx"
		rlRun "dig $zone kx | grep $kxpref1" 0 "make sure dig can find the kx record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-134: delete record of type kx"
		rlRun "ipa dnsrecord-del $zone @ --kx-rec '$kxpref1 $a'" 0 "delete record type kx"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-135: make sure that IPA deleted record type kx"
		rlRun "ipa dnsrecord-find $zone kx" 1 "make sure ipa deleted record type kx"
	rlPhaseEnd

	sleep 5
	rlPhaseStartTest "ipa-dns-136: make sure that dig can not find the record type kx"
		rlRun "dig $zone kx | grep $kxpref1" 1 "make sure dig can not find the kx record"
	rlPhaseEnd

	# Negitive kx tests

	rlPhaseStartTest "ipa-dns-137: add record of type bad kx"
		rlRun "ipa dnsrecord-add $zone @ --kx-rec '$kxbadpref1 $a'" 1 "add record type bad kx"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-138: make sure that IPA saved record type kx"
		rlRun "ipa dnsrecord-find $zone @ | grep $kxbadpref1" 1 "make sure ipa recieved record type kx"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-139: add record of type bad kx"
		rlRun "ipa dnsrecord-add $zone @ --kx-rec '$kxbadpref2 $zone'" 1 "add record type bad kx"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-140: make sure that IPA saved record type kx"
		rlRun "ipa dnsrecord-find $zone @ | grep $kxbadpref2" 1 "make sure ipa recieved record type kx"
	rlPhaseEnd

	# Type loc
	rlPhaseStartTest "ipa-dns-141: add record of type loc"
		rlRun "ipa dnsrecord-add $zone @ --loc-rec '$loc'" 0 "add record type loc"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-142: make sure that IPA saved record type loc"
		rlRun "ipa dnsrecord-find $zone | grep '$loclong'" 0 "make sure ipa recieved record type loc"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-143: make sure that dig can find the record type loc"
		rlRun "dig $zone loc | grep '$loc'" 0 "make sure dig can find the loc record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-144: delete record of type loc"
		rlRun "ipa dnsrecord-del $zone @ --loc-rec '$loc'" 0 "delete record type loc"
	rlPhaseEnd

	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-145: make sure that IPA deleted record type loc"
		rlRun "ipa dnsrecord-find $zone loc" 1 "make sure ipa deleted record type loc"
	rlPhaseEnd

	sleep 5
	rlPhaseStartTest "ipa-dns-146: make sure that dig can not find the record type loc"
		rlRun "dig $zone loc | grep $loclong" 1 "make sure dig can not find the loc record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-147: Delete the created zone"
		rlRun "ipa dnszone-del $zone" 0 "Delete the zone created for this test"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-148: Make sure zone the got deleted properly"
		rlRun "ipa dnszone-find $zone" 1 "Make sure the zone delete happened properly"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-149: Delete the created ptr zone"
		rlRun "ipa dnszone-del $ptrzone" 0 "Delete the ptr zone created for this test"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-150: Make sure the ptr zone got deleted properly"
		rlRun "ipa dnszone-find $ptrzone" 1 "Make sure the ptr zone delete happened properly"
	rlPhaseEnd

	rlJournalPrintText
	report=/tmp/rhts.report.$RANDOM.txt
	makereport $report
	rhts-submit-log -l $report

rlJournalEnd



