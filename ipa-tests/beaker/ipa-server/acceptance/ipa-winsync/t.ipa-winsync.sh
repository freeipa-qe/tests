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
userpw3="Enc3ypt39"

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
PACKAGE3="samba-common"
PACKAGE4="expect"

sec="30"
DMpswd="Secret123"
ADfn="Frank"
ADsn="Slade"
ADln="frank"
ADcrt="ADcert.cer"
invldcrt="invalidAD.cer"
slfcrt="Self-Signed-CA Certificate"
slfcer="slfcrt.cer"
aduser="aduser1"
aduser2="aduser2"
ADUser3="First.Last"
aduser3="first.last"
l1user="l1user"
l2user="l2user"
sub1user="sub1user"
sub2user="sub2user"
phn_1="22334455"
phn_2="66778899"
phn_3="888-999-111"
phn_4="001788788001"
new_UID="88228822"
OU1="level1"
sub_OU1="sub-level1"
OU2="level2"
sub_OU2="sub-level2"
IPAhost="`hostname`"
IPAhostIP="`host $IPAhost | awk '{print $NF}'`"
IPAlog="IPAcert_install.log"
#aduser_ln="ads"
slapd_dir="/etc/dirsrv/slapd-TESTRELM-COM"
ldap_conf="/etc/openldap/ldap.conf"
crt_file="/etc/ipa/ca.crt"
ipacrt="IPAcrt.cer"
named_conf="/etc/named.conf"
named_conf_bkp="/etc/named.conf.winsync"
error_log="/var/log/dirsrv/slapd-TESTRELM-COM/errors"
AD_binddn="CN=Administrator,CN=Users,$ADdc"
DS_binddn="CN=Directory Manager"
SyncPlugin="cn=ipa-winsync,cn=plugins,cn=config"
ipa="/usr/bin/ipa"
aduser_mail="$aduser@testrelm.com"

setup() {
rlPhaseStartSetup "ipa-winsync-startup - Check for admintools package, setup certificates."
	# check for packages
pushd .
	for item in $PACKAGE1 $PACKAGE2 $PACKAGE3 $PACKAGE4; do
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
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "$ipa user-mod 456 --phone $phn_1" 0 "Adding telephone number of user 456"

	# Adding conditional forwarder
	rlRun "cp -p $named_conf $named_conf_bkp" 0 "Backup $named_conf before adding conditional forwarder for AD"
	echo -e "\nzone \"$ADdomain\" IN {\n\ttype forward;\n\tforwarders { $ADip; };\n\tforward only;\n};" >> $named_conf
	rlServiceStop "named"
	rlServiceStart "named"
	sleep 30
	rlRun "host $ADhost"

	# Removing IPA cert from AD
	# Passing $ADip instead of $ADhost as I faced issue in F17
	rlLog "Cleanup AD before PassSync Install"
	./IPAcert_install.exp delete $ADadmin $ADpswd $ADip $msifile > /dev/null 2>&1
	sleep 10

	# Uploading the IPA certificate in AD and importing it for passync
	rm -f $ipacrt
	rlRun "cp $crt_file $ipacrt"
	rlRun "ping -c 4 $ADhost" 0 "AD Server is reachable from IPA Server"
	rlRun "./IPAcert_install.exp add $ADadmin $ADpswd $ADip $msifile $IPAhost $ipacrt $IPAhostIP > /dev/null 2>&1" 0 "Installing PassSync, forwarder and IPA cert in AD"
	rlLog "AD server is being rebooted. Waiting 5 mins"
	sleep 300
	while true; do
	  ping -c 1 $ADhost
	  [ $? -eq 0 ] && break
	done
	ping -c 4 $ADhost && rlPass "AD server has rebooted"
	sleep 180
	net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd | grep \"passsync.exe\"
	sleep 5
	net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd | grep \"passsync.exe\"
	rlRun "net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd | grep \"passsync.exe\"" 0 "PassSync Service installed successfully"
rlPhaseEnd
}

winsync_test_0001() {

rlPhaseStartTest "0001 Creating winsync agreement"
	# Specifying TLS_CACERTDIR
	grep -q "TLS_CACERTDIR" $ldap_conf
	if [ $? -eq 0 ]; then
	  sed -i "s/.*TLS_CACERTDIR.*/TLS_CACERTDIR \/etc\/dirsrv\/slapd\-TESTRELM\-COM/" $ldap_conf
	else
	  echo "TLS_CACERTDIR $slapd_dir" >> $ldap_conf
	fi
	
	# Provide a self signed cert to --cacert option
	rlLog "Provide a self signed cert to --cacert option"
	rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
	rlRun "pushd $TmpDir"
	rlRun "echo \"Password\" > passwd_certdb"
	rlRun "echo \"7hdkujendbvcgfterwvsvzgavqal,,5372891900120o,sfasda21cma,da,anvavadadfaw\" > noise_certdb"
	rlRun "certutil -d $TmpDir -N -f passwd_certdb"
	rlRun "certutil -S -n \"$slfcrt\" -s \"cn=Self-Signed-CAcer\" -x -t \"CT,,C\" -m 1000 -v 120 -d $TmpDir -f passwd_certdb -z noise_certdb"
	rlRun "certutil -d $TmpDir -L -n \"$slfcrt\" -a > $slfcer"
	rlRun "certutil -d $slapd_dir -A -n \"$slfcrt\" -i \"$slfcer\" -t \"CT,,C\" -a"
	rlRun "certutil -L -d $slapd_dir | grep \"$slfcrt\"" 0 "Verifying $slfcrt is imported in db"
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=$slfcer $ADhost --binddn \"$AD_binddn\" --bindpw $ADpswd -v -p $DMpswd" 1 "Winsync Agreement with $slfcrt failed as expected"
	rlRun "certutil -d $slapd_dir -D -n \"$slfcrt\""

	# Tidy up
	rlRun "rm -f *db $slfcer"
	rlRun "popd"

	# Attempting creating the Agreement with invalid cert
	rlLog "Attempting creating the Agreement with invalid cert"
	rlRun "certutil -A -i $invldcrt -d $slapd_dir -n \"Invalid cert\" -t \"CT,,C\" -a"
	rlRun "certutil -L -d $slapd_dir | grep \"Invalid cert\"" 0 "Verifying Invalid AD cert is imported in db"
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=$invldcrt $ADhost --binddn \"$AD_binddn\" --bindpw $ADpswd -v -p $DMpswd" 1 "Winsync Agreement with invalid cert failed as expected"
	rlRun "certutil -d $slapd_dir -D -n \"Invalid cert\""

	# Using valid AD cert
	rlRun "certutil -A -i $ADcrt -d $slapd_dir -n \"AD cert\" -t \"CT,C,C\" -a"
	rlRun "certutil -L -d $slapd_dir | grep \"AD cert\"" 0 "Verifying AD cert is imported in db"

	# Verify you can connect via TLS to ADS server
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"$AD_binddn\"" 0 "Verifying connection via TLS to ADS server"

	# Adding a user before winsync agreement
	rlRun "ADuser_ldif $ADfn $ADsn $ADln $userpw 512 add" 0 "Generate ldif file to add $ADln"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user in AD before winsync $ADln"
	rlRun "telephoneNumber_ldif $ADfn $ADsn $phn_4"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f telephoneNumber.ldif" 0 "Adding telephone number for $ADln"

	# Creating the Agreement
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=$ADcrt $ADhost --binddn \"$AD_binddn\" --bindpw $ADpswd -v -p $DMpswd" 0 "Creating Winsync Agreement with valid cert"

	# Restart PassSync after winsync agreement is established
	rlRun "ping -c 4 $ADip" 0 "AD server reachable"
	net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd | grep \"passsync.exe\"
	sleep 5
	net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd | grep \"passsync.exe\"
	rlRun "net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd" 0 "PassSync status on AD"
	rlRun "PassSync_Restart $ADip $ADadmin $ADpswd" 0 "Restarting PassSync Service"

rlPhaseEnd
}

winsync_test_0002() {

rlPhaseStartTest "0002 bz820258 - Modify Winsync Interval (default 300 seconds)"
	rlRun "errorlog_ldif 8192"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f errorlog.ldif" 0 "Setting the error log level"
	rlRun "sleep 540" 0 "Waiting for winsync interval to log in logfile"
	rlRun "syncinterval_ldif $sec add"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f syncinterval.ldif" 0 "Change winsync interval to $sec seconds"
	rlRun "sleep $sec" 0 "Waiting for new interval logs"
	rlRun "sleep 30"
	x=`grep "Running Dirsync" $error_log | tail -n2 | head -1| awk -F: '{print $3}'`
	y=`grep "Running Dirsync" $error_log | tail -n1 | awk -F: '{print $3}'`
	if [ $x -gt $y ]; then
	 $y=`expr $y + 60`
	fi
	rlRun "z=`expr $y - $x | awk -F- '{print $NF}'`"
	if [ $z -ge 5 ]; then
	 rlRun "echo \"SyncInterval is unchanged: $z mins\"" 0 "bz820258: Winsync interval change to $sec sec failed as expected"
	 rlLog "https://bugzilla.redhat.com/show_bug.cgi?id=820258"
	 #rlRun "service dirsrv restart" 0 "Restarting dirsrv for winsync interval change to take effect"
	 rlRun "rlDistroDiff dirsrv_svc_restart" 0 "Restarting dirsrv for winsync interval change to take effect"
	 rlRun "sleep 120" 0 "Waiting for new interval logs"
	 sleep $sec
	fi
	 x=`grep "Running Dirsync" $error_log | tail -n2 | head -1| awk -F: '{print $4}' | awk '{print $1}'`
	 y=`grep "Running Dirsync" $error_log | tail -n1 | head -1| awk -F: '{print $4}' | awk '{print $1}'`
	 rlRun "z=`expr $y - $x | awk -F- '{print $NF}'`"
	 if [ $z -le 35 ]; then
	  rlRun "echo \"Winsync Interval successfully modified to $sec Seconds\""
	 else
	  rlFail "Winsync interval change to $sec seconds did not take effect"
	 fi

rlPhaseEnd
}


winsync_test_0003() {

rlPhaseStartTest "0003 Create users(numeric/alphanumeric) in AD and verify it is synced to IPA and overwrites existing IPA users"

	# Creating user in AD
	rlRun "ADuser_ldif $aduser ads $aduser $userpw 512 add" 0 "Generate ldif file to add user $aduser"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user in AD $aduser"
	sleep 15

	rlRun "ADuser_ldif 456 ads 456 $userpw 512 add" 0 "Generate ldif file to add user 456"
	rlRun "telephoneNumber_ldif 456 ads $phn_2" 0 "Generate ldif file to add phone number of user 456"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user in AD "456""
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f telephoneNumber.ldif" 0 "Add phone number of user 456"
	rlRun "sleep $sec" 0 "Sleeping $sec sec for sync"
	sleep 90

	# Verify Users have synced to IPA Server
	rlRun "$ipa user-show $aduser" 0 "$aduser is synced to IPA"
	rlRun "$ipa user-show $aduser | grep \"Account disabled: False\"" 0 "$aduser sycned and enabled on IPA"

	# Check if the users details merge as per AD user settings
	rlRun "$ipa user-show 456" 0 "456 is synced to IPA"
	rlRun "$ipa user-show 456 | grep -q $phn_2" 0 "AD user overwrites on a IPA existing user"

rlPhaseEnd
}

winsync_test_0004() {

rlPhaseStartTest "0004 bz824490 - Modify password for winsync users with mix case"
	# Creating user in AD with mix case
        rlRun "ADuser_ldif First Last $ADUser3 $userpw 512 add" 0 "Generate ldif file to add user $ADUser3"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user in AD $ADUser3"
        sleep 90
	# Verify Users have synced to IPA Server
        rlRun "$ipa user-show $ADUser3" 0 "$ADUser3 is synced to IPA"
	rlRun "$ipa user-show $ADUser3 | grep \"Password: True\"" 0 "Password in sync for $ADUser3"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "echo $userpw2 | ipa passwd $ADUser3" 0 "Reset $ADUser3 passwd from IPA"
        sleep $sec
        FirstKinitAs $aduser3 $userpw2 $userpw3
        sleep $sec
        /usr/bin/kdestroy 2>&1 >/dev/null
	rlRun "ssh_auth_success $aduser3 $userpw3 $IPAhost"

	# Test case cleanup
        rlRun "$ipa user-del $aduser3" 0 "Deleting $ADUser3"
	
rlPhaseEnd
}

winsync_test_0005() {

rlPhaseStartTest "0005 User added in IPA is not replicated on AD"
	rlRun "create_ipauser $firstname $surname $firstname $userpw"
	sleep 5
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "$ipa user-show $firstname"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$firstname $surname,CN=users,$ADdc\"" 32 "IPA user does not sync to AD as expected"

	# Test case cleanup
	rlRun "$ipa user-del $firstname"
rlPhaseEnd
}


winsync_test_0006() {

rlPhaseStartTest "0006 Synchronization behaviour of account lock status"
	
syncaccntdefault() {  
	rlLog "Testing with Winsync account disable set to\"both\""
	rlRun "acctdisable_ldif both" 0 "Creating ldif file to reset ipawinsyncacctdisable to \"both\""
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f acctdisable.ldif" 0 "Setting disabled account to sync to both servers"
        rlRun "$ipa user-show $aduser | grep \"Account disabled: False\"" 0 "$aduser is enabled on IPA"

	# To disable account set userAccountControl to 514
	rlRun "ADuser_cntrl_ldif $aduser ads 514" 0 "Creating ldif file for disabling $aduser"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser_cntrl.ldif" 0 "Disable $aduser on AD"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$aduser ads,CN=Users,$ADdc\" | grep \"userAccountControl: 514\"" 0 "$aduser disabled in AD"
	rlRun "sleep 30" 0 "Waiting for sync"
	sleep $sec
	rlRun "$ipa user-show $aduser | grep \"Account disabled: True\"" 0 "After sync $aduser disabled on IPA as well"
	rlRun "$ipa user-enable $aduser"
	rlRun "$ipa user-show $aduser | grep \"Account disabled: False\"" 0 "Re-enabled $aduser from IPA"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$aduser ads,CN=Users,$ADdc\" | grep \"userAccountControl: 512\"" 0 "$aduser is enabled in AD as well"
	sleep 10
}

syncaccntnone() {
	rlLog "Testing with Winsync account disable set to \"none\""
	rlRun "acctdisable_ldif none" 0 "Creating ldif file to set ipawinsyncacctdisable to none"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f acctdisable.ldif" 0 "Setting disabled account to not sync to IPA"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser_cntrl.ldif" 0 "Disable $aduser on AD"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$aduser ads,CN=Users,$ADdc\" | grep \"userAccountControl: 514\"" 0 "$aduser disabled in AD"
	rlRun "sleep 15" 0 "Waiting for sync"
	sleep $sec
        rlRun "$ipa user-show $aduser | grep \"Account disabled: False\"" 0 "$aduser is not disabled on IPA. As expected"
}

syncaccntboth() {
	rlLog "Testing reverting change for ipawinsyncacctdisable does not trigger a rescan of AD"
	rlRun "acctdisable_ldif both" 0 "Creating ldif file to reset ipawinsyncacctdisable to \"both\""
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f acctdisable.ldif" 0 "Resetting disabled account to sync to both servers"
        rlRun "sleep 15" 0 "Waiting for sync"
        sleep $sec
        rlRun "$ipa user-show $aduser | grep \"Account disabled: False\"" 0 "$aduser is still enabled on IPA after account lock status change to both. As expected"

	# Re-enable user on AD	
	rlRun "ADuser_cntrl_ldif $aduser ads 512"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser_cntrl.ldif" 0 "Re-enable $aduser on AD"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$aduser ads,CN=Users,$ADdc\" | grep \"userAccountControl: 512\"" 0 "$aduser re-enabled in AD"
	rlRun "sleep 5" 0 "Waiting for sync"
	sleep $sec
	rlRun "$ipa user-show $aduser | grep \"Account disabled: False\"" 0 "$aduser is enabled in IPA"
	sleep 10
}
	
	ldapsearch -x -h $IPAhost -D "$DS_binddn" -w $DMpswd -b "$SyncPlugin" | grep -q "ipawinsyncacctdisable: both"
	if [ $? -eq 0 ]; then
	  rlPass "Winsync account disable set to \"both\" by default"
	  syncaccntdefault
	  syncaccntnone
	  syncaccntboth
	else
	  rlFail "Winsync account disable not set to \"both\" by default"
	  syncaccntdefault
	  syncaccntnone
	  syncaccntboth
	fi
rlPhaseEnd
}

winsync_test_0007() {

rlPhaseStartTest "0007 bz765986 - winsync doesn't sync the employeeType attribute"
	rlRun "employeetype_ldif add" 0 "Set employeetype attribute"
	rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f employeetype.ldif"
	rlRun "ADuser_ldif $aduser2 ads $aduser2 $userpw 512 add" 0 "Generate ldif file to add user $aduser2"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user in AD $aduser2"
	sleep 60
	rlRun "$ipa user-show $aduser2 | grep \"Account disabled: False\"" 0 "$aduser2 synced and enabled on IPA"
	rlRun "$ipa user-show $aduser2 --all | grep -i \"employeeType: unknown\"" 0 "employeetype attribute set to unknown in IPA"
	rlRun "AD_employeetype_ldif $aduser2 ads staff"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f AD_employeetype.ldif"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$aduser2 ads,CN=Users,$ADdc\" | grep \"employeeType: staff\"" 0 "Set employeetype to staff in AD for $aduser2"
	sleep 30
	rlRun "$ipa user-find $aduser2 --all | grep \"employeetype: staff\"" 1 "winsync doesn't sync the employeeType attribute as expected"

	# Test Cleanup
	rlRun "employeetype_ldif delete" 0 "Create ldif to unset employeetype attribute"
        rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f employeetype.ldif" 0 "Unsetting employeetype attribute"
rlPhaseEnd
}

winsync_test_0008() {

rlPhaseStartTest "0008 ipa-replica-manage list"
	rlRun "ipa-replica-manage list | grep winsync" 0 "Listing winsync in Replica agreement"
	rlRun "ipa-replica-manage list | grep master" 0 "Listing master in Replica agreement"
rlPhaseEnd
}

winsync_test_0009() {

rlPhaseStartTest "0009 Modify user attributes after replication setup"
	rlLog "Modify user attributes for user existing before winsync"
	rlRun "telephoneNumber_ldif $ADfn $ADsn $phn_3"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f telephoneNumber.ldif" 0 "Modifying telephone number for $ADln"
	rlRun "sleep 30" 0 "Waiting for sync"
	sleep $sec
	rlRun "$ipa user-show $ADln | grep \"Telephone Number: $phn_3\"" 0 "Attribute modify for user existing before winsync"

	rlLog "Modify user attributes for user created after winsync"
	rlRun "telephoneNumber_ldif $aduser ads $phn_4"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f telephoneNumber.ldif" 0 "Adding telephone number for $aduser"
	rlRun "sleep 30" 0 "Waiting for sync"
	sleep $sec
	rlRun "$ipa user-show $aduser | grep \"Telephone Number: $phn_4\"" 0 "Attribute modify for user created after winsync"
rlPhaseEnd
}

winsync_test_0010() {

rlPhaseStartTest "0010 Update Password"
	rlLog "Update password in AD"
	rlRun "ADuser_passwd_ldif $ADfn $ADsn $userpw2" 0 "Creating update passwd ldif file"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser_passwd.ldif" 0 "Reset $ADfn passwd from AD"
	sleep $sec
	sleep 30
	rlRun "kdestroy" 0 "Destroy any credentials"
	rlRun "ssh_auth_success $ADln $userpw2 $IPAhost"

	rlLog "Update password in IPA"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "echo $userpw2 | ipa passwd $aduser2" 0 "Reset $aduser2 passwd from IPA"
	sleep $sec
	FirstKinitAs $aduser2 $userpw2 $userpw3
	sleep $sec
	/usr/bin/kdestroy 2>&1 >/dev/null

	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"CN=$aduser2 ads,CN=users,$ADdc\" -w $userpw3 -b \"CN=$aduser2 ads,CN=users,$ADdc\" | grep -i \"sAMAccountName: $aduser2\"" 0 "Verifying new $aduser2 passwd for TLS connection to AD server"

rlPhaseEnd
}

winsync_test_0011() {

rlPhaseStartTest "0011 \"ipausers\" group is a non-posix group (without gid number)"
	rlLog "Synced users must have a GID which is that same as thier UID. This GID is a UPG GID"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	x=`$ipa user-show $aduser | grep UID | awk '{print $NF}'`
	y=`$ipa user-show $aduser | grep GID | awk '{print $NF}'`
	z=`$ipa user-show $aduser2 | grep UID | awk '{print $NF}'`
	t=`$ipa user-show $aduser2 | grep GID | awk '{print $NF}'`
	rlRun "[ $x -eq $y ]" 0 "$aduser UID, GID is the same"
	rlRun "[ $z -eq $t ]" 0 "$aduser2 UID, GID is the same"

	rlLog "UPG Definition should be enabled by default"
	rlRun "ipa-managed-entries -e \"UPG Definition\" status | grep Enabled" 0 "UPG Definition is enabled by default"

	rlLog "\"ipausers\" group should not have a GID as it's a non-posix group"
	rlRun "ipa group-find ipausers | grep GID" 1 "\"ipausers\" does not have GID as expected"

rlPhaseEnd
}

winsync_test_0012() {

rlPhaseStartTest "0012 bz755436 - sync uidNumber from AD"
	rlLog "https://bugzilla.redhat.com/show_bug.cgi?id=755436"
	rlRun "uidNumber_ldif $aduser ads $new_UID"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f uidNumber.ldif" 0 "Setting UID for $aduser"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$aduser ads,CN=Users,$ADdc\" | grep \"uidNumber: $new_UID\"" 0 "Verifying UID is set for $aduser"
	rlRun "sleep $sec" 0 "Waiting for Sync"
	x=`$ipa user-show $aduser | grep "UID" | awk '{print $NF}'`
	rlRun "$ipa user-show $aduser | grep \"UID\"" 0 "UID after sync"
	if [ $x -eq $new_UID ]; then
	 rlPass "UID from AD synced to IPA"
	else
	 rlPass "bz755436 - Sync of UID from AD failed as expected"
	fi

rlPhaseEnd
}

winsync_test_0013() {

rlPhaseStartTest "0013 Delete User"
	rlLog "Delete user from AD"
	rlRun "ADuserdel_ldif $aduser ads"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuserdel.ldif" 0 "Delete $aduser from AD"
	rlRun "sleep 30" 0 "Waiting for sync"
	sleep $sec
	rlRun "$ipa user-show $aduser" 2 "User $aduser not found in IPA as expected"

	rlLog "Delete users from IPA"
	rlRun "$ipa user-del $aduser2 $ADln 456" 0 "Delete $aduser2, $ADln and 456 from IPA"
	sleep 10
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$aduser2 ads,CN=Users,$ADdc\"" 32 "Sync with AD is immediate. User $aduser2 deleted in AD"
	sleep 5
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$ADfn $ADsn,CN=Users,$ADdc\"" 32 "Sync with AD is immediate. User $ADln deleted in AD"
	sleep 5
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=456 ads,CN=Users,$ADdc\"" 0 "456 was in IPA and then added in AD after winsync, hence is not deleted from AD as expected"
	sleep 5
	# Making sure 456 is deleted from AD
	rlRun "ADuserdel_ldif 456 ads"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuserdel.ldif" 0 "Manual deletion of user 456 from AD"
rlPhaseEnd
}

winsync_test_0014() {

rlPhaseStartTest "0014 Error adding the agreement over existing agreement"
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=$ADcrt $ADhost --binddn \"$AD_binddn\" --bindpw $ADpswd -v -p $DMpswd" 1 "Error on attempting to add agreement over existing agreement"

rlPhaseEnd
}

winsync_test_0015() {

rlPhaseStartTest "0015 winsync should not delete entry that appears to be out of scope bz818762 resolved"
	rlRun "addOU_ldif $OU1 add"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f addOU.ldif" 0 "Adding OU $OU1"

	rlRun "ADuser_ldif $aduser ads $aduser $userpw 512 add" 0 "Generate ldif file to add user $aduser"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user in AD $aduser"
	sleep 60

	rlRun "$ipa user-show $aduser" 0 "$aduser is synced to IPA"
	rlRun "telephoneNumber_ldif $aduser ads $phn_4"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f telephoneNumber.ldif" 0 "Adding telephone number for $aduser"
	sleep 40
	rlRun "$ipa user-show $aduser | grep \"Telephone Number: $phn_4\"" 0 "Change in telephone details synced to IPA"
	rlRun "$ipa user-mod $aduser --email=$aduser_mail" 0 "Adding email address for $aduser from IPA server"
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$aduser ads,CN=users,$ADdc\" mail | grep $aduser_mail" 0 "Change in email ID synced to AD"
	rlRun "moveOU_ldif $aduser ads $OU1" 0 "Create OU change ldif file"
	rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f moveOU.ldif" 0 "Move $aduser out of scope of replication agreement"
	rlRun "$ipa user-mod $aduser --phone=$phn_2" 0 "Modifying $aduser locally"
	sleep 10
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"CN=$aduser ads,OU=$OU1,$ADdc\" telephoneNumber | grep $phn_4" 0 "Phone No. modification failed to sync on AD"
	rlRun "ADuserdel_ldif $aduser ads $OU1" 0 "Create ldif file to delete $aduser"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuserdel.ldif" 0 "Delete $aduser from the OU $OU1"
	sleep 45
	rlRun "$ipa user-show $aduser" 2 "Deleting $aduser in OU $OU1 also deletes it from IPA server"

	# Test Cleanup
	rlRun "addOU_ldif $OU1 delete"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f addOU.ldif" 0 "Delete OU $OU1"

rlPhaseEnd
}

winsync_test_0016() {

rlPhaseStartTest "0016 Using options force-sync, re-initialize, disconnect and del"
	
	rlRun "syncinterval_ldif delete"
        rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f syncinterval.ldif" 0 "Change winsync interval back to 5 mins"
	#rlRun "service dirsrv restart" 0 "Restarting to make winsync interval change effective"
	rlRun "rlDistroDiff dirsrv_svc_restart" 0 "Restarting to make winsync interval change effective"
	sleep 10

	rlRun "ADuser_ldif $aduser ads $aduser $userpw 512 add" 0 "Generate ldif file to add user $aduser"
	rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user in AD $aduser"
	sleep 10

	rlRun "ipa-replica-manage force-sync --from $ADhost" 0 "Using force-sync option"
	sleep 50
	rlRun "$ipa user-show $aduser" 0 "$aduser added in AD, synced to IPA using force-sync option"

	rlRun "ADuser_ldif $aduser2 ads $aduser2 $userpw 512 add" 0 "Generate ldif file to add user $aduser2"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding $aduser2 in AD to test options"
	sleep 20

	rlRun "ipa-replica-manage re-initialize --from $ADhost" 0 "Using re-initialize option"
	sleep 5
	rlRun "$ipa user-show $aduser2" 0 "$aduser2 added in AD, synced to IPA with reinitialize option"

	# Test clean up
	rlRun "$ipa user-del $aduser $aduser2" 0 "Deleting users from IPA and AD"
	sleep 15

	rlRun "ipa-replica-manage disconnect $ADhost" 0 "Disconnecting replica agreement"
	sleep 15
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=$ADcrt $ADhost --binddn \"$AD_binddn\" --bindpw $ADpswd -v -p $DMpswd" 0 "Re-connecting for next test"

	sleep 15	
	rlRun "ipa-replica-manage del $ADhost" 0 "Deleting agreement"
	#rlRun "service dirsrv restart" 0 "Restarting dirsrv to clear old cached principals"
	
rlPhaseEnd
}

winsync_test_0017() {

rlPhaseStartTest "0017 Winsync with --win-subtree"
	rlRun "addOU_ldif $OU1 add"
	rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f addOU.ldif" 0 "Adding OU $OU1"
	rlRun "addsubOU_ldif $sub_OU1 $OU1 add"
	rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f addsubOU.ldif" 0 "Adding sub OU $sub_OU1"
	
	rlRun "addOU_ldif $OU2 add"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f addOU.ldif" 0 "Adding OU $OU2"
        rlRun "addsubOU_ldif $sub_OU2 $OU2 add"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f addsubOU.ldif" 0 "Adding sub OU $sub_OU2"

	rlRun "ADuser_ldif $l1user ads $l1user $userpw 512 add $OU1" 0 "Generate ldif file to add user $l1user"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding $l1user in OU $OU1"

	rlRun "ADuser_ldif $sub1user ads $sub1user $userpw 512 add $OU1 $sub_OU1" 0 "Generate ldif file to add user $sub1user"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding $sub1user in OU $OU1"

	rlLog "Winsync OU with existing users"
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=$ADcrt $ADhost --binddn \"$AD_binddn\" --bindpw $ADpswd -v -p $DMpswd --win-subtree=\"OU=$OU1,$ADdc\"" 0 "Creating winsync agreement with OU $OU1 win-subtree"
	sleep 15

	 # Restart PassSync after winsync agreement is established
	rlRun "ping -c 4 $ADip" 0 "AD server reachable"
	net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd | grep \"passsync.exe\"
	sleep 5
	net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd | grep \"passsync.exe\"
	rlRun "net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd" 0 "PassSync status on AD"
	rlRun "PassSync_Restart $ADip $ADadmin $ADpswd" 0 "Restarting PassSync Service"
	sleep 15

	rlRun "$ipa user-show $l1user | grep \"Account disabled: False\"" 0 "$l1user from OU $OU1 synced and enabled in IPA"
	sleep 5
        rlRun "$ipa user-show $l1user | grep \"Password: True\"" 0 "Password in sync for $l1user of OU $OU1"
	sleep 5
        rlRun "$ipa user-show $sub1user| grep \"Account disabled: False\"" 0 "$sub1user from sub OU $sub_OU1 synced and enabled in IPA"
	sleep 5
        rlRun "$ipa user-show $sub1user | grep \"Password: True\"" 0 "Password in sync for $sub1user of sub OU $sub_OU1"
	sleep 5

	# Test clean up
	rlRun "$ipa user-del $l1user $sub1user"
	sleep 15
	rlRun "addsubOU_ldif $sub_OU1 $OU1 delete"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f addsubOU.ldif" 0 "Delete sub OU $sub_OU1"
	rlRun "addOU_ldif $OU1 delete"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f addOU.ldif" 0 "Delete OU $OU1"
	rlRun "ipa-replica-manage del $ADhost" 0 "Deleting agreement with OU $OU1"
	sleep 10

	rlLog "Winsync OU without existing users"
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=$ADcrt $ADhost --binddn \"$AD_binddn\" --bindpw $ADpswd -v -p $DMpswd --win-subtree=\"OU=$OU2,$ADdc\"" 0 "Creating winsync agreement with OU $OU2 win-subtree"
	sleep 15

	 # Restart PassSync after winsync agreement is established
	rlRun "ping -c 4 $ADip" 0 "AD server reachable"
	net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd | grep \"passsync.exe\"
	sleep 5
	net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd | grep \"passsync.exe\"
	rlRun "net rpc service status PassSync -I $ADip -U $ADadmin%$ADpswd" 0 "PassSync status on AD"
	rlRun "PassSync_Restart $ADip $ADadmin $ADpswd" 0 "Restarting PassSync Service"
	sleep 10

	rlRun "syncinterval_ldif $sec add"
        rlRun "ldapmodify -x -D \"$DS_binddn\" -w $DMpswd -f syncinterval.ldif" 0 "Change winsync interval back to $sec sec"
        #rlRun "service dirsrv restart" 0 "Restarting to make winsync interval change effective"
        rlRun "rlDistroDiff dirsrv_svc_restart" 0 "Restarting to make winsync interval change effective"
	sleep 30

	rlRun "ADuser_ldif $l2user ads $l2user $userpw 512 add $OU2" 0 "Generate ldif file to add user $l2user"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding $l2user in OU $OU2"

        rlRun "ADuser_ldif $sub2user ads $sub2user $userpw 512 add $OU2 $sub_OU2" 0 "Generate ldif file to add user $sub2user"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding $sub2user in OU $OU2"
	rlRun "sleep 30" 0 "Waiting for sync"
	sleep $sec
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	
	rlRun "$ipa user-show $l2user | grep \"Account disabled: False\"" 0 "$l2user from OU $OU2 synced and enabled in IPA"
	sleep 5
	rlRun "$ipa user-show $l2user | grep \"Password: True\"" 0 "Password in sync for $l2user of OU $OU2"
	sleep 5
        rlRun "$ipa user-show $sub2user| grep \"Account disabled: False\"" 0 "$sub2user from sub OU $sub_OU2 synced and enabled in IPA"
	sleep 5
	rlRun "$ipa user-show $sub2user | grep \"Password: True\"" 0 "Password in sync for $sub2user of sub OU $sub_OU2"

	# Test clean up
	rlRun "$ipa user-del $l2user $sub2user"
	sleep 15
        rlRun "addsubOU_ldif $sub_OU2 $OU2 delete"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f addsubOU.ldif" 0 "Delete sub OU $sub_OU2"
        rlRun "addOU_ldif $OU2 delete"
        rlRun "ldapmodify -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f addOU.ldif" 0 "Delete OU $OU2"
	rlRun "ipa-replica-manage del $ADhost" 0 "Deleting agreement with OU $OU2"

rlPhaseEnd
}

winsync_test_0018() {

rlPhaseStartTest "0018 bz869656 - Improve information on passsync user in man page, command help"
	rlRun "man ipa-replica-manage | col -b | grep -A3 \"\-\-passsync\" | head -4 > doc.txt" 0 "Picking Description of --passsync from man page"
	echo >> doc.txt
	rlRun "ipa-replica-manage -help | grep -A1 passsync >> doc.txt" 0 "Picking description of --passsync from help"
	rlRun "diff -q doc.txt bz869656" 0 "Text in both man and help page is correct"

	# Test cleanup
	rlRun "rm -f doc.txt" 0 "Remove the doc file"
	
rlPhaseEnd
}

cleanup() {

rlPhaseStartCleanup "Clean up for winsync sanity tests"

	rlRun "kinitAs $ADMINID $ADMINPW" 0

	rlRun "certutil -D -n \"AD cert\" -d /etc/dirsrv/slapd-TESTRELM-COM"

	rlRun "rm -f /etc/named.conf && cp -p /etc/named.conf.winsync /etc/named.conf" 0 "Replacing named.conf file from backup"
	rlServiceStop "named"
        rlServiceStart "named"

	rlRun "rm -f *.ldif"
	rlRun "rm -f $ipacrt"
	rlRun "rm -fr $TmpDir"

	rlRun "sed -i \"/^TLS_CACERTDIR.*/d\" /etc/openldap/ldap.conf"
	rlRun "kdestroy" 0 "Destroy any credentials"
#	rlRun "ipa_quick_uninstall" 0 "Uninstalling IPA server and Cleanup"

	rlRun "rm -fr /tmp/krb5cc_*"

rlPhaseEnd
}
