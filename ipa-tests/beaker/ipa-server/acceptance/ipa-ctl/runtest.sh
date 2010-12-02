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


PACKAGE="ipa-server"

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-ctl-01: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

	
	rlPhaseStartTest "ipa-ctl-02: ensure that ipactl gets installed"
		rlRun "ls /usr/sbin/ipactl" 0 "Checking to ensure that ipactl got installed"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-03: ensure that ipactl stopruns with a zero return code"
		rlRun "ls /usr/sbin/ipactl stop" 0 "Checking to ensure that ipactl stop returns a zero return code"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-04: ensure that ipactl stop stopped httpd"
		rlRun "ps xa | grep -v grep |grep httpd" 1 "Checking to ensure that ipactl stop stopped httpd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-05: ensure that ipactl stop stopped kpasswd"
		rlRun "ps xa | grep -v grep |grep ipa_kpasswd" 1 "Checking to ensure that ipactl stop stopped ipa_kpasswd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-06: ensure that ipactl stop stopped ntpd"
		rlRun "ps xa | grep -v grep |grep ntpd" 1 "Checking to ensure that ipactl stop stopped ntpd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-07: ensure that ipactl stop stopped named"
		rlRun "ps xa | grep -v grep |grep /usr/sbin/named" 1 "Checking to ensure that ipactl stop stopped named"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-08: ensure that ipactl stop stopped the PKI instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep PKI" 1 "Checking to ensure that ipactl stop stopped PKI"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-09: ensure that ipactl stop stopped the $RELM instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $RELM" 1 "Checking to ensure that ipactl stop stopped $RELM"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-10: ensure that ipactl start runs with a zero return code"
		rlRun "ls /usr/sbin/ipactl start" 0 "Checking to ensure that ipactl start returns a zero return code"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-11: ensure that ipactl start started httpd"
		rlRun "ps xa | grep -v grep |grep httpd" 0 "Checking to ensure that ipactl start started httpd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-12: ensure that ipactl start started kpasswd"
		rlRun "ps xa | grep -v grep |grep ipa_kpasswd" 0 "Checking to ensure that ipactl start started ipa_kpasswd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-13: ensure that ipactl start started ntpd"
		rlRun "ps xa | grep -v grep |grep ntpd" 0 "Checking to ensure that ipactl start started ntpd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-14: ensure that ipactl start started named"
		rlRun "ps xa | grep -v grep |grep /usr/sbin/named" 0 "Checking to ensure that ipactl start started named"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-15: ensure that ipactl start started the PKI instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep PKI" 0 "Checking to ensure that ipactl start started PKI"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-16: ensure that ipactl start started the $RELM instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $RELM" 0 "Checking to ensure that ipactl start started $RELM"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-17: ensure that ipactl restart runs with a zero return code"
		rlRun "ls /usr/sbin/ipactl restart" 0 "Checking to ensure that ipactl start returns a zero return code"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-18: ensure that ipactl restart started httpd"
		rlRun "ps xa | grep -v grep |grep httpd" 0 "Checking to ensure that ipactl start restarted httpd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-19: ensure that ipactl restart started kpasswd"
		rlRun "ps xa | grep -v grep |grep ipa_kpasswd" 0 "Checking to ensure that ipactl restart started ipa_kpasswd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-20: ensure that ipactl restart started ntpd"
		rlRun "ps xa | grep -v grep |grep ntpd" 0 "Checking to ensure that ipactl start restarted ntpd"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-21: ensure that ipactl restart started named"
		rlRun "ps xa | grep -v grep |grep /usr/sbin/named" 0 "Checking to ensure that ipactl restart started named"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-22: ensure that ipactl restart started the PKI instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep PKI" 0 "Checking to ensure that ipactl restart started PKI"
	rlPhaseEnd

	rlPhaseStartTest "ipa-ctl-23: ensure that ipactl restart started the $RELM instance of dirsrv"
		rlRun "ps xa | grep -v grep |grep dirsrv| grep -i $RELM" 0 "Checking to ensure that ipactl restart started $RELM"
	rlPhaseEnd


    rlPhaseStartCleanup "ipa-ctl cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd


 
# manifest:
# teststuie   : ipasample
    ## testset: _lifetime
        ### testcase: minlife_nolimit 
            #### comment : this is to test for minimum of password history
            #### data-loop : minage
            #### data-no-loop : pwusername pwinintial_password
        ### testcase: _minlife_somelimit
            #### comment: set password life time to 0
            #### data-loop: 
            #### data-no-loop : pwusername pwinitial_password
        ### testcase: _minlife_negative
            #### comment: negative test case for minimum password life
            #### data-loop: minage
            #### data-no-loop : pwusername pwinitial_password
        ### testcase: _minlife_verify
            #### comment: verify the changes
            #### data-loop: minage
            #### data-no-loop : pwusername pwinitial_password
    ## testset: pwhistory
        ### testcase: _defaultvalue
            #### comment: verifyt the default value
            #### data-loop: size day 
            #### data-no-loop:  admin adminpassword
        ### testcase: _lowbound
            #### comment: check the lower bound of value range
            #### data-loop:  size day expired
            #### data-no-loop: 
        ### testcase: password_history_negative
            #### comment: do negative test on history of password
            #### data-loop:  size day expired newpw
            #### data-no-loop: admin adminpassword
