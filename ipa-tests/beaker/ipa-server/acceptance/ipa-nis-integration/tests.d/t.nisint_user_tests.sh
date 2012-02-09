#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   template.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration TEMPLATE_SCRIPT
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
#   
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2012 Red Hat, Inc. All rights reserved.
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

######################################################################
# variables
######################################################################

######################################################################
# test suite
######################################################################
nisint_user_tests()
{
	nisint_user_test_1001
	nisint_user_test_1002
}

# ypcat positive
nisint_user_test_1001()
{
	PhaseStartTest "nisint_user_test_1001: ypcat positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ypcat passwd|grep gooduser1" 0 "ypcat search for existing user"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ypcat negative
nisint_user_test_1002()
{
	PhaseStartTest "nisint_user_test_1002: ypcat negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ypcat passwd|grep notauser" 1 "ypcat search for non-existent user"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# getent positive
nisint_user_test_1003()
{
	PhaseStartTest "nisint_user_test_1003: getent positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "getent passwd gooduser2" 0 "getent search for existing user"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# getent negative
nisint_user_test_1004()
{
	PhaseStartTest "nisint_user_test_1004: getent negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "getent passwd notauser" 2 "getent search for existing user"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# id positive
nisint_user_test_1005()
{
	PhaseStartTest "nisint_user_test_1005: id positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "id gooduser1" 0 "id search for existing user"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# id negative
nisint_user_test_1006()
{
	PhaseStartTest "nisint_user_test_1006: id negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "id notauser" 1 "id search for existing user"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# touch positive
nisint_user_test_1007()
{
	PhaseStartTest "nisint_user_test_1007: su touch positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - gooduser1 -c 'touch /tmp/mytestfile.user1'" 0 "touch new file as exisiting user"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# touch negative
nisint_user_test_1008()
{
	PhaseStartTest "nisint_user_test_1008: su touch negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - gooduser2 -c 'touch /tmp/mytestfile.user1'" 1 "attempt to touch existing file fail without permissions"
		rlRun "su - notauser -c 'touch /tmp/mytestfile.user1'" 1 "su fail as non-existent user"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rm negative
nisint_user_test_1009()
{
	PhaseStartTest "nisint_user_test_1009: su rm negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - gooduser2 -c 'rm /tmp/mytestfile.user1'" 1 "attempt to rm existing file fail without permissions"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rm positive
nisint_user_test_1010()
{
	PhaseStartTest "nisint_user_test_1010: su rm positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - gooduser1 -c 'rm /tmp/mytestfile.user1'" 1 "attempt to rm existing file fail without permissions"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# mkdir positive
nisint_user_test_1011()
{
	PhaseStartTest "nisint_user_test_1011: su mkdir positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - gooduser1 -c 'mkdir /tmp/mytmpdir.user1'" 0 "su mkdir new directory"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# mkdir negative
nisint_user_test_1011()
{
	PhaseStartTest "nisint_user_test_1011: su mkdir negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - gooduser2 -c 'mkdir /tmp/mytmpdir.user1/mytmpdir.user2'" 0 "attempt to mkdir new directory in dir without permissions"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rmdir negative
nisint_user_test_1012()
{
	PhaseStartTest "nisint_user_test_1012: su rmdir negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - gooduser2 -c 'rmdir /tmp/mytmpdir.user1'" 0 "attempt to rmdir directory without permissions"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rmdir positive
nisint_user_test_1013()
{
	PhaseStartTest "nisint_user_test_1013: su rmdir positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - gooduser1 -c 'rmdir /tmp/mytmpdir.user1'" 0 "rmdir directory"
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ssh as user to localhost # may need to wait on this one till migration...
## ipamaster:
### ipa host-add $NISCLIENT --ip-address=$NISCLIENT_IP
### ipa-getkeytab -s $MASTER -p host/spoore-dvm3.testrelm.com@TESTRELM.COM -k /tmp/krb5.keytab.spoore-dvm3
### scp /tmp/krb5.keytab.spoore-dvm3 $NISCLIENT:/etc/krb5.keytab ???
### create krb5.conf

nisint_user_test_1014()
{
	PhaseStartTest "nisint_user_test_1014: ssh positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "ipa host-add $NISCLIENT --ip-address=$NISCLIENT_IP"
		rlRun "ipa-getkeytab -s $MASTER -p host/$NISCLIENT@$RELM -k /tmp/krb5.keytab.$NISCLIENT"
		rlRun "scp /tmp/krb5.keytab.$NISCLIENT root@$NISCLIENT:/etc/krb5.keytab"
		rhts-sync-set -s "$RUNCNAME.0" -m $MASTER
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rhts-sync-block -s "$FUNCNAME.0" $MASTER

		rlRun "yum -y install krb5-workstation" 0 "Install krb5-workstation"
		
		cp /etc/krb5.conf /etc/krb5.conf.orig.nisint
		cat <<-EOF > /etc/krb5.conf
		[logging]
		 default = FILE:/var/log/krb5libs.log
		 kdc = FILE:/var/log/krb5kdc.log
		 admin_server = FILE:/var/log/kadmind.log

		[libdefaults]
		 default_realm = $RELM
		 dns_lookup_realm = false
		 dns_lookup_kdc = false
		 rdns = false
		 ticket_lifetime = 24h
		 forwardable = yes

		[realms]
		 TESTRELM.COM = {
		  kdc = $MASTER:88
		  admin_server = $MASTER:749
		  default_domain = $DOMAIN
		  pkinit_anchors = FILE:/etc/ipa/ca.crt
		}

		[domain_realm]
		 .$DOMAIN = $RELM
		 $DOMAIN = $RELM
		EOF
		
		rlRun "authconfig --enablekrb5 --update"

		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		rlRun "ssh_auth_success gooduser1 passw0rd1 localhost" 

		mv /etc/krb5.conf.orig.nisint /etc/krb5.conf
		rlRun "authconfig --disablekrb5 --update"
		rm /etc/krb5.keytab

		[ -f $tmpout ] && rm $tmpout

		rhts-sync-set -s "$FUNCNAME.1" -m $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}



