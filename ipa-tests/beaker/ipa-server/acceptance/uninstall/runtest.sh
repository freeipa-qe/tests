#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-server/acceptance/uninstall
#   Description: uninstall test of ipa-server
#   Author: Michael Gregg <mgregg@redhat.com>
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
. /usr/lib/beakerlib/beakerlib.sh

PACKAGE="ipa-server"
HOSTSFILE="/etc/hosts"
SERVICE="ipa_kpasswd"

rlJournalStart
	rlPhaseStartSetup
		rlRun "rpm -ql ipa-server" 
		rlAssertRpm $PACKAGE
		rlRun "ipa-server-install --uninstall -U"
		rlRun "yum -y erase 389-ds-base ipa-server ipa-python ipa-client ipa-admintools bind caching-nameserver bind-dyndb-ldap certmonger"
	rlPhaseEnd

	rlPhaseStartTest "IPA start test section"
		rlRun "ls /etc/yum.repos.d"
#		rlServiceStop $SERVICE

#		rlServiceRestore $SERVICE
	rlPhaseEnd

	rlPhaseStartCleanup
		rlRun "ls /tmp"
		rlRun "ls /root"
		rlRun "ls /etc/yum.repos.d"
		rlRun "rm -f /etc/yum.repos.d/ipa*"
		rlRun "cp -af $HOSTSFILE $HOSTSFILE.tmpbackup"
		rlRun "rm -f $HOSTSFILE"
		rlRun "cp -af $HOSTSFILE.ipabackup $HOSTSFILE"
		if [ ! -f $HOSTSFILE ]; then
			cp -af $HOSTSFILE.tmpbackup $HOSTSFILE;
		fi
		rlRun "rm -f $HOSTSFILE.tmpbackup"
#		rlFileRestore $HOSTSFILE
	rlPhaseEnd

rlJournalPrintText
rlJournalEnd 
