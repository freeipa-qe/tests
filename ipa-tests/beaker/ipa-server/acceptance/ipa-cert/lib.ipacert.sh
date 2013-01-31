######################################
# lib.ipacert.sh                     #
######################################

# test data used in ipa cert test
hostname=`hostname | xargs echo`
certList=$TmpDir/certlist.$RANDOM.txt
reqList=$TmpDir/reqlist.$RANDOM.txt

LKinitAsAdmin()
{
    echo Secret123 | kinit admin@SJC.REDHAT.COM 2>&1 >/dev/null
} #KinitAsAdmin

create_cert()
{
    local tmpout=$TmpDir/createCert.$RANDOM.txt
    local serviceName=service_$RANDOM
    local certRequestFile=$TmpDir/certreq.$RANDOM.csr
    local certPrivateKeyFile=$TmpDir/certprikey.$RANDOM.key
    local principal=$serviceName/$hostname
    rlLog "cert req [$certRequestFile]"
    rlRun "KinitAsAdmin" 0 "kinit as admin"
    # step 1: create/add a host
    #        this should already done
    
    # step 2: add a test service
    rlRun "ipa service-add $principal" 0 "add service: [$principal]"

    # step 3: create a cert request
    create_cert_request_file $certRequestFile $certPrivateKeyFile
    local ret=$?
    if [ "$ret" = "0" ];then
        rlLog "cert file creation success, continue"
    else
        rlFail "cert file creation failed, return fail"
        return 1
    fi
    # step 4: process cert request
    rlRun "cat /dev/null > /var/log/pki-ca/debug" 0 "pki-ca debug log cleared again"
    ipa cert-request --principal=$principal $certRequestFile >$tmpout
    local ret=$?
    if [ "$ret" = "0" ];then
        local reqid=`grep reqId /var/log/pki-ca/debug | cut -d"=" -f2 | xargs echo`
        local certid=`grep "Serial number" $tmpout | grep -v "hex" | cut -d":" -f2 | xargs echo` 
        echo "$principal=$certid" >> $certList
        echo "$reqid" >> $reqList
        rlPass "create cert success, req id :[$reqid], cert id :[$certid], principal [$principal]"
    else
        rlFail "create cert failed, principal [$principal]"
    fi
    rm $tmpout
    rlRun "Kcleanup" 0 "clear kerberos tkts"

    #debug 
    #echo "===================================="
    #echo "output of cert-request"
    #cat $tmpout
    #echo "===================================="

    #echo "==== cert list ==="
    #cat $certList
    #echo "=================="
    # done 
} #create_cert

create_cert_request_file()
{
    local requestFile=$1
    local keyFile=$2
    local keySize=$3
    # command to use:
    if [ -z "$keySize" ];then
     keySize=2048
    fi
    echo $keySize
    local certCmd="openssl req -out $requestFile -new -newkey rsa:$keySize -nodes -keyout $keyFile"
    local exp=$TmpDir/createCertRequestFile.$RANDOM.exp # beaker test
    #local exp=/tmp/createCertRequestFile.$RANDOM.exp  # local test

    echo "set timeout 5" > $exp
    echo "set force_conservative 0" >> $exp
    echo "set send_slow {1 .1}" >> $exp
    echo "spawn $certCmd" >> $exp
    echo 'match_max 100000' >> $exp

    echo 'expect "Country Name *"' >> $exp
    echo "send -s -- \"US\r\"" >> $exp

    echo 'expect "State or Province Name *"' >> $exp
    echo "send -s -- \"CA\r\"" >> $exp

    echo 'expect "Locality Name *"' >> $exp
    echo "send -s -- \"Mountain View\r\"" >> $exp

    echo 'expect "Organization Name *"' >> $exp
    echo "send -s -- \"IPA\r\"" >> $exp

    echo 'expect "Organizational Unit Name *"' >> $exp
    echo "send -s -- \"QA\r\"" >> $exp

    echo 'expect "Common Name *"' >> $exp
    echo "send -s -- \"$hostname\r\"" >> $exp

    echo 'expect "Email Address *"' >> $exp
    echo "send -s -- \"ipaqa@redhat.com\r\"" >> $exp

    echo 'expect "A challenge password *"' >> $exp
    echo "send -s -- \"\r\"" >> $exp

    echo 'expect "An optional company name *"' >> $exp
    echo "send -s -- \"\r\"" >> $exp

    echo 'expect eof ' >> $exp
    
    rlLog "create cert request file [$requestFile]"
    /usr/bin/expect $exp
    local ret=$?
    
    #echo "===== exp file [$exp] ===="
    #cat $exp
    #echo "========= Request file [$requestFile ]=="
    #cat $requestFile
    #echo "======================================="
    return $ret
} #create_cert_request_file
  
delete_cert()
{
    rlRun "KinitAsAdmin" 0 "kinit as admin"
    cat $certList
    cat $reqList
    for cert in `cat $certList`
    do
        echo "line:[$cert]"
        if [ "$cert" == service* ];then
        local cert_principal=`echo $cert | cut -d"=" -f1`
        local cert_id=`echo $cert | cut -d"=" -f2`
        rlLog "remove the service and revoke the cert [$cert_principal $cert_id"
        rlRun "ipa service-del $cert_principal" 0 "remove service $cert_principal";
        fi
    done
    echo "" > $certList #clear up the cert list file
    echo "" > $reqList #clear up the cert list file
    rlRun "Kcleanup" 0 "clear kerberos tkts"
} #delete_cert

qaRun()
{
    local cmd="$1"
    local out="$2"
    local errout=$TmpDir/qarun.$RANDOM.out
    local expectCode="$3"
    local expectMsg="$4"
    local comment="$5"
    local debug=$6
    rlLog "cmd=[$cmd]"
    rlLog "expect [$expectCode], out=[$out]"
    rlLog "$comment"
    
    $1 2>$errout >$out
    cat $errout >> $out
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
    rm $errout
} #qaRun
