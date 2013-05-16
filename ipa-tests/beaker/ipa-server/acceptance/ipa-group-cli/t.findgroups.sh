########################################################################
# Test Sections
########################################################################
findgroups()
{
  groupfindsetup
  sizelimits
  timelimits
  ingroups
  groupsinhbacrules
  groupsinsudorules
  usersingroups
  groupsingroups
  groupsinroles  
  groupfindcleanup
}
########################################################################
# Globals
########################################################################

hrule="hbacrule"
hgroup="hbacgroup"
srule="sudorule"
sgroup="sudogroup"
user1="myuser1"
user2="myuser2"
group1="group1"
group2="group2"
group3="group3"
admrole="adminrole"


groupfindsetup()
{
    rlPhaseStartSetup
	rlRun "kinitAs $ADMINID $ADMINPWD" 0 "Kinit as admin user"
        i=1
        while [ $i -le 10 ] ; do
                addGroup Group$i Group$i
                let i=$i+1
        done

	rlRun "ipa user-add --first=$user1 --last=$user1 $user1" 0 "Add test user $user1"
	rlRun "ipa user-add --first=$user2 --last=$user2 $user2" 0 "Add test user $user2"
	rlRun "ipa hbacrule-add $hrule" 0 "Adding test hbac rule $hrule"
	rlRun "ipa sudorule-add $srule" 0 "Adding test sudo rule $srule"
	rlRun "ipa role-add --desc=$admrole $admrole" 0 "Adding test admin role $admrole"
    rlPhaseEnd
}

sizelimits()
{
    rlPhaseStartTest "ipa-group-find-001: Add 10 groups and test find returns limit of 5"
	rlRun "ipa config-mod --searchrecordslimit=5" 0 "Set default search records limit to 5"
	ipa group-find > /tmp/groupfind.out
        result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "5 groups returned as expected with size limit of 0"
        else
                rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 5"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-002: find 0 groups"
	ipa group-find --sizelimit=0 > /tmp/groupfind.out
	result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
	number=`echo $result | cut -d " " -f 5`
	# We now have "Trusts administrators group" hence group-find is 14.
	#if [ $number -eq 13 ] ; then
	if [ $number -eq 14 ] ; then
		rlPass "All groups returned as expected with size limit of 0"
	else
		rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 14"
	fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-003: find 10 groups"
        ipa group-find --sizelimit=10 > /tmp/groupfind.out
        result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 10 ] ; then
                rlPass "All group returned as expected with size limit of 10"
        else
                rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 10"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-004: find 9 groups"
        ipa group-find --sizelimit=9 > /tmp/groupfind.out
        result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 9 ] ; then
                rlPass "All group returned as expected with size limit of 9"
        else
                rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 9"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-005: find more groups than exist"
	ipa group-find --sizelimit=20 > /tmp/groupfind.out
        result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
	# We now have "Trusts administrators group" hence group-find is 14.
        #if [ $number -eq 13 ] ; then
        if [ $number -eq 14 ] ; then
                rlPass "All group returned as expected with size limit of 20"
        else
                rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 14"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-006: find groups - size limit not an integer"
        expmsg="ipa: ERROR: invalid 'sizelimit': must be an integer"
        command="ipa group-find --sizelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa group-find --sizelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd
}

timelimits()
{
    rlPhaseStartTest "ipa-group-find-007: find groups - time limit 0"
        ipa group-find --timelimit=0 > /tmp/groupfind.out
        result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "Limit of 5 groups returned as expected with time limit of 0"
        else
                rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 5"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-008: find groups - time limit not an integer"
        expmsg="ipa: ERROR: invalid 'timelimit': must be an integer"
        command="ipa group-find --timelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa group-find --timelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd
}

ingroups()
{
    rlPhaseStartTest "ipa-group-find-009: Negative Test of --in-groups in group-find"
	rlRun "ipa group-find --in-groups=$group1 | grep Group\ name: | grep $group2" 1 "Making sure that group $group2 does not come back when searching --in-groups=$group1"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-010: Positive Test of --in-groups in group-find"
	rlRun "ipa group-add-member --groups=$group2 $group1" 0
	rlRun "ipa group-find --in-groups=$group1 | grep $group2" 0 "Making sure that group $group2 comes back when searching --in-groups=$group1"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-011: Negative Test of --not-in-groups in group-find"
	rlRun "ipa group-find --not-in-groups=$group1 | grep Group\ name: | grep $group2" 1 "Making sure that group $group2 does not come back when searching --not-in-groups=$group1"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-012: Positive test of --not-in-groups in group-find"
	# We have one more group now "Trust admins", and this pushed group3 out of search limit. Hence setting the search
	# limit to 6 to accomodate this case.
	rlRun "ipa config-mod --searchrecordslimit=6"
	rlRun "ipa group-find --not-in-groups=$group1 | grep Group\ name: | grep $group3" 0 "Making sure that group $group3 comes back when searching --not-in-groups=$group1"
    rlPhaseEnd
}

groupsinhbacrules()
{
    rlPhaseStartTest "ipa-group-find-013: Positive test of --in-hbacrules in group-find"
	rlRun "ipa group-add --desc=$hgroup $hgroup" 0
	rlRun "ipa hbacrule-add-user --groups=$hgroup $hrule" 0 "adding group $hgroup to hbacrule $hrule"
	rlRun "ipa group-find --in-hbacrules=$hrule | grep $hgroup" 0 "make sure that $hbroup returns in a search constrained to $hrule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-014: Negative test of --in-hbacrules in group-find"
	rlRun "ipa group-find --in-hbacrules=$hrule | grep $group1" 1 "make sure that $group1 does not return in a search constrained to $hrule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-015: Positive test of --not-in-hbacrules in group-find"
	rlRun "ipa group-find --not-in-hbacrules=$hrule | grep $group1" 0 "make sure that $group1 returns in a search excluding hbacrule $hrule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-016: Negative test of --not-in-hbacrules in group-find"
	rlRun "ipa group-find --not-in-hbacrules=$hrule | grep $hgroup" 1 "make sure that $hgroup does not return in a search excluding hbacrule $hrule"
    rlPhaseEnd
}

groupsinsudorules()
{
    rlPhaseStartTest "ipa-group-find-017: Positive test of search of groups in a sudorules"
	ipa group-add --desc=$sgroup $sgroup
	rlRun "ipa sudorule-add-user --groups=$sgroup $srule" 0 "adding group $sgroup to sudorule $srule"
	rlRun "ipa group-find --in-sudorule=$srule | grep $sgroup" 0 "ensuring that group $sgroup is returned when searching for groups in a given sudorule $srule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-018: Negative test of search of groups in a sudorule"
	rlRun "ipa group-find --in-sudorule=$srule | grep $group2" 1 "ensuring that group $group2 is notreturned when searching for groups in a given sudorule $srule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-019: Positive test of search of groups not in a sudorule"
	rlRun "ipa group-find --not-in-sudorule=$srule | grep $group1" 0 "ensuring that group $group1 is returned when searching for groups not in a given sudorule $srule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-020: Negative test of search of groups not in a sudorule"
	rlRun "ipa group-find --not-in-sudorule=$srule | grep $sgroup" 1 "ensuring that group $sgroup is not returned when searching for groups not in a given sudorule $srule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-021: Positive test for search of groups --not-in-sudorule after group is removed from rule"
	rlRun "ipa sudorule-remove-user --groups=$sgroup $srule" 0 "removing group $sgroup from sudorule $srule"
	rlRun "ipa group-find --not-in-sudorule=$srule | grep $sgroup" 1 "ensuring that group $sgroup is returned when searching for groups not in a given sudorule $srule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-022: Negative test of search of groups not in a sudorule after group is removed from rule"
	rlRun "ipa group-find --in-sudorule=$srule | grep $sgroup" 1 "ensuring that group $sgroup is not returned when searching for groups not in a given sudorule $srule"
    rlPhaseEnd
}

usersingroups()
{
    rlPhaseStartTest "ipa-group-find-023: Positive search of group when filtering by user in group."
	rlRun "ipa group-add-member --users=$user1 $group1" 0 "adding user $user1 to group $group1"
	rlRun "ipa group-find --users=$user1 | grep $group1" 0 "Positive search of group when filtering by user in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-024: Negative search of group when filtering by user in group."
	rlRun "ipa group-find --users=$user2 | grep $group1" 1 "Negative search of group when filtering by user in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-025: Positive search of group when filtering by user not in group."
	rlRun "ipa group-find --no-users=$user2 | grep $group1" 0 "Positive search of group when filtering by user not in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-026: Negative search of group when filtering by user not in group."
	rlRun "ipa group-find --no-users=$user1 | grep 'Group name: $group1'" 1 "Negative search of group when filtering by user not in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-027: Positive search of group when filtering by user in group for removed user."
	rlRun "ipa group-remove-member --users=$user1 $group1" 0 "removing user $user1 from group $group1"
	rlRun "ipa group-find --no-users=$user1 | grep $group1" 0 "Positive search of group when filtering by user not in group for removed user."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-028: Negative search of group when filtering by user in group for removed user."
	rlRun "ipa group-find --users=$user1 | grep 'Group name: $group1'" 1 "Negative search of group when filtering by user in group for removed user."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-029: positive search of group when filtering by user not in group for removed user."
	rlRun "ipa group-find --no-users=$user1 | grep $group1" 0 "Positive search of group when filtering by user not in group."
    rlPhaseEnd
}

groupsingroups()
{
    rlPhaseStartTest "ipa-group-find-030: Positive search of group when filtering by group in group."
	rlRun "ipa group-find --groups=$group2 | grep 'Group name: $group1'" 0 "Positive search of group when filtering by groups in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-031: Negative search of group when filtering by group in group."
	rlRun "ipa group-find --groups=$group3 | grep 'Group name: $group1'" 1 "Negative search of group when filtering by groups in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-032: Positive search of group when filtering by group not in group."
	rlRun "ipa group-find --no-groups=$group3 | grep 'Group name: $group1'" 0 "Positive search of group when filtering by groups not in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-033: Negative search of group when filtering by groups not in group."
	rlRun "ipa group-find --no-groups=$group2 | grep 'Group name: $group1'" 1 "Negative search of group when filtering by groups not in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-034: Positive search of group when filtering by groups in group for removed group."
	rlRun "ipa group-remove-member --groups=$group2 $group1" 0 "removing group $group2 from group $group1"
	rlRun "ipa group-find --no-groups=$gb | grep 'Group name: $ga'" 0 "Positive search of group when filtering by group not in group for removed group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-035: Negative search of group when filtering by groups in group for removed group."
	rlRun "ipa group-find --groups=$group2 | grep 'Group name: $group1'" 1 "Negative search of group when filtering by groups in group for removed group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-036: Positive search of group when filtering by groups not in group for removed group."
	rlRun "ipa group-find --no-groups=$group1 | grep 'Group name: $group2'" 0 "Positive search of group when filtering by groups not in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-037: Negative Test of --not-in-groups in group-find after group removal"
	rlRun "ipa group-find --in-groups=$group1 | grep Group\ name: | grep $group3" 1 "Making sure that group $group3 does not come back when searching --in-groups=$group1"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-038: Positive test of --not-in-groups in group-find after group removal"
	rlRun "ipa group-find --not-in-groups=$group2 | grep Group\ name: | grep $group1" 0 "Making sure that group $group2 comes back when searching --not-in-groups=$group1"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-039: Negative test of --not-in-groups in group-find after group removal"
	rlRun "ipa group-find --in-groups=$group1 | grep Group\ name: | grep $group3" 1 "Making sure that group $group3 does not comes back when searching --in-groups=$group1"
    rlPhaseEnd
}

groupsinroles()
{
    rlPhaseStartTest "ipa-group-find-040: Positive search of group --in-role"
        rlRun "ipa role-add-member --groups=$group1 $admrole" 0 "adding group $group1 to admin role $admrole"
        rlRun "ipa group-find --in-roles=$admrole | grep $group1" 0 "Positive search for groups in admin role"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-041: Negative search of group --in-role"
        rlRun "ipa group-find --in-roles=$admrole | grep $group2" 1 "Negative search of groups in admin role"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-042: Positive search of group --not-in-role"
        rlRun "ipa group-find --not-in-roles=$admrole | grep $group2" 0 "Positive search of group not in admin role"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-043: Negative search of group --not-in-role"
        rlRun "ipa group-find --not-in-roles=$admrole | grep 'Group name: $group1'" 1 "Negative search of group not in admin role"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-044: Positive search of group --not-in-role - group removed from role"
        rlRun "ipa role-remove-member --groups=$group1 $admrole" 0 "removing group $group1 from admin role $admrole"
        rlRun "ipa group-find --not-in-role=$admrole | grep $group1" 0 "Positive search of group not in admin role"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-find-045: Negative search of group --in-role - group removed from role"
        rlRun "ipa group-find --in-role $admrole | grep 'Group name: $group1'" 1 "Negative search of group in admin role"
    rlPhaseEnd
}

groupfindcleanup()
{
    rlPhaseStartCleanup
	rlRun "ipa config-mod --searchrecordslimit=100" 0 "setting search records limit back to default"
        rlRun "ipa group-del $group1 $group2 $group3 group4 group5 group6 group7 group8 group9 group10 $hgroup $sgroup" 0 "Deleting test groups" 
	rlRun "ipa user-del $user1 $user2" 0 "Deleting test users"
	rlRun "ipa sudorule-del $srule" 0 "Deleting test sudo rule"
 	rlRun "ipa hbacrule-del $hrule" 0 "Deleting test hbac rule"
	rlRun "ipa role-del $admrole" 0 "Deleting test admin role"
	rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd
}
