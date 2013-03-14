#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/sssd/Sanity/sssd-initscripts-tests
#   Description: LSB Compliance testing of sssd initscripts
#   Author: Jenny Galipeau <jgalipea@redhat.com>
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
# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

PACKAGE="ipa-server"
IPASERVICE="ipa"
DSSERVICE="dirsrv"
KPWDSERVICE="ipa_kpasswd"

rlJournalStart
	rlPhaseStartSetup "ipa-initscripts-setup"
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
	        rlRun "useradd testuserqa" 0 "Add test user"
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-001: Check $IPASERVICE service and default settings"
        	rlRun "chkconfig $IPASERVICE --list" 0 "Server $IPASERVICE exists"
        	rlRun "chkconfig $IPASERVICE" 0 "chkconfig $IPASERVICE should be on by default"
        	rlRun "chkconfig $IPASERVICE off" 0 "Turning chkconfig $IPASERVICE off"
        	rlRun "chkconfig $IPASERVICE" 1 "chkconfig $IPASERVICE should be off"
        	rlRun "chkconfig $IPASERVICE on" 0 "Turning chkconfig $IPASERVICE on"
        	rlRun "chkconfig $IPASERVICE" 0 "chkconfig $IPASERVICE should be on"
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-002: Check $KPWDSERVICE service and default settings"
		rlRun "chkconfig $KPWDSERVICE --list" 0 "Serivce $KPWDSERVICE exists"
        	rlRun "chkconfig $KPWDSERVICE" 1 "chkconfig $KPWDSERVICE should be off by default"
        	rlRun "chkconfig $KPWDSERVICE on" 0 "Turning chkconfig $KPWDSERVICE on"
        	rlRun "chkconfig $KPWDSERVICE" 0 "chkconfig $KPWDSERVICE should be on"
        	rlRun "chkconfig $KPWDSERVICE off" 0 "Turning chkconfig $KPWDSERVICE off"
        	rlRun "chkconfig $KPWDSERVICE" 1 "chkconfig $KPWDSERVICE should be off"
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-003: Check $DSSERVICE service and default settings"
		rlRun "chkconfig $DSSERVICE --list" 0 "Serivce $DSSERVICE exists"
        	rlRun "chkconfig $DSSERVICE" 1 "chkconfig $DSSERVICE should be off by default"
        	rlRun "chkconfig $DSSERVICE on" 0 "Turning chkconfig $DSSERVICE on"
        	rlRun "chkconfig $DSSERVICE" 0 "chkconfig $DSSERVICE should be on"
        	rlRun "chkconfig $DSSERVICE off" 0 "Turning chkconfig $DSSERVICE off"
        	rlRun "chkconfig $DSSERVICE" 1 "chkconfig $DSSERVICE should be off"
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-004: $IPASERVICE start"
		rlServiceStop $IPASERVICE
		rlRun "service $IPASERVICE start" 0 " Service must start without problem"
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-005: $IPASERVICE status while started"
		rlRun "service $IPASERVICE status" 0 " Status with service started "
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-006: $IPASERVICE start already started services"
		rlRun "service $IPASERVICE start" 0 " Already started service "
		rlRun "service $IPASERVICE status" 0 " Again status command "
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-007: $IPASERVICE restart"
		rlRun "service $IPASERVICE restart" 0 " Restarting of service"
		rlRun "service $IPASERVICE status" 0 " Status command"
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-008: $IPASERVICE stop"
		rlRun "service $IPASERVICE stop" 0 " Stopping service"
		rlRun "service $IPASERVICE status" 1 " Status of stopped service"
                        # work around for bug 669358
                        PID=`ps -e | grep slapd | cut -d " " -f 1`
                        kill -9 $PID
                        sleep 1
                        ipactl stop
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-009: $IPASERVICE stop service already stopped"
		rlRun "service $IPASERVICE stop" 0 " Stopping service again "
		rlRun "service $IPASERVICE status" 1 " Status of stopped service "
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-010: $IPASERVICE service as non root user"
		rlRun "su testuserqa -c 'service $IPASERVICE start'" 1 "Insufficient rights, starting service as nonprivileged user"
		rlRun "su testuserqa -c 'service $IPASERVICE restart'" 1 "Insufficient rights, restarting service as nonprivileged user"
		rlRun "service $IPASERVICE start " 0 " Starting service for next test"
		rlRun "su testuserqa -c 'service $IPASERVICE stop'" 1 "Insufficient rights, stopping service as nonprivileged user"
		rlRun "service $IPASERVICE stop " 0 " Stopping service for next test"

			# work around for bug 669358
			PID=`ps -e | grep slapd | cut -d " " -f 1`
			kill -9 $PID
			sleep 1
			ipactl stop
			ipactlstart
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-011: $IPASERVICE operations - condrestart"
		rlRun "service $IPASERVICE condrestart" 0 " Service has to implement condrestart function"
	rlPhaseEnd

	rlPhaseStartTest "ipa-initscripts-012: $IPASERVICE non existent function"
		rlRun "service $IPASERVICE noexistop" 2 " Testing proper return code when nonexisting function"
	rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-013: $KPWDSERVICE start"
                rlServiceStop $KPWDSERVICE
                rlRun "service $KPWDSERVICE start" 0 " Service must start without problem"
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-014: $KPWDSERVICE status while started"
                rlRun "service $KPWDSERVICE status" 0 "Status with service started "
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-015: $KPWDSERVICE start already started services"
                rlRun "service $KPWDSERVICE start" 0 " Already started service "
                rlRun "service $KPWDSERVICE status" 0 " Again status command "
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-016: $KPWDSERVICE restart"
                rlRun "service $KPWDSERVICE restart" 0 " Restarting of service"
                rlRun "service $KPWDSERVICE status" 0 " Status command"
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-017: $KPWDSERVICE stop"
                rlRun "service $KPWDSERVICE stop" 0 " Stopping service"
                rlRun "service $KPWDSERVICE status" 3 " Status of stopped service"
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-018: $KPWDSERVICE stop service already stopped"
                rlRun "service $KPWDSERVICE stop" 0 " Stopping service again "
                rlRun "service $KPWDSERVICE status" 3 " Status of stopped service "
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-019: $KPWDSERVICE service as non root user"
                rlRun "su testuserqa -c 'service $KPWDSERVICE start'" 1 "Insufficient rights, starting service as nonprivileged user"
                rlRun "su testuserqa -c 'service $KPWDSERVICE restart'" 1 "Insufficient rights, restarting service as nonprivileged user"
                rlRun "service $KPWDSERVICE start " 0 " Starting service for next test"
                rlRun "su testuserqa -c 'service $KPWDSERVICE stop'" 1 "Insufficient rights, stopping service as nonprivileged user"
                rlRun "service $KPWDSERVICE stop " 0 " Stopping service for next test"
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-020: $KPWDSERVICE operations - condrestart"
                rlRun "service $KPWDSERVICE condrestart" 0 " Service has to implement condrestart function"
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-021: $KPWDSERVICE non existent function"
                rlRun "service $KPWDSERVICE noexistop" 2 " Testing proper return code when nonexisting function"
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-022: $DSSERVICE start"
                rlServiceStop $DSSERVICE
                rlRun "service $DSSERVICE start" 0 " Service must start without problem"
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-023: $DSSERVICE status while started"
                rlRun "service $DSSERVICE status" 0 "Status with service started "
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-024: $DSSERVICE start already started services"
                rlRun "service $DSSERVICE start" 0 " Already started service "
                rlRun "service $DSSERVICE status" 0 " Again status command "
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-025: $DSSERVICE restart"
                rlRun "service $DSSERVICE restart" 0 " Restarting of service"
                rlRun "service $DSSERVICE status" 0 " Status command"
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-026: $DSSERVICE stop"
                rlRun "service $DSSERVICE stop" 0 " Stopping service"
                rlRun "service $DsSERVICE status" 3 " Status of stopped service"
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-027: $DSSERVICE stop service already stopped"
                rlRun "service $DSSERVICE stop" 0 " Stopping service again "
                rlRun "service $DSSERVICE status" 3 " Status of stopped service "
	rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-028: $DSSERVICE service as non root user"
                rlRun "su testuserqa -c 'service $DSSERVICE start'" 1 "Insufficient rights, starting service as nonprivileged user"
                rlRun "su testuserqa -c 'service $DSSERVICE restart'" 1 "Insufficient rights, restarting service as nonprivileged user"
                rlRun "service $DSSERVICE start " 0 " Starting service for next test"
                rlRun "su testuserqa -c 'service $DSSERVICE stop'" 1 "Insufficient rights, stopping service as nonprivileged user"
                rlRun "service $DSSERVICE stop " 0 " Stopping service for next test"

                        # work around for bug 669358
                        PID=`ps -e | grep slapd | cut -d " " -f 1`
                        kill -9 $PID
			sleep 1
                        ipactl stop
                        ipactlstart
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-029: $DSSERVICE operations - condrestart"
                rlRun "service $DSSERVICE condrestart" 0 " Service has to implement condrestart function"
        rlPhaseEnd

        rlPhaseStartTest "ipa-initscripts-030: $DSSERVICE non existent function"
                rlRun "service $DSSERVICE noexistop" 2 " Testing proper return code when nonexisting function"
        rlPhaseEnd

	rlPhaseStartCleanup
		rlServiceRestore $IPASERVICE
		rlRun "userdel -fr testuserqa" 0 "Remove test user"
	rlPhaseEnd

rlJournalPrintText
report=/tmp/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd 

