#!/bin/bash
# This script was written to test ticket:
# https://engineering.redhat.com/trac/ipa-tests/ticket/278, aka:
# https://bugzilla.redhat.com/show_bug.cgi?id=783606
# Run the master-setup.bash script on the master, then run the ron-on-slave.bash script on the replica 
. /opt/rhqa_ipa/env.sh
. /opt/rhqa_ipa/ipa-server-shared.sh

hostnames=$(hostname -s)
REPLICAFILE="/opt/rhqa_ipa/replica-info-$hostnames.$DOMAIN.gpg"
NEWPORT=29719
maxusers=100

if [ ! -f /opt/rhqa_ipa/env.sh ]; then
        echo 'ERROR - Sorry, this script needs to be run on a IPA provisioned slave from beaker'
        exit
fi

hostnames=$(hostname -s)
echo "Hostname is: " 
echo $BEAKERSLAVE | grep $hostnames
if [ $? -ne 0 ]; then
        echo "ERROR - this script needs to be run on the beaker slave, sorry."
        exit
fi

x=1
result=0
while [ $x -lt $maxusers ]; do
	ipa user-find --login=guest$x &> /dev/null
	if [ $? -eq 0 ]; then
		echo "user guest$x replicated correctly"
	else
		echo "ERROR - user guest$x was not found"
		result=1;
	fi
	let x=$x+1
done

if [ $result -eq 1 ]; then
	echo "ERROR - not all of the users were found in the slave"
	exit 1
else
	echo "Test Passed"
	exit 0
fi
