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
		# Install and setup environment and add data
		ipa_install_master_all
		ipa_install_slave_all
		ipa_install_client
		data_add

		# test upgrade with new master, old slave, and old client
		upgrade_master 
		data_check

		# test upgrade with new master, new slave, and old client 
		upgrade_slave
		data_check

		# test upgrade with new master, new slave, and new client
		upgrade_client
		data_check

		# uninstall everything so we can start over
		uninstall	
	rlPhaseEnd
}
	
upgrade_test_client_slave_master_all()
{
	rlPhaseStartTest "upgrade_test_client_slave_master_all: test full setup for client, then slave, then master"
		# Install and setup environment and add data
		ipa_install_master_all
		ipa_install_slave_all
		ipa_install_client
		data_add

		# test upgrade with old master, old slave, and new client
		upgrade_client
		data_check

		# test upgrade with old master, new slave, and new client 
		upgrade_slave
		data_check

		# test upgrade with new master, new slave, and new client
		upgrade_master 
		data_check
		# uninstall everything so we can start over
		uninstall	
	rlPhaseEnd
}

upgrade_test_master_slave_client_nodns()
{
	rlPhaseStartTest "upgrade_test_master_slave_client_nodns: Test setup without dns for master, then slave, then client"
		# Install and setup environment and add data
		ipa_install_master_nodns
		ipa_install_slave_nodns
		ipa_install_client
		data_add

		# test upgrade with old master, old slave, and old client
		upgrade_master
		data_check

		# test upgrade with new master, new slave, and old client
		upgrade_slave
		data_check

		# test upgrade with new master, new slave, and new client
		upgrade_client
		data_check

		# uninstall everything so we can start over
		uninstall
	rlPhaseEnd
}


upgrade_test_master_slave_client_dirsrv_off()
{
	rlPhaseStartTest "upgrade_test_master_slave_client_dirsrv_off: Test upgrade with dirsrv down before upgrade"
		# Install and setup environment and add data
		ipa_install_master_all
		ipa_install_slave_all
		ipa_install_client
		data_add

		# test master upgrade with dirsrv down
		if [ "$MYROLE" = "MASTER" ]; then
			rlLog "Shutting down dirsrv before upgrading MASTER ($MASTER)"
			rlRun "service dirsrv stop"
		fi
		upgrade_master
		data_check
		
		# test slave upgrade with dirsrv down
		if [ "$MYROLE" = "SLAVE" ]; then
			rlLog "Shutting down dirsrv before upgrading SLAVE ($SLAVE)"
			rlRun "service dirsrv stop"
		fi
		upgrade_slave
		data_check

		# test client upgrade after master and slave upgrades with dirsrv down
		upgrade_client
		data_check

		# uninstall everything so we can start over
		uninstall
			
	rlPhaseEnd
}

#	install_all
#	data_add
#	bz000000_disable_dirsrv
#	upgrade
#	bz000000_check
#	data_check
#	uninstall
#
#	# Final upgrade to run other beaker test sets against 
#	install_all
#	upgrade_master
#	upgrade_slave
#	upgade_client
