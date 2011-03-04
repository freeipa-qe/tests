. ./t.tests.common.sh

# Main test case
run_master_tests()
{
	rlPass "this is the master server managed replica test suite"
	rlRun check_list 0 "checking to ensure that all machines are viewable by replica manage" 

	# Disconnect from a slave server
	serverfull=$(echo $SLAVE | cut -d\  -f1)	
	serversimple=$(echo $serverfull | cut -d\  -f1)
	server=$(echo serversimple | cut -d\. -f1)
	echo "Server I am going to disconnect is: $server"
	
}
