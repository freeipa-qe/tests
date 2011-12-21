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
ipa hostgroup-add --desc=hg1 hg1
ipa hostgroup-add --desc=hg2 hg2
ipa hostgroup-add --desc=hg3 hg3
ipa hostgroup-add --desc=hg4 hg4

ipa group-add --desc=g1 g1
ipa group-add --desc=g2 g2
ipa group-add --desc=g3 g3
ipa group-add --desc=g4 g4
