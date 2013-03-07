#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA ipa-upgrade acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#   Date  : Nar 12, 2012
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


upgrade_test_master_slave_client_all()
{	
	rlPhaseStartTest "upgrade_test_msc_all: test full setup for master, then slave, then client"
		rlRun "env|sort"
		# Install and setup environment and add data
		install_all
		data_add

		# test upgrade with new master, old slave, and old client
		upgrade_master 
		#data_add_2
		data_check_all
		#data_check_2 $MASTER_IP

		# test upgrade with new master, new slave, and old client 
		upgrade_slave
		data_check_all

		# test upgrade with new master, new slave, and new client
		upgrade_client
		data_check_all

		# uninstall everything so we can start over
		uninstall	
	rlPhaseEnd
}
	
upgrade_test_client_slave_master_all()
{
	local tmpout=/tmp/errormsg.out
	rlPhaseStartTest "upgrade_test_client_slave_master_all: test full setup for client, then slave, then master"
		rlRun "env|sort"
		# Install and setup environment and add data
		install_all
		data_add

		# test upgrade with old master, old slave, and new client
		upgrade_client
		# No data_check here because it will fail...need negative checks for ipa commands
		# can't upgrade client first or ipa commands won't work.  native ones do but, ipa ones don't.
		if [ "$MYROLE" = "CLIENT" ]; then
			KinitAsAdmin 
			rlLog "Running negative test for ipa commands failing when client upgraded first"
			rlRun "ipa --delegate user-find > $tmpout 2>&1" 1
			if [ $(grep "ERROR.*client incompatible with.*server" $tmpout| wc -l) -gt 0 ]; then
				rlPass "Expected failure seen running ipa commands after upgrading client first"
			fi
			rlRun "cat $tmpout"
		fi

		# test upgrade with old master, new slave, and new client 
		upgrade_slave
		data_check $SLAVE_IP

		# test upgrade with new master, new slave, and new client
		upgrade_master 
		data_check $MASTER_IP
		
		# check data from client again to make sure things look good now
		data_check $CLIENT_IP

		# uninstall everything so we can start over
		uninstall	
	rlPhaseEnd
}

upgrade_test_master_slave_client_nodns()
{
	rlPhaseStartTest "upgrade_test_master_slave_client_nodns: Test setup without dns for master, then slave, then client"
		rlRun "env|sort"
		# Install and setup environment and add data
		install_nodns
		data_add

		# test upgrade with old master, old slave, and old client
		upgrade_master
		data_check $MASTER_IP

		# test upgrade with new master, new slave, and old client
		upgrade_slave
		data_check $SLAVE_IP

		# test upgrade with new master, new slave, and new client
		upgrade_client
		data_check $CLIENT_IP

		# uninstall everything so we can start over
		uninstall
	rlPhaseEnd
}


upgrade_test_master_slave_client_dirsrv_off()
{
	rlPhaseStartTest "upgrade_test_master_slave_client_dirsrv_off: Test upgrade with dirsrv down before upgrade"
		rlRun "env|sort"
		# Install and setup environment and add data
		install_all
		data_add

		# test master upgrade with dirsrv down
		if [ "$MYROLE" = "MASTER" ]; then
			rlLog "Shutting down dirsrv before upgrading MASTER ($MASTER)"
			rlRun "service dirsrv stop"
		fi
		upgrade_master
		upgrade_bz_895298_check_master	
		data_check $MASTER_IP
		
		# test slave upgrade with dirsrv down
		if [ "$MYROLE" = "SLAVE" ]; then
			rlLog "Shutting down dirsrv before upgrading SLAVE ($SLAVE)"
			rlRun "service dirsrv stop"
		fi
		upgrade_slave
		upgrade_bz_895298_check_slave
		data_check $SLAVE_IP

		# test client upgrade after master and slave upgrades with dirsrv down
		upgrade_client
		data_check $CLIENT_IP

		# uninstall everything so we can start over
		uninstall
			
	rlPhaseEnd
}

upgrade_test_master_bz_tests()
{
	rlPhaseStartTest "upgrade_test_master_bz_tests: execute bug tests against a master upgrade"
		rlRun "env|sort"
		# Install and setup master for bug checks
		ipa_install_master_all
		ipa_install_slave_all

		# Running start function for 772359 to capture info before upgrade
		upgrade_bz_772359_start

		# Alter the bind configuration to ensure that BZ 819629 will be tested properly
		upgrade_bz_819629_setup

		# upgrade master and check data
		upgrade_master
		upgrade_slave
		
		# Now execute bug checks
		upgrade_bz_819629
		upgrade_bz_772359_finish
		upgrade_bz_766096
		upgrade_bz_746589
		upgrade_bz_782918
		upgrade_bz_803054
		upgrade_bz_809262
		upgrade_bz_808201
		upgrade_bz_803930
		upgrade_bz_812391
		upgrade_bz_821176
		upgrade_bz_824074
		upgrade_bz_893722
		upgrade_bz_902474
		upgrade_bz_903758

		# uninstall everything so we can start over
		ipa_uninstall_slave
		ipa_uninstall_master
			
	rlPhaseEnd
}

upgrade_test_master_bz_866977()
{
	rlPhaseStartTest "upgrade_test_master_bz_866977: Inform user when ipa-upgradeconfig reports errors"
		rlRun "env|sort"
		ipa_install_master_all
		upgade_bz_866977_setup
		upgrade_master 2>&1 | tee /tmp/upgade_master_bz_866977.out
		upgrade_bz_866977_check
		ipa_uninstall_master
	rlPhaseEnd
}

upgrade_test_master_slave_client_all_final()
{	
	rlPhaseStartTest "upgrade_test_master_slave_client_all_final: Install and upgrade to leave in a state for other testing"
		rlRun "env|sort"
		install_all
		upgrade_master 
		upgrade_slave
		upgrade_client
	rlPhaseEnd
}
