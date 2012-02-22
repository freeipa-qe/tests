#!/bin/bash
# test for https://engineering.redhat.com/trac/ipa-tests/ticket/222
# The script is meant to run on a system with dual nic's 
# You shouldn't need a beaker installed machine, but you will need the following packages installed
# bind expect krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl ipa-server ipa-admintools
ADMINID=admin
ADMINPW=Secret123
ROOTDN="cn=Directory Manager"
ROOTDNPWD=Secret123
DNSFORWARD=10.14.63.12
RELM=TESTRELM.COM
DOMAIN=testrelm.com
BASEDN="dc=testrelm,dc=com"
NISDOMAIN=ipatest
NTPSERVER=clock.redhat.com
FIRSTIP=10.14.5.136
SECONDIP=10.14.5.164

ifcount=$(lspci | grep Ethernet | wc -l)
if [ $ifcount -lt 2 ]; then
	echo "ERROR - This script needs to be run on a machine with 2 or more interfaces";
	exit;
fi

dig $(hostname) | grep $FIRSTIP &> /dev/null
if [ $? -ne 0 ]; then
	echo "ERROR - FIRSTIP is not found when running dig \$(hostname) | grep \$FIRSTIP";
	echo "  Please make sure dig returns a two IP's when you dig the hostname of this machine";
	echo "  Also, edit this script and populate the FIRSTIP and SECONDIP lines"
	exit
fi

dig $(hostname) | grep $SECONDIP &> /dev/null
if [ $? -ne 0 ]; then
	echo "ERROR - SECONDIP is not found when running dig \$(hostname) | grep \$SECONDIP";
	echo "  Please make sure dig returns a two IP's when you dig the hostname of this machine";
	echo "  Also, edit this script and populate the FIRSTIP and SECONDIP lines"
	exit
fi

yum -y install bind expect krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl ipa-server ipa-admintools


echo "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$(hostname) --ip-address=$FIRSTIP -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$(hostname) --ip-address=$FIRSTIP -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U
if [ $? -ne 0 ]; then 
	echo "ERROR - ipa-server-install failed"
	exit 
fi

echo $ADMINPW | kinit admin
if [ $? -ne 0 ]; then 
	echo "kinit failed, please figure out why"
	exit
fi

echo "Remove IPA server"
ipa-server-install --uninstall -U

echo "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$(hostname) --ip-address=$SECONDIP -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$(hostname) --ip-address=$SECONDIP -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U
if [ $? -ne 0 ]; then 
	echo "ERROR - ipa-server-install failed"
	exit 
fi

echo $ADMINPW | kinit admin
if [ $? -ne 0 ]; then 
	echo "kinit failed, please figure out why"
	exit
fi

echo "Remove IPA server"
ipa-server-install --uninstall -U

echo "PASS - all tests passed"
