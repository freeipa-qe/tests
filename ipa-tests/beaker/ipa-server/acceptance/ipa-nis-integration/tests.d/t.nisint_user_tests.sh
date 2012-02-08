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
	nisint_user_test_1001 # Run id test
}

# id user1
nisint_user_test_1001()
{
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
		PhaseStartTest "nisint_ipamaster_integration_envsetup: "
			local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
			rlRun "id gooduser1"
			[ -f $tmpout ] && rm $tmpout
		rlPhaseEnd
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
}

# su - user2 -c "touch /tmp/mytestfile"
nisint_user_test_1002()
{
	echo $FUNCNAME
}

# su - user3 -c "rm /tmp/mytestfile"
nisint_user_test_1003()
{
	echo $FUNCNAME
}

# su - user2 -c "rm /tmp/mytestfile"
nisint_user_test_1003()
{
	echo $FUNCNAME
}

# su - user3 -c "mkdir /tmp/mytestdir"
nisint_user_test_1003()
{
	echo $FUNCNAME
}

# su - user4 -c "rmdir /tmp/mytestdir"
nisint_user_test_1003()
{
	echo $FUNCNAME
}

# su - user3 -c "rmdir /tmp/mytestdir"
nisint_user_test_1003()
{
	echo $FUNCNAME
}

# ssh as user to localhost # may need to wait on this one till migration...
## ipamaster:
### ipa host-add $NISCLIENT --ip-address=$NISCLIENT_IP
### ipa-getkeytab -s $MASTER -p host/spoore-dvm3.testrelm.com@TESTRELM.COM -k /tmp/krb5.keytab.spoore-dvm3
### 
nisint_user_test_1003()
{
	echo $FUNCNAME
}


#rlPhaseStartTest "nisint_ipamaster_integration_envsetup: "
#	local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#	[ -f $tmpout ] && rm $tmpout
#rlPhaseEnd
