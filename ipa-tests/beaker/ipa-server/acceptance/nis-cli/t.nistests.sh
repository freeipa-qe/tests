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
	rlPhaseStartTest "add users and groups for use with nis tests"
        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        	rlRun "ipa user-add --first=aa --last=bb $user1" 0 "adding user $user1 for use in ipa test"
        	rlRun "ipa user-add --first=aa --last=bb $user2" 0 "adding user $user2 for use in ipa test"
        	rlRun "ipa user-add --first=aa --last=bb $user3" 0 "adding user $user3 for use in ipa test"
        	rlRun "ipa user-add --first=aa --last=bb $user4" 0 "adding user $user4 for use in ipa test"
        	rlRun "ipa group-add --desc=testtest $group1" 0 "adding group $group1 for use in ipa test"
        	rlRun "ipa group-add --desc=testtest $group2" 0 "adding group $group2 for use in ipa test"
        	rlRun "ipa group-add --desc=testtest $group3" 0 "adding group $group3 for use in ipa test"
        	rlRun "ipa group-add --desc=testtest $group4" 0 "adding group $group4 for use in ipa test"

        	addNetgroup $ngroup1 test-group-1
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-nis-cli-01: enable nis listening."
		# Enabling ipa compatibility	
		echo $ADMINPW | ipa-compat-manage enable
		# Enabling nis listening
		echo $ADMINPW | ipa-nis-manage enable  
		rlRun "/etc/init.d/rpcbind restart" 0 "restarting rcpbind"
		rlRun "/etc/init.d/ipa restart" 0 "restarting IPA"
	rlPhaseEnd
}

runtests()
{
        rlPhaseStartTest "ipa-nis-cli-02: check to see if ypcat can enumerate passwd"
                rlRun "ypcat -h $MASTER -d $DOMAIN passwd" 0 "Check to see that passwd can be enumerated"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-03: check to see if ypcat can enumerate group"
                rlRun "ypcat -h $MASTER -d $DOMAIN group" 0 "Check to see that group can be enumerated"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-04: check to see if ypcat can enumerate netgroup"
                rlRun "ypcat -h $MASTER -d $DOMAIN netgroup" 0 "Check to see that netgroup can be enumerated"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-05: check to see if ypcat cannot enumerate badgroup"
                rlRun "ypcat -h $MASTER -d $DOMAIN badgroup" 1 "Check to see that badgroup can not be enumerated"
        rlPhaseEnd

        # enumerate maps into some files for analysis. 
        ypcat -h $MASTER -d $DOMAIN passwd > /opt/rhqa_ipa/passwd-map
        ypcat -h $MASTER -d $DOMAIN group > /opt/rhqa_ipa/group-map
        ypcat -h $MASTER -d $DOMAIN netgroup > /opt/rhqa_ipa/netgroup-map

        rlPhaseStartTest "ipa-nis-cli-06: check to ensure user $user1 is in nis"
                rlRun "grep $user1 /opt/rhqa_ipa/passwd-map" 0 "Verifying that user1 is in the nis passwd map"
	rlPhaseEnd 

        rlPhaseStartTest "ipa-nis-cli-07: check to ensure user $user2 is in nis"
                rlRun "grep $user2 /opt/rhqa_ipa/passwd-map" 0 "Verifying that user2 is in the nis passwd map"
	rlPhaseEnd 

        rlPhaseStartTest "ipa-nis-cli-08: check to ensure user $user3 is in nis"
                rlRun "grep $user3 /opt/rhqa_ipa/passwd-map" 0 "Verifying that user3 is in the nis passwd map"
	rlPhaseEnd 

        rlPhaseStartTest "ipa-nis-cli-09: check to ensure user $user4 is in nis"
                rlRun "grep $user4 /opt/rhqa_ipa/passwd-map" 0 "Verifying that user4 is in the nis passwd map"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-10: check to ensure that group $group1 in the nis group map"
                rlRun "grep $group1 /opt/rhqa_ipa/group-map" 0 "Verifying that group1 is in the nis password map"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-11: check to ensure that group $group2 in the nis group map"
                rlRun "grep $group2 /opt/rhqa_ipa/group-map" 0 "Verifying that group2 is in the nis password map"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-12: check to ensure that group $group3 in the nis group map"
                rlRun "grep $group3 /opt/rhqa_ipa/group-map" 0 "Verifying that group3 is in the nis password map"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-13: check to ensure that group $group4 in the nis group map"
                rlRun "grep $group4 /opt/rhqa_ipa/group-map" 0 "Verifying that group4 is in the nis password map"
        rlPhaseEnd

        rlPhaseStartTest "ipa-nis-cli-14: check to ensure invalid users are not in nis"
                rlRun "grep baduser1 /opt/rhqa_ipa/passwd-map" 1 "Verifying that user1 is in the nis passwd map"
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
                ypcat -h $MASTER -d $DOMAIN netgroup > /opt/rhqa_ipa/netgroup-map
                rlRun "grep $MASTER /opt/rhqa_ipa/netgroup-map" 0 "Checking to ensure that nis is able to find a created netgroup"
        rlPhaseEnd
}

cleanup()
{
    rlPhaseStartCleanup "nis-cli cleanup"
        rlRun "setenforce 1" 0 "reenable enforcing selinux"
	rlRun "echo $ADMINPW | ipa-nis-manage disable" 0 "Disabling nis listening"
	rlRun "echo $ADMINPW | ipa-compat-manage disable" 0 "Disabling ipa compatibility"
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
