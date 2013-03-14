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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh


PACKAGE="ipa-server"
INSTANCE=`echo $RELM | sed 's/\./-/g'`

##########################################
getServicePIDs()
{

   for item in named krb5kdc kadmind ; do
   	ps -e | grep $item | awk '{print $1}'> /tmp/$item.out
   done

   ps -ef | grep slapd | grep PKI | awk '{print $2}' > /tmp/slapd_PKI.out
   ps -ef | grep slapd | grep -i $INSTANCE | awk '{print $2}' > /tmp/slapd_$INSTANCE.out
   ps -ef | grep pki-ca | grep tomcat | awk '{print $2}' > /tmp/pki-ca.out
   ps -e | grep memcached | awk '{print $1}' > /tmp/memcached.out

   return 0
}

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup 
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-server package is installed"
        else
                rlFail "ipa-server package NOT found!"
        fi
	rlRun "useradd testuserqa" 0 "Add test user"
	# get initial service pids
	getServicePIDs
    rlPhaseEnd
	
	rlPhaseStartTest "ipa-ctl-01 ensure that ipactl gets installed"
		rlRun "ls /usr/sbin/ipactl" 0 "Checking to ensure that ipactl got installed"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-02 ensure that ipactl stop runs with a zero return code"
		rlRun "/usr/sbin/ipactl stop" 0 "Checking to ensure that ipactl stop returns a zero return code"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-03 ensure that ipactl stop stopped httpd"
		rlRun "ps xa | grep -v grep |grep httpd" 1 "Checking to ensure that ipactl stop stopped httpd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-04A ensure that ipactl stop stopped krb5kdc -- bug 871524 "
                rlRun "ps xa | grep -v grep |grep krb5kdc" 1 "Checking to ensure that ipactl stop stopped krb5kdc"
                PID=`cat /tmp/krb5kdc.out`
                ps -e | grep $PID
                if [ $? -eq 0 ] ; then
                        rlFail "Process id found - krb5kdc PID $PID is still running"
                else
                        rlPass "krb5kdc pid $PID not found"
                fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-04B ensure that ipactl stop stopped kadmind"
                rlRun "ps xa | grep -v grep |grep kadmind" 1 "Checking to ensure that ipactl stop stopped kadmind"
                PID=`cat /tmp/kadmind.out`
                ps -e | grep $PID
                if [ $? -eq 0 ] ; then
                        rlFail "Process id found - kadmind PID $PID is still running"
                else
                        rlPass "kadmind pid $PID not found"
                fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-04C ensure that ipactl stop stopped memcached"
                rlRun "ps xa | grep -v grep |grep memcached" 1 "Checking to ensure that ipactl stop stopped memcached"
                PID=`cat /tmp/memcached.out`
                ps -e | grep $PID
                if [ $? -eq 0 ] ; then
                        rlFail "Process id found - memcached PID $PID is still running"
                else
                        rlPass "memcached pid $PID not found"
                fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-05 ensure that ipactl stop stopped named"
		rlRun "ps xa | grep -v grep |grep named" 1 "Checking to ensure that ipactl stop stopped named"
		PID=`cat /tmp/named.out`
                ps -e | grep $PID
                if [ $? -eq 0 ] ; then
                        rlFail "Process id found - named PID $PID is still running"
                else
			rlPass "named pid $PID not found"
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-06 ensure that ipactl stop stopped the PKI instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep PKI" 1 "Checking to ensure that ipactl stop stopped PKI"
		PID=`cat /tmp/slapd_PKI.out`
		ps -e | grep $PID
                if [ $? -eq 0 ] ; then
         	        rlFail "Process id found - dirsrv instance PKI PID $PID is still running"
                else
			rlPass "dirsrv PKI instance pid $PID not found"
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-07 ensure that ipactl stop stopped the $INSTANCE instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $INSTANCE" 1 "Checking to ensure that ipactl stop stopped $INSTANCE DS instance"
		tmpfile=/tmp/slapd_$INSTANCE.out
                PID=`cat $tmpfile`
                ps -e | grep $PID
                if [ $? -eq 0 ] ; then
                	rlFail "Process id found - dirsrv instance $INSTANCE PID $PID is still running"
                else
			rlPass "dirsrv $INSTANCE instance pid $PID not found"
		fi 
	rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-08 ensure that ipactl stop stopped pki-cad"
                rlRun "ps xa | grep -v grep |grep pki-ca" 1 "Checking to ensure that ipactl stop stopped pki-cad"
                PID=`cat /tmp/pki-ca.out`
                ps -e | grep $PID
                if [ $? -eq 0 ] ; then
                       rlFail "Process id found - pki-cad PID $PID is still running"
                else
                       rlPass "pki-cad pid $PID not found"
                fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-09 ensure that ipactl start runs with a zero return code"
		rlRun "/usr/sbin/ipactl start" 0 "Checking to ensure that ipactl start returns a zero return code"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-10 ensure that ipactl start started httpd"
		rlRun "ps xa | grep -v grep |grep httpd" 0 "Checking to ensure that ipactl start started httpd"
	rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-11A ensure that ipactl start started krb5kdc"
                rlRun "ps xa | grep -v grep |grep krb5kdc" 0 "Checking to ensure that ipactl start started krb5kdc"
                newPID=`ps -e | grep krb5kdc | awk '{print $1}'`
                rlLog "New krb5kdc pid is $newPID"
                oldPID=`cat /tmp/krb5kdc.out | awk '{print $1}'`
                rlLog "Old krb5kdc pid is $oldPID"
                if [ "$newPID" = "$oldPID" ] ; then
                    rlFail "krb5kdc did not restart"
                else
                    rlPass "krb5kdc was restarted"
                fi
                numberOfProcesses=`ps -e | grep krb5kdc | wc -l`
                numberOfCPUs=`cat /proc/cpuinfo | grep processor | wc -l` 
                rlLog "Number of krb5 process: $numberOfProcesses and number of CPUs: $numberOfCPUs"
                numberOfCPUs=$((numberOfCPUs + 1))
                if [ "$numberOfProcesses" -gt "$numberOfCPUs" ] ; then 
                   rlFail "Bug 871524 - orphaned krb5kdc processes restarting IPA services"
                fi
        rlPhaseEnd


        rlPhaseStartTest "ipa-ctl-11B ensure that ipactl start started kadmind"
                rlRun "ps xa | grep -v grep |grep kadmind" 0 "Checking to ensure that ipactl start started kadmind"
                newPID=`ps -e | grep kadmind | awk '{print $1}'`
               rlLog "New kadmind pid is $newPID"
                oldPID=`cat /tmp/kadmind.out | awk '{print $1}'`
                rlLog "Old kadmind pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "kadmind did not restart"
                else
                        rlPass "kadmind was restarted"
                fi
        rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-11C ensure that ipactl start started memcached"
                rlRun "ps xa | grep -v grep |grep memcached" 0 "Checking to ensure that ipactl start started memcached"
                newPID=`ps -e | grep memcached | awk '{print $1}'`
                rlLog "New memcached pid is $newPID"
                oldPID=`cat /tmp/memcached.out | awk '{print $1}'`
                rlLog "Old memcached pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "memcached did not restart"
                else
                        rlPass "memcached was restarted"
                fi
        rlPhaseEnd


	rlPhaseStartTest "ipa-ctl-12 ensure that ipactl start started named"
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

	rlPhaseStartTest "ipa-ctl-13 ensure that ipactl start started the $INSTANCE instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $INSTANCE" 0 "Checking to ensure that ipactl start started $INSTANCE DS instance"
		tmpfile=/tmp/slapd_$INSTANCE.out
		newPID=`ps -ef | grep slapd | grep -i $INSTANCE | awk '{print $2}'`
                rlLog "New $INSTANCE DS instance pid is $newPID"
                oldPID=`cat $tmpfile | awk '{print $1}'`
                rlLog "Old $INSTANCE DS instance pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "$INSTANCE DS instance did not restart"
                else
                        rlPass "$INSTANCE DS instance was restarted"
                fi
	rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-14 ensure that ipactl start started the PKI instance of dirsrv"
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

        rlPhaseStartTest "ipa-ctl-15 ensure that ipactl start started pki-cad"
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

	rlPhaseStartTest "ipa-ctl-16 ensure that ipactl restart runs with a zero return code"
		getServicePIDs
		rlRun "/usr/sbin/ipactl restart" 0 "Checking to ensure that ipactl start returns a zero return code"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-17 ensure that ipactl restart started httpd"
		rlRun "ps xa | grep -v grep |grep httpd" 0 "Checking to ensure that ipactl start restarted httpd"
	rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-18A ensure that ipactl restart started krb5kdcd"
                rlRun "ps xa | grep -v grep |grep krb5kdc" 0 "Checking to ensure that ipactl start restarted krb5kdc"
                newPID=`ps -e | grep krb5kdc | awk '{print $1}'`
                rlLog "New krb5kdc pid is $newPID"
                oldPID=`cat /tmp/krb5kdc.out | awk '{print $1}'`
                rlLog "Old krb5kdc pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "krb5kdc did not restart"
                else
                        rlPass "krb5kdc was restarted"
                fi
        rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-18B ensure that ipactl restart started kadmind"
                rlRun "ps xa | grep -v grep |grep kadmind" 0 "Checking to ensure that ipactl start restarted kadmind"
                newPID=`ps -e | grep kadmind | awk '{print $1}'`
                rlLog "New kadmind pid is $newPID"
                oldPID=`cat /tmp/kadmind.out | awk '{print $1}'`
                rlLog "Old kadmind pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "kadmind did not restart"
                else
                        rlPass "kadmind was restarted"
                fi
        rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-18C ensure that ipactl restart started memcached"
                rlRun "ps xa | grep -v grep |grep memcached" 0 "Checking to ensure that ipactl start restarted memcached"
                newPID=`ps -e | grep memcached | awk '{print $1}'`
                rlLog "New memcached pid is $newPID"
                oldPID=`cat /tmp/memcached.out | awk '{print $1}'`
                rlLog "Old memcached pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "memcached did not restart"
                else
                        rlPass "memcached was restarted"
                fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-19 ensure that ipactl restart started named"
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

	rlPhaseStartTest "ipa-ctl-20 ensure that ipactl restart started the $INSTANCE instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $INSTANCE" 0 "Checking to ensure that ipactl restart started $INSTANCE DS instance"
                tmpfile=/tmp/slapd_$INSTANCE.out
                newPID=`ps -ef | grep slapd | grep -i $INSTANCE | awk '{print $2}'`
                rlLog "New $INSTANCE DS instance pid is $newPID"
                oldPID=`cat $tmpfile | awk '{print $1}'`
                rlLog "Old $INSTANCE DS instance pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlFail "$INSTANCE DS instance did not restart"
                else
                        rlPass "$INSTANCE DS instance was restarted"
                fi
	rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-21 ensure that ipactl restart started the PKI instance of dirsrv"
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

        rlPhaseStartTest "ipa-ctl-22 ensure that ipactl restart started pki-cad"
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

	rlPhaseStartTest "ipa-ctl-23 stop services as non-root user"
		rlRun "su testuserqa -c 'ipactl stop' > /tmp/stopnonroot.out 2>&1" 4 "Insufficient rights, starting service as nonprivileged user"
		rlAssertGrep "You must be root to run ipactl." "/tmp/stopnonroot.out"
		rlRun "ps xa | grep -v grep |grep httpd" 0 "Checking to ensure that httpd is still running"
		rlRun "ps xa | grep -v grep |grep named" 0 "Checking to ensure that named is still running"
		rlRun "ps xa | grep -v grep |grep krb5kdc" 0 "Checking to ensure that krb5kdc is still running"
		rlRun "ps xa | grep -v grep |grep kadmind" 0 "Checking to ensure that kadmind is still running"
		rlRun "ps xa | grep -v grep |grep memcached" 0 "Checking to ensure that memcached is still running"
		#rlRun "ps xa | grep -v grep |grep ipa_kpasswd" 0 "Checking to ensure that is still running"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $INSTANCE" 0 "Checking to ensure that $INSTANCE DS instance is still running"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i PKI" 0 "Checking to ensure that PKI DS instance is still running"
		rlRun "ps xa | grep -v grep |grep pki-ca" 0 "Checking to ensure that pki-cad is still running"	
        rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-24 start services as non-root user"
		rlRun "ipactl stop" 0 "Stop services as root first"
                rlRun "su testuserqa -c 'ipactl start' > /tmp/startnonroot.out 2>&1" 4 "Insufficient rights, starting service as nonprivileged user"
		rlAssertGrep "You must be root to run ipactl." "/tmp/startnonroot.out"
                rlRun "ps xa | grep -v grep |grep httpd" 1 "Checking to ensure that httpd is NOT running"
                rlRun "ps xa | grep -v grep |grep named" 1 "Checking to ensure that named is NOT running"
		rlRun "ps xa | grep -v grep |grep krb5kdc" 1 "Checking to ensure that krb5kdc is NOT running -- bug 871524"
		rlRun "ps xa | grep -v grep |grep kadmind" 1 "Checking to ensure that kadmind is NOT running"
		rlRun "ps xa | grep -v grep |grep memcached" 1 "Checking to ensure that memcached is NOT running"
                #rlRun "ps xa | grep -v grep |grep ipa_kpasswd" 1 "Checking to ensure that is NOT running"
                rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $INSTANCE" 1 "Checking to ensure that $INSTANCE DS instance is NOT running"
                rlRun "ps xa | grep -v grep |grep dirsrv| grep -i PKI" 1 "Checking to ensure that PKI DS instance is NOT running"
                rlRun "ps xa | grep -v grep |grep pki-ca" 1 "Checking to ensure that pki-cad is NOT running"
        rlPhaseEnd

rlPhaseStartTest "ipa-ctl-25 restart services as non-root user"
                rlRun "ipactl start" 0 "Start services as root first"
		getServicePIDs
                rlRun "su testuserqa -c 'ipactl restart' > /tmp/restartnonroot.out 2>&1" 4 "Insufficient rights, starting service as nonprivileged user"
		rlAssertGrep "You must be root to run ipactl." "/tmp/restartnonroot.out"

                #verify krb5kdc was not restarted
                newPID=`ps -e | grep krb5kdc | awk '{print $1}'`
                newPID=`echo $newPID | cut -d " " -f 1`
                rlLog "previous krb5kdc pid is $newPID"
                oldPID=`cat /tmp/krb5kdc.out | awk '{print $1}'`
                oldPID=`echo $oldPID | cut -d " " -f 1`
                rlLog "current krb5kdc pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlPass "krb5kdc did not restart"
                else
                        rlFail "kdrb5kdc was restarted"
                fi

		#verify kadmind was not restarted
                newPID=`ps -e | grep kadmind | awk '{print $1}'`
                rlLog "previous kadmind pid is $newPID"
                oldPID=`cat /tmp/kadmind.out | awk '{print $1}'`
                rlLog "current kadmind pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlPass "kadmind did not restart"
                else
                        rlFail "kadmind was restarted"
                fi
		#verify memcached was not restarted
                 newPID=`ps -e | grep memcached | awk '{print $1}'`
                 rlLog "previous memcached pid is $newPID"
                 oldPID=`cat /tmp/memcached.out | awk '{print $1}'`
                 rlLog "current memcached pid is $oldPID"
                 if [ $newPID -eq $oldPID ] ; then
                         rlPass "memcached did not restart"
                 else
                         rlFail "memcached was restarted"
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
		# verify INSTANCE DS instance was not restarted
		tmpfile=/tmp/slapd_$INSTANCE.out
                newPID=`ps -ef | grep slapd | grep -i $INSTANCE | awk '{print $2}'`
                rlLog "previous $INSTANCE DS instance pid is $newPID"
                oldPID=`cat $tmpfile | awk '{print $1}'`
                rlLog "current $INSTANCE DS instance pid is $oldPID"
                if [ $newPID -eq $oldPID ] ; then
                        rlPass "$INSTANCE DS instance did not restart"
                else
                        rlFail "$INSTANCE DS instance was restarted"
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
        rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-26 verify status when directory server pki instance not running"
		rlRun "service dirsrv stop PKI-IPA" 0 "stop the directory server PKI-IPA instance"
		rlRun "ipactl status > /tmp/status.out" 3 "get ipa services status"
		cat /tmp/status.out | grep "Directory Service: STOPPED"
		if [ $? -eq 0 ] ; then
			rlPass "Found: \"Directory Service: STOPPED\""
		else
			rlFail "\"Directory Service: STOPPED\" not found"
		fi
		rlRun "service dirsrv start PKI-IPA" 0 "restart the directory server PKI-IPA instance"
        rlPhaseEnd

        rlPhaseStartTest "ipa-ctl-27 verify ipactl status non zero return code on error"
		rlRun "service dirsrv stop $INSTANCE" 0 "stop the $INSTANCE directory server instance"
		rlRun "ipactl status" 3 "Get the status of ipactl service and verify non zero return code"
		rlRun "service dirsrv start $INSTANCE" 0 "restart the $INSTANCE directory server instance"
		rlRun "ipactl status" 0 "check after instance restart"
        rlPhaseEnd

	rlPhaseStartTest "ipa-ctl bz840381 At times ipactl fails to start DNS service and a crash is detected."
		rlRun "ipactl stop" 0 "Stop all ipa services"
		#outfile=/opt/rhqa_ipa/bz840381.txt
                # check output of ipactl start and search for error instead of writing it out to a file.
                # ipactl writing to /opt/rhqa_ipa causes avc errors, so not using that apprach. 
                # Test ipa-ctl-20 tests that DNS service start correctly
		rlRun "ipactl start | grep 'Failed to start DNS Service'" 1 "Start ipa services. Ensure that a DNS failure is not in the output - BZ 840381"
		#rlRun "grep 'Failed to start DNS Service' $outfile" 1 "Ensure that a DNS failure is not in the output file BZ 840381"
		# the check below is not valid. ipactl stop - will stop DS, and bind will try to reconnect periodically (default is 60 sec)
                # everytime it reconnects, if ipactl is not restarted - there will be a message - bind to LDAP server failed: Can't contact LDAP server
                # In which case - it is a valid message.
                # rlRun "grep named /var/log/messages | grep 'bind to LDAP server failed'" 1 "Make sure that there appears to be no bad messages from named in /var/log/messages BZ 840381"
		rlRun "grep named /var/log/messages | grep 'control process exited'" 1 "Make sure that bind has not crashed. BZ 840381"
	rlPhaseEnd

##############################################################################################################
#  Disabling test development unwilling to remove KPASSWD from output
###############################################################################################################
#        rlPhaseStartTest "ipa-ctl-28: verify bz785791 :: depricated KPASSWD service in ipactl output"
#
#		output="/tmp/services.out"
#		
#		ipactl status > $output
#		cat $output | grep "KPASSWD"
#		if [ $? -eq 0 ] ; then
#			rlFail "KPASSWD is still in output for ipactl status"
#		else
#			rlPass "KPASSWD no longer in output for ipactl status"
#		fi
#
#                ipactl stop > $output
#                cat $output | grep "KPASSWD"
#                if [ $? -eq 0 ] ; then
#                        rlFail "KPASSWD is still in output for ipactl stop"
#                else
#                        rlPass "KPASSWD no longer in output for ipactl stop"
#                fi
#
#                ipactl start > $output
#                cat $output | grep "KPASSWD"
#                if [ $? -eq 0 ] ; then
#                        rlFail "KPASSWD is still in output for ipactl start"
#                else
#                       rlPass "KPASSWD no longer in output for ipactl start"
#                fi
#
#                ipactl restart > $output
#                cat $output | grep "KPASSWD"
#                if [ $? -eq 0 ] ; then
#                        rlFail "KPASSWD is still in output for ipactl restart"
#                else
#                        rlPass "KPASSWD no longer in output for ipactl restart"
#                fi
#
#        rlPhaseEnd

    rlPhaseStartCleanup
	rlRun "userdel -fr testuserqa" 0 "Remove test user"
	ipactl restart
    rlPhaseEnd

  rlJournalPrintText
  report=/tmp/rhts.report.$RANDOM.txt
  makereport $report
rhts-submit-log -l $report

rlJournalEnd
