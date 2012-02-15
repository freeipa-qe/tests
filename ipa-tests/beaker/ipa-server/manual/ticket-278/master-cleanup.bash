#!/bin/bash
# This script was written to test ticket:
# https://engineering.redhat.com/trac/ipa-tests/ticket/278, aka:
# https://bugzilla.redhat.com/show_bug.cgi?id=783606
# Run the master-setup.bash script on the master, then run the run-on-slave.bash script on the replica 
# Run the master-cleanup.bash script to clean up the enviroment after complete
. /dev/shm/env.sh
. /dev/shm/ipa-server-shared.sh

NEWPORT=29719
# number of users to add to server for replication
maxusers=100
hostnames=$(hostname -s)

remove-ds.pl -f -i slapd-$hostnames


ipa group-del group0
ipa group-del group1

thisuser=1;
while [ $thisuser -lt $maxusers ]; do 
	ipa user-del $thisuser;
done
