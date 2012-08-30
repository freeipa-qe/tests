#!/bin/bash
. ./d.autorenewcert.sh

oscpSubsystemCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="ocspSigningCert cert-$CAINSTANCE"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

caSSLServiceCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="Server-Cert cert-$CAINSTANCE"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

caSubsystemCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="subsystemCert cert-$CAINSTANCE"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

caAuditLogCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="auditSigningCert cert-$CAINSTANCE"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

ipaRAagentCert(){
    local db="/etc/httpd/alias"
    local nickname="ipaCert"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

ipaServiceCert_ds(){
    local db="/etc/dirsrv/$DSINSTANCE"
    local nickname="Server-Cert"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

ipaServiceCert_pki(){
    local db="/etc/dirsrv/$CA_DSINSTANCE"
    local nickname="Server-Cert"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

ipaServiceCert_httpd(){
    local db="/etc/httpd/alias"
    local nickname="Server-Cert"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

caJarSigningCert(){
    local db="/etc/httpd/alias"
    local nickname="Signing-Cert"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

list_all_ipa_certs(){
    sort_certs
    echo ""
    echo "+-------------------- all IPA certs [`date`]----------------------------------+"
    echo "[preValid certs]:"
    list_certs "preValid" $allcerts
    echo ""

    echo "[valid certs]:"
    list_certs "valid" $allcerts
    echo ""

    echo "[expired certs]:"
    list_certs "expired" $allcerts
    echo "+--------------------------------------------------------------------------------------------------+"
    echo ""
}

list_certs(){
    local state=$1
    shift
    for cert in $@
    do
        print_cert_brief $cert $state
    done
}

print_cert_brief(){
    local cert=$1
    local passinState=$2
    local readState=`$cert status $passinState`
    if [[ "$passinState" =~ ^(preValid|valid|expired)$ ]] ;then
        if [ "$readState" = "$passinState" ];then
            local nickname=`$cert nickname $passinState`
            local serial=`$cert serial $passinState`
            local notbefore_sec=`$cert NotBefore_sec $passinState`
            local notbefore_date=`$cert NotBefore $passinState`
            local notafter_sec=`$cert NotAfter_sec $passinState`
            local notafter_date=`$cert NotAfter $passinState`
            local timeleft=`$cert LifeLeft $passinState`
            local life=`$cert Life $passinState`
            local subject=`$cert subject $passinState`

            local fp_certname=`perl -le "print sprintf (\"%-21s\",\"$cert\")"`
            local name="$fp_certname($nickname)"
            local fp_name=`perl -le "print sprintf (\"%-51s\",\"$name\")"`
            local fp_serial=`perl -le "print sprintf (\"%-2d\",$serial)"`
            local fp_state=`perl -le "print sprintf (\"%-8s\",$passinState)"`
            local fp_timeleft=`perl -le "print sprintf(\"%-20s\",\"$timeleft\")"`
            echo "$fp_name #$fp_serial: [$notbefore_date]~~[$notafter_date] expires@($fp_timeleft) life [$life] "
        fi
    else
        echo "not supported status :[$passinState]"
    fi
}

print_cert_details(){
    local indent=$1
    local cert=$2
    local state=$3
    local db=`$cert db`
    local nickname=`$cert nickname`
    local tempcertfile="$dir/cert.detail.$RANDOM.txt"
    $readCert -d $db -n "$nickname" -s $state -f $tempcertfile 2>&1 >/dev/null
    if [ -f $tempcertfile ];then
        echo "$indent+------------------------------------------------------------------------+"
        cat $tempcertfile | sed -e "s/^\w/$indent &/"
        echo "$indent+------------------------------------------------------------------------+"
        rm $tempcertfile
    fi
    echo ""
}

max(){
    local max=$1
    shift
    for n in $@
    do
        if [ $max -lt $n ];then
            max=$n
        fi
    done
    echo $max
}

min(){
    local min=$1
    shift
    for n in $@
    do
        if [ $min -gt $n ];then
            min=$n
        fi
    done
    echo $min
} 

get_not_before_sec(){
    local state=$1
    shift
    local notBefore=""
    for cert in $@
    do
        local notBefore_epoch=`$cert "NotBefore_sec" $state`
        if [ "$notBefore_epoch" != "no cert found" ];then
            notBefore="$notBefore $notBefore_epoch"
        fi
    done
    echo $notBefore
}

get_not_after_sec(){
    local state=$1
    shift
    local notAfter=""
    for cert in $@
    do
        local notAfter_epoch=`$cert "NotAfter_sec" $state`
        if [ "$notAfter_epoch" != "no cert found" ];then
            notAfter="$notAfter $notAfter_epoch"
        fi
    done
    echo $notAfter
}

convert_utc_date_to_epoch(){
    date -d "$@ UTC" "+%s"
}

convert_date_to_epoch(){
    date -d "$@" "+%s"
}
    

convert_epoch_to_date(){
    perl -e "print scalar localtime($1)"
}

fix_prevalid_cert_problem(){
    local before=`get_not_before_sec "preValid" $allcerts `
    echo "+----------------- check prevalid problem -----------------+"
    echo -n "[fix_prevalid_cert_problem]"
    if [ "$before" = "" ];then
        echo " no preValid problem found"
    else
        echo " found previlid problem, fixing..."
        list_certs "preValid" $allcerts
        local before_max=`max $before`
        local now=`date`
        local now_epoch=`convert_date_to_epoch "$now"`
        echo "      current time   : $now"
        echo "      cert not-before: `convert_epoch_to_date $before_max`"
        if [ $now_epoch -lt $before_max ];then
            adjust_system_time $before_max preValid
        fi 
    fi
    echo "+---------------------------------------------------------+"
}

calculate_autorenew_date(){
    local group=$@
    local after=`get_not_after_sec valid $group`
    local after_min=`min $after`
    local after_max=`max $after`
    certExpire=`min $after`
    preAutorenew=`echo "$certExpire - $oneday" | bc`
    autorenew=`echo "$certExpire - $sixdays" | bc`
    postAutorenew=`echo "$certExpire - $halfhour " | bc`
    postExpire=`echo "$certExpire + $halfday" | bc`
    echo "[calculate_autorenew_date]"
    #echo "  preAutorenew :"`convert_epoch_to_date $preAutorenew` " ($preAutorenew)"  
    echo "     autorenew    :" `convert_epoch_to_date $autorenew` " ($autorenew)"  
    #echo "  postAutorenew:" `convert_epoch_to_date $postAutorenew` " ($postAutorenew)" 
    echo "     certExpire   :" `convert_epoch_to_date $certExpire` " ($certExpire)" 
    echo "     postExpire   :" `convert_epoch_to_date $postExpire` " ($postExpire)" 
}

adjust_system_time(){
    local adjustTo=$1
    local label=$2
    echo "[adjust_system_time] ($label)"
    stopIPA
    echo "        given [$adjustTo]" `convert_epoch_to_date $adjustTo`
    local before=`date`
    date "+%a %b %e %H:%M:%S %Y" -s "`perl -le "print scalar localtime $adjustTo"`" 2>&1 > /dev/null
    local after=`date`
    echo "        adjust [$before]=>[$after] done"
    startIPA
}

stopIPA(){
    local out=`ipactl stop | sed -e "s/Stopping/ : Stopping/"`
    local cleanout=`echo $out`
    echo "[stop ipa ] $cleanout"
}

startIPA(){
    local out=`ipactl start | sed -e "s/Starting/ : Starting/"`
    local cleanout=`echo $out`
    echo  "[start ipa] $cleanout"
}

go_to_sleep(){
    local waittime=0
    echo -n "[go_to_sleep] $maxwait(s): "
    while [ $waittime -lt $maxwait ]
    do    
        waittime=$((waittime + $wait4renew))
        echo -n " ...$waittime(s)"
        sleep $wait4renew
    done
    echo ""
}

record_just_renewed_certs(){
    renewedCerts="$renewedCerts $justRenewedCerts"
    justRenewedCerts="" #reset so we can continue test
}

report_renew_status(){
    echo "--------------- Cert Renew report ----------------"
    for cert in $allcerts
    do
        local counter=`$countlist -s "$renewedCerts" -c "$cert"`
        local fp_certname=`perl -le "print sprintf (\"%+21s\",\"$cert\")"`
        echo "$fp_certname : renewed [ $counter ] times"
    done
    echo "--------------------------------------------------"
}

check_actually_renewed_certs(){
    rlPhaseStartTest "autorenewcert round [$testid] - check_actually_renewed_certs"
    local certsShouldBeRenewed=$@
    echo "[check_actually_renewed_certs]:"
    for cert in $certsShouldBeRenewed
    do
        local state=`$cert status valid`
        if [ "$state" = "valid" ];then
            rlPass "      valid cert found for  [$cert]"
            justRenewedCerts="${justRenewedCerts}${cert} " #append spaces at end
        else
            rlFail "      NO valid cert found for [$cert]"
        fi
    done
    rlPhaseEnd
}

report_test_result(){
    rlPhaseStartTest "autorenewcert round [$testid] final result"
    echo ""
    echo "##################### renew test result report ##############################"
    echo "#       [soon to be renewed certs]: [$soonTobeRenewedCerts]"
    echo "#       [acutally being renewed  ]: [$justRenewedCerts]"
    echo "#############################################################################"
    if [ "$soonTobeRenewedCerts " = "$justRenewedCerts " ];then # don't forget the extra spaces
        rlPass "round [$testid] renewed certs: [$soonTobeRenewedCerts]"
    else
        local difflist=`$difflist "$soonTobeRenewedCerts" "$justRenewedCerts"`
        rlFail "round [$testid] certs not renewed [ $difflist ]"
        rlLog "current system time :[`date`]"
        for cert in $difflist
        do
            print_cert_details "     " $cert expired
            print_cert_details "     " $cert preValid
        done
    fi
    rlPhaseEnd
}

pause(){
    local choice="y"
    echo -n "continue? (y/n) "
    read choice
    if [ "$choice" = "n" ];then
        exit
    fi
}

sort_certs(){
    local tempdatafile="$dir/cert.timeleft.$RANDOM.txt"
    echo "[sort_certs]"
    for cert in $allcerts
    do
        local timeleft_sec=`$cert LifeLeft_sec valid`
        if [ "$timeleft_sec" != "no cert found" ];then
            echo "$cert=$timeleft_sec" >> $tempdatafile
        else
            timeleft_sec=`$cert LifeLeft_sec preValid`
            if [ "$timeleft_sec" != "no cert found" ];then
                echo "$cert=$timeleft_sec" >> $tempdatafile 
            else
                timeleft_sec=`$cert LifeLeft_sec expired`
                echo "$cert=$timeleft_sec" >> $tempdatafile
            fi
        fi
    done
    if [ -f $tempdatafile ];then
        allcerts=`$sortlist $tempdatafile`
        echo "       after sorted: [$allcerts]"
        rm $tempdatafile
    fi   
}

find_soon_to_be_renewed_certs(){
    local tempdatafile="$dir/cert.timeleft.$RANDOM.txt"
    for cert in $allcerts
    do
        local timeleft_sec=`$cert LifeLeft_sec valid`
        if [ "$timeleft_sec" != "no cert found" ];then
            echo "$cert=$timeleft_sec" >> $tempdatafile
        fi
    done
    if [ -f $tempdatafile ];then
        soonTobeRenewedCerts=`$grouplist "$tempdatafile" "$halfhour"`
        echo "[find_soon_to_be_renewed_certs] test: [$soonTobeRenewedCerts]"
        rm $tempdatafile
    else
        echo "[find_soon_to_be_renewed_certs] ERROR: no cert found to test: [$soonTobeRenewedCerts]"
    fi
}

continue_test(){
    # test will continue in two condition
    # 1. there are some certs haven't get chance to renew once
    # 2. all certs have valid version

    local continueTest="no"
    notRenewedCerts=`$difflist "$renewedCerts" "$allcerts"`
    local validCerts=`get_all_valid_certs`
    local notValid=`$difflist "$validCerts" "$allcerts"`
    
    if [ "$notRenewedCerts" = "" ];then
        # if all certs have been renewed once, not need to continue test
        continueTest="no" 
    else
        if [ "$notValid" = "" ];then
            continueTest="yes" # if all certs are continue test
        else
            continueTest="no"  # other wise, stop test
            checkTestConditionRequired="true"
        fi
    fi
    echo $continueTest
}

get_all_valid_certs(){
    local validCerts=""
    for cert in $allcerts
    do
        state=`$cert status valid`
        if [ "$state" = "valid" ];then
            validCerts="$validCerts $cert"
        fi
    done
    echo "$validCerts"
}

check_test_condition(){
    # we stop test in the following 2 conditions
    # 1. previous test result has to pass
    # 2. there are some certs haven't get chance to be renewed
   
    # check condition 1:
    notRenewedCerts=`$difflist "$renewedCerts" "$allcerts"`
    local validCerts=`get_all_valid_certs`
    local notValid=`$difflist "$validCerts" "$allcerts"`

    list_all_ipa_certs
    echo "[all certs  ] [$allcerts]"
    echo "[valid certs] [$validCerts]"
    echo "[not valid  ] [$notValid]"
    echo "[not renewed] [$notRenewedCerts]"
    for cert in $noValid
    do
        echo "   No valid certs found for [$cert]"
        local db=`$cert db`
        local nickname=`$cert nickname`
        echo "      debug [certutil -L -d $db -n \"$nickname\"] "
        echo "      OR    [$readCert -d $db -n \"$nickname\" -s (preValid/valid/expired)]"
        print_cert_details "     " $cert preValid
        print_cert_details "     " $cert expired
    done
}

print_test_header(){
    local round=$1
    echo ""
    echo "###########################################################"
    echo "#                                                         #"
    echo "#                    test round [$round]                       #"
    echo "#                                                         #"
    echo "###########################################################"
    echo ""
}

test_ipa_via_kinit_as_admin(){
    
    rlPhaseStartTest "autorenewcert round [$testid] - test_ipa_via_kinit_as_admin"
    local pw=$ADMINPW #use the password in env.sh file
    local out=$dir/kinit.as.admin.$RANDOM.txt
    local exp
    local temppw
    echo "[test_ipa_via_kinit_as_admin] test with password: [$pw]"
    echo $pw | kinit $ADMINID 2>&1 > $out
    if [ $? = 0 ];then
        rlPass "[test_ipa_via_kinit_as_admin] kinit as $ADMINID with [$pw] success"
    elif [ $? = 1 ];then
        echo "[test_ipa_via_kinit_as_admin] first try of kinit as $ADMINID with [$pw] failed"
        echo "[test_ipa_via_kinit_as_admin] check ipactl status"
        ipactl status
        if echo $pw | kinit $ADMINID | grep -i "kinit: Generic error (see e-text) while getting initial credentials"
        then
            echo "[test_ipa_via_kinit_as_admin] got kinit: Generic error, restart ipa and try same password again"
            ipactl restart
            rlRun "$kdestroy"
            echo $pw | kinit $ADMINID 2>&1 > $out
            if [ $? = 0 ];then
                rlPass "[test_ipa_via_kinit_as_admin] kinit as $ADMINID with [$pw] success at second attemp -- after restart ipa"
                return
            fi
        fi        
            
        echo "[test_ipa_via_kinit_as_admin] password [$pw] failed, check whether it is because password expired"
        echo "============ output of [echo $pw | kinit $ADMINID] ============="
        cat $out
        echo "============================================================"
        if grep "Password expired" $out 2>&1 >/dev/null
        then
            echo "$ADMINID password exipred, do reset process"
            exp=$dir/reset.admin.password.$RANDOM.exp
            temppw="New_$pw"
            kinit_aftermaxlife "$ADMINID" "$ADMINPW" $temppw
            # set password policy to allow $ADMINID change password right away
            min=`ipa pwpolicy-show | grep "Min lifetime" | cut -d":" -f2`
            min=`echo $min`
            history=`ipa pwpolicy-show | grep "History size" | cut -d":" -f2`
            history=`echo $history`
            classses=`ipa pwpolicy-show | grep "classes" | cut -d":" -f2`
            classes=`echo $classes`
            ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --minlife=0 --history=0 --minclasses=0
            # now set $ADMINID password back to original password
            echo "set timeout 10" > $exp
            echo "set force_conservative 0" >> $exp
            echo "set send_slow {1 .01}" >> $exp
            echo "spawn ipa passwd $ADMINID" >> $exp
            echo 'expect "Current Password: "' >> $exp
            echo "send -s -- $temppw\r" >> $exp
            echo 'expect "New Password: "' >> $exp
            echo "send -s -- $pw\r" >> $exp
            echo 'expect "Enter New Password again to verify: "' >> $exp
            echo "send -s -- $pw\r" >> $exp
            echo 'expect eof' >> $exp
            /usr/bin/expect $exp 
            cat $exp
            rm $exp
            # after reset password, test the new password
            $kdestroy
            echo $pw | kinit $ADMINID
            if [ $? = 1 ];then
                rlFail "[test_ipa_via_kinit_as_admin] reset password back to original [$pw] failed"
            else
                rlPass "[test_ipa_via_kinit_as_admin] reset password success"
                ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --minlife=$min --history=$history --minclasses=$classes
                echo "[test_ipa_via_kinit_as_admin] set $ADMINID password back to [$pw] success -- after set to temp"
            fi
        elif grep "Password incorrect while getting initial credentials" $out 2>&1 >/dev/null
        then
            rlFail "[test_ipa_via_kinit_as_admin] wrong $ADMINID password provided: [$pw]"
        else
            rlFail "[test_ipa_via_kinit_as_admin] unhandled error: Not because password expired; not because wrong password provided"
        fi
    else
        rlFail "[test_ipa_via_kinit_as_admin] unknow error, return code [$?] not recoginzed"
    fi
    rm $out
    rlPhaseEnd
}

kinit_aftermaxlife()
{
    local username=$1
    local pw=$2
    local newpw=$3
    local exp=$tmpdir/kinitaftermaxlife.$RANDOM.exp
    echo "set timeout 10" > $exp
    echo "set force_conservative 0" >> $exp
    echo "set send_slow {1 .01}" >> $exp
    echo "spawn kinit -V $username" >> $exp
    echo 'match_max 100000' >> $exp
    echo 'expect "*: "' >> $exp
    echo "send -s -- $pw\r" >> $exp
    echo 'expect "Password expired. You must change it now."' >> $exp
    echo 'expect "Enter new password: "' >> $exp
    echo "send -s -- $newpw\r" >> $exp
    echo 'expect "Enter it again: "' >> $exp
    echo "send -s -- $newpw\r" >> $exp
    echo 'expect eof' >> $exp
    echo "$kdestroy"

    echo "====== [kinit_aftermaxlife] exp file ========="
    cat $exp
    echo "----------- ipactl status -------------------"
    ipactl status
    echo "=============================================="
    /usr/bin/expect $exp
    echo "$kdestroy"

    echo "====== [kinit_aftermaxlife] ipactl status after run exp file ========="
    ipactl status
    echo "=============================================="

    echo $newpw | kinit $username
    # clean up
    rm $exp
} #kinit_aftermaxlife



test_dirsrv_via_ssl_based_ldapsearch(){
    rlPhaseStartTest "autorenewcert round [$testid] - test_dirsrv_via_ssl_based_ldapsearch"
    # doc: http://directory.fedoraproject.org/wiki/Howto:SSL#Use_ldapsearch_with_SSL
    echo "test_dirsrv_via_ssl_based_ldapsearch"
    $ldapsearch -H ldaps://$host -x -D "$ROOTDN" -w "$ROOTDNPWD" -s base -b "" objectclass=* | grep "vendorName:"
    if [ "$?" = "0" ];then
        rlPass "[test_dirsrv_via_ssl_based_ldapsearch] Test Pass"
    else
        rlFail "[test_dirsrv_via_ssl_based_ldapsearch] Test Failed"
    fi
    echo ""
    rlPhaseEnd
}

test_dogtag_via_getcert(){
    rlPhaseStartTest "autorenewcert round [$testid] - test_dogtag_via_getcert"
    echo "test_dogtag_via_getcert"
    local certid=1
    ipa cert-show $certid | grep "Certificate:"
    if [ "$?" = "0" ];then
        rlPass "[test_dogtag_via_getcert] Test Pass"
    else
        rlFail "[test_dogtag_via_getcert] Test Failed"
    fi
    echo ""
    rlPhaseEnd
}

find_dirsrv_instance(){
    local asking=$1
    local all=`ls -d /etc/dirsrv/slapd-*`
    local ca_ds_instance=""
    local ds_instance=""
    # determine dirsrv instance name
    for name in $all
    do
        basename=`basename $name`
        if [[ $name =~ "PKI-IPA" ]];then
            ca_ds_instance=$basename
        else
            ds_instance=$basename
        fi
    done
    if [ "$asking" = "ca" ];then
        echo $ca_ds_instance
    elif [ "$asking" = "ds" ];then
        echo "$ds_instance"
    fi
}

exercise_ipa_via_create_brand_new_customer_cert(){
    rlPhaseStartTest "autorenewcert round [$testid] - exercise_ipa_via_create_brand_new_customer_cert"
    local serviceName=testservice_$RANDOM
    local certRequestFile=$dir/certreq.$RANDOM.csr
    local certPrivateKeyFile=$dir/certprikey.$RANDOM.key
    local principal=$serviceName/$host
    echo "certreq    [$certRequestFile]"
    echo "privatekey [$certPrivateKeyFile]"
    echo "principal  [$principal]"

    #requires : kinit as admin to success 
    echo step 1: create/add a host this should already done : use existing host $host

    echo step 2: add a test service add service: [$principal]
    ipa service-add $principal

    echo step 3: create a cert request
    create_cert_request_file $certRequestFile $certPrivateKeyFile
    local ret=$?
    if [ "$ret" = "0" ];then
        echo "cert file creation success, continue"
    else
        echo "cert file creation failed, return fail"
        return 1
    fi

    echo step 4: process cert request
    ipa cert-request --principal=$principal $certRequestFile 
    if [ $? = 0 ];then
        rlPass "customer cert create success, test pass"
    else
        rlFail "customer cert create failed, test failed"
    fi
    rlPhaseEnd
}

create_cert_request_file()
{
    local requestFile=$1
    local keyFile=$2
    # command to use:
    local certCmd="openssl req -out $requestFile -new -newkey rsa:2048 -nodes -keyout $keyFile"
    local exp=$dir/createCertRequestFile.$RANDOM.exp  # local test

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
    echo "send -s -- \"$host\r\"" >> $exp

    echo 'expect "Email Address *"' >> $exp
    echo "send -s -- \"ipaqa@redhat.com\r\"" >> $exp

    echo 'expect "A challenge password *"' >> $exp
    echo "send -s -- \"\r\"" >> $exp

    echo 'expect "An optional company name *"' >> $exp
    echo "send -s -- \"\r\"" >> $exp

    echo 'expect eof ' >> $exp
    
    echo "create cert request file [$requestFile]"
    /usr/bin/expect $exp
    local ret=$?
   
} #create_cert_request_file
 
