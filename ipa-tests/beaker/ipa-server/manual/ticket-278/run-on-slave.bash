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
maxusers=1000

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

if [ ! -f $REPLICAFILE ]; then
        echo "ERROR - file $REPLICAFILE does not exist, unable to continue"
        exit
fi

echo "uninstalling ipa server replica."
/usr/sbin/ipa-server-install --uninstall -U
if [ $? -ne 0 ]; then echo "ERROR - Unable to uninstall server.";exit; fi

echo "re-installing ipa server replica for testing"
ipa-replica-install --password=$ROOTDNPWD -w $ADMINPW $REPLICAFILE
if [ $? -ne 0 ]; then echo "ERROR - Replication setup did not complete.";exit; fi


