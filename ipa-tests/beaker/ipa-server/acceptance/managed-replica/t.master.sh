. ./t.tests.common.sh

# Main test case
run_master_tests()
{
	rlPhaseStartTest "run_master_tests"
		rlRun "KinitAsAdmin"
		rlPass "this is the master server managed replica test suite"
		rlRun check_list 0 "checking to ensure that all machines are viewable by replica manage" 

		serverfull=$(echo $SLAVE | cut -d\  -f1)
		serveralone=$(echo $serverfull | cut -d\  -f1)
		serversimple=$(echo $serveralone | cut -d\. -f1)
		server=$(echo $serversimple.$DOMAIN) # This should be the servername in the servername.relm format
		server2=$(echo $SLAVE|awk '{print $2}'|cut -f1 -d.|sed s/$/.$DOMAIN/)

		# Connect a new link between two replicas
		rlLog "Make replication connection between $server and $server2"
		rlRun "ipa-replica-manage -p $ADMINPW connect $server $server2"

		# List all links and combinations
		rlRun "ipa-replica-manage list"
		rlRun "ipa-replica-manage -p $ADMINPW list"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|egrep \"$server|$server2\""
		rlRun "ipa-replica-manage -p $ADMINPW list $server|grep $server2"
		rlRun "ipa-replica-manage -p $ADMINPW list $server2|grep $server"

		# re-initialize from replica
		rlLog "running: ipa-replica-manage -p $ADMINPW re-initialize --from=$server"
		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$server" 0 "reinitilizing server $server."

		# Disconnect one link
		rlLog "running: ipa-replica-manage -p $ADMINPW disconnect $server $MASTER"
		rlRun "ipa-replica-manage -p $ADMINPW disconnect $server $MASTER" 0 "disconnecting server $server from the replication list"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep $server" 1 "Server $server should not be in the list"

		# Delete last link
		rlLog "running: ipa-replica-manage -p $ADMINPW del $server2"
		rlRun "ipa-replica-manage -p $ADMINPW del $server2" 0 "connecting to server $server again"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep $server2" 1 "Server $server2 should not be in the list"

		rlLog "running: ipa-replica-manage -p $ADMINPW list | grep $server"
		rlRun "ipa-replica-manage -p $ADMINPW list | grep $server" 0 "Server $server should be in the list"

	rlPhaseEnd
}

