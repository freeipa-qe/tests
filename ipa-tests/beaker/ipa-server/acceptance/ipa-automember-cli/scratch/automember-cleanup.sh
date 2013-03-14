#!/bin/bash

. /opt/rhqa_ipa/ipa-automember-cli-lib.sh
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-group-cli-lib.sh
. /opt/rhqa_ipa/ipa-hostgroup-cli-lib.sh
. /opt/rhqa_ipa/ipa-host-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

kinitAs $ADMINID $ADMINPW

ipa hostgroup-del hg1
ipa hostgroup-del hg2
ipa hostgroup-del hg3
ipa hostgroup-del hg4

ipa group-del g1
ipa group-del g2
ipa group-del g3
ipa group-del g4
