#!/bin/sh

A=`ls old`
for FILE in $A
do
	echo $FILE
	sed 's/seluser/usr/' ./old/$FILE > ./tmp/$FILE.new.1
	sed 's/selgrp/grp/'  ./tmp/$FILE.new.1 > ./tmp/$FILE.new.2
	sed 's/sel_user_/usr_/'  ./tmp/$FILE.new.2 > ./tmp/$FILE.new.3
	sed 's/sel_grp_/grp_/'  ./tmp/$FILE.new.3 > ./tmp/$FILE.new.4
	sed 's/"\/ipa/"\/ipa\/ui/'  ./tmp/$FILE.new.4 > ./tmp/$FILE.new.5
	cp -v ./tmp/$FILE.new.5 ./new/$FILE
done


#$testuid="seluser_".$testid;
#$testgid="selgrp_".$testid;
#$testfulluid="uid=sel_user_".$testid.",".$base;
#$testfullgid="cn=sel_grp_".$testid.",cn=groups,cn=accounts,".$base;
#$sel->open_ok("/ipa/user/show?uid=$testuid");



