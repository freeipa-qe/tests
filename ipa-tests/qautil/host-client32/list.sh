#!/bin/sh

for f in `cat ipa-files.list`
do
	if [ ! -d $f ];then
		ls -l $f
	fi
done
