#######################################
# lib.user-cli.sh
#######################################

# functions used in user-cli test
Kinit()
{
#return 0=success
#return 1=failed
    local user=$1
    local password=$2
    rlLog "kinit as user [$user] with password [$password]"
    rlRun "echo $password | kinit $user"
    if [ $? -ne 0 ];then
        rlLog "kinit as [$user] failed"
        return 1
    else
        if klist | grep $user
        then
            rlLog "principal found, kinit success"
            return 0
        else
            rlLog "kinit success, but no principal found"
            return 1
        fi
    fi
} #Kinit

Kdestroy()
{
#return 0=success
#return 1=failed
    rlLog "clean up all kinit ticket by kdestroy"
    rlRun "/usr/kerberos/bin/kdestroy  "
    if [ $? -ne 0 ];then
        rlLog "kdestroy failed"
        return 1
    else
        rlLog "kdestroy success"
        return 0
    fi
} #Kdestroy
