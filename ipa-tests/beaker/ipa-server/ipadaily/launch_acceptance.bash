#!/bin/bash

# remove existing automation scripts
HOME=$PWD
rm -rf $PWD/beaker

SHAREDLIB=$PWD/beaker/ipa-server/shared
TESTROOT=$PWD/beaker/ipa-server/acceptance
REPOCLONE=$PWD/beaker/ipa-server/repoclone
DAILY=$PWD/beaker/ipa-server/daily
# check out the lastest
svn co https://svn.devel.redhat.com/repos/ipa-tests/trunk/ipa-tests/beaker

# make test rpms and add new tasks for the test suites
cd $SHAREDLIB
rm -rf *.rpm
make rpm
bkr task-add *.rpm

cd $REPOCLONE
rm -rf *.rpm
make rpm
bkr task-add *.rpm

testsuites="ipa-user-cli ipa-group-cli ipa-host-cli ipa-hostgroup-cli ipa-netgroups-cli install ipa-default ipa-password ipa-hbac-cli install-slave install-client uninstall"
for item in $testsuites ; do
	cd $TESTROOT/$item/
	rm -rf *.rpm
	make rpm
	bkr task-add *.rpm
done

# submit beaker jobs
cd $DAILY
bkr job-submit acceptance.xml

cd $REPOCLONE
ls *.xml | while read x; do
	bkr job-submit $x
done

