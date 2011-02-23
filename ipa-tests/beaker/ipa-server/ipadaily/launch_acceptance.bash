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

# submit beaker jobs
cd $DAILY
ls *.xml | while read x; do
	bkr job-submit $x
done

cd $REPOCLONE
ls *.xml | while read x; do
	bkr job-submit $x
done

