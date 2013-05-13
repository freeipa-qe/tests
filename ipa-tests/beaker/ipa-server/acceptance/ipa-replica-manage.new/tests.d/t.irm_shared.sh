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
    if [ -n "$PWOPT" ]; then
        rlRun "ssh $runhost 'echo $ADMINPW| kinit admin'"
    fi

    rlRun "ssh $runhost 'ipa user-add $user --first=test --last=user'"

    if [ -n "$PWOPT" ]; then
        rlRun "ssh $runhost 'kdestroy'"
    fi
}

function irm_userdel()
{
    local runhost=$1
    local user=$2
    if [ -z "$PWOPT" ]; then
        rlRun "ssh $runhost 'echo $ADMINPW; kinit admin'"
    fi

    rlRun "ssh $runhost 'ipa user-del $user'"

    if [ -z "$PWOPT" ]; then
        rlRun "ssh $runhost 'kdestroy'"
    fi
}

function irm_userchk()
{
    local runhost=$1
    local user=$2
    if [ -z "$PWOPT" ]; then
        rlRun "ssh $runhost 'echo $ADMINPW; kinit admin'"
    fi

    rlRun "ssh $runhost 'ipa user-show $user'"

    if [ -z "$PWOPT" ]; then
        rlRun "ssh $runhost 'kdestroy'"
    fi
}

function irm_check_ruv()
{
    local runhosts="$@"
    local runhost=""
    local ruvcurr=""
    local ruvprev=""
    local runerrnum=0

    for runhost in $runhosts; do
        ruvcurr=$(ldapsearch -xLLL -h $runhost -D "$ROOTDN" -w $ROOTDNPWD -b $BASEDN \
        '(&(objectclass=nstombstone)(nsuniqueid=ffffffff-ffffffff-ffffffff-ffffffff))' \
        | grep replicageneration|awk '{print $3}') 
        if [ -n "$ruvprev" -a "$ruvprev" != "$ruvcurr" ]; then
            runerrnum=$(( runerrnum += 1 ))
        fi
        rlLog "RUV for $runhost is $ruvcurr"
    done

    return $runerrnum 
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
