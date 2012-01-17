#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-delegation-cli-bz.sh of /CoreOS/ipa-tests/acceptance/ipa-delegation-cli
#   Description: IPA delegation cli BZ acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa BZ's need to be tested:
#  BZ BZID -- delegation cli BZ description...
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
ipa_delegation_cli_bz()
{
	ipa_delegation_cli_bz_envsetup
	#ipa_delegation_cli_bz_BZID
	ipa_delegation_cli_bz_envcleanup
}

######################################################################
# SETUP
######################################################################
ipadelegation_cli_bz_envsetup()
{
	rlPhaseStartTest "ipa-delegation-cli-bz-envsetup: "
		KinitAsAdmin
	rlPhaseEnd
}

######################################################################
# CLEANUP
######################################################################
ipadelegation_cli_bz_envcleanup()
{
	rlPhaseStartTest "ipa-delegation-cli-bz-envcleanup: "
		KinitAsAdmin
	rlPhaseEnd
}

######################################################################
# delegation cli BZ description...
######################################################################
ipadelegation_cli_bz_BZID()
{
	rlPhaseStartTest "ipa-delegation-cli-bz-BZID: delegation cli BZ description..."
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		# Need some code to test if a version was from upgrade??? 
		# Run some check to see if BZ found...
		if [ $? -eq 0 ]; then
			rlPass "BZ BZID not found"
			# cleanup if necessary
		elif [ $(grep "check output for BZ returned error message" $tmpout|wc -l) -eq 1 ]; then
			rlFail "BZ BZID found...delegation cli BZ description..."
		fi	
	rlPhaseEnd
}
