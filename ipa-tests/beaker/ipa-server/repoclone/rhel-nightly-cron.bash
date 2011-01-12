#!/bin/bash
# Run this cron job nightly as root. 
cd
if [ ! -d ./ipa-server ]; then 
	svn co https://svn.devel.redhat.com/repos/ipa-tests/trunk/ipa-tests/beaker/ipa-server
else
	cd ipa-server
	svn update
fi
yum -y install yum-utils rhts-test-env beaker-redhat beakerlib-redhat beaker beah portreserve
iptables -F
setenforce 0
cd repoclone;make
