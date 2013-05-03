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
    if [ -z "$PWOPT" ]; then
        rlRun "ssh $runhost 'echo $ADMINPW; kinit admin'"
    fi

    rlRun "ssh $runhost 'ipa user-add $user --first=test --last=user'"

    if [ -z "$PWOPT" ]; then
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
