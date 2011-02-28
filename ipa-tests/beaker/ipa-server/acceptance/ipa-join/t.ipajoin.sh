#!/bin/bash
# By  : Automatic Generated by at.3.testcase.pl
# Date: Mon Feb 28 09:17:17 2011

join()
{
    ipa_join
} #join

#############################################
#  test suite: ipa-join (44 test cases)
#############################################
ipa_join()
{
    ipa_join_envsetup
    ipa_join_1001  #test_scenario (negative test): [--bindpw;negative;InvalidPW]
    ipa_join_1002  #test_scenario (positive test): [--bindpw;positive;ValidPW]
    ipa_join_1003  #test_scenario (negative test): [--hostname;negative;NoSuchDomain]
    ipa_join_1004  #test_scenario (negative test): [--hostname;negative;NoSuchDomain --keytab;positive;ValidKeytab --bindpw;positive;ValidPW]
    ipa_join_1005  #test_scenario (negative test): [--hostname;negative;NoSuchDomain --server;positive;FQDN]
    ipa_join_1006  #test_scenario (negative test): [--hostname;negative;NoSuchDomain --server;positive;FQDN --bindpw;positive;ValidPW]
    ipa_join_1007  #test_scenario (negative test): [--hostname;negative;NoSuchDomain --server;positive;FQDN --keytab;positive;ValidKeytab]
    ipa_join_1008  #test_scenario (negative test): [--hostname;negative;NoSuchDomain --server;positive;FQDN --keytab;positive;ValidKeytab --bindpw;positive;ValidPW]
    ipa_join_1009  #test_scenario (negative test): [--hostname;negative;NoSuchDomain--bindpw;positive;ValidPW]
    ipa_join_1010  #test_scenario (negative test): [--hostname;negative;NoSuchDomain--keytab;positive;ValidKeytab]
    ipa_join_1011  #test_scenario (positive test): [--hostname;positive;FQDN]
    ipa_join_1012  #test_scenario (negative test): [--hostname;positive;FQDN --bindpw;negative;InvalidPW]
    ipa_join_1013  #test_scenario (positive test): [--hostname;positive;FQDN --bindpw;positive;ValidPW]
    ipa_join_1014  #test_scenario (negative test): [--hostname;positive;FQDN --keytab;negative;InvalidKeytab]
    ipa_join_1015  #test_scenario (negative test): [--hostname;positive;FQDN --keytab;negative;InvalidKeytab --bindpw;positive;ValidPW]
    ipa_join_1016  #test_scenario (positive test): [--hostname;positive;FQDN --keytab;positive;ValidKeytab]
    ipa_join_1017  #test_scenario (negative test): [--hostname;positive;FQDN --keytab;positive;ValidKeytab --bindpw;negative;InvalidPW]
    ipa_join_1018  #test_scenario (positive test): [--hostname;positive;FQDN --keytab;positive;ValidKeytab --bindpw;positive;ValidPW]
    ipa_join_1019  #test_scenario (negative test): [--hostname;positive;FQDN --server;negative;NoSuchDomain]
    ipa_join_1020  #test_scenario (negative test): [--hostname;positive;FQDN --server;negative;NoSuchDomain --bindpw;positive;ValidPW]
    ipa_join_1021  #test_scenario (negative test): [--hostname;positive;FQDN --server;negative;NoSuchDomain --keytab;positive;ValidKeytab]
    ipa_join_1022  #test_scenario (negative test): [--hostname;positive;FQDN --server;negative;NoSuchDomain --keytab;positive;ValidKeytab --bindpw;positive;ValidPW]
    ipa_join_1023  #test_scenario (positive test): [--hostname;positive;FQDN --server;positive;FQDN]
    ipa_join_1024  #test_scenario (negative test): [--hostname;positive;FQDN --server;positive;FQDN --bindpw;negative;InvalidPW]
    ipa_join_1025  #test_scenario (positive test): [--hostname;positive;FQDN --server;positive;FQDN --bindpw;positive;ValidPW]
    ipa_join_1026  #test_scenario (negative test): [--hostname;positive;FQDN --server;positive;FQDN --keytab;negative;InvalidKeytab]
    ipa_join_1027  #test_scenario (negative test): [--hostname;positive;FQDN --server;positive;FQDN --keytab;negative;InvalidKeytab --bindpw;positive;ValidPW]
    ipa_join_1028  #test_scenario (positive test): [--hostname;positive;FQDN --server;positive;FQDN --keytab;positive;ValidKeytab]
    ipa_join_1029  #test_scenario (negative test): [--hostname;positive;FQDN --server;positive;FQDN --keytab;positive;ValidKeytab --bindpw;negative;InvalidPW]
    ipa_join_1030  #test_scenario (positive test): [--hostname;positive;FQDN --server;positive;FQDN --keytab;positive;ValidKeytab --bindpw;positive;ValidPW]
    ipa_join_1031  #test_scenario (negative test): [--keytab;negative;InvalidKeytab]
    ipa_join_1032  #test_scenario (negative test): [--keytab;negative;InvalidKeytab --bindpw;positive;ValidPW]
    ipa_join_1033  #test_scenario (positive test): [--keytab;positive;ValidKeytab]
    ipa_join_1034  #test_scenario (negative test): [--keytab;positive;ValidKeytab --bindpw;negative;InvalidPW]
    ipa_join_1035  #test_scenario (positive test): [--keytab;positive;ValidKeytab --bindpw;positive;ValidPW]
    ipa_join_1036  #test_scenario (negative test): [--server;negative;NoSuchDomain]
    ipa_join_1037  #test_scenario (negative test): [--server;negative;NoSuchDomain --bindpw;positive;ValidPW]
    ipa_join_1038  #test_scenario (negative test): [--server;negative;NoSuchDomain--keytab;positive;ValidKeytab]
    ipa_join_1039  #test_scenario (positive test): [--server;positive;FQDN]
    ipa_join_1040  #test_scenario (negative test): [--server;positive;FQDN --bindpw;negative;InvalidPW]
    ipa_join_1041  #test_scenario (positive test): [--server;positive;FQDN --bindpw;positive;ValidPW]
    ipa_join_1042  #test_scenario (negative test): [--server;positive;FQDN --keytab;negative;InvalidKeytab]
    ipa_join_1043  #test_scenario (positive test): [--server;positive;FQDN --keytab;positive;ValidKeytab]
    ipa_join_1044  #test_scenario (positive test): [--unenroll]
    ipa_join_envcleanup
} #ipa-join

ipa_join_envsetup()
{
    rlPhaseStartSetup "ipa_join_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

ipa_join_envcleanup()
{
    rlPhaseStartCleanup "ipa_join_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

ipa_join_1001()
{
    rlPhaseStartTest "ipa_join_1001 [negative test] --bindpw;negative;InvalidPW"
        local testID="ipa_join_1001"
        local tmpout=$TmpDir/ipa_join_1001.$RANDOM.out
        KinitAsAdmin
        local bindpw_TestValue_Negative="replace_me" #bindpw;negative;InvalidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --bindpw=$bindpw_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [bindpw]=[$bindpw_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1001

ipa_join_1002()
{
    rlPhaseStartTest "ipa_join_1002 [positive test] --bindpw;positive;ValidPW"
        local testID="ipa_join_1002"
        local tmpout=$TmpDir/ipa_join_1002.$RANDOM.out
        KinitAsAdmin
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        rlRun "ipa-join --bindpw=$bindpw_TestValue " 0 "test options:  [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1002

ipa_join_1003()
{
    rlPhaseStartTest "ipa_join_1003 [negative test] --hostname;negative;NoSuchDomain"
        local testID="ipa_join_1003"
        local tmpout=$TmpDir/ipa_join_1003.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue_Negative="replace_me" #hostname;negative;NoSuchDomain
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1003

ipa_join_1004()
{
    rlPhaseStartTest "ipa_join_1004 [negative test] --hostname;negative;NoSuchDomain --keytab;positive;ValidKeytab --bindpw;positive;ValidPW"
        local testID="ipa_join_1004"
        local tmpout=$TmpDir/ipa_join_1004.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue_Negative="replace_me" #hostname;negative;NoSuchDomain 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue_Negative  --keytab=$keytab_TestValue  --bindpw=$bindpw_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue_Negative] [keytab]=[$keytab_TestValue] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1004

ipa_join_1005()
{
    rlPhaseStartTest "ipa_join_1005 [negative test] --hostname;negative;NoSuchDomain --server;positive;FQDN"
        local testID="ipa_join_1005"
        local tmpout=$TmpDir/ipa_join_1005.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue_Negative="replace_me" #hostname;negative;NoSuchDomain 
        local server_TestValue="replace_me" #server;positive;FQDN
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue_Negative  --server=$server_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue_Negative] [server]=[$server_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1005

ipa_join_1006()
{
    rlPhaseStartTest "ipa_join_1006 [negative test] --hostname;negative;NoSuchDomain --server;positive;FQDN --bindpw;positive;ValidPW"
        local testID="ipa_join_1006"
        local tmpout=$TmpDir/ipa_join_1006.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue_Negative="replace_me" #hostname;negative;NoSuchDomain 
        local server_TestValue="replace_me" #server;positive;FQDN 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue_Negative  --server=$server_TestValue  --bindpw=$bindpw_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue_Negative] [server]=[$server_TestValue] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1006

ipa_join_1007()
{
    rlPhaseStartTest "ipa_join_1007 [negative test] --hostname;negative;NoSuchDomain --server;positive;FQDN --keytab;positive;ValidKeytab"
        local testID="ipa_join_1007"
        local tmpout=$TmpDir/ipa_join_1007.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue_Negative="replace_me" #hostname;negative;NoSuchDomain 
        local server_TestValue="replace_me" #server;positive;FQDN 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue_Negative  --server=$server_TestValue  --keytab=$keytab_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue_Negative] [server]=[$server_TestValue] [keytab]=[$keytab_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1007

ipa_join_1008()
{
    rlPhaseStartTest "ipa_join_1008 [negative test] --hostname;negative;NoSuchDomain --server;positive;FQDN --keytab;positive;ValidKeytab --bindpw;positive;ValidPW"
        local testID="ipa_join_1008"
        local tmpout=$TmpDir/ipa_join_1008.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue_Negative="replace_me" #hostname;negative;NoSuchDomain 
        local server_TestValue="replace_me" #server;positive;FQDN 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue_Negative  --server=$server_TestValue  --keytab=$keytab_TestValue  --bindpw=$bindpw_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue_Negative] [server]=[$server_TestValue] [keytab]=[$keytab_TestValue] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1008

ipa_join_1009()
{
    rlPhaseStartTest "ipa_join_1009 [negative test] --hostname;negative;NoSuchDomain--bindpw;positive;ValidPW"
        local testID="ipa_join_1009"
        local tmpout=$TmpDir/ipa_join_1009.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue_Negative="replace_me" #hostname;negative;NoSuchDomain
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue_Negative  --bindpw=$bindpw_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue_Negative] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1009

ipa_join_1010()
{
    rlPhaseStartTest "ipa_join_1010 [negative test] --hostname;negative;NoSuchDomain--keytab;positive;ValidKeytab"
        local testID="ipa_join_1010"
        local tmpout=$TmpDir/ipa_join_1010.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue_Negative="replace_me" #hostname;negative;NoSuchDomain
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue_Negative  --keytab=$keytab_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue_Negative] [keytab]=[$keytab_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1010

ipa_join_1011()
{
    rlPhaseStartTest "ipa_join_1011 [positive test] --hostname;positive;FQDN"
        local testID="ipa_join_1011"
        local tmpout=$TmpDir/ipa_join_1011.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN
        rlRun "ipa-join --hostname=$hostname_TestValue " 0 "test options:  [hostname]=[$hostname_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1011

ipa_join_1012()
{
    rlPhaseStartTest "ipa_join_1012 [negative test] --hostname;positive;FQDN --bindpw;negative;InvalidPW"
        local testID="ipa_join_1012"
        local tmpout=$TmpDir/ipa_join_1012.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local bindpw_TestValue_Negative="replace_me" #bindpw;negative;InvalidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --bindpw=$bindpw_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [bindpw]=[$bindpw_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1012

ipa_join_1013()
{
    rlPhaseStartTest "ipa_join_1013 [positive test] --hostname;positive;FQDN --bindpw;positive;ValidPW"
        local testID="ipa_join_1013"
        local tmpout=$TmpDir/ipa_join_1013.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        rlRun "ipa-join --hostname=$hostname_TestValue  --bindpw=$bindpw_TestValue " 0 "test options:  [hostname]=[$hostname_TestValue] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1013

ipa_join_1014()
{
    rlPhaseStartTest "ipa_join_1014 [negative test] --hostname;positive;FQDN --keytab;negative;InvalidKeytab"
        local testID="ipa_join_1014"
        local tmpout=$TmpDir/ipa_join_1014.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local keytab_TestValue_Negative="replace_me" #keytab;negative;InvalidKeytab
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --keytab=$keytab_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [keytab]=[$keytab_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1014

ipa_join_1015()
{
    rlPhaseStartTest "ipa_join_1015 [negative test] --hostname;positive;FQDN --keytab;negative;InvalidKeytab --bindpw;positive;ValidPW"
        local testID="ipa_join_1015"
        local tmpout=$TmpDir/ipa_join_1015.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local keytab_TestValue_Negative="replace_me" #keytab;negative;InvalidKeytab 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --keytab=$keytab_TestValue_Negative  --bindpw=$bindpw_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [keytab]=[$keytab_TestValue_Negative] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1015

ipa_join_1016()
{
    rlPhaseStartTest "ipa_join_1016 [positive test] --hostname;positive;FQDN --keytab;positive;ValidKeytab"
        local testID="ipa_join_1016"
        local tmpout=$TmpDir/ipa_join_1016.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab
        rlRun "ipa-join --hostname=$hostname_TestValue  --keytab=$keytab_TestValue " 0 "test options:  [hostname]=[$hostname_TestValue] [keytab]=[$keytab_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1016

ipa_join_1017()
{
    rlPhaseStartTest "ipa_join_1017 [negative test] --hostname;positive;FQDN --keytab;positive;ValidKeytab --bindpw;negative;InvalidPW"
        local testID="ipa_join_1017"
        local tmpout=$TmpDir/ipa_join_1017.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab 
        local bindpw_TestValue_Negative="replace_me" #bindpw;negative;InvalidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --keytab=$keytab_TestValue  --bindpw=$bindpw_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [keytab]=[$keytab_TestValue] [bindpw]=[$bindpw_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1017

ipa_join_1018()
{
    rlPhaseStartTest "ipa_join_1018 [positive test] --hostname;positive;FQDN --keytab;positive;ValidKeytab --bindpw;positive;ValidPW"
        local testID="ipa_join_1018"
        local tmpout=$TmpDir/ipa_join_1018.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        rlRun "ipa-join --hostname=$hostname_TestValue  --keytab=$keytab_TestValue  --bindpw=$bindpw_TestValue " 0 "test options:  [hostname]=[$hostname_TestValue] [keytab]=[$keytab_TestValue] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1018

ipa_join_1019()
{
    rlPhaseStartTest "ipa_join_1019 [negative test] --hostname;positive;FQDN --server;negative;NoSuchDomain"
        local testID="ipa_join_1019"
        local tmpout=$TmpDir/ipa_join_1019.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue_Negative="replace_me" #server;negative;NoSuchDomain
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1019

ipa_join_1020()
{
    rlPhaseStartTest "ipa_join_1020 [negative test] --hostname;positive;FQDN --server;negative;NoSuchDomain --bindpw;positive;ValidPW"
        local testID="ipa_join_1020"
        local tmpout=$TmpDir/ipa_join_1020.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue_Negative="replace_me" #server;negative;NoSuchDomain 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue_Negative  --bindpw=$bindpw_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue_Negative] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1020

ipa_join_1021()
{
    rlPhaseStartTest "ipa_join_1021 [negative test] --hostname;positive;FQDN --server;negative;NoSuchDomain --keytab;positive;ValidKeytab"
        local testID="ipa_join_1021"
        local tmpout=$TmpDir/ipa_join_1021.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue_Negative="replace_me" #server;negative;NoSuchDomain 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue_Negative  --keytab=$keytab_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue_Negative] [keytab]=[$keytab_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1021

ipa_join_1022()
{
    rlPhaseStartTest "ipa_join_1022 [negative test] --hostname;positive;FQDN --server;negative;NoSuchDomain --keytab;positive;ValidKeytab --bindpw;positive;ValidPW"
        local testID="ipa_join_1022"
        local tmpout=$TmpDir/ipa_join_1022.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue_Negative="replace_me" #server;negative;NoSuchDomain 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue_Negative  --keytab=$keytab_TestValue  --bindpw=$bindpw_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue_Negative] [keytab]=[$keytab_TestValue] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1022

ipa_join_1023()
{
    rlPhaseStartTest "ipa_join_1023 [positive test] --hostname;positive;FQDN --server;positive;FQDN"
        local testID="ipa_join_1023"
        local tmpout=$TmpDir/ipa_join_1023.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue="replace_me" #server;positive;FQDN
        rlRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue " 0 "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1023

ipa_join_1024()
{
    rlPhaseStartTest "ipa_join_1024 [negative test] --hostname;positive;FQDN --server;positive;FQDN --bindpw;negative;InvalidPW"
        local testID="ipa_join_1024"
        local tmpout=$TmpDir/ipa_join_1024.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue="replace_me" #server;positive;FQDN 
        local bindpw_TestValue_Negative="replace_me" #bindpw;negative;InvalidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue  --bindpw=$bindpw_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue] [bindpw]=[$bindpw_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1024

ipa_join_1025()
{
    rlPhaseStartTest "ipa_join_1025 [positive test] --hostname;positive;FQDN --server;positive;FQDN --bindpw;positive;ValidPW"
        local testID="ipa_join_1025"
        local tmpout=$TmpDir/ipa_join_1025.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue="replace_me" #server;positive;FQDN 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        rlRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue  --bindpw=$bindpw_TestValue " 0 "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1025

ipa_join_1026()
{
    rlPhaseStartTest "ipa_join_1026 [negative test] --hostname;positive;FQDN --server;positive;FQDN --keytab;negative;InvalidKeytab"
        local testID="ipa_join_1026"
        local tmpout=$TmpDir/ipa_join_1026.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue="replace_me" #server;positive;FQDN 
        local keytab_TestValue_Negative="replace_me" #keytab;negative;InvalidKeytab
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue  --keytab=$keytab_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue] [keytab]=[$keytab_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1026

ipa_join_1027()
{
    rlPhaseStartTest "ipa_join_1027 [negative test] --hostname;positive;FQDN --server;positive;FQDN --keytab;negative;InvalidKeytab --bindpw;positive;ValidPW"
        local testID="ipa_join_1027"
        local tmpout=$TmpDir/ipa_join_1027.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue="replace_me" #server;positive;FQDN 
        local keytab_TestValue_Negative="replace_me" #keytab;negative;InvalidKeytab 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue  --keytab=$keytab_TestValue_Negative  --bindpw=$bindpw_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue] [keytab]=[$keytab_TestValue_Negative] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1027

ipa_join_1028()
{
    rlPhaseStartTest "ipa_join_1028 [positive test] --hostname;positive;FQDN --server;positive;FQDN --keytab;positive;ValidKeytab"
        local testID="ipa_join_1028"
        local tmpout=$TmpDir/ipa_join_1028.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue="replace_me" #server;positive;FQDN 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab
        rlRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue  --keytab=$keytab_TestValue " 0 "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue] [keytab]=[$keytab_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1028

ipa_join_1029()
{
    rlPhaseStartTest "ipa_join_1029 [negative test] --hostname;positive;FQDN --server;positive;FQDN --keytab;positive;ValidKeytab --bindpw;negative;InvalidPW"
        local testID="ipa_join_1029"
        local tmpout=$TmpDir/ipa_join_1029.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue="replace_me" #server;positive;FQDN 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab 
        local bindpw_TestValue_Negative="replace_me" #bindpw;negative;InvalidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue  --keytab=$keytab_TestValue  --bindpw=$bindpw_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue] [keytab]=[$keytab_TestValue] [bindpw]=[$bindpw_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1029

ipa_join_1030()
{
    rlPhaseStartTest "ipa_join_1030 [positive test] --hostname;positive;FQDN --server;positive;FQDN --keytab;positive;ValidKeytab --bindpw;positive;ValidPW"
        local testID="ipa_join_1030"
        local tmpout=$TmpDir/ipa_join_1030.$RANDOM.out
        KinitAsAdmin
        local hostname_TestValue="replace_me" #hostname;positive;FQDN 
        local server_TestValue="replace_me" #server;positive;FQDN 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        rlRun "ipa-join --hostname=$hostname_TestValue  --server=$server_TestValue  --keytab=$keytab_TestValue  --bindpw=$bindpw_TestValue " 0 "test options:  [hostname]=[$hostname_TestValue] [server]=[$server_TestValue] [keytab]=[$keytab_TestValue] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1030

ipa_join_1031()
{
    rlPhaseStartTest "ipa_join_1031 [negative test] --keytab;negative;InvalidKeytab"
        local testID="ipa_join_1031"
        local tmpout=$TmpDir/ipa_join_1031.$RANDOM.out
        KinitAsAdmin
        local keytab_TestValue_Negative="replace_me" #keytab;negative;InvalidKeytab
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --keytab=$keytab_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [keytab]=[$keytab_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1031

ipa_join_1032()
{
    rlPhaseStartTest "ipa_join_1032 [negative test] --keytab;negative;InvalidKeytab --bindpw;positive;ValidPW"
        local testID="ipa_join_1032"
        local tmpout=$TmpDir/ipa_join_1032.$RANDOM.out
        KinitAsAdmin
        local keytab_TestValue_Negative="replace_me" #keytab;negative;InvalidKeytab 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --keytab=$keytab_TestValue_Negative  --bindpw=$bindpw_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [keytab]=[$keytab_TestValue_Negative] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1032

ipa_join_1033()
{
    rlPhaseStartTest "ipa_join_1033 [positive test] --keytab;positive;ValidKeytab"
        local testID="ipa_join_1033"
        local tmpout=$TmpDir/ipa_join_1033.$RANDOM.out
        KinitAsAdmin
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab
        rlRun "ipa-join --keytab=$keytab_TestValue " 0 "test options:  [keytab]=[$keytab_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1033

ipa_join_1034()
{
    rlPhaseStartTest "ipa_join_1034 [negative test] --keytab;positive;ValidKeytab --bindpw;negative;InvalidPW"
        local testID="ipa_join_1034"
        local tmpout=$TmpDir/ipa_join_1034.$RANDOM.out
        KinitAsAdmin
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab 
        local bindpw_TestValue_Negative="replace_me" #bindpw;negative;InvalidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --keytab=$keytab_TestValue  --bindpw=$bindpw_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [keytab]=[$keytab_TestValue] [bindpw]=[$bindpw_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1034

ipa_join_1035()
{
    rlPhaseStartTest "ipa_join_1035 [positive test] --keytab;positive;ValidKeytab --bindpw;positive;ValidPW"
        local testID="ipa_join_1035"
        local tmpout=$TmpDir/ipa_join_1035.$RANDOM.out
        KinitAsAdmin
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        rlRun "ipa-join --keytab=$keytab_TestValue  --bindpw=$bindpw_TestValue " 0 "test options:  [keytab]=[$keytab_TestValue] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1035

ipa_join_1036()
{
    rlPhaseStartTest "ipa_join_1036 [negative test] --server;negative;NoSuchDomain"
        local testID="ipa_join_1036"
        local tmpout=$TmpDir/ipa_join_1036.$RANDOM.out
        KinitAsAdmin
        local server_TestValue_Negative="replace_me" #server;negative;NoSuchDomain
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --server=$server_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [server]=[$server_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1036

ipa_join_1037()
{
    rlPhaseStartTest "ipa_join_1037 [negative test] --server;negative;NoSuchDomain --bindpw;positive;ValidPW"
        local testID="ipa_join_1037"
        local tmpout=$TmpDir/ipa_join_1037.$RANDOM.out
        KinitAsAdmin
        local server_TestValue_Negative="replace_me" #server;negative;NoSuchDomain 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --server=$server_TestValue_Negative  --bindpw=$bindpw_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [server]=[$server_TestValue_Negative] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1037

ipa_join_1038()
{
    rlPhaseStartTest "ipa_join_1038 [negative test] --server;negative;NoSuchDomain--keytab;positive;ValidKeytab"
        local testID="ipa_join_1038"
        local tmpout=$TmpDir/ipa_join_1038.$RANDOM.out
        KinitAsAdmin
        local server_TestValue_Negative="replace_me" #server;negative;NoSuchDomain
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --server=$server_TestValue_Negative  --keytab=$keytab_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [server]=[$server_TestValue_Negative] [keytab]=[$keytab_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1038

ipa_join_1039()
{
    rlPhaseStartTest "ipa_join_1039 [positive test] --server;positive;FQDN"
        local testID="ipa_join_1039"
        local tmpout=$TmpDir/ipa_join_1039.$RANDOM.out
        KinitAsAdmin
        local server_TestValue="replace_me" #server;positive;FQDN
        rlRun "ipa-join --server=$server_TestValue " 0 "test options:  [server]=[$server_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1039

ipa_join_1040()
{
    rlPhaseStartTest "ipa_join_1040 [negative test] --server;positive;FQDN --bindpw;negative;InvalidPW"
        local testID="ipa_join_1040"
        local tmpout=$TmpDir/ipa_join_1040.$RANDOM.out
        KinitAsAdmin
        local server_TestValue="replace_me" #server;positive;FQDN 
        local bindpw_TestValue_Negative="replace_me" #bindpw;negative;InvalidPW
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --server=$server_TestValue  --bindpw=$bindpw_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [server]=[$server_TestValue] [bindpw]=[$bindpw_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1040

ipa_join_1041()
{
    rlPhaseStartTest "ipa_join_1041 [positive test] --server;positive;FQDN --bindpw;positive;ValidPW"
        local testID="ipa_join_1041"
        local tmpout=$TmpDir/ipa_join_1041.$RANDOM.out
        KinitAsAdmin
        local server_TestValue="replace_me" #server;positive;FQDN 
        local bindpw_TestValue="replace_me" #bindpw;positive;ValidPW
        rlRun "ipa-join --server=$server_TestValue  --bindpw=$bindpw_TestValue " 0 "test options:  [server]=[$server_TestValue] [bindpw]=[$bindpw_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1041

ipa_join_1042()
{
    rlPhaseStartTest "ipa_join_1042 [negative test] --server;positive;FQDN --keytab;negative;InvalidKeytab"
        local testID="ipa_join_1042"
        local tmpout=$TmpDir/ipa_join_1042.$RANDOM.out
        KinitAsAdmin
        local server_TestValue="replace_me" #server;positive;FQDN 
        local keytab_TestValue_Negative="replace_me" #keytab;negative;InvalidKeytab
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa-join --server=$server_TestValue  --keytab=$keytab_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [server]=[$server_TestValue] [keytab]=[$keytab_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1042

ipa_join_1043()
{
    rlPhaseStartTest "ipa_join_1043 [positive test] --server;positive;FQDN --keytab;positive;ValidKeytab"
        local testID="ipa_join_1043"
        local tmpout=$TmpDir/ipa_join_1043.$RANDOM.out
        KinitAsAdmin
        local server_TestValue="replace_me" #server;positive;FQDN 
        local keytab_TestValue="replace_me" #keytab;positive;ValidKeytab
        rlRun "ipa-join --server=$server_TestValue  --keytab=$keytab_TestValue " 0 "test options:  [server]=[$server_TestValue] [keytab]=[$keytab_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1043

ipa_join_1044()
{
    rlPhaseStartTest "ipa_join_1044 [positive test] --unenroll"
        local testID="ipa_join_1044"
        local tmpout=$TmpDir/ipa_join_1044.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa-join--unenroll " 0 "test options: " 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #ipa_join_1044

#END OF TEST CASE for [ipa-join]
