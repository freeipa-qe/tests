#!/bin/bash
# library for t.ipajoin.sh


############ global variable for ipa-join test ############
OTP="oneTimePass$RANDOM"
#clientFQDN=`hostname`
clientFQDN="$CLIENT"
#serverFQDN="dhcp-153.sjc.redhat.com"
#serverFQDN="mv32a-vm.idm.lab.bos.redhat.com"
serverFQDN="$MASTER"
#domain="sjc.redhat.com"
testKeytabfile="/tmp/ipajoin.testkeytab.$RANDOM.keytab"
defaultKeytabFile="/etc/krb5.keytab"


#################### functions ############################

install_ipa_client()
{
    #installCMD="ipa-client-install --unattended --principal=$ADMINID --password $ADMINPW --domain=$domain --server=$serverFQDN --hostname=$clientFQDN"
    installCMD="ipa-client-install --unattended --principal=$ADMINID --password $ADMINPW --domain=$DOMAIN--server=$serverFQDN --hostname=$clientFQDN"
    #rlRun "$installCMD" 0 "install client: server [$serverFQDN], client [$clientFQDN], domain [$domain]"
    rlRun "$installCMD" 0 "install client: server [$serverFQDN], client [$clientFQDN], domain [$DOMAIN]"
} #install_ipa_client

uninstall_ipa_client()
{
    uninstallCMD="ipa-client-install --unattended --uninstall"
    rlRun "$uninstallCMD" 0 "uninstall ipa client"
} #uninstall_ipa_client

execute_on_ipaserver()
{
    local cmd=$1
    rlRun "ssh root@$serverFQDN \"echo $ADMINPW | kinit $ADMINID ; $cmd\" "
} #execute_on_ipaserver

delete_clientHostEntry_FromIPAServer()
{
# delete the client host entry in ipa server
    local host=$1
    if [ "$host" = "" ];then 
        host=$clientFQDN
    fi
    rlLog "log into ipa server [$serverFQDN] as root and delete [$host]"
    rlRun "ssh -o StrictHostKeyChecking=no root@$serverFQDN \"echo $ADMINPW | kinit $ADMINID;ipa host-del $host\" " 0 "remotely remove client entry in ipa server"
} #delete_clientHostEntry_FromIPAServer

qaRun()
{
    local cmd="$1"
    local out="$2"
    local expectCode="$3"
    local expectMsg="$4"
    local comment="$5"
    local debug=$6
    rlLog "cmd=[$cmd]"
    rlLog "expect [$expectCode], out=[$out]"
    rlLog "$comment"
    
    $1 2>$out
    actualCode=$?
    if [ "$actualCode" = "$expectCode" ];then
        rlLog "return code matches, now check the message"
        if grep -i "$expectMsg" $out 2>&1 >/dev/null
        then 
            rlPass "expected return code and msg matches"
        else
            rlFail "return code matches,but message does not match expection";
            debug="debug"
        fi
    else
        rlFail "expect [$expectCode] actual [$actualCode]"
        debug="debug"
    fi
    # if debug is defined
    if [ "$debug" = "debug" ];then
        echo "--------- expected msg ---------"
        echo "[$expectMsg]"
        echo "========== execution output ==============="
        cat $out
        echo "============== end of output =============="
    fi
} #qaRun
