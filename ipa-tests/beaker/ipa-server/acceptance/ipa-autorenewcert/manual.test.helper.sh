#!/bin/bash
# this is a helper tool for autorenew cert manual test. Please check the test plan for details
# by yzhang@redhat.com
# Sept. 5, 2012

. ./lib.autorenewcert.sh

# calculate dynamic variables
host=`hostname`
CAINSTANCE="pki-ca"
DSINSTANCE="`find_dirsrv_instance ds`"
CA_DSINSTANCE="`find_dirsrv_instance ca`"
testid="manual test"
TmpDir="/tmp"

echo "------ manual test helper ---------"
list_all_ipa_certs
echo "find_soon_to_be_renewed_certs"
    tempdatafile="$TmpDir/cert.timeleft.$RANDOM.txt"
    for cert in $allcerts
    do
        timeleft_sec=`$cert LifeLeft_sec valid`
        if [ "$timeleft_sec" != "no cert found" ];then
            echo "$cert=$timeleft_sec" >> $tempdatafile
        fi
    done
    if [ -f $tempdatafile ];then
        soonTobeRenewedCerts=`$grouplist "$tempdatafile" "$halfhour"`
        rm $tempdatafile
        echo "PASS : found [$soonTobeRenewedCerts]"
    else
        echo "FAIL : no cert found to test: [$soonTobeRenewedCerts]"
    fi

echo calculate_autorenew_date $soonTobeRenewedCerts
    group=$soonTobeRenewedCerts
    after=`get_not_after_sec valid $group`
    after_min=`min $after`
    after_max=`max $after`
    current_epoch=`date +%s`
    certExpire=`min $after`
    preAutorenew=`echo "$certExpire - $oneday" | bc`
    autorenew=`echo "$certExpire - $sixdays" | bc`
    postAutorenew=`echo "$certExpire - $halfhour " | bc`
    postExpire=`echo "$certExpire + $halfday" | bc`
    echo "     current date :" `date` "($current_epoch)"
    echo "     autorenew    :" `convert_epoch_to_date $autorenew` " ($autorenew)"  
    echo "     postAutorenew:" `convert_epoch_to_date $postAutorenew` " ($postAutorenew)"  
    echo "     certExpire   :" `convert_epoch_to_date $certExpire` " ($certExpire)" 
    echo "     postExpire   :" `convert_epoch_to_date $postExpire` " ($postExpire)" 
    echo ""
    if [ $current_epoch -lt $autorenew ] \
        && [ $autorenew -lt $certExpire ] \
        && [ $certExpire -lt $postExpire ]
    then
        echo "Pass: got reasonable autorenew time"
        echo "    adjust to autorenew    : 'date -s '`convert_epoch_to_date $autorenew`'"
        echo "    adjust to postAutorenew: 'date -s '`convert_epoch_to_date $postAutorenew`'"
        echo "    adjust to postExpire   : 'date -s '`convert_epoch_to_date $postExpire`'"
        echo ""
    else
        echo "Fail: something wrong, date are not well ordered"
    fi
