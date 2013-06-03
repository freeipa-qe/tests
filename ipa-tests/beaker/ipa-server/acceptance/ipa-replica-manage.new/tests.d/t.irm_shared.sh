#!/bin/bash

# irm_uninstall 
# irm_install <master> 
# irm_useradd <server> <username>
# irm_userdel <server> <username>
# irm_userchk <server> <username>

function irm_uninstall()
{
    MYMASTER=$(ipa-replica-manage -p $ADMINPW list $(hostname)|head -1|cut -f1 -d:)
    ipa-replica-manage -p $ADMINPW del -H $MYMASTER $(hostname) --force

    ipa_quick_uninstall
}

function irm_install()
{
    ipa_install_replica $1
}

function irm_useradd()
{
    local runhost=$1
    local user=$2
    tmpout=/tmp/output.$FUNCNAME
    if [ -n "$PWOPT" ]; then
        rlRun "ssh $runhost 'echo $ADMINPW| kinit admin'"
    fi

    rlRun "ssh $runhost 'ipa user-add $user --first=test --last=user' > $tmpout 2>&1"
    irm_bugcheck_970225 $tmpout

    if [ -n "$PWOPT" ]; then
        rlRun "ssh $runhost 'kdestroy'"
    fi
}

function irm_userdel()
{
    local runhost=$1
    local user=$2
    if [ -n "$PWOPT" ]; then
        rlRun "ssh $runhost 'echo $ADMINPW| kinit admin'"
    fi

    rlRun "ssh $runhost 'ipa user-del $user'"

    if [ -n "$PWOPT" ]; then
        rlRun "ssh $runhost 'kdestroy'"
    fi
}

function irm_userchk()
{
    local runhost=$1
    local user=$2
    local chkerr=${3:-0}
    if [ -n "$PWOPT" ]; then
        rlRun "ssh $runhost 'echo $ADMINPW| kinit admin'"
    fi

    rlRun "ssh $runhost 'ipa user-show $user'" $chkerr

    if [ -n "$PWOPT" ]; then
        rlRun "ssh $runhost 'kdestroy'"
    fi
}

######################################################################
# Rich found that all of the attributes for the CSN entry were
# excluded from replication.  So, it was in local RUV for server
# where change occurred.  But, it wasn't replicated out to other
# servers.  So, for now (as of 5/21/2013), we can't rely on 
# the RUV method to check if all replicas are in sync.
######################################################################
#function irm_check_ruv_broken()
#{
#    local runhosts="$@"
#    local runhost=""
#    local ruvcurr=""
#    local ruvprev=""
#    local runerrnum=0
#
#    for runhost1 in $runhosts; do
#        ruvprev=""
#        for runhost2 in $runhosts; do
#            ruvcurr=$(ldapsearch -o ldif-wrap=no -xLLL \
#            -h $runhost2 -D "$ROOTDN" -w $ROOTDNPWD -b $BASEDN \
#            '(&(objectclass=nstombstone)(nsuniqueid=ffffffff-ffffffff-ffffffff-ffffffff))' \
#            nsds50ruv| grep $runhost1 | sed 's/^.*} [a-z0-9]* //g')
#            if [ -n "$ruvprev" -a "$ruvprev" != "$ruvcurr" ]; then
#                runerrnum=$(( runerrnum += 1 ))
#            fi
#            rlLog "On $runhost2 RUV MaxCSN for $runhost1 is $ruvcurr"
#            ruvprev="$ruvcurr"
#        done
#        echo
#    done
#
#    return $runerrnum 
#}
######################################################################
# Ruv a check to print out all the RUV info across all servers
######################################################################
#for RUV in $MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4; do 
#    for SERVER in $MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4; do 
#        RUVCHK=$(ldapsearch -o ldif-wrap=no -h $SERVER \
#        -xLLL -D "$ROOTDN" -w $ROOTDNPWD -b $BASEDN \
#        '(&(objectclass=nstombstone)(nsuniqueid=ffffffff-ffffffff-ffffffff-ffffffff))' \
#        nsds50ruv|grep $RUV);   echo "$(echo $SERVER|cut -f1 -d.): $RUVCHK"
#    done
#    echo 
#done

### Temp check function until we get a better way to confirm replicas in sync
function irm_check_ruv()
{
    rlRun "sleep 60"
    return 0
}

function irm_check_ruv_sync()
{
    local runhosts="$@"
    local runcount=3
    local runtimeout=30
    local runerrnum=0

    for (( i=1; i<=$runcount; i++ )); do
        rlLog "RUV CHECK: $i $runhosts"
        irm_check_ruv "$runhosts"
        runerrnum=$?
        if [ $runerrnum -gt 0 ]; then
            sleep $runtimeout
        else
            rlPass "Replicas in sync"
            return 0
        fi
    done

    rlFail "Replicas still out of sync after $i tries.  Errnum: $runerrnum"
    return 1
}

function irm_rep_pause()
{
    local runfrom=$1
    local runto=$2

    DAYTORUN=$(( $(date +%w) - 1 ))
    if [ $DAYTORUN -eq -1 ]; then
        DAYTORUN=6
    fi

    REPDN=$(ldapsearch -h $runfrom -o ldif-wrap=no \
        -x -D "$ROOTDN" -w "$ROOTDNPWD" \
        -b cn=config "(objectclass=nsds5ReplicationAgreement)" dn cn \
        |grep dn:.*meTo$runto|sed 's/dn: //')

    unindent <<<"\
        dn: $REPDN
        changetype: modify
        replace: nsds5replicaupdateschedule
        nsds5replicaupdateschedule: 2358-2359 $DAYTORUN
    " | ldapmodify -h $runfrom -x -D "$ROOTDN" -w "$ROOTDNPWD"
} 

