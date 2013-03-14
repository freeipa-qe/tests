#!/bin/bash

. /opt/rhqa_ipa/ipa-automember-cli-lib.sh
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-group-cli-lib.sh
. /opt/rhqa_ipa/ipa-hostgroup-cli-lib.sh
. /opt/rhqa_ipa/ipa-host-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

deleteAutomember()
{
	type=$1
	name=$2
	rc=0
	options=""
	expect_name=0
	expect_type=0

	if [ $(echo $name|grep "^P:"|wc -l) -eq 0 ]; then
		options="$name"
	else
		expect_name=1
		name=$(echo $name|sed 's/^P://')
	fi
	
	if [ $(echo $type|grep "^P:"|wc -l) -eq 0 ]; then
		options="$options --type=$type"
	else
		expect_type=1
		type=$(echo $type|sed 's/^P://')
	fi

	cat <<- EOF > /tmp/automember-del-test.sh
	#!/usr/bin/expect
	set timeout 30
	match_max 100000
	spawn ipa automember-del $options
	EOF

	if [ $expect_name -eq 1 ]; then
		cat <<- EOF >> /tmp/automember-del-test.sh
		expect "Automember Rule: "
		send -- "$name\r"
		EOF
	fi
	
	if [ $expect_type -eq 1 ]; then
		cat <<- EOF >> /tmp/automember-del-test.sh
		expect "Grouping Type: "
		send -- "$type\r"
		EOF
	fi
	
	cat <<- EOF >> /tmp/automember-del-test.sh
	expect eof
	EOF

	chmod 755 /tmp/automember-del-test.sh
	rlLog "Executing: ipa automember-del $options"
	#ipa automember-del $options
	/tmp/automember-del-test.sh
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "WARNING: Adding new Automember Rule \"$name\" failed."
	else
		rlLog "Adding new Automember Rule \"$name\" successful."
	fi

	return $rc
}

kinitAs $ADMINID $ADMINPW

rlRun "deleteAutomember hostgroup   hg1"
rlRun "deleteAutomember P:hostgroup hg2"
rlRun "deleteAutomember hostgroup   P:hg3"
rlRun "deleteAutomember P:hostgroup P:hg4"

rlRun "deleteAutomember group   g1"
rlRun "deleteAutomember P:group g2"
rlRun "deleteAutomember group   P:g3"
rlRun "deleteAutomember P:group P:g4"

