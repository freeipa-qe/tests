#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa_ssh_bug.sh of /CoreOS/ipa-tests/acceptance/ipa-ssh-functional
#   Description: IPA Functional SSH Bug Tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
#
### host key functional test
# ipa_ssh_bug_bz799928 - [RFE] Hash the hostname/port information in
#                        the known_hosts file.
#
# ipa_ssh_bug_bz801719 - "Error looking up public keys" while ssh to 
#                        replica using IP address
#   
# ipa_ssh_bug_bz870060 - SSH host keys are not being removed from the cache 
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
ipa_ssh_bug_envsetup()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	rlPhaseStartSetup "ipa_ssh_bug_envsetup - Setup environment for IPA Bug Tests"
		if [ -z "$MYENV" ]; then
			MYENV=1
		fi
		hostname_s=$(hostname -s)

		# Use BEAKERMASTER if BEAKERMASTER_env${MYENV} not set
		MYBM1=$(eval echo \$BEAKERMASTER_env${MYENV}) 
		export MYBM1=${MYBM1:-$BEAKERMASTER} 
		if [ $(echo $MYBM1|grep $hostname_s|wc -l) -gt 0 ]; then
			MYROLE=MASTER
		fi
		
		# User BEAKERSLAVE if BEAKERSLAVE_env${MYENV} not set
		MYBRS=$(eval echo \$BEAKERREPLICA_env${MYENV})
		MYBRS=${MYBRS:-$BEAKERSLAVE}
		COUNT=0
		for MYBR in $MYBRS; do
			COUNT=$(( COUNT+=1 ))
			eval export MYBR$COUNT=$MYBR
			if [ $(echo $MYBR|grep $hostname_s|wc -l) -gt 0 ]; then
				MYROLE=REPLICA$COUNT
			fi
		done
		
		# User BEAKERCLIENT if BEAKERCLIENT_env${MYENV} not set
		MYBCS=$(eval echo \$BEAKERCLIENT_env${MYENV})
		MYBCS=${MYBCS:-$BEAKERCLIENT}
		COUNT=0
		for MYBC in $MYBCS; do
			COUNT=$(( COUNT+=1 ))
			eval export MYBC$COUNT=$MYBC
			if [ $(echo $MYBC|grep $hostname_s|wc -l) -gt 0 ]; then
				MYROLE=CLIENT$COUNT
			fi
		done

		rlLog "===================================================================="
		rlRun "env|sort"
		rlLog "===================================================================="
		#rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME' "
	rlPhaseEnd
}

######################################################################
# test suite
######################################################################
ipa_ssh_bug_run()
{
	ipa_ssh_bug_bz799928 # Hash the hostname/port information in the known_hosts file.
	ipa_ssh_bug_bz801719 # "Error looking up public keys" while ssh to replica using IP address
	ipa_ssh_bug_bz870060 # SSH host keys are not being removed from the cache
}

ipa_ssh_bug_bz799928()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_ssh_bug_0001: bz799928 Hash the hostname/port information in the known_hosts file."
		case "$MYROLE" in
		MASTER*)
			rlLog "Machine in recipe is MASTER ($(hostname))"
			rlRun "KinitAsAdmin"
			rlRun "authconfig --enablemkhomedir --updateall"
			rlRun "service sssd start"

			expect <<-EOF 
			set timeout 3
			set force_conservative 0
			set send_slow {1 .1}
			spawn ssh admin@${MASTER} -q -o StrictHostKeyChecking=no echo 'login successful'
			send -s -- "${ADMINPW}\r"
			expect eof
			EOF

			knownhost="$(ssh-keygen -H -F rhel6-1.testrelm.com -f /var/lib/sss/pubconf/known_hosts |grep ssh-rsa)"
			hostname=$(hostname)
			key=$(echo ${knownhost:3:28} | base64 -d | xxd -ps)
			mac1=$(echo ${knownhost:32:28} | base64 -d | xxd -ps)
			mac2=$(echo -n $hostname | openssl dgst -sha1 -mac HMAC -macopt hexkey:$key | awk '{ print $2 }')
			if [ $mac1 = $mac2 ]; then
				rlPass "BZ 799928 fixed.  sssd known_hosts file using hashes"
			else
				rlFail "BZ 799928 not working."
				rlFail "sssd known_hosts file not using hashes or do not match"
			fi

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

# ipa_ssh_bug_bz801719 - "Error looking up public keys" while ssh to 
#                        replica using IP address
ipa_ssh_bug_bz801719()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	MYREPLICA1_IP=$(dig +short $(eval echo \$BEAKERREPLICA1_env${MYENV}))
	rlPhaseStartTest "ipa_ssh_bug_0002: bz801719 Error looking up public keys while ssh to replica using IP address"
		case "$MYROLE" in
		MASTER*)
			rlLog "Machine in recipe is MASTER ($(hostname))"
			rlRun "KinitAsAdmin"

			expect <<-EOF > $tmpout
			set timeout 3
			set force_conservative 0
			set send_slow {1 .1}
			spawn ssh admin@${MYREPLICA1_IP} -q -o StrictHostKeyChecking=yes echo 'login successful'
			expect "*ssword:"
			send -s -- "${ADMINPW}\r"
			expect eof
			EOF
			rlAssertGrep "login successful" $tmpout

			if [ $(grep "Error looking up public keys" $tmpout |wc -l) -gt 0 ]; then
				rlFail "BZ 801719 Found...Error looking up public keys while ssh to replica using IP address"	
			else
				rlPass "BZ 801719 not found."
				rlPass "Error message 'Error looking up public keys' not seen in output"
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

# ipa_ssh_bug_bz870060 - SSH host keys are not being removed from the cache 
ipa_ssh_bug_bz870060()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	MYREPLICA1=$(echo $(eval echo \$BEAKERREPLICA1_env${MYENV})|cut -f1 -d.).$DOMAIN
	rlPhaseStartTest "ipa_ssh_bug_0003: bz870060 SSH host keys are not being removed from the cache"
		case "$MYROLE" in
		MASTER*)
			rlLog "Machine in recipe is MASTER ($(hostname))"
			rlRun "KinitAsAdmin"
			
			rlRun "ipa host-show $MYREPLICA1 --all --raw | grep ipasshpubkey:"

			rlRun "kdestroy"
			expect <<-EOF > $tmpout
			set timeout 3
			set force_conservative 0
			set send_slow {1 .1}
			spawn ssh admin@${MYREPLICA1} -q -o StrictHostKeyChecking=yes echo 'login successful'
			expect "*ssword:"
			send -s -- "${ADMINPW}\r"
			expect eof
			EOF
			rlAssertGrep "login successful" $tmpout
			rlRun "KinitAsAdmin"


			rlRun "yum -y install ldb-tools"

			rlRun "ldbsearch -H /var/lib/sss/db/cache_$DOMAIN.ldb -b name=$MYREPLICA1,cn=ssh_hosts,cn=custom,cn=$DOMAIN,cn=sysdb 2>/dev/null| grep -i sshPublicKey:"
		
			rlRun "ipa host-mod $MYREPLICA1 --sshpubkey=''"
	
			rlRun "kdestroy"
			expect <<-EOF > $tmpout
			set timeout 3
			set force_conservative 0
			set send_slow {1 .1}
			spawn ssh admin@${MYREPLICA1} -q -o StrictHostKeyChecking=yes echo 'login successful'
			expect "*ssword:"
			send -s -- "${ADMINPW}\r"
			expect eof
			EOF
			rlAssertGrep "login successful" $tmpout
			rlRun "KinitAsAdmin"
			
			if [ $(ldbsearch -H /var/lib/sss/db/cache_$DOMAIN.ldb -b name=$MYREPLICA1,cn=ssh_hosts,cn=custom,cn=$DOMAIN,cn=sysdb 2>/dev/null| grep -i sshPublicKey:|wc -l) -gt 0 ]; then
				rlRun "ldbsearch -H /var/lib/sss/db/cache_$DOMAIN.ldb -b name=$MYREPLICA1,cn=ssh_hosts,cn=custom,cn=$DOMAIN,cn=sysdb 2>/dev/null"
				rlFail "BZ 870060 Found...SSH host keys are not being removed from the cache"
			else
				rlPass "BZ 870060 not found."
			fi
			
			rlRun "sftp -o StrictHostKeyChecking=no $MYREPLICA1:/etc/ssh/ssh_host_rsa_key.pub /tmp/ssh_host_rsa_key.pub.$MYREPLICA1"
			rlRun "sftp -o StrictHostKeyChecking=no $MYREPLICA1:/etc/ssh/ssh_host_dsa_key.pub /tmp/ssh_host_dsa_key.pub.$MYREPLICA1"
			rlRun "ipa host-mod $MYREPLICA1 --sshpubkey=\"$(cat /tmp/ssh_host_rsa_key.pub.$MYREPLICA1), $(cat /tmp/ssh_host_dsa_key.pub.$MYREPLICA1)\""

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
