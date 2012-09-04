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

# calculate dynamic variables
host=`hostname`
CAINSTANCE="pki-ca"
DSINSTANCE="`find_dirsrv_instance ds`"
CA_DSINSTANCE="`find_dirsrv_instance ca`"


cert_sanity_check(){
    test_ipa_via_kinit_as_admin "$@"
    test_dirsrv_via_ssl_based_ldapsearch "$@"
    test_dogtag_via_cert_show "$@"
    test_ipa_via_creating_new_cert "$@"
}

autorenewcert()
{
        print_test_header
        cert_sanity_check "Before auto renew triggered"

        calculate_autorenew_date $soonTobeRenewedCerts

        stop_ipa_server "Before autorenew"
        adjust_system_time $autorenew autorenew    
        start_ipa_server "After autorenew"

        go_to_sleep

        stop_ipa_server "Before postExpire"
        adjust_system_time $postExpire postExpire
        start_ipa_server "After postExpire"

        check_actually_renewed_certs $soonTobeRenewedCerts
        compare_expected_renewal_certs_with_actual_renewed_certs "After postExpire"

        cert_sanity_check  "After auto renew triggered"
        test_status_report 
}

############## main test #################
main_autorenewcert_test(){
    testid=1
    fix_prevalid_cert_problem #weird problem
    # conditions for test to continue (continue_test returns "yes")
    # 1. all ipa certs are valid
    # 2. if there are some certs haven't get chance to be renewed, test should be continue

    while [ "`continue_test`" = "yes" ]
    do
        echo "" > $testResult  # reset test result from last round
        list_all_ipa_certs
        find_soon_to_be_renewed_certs
        autorenewcert $round
        prepare_for_next_round
        testid=$((testid + 1))
        #fix_prevalid_cert_problem #weird problem
    done
    final_cert_status_report 
}
################ end of main ###########
