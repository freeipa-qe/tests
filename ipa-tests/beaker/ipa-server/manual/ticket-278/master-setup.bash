#!/bin/bash

if [ ! -f /dev/shm/env.sh ]; then
	echo 'Sorry, this script needs to be run on a IPA provisioned master from beaker'
	exit
fi
