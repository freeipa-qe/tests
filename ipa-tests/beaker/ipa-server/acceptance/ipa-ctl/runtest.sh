#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-ctl
#   Description: IPA ipa-ctl acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Michael Gregg <mgregg@redhat.com>
#   Date  : Sept 10, 2010
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh


PACKAGE="ipa-admintools"

##########################################
getServicePIDs()
{

   for item in named ipa_kpasswd ; do
   	ps -e | grep $item | awk '{print $1}'> /tmp/$item.out
   done

   ps -ef | grep slapd | grep PKI | awk '{print $2}' > /tmp/slapd_PKI.out
   ps -ef | grep slapd | grep -i $RELM | awk '{print $2}' > /tmp/slapd_$RELM.out
   ps -ef | grep pki-ca | grep tomcat | awk '{print $2}' > /tmp/pki-ca.out

   return 0
}

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-ctl-setup: Check for ipa-server package and add test user"
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
	rlRun "useradd testuserqa" 0 "Add test user"
	# get initial service pids
	getServicePIDs
    rlPhaseEnd
	
	rlPhaseStartTest "ipa-ctl-01: ensure that ipactl gets installed"
		rlRun "ls /usr/sbin/ipactl" 0 "Checking to ensure that ipactl got installed"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-02: ensure that ipactl stop runs with a zero return code"
		rlRun "/usr/sbin/ipactl stop" 0 "Checking to ensure that ipactl stop returns a zero return code"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-03: ensure that ipactl stop stopped httpd"
		rlRun "ps xa | grep -v grep |grep httpd" 1 "Checking to ensure that ipactl stop stopped httpd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-04: ensure that ipactl stop stopped ipa_kpasswd"
		rlRun "ps xa | grep -v grep |grep ipa_kpasswd" 1 "Checking to ensure that ipactl stop stopped ipa_kpasswd"
		PID=`cat /tmp/ipa_kpasswd.out`
		ps -e | grep $PID
		if [ $? -eq 0 ] ; then
			rlFail "Process id found - ipa_kpasswd PID $PID is still running"
		else
			rlPass "ipa_kpasswd pid $PID not found"
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-05: ensure that ipactl stop stopped named"
		rlRun "ps xa | grep -v grep |grep named" 1 "Checking to ensure that ipactl stop stopped named"
		PID=`cat /tmp/named.out`
                ps -e | grep $PID
                if [ $? -eq 0 ] ; then
                        rlFail "Process id found - named PID $PID is still running"
                else
			rlPass "named pid $PID not found"
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-06: ensure that ipactl stop stopped the PKI instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep PKI" 1 "Checking to ensure that ipactl stop stopped PKI"
		PID=`cat /tmp/slapd_PKI.out`
		ps -e | grep $PID
                if [ $? -eq 0 ] ; then
         	        rlFail "Process id found - dirsrv instance PKI PID $PID is still running"
                else
			rlPass "dirsrv PKI instance pid $PID not found"
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-07: ensure that ipactl stop stopped the $RELM instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $RELM" 1 "Checking to ensure that ipactl stop stopped $RELM DS instance"
		tmpfile=/tmp/slapd_$RELM.out
                PID=`cat $tmpfile`
                ps -e | grep $PID
                if [ $? -eq 0 ] ; then
                	rlFail "Process id found - dirsrv instance $RELM PID $PID is still running"
                else
			rlPass "dirsrv $RELM instance pid $PID not found"
		fi 
	rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-08: ensure that ipactl stop stopped pki-cad"
                rlRun "ps xa | grep -v grep |grep pki-ca" 1 "Checking to ensure that ipactl stop stopped pki-cad"
                PID=`cat /tmp/pki-ca.out`
                ps -e | grep $PID
                if [ $? -eq 0 ] ; then
                       rlFail "Process id found - pki-cad PID $PID is still running"
                else
                       rlPass "pki-cad pid $PID not found"
                fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-09: ensure that ipactl start runs with a zero return code"
		rlRun "/usr/sbin/ipactl start" 0 "Checking to ensure that ipactl start returns a zero return code"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-10: ensure that ipactl start started httpd"
		rlRun "ps xa | grep -v grep |grep httpd" 0 "Checking to ensure that ipactl start started httpd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-11: ensure that ipactl start started kpasswd"
		rlRun "ps xa | grep -v grep |grep ipa_kpasswd" 0 "Checking to ensure that ipactl start started ipa_kpasswd"
                newPID=`ps -e | grep ipa_kpasswd | awk '{print $1}'`
                rlLog "New ipa_kpasswd pid is $newPID"
                oldPID=`cat /tmp/ipa_kpasswd.out | awk '{print $1}'`
                rlLog "Old ipa_kpasswd pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "ipa_kpasswd did not restart"
                else
                        rlPass "ipa_kpasswd was restarted"
                fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-12: ensure that ipactl start started named"
		rlRun "ps xa | grep -v grep |grep named" 0 "Checking to ensure that ipactl start started named"
		newPID=`ps -e | grep named | awk '{print $1}'`
                rlLog "New named pid is $newPID"
                oldPID=`cat /tmp/named.out | awk '{print $1}'`
                rlLog "Old named pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "named did not restart"
                else
                        rlPass "named was restarted"
                fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-13: ensure that ipactl start started the $RELM instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $RELM" 0 "Checking to ensure that ipactl start started $RELM DS instance"
		tmpfile=/tmp/slapd_$RELM.out
		newPID=`ps -ef | grep slapd | grep -i $RELM | awk '{print $2}'`
                rlLog "New $RELM DS instance pid is $newPID"
                oldPID=`cat $tmpfile | awk '{print $1}'`
                rlLog "Old $RELM DS instance pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "$RELM DS instance did not restart"
                else
                        rlPass "$RELM DS instance was restarted"
                fi
	rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-14: ensure that ipactl start started the PKI instance of dirsrv"
                rlRun "ps xa | grep -v grep |grep dirsrv| grep -i PKI" 0 "Checking to ensure that ipactl start started PKI DS instance"
                newPID=`ps -ef | grep slapd | grep PKI | awk '{print $2}'`
                rlLog "New PKI DS instance pid is $newPID"
                oldPID=`cat /tmp/slapd_PKI.out | awk '{print $1}'`
                rlLog "Old PKI DS instance pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "PKI DS instance did not restart"
                else
                        rlPass "PKI DS instance was restarted"
                fi
        rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-15: ensure that ipactl start started pki-cad"
                rlRun "ps xa | grep -v grep |grep pki-ca" 0 "Checking to ensure that ipactl start started pki-cad"
		newPID=`ps -ef | grep pki-ca | grep tomcat | awk '{print $2}'`
                rlLog "New pki-ca pid is $newPID"
                oldPID=`cat /tmp/pki-ca.out | awk '{print $1}'`
                rlLog "Old pki-ca pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "pki-ca did not restart"
                else
                        rlPass "pki-ca was restarted"
                fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-16: ensure that ipactl restart runs with a zero return code"
		getServicePIDs
		rlRun "/usr/sbin/ipactl restart" 0 "Checking to ensure that ipactl start returns a zero return code"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-17: ensure that ipactl restart started httpd"
		rlRun "ps xa | grep -v grep |grep httpd" 0 "Checking to ensure that ipactl start restarted httpd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-18: ensure that ipactl restart started kpasswd"
		rlRun "ps xa | grep -v grep |grep ipa_kpasswd" 0 "Checking to ensure that ipactl restart started ipa_kpasswd"
                newPID=`ps -e | grep ipa_kpasswd | awk '{print $1}'`
                rlLog "New ipa_kpasswd pid is $newPID"
                oldPID=`cat /tmp/ipa_kpasswd.out | awk '{print $1}'`
                rlLog "Old ipa_kpasswd pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "ipa_kpasswd did not restart"
                else
                        rlPass "ipa_kpasswd was restarted"
                fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-19: ensure that ipactl restart started named"
		rlRun "ps xa | grep -v grep |grep named" 0 "Checking to ensure that ipactl start restarted named"
                newPID=`ps -ef | grep named | awk '{print $2}'`
                rlLog "New named pid is $newPID"
                oldPID=`cat /tmp/named.out | awk '{print $1}'`
                rlLog "Old named pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "named did not restart"
                else
                        rlPass "named was restarted"
                fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-20: ensure that ipactl restart started the $RELM instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $RELM" 0 "Checking to ensure that ipactl restart started $RELM DS instance"
                tmpfile=/tmp/slapd_$RELM.out
                newPID=`ps -ef | grep slapd | grep -i $RELM | awk '{print $2}'`
                rlLog "New $RELM DS instance pid is $newPID"
                oldPID=`cat $tmpfile | awk '{print $1}'`
                rlLog "Old $RELM DS instance pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "$RELM DS instance did not restart"
                else
                        rlPass "$RELM DS instance was restarted"
                fi
	rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-21: ensure that ipactl restart started the PKI instance of dirsrv"
                rlRun "ps xa | grep -v grep |grep dirsrv| grep -i PKI" 0 "Checking to ensure that ipactl restart started PKI DS instance"
                newPID=`ps -ef | grep slapd | grep PKI | awk '{print $2}'`
                rlLog "New PKI DS instance pid is $newPID"
                oldPID=`cat /tmp/slapd_PKI.out | awk '{print $1}'`
                rlLog "Old PKI DS instance pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "PKI DS instance did not restart"
                else
                        rlPass "PKI DS instance was restarted"
                fi
        rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-22: ensure that ipactl restart started pki-cad"
                rlRun "ps xa | grep -v grep |grep pki-ca" 0 "Checking to ensure that ipactl restart started pki-cad"
                newPID=`ps -ef | grep pki-ca | grep tomcat | awk '{print $2}'`
                rlLog "New pki-ca pid is $newPID"
                oldPID=`cat /tmp/pki-ca.out | awk '{print $1}'`
                rlLog "Old pki-ca pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "pki-ca did not restart"
                else
                        rlPass "pki-ca was restarted"
                fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-23: stop services as non-root user"
		rlRun "su testuserqa -c 'ipactl stop'" 1 "Insufficient rights, starting service as nonprivileged user"
		rlRun "ps xa | grep -v grep |grep httpd" 0 "Checking to ensure that httpd is still running"
		rlRun "ps xa | grep -v grep |grep named" 0 "Checking to ensure that named is still running"
		rlRun "ps xa | grep -v grep |grep ipa_kpasswd" 0 "Checking to ensure that is still running"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $RELM" 0 "Checking to ensure that $RELM DS instance is still running"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i PKI" 0 "Checking to ensure that PKI DS instance is still running"
		rlRun "ps xa | grep -v grep |grep pki-ca" 0 "Checking to ensure that pki-cad is still running"	
        rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-24: start services as non-root user"
		rlRun "ipactl stop" 0 "Stop services as root first"
                rlRun "su testuserqa -c 'ipactl start'" 1 "Insufficient rights, starting service as nonprivileged user"
                rlRun "ps xa | grep -v grep |grep httpd" 1 "Checking to ensure that httpd is NOT running"
                rlRun "ps xa | grep -v grep |grep named" 1 "Checking to ensure that named is NOT running"
                rlRun "ps xa | grep -v grep |grep ipa_kpasswd" 1 "Checking to ensure that is NOT running"
                rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $RELM" 1 "Checking to ensure that $RELM DS instance is NOT running"
                rlRun "ps xa | grep -v grep |grep dirsrv| grep -i PKI" 1 "Checking to ensure that PKI DS instance is NOT running"
                rlRun "ps xa | grep -v grep |grep pki-ca" 1 "Checking to ensure that pki-cad is NOT running"
        rlPhaseEnd

rlPhaseStartTest "ipa-ctl-25: restart services as non-root user"
                rlRun "ipactl start" 0 "Start services as root first"
		getServicePIDs
                rlRun "su testuserqa -c 'ipactl restart'" 1 "Insufficient rights, starting service as nonprivileged user"
		# verify kpasswd was not restarted
		newPID=`ps -e | grep ipa_kpasswd | awk '{print $1}'`
                rlLog "previous ipa_kpasswd pid is $newPID"
                oldPID=`cat /tmp/ipa_kpasswd.out | awk '{print $1}'`
                rlLog "current ipa_kpasswd pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlPass "ipa_kpasswd did not restart"
                else
                        rlFail "ipa_kpasswd was restarted"
                fi
		# verify named was not restart
		newPID=`ps -ef | grep pki-ca | grep tomcat | awk '{print $2}'`
                rlLog "previous pki-cad pid is $newPID"
                oldPID=`cat /tmp/pki-ca.out | awk '{print $1}'`
                rlLog "curremt pki-cad pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlPass "pki-cad did not restart"
                else
                        rlFail "pki-cad was restarted"
                fi
		# verify RELM DS instance was not restarted
		tmpfile=/tmp/slapd_$RELM.out
                newPID=`ps -ef | grep slapd | grep -i $RELM | awk '{print $2}'`
                rlLog "previous $RELM DS instance pid is $newPID"
                oldPID=`cat $tmpfile | awk '{print $1}'`
                rlLog "current $RELM DS instance pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlPass "$RELM DS instance did not restart"
                else
                        rlFail "$RELM DS instance was restarted"
                fi
		# verify PKI DS instance was not restarted
                newPID=`ps -ef | grep slapd | grep PKI | awk '{print $2}'`
                rlLog "previous PKI DS instance pid is $newPID"
                oldPID=`cat /tmp/slapd_PKI.out | awk '{print $1}'`
                rlLog "current PKI DS instance pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlPass "PKI DS instance did not restart"
                else
                        rlFail "PKI DS instance was restarted"
                fi
		# verify pki-cad was not restarted
		newPID=`ps -ef | grep pki-ca | grep tomcat | awk '{print $2}'`
                rlLog "previous pki-ca pid is $newPID"
                oldPID=`cat /tmp/pki-ca.out | awk '{print $1}'`
                rlLog "current pki-ca pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlPass "pki-ca did not restart"
                else
                        rlFail "pki-ca was restarted"
                fi

		# work around for DS bug
		getServicePIDs
		RELMPID=`cat /tmp/slapd_$RELM.out`
		PKIPID=`cat /tmp/slapd_PKI.out`
		rlLog "$RELM PID: $RELMPID  PKI PID: $PKIPID"
		kill -9 $RELMPIK $PKIPID
		service dirsrv start
		service dirsrv stop
		ipactl start

        rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-26: bugzilla 674196 - incorrect status when directory server pki instance not running"
		rlRun "service dirsrv stop PKI-IPA" 0 "stop the directory server PKI-IPA instance"
		rlRun "ipactl status > /tmp/status.out" 0 "get ipa services status"
		cat /tmp/status.out | grep "Directory Service: STOPPED"
		if [ $? -eq 0 ] ; then
			rlPass "Found: \"Directory Service: STOPPED\""
		else
			rlFail "\"Directory Service: STOPPED\" not found"
		fi
		rlRun "service dirsrv start PKI-IPA" 0 "restart the directory server PKI-IPA instance"
        rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-27: bugzilla 674342 - ipactl status return code 0 on error"
		rlRun "service dirsrv stop $RELM" 0 "stop the $RELM directory server instance"
		rlRun "ipactl status" 1 "Get the status of ipactl service and verify non zero return code"
		rlRun "service dirsrv start $RELM" 0 "restart the $RELM directory server instance"
        rlPhaseEnd

    rlPhaseStartCleanup "ipa-ctl cleanup"
	rlRun "userdel -fr testuserqa" 0 "Remove test user"
	PID=`ps -ef | grep slapd | grep -i $RELM | awk '{print $2}'`
	kill -9 $PID
	service dirsrv restart
	ipactl start
    rlPhaseEnd

  rlJournalPrintText
  report=/tmp/rhts.report.$RANDOM.txt
  makereport $report
rhts-submit-log -l $report

rlJournalEnd
