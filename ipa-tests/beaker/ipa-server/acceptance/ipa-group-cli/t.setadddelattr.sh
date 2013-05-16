
########################################################################
# Test Sections 
########################################################################
setadddelattr()
{
  attrsetup
  setaddattr
  delattr
  multiop
  attrcleanup
}
########################################################################
grp="gmodtest"
user1="user1"
user2="user2"

attrsetup()
{

    rlPhaseStartSetup 
	rlRun "kinitAs $ADMINID $ADMINPWD" 0 "Kinit as admin user"
	rlRun "ipa group-add --desc=j-test $grp" 0 "Adding Test Group $grp"
	rlRun "ipa user-add --first=$user1 --last=$user1 $user1" 0 "Add test user $user1"
	rlRun "ipa user-add --first=$user2 --last=$user2 $user2" 0 "Add test user $user2"
    rlPhaseEnd
}

setaddattr()
{
    rlPhaseStartTest "ipa-group-setaddattr-001: setattr group that doesn't exist"
        command="ipa group-mod --setattr dn=\"cn=mynewDN,cn=groups,cn=accounts,dc=testrelm,dc=com\" doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-setaddattr-002: setattr and addattr on dn"
        command="ipa group-mod --setattr dn=\"cn=mynewDN,cn=groups,cn=accounts,dc=testrelm,dc=com\" $grp"
        expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa group-mod --addattr dn=\"cn=anothernewDN,cn=groups,cn=accounts,dc=testrelm,dc=com\" $grp"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-setaddattr-003: setattr and addattr on cn"
	# add a test group
	addGroup mynewgroup mynewgroup
	rlRun "setAttribute group cn blah mynewgroup" 0 "Setting new cn attribute"
	rlRun "verifyGroupAttr blah \"Group name\" blah" 0 "Verifying new cn attribute"
	expmsg="ipa: ERROR: cn: Only one value allowed."
        command="ipa group-mod --addattr cn=another blah"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	# delete the test group
	deleteGroup blah
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-setaddattr-004: setattr and addattr on description"
        rlRun "setAttribute group description new $grp" 0 "Setting attribute $attr to value of new."
        rlRun "verifyGroupAttr $grp Description new" 0 "Verifying group $attr was modified."
        # shouldn't be multivalue - additional add should fail
        command="ipa group-mod --addattr description=newer $grp"
        expmsg="ipa: ERROR: description: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-setaddattr-005: setattr and addattr on member"
	member1="uid=$user1,$USERDN"
	member2="uid=$user2,$USERDN"
	rlRun "setAttribute group member \"$member1\" $grp" 0 "setting member attribute member to $member1"
	rlRun "addAttribute group member \"$member2\" $grp" 0 "Adding attribute member $member2"
	rlRun "verifyGroupMember $user1 user $grp" 0 "member and memberOf attribute verification"
	rlRun "verifyGroupMember $user2 user $grp" 0 "member and memberOf attribute verification"
	ipa group-remove-member --users="$user1,$user2" $grp
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-setaddattr-006: setattr and addattr on memberOf"
        attr="memberOf"
        member1="uid=$user1,cn=users,cn=accounts,$BASEDN"
        member2="uid=$user2,cn=users,cn=accounts,$BASEDN"
        command="ipa group-mod --setattr $attr=\"$member1\" $grp"
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry 'cn=$grp,cn=groups,cn=accounts,$BASEDN'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa group-mod --addattr $attr=\"$member2\" $grp"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-setaddattr-007: setattr and addattr on ipauniqueid"
        command="ipa group-mod --setattr ipauniqueid=mynew-unique-id $grp"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa group-mod --addattr ipauniqueid=another-new-unique-id $grp"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-setaddattr-008: setattr and addattr on invalid attribute"
        command="ipa group-mod --setattr bad=test $grp"
        expmsg="ipa: ERROR: attribute \"bad\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa group-mod --setattr bad=test $grp"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-setaddattr-009: group-mod --addattr memberUid"
        rlRun "ipa group-mod --addattr memberUid=22344 $grp" 0 "Adding memberuid to $grp"
	rlRun "ipa group-find --all --raw $grp | grep 22344" 0 "Making sure new uid is in $grp"
    rlPhaseEnd
}

delattr()
{
    rlPhaseStartTest "ipa-group-delattr-001: --delattr memberUid"
	rlRun "ipa group-mod --delattr memberUid=22344 $grp" 0 "Deleting new memberUid"
	rlRun "ipa group-find --all --raw $grp | grep 22344" 1 "Making sure new uid is no longer in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-delattr-002: --delattr negative test case for Description"
	var=Description
	val=$(ipa group-find --all $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --delattr $var=$val $grp" 1 "trying to delete $var"
	rlRun "ipa group-find --all $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-delattr-003: group-mod --delattr negative test case for cn"
	var=cn
	val=$(ipa group-find --all --raw $grp | grep $var: | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --delattr $var='$val' $grp" 1 "trying to delete $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep '$val'" 0 "Making sure $var still exists as '$val' in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-delattr-004: group-mod --delattr negative test case for gidnumber"
	var=gidnumber
	val=$(ipa group-find --all --raw $grp | grep $var: | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --delattr $var=$val $grp" 1 "trying to delete $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-delattr-005: group-mod --delattr negative test case for ipauniqueid"
	var=ipauniqueid
	val=$(ipa group-find --all --raw $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --delattr $var=$val $grp" 1 "trying to delete $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-delattr-006: delattr test of member attributes"
    	#1) add a group    	
	#2) add a user to the group
    	#3) attempt to --delattr on the user's memberOf attribute (this should NOT be allowed)
    	#4) attempt to --delattr on the group's member attribute (this should be allowed)
    	#5) then verify that the user's memberOf attribute no longer exists.

        rlRun "ipa group-add-member --users=$user1 $grp" 0 "adding $user1 to group"
        rlRun "ipa user-find --all --raw $user1 | grep memberof | grep $grp" 0 "making sure that the memberof entry was added to user $user1"
        rlRun "ipa user-mod --delattr=memberof='cn=$grp,cn=groups,cn=accounts,$BASEDN' $user1" 1 "trying to delete memberof entry from $usr, this should fail"
        rlRun "ipa user-find --all --raw $user1 | grep memberof | grep $grp" 0 "making sure that the memberof entry is still in user $user1"
        rlRun "ipa group-mod --delattr=member='uid=$user1,cn=users,cn=accounts,$BASEDN' $grp" 0 "Removing the member entry from the group"
        rlRun "ipa user-find --all --raw $user1 | grep memberof | grep $grp" 1 "making sure that the memberof entry was removed from user $user1"
    rlPhaseEnd

}

multiop()
{
    var=memberuid
    rlPhaseStartTest "ipa-group-multiop-001: group-mod --delattr + --addattr null op for non existant var memberUid"
	val=928374
	rlRun "ipa group-mod --addattr $var=$val --delattr $var=$val $grp" 1 "Testing a multi-value manipulation for $var"
	rlRun "ipa group-find --all $grp | grep $var | grep $val" 1 "Making sure $var still does not exist in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-multiop-002: group-mod --setattr + --addattr null op for field in memberUid"
	val="928374"
	val2="abcde"
	rlRun "ipa group-mod --addattr $var=$val --setattr $var=$val2 $grp" 0 "Testing a multi-value manipulation for $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var exists as $val in $grp"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val2" 0 "Making sure $var exists as $val2 in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-multiop-003: group-mod --delattr + --addattr null op for Description"
	var=Description
	val=$(ipa group-find --all $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --addattr $var=$val --delattr $var=$val $grp" 1 "Testing a multi-value manipulation for $var"
	rlRun "ipa group-find --all $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-multiop-004: group-mod --delattr + --addattr null op for cn"
	var=cn
	val=$(ipa group-find --all --raw $grp | grep $var: | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --addattr $var='$val' --delattr $var='$val' $grp" 1 "Testing a multi-value manipulation for $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    var=gidnumber
    rlPhaseStartTest "ipa-group-multiop-005: group-mod --delattr + --addattr null op for gidnumber  - bug 870446"
	var=gidnumber
	val=$(ipa group-find --all --raw $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --addattr $var=$val --delattr $var=$val $grp" 1 "Testing a multi-value manipulation for $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-multiop-006: group-mod --delattr + --addattr null op for ipauniqueid"
	var=ipauniqueid
	val=$(ipa group-find --all --raw $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --addattr $var=$val --delattr $var=$val $grp" 1 "Testing a multi-value manipulation for $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-multiop-007: group-mod --setattr + --addattr null op for Description"
	var=Description
	val=$(ipa group-find --all $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	val2="alt-description"
	rlRun "ipa group-mod --addattr $var='$val' --setattr $var='$val2' $grp" 1 "ensuring that we are unable to write multiple definitions of $var"
	rlRun "ipa group-find --all $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
	rlRun "ipa group-find --all $grp | grep $var | grep $val2" 1 "Making sure $var does not contain $val2 in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-multiop-008: group-mod --setattr + --addattr null op for cn"
	var=cn
	val=$(ipa group-find --all --raw $grp | grep $var: | cut -d: -f2 | sed s/\ //g)
	val2="cn2"
	rlRun "ipa group-mod --addattr $var='$val' --setattr $var='$val2' $grp" 1 "ensuring that we are unable to write multiple definitions of $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val2" 1 "Making sure $var does not contain $val2 in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-multiop-009: group-mod --setattr + --addattr null op for gidnumber"
	var=gidnumber
	val=$(ipa group-find --all --raw $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	val2="23456"
	rlRun "ipa group-mod --addattr $var='$val' --setattr $var='$val2' $grp" 1 "ensuring that we are unable to write multiple definitions of $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val2" 1 "Making sure $var does not contain $val2 in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-multiop-010: group-mod --setattr + --addattr null op for ipauniqueid"
	var=ipauniqueid
	val=$(ipa group-find --all --raw $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	val2="b77627fc-5dae-11e1-a45f-111111111111"
	rlRun "ipa group-mod --addattr $var='$val' --setattr $var='$val2' $grp" 1 "ensuring that we are unable to write multiple definitions of $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val2" 1 "Making sure $var does not contain $val2 in $grp"
    rlPhaseEnd
}

attrcleanup()
{
    rlPhaseStartCleanup 
        rlRun "ipa group-del $grp" 0 "Deleting Test Group" 
	rlRun "ipa user-del $user1 $user2" 0 "Deleting Test Users"
	rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd
}
