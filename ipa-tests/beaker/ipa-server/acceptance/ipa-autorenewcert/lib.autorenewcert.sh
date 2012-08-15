#!/bin/bash

# prepare for storage directories for autorenew cert test
TmpDir="/tmp"
testid=$RANDOM
testdir="$TmpDir/autorenewcert/$testid"
currentCertDir="$testdir/current"
renewalCertDir="$testdir/renewal"
if [ ! -d $testdir ];then
    mkdir -p $testdir
    mkdir $currentCertDir
    mkdir $renewalCertDir
    echo "cert storage: current [$currentCertDir] renewal: [$renewalCertDir]"
fi

# assumption constances, need work FIXME
CAINSTANCE="pki-ca"
DSINSTANCE="YZHANG-REDHAT-COM"
CA_DSINSTANCE="PKI-IPA"
DN="cn=directory manager"

# constance used for cert autorenew test
oneday=86400 
halfday=43200
onehour=3600
halfhour=1800
wait4renew=30
maxwait=`echo "$wait4renew * 3" | bc`

# helping tools used for this test
dir=$( cd "$( dirname "$0" )" && pwd )
readCert="$dir/readCert.pl"
readRenewalCert="$dir/readRenewalCertsInLDAP.pl"

# cert names
groupA="oscpSubsystemCert caSSLServiceCert caSubsystemCert caAuditLogCert ipaRAagentCert"
groupB="ipaServiceCert_ds ipaServiceCert_pki ipaServiceCert_httpd"
groupC="caJarSigningCert"
allTestCerts="$groupA $groupB $groupC"


oscpSubsystemCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="ocspSigningCert cert-$CAINSTANCE"
    if [ "$1" = "nickname" ];then
        echo $nickname
    else
        $readCert -d $db -n "$nickname" -p "$1"
    fi
}

caSSLServiceCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="Server-Cert cert-$CAINSTANCE"
    if [ "$1" = "nickname" ];then
        echo $nickname
    else
        $readCert -d $db -n "$nickname" -p "$1"
    fi
}

caSubsystemCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="subsystemCert cert-$CAINSTANCE"
    if [ "$1" = "nickname" ];then
        echo $nickname
    else
        $readCert -d $db -n "$nickname" -p "$1"
    fi
}

caAuditLogCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="auditSigningCert cert-$CAINSTANCE"
    if [ "$1" = "nickname" ];then
        echo $nickname
    else
        $readCert -d $db -n "$nickname" -p "$1"
    fi
}

ipaRAagentCert(){
    local db="/etc/httpd/alias"
    local nickname="ipaCert"
    if [ "$1" = "nickname" ];then
        echo $nickname
    else
        $readCert -d $db -n "$nickname" -p "$1"
    fi
}

ipaServiceCert_ds(){
    local db="/etc/dirsrv/slapd-$DSINSTANCE"
    local nickname="Server-Cert"
    if [ "$1" = "nickname" ];then
        echo $nickname
    else
        $readCert -d $db -n "$nickname" -p "$1"
    fi
}

ipaServiceCert_pki(){
    local db="/etc/dirsrv/slapd-$CA_DSINSTANCE"
    local nickname="Server-Cert"
    if [ "$1" = "nickname" ];then
        echo $nickname
    else
        $readCert -d $db -n "$nickname" -p "$1"
    fi
}

ipaServiceCert_httpd(){
    local db="/etc/httpd/alias"
    local nickname="Server-Cert"
    if [ "$1" = "nickname" ];then
        echo $nickname
    else
        $readCert -d $db -n "$nickname" -p "$1"
    fi
}

caJarSigningCert(){
    local db="/etc/httpd/alias"
    local nickname="Signing-Cert"
    if [ "$1" = "nickname" ];then
        echo $nickname
    else
        $readCert -d $db -n "$nickname" -p "$1"
    fi
}

listCurrentCerts(){
    echo "[current loaded cert list]"
    for cert in $@
    do
        local nickname=`$cert nickname`
        local serial=`$cert serial`
        local notBefore=`$cert NotBefore_sec`
        local notAfter=`$cert NotAfter_sec`
        local fp_cert=`perl -le "print sprintf (\"%-20s\",$cert)"`
        local fp_nickname=`perl -le "print sprintf (\"%-30s\",\"$nickname\")"`
        local fp_serial=`perl -le "print sprintf (\"%-2d\",$serial)"`
        echo -n "$fp_cert #$fp_serial: "
        echo "[`$cert NotBefore` ($notBefore)] - [`$cert NotAfter` ($notAfter)] [`$cert Life`] [$fp_nickname]"
    done
    echo "============================================"
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
        local notBefore_epoch=`$cert "NotBefore_sec"`
        notBefore="$notBefore $notBefore_epoch"
    done
    echo $notBefore
}

getNotAfter(){
    local notAfter=""
    for cert in $@
    do
        local notAfter_epoch=`$cert "NotAfter_sec"`
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

calculateCriticalPeriod(){
    local group=$@
    #listCerts $group
    
    local after=`getNotAfter $group`
    local after_min=`min $after`
    local after_max=`max $after`
    #local adjust=`echo $after - $halfday | bc`
    #echo "before: $before = " `epochToDate $before`
    echo "after : $after  = $after"
    echo "after min : $after_min  = " `epochToDate $after_min`
    echo "after max : $after_max  = " `epochToDate $after_max`
    certExpire=`min $after`
    preAutorenew=`echo "$certExpire - $oneday" | bc`
    autorenew=`echo "$certExpire - $halfday" | bc`
    postAutorenew=`echo "$certExpire - $halfhour " | bc`
    postExpire=`echo "$certExpire + $halfday" | bc`
    echo "preAutorenew :" $preAutorenew " = "  `epochToDate $preAutorenew`
    echo "autorenew    :" $autorenew " = "  `epochToDate $autorenew`
    echo "postAutorenew:" $postAutorenew " = "  `epochToDate $postAutorenew`
    echo "certExpire   :" $certExpire " = "  `epochToDate $certExpire`
    echo "postExpire   :" $postExpire " = "  `epochToDate $postExpire`
}

#calculateCriticalPeriod $groupA
#calculateCriticalPeriod $groupB
#calculateCriticalPeriod $groupC

certSanityCheck(){
    echo certSanityCheck need work
}

adjustSystemTime(){
    local adjustTo=$1
    stopIPA
    echo "adjust system time to [$adjustTo]" `epochToDate $adjustTo`
    echo "before adjust: [`date`]"
    date "+%a %b %e %H:%M:%S %Y" -s "`perl -le "print scalar localtime $adjustTo"`" 2>&1 > /dev/null
    echo "after  adjust: [`date`]"
    startIPA
}

stopIPA(){
    echo "-------------------------- "
    ipactl stop
    echo "-------------------------- "
}

startIPA(){
    echo "-------------------------- "
    ipactl start
    echo "-------------------------- "
}

verifyAutorenewTriggering(){
    local group=$@
    local waittime=0
    until ldapsearch -D "cn=directory manager" -w Secret123 -b "cn=ca_renewal,cn=ipa,cn=etc,dc=yzhang,dc=redhat,dc=com" | grep "numEntries: 5" || [ $waittime -gt $maxwait ]
    do
        echo "sleep $wait4renew seconds so auto renew will be triggered"
        sleep $wait4renew
        waittime=$((waittime + $wait4renew))
    done
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

verifyRenewedCerts(){
    local group=$@
    for cert in $group
    do
        echo "verify cert: [$cert]"
        echo "  nickname: " `$cert nickname`
        local current_serial=`$cert serial`

        local renewal_certfile="$renewalCertDir/$cert.cert"
        if [ -f $renewal_certfile ];then
            echo "  check renewal cert file [$renewal_certfile]"
            local renewal_serial=`grep serial $renewal_certfile | cut -d"=" -f2`
            if [ $renewal_serial = $current_serial ];then
                echo "PASS: serial number matches"
            else
                echo "  renewal serial  :[$renewal_serial]"
                echo "  currently loaded:[$current_serial]"
                echo "ERROR: test failed, the serial number is different"
            fi
        else
            echo "ERROR:cert [$cert] has no renewal cert in ldap server"
        fi
    done
}

pause(){
    local choice="y"
    echo -n "continue? (y/n) "
    read choice
    if [ "$choice" = "n" ];then
        exit
    fi
}
