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
let endseconds=$starttime+$RESERVETIME
enddate=$(date --date="$endseconds seconds")
echo "Subject: reserved $hostname for your use with job $JOBID
This is the machine at $hostname,

This machine is now in a reservation state for $RESERVETIME seconds

Reservation will end at $enddate. 

Find information on this job at: Watch the progress at: https://beaker.engineering.redhat.com/jobs/$JOBID
Or, if in mountain view: http://hammer1.dsdev.sjc.redhat.com/bkr/jobs/$JOBID

A seperate email will be sent once the reservation time has elapsed.

Good luck" > /dev/shm/setup-email.txt
        sendmail -fbeaker@redhat.com $SUBMITTER < /dev/shm/setup-email.txt
}


send_day_remaining_notice()
{
hostname=$(hostname)
echo "Subject: Reservation expirationnotice for $hostname with job $JOBID
This is the machine at $hostname,

This machine's reservation will expire in less than 24 hours for now. 

If you would like to keep this reservation going, please login to $hostname 
and extend the reservation with the extendreservation.sh script.

Have a nice day." > /dev/shm/end-email.txt
        sendmail -fbeaker@redhat.com $SUBMITTER < /dev/shm/end-email.txt
}

send_end_notice()
{
hostname=$(hostname)
echo "Subject: returned $hostname to pool
This is the machine at $hostname,

This machine is now being returned to the pool since $RESERVETIME seconds has elapsed

Have a nice day." > /dev/shm/end-email.txt
        sendmail -fbeaker@redhat.com $SUBMITTER < /dev/shm/end-email.txt
}

send_extended_email()
{
hostname=$(hostname)
let endseconds=$starttime+$RESERVETIME
enddate=$(date --date="$endseconds seconds")
echo "Subject: $hostname reservation extended by $moreseconds
This is the machine at $hostname,

This machines reservation has been extended by $moreseconds seconds.

This reservation should expire at $enddate

Have a nice day." > /dev/shm/end-email.txt
        sendmail -fbeaker@redhat.com $SUBMITTER < /dev/shm/end-email.txt
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
		rlRun "ls /dev/shm/toomanyseconds.txt" 1 "Making sure RESERVETIME is 1209600 (ie 20160 minuites, ie 14 days) or less"
	rlPhaseEnd

	rlPhaseStartSetup "gathering start time"
		starttime=$(date +%s)
		export starttime
		rlRun "echo 'start time is $starttime'" 0 "echoing start time"
	rlPhaseEnd

	rlPhaseStartSetup "running reserve loop"
		rescomplete=1
		while [ $rescomplete ]; do
			sleep 500
			currenttime=$(date +%s)
			echo "current time is $currenttime starttime is $starttime"
			let timediff=$currenttime-$starttime
			if [ $timediff -lt 86400 ]; then # 86400 is 24 hours
				rescomplete=0
				export $rescomplete
				export $timediff
			fi
		done
		send_day_remaining_notice
		let endseconds=$starttime+$RESERVETIME
		enddate=$(date --date="$endseconds seconds")
		echo "This machine is reserved until $enddate. Run extendreservation.sh to extend the reservation to a time farther in the future" >> /etc/motd
		rescomplete=1
		while [ $rescomplete ]; do
			sleep 500
			let timediff=$currenttime-$starttime
			if [ -f /tmp/ipa-reservation-extend-seconds.dat ]; then
				moreseconds=$(cat /tmp/ipa-reservation-extend-seconds.dat)
				let $RESERVETIME=$RESERVETIME+$moreseconds
				echo "$moreseconds seconds added to this reservation under jobid of $JOBID."
				export $moreseconds
				send_extended_email
				rm -f /tmp/ipa-reservation-extend-seconds.dat
			fi
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
