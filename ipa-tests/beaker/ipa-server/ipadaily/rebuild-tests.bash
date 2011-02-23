#!/bin/bash

# remove existing automation scripts
HOME=$PWD
rm -rf $PWD/beaker

SHAREDLIB=$PWD/beaker/ipa-server/shared
TESTROOT=$PWD/beaker/ipa-server/acceptance
REPOCLONE=$PWD/beaker/ipa-server/repoclone
DAILY=$PWD/beaker/ipa-server/ipadaily
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

testsuites="install         ipa-cert    ipa-default     ipa-functional-services  ipa-hbac-cli     ipa-hostgroup-cli  ipa-password install-client  ipa-config  ipa-delegation  ipa-get-rm-keytab        ipa-hbacsvc-cli  ipa-krbtpolicy     ipa-services      nis-cli install-slave   ipa-ctl     ipa-dns         ipa-group-cli            ipa-host-cli     ipa-netgroup-cli   ipa-set-add-attr  uninstall ipa-user-cli/adduser ipa-user-cli/moduser"
for item in $testsuites ; do
	cd $TESTROOT/$item/
	rm -rf *.rpm
	make rpm
	bkr task-add *.rpm
done

