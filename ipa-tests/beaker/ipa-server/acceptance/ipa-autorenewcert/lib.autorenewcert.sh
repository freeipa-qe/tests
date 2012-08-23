#!/bin/bash
. ./d.autorenewcert.sh

generateCertConf(){
    echo "# auto generated file, do not edit by hand" > $certconf
    echo "# `date`" >> $certconf
    for cert in $allcerts
    do
        local db=`$cert db`
        local nickname=`$cert nickname`
        echo "$cert=$db:$nickname" >> $certconf
    done
}

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
    local db="/etc/dirsrv/slapd-$DSINSTANCE"
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
    local db="/etc/dirsrv/slapd-$CA_DSINSTANCE"
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
    generateCertConf
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

getNotBefore(){
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

getNotAfter(){
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

dateToEpoch(){
    date -d "$@" "+%s"
}
    

epochToDate(){
    perl -e "print scalar localtime($1)"
}

fix_prevalid_cert_problem(){
    local before=`getNotBefore "preValid" $allcerts `
    echo "+----------------- check prevalid problem -----------------+"
    echo -n "[fix_prevalid_cert_problem]"
    if [ "$before" = "" ];then
        echo " no preValid problem found"
    else
        echo " found previlid problem, fixing..."
        list_certs "preValid" $allcerts
        local before_max=`max $before`
        local now=`date`
        local now_epoch=`dateToEpoch "$now"`
        echo "      current time   : $now"
        echo "      cert not-before: `epochToDate $before_max`"
        if [ $now_epoch -lt $before_max ];then
            adjust_system_time $before_max preValid
        fi 
    fi
    echo "+---------------------------------------------------------+"
}

calculate_autorenew_date(){
    local group=$@
    local after=`getNotAfter valid $group`
    local after_min=`min $after`
    local after_max=`max $after`
    certExpire=`min $after`
    preAutorenew=`echo "$certExpire - $oneday" | bc`
    autorenew=`echo "$certExpire - $halfday" | bc`
    postAutorenew=`echo "$certExpire - $halfhour " | bc`
    postExpire=`echo "$certExpire + $halfday" | bc`
    INFO "[calculate_autorenew_date]"
    #INFO "  preAutorenew :"`epochToDate $preAutorenew` " ($preAutorenew)"  
    INFO "|    autorenew    :" `epochToDate $autorenew` " ($autorenew)"  
    #INFO "  postAutorenew:" `epochToDate $postAutorenew` " ($postAutorenew)" 
    DEBUG "|    certExpire   :" `epochToDate $certExpire` " ($certExpire)" 
    INFO "|    postExpire   :" `epochToDate $postExpire` " ($postExpire)" 
}

certSanityCheck(){
    echo certSanityCheck need work
}

adjust_system_time(){
    local adjustTo=$1
    local label=$2
    INFO "[adjust_system_time] ($label)"
    stopIPA
    DEBUG "|     | given [$adjustTo]" `epochToDate $adjustTo`
    local before=`date`
    date "+%a %b %e %H:%M:%S %Y" -s "`perl -le "print scalar localtime $adjustTo"`" 2>&1 > /dev/null
    local after=`date`
    DEBUG "|     | adjust [$before]=>[$after] done"
    startIPA
}

stopIPA(){
    local out=`ipactl stop | sed -e "s/Stopping/ : Stopping/"`
    local cleanout=`echo $out`
    DEBUG "[stop ipa ] $cleanout"
}

startIPA(){
    local out=`ipactl start | sed -e "s/Starting/ : Starting/"`
    local cleanout=`echo $out`
    DEBUG  "[start ipa] $cleanout"
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
    local certsShouldBeRenewed=$@
    INFO "[check_actually_renewed_certs]:"
    for cert in $certsShouldBeRenewed
    do
        local state=`$cert status valid`
        if [ "$state" = "valid" ];then
            DEBUG "|     valid cert found for  [$cert]"
            justRenewedCerts="${justRenewedCerts}${cert} " #append spaces at end
        else
            DEBUG "|     NO valid cert found for [$cert]"
        fi
    done
}

report_test_result(){
    echo ""
    DEBUG "##################### renew test result report ##############################"
    DEBUG "#       [soon to be renewed certs]: [$soonTobeRenewedCerts]"
    DEBUG "#       [acutally being renewed  ]: [$justRenewedCerts]"
    if [ "$soonTobeRenewedCerts " = "$justRenewedCerts " ];then # don't forget the extra spaces
        INFO "# Test PASS: [$soonTobeRenewedCerts] does renewed"
    else
        local difflist=`$difflist "$soonTobeRenewedCerts" "$justRenewedCerts"`
        INFO "# Test FAIL: certs not renewed [ $difflist ]"
        for cert in $difflist
        do
            print_cert_details "     " $cert expired
            print_cert_details "     " $cert preValid
        done
    fi
    DEBUG "#############################################################################"
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
    DEBUG "[sort_certs]"
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
        DEBUG "|      after sorted: [$allcerts]"
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
        DEBUG "[find_soon_to_be_renewed_certs] test: [$soonTobeRenewedCerts]"
        rm $tempdatafile
    else
        DEBUG "[find_soon_to_be_renewed_certs] ERROR: no cert found to test: [$soonTobeRenewedCerts]"
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
        DEBUG "   No valid certs found for [$cert]"
        local db=`$cert db`
        local nickname=`$cert nickname`
        DEBUG "      debug [certutil -L -d $db -n \"$nickname\"] "
        DEBUG "      OR    [$readCert -d $db -n \"$nickname\" -s (preValid/valid/expired)]"
        print_cert_details "     " $cert preValid
        print_cert_details "     " $cert expired
    done
}

INFO(){
    log info $@
}

DEBUG(){
    log debug $@
}

log(){
    local level=""
    local logmsg=""
    if [[ $# -ge 2 ]];then
        level=$1  
        shift
        logmsg=$@
    else           
        logmsg=$@ 
    fi
    # default to INFO, if level is not defined
    if [ "$level" = "" ];then
        level="info"
    fi
    local setting=`get_int_level $loglevel`
    local request=`get_int_level $level`
    if [ $setting -ge $request ];then
        echo "$logmsg"
    fi
}      

get_int_level(){
    # debug=3 ; info=2 ;
    local level=$1
    case $level in
    debug)
        echo 3
        ;;
    info)
        echo 2
        ;;
    esac
}

get_log_level(){
    # debug=3 ; info=2 ;
    local intlevel=$1
    case $intlevel in
    3)
        echo "debug"
        ;;
    2)
        echo "info"
        ;;
    esac
}

print_test_header(){
    local round=$1
    echo ""
    echo ""
    echo "###########################################################"
    echo "#                    test round [$round]                       #"
    echo "###########################################################"
    echo ""
}
