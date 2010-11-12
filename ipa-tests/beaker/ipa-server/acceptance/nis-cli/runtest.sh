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
. /dev/shm/ipa-netgroup-cli-lib.sh
. /dev/shm/env.sh

PACKAGE="ipa-server"

# Init master var
export master=0;

hostname_s=$(hostname -s)

user1=usk1r
user2=use33t
user3=usern00b
user4=lopr4k
group1=grpddee
group2=grplloo
group3=grpmmpp
group4=grpeeww
ngroup1=ngrp7664

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
	setenforce 0
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

    # r2d2_test_starts
	rlPhaseStartTest "Get admin ticket"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlPhaseEnd

 	ipa user-add --first=aa --last=bb $user1
	ipa user-add --first=aa --last=bb $user2
	ipa user-add --first=aa --last=bb $user3
	ipa user-add --first=aa --last=bb $user4
	ipa group-add --desc=testtest $group1
	ipa group-add --desc=testtest $group2
	ipa group-add --desc=testtest $group3
	ipa group-add --desc=testtest $group4

        addNetgroup $ngroup1 test-group-1

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

	# enumerate maps into some files for analysis. 
	ypcat -h $MASTER -d $DOMAIN passwd > /dev/shm/passwd-map
	ypcat -h $MASTER -d $DOMAIN group > /dev/shm/group-map
	ypcat -h $MASTER -d $DOMAIN netgroup > /dev/shm/netgroup-map	
	rlPhaseStartTest "check to ensure all users are in nis"
		rlRun "grep $user1 /dev/shm/passwd-map" 0 "Verifying that user1 is in the nis passwd map"
		rlRun "grep $user2 /dev/shm/passwd-map" 0 "Verifying that user2 is in the nis passwd map"
		rlRun "grep $user3 /dev/shm/passwd-map" 0 "Verifying that user3 is in the nis passwd map"
		rlRun "grep $user4 /dev/shm/passwd-map" 0 "Verifying that user4 is in the nis passwd map"
	rlPhaseEnd

	rlPhaseStartTest "check to ensure that groups are in nis passwd map"
		rlRun "grep $group1 /dev/shm/group-map" 0 "Verifying that group1 is in the nis password map"
		rlRun "grep $group2 /dev/shm/group-map" 0 "Verifying that group2 is in the nis password map"
		rlRun "grep $group3 /dev/shm/group-map" 0 "Verifying that group3 is in the nis password map"
		rlRun "grep $group4 /dev/shm/group-map" 0 "Verifying that group4 is in the nis password map"
	rlPhaseEnd

	rlPhaseStartTest "check to ensure that net groups are in nis passwd map"
		rlRun "grep $ngroup1 /dev/shm/netgroup-map" 0 "Verifying that netgroup1 is in the nis password map"
	rlPhaseEnd

	rlPhaseStartTest "check to ensure invalid users are not in nis"
		rlRun "grep baduser1 /dev/shm/passwd-map" 1 "Verifying that user1 is in the nis passwd map"
	rlPhaseEnd

	rlPhaseStartTest "checking that using netgroups with nis really works."
		ipa user-add --first=Kermit --last=Frog kfrog
		ipa user-add --first=Count --last=VonCount count123
		ipa user-add --first=Oscar --last=Grouch scram
		ipa user-add --first=Elmo --last=Gonzales elmo
		ipa user-add --first=Zoe --last=MacPhearson zoe
		ipa user-add --first=Prairie --last=Dawn pdawn
		ipa group-add --desc="Monsters on Sesame Street" monsters
		ipa group-add --desc="Muppets moonlighting for CTW" muppets
		ipa group-add-member --users=kfrog,scram,pdawn muppets
		ipa group-add-member --users=count123,elmo,zoe monsters
		ipa netgroup-add --desc="staging servers" net-stage
		ipa netgroup-add --desc="live servers" net-live
		ipa hostgroup-add --desc "Live servers" host-live
		ipa hostgroup-add --desc "Staging servers" stage-live
		ipa hostgroup-add-member --hosts=$MASTER host-live
		ipa hostgroup-add-member --hosts=$MASTER stage-live
		ipa netgroup-add-member --groups=muppets --hostgroups=host-live net-live
		ipa netgroup-add-member --groups=muppets --hostgroups=host-stage net-stage
		ypcat -h $MASTER -d $DOMAIN netgroup > /dev/shm/netgroup-map
		rlRun "grep $MASTER /dev/shm/netgroup-map" 0 "Checking to ensure that nis is able to find a created netgroup"
	rlPhaseEnd

	# sleeping to allow all hosts to sync up. 
	sleep 200

    # r2d2_test_ends

    rlPhaseStartCleanup "nis-cli cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlRun "setenforce 1" 0 "reenable enforcing selinux"
	ipa user-del $user1
	ipa user-del $user2
	ipa user-del $user3
	ipa user-del $user4
	ipa group-del $group1
	ipa group-del $group2
	ipa group-del $group3
	ipa group-del $group4
	ipa netgroup-del $ngroup1
	ipa netgroup-del net-live
	ipa netgroup-del net-stage
	ipa hostgroup-del host-live
	ipa hostgroup-del stage-live
	ipa group-del muppets
	ipa group-del monsters
	ipa user-del pdawn
	ipa user-del zoe
	ipa user-del elmo
	ipa user-del scram
	ipa user-del count123
	ipa user-del kfrog
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
