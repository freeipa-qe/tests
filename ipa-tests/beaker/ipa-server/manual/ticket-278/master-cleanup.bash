#!/bin/bash
# This script was written to test ticket:
# https://engineering.redhat.com/trac/ipa-tests/ticket/278, aka:
# https://bugzilla.redhat.com/show_bug.cgi?id=783606
# Run the master-setup.bash script on the master, then run the run-on-slave.bash script on the replica 
# Run the master-cleanup.bash script to clean up the enviroment after complete
. /opt/rhqa_ipa/env.sh
. /opt/rhqa_ipa/ipa-server-shared.sh

NEWPORT=29719
# number of users to add to server for replication
maxusers=100
hostnames=$(hostname -s)

echo "kinit as admin"
KinitAsAdmin

echo "Removing slapd-$hostnames. This may take some time"
remove-ds.pl -f -i slapd-$hostnames

ipa group-del group0
ipa group-del group1

thisuser=1;
while [ $thisuser -lt $maxusers ]; do 
	echo "Removing user guest$thisuser"
	ipa user-del guest$thisuser;
	let thisuser=$thisuser+1;
done
