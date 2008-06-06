#!/bin/ksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="instclean"
iclist="ic1 ic2 ic3"
ic1="tp1"
ic2="tp2"
ic3="tp6"

######################################################################
tp1()
{
	echo "START tp1"
	echo "kiniting as admin on all hosts"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "kiniting as $DS_USER on $s now"
			KinitAs $s $DS_USER $DM_ADMIN_PASS 
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "kinit as $DS_USER on $s, using $DM_ADMIN_PASS failed"
				tet_result FAIL
			fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "kiniting as $DS_USER on $s now"
			KinitAs $s $DS_USER $DM_ADMIN_PASS 
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "kinit as $DS_USER on $s, using $DM_ADMIN_PASS failed"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
}
######################################################################
tp2()
{
	echo "START tp2"

	echo "creating 10 users on M1"
	eval_vars M1
	usernum=1
	while [[ $usernum -lt 11 ]] ; do
		echo "creating user usr$usernum on $FULLHOSTNAME"
		ssh root@$FULLHOSTNAME "ipa-adduser -p $DM_ADMIN_PASS -f userfirstname$usernum -l userlastname$usernum usr$usernum"
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "creation of usr$usernum on M1 failed ssh failed"
			tet_result FAIL
		fi
	let usernum+=1
	done

	tet_result PASS

}

tp3()
{
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			SetupRepo $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Install of server RPM on $s ssh failed"
				tet_result FAIL
			fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			SetupRepo $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Install of server RPM on $s ssh failed"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
}

tp6()
{
	echo "START tp6"

	echo "deleting 10 users on M1"
	eval_vars M1
	usernum=1
	while [[ $usernum -lt 11 ]] ; do
		echo "deleting user usr$usernum on $FULLHOSTNAME"
		ssh root@$FULLHOSTNAME "/usr/sbin/ipa-deluser usr$usernum"
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "deletion of usr$usernum on M1 failed ssh failed"
			tet_result FAIL
		fi
	let usernum+=1
	done

	tet_result PASS

}

instclean()
{
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "It is okay if this kdestroy fails"
			ssh root@$FULLHOSTNAME 'kdestroy'
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "It is okay if this kdestroy fails"
			ssh root@$FULLHOSTNAME 'kdestroy'
		fi
	done

	tet_result PASS

}

######################################################################

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
