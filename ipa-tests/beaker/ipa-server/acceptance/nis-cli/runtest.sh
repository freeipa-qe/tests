#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/nis-cli
#   Description: IPA nis-cli acceptance tests
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

PACKAGE="ipa-server"

# Init master var
export master=0;

##########################################
#   test main 
#########################################

# Determine if this is a master

if [ "$MASTER" = "$HOSTNAME" ]; then 
	export master=1;
fi

rlJournalStart
    rlPhaseStartSetup "nis-cli startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

	rlPhaseStartTest "Installing rpcbind yptools"
		yum -y install wget rpcbind
	rlPhaseEnd

if [ $master -eq 1 ]; then
	echo $ADMINPW > /dev/shm/password
	ipa-compat-manage -y /dev/shm/password enable
	ipa-nis-manage -y /dev/shm/password enable
	/etc/init.d/rpcbind restart
	/etc/init.d/dirsrv restart
	# populating file that lets other machines know that nis is configured.
	touch /var/www/html/nisconfigured.html
	chmod 755 /var/www/html/nisconfigured.html
	/etc/init.d/httpd restart
fi

# If this is a client, wait until the master server is setup before continuing.
export serverdone=0;
while [ $serverdone -eq 0 ]; do
	cd /dev/shm;wget http://$MASTER/nisconfigured.html
	if [ $? -ne 0 ]; then
		echo "NIS not configured on master yet, waiting 60 sec"
		sleep 60
	else
		echo "NIS configured on master!"
		export serverdone=1;
	fi
done

env
    # r2d2_test_starts
	rlPhaseStartTest "Get admin ticket"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlPhaseEnd

	rlPhaseStartTest "check to see if ypcat can enumerate passwd"
	rlRun "ypcat -h $MASTER -d $DOMAIN passwd" 0 "Check to see that passwd can be enumerated"
	rlPhaseEnd

	rlPhaseStartTest "check to see if ypcat can enumerate group"
	rlRun "ypcat -h $MASTER -d $DOMAIN group" 0 "Check to see that group can be enumerated"
	rlPhaseEnd

	rlPhaseStartTest "check to see if ypcat can enumerate netgroup"
	rlRun "ypcat -h $MASTER -d $DOMAIN netgroup" 0 "Check to see that netgroup can be enumerated"
	rlPhaseEnd

	rlPhaseStartTest "check to see if ypcat cannot enumerate badgroup"
	rlRun "ypcat -h $MASTER -d $DOMAIN badgroup" 1 "Check to see that badgroup can not be enumerated"
	rlPhaseEnd

    # r2d2_test_ends

    rlPhaseStartCleanup "nis-cli cleanup"
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
