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
tet_cleanup=""
iclist="ic1 "
ic1="tp1 tp2 tp3 tp4 tp5"

######################################################################
tp1()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START tp1"
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
	echo "END tp1"
}
######################################################################
tp2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START tp2"
	# test for ipactl
	ipactl restart
	
	if [ $? -ne 0 ]
	then
		echo "ipactl restart failed"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END tp2"
}

######################################################################
tp3()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START tp3"
	# test for ipa-addservice
	ipa-addservice "host/idmwiki.sjc.redhat.com"
	if [ $? -ne 0 ]
	then
		echo "ipa-addservice failed"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END tp3"

}
######################################################################
tp4()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	# test for ipa-addservice
	ipa-addservice "nfs/idmwiki.sjc.redhat.com"
	if [ $? -ne 0 ]
	then
		echo "ipa-addservice failed"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
tp5()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	# test for ipa-addservice
	ipa-addservice "ldap/idmwiki.sjc.redhat.com"
	if [ $? -ne 0 ]
	then
		echo "ipa-addservice failed"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
