#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-winsync
#   Description: winsync test cases
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Steeve Goveas <stv@redhat.com>
#   Date: June 14, 2012
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

# AD values
. ./Config

# AD libs
. ./winlib.sh

########################################################################
# Test Suite Globals
########################################################################

RELM=`echo $RELM | tr "[a-z]" "[A-Z]"`

########################################################################

######################
#     Variables      #
######################
firstname="ipauser1"
surname="user"
userpw="Secret123"
userpw2="Dec3yp12"

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
PACKAGE3="samba-common"

sec="30"
ADfn="test"
ADsn="user"
ADln="tuser"
aduser="aduser1"
aduser2="aduser2"
l1user="l1user"
l2user="l2user"
sub1user="sub1user"
sub2user="sub2user"
phn_1="22334455"
phn_2="66778899"
new_UID="88228822"
OU1="level1"
sub_OU1="sub-level1"
OU2="level2"
sub_OU2="sub-level2"
IPAhost=`hostname`
#aduser_ln="ads"
slapd_dir="/etc/dirsrv/slapd-TESTRELM-COM"
ldap_conf="/etc/openldap/ldap.conf"
named_conf="/etc/named.conf"
named_conf_bkp="/etc/named.conf.winsync"
error_log="/var/log/dirsrv/slapd-TESTRELM-COM/errors"
AD_binddn="cn=Administrator,cn=Users,dc=adrelm,dc=com"
DS_binddn="cn=Directory Manager"


setup() {
rlPhaseStartTest "Setup for winsync sanity tests"

	# check for packages
pushd .
	for item in $PACKAGE1 $PACKAGE2 $PACKAGE3; do
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

popd
	# Adding a same user in IPA that will be added in AD before winsync"
	rlRun "create_ipauser 456 ads 456 $userpw2"
	rlRun "ipa user-mod 456 --phone $phn_1" 0 "Adding telephone number of user 456"

	# Adding conditional forwarder
	rlRun "cp -p $named_conf $named_conf_bkp" 0 "Backup $named_conf before adding conditional forwarder for AD"
	echo -e "\nzone \"$ADdomain\" IN {\n\ttype forward;\n\tforwarders { $ADip; };\n\tforward only;\n};" >> $named_conf
#	rlRun "service named restart"
	rlServiceStop "named"
	rlServiceStart "named"
	sleep 30
	rlRun "host $ADhost"
rlPhaseEnd
}

winsync_test_0001() {

rlPhaseStartTest "winsync_test_0001: Creating winsync agreement"
	# Specifying TLS_CACERTDIR
	grep -q "TLS_CACERTDIR" $ldap_conf
	if [ $? -eq 0 ]; then
	  sed -i "s/.*TLS_CACERTDIR.*/TLS_CACERTDIR \/etc\/dirsrv\/slapd\-TESTRELM\-COM/" $ldap_conf
	else
	  echo "TLS_CACERTDIR $slapd_dir" >> $ldap_conf
	fi

	# Attempting creating the Agreement with invalid cert
	rlRun "certutil -A -i invalidAD.cer -d $slapd_dir -n \"Invalid cert\" -t \"CT,,C\" -a"
	rlRun "certutil -L -d $slapd_dir | grep \"Invalid cert\"" 0 "Verifying Invalid AD cert is imported in db"
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=invalidAD.cer $ADhost --binddn "$AD_binddn" --bindpw Secret123 -v -p Secret123" 1 "Winsync Agreement with invalid cert failed as expected"
	rlRun "certutil -d $slapd_dir -D -n \"Invalid cert\""

	rlRun "certutil -A -i ADcert.cer -d $slapd_dir -n \"AD cert\" -t \"CT,,C\" -a"
	rlRun "certutil -L -d $slapd_dir | grep \"AD cert\"" 0 "Verifying AD cert is imported in db"
	# Verify you can connect via TLS to ADS server
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpasswd -b \"$AD_binddn\"" 0 "Verifying connection via TLS to ADS server"
	# Adding a user before winsync agreement
	rlRun "ADuser_ldif $ADfn $ADsn $ADln add" 0 "Generate ldif file to add $ADln"
        rlRun "ADuser_passwd_ldif $ADfn $ADsn $userpw" 0 "Generate ldif file for setting $ADln passwd"
        rlRun "ADuser_cntrl_ldif $ADfn $ADsn 512" 0 "Generate ldif file to enable $ADln"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser.ldif" 0 "Adding new user in AD before winsync $ADln"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting $ADln passwd"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling $ADln"
	rlRun "telephoneNumber_ldif $ADfn $ADsn 001788788001"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f telephoneNumber.ldif" 0 "Adding telephone number for $ADln"

	# Creating the Agreement
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=ADcert.cer $ADhost --binddn \"$AD_binddn\" --bindpw Secret123 -v -p Secret123" 0 "Creating Winsync Agreement with valid cert"

	# Restart PassSync after winsync agreement is established
	net rpc service stop PassSync -I $ADhost -U administrator%$ADpasswd
	net rpc service stop PassSync -I $ADhost -U administrator%$ADpasswd
	rlRun "net rpc service start PassSync -I $ADhost -U administrator%$ADpasswd" 0 "Restarting PassSync Service"

rlPhaseEnd
}

winsync_test_0002() {

rlPhaseStartTest "winsync_test_0002: Change Winsync Interval from default 300 seconds"
	rlRun "errorlog_ldif 8192"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w Secret123 -f errorlog.ldif" 0 "Setting the error log level"
	rlRun "syncinterval_ldif $sec add"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w Secret123 -f syncinterval.ldif" 0 "Change winsync interval to $sec seconds"
	sleep $sec
	rlRun "sleep 30"
	x=`grep "Running Dirsync" $error_log | tail -n2 | head -1| awk -F: '{print $3}'`
	y=`grep "Running Dirsync" $error_log | tail -n1 | awk -F: '{print $3}'`
	rlRun "z=`expr $y - $x | awk -F- '{print $NF}'`"
	if [ $z -ge 5 ]; then
	 rlRun "echo \"SyncInterval is unchanged: $z mins\"" 0 "Winsync interval change to $sec sec failed as expected: Bug 820258"
	 rlLog "https://bugzilla.redhat.com/show_bug.cgi?id=820258"
	 rlRun "service dirsrv restart" 0 "Restarting dirsrv for winsync interval change to take effect"
	 sleep $sec
	 rlRun "sleep 30"
	fi
	 x=`grep "Running Dirsync" /var/log/dirsrv/slapd-TESTRELM-COM/errors | tail -n2 | head -1| awk -F: '{print $4}' | cut -f1 -d+`
	 y=`grep "Running Dirsync" /var/log/dirsrv/slapd-TESTRELM-COM/errors | tail -n1 | head -1| awk -F: '{print $4}' | cut -f1 -d+`
	 rlRun "z=`expr $y - $x | awk -F- '{print $NF}'`"
	 if [ $z -le $sec ]; then
	  rlRun "echo \"Winsync Interval successfully modified to $z Seconds\""
	 else
	  rlFail "Winsync interval change to $sec seconds did not take effect"
	 fi

rlPhaseEnd
}


winsync_test_0003() {

rlPhaseStartTest "winsync_test_0003: Create users(numeric/alphanumeric) in AD and verify it is synced to IPA and overwrites existing IPA users"

	# Creating user in AD
	rlRun "ADuser_ldif $aduser ads $aduser add" 0 "Generate ldif file to add user $aduser"
	rlRun "ADuser_passwd_ldif $aduser ads $userpw" 0 "Generate ldif file for setting passwd for $aduser"
	rlRun "ADuser_cntrl_ldif $aduser ads 512" 0 "Generate ldif file to enable user $aduser"
	rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser.ldif" 0 "Adding new user in AD $aduser"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting $aduser passwd"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling $aduser"

	rlRun "ADuser_ldif 456 ads 456 add" 0 "Generate ldif file to add user 456"
	rlRun "ADuser_passwd_ldif 456 ads $userpw" 0 "Generate ldif file for setting passwd for 456"
	rlRun "ADuser_cntrl_ldif 456 ads 512" 0 "Generate ldif file to enable user 456"
	rlRun "telephoneNumber_ldif 456 ads $phn_2" 0 "Generate ldif file to add phone number of user 456"
	rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser.ldif" 0 "Adding new user in AD "456""
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting 456 passwd"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling user 456"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f telephoneNumber.ldif" 0 "Add phone number of user 456"
	rlRun "sleep $sec" 0 "Sleeping $sec sec for sync"

	# Verify Users have synced to IPA Server
	rlRun "ipa user-find $aduser" 0 "$aduser is synced to IPA"

	# Check if the users details merge as per AD user settings
	rlRun "ipa user-find 456" 0 "456 is synced to IPA"
	rlRun "ipa user-find 456 | grep -q $phn_2" 0 "AD user overwrites on a IPA existing user"

rlPhaseEnd
}


winsync_test_0004() {

rlPhaseStartTest "winsync_test_0004: User added in IPA is not replicated on AD"
	rlRun "create_ipauser $firstname $surname $firstname $userpw"
	sleep 5
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ipa user-show $firstname"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -b \"cn=$firstname $surname,cn=users,dc=adrelm,dc=com\"" 32 "IPA user does not sync to AD as expected"

	# Test case cleanup
	rlRun "ipa user-del $firstname"
rlPhaseEnd
}


winsync_test_0005() {

rlPhaseStartTest "winsync_test_0005: Synchronization behaviour of account lock status"
	rlRun "acctdisable_ldif both" 0 "Creating ldif file to set ipawinsyncacctdisable to both"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w Secret123 -f acctdisable.ldif" 0 "Setting disabled account to sync to both AD and IPA server"
	# To disable account set userAccountControl to 514
	rlRun "ADuser_cntrl_ldif $aduser ads 514"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "$aduser disable on AD"
	rlRun "sleep $sec" 0 "Waiting for sync"
	rlRun "ipa user-find $aduser | grep \"Account disabled: True\"" 0 "User disabled on IPA as well"
	rlRun "ipa user-enable $aduser"

	rlRun "acctdisable_ldif none" 0 "Creating ldif file to set ipawinsyncacctdisable to none"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w Secret123 -f acctdisable.ldif" 0 "Setting disabled account to not sync to IPA"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "$aduser disable on AD"
	rlRun "sleep $sec" 0 "Waiting for sync"
        rlRun "ipa user-find $aduser | grep \"Account disabled: False\"" 0 "User is enabled on IPA"
	
	rlRun "acctdisable_ldif both" 0 "Creating ldif file to reset ipawinsyncacctdisable to both"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w Secret123 -f acctdisable.ldif" 0 "Resetting disabled account to sync to both servers"
rlPhaseEnd
}

winsync_test_0006() {

rlPhaseStartTest "winsync_test_0006: winsync doesn't sync the employeeType attribute - Bug 765986"
	rlRun "employeetype_ldif add" 0 "Set employeetype attribute"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w Secret123 -f employeetype.ldif"
	rlRun "ADuser_ldif $aduser2 ads $aduser2 add" 0 "Generate ldif file to add user $aduser2"
        rlRun "ADuser_passwd_ldif $aduser2 ads $userpw" 0 "Generate ldif file for setting passwd for $aduser2"
        rlRun "ADuser_cntrl_ldif $aduser2 ads 512" 0 "Generate ldif file to enable user $aduser2"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser.ldif" 0 "Adding new user in AD $aduser2"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting $aduser2 passwd"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling $aduser2"
	sleep 30
	rlRun "ipa user-find $aduser2 --all | grep \"employeetype: unknown\"" 0 "employeetype attribute set to unknown"
	rlRun "AD_employeetype_ldif $aduser2 ads staff"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f AD_employeetype.ldif"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -b \"CN=$aduser2 ads,CN=Users,DC=adrelm,DC=com\" | grep \"employeeType: staff\"" 0 "Set employeetype to staff in AD for $aduser2"
	sleep 30
	rlRun "ipa user-find $aduser2 --all | grep \"employeetype: staff\"" 1 "winsync doesn't sync the employeeType attribute as expected"

	# Test Cleanup
	rlRun "employeetype_ldif delete" 0 "Unset employeetype attribute"
        rlRun "ldapmodify -x -D \"$DS_binddn\" -w Secret123 -f employeetype.ldif"
rlPhaseEnd
}

winsync_test_0007() {

rlPhaseStartTest "winsync_test_0007: ipa-replica-manage list"
	rlRun "ipa-replica-manage list | grep winsync" 0 "Listing winsync in Replica agreement"
	rlRun "ipa-replica-manage list | grep master" 0 "Listing master in Replica agreement"
rlPhaseEnd
}

winsync_test_0008() {

rlPhaseStartTest "winsync_test_0008: Modify user attributes after replication setup"
	rlLog "Modify user attributes for user existing before winsync"
	rlRun "telephoneNumber_ldif $ADfn $ADsn 888-999-111"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f telephoneNumber.ldif" 0 "Modifying telephone number for $ADln"
	rlRun "sleep 30" 0 "Waiting for sync"
	rlRun "ipa user-find $ADln | grep \"Telephone Number: 888-999-111\"" 0 "Attribute modify for user existing before winsync"

	rlLog "Modify user attributes for user created after winsync"
	rlRun "telephoneNumber_ldif $aduser ads 001788788001"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f telephoneNumber.ldif" 0 "Adding telephone number for $aduser"
	rlRun "sleep 30" 0 "Waiting for sync"
	rlRun "ipa user-find $aduser | grep \"Telephone Number: 001788788001\"" 0 "Attribute modify for user created after winsync"
rlPhaseEnd
}

winsync_test_0009() {

rlPhaseStartTest "winsync_test_0009: Update Password"
	rlLog "Update password in AD"
	rlRun "ADuser_passwd_ldif $aduser ads $userpw2"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_passwd.ldif" 0 "Reset $aduser passwd from AD"
	rlLog "$aduser login in IPA server with new password"
	rlRun "ssh_auth_success $aduser $userpw2 $IPAhost"

	rlLog "Update password in IPA"
	rlRun "echo $userpw2 | ipa passwd $aduser2" 0 "Reset $aduser2 passwd from IPA"

	rlLog "$aduser2 login with in AD with new password"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"cn=$aduser2 ads,cn=users,dc=adrelm,dc=com\" -w $userpw2 -b \"cn=$aduser2 ads,cn=users,dc=adrelm,dc=com\" | grep \"sAMAccountName: $aduser2\"" 0 "Verifying connection via TLS to AD server as user $aduser2"

rlPhaseEnd
}

winsync_test_0010() {

rlPhaseStartTest "winsync_test_0010: \"ipausers\" group is a non-posix group (without gid number)"
	rlLog "Synced users must have a GID which is that same as thier UID. This GID is a UPG GID"
	x=`ipa user-show $aduser | grep UID | awk '{print $NF}'`
	y=`ipa user-show $aduser | grep GID | awk '{print $NF}'`
	z=`ipa user-show $aduser2 | grep UID | awk '{print $NF}'`
	t=`ipa user-show $aduser2 | grep GID | awk '{print $NF}'`
	rlRun "[ $x -eq $y ]" 0 "$aduser UID, GID is the same"
	rlRun "[ $z -eq $t ]" 0 "$aduser2 UID, GID is the same"

	rlLog "UPG Definition should be enabled by default"
	rlRun "ipa-managed-entries -e \"UPG Definition\" status | grep Enabled" 0 "UPG Definition is enabled by default"

	rlLog "\"ipausers\" group should not have a GID as it's a non-posix group"
	rlRun "ipa group-find ipausers | grep GID" 1 "\"ipausers\" does not have GID as expected"

rlPhaseEnd
}

winsync_test_0011() {

rlPhaseStartTest "winsync_test_0011: sync uidNumber from AD - Bug 755436"
	rlLog "https://bugzilla.redhat.com/show_bug.cgi?id=755436"
	rlRun "uidNumber_ldif $aduser ads $new_UID"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f uidNumber.ldif" 0 "Setting UID for $aduser"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -b \"CN=$aduser ads,CN=Users,DC=adrelm,DC=com\" | grep \"uidNumber: $new_UID\"" 0 "Verifying UID is set for $aduser"
	rlRun "sleep $sec" 0 "Waiting for Sync"
	x=`ipa user-show $aduser | grep "UID" | awk '{print $NF}'`
	rlRun "ipa user-show $aduser | grep \"UID\"" 0 "UID after sync"
	if [ $x -eq $new_UID ]; then
	 rlPass "UID from AD synced to IPA"
	else
	 rlPass "Sync of UID from AD failed as expected - Bug 755436"
	fi

rlPhaseEnd
}

winsync_test_0012() {

rlPhaseStartTest "winsync_test_0012: Delete User"
	rlLog "Delete user from AD"
	rlRun "deleteuser_ldif $aduser ads"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f deleteuser.ldif" 0 "Delete $aduser from AD"
	rlRun "sleep $sec" 0 "Waiting for sync"
	rlRun "ipa user-show $aduser" 2 "User not found in IPA as expected"

	rlLog "Delete user from IPA"
	rlRun "ipa user-del $aduser2" 0 "Delete $aduser2 from IPA"
	rlRun "ipa user-del 456" 0 "Delete user 456 from IPA"
	sleep 10
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -b \"CN=$aduser2 ads,CN=Users,DC=adrelm,DC=com\"" 32 "Sync with AD is immediate. User $aduser2 not found in AD as expected"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -b \"CN=456 ads,CN=Users,DC=adrelm,DC=com\"" 32 "Sync with AD is immediate. User 456not found in AD as expected"

rlPhaseEnd
}

winsync_test_0013() {

rlPhaseStartTest "winsync_test_0013: Error adding the agreement over existing agreement"
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=ADcert.cer $ADhost --binddn \"$AD_binddn\" --bindpw Secret123 -v -p Secret123" 1 "Error on attempting to add agreement over existing agreement"

rlPhaseEnd
}

winsync_test_0014() {

rlPhaseStartTest "winsync_test_0014: Using options force-sync, re-initialize, disconnect and del"
	
	rlRun "syncinterval_ldif 300 replace"
        rlRun "ldapmodify -x -D \"$DS_binddn\" -w Secret123 -f syncinterval.ldif" 0 "Change winsync interval back to 5 mins"
	rlRun "service dirsrv restart" 0 "Restarting to make winsync interval change effective"
	sleep 10

	rlRun "ADuser_ldif $aduser ads $aduser add" 0 "Generate ldif file to add user $aduser"
        rlRun "ADuser_passwd_ldif $aduser ads $userpw" 0 "Generate ldif file for setting passwd for $aduser"
        rlRun "ADuser_cntrl_ldif $aduser ads 512" 0 "Generate ldif file to enable user $aduser"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser.ldif" 0 "Adding $aduser in AD to test options"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting $aduser passwd"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling $aduser"

	rlRun "ipa-replica-manage force-sync --from $ADhost" 0 "Using force-sync option"
	rlRun "ipa user-show $aduser" 0 "$aduser added in AD, synced to IPA using force-sync option"

	sleep 15
	rlRun "ADuser_ldif $aduser2 ads $aduser2 add" 0 "Generate ldif file to add user $aduser2"
        rlRun "ADuser_passwd_ldif $aduser2 ads $userpw" 0 "Generate ldif file for setting passwd for $aduser2"
        rlRun "ADuser_cntrl_ldif $aduser2 ads 512" 0 "Generate ldif file to enable user $aduser2"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser.ldif" 0 "Adding $aduser2 in AD to test options"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting $aduser2 passwd"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling $aduser2"
	sleep 20

	rlRun "ipa-replica-manage re-initialize --from $ADhost" 0 "Using re-initialize option"
	rlRun "ipa user-show $aduser2" 0 "$aduser2 added in AD, synced to IPA with reinitialize option"

	sleep 5
	rlRun "ipa-replica-manage disconnect $ADhost" 0 "Disconnecting replica agreement"
	sleep 15
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=ADcert.cer $ADhost --binddn \"$AD_binddn\" --bindpw Secret123 -v -p Secret123" 0 "Re-connecting for next test"

	sleep 15	
	rlRun "ipa-replica-manage del $ADhost" 0 "Deleting agreement"
	#rlRun "service dirsrv restart" 0 "Restarting dirsrv to clear old cached principals"
	
rlPhaseEnd
}

winsync_test_0015() {

rlPhaseStartTest "winsync_test_0015: Winsync with --win-subtree"
	rlRun "addOU_ldif $OU1 add"
	rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f addOU.ldif" 0 "Adding OU $OU1"
	rlRun "addsubOU_ldif $sub_OU1 $OU1 add"
	rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f addsubOU.ldif" 0 "Adding sub OU $sub_OU1"
	
	rlRun "addOU_ldif $OU2 add"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f addOU.ldif" 0 "Adding OU $OU2"
        rlRun "addsubOU_ldif $sub_OU2 $OU2 add"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f addsubOU.ldif" 0 "Adding sub OU $sub_OU2"

	rlRun "ADuser_ldif $l1user ads $l1user add $OU1" 0 "Generate ldif file to add user $l1user"
        rlRun "ADuser_passwd_ldif $l1user ads $userpw $OU1" 0 "Generate ldif file for setting passwd for $l1user"
        rlRun "ADuser_cntrl_ldif $l1user ads 512 $OU1" 0 "Generate ldif file to enable user $l1user"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser.ldif" 0 "Adding $l1user in OU $OU1"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting $l1user passwd"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling $l1user"

	rlRun "ADuser_ldif $sub1user ads $sub1user add $OU1 $sub_OU1" 0 "Generate ldif file to add user $sub1user"
        rlRun "ADuser_passwd_ldif $sub1user ads $userpw $OU1 $sub_OU1" 0 "Generate ldif file for setting passwd for $sub1user"
        rlRun "ADuser_cntrl_ldif $sub1user ads 512 $OU1 $sub_OU1" 0 "Generate ldif file to enable user $sub1user"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser.ldif" 0 "Adding $sub1user in OU $OU1"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting $sub1user passwd"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling $sub1user"

	rlLog "Winsync with OU with existing users"
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=ADcert.cer $ADhost --binddn \"$AD_binddn\" --bindpw Secret123 -v -p Secret123 --win-subtree=\"OU=$OU1,DC=adrelm,DC=com\"" 0 "Creating winsync agreement with OU $OU1 win-subtree"
	sleep 10

	 # Restart PassSync after winsync agreement is established
        net rpc service stop PassSync -I $ADhost -U administrator%$ADpasswd
        net rpc service stop PassSync -I $ADhost -U administrator%$ADpasswd
        rlRun "net rpc service start PassSync -I $ADhost -U administrator%$ADpasswd" 0 "Restarting PassSync Service"
	sleep 10

	rlRun "ipa user-show $l1user | grep \"Account disabled: False\"" 0 "$l1user from OU $OU1 synced and enabled in IPA"
        rlRun "ipa user-show $l1user | grep \"Password: True\"" 0 "Password in sync for $l1user of OU $OU1"
        rlRun "ipa user-show $sub1user| grep \"Account disabled: False\"" 0 "$sub1user from sub OU $sub_OU1 synced and enabled in IPA"
        rlRun "ipa user-show $sub1user | grep \"Password: True\"" 0 "Password in sync for $sub1user of sub OU $sub_OU1"

	rlRun "ipa-replica-manage del $ADhost" 0 "Deleting agreement with OU $OU1"
	sleep 20

	rlLog "Winsync with OU without existing users"
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=ADcert.cer $ADhost --binddn \"$AD_binddn\" --bindpw Secret123 -v -p Secret123 --win-subtree=\"OU=$OU2,DC=adrelm,DC=com\"" 0 "Creating winsync agreement with OU $OU2 win-subtree"
	sleep 10

	 # Restart PassSync after winsync agreement is established
        net rpc service stop PassSync -I $ADhost -U administrator%$ADpasswd
        net rpc service stop PassSync -I $ADhost -U administrator%$ADpasswd
        rlRun "net rpc service start PassSync -I $ADhost -U administrator%$ADpasswd" 0 "Restarting PassSync Service"
	sleep 10

	rlRun "syncinterval_ldif $sec replace"
        rlRun "ldapmodify -x -D \"$DS_binddn\" -w Secret123 -f syncinterval.ldif" 0 "Change winsync interval back to $sec sec"
        rlRun "service dirsrv restart" 0 "Restarting to make winsync interval change effective"
	sleep 10

	rlRun "ADuser_ldif $l2user ads $l2user add $OU2" 0 "Generate ldif file to add user $l2user"
        rlRun "ADuser_passwd_ldif $l2user ads $userpw $OU2" 0 "Generate ldif file for setting passwd for $l2user"
        rlRun "ADuser_cntrl_ldif $l2user ads 512 $OU2" 0 "Generate ldif file to enable user $l2user"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser.ldif" 0 "Adding $l2user in OU $OU2"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting $l2user passwd"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling $l2user"

        rlRun "ADuser_ldif $sub2user ads $sub2user add $OU2 $sub_OU2" 0 "Generate ldif file to add user $sub2user"
        rlRun "ADuser_passwd_ldif $sub2user ads $userpw $OU2 $sub_OU2" 0 "Generate ldif file for setting passwd for $sub2user"
        rlRun "ADuser_cntrl_ldif $sub2user ads 512 $OU2 $sub_OU2" 0 "Generate ldif file to enable user $sub2user"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser.ldif" 0 "Adding $sub2user in OU $OU2"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting $sub2user passwd"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling $sub2user"
	rlRun "sleep $sec" 0 "Waiting for sync"
	
	rlRun "ipa user-show $l2user | grep \"Account disabled: False\"" 0 "$l2user from OU $OU2 synced and enabled in IPA"
	rlRun "ipa user-show $l2user | grep \"Password: True\"" 0 "Password in sync for $l2user of OU $OU2"
        rlRun "ipa user-show $sub2user| grep \"Account disabled: False\"" 0 "$sub2user from sub OU $sub_OU2 synced and enabled in IPA"
	rlRun "ipa user-show $sub2user | grep \"Password: True\"" 0 "Password in sync for $sub2user of sub OU $sub_OU2"

rlPhaseEnd
}

cleanup() {

rlPhaseStartTest "Clean up for winsync sanity tests"

	rlRun "kinitAs $ADMINID $ADMINPW" 0
	sleep 5
	rlRun "ipa-replica-manage del $ADhost"
	rlrun "ipa user-del $l1user $l2user $sub1user $sub2user $aduser $aduser2"
	rlRun "addsubOU_ldif $sub_OU1 delete"
	rlRun "addsubOU_ldif $sub_OU2 delete"
	rlRun "addOU_ldif $OU1 delete"
	rlRun "addOU_ldif $OU2 delete"
	rlRun "certutil -D -n \"AD cert\" -d /etc/dirsrv/slapd-TESTRELM-COM"
	rlRun "rm -f /etc/named.conf && cp -p /etc/named.conf.winsync /etc/named.conf" 0 "Replacing named.conf file from backup"
	rlRun "service named restart"
	rlRun "rm -f *.ldif"
	rlRun "sed -i \"/^TLS_CACERTDIR.*/d\" /etc/openldap/ldap.conf"
	rlRun "rm -fr /tmp/krb5cc_1*"
	rlRun "kdestroy" 0 "Destroying admin credentials."

rlPhaseEnd
}
