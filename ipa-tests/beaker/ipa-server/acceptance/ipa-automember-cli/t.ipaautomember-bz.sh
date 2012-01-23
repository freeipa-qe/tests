#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipaautomember-bz.sh of /CoreOS/ipa-tests/acceptance/ipa-automember-cli
#   Description: IPA automember BZ acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa BZ's need to be tested:
#  BZ 746589 -- automember functionality not available for upgraded IPA server
#  BZ 772659 -- Typo in example description for automember-default-group-remove
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
ipaautomember_bz()
{
	ipaautomember_bz_envsetup
	ipaautomember_bz_746589
	ipaautomember_bz_772659
	ipaautomember_bz_envcleanup
}

######################################################################
# SETUP
######################################################################
ipaautomember_bz_envsetup()
{
	rlPhaseStartTest "ipa-automember-bz-envsetup: "
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as $ADMINID user"
	rlPhaseEnd
}

######################################################################
# automember functionality not available for upgraded IPA server
######################################################################
ipaautomember_bz_746589()
{
	rlPhaseStartTest "ipa-automember-bz-746589: automember functionality not available for upgraded IPA server"
		KinitAsAdmin
		local tmpout=$TmpDir/automember_bz_746589.$RANDOM.out
		# Need some code to test if a version was from upgrade??? 
		ipa automember-add --type=group ipa-automember-bz-746589  > $tmpout 2>&1
		if [ $? -eq 0 ]; then
			rlPass "BZ 746589 not found"
			ipa automember-del --type=group ipa-automember-bz-746589 > /dev/null
		elif [ $(grep "ipa: ERROR: Auto Membership is not configured" $tmpout|wc -l) -eq 1 ]; then
			rlFail "BZ 746589 found...automember functionality not available for upgraded IPA server"
		fi	
	rlPhaseEnd
}

#  BZ 772659 -- Typo in example description for automember-default-group-remove
#  $(ipa help automember|grep "Set the default target group:" | wc -l) -gt 1 ] && rlFail
ipaautomember_bz_772659()
{
	rlPhaseStartTest "ipaautomember_bz_772659: Typo in example description for automember-default-group-remove"
		KinitAsAdmin
		if [ $(ipa help automember|grep "Set the default target group:" | wc -l) -gt 1 ]; then
			rlFail "BZ 772659 found...Typo in example description for automember-default-group-remove"
		else
			rlPass "BZ 772659 not found"
		fi
	rlPhaseEnd
}
