#!/bin/bash
. ./d.autorenewcert.sh

prepareStorage(){
    if [ ! -d $testdir ];then
        mkdir -p $testdir
        mkdir $currentCertDir
        mkdir $renewalCertDir
        echo "cert storage: current [$currentCertDir] renewal: [$renewalCertDir]"
    fi
}

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
    #sortAndFindToBeRenewedCerts
    echo "--------------------- all IPA certs ------------------------------------"
    echo "[valid certs]:"
    if [ "$sortedValidCerts" != "" ];then
        listCerts "valid" $sortedValidCerts
    else
        listCerts "valid" $allcerts
    fi
    echo ""
    echo "[preValid certs]:"
    listCerts "preValid" $allcerts
    echo ""
    echo "[expired certs]:"
    listCerts "expired" $allcerts
    echo "-----------------------------------------------------------------------"
}

listCerts(){
    local state=$1
    shift
    for cert in $@
    do
        listCert $cert $state
    done
}

listCert(){
    local cert=$1
    local passinState=$2
    local readState=`$cert status $passinState`
    if [ "$readState" = "$passinState" ];then
        local nickname=`$cert nickname $passinState`
        local serial=`$cert serial $passinState`
        local notbefore_sec=`$cert NotBefore_sec $passinState`
        local notbefore_date=`$cert NotBefore $passinState`
        local notafter_sec=`$cert NotAfter_sec $passinState`
        local notafter_date=`$cert NotAfter $passinState`
        local timeleft=`$cert LifeLeft $passinState`
        local life=`$cert Life $passinState`

        local name="$cert($nickname)"
        local fp_name=`perl -le "print sprintf (\"%-47s\",\"$name\")"`
        local fp_serial=`perl -le "print sprintf (\"%-2d\",$serial)"`
        local fp_state=`perl -le "print sprintf (\"%-8s\",$passinState)"`
        local fp_timeleft=`perl -le "print sprintf(\"%-20s\",\"$timeleft\")"`
        echo -n "$fp_name #$fp_serial: ($fp_state) "
        echo "expires in:[$fp_timeleft] [$notbefore_date]-[$notafter_date] length[$life] "
    fi
}

print_single_cert_details(){
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
    for n in $@
    do
        if [ $min -gt $n ];then
            min=$n
        fi
    done
    echo $min
} 

getNotBefore(){
    local notBefore=""
    for cert in $@
    do
        local notBefore_epoch=`$cert "NotBefore_sec" valid`
        notBefore="$notBefore $notBefore_epoch"
    done
    echo $notBefore
}

getNotAfter(){
    local notAfter=""
    for cert in $@
    do
        local notAfter_epoch=`$cert "NotAfter_sec" valid`
        notAfter="$notAfter $notAfter_epoch"
    done
    echo $notAfter
}

dateToEpoch(){
    date -d "$@" "+%s"
}
    

epochToDate(){
    perl -e "print scalar localtime($1)"
}

calculating_critical_period(){
    local group=$@
    #listCerts $group
    
    local after=`getNotAfter $group`
    local after_min=`min $after`
    local after_max=`max $after`
    #local adjust=`echo $after - $halfday | bc`
    #echo "before: $before = " `epochToDate $before`
    #echo "after : $after  = $after"
    #echo "after min : $after_min  = " `epochToDate $after_min`
    #echo "after max : $after_max  = " `epochToDate $after_max`
    certExpire=`min $after`
    preAutorenew=`echo "$certExpire - $oneday" | bc`
    autorenew=`echo "$certExpire - $halfday" | bc`
    postAutorenew=`echo "$certExpire - $halfhour " | bc`
    postExpire=`echo "$certExpire + $halfday" | bc`
    echo "[calculating_critical_period]"
    #echo "  preAutorenew :"`epochToDate $preAutorenew` " ($preAutorenew)"  
    echo "  autorenew    :" `epochToDate $autorenew` " ($autorenew)"  
    #echo "  postAutorenew:" `epochToDate $postAutorenew` " ($postAutorenew)" 
    echo "  certExpire   :" `epochToDate $certExpire` " ($certExpire)" 
    echo "  postExpire   :" `epochToDate $postExpire` " ($postExpire)" 
    echo ""
}

certSanityCheck(){
    echo certSanityCheck need work
}

adjust_system_time(){
    local adjustTo=$1
    local label=$2
    echo "[adjust_system_time] ($label)"
    stopIPA
    #echo "  given [$adjustTo]" `epochToDate $adjustTo`
    local before=`date`
    date "+%a %b %e %H:%M:%S %Y" -s "`perl -le "print scalar localtime $adjustTo"`" 2>&1 > /dev/null
    local after=`date`
    echo "  adjust [$before]=>[$after] done"
    startIPA
}

stopIPA(){
    local out=`ipactl stop | sed -e "s/Stopping/ : Stopping/"`
    local cleanout=`echo $out`
    echo "  [stop ipa ] $cleanout"
}

startIPA(){
    local out=`ipactl start | sed -e "s/Starting/ : Starting/"`
    local cleanout=`echo $out`
    echo "  [start ipa] $cleanout"
}

go_to_sleep_so_certmonger_has_chance_to_trigger_renewal_action(){
    local waittime=0
    #until ldapsearch -D "cn=directory manager" -w Secret123 -b "cn=ca_renewal,cn=ipa,cn=etc,dc=yzhang,dc=redhat,dc=com" | grep "numEntries: 5" || [ $waittime -gt $maxwait ]
    echo -n "[go_to_sleep_so_certmonger_has_chance_to_trigger_renewal_action] "
    until [ $waittime -gt $maxwait ]
    do    
        waittime=$((waittime + $wait4renew))
        echo -n " ...$waittime(s)"
        sleep $wait4renew
    done
    echo ""
}

verifyRenewalCertInLDAP(){
    local group=$@
    for cert in $group
    do
        local nickname=`$cert nickname`
        local certFile="$renewalCertDir/$cert.cert"
        echo "verify cert [$cert] nickname: [$nickname]"
        $readRenewalCert -n "$nickname" -f "$certFile"
        if [ -f $certFile ];then
            echo "----------- found renewal cert [$cert] ------------"
            cat $certFile
            echo "---------------------------------------------------"
        else
            echo "ERROR: for [$cert], no renewal cert found, error"
        fi
    done        
}

save_certs_that_just_being_renewed(){
    renewedCerts="$renewedCerts $justRenewedCerts"
    justRenewedCerts="" #reset so we can continue test
}

check_which_cert_is_actually_renewed(){
    local certsShouldBeRenewed=$@
    echo "[check_which_cert_is_actually_renewed]:"
    for cert in $certsShouldBeRenewed
    do
        echo -n "   [$cert]"
        local state=`$cert status valid`
        if [ "$state" = "valid" ];then
            echo " valid cert found"
            justRenewedCerts="${justRenewedCerts}${cert} " #append spaces at end
        else
            echo " NO valid cert found"
        fi
    done
}

report_cert_renewal_result(){
    echo "################ cert auto renew test result report #########################"
    echo "#       [soon to be renewed certs]: [$soonTobeRenewedCerts]"
    echo "#       [acutally being renewed  ]: [$justRenewedCerts]"
    if [ "$soonTobeRenewedCerts " = "$justRenewedCerts " ];then # don't forget the extra spaces
        echo "# PASS: soon to be renewed certs matches with actually renewed certs #"
        testresult="pass"
    else
        echo "# FAIL: soon to be renewed certs DOES NOT matches with actually renewed certs"
        local difflist=`$difflist $soonTobeRenewedCerts $justRenewedCerts`
        for cert in $difflist
        do
            print_single_cert_details "     " $cert expired
            print_single_cert_details "     " $cert preValid
        done
        testresult="fail"
    fi
    echo "#############################################################################"
}

pause(){
    local choice="y"
    echo -n "continue? (y/n) "
    read choice
    if [ "$choice" = "n" ];then
        exit
    fi
}

find_soon_to_be_renewed_certs(){
    local tempdatafile="$dir/cert.timeleft.$RANDOM.txt"
    echo -n "[find_soon_to_be_renewed_certs]"
    for cert in $allcerts
    do
        local timeleft_sec=`$cert LifeLeft_sec valid`
        if [ "$timeleft_sec" != "no cert found" ];then
            echo "$cert=$timeleft_sec" >> $tempdatafile
        fi
    done
    if [ -f $tempdatafile ];then
        sortedValidCerts=`$sortlist $tempdatafile`
        soonTobeRenewedCerts=`$grouplist $tempdatafile $halfhour`
        #echo "  all IPA certs: [$allcerts]"
        #echo "  sorted  certs: [$sortedValidCerts]"
        #echo "  to be renewed: [$soonTobeRenewedCerts]"
        echo "[$soonTobeRenewedCerts]"
        rm $tempdatafile
    else
        echo "  no valid certs found, test can not continue"
    fi
}

check_test_condition(){
    # we stop test in the following 2 conditions
    # 1. previous test result has to pass
    # 2. there are some certs haven't get chance to be renewed
   
    # check condition 1:
    local noValidCertFound=""
    local state=""
    for cert in $allcerts
    do
        state=`$cert status valid`
        if [ "$state" = "valid" ];then
            listCert $cert valid
        else
            noValidCertFound="$noValidCertFound $cert"
        fi
    done
    if [ "$noValidCertFound" != "" ];then
        # if this queue is not empty, that means we found some certs expired and not being renewed, test can not continue
        continueTest="no" # test can not continue since there are some certs are not valid
        echo "[check_test_condition] Test Can not continue, invalid certs found [$noValidCertFound]"
        for cert in $noValidCertFound
        do
            echo "   No valid certs found for [$cert]"
            local db=`$cert db`
            local nickname=`$cert nickname`
            echo "      debug [certutil -L -d $db -n \"$nickname\"] "
            echo "      OR    [$readCert -d $db -n \"$nickname\" -s (preValid/valid/expired)]"
            print_single_cert_details "     " $cert preValid
            print_single_cert_details "     " $cert expired
        done
    else
        # check contition 2:  each cert has to be renewed at least required [$numofround] times
        local notRenewedCerts=""
        for cert in $allcerts
        do
            local counter=`$countlist -s "$allcerts" -l "$renewedCerts" -c "$cert" `
            if [ $counter -lt $numofround ];then
                notRenewedCerts="$notRenewedCerts $cert"
            else
                echo "  cert: [$cert] has bee renewed [$counter] times, required [$numofround]"
            fi
        done
        if [ "$notRenewedCerts" = "" ];then
            continueTest="no" # all certs have been renewed required [$numofround] times, no need to continue test
            echo "[check_test_condition] no need to continue"
        else
            continueTest="yes" # 
            echo "[check_test_condition] the following certs has not being renewed for min [$numofround] times, test should continue =="
            for cert in $notRenewedCerts
            do
                listCert $cert valid
            done
        fi
    fi
}

log(){
    local loglevel
    local logmsg 
    if [ $# -ge 2 ];then
        loglevel=$1  
        shift
        logmsg=$@
    else           
        logmsg=$@ 
    fi 
    if [ "$loglevel" != "" ] && [ $loglevel -ge $mode ];then
        echo "[$mode] $logmsg"
    fi
#info=3
#debug=4
#mode=2
#log $info detail info
}      

