user1=usk1r
user2=use33t
user3=usern00b
user4=lopr4k
group1=grpddee
group2=grplloo
group3=grpmmpp
group4=grpeeww
ngroup1=ngrp7664
setup()
{        
	rlPhaseStartTest "ipa-nis-cli-setup: SETUP"
        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        	ipa user-add --first=aa --last=bb $user1
        	ipa user-add --first=aa --last=bb $user2
        	ipa user-add --first=aa --last=bb $user3
        	ipa user-add --first=aa --last=bb $user4
        	ipa group-add --desc=testtest $group1
        	ipa group-add --desc=testtest $group2
        	ipa group-add --desc=testtest $group3
        	ipa group-add --desc=testtest $group4

        	addNetgroup $ngroup1 test-group-1
	rlPhaseEnd
}

runtests()
{
        rlPhaseStartTest "ipa-nis-cli-01: check to see if ypcat can enumerate passwd"
                rlRun "ypcat -h $MASTER -d $DOMAIN passwd" 0 "Check to see that passwd can be enumerated"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-02: check to see if ypcat can enumerate group"
                rlRun "ypcat -h $MASTER -d $DOMAIN group" 0 "Check to see that group can be enumerated"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-03: check to see if ypcat can enumerate netgroup"
                rlRun "ypcat -h $MASTER -d $DOMAIN netgroup" 0 "Check to see that netgroup can be enumerated"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-04: check to see if ypcat cannot enumerate badgroup"
                rlRun "ypcat -h $MASTER -d $DOMAIN badgroup" 1 "Check to see that badgroup can not be enumerated"
        rlPhaseEnd

        # enumerate maps into some files for analysis. 
        ypcat -h $MASTER -d $DOMAIN passwd > /dev/shm/passwd-map
        ypcat -h $MASTER -d $DOMAIN group > /dev/shm/group-map
        ypcat -h $MASTER -d $DOMAIN netgroup > /dev/shm/netgroup-map

        rlPhaseStartTest "ipa-nis-cli-05: check to ensure all users are in nis"
                rlRun "grep $user1 /dev/shm/passwd-map" 0 "Verifying that user1 is in the nis passwd map"
                rlRun "grep $user2 /dev/shm/passwd-map" 0 "Verifying that user2 is in the nis passwd map"
                rlRun "grep $user3 /dev/shm/passwd-map" 0 "Verifying that user3 is in the nis passwd map"
                rlRun "grep $user4 /dev/shm/passwd-map" 0 "Verifying that user4 is in the nis passwd map"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-06: check to ensure that groups are in nis passwd map"
                rlRun "grep $group1 /dev/shm/group-map" 0 "Verifying that group1 is in the nis password map"
                rlRun "grep $group2 /dev/shm/group-map" 0 "Verifying that group2 is in the nis password map"
                rlRun "grep $group3 /dev/shm/group-map" 0 "Verifying that group3 is in the nis password map"
                rlRun "grep $group4 /dev/shm/group-map" 0 "Verifying that group4 is in the nis password map"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-07: check to ensure invalid users are not in nis"
                rlRun "grep baduser1 /dev/shm/passwd-map" 1 "Verifying that user1 is in the nis passwd map"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-08: checking that using netgroups with nis works."
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
}

cleanup()
{
    rlPhaseStartCleanup "nis-cli cleanup"
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
}
