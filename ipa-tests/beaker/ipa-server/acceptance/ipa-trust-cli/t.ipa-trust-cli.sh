#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-trust-cli
#   Description: IPA trust CLI test cases
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
IPA_range="$IPADOMAIN"_id_range
ADDOMAIN=`echo ${ADdomain^^}`
AD_range="$ADDOMAIN"_id_range
ADDOMAIN2=`echo ${ADdomain2^^}`
AD2_range="$ADDOMAIN2"_id_range
IPAhostIP=`ip addr | egrep 'inet ' | grep "global" | cut -f1 -d/ | awk '{print $NF}'`
srv_name=`hostname -s`
NBname="TESTRELM"
trust_bin=`which ipa-adtrust-install`
exp=`which expect`
slapd_dir="/etc/dirsrv/slapd-TESTRELM-COM"
ldap_conf="/etc/openldap/ldap.conf"
ADcrt="ADcert.cer"
AD_binddn="CN=Administrator,CN=Users,$ADdc" 
userpw="Secret123"
user="tuser"
user2="nuser"
adminpw="Secret123"
ADfn="ads"
ADfn2="ads2"
ADsn="user"
aduser1="aduser1"
aduser2="aduser2"
trust_secret="TrUsTsEcRet"
samba_cc="/var/run/samba/krb5cc_samba"

setup() {
rlPhaseStartSetup "Setup both ADS and IPA Servers for trust"
	# check for packages
	rlRun "rlDistroDiff ipa_pkg_check" 0 "Packages installed for current OS flavor"

	# stopping firewall
	rlServiceStop "firewalld"
#	rlServiceStop "ip6tables"

	# Setup both ADs with conditional forwarder for IPA domain
	rlRun "./adsetup.exp add $ADadmin $ADpswd $ADip $IPAdomain $IPAhostIP" 0 "Add conditional forwarder for $ADdomain"
	rlRun "./adsetup.exp add $ADadmin2 $ADpswd2 $ADip2 $IPAdomain $IPAhostIP" 0 "Add conditional forwarder for $ADdomain"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "$ipacmd dnszone-add $ADdomain --name-server=$ADhost --admin-email=hostmaster@$ADdomain --force --forwarder=$ADip --forward-policy=only --ip-address=$ADip" 0 "Adding forwarder for  $ADdomain"
	rlRun "$ipacmd dnszone-add $ADdomain2 --name-server=$ADhost2 --admin-email=hostmaster@$ADdomain2 --force --forwarder=$ADip2 --forward-policy=only --ip-address=$ADip2" 0 "Adding forwarder for  $ADdomain2"
	sleep 30

	# Deleting samba cache credential. Remove this after https://fedorahosted.org/freeipa/ticket/3479 is resolved
        [ -e $samba_cc ] && rm -f $samba_cc

	# Prepare IPA server for trust
	rlRun "$trust_bin -a $adminpw --netbios-name $NBname -U" 0 "Preparing server to establish trust"
	
	# Checking DNS records are in place or AD and IPA, Needs improovement #####
	rlRun "dig +short SRV @$ADip _ldap._tcp.$IPAdomain | grep $IPAhost" 0 "Conditional forwarder for IPA server setup on $ADhost"
	rlRun "dig +short SRV @$ADip2 _ldap._tcp.$IPAdomain | grep $IPAhost" 0 "Conditional forwarder for IPA server setup on $ADhost2"

	rlRun "dig +short SRV _ldap._tcp.$ADdomain | grep $ADhost" 0 "Forwarder for $ADdomain setup"
	rlRun "dig +short SRV _ldap._tcp.$ADdomain2 | grep $ADhost2" 0 "Forwarder for $ADdomain2 setup"

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
	# Adding a user in AD
        rlRun "ADuser_ldif $ADfn $ADsn $aduser1 $userpw 512 add" 0 "Generate ldif file to add $aduser1"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user $aduser1 in AD before"

	# Adding a user in AD and adding to Administrators group
        rlRun "ADuser_ldif $ADfn2 $ADsn $aduser2 $userpw 512 add" 0 "Generate ldif file to add $aduser2"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user $aduser2 in AD before"
	rlRun "User_Admin_ldif $ADfn2 $ADsn modify" 0 "Generate ldif file to add $aduser2 to administrators group"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f User_Admin.ldif" 0 "Adding $aduser2 to administrators group"

	# Clean up
	rlRun "popd"

	rlRun "create_ipauser $user test user $userpw"
	rlRun "create_ipauser $user2 new user $userpw"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "$ipacmd group-add-member admins --users=$user2" 0 "Adding $user2 to IPA admins group"
rlPhaseEnd
}

trust_test_0001() {

rlPhaseStartTest "0001 Add trust for invalid domain"
	rlRun "Add_Trust" 0 "Creating expect script"
	rlRun "$exp $expfile bad$ADdomain $ADadmin $ADpswd" 2 "Unable to resolve domain controller as expected"
rlPhaseEnd
}

trust_test_0002() {

rlPhaseStartTest "0002 Add trust with type and domain"
	rlRun "Add_Trust type" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain" 1 "Trust add needs more arguments"
rlPhaseEnd
}

trust_test_0003() {

rlPhaseStartTest "0003 Give invalid server name in --server option"
	rlRun "Add_Trust server" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd zombie.$ADdomain" 2 "Invalid server and correct domain on cli fails"
	rlRun "Add_Trust no_ad" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd zombie.$ADdomain" 2 "Invalid server and correct domain given interactively fails"
rlPhaseEnd
}

trust_test_0004() {

rlPhaseStartTest "0004 Give password on CLI for --password"
	rlRun "Passwd_Cli" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd" 1 "Expected. Giving password for --password is assumed as an argument"
	rlRun "Passwd_Cli passwd" 0 "Creating expect script"
        rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd" 2 "Expected. --password does not take a value"
rlPhaseEnd
}

trust_test_0005() {

rlPhaseStartTest "0005 Give user with no administrator rights for --admin option"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$ADfn $ADsn,CN=Users,$ADdc\" | grep sAMAccountName | grep $aduser1" 0 "$aduser1 exists on AD"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$ADfn $ADsn,CN=Users,$ADdc\" | grep memberOf" 1 "$aduser1 not a member of administrators group"
	rlRun "Non_Admin" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $aduser1 $userpw" 1 "Add trust by $aduser1 with correct credentials cannot add trust"
	rlRun "Non_Admin wrng_passwd" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $aduser1 wrng_passwd" 1 "Add trust by $aduser1 with wrong credentials fails as expected"
rlPhaseEnd
}

trust_test_0006() {

rlPhaseStartTest "0006 trust-add interactively"
	rlRun "Interactive_trust" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain" 1 "Trust-add is not Interactive, https://fedorahosted.org/freeipa/ticket/3034"
rlPhaseEnd
}

trust_test_0007() {

rlPhaseStartTest "0007 Trust add with minimum options on CLI"
	rlRun "Add_Trust" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd" 0 "Active Directory Trust added for $ADdomain"
rlPhaseEnd
}

trust_test_0008() {

rlPhaseStartTest "0008 Delete trust with invalid domain"
	rlRun "Trust_Del domain" 0 "Creating expect script"
	rlRun "$exp $expfile bad$ADdomain" 2 "bad$ADdomain Domain does not have trust relation"
rlPhaseEnd
}

trust_test_0009() {

rlPhaseStartTest "0009 Delete trust interactively"
	rlRun "Trust_Del" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain" 0 "Trust deleted with $ADdomain"
rlPhaseEnd
}

trust_test_0010() {

rlPhaseStartTest "0010 Add trust with --server option"
	rlRun "Add_Trust server" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd $ADhost" 0 "Active Directory Trust added with --server"
rlPhaseEnd
}

trust_test_0011() {

rlPhaseStartTest "0011 Delete trust with --continue and invalid domain"
	rlRun "Trust_Del continue" 0 "Creating expect script"
	rlRun "$exp $expfile bad$ADdomain" 1 "Invalid domain deletion fails"
rlPhaseEnd
}

trust_test_0012() {

rlPhaseStartTest "0012 Having existing AD trust add trust with a new domain"
	rlRun "Add_Trust" 0 "Creating expect script"
        rlRun "$exp $expfile $ADdomain2 $ADadmin2 $ADpswd2" 0 "Active Directory Trust add for $ADdomain2"
rlPhaseEnd
}

trust_test_0013() {

rlPhaseStartTest "0013 Delete trust with --continue option"
	rlRun "Trust_Del continue" 0 "Creating expect script"
        rlRun "$exp $expfile $ADdomain2" 0 "Trust deleted successfully with --continue"
rlPhaseEnd
}

trust_test_0014() {

rlPhaseStartTest "0014 Add trust with --trust-secret"
	rlRun "Add_Trust secret" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain2 $ADadmin2 $ADpswd2 $trust_secret" 0 "Trust add for $ADdomain2 with Secret"
rlPhaseEnd
}

trust_test_0015() {

rlPhaseStartTest "0015 Trust delete by user, member of IPA admins group"
	rlRun "Trust_Del domain" 0 "Creating expect script"
	rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
	rlRun "$exp $expfile $ADdomain2" 0 "Trust delete by a user, member of admins group"
	rlRun "kdestroy" 0 "Destroy any credentials"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
rlPhaseEnd
}

trust_test_0016() {

rlPhaseStartTest "0016 Add trust with --trust-secret with empty string"
        rlRun "Add_Trust secret" 0 "Creating expect script"
        rlRun "$exp $expfile $ADdomain2 $ADadmin2 $ADpswd2" 0 "Trust add for $ADdomain2 with empty string as Secret"
rlPhaseEnd
}

trust_test_0017() {

rlPhaseStartTest "0017 Provide user with admin rights in --admin option"
	rlRun "$ipacmd trust-del $ADdomain --continue" 0 "Deleting trust to continue testing"
	rlRun "Add_Trust" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $aduser2 $userpw" 0 "Trust add for $ADdomain2 by $aduser2 member of administrators group"
rlPhaseEnd
}

trust_test_0018() {

rlPhaseStartTest "0018 Delete trust as a non-admin user"
	rlRun "kinitAs $user $userpw" 0 "Kinit as $user"
	rlRun "Trust_Del domain" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain" 1 "Delete trust by IPA user fails"
	rlRun "kdestroy" 0 "Destroy any credentials"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
rlPhaseEnd
}

trust_test_0019() {

rlPhaseStartTest "0019 Find trust for invalid domain"
	rlRun "$ipacmd trust-find bad$ADdomain" 1 "Invalid domain find fails"
	rlRun "$ipacmd trust-find --realm=bad$ADdomain" 1 "Invalid domain find with --realm fails"
rlPhaseEnd
}

trust_test_0020() {

rlPhaseStartTest "0020 Find trust with valid domain"
	rlRun "$ipacmd trust-find | grep \"Number of entries returned 2\"" 0 "Find without domain as argument"
	rlRun "$ipacmd trust-find $ADdomain" 0 "Valid domain find"
	rlRun "$ipacmd trust-find --realm=$ADdomain" 0 "Valid domain find with --realm"
rlPhaseEnd
}

trust_test_0021() {

rlPhaseStartTest "0021 Find trust with --timelimit"
	rlRun "$ipacmd trust-find --timelimit=1" 0 "Trust find with --timelimit"
rlPhaseEnd
}

trust_test_0022() {

rlPhaseStartTest "0022 Find trust with --sizelimit"
	rlRun "$ipacmd trust-find --sizelimit 1 | grep \"entries returned 1\"" 0 "Find 1 trust with --sizelimit"
	rlRun "$ipacmd trust-find --sizelimit 2 | grep \"entries returned 2\"" 0 "Find 2 trust with --sizelimit"
	rlRun "$ipacmd trust-find --sizelimit 0 | grep \"entries returned 2\"" 0 "Find infinite trust with --sizelimit"
rlPhaseEnd
}

trust_test_0023() {

rlPhaseStartTest "0023 Find trust with --pkey-only"
	rlRun "$ipacmd trust-find --pkey-only | grep \"Domain\"" 1 "Find with pkey-only"
rlPhaseEnd
}

trust_test_0024() {

rlPhaseStartTest "0024 Show trust for invalid/non-existent domain"
	rlRun "$ipacmd trust-show bad$ADdomain2" 2 "Trust show for invalid domain fails"
rlPhaseEnd
}

trust_test_0025() {

rlPhaseStartTest "0025 Show trust for valid domain"
	rlRun "Trust_Show" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain" 0 "Show trust interactively"
	rlRun "Trust_Show domain" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain" 0 "Show trust with domain as argument"
rlPhaseEnd
}

trust_test_0026() {

rlPhaseStartTest "0026 Show trust entries of Realm with --all and --raw"
	rlRun "Trust_Show allraw" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain2" 1 "Getting all raw output fails (Ticket #3525)"
rlPhaseEnd
}

trust_test_0027() {

rlPhaseStartTest "0027 Deleting multiple trusts"
	rlRun "Trust_Del multi" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADdomain2" 0 "Delete both trusts"
rlPhaseEnd
}

trust_test_0028() {

rlPhaseStartTest "0028 Trust add without specifying AD domain"
	rlRun "Add_Trust domain" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain2 $ADadmin2 $ADpswd2" 0 "Trust add for $ADdomain2 giving realm name interactively"
rlPhaseEnd
}

trust_test_0029() {

rlPhaseStartTest "0029 Trust add with AD server name, but without specifying AD domain"
	rlRun "Add_Trust onlyserver" 0 "Creating expect script"
        rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd $ADhost" 0 "Trust add for $ADdomain with --server and giving realm name interactively"
rlPhaseEnd
}

trust_test_0030() {

rlPhaseStartTest "0030 Show trust raw data"
	rlRun "Trust_Show raw" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain" 0 "Show entries as stored on the server"
rlPhaseEnd
}

trust_test_0031() {

rlPhaseStartTest "0031 Show trust rights with --rights"
	rlRun "Trust_Show rights" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain2" 0 "Show access rights"
rlPhaseEnd
}

trust_test_0032() {

rlPhaseStartTest "0032 Add trust with invalid values for --base-id"
	rlRun "Trust_Del multi" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADdomain2" 0 "Delete both trusts for next tests"
	rlRun "Trust_ID empty" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd base-id" 2 "--base-id requires an argument"
	rlRun "Trust_ID invalid" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd base-id sfae32df" 1 "--base-id requires an argument"

rlPhaseEnd
}

trust_test_0033() {

rlPhaseStartTest "0033 Add trust with invalid values for range-size"
	rlRun "Trust_ID empty" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd range-size" 2 "--range-size requires an argument"
	rlRun "Trust_ID invalid" 0 "Creating expect script"
        rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd range-size sfae32df" 1 "--range-size requires an argument"

rlPhaseEnd
}

trust_test_0034() {

rlPhaseStartTest "0034 Add trust with --base-id overlapping existing range"
	IPA_Variables
	# Calulating new base-id for AD range to avoid overlap error
	new_base_id1=$((lbase_id + 9))
	new_base_id2=$((lbase_id + lrange_size - 1))
	new_base_id3=$((lbase_id - 200000 + 1))
	rlRun "Add_Trust base-id" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd $new_base_id1" 1 "base-id $new_base_id1 within existing range fails"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd $new_base_id2" 1 "base-id $new_base_id2 last id of existing range fails"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd $new_base_id3" 1 "base-id $new_base_id3 and default range (200000), making local range first base-id its last id fails"

rlPhaseEnd
}

trust_test_0035() {

rlPhaseStartTest "0035 Warning needed when re-adding trust with a different range Ticket #3635"
	rlLog "https://fedorahosted.org/freeipa/ticket/3635"
	rlLog "Needs code after ticket is resolved"
	rlRun "$ipacmd idrange-del $AD_range $AD2_range" 0 "Deleting ranges as trusts do not exist"

rlPhaseEnd
}

trust_test_0036() {

rlPhaseStartTest "0036 Add trust with correct value --base-id"
	IPA_Variables
	new_base_id=$((lbase_id - lrange_size))
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd $new_base_id" 0 "Trust added with base-id $new_base_id"
	AD_Variables
	rlRun "[ $new_base_id -eq $adbase_id ]" 0 "First Posix ID is $new_base_id"
	# Test CleanUp
	rlRun "$ipacmd trust-del $ADdomain" 0 "Deleting trust to continue testing"
	rlRun "$ipacmd idrange-del $AD_range" 0 "Deleting range to continue testing"

rlPhaseEnd
}

trust_test_0037() {

rlPhaseStartTest "0037 Add trust with proper range value for --range-size" 
	new_range="2000"
	rlRun "Add_Trust range" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain2 $ADadmin2 $ADpswd2 $new_range" 0 "Trust added with range-size $new_range"
	added_range=`$ipacmd idrange-show $AD2_range | grep "Number of IDs in the range" | awk '{print $NF}'`
	rlRun "[ $added_range -eq $new_range ]" 0 "Number of IDs in the range is $new_range"

rlPhaseEnd
}

trust_test_0038() {

rlPhaseStartTest "0038 Add trust with correct values for base-id and range-size"
	IPA_Variables
        new_base_id=$((lbase_id - 200000))
	new_range="3000"
	rlRun "Add_Trust base_range" 0 "Creating expect script"
	rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd $new_base_id $new_range" 0 "Trust added with base-id $new_base_id and range-size $new_range"
	AD_Variables
	rlRun "[ $new_base_id -eq $adbase_id ]" 0 "Trusted range base-id is $new_base_id"
	rlRun "[ $new_range -eq $adrange_size ]" 0 "Trusted range size is $new_range"

rlPhaseEnd
}

cleanup() {

rlPhaseStartCleanup "Clean up for trust-cli tests"
	rlRun "$ipacmd trust-del $ADdomain $ADdomain2" 0 "Delete trusts for cleanup"
	rlRun "pushd $TmpDir"
	rlRun "ADuserdel_ldif $ADfn $ADsn" 0 "Create ldif file to delete $aduser1"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuserdel.ldif" 0 "Delete $aduser1 from AD"
	rlRun "ADuserdel_ldif $ADfn2 $ADsn" 0 "Create ldif file to delete $aduser2"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuserdel.ldif" 0 "Delete $aduser2 from AD"	
	rlRun "rm -f *.ldif"
	rlRun "popd"
	rlRun "rm -fr $TmpDir"

	# Clear trust from AD side
	rlRun "./clear_trust.exp remove $ADadmin $ADpswd $ADip $ADdomain $ADMINID $ADMINPW $IPAdomain" 0 "Clear trust from $ADdomain"
	rlRun "./clear_trust.exp remove $ADadmin2 $ADpswd2 $ADip2 $ADdomain2 $ADMINID $ADMINPW $IPAdomain" 0 "Clear trust from $ADdomain2"

	# Delete conditional forwarder for IPA domain from both ADs
        rlRun "./adsetup.exp delete $ADadmin $ADpswd $ADip $IPAdomain" 0 "Delete conditional forwarder for IPA on $ADadmin"
	rlRun "./adsetup.exp delete $ADadmin2 $ADpswd2 $ADip2 $IPAdomain" 0 "Delete conditional forwarder for IPA on $ADadmin2"

	rlRun "certutil -d $slapd_dir -D -n \"AD cert\"" 0 "Delete AD cert"
	rlRun "kdestroy" 0 "Destroy any credentials"
	rlRun "rm -fr /tmp/krb5cc_*"
rlPhaseEnd
}
