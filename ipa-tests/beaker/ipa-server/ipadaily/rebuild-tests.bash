#!/bin/bash

scriptname="rebuild-tests.bash"

logger -t $scriptname "starting"

# remove existing automation scripts
#HOME=$PWD
rm -rf $PWD/beaker

SHAREDLIB=$PWD/beaker/ipa-server/shared
TESTROOT=$PWD/beaker/ipa-server/acceptance
REPOCLONE=$PWD/beaker/ipa-server/repoclone
DAILY=$PWD/beaker/ipa-server/ipadaily
# check out the lastest
svn co https://svn.devel.redhat.com/repos/ipa-tests/trunk/ipa-tests/beaker

# Make sure that this script is the updated script.
diff $DAILY/$scriptname /root/$scriptname
if [ $? -eq 0 ]; then
	# The current script is the same as the one in svn
	# make test rpms and add new tasks for the test suites
	cd $SHAREDLIB
	rm -rf *.rpm
	make rpm
	bkr task-add *.rpm

	cd $REPOCLONE
	rm -rf *.rpm
	make rpm
	bkr task-add *.rpm

	testsuites="install         ipa-cert    ipa-default     ipa-functional-services  ipa-hbac-cli     ipa-hostgroup-cli  ipa-password install-client  ipa-config  ipa-delegation  ipa-get-rm-keytab        ipa-hbacsvc-cli  ipa-krbtpolicy     ipa-services      nis-cli install-slave   ipa-ctl     ipa-dns         ipa-group-cli            ipa-host-cli     ipa-netgroup-cli   ipa-set-add-attr  uninstall ipa-user-cli/adduser ipa-user-cli/moduser ipa-i18n replication"
	for item in $testsuites ; do
		cd $TESTROOT/$item/
		rm -rf *.rpm
		make rpm
		bkr task-add *.rpm
	done
else
	logger -t $scriptname "/root/ differs from subversion, syncing up."
	cat $DAILY/$scriptname > /root/$scriptname
	chmod 755 /root/$scriptname
	bash /root/$scriptname
fi

logger -t $scriptname "done"
