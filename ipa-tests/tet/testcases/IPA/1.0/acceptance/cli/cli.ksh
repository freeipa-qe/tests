#!/bin/ksh

######################################################################

#The following ipa cli commands needs to be tested:

#ipa-adddelegation       ipa-findgroup           ipa-passwd
#ipa-addgroup            ipa-findservice         ipa-pwpolicy
#ipa-addservice          ipa-finduser            ipa-replica-install
#ipa-adduser             ipa-getkeytab           ipa-replica-manage
#ipa-client-install      ipa_kpasswd             ipa-replica-prepare
#ipactl                  ipa-listdelegation      ipa-server-certinstall
#ipa-deldelegation       ipa-lockuser            ipa-server-install
#ipa-delgroup            ipa-moddelegation       ipa-upgradeconfig
#ipa-delservice          ipa-modgroup            ipa_webgui
#ipa-deluser             ipa-moduser             
######################################################################
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="cli_cleanup"
iclist="ic1 "
ic1="tp1 tp2 tp3 tp4 tp5 tp6 tp7 tp8 tp9 tp10 tp11 tp12 tp13 tp14 tp15 tp16 tp17 tp18 tp19 tp20"

# These services will be used by the tests, and removed when the cli test is complete
service1='host/emc-cge0.sjc2.redhat.com'
service2='nfs/emc-cge0.sjc2.redhat.com'
service3='ldap/emc-cge0.sjc2.redhat.com'

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

######################################################################
tp3()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-addservice \"$service1\""
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - ipa-addservice failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa-findservice \"$service1\""
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
tp4()
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
tp5()
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
			ssh root@$FULLHOSTNAME "ipa-findservice \"$service3\""
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
# Negitive test case of tp3
################################################################
tp6()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "M1" ]&&[ "$s" != "" ]; then
			eval_vars $s

			echo "this step is supposed to fail"
			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-addservice \"$service1\""
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
# Negitive test case of tp4
################################################################
tp7()
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
tp8()
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
######################################################################
#

tp9()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-delservice \"$service1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa-delservice failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			echo "this step is supposed to fail"
			ssh root@$FULLHOSTNAME "ipa-findservice \"$service1\""
			if [ $? -eq 0 ]
			then
				echo "ERROR - ipa-findservice passed when it shouldn't have on $FULLHOSTNAME"
				tet_result FAIL
			fi

		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

tp10()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-delservice \"$service2\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa-delservice failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			echo "this step is supposed to fail"
			ssh root@$FULLHOSTNAME "ipa-findservice \"$service2\""
			if [ $? -eq 0 ]
			then
				echo "ERROR - ipa-findservice passed when it shouldn't have on $FULLHOSTNAME"
				tet_result FAIL
			fi

		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

tp11()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-delservice \"$service3\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa-delservice failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			echo "this step is supposed to fail"
			ssh root@$FULLHOSTNAME "ipa-findservice \"$service3\""
			if [ $? -eq 0 ]
			then
				echo "ERROR - ipa-findservice passed when it shouldn't have on $FULLHOSTNAME"
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
tp12()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa-adduser -ffirstname-super -llastbname-super $superuser"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa-finduser $superuser | grep Login | grep $superuser"
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
# ipa-adddelegation
######################################################################
tp13()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	# Setting up for test
	ssh root@$FULLHOSTNAME "ipa-adduser -ffirstname-mod1 -llastbname-mod1 usermod1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa-addgroup -d super-user superg"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa-addgroup -d group-to-mod-users modusers"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa-modgroup -a $superuser superg"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa-modgroup -a usermod1 modusers"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - setup for $tet_thistest failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa-adddelegation --attributes telephonenumber -s superg -t modusers namef"
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
			ssh root@$FULLHOSTNAME "ipa-listdelegation namef"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - ipa-listdelegation failed on $FULLHOSTNAME"
				tet_result FAIL
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

			ssh root@$FULLHOSTNAME "ipa-listdelegation findf | grep uid | grep 9933"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - ipa-listdelegation failed on $FULLHOSTNAME"
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
			ssh root@$FULLHOSTNAME "ipa-listdelegation namef"
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
