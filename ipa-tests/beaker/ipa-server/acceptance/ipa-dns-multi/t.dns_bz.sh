
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
   bz869658
   bz869324
   bz869325

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
	hname=$(hostname)
	rlRun "ipa dnszone-add --name-server=$hname. --admin-email=$email $zone" 0 "Add test zone: $zone"
	# Determine my IP address
    rlPhaseEnd
}

bz766233()
{
    rlPhaseStartTest "BZ 766233 - Test of zone transfers in IPA."
	tzone="newtransferzone.com"
	if [ "$MYROLE" == "MASTER1" ]; then
        	iparhts-sync-set -s READY_REPLICA1 -m $MASTER_env1
	        rlLog "ready_replica1 set"
        	rlLog "blocking master, waiting for slave"
	        iparhts-sync-block -s BEGIN_REPLICA2 $MASTER_env2
        	rlLog "test start"
		rlRun "dig @$MASTER_env2 $tzone AXFR | grep 'Transfer failed'" 0 "Ensure that the zone transfer fails before continuing"
        	iparhts-sync-set -s STEP1_REPLICA1 -m $MASTER_env1
	        iparhts-sync-block -s STEP1_REPLICA2 $MASTER_env2
	        iparhts-sync-block -s STEP2_REPLICA2 $MASTER_env2
		# Get the short hostname of the second master.
		env2small=$(echo $MASTER_env2 | sed s/'\.'/=/g | cut -d= -f1)
		rlRun "dig @$MASTER_env2 $tzone AXFR | grep NS | grep $env2small" 0 "Making sure that the zone trasfer from the second master succeedes."
        	iparhts-sync-set -s COMPLETE_REPLICA1 -m $MASTER_env1
	else
	        rlLog "blocking for master 1"
        	iparhts-sync-block -s READY_REPLICA1 $MASTER_env1
	        iparhts-sync-set -s BEGIN_REPLICA2 -m $MASTER_env1
	        iparhts-sync-set -s STEP1_REPLICA2 -m $MASTER_env1
		iparhts-sync-block -s STEP1_REPLICA1 $MASTER_env1
		# Change bind to allow transfers
		cat /etc/named.conf > /etc/named.conf-bz766233-backup
		sed -i s/'forward first;'/'allow-transfer {any; };forward first;'/g /etc/named.conf
		rlRun "grep 'allow-transfer {any; };' /etc/named.conf" 0 "ensure that new config of bind happened"
		service named restart
		systemctl restart named.service 
		hname=$(hostname)
		rlRun "ipa dnszone-add $tzone --name-server=$hname. --admin-email=$hname" 0 "adding zone to test with"
		rlRun "ipa dnszone-mod $tzone --allow-transfer=10.0.0.0/8" 0 "enabling zone transfers for the test zone"
		iparhts-sync-set -s STEP2_REPLICA2 -m $MASTER_env1
		iparhts-sync-block -s COMPLETE_REPLICA1 $MASTER_env1
		rlRun "ipa dnszone-del $tzone" 0 "cleaning up test zone."
		rlLog "Restoring Bind config"
		cat /etc/named.conf-bz766233-backup > /etc/named.conf
		service named restart
		systemctl restart named.service 
        	rlLog "test complete"
	fi
    rlPhaseEnd
}

bz869658()
{
    rlPhaseStartTest "BZ 869658 - It is not possible to disable forwarding on per-zone basis."
	tzone="newtransferzone.com"
	if [ "$MYROLE" == "MASTER1" ]; then
        	iparhts-sync-set -s 869658_READY_REPLICA1 -m $MASTER_env1
	        rlLog "ready_replica1 set"
        	rlLog "blocking master, waiting for slave"
	        iparhts-sync-block -s 869658_BEGIN_REPLICA2 $MASTER_env2
        	rlLog "test start"
		ipOfMaster1=$(host -4 $MASTER_env1 |  grep -v IPv6 | cut -d\  -f 4)
		rlRun "ipa dnszone-add sub.$tzone --name-server=$hname. --admin-email=$hname" 0 "adding zone to test with"
		rlRun "ipa dnsrecord-add sub.$tzone client --a-rec $ipOfMaster1" 0 "Adding host record to try resolving to from other master"
        	iparhts-sync-set -s 869658_STEP1_REPLICA1 -m $MASTER_env1
	        iparhts-sync-block -s 869658_STEP1_REPLICA2 $MASTER_env2
        	iparhts-sync-set -s 869658_COMPLETE_REPLICA1 -m $MASTER_env1
	        iparhts-sync-block -s 869658_COMPLETE_REPLICA2 $MASTER_env2
		rlRun "ipa dnszone-del sub.$tzone" 0 "cleaning up test zone."
	else
	        rlLog "blocking for master 1"
        	iparhts-sync-block -s 869658_READY_REPLICA1 $MASTER_env1
	        iparhts-sync-set -s 869658_BEGIN_REPLICA2 -m $MASTER_env1
		hname=$(hostname)
		ipOfMaster1=$(host -4 $MASTER_env1 |  grep -v IPv6 | cut -d\  -f 4)
		rlRun "ipa dnszone-add $tzone --name-server=$hname. --admin-email=$hname" 0 "adding zone to test with"
		rlRun "ipa dnsrecord-add $tzone ns.sub --a-rec=$ipOfMaster1" 0 "adding record to test with"
		rlRun "ipa dnsrecord-add $tzone sub --ns-rec=ns.sub.$tzone." 0 "adding NS zerver to new zone"
		rlRun "ipa dnszone-mod --forwarder=$ipOfMaster1 $tzone" 0 "adding forwarder to test zone"
		iparhts-sync-set -s 869658_STEP1_REPLICA2 -m $MASTER_env1
		iparhts-sync-block -s 869658_STEP1_REPLICA1 $MASTER_env1
		rlRun "dig client.sub.$tzone | grep A | grep $tzone | grep $ipOfMaster1" 0 "Search for client.sub, make sure it returns result from forwarder server"
		rlRun "ipa dnszone-mod --forwarder=  $tzone" 0 "removing forwarder to test zone"
		rlRun "dig client.sub.$tzone | grep A | grep $tzone | grep $ipOfMaster1" 1 "Retry search for client.sub, ensure that this failes because the forwarder for this zone is removed."
		iparhts-sync-block -s 869658_COMPLETE_REPLICA1 $MASTER_env1
		iparhts-sync-set -s 869658_COMPLETE_REPLICA2 -m $MASTER_env1
		rlRun "ipa dnszone-del $tzone" 0 "cleaning up test zone."
        	rlLog "test complete"
	fi
    rlPhaseEnd
}

bz869324()
{
	rlPhaseStartTest "BZ 869324 - Cache is not flushed after creating a new zone with conditional forwarder"

	export MASTER_env1_short=$(host -4 $MASTER_env1 |  grep -v IPv6 | cut -d\  -f 1 | cut -d\. -f1)
	export MASTER_env2_short=$(host -4 $MASTER_env2 |  grep -v IPv6 | cut -d\  -f 1 | cut -d\. -f1)
	hname=$(hostname)	
	export hname
	ipOfMaster1=$(host -4 $MASTER_env1 |  grep -v IPv6 | cut -d\  -f 4)
	ipOfMaster2=$(host -4 $MASTER_env2 |  grep -v IPv6 | cut -d\  -f 4)

	tzone="newtransferzoneb.com"
	if [ "$MYROLE" == "MASTER1" ]; then
        	iparhts-sync-set -s 869324_READY_REPLICA1 -m $MASTER_env1
	        rlLog "ready_replica1 set"
        	rlLog "blocking master, waiting for slave"
	        iparhts-sync-block -s 869324_BEGIN_REPLICA2 $MASTER_env2
        	rlLog "test start"
		rlRun "dig @127.0.0.1 $MASTER_env2_short.$tzone | grep $ipOfMaster2" 1 "Make sure that the entry does not already exist"
		rlRun "ipa dnszone-add $tzone --name-server=$hname. --admin-email=$hname --forward-policy=only --force --forwarder=$ipOfMaster2" 0 "adding forwarding zone to test with"
	        iparhts-sync-block -s 869324_STEP1 $MASTER_env2
		rlRun "dig @127.0.0.1 $MASTER_env2_short.$tzone | grep $ipOfMaster2" 0 "Make sure that the entry has been pulled from the forwarded cache."
        	iparhts-sync-set -s 869324_COMPLETE_REPLICA1 -m $MASTER_env1
		rlRun "ipa dnszone-del $tzone" 0 "cleaning up test zone."
        	rlLog "test complete"
	else
	        rlLog "blocking for master 1"
        	iparhts-sync-block -s 869324_READY_REPLICA1 $MASTER_env1
	        iparhts-sync-set -s 869324_BEGIN_REPLICA2 -m $MASTER_env1
		rlRun "ipa dnszone-add $tzone --name-server=$hname. --admin-email=$hname" 0 "adding zone to test with"
		rlRun "ipa dnsrecord-add $tzone $MASTER_env2_short --a-rec=$ipOfMaster2" 0 "adding A record into zone to test with"
		rlRun "dig @127.0.0.1 $MASTER_env2_short.$tzone | grep $ipOfMaster2" 0 "Make sure that the entry was created properly"
	        iparhts-sync-set -s 869324_STEP1 -m $MASTER_env1
		iparhts-sync-block -s 869324_COMPLETE_REPLICA1 $MASTER_env1
		rlRun "ipa dnszone-del $tzone" 0 "cleaning up test zone."
        	rlLog "test complete"
	fi
	rlPhaseEnd
}

bz869325()
{
	tzone="bz669325zone.com"
	rlPhaseStartTest "BZ 869325 - Zones with conditional forwarder are not removed properly when persistent search is enabled"
		export MASTER_env1_short=$(host -4 $MASTER_env1 |  grep -v IPv6 | cut -d\  -f 1 | cut -d\. -f1)
		export MASTER_env2_short=$(host -4 $MASTER_env2 |  grep -v IPv6 | cut -d\  -f 1 | cut -d\. -f1)
		hname=$(hostname)	
		export hname
		ipOfMaster1=$(host -4 $MASTER_env1 |  grep -v IPv6 | cut -d\  -f 4)
		ipOfMaster2=$(host -4 $MASTER_env2 |  grep -v IPv6 | cut -d\  -f 4)

		if [ "$MYROLE" == "MASTER1" ]; then
			rlRun "dig @127.0.0.1 -t ANY $tzone | grep ANSWER\ SECTION" 1 "Before we begin, ensure that $tzone does not exist on master1 in any way"
			rlRun "ipa dnszone-add $tzone --name-server=$hname. --admin-email='$hname' --force --forwarder=$ipOfMaster2 --forward-policy=only" 0 "Adding $tzone on master 1 with forward policy set to only"
			rlRun "dig @127.0.0.1 test.$tzone | grep ANSWER\ SECTION" 1 "Ensure that we cannot resolve the test record from the second master"
			iparhts-sync-set -s 869325_MASTER1_SETUP_COMPLETE -m $MASTER_env2		
	        	iparhts-sync-block -s 869325_MASTER2_SETUP_COMPLETE $MASTER_env2
			# Now the records and zones should exist
			rlRun "dig @127.0.0.1 -t ANY $tzone | grep ANSWER\ SECTION" 0 "Make sure the zone is created and returning answers"
			rlRun "dig @127.0.0.1 test.$tzone | grep ANSWER\ SECTION | grep 4.2.2.2" 0 "Ensure that test.$tzone is set up correctly and pulling from master 2."
			# The initial phase seting up forwarding is complete. Delete the zone and make sure it now does not work after.
			rlRun "ipa dnszone-del $tzone" 0 "Deleting the test zone"
			rlRun "dig @127.0.0.1 -t ANY $tzone | grep ANSWER\ SECTION" 1 "Make sure the zone does not return any answers after removing forwarding zone"
			rlRun "dig @127.0.0.1 test.$tzone | grep ANSWER\ SECTION" 1 "Ensure that test.$tzone does not resolve anywhere"
			iparhts-sync-set -s 869325_MASTER1_TEST_COMPLETE -m $MASTER_env2		
	        	iparhts-sync-block -s 869325_MASTER2_TEST_COMPLETE $MASTER_env2
		else
	        	iparhts-sync-block -s 869325_MASTER1_SETUP_COMPLETE $MASTER_env1
			rlRun "dig @127.0.0.1 -t ANY $tzone | grep ANSWER\ SECTION" 1 "Before we begin, ensure that $tzone does not exist on master2 in any way"
			rlRun "ipa dnszone-add $tzone --name-server=$hname. --admin-email='$hname' --force" 0 "Adding $tzone on master 2"
			rlRun "ipa dnsrecord-add $tzone test --a-rec=4.2.2.2" 0 "Add record to test resolving to on first master"
			iparhts-sync-set -s 869325_MASTER2_SETUP_COMPLETE -m $MASTER_env1
	        	iparhts-sync-block -s 869325_MASTER1_TEST_COMPLETE $MASTER_env1
			# Tests should be completed, waiting on Master 1.
			rlRun "ipa dnszone-del $tzone" 0 "Deleting the test zone"
			iparhts-sync-set -s 869325_MASTER2_TEST_COMPLETE -m $MASTER_env1
		fi
	rlPhaseEnd
}

dnsbugcleanup()
{
       rlPhaseStartTest "dns bug cleanup"
               rlRun "ipa dnszone-del $zone" 0 "Delete test zone: $zone"
       rlPhaseEnd
}

