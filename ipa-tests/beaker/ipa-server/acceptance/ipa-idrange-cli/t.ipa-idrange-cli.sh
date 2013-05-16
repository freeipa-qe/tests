#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-idrange-cli
#   Description: IPA idrange CLI test cases
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Steeve Goveas <stv@redhat.com>
#   Date: March 07, 2013
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

# AD values
. ./Config

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

IPAhost=`hostname`
IPAdomain="testrelm.com"
IPADOMAIN=`echo ${IPAdomain^^}`
ADDOMAIN=`echo ${ADdomain^^}`
IPAhostIP=`ip addr | egrep 'inet ' | grep "global" | cut -f1 -d/ | awk '{print $NF}'`
srv_name=`hostname -s`
NBname="TESTRELM"
trust_bin=`which ipa-adtrust-install`
exp=`which expect`
ID=`which id`
slapd_dir="/etc/dirsrv/slapd-TESTRELM-COM"
ldap_conf="/etc/openldap/ldap.conf"
ADcrt="ADcert.cer"
AD_binddn="CN=Administrator,CN=Users,$ADdc" 
userpw="Secret123"
ipa_user="tuser"
#user2="nuser"
adminpw="Secret123"
ADfn="ads"
ADsn="user"
aduser="aduser"
trust_secret="TrUsTsEcRet"
samba_cc="/var/run/samba/krb5cc_samba"
lrange="local_range"
norange="range_new"
adrange="ad_range"
DS_binddn="CN=Directory Manager"
DNA_plugin="cn=Posix IDs,cn=Distributed Numeric Assignment Plugin,cn=plugins,cn=config"
DMpswd="Secret123"

IPA_Variables() {
	# Defining some variables post ipa-adtrust-install	
	lrid_base=`$ipacmd idrange-show $IPADOMAIN_id_range | grep "First RID of the corresponding RID range:" | awk '{print $NF}'`
	lbase_id=`$ipacmd idrange-show $IPADOMAIN_id_range | grep 'First Posix ID' | awk '{print $NF}'`
	lrange_size=`$ipacmd idrange-show $IPADOMAIN_id_range | egrep "Number.*range:" | awk '{print $NF}'`
	lsecrid_base=`$ipacmd idrange-show $IPADOMAIN_id_range | grep "First RID of the secondary RID range:" | awk '{print $NF}'`
}

AD_Variables() {
	ad_values=(`$ipacmd idrange-show $ADDOMAIN_id_range | awk '{print $NF}'`)
	adbase_id=`echo ${ad_values[1]}`
	adrange_size=`echo ${ad_values[2]}`
	adrid=`echo ${ad_values[3]}`
	AD_SID=`echo ${ad_values[4]}`
	New_adbase_id=$((adbase_id + adrange_size))
# Check this with sbose
	New_adrid=$((adrid + adrange_size))
}

setup() {
rlPhaseStartSetup "Setup both ADS and IPA Servers for trust and idrange Test Cases"
	# check for packages
	rlRun "rlDistroDiff ipa_pkg_check" 0 "Packages installed for current OS flavor"

	# stopping firewall
	rlServiceStop "firewalld"
#	rlServiceStop "ip6tables"

	# Setup AD with conditional forwarder for IPA domain
	rlRun "./adsetup.exp add $ADadmin $ADpswd $ADip $IPAdomain $IPAhostIP" 0 "Add conditional forwarder for $ADdomain"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "$ipacmd dnszone-add $ADdomain --name-server=$ADhost --admin-email=hostmaster@$ADdomain --force --forwarder=$ADip --forward-policy=only" 0 "Adding forwarder for  $ADdomain"
	sleep 30

	# Deleting samba cache credential. Remove this after https://fedorahosted.org/freeipa/ticket/3479 is resolved
        [ -e $samba_cc ] && rm -f $samba_cc

	# Prepare IPA server for trust
	rlRun "$trust_bin -a $adminpw --netbios-name $NBname -U" 0 "Preparing server to establish trust"

	# Checking DNS records are in place or AD and IPA, Needs improovement #####
	rlRun "dig +short SRV @$ADip _ldap._tcp.$IPAdomain | grep $IPAhost" 0 "Conditional forwarder for IPA server setup on $ADhost"

	rlRun "dig +short SRV _ldap._tcp.$ADdomain | grep $ADhost" 0 "Forwarder for $ADdomain setup"

	# Using valid AD cert
        rlRun "certutil -A -i $ADcrt -d $slapd_dir -n \"AD cert\" -t \"CT,C,C\" -a"
        rlRun "certutil -L -d $slapd_dir | grep \"AD cert\"" 0 "Verifying AD cert is imported in db"

	# Specifying TLS_CACERTDIR
        grep -q "TLS_CACERTDIR" $ldap_conf
        if [ $? -eq 0 ]; then
          sed -i "s/.*TLS_CACERTDIR.*/TLS_CACERTDIR \/etc\/dirsrv\/slapd\-TESTRELM\-COM/" $ldap_conf
        else
          echo "TLS_CACERTDIR $slapd_dir" >> $ldap_conf
        fi

        # Verify you can connect via TLS to ADS server
        rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"$AD_binddn\"" 0 "Verifying connection via TLS to ADS server"

	# Make temp directory to work with ldif files
	rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"

	# Clean up
	rlRun "popd"

	rlRun "create_ipauser $ipa_user test user $userpw"
#	rlRun "create_ipauser $user2 new user $userpw"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
#	rlRun "$ipacmd group-add-member admins --users=$user2" 0 "Adding $user2 to IPA admins group"
rlPhaseEnd
}

Trust_Add() {
rlPhaseStartSetup " Adding trust with AD domain"
	rlRun "Add_Trust" 0 "Creating expect script"
        rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd" 0 "Active Directory Trust added for $ADdomain"
rlPhaseEnd
}

idrange_test_0001() {

rlPhaseStartTest "0001 Find idrange passing a value to --pkey-only"
	idrange_name=`$ipacmd idrange-find --pkey-only | grep "Range name:" | awk '{print $NF}'`
	if [ "$idrange_name" = "$IPADOMAIN_id_range" ]; then
	  rlPass "IDrange find with pkey-only"
	else
	  rlFail "IDrange find with pkey-only"
	fi
rlPhaseEnd
}

idrange_test_0002() {

rlPhaseStartTest "0002 Add idrange with existing range name"
	rlRun "IDrange_Add same_name" 0 "Creating expect script"
	rlRun "$exp $expfile $idrange_name 3000 5" 2 "IDrange add with existing range name fails"
rlPhaseEnd
}

idrange_test_0003() {

rlPhaseStartTest "0003 Add idrange with existing range base-id"
	IPA_Variables
	rlRun "IDrange_Add same_startid" 0 "Creating expect script"
	rlRun "$exp $expfile $lrange $lbase_id 10" 1 "IDrange add with same range start id fails"
rlPhaseEnd
}

idrange_test_0004() {

rlPhaseStartTest "0004 Using alphanumeric value and special characters"
	rlRun "Wrong_Values" 0 "Creating expect script"
	rlRun "$exp $expfile $lrange rye34 \'r!83&\' 3000 R345 \'r#(26\' 10" 0 "Using alphanumeric value and special characters fail"
rlPhaseEnd
}

idrange_test_0005() {

rlPhaseStartTest "0005 Delete non-existing idrange"
	rlRun "$ipacmd idrange-del $norange" 2 "$norange does not exist to be deleted"
rlPhaseEnd
}

idrange_test_0006() {

rlPhaseStartTest "0006 Delete idrange with range name"
	rlRun "$ipacmd idrange-del $lrange" 0 "Deleting $lrange"
rlPhaseEnd
}

idrange_test_0007() {

rlPhaseStartTest "0007 Using rid-base without secondary-rid-base option and vice versa"
	rlRun "IDrange_Add2" 0 "Creating expect script"
	rlRun "$exp $expfile rid-base 2000 2345678 10 $lrange" 1 "rid-base and secondary-rid-base must be used together"
	rlRun "$exp $expfile secondary-rid-base 2000 2345678 10 $lrange" 1 "secondary-rid-base and rid-base must be used together"
rlPhaseEnd
}

idrange_test_0008() {

rlPhaseStartTest "0008 Add idrange with existing rid-base and secondary-rid-base values - Ticket # 3086"
	IPA_Variables
	New_rid_base=$((lrid_base + lrange_size))
	New_lbase_id=$((lbase_id + lrange_size))
	New_secrid_base=$((lsecrid_base + lrange_size))
	rlLog "https://fedorahosted.org/freeipa/ticket/3086"
	rlRun "rid-values=(`$ipacmd idrange-show $IPADOMAIN_id_range | grep "First RID" | awk '{print $NF}'`)"
	rlRun "IDrange_Add3 primary" 0 "Creating expect script"
	RID_BASE=`echo ${rid-values[0]}`
	rlRun "$exp $expfile $RID_BASE $New_secrid_base 2345678 10 $lrange" 1 "Cant use existing rid-base value"
	rlRun "IDrange_Add3 secondary" 0 "Creating expect script"
	SEC_RID_BASE=`echo ${rid-values[1]}`
	rlRun "$exp $expfile $New_rid_base $SEC_RID_BASE 2345678 10 $lrange" 1 "Cant use existing secondary-rid-base value"
rlPhaseEnd
}

idrange_test_0009() {

rlPhaseStartTest "0009 Add idrange for local domain overlapping existing range"
	rlRun "BASE_ID=`$ipacmd idrange-show $IPADOMAIN_id_range | grep "First Posix ID" | awk '{print $NF}'`"
	rlRun "NEW_BASE_ID=`expr $BASE_ID + 50000`"
	rlRun "IDrange_Add same_startid" 0 "Creating expect script"
	rlRun "$exp $expfile $lrange $NEW_BASE_ID 10" 1 "Overlapping local idrange not allowed"

rlPhaseEnd
}

idrange_test_0010() {

rlPhaseStartTest "0010 Delete non-existing idrange with --continue"
	rlRun "Del_Range contd" 0 "Creating expect script"
	rlRun "$exp $expfile $norange" 1 "Non-existing range deletion with --continue fails"
rlPhaseEnd
}

idrange_test_0011() {

rlPhaseStartTest "0011 Using dom-sid and secondary-rid-base together"
	rlRun "Trust_Add" 0 "Trust add between IPA domain and AD domain"
	rlRun "DOM_SID=`$ipacmd trust-find | grep -i \"Identifier\" | awk '{print $NF}'`" 0 "Getting AD Domain SID"
	rlRun "Dom_Sec_Rid domsec" 0 "Creating expect script"
	rlRun "$exp $expfile dom-sid $DOM_SID 10000 1549000000 10 $lrange" 1 "dom-sid and secondary-rid-base cannot be used together"
rlPhaseEnd
}

idrange_test_0012() {

rlPhaseStartTest "0012 Using dom-name and secondary-rid-base together"
	rlRun "Dom_Sec_Rid domsec" 0 "Creating expect script"
	rlRun "$exp $expfile dom-name $ADdomain 10000 1549000000 10 $lrange" 1 "dom-name and secondary-rid-base cannot be used together"
rlPhaseEnd
}

idrange_test_0013() {

rlPhaseStartTest "0013 Add idrange with dom-sid with invalid value - Ticket #3087"
	rlRun "Dom_Sec_Rid domsid" 0 "Creating expect script"
	rlRun "$exp $expfile dom-sid defrRCg 10000 1549000000 10 $lrange" 1 "Invalid SID is not accepted"

rlPhaseEnd
}

idrange_test_0014() {

rlPhaseStartTest "0014 Add idrange with dom-name with invalid value"
	rlRun "Dom_Sec_Rid domname" 0 "Creating expect script"
	rlRun "$exp $expfile dom-name 76543 10000 1549000000 10 $lrange" 1 "Invalid domain name is not accepted"

rlPhaseEnd
}


idrange_test_0015() {

rlPhaseStartTest "0015 Add idrange for trusted domain overlapping existing range"
	rlRun "ADBASE_ID=`$ipacmd idrange-show $ADDOMAIN_id_range | grep "First Posix ID" | awk '{print $NF}'`"
        rlRun "NEW_ADBASE_ID=`expr $BASE_ID + 50000`"
        rlRun "IDrange_Add same_startid" 0 "Creating expect script"
        rlRun "$exp $expfile $lrange $NEW_ADBASE_ID 10" 1 "Overlapping local idrange not allowed"

rlPhaseEnd
}

idrange_test_0016() {

rlPhaseStartTest "0016 Delete IPA server generated local domain range"
	rlRun "Del_Range" 0 "Creating expect script"
	rlRun "$exp $expfile $IPADOMAIN_id_range" 0 "IPA server generated local domain range cannot be deleted"

rlPhaseEnd
}

idrange_test_0017() {

rlPhaseStartTest "0017 Find idrange with wrong range name"
	rlRun "$ipacmd idrange-find $norange" 1 "Invalid range name find fails"

rlPhaseEnd
}

idrange_test_0018() {

rlPhaseStartTest "0018 Find idrange passing a value to --pkey-only"
	rlRun "$ipacmd idrange-find --pkey-only=$norange" 2 "--pkey-only does not take a value"

rlPhaseEnd
}

idrange_test_0019() {

rlPhaseStartTest "0019 Idrange find with empty values in options"
	rlRun "IDrange_Find novalue" 0 "Creating expect script"
	rlRun "$exp $expfile name" 2 "Fails without argument for --name"
	rlRun "$exp $expfile base-id" 2 "Fails without argument for --base-id"
	rlRun "$exp $expfile range-size" 2 "Fails without argument for --range-size"
	rlRun "$exp $expfile rid-base" 2 "Fails without argument for --rid-base"
	rlRun "$exp $expfile secondary-rid-base" 2 "Fails without argument for --secondary-rid-base"
	rlRun "$exp $expfile dom-sid" 2 "Fails without argument --dom-sid"

rlPhaseEnd
}

idrange_test_0020() {

rlPhaseStartTest "0020 Idrange find with invalid values in options"
	rlRun "$ipacmd idrange-find --name $norange" 1 "Name $norange does not exist, hence fails"
	rlRun "$ipacmd idrange-find --dom-sid $norange" 1 "dom-sid $norange is not valid sid, hence fails"
	rlRun "$ipacmd idrange-find --dom-name $norange" 1 "dom-name $norange is not valid domain, hence fails"
	rlRun "IDrange_Find invalid" 0 "Creating expect script"
	rlRun "$exp $expfile base-id someid00" 1 "Find with --base-id needs valid integer value"
	rlRun "$exp $expfile range-size somerange45" 1 "Find with --range-size needs valid integer value"
	rlRun "$exp $expfile rid-base somerid333"  1 "Find with --rid-base needs valid integer value"
	rlRun "$exp $expfile secondary-rid-base somesrid34" 1 "Find with --secondary-rid-base needs valid integer value"

rlPhaseEnd
}

idrange_test_0021() {

rlPhaseStartTest "0021 Idrange modify with empty values in options"
	rlRun "IDrange_Mod novalue" 0 "Creating expect script"
	rlRun "$exp $expfile base-id" 2 "Fails without argument for --base-id"
	rlRun "$exp $expfile range-size" 2 "Fails without argument for --range-size"
	rlRun "$exp $expfile rid-base" 2 "Fails without argument for --rid-base"
	rlRun "$exp $expfile secondary-rid-base" 2 "Fails without argument for --secondary-rid-base"
	rlRun "$exp $expfile dom-sid" 2 "Fails without argument for --dom-sid"
	rlRun "$exp $expfile dom-name" 2 "Fails without argument for --dom-name"

rlPhaseEnd
}

idrange_test_0022() {

rlPhaseStartTest "0022 Idrange modify with invalid values in options"
	rlRun "IDrange_Mod invalid" 0 "Creating expect script" 
	rlRun "$exp $expfile base-id someid00 $ADDOMAIN_id_range" 1 "Mod with --base-id needs valid integer value"
	rlRun "$exp $expfile range-size somerange45 $ADDOMAIN_id_range" 1 "Mod with --range-size needs valid integer value"
	rlRun "$exp $expfile rid-base somerid333 $ADDOMAIN_id_range" 1 "Mod with --rid-base needs valid integer value"
	rlRun "$exp $expfile secondary-rid-base $ADDOMAIN_id_range" 1 "Mod with --secondary-rid-base needs valid integer value"
	rlRun "IDrange_Mod domsid" 0 "Creating expect script"
	rlRun "$exp $expfile dom-sid someid00 $ADDOMAIN_id_range" 1 "Mod with --dom-sid needs valid SID value"
	rlRun "IDrange_Mod domname" 0 "Creating expect script"
	rlRun "$exp $expfile dom-name someid00 $ADDOMAIN_id_range" 1 "Mod with --dom-name needs valid domain name"

rlPhaseEnd
}

idrange_test_0023() {

rlPhaseStartTest "0023 Modify local/trusted idrange overlapping existing idrange"
	IPA_Variables
	AD_Variables
	rlRun "IDrange_Add same_startid" 0 "Creating expect script"
#	rlRun "ADbase_id=`$ipacmd idrange-show $ADDOMAIN_id_range | grep 'First Posix ID' | awk '{print $NF}'`" 0 "Find Base-id of AD range"
#	rlRun "lbase_id=`$ipacmd idrange-show $IPADOMAIN_id_range | grep 'First Posix ID' | awk '{print $NF}'`" 0 "Find Base-id of local range"
	if [ $adbase_id -lt $lbase_id ]; then
	  New_baseid=$((lbase_id - adbase_id + 1))
	  rlRun "$exp $expfile $ADDOMAIN_id_range $New_baseid 10" 1 "IDrange add with range-size overlapping the other existing range fails"
	else
	  New_baseid=$((adbase_id - lbase_id + 1))
          rlRun "$exp $expfile $IPADOMAIN_id_range $New_baseid 10" 1 "IDrange add with range-size overlapping the other existing range fails"
	fi

rlPhaseEnd
}

idrange_test_0024() {

rlPhaseStartTest "0024 Modify local range-size such that an object (uid,gid) falls out of the range"
	IPA_Variables
	rlRun "for i in `seq 2 9`; do $ipacmd user-add $user$i --first test$i --last $i; done" 0 "Create IPA users"
	last_user=`$ipacmd user-find --pkey-only | grep "User login" | tail -1 | awk '{print $NF}'`
	rlRun "last_uid=`$ipacmd user-show $last_user | grep UID | awk '{print $NF}'`" 0 "$last_user UID found"
	New_range=$((last_uid - lbase_id -1))
	rlRun "IDrange_Mod outofrange" 0 "Creating expect script"
	rlRun "$exp $expfile range-size $New_range $IPADOMAIN_id_range" 1 "Range-mod fails if Objects fall out of range"

rlPhaseEnd
}

idrange_test_0025() {

rlPhaseStartTest "0025 Add idrange interactively for local domain"
	IPA_Variables
	New_lbase_id=$((lbase_id + lrange_size))
	rlRun "IDrange_Add interactive" 0 "Creating expect script"
	rlRun "$exp $expfile $lrange $New_lbase_id 10" 0 "Adding local idrange interactively"
	# Clean up
	rlRun "$ipacmd idrange-del $lrange" 0 "Delete new local range"

rlPhaseEnd
}

idrange_test_0026() {

rlPhaseStartTest "0026 Add local idrange with rid-base secondary-rid-base"
	IPA_Variables
	New_rid_base=$((lrid_base + lrange_size))
	New_lbase_id=$((lbase_id + lrange_size))
	New_secrid_base=$((lsecrid_base + lrange_size))
	rlRun "IDrange_Add3 rid_sec" 0 "Creating expect script"
	rlRun "$exp $expfile $New_rid_base $New_secrid_base $New_lbase_id 10 $lrange" 0 "Local idrange add with rid-base secondary-rid-base"

rlPhaseEnd
}

idrange_test_0027() {

rlPhaseStartTest "0027 Delete idrange with --continue"
	rlRun "Del_Range contd" 0 "Creating expect script"
	rlRun "$exp $expfile $lrange" 0 "idrange delete with --continue"

rlPhaseEnd
}

idrange_test_0028() {

rlPhaseStartTest "0028 Add idrange for trusted domain with dom-sid/dom-name"
	AD_Variables
	rlRun "Dom_Sec_Rid domsid" 0 "Creating expect script"
	rlRun "$exp $expfile dom-sid $AD_SID $New_adrid $New_adbase_id 10 $adrange" 0 "idrange add for trusted domain with dom-sid"
	sleep 10
	# clean up
	rlRun "$ipacmd idrange-del $adrange" 0 "Delete $adrange"
	sleep 5
	rlRun "Dom_Sec_Rid domname" 0 "Creating expect script"
	rlRun "$exp $expfile dom-name $ADdomain $New_adrid $New_adbase_id 10 $adrange" 0 "idrange add for trusted domain with dom-sid"
	sleep 10
        # clean up
        rlRun "$ipacmd idrange-del $adrange" 0 "Delete $adrange"

rlPhaseEnd
}

idrange_test_0029() {

rlPhaseStartTest "0029 Add idrange for trusted domain without --rid-base on cli Ticket #3602"
	AD_Variables
	rlRun "Dom_Sec_Rid norid" 0 "Creating expect script"
	rlRun "$exp $expfile dom-name $ADdomain $New_adbase_id 10 $adrange" 1 "Not prompted for rid-base with dom-name"
	rlRun "$exp $expfile dom-sid $AD_SID $New_adbase_id 10 $adrange" 1 "Not prompted for rid-base with dom-sid"

rlPhaseEnd
}

idrange_test_0030() {

rlPhaseStartTest "0030 Find idrange with domain name"
	rlRun "$ipacmd idrange-find $ADdomain" 0 "Find with $ADdomain"
	rlRun "$ipacmd idrange-find $IPAdomain" 0 "Find with $IPAdomain"

rlPhaseEnd
}

idrange_test_0031() {

rlPhaseStartTest "0031 Find idrange with correct values for options"
	IPA_Variables
	AD_Variables
	rlRun "$ipacmd idrange-find --name $IPADOMAIN_id_range" 0 "idrange find with --name IPA range"
	rlRun "$ipacmd idrange-find --name $ADDOMAIN_id_range" 0 "idrange find with --name AD range"
	rlRun "$ipacmd idrange-find --base-id $lbase_id" 0 "idrange find with --base-id IPA range"
	rlRun "$ipacmd idrange-find --base-id $adbase_id" 0 "idrange find with --base-id AD range"
	rlRun "$ipacmd idrange-find --range-size $lrange_size" 0 "idrange find with --range-size IPA range"
	rlRun "$ipacmd idrange-find --range-size $adrange_size" 0 "idrange find with --range-size AD range"
	rlRun "$ipacmd idrange-find --rid-base  $lrid_base" 0 "idrange find with --rid-base IPA range"
	rlRun "$ipacmd idrange-find --rid-base  $adrid" 0 "idrange find with --rid-base AD range"
	rlRun "$ipacmd idrange-find --secondary-rid-base $lsecrid_base" 0 "idrange find with --secondary-rid-base IPA range"
	rlRun "$ipacmd idrange-find --dom-sid $AD_SID" 0 "idrange find with --dom-sid"
	rlRun "$ipacmd idrange-find --dom-sid $AD_SID" 2 "idrange find with --dom-name, no such option Ticket #3608"

rlPhaseEnd
}

idrange_test_0032() {

rlPhaseStartTest "0032 Modify idrange with correct values with options"
	IPA_Variables
        AD_Variables
	New_adbase_id=$((adbase_id - 1))
	rlRun "$ipacmd idrange-mod $ADDOMAIN_id_range --base-id $New_adbase_id | grep \"$New_adbase_id\"" 0 "idrange modify with --base-id"

	# Adding a user in AD
        rlRun "ADuser_ldif \"$ADfn\"1 $ADsn \"$aduser\"1 $userpw 512 add" 0 "Generate ldif file to add \"$aduser\"1"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user \"$aduser\"1 in AD before"
	rlRun "sleep 20" 0 "Sleeping for 20 sec as sssd (unresoved cache) entry_negative_timeout is 15 sec"
	# Get the uid of user aduser1
	aduser1_id=`$ID -u "$aduser"1@$ADdomain`
	New_adrange_size=$((aduser1_id - adbase_id + 1))
	rlRun "$ipacmd idrange-mod $ADDOMAIN_id_range --range-size $New_adrange_size | grep \"$New_adrange_size\"" 0 "idrange modify with --range-size"
	rlRun "$ipacmd idrange-mod $ADDOMAIN_id_range --rid-base 222 | grep \" 222\"" 0 "idrange modify with --rid-base"
	# Revert the change for test 0034
	rlRun "$ipacmd idrange-mod $ADDOMAIN_id_range --rid-base 0 | grep \" 0\"" 0 "Reverting the change with --rid-base"
	New_ridsec_base=$((lsecrid_base - 1))
	rlRun "$ipacmd idrange-mod $IPADOMAIN_id_range --secondary-rid-base $New_ridsec_base | grep \"$New_ridsec_base\"" 0 "idrange modify with --secondary-rid-base"
	
rlPhaseEnd
}

idrange_test_0033() {

rlPhaseStartTest "0033 Deplete trusted domain range, modify range size to use"
	AD_Variables
	aduser1_id=`$ID -u "$aduser"1@$ADdomain`
	rlLog "Last AD user UID is $aduser1_id"
	rlLog "AD idrange size is $adrange_size which is not inclusive, hence range is depleted"

	rlLog "Adding a new user in AD"
        rlRun "ADuser_ldif \"$ADfn\"2 $ADsn \"$aduser\"2 $userpw 512 add" 0 "Generate ldif file to add \"$aduser\"2"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user \"$aduser\"2 in AD"
	rlRun "sleep 20" 0 "Sleeping for 20 sec as sssd (unresoved cache) entry_negative_timeout is 15 sec"
	# Get the uid of user aduser2
	rlRun "$ID -u \"$aduser\"2@$ADdomain" 1 "No UID for \"$aduser\"2 as expected"
	New_adrange_size=$((aduser1_id - adbase_id + 2))
	rlRun "$ipacmd idrange-mod $ADDOMAIN_id_range --range-size $New_adrange_size | grep \"$New_adrange_size\"" 0 "idrange modify range-size for \"$aduser\"2 UID"
	rlRun "sleep 20" 0 "Sleeping for 20 sec as sssd (unresoved cache) entry_negative_timeout is 15 sec"
	rlRun "$ID -u \"$aduser\"2@$ADdomain" 0 "\"$aduser\"2 owns UID as expected after range-size mod"

rlPhaseEnd
}

idrange_test_0034() {

rlPhaseStartTest "0034 Deplete trusted domain range, add new range to use"
	AD_Variables
	aduser2_id=`$ID -u \"$aduser\"2@$ADdomain`
	rlLog "Last AD user UID is $aduser2_id"
	rlLog "AD idrange size is $adrange_size which is not inclusive, hence range is depleted"
	rlRun "Dom_Sec_Rid domsid" 0 "Creating expect script"
        rlRun "$exp $expfile dom-sid $AD_SID $New_adrid $New_adbase_id 10 $adrange" 0 "idrange add for trusted domain with dom-sid"
	rlLog "Adding a new user in AD"
        rlRun "ADuser_ldif \"$ADfn\"3 $ADsn \"$aduser\"3 $userpw 512 add" 0 "Generate ldif file to add \"$aduser\"3"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user \"$aduser\"3 in AD"
	rlRun "sleep 20" 0 "Sleeping for 20 sec as sssd (unresoved cache) entry_negative_timeout is 15 sec"
	rlRun "$ID -u \"$aduser\"3@$ADdomain | grep $New_adbase_id" 0 "\"$aduser\"3 owns UID as expected from new added range"

rlPhaseEnd
}

idrange_test_0035() {

rlPhaseStartTest "0035 idrange-add/mod with base-id/range-size value 0 Ticket #3624"
	rlRun "Zero_Val add" 0 "Creating expect script"
	rlRun "$exp $expfile range-size 10 base-id $lrange" 0 "Clear error for idrange add with base-id 0"
	rlRun "$exp $expfile base-id 1 range-size $lrange" 0 "Clear error for idrange add with range-size 0"
	
	rlRun "Zero_Val mod" 0 "Creating expect script"
	rlRun "$exp $expfile base-id $ADDOMAIN_id_range" 0 "Clear error for idrange mod with base-id 0"
	rlRun "$exp $expfile range-size $ADDOMAIN_id_range" 0 "Clear error for idrange mod with range-size 0"

rlPhaseEnd
}

idrange_test_0036() {

rlPhaseStartTest "0036 Deplete local range and then add user"
	IPA_Variables
	rlRun "create_ipauser \"$ipa_user\"2 test2 user $userpw"
	ipa_user2id=`$ID -u "$ipa_user"2`
	new_lrange=$((ipa_user2id - lbase_id + 1))
	rlRun "$ipacmd idrange-mod $IPADOMAIN_id_range --range_size $new_lrange | grep \" $new_lrange\"" 0 "Local range modify using idrange cli"
	rlLog "Since DNA plugin and idrange work independently, maunally editing DNA plugin setting to reflect range-change Ticket #3609"
	range_max=$((ipa_user2id + 1))
	rlRun "DNAmod_ldif \"$DNA_plugin\" dnaMaxValue $range_max" 0 "Generate ldif file to modify DNA plugin"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f DNAmod.ldif" 0 "Modify range in DNA plugin"
	rlRun "create_ipauser \"$ipa_user\"3 test3 user $userpw"
	rlRun "Add_User" 0 "Creating expect script"
	rlRun "$exp $expfile \"$ipa_user\"4 test4 user" 1 "User add fails when local range is depleted"
	
rlPhaseEnd
}

idrange_test_0037() {

rlPhaseStartTest "0037 Modify local range to use after it is depleted"
	IPA_Variables
	rlRun "Add_User" 0 "Creating expect script"
	rlRun "$exp $expfile \"$ipa_user\"4 test4 user" 1 "User add fails when local range is depleted"
	ipa_user3id=`$ID -u "$ipa_user"3`
	new_lrange=$((ipa_user3id - lbase_id + 1))
	rlRun "$ipacmd idrange-mod $IPADOMAIN_id_range --range_size $new_lrange | grep \" $new_lrange\"" 0 "Local range modify using idrange cli"
	rlLog "Since DNA plugin and idrange work independently, maunally editing DNA plugin setting to reflect range-change Ticket #3609"
        range_max=$((ipa_user3id + 1))
        rlRun "DNAmod_ldif replace \"$DNA_plugin\" dnaMaxValue $range_max" 0 "Generate ldif file to modify range DNA plugin"
        rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f DNAmod.ldif" 0 "Modify range in DNA plugin"
        rlRun "create_ipauser \"$ipa_user\"4 test4 user $userpw" 0 "New user add after increasing range size by 1"

rlPhaseEnd
}

idrange_test_0038() {

rlPhaseStartTest "0038 Add new range to use after it is depleted"
	IPA_Variables
	rlRun "Add_User" 0 "Creating expect script"
	rlRun "$exp $expfile \"$ipa_user\"5 test5 user" 1 "User add fails when local range is depleted"
	ipa_user4id=`$ID -u "$ipa_user"4`
	# Adding 3456 as a random difference between old and new range
	new_base_id=$((ipa_user4id + 3456))
	# Range-size is randomly taken as 5
	last_base_id=$((new_base_id + 5))
	# Adding 123 as a random difference between old and new rid and secrid
	new_rid=$((ipa_user4id - lbase_id + 123))
	new_secrid=$((lsecrid_base + 123))
	rlRun "IDrange_Add3 rid_sec" 0 "Creating expect script"
        rlRun "$exp $expfile $new_base_id $new_secrid $new_base_id 5 $lrange" 0 "Add new local idrange"
	rlLog "Since DNA plugin and idrange work independently, maunally editing DNA plugin setting to reflect range-change Ticket #3609"
	rlRun "DNAmod_ldif add \"$DNA_plugin\" dnaNextRange $new_base_id $last_base_id" 0 "Generate ldif file to add new range in DNA plugin"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f DNAmod.ldif" 0 "Add new range in DNA plugin"
	rlRun "create_ipauser \"$ipa_user\"5 test5 user $userpw" 0 "New user add after adding new range in DNA plugin"

rlPhaseEnd
}

idrange_test_0039() {

rlPhaseStartTest "0039 Delete idrange of trusted domain created when trust was established Ticket #3615"
	
rlPhaseEnd
}


cleanup() {

rlPhaseStartCleanup "Clean up for trust-cli tests"
        rlRun "$ipacmd trust-del $ADdomain $ADdomain2" 0 "Delete trusts for cleanup"
        rlRun "pushd $TmpDir"
        rlRun "ADuserdel_ldif \"$ADfn\"1 $ADsn" 0 "Create ldif file to delete \"$aduser\"1"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuserdel.ldif" 0 "Delete \"$aduser\"1 from AD"
        rlRun "ADuserdel_ldif \"$ADfn\"2 $ADsn" 0 "Create ldif file to delete \"$aduser\"2"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuserdel.ldif" 0 "Delete \"$aduser\"2 from AD"
        rlRun "ADuserdel_ldif \"$ADfn\"3 $ADsn" 0 "Create ldif file to delete \"$aduser\"3"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuserdel.ldif" 0 "Delete \"$aduser\"3 from AD"
        rlRun "rm -f *.ldif"
        rlRun "popd"
        rlRun "rm -fr $TmpDir"

        # Clear trust from AD side
        rlRun "./clear_trust.exp remove $ADadmin $ADpswd $ADip $ADdomain $ADMINID $ADMINPW $IPAdomain" 0 "Clear trust from $ADdomain"
#        rlRun "./clear_trust.exp remove $ADadmin2 $ADpswd2 $ADip2 $ADdomain2 $ADMINID $ADMINPW $IPAdomain" 0 "Clear trust from $ADdomain2"

        # Delete conditional forwarder for IPA domain from both ADs
        rlRun "./adsetup.exp delete $ADadmin $ADpswd $ADip $IPAdomain" 0 "Delete conditional forwarder for IPA on $ADadmin"
#        rlRun "./adsetup.exp delete $ADadmin2 $ADpswd2 $ADip2 $IPAdomain" 0 "Delete conditional forwarder for IPA on $ADadmin2"

        rlRun "certutil -d $slapd_dir -D -n \"AD cert\"" 0 "Delete AD cert"
        rlRun "kdestroy" 0 "Destroy any credentials"
        rlRun "rm -fr /tmp/krb5cc_*"
rlPhaseEnd
}
