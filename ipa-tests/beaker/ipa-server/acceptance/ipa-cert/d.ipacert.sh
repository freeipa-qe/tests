#!/bin/bash
# bug verification automation for ipa cert 

. ./buglib.ipacert.sh

bug_automation()
{
    bug_866955
}

bug_866955()
{
    local bugid="866955"
    rlPhaseStartTest "ipa-cert-bugzilla-001: bz$bugid unable to sign certificate request by IPA , when csr has subjectAltnames"
        local openssl_cnf="$TmpDir/openssl.${bugid}.cnf"
        local altname=`hostname`
        create_openssl_cnf $openssl_cnf $altname
        #create_cert_request
        openssl req -out server.csr -new -newkey rsa:2048 -nodes -keyout server.key -config $openssl_cnf

        #assign_the_request
        KinitAsAdmin
        rlRun "ipa cert-request server.csr --principal=HTTP/$altname --add" 0 "assign the request with altname"
    rlPhaseEnd
}
