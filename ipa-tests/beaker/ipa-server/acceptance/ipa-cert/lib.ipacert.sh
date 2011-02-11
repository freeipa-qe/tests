######################################
# lib.ipacert.sh                     #
######################################

# test data used in ipa cert test
hostname=`hostname | xargs echo`
certList=$TmpDir/certlist.$RANDOM.txt

create_cert()
{
    local out=$TmpDir/createCert.$RANDOM.txt
    local serviceName=service_$RANDOM
    local certRequestFile=$TmpDir/certreq.$RANDOM.csr
    local certPrivateKeyFile=$TmpDir/certprikey.$RANDOM.key
    local principal=$serviceName/$hostname
    rlLog "cert req [$certRequestFile]"
    KinitAsAdmin
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

    certid=`grep "Serial number" $out| cut -d":" -f2 | xargs echo` 
    rlLog "create a new cert in ipa db, cert id: $certid"
    echo "$certid" >> $certList
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
    local exp=$TmpDir/createCertRequestFile.$RANDOM.exp

    echo "set timeout 30" > $exp
    echo "set force_conservative 0" >> $exp
    echo "set send_slow {1 .1}" >> $exp
    echo "spawn $certCmd" >> $exp
    echo 'match_max 100000' >> $exp

    echo 'expect "Country Name *"' >> $exp
    echo "send -s -- \"US\"\r" >> $exp

    echo 'expect "State or Province Name *"' >> $exp
    echo "send -s -- \"CA\"\r" >> $exp

    echo 'expect "Locality Name *"' >> $exp
    echo "send -s -- \"Mountain View\"\r" >> $exp

    echo 'expect "Organization Name *"' >> $exp
    echo "send -s -- \"IPA\"\r" >> $exp

    echo 'expect "Organizational Unit Name *"' >> $exp
    echo "send -s -- \"QA\"\r" >> $exp

    echo 'expect "Common Name *"' >> $exp
    echo "send -s -- \"$hostname\"\r" >> $exp

    echo 'expect "Email Address *"' >> $exp
    echo "send -s -- \"ipaqa@redhat.com\"\r" >> $exp

    echo 'expect "A challenge password *"' >> $exp
    echo "send -s -- \"\"\r" >> $exp

    echo 'expect "An optional company name *"' >> $exp
    echo "send -s -- \"\"\r" >> $exp

    echo 'expect eof ' >> $exp
    rlRun "/usr/bin/expect $exp" 0 "create cert request file"
    
    echo "===== exp file [$exp] ===="
    cat $exp
    echo "========================================"
} #create_cert_request_file
  
delete_cert()
{
    rlLog "nothing here yet"
    rlPass "pass for now"
} #delete_cert
