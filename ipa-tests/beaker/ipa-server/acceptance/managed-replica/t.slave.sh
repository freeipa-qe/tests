. ./t.tests.common.sh

# Main test case
run_slave_tests()
{
	rlPass "this is the slave server managed replica test suite"
	rlRun check_list 0 "checking to ensure that all machines are viewable by replica manage" 
}
