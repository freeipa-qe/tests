#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/IpaReserveSys
#   Description: IPA shared libraries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Libraries Included:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
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
. /usr/share/beakerlib/beakerlib.sh

send_start_notice()
{
hostname=$(hostname)
echo "Subject: reserved $hostname for your use
This is the machine at $hostname,

This machine is now in a reservation state for $RESERVETIME seconds

A seperate email will be sent once the reservation time has elapsed.

Good luck" > /dev/shm/setup-email.txt
        sendmail $SUBMITTER < /dev/shm/setup-email.txt
}


send_end_notice()
{
hostname=$(hostname)
echo "Subject: returned $hostname to pool
This is the machine at $hostname,

This machine is now being returned to the pool since $RESERVETIME seconds has elapsed

Have a nice day." > /dev/shm/end-email.txt
        sendmail $SUBMITTER < /dev/shm/end-email.txt
}

rlJournalStart

	send_start_notice
	rlPhaseStartSetup "Make sure RESERVETIME was specified"
		if [ -x $RESERVETIME ]; then
			echo $RESERVETIME >> /dev/shm/reservetime.txt
		else
			rm -f /dev/shm/reservetime.txt
		fi
		rlRun "ls /dev/shm/reservetime.txt" 0 "Making sure RESERVETIME was defined in this job"
	rlPhaseEnd

	rlPhaseStartSetup "Make sure RESERVETIME is less than 20160 min"
		let maxseconds=1209600
		if [ $RESERVETIME -gt $maxseconds ]; then
			echo $RESERVETIME >> /dev/shm/toomanyseconds.txt
		else
			rm -f /dev/shm/toomanyseconds.txt
		fi
		rlRun "/dev/shm/toomanyseconds.txt" 1 "Making sure RESERVETIME is 1209600 (ie 20160 minuites, ie 14 days) or less"
	rlPhaseEnd

	rlPhaseStartSetup "gathering start time"
		$starttime=$(date +%s)
		export starttime
		rlRun "echo 'start time is $starttime'" 0 "echoing start time"
	rlPhaseEnd

	rlPhaseStartSetup "running reserve loop"
		$currenttime=$(date +%s)
		rescomplete=1
		while [ $rescomplete ]; do
			sleep 500
			let timediff=$currenttime-$starttime
			if [ $timediff -gt $RESERVETIME ]; then
				rescomplete=0
				export $rescomplete
			fi
		done
	finishtime=$(date +%s)
		rlRun "echo 'finish time is $finishtime'" 0 "echoing finish time"
	rlPhaseEnd
	send_end_notice

rlJournalPrintText
report=/tmp/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
