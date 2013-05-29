#!/bin/bash
# bug verification automation for ipa cert 

. ./buglib.ipacert.sh

bug_automation()
{
    bug_866955
    bug_964128
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

bug_964128() {

rlPhaseStartTest "LDAP upload CA cert sometimes double-encodes the value bz964128"
	Sfile1="$TmpDir/sfile1"
	Sfile2="$TmpDir/sfile2"
	DS_binddn="CN=Directory Manager"
	Base_DN="cn=CAcert,cn=ipa,cn=etc,dc=testrelm,dc=com"
	rlRun "ldapsearch -x -D \"$DS_binddn\" -w $ADMINPW -b \"$Base_DN\" > $Sfile1" 0 "ldapsearch for Cert"
	rlRun "ldapdelete -x -D \"$DS_binddn\" -w $ADMINPW \"$Base_DN\"" 0 "ldap delete cert"
	rlRun "ldapsearch -x -D \"$DS_binddn\" -w $ADMINPW -b \"$Base_DN\"" 32 "Making sure cert is deleted"
	rlRun "echo $ADMINPW | ipa-ldap-updater --plugins" 0 "Running ldap-updater with --plugins"
	rlRun "ldapsearch -x -D \"$DS_binddn\" -w $ADMINPW -b \"$Base_DN\" > $Sfile2" 0 "ldapsearch for Cert after ldap-updater"
	rlAssertNotDiffer "$Sfile1" "$Sfile2"
	[ $? -eq 0 ] && rlPass "CA cert is not double-encoded"
	
rlPhaseEnd
}
