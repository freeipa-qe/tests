######################
ipaconfig_bz()
{
   setup
   bugzillas
} 

######################
# test set           #
######################

bugzillas()
{
   ipaconfig_bugzillas
}

######################
# test cases         #
######################

setup()
{
   rlPhaseStartTest "kinit as Admin"
	rlRun "kinitAs $ADMINID $ADMINPW"
   rlPhaseEnd
}

ipaconfig_bugzillas()
{
	# Testcase covering https://fedorahosted.org/freeipa/ticket/2159 - bugzilla 782974
	rlPhaseStartTest "bz782974 Trace back with empty groupsearch config-mod"
		ipa config-mod --groupsearch= &> /dev/shm/2159out.txt
		rlRun "grep Traceback  /dev/shm/2159out.txt" 1 "Making sure that running a empty groupsearch did not return a exception"
	rlPhaseEnd
}

