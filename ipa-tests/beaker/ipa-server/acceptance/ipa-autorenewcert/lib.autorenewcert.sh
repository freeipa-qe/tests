#!/bin/bash
. ./d.autorenewcert.sh

caSigningCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="caSigningCert cert-$CAINSTANCE"
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

ipaAgentCert(){
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
    echo "+-------------- all IPA certs (round $testroundCounter) Days left to the CA Cert life limit [`distanceToCAcertLimit`] ----------------------------+"
    echo "+-------------- all IPA certs (round $testroundCounter) Days left to the CA Cert life limit [`distanceToCAcertLimit`] ----------------------------+" > $certReport
    local summary="   ===== Summary: are all certs valid? [`all_certs_are_valid`] current system date [`date`],  === "
    echo $summary
    echo $summary >> $certReport
    echo "[valid certs]:"
    echo "[valid certs]:" >> $certReport
    list_certs "valid" $allcerts
    echo ""

    echo "[expired certs]:"
    echo "[expired certs]:" >> $certReport
    list_certs "expired" $allcerts
    echo "+--------------------------------------------------------------------------------------------------+"
    echo "+--------------------------------------------------------------------------------------------------+" >> $certReport
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
            echo "$fp_name #$fp_serial: [$notbefore_date]~~[$notafter_date] expires@($fp_timeleft) life [$life] " >> $certReport
        fi
    else
        echo "not supported status :[$passinState]"
        echo "not supported status :[$passinState]" >> $certReport
    fi
}

print_cert_details(){
    local indent=$1
    local cert=$2
    local state=$3
    local db=`$cert db`
    local nickname=`$cert nickname`
    local tempcertfile="$TmpDir/cert.detail.$RANDOM.txt"
    $readCert -d $db -n "$nickname" -s $state -f $tempcertfile 2>&1 >/dev/null
    if [ -f $tempcertfile ];then
        echo "$indent+-------------------------------------------------------------------------------+"
        cat $tempcertfile | sed -e "s/^\w/$indent | &/"
        echo "$indent+-------------------------------------------------------------------------------+"
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
    echo "fix_prevalid_cert_problem"
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
    echo "+----------------------------------------------------------+"
}

calculate_autorenew_date(){
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - calculate_autorenew_date"
    local group=$@
    local after=`get_not_after_sec valid $group`
    local after_min=`min $after`
    local after_max=`max $after`
    local current_epoch=`date +%s`
    certExpire=`min $after`
    #preAutorenew=`echo "$certExpire - $sixdays - $sixdays" | bc` # this is not in use
    #autorenew=`echo "$certExpire - $threedays" | bc` # not sure if change from three days to one day would make any different
    #autorenew=`echo "$certExpire - $oneday" | bc`
    autorenew=`echo "$certExpire - 45 * 60 " | bc`
    postExpire=`echo "$certExpire + $oneday" | bc` #used to be halfhour, not sure change it to one day would make any different
    echo "     current date :" `date` "($current_epoch)"
    echo "     autorenew    :" `convert_epoch_to_date $autorenew` " ($autorenew)"  
    echo "     certExpire   :" `convert_epoch_to_date $certExpire` " ($certExpire)" 
    echo "     postExpire   :" `convert_epoch_to_date $postExpire` " ($postExpire)" 
    echo ""
    if [ $current_epoch -lt $autorenew ] \
        && [ $autorenew -lt $certExpire ] \
        && [ $certExpire -lt $postExpire ]
    then
        rlPass "got reasonable autorenew time"
    else
        rlFail "something wrong, date are not well ordered, the rest of test will fail"
    fi
    rlPhaseEnd
}

adjust_system_time(){
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - adjust_system_time $label"
        local adjustTo=$1
        local label=$2
        echo "[adjust_system_time] ($label) : current [`date`]" 
        echo "[adjust_system_time] ($label) : given [$adjustTo]" `convert_epoch_to_date $adjustTo`
        local before=`date`
        logger "************************ Before: `date` *************************"
        logger "*****       time adjusted by adjust_system_time()             *****"
        date "+%a %b %e %H:%M:%S %Y" -s "`perl -le "print scalar localtime $adjustTo"`" 2>&1 > /dev/null
        logger "************************ After : `date` *************************"
        if [ "$?" = "0" ];then
            local after=`date`
            rlPass "adjust ($label) [$before]=>[$after] done"
            echo "[adjust_system_time] finished: current [`date`]" 
        else
            local after=`date`
            rlFail "change system date to ($label) failed, current data: [`date`]"
        fi
    rlPhaseEnd
}

enable_ipa_debug_mode()
{
    rlPhaseStartTest "set debug=True in ipa server's config file: /etc/ipa/default.conf"
        rlRun "ipactl stop" 0 "stop ipa server"
        rlRun "echo debug=Ture >> /etc/ipa/default.conf" 0 "echo debug=True into /etc/ipa/default.conf" 
        rlRun "ipactl start" 0 "start ipa server in debug mode"
    rlPhaseEnd
}

stop_ipa_certmonger_server(){
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - stop_ipa_certmonger_server ($@)"
        local tempout=$TmpDir/stop.ipa.certmonger.server.$testid.$RANDOM.txt
        rlRun "service certmonger stop" 0 "stop certmonger service before stop ipa server"
        sleep 5 # give system some time so ipa server can fully stopped
        ipactl stop 2>&1 > $tempout
        sleep 5 # give system some time so ipa server can fully stopped
        if grep -i "Aborting ipactl\|FAILED" $tempout
        then
            rlFail "stop ipa server Failed"
            cat $tempout
        else
            rlPass "stop ipa server Success"
        fi
        sleep 5 # give system some time so ipa server can fully stopped
    rlPhaseEnd
}

start_ipa_certmonger_server(){
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - start_ipa_certmonger_server ($@)" 
        local tempout=$TmpDir/start.ipa.certmonger.server.$testid.$RANDOM.txt
        ipactl start 2>&1 > $tempout
        sleep 5 # give system some time so ipa server can fully stopped
        if grep -i "Aborting ipactl\|FAILED" $tempout 
        then
            rlFail "start ipa server Failed"
            cat $tempout
        else
            rlPass "start ipa server Success"
            rlRun "service certmonger start" 0 "start certmonger service after ipa server started"
            sleep 5 #give system some time
        fi
    rlPhaseEnd
}

restart_ipa_certmonger_server(){
    stop_ipa_certmonger_server "$@"
    start_ipa_certmonger_server "$@"
}

go_to_sleep(){
    local waittime=0
    echo "[go_to_sleep] before sleep, system time: [`date`]"
    echo -n "[go_to_sleep] $maxwait(s): "
    while [ $waittime -lt $maxwait ]
    do    
        waittime=$((waittime + $wait4renew))
        local signal=$((waittime%900))
        if [ "$signal" -eq "0" ];then
             echo "restart pki_ca and certmonger"
             service pki-cad restart
             service certmonger restart
             echo "==== status of pki-cad and certmonger"
             service pki-cad status
             service certmonger status
             echo "====================================="
        fi
        echo -n " ...$waittime(s)"
        sleep $wait4renew
    done
    echo ""
    echo "[go_to_sleep] after sleep, system time: [`date`]"
    echo "============= beginning of tail -n 50 /var/log/messages ============="
    tail -n 50 /var/log/messages
    echo "============= end of tail -n 50 /var/log/messages ============="
}

prepare_for_next_round(){
    renewedCerts="$renewedCerts $justRenewedCerts"
    justRenewedCerts="" #reset so we can continue test
    local header="  "
    local lowest=""
    echo "$header +------------------- Cert Renew report ($testroundCounter)-----------------+"
    for cert in $allcerts
    do
        local counter=`$countlist -s "$renewedCerts" -c "$cert"`
        local fp_certname=`perl -le "print sprintf (\"%+26s\",\"$cert\")"`
        echo "$header | $fp_certname : renewed [ $counter ] times         |"
        if [ "$lowest" = "" ];then
            lowest=$counter
        fi
        if [ $counter -le $lowest ];then
            lowest=$counter
        fi
    done
    certRenewCounter=$lowest
    echo "$header +----------------------------------------------------------------------+"
    echo "$header ~~~~~ check whether all certs are valid [`all_certs_are_valid`]  ~~~~~"
    echo "$header ~~~~~ current system date [`date`] ~~~~~~"
    echo "$header ~~~~~ distance to CA cert life limit [`distanceToCAcertLimit`] ~~~~~"
}

check_actually_renewed_certs(){
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - check_actually_renewed_certs"
    local certsShouldBeRenewed=$@
    rlLog "check the queue certsShouldBeRenewed: [$certsShouldBeRenewed], all certs in this queue should be valid"
    for cert in $certsShouldBeRenewed
    do
        local state=`$cert status valid`
        local db=`$cert db`
        local nickname=`$cert nickname`
        if [ "$state" = "valid" ];then
            rlPass "Found valid cert for [$cert]"
            # yidebug: enable the following 3 lines later
            #echo "$cert Summary:"
            #$readCert -d $db -n "$nickname" -s "valid"
            #echo ""
        else
            rlLog "[$cert status valid] returned [$state]"
            rlFail "NO valid cert found for [$cert], current date:[`date`]"
            echo "certutil -L -d $db"
            certutil -L -d $db
            echo "[`date`] Debug: check certutil output: certutil -L -d $db -n \"$nickname\""
            certutil -L -d $db -n "$nickname"
            $readCert -d $db -n "$nickname" -s "valid"
            echo "[`date`] [End of debug]"
            echo "getcert list output"
            getcert list
        fi
    done
    rlPhaseEnd
}

compare_expected_renewal_certs_with_actual_renewed_certs(){
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - compare_expected_renewal_certs_with_actual_renewed_certs"
    echo "[soon to be renewed certs]: [$soonTobeRenewedCerts]"
    echo "[acutally being renewed  ]: [$justRenewedCerts]"

    for soon in $soonTobeRenewedCerts
    do
        if echo $justRenewedCerts | grep $soon 2>&1 >/dev/null
        then
            rlPass "Round [$testroundCounter] meet expactation: [$soon] found in just renewed certs queue"
            echo "    [ PASS ] compare_expected_renewal_certs_with_actual_renewed_certs: [$soon] did get renewed" >> $testResult
        else
            rlFail "Round [$testroundCounter] did NOT meet expactation: [$soon] not found in just renewed certs queue"
            echo "    [ FAIL ] * compare_expected_renewal_certs_with_actual_renewed_certs: [$soon] did NOT get renewed" >> $testResult
        fi
    done
    rlPhaseEnd
}

test_status_report(){
    if [ -f $testReport ];then
        echo ""
        echo "#-------------- autorenewcert test status report round($testroundCounter) -------------------------------#"
        cat $testResult
        echo "#----------------------------------------------------------------------------------------#"
        echo ""
    fi
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
    local tempdatafile="$TmpDir/cert.timeleft.$RANDOM.txt"
    echo "[sort_certs ] sorted by cert timeLeft_sec: "
    for cert in $allcerts
    do
        local timeleft_sec=`$cert LifeLeft_sec valid`
        if [ "$timeleft_sec" != "no cert found" ];then
            echo "$cert=$timeleft_sec" >> $tempdatafile
        else
            timeleft_sec=`$cert LifeLeft_sec expired`
            if [ "$timeleft_sec" != "no cert found" ];then
                echo "$cert=$timeleft_sec" >> $tempdatafile 
            fi
        fi
    done
    if [ -f $tempdatafile ];then
        allcerts=`$sortlist $tempdatafile`
        echo "       [$allcerts]"
        rm $tempdatafile
    fi   
}

find_soon_to_be_renewed_certs(){
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - find_soon_to_be_renewed_certs"
    rlLog "find_soon_to_be_renewed_certs"
    local tempdatafile="$TmpDir/cert.timeleft.$RANDOM.txt"
    for cert in $allcerts
    do
        local timeleft_sec=`$cert LifeLeft_sec valid`
        if [ "$timeleft_sec" != "no cert found" ];then
            echo "$cert=$timeleft_sec" >> $tempdatafile
        fi
    done
    if [ -f $tempdatafile ];then
        soonTobeRenewedCerts=`$grouplist "$tempdatafile" "$halfhour"`
        rm $tempdatafile
        rlPass "PASS : found [$soonTobeRenewedCerts]"
    else
        rlFail "FAIL : no cert found to test: [$soonTobeRenewedCerts]"
    fi
    rlPhaseEnd
}

prepare_preserv_dir()
{
    preservDir="/opt/preserve"
    if [ ! -d $preservDir ];then
        mkdir -p $preservDir
        echo "create preserv dir: [$preservDir]"
    fi
}

preserve_hosts()
{
    local original="/etc/hosts"
    local dest="$preservDir/hosts"
    preserve $original $dest
}

preserve_resolv_conf()
{
    local original="/etc/resolv.conf"
    local dest="$preservDir/resolv.conf"
    preserve $original $dest
}

preserve()
{
    local original=$1
    local dest=$2
    if cp -fv $original $dest
    then
        echo "preserv [$original] at [$dest] success"
    else
        echo "preserv [$original] failed"
    fi
}

restore_hosts()
{
    local original="/etc/hosts"
    local dest="$preservDir/hosts"
    restore $original $dest
}

restore_resolv_conf()
{
    local original="/etc/resolv.conf"
    local dest="$preservDir/resolv.conf"
    restore $original $dest
}

restore()
{
    local original=$1
    local dest=$2
    if cp -fv $dest $original
    then
        echo "restore [$dest] to [$original] success"
    else
        echo "restore [$original] failed"
    fi
}

continue_test(){
    if [ ! -f $testResult ];then
        touch $testResult
        echo "yes" # when test gets into first round, there is no testResult file exist, just echo 'yes' to continue test
    else
        local now=`date "+%s"`
        local distance=`echo "$caCertLimit - $now" | bc`
        if [ $distance -le $twoyears ];then
            echo "no"
        else
            if [ "`all_certs_are_valid`" = "yes" ];then
            # continue test till all certs are being renewed minRound times
                if [ $certRenewCounter -ge $minRound ];then
                    echo "no"
                else
                    echo "yes"
                fi
            else
                echo "no" # stop test if any invalid certs are found
            fi
        fi
    fi
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

final_cert_status_report(){
    # we continue test in the following 2 conditions
    # 1. all previous test results are 'pass'
    # 2. there are some certs haven't get chance to be renewed for 'minround' times
   
    # check condition 1:
    notRenewedCerts=`$difflist "$renewedCerts" "$allcerts"`
    local validCerts=`get_all_valid_certs`
    local notValid=`$difflist "$validCerts" "$allcerts"`
    echo ""
    echo "#############################################################################"
    echo "#             Final IPA Cert Status Report [ `date`]  #"
    echo "[all certs  ] [$allcerts]"
    echo "[valid certs] [$validCerts]"
    echo "[not valid  ] [$notValid]"
    list_all_ipa_certs
    for cert in $notValid
    do
        echo "   No valid certs found for [$cert], current date [`date`]"
        echo "Debug:" >> $certReport
        echo "   No valid certs found for [$cert], current date [`date`]" >> $certReport
        local db=`$cert db`
        local nickname=`$cert nickname`
        echo "      debug [certutil -L -d $db -n \"$nickname\"] "
        echo "certutil -L -d $db"
        certutil -L -d $db
        certutil -L -d $db >> $certReport
        echo "      debug [certutil -L -d $db -n \"$nickname\"] " >> $certReport
        certutil -L -d $db -n "$nickname" 2>&1 >> $certReport
        echo "      OR    [$readCert -d $db -n \"$nickname\" -s (preValid/valid/expired)]"
        echo "      OR    [$readCert -d $db -n \"$nickname\" -s (preValid/valid/expired)]" >> $certReport
        $readCert -d $db -n "$nickname" -s expired >> $certReport
        #print_cert_details "     " $cert preValid
        print_cert_details "     " $cert expired
    done
    test_status_report
    echo "#---------------------------------------------------------------------------#"
    echo "       cert report for each round of test [`date`]"
    echo "#---------------------------------------------------------------------------#"
    local reportCounter=1
    while [ $reportCounter -le $testroundCounter ]
    do
        local report="$TmpDir/cert.report.$reportCounter.txt"
        if [ -f $report ];then
            echo "[- Begining of Cert reort: [$report] ------]"
            cat $report
            echo "[- END OF Cert report    : [$report] ------]"
        else
            echo "cert report: $report does not exist, this is not considerded as an error"
        fi
        reportCounter=$((reportCounter + 1 ))
    done
    if [ "`all_certs_are_valid`" = "no" ];then
        debuginfo
    else
        echo "No invalid certs found"
    fi
    #echo "getcert list output:"
    #getcert list
}

debuginfo()
{
    local nLines=300
    for log in $logs
    do
        echo ""
        echo "============ last $nLines lines of $log ==================="
        tail -n $nLines $log
        echo ""
    done
    echo "================ specific for certmonger : grep certmonger from /var/log/message* =========="
    tail -n $nLines /var/log/messages* | grep -i "certmonger"
    echo "===================== END OF CERTMONGER messages in /var/log/message* ======================"
}

all_certs_are_valid(){
    local all_are_valid="yes"
    local current_valid_certs=""
    for cert in $allcerts
    do
        local state=`$cert status valid`
        if [ "$state" = "valid" ];then
            current_valid_certs="$current_valid_certs $cert " #collect current valid certs
        fi
    done 
    # all certs should appear in this collected current valid cert string
    for cert in $allcerts
    do
        if ! echo "$current_valid_certs" | grep "$cert" 2>&1 > /dev/null
        then
            all_are_valid="no"
        fi
    done
    echo $all_are_valid
}

print_test_header(){
    echo " "
    echo "      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#"
    echo "      #                    test round [$testroundCounter]                       #"
    echo "      #                (minRound=$minRound, counter=$certRenewCounter)                  #"
    echo "      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#"
}

test_ipa_via_kinit_as_admin(){
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - test_ipa_via_kinit_as_admin ($@)"
    local pw=$ADMINPW #use the password in env.sh file
    rlLog "[test_ipa_via_kinit_as_admin] test with password: [$pw]: echo $pw | kinit $ADMINID"
    local out=`echo $pw | kinit $ADMINID 2>&1`
    echo $pw | kinit $ADMINID
    if [ $? = 0 ];then
        rlPass "[test_ipa_via_kinit_as_admin] kinit as $ADMINID with [$pw] success, output=[$out]"
        echo "    [ PASS ] test_ipa_via_kinit_as_admin ($@)" >> $testResult
    elif [ $? = 1 ];then
        echo "[test_ipa_via_kinit_as_admin] first try of kinit as $ADMINID with [$pw] failed"
        echo "[test_ipa_via_kinit_as_admin] check ipactl status"
        ipactl status
        if echo $out | grep -i "kinit: Generic error (see e-text) while getting initial credentials"
        then
            echo "[test_ipa_via_kinit_as_admin] got kinit: Generic error, restart ipa and try same password again"
            ipactl restart
            $kdestroy
            echo $pw | kinit $ADMINID 2>&1 > $out
            if [ $? = 0 ];then
                rlPass "[test_ipa_via_kinit_as_admin] kinit as $ADMINID with [$pw] success at second attempt -- after restart ipa"
                echo "    [ PASS ] test_ipa_via_kinit_as_admin ($@)" >> $testResult
                return
            else
                rlLog "[test_ipa_via_kinit_as_admin] kinit as $ADMINID with [$pw] failed at second attempt -- after restart ipa, continue trying"
            fi
        fi
            
        echo "[test_ipa_via_kinit_as_admin] password [$pw] failed, check whether it is because password expired"
        echo "#------------ output of [echo $pw | kinit $ADMINID] ----------#"
        echo $out
        echo "#----------------------------------------------------------------#"
        if echo $out | grep -i "Password expired" 2>&1 >/dev/null
        then
            echo "$ADMINID password exipred, do reset process"
            local exp=$TmpDir/reset.admin.password.$RANDOM.exp
            local temppw="New_$pw"
            kinit_aftermaxlife "$ADMINID" "$ADMINPW" "$temppw"
            # set password policy to allow $ADMINID change password right away
            local minlife=`ipa pwpolicy-show | grep "Min lifetime" | cut -d":" -f2| xargs echo`
            local history=`ipa pwpolicy-show | grep "History size" | cut -d":" -f2| xargs echo`
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
                echo "    [ FAIL ] * test_ipa_via_kinit_as_admin ($@)" >> $testResult
            else
                rlPass "[test_ipa_via_kinit_as_admin] reset password success"
                echo "    [ PASS ] test_ipa_via_kinit_as_admin ($@)" >> $testResult
                ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --minlife=$minlife --history=$history --minclasses=$classes
                echo "[test_ipa_via_kinit_as_admin] set $ADMINID password back to [$pw] success -- after set to temp"
            fi
        elif echo $out | grep -i "Password incorrect while getting initial credentials" 
        then
            rlFail "[test_ipa_via_kinit_as_admin] wrong $ADMINID password provided: [$pw]"
            echo "   [ FAIL ] * test_ipa_via_kinit_as_admin ($@)" >> $testResult
        elif echo $out | grep -i "kinit: cannot contact any KDC for realm"
        then
            rlLog "catch cannot contact KDC error, restart ipa and try again"
            ipactl restart
            rlRun "echo $pw | kinit $ADMINID" 0 "try again pw=[$pw], adminid=[$ADMINID]"
        else
            rlFail "[test_ipa_via_kinit_as_admin] unhandled error: Not because password expired; not because wrong password provided; also tried restart ipa but didnot work"
            echo "    [ FAIL ] * test_ipa_via_kinit_as_admin ($@)" >> $testResult
        fi
    else
        rlFail "[test_ipa_via_kinit_as_admin] unknow error, return code [$?] not recoginzed"
        echo "    [ FAIL ] * test_ipa_via_kinit_as_admin ($@)" >> $testResult
    fi
    rlPhaseEnd
}

kinit_aftermaxlife()
{
    local username=$1
    local pw=$2
    local newpw=$3
    local exp=$TmpDir/kinitaftermaxlife.$RANDOM.exp
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
    /usr/bin/expect $exp

    echo "kinit as [$username] with new password [$newpw]"
    echo $newpw | kinit $username
    if [ "$?" = "0" ];then
        echo "[kinit_aftermaxlife] kinit success"
    else
        echo "[kinit_aftermaxlife] kinit failed, please check the exp file"
        echo "#------ [kinit_aftermaxlife] exp file -------#" 
        cat $exp
        echo "#----------- ipactl status -------------------#"
        ipactl status
        echo "#---------------------------------------------#"
    fi
    rm $exp
} #kinit_aftermaxlife

record_cert_expires_epoch_time()
{
    if [ ! -f $certdata_notafter ];then
        touch $certdata_notafter
    fi
    echo "current date [`date`]" > $certdata_notafter
    for cert in $allcerts
    do
        local notafter_sec=`$cert NotAfter_sec valid`
        local notafter=`$cert NotAfter valid`
        echo "$cert $notafter_sec = $notafter"  >> $certdata_notafter
    done
    echo "#--------------- record NotAfter_sec of current certs --------------#"
    cat $certdata_notafter
    echo "#-------------------------------------------------------------------#"
}

compare_expires_epoch_time_of_certs()
{
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - compare epoch time of certs expires date round [$testroundCounter]"
    if [ ! -f $certdata_notafter ];then
        rlFail "no epoch time of certs expires data file fouond, error!"
    else
        echo "#--------------- recorded: expires date in eopch time of current certs -----------#"
        cat $certdata_notafter
        echo "#---------------------------------------------------------------------------------#"
        #rlLog "before: justRenewedCerts=[$justRenewedCerts], should be empty"
        for cert in $allcerts
        do
            local currentNotAfter=`$cert NotAfter_sec valid`
            if [ "$currentNotAfter" = "no cert found" ];then
                rlFail "No valid cert found for [$cert], current date:[`date`]"
                echo "    [ FAIL ] * compare_expires_epoch_time_of_certs: [$cert] has no valid cert" >> $testResult
                local db=`$cert db`
                local nickname=`$cert nickname`
                echo "certutil -L -d $db"
                certutil -L -d $db
                echo "certutil -L -d $db -n \"$nickname\""
                certutil -L -d $db -n "$nickname"
            else
                local previousNotAfter=`grep "$cert" $certdata_notafter | cut -d" " -f2`
                local previousNotAfterDate=`grep "$cert" $certdata_notafter | cut -d"=" -f2`
                local currentNotAfterDate=`$cert NotAfter valid`
                if [ $currentNotAfter -gt $previousNotAfter ];then
                    justRenewedCerts="${justRenewedCerts}${cert} " #append spaces at end
                    #rlLog "add cert [$cert] into queue: justRenewedCerts [${justRenewedCerts}]"
                    rlPass "$cert gets renewed, 'not after' values:  previous: [$previousNotAfter] now: [$currentNotAfterDate]"
                    echo "    [ PASS ] compare_expires_epoch_time_of_certs: [$cert], currentNotAfter=[$currentNotAfterDate], previousNotAfter=[$previousNotAfterDate] " >> $testResult
                elif [ $currentNotAfter -eq $previousNotAfter ];then
                    rlLog "$cert haven't get renewed, previous 'not after' values: previous [$previousNotAfterDate] is not changed now: [$currentNotAfterDate]"
                else
                    echo "    [ FAIL ] * compare_expires_epoch_time_of_certs: [$cert], currentNotAfter=[$currentNotAfter $currentNotAfterDate], previousNotAfter=[$previousNotAfter $previousNotAfterDate] " >> $testResult
                    rlFail "compare_expires_epoch_time_of_certs: [$cert], currentNotAfter=[$currentNotAfter $currentNotAfterDate], previousNotAfter=[$previousNotAfter $previousNotAfterDate]"
                fi
            fi
        done 
        #rlLog "after: justRenewedCerts=[$justRenewedCerts]"
    fi
    rlPhaseEnd
}

test_dirsrv_via_ssl_based_ldapsearch(){
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - test_dirsrv_via_ssl_based_ldapsearch ($@)"
    # doc: http://directory.fedoraproject.org/wiki/Howto:SSL#Use_ldapsearch_with_SSL
    local testCMD="$ldapsearch -H ldaps://$host -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -s base -b \"\" objectclass=* | grep \"vendorName:\" "
    rlLog "test command: $testCMD"
    $ldapsearch -H ldaps://$host -x -D "$ROOTDN" -w "$ROOTDNPWD" -s base -b "" objectclass=* | grep "vendorName:" 
    if [ "$?" = "0" ];then
        rlPass "[test_dirsrv_via_ssl_based_ldapsearch] Test Pass"
        echo "    [ PASS ] test_dirsrv_via_ssl_based_ldapsearch ($@)" >> $testResult
    else
        rlFail "[test_dirsrv_via_ssl_based_ldapsearch] Test Failed"
        echo "    [ FAIL ] * test_dirsrv_via_ssl_based_ldapsearch ($@)" >> $testResult
    fi
    echo ""
    rlPhaseEnd
}

test_dogtag_via_cert_show(){
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - test_dogtag_via_cert_show ($@)"
    local certid=1
    local testCMD="ipa cert-show $certid | grep 'Certificate:'"
    rlLog "test command : $testCMD"
    ipa cert-show $certid | grep 'Certificate:'
    if [ "$?" = "0" ];then
        rlPass "[test_dogtag_via_cert_show] Test Pass"
        echo "    [ PASS ] test_dogtag_via_cert_show ($@)" >> $testResult
    else
        rlFail "[test_dogtag_via_cert_show] Test Failed"
        echo "    [ FAIL ] * test_dogtag_via_cert_show ($@)" >> $testResult
        echo "=========== $log_httpd ========="
        tail -n 50 $log_httpd
        echo "=========== $log_sys ========="
        tail -n 50 $log_sys
        echo "=========== $log_pkica ======="
        tail -n 50 $log_pkica
        echo " ========== certutil -L -d /var/lib/$CAINSTANCE/alias ============="
        certutil -L -d /var/lib/$CAINSTANCE/alias
        echo "=============================="   
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

test_ipa_via_creating_new_cert(){
    rlPhaseStartTest "autorenewcert round [$testroundCounter] - test_ipa_via_creating_new_cert ($@)"
    local serviceName=testservice_$RANDOM
    local certRequestFile=$TmpDir/certreq.$RANDOM.csr
    local certPrivateKeyFile=$TmpDir/certprikey.$RANDOM.key
    local principal=$serviceName/$host
    echo "certreq    [$certRequestFile]"
    echo "privatekey [$certPrivateKeyFile]"
    echo "principal  [$principal]"

    #requires : kinit as admin to success 
    echo "[step 1/4] create/add a host this should already done : use existing host $host"
    if ipa host-find $host | grep -i "Host name: $host"
    then
        rlPass "found [$host] in ipa server"
    else
        rlFail "[$host] not found in ipa server"
    fi
    echo "[step 2/4] add a test service add service: [$principal], sometimes there are some random failures for this"
    local serviceAddResult=`ipa service-add $principal 2>&1`
    if echo $serviceAddResult | grep "Added service" 
    then
        echo "[step 2/4 result] success, service [$principal] added"
        rlPass "service [$principal] added"
    elif echo $serviceAddResult | grep -i "Host does not have corresponding DNS A record"
    then
        echo "[step 2/4 result] failed:, it reports no DNS A record, weird, try same command again"
    	digDNSerror "$host"
        ipa dnsrecord-find $DOMAIN
        ipa service-add $principal
        if [ $? = 0 ];then
            echo "[step 2/4 second try] success, gosh.."
            rlPass "create service [$principal] success"
        else
            echo "[step 2/4 second try] still failed, report failure"
            rlFail "create service [$principal] failed"
            debuginfo
        fi
    else
        rlFail "unknow error for step 2/4, add service, need more work here"
        debuginfo
    fi
        
    echo "[step 3/4] create a cert request"
    create_cert_request_file $certRequestFile $certPrivateKeyFile
    if [ "$?" = "0" ];then
        rlPass "cert file creation success, continue"
    else
        rlFail "cert file creation failed, return fail"
        echo "    [ FAIL ] * test_ipa_via_creating_new_cert ($@)" >> $testResult
        return
    fi

    echo "[step 4/4] process cert request"
    ipa cert-request --principal=$principal $certRequestFile 
    if [ $? = 0 ];then
        rlPass "customer cert create success, test pass"
        echo "    [ PASS ] test_ipa_via_creating_new_cert ($@)" >> $testResult
    else
        rlFail "customer cert create failed, test failed"
        echo "    [ FAIL ] * test_ipa_via_creating_new_cert ($@)" >> $testResult
    fi
    rlPhaseEnd
}

create_cert_request_file()
{
    local requestFile=$1
    local keyFile=$2
    # command to use:
    local certCmd="openssl req -out $requestFile -new -newkey rsa:2048 -nodes -keyout $keyFile"
    local exp=$TmpDir/createCertRequestFile.$RANDOM.exp  # local test

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

digDNSerror()
{
    local dig_hostname=$1
    echo "================= dig DNS error ==================="
    echo "#---------- dig -t ANY testrelm.com ---------------"
    dig -t ANY testrelm.com

    echo "#---------- dig -t ANY [$dig_hostname] ---------------"
    dig -t ANY $dig_hostname
   
    echo "------------------ log & conf file content --------"
    for file in /etc/resolv.conf /etc/hosts  /etc/named.conf 
    do
        echo "#---------- file [$file] ---------------#"
        cat $file 
        echo "#---------------------------------------#"
    echo "============== end of dig DNS error ==============="
    done
}

distanceToCAcertLimit()
{
    local now=`date "+%s"`
    local distance=`echo "$caCertLimit - $now" | bc`
    local distance_str=`$timeverter $distance`
    echo $distance_str
}

list_certutil_status()
{
    local label=$@
    echo "============ ($label) ==============="   
    echo " certutil -L -d /var/lib/$CAINSTANCE/alias "
    certutil -L -d /var/lib/$CAINSTANCE/alias
    certutil -L -d  /var/lib/$CAINSTANCE/alias -n "auditSigningCert cert-pki-ca"
    echo "======= report date [`date`] ========="
}

certutil_attributes()
{
    local label=$1
    local file=$2
    echo "============ ($label) ==============="   
    echo " certutil -L -d /var/lib/$CAINSTANCE/alias for each cert"
    for cert in $cert_list
    do
      certutil -L -d /var/lib/$CAINSTANCE/alias | grep $cert | awk '{print $1" "$2" "$3}' | sort | uniq >> $file
    done
    cat $file
    echo "======= report date [`date`] ========="
}

adjust_to_renew() {
   local currentdate=`date`
   rlRun "echo \"Current date and time: $currentdate\""
   local Certrnwdate="`certutil -L -d /var/lib/pki-ca/alias -n "Server-Cert cert-pki-ca" | grep -i "Not After" | awk '{print $5" "$6" "$7" "$8}'` yesterday"
   rlRun "date -s \"$Certrnwdate\"" 0 "Date reset to 1 day before certificate expiry"
   rlRun "echo \"New date and time: `date`\""
}
