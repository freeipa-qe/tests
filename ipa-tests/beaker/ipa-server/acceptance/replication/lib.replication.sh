

#########################
# User-related actions
#########################

add_newuser()
{
	rlPhaseStartTest "add user"
		# add manager user
		rlRun "ipa user-add --first=$manager --last=$manager $manager" 0 "Adding manager user: $manager"
		rlRun "ipa user-add --first=$firstName \
		                   --last=$lastName  \
		                   --cn=$cn \
		                   --displayname=$displayName  \
		                   --initials=$initials  \
		                   --homedir=$homedir  \
		                   --gecos=$gecos  \
		                   --shell=$shell  \
		                   --principal=$principal  \
		                   --email=$email  \
		                   --uid=$uid  \
		                   --gidnumber=$gidnumber  \
		                   --street=$street  \
		                   --city=$city  \
		                   --state=$state  \
		                   --postalcode=$postalcode  \
		                   --phone=$phone  \
		                   --mobile=$mobile  \
		                   --pager=$pager  \
		                   --fax=$fax  \
		                   --orgunit=$orgunit  \
		                   --title=$title  \
		                   --manager=$manager  \
		                   --carlicense=$carlicense \
		                   $login" \
		                   0 \
		                   "Add a new user"
	rlPhaseEnd
}

add_slave_user()
{
	rlPhaseStartTest "add user on slave"
		# add manager user
		rlRun "ipa user-add --first=$firstName \
		                   --last=$lastName  \
		                   --cn=$cn \
		                   --displayname=$displayName  \
		                   --initials=$initials  \
		                   --homedir=$homedir  \
		                   --gecos=$gecos  \
		                   --shell=$shell  \
		                   --principal=$principal  \
		                   --email=$email  \
		                   --uid=$uid  \
		                   --gidnumber=$gidnumber  \
		                   --street=$street  \
		                   --city=$city  \
		                   --state=$state  \
		                   --postalcode=$postalcode  \
		                   --phone=$phone  \
		                   --mobile=$mobile  \
		                   --pager=$pager  \
		                   --fax=$fax  \
		                   --orgunit=$orgunit  \
		                   --title=$title  \
		                   --manager=$manager  \
		                   --carlicense=$carlicense \
		                   slogin" \
		                   0 \
		                   "Add a new user on the slave"
	rlPhaseEnd

}

check_newuser()
{
	rlPhaseStartTest "check added user on master and slave"
		rlRun "verifyUserAttr $login \"First name\" $firstName" 0 "Verify user's first name"
		rlRun "verifyUserAttr $login \"Last name\" $lastName" 0 "Verify user's last name"
		rlRun "verifyUserAttr $login \"Full name\" $cn" 0 "Verify user's full name"
		rlRun "verifyUserAttr $login \"Display name\" $displayName" 0 "Verify user's display name"
		rlRun "verifyUserAttr $login \"Initials\" $initials" 0 "Verify user's initials"
		rlRun "verifyUserAttr $login \"Home directory\" $homedir" 0 "Verify user's home dir"
		rlRun "verifyUserAttr $login \"GECOS field\" $gecos" 0 "Verify user's gecos field"
		rlRun "verifyUserAttr $login \"Login shell\" $shell" 0 "Verify user's login shell"
		rlRun "verifyUserAttr $login \"Kerberos principal\" $principal" 0 "Verify user's kerberos principal"
		rlRun "verifyUserAttr $login \"Email address\" $email" 0 "Verify user's email addr"
		rlRun "verifyUserAttr $login \"UID\" $uid" 0 "Verify user's uid"
		rlRun "verifyUserAttr $login \"GID\" $gidnumber" 0 "Verify user's gid"
		rlRun "verifyUserAttr $login \"Street address\" $street" 0 "Verify user's street address"
		rlRun "verifyUserAttr $login \"City\" $city" 0 "Verify user's city"
		rlRun "verifyUserAttr $login \"State/Province\" $state" 0 "Verify user's State"
		rlRun "verifyUserAttr $login \"ZIP\" $postalcode" 0 "Verify user's zip"
		rlRun "verifyUserAttr $login \"Telephone Number\" $phone" 0 "Verify user's Telephone Number"
		rlRun "verifyUserAttr $login \"Mobile Telephone Number\" $mobile" 0 "Verify user's Mobile Telephone Number"
		rlRun "verifyUserAttr $login \"Pager Number\" $pager" 0 "Verify user's Pager Number"
		rlRun "verifyUserAttr $login \"Fax Number\" $fax" 0 "Verify user's Fax Number"
		rlRun "verifyUserAttr $login \"Org. Unit\" $orgunit" 0 "Verify user's Org. Unit"
		rlRun "verifyUserAttr $login \"Job Title\" $title" 0 "Verify user's Job Title"
		rlRun "verifyUserAttr $login \"Manager\" $manager" 0 "Verify user's Manager"
		rlRun "verifyUserAttr $login \"Car License\" $carlicense" 0 "Verify user's Car License"

		rlRun "verifyUserAttr slogin \"First name\" $firstName" 0 "Verify user's first name"
		rlRun "verifyUserAttr slogin \"Last name\" $lastName" 0 "Verify user's last name"
		rlRun "verifyUserAttr slogin \"Full name\" $cn" 0 "Verify user's full name"
		rlRun "verifyUserAttr slogin \"Display name\" $displayName" 0 "Verify user's display name"
		rlRun "verifyUserAttr slogin \"Initials\" $initials" 0 "Verify user's initials"
		rlRun "verifyUserAttr slogin \"Home directory\" $homedir" 0 "Verify user's home dir"
		rlRun "verifyUserAttr slogin \"GECOS field\" $gecos" 0 "Verify user's gecos field"
		rlRun "verifyUserAttr slogin \"Login shell\" $shell" 0 "Verify user's login shell"
		rlRun "verifyUserAttr slogin \"Kerberos principal\" $principal" 0 "Verify user's kerberos principal"
		rlRun "verifyUserAttr slogin \"Email address\" $email" 0 "Verify user's email addr"
		rlRun "verifyUserAttr slogin \"UID\" $uid" 0 "Verify user's uid"
		rlRun "verifyUserAttr slogin \"GID\" $gidnumber" 0 "Verify user's gid"
		rlRun "verifyUserAttr slogin \"Street address\" $street" 0 "Verify user's street address"
		rlRun "verifyUserAttr slogin \"City\" $city" 0 "Verify user's city"
		rlRun "verifyUserAttr slogin \"State/Province\" $state" 0 "Verify user's State"
		rlRun "verifyUserAttr slogin \"ZIP\" $postalcode" 0 "Verify user's zip"
		rlRun "verifyUserAttr slogin \"Telephone Number\" $phone" 0 "Verify user's Telephone Number"
		rlRun "verifyUserAttr slogin \"Mobile Telephone Number\" $mobile" 0 "Verify user's Mobile Telephone Number"
		rlRun "verifyUserAttr slogin \"Pager Number\" $pager" 0 "Verify user's Pager Number"
		rlRun "verifyUserAttr slogin \"Fax Number\" $fax" 0 "Verify user's Fax Number"
		rlRun "verifyUserAttr slogin \"Org. Unit\" $orgunit" 0 "Verify user's Org. Unit"
		rlRun "verifyUserAttr slogin \"Job Title\" $title" 0 "Verify user's Job Title"
		rlRun "verifyUserAttr slogin \"Manager\" $manager" 0 "Verify user's Manager"
		rlRun "verifyUserAttr slogin \"Car License\" $carlicense" 0 "Verify user's Car License"

	rlPhaseEnd
}

modify_newuser()
{
	rlPhaseStartTest "modify new user"  
		# add new manager user
		rlRun "ipa user-add --first=$manager_updated --last=$manager_updated $manager_updated" 0 "Adding new manager user: $manager_updated"
		rlRun "ipa user-mod --first=$firstName_updated \
		                   --last=$lastName_updated  \
		                   --cn=$cn_updated \
		                   --displayname=$displayName_updated  \
		                   --initials=$initials_updated  \
		                   --homedir=$homedir_updated  \
		                   --gecos=$gecos_updated  \
		                   --shell=$shell_updated  \
		                   --email=$email_updated  \
		                   --street=$street_updated  \
		                   --city=$city_updated  \
		                   --state=$state_updated  \
		                   --postalcode=$postalcode_updated  \
		                   --phone=$phone_updated  \
		                   --mobile=$mobile_updated  \
		                   --pager=$pager_updated  \
		                   --fax=$fax_updated  \
		                   --orgunit=$orgunit_updated  \
		                   --title=$title_updated  \
		                   --manager=$manager_updated  \
		                   --carlicense=$carlicense_updated \
		                   --rename=$login_updated \
		                   $1" \
		                   0 \
		                   "Modify the new user"
	rlPhaseEnd
}

modify_slave_user()
{
	rlPhaseStartTest "modify new user"  
		# add new manager user
		rlRun "ipa user-mod --first=$firstName_updated \
		                   --last=$lastName_updated  \
		                   --cn=$cn_updated \
		                   --displayname=$displayName_updated  \
		                   --initials=$initials_updated  \
		                   --homedir=$homedir_updated  \
		                   --gecos=$gecos_updated  \
		                   --shell=$shell_updated  \
		                   --email=$email_updated  \
		                   --street=$street_updated  \
		                   --city=$city_updated  \
		                   --state=$state_updated  \
		                   --postalcode=$postalcode_updated  \
		                   --phone=$phone_updated  \
		                   --mobile=$mobile_updated  \
		                   --pager=$pager_updated  \
		                   --fax=$fax_updated  \
		                   --orgunit=$orgunit_updated  \
		                   --title=$title_updated  \
		                   --manager=$manager_updated  \
		                   --carlicense=$carlicense_updated \
		                   --rename=$login_updated \
		                   suser" \
		                   0 \
		                   "Modify the new user"
	rlPhaseEnd
}


check_modifieduser()
{
	rlPhaseStartTest "check modified user"
		rlRun "verifyUserAttr $login_updated \"First name\" $firstName_updated" 0 "Verify user's first name"
		rlRun "verifyUserAttr $login_updated \"Last name\" $lastName_updated" 0 "Verify user's last name"
		rlRun "verifyUserAttr $login_updated \"Full name\" $cn_updated" 0 "Verify user's full name"
		rlRun "verifyUserAttr $login_updated \"Display name\" $displayName_updated" 0 "Verify user's display name"
		rlRun "verifyUserAttr $login_updated \"Initials\" $initials_updated" 0 "Verify user's initials"
		rlRun "verifyUserAttr $login_updated \"Home directory\" $homedir_updated" 0 "Verify user's home dir"
		rlRun "verifyUserAttr $login_updated \"GECOS field\" $gecos_updated" 0 "Verify user's gecos field"
		rlRun "verifyUserAttr $login_updated \"Login shell\" $shell_updated" 0 "Verify user's login_updated shell"
		rlRun "verifyUserAttr $login_updated \"Email address\" $email_updated" 0 "Verify user's email addr"
		rlRun "verifyUserAttr $login_updated \"Street address\" $street_updated" 0 "Verify user's street address"
		rlRun "verifyUserAttr $login_updated \"City\" $city_updated" 0 "Verify user's city"
		rlRun "verifyUserAttr $login_updated \"State/Province\" $state_updated" 0 "Verify user's State"
		rlRun "verifyUserAttr $login_updated \"ZIP\" $postalcode_updated" 0 "Verify user's zip"
		rlRun "verifyUserAttr $login_updated \"Telephone Number\" $phone_updated" 0 "Verify user's Telephone Number"
		rlRun "verifyUserAttr $login_updated \"Mobile Telephone Number\" $mobile_updated" 0 "Verify user's Mobile Telephone Number"
		rlRun "verifyUserAttr $login_updated \"Pager Number\" $pager_updated" 0 "Verify user's Pager Number"
		rlRun "verifyUserAttr $login_updated \"Fax Number\" $fax_updated" 0 "Verify user's Fax Number"
		rlRun "verifyUserAttr $login_updated \"Org. Unit\" $orgunit_updated" 0 "Verify user's Org. Unit"
		rlRun "verifyUserAttr $login_updated \"Job Title\" $title_updated" 0 "Verify user's Job Title"
		rlRun "verifyUserAttr $login_updated \"Manager\" $manager_updated" 0 "Verify user's Manager"
		rlRun "verifyUserAttr $login_updated \"Car License\" $carlicense_updated" 0 "Verify user's Car License"
	rlPhaseEnd
}

check_slave_modifieduser()
{
	rlPhaseStartTest "check user modified on slave"
		rlRun "verifyUserAttr slogin \"First name\" $firstName_updated" 0 "Verify user's first name"
		rlRun "verifyUserAttr slogin \"Last name\" $lastName_updated" 0 "Verify user's last name"
		rlRun "verifyUserAttr slogin \"Full name\" $cn_updated" 0 "Verify user's full name"
		rlRun "verifyUserAttr slogin \"Display name\" $displayName_updated" 0 "Verify user's display name"
		rlRun "verifyUserAttr slogin \"Initials\" $initials_updated" 0 "Verify user's initials"
		rlRun "verifyUserAttr slogin \"Home directory\" $homedir_updated" 0 "Verify user's home dir"
		rlRun "verifyUserAttr slogin \"GECOS field\" $gecos_updated" 0 "Verify user's gecos field"
		rlRun "verifyUserAttr slogin \"Login shell\" $shell_updated" 0 "Verify user's login_updated shell"
		rlRun "verifyUserAttr slogin \"Email address\" $email_updated" 0 "Verify user's email addr"
		rlRun "verifyUserAttr slogin \"Street address\" $street_updated" 0 "Verify user's street address"
		rlRun "verifyUserAttr slogin \"City\" $city_updated" 0 "Verify user's city"
		rlRun "verifyUserAttr slogin \"State/Province\" $state_updated" 0 "Verify user's State"
		rlRun "verifyUserAttr slogin \"ZIP\" $postalcode_updated" 0 "Verify user's zip"
		rlRun "verifyUserAttr slogin \"Telephone Number\" $phone_updated" 0 "Verify user's Telephone Number"
		rlRun "verifyUserAttr slogin \"Mobile Telephone Number\" $mobile_updated" 0 "Verify user's Mobile Telephone Number"
		rlRun "verifyUserAttr slogin \"Pager Number\" $pager_updated" 0 "Verify user's Pager Number"
		rlRun "verifyUserAttr slogin \"Fax Number\" $fax_updated" 0 "Verify user's Fax Number"
		rlRun "verifyUserAttr slogin \"Org. Unit\" $orgunit_updated" 0 "Verify user's Org. Unit"
		rlRun "verifyUserAttr slogin \"Job Title\" $title_updated" 0 "Verify user's Job Title"
		rlRun "verifyUserAttr slogin \"Manager\" $manager_updated" 0 "Verify user's Manager"
		rlRun "verifyUserAttr slogin \"Car License\" $carlicense_updated" 0 "Verify user's Car License"
	rlPhaseEnd
}


delete_user()
{
	rlPhaseStartTest "delete new user"
		rlRun "ipa user-del $login_updated" 0 "Deleted user: $login_updated"
		rlRun "ipa user-del $manager" 0 "Delete original manager user: $manager"
		rlRun "ipa user-del $manager_updated" 0 "Delete udpated manager user: $manager_updated"
	rlPhaseEnd
}

delete_slave_user()
{
	rlPhaseStartTest "delete new user from slave"
		rlRun "ipa user-del slogin" 0 "Deleted user: $login_updated"
	rlPhaseEnd
}

check_deleteduser()
{
	rlPhaseStartTest "check deleted user"
		command="ipa user-show $login_updated"
		expmsg="ipa: ERROR: $login_updated: user not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted user"

		command="ipa user-show $manager"
                expmsg="ipa: ERROR: $manager: user not found"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted original manager user"

		command="ipa user-show $manager_updated"
                expmsg="ipa: ERROR: $manager_updated: user not found"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted updated manager user"

		command="ipa user-show slogin"
		expmsg="ipa: ERROR: $login_updated: user not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted user"

	rlPhaseEnd
}

#########################
# Group-related actions
#########################
add_newgroup()
{
	rlPhaseStartTest "add new group"
		rlRun "ipa group-add --desc=$desc --gid=$gid $groupName" 0 "Add a new group"
		rlRun "ipa group-add --desc=$desc_nonposix --nonposix $groupName_nonposix" 0 "Add a new non-posixgroup"
		rlRun "ipa user-add --first=$groupMember1 --last=$groupMember1 $groupMember1" 0 "Add users to be added as members to the group"
		rlRun "ipa user-add --first=$groupMember2 --last=$groupMember2 $groupMember2" 0 "Add users to be added as members to the group"
		rlRun "ipa group-add-member --users=$groupMember1,$groupMember2 --groups=$groupName_nonposix $groupName" 0 "add members to this new group"
	rlPhaseEnd
}

add_slave_group()
{
	rlPhaseStartTest "add new group"
		rlRun "ipa group-add --desc=$desc --gid=$slaveGid $slaveGroupName" 0 "Add a new group"
		rlRun "ipa group-add-member --users=$groupMember1,$groupMember2 --groups=$groupName_nonposix $slaveGroupName" 0 "add members to this new group on the slave"
	rlPhaseEnd
}

check_newgroup()
{
	rlPhaseStartTest "check new group"
		rlRun "verifyGroupAttr $groupName \"dn\" $dn" 0 "Verify group's dn"
		rlRun "verifyGroupAttr $groupName \"Group name\" $groupName" 0 "Verify group's name"
		rlRun "verifyGroupAttr $slaveGroupName \"Group name\" $slaveGroupName" 0 "Verify group's name"
		rlRun "verifyGroupAttr $groupName \"Description\" $desc" 0 "Verify group's description"
		if [ "$1" == "nonposix" ] ; then 
		    # should not have a GID
		    rlLog "TODO"
		else
		   rlRun "verifyGroupAttr $groupName \"GID\" $gid" 0 "Verify group's gid"
		fi
		rlRun "verifyGroupAttr $groupName \"Member users\" \"$groupMember1, $groupMember2\"" 0 "Verify group's user members"
		rlRun "verifyGroupAttr $slaveGroupName \"Member users\" \"$groupMember1, $groupMember2\"" 0 "Verify group's user members"
		rlRun "verifyGroupAttr $groupName \"Member groups\" $groupName_nonposix" 0 "Verify group's group members"
	rlPhaseEnd
}

modify_newgroup()
{
	rlPhaseStartTest "modify new group"
		 rlRun "ipa group-mod $1 --desc=$desc_updated --rename=$groupName_updated" 0 "Modify the group"
		 rlRun "ipa group-remove-member $groupName_updated --users=$groupMember1_updated --groups=$group_nonposix_updated" 0 "remove members from this group"
	rlPhaseEnd
}

modify_slave_group()
{
	rlPhaseStartTest "modify group added on the slave"
		 rlRun "ipa group-mod $slaveGroupName --desc=$desc_updated --rename=$slave_groupName_updated" 0 "Modify the group"
		 rlRun "ipa group-remove-member $slave_groupName_updated --users=$groupMember1_updated --groups=$group_nonposix_updated" 0 "remove members from this group"
	rlPhaseEnd
}

check_modifiedgroup()
{
	rlPhaseStartTest "check modified group"
		#rlRun "verifyGroupAttr $groupName_updated \"dn\" $dn_updated" 0 "Verify group's dn"
		rlRun "verifyGroupAttr $groupName_updated \"Group name\" $groupName_updated" 0 "Verify group's name"
		rlRun "verifyGroupAttr $groupName_updated \"Description\" $desc_updated" 0 "Verify group's description"
		rlRun "verifyGroupAttr $groupName_updated \"Member users\" $groupMember2_updated" 0 "Verify group's user members"
	rlPhaseEnd
}

check_slave_modifiedgroup()
{
	rlPhaseStartTest "check group modifed on slave"
		#rlRun "verifyGroupAttr $slave_groupName_updated \"dn\" $slave_dn_updated" 0 "Verify group's dn"
		rlRun "verifyGroupAttr $slave_groupName_updated \"Group name\" $groupName_updated" 0 "Verify group's name"
		rlRun "verifyGroupAttr $slave_groupName_updated \"Description\" $desc_updated" 0 "Verify group's description"
		rlRun "verifyGroupAttr $slave_groupName_updated \"Member users\" $groupMember2_updated" 0 "Verify group's user members"
	rlPhaseEnd
}

delete_group()
{
	rlPhaseStartTest "delete group"
		rlRun "ipa group-del $groupName_updated" 0 "Deleted group"
	rlPhaseEnd
}

delete_slave_objects()
{
	rlPhaseStartTest "delete group"
		rlRun "ipa group-del $slave_groupName_updated" 0 "Deleted group"
	rlPhaseEnd
}

check_deletedgroup()
{
	rlPhaseStartTest "check deleted group"
		command="ipa group-show $groupName_updated"
		expmsg="ipa: ERROR: $groupName_updated: group not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted group"
	rlPhaseEnd
	rlPhaseStartTest "check deleted group from slave"
		command="ipa group-show $slave_groupName_updated"
		expmsg="ipa: ERROR: $slave_groupName_updated: group not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted group"
	rlPhaseEnd
}

#########################
# Host-related actions
#########################

add_newhost()
{
	rlPhaseStartTest "add new host"
		rlRun "ipa host-add --desc=$hostDesc \
		                  --location=$hostLocation \
		                  --platform=$hostPlatform \
		                  --os=$hostOS \
		                  --password=$hostPassword \
		                  --ip-address=$hostIPaddress \
		                  --no-reverse \
		                  $newHost" \
		                  0 \
		                  "Add a new host"
		rlRun "ipa host-add --no-reverse \
		                   --ip-address=$managedByHostIP \
		                   $managedByHost" \
		                   0 \
		                  "Add new host to use as managed-by host"
		rlRun "ipa  host-add-managedby --hosts=$managedByHost $newHost" 0 "Add managed-by host"
	rlPhaseEnd
}

slaveHost="nhl2"
add_slave_host()
{
	rlPhaseStartTest "add new host"
		rlRun "ipa host-add --desc=$hostDesc \
		                  --location=$hostLocation \
		                  --platform=$hostPlatform \
		                  --os=$hostOS \
		                  --password=$hostPassword \
		                  --ip-address=$hostIPaddress \
		                  --no-reverse \
		                  $slaveHost" \
		                  0 \
		                  "Add a new host"
}

check_newhost()
{
	rlPhaseStartTest "check new host"
		rlRun "verifyHostAttr $newHost \"Host name\" $newHost" 0 "Verify host's name"
		rlRun "verifyHostAttr $newHost \"Description\" $hostDesc" 0 "Verify host's description"
		rlRun "verifyHostAttr $newHost \"Location\" $hostLocation" 0 "Verify host's location"
		rlRun "verifyHostAttr $newHost \"Platform\" $hostPlatform" 0 "Verify host's platform"
		rlRun "verifyHostAttr $newHost \"Operating system\" $hostOS" 0 "Verify host's OS"
		rlRun "verifyHostAttr $slaveHost \"Host name\" $slaveHost" 0 "Verify host's name"
		rlRun "verifyHostAttr $slaveHost \"Description\" $hostDesc" 0 "Verify host's description"
		rlRun "verifyHostAttr $slaveHost \"Location\" $hostLocation" 0 "Verify host's location"
		rlRun "verifyHostAttr $slaveHost \"Platform\" $hostPlatform" 0 "Verify host's platform"
		rlRun "verifyHostAttr $slaveHost \"Operating system\" $hostOS" 0 "Verify host's OS"

	rlPhaseEnd
}

modify_newhost()
{
	rlPhaseStartTest "modify new host"
		rlRun "ipa host-mod --location=$hostLocation_updated \
		                  --platform=$hostPlatform_updated \
		                  --os=$hostOS_updated \
		                  --addattr=locality=$hostLocality_updated \
		                  --setattr=description=$hostDesc_updated \
		                  $newHost_updated" \
		                  0 \
		                  "Modify the host"
		rlRun "ipa host-remove-managedby --hosts=$managedByHost_updated $newHost_updated" 0 "Remove managed-by host"
	rlPhaseEnd
}

modify_slave_host()
{
	rlPhaseStartTest "modify new host"
		rlRun "ipa host-mod --location=$hostLocation_updated \
		                  --platform=$hostPlatform_updated \
		                  --os=$hostOS_updated \
		                  --addattr=locality=$hostLocality_updated \
		                  --setattr=description=$hostDesc_updated \
		                  $slaveHost" \
		                  0 \
		                  "Modify the host"
}

check_modifiedhost()
{
	rlPhaseStartTest "check modified host"
		rlRun "verifyHostAttr $newHost_updated \"Description\" $hostDesc_updated" 0 "Verify host's description"
		rlRun "verifyHostAttr $newHost_updated \"Locality\" $hostLocality_updated" 0 "Verify host's locality"
		rlRun "verifyHostAttr $newHost_updated \"Location\" $hostLocation_updated" 0 "Verify host's location"
		rlRun "verifyHostAttr $newHost_updated \"Platform\" $hostPlatform_updated" 0 "Verify host's platform"
		rlRun "verifyHostAttr $newHost_updated \"Operating system\" $hostOS_updated" 0 "Verify host's OS"
		rlRun "verifyHostAttr $newHost_updated \"Managed by\" $newHost_updated" 0 "Verify host's Managed-by list"
	rlPhaseEnd
}

check_slave_modifiedhost()
{
	rlPhaseStartTest "check modified host"
		rlRun "verifyHostAttr $slaveHost \"Description\" $hostDesc_updated" 0 "Verify host's description"
		rlRun "verifyHostAttr $slaveHost \"Locality\" $hostLocality_updated" 0 "Verify host's locality"
		rlRun "verifyHostAttr $slaveHost \"Location\" $hostLocation_updated" 0 "Verify host's location"
		rlRun "verifyHostAttr $slaveHost \"Platform\" $hostPlatform_updated" 0 "Verify host's platform"
		rlRun "verifyHostAttr $slaveHost \"Operating system\" $hostOS_updated" 0 "Verify host's OS"
	rlPhaseEnd
}

delete_host()
{
	rlPhaseStartTest "Deleting host"
		rlRun "ipa host-del $newHost_updated" 0 "Deleting $newHost_updated"
	rlPhaseEnd
}

delete_slave_host()
{
	rlPhaseStartTest "Deleting host from slave"
		rlRun "ipa host-del $slaveHost" 0 "Deleting $slaveHost"
	rlPhaseEnd
}

check_deletedhost()
{
	rlPhaseStartTest "check for deleted host"
		command="ipa host-show $newHost"
		expmsg="ipa: ERROR: $newHost: host not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted host"
		command="ipa host-show $slaveHost"
		expmsg="ipa: ERROR: $slaveHost: host not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted host"

	rlPhaseEnd
}

#############################
# Hostgroup-related actions
#############################
add_newhostgroup()
{
	rlPhaseStartTest "add hostgroup"
		rlRun "ipa hostgroup-add --desc=$hostgroup_groupMember1  $hostgroup_groupMember1" 0 "Add a hostgroup to be added as member"
		rlRun "ipa hostgroup-add --desc=$hostgroup_groupMember1_updated  $hostgroup_groupMember1_updated" 0 "Add another hostgroup to be added as member"

		rlRun "ipa hostgroup-add --desc=\"$hostgroup_desc\" \
		                         --addattr member=\"cn=$hostgroup_groupMember1,cn=hostgroups,cn=accounts,dc=$DOMAIN\" \
		                         $hostgroup " \
		                         0 \
		                         "Add a new hostgroup, with a hostgroup member"
		rlRun "ipa hostgroup-add-member --hosts=$managedByHost $hostgroup" 0 "Add a host member"
	rlPhaseEnd
}

add_slave_hostgroup()
{
	rlPhaseStartTest "add hostgroup on slave"
		rlRun "ipa hostgroup-add --desc=$hostgroup_groupMember2  $hostgroup_groupMember2" 0 "Add a hostgroup to be added as member"
		rlRun "ipa hostgroup-add --desc=$hostgroup_groupMember2_updated  $hostgroup_groupMember2_updated" 0 "Add another hostgroup to be added as member"

		rlRun "ipa hostgroup-add --desc=\"$hostgroup_desc\" \
		                         --addattr member=\"cn=$hostgroup_groupMember2,cn=hostgroups,cn=accounts,dc=$DOMAIN\" \
		                         $hostgroup2 " \
		                         0 \
		                         "Add a new hostgroup, with a hostgroup member"
		rlRun "ipa hostgroup-add-member --hosts=$managedByHost $hostgroup2" 0 "Add a host member"
	rlPhaseEnd

}

check_newhostgroup()
{
	rlPhaseStartTest "add new hostgroup"
		rlRun "verifyHostGroupAttr $hostgroup \"Host-group\" $hostgroup" 0 "Verify Hostgroup's name" 
		rlRun "verifyHostGroupAttr $hostgroup \"Description\" $hostgroup_desc" 0 "Verify Hostgroup's description" 
		rlRun "verifyHostGroupMember $managedByHost host $hostgroup" 0 "Verify Hostgroup's Member hosts" 
		rlRun "verifyHostGroupMember $hostgroup_groupMember1 hostgroup $hostgroup" 0 "Verify Hostgroup's Member hosts" 
		rlRun "verifyHostGroupAttr $hostgroup2 \"Host-group\" $hostgroup2" 0 "Verify Hostgroup's name" 
		rlRun "verifyHostGroupAttr $hostgroup2 \"Description\" $hostgroup_desc" 0 "Verify Hostgroup's description" 
		rlRun "verifyHostGroupMember $managedByHost host $hostgroup2" 0 "Verify Hostgroup's Member hosts" 
		rlRun "verifyHostGroupMember $hostgroup_groupMember2 hostgroup $hostgroup2" 0 "Verify Hostgroup's Member hosts" 

	rlPhaseEnd
}

modify_newhostgroup()
{
	rlPhaseStartTest "modify hostgroup"
		rlRun "ipa hostgroup-mod --desc=\"$hostgroup_desc_updated\" \
		                          $hostgroup_updated" \
		                          0 \
		                          "Modify hostgroup"
		rlRun "ipa hostgroup-remove-member --hosts=$managedByHost_updated $hostgroup_updated" 0 "Remove a host member"
# TODO: --setattr member=\"cn=$hostgroup_groupMember1_updated,cn=hostgroups,cn=accounts,dc=$DOMAIN\" \
	rlPhaseEnd
}

modify_slave_hostgroup()
{
	rlPhaseStartTest "modify hostgroup on slave"
		rlRun "ipa hostgroup-mod --desc=\"$hostgroup_desc_updated\" \
		                          $hostgroup2" \
		                          0 \
		                          "Modify hostgroup"
		rlRun "ipa hostgroup-remove-member --hosts=$managedByHost_updated $hostgroup2" 0 "Remove a host member"
# TODO: --setattr member=\"cn=$hostgroup_groupMember1_updated,cn=hostgroups,cn=accounts,dc=$DOMAIN\" \
	rlPhaseEnd
}

check_modifiedhostgroup()
{
	rlPhaseStartTest "check modified hostgroup"
		rlRun "verifyHostGroupAttr $hostgroup_updated \"Host-group\" $hostgroup_updated" 0 "Verify Hostgroup's name" 
		rlRun "verifyHostGroupAttr $hostgroup_updated \"Description\" $hostgroup_desc_updated" 0 "Verify Hostgroup's description" 
# TODO:    rlRun "verifyHostGroupMember $hostgroup_groupMember1_updated hostgroup $hostgroup_updated" 0 "Verify Hostgroup's Member hosts" 
	rlPhaseEnd
}

check_slave_modifedhostgroup()
{
	rlPhaseStartTest "check modified hostgroup from slave"
		rlRun "verifyHostGroupAttr $hostgroup2 \"Host-group\" $hostgroup_updated" 0 "Verify Hostgroup's name" 
		rlRun "verifyHostGroupAttr $hostgroup2 \"Description\" $hostgroup_desc_updated" 0 "Verify Hostgroup's description" 
	rlPhaseEnd
}

delete_hostgroup()
{
	rlPhaseStartTest "delete hostgroup"
		rlRun "ipa hostgroup-del $hostgroup_updated" 0 "Delete the hostgroup" 
	rlPhaseEnd
}

delete_slave_hostgroup()
{
	rlPhaseStartTest "delete hostgroup"
		rlRun "ipa hostgroup-del $hostgroup2" 0 "Delete the hostgroup" 
	rlPhaseEnd
}

check_deletedhostgroup()
{
	rlPhaseStartTest "check deleted hostgroup"
		command="ipa hostgroup-show $hostgroup_updated"
		expmsg="ipa: ERROR: $hostgroup_updated: hostgroup not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted hostgroup"
		command="ipa hostgroup-show $hostgroup1"
		expmsg="ipa: ERROR: $hostgroup2: hostgroup not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted hostgroup"

	rlPhaseEnd
}

###########################
# Netgroup-related actions
###########################
add_newnetgroup()
{
	rlPhaseStartTest "add netgroup"
		rlRun "ipa netgroup-add --desc=$netgroup_groupMember1 $netgroup_groupMember1" 0 "Add netgroup to be added as a member"
		rlRun "ipa netgroup-add --desc=$netgroup_desc --nisdomain=$DOMAIN --usercat=all --hostcat=all $netgroup" 0 "Add new netgroup"
		rlRun "ipa netgroup-add-member --users=$groupMember1 --groups=$groupName_nonposix --hosts=$managedByHost --hostgroups=$hostgroup_groupMember1 --netgroups=$netgroup_groupMember1 $netgroup" 0 "Add members to netgroup"
	rlPhaseEnd
}

add_slave_netgroup()
{
	rlPhaseStartTest "add netgroup"
		rlRun "ipa netgroup-add --desc=$netgroup_groupMember1 $netgroup_groupMember2" 0 "Add netgroup to be added as a member"
		rlRun "ipa netgroup-add --desc=$netgroup_desc --nisdomain=$DOMAIN --usercat=all --hostcat=all $netgroup" 0 "Add new netgroup"
		rlRun "ipa netgroup-add-member --users=$groupMember2 --groups=$groupName_nonposix --hosts=$managedByHost --hostgroups=$hostgroup_groupMember1 --netgroups=$netgroup_groupMember1 $netgroup2" 0 "Add members to netgroup"
	rlPhaseEnd
}

check_newnetgroup()
{
	rlPhaseStartTest "check netgroup"
		rlRun "verifyNetgroupAttr $netgroup \"Netgroup name\" $netgroup" 0 "Verify netgroup's name"
		rlRun "verifyNetgroupAttr $netgroup \"Description\" $netgroup_desc" 0 "Verify netgroup's Description"
		rlRun "verifyNetgroupAttr $netgroup \"NIS domain name\" $DOMAIN" 0 "Verify netgroup's NIS domain name"
		rlRun "verifyNetgroupAttr $netgroup \"User category\" \"all\"" 0 "Verify netgroup's User category"
		rlRun "verifyNetgroupAttr $netgroup \"Host category\" \"all\"" 0 "Verify netgroup's Host category"
		rlRun "verifyNetgroupAttr $netgroup \"Member netgroups\" $netgroup_groupMember1" 0 "Verify netgroup's Member netgroups"
		rlRun "verifyNetgroupAttr $netgroup \"Member User\" $groupMember1" 0 "Verify netgroup's Member User"
		rlRun "verifyNetgroupAttr $netgroup \"Member Group\" $groupName_nonposix" 0 "Verify netgroup's Member Group"
		rlRun "verifyNetgroupAttr $netgroup \"Member Host\" $managedByHost" 0 "Verify netgroup's Member Host"
		rlRun "verifyNetgroupAttr $netgroup \"Member Hostgroup\" $hostgroup_groupMember1" 0 "Verify netgroup's Member Hostgroup"
		rlRun "verifyNetgroupAttr $netgroup2 \"Netgroup name\" $netgroup2" 0 "Verify netgroup's name"
		rlRun "verifyNetgroupAttr $netgroup2 \"Description\" $netgroup_desc" 0 "Verify netgroup's Description"
		rlRun "verifyNetgroupAttr $netgroup2 \"NIS domain name\" $DOMAIN" 0 "Verify netgroup's NIS domain name"
		rlRun "verifyNetgroupAttr $netgroup2 \"User category\" \"all\"" 0 "Verify netgroup's User category"
		rlRun "verifyNetgroupAttr $netgroup2 \"Host category\" \"all\"" 0 "Verify netgroup's Host category"
		rlRun "verifyNetgroupAttr $netgroup2 \"Member netgroups\" $netgroup_groupMember1" 0 "Verify netgroup's Member netgroups"
		rlRun "verifyNetgroupAttr $netgroup2 \"Member User\" $groupMember1" 0 "Verify netgroup's Member User"
		rlRun "verifyNetgroupAttr $netgroup2 \"Member Group\" $groupName_nonposix" 0 "Verify netgroup's Member Group"
		rlRun "verifyNetgroupAttr $netgroup2 \"Member Host\" $managedByHost" 0 "Verify netgroup's Member Host"
		rlRun "verifyNetgroupAttr $netgroup2 \"Member Hostgroup\" $hostgroup_groupMember1" 0 "Verify netgroup's Member Hostgroup"

	rlPhaseEnd
}

modify_newnetgroup()
{
	rlPhaseStartTest "modify netgroup"
		rlRun "ipa netgroup-mod --desc=$netgroup_desc_updated --usercat="" --hostcat="" $netgroup_updated" 0 "Modify netgroup"
		rlRun "ipa netgroup-remove-member --hosts=$managedByHost_updated $netgroup_updated" 0 "Remove host member from netgroup"
	rlPhaseEnd
}

modify_slave_netgroup()
{
	rlPhaseStartTest "modify slave netgroup"
		rlRun "ipa netgroup-mod --desc=$netgroup_desc_updated --usercat="" --hostcat="" $netgroup2_updated" 0 "Modify netgroup"
		rlRun "ipa netgroup-remove-member --hosts=$managedByHost_updated $netgroup2_updated" 0 "Remove host member from netgroup"
	rlPhaseEnd
}

check_modifiednetgroup()
{
	rlPhaseStartTest "check modified netgroup"
		rlRun "verifyNetgroupAttr $netgroup_updated \"Description\" $netgroup_desc_updated" 0 "Verify netgroup's Description"
		rlRun "ipa netgroup-show --all $netgroup_updated | grep \"User category\"" 1 "Verifying user catagory was removed for $netgroup_updated"
		rlRun "ipa netgroup-show --all $netgroup_updated | grep \"Host category\"" 1 "Verifying Host catagory was removed for $netgroup_updated"
		rlRun "ipa netgroup-show --all $netgroup_updated | grep \"Member Host\" | grep $managedByHost_updated" 1 "Verifying that $managedByHost_updated is not in $netgroup_updated"
	rlPhaseEnd
}

check_slave_modifiednetgroup()
{
	rlPhaseStartTest "check modified netgroup"
		rlRun "verifyNetgroupAttr $netgroup2_updated \"Description\" $netgroup_desc_updated" 0 "Verifyi slave netgroup's Description"
		rlRun "ipa netgroup-show --all $netgroup2_updated | grep \"User category\"" 1 "Verifying user catagory was removed for $netgroup_updated"
		rlRun "ipa netgroup-show --all $netgroup2_updated | grep \"Host category\"" 1 "Verifying Host catagory was removed for $netgroup_updated"
		rlRun "ipa netgroup-show --all $netgroup2_updated | grep \"Member Host\" | grep $managedByHost_updated" 1 "Verifying that $managedByHost_updated is not in $netgroup_updated2"
	rlPhaseEnd
}

delete_netgroup()
{
	rlPhaseStartTest "delete netgroup"
		rlRun "ipa netgroup-del $netgroup_updated" 0 "Delete the netgroup" 
	rlPhaseEnd
}

delete_slave_netgroup()
{
	rlPhaseStartTest "delete netgroup"
		rlRun "ipa netgroup-del $netgroup2_updated" 0 "Delete the netgroup" 
	rlPhaseEnd
}

check_deletednetgroup()
{
	rlPhaseStartTest "check deleted netgroup"
		command="ipa netgroup-show $netgroup_updated"
		expmsg="ipa: ERROR: $netgroup_updated: netgroup not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted netgroup"
		command="ipa netgroup-show $netgroup2_updated"
		expmsg="ipa: ERROR: $netgroup2_updated: netgroup not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted netgroup"

	rlPhaseEnd
}

###########################
# Service-related actions
###########################
add_newservice()
{
	rlPhaseStartTest "add service"
		rlRun "ipa service-add $service --certificate=$certificate" 0 "Add new service"
		rlRun "ipa service-add-host --hosts=$managedByHost $service" 0 "Add service host"
	rlPhaseEnd
}

add_slave_newservice()
{
	rlPhaseStartTest "add service to slave"
		rlRun "ipa service-add $service2 --certificate=$certificate" 0 "Add new service"
		rlRun "ipa service-add-host --hosts=$managedByHost $service2" 0 "Add service host"
	rlPhaseEnd
}

check_newservice()
{
	rlPhaseStartTest "check service"
		rlRun "verifyServiceAttr $service \"Principal\" $service" 0 "Verify service's name"
		rlRun "verifyServiceAttr $service \"Certificate\" $certificate" 0 "Verify service's certificate"
		rlRun "verifyServiceAttr $service \"Keytab\" $keytab" 0 "Verify service's Keytab"
		rlRun "verifyServiceAttr $service \"Subject\" $subject" 0 "Verify service's Subject"
		rlRun "verifyServiceAttr $service \"Issuer\" $issuer" 0 "Verify service's Issuer"
		rlRun "verifyServiceAttr $service \"Managed by\" $service_managedby" 0 "Verify service's managed hosts"
		rlRun "verifyServiceAttr $service2 \"Principal\" $service2" 0 "Verify service's name"
		rlRun "verifyServiceAttr $service2 \"Certificate\" $certificate" 0 "Verify service's certificate"
		rlRun "verifyServiceAttr $service2 \"Keytab\" $keytab" 0 "Verify service's Keytab"
		rlRun "verifyServiceAttr $service2 \"Subject\" $subject" 0 "Verify service's Subject"
		rlRun "verifyServiceAttr $service2 \"Issuer\" $issuer" 0 "Verify service's Issuer"
		rlRun "verifyServiceAttr $service2 \"Managed by\" $service_managedby" 0 "Verify service's managed hosts"

	rlPhaseEnd
}

modify_newservice()
{
	rlPhaseStartTest "modify service"
		rlRun "ipa service-disable $service_updated" 0 "Disable service" 
		rlRun "ipa service-mod $service_updated --certificate=$updatedcertificate " 0 "Modify service's certificate"
		rlRun "ipa service-mod $service_updated --setattr=managedBy=$service_managedby_attr2" 0 "Set service's managed by"
		rlRun "ipa service-mod $service_updated --addattr=managedBy=$service_managedby_attr" 0 "Add service's managed by"
	rlPhaseEnd
}

modify_slave_newservice()
{
	rlPhaseStartTest "modify service on slave"
		rlRun "ipa service-disable $service2_updated" 0 "Disable service" 
		rlRun "ipa service-mod $service2_updated --certificate=$updatedcertificate " 0 "Modify service's certificate"
		rlRun "ipa service-mod $service2_updated --setattr=managedBy=$service_managedby_attr2" 0 "Set service's managed by"
		rlRun "ipa service-mod $service2_updated --addattr=managedBy=$service_managedby_attr" 0 "Add service's managed by"
	rlPhaseEnd
}

check_modifiedservice()
{
	rlPhaseStartTest "check modified service"
		rlRun "verifyServiceAttr $service_updated \"Certificate\" $updatedcertificate" 0 "Verify service's certificate"
		rlRun "verifyServiceAttr $service_updated \"Subject\" $subject_updated" 0 "Verify service's Subject"
		rlRun "verifyServiceAttr $service_updated \"Managed by\" \"$managedByHost, $managedByHost_updated\"" 0 "Verify service's managed hosts"
	rlPhaseEnd
}

check_slave_modifiedservice()
{
	rlPhaseStartTest "check modified service"
		rlRun "verifyServiceAttr $service2_updated \"Certificate\" $updatedcertificate" 0 "Verify service's certificate"
		rlRun "verifyServiceAttr $service2_updated \"Subject\" $subject_updated" 0 "Verify service's Subject"
		rlRun "verifyServiceAttr $service2_updated \"Managed by\" \"$managedByHost, $managedByHost_updated\"" 0 "Verify service's managed hosts"
	rlPhaseEnd
}

delete_service()
{
	rlPhaseStartTest "delete service"
		rlRun "ipa service-del $service_updated" 0 "Delete the service" 
	rlPhaseEnd

}

delete_slave_service()
{
	rlPhaseStartTest "delete service"
		rlRun "ipa service-del $service2_updated" 0 "Delete the service" 
	rlPhaseEnd

}

check_deletedservice()
{
	rlPhaseStartTest "check deleted service"
		command="ipa service-show $service_updated"
		expmsg="ipa: ERROR: $service_updated: service not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted service"
		command="ipa service-show $service2_updated"
		expmsg="ipa: ERROR: $service2_updated: service not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted service"

	rlPhaseEnd
}

################################
# Delegation bits
################################
add_delegation()
{ #test_scenario (positive): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR
	if [ $config == "master" ] ; then
		rlPhaseStartTest "permission_add_1036"
			local testID="permission_add_1036"
			local tmpout=$TmpDir/permission_add_1036.replicationtest.out
			KinitAsAdmin
			local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
			local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
			local permissions_TestValue="read,write,add,delete,all" #permissions;positive;read, write, add, delete, all
			local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
			rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue]"
			deletePermission $testID
			rm $tmpout 2>&1 >/dev/null
		rlPhaseEnd
	fi
} #permission_add_1036

check_delegation()
{ #test_scenario (positive): --type;positive;user, group, host, hostgroup, service, netgroup, dns
		 rlPhaseStartTest "permission_find_1036"
		     local testID="permission_find_1036"
		     local tmpout=$TmpDir/permission_find_1036.replicationtest.out
		     KinitAsAdmin
		     local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
		     rlRun "ipa permission-find $testID  --type=$type_TestValue " 0 "test options:  [type]=[$type_TestValue]"
		     rm $tmpout 2>&1 >/dev/null
		 rlPhaseEnd
} #permission_find_1036

################################
# DNS section
################################
export zone=repnewzone
export arec="alpha2.$zone"
export a="1.2.3.4"
add_dns()
{
	ipaddr=`hostname`	
	email="ipaqar.redhat.com"
	serial=2010010701
	refresh=303
	retry=101
	expire=1202
	minimum=33
	ttl=55
	
		    	KinitAsAdmin
	rlPhaseStartTest "create a new zone $zone to be used in a replication dns test. It could contain the $zrec record"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl $zone" 0 "Checking to ensure that ipa thinks that it can create a zone"
		rlRun "/usr/sbin/ipactl restart" 0 "Restarting IPA server"
		rlRun "ipa dnsrecord-add $zone $arec --a-rec $a" 0 "add record type a to $zone"
	rlPhaseEnd
}

check_dns()
{
	rlPhaseStartTest "make sure that the $arec entry is on this server"
		rlRun "ipa dnsrecord-find $zone $arec | grep $a" 0 "make sure ipa recieved record type A"
		rlRun "dig $arec.$zone | grep $a" 0 "make sure dig can find the A record"
	rlPhaseEnd
}

delete_dns()
{
	rlPhaseStartTest "delete the record $arec from $zone, as well as the dns zone"
		rlRun "ipa dnsrecord-del $zone $arec --a-rec $a" 0 "delete record type a"
		rlRun "ipa dnszone-del $zone" 0 "Delete the zone created for this test"
	rlPhaseEnd
}

check_deleteddns()
{
	rlPhaseStartTest "make sure that the $arec entry is removed from this server"
		/etc/init.d/named restart
		rlRun "ipa dnsrecord-find $zone $arec | grep $a" 1 "make sure the record $arec is removed from this server"
		rlRun "dig $arec.$zone | grep $a" 1 "make sure dig can not find the A record"
	rlPhaseEnd
}

################################
# hbac section
################################
REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`

host1="dev_host_hbac."$DOMAIN

user1="dev_hbac"

usergroup1="dev_ugrp_hbac"

hostgroup1="dev_hosts_hbac"

servicegroup="remote_access_hbac"

hbac_setup()
{
	rlPhaseStartTest "hbac setup"
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
		KinitAsAdmin
		# add host for testing
		rlRun "addHost $host1" 0 "SETUP: Adding host $host1 for testing."
		# add host group for testing
		rlRun "addHostGroup $hostgroup1 $hostgroup1" 0 "SETUP: Adding host group $hostgroup1 for testing."
		# add user for testing
		rlRun "ipa user-add --first=$user1 --last=$user1 $user1" 0 "SETUP: Adding user $user1."
		# add group for testing
		rlRun "addGroup $usergroup1 $usergroup1" 0 "SETUP: Adding user $usergroup1."
		# add service group
		rlRun "addHBACServiceGroup $servicegroup $servicegroup" 0 "SETUP: Adding service group $servicegroup"
	rlPhaseEnd
}

add_hbac()
{
	hbac_setup
	rlPhaseStartTest "Add host to Rule"
		rlRun "addHBACRule \" \" \" \" \" \" \" \" Engineering" 0 "Adding HBAC rule."
		rlRun "addToHBAC Engineering host hosts $host1" 0 "Adding host $host1 to Engineering rule."
		rlRun "verifyHBACAssoc Engineering Hosts $host1" 0 "Verifying host $host1 is associated with the Engineering rule."
	rlPhaseEnd

	rlPhaseStartTest "Add host group to Rule"
		rlRun "addToHBAC Engineering host hostgroups $hostgroup1" 0 "Adding host group $hostgroup1 to Engineering rule."
		rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup1" 0 "Verifying host group $hostgroup1 is associated with the Engineering rule."
	rlPhaseEnd
}

check_hbac()
{
	rlPhaseStartTest "Verify HBAC rules exist"
		rlRun "verifyHBACAssoc Engineering Hosts $host1" 0 "Verifying host $host1 is associated with the Engineering rule."
		rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup1" 0 "Verifying host group $hostgroup1 is associated with the Engineering rule."
	rlPhaseEnd

}

modify_hbac()
{
	rlPhaseStartTest "Modify hbac Description"
		rlRun "modifyHBACRule Engineering desc \"My New Description\"" 0 "Modifying Engineering Rule's Description"
		rlRun "verifyHBACAssoc Engineering Description \"My New Description\"" 0 "Verifying Description"
	rlPhaseEnd
}

check_modifiedhbac()
{
	rlPhaseStartTest "Check modified hbac Description"
		rlRun "verifyHBACAssoc Engineering Description \"My New Description\"" 0 "Verifying Description"
	rlPhaseEnd
}

delete_hbac()
{
	rlPhaseStartTest "delete hba entries from hosts"
		rlRun "deleteGroup $usergroup1" 0 "Deleting User Group associated with rule."
		rlRun "deleteHost $host1" 0 "Deleting Host associated with rule."
		rlRun "deleteHostGroup $hostgroup1" 0 "Deleting Host Group associated with rule."
		rlRun "deleteHBACRule Engineering" 0 "CLEANUP: Deleting Rule"
	rlPhaseEnd
}

check_deletedhbac()
{
	rlPhaseStartTest "verify that hostgroup1 was deleted"
		rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup1" 1 "Verifying host group $hostgroup1 is no longer associated with the Engineering rule."
	rlPhaseEnd
}

################################
# hbac service section
################################
service1="rlogin"
add_hbac_service()
{
	rlPhaseStartTest "add hbac service"
		rlRun "addHBACService $service1 $service1" 0 "Adding HBAC service $service1."
		rlRun "findHBACService $service1" 0 "Verifying HBAC service $service1 is found."
		rlRun "verifyHBACService $service1 \"Service name\" $service1" 0 "Verify New Service name"
		rlRun "verifyHBACService $service1 \"Description\" $service1" 0 "Verify New Service Description"
	rlPhaseEnd
}

check_hbac_service()
{
	rlPhaseStartTest "check hbac service"
		rlRun "findHBACService $service1" 0 "Verifying HBAC service $service1 is found."
	rlPhaseEnd

}

mod_hbac_service()
{
	rlPhaseStartTest "Modify hbac-service Description with --desc"
		rlRun "modifyHBACService $service1 desc \"Newer Description\"" 0 "Modify with --desc service description"
		rlRun "verifyHBACService $service1 Description \"Newer Description\"" 0 "Verify New Service Description"
	rlPhaseEnd
}

check_modifiedhbacservice()
{
	rlPhaseStartTest "Check modified hbac-service Description with --desc"
		rlRun "verifyHBACService $service1 Description \"Newer Description\"" 0 "Verify New Service Description"
	rlPhaseEnd
}

delete_hbac_service()
{
	rlPhaseStartTest "delete hbac serivce $service1"
		rlRun "deleteHBACService $service1" 0 "CLEANUP: Deleting service $service1"
	 rlPhaseEnd
}

check_deletedhbacservice()
{
	rlPhaseStartTest "check hbac service is removed"
		rlRun "findHBACService $service1" 1 "Verifying HBAC service $service1 is not found."
	rlPhaseEnd
}

################################
# permission section
################################
puser1="puser"
add_permission()
{
	rlPhaseStartTest "add a user, and add a permission to that user"
		rlRun "ipa user-add --first=$puser1 --last=$puser1 $puser1" 0 "SETUP: Adding user $puser1."		
		rlRun "ipa permission-add $puser1 --type=user --permissions=delete"
	rlPhaseEnd
}
check_permission()
{
	rlPhaseStartTest "check to ensure that the permission exists"
		rlRun "ipa permission-show $puser1 | grep delete" 0 "checking to make sure that the permission got installed on the user"		
	rlPhaseEnd
}
mod_permission()
{
	rlPhaseStartTest "mod puser1's permissions"
		rlRun "ipa permission-mod $puser1 --type=user --permissions=add"
	rlPhaseEnd
}
check_modpermission()
{
	rlPhaseStartTest "check to ensure that the permission has been modified"
		rlRun "ipa permission-show $puser1 | grep add" 0 "checking to make sure that the permission got installed on the user"		
	rlPhaseEnd
}

delete_permission()
{
	rlPhaseStartTest "add a user, and add a permission to that user"
		rlRun "ipa permission-del $puser1" 0 " deleting the permission for $puser1"
		rlRun "ipa user-del $puser1" 0 "deleting user $puser1."			
	rlPhaseEnd
}
check_deletedpermission()
{
	rlPhaseStartTest "add a user, and add a permission to that user"
		rlRun "ipa permission-show $puser1 | grep add" 1 "checking to make sure that the permission is not arund any more"
		rlRun "ipa user-find $puser1" 1 "making sure that the user is gone"
	rlPhaseEnd
}

################################
# sudo rule
################################
rule1=sudorule1
add_sudorule()
{
	rlPhaseStartTest "add a sudo rule"
		rlRun "ipa sudorule-add $rule1" 0 "creating $rule1 for replication testing"
	rlPhaseEnd
}

check_sudorule()
{
	rlPhaseStartTest "check to make sure that the sudo rule exists"
		rlRun "ipa sudorule-find $rule1" 0 "finding sudo rule $rule1"
	rlPhaseEnd
}

mod_sudorule()
{
	rlPhaseStartTest "disabling $rule1 for replication testing"
		rlRun "ipa sudorule-disable $rule1" 0 "disabling $rule1"
	rlPhaseEnd
}

check_modsudorule()
{
	rlPhaseStartTest "check to make sure that the sudo rule exists, and is disabled"
		rlRun "ipa sudorule-find $rule1 | grep Enabled | grep FALSE" 0 "finding sudo rule $rule1 and making sure it is disabled"
	rlPhaseEnd
}

delete_sudorule()
{
	rlPhaseStartTest "deleting $rule1"
		rlRun "ipa sudorule-del $rule1" 0 "deleting $rule1"
	rlPhaseEnd
}

check_deletedsudorule()
{
	rlPhaseStartTest "check to make sure that the sudo rule does not exist"
		rlRun "ipa sudorule-find $rule1" 1 "finding sudo rule $rule1"
	rlPhaseEnd
}

################################
# sudo cmd
################################
cmdrule1=/use/local/bin/nonexist
add_sudocmd()
{
	rlPhaseStartTest "add a sudo cmd"
		rlRun "ipa sudocmd-add --desc='for testing' $cmdrule1" 0 "creating $cmdrule1 for replication testing"
	rlPhaseEnd
}

check_sudocmd()
{
	rlPhaseStartTest "check to make sure that the sudo cmd exists"
		rlRun "ipa sudocmd-find $cmdrule1" 0 "finding sudo cmd $cmdrule1"
	rlPhaseEnd
}

mod_sudocmd()
{
	rlPhaseStartTest "modding $cmdrule1 for replication testing"
		rlRun "ipa sudocmd-mod --desc=newdesc $cmdrule1" 0 "modding $cmdrule1"
	rlPhaseEnd
}

check_modsudocmd()
{
	rlPhaseStartTest "check to make sure that the sudo cmd is moddified"
		rlRun "ipa sudocmd-find $cmdrule1 | grep newdesc" 0 "finding sudo rule $cmdrule1 and making sure it is disabled"
	rlPhaseEnd
}

delete_sudocmd()
{
	rlPhaseStartTest "deleting $cmdrule1"
		rlRun "ipa sudocmd-del $cmdrule1" 0 "deleteing sudo cmd $cmdrule1"
	rlPhaseEnd
}

check_deletedsudocmd()
{
	rlPhaseStartTest "check to make sure that the sudo cmd does not exist"
		rlRun "ipa sudocmd-find $cmdrule1" 1 "finding sudo cmd $cmdrule1"
	rlPhaseEnd
}

################################
# sudo cmd group
################################
cmdgrp1=repadmins
add_sudocmdgroup()
{
	rlPhaseStartTest "add a sudo cmd group"
		rlRun "ipa sudocmdgroup-add --desc='replication admins' $cmdgrp1" 0 "creating $cmdgrp1 for replication testing"
	rlPhaseEnd
}

check_sudocmdgroup()
{
	rlPhaseStartTest "check to make sure that the sudo cmd group exists"
		rlRun "ipa sudocmdgroup-find $cmdgrp1" 0 "finding sudo cmd group $cmdgrp1"
	rlPhaseEnd
}

mod_sudocmdgroup()
{
	rlPhaseStartTest "modding $cmdgrp1 for replication testing"
		rlRun "ipa sudocmdgroup-mod --desc=newdesc $cmdgrp1" 0 "modding $cmdgrp1"
	rlPhaseEnd
}

check_modsudocmdgroup()
{
	rlPhaseStartTest "check to make sure that the sudo cmd group is moddified"
		rlRun "ipa sudocmdgroup-find $cmdgrp1 | grep newdesc" 0 "finding sudo group $cmdgrp1 and making sure it is disabled"
	rlPhaseEnd
}

delete_sudocmdgroup()
{
	rlPhaseStartTest "deleting $cmdgrp1"
		rlRun "ipa sudocmdgroup-del $cmdgrp1" 0 "deleteing sudo cmd group $cmdgrp1"
	rlPhaseEnd
}

check_deletedsudocmdgroup()
{
	rlPhaseStartTest "check to make sure that the sudo command group does not exist"
		rlRun "ipa sudocmdgroup-find $cmdgrp1" 1 "finding sudo cmd $cmdgrp1"
	rlPhaseEnd
}

################################
# config section
################################
add_config()
{
	rlPhaseStartTest "modify a config entry to ensure that the change takes everywhere."
		rlRun "ipa config-mod --maxusername=994" 0 "modifying max username length"
	rlPhaseEnd

}

check_config()
{
	rlPhaseStartTest "making sure that the new max usernames is shown"
		rlRun "ipa config-show | grep 994" 0 "making sure that the new max usernames is specified"
	rlPhaseEnd
}

delete_config()
{
	rlPhaseStartTest "modify a config entry back to something a little more sane"
		rlRun "ipa config-mod --maxusername=25" 0 "modifying max username length"
	rlPhaseEnd

}

check_deletedconfig()
{
	rlPhaseStartTest "making sure that the new max usernames is shown"
		rlRun "ipa config-show | grep 25" 0 "making sure that the new max usernames is specified correctly"
	rlPhaseEnd
}

################################
# pwpolicy section
################################
tg="pwtestg"
add_pwpolicy()
{
	ipa group-add --desc=tg $tg
	rlPhaseStartTest "adding pwpolicy"
		rlRun "ipa pwpolicy-add --maxlife=999  --priority=10 $tg" 0 "setting password policy to something high"
	rlPhaseEnd
}

check_pwpolicy()
{
	rlPhaseStartTest "Searching for added pwpolicy"
		rlRun "ipa pwpolicy-find $tg | grep 999" 0 "Searching for added pwpolicy"
	rlPhaseEnd
}

mod_pwpolicy()
{	rlPhaseStartTest "modifying pwpolicy for test group"
		rlRun "ipa pwpolicy-mod --maxlife=384 $tg" 0 "modifying pwpolicy for test group"
	rlPhaseEnd
}

check_modpwpolicy()
{
	rlPhaseStartTest "Searching for modified pwpolicy in tg"
		rlRun "ipa pwpolicy-find $tg | grep 384" 0 "Searching for modified pwpolicy in tg"
	rlPhaseEnd
}

delete_pwpolicy()
{
	rlPhaseStartTest "Deleting the password policy for the testgroup"
		rlRun "ipa pwpolicy-del $tg" 0 "Deleting the password policy for the testgroup"
	rlPhaseEnd
}

check_deletedpwpolicy()
{
	rlPhaseStartTest "Making sure that the test group pwpolicy doesn't seem to be searchable"
		rlRun "ipa pwpolicy-find $tg" 1 "Making sure that the test group pwpolicy doesn't seem to be searchable"
	rlPhaseEnd
	# Cleanup of test group
	ipa group-del $tg
}

################################
# selfservice section
################################
ss="users-self-s"
add_selfservice()
{
	rlPhaseStartTest "adding a selfservice section"
		rlRun "ipa selfservice-add --permissions=write --attrs=street,postalCode,l,c,st $ss" 0 "adding a selfservice section"
	rlPhaseEnd
}

check_selfservice()
{
	rlPhaseStartTest "Searching for added selfservice"
		rlRun "ipa selfservice-find $ss | grep postalCode" 0 "Searching for added selfservice"
	rlPhaseEnd
}

mod_selfservice()
{	rlPhaseStartTest "modifying selfservice rule"
		rlRun "ipa selfservice-mod --attrs=street,postalCode,l,c,st,telephoneNumber $ss" 0 "modifying selfservice rule"
	rlPhaseEnd
}

check_modselfservice()
{
	rlPhaseStartTest "Searching for modified selfservice policy"
		rlRun "ipa selfservice-find $ss | grep telephoneNumber" 0 "Searching for modified selfservice policy"
	rlPhaseEnd
}

delete_selfservice()
{
	rlPhaseStartTest "Deleting the self service"
		rlRun "ipa selfservice-del $ss" 0 "Deleting the self service"
	rlPhaseEnd
}

check_deletedselfservice()
{
	rlPhaseStartTest "Searching for removed selfservice"
		rlRun "ipa selfservice-find $ss" 1 "Searching for removed selfservice"
	rlPhaseEnd
}

################################
# privilege section
################################
priv="rep-priv"
add_privilege()
{
	rlPhaseStartTest "Add a privilege"
		rlRun "ipa privilege-add --desc='test desc' $priv" 0 "adding a priviege"
	rlPhaseEnd
}

check_privilege()
{
	rlPhaseStartTest "check to ensure that the privilege exists"
		rlRun "ipa privilege-find $priv | grep 'test desc'" 0 "Searching for that added privilege"
	rlPhaseEnd
}

mod_privilege()
{	rlPhaseStartTest "Modify the privilege"
		rlRun "ipa privilege-mod --desc='newdesc' $priv" 0 "modifying privilege"
	rlPhaseEnd
}

check_modprivilege()
{
	rlPhaseStartTest "Find the modified privilege"
		rlRun "ipa privilege-find $priv | grep newdesc" 0 "Searching for modified privilege"
	rlPhaseEnd
}

delete_privilege()
{
	rlPhaseStartTest "deleting privilege"
		rlRun "ipa privilege-del $priv" 0 "Deleting the privilege"
	rlPhaseEnd
}

check_deletedprivilege()
{
	rlPhaseStartTest "check to ensure that privilege was deleted."
		rlRun "ipa privilege-find $priv" 1 "Searching for removed privilege"
	rlPhaseEnd
}

################################
# role section
################################
role="rep-rtst"
add_role()
{
	rlPhaseStartTest "Add a role"
		rlRun "ipa role-add --desc testrole $role" 0 "adding a role"
	rlPhaseEnd
}

check_role()
{
	rlPhaseStartTest "check to ensure that the role exists"
		rlRun "ipa role-find $role | grep testrole" 0 "Searching for that added role"
	rlPhaseEnd
}

mod_role()
{	rlPhaseStartTest "Modify the role"
		rlRun "ipa role-mod --desc='altdesc' $role" 0 "modifying role"
	rlPhaseEnd
}

check_modrole()
{
	rlPhaseStartTest "Find the modified role"
		rlRun "ipa role-find $role | grep altdesc" 0 "Searching for modified role"
	rlPhaseEnd
}

delete_role()
{
	rlPhaseStartTest "deleting role"
		rlRun "ipa role-del $role" 0 "Deleting the role"
	rlPhaseEnd
}

check_deletedrole()
{
	rlPhaseStartTest "check to ensure that role was deleted."
		rlRun "ipa role-find $role" 1 "Searching for removed role"
	rlPhaseEnd
}

