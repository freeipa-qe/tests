#!/bin/ksh

######################################################################

# The following ipa cli commands needs to be tested:
#  service-add               Add a new service.
#  service-del               Delete an existing service.
#  service-find              Search the existing services.
#  service-show              Examine an existing service.

######################################################################
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="cli_cleanup"
iclist="kinit ipaserviceprepare ipaserviceadd ipaserviceaddb ipaserviceaddc negaddservice negaddserviceb negaddservicec ipaservicedel ipaservicedelb ipaservicedelc ipanegservicedel ipaservicecleanup"
# These services will be used by the tests, and removed when the cli test is complete
host1='alpha.dsdev.sjc.redhat.com'
service1="ssh/$host1"
service2="nfs/$host1"
service3="ldap/$host1"

# Users to be used in varios tests
superuser="sup34"

######################################################################
kinit()
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
				echo "ERROR - ipa service-find failed on $FULLHOSTNAME"
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
	ssh root@$FULLHOSTNAME "ipa group-del modusers"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-del superg"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa user-del usermod1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa user-del $superuser"
	let code=$code+$?

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
