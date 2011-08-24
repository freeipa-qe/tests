#!/bin/bash

ipa help
echo "step 1: ./at.1.prepare.pl permission"
./at.1.prepare.pl permission

echo "step 2: ./at.2.scenario.pl permission permission.syntax permission.data"
./at.2.scenario.pl permission permission.syntax permission.data

echo "step 3: ./at.3.testcase.pl ./permission.scenario"
./at.3.testcase.pl ./permission.scenario 

echo "step 4: we should modify data file d.permission, before we do so, but i can skip it for now"
./at.4.insertdata.pl t.permission.sh d.permission

echo "done, check d.permission and t.permission.sh file"
cat d.permission
cat t.permission.sh 

