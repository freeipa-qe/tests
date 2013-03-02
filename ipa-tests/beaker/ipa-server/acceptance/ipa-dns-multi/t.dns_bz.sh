
#########################################
# Variables
#########################################
zone=newzone
email="ipaqar.redhat.com"

##########################################
#   Test Suite 
#########################################

dnsbugs()
{
   dnsbugsetup
   bz766233

   dnsbugcleanup
}

###############################################################
# Tests
###############################################################

dnsbugsetup()
{
    rlPhaseStartTest "dns bug setup"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	# add test zone
	rlRun "ipa dnszone-add --name-server=$MASTER. --admin-email=$email $zone" 0 "Add test zone: $zone"
	# Determine my IP address
    rlPhaseEnd
}

bz766233()
{
	tzone="newtransferzone.com"
	if [ "$MYROLE" == "MASTER1" ]; then
        	rhts-sync-set -s READY_REPLICA1 -m $MASTER_env1
	        rlLog "ready_replica1 set"
        	rlLog "blocking master, waiting for slave"
	        rhts-sync-block -s BEGIN_REPLICA2 $MASTER_env2
        	rlLog "test start"
		rlRun "dig @$MASTER_env2 $tzone AXFR | grep 'Transfer failed'" 0 "Ensure that the zone transfer fails before continuing"
        	rhts-sync-set -s STEP1_REPLICA1 -m $MASTER_env1
	        rhts-sync-block -s STEP1_REPLICA2 $MASTER_env2
	        rhts-sync-block -s STEP2_REPLICA2 $MASTER_env2
		# Get the short hostname of the second master.
		env2small=$(echo $MASTER_env2 | sed s/'\.'/=/g | cut -d= -f1)
		rlRun "dig @$MASTER_env2 $tzone AXFR | grep NS | grep $env2small" 0 "Making sure that the zone trasfer from the second master succeedes."
        	rhts-sync-set -s COMPLETE_REPLICA1 -m $MASTER_env1
	else
	        rlLog "blocking for master 1"
        	rhts-sync-block -s READY_REPLICA1 $MASTER_env1
	        rhts-sync-set -s BEGIN_REPLICA2 -m $MASTER_env1
	        rhts-sync-set -s STEP1_REPLICA2 -m $MASTER_env1
		rhts-sync-block -s STEP1_REPLICA1 $MASTER_env1
		# Change bind to allow transfers
		sed -i s/'forward first;'/'allow-transfer {any; };forward first;'/g /etc/named.conf
		rlRun "grep 'allow-transfer {any; };' /etc/named.conf" 0 "ensure that new config of bind happened"
		service named restart
		systemctl restart named.service 
		hname=$(hostname)
		rlRun "ipa dnszone-add $tzone --name-server=$hname. --admin-email=$hname" 0 "adding zone to test with"
		rlRun "ipa dnszone-mod $tzone --allow-transfer=10.0.0.0/8" 0 "enabling zone transfers for the test zone"
		rhts-sync-set -s STEP2_REPLICA2 -m $MASTER_env1
		rhts-sync-block -s COMPLETE_REPLICA1 $MASTER_env1
		rlRun "ipa dnszone-del $tzone" 0 "cleaning up test zone."
        	rlLog "test complete"
	fi
}

dnsbugcleanup()
{
       rlPhaseStartTest "dns bug cleanup"
               rlRun "ipa dnszone-del $zone" 0 "Delete test zone: $zone"
       rlPhaseEnd
}

