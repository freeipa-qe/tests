#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-adtrust
#   Description: Adtrust Install test cases
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Steeve Goveas <stv@redhat.com>
#   Date: August 13, 2012
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
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

# AD libs
. ./adlib.sh
########################################################################
# Test Suite Globals
########################################################################

RELM=`echo $RELM | tr "[a-z]" "[A-Z]"`
########################################################################

######################
#     Variables      #
######################
PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
PACKAGE3="ipa-server-trust-ad"
PACKAGE4="samba4-common"
PACKAGE5="expect"

ipainstall=`which ipa-server-install`
dmpaswd="Secret123"
named_conf="/etc/named.conf"
named_conf_bkp="/etc/named.conf.adtrust"
krb5_conf="/etc/krb5.conf"
krb5_conf_bkp="/etc/krb5.conf.bkp"
IPAhostIP=`ip addr | egrep 'inet ' | grep "global" | cut -f1 -d/ | awk '{print $NF}'`
IPAhostIP6=`ip addr | egrep 'inet6 ' | grep "global" | cut -f1 -d/ | awk '{print $NF}'`
IPAdomain="testrelm.com"
IPARealm="TESTRELM.COM"
NBname="TESTRELM"
dothypn=".TESTREM-"
lwnbnm="testrelm"
spchnm='Te!5@relm'
TID="10999"
STID="332233991"
fakeIP="10.25.11.21"
invalid_V6IP="3632:51:0:c41c:7054:ff:ae3c:c981"

setup() {
rlPhaseStartTest "Setup for adtrust sanity tests"
	# check for packages
	rlRun "rlDistroDiff ipa_pkg_check"

	# Checking other important pacakges	
	for item in $PACKAGE3 $PACKAGE4 $PACKAGE5; do
        	rpm -qa | grep $item
        	if [ $? -eq 0 ] ; then
                	rlPass "$item package is installed"
        	else
                	rlFail "$item package NOT found!"
        	fi
	done

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	# stopping firewall
#	rlRun "service iptables stop"
	rlServiceStop "iptables"
	rlServiceStop "ip6tables"

	# Adding conditional forwarder
#        rlRun "cp -p $named_conf $named_conf_bkp" 0 "Backup $named_conf before adding conditional forwarder for AD"
#        echo -e "\nzone \"$ADdomain\" IN {\n\ttype forward;\n\tforwarders { $ADip; };\n\tforward only;\n};" >> $named_conf
#        rlServiceStop "named"
#        rlServiceStart "named"
#        sleep 30
#        rlRun "host $ADhost"

#	rlRun "./adsetup.exp add $ADadmin $ADpswd $ADip $IPAhost $IPAhostIP > /dev/null 2>&1" 0 "Adding conditional forwarder for IPA domain in ADS"

#	rlRun "cp -p $krb5_conf $krb5_conf_bkp" 0 "Backup $krb5_conf"
#	rlRun "sed \"s/\(dns_lookup_kdc\).*/\dns_lookup_kdc = true/\" $krb5_conf"
#not required	rlrun "setenforce 0" 0 "Setting selinux in permissive mode"

rlPhaseEnd
}


adtrust_test_0001() {

rlPhaseStartTest "0001 Adtrust install with lowercase netbios name"
	rlRun "NB_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile netbios-name $lwnbnm" 2 "Giving lowercase Netbios name fails as expected"

rlPhaseEnd
}

adtrust_test_0002() {

rlPhaseStartTest "0002 Adtrust install with netbios name starting or ending with dot/hyphen"
	rlRun "NB_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile netbios-name $dothypn" 2 "Netbios name cannot start or end with dot/hyphen"

rlPhaseEnd
}

adtrust_test_0003() {

rlPhaseStartTest "0003 Adtrust install with special characters in Netbios name"
	rlRun "NB_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile netbios-name $spchnm" 2 "Netbios name cannot consist of special characters"

rlPhaseEnd
}

adtrust_test_0004() {

rlPhaseStartTest "0004 Adtrust install with random values in --ip-address"
	rlRun "IP_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile ip-address 1234.10.10.10" 2 "IP Address 1234.10.10.10 exited with an error"
	rlRun "$exp $expfile ip-address 10.1234.10.10" 2 "IP Address 10.1234.10.10 exited with an error"
	rlRun "$exp $expfile ip-address 10.10.1234.10" 2 "IP Address 10.10.1234.10 exited with an error"
	rlRun "$exp $expfile ip-address 10.10.10.1234" 2 "IP Address 10.10.10.1234 exited with an error"
	rlRun "$exp $expfile ip-address abcd" 2 "Alphabets for IP address exited with an error"
	
rlPhaseEnd
}

adtrust_test_0005() {

rlPhaseStartTest "0005 Adtrust install with empty string in --ip-address"
	rlRun "IP_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile ip-address \"\"" 2 "Empty quotes exited with an error"
        rlRun "$exp $expfile ip-address \" \"" 2 "Empty string exited with an error"

rlPhaseEnd
}

adtrust_test_0006() {

rlPhaseStartTest "0006 Adtrust install with wrong IP address"
	rlRun "IP_Exp" 0 "Creating expect script"
	rlRun "echo \"IPA server IP is $IPAhostIP\", but using and invalid IP to configure adtrust"
        rlRun "$exp $expfile ip-address $fakeIP" 2 "$fakeIP does not belong to this server. Adtrust install failed as expected"

rlPhaseEnd
}

adtrust_test_0007() {

rlPhaseStartTest "0007 Adtrust install with invalid IPv6 address"
	rlRun "IP_Exp" 0 "Creating expect script"
	rlRun "echo \"Server IPv6 address is $IPAhostIP6, but using an invalid IPv6 address to configure adtrust\""
	rlRun "$exp $expfile ip-address \"$invalid_V6IP\"" 2 "Invalid IPv6 Address exited with an error"

rlPhaseEnd
}

adtrust_test_0008() {

rlPhaseStartTest "0008 Adtrust install with invalid IP Address but valid Netbios Name and vice versa"
	rlRun "NBIP_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile ip-address 10.31.10.10 netbios-name $NBname" 2 "Valid Netbios-name and Invalid IP Address fails"
	rlRun "$exp $expfile ip-address $IPAhostIP netbios-name TESTrELm" 2 "Valid IP Address and Invalid Netbios Name fails"

rlPhaseEnd
}

adtrust_test_0009() {

rlPhaseStartTest "0009 Adtrust install as a non-root user"
	rlRun "create_ipauser $user test user $userpw"
	rlRun "NonRoot_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile" 2 "Failed as expected. Must be root to setup AD trusts on server"

rlPhaseEnd
}

adtrust_test_0010() {

rlPhaseStartTest "0010 Adtrust install by a user with administrative privileges"
	rlRun "ipa group-add-member --users=$user admins" 0 "Adding tuser to the admins group"
	rlRun "NonRoot_Exp" 0 "Createing expect script"
	rlRun "$exp $expfile" 2 "Failed as expected. Still need to be root to setup AD trusts"

rlPhaseEnd
}

adtrust_test_0011() {

rlPhaseStartTest "0011 Adtrust with invalid value for RID"
	rlRun "RID_Exp" 0 "Creating expect Script"
	rlRun "$exp $expfile rid-base RIDBase 63.3" 2 "--rid-base only accepts integers"

rlPhaseEnd
}

adtrust_test_0012() {

rlPhaseStartTest "0012 Adtrust with invalid value for Secondary RIDs"
	rlRun "RID_Exp" 0 "Creating expect Script"
        rlRun "$exp $expfile secondary-rid-base SRIDBase 23.7" 2 "--secondary-rid-base only accepts integers"

rlPhaseEnd
}

adtrust_test_0013() {

rlPhaseStartTest "0013 Adtrust install without creating DNS Service records"
	rlRun "No_SRV_Exp no-msdcs" 0 "Creating expect script"
        rlRun "$exp $expfile no-msdcs" 0 "Running $trust_bin with --no-msdcs option"

#	for i in $rec1 $rec2 $rec3 $rec4 $rec5 $rec6; do
#	rlRun "ipa dnsrecord-find $IPAdomain $i" 2 "$i SRV record not created as expected"
#	done

rlPhaseEnd
}

adtrust_test_0014() {

rlPhaseStartTest "0014 Install adtrust without options on CLI"
	rlRun "Intractive_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile" 0 "Running $trust_bin without cli options"
	if [ $? -eq 0 ]; then
	  for i in $rec{1..6}; do
            rlRun "ipa dnsrecord-find $IPAdomain $i" 0 "$i SRV record created"
	  done
	fi

rlPhaseEnd
}

adtrust_test_0015() {

rlPhaseStartTest "0015 Adtrust install with uppercase alphanumeric netbios name"
	rlRun "Valid_NB_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile netbios-name $NBname" 0 "ADtrust installed with uppercase alphanumberic netbios name"

rlPhaseEnd
}

adtrust_test_0016() {

rlPhaseStartTest "0016 Adtrust install with valid IP Address"
	rlRun "Valid_IP_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile ip-address $IPAhostIP" 0 "ADtrust installed with valid server IPv4 address"

rlPhaseEnd
}

adtrust_test_0017() {

rlPhaseStartTest "0017 Adtrust install with valid IP Address and Netbios Name on CLI"
	rlRun "Valid_NBIP_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile ip-address $IPAhostIP netbios-name $NBname" 0 "ADtrust installed with valid server IPv4 address and Netbios name."

rlPhaseEnd
}

adtrust_test_0018() {

rlPhaseStartTest "0018 Adtrust with valid IPv6 address"
	rlRun "Valid_IP_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile ip-address $IPAhostIP6" 0 "ADtrust installed with valid server IPv6 address"

rlPhaseEnd
}

adtrust_test_0019() {

rlPhaseStartTest "0019 Adtrust install with start value of RID Base"
	rlRun "$ipainstall --uninstall -U" 0 "Uninstalling IPA server"
	rlRun "$ipainstall --setup-dns --no-forwarder -p $dmpaswd -P $dmpaswd -a $adminpw -r $IPARealm -n $IPAdomain --ip-address=$IPAhostIP --hostname=$IPAhost -U" 0 "IPA server install with DNS"
	rlRun "Valid_RID_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile rid-base $TID" 0 "Adtrust install with start value for mapping UIDs and GIDs to RIDs"
	rlRun "ipa idrange-find | grep corresponding | grep $TID" 0 "ADtrust installed with preferred rid base."

rlPhaseEnd
}

adtrust_test_0020() {

rlPhaseStartTest "0020 Adtrust with start value of Secondary RID Base"
        rlRun "$ipainstall --uninstall -U" 0 "Uninstalling IPA server"
        rlRun "$ipainstall --setup-dns --no-forwarder -p $dmpaswd -P $dmpaswd -a $adminpw -r $IPARealm -n $IPAdomain --ip-address=$IPAhostIP --hostname=$IPAhost -U" 0 "IPA server install with DNS"
	rlRun "Valid_RID_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile secondary-rid-base $STID" 0 "Adtrust install with start value of secondary range"
        rlRun "ipa idrange-find | grep secondary | grep $STID" 0 "ADtrust installed with preferred secondary rid base."

rlPhaseEnd
}

adtrust_test_0021() {

rlPhaseStartTest "0021 Adtrust install with both base and secondary RIDs"
        rlRun "$ipainstall --uninstall -U" 0 "Uninstalling IPA server"
        rlRun "$ipainstall --setup-dns --no-forwarder -p $dmpaswd -P $dmpaswd -a $adminpw -r $IPARealm -n $IPAdomain --ip-address=$IPAhostIP --hostname=$IPAhost -U" 0 "IPA server install with DNS"
	rlRun "Valid_RID_Exp both" 0 "Creating expect script"
        rlRun "$exp $expfile rid-base $TID secondary-rid-base $STID" 0 "Adtrust install with start value of RID Base"
	rlRun "ipa idrange-find | grep corresponding | grep $TID" 0 "ADtrust installed with preferred rid base."
        rlRun "ipa idrange-find | grep secondary | grep $STID" 0 "ADtrust installed with preferred secondary rid base."

rlPhaseEnd
}

adtrust_test_0022() {

rlPhaseStartTest "0022 Adtrust install with --no-msdcs on Non DNS integrated server"
        rlRun "$ipainstall --uninstall -U" 0 "Uninstalling IPA server"
        rlRun "$ipainstall -p $dmpaswd -P $dmpaswd -a $adminpw -r $IPARealm -n $IPAdomain --ip-address=$IPAhostIP --hostname=$IPAhost -U" 0 "IPA server install without DNS"
	rlRun "No_SRV_Exp no-msdcs" 0 "Creating expect script"
        rlRun "$exp $expfile" 0 "SRV records not created with --no-msdcs"

rlPhaseEnd
}

adtrust_test_0023() {

rlPhaseStartTest "0023 Adtrust install on IPA server with DNS not integrated"
	rlRun "No_SRV_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile" 0 "SRV records not created without integrated DNS"

rlPhaseEnd
}

cleanup() {

rlPhaseStartTest "Clean up for adtrust sanity tests"

	rlRun "kinitAs $ADMINID $ADMINPW" 0
#	rlRun "rm -f $named_conf && cp -p $named_conf_bkp $named_conf" 0 "Restoring $named_conf file from backup"
#	rlServiceStop "named"
#        rlServiceStart "named"

	rlRun "kdestroy" 0 "Destroying admin credentials."
	rlRun "rm -fr /tmp/krb5cc_*"

rlPhaseEnd
}
