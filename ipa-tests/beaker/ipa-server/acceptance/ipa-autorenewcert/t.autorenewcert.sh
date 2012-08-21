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

autorenewcert()
{
#    certSanityCheck     # FIXME: not sure what it should be
    local certsShouldBeRenewed=$@
    calculating_critical_period $certsShouldBeRenewed
    adjust_system_time $autorenew autorenew    
    go_to_sleep_so_certmonger_has_chance_to_trigger_renewal_action
    adjust_system_time $postExpire postExpire
    check_which_cert_is_actually_renewed $certsShouldBeRenewed
    report_cert_renewal_result
#    certSanityCheck 
}

#list_all_ipa_certs

check_test_condition
while [ $continueTest = "yes" ]
do
    #pause
    find_soon_to_be_renewed_certs
    autorenewcert $soonTobeRenewedCerts
    save_certs_that_just_being_renewed
    check_test_condition
done

# after test, all certs still have to have 'valid' certs
