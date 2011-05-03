. ./t.tests.common.sh

# Main test case
run_master_tests()
{
	rlPass "this is the master server managed replica test suite"
	rlRun check_list 0 "checking to ensure that all machines are viewable by replica manage" 

	# Disconnect from a slave server
	serverfull=$(echo $SLAVE | cut -d\  -f1)
	serveralone=$(echo $serverfull | cut -d\  -f1)
	serversimple=$(echo $serveralone | cut -d\. -f1)
	server=$($serversimple.$DOMAIN) # This should be the servername in the servername.relm format
	echo "Server I am going to disconnect is: $server"

	echo "running ipa-replica-manage -p $ADMINPW re-initialize --from=$server"
	rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$server" 0 "reinitilizing server $server."

#	rlRun "ipa-replica-manage -p $ADMINPW disconnect $server" 0 "disconnecting server $server from the replication list"

#	rlRun "ipa-replica-manage -p $ADMINPW list | grep $server" 1 "Server $server should not be in the list"

#	rlRun "ipa-replica-manage -p $ADMINPW connect $server" 0 "connecting to server $server again"

#	rlRun "ipa-replica-manage -p $ADMINPW list | grep $server" 0 "Server $server should be in the list"

#	rlRun "ipa-replica-manage -p $ADMINPW del $server" 0 "connecting to server $server again"

#	rlRun "ipa-replica-manage -p $ADMINPW list | grep $server" 1 "Server $server should not be in the list"

#	rlRun "ipa-replica-manage -p $ADMINPW connect $server" 0 "connecting to server $server again"

#	rlRun "ipa-replica-manage -p $ADMINPW list | grep $server" 0 "Server $server should be in the list"

}

