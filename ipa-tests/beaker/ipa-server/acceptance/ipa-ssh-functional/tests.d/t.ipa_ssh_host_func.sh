#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa_ssh_host_func.sh of /CoreOS/ipa-tests/acceptance/ipa-ssh-functional
#   Description: IPA Functional SSH Host Key tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
#
### host key functional test
# New client added and host keys uploaded automatically to DNS
# User ssh to client and sees valid keys match from DNS.
        # ATM this will still prompt until DNSSEC support added???
# Admin revokes/removes host keys
# User does not see key match from DNS
# Admin re-adds keys
# Host replaces keys
# User gets error/warning about key mismatch?
# host-mod add keys after host-disable
# ssh to/from host after host-disable
# host-mod add keys after host-del?
# ssh to/from host after host-del?
#   
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2012 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

######################################################################
# variables
######################################################################
### Relies on MYROLE variable to be set appropriately.  This is done
### manually or in runtest.sh
######################################################################

######################################################################
# test suite
######################################################################
ipa_ssh_host_func_run()
{
	ipa_ssh_host_func_envsetup

	ipa_ssh_host_func_0001 # New client added and host keys uploaded automatically to DNS
	ipa_ssh_host_func_0002 # User ssh to client and sees valid keys match from DNS.
        # ATM this will still prompt until DNSSEC support added???
	ipa_ssh_host_func_0003 # Admin revokes/removes host keys
	ipa_ssh_host_func_0004 # User does not see key match from DNS
	ipa_ssh_host_func_0005 # Admin re-adds keys
	ipa_ssh_host_func_0006 # Host replaces keys
	ipa_ssh_host_func_0007 # User gets error/warning about key mismatch?
	ipa_ssh_host_func_0008 # host-mod add keys after host-disable
	ipa_ssh_host_func_0009 # ssh to/from host after host-disable
	ipa_ssh_host_func_0010 # host-mod add keys after host-del?
	ipa_ssh_host_func_0011 # ssh to/from host after host-del?

	ipa_ssh_host_func_envcleanup
}

ipa_ssh_host_func_envsetup()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartSetup "ipa_ssh_host_func_envsetup - Setup environment for IPA User Functional tests"
		rlLog "===================================================================="
		env|sort
		rlLog "===================================================================="
		case "$MYROLE" in
		MASTER*)
			rlLog "Machine in recipe is MASTER ($(hostname))"
			rlRun "KinitAsAdmin"
			rlRun "create_ipauser sshuser ssh user Passw0rd1"
			rlRun "create_ipauser sshuser2 ssh user2 Passw0rd1"

			rlRun "authconfig --enablemkhomedir --updateall"
			rlRun "service sssd start"

			KEYFILE=~sshuser/.ssh/id_rsa
			rlRun "su - sshuser -c \"ssh-keygen -q -t rsa -N '' -C 'sshuser.$DOMAIN' -f $KEYFILE\""
			rlRun "su - sshuser -c \"echo Passw0rd1|kinit sshuser\""
			rlRun "su - sshuser -c \"ipa user-mod sshuser --sshpubkey='$(cat ${KEYFILE}.pub)'\""

			KEYFILE2=~sshuser2/.ssh/id_rsa
			rlRun "su - sshuser2 -c \"ssh-keygen -q -t rsa -N '' -C 'sshuser2.$DOMAIN' -f $KEYFILE2\""
			rlRun "su - sshuser2 -c \"echo Passw0rd1|kinit sshuser2\""
			rlRun "su - sshuser2 -c \"ipa user-mod sshuser2 --sshpubkey='$(cat ${KEYFILE2}.pub)'\""

			rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
			;;
		REPLICA*)
			rlLog "Machine in recipe is REPLICA ($(hostname))"
			rlRun "authconfig --enablemkhomedir --updateall"
			rlRun "service sssd start"
			rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
			;;
		CLIENT*)
			rlLog "Machine in recipe is CLIENT ($(hostname))"
			rlRun "authconfig --enablemkhomedir --updateall"
			rlRun "service sssd start"
			rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
			;;
		*)
			rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
			;;
		esac
	rlPhaseEnd
}

# New client added and host keys uploaded automatically to DNS
ipa_ssh_host_func_0001()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERCLIENT1_env${MYENV})
	rlPhaseStartTest "ipa_ssh_host_func_0001: New client added and host keys uploaded automatically to DNS"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	REPLICA*)
		rlLog "Machine in recipe is REPLICA ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT1)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "KinitAsAdmin"
	
		RSAKEYFP=$(ssh-keygen -r $(hostname) -f /etc/ssh/ssh_host_rsa_key.pub|awk '{print $6}')
		RSADNSFP=$(dig +short $(hostname) sshfp|grep "^1 1" |awk '{print $3}'|tr '[:upper:]' '[:lower:]')
		if [ -z "$RSAKEYFP" -o -z "$RSADNSFP" ]; then
			rlFail "RSA Key FP on host or in DNS is empty"
		elif [ "$RSAKEYFP" = "$RSADNSFP" ]; then
			rlPass "RSA Key FP on host matches FP in DNS"
		else
			rlFail "RSA Key FP on host does not match FP in DNS"
		fi

		DSAKEYFP=$(ssh-keygen -r $(hostname) -f /etc/ssh/ssh_host_dsa_key.pub|awk '{print $6}')
		DSADNSFP=$(dig +short $(hostname) sshfp|grep "^2 1" |awk '{print $3}'|tr '[:upper:]' '[:lower:]')
		if [ -z "$DSAKEYFP" -o -z "$DSADNSFP" ]; then
			rlFail "DSA Key FP on host or in DNS is empty"
		elif [ "$DSAKEYFP" = "$DSADNSFP" ]; then
			rlPass "DSA Key FP on host matches FP in DNS"
		else
			rlFail "DSA Key FP on host does not match FP in DNS"
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# User ssh to client and sees valid keys match from DNS.
ipa_ssh_host_func_0002()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_ssh_host_func_0002: User ssh to client and sees valid keys match from DNS"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "su - sshuser -c \"kdestroy; ssh $CLIENT 'hostname'\"|grep $CLIENT"	
		
		expfile=/tmp/sshhosttest.exp
		cat > $expfile <<-EOF
		set timeout 30
		set force_conservative 0
		set send_slow {1 .1}
		match_max 100000
		spawn     su - sshuser -c "ssh $CLIENT"
		expect    "*$ "
		send      "ssh-keygen -r $CLIENT -f /etc/ssh/ssh_host_rsa_key.pub\r"
		expect    "*$ "
		send      "ssh-keygen -r $CLIENT -f /etc/ssh/ssh_host_dsa_key.pub\r"
		expect    "*$ "
		send      "dig +short $CLIENT sshfp\r"
		expect    "*$ "
		send      "exit\r"
		expect    eof
		EOF
		expect -f $expfile > $tmpout 2>&1
		rm -f $expfile

		RSAKEYFP=$(grep "$CLIENT IN SSHFP 1 1" $tmpout|awk '{print $6}')
		RSADNSFP=$(grep "^1 1 " $tmpout|awk '{print $3}'|tr '[:upper:]' '[:lower:]')
		if [ -z "$RSAKEYFP" -o -z "$RSADNSFP" ]; then
			rlFail "RSA Key FP on host or in DNS is empty"
		elif [ "$RSAKEYFP" = "$RSADNSFP" ]; then
			rlPass "RSA Key FP on host matches FP in DNS"
		else
			rlFail "RSA Key FP on host does not match FP in DNS"
		fi

		DSAKEYFP=$(grep "$CLIENT IN SSHFP 2 1" $tmpout|awk '{print $6}')
		DSADNSFP=$(grep "^2 1 " $tmpout|awk '{print $3}'|tr '[:upper:]' '[:lower:]')
		if [ -z "$RSAKEYFP" -o -z "$RSADNSFP" ]; then
			rlFail "RSA Key FP on host or in DNS is empty"
		elif [ "$RSAKEYFP" = "$RSADNSFP" ]; then
			rlPass "RSA Key FP on host matches FP in DNS"
		else
			rlFail "RSA Key FP on host does not match FP in DNS"
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	REPLICA*)
		rlLog "Machine in recipe is REPLICA ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# Admin revokes/removes host keys
ipa_ssh_host_func_0003()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_ssh_host_func_0003: Admin revokes/removes host keys"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "KinitAsAdmin"
		rlRun "ipa host-mod $CLIENT --sshpubkey="
		#rlRun "service sssd stop"
		#rlRun "rm -f /var/lib/sss/db/*"
		#rlRun "service sssd start"
		rlRun "ssh-keygen -R $CLIENT -f /var/lib/sss/pubconf/known_hosts"
		CHK1=$(ipa host-show $CLIENT --raw|grep sshpubkeyfp|wc -l)
		if [ $CHK1 -eq 0 ]; then
			rlPass "IPA Host has NO associated Public SSH Host Key"
		else
			rlFail "IPA Host has an associated Public SSH Host Key when it should not"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	REPLICA*)
		rlLog "Machine in recipe is REPLICA ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# User does not see key match from DNS
ipa_ssh_host_func_0004()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_ssh_host_func_0004: User does not see key match from DNS"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		expfile=/tmp/sshhosttest.exp
		cat > $expfile <<-EOF
		set timeout 30
		set force_conservative 0
		set send_slow {1 .1}
		match_max 100000
		spawn     su - sshuser -c "kdestroy"
		expect    eof
		spawn     su - sshuser -c "ssh -o StrictHostKeyChecking=yes $CLIENT hostname"
		expect    eof
		EOF
		expect -f $expfile > $tmpout 2>&1
		rm -f $expfile

		rlAssertGrep "No RSA host key is known for $CLIENT" $tmpout
		rlAssertGrep "Host key verification failed." $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	REPLICA*)
		rlLog "Machine in recipe is REPLICA ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# Admin re-adds keys
ipa_ssh_host_func_0005()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_ssh_host_func_0005: Admin re-adds keys"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "KinitAsAdmin"
		rlRun "sftp -o StrictHostKeyChecking=no $CLIENT:/etc/ssh/ssh_host_rsa_key.pub /tmp/ssh_host_rsa_key.pub.$CLIENT"
		rlRun "sftp -o StrictHostKeyChecking=no $CLIENT:/etc/ssh/ssh_host_dsa_key.pub /tmp/ssh_host_dsa_key.pub.$CLIENT"
		rlRun "ipa host-mod $CLIENT --sshpubkey=\"$(cat /tmp/ssh_host_rsa_key.pub.$CLIENT), $(cat /tmp/ssh_host_dsa_key.pub.$CLIENT)\""
		
		RSAKEYFP=$(ssh-keygen -r $CLIENT -f /tmp/ssh_host_rsa_key.pub.$CLIENT|awk '{print $6}')
		RSADNSFP=$(dig +short $CLIENT sshfp|grep "^1 1" |awk '{print $3}'|tr '[:upper:]' '[:lower:]')
		if [ -z "$RSAKEYFP" -o -z "$RSADNSFP" ]; then
			rlFail "RSA Key FP on host or in DNS is empty"
		elif [ "$RSAKEYFP" = "$RSADNSFP" ]; then
			rlPass "RSA Key FP on host matches FP in DNS"
		else
			rlFail "RSA Key FP on host does not match FP in DNS"
		fi

		DSAKEYFP=$(ssh-keygen -r $CLIENT -f /tmp/ssh_host_dsa_key.pub.$CLIENT|awk '{print $6}')
		DSADNSFP=$(dig +short $CLIENT sshfp|grep "^2 1" |awk '{print $3}'|tr '[:upper:]' '[:lower:]')
		if [ -z "$DSAKEYFP" -o -z "$DSADNSFP" ]; then
			rlFail "DSA Key FP on host or in DNS is empty"
		elif [ "$DSAKEYFP" = "$DSADNSFP" ]; then
			rlPass "DSA Key FP on host matches FP in DNS"
		else
			rlFail "DSA Key FP on host does not match FP in DNS"
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	REPLICA*)
		rlLog "Machine in recipe is REPLICA ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# Host replaces keys
ipa_ssh_host_func_0006()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERCLIENT1_env${MYENV})
	rlPhaseStartTest "ipa_ssh_host_func_0006: Host replaces keys"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	REPLICA*)
		rlLog "Machine in recipe is REPLICA ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT1)
		rlLog "Machine in recipe is CLIENT ($(hostname))"

		rlRun "mkdir /etc/ssh/backup"
		rlRun "mv /etc/ssh/ssh_host_[dr]sa_key* /etc/ssh/backup"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /etc/ssh/ssh_host_rsa_key"
		rlRun "ssh-keygen -q -t dsa -N '' -C '' -f /etc/ssh/ssh_host_dsa_key"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# User gets error/warning about key mismatch
ipa_ssh_host_func_0007()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_ssh_host_func_0007: User gets error/warning about key mismatch"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		expfile=/tmp/sshhosttest.exp
		cat > $expfile <<-EOF
		set timeout 30
		set force_conservative 0
		set send_slow {1 .1}
		match_max 100000
		spawn     su - sshuser -c "kdestroy"
		expect    eof
		spawn     su - sshuser -c "ssh -o StrictHostKeyChecking=yes $CLIENT hostname"
		expect    eof
		EOF
		expect -f $expfile > $tmpout 2>&1
		rm -f $expfile

		rlAssertGrep "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!" $tmpout
		rlAssertGrep "Offending key in /var/lib/sss/pubconf/known_hosts" $tmpout
		rlAssertGrep "RSA host key for $CLIENT has changed and you have requested strict checking." $tmpout
		rlAssertGrep "Host key verification failed." $tmpout

		rlRun "cat $tmpout"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	REPLICA*)
		rlLog "Machine in recipe is REPLICA ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# host-mod add keys after host-disable
ipa_ssh_host_func_0008()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_ssh_host_func_0008: host-mod add keys after host-disable"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		rlRun "KinitAsAdmin"
		rlRun "sftp -o StrictHostKeyChecking=no $CLIENT:/etc/ssh/ssh_host_rsa_key.pub /tmp/new_ssh_host_rsa_key.pub.$CLIENT"
		rlRun "sftp -o StrictHostKeyChecking=no $CLIENT:/etc/ssh/ssh_host_dsa_key.pub /tmp/new_ssh_host_dsa_key.pub.$CLIENT"
		rlRun "ipa host-mod $CLIENT --updatedns --sshpubkey=\"$(cat /tmp/new_ssh_host_rsa_key.pub.$CLIENT), $(cat /tmp/new_ssh_host_dsa_key.pub.$CLIENT)\""
		
		RSAKEYFP=$(ssh-keygen -r $CLIENT -f /tmp/new_ssh_host_rsa_key.pub.$CLIENT|awk '{print $6}')
		RSADNSFP=$(dig +short $CLIENT sshfp|grep "^1 1" |awk '{print $3}'|tr '[:upper:]' '[:lower:]')
		if [ -z "$RSAKEYFP" -o -z "$RSADNSFP" ]; then
			rlFail "RSA Key FP on host or in DNS is empty"
		elif [ "$RSAKEYFP" = "$RSADNSFP" ]; then
			rlPass "RSA Key FP on host matches FP in DNS"
		else
			rlFail "RSA Key FP on host does not match FP in DNS"
		fi

		DSAKEYFP=$(ssh-keygen -r $CLIENT -f /tmp/new_ssh_host_dsa_key.pub.$CLIENT|awk '{print $6}')
		DSADNSFP=$(dig +short $CLIENT sshfp|grep "^2 1" |awk '{print $3}'|tr '[:upper:]' '[:lower:]')
		if [ -z "$DSAKEYFP" -o -z "$DSADNSFP" ]; then
			rlFail "DSA Key FP on host or in DNS is empty"
		elif [ "$DSAKEYFP" = "$DSADNSFP" ]; then
			rlPass "DSA Key FP on host matches FP in DNS"
		else
			rlFail "DSA Key FP on host does not match FP in DNS"
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	REPLICA*)
		rlLog "Machine in recipe is REPLICA ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# ssh to/from host after host-disable
ipa_ssh_host_func_0009()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_ssh_host_func_0009: ssh to/from host after host-disable"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		expfile=/tmp/sshhosttest.exp
		cat > $expfile <<-EOF
		set timeout 30
		set force_conservative 0
		set send_slow {1 .1}
		match_max 100000
		spawn     su - sshuser -c "kdestroy"
		expect    eof
		spawn     su - sshuser -c "ssh -o StrictHostKeyChecking=yes $CLIENT echo login successful"
		expect    eof
		EOF
		expect -f $expfile > $tmpout 2>&1
		rm -f $expfile

		rlAssertGrep "^login successful" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	REPLICA*)
		rlLog "Machine in recipe is REPLICA ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# host-mod add keys after host-del
ipa_ssh_host_func_0010()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_ssh_host_func_0010: host-mod add keys after host-del"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "KinitAsAdmin"
		rlRun "ipa host-del $CLIENT"
		#rlRun "ipa dnsrecord-del $DOMAIN $(echo $CLIENT|cut -f1 -d.) --del-all"
		rlLog "Clearing sssd cache of previous host info"
		rlRun "service sssd stop"
		rlRun "ssh-keygen -R $CLIENT -f /var/lib/sss/pubconf/known_hosts"
		rlRun "rm -f /var/lib/sss/{db,mc}/*"
		rlRun "service sssd start"

		rlRun "ipa host-mod $CLIENT --updatedns --sshpubkey=\"$(cat /tmp/new_ssh_host_rsa_key.pub.$CLIENT), $(cat /tmp/new_ssh_host_dsa_key.pub.$CLIENT)\" > $tmpout 2>&1" 2
		
		rlAssertGrep "ipa: ERROR: no such entry" $tmpout
		rlRun "cat $tmpout"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	REPLICA*)
		rlLog "Machine in recipe is REPLICA ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# ssh to/from host after host-del
ipa_ssh_host_func_0011()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_ssh_host_func_0011: ssh to/from host after host-del"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		expfile=/tmp/sshhosttest.exp
		cat > $expfile <<-EOF
		set timeout 30
		set force_conservative 0
		set send_slow {1 .1}
		match_max 100000
		spawn     su - sshuser -c "kdestroy"
		expect    eof
		spawn     su - sshuser -c "ssh -o StrictHostKeyChecking=yes $CLIENT hostname"
		expect    eof
		EOF
		expect -f $expfile > $tmpout 2>&1
		rm -f $expfile

		rlAssertGrep "No RSA host key is known for $CLIENT" $tmpout
		rlAssertGrep "Host key verification failed." $tmpout
		rlRun "cat $tmpout"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	REPLICA*)
		rlLog "Machine in recipe is REPLICA ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}


