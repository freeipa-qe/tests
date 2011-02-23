#!/bin/bash

scriptname="launch_acceptance.bash"

logger -t $scriptname "starting"

# remove existing automation scripts
HOME=$PWD
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
	# submit beaker jobs
	cd $DAILY
	ls *.xml | while read x; do
		logger -t $scriptname "running bkr job-submit $x"
		bkr job-submit $x
	done

	cd $REPOCLONE
	ls *.xml | while read x; do
		logger -t $scriptname "running bkr job-submit $x"
		bkr job-submit $x
	done
else
	logger -t $scriptname "/root/ differs from subversion, syncing up."
	cat $DAILY/$scriptname > /root/$scriptname
	chmod 755 /root/$scriptname
	bash /root/$scriptname
fi

logger -t $scriptname "done"
