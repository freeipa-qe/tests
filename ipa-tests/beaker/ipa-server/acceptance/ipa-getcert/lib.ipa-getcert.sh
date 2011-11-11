######################################
# lib.ipa-getcert.sh                 #
######################################
get_certsubject(){
    echo $ADMINPW | kinit $ADMINID 2>&1 >/dev/null
    cert=`ipa config-show | grep "Certificate Subject base" | cut -d":" -f2 | xargs echo`
    echo $cert
}
    
#cert_subject=`echo $ADMINPW | kinit $ADMINID 2>&1 >/dev/null; ipa config-show | grep "Certificate Subject base" | cut -d":" -f2 | xargs echo;kdestroy 2>&1 >/dev/null`
cert_subject=`get_certsubject`
fqdn=`hostname --fqdn`
pem_dir="/tmp/getcert$RANDOM"
#REALM="SJC.REDHAT.COM"

echo "------ before we start, here are list of test data ------------------"
echo "  cert_subject: [$cert_subject]"
echo "          fqdn: [$fqdn]"
echo "---------------------------------------------------------------------"
prepare_certrequest(){
    local id=$1
    local TrackingNickName=$id
    local NSSDBDIR_positive="/etc/pki/nssdb"
    local CertNickName_positive=$id #make cert nickname same as tracking nickname
    rlRun "ipa-getcert request -n $CertNickName_positive -d $NSSDBDIR_positive" 0 "create a cert request"
    rlRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -I $TrackingNickName" 0 "create a tracking request: [$TrackingNickName]"  
} #prepare_certrequeest

prepare_pem_certfile()
{
    local id=$1
    if [ ! -d $pem_dir ];then
        create_pem_dir
    fi
    local certfile=$pem_dir/${id}.cert.pem
    touch $certfile
    return $?
}

prepare_pem_keyfile()
{
    local id=$1
    if [ ! -d $pem_dir ];then
        create_pem_dir
    fi
    local keyfile=$pem_dir/${id}.key.pem
    openssl genpkey -algorithm RSA -out $keyfile
    return $?
}

cleanup_pem_keyfile()
{
    local id=$1
    local keyfile=$pem_dir/${id}.key.pem
    rm $keyfile
    return $?
} #cleanup_pme

cleanup_pem_certfile()
{
    local id=$1
    local certfile=$pem_dir/${id}.cert.pem
    rm $certfile
    return $?
} #cleanup_pme

prepare_pin()
{
    local id=$1
    if [ ! -d $pem_dir ];then
        create_pem_dir
    fi
    local pinfile=$pem_dir/${id}.pin
    key="random generated pin string that save into pin file has id = $id and random number: $RANCOM"
    echo $key > $pinfile
    return $?
}

cleanup_pin()
{
    local id=$1
    local pinfile=$pem_dir/${id}.pin
    rm $pinfile
    return $?
}

create_pem_dir()
{
    if [ ! -d "$pem_dir" ];then
        mkdir -p $pem_dir
        chcon -t cert_t $pem_dir
    fi
} #create_pem_dir

verifyCert(){
    local certname=$1
    local verifyString=$2
    local recordfile=$3

    local certlist=$TmpDir/certlist.$RANDOM.list #temp file
    local certfile=$TmpDir/certlist.$RANDOM.cert # temp file
    if [ "$verifyString" = "" ] || [ "$certname" = "" ];then
        rlFail "certname and verifyString required , return error"
        return 1
    fi
    if [ "$recordfile" = "" ];then
        recordfile=$TmpDir/cert.record.$RANDOM.txt
    fi
    echo "verify cert: [$certname] for [$verifyString]"
    ipa-getcert list > $certfile #read all certs 
    grep -n "Request ID" $certfile > $certlist 
    local totalrecords=`wc $certlist -l | cut -d" " -f1 | xargs echo`

    if [ "$totalrecords" = "" ];then
        rlFail "no match cert found, you are looking for [$certname] "
        return 1
    fi
    local totalline=`wc $certfile -l | cut -d" " -f1 | xargs echo`
    echo "$totalline:end of file" >> $certlist
    local start_linenumber=`grep -n "Request ID" $certfile | grep "$certname" | cut -d":" -f1| xargs echo`

    local order=`grep -n "$certname" $certlist | cut -d":" -f1 | xargs echo`
    local index=`grep  "$certname" $certlist | cut -d":" -f1 | xargs echo `
    #echo "order=[$order], index=[$index]"

    local next_order=$((order + 1))
    local next_line=`head -n $next_order $certlist | tail -1`
    local next_index=`echo $next_line  | cut -d":" -f1 | xargs echo `
    #echo "nextline=[$next_line], next_index=[$next_index]"

    local head_number=$((next_index-1))
    local tail_number=`echo "$next_index - $index " | bc`
    head -n $head_number $certfile | tail -n $tail_number > $recordfile
    #echo "head [$head_number], tail [$tail_number]"
    #echo "========= save in [$recordfile ] ============="
    #cat $recordfile
    #echo "==============================================="
    if grep "SUBMITTING" $recordfile 2>&1 >/dev/null
    then
        rlLog "cert is in submitting status, we need sleep 3 seconds and come back to check"
        return 2
    elif grep "GENERATING_KEY_PAIR" $recordfile 2>&1 >/dev/null
    then
        rlLog "cert is generating key pair, we need sleep 3 seconds and come back to check"
        return 2
    fi
    if grep "$verifyString" $recordfile 2>&1 >/dev/null
    then
        rlPass "verified, found [$verifyString] in cert [$certname]"
    else
        rlFail "[$verifyString] NOT FOUND in cert [$certname]"
    fi
    echo "========== here is the cert information ============="
    cat $recordfile
    #echo "========= below is what you are looking for ========="
    #echo "$verifyString"
    echo "====================================================="
    rm $certlist
    rm $certfile
} #certgrep

certRun()
{
    local cmd=$1
    local out=$2
    local errout="/tmp/qarun.err.out.$RANDOM.out"
    local expectCode="$3"
    local expectMsg="$4"
    local comment="$5"
    local verifyString=$6
    rlLog "cmd=[$cmd]"
    rlLog "expect [$expectCode], out=[$out]"
    rlLog "$comment"
    
    $1 2>$errout 1>$out
    actualCode=$?
    cat $errout >> $out
    if [ "$actualCode" = "$expectCode" ];then
        rlPass "return code matches, now check the message"
        debug="debug"
    else
        rlFail "expect [$expectCode] actual [$actualCode]"
        debug="debug"
    fi
        #check the error message
        if grep -i "$expectMsg" $out 2>&1 >/dev/null
        then 
            rlPass "expected message matches"
        else
            if [ ! "$verifyString" = "" ];then
                rlLog "verify [$verifyString]"
                if grep -i "New .* request .* added" $out 2>&1 >/dev/null
                then
                    rlLog "New request detected, check verify string [$verifyString]"
                    local certname=`grep -i "New .* request" $out | cut -d"\"" -f2 | xargs echo`
                    verifyCert $certname "$verifyString"
                    ret=$?
                    if [ "$ret" = "2" ];then
                        rlLog "sleep 2 seconds"
                        sleep 2
                        verifyCert $certname "$verifyString"
                    fi
                elif grep -i "Request .* modified" $out 2>&1 >/dev/null
                then
                    rlLog "Modified request detected, check verify string [$verifyString]"
                    local certname=`grep -i "Request .* modified" $out | cut -d"\"" -f2 | xargs echo`
                    verifyCert $certname "$verifyString"
                    if [ "$ret" = "2" ];then
                        rlLog "sleep 2 seconds"
                        sleep 2
                        verifyCert $certname "$verifyString"
                    fi
                else
                    rlFail "No new signing/tracking request detected, this test is failed"
                    debug="debug"
                fi
            else
                rlFail "error message does not match as expected";
                debug="debug"
            fi
        fi
   # else
   #     rlFail "expect [$expectCode] actual [$actualCode]"
   #     debug="debug"
   # fi
    # if debug is defined
    if [ "$debug" = "debug" ];then
        echo "========== expected message ==============="
        echo "expected msg : $expectMsg"
        echo "verify string: $verifyString"
        echo "==========  actual  output  ==============="
        cat $out
        echo "============== end of output =============="
    fi
    if [ -f $errout ];then
        rm $errout
    fi
} #qaRun

qaRun()
{
    local cmd=$1
    local out=$2
    local errout="/tmp/qarun.err.out.$RANDOM.out"
    local expectCode="$3"
    local expectMsg="$4"
    local comment="$5"
    local debug=$6
    rlLog "cmd=[$cmd]"
    rlLog "expect [$expectCode], out=[$out]"
    rlLog "$comment"
    
    $1 2>$errout 1>$out
    actualCode=$?
    cat $errout >> $out
    if [ "$actualCode" = "$expectCode" ];then
        rlLog "return code matches, now check the message"
        if grep -i "$expectMsg" $out 2>&1 >/dev/null
        then 
            rlPass "expected return code and msg matches"
        else
            rlFail "return code matches,but error message does not match as expected";
            debug="debug"
        fi
    else
        rlFail "expect [$expectCode] actual [$actualCode]"
        debug="debug"
    fi
    # if debug is defined
    if [ "$debug" = "debug" ];then
        echo "========== expected message ==============="
        echo "$expectMsg"
        echo "==========  actual  output  ==============="
        cat $out
        echo "============== end of output =============="
    fi
    if [ -f $errout ];then
        rm $errout
    fi
} #qaRun
