######################################
# lib.ipacert.sh                     #
######################################

# test data used in ipa cert test
hostname=`hostname | xargs echo`
certList=$TmpDir/certlist.$RANDOM.txt

LKinitAsAdmin()
{
    echo Secret123 | kinit admin@SJC.REDHAT.COM
} #LKinitAsAdmin

create_cert()
{
    local out=$TmpDir/createCert.$RANDOM.txt
    local serviceName=service_$RANDOM
    local certRequestFile=$TmpDir/certreq.$RANDOM.csr
    local certPrivateKeyFile=$TmpDir/certprikey.$RANDOM.key
    local principal=$serviceName/$hostname
    rlLog "cert req [$certRequestFile]"
    LKinitAsAdmin
    # step 1: create/add a host
    #        this should already done
    
    # step 2: add a test service
    rlRun "ipa service-add $principal" 0 "add service: [$principal]"

    # step 3: create a cert request
    create_cert_request_file $certRequestFile $certPrivateKeyFile
    ret=$?
    if [ "$ret" = "0" ];then
        rlLog "cert file creation success, continue"
    else
        rlFail "cert file creation failed, return fail"
        return 1
    fi
    # step 4: process cert request
    #rlRun "ipa cert-request --principal=$principal $certRequestFile" 0 "process cert request for [$principal]"
    ipa cert-request --principal=$principal $certRequestFile >$out

    echo "===================================="
    echo "output of cert-request"
    cat $out
    echo "===================================="

    certid=`grep "Serial number" $out| cut -d":" -f2 | xargs echo` 
    rlLog "create a new cert in ipa db, cert id: $certid"
    echo "$principal=$certid" >> $certList
    echo "==== cert list ==="
    cat $certList
    echo "=================="
    # done 
    Kcleanup
} #create_cert

create_cert_request_file()
{
    local requestFile=$1
    local keyFile=$2
    # command to use:
    local certCmd="openssl req -out $requestFile -new -newkey rsa:2048 -nodes -keyout $keyFile"
    #local exp=$TmpDir/createCertRequestFile.$RANDOM.exp # beaker test
    local exp=/tmp/createCertRequestFile.$RANDOM.exp  # local test

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
    rlRun "/usr/bin/expect $exp" 0 "create cert request file"
    
    echo "===== exp file [$exp] ===="
    cat $exp
    echo "========= Request file [$requestFile ]=="
    cat $requestFile
    echo "======================================="
} #create_cert_request_file
  
delete_cert()
{
    LKinitAsAdmin
    for cert in `cat $certList`
    do
        echo "line:[$cert]"
        local cert_principal=`echo $cert | cut -d"=" -f1`
        local cert_id=`echo $cert | cut -d"=" -f2`
        rlLog "remove the service and revoke the cert [$cert_principal $cert_id"
        rlRun "ipa service-del $cert_principal" 0 "remove service $cert_principal"
    done
    Kcleanup
} #delete_cert
