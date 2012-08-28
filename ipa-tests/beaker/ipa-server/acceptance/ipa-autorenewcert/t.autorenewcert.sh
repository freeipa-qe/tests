#!/bin/bash
######################################################
# test suite  : ipa-autorenewcert
# description : IPA auto-renew certificate test suite
# created by  : Yi Zhang (yzhang@redhat.com)
# created date: Tue Aug  7 09:37:45 PDT 2012
######################################################

# time period used in this test
# [pre-autorenew] [auto-renew] [ post-autorenew] [ certs expiration time ] [postExpire]
# preAutorenew  : before auto renew being triggered
# autorenew     : 1 day to 1 hour before cert expires
# postAutorenew : after autorenew period but before certs expires
# certExpire    : exact point when certs expires
# postExpire    : after cert expires

. ./lib.autorenewcert.sh

certSanityCheck(){
    test_ipa_via_kinit_as_admin
    test_dirsrv_via_ssl_based_ldapsearch
    test_dogtag_via_getcert
}

autorenewcert()
{
    certSanityCheck     # FIXME: not sure what it should be
    local certsShouldBeRenewed=$@
    calculate_autorenew_date $certsShouldBeRenewed
    adjust_system_time $autorenew autorenew    
    go_to_sleep
    adjust_system_time $postExpire postExpire
    check_actually_renewed_certs $certsShouldBeRenewed
    report_test_result
    certSanityCheck 
}

############## main test #################

round=1
fix_prevalid_cert_problem #weird problem
# conditions for test to continue (continue_test returns "yes")
# 1. all ipa certs are valid
# 2. if there are some certs haven't get chance to be renewed, test should be continue

while [ "`continue_test`" = "yes" ]
do
    print_test_header $round
    list_all_ipa_certs
    find_soon_to_be_renewed_certs
    #pause
    autorenewcert $soonTobeRenewedCerts
    #pause
    record_just_renewed_certs
    report_renew_status
    round=$((round + 1))
    fix_prevalid_cert_problem #weird problem
done

if [ "$checkTestConditionRequired" = "true" ];then
    echo "check test condition"
    check_test_condition 
fi

################ end of main ###########
