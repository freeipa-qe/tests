#!/bin/bash
#testsuite : ipa-getcert
#author    : Yi Zhang (yzhang@redhat.com)
#testplan  : IPA client tool ipa-getcert Test Plan
#testplan version: 0.02
#last update time: 2011-04-26 14:20:27
#sequence number : 1

ipagetcert() #total test cases: 203
{
#    request
#    start_tracking
    stop_tracking
#    resubmit
#    list
#    list_cas
} #ipagetcert

request()
{ #total test cases: 81
    request_envsetup
    request_1001	#scenario: [ipa-getcert request -d -n]	data: [NSSDBDIR negative]
    request_1002	#scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [NSSDBDIR negative]
    request_1003	#scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [NSSDBDIR negative]
    request_1004	#scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [NSSDBDIR negative]
    request_1005	#scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [NSSDBDIR negative]
    request_1006	#scenario: [ipa-getcert request -d -n]	data: all positive
    request_1007	#scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [CertTokenName negative]
    request_1008	#scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [CertTokenName negative]
    request_1009	#scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [CertTokenName negative]
    request_1010	#scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [CertTokenName negative]
    request_1011	#scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [CertRequestNickName negative]
    request_1012	#scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [CertRequestNickName negative]
    request_1013	#scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1014	#scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1015	#scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: all positive
    request_1016	#scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1017	#scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1018	#scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: all positive
    request_1019	#scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [CertKeySize negative]
    request_1020	#scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [CertKeySize negative]
    request_1021	#scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1022	#scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1023	#scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: all positive
    request_1024	#scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1025	#scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1026	#scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: all positive
    request_1027	#scenario: [ipa-getcert request -k -f]	data: [PemKeyFile negative]
    request_1028	#scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [PemKeyFile negative]
    request_1029	#scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [PemKeyFile negative]
    request_1030	#scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [PemKeyFile negative]
    request_1031	#scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [PemKeyFile negative]
    request_1032	#scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [PemKeyFile negative]
    request_1033	#scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [PemKeyFile negative]
    request_1034	#scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [PemKeyFile negative]
    request_1035	#scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [PemKeyFile negative]
    request_1036	#scenario: [ipa-getcert request -k -f]	data: [PemCertFile negative]
    request_1037	#scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [PemCertFile negative]
    request_1038	#scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [PemCertFile negative]
    request_1039	#scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [PemCertFile negative]
    request_1040	#scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [PemCertFile negative]
    request_1041	#scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [PemCertFile negative]
    request_1042	#scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [PemCertFile negative]
    request_1043	#scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [PemCertFile negative]
    request_1044	#scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [PemCertFile negative]
    request_1045	#scenario: [ipa-getcert request -k -f]	data: all positive
    request_1046	#scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [CertRequestNickName negative]
    request_1047	#scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [CertRequestNickName negative]
    request_1048	#scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1049	#scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1050	#scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: all positive
    request_1051	#scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1052	#scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1053	#scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: all positive
    request_1054	#scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [CertKeySize negative]
    request_1055	#scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [CertKeySize negative]
    request_1056	#scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1057	#scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1058	#scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: all positive
    request_1059	#scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1060	#scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1061	#scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: all positive
    request_1062	#scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [PINFILE negative]
    request_1063	#scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [PINFILE negative]
    request_1064	#scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [PINFILE negative]
    request_1065	#scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [PINFILE negative]
    request_1066	#scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [CertRequestNickName negative]
    request_1067	#scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [CertRequestNickName negative]
    request_1068	#scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1069	#scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1070	#scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: all positive
    request_1071	#scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1072	#scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1073	#scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: all positive
    request_1074	#scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [CertKeySize negative]
    request_1075	#scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [CertKeySize negative]
    request_1076	#scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1077	#scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1078	#scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: all positive
    request_1079	#scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [CertPrincipalName negative]
    request_1080	#scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [EXTUSAGE negative]
    request_1081	#scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: all positive
   request_envcleanup
} #request
request_envsetup()
{
    rlPhaseStartSetup "request_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup
request_envcleanup()
{
    rlPhaseStartCleanup "request_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

request_1001()  #ipa-getcert request -d [NSSDBDIR negative] -n [CertNickName positive] 
{ 
    rlPhaseStartTest "request_1001 [negative test] scenario: [ipa-getcert request -d -n]	data: [NSSDBDIR negative]" 

        # test local variables 
        local testID="request_1001_${RANDOM}" 
        local tmpout=${TmpDir}/request_1001.${RANDOM}.out
        local NSSDBDIR_negative="/etc/pki/nssdb/cert8.db"
        local CertNickName_positive="GetcertTest-${testID}"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The location \"$NSSDBDIR_negative\" is not a directory\|No request found that matched arguments\|Path \"$NSSDBDIR_negative\" is not a directory."
        local comment="scenario: [ipa-getcert request -d -n]	data: [NSSDBDIR negative]" 
	local verifyString="Path \"$NSSDBDIR_negative\" is not a directory."

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_negative -n $CertNickName_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1001

request_1002()  #ipa-getcert request -d [NSSDBDIR negative] -n [CertNickName positive] -t [CertTokenName positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1002 [negative test] scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [NSSDBDIR negative]" 

        # test local variables 
        local testID="request_1002_${RANDOM}" 
        local tmpout=${TmpDir}/request_1002.${RANDOM}.out
        local NSSDBDIR_negative="/etc/pki/nssdb/cert8.db"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The location \"$NSSDBDIR_negative\" is not a directory\|No request found that matched arguments\|Path \"$NSSDBDIR_negative\" is not a directory." 
        local comment="scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [NSSDBDIR negative]" 
        local verifyString="Path \"$NSSDBDIR_negative\" is not a directory."

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_negative -n $CertNickName_positive -t $CertTokenName_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1002

request_1003()  #ipa-getcert request -d [NSSDBDIR negative] -n [CertNickName positive] -t [CertTokenName positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1003 [negative test] scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [NSSDBDIR negative]" 

        # test local variables 
        local testID="request_1003_${RANDOM}" 
        local tmpout=${TmpDir}/request_1003.${RANDOM}.out
        local NSSDBDIR_negative="/etc/pki/nssdb/cert8.db"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The location \"$NSSDBDIR_negative\" is not a directory\|No request found that matched arguments\|Path \"$NSSDBDIR_negative\" is not a directory." 
        local comment="scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [NSSDBDIR negative]" 
        local verifyString="Path \"$NSSDBDIR_negative\" is not a directory."

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_negative -n $CertNickName_positive -t $CertTokenName_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1003

request_1004()  #ipa-getcert request -d [NSSDBDIR negative] -n [CertNickName positive] -t [CertTokenName positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1004 [negative test] scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [NSSDBDIR negative]" 

        # test local variables 
        local testID="request_1004_${RANDOM}" 
        local tmpout=${TmpDir}/request_1004.${RANDOM}.out
        local NSSDBDIR_negative="/etc/pki/nssdb/cert8.db"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The location \"$NSSDBDIR_negative\" is not a directory\|No request found that matched arguments\|Path \"$NSSDBDIR_negative\" is not a directory." 
        local comment="scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [NSSDBDIR negative]" 
        local verifyString="Path \"$NSSDBDIR_negative\" is not a directory."

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_negative -n $CertNickName_positive -t $CertTokenName_positive -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1004

request_1005()  #ipa-getcert request -d [NSSDBDIR negative] -n [CertNickName positive] -t [CertTokenName positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1005 [negative test] scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [NSSDBDIR negative]" 

        # test local variables 
        local testID="request_1005_${RANDOM}" 
        local tmpout=${TmpDir}/request_1005.${RANDOM}.out
        local NSSDBDIR_negative="/etc/pki/nssdb/cert8.db"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The location \"$NSSDBDIR_negative\" is not a directory\|No request found that matched arguments\|Path \"$NSSDBDIR_negative\" is not a directory." 
        local comment="scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [NSSDBDIR negative]" 
        local verifyString="Path \"$NSSDBDIR_negative\" is not a directory."

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_negative -n $CertNickName_positive -t $CertTokenName_positive -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1005

request_1006()   #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] 
{ 
    rlPhaseStartTest "request_1006 [positive test] scenario: [ipa-getcert request -d -n]	data: all positive" 

        # local test variables 
        local testID="request_1006_${RANDOM}" 
        local tmpout=${TmpDir}/request_1006.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive" 0 "scenario: [ipa-getcert request -d -n]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1006 

request_1007()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName negative] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1007 [negative test] scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [CertTokenName negative]" 

        # test local variables 
        local testID="request_1007_${RANDOM}" 
        local tmpout=${TmpDir}/request_1007.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_negative=" NoSuchToken${testID}"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [CertTokenName negative]" 
	# Updating verifyString after confirming with Nalin.
        local verifyString="status: NEED_KEY_PAIR\|status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"
        #local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t $CertTokenName_negative -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1007

request_1008()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName negative] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1008 [negative test] scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [CertTokenName negative]" 

        # test local variables 
        local testID="request_1008_${RANDOM}" 
        local tmpout=${TmpDir}/request_1008.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_negative=" NoSuchToken${testID}"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [CertTokenName negative]" 
	# Updateing verifyString after confirming with Nalin.
        local verifyString="status: NEED_KEY_PAIR\|status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"
        #local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t $CertTokenName_negative -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1008

request_1009()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName negative] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1009 [negative test] scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [CertTokenName negative]" 

        # test local variables 
        local testID="request_1009_${RANDOM}" 
        local tmpout=${TmpDir}/request_1009.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_negative=" NoSuchToken${testID}"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [CertTokenName negative]" 
	# updating verifyString after confirming with Nalin
        local verifyString="status: NEED_KEY_PAIR\|status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"
	    #local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t $CertTokenName_negative -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1009

request_1010()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName negative] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1010 [negative test] scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [CertTokenName negative]" 

        # test local variables 
        local testID="request_1010_${RANDOM}" 
        local tmpout=${TmpDir}/request_1010.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_negative=" NoSuchToken${testID}"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [CertTokenName negative]" 
	# updating verifyString after confirming with Nalin
        local verifyString="status: NEED_KEY_PAIR\|status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"
	    #local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t $CertTokenName_negative -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1010

request_1011()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [CertRequestNickName negative] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1011 [negative test] scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [CertRequestNickName negative]" 

        # test local variables 
        local testID="request_1011_${RANDOM}" 
        local tmpout=${TmpDir}/request_1011.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertRequestNickName_negative="CertReq-$testID"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$CertRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [CertRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        local cmd="ipa-getcert request -d $NSSDBDIR_positive -n '$CertNickName_positive' -t '$CertTokenName_positive' -I '$CertRequestNickName_negative' -R -N '$CertSubjectName_positive' -K '$CertPrincipalName_positive' -U $EXTUSAGE_positive -D '$DNSName_positive' -E '$EMAIL_positive'"
        certRun "$cmd" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"
        #certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t '$CertTokenName_positive' -I $CertRequestNickName_negative -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1011

request_1012()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [CertRequestNickName negative] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1012 [negative test] scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [CertRequestNickName negative]" 

        # test local variables 
        local testID="request_1012_${RANDOM}" 
        local tmpout=${TmpDir}/request_1012.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertRequestNickName_negative="CertReq-$testID"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$CertRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [CertRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -I $CertRequestNickName_negative -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1012

request_1013()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1013 [negative test] scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1013_${RANDOM}" 
        local tmpout=${TmpDir}/request_1013.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1013

request_1014()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1014 [negative test] scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1014_${RANDOM}" 
        local tmpout=${TmpDir}/request_1014.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t $CertTokenName_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1014

request_1015()   #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1015 [positive test] scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1015_${RANDOM}" 
        local tmpout=${TmpDir}/request_1015.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -d -n  -t -I -R -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1015 

request_1016()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1016 [negative test] scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1016_${RANDOM}" 
        local tmpout=${TmpDir}/request_1016.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1016

request_1017()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1017 [negative test] scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1017_${RANDOM}" 
        local tmpout=${TmpDir}/request_1017.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t $CertTokenName_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1017

request_1018()   #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1018 [positive test] scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1018_${RANDOM}" 
        local tmpout=${TmpDir}/request_1018.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -d -n  -t -I -r -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1018 

request_1019()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -g [CertKeySize negative] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1019 [negative test] scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [CertKeySize negative]" 

        # test local variables 
        local testID="request_1019_${RANDOM}" 
        local tmpout=${TmpDir}/request_1019.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertKeySize_negative="shouldBEnumber${testID}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [CertKeySize negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE"

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -g $CertKeySize_negative -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1019

request_1020()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -g [CertKeySize negative] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1020 [negative test] scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [CertKeySize negative]" 

        # test local variables 
        local testID="request_1020_${RANDOM}" 
        local tmpout=${TmpDir}/request_1020.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertKeySize_negative="shouldBEnumber${testID}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [CertKeySize negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE"

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -g $CertKeySize_negative -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1020

request_1021()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1021 [negative test] scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1021_${RANDOM}" 
        local tmpout=${TmpDir}/request_1021.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1021

request_1022()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1022 [negative test] scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1022_${RANDOM}" 
        local tmpout=${TmpDir}/request_1022.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1022

request_1023()   #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1023 [positive test] scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1023_${RANDOM}" 
        local tmpout=${TmpDir}/request_1023.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -d -n  -t -g -R -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1023 

request_1024()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1024 [negative test] scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1024_${RANDOM}" 
        local tmpout=${TmpDir}/request_1024.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1024

request_1025()  #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1025 [negative test] scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1025_${RANDOM}" 
        local tmpout=${TmpDir}/request_1025.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1025

request_1026()   #ipa-getcert request -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1026 [positive test] scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1026_${RANDOM}" 
        local tmpout=${TmpDir}/request_1026.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert request -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -d -n  -t -g -r -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1026 

request_1027()  #ipa-getcert request -k [PemKeyFile negative] -f [PemCertFile positive] 
{ 
    rlPhaseStartTest "request_1027 [negative test] scenario: [ipa-getcert request -k -f]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="request_1027_${RANDOM}" 
        local tmpout=${TmpDir}/request_1027.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\" is not a directory\|No request found that matched arguments\|Path \"/root/${testID}\" is not a directory.\|\"/root/${testID}\": No such file or directory." 
        local comment="scenario: [ipa-getcert request -k -f]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_negative -f $PemCertFile_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1027

request_1028()  #ipa-getcert request -k [PemKeyFile negative] -f [PemCertFile positive] -P [CertPIN positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1028 [negative test] scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="request_1028_${RANDOM}" 
        local tmpout=${TmpDir}/request_1028.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_negative -f $PemCertFile_positive -P $CertPIN_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1028

request_1029()  #ipa-getcert request -k [PemKeyFile negative] -f [PemCertFile positive] -P [CertPIN positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1029 [negative test] scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="request_1029_${RANDOM}" 
        local tmpout=${TmpDir}/request_1029.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_negative -f $PemCertFile_positive -P $CertPIN_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1029

request_1030()  #ipa-getcert request -k [PemKeyFile negative] -f [PemCertFile positive] -P [CertPIN positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1030 [negative test] scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="request_1030_${RANDOM}" 
        local tmpout=${TmpDir}/request_1030.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_negative -f $PemCertFile_positive -P $CertPIN_positive -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1030

request_1031()  #ipa-getcert request -k [PemKeyFile negative] -f [PemCertFile positive] -P [CertPIN positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1031 [negative test] scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="request_1031_${RANDOM}" 
        local tmpout=${TmpDir}/request_1031.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_negative -f $PemCertFile_positive -P $CertPIN_positive -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1031

request_1032()  #ipa-getcert request -k [PemKeyFile negative] -f [PemCertFile positive] -p [PINFILE positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1032 [negative test] scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="request_1032_${RANDOM}" 
        local tmpout=${TmpDir}/request_1032.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_negative -f $PemCertFile_positive -p $PINFILE_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1032

request_1033()  #ipa-getcert request -k [PemKeyFile negative] -f [PemCertFile positive] -p [PINFILE positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1033 [negative test] scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="request_1033_${RANDOM}" 
        local tmpout=${TmpDir}/request_1033.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_negative -f $PemCertFile_positive -p $PINFILE_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1033

request_1034()  #ipa-getcert request -k [PemKeyFile negative] -f [PemCertFile positive] -p [PINFILE positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1034 [negative test] scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="request_1034_${RANDOM}" 
        local tmpout=${TmpDir}/request_1034.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_negative -f $PemCertFile_positive -p $PINFILE_positive -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1034

request_1035()  #ipa-getcert request -k [PemKeyFile negative] -f [PemCertFile positive] -p [PINFILE positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1035 [negative test] scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="request_1035_${RANDOM}" 
        local tmpout=${TmpDir}/request_1035.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_negative -f $PemCertFile_positive -p $PINFILE_positive -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1035

request_1036()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile negative] 
{ 
    rlPhaseStartTest "request_1036 [negative test] scenario: [ipa-getcert request -k -f]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="request_1036_${RANDOM}" 
        local tmpout=${TmpDir}/request_1036.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert request -k -f]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_negative" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1036

request_1037()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile negative] -P [CertPIN positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1037 [negative test] scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="request_1037_${RANDOM}" 
        local tmpout=${TmpDir}/request_1037.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_negative -P $CertPIN_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1037

request_1038()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile negative] -P [CertPIN positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1038 [negative test] scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="request_1038_${RANDOM}" 
        local tmpout=${TmpDir}/request_1038.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_negative -P $CertPIN_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1038

request_1039()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile negative] -P [CertPIN positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1039 [negative test] scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="request_1039_${RANDOM}" 
        local tmpout=${TmpDir}/request_1039.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_negative -P $CertPIN_positive -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1039

request_1040()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile negative] -P [CertPIN positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1040 [negative test] scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="request_1040_${RANDOM}" 
        local tmpout=${TmpDir}/request_1040.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_negative -P $CertPIN_positive -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1040

request_1041()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile negative] -p [PINFILE positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1041 [negative test] scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="request_1041_${RANDOM}" 
        local tmpout=${TmpDir}/request_1041.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_negative -p $PINFILE_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1041

request_1042()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile negative] -p [PINFILE positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1042 [negative test] scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="request_1042_${RANDOM}" 
        local tmpout=${TmpDir}/request_1042.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_negative -p $PINFILE_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1042

request_1043()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile negative] -p [PINFILE positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1043 [negative test] scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="request_1043_${RANDOM}" 
        local tmpout=${TmpDir}/request_1043.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_negative -p $PINFILE_positive -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1043

request_1044()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile negative] -p [PINFILE positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1044 [negative test] scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="request_1044_${RANDOM}" 
        local tmpout=${TmpDir}/request_1044.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_negative -p $PINFILE_positive -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1044

request_1045()   #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] 
{ 
    rlPhaseStartTest "request_1045 [positive test] scenario: [ipa-getcert request -k -f]	data: all positive" 

        # local test variables 
        local testID="request_1045_${RANDOM}" 
        local tmpout=${TmpDir}/request_1045.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive" 0 "scenario: [ipa-getcert request -k -f]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1045 

request_1046()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [CertRequestNickName negative] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1046 [negative test] scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [CertRequestNickName negative]" 

        # test local variables 
        local testID="request_1046_${RANDOM}" 
        local tmpout=${TmpDir}/request_1046.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_negative="CertReq-$testID"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$CertRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [CertRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $CertRequestNickName_negative -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1046

request_1047()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [CertRequestNickName negative] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1047 [negative test] scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [CertRequestNickName negative]" 

        # test local variables 
        local testID="request_1047_${RANDOM}" 
        local tmpout=${TmpDir}/request_1047.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_negative="CertReq-$testID"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$CertRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [CertRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $CertRequestNickName_negative -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1047

request_1048()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1048 [negative test] scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1048_${RANDOM}" 
        local tmpout=${TmpDir}/request_1048.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1048

request_1049()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1049 [negative test] scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1049_${RANDOM}" 
        local tmpout=${TmpDir}/request_1049.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1049

request_1050()   #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1050 [positive test] scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1050_${RANDOM}" 
        local tmpout=${TmpDir}/request_1050.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -k -f  -P -I -R -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1050 

request_1051()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1051 [negative test] scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1051_${RANDOM}" 
        local tmpout=${TmpDir}/request_1051.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1051

request_1052()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1052 [negative test] scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1052_${RANDOM}" 
        local tmpout=${TmpDir}/request_1052.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1052

request_1053()   #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1053 [positive test] scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1053_${RANDOM}" 
        local tmpout=${TmpDir}/request_1053.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -k -f  -P -I -r -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1053 

request_1054()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -g [CertKeySize negative] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1054 [negative test] scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [CertKeySize negative]" 

        # test local variables 
        local testID="request_1054_${RANDOM}" 
        local tmpout=${TmpDir}/request_1054.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_negative="shouldBEnumber${testID}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [CertKeySize negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -g $CertKeySize_negative -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1054

request_1055()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -g [CertKeySize negative] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1055 [negative test] scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [CertKeySize negative]" 

        # test local variables 
        local testID="request_1055_${RANDOM}" 
        local tmpout=${TmpDir}/request_1055.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_negative="shouldBEnumber${testID}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [CertKeySize negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -g $CertKeySize_negative -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1055

request_1056()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1056 [negative test] scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1056_${RANDOM}" 
        local tmpout=${TmpDir}/request_1056.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1056

request_1057()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1057 [negative test] scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1057_${RANDOM}" 
        local tmpout=${TmpDir}/request_1057.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1057

request_1058()   #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1058 [positive test] scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1058_${RANDOM}" 
        local tmpout=${TmpDir}/request_1058.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -k -f  -P -g -R -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1058 

request_1059()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1059 [negative test] scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1059_${RANDOM}" 
        local tmpout=${TmpDir}/request_1059.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1059

request_1060()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1060 [negative test] scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1060_${RANDOM}" 
        local tmpout=${TmpDir}/request_1060.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1060

request_1061()   #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1061 [positive test] scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1061_${RANDOM}" 
        local tmpout=${TmpDir}/request_1061.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -k -f  -P -g -r -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1061 

request_1062()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE negative] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1062 [negative test] scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [PINFILE negative]" 

        # test local variables 
        local testID="request_1062_${RANDOM}" 
        local tmpout=${TmpDir}/request_1062.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_negative="/root/${testID}/no.such.pin.file"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [PINFILE negative]" 
        local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_negative -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1062

request_1063()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE negative] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1063 [negative test] scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [PINFILE negative]" 

        # test local variables 
        local testID="request_1063_${RANDOM}" 
        local tmpout=${TmpDir}/request_1063.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_negative="/root/${testID}/no.such.pin.file"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [PINFILE negative]" 
        local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_negative -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1063

request_1064()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE negative] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1064 [negative test] scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [PINFILE negative]" 

        # test local variables 
        local testID="request_1064_${RANDOM}" 
        local tmpout=${TmpDir}/request_1064.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_negative="/root/${testID}/no.such.pin.file"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [PINFILE negative]" 
        local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_negative -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1064

request_1065()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE negative] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1065 [negative test] scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [PINFILE negative]" 

        # test local variables 
        local testID="request_1065_${RANDOM}" 
        local tmpout=${TmpDir}/request_1065.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_negative="/root/${testID}/no.such.pin.file"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [PINFILE negative]" 
        local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_negative -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1065

request_1066()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [CertRequestNickName negative] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1066 [negative test] scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [CertRequestNickName negative]" 

        # test local variables 
        local testID="request_1066_${RANDOM}" 
        local tmpout=${TmpDir}/request_1066.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_negative="CertReq-$testID"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$CertRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [CertRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $CertRequestNickName_negative -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1066

request_1067()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [CertRequestNickName negative] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1067 [negative test] scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [CertRequestNickName negative]" 

        # test local variables 
        local testID="request_1067_${RANDOM}" 
        local tmpout=${TmpDir}/request_1067.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_negative="CertReq-$testID"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$CertRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [CertRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $CertRequestNickName_negative -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1067

request_1068()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1068 [negative test] scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1068_${RANDOM}" 
        local tmpout=${TmpDir}/request_1068.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1068

request_1069()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1069 [negative test] scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1069_${RANDOM}" 
        local tmpout=${TmpDir}/request_1069.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1069

request_1070()   #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [CertRequestNickName positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1070 [positive test] scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1070_${RANDOM}" 
        local tmpout=${TmpDir}/request_1070.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # test starts here  
        rlRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $CertRequestNickName_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -k -f  -p -I -R -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1070 

request_1071()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1071 [negative test] scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1071_${RANDOM}" 
        local tmpout=${TmpDir}/request_1071.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1071

request_1072()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1072 [negative test] scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1072_${RANDOM}" 
        local tmpout=${TmpDir}/request_1072.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1072

request_1073()   #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [CertRequestNickName positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1073 [positive test] scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1073_${RANDOM}" 
        local tmpout=${TmpDir}/request_1073.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertRequestNickName_positive="CertReq_${testID}_${RANDOM}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # test starts here  
        rlRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $CertRequestNickName_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -k -f  -p -I -r -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1073 

request_1074()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -g [CertKeySize negative] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1074 [negative test] scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [CertKeySize negative]" 

        # test local variables 
        local testID="request_1074_${RANDOM}" 
        local tmpout=${TmpDir}/request_1074.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_negative="shouldBEnumber${testID}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [CertKeySize negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -g $CertKeySize_negative -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1074

request_1075()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -g [CertKeySize negative] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1075 [negative test] scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [CertKeySize negative]" 

        # test local variables 
        local testID="request_1075_${RANDOM}" 
        local tmpout=${TmpDir}/request_1075.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_negative="shouldBEnumber${testID}"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [CertKeySize negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -g $CertKeySize_negative -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1075

request_1076()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1076 [negative test] scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1076_${RANDOM}" 
        local tmpout=${TmpDir}/request_1076.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1076

request_1077()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1077 [negative test] scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1077_${RANDOM}" 
        local tmpout=${TmpDir}/request_1077.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1077

request_1078()   #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -g [CertKeySize positive] -R -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1078 [positive test] scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1078_${RANDOM}" 
        local tmpout=${TmpDir}/request_1078.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # test starts here  
        rlRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -g $CertKeySize_positive -R -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -k -f  -p -g -R -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1078 

request_1079()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName negative] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1079 [negative test] scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="request_1079_${RANDOM}" 
        local tmpout=${TmpDir}/request_1079.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_negative -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1079

request_1080()  #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1080 [negative test] scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="request_1080_${RANDOM}" 
        local tmpout=${TmpDir}/request_1080.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1080

request_1081()   #ipa-getcert request -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -g [CertKeySize positive] -r -N [CertSubjectName positive] -K [CertPrincipalName positive] -U [EXTUSAGE positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "request_1081 [positive test] scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: all positive" 

        # local test variables 
        local testID="request_1081_${RANDOM}" 
        local tmpout=${TmpDir}/request_1081.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local CertKeySize_positive="1024"
        local CertSubjectName_positive="$cert_subject"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # test starts here  
        rlRun "ipa-getcert request -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -g $CertKeySize_positive -r -N $CertSubjectName_positive -K $CertPrincipalName_positive -U $EXTUSAGE_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert request -k -f  -p -g -r -N -K -U -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #request_1081 

start_tracking()
{ #total test cases: 75
    start_tracking_envsetup
    start_tracking_1001	#scenario: [ipa-getcert start-tracking -d -n -t]	data: [NSSDBDIR negative]
    start_tracking_1002	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [NSSDBDIR negative]
    start_tracking_1003	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [NSSDBDIR negative]
    start_tracking_1004	#scenario: [ipa-getcert start-tracking -d -n -t]	data: [CertTokenName negative]
    start_tracking_1005	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [CertTokenName negative]
    start_tracking_1006	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [CertTokenName negative]
    start_tracking_1007	#scenario: [ipa-getcert start-tracking -d -n -t]	data: all positive
    start_tracking_1008	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]
    start_tracking_1009	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]
    start_tracking_1010	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [EXTUSAGE negative]
    start_tracking_1011	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [EXTUSAGE negative]
    start_tracking_1012	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [CertPrincipalName negative]
    start_tracking_1013	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [CertPrincipalName negative]
    start_tracking_1014	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: all positive
    start_tracking_1015	#scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: all positive
    start_tracking_1016	#scenario: [ipa-getcert start-tracking -i]	data: [ExistingTrackingRequestNickName negative]
    start_tracking_1017	#scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [ExistingTrackingRequestNickName negative]
    start_tracking_1018	#scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [ExistingTrackingRequestNickName negative]
    start_tracking_1019	#scenario: [ipa-getcert start-tracking -i]	data: all positive
    start_tracking_1020	#scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]
    start_tracking_1021	#scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]
    start_tracking_1022	#scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [EXTUSAGE negative]
    start_tracking_1023	#scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [EXTUSAGE negative]
    start_tracking_1024	#scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [CertPrincipalName negative]
    start_tracking_1025	#scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [CertPrincipalName negative]
    start_tracking_1026	#scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: all positive
    start_tracking_1027	#scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: all positive
    start_tracking_1028	#scenario: [ipa-getcert start-tracking -k -f]	data: [PemKeyFile negative]
    start_tracking_1029	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [PemKeyFile negative]
    start_tracking_1030	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [PemKeyFile negative]
    start_tracking_1031	#scenario: [ipa-getcert start-tracking -k -f -P]	data: [PemKeyFile negative]
    start_tracking_1032	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [PemKeyFile negative]
    start_tracking_1033	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [PemKeyFile negative]
    start_tracking_1034	#scenario: [ipa-getcert start-tracking -k -f -p]	data: [PemKeyFile negative]
    start_tracking_1035	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [PemKeyFile negative]
    start_tracking_1036	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [PemKeyFile negative]
    start_tracking_1037	#scenario: [ipa-getcert start-tracking -k -f]	data: [PemCertFile negative]
    start_tracking_1038	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [PemCertFile negative]
    start_tracking_1039	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [PemCertFile negative]
    start_tracking_1040	#scenario: [ipa-getcert start-tracking -k -f -P]	data: [PemCertFile negative]
    start_tracking_1041	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [PemCertFile negative]
    start_tracking_1042	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [PemCertFile negative]
    start_tracking_1043	#scenario: [ipa-getcert start-tracking -k -f -p]	data: [PemCertFile negative]
    start_tracking_1044	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [PemCertFile negative]
    start_tracking_1045	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [PemCertFile negative]
    start_tracking_1046	#scenario: [ipa-getcert start-tracking -k -f]	data: all positive
    start_tracking_1047	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]
    start_tracking_1048	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]
    start_tracking_1049	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [EXTUSAGE negative]
    start_tracking_1050	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [EXTUSAGE negative]
    start_tracking_1051	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [CertPrincipalName negative]
    start_tracking_1052	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [CertPrincipalName negative]
    start_tracking_1053	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: all positive
    start_tracking_1054	#scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: all positive
    start_tracking_1055	#scenario: [ipa-getcert start-tracking -k -f -P]	data: all positive
    start_tracking_1056	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]
    start_tracking_1057	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]
    start_tracking_1058	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [EXTUSAGE negative]
    start_tracking_1059	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [EXTUSAGE negative]
    start_tracking_1060	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [CertPrincipalName negative]
    start_tracking_1061	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [CertPrincipalName negative]
    start_tracking_1062	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: all positive
    start_tracking_1063	#scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: all positive
    start_tracking_1064	#scenario: [ipa-getcert start-tracking -k -f -p]	data: [PINFILE negative]
    start_tracking_1065	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [PINFILE negative]
    start_tracking_1066	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [PINFILE negative]
    start_tracking_1067	#scenario: [ipa-getcert start-tracking -k -f -p]	data: all positive
    start_tracking_1068	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]
    start_tracking_1069	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]
    start_tracking_1070	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [EXTUSAGE negative]
    start_tracking_1071	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [EXTUSAGE negative]
    start_tracking_1072	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [CertPrincipalName negative]
    start_tracking_1073	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [CertPrincipalName negative]
    start_tracking_1074	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: all positive
    start_tracking_1075	#scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: all positive
    start_tracking_envcleanup
} #start_tracking
start_tracking_envsetup()
{
    rlPhaseStartSetup "start_tracking_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup
start_tracking_envcleanup()
{
    rlPhaseStartCleanup "start_tracking_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

start_tracking_1001()  #ipa-getcert start-tracking -d [NSSDBDIR negative] -n [CertNickName positive] -t [CertTokenName positive] 
{ 
    rlPhaseStartTest "start_tracking_1001 [negative test] scenario: [ipa-getcert start-tracking -d -n -t]	data: [NSSDBDIR negative]" 

        # test local variables 
        local testID="start_tracking_1001_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1001.${RANDOM}.out
        local NSSDBDIR_negative="/etc/pki/nssdb/cert8.db"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"$NSSDBDIR_negative\" is not a directory\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t]	data: [NSSDBDIR negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_negative -n $CertNickName_positive -t $CertTokenName_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1001

start_tracking_1002()  #ipa-getcert start-tracking -d [NSSDBDIR negative] -n [CertNickName positive] -t [CertTokenName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1002 [negative test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [NSSDBDIR negative]" 

        # test local variables 
        local testID="start_tracking_1002_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1002.${RANDOM}.out
        local NSSDBDIR_negative="/etc/pki/nssdb/cert8.db"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"$NSSDBDIR_negative\" is not a directory\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [NSSDBDIR negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_negative -n $CertNickName_positive -t $CertTokenName_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1002

start_tracking_1003()  #ipa-getcert start-tracking -d [NSSDBDIR negative] -n [CertNickName positive] -t [CertTokenName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1003 [negative test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [NSSDBDIR negative]" 

        # test local variables 
        local testID="start_tracking_1003_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1003.${RANDOM}.out
        local NSSDBDIR_negative="/etc/pki/nssdb/cert8.db"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"$NSSDBDIR_negative\" is not a directory\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [NSSDBDIR negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_negative -n $CertNickName_positive -t $CertTokenName_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1003

start_tracking_1004()  #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName negative] 
{ 
    rlPhaseStartTest "start_tracking_1004 [negative test] scenario: [ipa-getcert start-tracking -d -n -t]	data: [CertTokenName negative]" 

        # test local variables 
        local testID="start_tracking_1004_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1004.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_negative=" NoSuchToken${testID}"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t]	data: [CertTokenName negative]" 
	    # Updating the verifyString after confirming with Nalin.
        local verifyString="status: NEED_KEY_PAIR\|status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"
        #local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"

        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t $CertTokenName_negative" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1004

start_tracking_1005()  #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName negative] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1005 [negative test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [CertTokenName negative]" 

        # test local variables 
        local testID="start_tracking_1005_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1005.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_negative=" NoSuchToken${testID}"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [CertTokenName negative]" 
        # Updating the verifyString after confirming with Nalin.
        local verifyString="status: NEED_KEY_PAIR\|status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"
        #local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"


        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t $CertTokenName_negative -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1005

start_tracking_1006()  #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName negative] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1006 [negative test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [CertTokenName negative]" 

        # test local variables 
        local testID="start_tracking_1006_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1006.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_negative=" NoSuchToken${testID}"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [CertTokenName negative]" 
        # Updating the verifyString after confirming with Nalin.
        local verifyString="status: NEED_KEY_PAIR\|status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"
        #local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_TOKEN"

        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t $CertTokenName_negative -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1006

start_tracking_1007()   #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] 
{ 
    rlPhaseStartTest "start_tracking_1007 [positive test] scenario: [ipa-getcert start-tracking -d -n -t]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1007_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1007.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\"" 0 "scenario: [ipa-getcert start-tracking -d -n -t]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1007 

start_tracking_1008()  #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [TrackingRequestNickName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1008 [negative test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1008_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1008.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -I $TrackingRequestNickName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1008

start_tracking_1009()  #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [TrackingRequestNickName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1009 [negative test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1009_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1009.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -I $TrackingRequestNickName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1009

start_tracking_1010()  #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1010 [negative test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="start_tracking_1010_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1010.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t $CertTokenName_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1010

start_tracking_1011()  #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1011 [negative test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="start_tracking_1011_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1011.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t $CertTokenName_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1011

start_tracking_1012()  #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1012 [negative test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="start_tracking_1012_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1012.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1012

start_tracking_1013()  #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1013 [negative test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="start_tracking_1013_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1013.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1013

start_tracking_1014()   #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1014 [positive test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1014_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1014.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" 0 "scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -R]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1014 

start_tracking_1015()   #ipa-getcert start-tracking -d [NSSDBDIR positive] -n [CertNickName positive] -t [CertTokenName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1015 [positive test] scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1015_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1015.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local CertNickName_positive="GetcertTest-${testID}"
        local CertTokenName_positive="NSS Certificate DB"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert start-tracking -d $NSSDBDIR_positive -n $CertNickName_positive -t \"$CertTokenName_positive\" -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" 0 "scenario: [ipa-getcert start-tracking -d -n -t -I -U -K -D -E -r]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1015 

start_tracking_1016()  #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName negative] 
{ 
    rlPhaseStartTest "start_tracking_1016 [negative test] scenario: [ipa-getcert start-tracking -i]	data: [ExistingTrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1016_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1016.${RANDOM}.out
        local ExistingTrackingRequestNickName_negative="ReqDoesNotExist_${testID}"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="None of database directory and nickname or certificate file specified\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -i]	data: [ExistingTrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_negative" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1016

start_tracking_1017()  #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName negative] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1017 [negative test] scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [ExistingTrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1017_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1017.${RANDOM}.out
        local ExistingTrackingRequestNickName_negative="ReqDoesNotExist_${testID}"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="None of database directory and nickname or certificate file specified\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [ExistingTrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_negative -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1017

start_tracking_1018()  #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName negative] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1018 [negative test] scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [ExistingTrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1018_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1018.${RANDOM}.out
        local ExistingTrackingRequestNickName_negative="ReqDoesNotExist_${testID}"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="None of database directory and nickname or certificate file specified\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [ExistingTrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_negative -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1018

start_tracking_1019()   #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName positive] 
{ 
    rlPhaseStartTest "start_tracking_1019 [positive test] scenario: [ipa-getcert start-tracking -i]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1019_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1019.${RANDOM}.out
        local ExistingTrackingRequestNickName_positive="$testID"

        # test env setup 
        prepare_certrequest $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_positive" 0 "scenario: [ipa-getcert start-tracking -i]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1019 

start_tracking_1020()  #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName positive] -I [TrackingRequestNickName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1020 [negative test] scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1020_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1020.${RANDOM}.out
        local ExistingTrackingRequestNickName_positive="$testID"
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_positive -I $TrackingRequestNickName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1020

start_tracking_1021()  #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName positive] -I [TrackingRequestNickName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1021 [negative test] scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1021_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1021.${RANDOM}.out
        local ExistingTrackingRequestNickName_positive="$testID"
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_positive -I $TrackingRequestNickName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1021

start_tracking_1022()  #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1022 [negative test] scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="start_tracking_1022_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1022.${RANDOM}.out
        local ExistingTrackingRequestNickName_positive="$testID"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1022

start_tracking_1023()  #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1023 [negative test] scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="start_tracking_1023_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1023.${RANDOM}.out
        local ExistingTrackingRequestNickName_positive="$testID"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1023

start_tracking_1024()  #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1024 [negative test] scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="start_tracking_1024_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1024.${RANDOM}.out
        local ExistingTrackingRequestNickName_positive="$testID"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1024

start_tracking_1025()  #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1025 [negative test] scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="start_tracking_1025_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1025.${RANDOM}.out
        local ExistingTrackingRequestNickName_positive="$testID"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1025

start_tracking_1026()   #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1026 [positive test] scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1026_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1026.${RANDOM}.out
        local ExistingTrackingRequestNickName_positive="$testID"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" 0 "scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -R]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1026 

start_tracking_1027()   #ipa-getcert start-tracking -i [ExistingTrackingRequestNickName positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1027 [positive test] scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1027_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1027.${RANDOM}.out
        local ExistingTrackingRequestNickName_positive="$testID"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -i $ExistingTrackingRequestNickName_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" 0 "scenario: [ipa-getcert start-tracking -i -I -U -K -D -E -r]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1027 

start_tracking_1028()  #ipa-getcert start-tracking -k [PemKeyFile negative] -f [PemCertFile positive] 
{ 
    rlPhaseStartTest "start_tracking_1028 [negative test] scenario: [ipa-getcert start-tracking -k -f]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="start_tracking_1028_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1028.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -k -f]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_negative -f $PemCertFile_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1028

start_tracking_1029()  #ipa-getcert start-tracking -k [PemKeyFile negative] -f [PemCertFile positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1029 [negative test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="start_tracking_1029_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1029.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_negative -f $PemCertFile_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1029

start_tracking_1030()  #ipa-getcert start-tracking -k [PemKeyFile negative] -f [PemCertFile positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1030 [negative test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="start_tracking_1030_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1030.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_negative -f $PemCertFile_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1030

start_tracking_1031()  #ipa-getcert start-tracking -k [PemKeyFile negative] -f [PemCertFile positive] -P [CertPIN positive] 
{ 
    rlPhaseStartTest "start_tracking_1031 [negative test] scenario: [ipa-getcert start-tracking -k -f -P]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="start_tracking_1031_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1031.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_negative -f $PemCertFile_positive -P $CertPIN_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1031

start_tracking_1032()  #ipa-getcert start-tracking -k [PemKeyFile negative] -f [PemCertFile positive] -P [CertPIN positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1032 [negative test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="start_tracking_1032_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1032.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\" is not a directory\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_negative -f $PemCertFile_positive -P $CertPIN_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1032

start_tracking_1033()  #ipa-getcert start-tracking -k [PemKeyFile negative] -f [PemCertFile positive] -P [CertPIN positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1033 [negative test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="start_tracking_1033_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1033.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_negative -f $PemCertFile_positive -P $CertPIN_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1033

start_tracking_1034()  #ipa-getcert start-tracking -k [PemKeyFile negative] -f [PemCertFile positive] -p [PINFILE positive] 
{ 
    rlPhaseStartTest "start_tracking_1034 [negative test] scenario: [ipa-getcert start-tracking -k -f -p]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="start_tracking_1034_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1034.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"

        # test env setup 
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_negative -f $PemCertFile_positive -p $PINFILE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1034

start_tracking_1035()  #ipa-getcert start-tracking -k [PemKeyFile negative] -f [PemCertFile positive] -p [PINFILE positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1035 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="start_tracking_1035_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1035.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_negative -f $PemCertFile_positive -p $PINFILE_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1035

start_tracking_1036()  #ipa-getcert start-tracking -k [PemKeyFile negative] -f [PemCertFile positive] -p [PINFILE positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1036 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="start_tracking_1036_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1036.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_negative -f $PemCertFile_positive -p $PINFILE_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1036

start_tracking_1037()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile negative] 
{ 
    rlPhaseStartTest "start_tracking_1037 [negative test] scenario: [ipa-getcert start-tracking -k -f]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="start_tracking_1037_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1037.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert start-tracking -k -f]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_negative" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1037

start_tracking_1038()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile negative] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1038 [negative test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="start_tracking_1038_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1038.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_negative -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1038

start_tracking_1039()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile negative] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1039 [negative test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="start_tracking_1039_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1039.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_negative -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1039

start_tracking_1040()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile negative] -P [CertPIN positive] 
{ 
    rlPhaseStartTest "start_tracking_1040 [negative test] scenario: [ipa-getcert start-tracking -k -f -P]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="start_tracking_1040_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1040.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_negative -P $CertPIN_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1040

start_tracking_1041()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile negative] -P [CertPIN positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1041 [negative test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="start_tracking_1041_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1041.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_negative -P $CertPIN_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1041

start_tracking_1042()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile negative] -P [CertPIN positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1042 [negative test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="start_tracking_1042_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1042.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_negative -P $CertPIN_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1042

start_tracking_1043()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile negative] -p [PINFILE positive] 
{ 
    rlPhaseStartTest "start_tracking_1043 [negative test] scenario: [ipa-getcert start-tracking -k -f -p]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="start_tracking_1043_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1043.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local PINFILE_positive="${pem_dir}/${testID}.pin"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_negative -p $PINFILE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1043

start_tracking_1044()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile negative] -p [PINFILE positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1044 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="start_tracking_1044_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1044.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_negative -p $PINFILE_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1044

start_tracking_1045()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile negative] -p [PINFILE positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1045 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="start_tracking_1045_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1045.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_negative -p $PINFILE_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1045

start_tracking_1046()   #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] 
{ 
    rlPhaseStartTest "start_tracking_1046 [positive test] scenario: [ipa-getcert start-tracking -k -f]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1046_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1046.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive" 0 "scenario: [ipa-getcert start-tracking -k -f]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1046 

start_tracking_1047()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -I [TrackingRequestNickName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1047 [negative test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1047_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1047.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -I $TrackingRequestNickName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1047

start_tracking_1048()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -I [TrackingRequestNickName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1048 [negative test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1048_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1048.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -I $TrackingRequestNickName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1048

start_tracking_1049()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1049 [negative test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="start_tracking_1049_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1049.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1049

start_tracking_1050()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1050 [negative test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="start_tracking_1050_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1050.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1050

start_tracking_1051()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1051 [negative test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="start_tracking_1051_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1051.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1051

start_tracking_1052()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1052 [negative test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="start_tracking_1052_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1052.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1052

start_tracking_1053()   #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1053 [positive test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1053_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1053.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" 0 "scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -R]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1053 

start_tracking_1054()   #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1054 [positive test] scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1054_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1054.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" 0 "scenario: [ipa-getcert start-tracking -k -f -I -U -K -D -E -r]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1054 

start_tracking_1055()   #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] 
{ 
    rlPhaseStartTest "start_tracking_1055 [positive test] scenario: [ipa-getcert start-tracking -k -f -P]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1055_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1055.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive" 0 "scenario: [ipa-getcert start-tracking -k -f -P]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1055 

start_tracking_1056()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [TrackingRequestNickName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1056 [negative test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1056_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1056.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $TrackingRequestNickName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1056

start_tracking_1057()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [TrackingRequestNickName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1057 [negative test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1057_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1057.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $TrackingRequestNickName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1057

start_tracking_1058()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1058 [negative test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="start_tracking_1058_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1058.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1058

start_tracking_1059()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1059 [negative test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="start_tracking_1059_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1059.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1059

start_tracking_1060()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1060 [negative test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="start_tracking_1060_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1060.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: [CertPrincipalName negative]" 
        # Updating the verifyString after confirming with Nalin.
        # local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1060

start_tracking_1061()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1061 [negative test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="start_tracking_1061_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1061.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: [CertPrincipalName negative]" 
        # Updating the verifyString after confirming with Nalin.
	# local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"
	local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1061

start_tracking_1062()   #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1062 [positive test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1062_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1062.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" 0 "scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -R]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1062 

start_tracking_1063()   #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -P [CertPIN positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1063 [positive test] scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1063_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1063.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -P $CertPIN_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" 0 "scenario: [ipa-getcert start-tracking -k -f -P -I -U -K -D -E -r]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1063 

start_tracking_1064()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE negative] 
{ 
    rlPhaseStartTest "start_tracking_1064 [negative test] scenario: [ipa-getcert start-tracking -k -f -p]	data: [PINFILE negative]" 

        # test local variables 
        local testID="start_tracking_1064_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1064.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_negative="/root/${testID}/no.such.pin.file"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p]	data: [PINFILE negative]" 
        local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_negative" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1064

start_tracking_1065()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE negative] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1065 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [PINFILE negative]" 

        # test local variables 
        local testID="start_tracking_1065_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1065.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_negative="/root/${testID}/no.such.pin.file"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [PINFILE negative]" 
        local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_negative -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1065

start_tracking_1066()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE negative] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1066 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [PINFILE negative]" 

        # test local variables 
        local testID="start_tracking_1066_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1066.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_negative="/root/${testID}/no.such.pin.file"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [PINFILE negative]" 
        local verifyString="status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_negative -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1066

start_tracking_1067()   #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] 
{ 
    rlPhaseStartTest "start_tracking_1067 [positive test] scenario: [ipa-getcert start-tracking -k -f -p]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1067_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1067.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive" 0 "scenario: [ipa-getcert start-tracking -k -f -p]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1067 

start_tracking_1068()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [TrackingRequestNickName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1068 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1068_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1068.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $TrackingRequestNickName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1068

start_tracking_1069()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [TrackingRequestNickName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1069 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="start_tracking_1069_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1069.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $TrackingRequestNickName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1069

start_tracking_1070()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1070 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="start_tracking_1070_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1070.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1070

start_tracking_1071()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1071 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="start_tracking_1071_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1071.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1071

start_tracking_1072()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1072 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="start_tracking_1072_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1072.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: [CertPrincipalName negative]" 
	# Updating verifyString after confirming with Nalin
	# local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -R" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1072

start_tracking_1073()  #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1073 [negative test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="start_tracking_1073_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1073.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: [CertPrincipalName negative]" 
        # Updating verifyString after confirming with Nalin
        # local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED\|status: NEWLY_ADDED_NEED_KEYINFO_READ_PIN"

        # test starts here  
        certRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -r" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1073

start_tracking_1074()   #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -R 
{ 
    rlPhaseStartTest "start_tracking_1074 [positive test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1074_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1074.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -R" 0 "scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -R]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1074 

start_tracking_1075()   #ipa-getcert start-tracking -k [PemKeyFile positive] -f [PemCertFile positive] -p [PINFILE positive] -I [TrackingRequestNickName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -r 
{ 
    rlPhaseStartTest "start_tracking_1075 [positive test] scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: all positive" 

        # local test variables 
        local testID="start_tracking_1075_${RANDOM}" 
        local tmpout=${TmpDir}/start_tracking_1075.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local PINFILE_positive="${pem_dir}/${testID}.pin"
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID
        prepare_pin $testID 

        # test starts here  
        rlRun "ipa-getcert start-tracking -k $PemKeyFile_positive -f $PemCertFile_positive -p $PINFILE_positive -I $TrackingRequestNickName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -r" 0 "scenario: [ipa-getcert start-tracking -k -f -p -I -U -K -D -E -r]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID
        cleanup_pin $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #start_tracking_1075 

stop_tracking()
{ #total test cases: 9
    stop_tracking_envsetup
    stop_tracking_1001	#scenario: [ipa-getcert stop-tracking -d -n -t]	data: [NSSDBDIR negative]
    stop_tracking_1002	#scenario: [ipa-getcert stop-tracking -d -n -t]	data: [ExistingCertNickName negative]
    stop_tracking_1003	#scenario: [ipa-getcert stop-tracking -d -n -t]	data: [StopTrackingCertTokenName negative]
    stop_tracking_1004	#scenario: [ipa-getcert stop-tracking -d -n -t]	data: all positive
    stop_tracking_1005	#scenario: [ipa-getcert stop-tracking -i]	data: [ExistingTrackingRequestNickName negative]
    stop_tracking_1006	#scenario: [ipa-getcert stop-tracking -i]	data: all positive
    stop_tracking_1007	#scenario: [ipa-getcert stop-tracking -k -f]	data: [PemKeyFile negative]
    stop_tracking_1008	#scenario: [ipa-getcert stop-tracking -k -f]	data: [PemCertFile negative]
    stop_tracking_1009	#scenario: [ipa-getcert stop-tracking -k -f]	data: all positive
    stop_tracking_envcleanup
} #stop_tracking
stop_tracking_envsetup()
{
    rlPhaseStartSetup "stop_tracking_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup
stop_tracking_envcleanup()
{
    rlPhaseStartCleanup "stop_tracking_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

stop_tracking_1001()  #ipa-getcert stop-tracking -d [NSSDBDIR negative] -n [ExistingCertNickName positive] -t [StopTrackingCertTokenName positive] 
{ 
    rlPhaseStartTest "stop_tracking_1001 [negative test] scenario: [ipa-getcert stop-tracking -d -n -t]	data: [NSSDBDIR negative]" 

        # test local variables 
        local testID="stop_tracking_1001_${RANDOM}" 
        local tmpout=${TmpDir}/stop_tracking_1001.${RANDOM}.out
        local NSSDBDIR_negative="/etc/pki/nssdb/cert8.db"
        local ExistingCertNickName_positive="$testID"
        local StopTrackingCertTokenName_positive="NSS Certificate DB"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"$NSSDBDIR_negative\" is not a directory\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert stop-tracking -d -n -t]	data: [NSSDBDIR negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert stop-tracking -d $NSSDBDIR_negative -n $ExistingCertNickName_positive -t $StopTrackingCertTokenName_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #stop_tracking_1001

stop_tracking_1002()  #ipa-getcert stop-tracking -d [NSSDBDIR positive] -n [ExistingCertNickName negative] -t [StopTrackingCertTokenName positive] 
{ 
    rlPhaseStartTest "stop_tracking_1002 [negative test] scenario: [ipa-getcert stop-tracking -d -n -t]	data: [ExistingCertNickName negative]" 

        # test local variables 
        local testID="stop_tracking_1002_${RANDOM}" 
        local tmpout=${TmpDir}/stop_tracking_1002.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_negative="NoSuchCertExist${testID}"
        local StopTrackingCertTokenName_positive="NSS Certificate DB"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="No request found that matched arguments" 
        local comment="scenario: [ipa-getcert stop-tracking -d -n -t]	data: [ExistingCertNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert stop-tracking -d $NSSDBDIR_positive -n $ExistingCertNickName_negative -t '$StopTrackingCertTokenName_positive' " "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #stop_tracking_1002

stop_tracking_1003()  #ipa-getcert stop-tracking -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -t [StopTrackingCertTokenName negative] 
{ 
    rlPhaseStartTest "stop_tracking_1003 [negative test] scenario: [ipa-getcert stop-tracking -d -n -t]	data: [StopTrackingCertTokenName negative]" 

        # test local variables 
        local testID="stop_tracking_1003_${RANDOM}" 
        local tmpout=${TmpDir}/stop_tracking_1003.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local StopTrackingCertTokenName_negative="NoSuchToken${testID}"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="No request found that matched arguments" 
        local comment="scenario: [ipa-getcert stop-tracking -d -n -t]	data: [StopTrackingCertTokenName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert stop-tracking -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -t $StopTrackingCertTokenName_negative" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #stop_tracking_1003

stop_tracking_1004()   #ipa-getcert stop-tracking -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -t [StopTrackingCertTokenName positive] 
{ 
    rlPhaseStartTest "stop_tracking_1004 [positive test] scenario: [ipa-getcert stop-tracking -d -n -t]	data: all positive" 

        # local test variables 
        local testID="stop_tracking_1004_${RANDOM}" 
        local tmpout=${TmpDir}/stop_tracking_1004.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local StopTrackingCertTokenName_positive="NSS Certificate DB"

        # test env setup 
        prepare_certrequest $testID 

        # test starts here  
        rlRun "ipa-getcert stop-tracking -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -t $StopTrackingCertTokenName_positive" 0 "scenario: [ipa-getcert stop-tracking -d -n -t]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #stop_tracking_1004 

stop_tracking_1005()  #ipa-getcert stop-tracking -i [ExistingTrackingRequestNickName negative] 
{ 
    rlPhaseStartTest "stop_tracking_1005 [negative test] scenario: [ipa-getcert stop-tracking -i]	data: [ExistingTrackingRequestNickName negative]" 

        # test local variables 
        local testID="stop_tracking_1005_${RANDOM}" 
        local tmpout=${TmpDir}/stop_tracking_1005.${RANDOM}.out
        local ExistingTrackingRequestNickName_negative="ReqDoesNotExist_${testID}"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="None of database directory and nickname or certificate file specified\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert stop-tracking -i]	data: [ExistingTrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert stop-tracking -i $ExistingTrackingRequestNickName_negative" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #stop_tracking_1005

stop_tracking_1006()   #ipa-getcert stop-tracking -i [ExistingTrackingRequestNickName positive] 
{ 
    rlPhaseStartTest "stop_tracking_1006 [positive test] scenario: [ipa-getcert stop-tracking -i]	data: all positive" 

        # local test variables 
        local testID="stop_tracking_1006_${RANDOM}" 
        local tmpout=${TmpDir}/stop_tracking_1006.${RANDOM}.out
        local ExistingTrackingRequestNickName_positive="$testID"

        # test env setup 
        prepare_certrequest $testID 

        # test starts here  
        rlRun "ipa-getcert stop-tracking -i $ExistingTrackingRequestNickName_positive" 0 "scenario: [ipa-getcert stop-tracking -i]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #stop_tracking_1006 

stop_tracking_1007()  #ipa-getcert stop-tracking -k [PemKeyFile negative] -f [PemCertFile positive] 
{ 
    rlPhaseStartTest "stop_tracking_1007 [negative test] scenario: [ipa-getcert stop-tracking -k -f]	data: [PemKeyFile negative]" 

        # test local variables 
        local testID="stop_tracking_1007_${RANDOM}" 
        local tmpout=${TmpDir}/stop_tracking_1007.${RANDOM}.out
        local PemKeyFile_negative="/root/${testID}/no.such.pem.key.file."
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"/root/${testID}\": No such file or directory.\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert stop-tracking -k -f]	data: [PemKeyFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert stop-tracking -k $PemKeyFile_negative -f $PemCertFile_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #stop_tracking_1007

stop_tracking_1008()  #ipa-getcert stop-tracking -k [PemKeyFile positive] -f [PemCertFile negative] 
{ 
    rlPhaseStartTest "stop_tracking_1008 [negative test] scenario: [ipa-getcert stop-tracking -k -f]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="stop_tracking_1008_${RANDOM}" 
        local tmpout=${TmpDir}/stop_tracking_1008.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"

        # test env setup 
        prepare_pem_keyfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert stop-tracking -k -f]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert stop-tracking -k $PemKeyFile_positive -f $PemCertFile_negative" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_keyfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #stop_tracking_1008

stop_tracking_1009()   #ipa-getcert stop-tracking -k [PemKeyFile positive] -f [PemCertFile positive] 
{ 
    rlPhaseStartTest "stop_tracking_1009 [positive test] scenario: [ipa-getcert stop-tracking -k -f]	data: all positive" 

        # local test variables 
        local testID="stop_tracking_1009_${RANDOM}" 
        local tmpout=${TmpDir}/stop_tracking_1009.${RANDOM}.out
        local PemKeyFile_positive="${pem_dir}/${testID}.key.pem"
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"

        # test env setup 
        prepare_pem_keyfile $testID
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert stop-tracking -k $PemKeyFile_positive -f $PemCertFile_positive" 0 "scenario: [ipa-getcert stop-tracking -k -f]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_keyfile $testID
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #stop_tracking_1009 

resubmit()
{ #total test cases: 34
    resubmit_envsetup
    resubmit_1001	#scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [NSSDBDIR negative]
    resubmit_1002	#scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [NSSDBDIR negative]
    resubmit_1003	#scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [CertSubjectName negative]
    resubmit_1004	#scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [EXTUSAGE negative]
    resubmit_1005	#scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [CertPrincipalName negative]
    resubmit_1006	#scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: all positive
    resubmit_1007	#scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [CertTokenName negative]
    resubmit_1008	#scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [CertSubjectName negative]
    resubmit_1009	#scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [EXTUSAGE negative]
    resubmit_1010	#scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [CertPrincipalName negative]
    resubmit_1011	#scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [EXTUSAGE negative]
    resubmit_1012	#scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: all positive
    resubmit_1013	#scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [PemCertFile negative]
    resubmit_1014	#scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [PemCertFile negative]
    resubmit_1015	#scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [CertSubjectName negative]
    resubmit_1016	#scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [EXTUSAGE negative]
    resubmit_1017	#scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [CertPrincipalName negative]
    resubmit_1018	#scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: all positive
    resubmit_1019	#scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [CertSubjectName negative]
    resubmit_1020	#scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [EXTUSAGE negative]
    resubmit_1021	#scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [CertPrincipalName negative]
    resubmit_1022	#scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [EXTUSAGE negative]
    resubmit_1023	#scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: all positive
    resubmit_1024	#scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [TrackingRequestNickName negative]
    resubmit_1025	#scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [TrackingRequestNickName negative]
    resubmit_1026	#scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [CertSubjectName negative]
    resubmit_1027	#scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [CertSubjectName negative]
    resubmit_1028	#scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [EXTUSAGE negative]
    resubmit_1029	#scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [EXTUSAGE negative]
    resubmit_1030	#scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [CertPrincipalName negative]
    resubmit_1031	#scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [CertPrincipalName negative]
    resubmit_1032	#scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: all positive
    resubmit_1033	#scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [EXTUSAGE negative]
    resubmit_1034	#scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: all positive
    resubmit_envcleanup
} #resubmit
resubmit_envsetup()
{
    rlPhaseStartSetup "resubmit_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup
resubmit_envcleanup()
{
    rlPhaseStartCleanup "resubmit_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

resubmit_1001()  #ipa-getcert resubmit -d [NSSDBDIR negative] -n [ExistingCertNickName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1001 [negative test] scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [NSSDBDIR negative]" 

        # test local variables 
        local testID="resubmit_1001_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1001.${RANDOM}.out
        local NSSDBDIR_negative="/etc/pki/nssdb/cert8.db"
        local ExistingCertNickName_positive="$testID"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"$NSSDBDIR_negative\" is not a directory\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [NSSDBDIR negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -d $NSSDBDIR_negative -n $ExistingCertNickName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1001

resubmit_1002()  #ipa-getcert resubmit -d [NSSDBDIR negative] -n [ExistingCertNickName positive] -t [CertTokenName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1002 [negative test] scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [NSSDBDIR negative]" 

        # test local variables 
        local testID="resubmit_1002_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1002.${RANDOM}.out
        local NSSDBDIR_negative="/etc/pki/nssdb/cert8.db"
        local ExistingCertNickName_positive="$testID"
        local CertTokenName_positive="NSS Certificate DB"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path \"$NSSDBDIR_negative\" is not a directory\|No request found that matched arguments" 
        local comment="scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [NSSDBDIR negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -d $NSSDBDIR_negative -n $ExistingCertNickName_positive -t $CertTokenName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1002

resubmit_1003()  #ipa-getcert resubmit -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -N [CertSubjectName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1003 [negative test] scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [CertSubjectName negative]" 

        # test local variables 
        local testID="resubmit_1003_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1003.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local CertSubjectName_negative="#"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [CertSubjectName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -N $CertSubjectName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1003

resubmit_1004()  #ipa-getcert resubmit -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -N [CertSubjectName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1004 [negative test] scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="resubmit_1004_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1004.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -N $CertSubjectName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1004

resubmit_1005()  #ipa-getcert resubmit -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1005 [negative test] scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="resubmit_1005_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1005.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert resubmit -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1005

resubmit_1006()   #ipa-getcert resubmit -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1006 [positive test] scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: all positive" 

        # local test variables 
        local testID="resubmit_1006_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1006.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # test starts here  
        rlRun "ipa-getcert resubmit -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert resubmit -d -n -N -U -K -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1006 

resubmit_1007()  #ipa-getcert resubmit -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -t [CertTokenName negative] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1007 [negative test] scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [CertTokenName negative]" 

        # test local variables 
        local testID="resubmit_1007_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1007.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local CertTokenName_negative=" NoSuchToken${testID}"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [CertTokenName negative]" 
        local verifyString="status: NEED_KEY_PAIR"

        # test starts here  
        certRun "ipa-getcert resubmit -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -t $CertTokenName_negative -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1007

resubmit_1008()  #ipa-getcert resubmit -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -t [CertTokenName positive] -N [CertSubjectName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1008 [negative test] scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [CertSubjectName negative]" 

        # test local variables 
        local testID="resubmit_1008_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1008.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local CertTokenName_positive="NSS Certificate DB"
        local CertSubjectName_negative="#"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="__errmsg_NOT_FOUND_IN_DB__" 
        local comment="scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [CertSubjectName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -t $CertTokenName_positive -N $CertSubjectName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1008

resubmit_1009()  #ipa-getcert resubmit -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -t [CertTokenName positive] -N [CertSubjectName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1009 [negative test] scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="resubmit_1009_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1009.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local CertTokenName_positive="NSS Certificate DB"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -t $CertTokenName_positive -N $CertSubjectName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1009

resubmit_1010()  #ipa-getcert resubmit -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -t [CertTokenName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1010 [negative test] scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="resubmit_1010_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1010.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local CertTokenName_positive="NSS Certificate DB"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert resubmit -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -t $CertTokenName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1010

resubmit_1011()  #ipa-getcert resubmit -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -t [CertTokenName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE negative] 
{ 
    rlPhaseStartTest "resubmit_1011 [negative test] scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="resubmit_1011_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1011.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local CertTokenName_positive="NSS Certificate DB"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"

        # test env setup 
        prepare_certrequest $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -t $CertTokenName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_negative" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1011

resubmit_1012()   #ipa-getcert resubmit -d [NSSDBDIR positive] -n [ExistingCertNickName positive] -t [CertTokenName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1012 [positive test] scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: all positive" 

        # local test variables 
        local testID="resubmit_1012_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1012.${RANDOM}.out
        local NSSDBDIR_positive="/etc/pki/nssdb"
        local ExistingCertNickName_positive="$testID"
        local CertTokenName_positive="NSS Certificate DB"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_certrequest $testID 

        # test starts here  
        rlRun "ipa-getcert resubmit -d $NSSDBDIR_positive -n $ExistingCertNickName_positive -t $CertTokenName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" 0 "scenario: [ipa-getcert resubmit -d -n  -t -N -U -K -D -E -I]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1012 

resubmit_1013()  #ipa-getcert resubmit -f [PemCertFile negative] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1013 [negative test] scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="resubmit_1013_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1013.${RANDOM}.out
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -f $PemCertFile_negative -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1013

resubmit_1014()  #ipa-getcert resubmit -f [PemCertFile negative] -P [CertPIN positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1014 [negative test] scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [PemCertFile negative]" 

        # test local variables 
        local testID="resubmit_1014_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1014.${RANDOM}.out
        local PemCertFile_negative="${testID}/NoSuchPemCertFile"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Path .* is not absolute" 
        local comment="scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [PemCertFile negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -f $PemCertFile_negative -P $CertPIN_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1014

resubmit_1015()  #ipa-getcert resubmit -f [PemCertFile positive] -N [CertSubjectName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1015 [negative test] scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [CertSubjectName negative]" 

        # test local variables 
        local testID="resubmit_1015_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1015.${RANDOM}.out
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertSubjectName_negative="#"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="__errmsg_NOT_FOUND_IN_DB__" 
        local comment="scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [CertSubjectName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -f $PemCertFile_positive -N $CertSubjectName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1015

resubmit_1016()  #ipa-getcert resubmit -f [PemCertFile positive] -N [CertSubjectName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1016 [negative test] scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="resubmit_1016_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1016.${RANDOM}.out
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -f $PemCertFile_positive -N $CertSubjectName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1016

resubmit_1017()  #ipa-getcert resubmit -f [PemCertFile positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1017 [negative test] scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="resubmit_1017_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1017.${RANDOM}.out
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert resubmit -f $PemCertFile_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1017

resubmit_1018()   #ipa-getcert resubmit -f [PemCertFile positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1018 [positive test] scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: all positive" 

        # local test variables 
        local testID="resubmit_1018_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1018.${RANDOM}.out
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert resubmit -f $PemCertFile_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert resubmit -f -N -U -K -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1018 

resubmit_1019()  #ipa-getcert resubmit -f [PemCertFile positive] -P [CertPIN positive] -N [CertSubjectName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1019 [negative test] scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [CertSubjectName negative]" 

        # test local variables 
        local testID="resubmit_1019_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1019.${RANDOM}.out
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertSubjectName_negative="#"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="__errmsg_NOT_FOUND_IN_DB__" 
        local comment="scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [CertSubjectName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -f $PemCertFile_positive -P $CertPIN_positive -N $CertSubjectName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1019

resubmit_1020()  #ipa-getcert resubmit -f [PemCertFile positive] -P [CertPIN positive] -N [CertSubjectName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1020 [negative test] scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="resubmit_1020_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1020.${RANDOM}.out
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -f $PemCertFile_positive -P $CertPIN_positive -N $CertSubjectName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1020

resubmit_1021()  #ipa-getcert resubmit -f [PemCertFile positive] -P [CertPIN positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1021 [negative test] scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="resubmit_1021_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1021.${RANDOM}.out
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert resubmit -f $PemCertFile_positive -P $CertPIN_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1021

resubmit_1022()  #ipa-getcert resubmit -f [PemCertFile positive] -P [CertPIN positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE negative] 
{ 
    rlPhaseStartTest "resubmit_1022 [negative test] scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="resubmit_1022_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1022.${RANDOM}.out
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"

        # test env setup 
        prepare_pem_certfile $testID 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -f $PemCertFile_positive -P $CertPIN_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_negative" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        cleanup_pem_certfile $testID 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1022

resubmit_1023()   #ipa-getcert resubmit -f [PemCertFile positive] -P [CertPIN positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1023 [positive test] scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: all positive" 

        # local test variables 
        local testID="resubmit_1023_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1023.${RANDOM}.out
        local PemCertFile_positive="${pem_dir}/${testID}.cert.pem"
        local CertPIN_positive="${testID}jfkdlaj2920jgajfklda290-9-jdjep9"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        prepare_pem_certfile $testID 

        # test starts here  
        rlRun "ipa-getcert resubmit -f $PemCertFile_positive -P $CertPIN_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" 0 "scenario: [ipa-getcert resubmit -f  -P -N -U -K -D -E -I]	data: all positive"  
        # test ends here 

        # test env cleanup 
        cleanup_pem_certfile $testID 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1023 

resubmit_1024()  #ipa-getcert resubmit -i [TrackingRequestNickName negative] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1024 [negative test] scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="resubmit_1024_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1024.${RANDOM}.out
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -i $TrackingRequestNickName_negative -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1024

resubmit_1025()  #ipa-getcert resubmit -i [TrackingRequestNickName negative] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1025 [negative test] scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [TrackingRequestNickName negative]" 

        # test local variables 
        local testID="resubmit_1025_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1025.${RANDOM}.out
        local TrackingRequestNickName_negative="TracReq-${testID}"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="The nickname \"$TrackingRequestNickName_negative\" is not allowed" 
        local comment="scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [TrackingRequestNickName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -i $TrackingRequestNickName_negative -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1025

resubmit_1026()  #ipa-getcert resubmit -i [TrackingRequestNickName positive] -N [CertSubjectName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1026 [negative test] scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [CertSubjectName negative]" 

        # test local variables 
        local testID="resubmit_1026_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1026.${RANDOM}.out
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local CertSubjectName_negative="#"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="__errmsg_NOT_FOUND_IN_DB__" 
        local comment="scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [CertSubjectName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -i $TrackingRequestNickName_positive -N $CertSubjectName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1026

resubmit_1027()  #ipa-getcert resubmit -i [TrackingRequestNickName positive] -N [CertSubjectName negative] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1027 [negative test] scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [CertSubjectName negative]" 

        # test local variables 
        local testID="resubmit_1027_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1027.${RANDOM}.out
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local CertSubjectName_negative="#"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="__errmsg_NOT_FOUND_IN_DB__" 
        local comment="scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [CertSubjectName negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -i $TrackingRequestNickName_positive -N $CertSubjectName_negative -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1027

resubmit_1028()  #ipa-getcert resubmit -i [TrackingRequestNickName positive] -N [CertSubjectName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1028 [negative test] scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="resubmit_1028_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1028.${RANDOM}.out
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -i $TrackingRequestNickName_positive -N $CertSubjectName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1028

resubmit_1029()  #ipa-getcert resubmit -i [TrackingRequestNickName positive] -N [CertSubjectName positive] -U [EXTUSAGE negative] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1029 [negative test] scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="resubmit_1029_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1029.${RANDOM}.out
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -i $TrackingRequestNickName_positive -N $CertSubjectName_positive -U $EXTUSAGE_negative -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1029

resubmit_1030()  #ipa-getcert resubmit -i [TrackingRequestNickName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1030 [negative test] scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="resubmit_1030_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1030.${RANDOM}.out
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert resubmit -i $TrackingRequestNickName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1030

resubmit_1031()  #ipa-getcert resubmit -i [TrackingRequestNickName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName negative] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1031 [negative test] scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [CertPrincipalName negative]" 

        # test local variables 
        local testID="resubmit_1031_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1031.${RANDOM}.out
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_negative="NoSuchPrincipal${testID}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="0" 
        local expectedErrMsg="" 
        local comment="scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [CertPrincipalName negative]" 
        local verifyString="status: NEED_KEY_PAIR\|status: CA_UNREACHABLE\|status: CA_UNCONFIGURED"

        # test starts here  
        certRun "ipa-getcert resubmit -i $TrackingRequestNickName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_negative -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1031

resubmit_1032()   #ipa-getcert resubmit -i [TrackingRequestNickName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] 
{ 
    rlPhaseStartTest "resubmit_1032 [positive test] scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: all positive" 

        # local test variables 
        local testID="resubmit_1032_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1032.${RANDOM}.out
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert resubmit -i $TrackingRequestNickName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive" 0 "scenario: [ipa-getcert resubmit -i -N -U -K -D -E]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1032 

resubmit_1033()  #ipa-getcert resubmit -i [TrackingRequestNickName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE negative] 
{ 
    rlPhaseStartTest "resubmit_1033 [negative test] scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 

        # test local variables 
        local testID="resubmit_1033_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1033.${RANDOM}.out
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"
        local EXTUSAGE_negative="in.valid.ext.usage.${testID}"

        # test env setup 
        #no data prepare defined 

        # expectedErrCode expectedErrMsg will be saved in testvalues table 
        local expectedErrCode="1" 
        local expectedErrMsg="Could not evaluate OID" 
        local comment="scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: [EXTUSAGE negative]" 
        # verifyString not defined, it will be ignore 

        # test starts here  
        certRun "ipa-getcert resubmit -i $TrackingRequestNickName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_negative" "$tmpout" $expectedErrCode "$expectedErrMsg" "$comment"  "$verifyString"

        # test evn cleanup 
        #no data cleanup defined 

        # test cleanup 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1033

resubmit_1034()   #ipa-getcert resubmit -i [TrackingRequestNickName positive] -N [CertSubjectName positive] -U [EXTUSAGE positive] -K [CertPrincipalName positive] -D [DNSName positive] -E [EMAIL positive] -U [EXTUSAGE positive] 
{ 
    rlPhaseStartTest "resubmit_1034 [positive test] scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: all positive" 

        # local test variables 
        local testID="resubmit_1034_${RANDOM}" 
        local tmpout=${TmpDir}/resubmit_1034.${RANDOM}.out
        local TrackingRequestNickName_positive="TracReq_${testID}"
        local CertSubjectName_positive="$cert_subject"
        local EXTUSAGE_positive="1.3.6.1.5.5.7.3.1"
        local CertPrincipalName_positive="${testID}/${fqdn}@${RELM}"
        local DNSName_positive="$fqdn"
        local EMAIL_positive="testqa@redhat.com"

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert resubmit -i $TrackingRequestNickName_positive -N $CertSubjectName_positive -U $EXTUSAGE_positive -K $CertPrincipalName_positive -D $DNSName_positive -E $EMAIL_positive -U $EXTUSAGE_positive" 0 "scenario: [ipa-getcert resubmit -i -N -U -K -D -E -I]	data: all positive"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #resubmit_1034 

list()
{ #total test cases: 3
    list_envsetup
    list_1001	#scenario: [ipa-getcert list ]	data: no data passed
    list_1002	#scenario: [ipa-getcert list -r]	data: no data passed
    list_1003	#scenario: [ipa-getcert list -t]	data: no data passed
    list_envcleanup
} #list
list_envsetup()
{
    rlPhaseStartSetup "list_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup
list_envcleanup()
{
    rlPhaseStartCleanup "list_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

list_1001()   #ipa-getcert list  
{ 
    rlPhaseStartTest "list_1001 [positive test] scenario: [ipa-getcert list ]	data: no data passed" 

        # local test variables 
        local testID="list_1001_${RANDOM}" 
        local tmpout=${TmpDir}/list_1001.${RANDOM}.out

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert list " 0 "scenario: [ipa-getcert list ]	data: no data passed"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #list_1001 

list_1002()   #ipa-getcert list -r 
{ 
    rlPhaseStartTest "list_1002 [positive test] scenario: [ipa-getcert list -r]	data: no data passed" 

        # local test variables 
        local testID="list_1002_${RANDOM}" 
        local tmpout=${TmpDir}/list_1002.${RANDOM}.out

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert list -r" 0 "scenario: [ipa-getcert list -r]	data: no data passed"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #list_1002 

list_1003()   #ipa-getcert list -t 
{ 
    rlPhaseStartTest "list_1003 [positive test] scenario: [ipa-getcert list -t]	data: no data passed" 

        # local test variables 
        local testID="list_1003_${RANDOM}" 
        local tmpout=${TmpDir}/list_1003.${RANDOM}.out

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert list -t" 0 "scenario: [ipa-getcert list -t]	data: no data passed"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #list_1003 

list_cas()
{ #total test cases: 1
    list_cas_envsetup
    list_cas_1001	#scenario: [ipa-getcert list-cas ]	data: no data passed
    list_cas_envcleanup
} #list_cas
list_cas_envsetup()
{
    rlPhaseStartSetup "list_cas_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup
list_cas_envcleanup()
{
    rlPhaseStartCleanup "list_cas_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

list_cas_1001()   #ipa-getcert list-cas  
{ 
    rlPhaseStartTest "list_cas_1001 [positive test] scenario: [ipa-getcert list-cas ]	data: no data passed" 

        # local test variables 
        local testID="list_cas_1001_${RANDOM}" 
        local tmpout=${TmpDir}/list_cas_1001.${RANDOM}.out

        # test env setup 
        #no data prepare defined 

        # test starts here  
        rlRun "ipa-getcert list-cas " 0 "scenario: [ipa-getcert list-cas ]	data: no data passed"  
        # test ends here 

        # test env cleanup 
        #no data cleanup defined 

        # test clean up 
        if [ -f $tmpout ];then 
            rm $tmpout 
        fi 
    rlPhaseEnd 
} #list_cas_1001 
