

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
   add_newuser
}

check_newuser()
{
	rlPhaseStartTest "check added user"
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
   modify_newuser $1
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
   check_modifieduser
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
    delete_user
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
   add_newgroup
}

check_newgroup()
{
	rlPhaseStartTest "check new group"
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
	rlPhaseEnd
}

modify_newgroup()
{
	rlPhaseStartTest "modify new group"
		 rlRun "ipa group-mod $1 --desc=$desc_updated --rename=$groupName_updated" 0 "Modify the group $1"
		 rlRun "ipa group-remove-member $groupName_updated --users=$groupMember1_updated --groups=$group_nonposix_updated" 0 "remove members from this group"
	rlPhaseEnd
}

modify_slave_group()
{
   modify_newgroup $1
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
   check_modifiedgroup
}

delete_group()
{
	rlPhaseStartTest "delete group"
		rlRun "ipa group-del $groupName_updated" 0 "Deleted group"
	rlPhaseEnd
}

delete_slave_group()
{
  delete_group
}

check_deletedgroup()
{
	rlPhaseStartTest "check deleted group"
		command="ipa group-show $groupName_updated"
		expmsg="ipa: ERROR: $groupName_updated: group not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted group"
	rlPhaseEnd
}

#########################
# Host-related actions
#########################

add_newhost()
{
	rlPhaseStartTest "add new host"
        rlLog "ipa host-add --desc=$hostDesc --location=$hostLocation --platform=$hostPlatform --os=$hostOS --password=$hostPassword --ip-address=$hostIPaddress --no-reverse  $newHost"
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
                rlLog "ipa host-add --no-reverse  --ip-address=$managedByHostIP $managedByHost "
		rlRun "ipa host-add --no-reverse \
		                   --ip-address=$managedByHostIP \
		                   $managedByHost" \
		                   0 \
		                  "Add new host to use as managed-by host"
		rlLog "ipa  host-add-managedby --hosts=$managedByHost $newHost" 
		rlRun "ipa  host-add-managedby --hosts=$managedByHost $newHost" 0 "Add managed-by host"
	rlPhaseEnd
}

add_slave_host()
{
   add_newhost
}

check_newhost()
{
	rlPhaseStartTest "check new host"
		rlRun "verifyHostAttr $newHost \"Host name\" $newHost" 0 "Verify host's name"
		rlRun "verifyHostAttr $newHost \"Description\" $hostDesc" 0 "Verify host's description"
		rlRun "verifyHostAttr $newHost \"Location\" $hostLocation" 0 "Verify host's location"
		rlRun "verifyHostAttr $newHost \"Platform\" $hostPlatform" 0 "Verify host's platform"
		rlRun "verifyHostAttr $newHost \"Operating system\" $hostOS" 0 "Verify host's OS"
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
		                  $host_updated" \
		                  0 \
		                  "Modify the host"
		rlRun "ipa host-remove-managedby --hosts=$managedByHost_updated $host_updated" 0 "Remove managed-by host"
	rlPhaseEnd
}

modify_slave_host()
{
  modify_newhost
}

check_modifiedhost()
{
	rlPhaseStartTest "check modified host"
		rlRun "verifyHostAttr $host_updated \"Description\" $hostDesc_updated" 0 "Verify host's description"
		rlRun "verifyHostAttr $host_updated \"Locality\" $hostLocality_updated" 0 "Verify host's locality"
		rlRun "verifyHostAttr $host_updated \"Location\" $hostLocation_updated" 0 "Verify host's location"
		rlRun "verifyHostAttr $host_updated \"Platform\" $hostPlatform_updated" 0 "Verify host's platform"
		rlRun "verifyHostAttr $host_updated \"Operating system\" $hostOS_updated" 0 "Verify host's OS"
		rlRun "verifyHostAttr $host_updated \"Managed by\" $newHost_updated" 0 "Verify host's Managed-by list"
	rlPhaseEnd
}

check_slave_modifiedhost()
{
   check_modifiedhost
}

delete_host()
{
	rlPhaseStartTest "Deleting host"
		rlLog "Executing: ipa host-del $host_updated"
		rlRun "ipa host-del $host_updated" 0 "Deleting $host_updated"
	rlPhaseEnd
}

delete_slave_host()
{
    delete_host
}

check_deletedhost()
{
	rlPhaseStartTest "check for deleted host"
		command="ipa host-show $newHost"
		expmsg="ipa: ERROR: $newHost: host not found"
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
   add_newhostgroup
}

check_newhostgroup()
{
	rlPhaseStartTest "check new hostgroup"
		rlRun "verifyHostGroupAttr $hostgroup \"Host-group\" $hostgroup" 0 "Verify Hostgroup's name" 
		rlRun "verifyHostGroupAttr $hostgroup \"Description\" $hostgroup_desc" 0 "Verify Hostgroup's description" 
		rlRun "verifyHostGroupMember $managedByHost host $hostgroup" 0 "Verify Hostgroup's Member hosts" 
		rlRun "verifyHostGroupMember $hostgroup_groupMember1 hostgroup $hostgroup" 0 "Verify Hostgroup's Member hosts" 
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
   modify_newhostgroup
}

check_modifiedhostgroup()
{
	rlPhaseStartTest "check modified hostgroup"
		rlRun "verifyHostGroupAttr $hostgroup_updated \"Host-group\" $hostgroup_updated" 0 "Verify Hostgroup's name" 
		rlRun "verifyHostGroupAttr $hostgroup_updated \"Description\" $hostgroup_desc_updated" 0 "Verify Hostgroup's description" 
# TODO:    rlRun "verifyHostGroupMember $hostgroup_groupMember1_updated hostgroup $hostgroup_updated" 0 "Verify Hostgroup's Member hosts" 
	rlPhaseEnd
}

check_slave_modifiedhostgroup()
{
   check_modifiedhostgroup
}

delete_hostgroup()
{
	rlPhaseStartTest "delete hostgroup"
		rlRun "ipa hostgroup-del $hostgroup_updated" 0 "Delete the hostgroup" 
	rlPhaseEnd
}

delete_slave_hostgroup()
{
   delete_hostgroup
}

check_deletedhostgroup()
{
	rlPhaseStartTest "check deleted hostgroup"
		command="ipa hostgroup-show $hostgroup_updated"
		expmsg="ipa: ERROR: $hostgroup_updated: host group not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error when checking for deleted host group"
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
    add_newnetgroup
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
   modify_newnetgroup
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
   check_modifiednetgroup
}

delete_netgroup()
{
	rlPhaseStartTest "delete netgroup"
		rlRun "ipa netgroup-del $netgroup_updated" 0 "Delete the netgroup" 
		rlRun "ipa netgroup-del $netgroup_groupMember1" 0 "Delete $netgroup_groupMember1"
	rlPhaseEnd
}

delete_slave_netgroup()
{
    delete_netgroup
}

check_deletednetgroup()
{
	rlPhaseStartTest "check deleted netgroup"
		command="ipa netgroup-show $netgroup_updated"
		expmsg="ipa: ERROR: $netgroup_updated: netgroup not found"
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
		rlRun "ipa service-add $service2 --certificate=$certificate" 0 "Add new service"
		rlRun "ipa service-add-host --hosts=$managedByHost $service2" 0 "Add service host"
	rlPhaseEnd
}

add_slave_newservice()
{
   add_newservice
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
   modify_newservice
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
    check_modifiedservice
}

delete_service()
{
	rlPhaseStartTest "delete service"
		rlRun "ipa service-del $service_updated" 0 "Delete the service" 
	rlPhaseEnd

}

delete_slave_newservice()
{
   delete_service
}

check_deletedservice()
{
	rlPhaseStartTest "check deleted service"
		command="ipa service-show $service_updated"
		expmsg="ipa: ERROR: $service_updated: service not found"
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
		#	KinitAsAdmin
	                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials to delete objects"
			local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
			local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
			local permissions_TestValue="read,write,add,delete,all" #permissions;positive;read, write, add, delete, all
			local targetgroup_TestValue="$groupName" #targetgroup;positive;STR
			rlLog "ipa permission-add $testID  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue "
			rlRun "ipa permission-add $testID  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue]"
			# TODO: command not found: deletePermission $testID
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
add_dns()
{
    	KinitAsAdmin
	rlPhaseStartTest "create a new zone $zone to be used in a replication dns test. It could contain the $zrec record"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl $zone" 0 "Checking to ensure that ipa thinks that it can create a zone"
		rlRun "/usr/sbin/ipactl restart" 0 "Restarting IPA server"
		rlRun "ipa dnsrecord-add $zone $arec --a-rec $a" 0 "add record type a to $zone"
	rlPhaseEnd
}

add_slave_dns()
{
	rlPhaseStartTest "create a new a record in $zone on the dns zone"
		rlRun "ipa dnsrecord-add $zone $slavearec --a-rec $slavea" 0 "add record type a to $zone"
	rlPhaseEnd
}

check_dns()
{
	rlPhaseStartTest "make sure that the $arec entry is on this server"
		rlRun "ipa dnsrecord-find $zone $arec | grep $a" 0 "make sure ipa recieved record type A"
		rlRun "dig $arec.$zone | grep $a" 0 "make sure dig can find the A record"
		rlRun "ipa dnsrecord-find $zone $slavearec | grep $slavea" 0 "make sure ipa recieved record type A"
		rlRun "dig $slavearec.$zone | grep $slavea" 0 "make sure dig can find the A record"

	rlPhaseEnd
}

delete_dns()
{
	rlPhaseStartTest "delete the record $arec from $zone, as well as the dns zone"
		rlRun "ipa dnsrecord-del $zone $arec --a-rec $a" 0 "delete record type a"
		#rlRun "ipa dnszone-del $zone" 0 "Delete the zone created for this test"
	rlPhaseEnd
}

delete_slave_dns()
{
	rlPhaseStartTest "delete the record $arec from $zone, as well as the dns zone"
		rlRun "ipa dnsrecord-del $zone $slavearec --a-rec $slavea" 0 "delete record type a"
		rlRun "ipa dnszone-del $zone" 0 "Delete the zone created for this test"
	rlPhaseEnd
}


check_deleteddns()
{
	rlPhaseStartTest "make sure that the $arec entry is removed from this server"
		/etc/init.d/named restart
		rlRun "ipa dnsrecord-find $zone $arec | grep $a" 1 "make sure the record $arec is removed from this server"
		rlRun "ipa dnsrecord-find $zone $slavearec | grep $slavea" 1 "make sure the record $arec is removed from this server"
		rlRun "dig $arec.$zone | grep $a" 1 "make sure dig can not find the A record"
	rlPhaseEnd
}

################################
# hbac section
################################
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
		rlRun "addHostGroup $hostgroup2 $hostgroup2" 0 "SETUP: Adding host group $hostgroup2 for testing."
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

add_slave_hbac()
{
	rlPhaseStartTest "Add host group to Rule"
		rlRun "addToHBAC Engineering host hostgroups $hostgroup2" 0 "Adding host group $hostgroup2 to Engineering rule."
		rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup2" 0 "Verifying host group $hostgroup2 is associated with the Engineering rule."
	rlPhaseEnd

}

check_hbac()
{
	rlPhaseStartTest "Verify HBAC rules exist"
		rlRun "verifyHBACAssoc Engineering Hosts $host1" 0 "Verifying host $host1 is associated with the Engineering rule."
		rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup1" 0 "Verifying host group $hostgroup1 is associated with the Engineering rule."
	rlPhaseEnd
}

check_slave_hbac()
{
	rlPhaseStartTest "Verify slave HBAC rules exist"
		rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup2" 0 "Verifying host group $hostgroup2 is associated with the Engineering rule."
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
	rlPhaseEnd
}

delete_slave_hbac()
{
	rlPhaseStartTest "delete hba entries from hosts"
		rlRun "deleteHostGroup $hostgroup2" 0 "Deleting Host Group associated with rule."
		rlRun "deleteHBACRule Engineering" 0 "CLEANUP: Deleting Rule"
	rlPhaseEnd
}


check_deletedhbac()
{
	rlPhaseStartTest "verify that hostgroup1 was deleted"
		rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup1" 1 "Verifying host group $hostgroup1 is no longer associated with the Engineering rule."
		rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup2" 1 "Verifying host group $hostgroup2 is no longer associated with the Engineering rule."
	rlPhaseEnd
}

################################
# hbac service section
################################
add_hbac_service()
{
	rlPhaseStartTest "add hbac service"
		rlRun "addHBACService $hbacservice1 $hbacservice1" 0 "Adding HBAC service $hbacservice1."
		rlRun "findHBACService $hbacservice1" 0 "Verifying HBAC service $hbacservice1 is found."
		rlRun "verifyHBACService $hbacservice1 \"Service name\" $hbacservice1" 0 "Verify New Service name"
		rlRun "verifyHBACService $hbacservice1 \"Description\" $hbacservice1" 0 "Verify New Service Description"
	rlPhaseEnd
}

add_slave_hbac_service()
{
	rlPhaseStartTest "add hbac slave service"
		rlRun "addHBACService $hbacservice2 $hbacservice2" 0 "Adding HBAC service $hbacservice2."
		rlRun "findHBACService $hbacservice2" 0 "Verifying HBAC service $hbacservice2 is found."
		rlRun "verifyHBACService $hbacservice2 \"Service name\" $hbacservice2" 0 "Verify New Service name"
		rlRun "verifyHBACService $hbacservice2 \"Description\" $hbacservice2" 0 "Verify New Service Description"
	rlPhaseEnd
}

check_hbac_service()
{
	rlPhaseStartTest "check hbac service"
		rlRun "findHBACService $hbacservice1" 0 "Verifying HBAC service $hbacservice1 is found."
		rlRun "findHBACService $hbacservice2" 0 "Verifying HBAC service $hbacservice2 is found."
	rlPhaseEnd

}

modify_hbac_service()
{
	rlPhaseStartTest "Modify hbac-service Description with --desc"
		rlRun "modifyHBACService $hbacservice1 desc \"Newer Description\"" 0 "Modify with --desc service description"
	rlPhaseEnd
}

modify_slave_hbacservice()
{
	rlPhaseStartTest "Modify hbac-service Description with --desc"
		rlRun "modifyHBACService $hbacservice2 desc \"Newer Description\"" 0 "Modify with --desc service description"
	rlPhaseEnd
}


check_modifiedhbacservice()
{
	rlPhaseStartTest "Check modified hbac-service Description with --desc"
		rlRun "verifyHBACService $hbacservice1 \"Description\" \"Newer Description\"" 0 "Verify New Service Description"
	rlPhaseEnd
}

check_slave_modifiedhbacservice()
{
	rlPhaseStartTest "Check modified hbac-service Description with --desc"
		rlRun "verifyHBACService $hbacservice2 \"Description\" \"Newer Description\"" 0 "Verify New Service Description"
	rlPhaseEnd
}

delete_hbac_service()
{
	rlPhaseStartTest "delete hbac serivce $hbacservice1"
		rlRun "deleteHBACService $hbacservice1" 0 "CLEANUP: Deleting service $hbacservice1"
	 rlPhaseEnd
}

delete_slave_hbac_service()
{
	rlPhaseStartTest "delete hbac serivce $hbacservice2"
		rlRun "deleteHBACService $hbacservice2" 0 "CLEANUP: Deleting service $hbacservice2"
	 rlPhaseEnd
}


check_deletedhbacservice()
{
	rlPhaseStartTest "check hbac service is removed"
		rlRun "findHBACService $hbacservice1" 1 "Verifying HBAC service $hbacservice1 is not found."
		rlRun "findHBACService $hbacservice2" 1 "Verifying HBAC service $hbacservice2 is not found."
	rlPhaseEnd
}

################################
# permission section
################################
add_permission()
{
	rlPhaseStartTest "add a permission"
		rlRun "ipa permission-add $puser1 --type=user --permissions=delete"
	rlPhaseEnd
}
add_slave_permission()
{
	rlPhaseStartTest "add a permission "
		rlRun "ipa permission-add $puser2 --type=user --permissions=delete"
	rlPhaseEnd
}
check_permission()
{
	rlPhaseStartTest "check to ensure that the permission exists"
		rlRun "ipa permission-show $puser1 | grep delete" 0 "checking to make sure that the permission got installed"		
		rlRun "ipa permission-show $puser2 | grep delete" 0 "checking to make sure that the permission got installed"		
	rlPhaseEnd
}
modify_permission()
{
	rlPhaseStartTest "mod  permissions"
		rlRun "ipa permission-mod $puser1 --type=user --permissions=add"
	rlPhaseEnd
}
mod_slave_permission()
{
	rlPhaseStartTest "mod  permissions"
		rlRun "ipa permission-mod $puser2 --type=user --permissions=add"
	rlPhaseEnd
}
check_modifiedpermission()
{
	rlPhaseStartTest "check to ensure that the permission has been modified"
		rlRun "ipa permission-show $puser1 | grep add" 0 "checking to make sure that the permission got modified"		
	rlPhaseEnd
}
check_slave_modifiedpermission()
{
	rlPhaseStartTest "check to ensure that the permission has been modified"
		rlRun "ipa permission-show $puser2 | grep add" 0 "checking to make sure that the permission got modified"		
	rlPhaseEnd
}
delete_permission()
{
	rlPhaseStartTest "delete added permission from master"
		rlRun "ipa permission-del $puser1" 0 " deleting the permission"
	rlPhaseEnd
}
delete_slave_permission()
{
	rlPhaseStartTest "delete added permission from slave"
		rlRun "ipa permission-del $puser2" 0 " deleting the permission"
	rlPhaseEnd
}
check_deletedpermission()
{
	rlPhaseStartTest "delete a permission"
		rlRun "ipa permission-show $puser1 | grep add" 1 "checking to make sure that the permission is not arund any more"
		rlRun "ipa permission-show $puser2 | grep add" 1 "checking to make sure that the permission added on the slave is not arund any more"
	rlPhaseEnd
}

################################
# sudo rule
################################
add_sudorule()
{
	rlPhaseStartTest "add a sudo rule"
		rlRun "ipa sudorule-add $rule1" 0 "creating $rule1 for replication testing"
	rlPhaseEnd
}
add_slave_sudorule()
{
	rlPhaseStartTest "add a sudo rule to the slave"
		rlRun "ipa sudorule-add $rule2" 0 "creating $rule2 for replication testing"
	rlPhaseEnd
}
check_sudorule()
{
	rlPhaseStartTest "check to make sure that the sudo rule exists"
		rlRun "ipa sudorule-find $rule1" 0 "finding sudo rule $rule1"
		rlRun "ipa sudorule-find $rule2" 0 "finding sudo rule $rule2"
	rlPhaseEnd
}
modify_sudorule()
{
	rlPhaseStartTest "disabling $rule1 for replication testing"
		rlRun "ipa sudorule-disable $rule1" 0 "disabling $rule1"
	rlPhaseEnd
}
modify_slave_sudorule()
{
	rlPhaseStartTest "disabling $rule2 for replication testing"
		rlRun "ipa sudorule-disable $rule2" 0 "disabling $rule2"
	rlPhaseEnd
}
check_modifiedsudorule()
{
	rlPhaseStartTest "check to make sure that the sudo rule exists, and is disabled"
		rlRun "ipa sudorule-find $rule1 | grep Enabled | grep FALSE" 0 "finding sudo rule $rule1 and making sure it is disabled"
	rlPhaseEnd
}
check_slave_modifiedsudorule()
{
	rlPhaseStartTest "check to make sure that the sudo rule exists, and is disabled"
		rlRun "ipa sudorule-find $rule2 | grep Enabled | grep FALSE" 0 "finding sudo rule $rule2 and making sure it is disabled"
	rlPhaseEnd
}
delete_sudorule()
{
	rlPhaseStartTest "deleting $rule1"
		rlRun "ipa sudorule-del $rule1" 0 "deleting $rule1"
	rlPhaseEnd
}
delete_slave_sudorule()
{
	rlPhaseStartTest "deleting $rule2"
		rlRun "ipa sudorule-del $rule2" 0 "deleting $rule2"
	rlPhaseEnd
}
check_deletedsudorule()
{
	rlPhaseStartTest "check to make sure that the sudo rule does not exist"
		rlRun "ipa sudorule-find $rule1" 1 "finding sudo rule $rule1"
		rlRun "ipa sudorule-find $rule2" 1 "finding sudo rule $rule2"
	rlPhaseEnd
}

################################
# sudo cmd
################################
add_sudocmd()
{
	rlPhaseStartTest "add a sudo cmd"
		rlRun "ipa sudocmd-add --desc='for testing' $cmdrule1" 0 "creating $cmdrule1 for replication testing"
	rlPhaseEnd
}
add_slave_sudocmd()
{
	rlPhaseStartTest "add a sudo cmd"
		rlRun "ipa sudocmd-add --desc='for testing' $cmdrule2" 0 "creating $cmdrule2 for replication testing"
	rlPhaseEnd
}
check_sudocmd()
{
	rlPhaseStartTest "check to make sure that the sudo cmd exists"
		rlRun "ipa sudocmd-find $cmdrule1" 0 "finding sudo cmd $cmdrule1"
		rlRun "ipa sudocmd-find $cmdrule2" 0 "finding sudo cmd $cmdrule2"
	rlPhaseEnd
}
modify_sudocmd()
{
	rlPhaseStartTest "modding $cmdrule1 for replication testing"
		rlRun "ipa sudocmd-mod --desc=newdesc $cmdrule1" 0 "modding $cmdrule1"
	rlPhaseEnd
}
modify_slave_sudocmd()
{
	rlPhaseStartTest "modding $cmdrule2 for replication testing"
		rlRun "ipa sudocmd-mod --desc=newdesc $cmdrule2" 0 "modding $cmdrule2"
	rlPhaseEnd
}
check_modifiedsudocmd()
{
	rlPhaseStartTest "check to make sure that the sudo cmd is moddified"
		rlRun "ipa sudocmd-find $cmdrule1 | grep newdesc" 0 "finding sudo rule $cmdrule1 and making sure it is disabled"
	rlPhaseEnd
}
check_slave_modifiedsudocmd()
{
	rlPhaseStartTest "check to make sure that the sudo cmd moddified on the slave is moddified"
		rlRun "ipa sudocmd-find $cmdrule2 | grep newdesc" 0 "finding sudo rule $cmdrule2 and making sure it is disabled"
	rlPhaseEnd
}
delete_sudocmd()
{
	rlPhaseStartTest "deleting $cmdrule1"
		rlRun "ipa sudocmd-del $cmdrule1" 0 "deleteing sudo cmd $cmdrule1"
	rlPhaseEnd
}
delete_slave_sudocmd()
{
	rlPhaseStartTest "deleting $cmdrule2"
		rlRun "ipa sudocmd-del $cmdrule2" 0 "deleteing sudo cmd $cmdrule2"
	rlPhaseEnd
}
check_deletedsudocmd()
{
	rlPhaseStartTest "check to make sure that the sudo cmd does not exist"
		rlRun "ipa sudocmd-find $cmdrule1" 1 "finding sudo cmd $cmdrule1"
		rlRun "ipa sudocmd-find $cmdrule2" 1 "finding sudo cmd $cmdrule2"
	rlPhaseEnd
}

################################
# sudo cmd group
################################
add_sudocmdgroup()
{
	rlPhaseStartTest "add a sudo cmd group"
		rlRun "ipa sudocmdgroup-add --desc='replication admins' $cmdgrp1" 0 "creating $cmdgrp1 for replication testing"
	rlPhaseEnd
}
add_slave_sudocmdgroup()
{
	rlPhaseStartTest "add a sudo cmd group on the slave"
		rlRun "ipa sudocmdgroup-add --desc='replication admins' $cmdgrp2" 0 "creating $cmdgrp2 for replication testing"
	rlPhaseEnd
}
check_sudocmdgroup()
{
	rlPhaseStartTest "check to make sure that the sudo cmd group exists"
		rlRun "ipa sudocmdgroup-find $cmdgrp1" 0 "finding sudo cmd group $cmdgrp1"
		rlRun "ipa sudocmdgroup-find $cmdgrp2" 0 "finding sudo cmd group $cmdgrp2"
	rlPhaseEnd
}
modify_sudocmdgroup()
{
	rlPhaseStartTest "modding $cmdgrp1 for replication testing"
		rlRun "ipa sudocmdgroup-mod --desc=newdesc $cmdgrp1" 0 "modding $cmdgrp1"
	rlPhaseEnd
}
modify_slave_sudocmdgroup()
{
	rlPhaseStartTest "modding $cmdgrp2 for replication testing"
		rlRun "ipa sudocmdgroup-mod --desc=newdesc $cmdgrp2" 0 "modding $cmdgrp2"
	rlPhaseEnd
}
check_modifiedsudocmdgroup()
{
	rlPhaseStartTest "check to make sure that the sudo cmd group is moddified"
		rlRun "ipa sudocmdgroup-find $cmdgrp1 | grep newdesc" 0 "finding sudo group $cmdgrp1 and making sure it is disabled"
	rlPhaseEnd
}
check_slave_modifiedsudocmdgroup()
{
	rlPhaseStartTest "check to make sure that the sudo cmd group modified on the slave is moddified"
		rlRun "ipa sudocmdgroup-find $cmdgrp2 | grep newdesc" 0 "finding sudo group $cmdgrp2 and making sure it is disabled"
	rlPhaseEnd
}
delete_sudocmdgroup()
{
	rlPhaseStartTest "deleting $cmdgrp1"
		rlRun "ipa sudocmdgroup-del $cmdgrp1" 0 "deleteing sudo cmd group $cmdgrp1"
	rlPhaseEnd
}
delete_slave_sudocmdgroup()
{
	rlPhaseStartTest "deleting $cmdgrp2"
		rlRun "ipa sudocmdgroup-del $cmdgrp2" 0 "deleteing sudo cmd group $cmdgrp2"
	rlPhaseEnd
}
check_deletedsudocmdgroup()
{
	rlPhaseStartTest "check to make sure that the sudo command group does not exist"
		rlRun "ipa sudocmdgroup-find $cmdgrp1" 1 "finding sudo cmd $cmdgrp1"
		rlRun "ipa sudocmdgroup-find $cmdgrp2" 1 "finding sudo cmd $cmdgrp2"
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

add_slave_config()
{
	rlPhaseStartTest "modify a config entry to ensure that the change takes everywhere."
		rlRun "ipa config-mod --maxusername=993" 0 "modifying max username length"
	rlPhaseEnd

}

check_config()
{
	rlPhaseStartTest "making sure that the new max usernames is shown"
		rlRun "ipa config-show | grep 993" 0 "making sure that the new max usernames is specified"
	rlPhaseEnd
}

modify_config()
{
	rlPhaseStartTest "modify a config entry back to something a little more sane"
		rlRun "ipa config-mod --maxusername=25" 0 "modifying max username length"
	rlPhaseEnd
}


check_modifiedconfig()
{
	rlPhaseStartTest "making sure that the new max usernames is shown"
		rlRun "ipa config-show | grep 25" 0 "making sure that the new max usernames is specified correctly"
	rlPhaseEnd
}

################################
# pwpolicy section
################################
add_pwpolicy()
{
	ipa group-add --desc=tg $tg
	rlPhaseStartTest "adding pwpolicy"
		rlRun "ipa pwpolicy-add --maxlife=999  --priority=10 $tg" 0 "setting password policy to something high"
	rlPhaseEnd
}
add_slave_pwpolicy()
{
	ipa group-add --desc=tg $ts
	rlPhaseStartTest "adding pwpolicy to a user on the slave server"
		rlRun "ipa pwpolicy-add --maxlife=999  --priority=9 $ts" 0 "setting password policy to something high"
	rlPhaseEnd
}
check_pwpolicy()
{
	rlPhaseStartTest "Searching for added pwpolicy"
		rlRun "ipa pwpolicy-find $tg | grep 999" 0 "Searching for added pwpolicy"
		rlRun "ipa pwpolicy-find $ts | grep 999" 0 "Searching for added pwpolicy"
	rlPhaseEnd
}
modify_pwpolicy()
{	rlPhaseStartTest "modifying pwpolicy for test group"
		rlRun "ipa pwpolicy-mod --maxlife=384 $tg" 0 "modifying pwpolicy for test group"
	rlPhaseEnd
}
modify_slave_pwpolicy()
{	rlPhaseStartTest "modifying pwpolicy for test group on slave"
		rlRun "ipa pwpolicy-mod --maxlife=384 $ts" 0 "modifying pwpolicy for test group"
	rlPhaseEnd
}
check_modifiedpwpolicy()
{
	rlPhaseStartTest "Searching for modified pwpolicy in tg"
		rlRun "ipa pwpolicy-find $tg | grep 384" 0 "Searching for modified pwpolicy in tg"
	rlPhaseEnd
}
check_slave_modifiedpwpolicy()
{
	rlPhaseStartTest "Searching for modified pwpolicy in the slave for user $ts"
		rlRun "ipa pwpolicy-find $ts | grep 384" 0 "Searching for modified pwpolicy in ts"
	rlPhaseEnd
}
delete_pwpolicy()
{
	rlPhaseStartTest "Deleting the password policy for the testgroup"
		rlRun "ipa pwpolicy-del $tg" 0 "Deleting the password policy for the testgroup"
	rlPhaseEnd
}
delete_slave_pwpolicy()
{
	rlPhaseStartTest "Deleting the password policy for the testgroup added to the slave"
		rlRun "ipa pwpolicy-del $ts" 0 "Deleting the password policy for the testgroup added to the slave"
	rlPhaseEnd
}
check_deletedpwpolicy()
{
	rlPhaseStartTest "Making sure that the test groups pwpolicy doesn't seem to be searchable"
		rlRun "ipa pwpolicy-find $tg" 1 "Making sure that the test group pwpolicy doesn't seem to be searchable"
		rlRun "ipa pwpolicy-find $ts" 1 "Making sure that the test group pwpolicy doesn't seem to be searchable"
	rlPhaseEnd
	# Cleanup of test group
	ipa group-del $tg
	ipa group-del $ts
}

################################
# selfservice section
################################
add_selfservice()
{
	rlPhaseStartTest "adding a selfservice section"
		rlRun "ipa selfservice-add --permissions=write --attrs=street,postalCode,l,c,st $ss" 0 "adding a selfservice section"
	rlPhaseEnd
}
add_slave_selfservice()
{
	rlPhaseStartTest "adding a selfservice to the slave"
		rlRun "ipa selfservice-add --permissions=write --attrs=street,postalCode,l,c,st $sr" 0 "adding a selfservice to the slave"
	rlPhaseEnd
}
check_selfservice()
{
	rlPhaseStartTest "Searching for added selfservice"
		rlRun "ipa selfservice-find $ss | grep -i postalCode" 0 "Searching for added selfservice"
		rlRun "ipa selfservice-find $sr | grep -i postalCode" 0 "Searching for added selfservice"
	rlPhaseEnd
}
modify_selfservice()
{	rlPhaseStartTest "modifying selfservice rule"
		rlRun "ipa selfservice-mod --attrs=street,postalCode,l,c,st,telephoneNumber $ss" 0 "modifying selfservice rule"
	rlPhaseEnd
}
modify_slave_selfservice()
{	rlPhaseStartTest "modifying selfservice rule on the slave"
		rlRun "ipa selfservice-mod --attrs=street,postalCode,l,c,st,telephoneNumber $sr" 0 "modifying selfservice rule on the slave"
	rlPhaseEnd
}
check_modifiedselfservice()
{
	rlPhaseStartTest "Searching for modified selfservice policy"
		rlRun "ipa selfservice-find $ss | grep -i telephoneNumber" 0 "Searching for modified selfservice policy"
	rlPhaseEnd
}
check_slave_modifiedselfservice()
{
	rlPhaseStartTest "Searching for modified selfservice policy on the slave"
		rlRun "ipa selfservice-find $sr | grep -i telephoneNumber" 0 "Searching for modified selfservice policy on the slave"
	rlPhaseEnd
}
delete_selfservice()
{
	rlPhaseStartTest "Deleting the self service"
		rlRun "ipa selfservice-del $ss" 0 "Deleting the self service"
	rlPhaseEnd
}
delete_slave_selfservice()
{
	rlPhaseStartTest "Deleting the self service from the slave"
		rlRun "ipa selfservice-del $sr" 0 "Deleting the self service from the slave"
	rlPhaseEnd
}
check_deletedselfservice()
{
		rlPhaseStartTest "Searching for removed selfservice"
		rlRun "ipa selfservice-find $ss" 1 "Searching for removed selfservice"
		rlRun "ipa selfservice-find $sr" 1 "Searching for the selfservice removed from the slave"
	rlPhaseEnd
}

################################
# privilege section
################################
add_privilege()
{
	rlPhaseStartTest "Add a privilege"
		rlRun "ipa privilege-add --desc='test desc' $priv" 0 "adding a priviege"
	rlPhaseEnd
}
add_slave_privilege()
{
	rlPhaseStartTest "Add a privilege to the slave"
		rlRun "ipa privilege-add --desc='test desc' $priv2" 0 "adding a priviege to the slave"
	rlPhaseEnd
}
check_privilege()
{
	rlPhaseStartTest "check to ensure that the privilege exists"
		rlRun "ipa privilege-find $priv | grep 'test desc'" 0 "Searching for that added privilege"
		rlRun "ipa privilege-find $priv2 | grep 'test desc'" 0 "Searching for that privilege added to the slave"
	rlPhaseEnd
}
modify_privilege()
{	rlPhaseStartTest "Modify the privilege"
		rlRun "ipa privilege-mod --desc='newdesc' $priv" 0 "modifying privilege"
	rlPhaseEnd
}
modify_slave_privilege()
{	rlPhaseStartTest "Modify the privilege added to the slave"
		rlRun "ipa privilege-mod --desc='newdesc' $priv2" 0 "modifying privilege on slave"
	rlPhaseEnd
}
check_modifiedprivilege()
{
	rlPhaseStartTest "Find the modified privilege"
		rlRun "ipa privilege-find $priv | grep newdesc" 0 "Searching for modified privilege"
	rlPhaseEnd
}
check_slave_modifiedprivilege()
{
	rlPhaseStartTest "Find the modified privilege from the slave"
		rlRun "ipa privilege-find $priv2 | grep newdesc" 0 "Searching for modified privilege from the slave"
	rlPhaseEnd
}
delete_privilege()
{
	rlPhaseStartTest "deleting privilege"
		rlRun "ipa privilege-del $priv" 0 "Deleting the privilege"
	rlPhaseEnd
}
delete_slave_privilege()
{
	rlPhaseStartTest "deleting privilege from the slave"
		rlRun "ipa privilege-del $priv2" 0 "Deleting the privilege from the slave"
	rlPhaseEnd
}
check_deletedprivilege()
{
	rlPhaseStartTest "check to ensure that privilege was deleted."
		rlRun "ipa privilege-find $priv" 1 "Searching for removed privilege"
		rlRun "ipa privilege-find $priv2" 1 "Searching for privilege removed from the slave"
	rlPhaseEnd
}

################################
# role section
################################
add_role()
{
	rlPhaseStartTest "Add a role"
		rlRun "ipa role-add --desc testrole $role" 0 "adding a role"
	rlPhaseEnd
}
add_slave_role()
{
	rlPhaseStartTest "Add a role to the slave"
		rlRun "ipa role-add --desc testrole $role2" 0 "adding a role to the slave"
	rlPhaseEnd
}
check_role()
{
	rlPhaseStartTest "check to ensure that the role exists"
		rlRun "ipa role-find $role | grep testrole" 0 "Searching for that added role"
		rlRun "ipa role-find $role2 | grep testrole" 0 "Searching for the role added on the slave"
	rlPhaseEnd
}
modify_role()
{	rlPhaseStartTest "Modify the role"
		rlRun "ipa role-mod --desc='altdesc' $role" 0 "modifying role"
	rlPhaseEnd
}
modify_slave_role()
{	rlPhaseStartTest "Modify the role on the slave"
		rlRun "ipa role-mod --desc='altdesc' $role2" 0 "modifying role on the slave"
	rlPhaseEnd
}
check_modifiedrole()
{
	rlPhaseStartTest "Find the modified role"
		rlRun "ipa role-find $role | grep altdesc" 0 "Searching for modified role"
	rlPhaseEnd
}
check_slave_modifiedrole()
{
	rlPhaseStartTest "Find the modified role from the slave"
		rlRun "ipa role-find $role2 | grep altdesc" 0 "Searching for modified role from the slave"
	rlPhaseEnd
}
delete_role()
{
	rlPhaseStartTest "deleting role"
		rlRun "ipa role-del $role" 0 "Deleting the role"
	rlPhaseEnd
}
delete_slave_role()
{
	rlPhaseStartTest "deleting role"
		rlRun "ipa role-del $role2" 0 "Deleting the role from the slave"
	rlPhaseEnd
}
check_deletedrole()
{
	rlPhaseStartTest "check to ensure that role was deleted."
		rlRun "ipa role-find $role" 1 "Searching for removed role"
		rlRun "ipa role-find $role2" 1 "Searching for role removed from the server"
	rlPhaseEnd
}

