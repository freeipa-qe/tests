

#########################
# User-related actions
#########################

add_newuser()
{
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
}


check_newuser()
{
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
}



modify_newuser()
{
  
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
}



check_modifieduser()
{
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
}


delete_user()
{
  rlRun "ipa user-del $login_updated" 0 "Deleted user"
}

check_deleteduser()
{
   command="ipa user-show $login_updated"
   expmsg="ipa: ERROR: $login_updated: user not found"
   rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted user"
}


#########################
# Group-related actions
#########################

add_newgroup()
{
   rlRun "ipa group-add --desc=$desc --gid=$gid $groupName" 0 "Add a new group"
   rlRun "ipa group-add --desc=$desc_nonposix --nonposix $groupName_nonposix" 0 "Add a new non-posixgroup"
   rlRun "ipa user-add --first=$groupMember1 --last=$groupMember1 $groupMember1" 0 "Add users to be added as members to the group"
   rlRun "ipa user-add --first=$groupMember2 --last=$groupMember2 $groupMember2" 0 "Add users to be added as members to the group"
   rlRun "ipa group-add-member --users=$groupMember1,$groupMember2 --groups=$groupName_nonposix $groupName" 0 "add members to this new group"
}

check_newgroup()
{
   rlRun "verifyGroupAttr $groupName \"dn\" $dn" 0 "Verify group's dn"
   rlRun "verifyGroupAttr $groupName \"Group name\" $groupName" 0 "Verify group's name"
   rlRun "verifyGroupAttr $groupName \"Description\" $desc" 0 "Verify group's description"
   if [ "$1" == "nonposix" ] ; then 
       # should not have a GID
       rlLog "TODO"
   else
      rlRun "verifyGroupAttr $groupName \"GID\" $gid" 0 "Verify group's gid"
   fi
   rlRun "verifyGroupAttr $groupName \"Member users\" \"$groupMember1, $groupMember2\"" 0 "Verify group's user members"
   rlRun "verifyGroupAttr $groupName \"Member groups\" $groupName_nonposix" 0 "Verify group's group members"
}

modify_newgroup()
{

    rlRun "ipa group-mod $1 --desc=$desc_updated --rename=$groupName_updated" 0 "Modify the group"
    rlRun "ipa group-remove-member $groupName_updated --users=$groupMember1_updated --groups=$group_nonposix_updated" 0 "remove members from this group"
}

check_modifiedgroup()
{
   rlRun "verifyGroupAttr $groupName_updated \"dn\" $dn_updated" 0 "Verify group's dn"
   rlRun "verifyGroupAttr $groupName_updated \"Group name\" $groupName_updated" 0 "Verify group's name"
   rlRun "verifyGroupAttr $groupName_updated \"Description\" $desc_updated" 0 "Verify group's description"
   rlRun "verifyGroupAttr $groupName_updated \"Member users\" $groupMember2_updated" 0 "Verify group's user members"
}

delete_group()
{

  rlRun "ipa group-del $groupName_updated" 0 "Deleted group"
}


check_deletedgroup()
{
   command="ipa group-show $groupName_updated"
   expmsg="ipa: ERROR: $groupName_updated: group not found"
   rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted group"
}



#########################
# Host-related actions
#########################

add_newhost()
{
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
}

check_newhost()
{
   rlRun "verifyHostAttr $newHost \"Host name\" $newHost" 0 "Verify host's name"
   rlRun "verifyHostAttr $newHost \"Description\" $hostDesc" 0 "Verify host's description"
   rlRun "verifyHostAttr $newHost \"Location\" $hostLocation" 0 "Verify host's location"
   rlRun "verifyHostAttr $newHost \"Platform\" $hostPlatform" 0 "Verify host's platform"
   rlRun "verifyHostAttr $newHost \"Operating system\" $hostOS" 0 "Verify host's OS"
   rlRun "verifyHostAttr $newHost \"Managed by\" \"$newHost, $managedByHost\"" 0 "Verify host's Managed-by list"
}


modify_newhost()
{
 rlRun "ipa host-mod --location=$hostLocation_updated \
                     --platform=$hostPlatform_updated \
                     --os=$hostOS_updated \
                     --addattr=locality=$hostLocality_updated \
                     --setattr=description=$hostDesc_updated \
                     $newHost_updated" \
                     0 \
                     "Modify the host"
 rlRun "ipa host-remove-managedby --hosts=$managedByHost_updated $newHost_updated" 0 "Remove managed-by host"
}


check_modifiedhost()
{
   rlRun "verifyHostAttr $newHost_updated \"Description\" $hostDesc_updated" 0 "Verify host's description"
   rlRun "verifyHostAttr $newHost_updated \"Locality\" $hostLocality_updated" 0 "Verify host's locality"
   rlRun "verifyHostAttr $newHost_updated \"Location\" $hostLocation_updated" 0 "Verify host's location"
   rlRun "verifyHostAttr $newHost_updated \"Platform\" $hostPlatform_updated" 0 "Verify host's platform"
   rlRun "verifyHostAttr $newHost_updated \"Operating system\" $hostOS_updated" 0 "Verify host's OS"
   rlRun "verifyHostAttr $newHost_updated \"Managed by\" $newHost_updated" 0 "Verify host's Managed-by list"
}


delete_host()
{
   rlRun "ipa host-del $newHost" 0 "Delete host"
}


check_deletedhost()
{
   command="ipa host-show $newHost"
   expmsg="ipa: ERROR: $newHost: host not found"
   rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted host"
}




#########################
# Hostgroup-related actions
#########################

add_newhostgroup()
{
   rlRun "ipa hostgroup-add --desc=$hostgroup_groupMember1  $hostgroup_groupMember1" 0 "Add a hostgroup to be added as member"
   rlRun "ipa hostgroup-add --desc=$hostgroup_groupMember1_updated  $hostgroup_groupMember1_updated" 0 "Add another hostgroup to be added as member"

   rlRun "ipa hostgroup-add --desc=\"$hostgroup_desc\" \
                            --addattr member=\"cn=$hostgroup_groupMember1,cn=hostgroups,cn=accounts,dc=$DOMAIN\" \
                            $hostgroup " \
                            0 \
                            "Add a new hostgroup, with a hostgroup member"
   rlRun "ipa hostgroup-add-member --hosts=$managedByHost $hostgroup" 0 "Add a host member"
 
}

check_newhostgroup()
{
   rlRun "verifyHostGroupAttr $hostgroup \"Host-group\" $hostgroup" 0 "Verify Hostgroup's name" 
   rlRun "verifyHostGroupAttr $hostgroup \"Description\" $hostgroup_desc" 0 "Verify Hostgroup's description" 
   rlRun "verifyHostGroupMember $managedByHost host $hostgroup" 0 "Verify Hostgroup's Member hosts" 
   rlRun "verifyHostGroupMember $hostgroup_groupMember1 hostgroup $hostgroup" 0 "Verify Hostgroup's Member hosts" 
}



modify_newhostgroup()
{
    rlRun "ipa hostgroup-mod --desc=\"$hostgroup_desc_updated\" \
                             $hostgroup_updated" \
                             0 \
                             "Modify hostgroup"
    rlRun "ipa hostgroup-remove-member --hosts=$managedByHost_updated $hostgroup_updated" 0 "Remove a host member"
# TODO: --setattr member=\"cn=$hostgroup_groupMember1_updated,cn=hostgroups,cn=accounts,dc=$DOMAIN\" \
}


check_modifiedhostgroup()
{
   rlRun "verifyHostGroupAttr $hostgroup_updated \"Host-group\" $hostgroup_updated" 0 "Verify Hostgroup's name" 
   rlRun "verifyHostGroupAttr $hostgroup_updated \"Description\" $hostgroup_desc_updated" 0 "Verify Hostgroup's description" 
# TODO:    rlRun "verifyHostGroupMember $hostgroup_groupMember1_updated hostgroup $hostgroup_updated" 0 "Verify Hostgroup's Member hosts" 
}



delete_hostgroup()
{
   rlRun "ipa hostgroup-del $hostgroup_updated" 0 "Delete the hostgroup" 
}


check_deletedhostgroup()
{
   command="ipa hostgroup-show $hostgroup_updated"
   expmsg="ipa: ERROR: $hostgroup_updated: hostgroup not found"
   rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted hostgroup"
}
