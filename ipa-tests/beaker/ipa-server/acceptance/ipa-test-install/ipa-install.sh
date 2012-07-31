#!/bin/bash
### WORK IN PROGRESS...NOT READY FOR USE YET...
### almost ready for basic testing...07/17/2012

#  
# ROLE=MASTER, SLAVE, CLIENT, CLIENT2
# ROLE=MASTER_env2, REPLICA_env2, CLIENT_env2
# 
# <task name="/CoreOS/ipa-server/acceptance/ipa-test-install" role="MASTER">
#   <params> <param name="TOPO1" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-test-install" role="REPLICA">
#   <params> <param name="TOPO1" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-test-install" role="REPLICA">
#   <params> <param name="TOPO1" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-test-install" role="REPLICA">
#   <params> <param name="TOPO1" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-test-install" role="REPLICA">
#   <params> <param name="TOPO1" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/ipa-test-install" role="REPLICA">
#   <params> <param name="TOPO1" value="star"/> </params>
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
		unset ${!TOPO*}
	done
}

ipa_install_set_vars() {

	# First let's normalize the data to use <ROLE>_env<NUM> variables:
	[ -n "$MASTER"  -a -z "$MASTER_env1"  ] && export MASTER_env1="$MASTER"
	[ -n "$SLAVE"   -a -z "$REPLICA_env1" ] && export REPLICA_env1="$SLAVE"
	[ -n "$REPLICA" -a -z "$REPLICA_env1" ] && export REPLICA_env1="$REPLICA"
	[ -n "$CLIENT"  -a -z "$CLIENT_env1"  ] && export CLIENT_env1="$CLIENT"
	#[ -n "$CLIENT2" -a -n "$SLAVE" -a -z "$CLIENT2_env1" ] && \
	[ -n "$CLIENT2" -a -z "$CLIENT2_env1" ] && \
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
		export BEAKERCLIENT_env${I}="$(eval echo \$CLIENT_env${I})"
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
	echo "export SLAVE=\"$REPLICA_env1\"" >> /dev/shm/env.sh
	echo "export REPLICA=\"$REPLICA_env1\"" >> /dev/shm/env.sh
	echo "export CLIENT=$CLIENT1_env1" >> /dev/shm/env.sh
	echo "export CLIENT2=$CLIENT2_env1" >> /dev/shm/env.sh

	### Set OS/YUM/RPM related variables here
	if [ $(grep Fedora /etc/redhat-release|wc -l) -gt 0 ]; then
		export DISTRO="Fedora"
		export IPA_SERVER_PACKAGES="freeipa-server"
		export IPA_CLIENT_PACKAGES="freeipa-admintools freeipa-client"
		export YUM_OPTIONS="--disablerepo=updates-testing"
	else
		export DISTRO="RedHat"
		export IPA_SERVER_PACKAGES="ipa-server"
		export IPA_CLIENT_PACKAGES="ipa-admintools ipa-client"
		export YUM_OPTIONS=""
	fi

	if [ -n "${IPADEBUG}" -o -f /tmp/IPADEBUG ]; then 
		IPADEBUG=1
	fi
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
	if [ -z "$MYENV" ]; then
		export MYENV=1
	fi

	rlPhaseStartTest "ipa_install_topo_default_envsetup - Set some base variables"
		rlLog
		MYBM1=$(eval echo \$BEAKERMASTER_env${MYENV})
		MYBRS=$(eval echo \$BEAKERREPLICA_env${MYENV})
		MYBCS=$(eval echo \$BEAKERCLIENT_env${MYENV})
	rlPhaseEnd	
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_default_master - install Master in Default Topology"
		if [ "$(hostname -s)" = "$(echo $MYBM1|cut -f1 -d.)" ]; then
			ipa_install_master
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBM1.0' -m $MYBM1"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBM1.0'  $MYBM1"	
		fi
	rlPhaseEnd
	
	for MYBR1 in $MYBRS; do
		TESTORDER=$(( TESTORDER += 1 ))
		rlPhaseStartTest "ipa_install_topo_default_replica - install Replica1 in Default Topology - $MYBR1"
			if [ "$(hostname -s)" = "$(echo $MYBR1|cut -f1 -d.)" ]; then
				ipa_install_replica $MYBM1
				rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR1.1' -m $MYBR1"	
			else
				rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR1.1'  $MYBR1"
			fi
		rlPhaseEnd
	done

	for MYBC1 in $MYBCS; do
		TESTORDER=$(( TESTORDER += 1 ))
		rlPhaseStartTest "ipa_install_topo_default_client - install Client1 in Default Topology - $MYBC1"
			if [ "$(hostname -s)" = "$(echo $MYBC1|cut -f1 -d.)" ]; then
				ipa_install_client $MYBM1
				rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBC1.1' -m $MYBC1"
			else
				rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBC1.1' $MYBC1"
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
	if [ -z "$MYENV" ]; then
		export MYENV=1
	fi

	rlPhaseStartTest "ipa_install_topo_star_envsetup - Make sure enough Replicas are defined"
		if [ $(eval echo \$REPLICA_env${MYENV}|wc -w) -lt 5 ]; then
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
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_star_master - install Master in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBM1|cut -f1 -d.)" ]; then
			ipa_install_master
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBM1.0' -m $MYBM1"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBM1.0'  $MYBM1"	
		fi
	rlPhaseEnd
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_star_replica1 - install Replica1 in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR1|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR1.1' -m $MYBR1"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR1.1'  $MYBR1"	
		fi
	rlPhaseEnd
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_star_replica2 - install Replica2 in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR2|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR2.2' -m $MYBR2"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR2.2'  $MYBR2"	
		fi
	rlPhaseEnd
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_star_replica3 - install Replica3 in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR3|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR3.3' -m $MYBR3"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR3.3'  $MYBR3"	
		fi
	rlPhaseEnd
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_star_replica4 - install Replica4 in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR4|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR4.0' -m $MYBR4"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR4.0'  $MYBR4"	
		fi
	rlPhaseEnd
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_star_replica5 - install Replica5 in Star Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR5|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR5.0' -m $MYBR5"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR5.0'  $MYBR5"	
		fi
	rlPhaseEnd

	# Balance clients across all nodes
	MYSERVERS="$MYBM1 $MYBR1 $MYBR2 $MYBR3 $MYBR4 $MYBR5"
	MYCLIENTS=$(eval echo \$BEAKERCLIENT_env${MYENV})
	CNUM=0
	SNUM=0
	SMAX=$(echo $MYSERVERS|wc -w)
	CMAX=$(echo $MYCLIENTS|wc -w)
	for C in $MYCLIENTS; do
		TESTORDER=$(( TESTORDER += 1 ))
		CNUM=$(( CNUM += 1 ))
		if [ $SNUM -eq $SMAX ]; then	
			SNUM=0
		fi
		SNUM=$(( SNUM += 1 ))
		CS=$(echo "$MYSERVERS"|awk "{print \$$SNUM}")
		if [ "$(hostname -s)" = "$(echo $C|cut -f1 -d.)" ]; then
			ipa_install_client $CS
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$C.0' -m $C"
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$C.0' $C"
		fi
	done
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
	if [ -z "$MYENV" ]; then
		export MYENV=1
	fi

	rlPhaseStartTest "ipa_install_topo_tree1_envsetup - Make sure enough Replicas are defined"
		if [ $(eval echo \$REPLICA_env${MYENV}|wc -w) -lt 5 ]; then
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
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_tree1_master - install Master in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBM1|cut -f1 -d.)" ]; then
			ipa_install_master
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBM1.0' -m $MYBM1"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBM1.0'  $MYBM1"	
		fi
	rlPhaseEnd
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_tree1_replica1 - install Replica1 in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR1|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR1.1' -m $MYBR1"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR1.1'  $MYBR1"	
		fi
	rlPhaseEnd
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_tree1_replica2 - install Replica2 in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR2|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBM1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR2.2' -m $MYBR2"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR2.2'  $MYBR2"	
		fi
	rlPhaseEnd
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_tree1_replica3 - install Replica3 in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR3|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBR1
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR3.3' -m $MYBR3"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR3.3'  $MYBR3"	
		fi
	rlPhaseEnd
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_tree1_replica4 - install Replica4 in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR4|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBR2
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR4.4' -m $MYBR4"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR4.4'  $MYBR4"	
		fi
	rlPhaseEnd
	
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_tree1_replica5 - install Replica5 in Tree1 Topology"
		if [ "$(hostname -s)" = "$(echo $MYBR5|cut -f1 -d.)" ]; then
			ipa_install_replica $MYBR2
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR5.5' -m $MYBR5"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR5.5'  $MYBR5"	
		fi
	rlPhaseEnd

	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_topo_tree1_connect_rep4_and_rep5 - Create replication agreement between Replica4 and Replica5"
		if [ "$(hostname -s)" = "$(echo $MYBR4|cut -f1 -d.)" ]; then
			ipa_connect_replica $MYBR4 $MYBR5
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$MYBR4.6' -m $MYBR4"	
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$MYBR4.6'  $MYBR4"	
		fi
	rlPhaseEnd

	# Balance clients across all nodes
	MYSERVERS="$MYBM1 $MYBR1 $MYBR2 $MYBR3 $MYBR4 $MYBR5"
	MYCLIENTS=$(eval echo \$BEAKERCLIENT_env${MYENV})
	CNUM=0
	SNUM=0
	SMAX=$(echo $MYSERVERS|wc -w)
	CMAX=$(echo $MYCLIENTS|wc -w)
	for C in $MYCLIENTS; do
		TESTORDER=$(( TESTORDER += 1 ))
		CNUM=$(( CNUM += 1 ))
		if [ $SNUM -eq $SMAX ]; then	
			SNUM=0
		fi
		SNUM=$(( SNUM += 1 ))
		CS=$(echo "$MYSERVERS"|awk "{print \$$SNUM}")
		if [ "$(hostname -s)" = "$(echo $C|cut -f1 -d.)" ]; then
			ipa_install_client $CS
			rlRun "rhts-sync-set -s '$TESTORDER.$FUNCNAME.$C.0' -m $C"
		else
			rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME.$C.0' $C"
		fi
	done
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
	case $(eval echo \$TOPO${MYENV}) in 
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

ipa_install_prep() 
{
	rlLog "$FUNCNAME"
	if [ -z "$IPA_SERVER_PACKAGES" ]; then
		rlFail "IPA_SERVER_PACKAGES variable not set.  Run ipa_install_set_vars first"
		return 1
	fi

	tmpout=/tmp/error_msg.out
	currenteth=$(route | grep ^default | awk '{print $8}')
	ipaddr=$(ip -o -4 addr show $currenteth|awk '{print $4}'|awk -F/ '{print $1}')
	ipv6addr=$(ip -o -6 addr show $currenteth|awk '{print $4}'|awk -F/ '{print $1}')
	hostname=$(hostname)
	hostname_s=$(hostname -s)
	if [ "$IPv6SETUP" = "TRUE" ]; then 
		rrtype="AAAA"
		netaddr="$ipv6addr"
	else	
		rrtype=""
		netaddr="$ipaddr"
	fi

	rlRun "yum clean all"
	rlRun "yum -y install bind expect krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl nmap"
	if [ $(echo $MYROLE|grep CLIENT|wc -l) -gt 0 ]; then
		rlRun "yum -y install $YUM_OPTIONS $IPA_CLIENT_PACKAGES"
	else
		rlRun "yum -y install $YUM_OPTIONS $IPA_SERVER_PACKAGES"
	fi
	rlRun "yum -y update"

	# Set time
	rlLog "Stopping ntpd service"
	rlRun "service ntpd stop"
	rlLog "Synchronizing time to $NTPSERVER"
	rlRun "ntpdate $NTPSERVER"

	# Fix /etc/hosts
	cp -af /etc/hosts /etc/hosts.ipabackup
	rlRun "sed -i s/$hostname//g    /etc/hosts"
	rlRun "sed -i s/$hostname_s//g  /etc/hosts"
	rlRun "sed -i /$ipaddr/d    /etc/hosts"
	if [ -n "$ipv6addr" ]; then 
		for i6 in $(echo $ipv6addr); do
			rlRun "sed -i '/$i6/d'  /etc/hosts"
		done
	fi
	rlRun "echo \"$netaddr $hostname_s.$DOMAIN $hostname_s\" >> /etc/hosts"
	
	# Other IPv6 fixes
	if [ "$IPv6SETUP" = "TRUE" ] ; then
		rlRun "sed -i \"s/10.14.63.12/$ipv6addr/g\" /dev/shm/env.sh"
		. /dev/shm/env.sh
		rlRun "/sbin/ip -4 addr del $ipaddr dev $currenteth"
	fi

	# Fix hostname
	if [ ! -f /etc/sysconfig/network-ipabackup ]; then
		rlRun "cp /etc/sysconfig/network /etc/sysconfig/network-ipabackup"
	fi
	rlRun "hostname $hostname_s.$DOMAIN"
	rlRun "sed -i \"s/HOSTNAME=.*$/HOSTNAME=$hostname_s.$DOMAIN/\" /etc/sysconfig/network"
	. /etc/sysconfig/network
	
	# Fix /etc/resolv.conf
	# we use the RRTYPE here in $rrtype to determine if IPv4 vs IPv6 address needed.
	if [ ! -f /etc/resolv.conf.ipabackup ]; then
		rlRun "cp /etc/resolv.conf /etc/resolv.conf.ipabackup"
	fi
	if [ $(echo $MYROLE | egrep "REPLICA|CLIENT"|wc -l) -gt 0 ]; then
		for ns in $(eval echo \$BEAKERMASTER_env${MYENV}) $(eval echo \$BEAKERREPLICA_env${MYENV}); do
			nsaddr=$(dig +short $ns $rrtype)
			rlRun "echo \"nameserver $nsaddr\" >> /etc/resolv.conf.new"
		done
		rlRun "sed -i s/^nameserver/#nameserver/g /etc/resolv.conf"
		rlRun "cat /etc/resolv.conf.new >> /etc/resolv.conf"
		rlRun "rm -f /etc/resolv.conf.new"
	fi
		
	# Disable Firewall
	rlRun "service iptables stop"
	rlRun "chkconfig iptables off"
	rlRun "service ip6tables stop"
	rlRun "chkconfig ip6tables off"

	#if [ $(rpm -qa | grep ipa-server | wc -l) -eq 0 ]; then
	#	rlFail "No ipa-server packages found"
	#fi

	# setup SSH keys
	## Adding code from SetUpAuthKeys
	[ ! -d /root/.ssh/ ] && rlRun "mkdir -p /root/.ssh"
	diff -q /dev/shm/id_rsa_global.pub /root/.ssh/id_rsa > /dev/null 2>&1
	if [ $? -eq 1 ]; then	
		cp /dev/shm/id_rsa_global /root/.ssh/id_rsa
		cp /dev/shm/id_rsa_global.pub /root/.ssh/id_rsa.pub
		for var in ${!BEAKERMASTER_env*} ${!BEAKERREPLICA_env*} ${!BEAKERCLIENT_env*}; do
			for server in $(eval echo \$$var); do
				sed -e s/localhost/$server/g /dev/shm/id_rsa_global.pub >> /root/.ssh/authorized_keys
				#AddToKnownHosts $server
				ssh-keygen -R $server
				ssh-keyscan $server >> /root/.ssh/known_hosts
			done
		done
	fi
}

ipa_install_master()
{
	tmpout=/tmp/error_msg.out
	rlPhaseStartTest "ipa_install_master - Install IPA Master Server"
		rlLog "$FUNCNAME"
	
		ipa_install_prep
		
		for PKG in $IPA_SERVER_PACKAGES; do
			rlAssertRpm $PKG
		done
		
		rlRun "ipa-server-install $IPAOPTIONS --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"

		if [ $IPADEBUG ]; then
			if [ -f /usr/share/ipa/bind.named.conf.template ]; then
				rlLog "Forcing debug logging in named.conf template"
				sed -i 's/severity dynamic/severity debug 10/' /usr/share/ipa/bind.named.conf.template
			fi
			DATE=$(date +%Y%m%d-%H%M%S)	
			INSTANCE=$(echo $RELM|sed 's/\./-/g')
			rlLog "DEBUG selected.  submitting logs"
			if [ -f /var/log/ipaserver-install.log ]; then
				cp /var/log/ipaserver-install.log /var/log/ipaserver-install.log.$DATE
				rhts-submit-log -l /var/log/ipaserver-install.log.$DATE	
			fi
			if [ -f /var/log/ipaclient-install.log ]; then
				cp /var/log/ipaclient-install.log /var/log/ipaclient-install.log.$DATE
				rhts-submit-log -l /var/log/ipaclient-install.log.$DATE	
			fi
			if [ -f /var/log/dirsrv/slapd-$INSTANCE/errors ]; then
				cp /var/log/dirsrv/slapd-$INSTANCE/errors /var/log/dirsrv/slapd-$INSTANCE/errors.$DATE
				rhts-submit-log -l /var/log/dirsrv/slapd-$INSTANCE/errors.$DATE
			fi
			if [ -f /var/log/dirsrv/slapd-$INSTANCE/access ]; then
				cp /var/log/dirsrv/slapd-$INSTANCE/access /var/log/dirsrv/slapd-$INSTANCE/access.$DATE
				rhts-submit-log -l /var/log/dirsrv/slapd-$INSTANCE/access.$DATE
			fi
		fi	
	rlPhaseEnd
}

ipa_install_replica()
{
	local MYMASTER=$1
	local MYREVNET=$(hostname -i|awk -F. '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
	rlPhaseStartTest "ipa_install_replica - Install IPA Replica Server"
		rlLog "$FUNCNAME $MYMASTER"

		ipa_install_prep

		for PKG in $IPA_SERVER_PACKAGES; do
			rlAssertRpm $PKG
		done
	
		rlLog "RUN ipa-replica-prepare on $MYMASTER"
		rlRun "ssh root@$MYMASTER \"echo $ADMINPW|kinit admin; ipa-replica-prepare -p $ADMINPW --ip-address=$ipaddr $hostname_s.$DOMAIN\" ; service named restart"
		# named can take a little time to update sometimes?
		rlRun "sleep 60"

		rlLog "RUN sftp to get gpg file"
		rlRun "sftp root@$MYMASTER:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg /dev/shm/"

		# Do we need DelayUntilMasterReady???
		rlLog "RUN ipa-replica-install"
		rlRun "ipa-replica-install $IPAOPTIONS -U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
	rlPhaseEnd
}

ipa_install_client()
{
	local MYMASTER=$1
	rlPhaseStartTest "ipa_install_client - Install IPA Client"
		rlLog "$FUNCNAME $MYMASTER"

		ipa_install_prep

		for PKG in $IPA_CLIENT_PACKAGES; do
			rlAssertRpm $PKG
		done

		rlLog "RUN ipa dns-add for client?"
		rlLog "RUN ipa-client-install"
		rlRun "ipa-client-install $IPAOPTIONS -U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$(echo $MYMASTER|cut -f1 -d.).$DOMAIN"
	rlPhaseEnd
}

ipa_connect_replica()
{
	local REP1=$(echo $1|cut -f1 -d.).$DOMAIN
	local REP2=$(echo $2|cut -f1 -d.).$DOMAIN
	
	rlPhaseStartTest "ipa_connect_replica - Create Replication Agreement between two servers"
		rlLog "$FUNCNAME $REP1 $REP2"
	
		rlLog "RUN ipa-replica-manage connect $REP1 $REP2"
		rlRun "ipa-replica-manage -p $ADMINPW connect $REP1 $REP2"
	rlPhaseEnd
}	
