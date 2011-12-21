#!/bin/bash

. /dev/shm/ipa-automember-cli-lib.sh
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-group-cli-lib.sh
. /dev/shm/ipa-hostgroup-cli-lib.sh
. /dev/shm/ipa-host-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

kinitAs $ADMINID $ADMINPW

ipa hostgroup-del hg1
ipa hostgroup-del hg2
ipa hostgroup-del hg3
ipa hostgroup-del hg4

ipa group-del g1
ipa group-del g2
ipa group-del g3
ipa group-del g4
