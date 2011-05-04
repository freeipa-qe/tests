. ./t.tests.common.sh

# Main test case
run_slave_tests()
{
	rlPass "this is the slave server managed replica test suite"
	rlRun check_list 0 "checking to ensure that all machines are viewable by replica manage" 

	# Disconnect from a slave server
	server=$MASTER # This should be the servername in the servername.relm format
	me=$(hostname)
	echo "Server I am going to disconnect is: $server"

	rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from $server" 0 "reinitilizing server $server."

	rlRun "ipa-replica-manage -p $ADMINPW disconnect $server $me" 0 "disconnecting server $server from the replication list"

	rlRun "ipa-replica-manage -p $ADMINPW list | grep $server" 1 "Server $server should not be in the list"

	rlRun "ipa-replica-manage -p $ADMINPW connect $server $me" 0 "connecting to server $server again"

	rlRun "ipa-replica-manage -p $ADMINPW list | grep $server" 0 "Server $server should be in the list"

	rlRun "ipa-replica-manage -p $ADMINPW del $server" 0 "connecting to server $server again"

	rlRun "ipa-replica-manage -p $ADMINPW list | grep $server" 1 "Server $server should not be in the list"

	rlRun "ipa-replica-manage -p $ADMINPW connect $server $me" 0 "connecting to server $server again"

	rlRun "ipa-replica-manage -p $ADMINPW list | grep $server" 0 "Server $server should be in the list"

}

