#!/bin/bash
######################################################
# test suite  : ipa-autorenewcert
# description : IPA auto-renew certificate test suite
# created by  : Yi Zhang (yzhang@redhat.com)
# created date: Tue Aug  7 09:37:45 PDT 2012
######################################################

# time period used in this test
# [pre-autorenew] [auto-renew] [ post-autorenew] [ certs expiration time ] [postExpire]
# preAutorenew  : before auto renew being triggered
# autorenew     : 1 day to 1 hour before cert expires
# postAutorenew : after autorenew period but before certs expires
# certExpire    : exact point when certs expires
# postExpire    : after cert expires

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. ../../shared/ipa-server-shared.sh
. ../../shared/env.sh

. ./d.autorenewcert.sh
. ./lib.autorenewcert.sh

# calculate dynamic variables
host=`hostname`
CAINSTANCE="pki-ca"
DSINSTANCE="`find_dirsrv_instance ds`"
CA_DSINSTANCE="`find_dirsrv_instance ca`"
logs=""
BASEDN="dc=yzhang,dc=redhat,dc=com"
RELM="YZHANG.REDHAT.COM"
DOMAIN="yzhang.redhat.com"
DNSFORWARD=192.168.122.1

certReport=$1
if [ "$certReport" = "" ];then
    certReport="/tmp/ipa.cert.report.$RANDOM.txt"
fi

list_all_ipa_certs
