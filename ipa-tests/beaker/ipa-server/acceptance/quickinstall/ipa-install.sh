#!/bin/bash
### WORK IN PROGRESS...NOT READY FOR USE YET...
### almost ready for basic testing...07/17/2012

#  
# ROLE=MASTER, SLAVE, CLIENT, CLIENT2
# ROLE=MASTER_env2, REPLICA_env2, CLIENT_env2
# 
# <task name="/CoreOS/ipa-server/acceptance/quickinstall" role="MASTER">
#   <params> <param name="TOPO1" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/quickinstall" role="REPLICA">
#   <params> <param name="TOPO1" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/quickinstall" role="REPLICA">
#   <params> <param name="TOPO1" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/quickinstall" role="REPLICA">
#   <params> <param name="TOPO1" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/quickinstall" role="REPLICA">
#   <params> <param name="TOPO1" value="star"/> </params>
# <task name="/CoreOS/ipa-server/acceptance/quickinstall" role="REPLICA">
#   <params> <param name="TOPO1" value="star"/> </params>
#

ipa_install_envcleanup()
{
    for i in $(seq 1 10); do
        unset ${!BEAKERCLIENT*}
        unset ${!BEAKERSLAVE*}
        unset ${!BEAKERREPLICA*}
        unset ${!CLIENT*}
        unset ${!SLAVE*}
        unset ${!REPLICA*}
        unset ${!MASTER*}
        unset ${!BEAKERMASTER*}
        unset ${!MYROLE*}
        unset ${!MYENV*}
        unset ${!TOPO*}
        unset ${!NEWREPLICA*}
        unset ${!NEWCLIENT*}
    done
}

ipa_add_to_env()
{
    local VAR1=$1
    local VAL1=$2

    if [ -z "$VAR1" ]; then
        echo "CANNOT run $FUNCNAME with no VAR name provided."
        echo "Usage: $FUNCNAME <VARNAME> <VALUE>"
        return 1
    fi

    sed -i "/^export $VAR1=/d" /opt/rhqa_ipa/env.sh
    echo "export $VAR1=\"$VAL1\"" >> /opt/rhqa_ipa/env.sh
    . /opt/rhqa_ipa/env.sh
}

ipa_install_set_vars()
{
    # Initialize Global TESTCOUNT variable
    # TESTCOUNT=1

    # First let's normalize the data to use <ROLE>_env<NUM> variables:
    [ -n "$MASTER"  -a -z "$MASTER_env1"  ] && export MASTER_env1="$MASTER"
    [ -n "$SLAVE"   -a -z "$REPLICA_env1" ] && export REPLICA_env1="$SLAVE"
    [ -n "$REPLICA" -a -z "$REPLICA_env1" ] && export REPLICA_env1="$REPLICA"
    [ -n "$CLIENT"  -a -z "$CLIENT_env1"  ] && export CLIENT_env1="$CLIENT"
    #[ -n "$CLIENT2" -a -n "$SLAVE" -a -z "$CLIENT2_env1" ] && \
    [ -n "$CLIENT2" -a -z "$CLIENT2_env1" ] && \
        export CLIENT_env1=$(echo $CLIENT_env1 $CLIENT2)
    
    if [ "$IPv6SETUP" = "TRUE" ]; then 
        rrtype="AAAA"
    else    
        rrtype=""
    fi

    # Try to set our ENV first.  Will confirm/fix this later as well for full confirmation
    MYENV=$(env|grep $(hostname -s)|grep -v HOSTNAME|egrep \
        "MASTER|REPLICA|SLAVE|CLIENT"|grep "_env"|sed \
        's/^.*_env\([0-9]*\)=.*$/\1/'|head -1)

    # Process MASTER variables
    I=1
    while test -n "$(eval echo \$MASTER_env${I})"; do
        echo "Parsing MASTER Variables for Environment ${I}"
        if [ $I -gt 1 ]; then
            THISDOMAIN=$(echo $DOMAIN|sed "s/^\([^\.]*\)/\1$I/g")
        else
            THISDOMAIN=$DOMAIN
        fi
        M=$(eval echo \$MASTER_env${I}|awk '{print $1}')
        ipa_add_to_env "MASTER_env${I}" "$(echo $M|cut -f1 -d.).$THISDOMAIN"
        ipa_add_to_env "BEAKERMASTER_env${I}" "$M"
        export BEAKERMASTER_IP_env${I}=$(dig +short $M $rrtype|tail -1)
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
        if [ $I -gt 1 ]; then
            THISDOMAIN=$(echo $DOMAIN|sed "s/^\([^\.]*\)/\1$I/g")
        else
            THISDOMAIN=$DOMAIN
        fi
        export BEAKERREPLICA_env${I}="$(eval echo \$REPLICA_env${I})"
        for R in $(eval echo \$REPLICA_env${I}); do
            ipa_add_to_env "REPLICA${J}_env${I}" "$(echo $R|cut -f1 -d.).$THISDOMAIN"
            ipa_add_to_env "BEAKERREPLICA${J}_env${I}" "$R"
            export BEAKERREPLICA${J}_IP_env${I}=$(dig +short $R $rrtype|tail -1)
            if [ "$(hostname -s)" = "$(echo $R|cut -f1 -d.)" ]; then
                export MYROLE=REPLICA${J}_env${I}
                export MYENV=${I}
            fi
            export NEWREPLICAS="$NEWREPLICAS $(echo $R|cut -f1 -d.).$THISDOMAIN"
            export NEWREPLICAS=$(echo $NEWREPLICAS)
            J=$(( J += 1 ))
        done
        export REPLICA_env${I}="$NEWREPLICAS"
        I=$(( I += 1 ))
        unset NEWREPLICAS
    done

    # Process CLIENT variables
    I=1
    while test -n "$(eval echo \$CLIENT_env${I})"; do
        J=1
        echo "Parsing CLIENT Variables for Environment ${I}"
        if [ $I -gt 1 ]; then
            THISDOMAIN=$(echo $DOMAIN|sed "s/^\([^\.]*\)/\1$I/g")
        else
            THISDOMAIN=$DOMAIN
        fi
        export BEAKERCLIENT_env${I}="$(eval echo \$CLIENT_env${I})"
        for C in $(eval echo \$CLIENT_env${I}); do
            ipa_add_to_env "CLIENT${J}_env${I}" "$(echo $C|cut -f1 -d.).$THISDOMAIN"
            ipa_add_to_env "BEAKERCLIENT${J}_env${I}" "$C"
            export BEAKERCLIENT${J}_IP_env${I}=$(dig +short $C $rrtype|tail -1)
            if [ "$(hostname -s)" = "$(echo $C|cut -f1 -d.)" ]; then
                export MYROLE=CLIENT${J}_env${I}
                export MYENV=${I}
            fi
            export NEWCLIENTS="$NEWCLIENTS $(echo $C|cut -f1 -d.).$THISDOMAIN"
            export NEWCLIENTS=$(echo $NEWCLIENTS)
            J=$(( J += 1 ))
        done
        export CLIENT_env${I}="$NEWCLIENTS"
        I=$(( I += 1 ))
        unset NEWCLIENTS
    done

    # Make sure Simple Vars are set in env.sh for simplicity and
    # backwards compatibility with older tests.  This means no
    # _env<NUM> suffix.
    ipa_add_to_env "MYENV" "${MYENV}"
    ipa_add_to_env "MYROLE" "${MYROLE}"
    ipa_add_to_env "MASTER" "$(eval echo \$MASTER_env${MYENV})"
    ipa_add_to_env "MASTERIP" "$(eval echo \$BEAKERMASTER_IP_env${MYENV})"
    ipa_add_to_env "SLAVE" "$(eval echo \$REPLICA_env${MYENV})"
    ipa_add_to_env "SLAVEIP" "$(eval echo \$BEAKERREPLICA1_IP_env${MYENV})"
    ipa_add_to_env "REPLICA" "$(eval echo \$REPLICA_env${MYENV})"
    ipa_add_to_env "CLIENT" "$(eval echo \$CLIENT1_env${MYENV})"
    ipa_add_to_env "CLIENT2" "$(eval echo \$CLIENT2_env${MYENV})"
    ipa_add_to_env "BEAKERMASTER" "$(eval echo \$BEAKERMASTER_env${MYENV})"
    ipa_add_to_env "BEAKERREPLICA_env${MYENV}" "$(eval echo \$BEAKERREPLICA_env${MYENV})"
    ipa_add_to_env "BEAKERSLAVE" "$(eval echo \$BEAKERREPLICA_env${MYENV})"
    ipa_add_to_env "BEAKERCLIENT" "$(eval echo \$BEAKERCLIENT1_env${MYENV})"
    ipa_add_to_env "BEAKERCLIENT2" "$(eval echo \$BEAKERCLIENT2_env${MYENV})"

    # FIX Env specific vars like RELM, DOMAIN, BASEDN
    if [ $MYENV -gt 1 ]; then 
        NEWRELM=$(echo $RELM|sed "s/^\([^\.]*\)/\1$MYENV/g")
        sed -i "s/RELM=.*$/RELM=$NEWRELM/" /opt/rhqa_ipa/env.sh

        NEWDOMAIN=$(echo $DOMAIN|sed "s/^\([^\.]*\)/\1$MYENV/g")
        sed -i "s/DOMAIN=.*$/DOMAIN=$NEWDOMAIN/" /opt/rhqa_ipa/env.sh

        NEWBASEDN=$(echo $BASEDN|sed "s/^\([^\,]*\)/\1$MYENV/g")
        sed -i "s/BASEDN=.*$/BASEDN=\"$NEWBASEDN\"/" /opt/rhqa_ipa/env.sh
    fi

    ### Set OS/YUM/RPM related variables here
    if [ $(grep Fedora /etc/redhat-release|wc -l) -gt 0 ]; then
        ipa_add_to_env "DISTRO" "Fedora"
        ipa_add_to_env "IPA_SERVER_PACKAGES" "freeipa-server"
        ipa_add_to_env "IPA_CLIENT_PACKAGES" "freeipa-admintools freeipa-client"
        #ipa_add_to_env "YUM_OPTIONS" ""
        ipa_add_to_env "YUM_OPTIONS" "--disablerepo=updates-testing"
    else
        ipa_add_to_env "DISTRO" "RedHat"
        ipa_add_to_env "IPA_SERVER_PACKAGES" "ipa-server"
        if [ $(grep "Red Hat.*5\.[0-9]" /etc/redhat-release|wc -l) -gt 0 ]; then
            ipa_add_to_env "IPA_CLIENT_PACKAGES" "ipa-client"
        else
            ipa_add_to_env "IPA_CLIENT_PACKAGES" "ipa-admintools ipa-client"
        fi
        ipa_add_to_env "YUM_OPTIONS" ""
    fi

    if [ -n "${IPADEBUG}" -o -f /tmp/IPADEBUG ]; then 
        IPADEBUG=1
    fi
        
    . /opt/rhqa_ipa/env.sh

    # Copy ipa-install.sh to /opt/rhqa_ipa 
    # Some tests like install-server-cli like to call the scipt as a library
    rm -f /opt/rhqa_ipa/ipa-install.sh
    cp -a ./ipa-install.sh /opt/rhqa_ipa/.
 
    rlLog "===================== env|sort =========================="
    rlRun "env|sort"
    rlLog "===================== env.sh   =========================="
    rlRun "cat /opt/rhqa_ipa/env.sh"
    rlLog "==============================================="
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
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_default_master - install Master in Default Topology"
        if [ "$(hostname -s)" = "$(echo $MYBM1|cut -f1 -d.)" ]; then
            ipa_install_master
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBM1.0' -m $MYBM1"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBM1.0'  $MYBM1"  
        fi
    rlPhaseEnd
    
    for MYBR1 in $MYBRS; do
        TESTCOUNT=$(( TESTCOUNT += 1 ))
        rlPhaseStartTest "ipa_install_topo_default_replica - install Replica1 in Default Topology - $MYBR1"
            if [ "$(hostname -s)" = "$(echo $MYBR1|cut -f1 -d.)" ]; then
                ipa_install_replica $MYBM1
                rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR1.1' -m $MYBR1"  
            else
                rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR1.1'  $MYBR1"
            fi
        rlPhaseEnd
    done

    for MYBC1 in $MYBCS; do
        TESTCOUNT=$(( TESTCOUNT += 1 ))
        rlPhaseStartTest "ipa_install_topo_default_client - install Client1 in Default Topology - $MYBC1"
            if [ "$(hostname -s)" = "$(echo $MYBC1|cut -f1 -d.)" ]; then
                ipa_install_client $MYBM1
                rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBC1.1' -m $MYBC1"
            else
                rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBC1.1' $MYBC1"
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
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_star_master - install Master in Star Topology"
        if [ "$(hostname -s)" = "$(echo $MYBM1|cut -f1 -d.)" ]; then
            ipa_install_master
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBM1.0' -m $MYBM1"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBM1.0'  $MYBM1"  
        fi
    rlPhaseEnd
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_star_replica1 - install Replica1 in Star Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR1|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBM1
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR1.1' -m $MYBR1"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR1.1'  $MYBR1"  
        fi
    rlPhaseEnd
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_star_replica2 - install Replica2 in Star Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR2|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBM1
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR2.2' -m $MYBR2"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR2.2'  $MYBR2"  
        fi
    rlPhaseEnd
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_star_replica3 - install Replica3 in Star Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR3|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBM1
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR3.3' -m $MYBR3"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR3.3'  $MYBR3"  
        fi
    rlPhaseEnd
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_star_replica4 - install Replica4 in Star Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR4|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBM1
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR4.0' -m $MYBR4"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR4.0'  $MYBR4"  
        fi
    rlPhaseEnd
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_star_replica5 - install Replica5 in Star Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR5|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBM1
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR5.0' -m $MYBR5"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR5.0'  $MYBR5"  
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
        TESTCOUNT=$(( TESTCOUNT += 1 ))
        CNUM=$(( CNUM += 1 ))
        if [ $SNUM -eq $SMAX ]; then    
            SNUM=0
        fi
        SNUM=$(( SNUM += 1 ))
        CS=$(echo "$MYSERVERS"|awk "{print \$$SNUM}")
        if [ "$(hostname -s)" = "$(echo $C|cut -f1 -d.)" ]; then
            ipa_install_client $CS
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$C.0' -m $C"
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$C.0' $C"
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
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree1_master - install Master in Tree1 Topology"
        if [ "$(hostname -s)" = "$(echo $MYBM1|cut -f1 -d.)" ]; then
            ipa_install_master
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBM1.0' -m $MYBM1"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBM1.0'  $MYBM1"  
        fi
    rlPhaseEnd
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree1_replica1 - install Replica1 in Tree1 Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR1|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBM1
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR1.1' -m $MYBR1"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR1.1'  $MYBR1"  
        fi
    rlPhaseEnd
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree1_replica2 - install Replica2 in Tree1 Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR2|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBM1
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR2.2' -m $MYBR2"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR2.2'  $MYBR2"  
        fi
    rlPhaseEnd
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree1_replica3 - install Replica3 in Tree1 Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR3|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBR1
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR3.3' -m $MYBR3"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR3.3'  $MYBR3"  
        fi
    rlPhaseEnd
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree1_replica4 - install Replica4 in Tree1 Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR4|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBR2
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR4.4' -m $MYBR4"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR4.4'  $MYBR4"  
        fi
    rlPhaseEnd
    
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree1_replica5 - install Replica5 in Tree1 Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR5|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBR2
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR5.5' -m $MYBR5"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR5.5'  $MYBR5"  
        fi
    rlPhaseEnd

    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree1_connect_rep4_and_rep5 - Create replication agreement between Replica4 and Replica5"
        if [ "$(hostname -s)" = "$(echo $MYBR4|cut -f1 -d.)" ]; then
            ipa_connect_replica $MYBR4 $MYBR5
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR4.6' -m $MYBR4"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR4.6'  $MYBR4"  
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
        TESTCOUNT=$(( TESTCOUNT += 1 ))
        CNUM=$(( CNUM += 1 ))
        if [ $SNUM -eq $SMAX ]; then    
            SNUM=0
        fi
        SNUM=$(( SNUM += 1 ))
        CS=$(echo "$MYSERVERS"|awk "{print \$$SNUM}")
        if [ "$(hostname -s)" = "$(echo $C|cut -f1 -d.)" ]; then
            ipa_install_client $CS
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$C.0' -m $C"
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$C.0' $C"
        fi
    done
}

######################################################################
# ipa_install_topo_tree2
#            M
#           / \
#          R1  R2
#               \
#                R3
#                 \
#                  R4
# This REQUIRES 4 replicas
######################################################################
ipa_install_topo_tree2() 
{
    if [ -z "$MYENV" ]; then
        export MYENV=1
    fi

    MINREPS=4
    rlPhaseStartTest "ipa_install_topo_tree2_envsetup - Make sure enough Replicas are defined"
        if [ $(eval echo \$REPLICA_env${MYENV}|wc -w) -lt $MINREPS ]; then
            rlFail "Not enough Replicas defined for tree2 topology...skipping"
            rlPhaseEnd
            return 1
        else
            rlPass "Enough Replicas defined for tree2 topology...continuing"
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

    # M
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree2_master - install Master in Tree2 Topology"
        if [ "$(hostname -s)" = "$(echo $MYBM1|cut -f1 -d.)" ]; then
            ipa_install_master
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBM1.0' -m $MYBM1"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBM1.0'  $MYBM1"  
        fi
    rlPhaseEnd
    
    # R1
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree1_replica1 - install Replica1 in Tree1 Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR1|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBM1
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR1.1' -m $MYBR1"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR1.1'  $MYBR1"  
        fi
    rlPhaseEnd
    
    # R2
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree1_replica2 - install Replica2 in Tree1 Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR2|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBM1
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR2.2' -m $MYBR2"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR2.2'  $MYBR2"  
        fi
    rlPhaseEnd
    
    # R3
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree1_replica3 - install Replica3 in Tree1 Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR3|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBR2
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR3.3' -m $MYBR3"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR3.3'  $MYBR3"  
        fi
    rlPhaseEnd
    
    # R4
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "ipa_install_topo_tree1_replica4 - install Replica4 in Tree1 Topology"
        if [ "$(hostname -s)" = "$(echo $MYBR4|cut -f1 -d.)" ]; then
            ipa_install_replica $MYBR3
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$MYBR4.4' -m $MYBR4"  
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$MYBR4.4'  $MYBR4"  
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
        TESTCOUNT=$(( TESTCOUNT += 1 ))
        CNUM=$(( CNUM += 1 ))
        if [ $SNUM -eq $SMAX ]; then    
            SNUM=0
        fi
        SNUM=$(( SNUM += 1 ))
        CS=$(echo "$MYSERVERS"|awk "{print \$$SNUM}")
        if [ "$(hostname -s)" = "$(echo $C|cut -f1 -d.)" ]; then
            ipa_install_client $CS
            rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.$C.0' -m $C"
        else
            rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.$C.0' $C"
        fi
    done
}

ipa_install_envs()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    I=1
    local ENVTESTCOUNT=$TESTCOUNT
    rlPhaseStartTest "ipa_install_envs - Install IPA in all defined Environments sequentially"
        while test -n "$(eval echo \$BEAKERMASTER_env${I})"; do
            RUNMASTER=$(eval echo \$BEAKERMASTER_env${I})
            if [ "$MYENV" != "$I" ]; then
                rlLog "rhts-sync-block -s '$ENVTESTCOUNT.$FUNCNAME.$I.0' $RUNMASTER"
                rlRun "rhts-sync-block -s '$ENVTESTCOUNT.$FUNCNAME.$I.0' $RUNMASTER"
            else
                ipa_install_topo
            fi
            # Now, if we're the MASTER for ENV $I, rhts-sync-set to unblock others...
            if [ "$(hostname -s)" = "$(echo $RUNMASTER|cut -f1 -d.)" ]; then
                rlRun "rhts-sync-set -s '$ENVTESTCOUNT.$FUNCNAME.$MYENV.0' -m $RUNMASTER"
            fi
            I=$(( I += 1 ))
        done
        # Backup /opt/rhqa_ipa/ to /root/dev-shm-backup
        mkdir /root/dev-shm-backup
        cp -a /opt/rhqa_ipa/* /root/dev-shm-backup/.
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
    tree2|TREE2|tree|TREE)
        ipa_install_topo_tree2
        ;;
    *)
        ipa_install_topo_default
        ;;
    esac

}

ipa_install_prep_initVars()
{
    tmpout=/tmp/error_msg.out
    rpm -qa|grep net-tools
    if [ $? -eq 1 ];then
        rlRun "yum install net-tools -y" 
    fi
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
}

ipa_install_prep_pkgInstalls()
{
    rlRun "yum clean all"
    rlRun "yum -y install bind expect krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl nmap"
    rlRun "yum -y install ntp autogen-libopts"
    if [ $(echo $MYROLE|grep CLIENT|wc -l) -gt 0 ]; then
        rlRun "yum -y install nscd httpd curl mod_nss mod_auth_kerb 389-ds-base expect ntpdate"
        rlRun "yum -y install $YUM_OPTIONS $IPA_CLIENT_PACKAGES"
    else
        rlRun "yum -y install $YUM_OPTIONS $IPA_SERVER_PACKAGES"
    fi
    #rlRun "yum -y update"
}

ipa_install_prep_setTime()
{
    rlLog "Stopping ntpd service"
    rlRun "service ntpd stop"
    rlLog "Synchronizing time to $NTPSERVER"
    rlRun "ntpdate $NTPSERVER"
}

fixHostFile()
{
    ipa_install_prep_initVars

    if [ "$USEDNS" != "no" ]; then
        cp -af /etc/hosts /etc/hosts.ipabackup
        rlRun "sed -i s/$hostname//g    /etc/hosts"
        rlRun "sed -i s/$hostname_s//g  /etc/hosts"
        for i in $(echo $ipaddr); do
            rlRun "sed -i /$i/d    /etc/hosts"
        done

        rlRun "echo \"$netaddr $hostname_s.$DOMAIN $hostname_s\" >> /etc/hosts"
    else
        rlLog "USEDNS=no, skipping hosts reconfig"
    fi
    rlRun "cat /etc/hosts"
}

fixHostFileIPv6()
{
    ipa_install_prep_initVars

    if [ "$USEDNS" != "no" ]; then
        cp -af /etc/hosts /etc/hosts.ipabackup
        rlRun "sed -i s/$hostname//g    /etc/hosts"
        rlRun "sed -i s/$hostname_s//g  /etc/hosts"
        for i6 in $(echo $ipv6addr); do
            rlRun "sed -i '/$i6/d'  /etc/hosts"
        done
        rlRun "echo \"$netaddr $hostname_s.$DOMAIN $hostname_s\" >> /etc/hosts"
    else
        rlLog "USEDNS=no, skipping hosts reconfig for IPv6"
    fi
}

fixhostname()
{
    ipa_install_prep_initVars
        
    if [ "$USEDNS" != "no" ]; then
        if [ -f /etc/sysconfig/network ]; then
            if [ ! -f /etc/sysconfig/network-ipabackup ]; then
                rlRun "cp /etc/sysconfig/network /etc/sysconfig/network-ipabackup"
            fi
            rlRun "sed -i \"s/HOSTNAME=.*$/HOSTNAME=$hostname_s.$DOMAIN/\" /etc/sysconfig/network"
            . /etc/sysconfig/network
        fi
        if [ -f /etc/hostname ]; then
            if [ ! -f /etc/hostname-ipabackup ]; then
                rlRun "cp /etc/hostname /etc/hostname-ipabackup"
            fi
            rlRun "echo \"$hostname_s.$DOMAIN\" > /etc/hostname"
        fi
        export HOSTNAME=$hostname_s.$DOMAIN

        rlRun "hostname $hostname_s.$DOMAIN"
    else
        rlLog "USEDNS=no, skipping hostname reconfig"
    fi
}

fixForwarderIPv6()
{
    ipa_install_prep_initVars
    
    rlRun "sed -i \"s/$DNSFORWARD/$ipv6addr/g\" /opt/rhqa_ipa/env.sh"
    . /opt/rhqa_ipa/env.sh
}

rmIPv4addr()
{
    ipa_install_prep_initVars
    
    rlRun "/sbin/ip -4 addr del $ipaddr dev $currenteth"
}

fixResolv()
{
    ipa_install_prep_initVars

    if [ "$USEDNS" != "no" ]; then
        # we use the RRTYPE here in $rrtype to determine if IPv4 vs IPv6 address needed.
        if [ ! -f /etc/resolv.conf.ipabackup ]; then
            rlRun "cp /etc/resolv.conf /etc/resolv.conf.ipabackup"
        fi
        if [ $(echo $MYROLE | egrep "REPLICA|CLIENT"|wc -l) -gt 0 ]; then
            for ns in $(eval echo \$BEAKERMASTER_env${MYENV}) $(eval echo \$BEAKERREPLICA_env${MYENV}); do
                nsaddr=$(dig +short $ns $rrtype|tail -1)
                rlRun "echo \"nameserver $nsaddr\" >> /etc/resolv.conf.new"
            done
            rlRun "sed -i s/^nameserver/#nameserver/g /etc/resolv.conf"
            rlRun "cat /etc/resolv.conf.new >> /etc/resolv.conf"
            rlRun "rm -f /etc/resolv.conf.new"
        fi
    else
        rlLog "USEDNS=no, skipping resolv.conf reconfig"
    fi
    rlRun "cat /etc/resolv.conf"
}

fixResolvIPv6()
{
    ipa_install_prep_initVars
        
    if [ "$USEDNS" != "no" ]; then
        # we use the RRTYPE here in $rrtype to determine if IPv4 vs IPv6 address needed.
        if [ ! -f /etc/resolv.conf.ipabackup ]; then
            rlRun "cp /etc/resolv.conf /etc/resolv.conf.ipabackup"
        fi
        if [ $(echo $MYROLE | egrep "REPLICA|CLIENT"|wc -l) -gt 0 ]; then
            for ns in $(eval echo \$BEAKERMASTER_env${MYENV}) $(eval echo \$BEAKERREPLICA_env${MYENV}); do
                nsaddr=$(dig +short $ns $rrtype|tail -1)
                rlRun "echo \"nameserver $nsaddr\" >> /etc/resolv.conf.new"
            done
            rlRun "sed -i s/^nameserver/#nameserver/g /etc/resolv.conf"
            rlRun "cat /etc/resolv.conf.new >> /etc/resolv.conf"
            rlRun "rm -f /etc/resolv.conf.new"
        fi
    else
        rlLog "USEDNS=no, skipping resolv.conf reconfig"
    fi
}

ipa_install_prep_disableFirewall()
{
    # Disable iptables, ip6tables, or firewalld
    if [ -f /etc/init.d/iptables ]; then
        rlRun "chkconfig iptables off"
    fi
    if [ -f /etc/init.d/ip6tables ]; then
        rlRun "chkconfig ip6tables off"
    fi
    if [ -f /usr/lib/systemd/system/firewalld.service ]; then
        rlRun "systemctl disable firewalld"
    fi

    # Turn off iptables or firewalld
    if [ $(cat /etc/redhat-release|grep "5\.[0-9]"|wc -l) -gt 0 ]; then
        service iptables stop
        if [ $? -eq 1 ]; then
            rlLog "BZ 845301 found -- service iptables stop returns 1 when already stopped"
        else
            rlPass "BZ 845301 not found -- service iptables stop succeeeded"
        fi
    else    
        if [ -f /etc/init.d/iptables ]; then
            rlRun "service iptables stop"
        fi
        if [ -f /usr/lib/systemd/system/firewalld.service ]; then
            rlRun "systemctl stop firewalld"
        fi
    fi

    # Turn off ip6tables if it exists
    if [ $(cat /etc/redhat-release|grep "5\.[0-9]"|wc -l) -gt 0 ]; then
        service ip6tables stop
        if [ $? -eq 1 ]; then
            rlLog "BZ 845301 found -- service ip6tables stop returns 1 when already stopped"
        else
            rlPass "BZ 845301 not found -- service ip6tables stop succeeeded"
        fi
    else    
        if [ -f /etc/init.d/ip6tables ]; then
            rlRun "service ip6tables stop"
        fi
    fi
}

SetUpAuthKeys()
{
    [ ! -d /root/.ssh/ ] && rlRun "mkdir -p /root/.ssh"
    chmod 700 /root/.ssh
    restorecon -R /root/.ssh
    diff -q /opt/rhqa_ipa/id_rsa_global.pub /root/.ssh/id_rsa > /dev/null 2>&1
    if [ $? -eq 1 ]; then   
        /bin/cp -f /opt/rhqa_ipa/id_rsa_global /root/.ssh/id_rsa
        /bin/cp -f /opt/rhqa_ipa/id_rsa_global.pub /root/.ssh/id_rsa.pub
        for var in ${!BEAKERMASTER_env*} ${!BEAKERREPLICA_env*} ${!BEAKERCLIENT_env*}; do
            for server in $(eval echo \$$var); do
                sed -e s/localhost/$server/g /opt/rhqa_ipa/id_rsa_global.pub >> /root/.ssh/authorized_keys
            done
        done
    fi
}

SetUpKnownHosts()
{
    [ ! -d /root/.ssh/ ] && rlRun "mkdir -p /root/.ssh"
    chmod 700 /root/.ssh
    restorecon -R /root/.ssh
    for var in ${!BEAKERMASTER_env*} ${!BEAKERREPLICA_env*} ${!BEAKERCLIENT_env*}; do
        for server in $(eval echo \$$var); do
            ip=$(dig +short $server)
            #AddToKnownHosts $server
            if [ ! -f /root/.ssh/known_hosts ]; then
                touch /root/.ssh/known_hosts
            fi
            ssh-keygen -R $server 2>/dev/null
            ssh-keyscan $server >> /root/.ssh/known_hosts

            ssh-keygen -R $ip 2>/dev/null
            ssh-keyscan $ip >> /root/.ssh/known_hosts
        done
    done
}

configAbrt()
{
    # configure abrt
    if [ $(cat /etc/redhat-release|grep "5\.[0-9]" |wc -l) -gt 0 ]; then
        rlLog "configAbrt : Machine is a RHEL 5 machine - no abrt"
    elif [ $(cat /etc/redhat-release|grep "6\.[0-2] "|wc -l) -gt 0 ]; then
        rlLog "configAbrt : Machine is RHEL 6.2 or earlier.  no abrt"
    else
        hostname_s=`hostname -s`
        for rpm in abrt-tui abrt-addon-ccpp libreport-plugin-mailx; do
            rlCheckRpm "$rpm"
            if [ $? -ne 0 ]; then
                rlRun "yum install -y $rpm"
            fi
        done

        if [ -z "$JOBID" ]; then 
            eval $(echo $(grep JOBID /etc/motd))
        fi

    
        alias unindent="sed -e 's/^[[:space:]]*//'"

        unindent > /etc/abrt/abrt-action-save-package-data.conf <<<"\
        OpenGPGCheck = no
        BlackList = nspluginwrapper, valgrind, strace, mono-core
        ProcessUnpackaged = yes
        BlackListedPaths = /usr/share/doc/*, */example*, /usr/bin/nspluginviewer, /usr/lib/xulrunner-*/plugin-container"

        unindent > /etc/libreport/plugins/mailx.conf <<<"\
        Subject=CRASH ALERT: Crash detected in ipa automation [Beaker Job: $JOBID].
        EmailFrom=root@$hostname_s
        EmailTo=seceng-idm-qe-list@redhat.com
        SendBinaryData=no"

        rlRun "service abrtd restart"
    fi
}

ipa_install_dogtag_workarounds()
{
    rlLog "setting up workaround for dogtag 10.0.2."
    rlRun "mkdir /root/.dogtag"
    rlRun "chmod 775 /root/.dogtag"
    rlRun "ln -s /root/.dogtag /root/.pki"
}

ipa_install_prep() 
{
    rlLog "$FUNCNAME"
    if [ -z "$IPA_SERVER_PACKAGES" ]; then
        rlFail "IPA_SERVER_PACKAGES variable not set.  Run ipa_install_set_vars first"
        return 1
    fi

    ipa_install_prep_pkgInstalls

    ipa_install_prep_setTime

    if [ "$IPv6SETUP" != "TRUE" ]; then
        fixHostFile
        fixhostname
        fixResolv
    else
        fixHostFileIPv6
        fixhostname
        fixForwarderIPv6
        rmIPv4addr
        fixResolvIPv6
    fi

    ipa_install_prep_disableFirewall

    SetUpAuthKeys
    SetUpKnownHosts

    configAbrt

    ipa_install_dogtag_workarounds
}

ipa_install_sssd_workarounds()
{
    # BZ 878420 Workaround
    # commenting since it breaks rhel6.3 installs.
    #rlLog "Adding ldap_sasl_authid to sssd.conf"
    #rlLog "Working around BZ 878420"
    #M1="\[domain\/$DOMAIN\]"
    #M2="\[sssd\]"
    #A1="ldap_sasl_authid = host\/$(hostname)\@$RELM"
    #sed -i "/$M1/,/$M2/ s/^\(.*\[sssd\]\)/$A1\n\n\1/" /etc/sssd/sssd.conf

    # BZ 878288 Workaround
    rlLog "Starting SSSD in case it is not running"
    rlLog "Workaround for BZ 878288 due to BZ 874527 fix"
    rlRun "service sssd start"
}

ipa_install_master()
{
    tmpout=/tmp/error_msg.out
    rlLog "ipa_install_master - Install IPA Master Server"
    rlLog "$FUNCNAME"

    ipa_install_prep
    
    for THISPKG in $IPA_SERVER_PACKAGES; do
        rlAssertRpm $THISPKG
    done
    
    if [ -z "$IPA_SERVER_OPTIONS" ]; then
        IPA_SERVER_OPTIONS="--setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
    fi
    rlRun "ipa-server-install $IPA_SERVER_OPTIONS"

    if [ $? -gt 0 ]; then
        rlRun "submit_log /var/log/ipaserver-install.log"
    fi

    if [ $(dig +short download.devel.redhat.com|wc -l) -eq 0 ]; then 
        KinitAsAdmin
        rlLog "[FAIL]: BZ 872372 found...IPA server DNS forwarding broken with bind-dyndb-ldap-2.2-1.el6.x86_64"
        rlLog "Adding workaround for BZ 872372 to fix broken forwarding"
        rlRun "echo $ADMINPW|kinit admin"
        rlRun "ipa dnsconfig-mod --forwarder=$DNSFORWARD"
        rlRun "service named restart"
    fi

    ipa_install_sssd_workarounds

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
}

ipa_install_replica()
{
    local MYMASTER=$1
    local MYREVNET=$(hostname -i|awk -F. '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
    rlLog "ipa_install_replica - Install IPA Replica Server"
    rlLog "$FUNCNAME $MYMASTER"

    ipa_install_prep

    for THISPKG in $IPA_SERVER_PACKAGES; do
        rlAssertRpm $THISPKG
    done

    if [ "$USEDNS" != "no" ]; then
        PREPOPTS="-p $ADMINPW --ip-address=$ipaddr $hostname_s.$DOMAIN"
    else
        PREPOPTS="-p $ADMINPW $hostname_s.$DOMAIN"
    fi

    rlLog "RUN ipa-replica-prepare on $MYMASTER"
    rlRun "ssh -o StrictHostKeyChecking=no root@$MYMASTER \"echo $ADMINPW|kinit admin; ipa-replica-prepare $PREPOPTS\" ; service named restart"
    # named can take a little time to update sometimes?
    rlRun "sleep 60"

    rlLog "RUN sftp to get gpg file"
    rlRun "sftp -o StrictHostKeyChecking=no root@$MYMASTER:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg /opt/rhqa_ipa/"

    rlLog "RUN ipa-replica-install"
    if [ -z "$IPA_REPLICA_OPTIONS" ];then
        IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
    fi
    rlRun "ipa-replica-install $IPA_REPLICA_OPTIONS"
    if [ $? -gt 0 ]; then
        rlRun "submit_log /var/log/ipareplica-install.log"
    fi

    ipa_install_sssd_workarounds
}

ipa_install_client()
{
    local MYMASTER=$1
    rlLog "ipa_install_client - Install IPA Client"
    rlLog "$FUNCNAME $MYMASTER"

    ipa_install_prep

    for THISPKG in $IPA_CLIENT_PACKAGES; do
        rlAssertRpm $THISPKG
    done

    rlLog "RUN ipa-client-install"
    if [ -z "$IPA_CLIENT_OPTIONS" ]; then
        IPA_CLIENT_OPTIONS="-U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$(echo $MYMASTER|cut -f1 -d.).$DOMAIN"
    fi
    rlRun "ipa-client-install $IPA_CLIENT_OPTIONS"
    if [ $? -gt 0 ]; then
        rlRun "submit_log /var/log/ipaclient-install.log"
    fi

    ipa_install_sssd_workarounds

    CHK1=$(grep "kinit: Preauthentication failed while getting initial credentials" /var/log/ipaclient-install.log|wc -l)
    if [ $CHK1 -gt 0 ]; then
        rlLog "[FAIL1] BZ 845691 found...ipa-client-install Failed to obtain host TGT"
        submit_log /var/log/ipaclient-install.log
    fi

    CHK2=$(grep "kinit: Client.*not found in Kerberos database while getting initial credentials" /var/log/ipaclient-install.log|wc -l)
    if [ $CHK2 -gt 0 ]; then
        rlLog "[FAIL2] BZ 845691 found...ipa-client-install Failed to obtain host TGT"
        submit_log /var/log/ipaclient-install.log
    fi
}

ipa_connect_replica()
{
    local REP1=$(echo $1|cut -f1 -d.).$DOMAIN
    local REP2=$(echo $2|cut -f1 -d.).$DOMAIN
    
    rlLog "ipa_connect_replica - Create Replication Agreement between two servers"
    rlLog "$FUNCNAME $REP1 $REP2"
    rlLog "RUN ipa-replica-manage connect $REP1 $REP2"
    rlRun "ipa-replica-manage -p $ADMINPW connect $REP1 $REP2"
}   
