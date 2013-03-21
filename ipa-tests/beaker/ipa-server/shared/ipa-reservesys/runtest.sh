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

moresecondsfile="/tmp/ipa-reservation-extend-seconds.dat"
ipatmp=/opt/rhqa_ipa

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

Good luck" > $ipatmp/setup-email.txt
        sendmail -fbeaker@redhat.com $SUBMITTER < $ipatmp/setup-email.txt
}


send_day_remaining_notice()
{
hostname=$(hostname)
currentseconds=$(date +%s)
let endfromnow=$endseconds-$currentseconds
enddate=$(date --date="$endfromnow seconds")
echo "Subject: Reservation expiration notice for $hostname with job $JOBID
This is the machine at $hostname.

This machine's reservation will expire in less than 24 hours for now. 

Currently, the reservation will expire at:
$enddate

If you would like to keep this reservation going, please login to $hostname 
and extend the reservation with the extendreservation.sh script.

Find information on this job at: Watch the progress at: https://beaker.engineering.redhat.com/jobs/$JOBID
Or, if in mountain view: http://hammer1.dsdev.sjc.redhat.com/bkr/jobs/$JOBID

Have a nice day." > $ipatmp/end-email.txt
        sendmail -fbeaker@redhat.com $SUBMITTER < $ipatmp/end-email.txt
}

send_end_notice()
{
hostname=$(hostname)
echo "Subject: returned $hostname to pool
This is the machine at $hostname,

This machine is now being returned to the pool since $RESERVETIME seconds has elapsed

Have a nice day." > $ipatmp/end-email.txt
        sendmail -fbeaker@redhat.com $SUBMITTER < $ipatmp/end-email.txt
}

send_extended_email()
{
hostname=$(hostname)
currentseconds=$(date +%s)
let endseconds=$starttime+$RESERVETIME-$currentseconds
enddate=$(date --date="$endseconds seconds")
echo "Subject: $hostname reservation extended by $moreseconds
This is the machine at $hostname,

This machines reservation has been extended by $moreseconds seconds.

This reservation should expire at $enddate

Have a nice day." > $ipatmp/end-email.txt
        sendmail -fbeaker@redhat.com $SUBMITTER < $ipatmp/end-email.txt
}

rlJournalStart

	send_start_notice
	rlPhaseStartSetup "Make sure RESERVETIME was specified"
		rlRun "mkdir -p $ipatmp" 0 "Creating rhqa dir in case it does not exist." 
		if [ ! -f $ipatmp/reservetime.txt ]; then
			echo $RESERVETIME >> $ipatmp/reservetime.txt
		else
			rm -f $ipatmp/reservetime.txt
		fi
		rlRun "ls $ipatmp/reservetime.txt" 0 "Making sure RESERVETIME was defined in this job"
	rlPhaseEnd

	send_start_notice

	rlPhaseStartSetup "Make sure RESERVETIME is less than 20160 min"
		let maxseconds=1209600
		if [ $RESERVETIME -gt $maxseconds ]; then
			echo $RESERVETIME >> $ipatmp/toomanyseconds.txt
			rlLog "ERROR - Reserve time is greater than 2 weeks.(1209600 seconds) Exiting"
			echo "ERROR - Reserve time is greater than 2 weeks. Exiting"
			rlFail "ERROR - reserve seconds was greater than 1209600"
			rlPhaseEnd
			send_end_notice
			rlJournalPrintText
			rlJournalEnd
			sleep 60
			exit
		else
			rm -f $ipatmp/toomanyseconds.txt
		fi
		rlRun "ls $ipatmp/toomanyseconds.txt" 2 "Making sure RESERVETIME is 1209600 (ie 20160 minuites, ie 14 days) or less"
	rlPhaseEnd

	rlPhaseStartSetup "gathering start time"
		starttime=$(date +%s)
		export starttime
		rlRun "echo 'start time is $starttime'" 0 "echoing start time"
	rlPhaseEnd

	rlPhaseStartSetup "running reserve loop"
		rescomplete=0
		while [ $rescomplete -eq 0 ]; do
			sleep 500
			currenttime=$(date +%s)
			let timediff=$currenttime-$starttime
			rlLog "current time is $currenttime starttime is $starttime"
			rlLog "Seconds remaing in this reservation: $timediff"
			if [ $timediff -lt 86400 ]; then # 86400 is 24 hours
				rescomplete=1
				export rescomplete
				export timediff
				rlLog "Exiting first reserve loop"
			fi
		done
		send_day_remaining_notice
		let endseconds=$starttime+$RESERVETIME
		enddate=$(date --date="$endseconds seconds")
		rlLog "This machine is reserved until $enddate. Run extendreservation.sh to extend the reservation to a time farther in the future" >> /etc/motd
		rescomplete=0
		while [ $rescomplete -eq 0 ]; do
			sleep 500
			currenttime=$(date +%s)
			if [ -f $moresecondsfile ]; then
				oldseconds=$RESERVETIME
				moreseconds=$(cat $moresecondsfile)
				let $RESERVETIME=$RESERVETIME+$moreseconds
				rlLog "Original reservation time is $RESERVETIME"
				rlLog "New reservation time is $starttime"
				rlLog "$moreseconds seconds added to this reservation under jobid of $JOBID."
				export moreseconds
				send_extended_email
				rm -f $moresecondsfile
			fi
			let endseconds=$starttime+$RESERVETIME
			let timediff=$endseconds-$currenttime
			rlLog "current time is $currenttime starttime now reported as $starttime, endseconds as $endseconds"
			rlLog "Seconds remaing in this reservation: $timediff"
			if [ $currenttime -gt $endseconds ]; then
				rescomplete=1
				export rescomplete
				rlLog "Time expired. Exiting reserve loop."
			fi
		done

	finishtime=$(date +%s)
		rlRun "echo 'finish time is $finishtime'" 0 "echoing finish time"
	rlPhaseEnd
	send_end_notice

rlJournalPrintText
rlJournalEnd
