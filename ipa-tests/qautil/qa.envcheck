#!/bin/sh

# this utility designed to meet the following purpose
# verify the OS type
# verify whether IPA has been installed. If it does, what version has been installed"

echo "---- IPA qa environment report ----"
# should add one more for x86_64
echo "[repo check]"
if [ -f /etc/yum.repos.d/ipa1.1-i386.repo ]
then
	echo "yum repo points to ipa 1.1 daily build"
else
	echo "yum repo doesn't contain IPA info"
fi

echo "[OS]"
uname -a
if [ -a /etc/redhat-release ]
then
	cat < /etc/redhat-release
fi

echo "[rhn registeration]"
echo "[ipa installation]"
rpm -qi ipa-server
rpm -qi ipa-client
rpm -qi ipa-admintools
rpm -qi redhat-ds-base
echo "------------------------------"
