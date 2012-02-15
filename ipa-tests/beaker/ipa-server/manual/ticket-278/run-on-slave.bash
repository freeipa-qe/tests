#!/bin/bash
# This script was written to test ticket:
# https://engineering.redhat.com/trac/ipa-tests/ticket/278, aka:
# https://bugzilla.redhat.com/show_bug.cgi?id=783606
# Run the master-setup.bash script on the master, then run the ron-on-slave.bash script on the replica 
. /dev/shm/env.sh
. /dev/shm/ipa-server-shared.sh

INFFILE=/dev/shm/ticket-278.inf
LDIFIN=./10.entries.example.dc.com.ldif
LDIFOUT=/dev/shm/import-278.ldif
NEWPORT=29719

if [ ! -f /dev/shm/env.sh ]; then
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

