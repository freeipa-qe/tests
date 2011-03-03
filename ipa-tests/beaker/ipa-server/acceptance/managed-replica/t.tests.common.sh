# Tests to ensure that all of the servers are avaliable 
check_list()
{
	hostsimple=$(echo $MASTER | cut -d\. -f1)	
	rlRun "ipa-replica-manage --password=Secret123 list | grep $hostsimple" 0 "Looking for MASTER server $hostsimple in replica manage host list"
	for slave in $SLAVE
	do
		hostsimple=$(echo $slave | cut -d\. -f1)	
		rlRun "ipa-replica-manage --password=Secret123 list | grep $hostsimple" 0 "Looking for SLAVE server $hostsimple in replica manage host list"
	done
	
}

