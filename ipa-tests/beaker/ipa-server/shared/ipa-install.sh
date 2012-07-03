#!/bin/bash
### WORK IN PROGRESS...NOT READY FOR USE YET

# ROLE=STAR1
# ROLE=STAR2
# ROLE=TREEA1
# ROLE=TREEB1
# ROLE=TREEC1
# ROLE=TREEC2
# ROLE=CHAIN1
# ROLE=SQUARE1
# ROLE=TRIANGLE1
# ROLE=MASTER, SLAVE
# ROLE=MASTER1, REPLICA1, REPLICA2
#      REPLICA1_1, REPLICA1_2
# ROLE=MASTER2, REPLICA2, REPLICA2
#      REPLICA2_1, REPLICA2_2
#  
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="MASTER1">
#   <params> <param name="TOPO" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA1_1">
#   <params> <param name="TOPO" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA1_2">
#   <params> <param name="TOPO" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA1_3">
#   <params> <param name="TOPO" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA1_4">
#   <params> <param name="TOPO" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA1_5">
#   <params> <param name="TOPO" value="star"/> <param name="DOM" value="chicago.testrelm.com"/> </params>
#
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="MASTER2">
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA2_1">
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="REPLICA2_2">
#
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="STAR1">
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="STAR1">
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="STAR1">
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="STAR1">
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="STAR1">
# <task name="/CoreOS/ipa-server/acceptance/ipa-nis-integration" role="STAR1">
#

#MASTER=MASTER1
#SLAVE="REPLICA1 thru REPLICAN"
#CLIENT=CLIENT1

ipa_install_envcleanup() {
	for i in $(seq 1 10); do
		unset BEAKERSLAVE$i
		unset BEAKERSLAVE${i}_IP
		unset BEAKERREPLICA$i
		unset BEAKERREPLICA${i}_IP
		unset SLAVE$i
		unset REPLICA$i
		unset MASTER
		unset BEAKERMASTER_IP
	done
}

ipa_install_parse_servers() {
	# Figure out which method to use for parsing servers lists
	if   [ -n "$MASTER" -a -n "$SLAVE" ]; then
		ipa_install_parse_servers_1
	elif [ -n "$MASTER" -a -n "$REPLICA" ]; then
		ipa_install_parse_servers_2
	elif [ -n "$MASTER1" -a -n "$REPLICA1" ]; then
		ipa_install_parse_servers_3
	else
		ipa_install_parse_servers_default
	fi
}

ipa_install_parse_servers_default() {
	ipa_install_parse_servers_1
}

############ ipa_install_parse_servers_1 ##################
### Supports the following ROLE types:
### MASTER - only 1...if more, it will strip and keep only the first.
### SLAVE - supports multiple in a list.  Will create SLAVE# and BEAKERSLAVE# vars.
### CLIENT - only 1...if more, it will strip and keep only the first.
### CLIENT2 - only 1...if more, it will strip and keep only the first.

ipa_install_parse_servers_1() {
	# MASTER
	export MASTER=$(echo $MASTER|awk '{print $1}')
	export BEAKERMASTER=$MASTER
	if [ -n "$MASTER" ]; then
		export BEAKERMASTER_IP=$(dig +short $MASTER)
	fi
	if [ "$(hostname -s)" = "$(echo $MASTER|cut -f1 -d.)" ]; then 
		export MYROLE=MASTER
	fi

	# REPLICA(S)
	I=0
	export SLAVE="$SLAVE"
	export REPLICA="$SLAVE"
	for s in $SLAVE; do
		I=$(( I += 1 ))
		export SLAVE${I}=$s
		export BEAKERSLAVE${I}=$s
		if [ -n "$s" ]; then
			export BEAKERSLAVE${I}_IP=$(dig +short $s)
		fi

		export REPLICA${I}=$s
		export BEAKERREPLICA${I}=$s
		if [ -n "$s" ]; then
			export BEAKERREPLICA${I}_IP=$(dig +short $s)
		fi
		
		if [ "$(hostname -s)" = "$(echo $SLAVE${I}|cut -f1 -d.)" ]; then 
			export MYROLE=SLAVE${I}	
		fi
	done
	export BEAKERSLAVE=$BEAKERSLAVE1
	export BEAKERSLAVE_IP=$BEAKERSLAVE1_IP

	# CLIENT(S)
	export CLIENT=$(echo $CLIENT|awk '{print $1}')
	export BEAKERCLIENT=$CLIENT
	if [ -n "$CLIENT" ]; then
		export BEAKERCLIENT_IP=$(dig +short $CLIENT)
	fi
	if [ "$(hostname -s)" = "$(echo $CLIENT|cut -f1 -d.)" ]; then 
		export MYROLE=CLIENT
	fi
	
	export CLIENT2=$(echo $CLIENT2|awk '{print $1}')
	export BEAKERCLIENT2=$CLIENT2
	if [ -n "$CLIENT2" ]; then
		export BEAKERCLIENT2_IP=$(dig +short $CLIENT2)
	fi
	if [ "$(hostname -s)" = "$(echo $CLIENT2|cut -f1 -d.)" ]; then 
		export MYROLE=CLIENT2
	fi
	
	echo "export MASTER=$MASTER" >> /dev/shm/env.sh
	echo "export SLAVE=\"$SLAVE\"" >> /dev/shm/env.sh
	echo "export REPLICA=\"$SLAVE\"" >> /dev/shm/env.sh
	echo "export CLIENT=$CLIENT"  >> /dev/shm/env.sh
	echo "export CLIENT2=$CLIENT2" >> /dev/shm/env.sh
}

############ ipa_install_parse_servers_2 ##################
### Supports the following ROLE types:
### MASTER - only 1...if more, it will strip and keep only the first.
### REPLICA - supports multiple in a list.  Will create SLAVE# and BEAKERSLAVE# vars.
### CLIENT - supports multiple in a list.  Will create CLIENT# and BEAKERCLIENT# vars.

ipa_install_parse_servers_2() {
	# MASTER
	export MASTER=$(echo $MASTER|awk '{print $1}')
	export BEAKERMASTER=$MASTER
	if [ -n "$MASTER" ]; then
		export BEAKERMASTER_IP=$(dig +short $MASTER)
	fi
	if [ "$(hostname -s)" = "$(echo $MASTER|cut -f1 -d.)" ]; then 
		MYROLE=MASTER
	fi

	# REPLICA(S)
	I=0
	export SLAVE="$REPLICA"
	export REPLICA="$REPLICA"
	for r in "$REPLICA"; do
		I=$(( I += 1 ))
		export REPLICA${I}=$r
		export BEAKERREPLICA${I}=$r
		if [ -n "$r" ]; then
			export BEAKERREPLICA${I}_IP=$(dig +short $r)
		fi

		export SLAVE${I}=$r
		export BEAKERSLAVE${I}=$r
		if [ -n "$r" ]; then
			export BEAKERSLAVE${I}_IP=$(dig +short $r)
		fi
		if [ "$(hostname -s)" = "$(echo $REPLICA${I}|cut -f1 -d.)" ]; then
			MYROLE=REPLICA${I}
		fi
	done
	# May need to uncomment this for backwards compatibility
	#export BEAKERSLAVE=$BEAKERSLAVE1
	#export BEAKERSLAVE_IP=$BEAKERSLAVE1_IP

	# CLIENT(S)
	I=0
	for c in $CLIENT; do
		I=$(( I += 1 ))
		export CLIENT${I}=$(echo $c|awk '{print $1}')
		export BEAKERCLIENT${I}=$c
		if [ -n "$c" ]; then 
			export BEAKERCLIENT${I}_IP=$(dig +short $c)
		fi
		if [ "$(hostname -s)" = "$(echo $CLIENT${I}|cut -f1 -d.)" ]; then
			export MYROLE=CLIENT${I}
		fi
	done

	echo "export MASTER=$MASTER" >> /dev/shm/env.sh
	echo "export SLAVE=\"$SLAVE\"" >> /dev/shm/env.sh
	echo "export REPLICA=\"$REPLICA\"" >> /dev/shm/env.sh
	echo "export CLIENT=\"$CLIENT\""  >> /dev/shm/env.sh
}

############ ipa_install_parse_servers_3 ##################
### Supports the following ROLE types:
### MASTER# - only 1...if more, it will strip and keep only the first.
### REPLICA# - supports multiple in a list.  Will create SLAVE# and BEAKERSLAVE# vars.
### CLIENT# - supports multiple in a list.  Will create CLIENT# and BEAKERCLIENT# vars.
### # above used to represent number for Environment.  This is the format that will
### # support multiple domains

ipa_install_parse_servers_3() {
	I=1
	while test -n "$(eval echo $(echo \$MASTER${I}))"; do
		echo "ENVIRONMENT ${I}"

		# MASTER
		M=$(eval echo $(echo \$MASTER${I})|awk '{print $1}')
		export MASTER${I}=$M
		export BEAKERMASTER${I}=$M
		if [ -n "$MASTER${I}" ]; then
			export BEAKERMASTER${I}_IP=$(dig +short $M)
		fi

		# REPLICA(S)
		J=0
		export SLAVE="$REPLICA1"
		export REPLICA="$REPLICA1"
		for r in $(eval echo $(echo \$REPLICA${I})); do
			J=$(( J += 1 ))
			export REPLICA${I}_${J}=$r
			export BEAKERREPLICA${I}_${J}=$r
			if [ -n "$r" ]; then
				export BEAKERREPLICA${I}_${J}_IP=$(dig +short $r)
			fi

			export SLAVE${I}_${J}=$r
			export BEAKERSLAVE${I}_${J}=$r
			if [ -n "$r" ]; then
				export BEAKERSLAVE${I}_${J}_IP=$(dig +short $r)
			fi
		done
		# May need to uncomment this for backwards compatibility
		#export BEAKERSLAVE=$BEAKERSLAVE1
		#export BEAKERSLAVE_IP=$BEAKERSLAVE1_IP

		# CLIENT(S)
		J=0
		for c in $(eval echo $(echo \$CLIENT${I})); do
			J=$(( J += 1 ))
			export CLIENT${I}_${J}=$(echo $c|awk '{print $1}')
			export BEAKERCLIENT${I}_${J}=$c
			if [ -n "$c" ]; then
				export BEAKERCLIENT${I}_${J}_IP=$(dig +short $c)
			fi
		done
		I=$(( I += 1 ))
	done	

	echo "export MASTER=$MASTER1" >> /dev/shm/env.sh
	echo "export SLAVE=\"$REPLICA1\"" >> /dev/shm/env.sh
	echo "export REPLICA=\"$REPLICA1\"" >> /dev/shm/env.sh
	echo "export CLIENT=\"$CLIENT1\""  >> /dev/shm/env.sh
}

ipa_install_topo_star() {
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_star_master - "
		if [ "$MYROLE" = "MASTER" ]; then
			ipa_install_master
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.0' -m $BEAKERMASTER"
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.0' $BEAKERMASTER"
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_star_replica1 - "
		if [ "$MYROLE" = "REPLICA" ]; then
			ipa_install_replica $MASTER
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.1' -m $BEAKERREPLICA1"
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.1' $BEAKERREPLICA1"
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_star_replica2 - "
		if [ "$MYROLE" = "REPLICA2" ]; then
			ipa_install_replica $MASTER
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.2' -m $BEAKERREPLICA2"
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.2' $BEAKERREPLICA2"
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_star_replica3 - "
		if [ "$MYROLE" = "REPLICA3" ]; then
			ipa_install_replica $MASTER
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.3' -m $BEAKERREPLICA3"
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.3' $BEAKERREPLICA3"
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_star_replica4 - "
		if [ "$MYROLE" = "REPLICA4" ]; then
			ipa_install_replica $MASTER
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.4' -m $BEAKERREPLICA4"
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.4' $BEAKERREPLICA4"
		fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa_install_topo_star_replica5 - "
		if [ "$MYROLE" = "REPLICA5" ]; then
			ipa_install_replica $MASTER
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.5' -m $BEAKERREPLICA5"
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.5' $BEAKERREPLICA5"
		fi
	rlPhaseEnd
}

ipa_install_master() 
{
	rlPhaseStartTest "ipa_install_master - "
		rlRun "env"
	rlPhaseEnd	
}

