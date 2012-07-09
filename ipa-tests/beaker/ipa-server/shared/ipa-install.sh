#!/bin/bash
### WORK IN PROGRESS...NOT READY FOR USE YET

#  
# ROLE=MASTER, SLAVE, CLIENT, CLIENT2
# ROLE=MASTER_env2, REPLICA_env2, CLIENT_env2
# 
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="MASTER">
#   <params> <param name="TOPO" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA">
#   <params> <param name="TOPO" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA">
#   <params> <param name="TOPO" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA">
#   <params> <param name="TOPO" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA">
#   <params> <param name="TOPO" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA">
#   <params> <param name="TOPO" value="star"/> <param name="DOM" value="chicago.testrelm.com"/> </params>
#

ipa_install_envcleanup() {
	for i in $(seq 1 10); do
		unset ${!BEAKERSLAVE*}
		unset ${!BEAKERREPLICA*}
		unset ${!SLAVE*}
		unset ${!REPLICA*}
		unset ${!MASTER*}
		unset ${!BEAKERMASTER*}
		unset ${!MYROLE*}
		unset ${!MYENV*}
	done
}

ipa_install_set_vars() {

	# First let's normalize the data to use <ROLE>_env<NUM> variables:
	[ -n "$MASTER"  -a -z "$MASTER_env1"  ] && export MASTER_env1="$MASTER"
	[ -n "$SLAVE"   -a -z "$REPLICA_env1" ] && export REPLICA_env1="$SLAVE"
	[ -n "$REPLICA" -a -z "$REPLICA_env1" ] && export REPLICA_env1="$REPLICA"
	[ -n "$CLIENT"  -a -z "$CLIENT_env1"  ] && export CLIENT_env1="$CLIENT"
	[ -n "$CLIENT2" -a -n "$SLAVE" -a -z "$CLIENT2_env1" ] && \
		export CLIENT_env1=$(echo $CLIENT_env1 $CLIENT2)
	
	# Process MASTER variables
	I=1
	while test -n "$(eval echo \$MASTER_env${I})"; do
		echo "Parsing MASTER Variables for Environment ${I}"
		M=$(eval echo \$MASTER_env${I}|awk '{print $1}')
		export MASTER_env${I}=$M
		export BEAKERMASTER_env${I}=$M
		export BEAKERMASTER_IP_env${I}=$(dig +short $M)
		if [ "$(hostname -s)" = "$(echo $M|cut -f1 -d.)" ]; then
			export MYROLE=MASTER_env${I}
			export MYENV=${I}
		fi
		I=$(( I += 1 ))
	done

	# Process REPLICA variables
	I=1
	while test -n "$(eval echo \$REPLICA_env${I})"; do
		J=1
		echo "Parsing REPLICA Variables for Environment ${I}"
		export BEAKERREPLICA_env${I}="$(eval echo \$REPLICA_env${I})"
		for R in $(eval echo \$REPLICA_env${I}); do
			export REPLICA${J}_env${I}=$R
			export BEAKERREPLICA${J}_env${I}=$R
			export BEAKERREPLICA${J}_IP_env${I}=$(dig +short $R)
			if [ "$(hostname -s)" = "$(echo $R|cut -f1 -d.)" ]; then
				export MYROLE=REPLICA${J}_env${I}
				export MYENV=${I}
			fi
			J=$(( J += 1 ))
		done
		I=$(( I += 1 ))
	done

	# Process CLIENT variables
	I=1
	while test -n "$(eval echo \$CLIENT_env${I})"; do
		J=1
		echo "Parsing CLIENT Variables for Environment ${I}"
		export BEAKERCLIENT_env${I}=$(eval echo \$CLIENT_env${I})
		for C in $(eval echo \$CLIENT_env${I}); do
			export CLIENT${J}_env${I}=$C
			export BEAKERCLIENT${J}_env${I}=$C
			export BEAKERCLIENT${J}_IP_env${I}=$(dig +short $C)
			if [ "$(hostname -s)" = "$(echo $C|cut -f1 -d.)" ]; then
				export MYROLE=CLIENT${J}_env${I}
				export MYENV=${I}
			fi
			J=$(( J += 1 ))
		done
		I=$(( I += 1 ))
	done

	# Make sure Simple Vars are set in env.sh for simplicity and
    # backwards compatibility with older tests.  This means no
    # _env<NUM> suffix.
	echo "export MASTER=$MASTER_env1" >> /dev/shm/env.sh
	echo "export SLAVE=$REPLICA_env1" >> /dev/shm/env.sh
	echo "export REPLICA=$REPLICA_env1" >> /dev/shm/env.sh
	echo "export CLIENT=$CLIENT_env1" >> /dev/shm/env.sh
	echo "export CLIENT2=$CLIENT2_env1" >> /dev/shm/env.sh
}


######################################################################
# ipa_install_topo_default
#         RN R1 R2
#          \ | /
#       R7-- M --R3
#          / | \
#         R6 R5 R4
# The thing to note here is that this supports a variable number of
# Replicas.  All replicas created from and connected to MASTER.
######################################################################
ipa_install_topo_default()
{
	TESTORDER=$(( TESTORDER += 1 ))
	if [ -z "$MYENV" ]; then
		export MYENV=1
	fi

	rlPhaseStartTest "ipa_install_topo_default_envsetup - Make sure enough Replicas are defined"
		rlLog
		MYBM1=$(eval echo \$BEAKERMASTER_env${MYENV})
		MYBRS=$(eval echo \$BEAKERREPLICA_env${MYENV})
		MYBCS=$(eval echo \$BEAKERCLIENT_env${MYENV})
	rlPhaseEnd	
	
	rlPhaseStartTest "ipa_install_topo_default_master - install Master in Default Topology"
		if [ "$(hostname -s)" = "$(echo $MYBM1|cut -f1 -d.)" ]; then
			ipa_install_master
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBM1.0' -m $MYBM1"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBM1.0'  $MYBM1"	
		fi
	rlPhaseEnd
	
	for MYBR1 in $MYBRS; do
		rlPhaseStartTest "ipa_install_topo_default_replica - install Replica1 in Default Topology - $MYBR1"
			if [ "$(hostname -s)" = "$(echo $MYBR1|cut -f1 -d.)" ]; then
				ipa_install_replica $MYBM1
				rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR1.1' -m $MYBR1"	
			else
				rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR1.1'  $MYBR1"
			fi
		rlPhaseEnd
	done
}

######################################################################
# ipa_install_topo_star
#            R1
#            |
#        R5--M--R2
#           / \
#          R4  R3
# This REQUIRES 5 replicas
######################################################################
ipa_install_topo_star()
{
	TESTORDER=$(( TESTORDER += 1 ))
	if [ -z "$MYENV" ]; then
		export MYENV=1
	fi

	rlPhaseStartTest "ipa_install_topo_star_envsetup - Make sure enough Replicas are defined"
		if [ $(eval echo \$REPLICA_env${$MYENV}|wc -w) -lt 5 ]; then
			rlFail "Not enough Replicas defined for star topology...skipping"
			rlPhaseEnd
			return 1
		else
			rlPass "Enough Replicas defined for star topology...continuing"
			MYBM1=$(eval echo \$BEAKERMASTER_env${MYENV})
			MYBR1=$(eval echo \$BEAKERREPLICA1_env${MYENV})
			MYBR2=$(eval echo \$BEAKERREPLICA2_env${MYENV})
			MYBR3=$(eval echo \$BEAKERREPLICA3_env${MYENV})
			MYBR4=$(eval echo \$BEAKERREPLICA4_env${MYENV})
			MYBR5=$(eval echo \$BEAKERREPLICA5_env${MYENV})
			MYBC1=$(eval echo \$BEAKERCLIENT1_env${MYENV})
			MYBC2=$(eval echo \$BEAKERCLIENT2_env${MYENV})
		fi
	rlPhaseEnd	
	
	rlPhaseStartTest "ipa_install_topo_star_master - install Master in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBM1|cut -f1 -d.)" ]; then
			ipa_install_master
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBM1.0' -m $MYBM1"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBM1.0'  $MYBM1"	
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_star_replica1 - install Replica1 in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR1|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR1.1' -m $MYBR1"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR1.1'  $MYBR1"	
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_star_replica2 - install Replica2 in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR2|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR2.2' -m $MYBR2"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR2.2'  $MYBR2"	
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_star_replica3 - install Replica3 in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR3|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR3.3' -m $MYBR3"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR3.3'  $MYBR3"	
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_star_replica4 - install Replica4 in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR4|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR4.0' -m $MYBR4"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR4.0'  $MYBR4"	
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_star_replica5 - install Replica5 in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR5|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR5.0' -m $MYBR5"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR5.0'  $MYBR5"	
		fi
	rlPhaseEnd
}

######################################################################
# ipa_install_topo_tree1
#            M
#           / \
#          R1  R2
#         /    /\
#        R3   R4-R5
# This REQUIRES 5 replicas
######################################################################
ipa_install_topo_tree1()
{
	TESTORDER=$(( TESTORDER += 1 ))
	if [ -z "$MYENV" ]; then
		export MYENV=1
	fi

	rlPhaseStartTest "ipa_install_topo_tree1_envsetup - Make sure enough Replicas are defined"
		if [ $(eval echo \$REPLICA_env${$MYENV}|wc -w) -lt 5 ]; then
			rlFail "Not enough Replicas defined for tree1 topology...skipping"
			rlPhaseEnd
			return 1
		else
			rlPass "Enough Replicas defined for star topology...continuing"
			MYBM1=$(eval echo \$BEAKERMASTER_env${MYENV})
			MYBR1=$(eval echo \$BEAKERREPLICA1_env${MYENV})
			MYBR2=$(eval echo \$BEAKERREPLICA2_env${MYENV})
			MYBR3=$(eval echo \$BEAKERREPLICA3_env${MYENV})
			MYBR4=$(eval echo \$BEAKERREPLICA4_env${MYENV})
			MYBR5=$(eval echo \$BEAKERREPLICA5_env${MYENV})
			MYBC1=$(eval echo \$BEAKERCLIENT1_env${MYENV})
			MYBC2=$(eval echo \$BEAKERCLIENT2_env${MYENV})
		fi
	rlPhaseEnd	
	
	rlPhaseStartTest "ipa_install_topo_tree1_master - install Master in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBM1|cut -f1 -d.)" ]; then
			ipa_install_master
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBM1.0' -m $MYBM1"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBM1.0'  $MYBM1"	
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_tree1_replica1 - install Replica1 in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR1|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR1.1' -m $MYBR1"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR1.1'  $MYBR1"	
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_tree1_replica2 - install Replica2 in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR2|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR2.2' -m $MYBR2"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR2.2'  $MYBR2"	
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_tree1_replica3 - install Replica3 in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR3|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBR1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR3.3' -m $MYBR3"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR3.3'  $MYBR3"	
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_tree1_replica4 - install Replica4 in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR4|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBR2
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR4.4' -m $MYBR4"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR4.4'  $MYBR4"	
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_tree1_replica5 - install Replica5 in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR5|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBR2
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR5.5' -m $MYBR5"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR5.5'  $MYBR5"	
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa_install_topo_tree1_connect_rep4_and_rep5 - Create replication agreement between Replica4 and Replica5"
		if [ "$(hostname -s)" = "$(echo $MYBR4|cut -f1 -d.)" ]; then
			ipa_connect_replica $MYBR4 $MYBR5
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR4.6' -m $MYBR4"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR4.6'  $MYBR4"	
		fi
	rlPhaseEnd
}

ipa_install_envs()
{
	TESTORDER=$(( TESTORDER += 1 ))
	I=1
	rlPhaseStartTest "ipa_install_envs - Install IPA in all defined Environments sequentially"
		while test -n "$(eval echo \$BEAKERMASTER_env${I})"; do
			RUNMASTER=$(eval echo \$BEAKERMASTER_env${I})
			if [ "$MYENV" != "$I" ]; then
				rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYENV.0' $RUNMASTER"
			else
				ipa_install_topo
			fi
			# Now, if we're the MASTER for ENV $I, rhts-sync-set to unblock others...
			if [ "$(hostname -s)" = "$(echo $RUNMASTER|cut -f1 -d.)" ]; then
				rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYENV.0' -m $RUNMASTER"
			fi
			I=$(( I += 1 ))
		done
	rlPhaseEnd
}

ipa_install_topo()
{
	case TOPO${MYENV} in 
	star*|STAR*) 
		ipa_install_topo_star
		;;
	tree1|TREE1|tree|TREE)
		ipa_install_topo_tree1
		;;
	*)
		ipa_install_topo_default
		;;
	esac

}

ipa_install_master() 
{
	tmpout=/tmp/error_msg.out
	rlLog "$FUNCNAME"
	#yum clean all
	#yum -y install bind expect krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl nmap
	#yum -y install --disablerepo=updates-testing* '*ipa-server'
	#yum -y update		
	#
	#rpm -qa | grep ipa-server > $tmpout 2>&1
	#
	#if [ $(rpm -qa | grep ipa-server | wc -l) -eq 0 ]; then
	#	rlFail "No ipa-server packages found"
	#fi
		
}

ipa_install_replica()
{
	local MYMASTER=$1
	echo "$FUNCNAME $MYMASTER"
}

ipa_install_client()
{
	local MYMASTER=$1
	echo "$FUNCNAME $MYMASTER"
}

ipa_connect_replica()
{
	local REP1=$1
	local REP2=$2
	
	rlLog "$FUNNAME $REP1 $REP2"
}	
