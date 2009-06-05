#!/bin/sh

server="mv32a-vm.idm.lab.bos.redhat.com"
client="mv32b-vm.idm.lab.bos.redhat.com"
nisdomain="idm.lab.bos.redhat.com"
nisserver=$server
echo "enable nis on remote ipa server : [$server]"
./env.nis.enable.sh $server
echo "config nis client : [$client]"
. ./config.nis.client.sh 
config_nisclient $client $nisdomain $nisserver
