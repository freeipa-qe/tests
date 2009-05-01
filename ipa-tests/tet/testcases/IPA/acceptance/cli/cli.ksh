#!/bin/ksh

######################################################################

# The following ipa cli commands needs to be tested:
#  aci-add                   Add a new aci.
#  aci-del                   Delete an existing aci.
#  aci-find                  Search for a aci.
#  aci-mod                   Edit an existing aci.
#  aci-show                  Examine an existing aci.
#  aci-showall               Examine all existing acis.
#  application-create        Add a new application
#  application-delete        Delete an application
#  application-edit          Edit an existing application
#  application-find          Search for applications
#  application-show          Examine an existing application
#  automount-addindirectmap  Add a new automap indirect mount point.
#  automount-addkey          Add a new automount key.
#  automount-addmap          Add a new automount map.
#  automount-delkey          Delete an automount key.
#  automount-delmap          Delete an automount map.
#  automount-findkey         Search automount keys.
#  automount-findmap         Search automount maps.
#  automount-getkeys         Retrieve all keys for an automount map.
#  automount-getmaps         Retrieve all automount maps
#  automount-modkey          Edit an existing automount key.
#  automount-modmap          Edit an existing automount map.
#  automount-showkey         Examine an existing automount key.
#  automount-showmap         Examine an existing automount map.
#  automount-tofiles         Generate the automount maps as they would be in the filesystem
#  console                   Start the IPA interactive Python console.
#  defaultoptions-mod        Options command.
#  defaultoptions-show       Retrieve current default options
#  delegation-add            Add a new delegation.
#  delegation-del            Delete an existing delegation.
#  delegation-find           Search for a delegation.
#  delegation-mod            Edit an existing delegation.
#  delegation-show           Examine an existing delegation.
#  env                       Show environment variables
#  group-add                 Add a new group.
#  group-add-member          Add a member to a group.
#  group-del                 Delete an existing group.
#  group-find                Search the groups.
#  group-mod                 Edit an existing group.
#  group-remove-member       Remove a member from a group.
#  group-show                Examine an existing group.
#  help                      Display help for a command or topic.
#  host-add                  Add a new host.
#  host-del                  Delete an existing host.
#  host-find                 Search the hosts.
#  host-mod                  Edit an existing host.
#  host-show                 Examine an existing host.
#  hostgroup-add             Add a new hostgroup.
#  hostgroup-add-member      Add a member to a hostgroup.
#  hostgroup-del             Delete an existing hostgroup.
#  hostgroup-find            Search the groups.
#  hostgroup-mod             Edit an existing hostgroup.
#  hostgroup-remove-member   Remove a member from a hostgroup.
#  hostgroup-show            Examine an existing hostgroup.
#  join                      Join an IPA domain
#  netgroup-add              Add a new netgroup.
#  netgroup-add-member       Add a member to a netgroup.
#  netgroup-del              Delete an existing netgroup.
#  netgroup-find             Search the groups.
#  netgroup-mod              Edit an existing netgroup.
#  netgroup-remove-member    Remove a member from a netgroup.
#  netgroup-show             Examine an existing netgroup.
#  passwd                    Edit existing password policy.
#  plugins                   Show all loaded plugins
#  pwpolicy-mod              Edit existing password policy.
#  pwpolicy-show             Retrieve current password policy
#  rolegroup-add             Add a new rolegroup.
#  rolegroup-add-member      Add a member to a rolegroup.
#  rolegroup-del             Delete an existing rolegroup.
#  rolegroup-find            Search the groups.
#  rolegroup-mod             Edit an existing rolegroup.
#  rolegroup-remove-member   Remove a member from a rolegroup.
#  rolegroup-show            Examine an existing rolegroup.
#  service-add               Add a new service.
#  service-del               Delete an existing service.
#  service-find              Search the existing services.
#  service-show              Examine an existing service.
#  taskgroup-add             Add a new taskgroup.
#  taskgroup-add-member      Add a member to a taskgroup.
#  taskgroup-del             Delete an existing taskgroup.
#  taskgroup-find            Search the groups.
#  taskgroup-mod             Edit an existing taskgroup.
#  taskgroup-remove-member   Remove a member from a taskgroup.
#  taskgroup-show            Examine an existing taskgroup.
#  taskgroup-showall         List all taskgroups.
#  user2-create              Create new user.
#  user2-delete              Delete user.
#  user2-find                Search for users.
#  user2-lock                Lock user account.
#  user2-mod                 Modify user.
#  user2-show                Display user.
#  user2-unlock              Unlock user account.
#  user-add                  Add a new user.
#  user-del                  Delete an existing user.
#  user-find                 Search for users.
#  user-lock                 Lock a user account.
#  user-mod                  Edit an existing user.
#  user-show                 Examine an existing user.
#  user-unlock               Unlock a user account.

######################################################################
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="cli_cleanup"
iclist="ic1 "
ic1="tp1 tp2 tp3 hostlist servicelist adduser delegationlist acilist tp14 tp15 tp16 tp17 tp18 tp19 tp20"
hostlist="ipahostfind ipahostshow ipahostmoda ipahostmodb ipahostmodc ipahostmodd ipahostmode ipahostdel"
servicelist="ipaserviceprepare ipaserviceadd ipaserviceaddb ipaserviceaddc negaddservice negaddserviceb negaddservicec ipaservicedel ipaservicedelb ipaservicedelc ipanegservicedel ipaservicecleanup"
delegationlist="adddelegationsetup"
acilist=""
# These services will be used by the tests, and removed when the cli test is complete
host1='alpha.dsdev.sjc.redhat.com'
service1="ssh/$host1"
service2="nfs/$host1"
service3="ldap/$host1"

# Users to be used in varios tests
superuser="sup34"

######################################################################
tp1()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - kinit on $s failed"
				tet_result FAIL
			fi
		else
			echo "skipping $s"
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - kinit on $s failed"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################
tp2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			# test for ipactl
			ssh root@$FULLHOSTNAME 'ipactl restart'
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipactl restart failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

# ipa host-add
tp3()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa host-add
			ssh root@$FULLHOSTNAME "ipa host-add \"$host1\""
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - ipa host-add failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# Verifying
			ssh root@$FULLHOSTNAME "ipa host-find \"$host1\" | grep $host1"
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-find \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

# ipa host-find
ipahostfind()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# check return code
			ssh root@$FULLHOSTNAME "ipa host-find \"$host1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-find \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# check output
			ssh root@$FULLHOSTNAME "ipa host-find \"$host1\" | grep $host1"
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-find \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

# ipa host-show
ipahostshow()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# check return code
			ssh root@$FULLHOSTNAME "ipa host-show \"$host1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-show \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# check output
			ssh root@$FULLHOSTNAME "ipa host-show \"$host1\" | grep $host1"
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-show \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

# ipa host-mod
ipahostmoda()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# check return code
			ssh root@$FULLHOSTNAME "ipa host-mod --location=testloc \"$host1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-mod \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# check output
			ssh root@$FULLHOSTNAME "ipa host-show \"$host1\" | grep testloc"
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-show \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

# ipa host-mod
ipahostmodb()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# check return code
			ssh root@$FULLHOSTNAME "ipa host-mod --platform=MAC \"$host1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-mod \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# check output
			ssh root@$FULLHOSTNAME "ipa host-show \"$host1\" | grep MAC"
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-show \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

# ipa host-mod
ipahostmodc()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# check return code
			ssh root@$FULLHOSTNAME "ipa host-mod --os=osx \"$host1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-mod \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# check output
			ssh root@$FULLHOSTNAME "ipa host-show \"$host1\" | grep osx"
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-show \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

# ipa host-mod
ipahostmodd()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# check return code
			ssh root@$FULLHOSTNAME "ipa host-mod --description='interesting description' \"$host1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-mod \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# check output
			ssh root@$FULLHOSTNAME "ipa host-show \"$host1\" | grep 'interesting description'"
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-show \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

# ipa host-mod
ipahostmode()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# check return code
			ssh root@$FULLHOSTNAME "ipa host-mod --locality='mountain view, ca' \"$host1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-mod \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# check output
			ssh root@$FULLHOSTNAME "ipa host-show \"$host1\" | grep 'mountain view, ca'"
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-show \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

# ipa host-del
ipahostdel()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# check return code
			ssh root@$FULLHOSTNAME "ipa host-del \"$host1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-del \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# check output
			ssh root@$FULLHOSTNAME "ipa host-show \"$host1\" | grep 'mountain view, ca'"
			if [ $? -eq 0 ]
			then
				echo "ERROR - ipa host-show \"$host1\" passed when it should not have on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
# Setup the enviroment for the ipaservice tests
ipaserviceprepare()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s
			# test for ipa host-add
			ssh root@$FULLHOSTNAME "ipa host-add \"$host1\""
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - ipa host-add failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
ipaserviceadd()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa service-add \"$service1\""
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - ipa service-add failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa service-find \"$service1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa-findservice failed on $FULLHOSTNAME"
				tet_result FAIL
			fi

		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

################################################################
# Negitive test case of ipa service-add
################################################################
negaddservice()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "M1" ]&&[ "$s" != "" ]; then
			eval_vars $s

			echo "this step is supposed to fail"
			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa service-add \"$service1\""
			ret=$?
			if [ $ret -eq 0 ]
			then
				echo "ERROR - ipa service-add passed when it should not have on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
ipaserviceaddb()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-addservice \"$service2\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa-addservice failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa-findservice \"$service2\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa-findservice failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
ipaserviceaddc()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-addservice \"$service3\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa-addservice failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# Sleeping for 10 seconds to allow addservice to sync
			sleep 10;
		fi
		ssh root@$FULLHOSTNAME "ipa-findservice \"$service3\""
		if [ $? -ne 0 ]
		then
			echo "ERROR - ipa-findservice failed on $FULLHOSTNAME"
			tet_result FAIL
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

################################################################
# Negitive test case of ipaserviceaddb
################################################################
negaddserviceb()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "M1" ]&&[ "$s" != "" ]; then
			eval_vars $s

			echo "this step is supposed to fail"
			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-addservice \"$service2\""
			ret=$?
			if [ $ret -eq 0 ]
			then
				echo "ERROR - ipa-addservice passed when it should not have on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

################################################################
# Negitive test case of tp5
################################################################
negaddservicec()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "M1" ]&&[ "$s" != "" ]; then
			eval_vars $s

			echo "this step is supposed to fail"
			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-addservice \"$service3\""
			ret=$?
			if [ $ret -eq 0 ]
			then
				echo "ERROR - ipa-addservice passed when it should not have on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}
#
###############################################################################
ipaservicedel()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa service-del \"$service1\""
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - ipa service-del failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa service-find \"$service1\""
			if [ $? -eq 0 ]
			then
				echo "ERROR - ipa service-find passed when it should not have on $FULLHOSTNAME"
				tet_result FAIL
			fi

		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

###############################################################################
ipaservicedelb()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa service-del \"$service2\""
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - ipa service-del failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa service-find \"$service2\""
			if [ $? -eq 0 ]
			then
				echo "ERROR - ipa service-find passed when it should not have on $FULLHOSTNAME"
				tet_result FAIL
			fi

		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

###############################################################################
ipaservicedelc()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa service-del \"$service3\""
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - ipa service-del failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa service-find \"$service3\""
			if [ $? -eq 0 ]
			then
				echo "ERROR - ipa service-find passed when it should not have on $FULLHOSTNAME"
				tet_result FAIL
			fi

		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

###############################################################################
ipanegservicedel()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa service-del \"$service3\""
			ret=$?
			if [ $ret -eq 0 ]
			then
				echo "ERROR - ipa service-del passed when it should not have on $FULLHOSTNAME"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa service-find \"$service3\""
			if [ $? -eq 0 ]
			then
				echo "ERROR - ipa service-find passed when it should not have on $FULLHOSTNAME"
				tet_result FAIL
			fi

		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}


# Cleanup host used in the service cli tests
ipaservicecleanup()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# run cleanup of services and host
			ssh root@$FULLHOSTNAME "ipa service-del \"$service1\";ipa service-del \"$service2\";ipa service-del \"$service3\""
			ssh root@$FULLHOSTNAME "ipa host-del \"$host1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-del \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# check output
			ssh root@$FULLHOSTNAME "ipa host-show \"$host1\" | grep 'mountain view, ca'"
			if [ $? -eq 0 ]
			then
				echo "ERROR - ipa host-show \"$host1\" passed when it should not have on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
# ipa-adduser
######################################################################
adduser()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-add --first=firstname-super --last=lastbname-super $superuser"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-add failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find $superuser | grep uid | grep $superuser"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - Search for created user failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# adddelegation setup
######################################################################
adddelegationsetup()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	# Setting up for test
	ssh root@$FULLHOSTNAME "ipa user-add --first=firstname-mod1 --last=lastbname-mod1 usermod1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-add --description=super-user superg"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-add --description=group-to-mod-users modusers"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-add-member --users=$superuser superg"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-add-member --users=usermod1 modusers"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - setup for $tet_thistest failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa delegation-add --attributes telephonenumber --source=superg --target=modusers namef"
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo "ERROR - ipa-adddelegation failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"

}

################################################################
# Check to make sure adddegation from tp13 exists everywhere
################################################################
tp14()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "M1" ]&&[ "$s" != "" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-listdelegation -n namef"
			if [ $? -ne 0 ]
			then
				echo "that didn't work, try the old method"
				ssh root@$FULLHOSTNAME "ipa-listdelegation namef"
				if [ $? -ne 0 ]; then
					echo "ERROR - ipa-listdelegation failed on $FULLHOSTNAME"
					tet_result FAIL
				fi
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}
#
######################################################################

######################################################################
# ipa-moddelegation
######################################################################
tp15()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa-moddelegation -a uid=9933 namef"
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo "ERROR - ipa-moddelegation failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

################################################################
# Check to make sure delegation from tp15 exists everywhere
################################################################
tp16()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "M1" ]&&[ "$s" != "" ]; then
			eval_vars $s

			ssh root@$FULLHOSTNAME "ipa-listdelegation -n namef"
			if [ $? -eq 0 ]; then
				# new method
				search_string="ipa-listdelegation -n namef | grep uid | grep 9933"
			else
				# old method
				search_string="ipa-listdelegation namef | grep uid | grep 9933"
			fi
			ssh root@$FULLHOSTNAME "$search_string"
			if [ $? -ne 0 ]
			then
				echo "ERROR - $search_string failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
# ipa-deldelegation
######################################################################
tp17()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa-deldelegation namef"
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo "ERROR - ipa-deldelegation failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

################################################################
# Check to make sure delegation from tp15 exists everywhere
################################################################
tp18()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "M1" ]&&[ "$s" != "" ]; then
			eval_vars $s

			echo "this step is supposed to fail"
			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-listdelegation -n namef"
			ret=$?
			if [ $ret -eq 0 ]
			then
				echo "ERROR - ipa-listdelegation passed when it should not have $FULLHOSTNAME"
				# Because of bug 452027 this test will always fail. So, until the bug is fixed, the FAIL part will be commented out.
				# This is a known bug, so Fail if IGNORE_KNOWN_BUGS isn't set.
				if [ "$IGNORE_KNOWN_BUGS" != "y" ]; then
					tet_result FAIL
				else
					echo "Ignoring because IGNORE_KNOWN_BUGS is set"
				fi
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
# ipa-moduser
######################################################################
tp19()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	
	fname="kekekejrhr"
	ssh root@$FULLHOSTNAME "ipa-moduser -f $fname $superuser"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa-moduser failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa-finduser $superuser | grep First\ Name | grep $fname"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - Search for modified user failed on $FULLHOSTNAME"
				echo "Possibly due to bug https://bugzilla.redhat.com/show_bug.cgi?id=451318"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# ipa-getkeytab
######################################################################
tp20()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	
	ssh root@$FULLHOSTNAME "ipa-addservice \"$service1\""
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa-addservice failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	server1=$FULLHOSTNAME
	servicehost=`echo $service1 | sed s=/=\ = | awk '{print $2}'`
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "rm -f /tmp/keytab;ipa-getkeytab -s $server1 -p $service1 -k /tmp/keytab"
			ssh root@$FULLHOSTNAME "strings /tmp/keytab | grep $servicehost"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - Search for keytab failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	eval_vars M1
	
	ssh root@$FULLHOSTNAME "ipa-delservice \"$service1\""

	tet_result PASS
	echo "END $tet_thistest"
}



######################################################################
# Cleanup Section for the cli tests
######################################################################
cli_cleanup()
{
	tet_thistest="cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0


	# Setting up for test
	ssh root@$FULLHOSTNAME "ipa-delgroup modusers"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa-delgroup superg"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa-deluser usermod1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa-deluser $superuser"
	let code=$code+$?

	#ssh root@$FULLHOSTNAME "ipa-modgroup -a biguser super"
	#let code=$code+$?

	#ssh root@$FULLHOSTNAME "ipa-modgroup -a usermod1 modusers"
	#let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - setup for $tet_thistest failed"
		tet_result FAIL
	fi

	tet_result PASS
}

######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
