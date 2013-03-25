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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

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

ipainstall=`which ipa-server-install`
dmpaswd="Secret123"
named_conf="/etc/named.conf"
named_conf_bkp="/etc/named.conf.adtrust"
krb5_conf="/etc/krb5.conf"
krb5_conf_bkp="/etc/krb5.conf.bkp"
IPAhost=`hostname`
IPAhostIP=`ip addr | egrep 'inet ' | grep "global" | cut -f1 -d/ | awk '{print $NF}'`
IPAhostIP6=`ip addr | egrep 'inet6 ' | grep "global" | cut -f1 -d/ | awk '{print $NF}'`
IPAdomain="testrelm.com"
IPARealm="TESTRELM.COM"
srv_name=`hostname -s`
NBname="TESTRELM"
NBname2="TESTRELM2"
dotname1=".TESTRELM"
dotname2="TESTRELM."
dotname3="TEST.RELM"
hypname1="-TESTRELM"
hypname2="TESTRELM-"
hypname3="TEST-RELM"
lwnbnm="testrelm"
spchnm='Te!5@relm'
TID="10999"
STID="332233991"
fakeIP="10.25.11.21"
invalid_V6IP="3632:51:0:c41c:7054:ff:ae3c:c981"
smbfile="/etc/samba/smb.conf"
group1="editors"
group2="tgroup"
ipacmd=`which ipa`
sidgen_ldif="/usr/share/ipa/ipa-sidgen-task-run.ldif"
newsuffix='dc=testrelm,dc=com'
DS_binddn="CN=Directory Manager"
DMpswd="Secret123"
samba_cc="/var/run/samba/krb5cc_samba"
abrt_econf="/etc/libreport/events.d/abrt_event.conf"

setup() {
rlPhaseStartSetup "Setup for adtrust sanity tests"
	# check for packages
	rlRun "rlDistroDiff ipa_pkg_check"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "create_ipauser $user test user $userpw"
	rlRun "create_ipauser $user1 new user $userpw"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "$ipacmd group-add --desc Test-Group $group2" 0 "Adding a test group"

	# stopping firewall
	rlServiceStop "iptables"
	rlServiceStop "ip6tables"

rlPhaseEnd
}


adtrust_test_0001() {

rlPhaseStartTest "0001 Adtrust install with lowercase netbios name"
	rlRun "NB_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile netbios-name $lwnbnm" 2 "Giving lowercase Netbios name fails as expected"

rlPhaseEnd
}

adtrust_test_0002() {

rlPhaseStartTest "0002 Adtrust install with netbios name cannot consist of dot/hyphen"
	rlRun "NB_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile netbios-name $dotname1" 2 "Netbios name cannot have a dot \"$dotname1\""
        rlRun "$exp $expfile netbios-name $dotname2" 2 "Netbios name cannot have a dot \"$dotname2\""
        rlRun "$exp $expfile netbios-name $dotname3" 2 "Netbios name cannot have a dot \"$dotname3\""
        rlRun "$exp $expfile netbios-name $hypname1" 2 "Netbios name cannot have a hyphen \"$hypname1\""
        rlRun "$exp $expfile netbios-name $hypname2" 2 "Netbios name cannot have a hyphen \"$hypname2\""
        rlRun "$exp $expfile netbios-name $hypname3" 2 "Netbios name cannot have a hyphen \"$hypname3\""

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

rlPhaseStartTest "0007 Adtrust install with wrong IPv6 address"
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
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "NonRoot_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile" 2 "Failed as expected. Must be root to setup AD trusts on server"

rlPhaseEnd
}

adtrust_test_0010() {

rlPhaseStartTest "0010 Login as root, adtrust install by user without administrative privileges"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rlRun "NoAdminPriv_Exp A" 0 "Creating expect script"
	rlRun "$exp $expfile A $user $userpw" 2 "Failed as expected. $user does not have admin priviliges"

rlPhaseEnd
}

adtrust_test_0011() {

rlPhaseStartTest "0011 Adtrust install by a user with administrative privileges"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ipa group-add-member --users=$user admins" 0 "Adding tuser to the admins group"
	rlRun "NonRoot_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile" 2 "Failed as expected. Still need to be root to setup AD trusts"

rlPhaseEnd
}

adtrust_test_0012() {

rlPhaseStartTest "0012 Adtrust install with wrong admin passwd on cli"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rlRun "NoAdminPriv_Exp" 0 "Creating expect script"
	# using $user as wrong password
	rlRun "$exp $expfile a $user" 2 "Failed as expected. admin user password incorrect"

rlPhaseEnd
}

adtrust_test_0013() {

rlPhaseStartTest "0013 Adtrust with invalid value for RID"
	rlRun "RID_Exp" 0 "Creating expect Script"
	rlRun "$exp $expfile rid-base RIDBase 63.3" 2 "--rid-base only accepts integers"

rlPhaseEnd
}

adtrust_test_0014() {

rlPhaseStartTest "0014 Adtrust with invalid value for Secondary RIDs"
	rlRun "RID_Exp" 0 "Creating expect Script"
        rlRun "$exp $expfile secondary-rid-base SRIDBase 23.7" 2 "--secondary-rid-base only accepts integers"

rlPhaseEnd
}

adtrust_test_0015() {

rlPhaseStartTest "0015 Adtrust install without creating DNS Service records"
	rlRun "No_SRV_Exp no-msdcs" 0 "Creating expect script"
        rlRun "$exp $expfile no-msdcs" 0 "Running $trust_bin with --no-msdcs option"

	  for i in $rec{1..6}; do
	    rlRun "ipa dnsrecord-find $IPAdomain $i" 1 "$i SRV record not created as expected"
	  done

rlPhaseEnd
}

adtrust_test_0016() {

rlPhaseStartTest "0016 Install adtrust without options on CLI. Check srv records. - BZ 866572"
	rpm -qa samba-client && yum remove -y samba-client
	rlRun "which smbpasswd"  1 "/usr/bin/smbpasswd binary not found"
	rlRun "Interactive_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile" 0 "Running $trust_bin without cli options"
	if [ "$?" -eq 0 ]; then
	rlPass "Adtrust intall interactively and no failure if /usr/bin/smbpasswd is not found - BZ 866572"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	  for i in $rec{1..6}; do
            rlRun "ipa dnsrecord-find $IPAdomain $i" 0 "$i SRV record created"
	  done
	fi

rlPhaseEnd
}

adtrust_test_0017() {

rlPhaseStartTest "0017 Login as root, adtrust install by a user with administrative privileges"
        rlRun "kdestroy" 0 "Destroying admin credentials."
        rlRun "AdminPriv_Exp A" 0 "Creating expect script"
        rlRun "$exp $expfile A $user" 0 "Adtrust installed by $user with admin priviliges"

rlPhaseEnd
}

adtrust_test_0018() {

rlPhaseStartTest "0018 Adtrust install with correct admin passwd on cli"
        rlRun "kdestroy" 0 "Destroying admin credentials."
        rlRun "AdminPriv_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile a $adminpw" 0 "Adtrust installed by providing correct admin passwd on cli"

rlPhaseEnd
}

adtrust_test_0019() {

rlPhaseStartTest "0019 Adtrust install with uppercase alphanumeric netbios name"
	rlRun "Valid_NB_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile netbios-name $NBname" 0 "ADtrust installed with uppercase alphanumberic netbios name"

rlPhaseEnd
}

adtrust_test_0020() {

rlPhaseStartTest "0020 Adtrust install when re-run with new netbios name should reset ipaNTFlatName attribute - BZ 867447"
	rlRun "Valid_NB_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile netbios-name $NBname2" 0 "ADtrust re-run with new netbios name"
	ldapsearch -H ldapi://%2fvar%2frun%2fslapd-TESTRELM-COM.socket objectclass=ipaNTDomainAttrs | grep $NBname2
	if [ $? -eq 0 ]; then
	  rlPass "Adtrust install re-run with new netbios name resets ipaNTFlatName attribute"
	else
	  rlFail "Adtrust install re-run with new netbios name does not resets ipaNTFlatName attribute - BZ 867447"
	fi

rlPhaseEnd
}


adtrust_test_0021() {

rlPhaseStartTest "0021 Install adtrust with valid IP Address"
	rlRun "Valid_IP_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile ip-address $IPAhostIP" 0 "ADtrust installed with valid server IPv4 address"

rlPhaseEnd
}

adtrust_test_0022() {

rlPhaseStartTest "0022 Adtrust install with valid IP Address and Netbios Name on CLI"
	rlRun "Valid_NBIP_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile ip-address $IPAhostIP netbios-name $NBname" 0 "ADtrust installed with valid server IPv4 address and Netbios name."

rlPhaseEnd
}

adtrust_test_0023() {

rlPhaseStartTest "0023 Adtrust with valid IPv6 address"
	rlRun "Valid_IP_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile ip-address $IPAhostIP6" 0 "ADtrust installed with valid server IPv6 address"

rlPhaseEnd
}

adtrust_test_0024() {

rlPhaseStartTest "0024 Adtrust install with adding sids for existing IPA users and groups"
        rlRun "SID_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile" 0 "ADtrust installed without populating SIDs"
	rlRun "$ipacmd user-show $user1 --all | grep ipantsecurityidentifier" 1 "SID not created for $user1 as expected"
	rlRun "$ipacmd group-show $group1 --all | grep ipantsecurityidentifier" 1 "SID not created for default $group1 group as expected"
	rlRun "$ipacmd group-show $group2 --all | grep ipantsecurityidentifier" 1 "SID not created for $group2 as expected"
        rlRun "SID_Exp add-sids" 0 "Creating expect script"
	rlRun "$exp $expfile" 0 "ADtrust installed with populating SIDS for existing users"
	rlRun "$ipacmd user-show $user1 --all | grep ipantsecurityidentifier" 0 "SID created for $user1 as expected"
	rlRun "$ipacmd group-show $group1 --all | grep ipantsecurityidentifier" 0 "SID created for default $group1 group as expected"
	rlRun "$ipacmd group-show $group2 --all | grep ipantsecurityidentifier" 0 "SID created for $group2 as expected"

rlPhaseEnd
}

adtrust_test_0025() {

rlPhaseStartTest "0025 Adtrust install with start value of RID Base"
	rlRun "$ipainstall --uninstall -U" 0 "Uninstalling IPA server"
	rlRun "Interactive_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile" 2 "Cannot configure adtrust without IPA server configured first"

rlPhaseEnd
}

adtrust_test_0026() {

rlPhaseStartTest "0026 Adtrust install with adding sids for existing IPA users and groups interactively - Ticket 3195"
	# Deleting samba cache credential
	[ -e $samba_cc ] && rm -f $samba_cc
	rlRun "$ipainstall --setup-dns --no-forwarder -p $dmpaswd -P $dmpaswd -a $adminpw -r $IPARealm -n $IPAdomain --ip-address=$IPAhostIP --hostname=$IPAhost -U"
	
	#Creating users and groups to check the creation of SIDs post adtrust-install
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "create_ipauser $user1 new user $userpw"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "$ipacmd group-add --desc \"Test Group\" $group2" 0 "Adding a test group"

	rlLog "Adtrust install not run yet"
        rlRun "$ipacmd user-show $user1 --all | grep ipantsecurityidentifier" 1 "SID not created for $user1 as expected"
        rlRun "$ipacmd group-show $group1 --all | grep ipantsecurityidentifier" 1 "SID not created for default $group1 group as expected"
        rlRun "$ipacmd group-show $group2 --all | grep ipantsecurityidentifier" 1 "SID not created for $group2 as expected"

	rlRun "Interactive_Exp sidgen" 0 "Creating expect script with"
        rlRun "$exp $expfile" 0 "ADtrust installed with populating SIDS interactively for existing users"
        rlRun "$ipacmd user-show $user1 --all | grep ipantsecurityidentifier" 0 "SID created for $user1 as expected"
        rlRun "$ipacmd group-show $group1 --all | grep ipantsecurityidentifier" 0 "SID created for default $group1 group as expected"
        rlRun "$ipacmd group-show $group2 --all | grep ipantsecurityidentifier" 0 "SID created for $group2 as expected"

rlPhaseEnd
}

adtrust_test_0027() {

rlPhaseStartTest "0027 Adtrust install with start value of RID Base"
	rlRun "$ipainstall --uninstall -U" 0 "Uninstalling IPA server"
	[ -e $samba_cc ] && rm -f $samba_cc
	# Install IPA and create users and groups
	rlRun "$ipainstall --setup-dns --no-forwarder -p $dmpaswd -P $dmpaswd -a $adminpw -r $IPARealm -n $IPAdomain --ip-address=$IPAhostIP --hostname=$IPAhost -U" 0 "IPA server install with DNS"
	[ -e $smbfile ] && rm -f $smbfile
	rlRun "Valid_RID_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile rid-base $TID" 0 "Adtrust install with start value for mapping UIDs and GIDs to RIDs"
	rlRun "ipa idrange-find | grep corresponding | grep $TID" 0 "ADtrust installed with preferred rid base."

rlPhaseEnd
}

adtrust_test_0028() {

rlPhaseStartTest "0028 Adtrust with start value of Secondary RID Base"
        rlRun "$ipainstall --uninstall -U" 0 "Uninstalling IPA server"
	# Deleting samba cache credential
        [ -e $samba_cc ] && rm -f $samba_cc
        rlRun "$ipainstall --setup-dns --no-forwarder -p $dmpaswd -P $dmpaswd -a $adminpw -r $IPARealm -n $IPAdomain --ip-address=$IPAhostIP --hostname=$IPAhost -U" 0 "IPA server install with DNS"
	[ -e $smbfile ] && rm -f $smbfile
	rlRun "Valid_RID_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile secondary-rid-base $STID" 0 "Adtrust install with start value of secondary range"
        rlRun "ipa idrange-find | grep secondary | grep $STID" 0 "ADtrust installed with preferred secondary rid base."

rlPhaseEnd
}

adtrust_test_0029() {

rlPhaseStartTest "0029 Adtrust install with both base and secondary RIDs"
        rlRun "$ipainstall --uninstall -U" 0 "Uninstalling IPA server"
	# Deleting samba cache credential
        [ -e $samba_cc ] && rm -f $samba_cc
        rlRun "$ipainstall --setup-dns --no-forwarder -p $dmpaswd -P $dmpaswd -a $adminpw -r $IPARealm -n $IPAdomain --ip-address=$IPAhostIP --hostname=$IPAhost -U" 0 "IPA server install with DNS"
	[ -e $smbfile ] && rm -f $smbfile
	rlRun "Valid_RID_Exp both" 0 "Creating expect script"
        rlRun "$exp $expfile rid-base $TID secondary-rid-base $STID" 0 "Adtrust install with start value of RID Base"
	rlRun "ipa idrange-find | grep corresponding | grep $TID" 0 "ADtrust installed with preferred rid base."
        rlRun "ipa idrange-find | grep secondary | grep $STID" 0 "ADtrust installed with preferred secondary rid base."

rlPhaseEnd
}

adtrust_test_0030() {

rlPhaseStartTest "0030 Adtrust install on IPA server without DNS with --no-msdcs"
        rlRun "$ipainstall --uninstall -U" 0 "Uninstalling IPA server"

	# Deleting samba cache credential
        [ -e $samba_cc ] && rm -f $samba_cc

	# Adding hostname and IP details to /etc/hosts file
	grep $IPAhost /etc/hosts || echo -e "$IPAhostIP\t$IPAhost\t$srv_name" >> /etc/hosts

        rlRun "$ipainstall -p $dmpaswd -P $dmpaswd -a $adminpw -r $IPARealm -n $IPAdomain --ip-address=$IPAhostIP --hostname=$IPAhost -U" 0 "IPA server install without DNS"

	#Creating users and groups to check the creation of SIDs post adtrust-install
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "create_ipauser $user test user $userpw"
        rlRun "create_ipauser $user1 new user $userpw"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "$ipacmd group-add --desc \"Test Group\" $group2" 0 "Adding a test group"

	[ -e $smbfile ] && rm -f $smbfile
	rlRun "No_SRV_Exp no-msdcs" 0 "Creating expect script"
        rlRun "$exp $expfile" 0 "SRV records not created with --no-msdcs"

rlPhaseEnd
}

adtrust_test_0031() {

rlPhaseStartTest "0031 Adtrust install on IPA server with no integrated DNS"
	rlRun "[ -e $smbfile ] && rm -f $smbfile" 0 "Deleting $smbfile for convenience"
	rlRun "No_SRV_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile" 0 "SRV records not created without integrated DNS"

rlPhaseEnd
}

adtrust_test_0032() {

rlPhaseStartTest "0032 Add SIDs for exiting IPA users and groups after adtrust install"
	rlRun "$ipacmd user-show $user1 --all | grep ipantsecurityidentifier" 1 "SID not created for $user1 as expected"
        rlRun "$ipacmd group-show $group1 --all | grep ipantsecurityidentifier" 1 "SID not created for default $group1 group as expected"
        rlRun "$ipacmd group-show $group2 --all | grep ipantsecurityidentifier" 1 "SID not created for $group2 as expected"	
	
	rlRun "Tmpfile=\`mktemp\`" 0 "Creating tmp directory"
	if [ -e $sidgen_ldif ]; then
          rlRun "cp $sidgen_ldif $Tmpfile" 0 "Copying file for SID generation"
	else
	  rlFail "$sidgen_ldif file does not exist" 
	  return 1
	fi
	sed -i "s/\:\ \$SUFFIX/\:\ $newsuffix/" $Tmpfile
	if [ $? -eq 0 ]; then
	  rlPass "Modifying $Tmpfile"
	else
	  rlFail "Modifying $Tmpfile"
	fi
	ldapmodify -H ldapi://%2fvar%2frun%2fslapd-TESTRELM-COM.socket -f $Tmpfile
	if [ $? -eq 0 ]; then
          rlPass "Populating ipaNTSecurityIdentifier (SID) for existing users and groups"
        else
          rlFail "Populating ipaNTSecurityIdentifier (SID) for existing users and groups"
        fi
	rlRun "$ipacmd user-show $user1 --all | grep ipantsecurityidentifier" 0 "SID created for $user1 as expected"
        rlRun "$ipacmd group-show $group1 --all | grep ipantsecurityidentifier" 0 "SID created for default $group1 group as expected"
        rlRun "$ipacmd group-show $group2 --all | grep ipantsecurityidentifier" 0 "SID created for $group2 as expected"

	# Test Cleanup
	rm -f $Tmpfile
	
rlPhaseEnd
}

adtrust_test_0033() {

rlPhaseStartTest "0033 ipa-adtrust-install fails with syntax error in ipachangecon - BZ 916209 and 917065"
	sed -i 's/dns_lookup_kdc.*/dns_lookup_kdc \= false/' /etc/krb5.conf
	if [ $? -eq 0 ]; then 
	  rlPass "Setting dns_lookup_kdc to false"
	else
	  rlFail "Setting dns_lookup_kdc to false"
	fi
	rlRun "Interactive_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile" 0 "No errors while amending dns_lookup_kdc to true"
rlPhaseEnd
}

adtrust_test_0034() {

rlPhaseStartTest "0034 Adtrust install unattented, ticket 3497 - BZ 924079"
        rlRun "$ipainstall --uninstall -U" 0 "Uninstalling IPA server"
	# Deleting samba cache credential
        [ -e $samba_cc ] && rm -f $samba_cc
	[ -e $smbfile ] && rm -f $smbfile
        rlRun "$ipainstall --setup-dns --no-forwarder -p $dmpaswd -P $dmpaswd -a $adminpw -r $IPARealm -n $IPAdomain --ip-address=$IPAhostIP --hostname=$IPAhost -U" 0 "IPA server install with DNS"
	rlRun "Unattended_Exp" 0 "Creating expect script"
	rlRun "$exp $expfile" 0 "Unattended ADtrust install - Ticket 3497 and BZ 924079 resolved"

rlPhaseEnd
}

cleanup() {

rlPhaseStartCleanup "Clean up for adtrust sanity tests"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rlRun "rm -fr /tmp/krb5cc_*"
	rlRun "rm -fr $expfile"

rlPhaseEnd
}
