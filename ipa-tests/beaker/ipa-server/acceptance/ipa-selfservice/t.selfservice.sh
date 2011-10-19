#!/bin/bash
# By  : Automatic Generated by at.3.testcase.pl
# Date: Wed Oct 19 14:47:04 2011

selfservice()
{
    selfservice_add
    selfservice_del
    selfservice_find
    selfservice_mod
    selfservice_show
} #selfservice

#############################################
#  test suite: selfservice-add (9 test cases)
#############################################
selfservice_add()
{
    selfservice_add_envsetup
    selfservice_add_1001  #test_scenario (positive test): [--all]
    selfservice_add_1002  #test_scenario (negative test): [--all --attrs;negative;LIST --permissions;positive;LIST --raw]
    selfservice_add_1003  #test_scenario (negative test): [--all --attrs;positive;LIST --permissions;negative;LIST --raw]
    selfservice_add_1004  #test_scenario (positive test): [--all --attrs;positive;LIST --permissions;positive;LIST --raw]
    selfservice_add_1005  #test_scenario (negative test): [--attrs;negative;LIST]
    selfservice_add_1006  #test_scenario (positive test): [--attrs;positive;LIST]
    selfservice_add_1007  #test_scenario (negative test): [--permissions;negative;LIST]
    selfservice_add_1008  #test_scenario (positive test): [--permissions;positive;LIST]
    selfservice_add_1009  #test_scenario (positive test): [--raw]
    selfservice_add_envcleanup
} #selfservice-add

selfservice_add_envsetup()
{
    rlPhaseStartSetup "selfservice_add_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

selfservice_add_envcleanup()
{
    rlPhaseStartCleanup "selfservice_add_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

selfservice_add_1001()
{
    rlPhaseStartTest "selfservice_add_1001 [positive test] --all"
        local testID="selfservice_add_1001"
        local tmpout=$TmpDir/selfservice_add_1001.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa selfservice-add $testID --all " 0 "test options: " 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_add_1001

selfservice_add_1002()
{
    rlPhaseStartTest "selfservice_add_1002 [negative test] --all --attrs;negative;LIST --permissions;positive;LIST --raw"
        local testID="selfservice_add_1002"
        local tmpout=$TmpDir/selfservice_add_1002.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue_Negative="replace_me" #attrs;negative;LIST 
        local permissions_TestValue="replace_me" #permissions;positive;LIST 
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-add $testID --all  --attrs=$attrs_TestValue_Negative  --permissions=$permissions_TestValue --raw " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue_Negative] [permissions]=[$permissions_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_add_1002

selfservice_add_1003()
{
    rlPhaseStartTest "selfservice_add_1003 [negative test] --all --attrs;positive;LIST --permissions;negative;LIST --raw"
        local testID="selfservice_add_1003"
        local tmpout=$TmpDir/selfservice_add_1003.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="replace_me" #attrs;positive;LIST 
        local permissions_TestValue_Negative="replace_me" #permissions;negative;LIST 
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-add $testID --all  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue_Negative --raw " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_add_1003

selfservice_add_1004()
{
    rlPhaseStartTest "selfservice_add_1004 [positive test] --all --attrs;positive;LIST --permissions;positive;LIST --raw"
        local testID="selfservice_add_1004"
        local tmpout=$TmpDir/selfservice_add_1004.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="replace_me" #attrs;positive;LIST 
        local permissions_TestValue="replace_me" #permissions;positive;LIST 
        rlRun "ipa selfservice-add $testID --all  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue --raw " 0 "test options:  [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_add_1004

selfservice_add_1005()
{
    rlPhaseStartTest "selfservice_add_1005 [negative test] --attrs;negative;LIST"
        local testID="selfservice_add_1005"
        local tmpout=$TmpDir/selfservice_add_1005.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue_Negative="replace_me" #attrs;negative;LIST
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-add $testID  --attrs=$attrs_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_add_1005

selfservice_add_1006()
{
    rlPhaseStartTest "selfservice_add_1006 [positive test] --attrs;positive;LIST"
        local testID="selfservice_add_1006"
        local tmpout=$TmpDir/selfservice_add_1006.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="replace_me" #attrs;positive;LIST
        rlRun "ipa selfservice-add $testID  --attrs=$attrs_TestValue " 0 "test options:  [attrs]=[$attrs_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_add_1006

selfservice_add_1007()
{
    rlPhaseStartTest "selfservice_add_1007 [negative test] --permissions;negative;LIST"
        local testID="selfservice_add_1007"
        local tmpout=$TmpDir/selfservice_add_1007.$RANDOM.out
        KinitAsAdmin
        local permissions_TestValue_Negative="replace_me" #permissions;negative;LIST
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-add $testID  --permissions=$permissions_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [permissions]=[$permissions_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_add_1007

selfservice_add_1008()
{
    rlPhaseStartTest "selfservice_add_1008 [positive test] --permissions;positive;LIST"
        local testID="selfservice_add_1008"
        local tmpout=$TmpDir/selfservice_add_1008.$RANDOM.out
        KinitAsAdmin
        local permissions_TestValue="replace_me" #permissions;positive;LIST
        rlRun "ipa selfservice-add $testID  --permissions=$permissions_TestValue " 0 "test options:  [permissions]=[$permissions_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_add_1008

selfservice_add_1009()
{
    rlPhaseStartTest "selfservice_add_1009 [positive test] --raw"
        local testID="selfservice_add_1009"
        local tmpout=$TmpDir/selfservice_add_1009.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa selfservice-add $testID --raw " 0 "test options: " 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_add_1009

#END OF TEST CASE for [selfservice-add]

#############################################
#  test suite: selfservice-del (9 test cases)
#############################################
selfservice_del()
{
    selfservice_del_envsetup
    selfservice_del_envcleanup
} #selfservice-del

selfservice_del_envsetup()
{
    rlPhaseStartSetup "selfservice_del_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

selfservice_del_envcleanup()
{
    rlPhaseStartCleanup "selfservice_del_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

#END OF TEST CASE for [selfservice-del]

#############################################
#  test suite: selfservice-find (12 test cases)
#############################################
selfservice_find()
{
    selfservice_find_envsetup
    selfservice_find_1001  #test_scenario (positive test): [--all]
    selfservice_find_1002  #test_scenario (negative test): [--all --attrs;negative;LIST --name;positive;STR --permissions;positive;LIST --raw]
    selfservice_find_1003  #test_scenario (negative test): [--all --attrs;positive;LIST --name;negative;STR --permissions;positive;LIST --raw]
    selfservice_find_1004  #test_scenario (negative test): [--all --attrs;positive;LIST --name;positive;STR --permissions;negative;LIST --raw]
    selfservice_find_1005  #test_scenario (positive test): [--all --attrs;positive;LIST --name;positive;STR --permissions;positive;LIST --raw]
    selfservice_find_1006  #test_scenario (negative test): [--attrs;negative;LIST]
    selfservice_find_1007  #test_scenario (positive test): [--attrs;positive;LIST]
    selfservice_find_1008  #test_scenario (negative test): [--name;negative;STR]
    selfservice_find_1009  #test_scenario (positive test): [--name;positive;STR]
    selfservice_find_1010  #test_scenario (negative test): [--permissions;negative;LIST]
    selfservice_find_1011  #test_scenario (positive test): [--permissions;positive;LIST]
    selfservice_find_1012  #test_scenario (positive test): [--raw]
    selfservice_find_envcleanup
} #selfservice-find

selfservice_find_envsetup()
{
    rlPhaseStartSetup "selfservice_find_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

selfservice_find_envcleanup()
{
    rlPhaseStartCleanup "selfservice_find_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

selfservice_find_1001()
{
    rlPhaseStartTest "selfservice_find_1001 [positive test] --all"
        local testID="selfservice_find_1001"
        local tmpout=$TmpDir/selfservice_find_1001.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa selfservice-find $testID --all " 0 "test options: " 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1001

selfservice_find_1002()
{
    rlPhaseStartTest "selfservice_find_1002 [negative test] --all --attrs;negative;LIST --name;positive;STR --permissions;positive;LIST --raw"
        local testID="selfservice_find_1002"
        local tmpout=$TmpDir/selfservice_find_1002.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue_Negative="replace_me" #attrs;negative;LIST 
        local name_TestValue="replace_me" #name;positive;STR 
        local permissions_TestValue="replace_me" #permissions;positive;LIST 
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-find $testID --all  --attrs=$attrs_TestValue_Negative  --name=$name_TestValue  --permissions=$permissions_TestValue --raw " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue_Negative] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1002

selfservice_find_1003()
{
    rlPhaseStartTest "selfservice_find_1003 [negative test] --all --attrs;positive;LIST --name;negative;STR --permissions;positive;LIST --raw"
        local testID="selfservice_find_1003"
        local tmpout=$TmpDir/selfservice_find_1003.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="replace_me" #attrs;positive;LIST 
        local name_TestValue_Negative="replace_me" #name;negative;STR 
        local permissions_TestValue="replace_me" #permissions;positive;LIST 
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-find $testID --all  --attrs=$attrs_TestValue  --name=$name_TestValue_Negative  --permissions=$permissions_TestValue --raw " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [name]=[$name_TestValue_Negative] [permissions]=[$permissions_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1003

selfservice_find_1004()
{
    rlPhaseStartTest "selfservice_find_1004 [negative test] --all --attrs;positive;LIST --name;positive;STR --permissions;negative;LIST --raw"
        local testID="selfservice_find_1004"
        local tmpout=$TmpDir/selfservice_find_1004.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="replace_me" #attrs;positive;LIST 
        local name_TestValue="replace_me" #name;positive;STR 
        local permissions_TestValue_Negative="replace_me" #permissions;negative;LIST 
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-find $testID --all  --attrs=$attrs_TestValue  --name=$name_TestValue  --permissions=$permissions_TestValue_Negative --raw " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1004

selfservice_find_1005()
{
    rlPhaseStartTest "selfservice_find_1005 [positive test] --all --attrs;positive;LIST --name;positive;STR --permissions;positive;LIST --raw"
        local testID="selfservice_find_1005"
        local tmpout=$TmpDir/selfservice_find_1005.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="replace_me" #attrs;positive;LIST 
        local name_TestValue="replace_me" #name;positive;STR 
        local permissions_TestValue="replace_me" #permissions;positive;LIST 
        rlRun "ipa selfservice-find $testID --all  --attrs=$attrs_TestValue  --name=$name_TestValue  --permissions=$permissions_TestValue --raw " 0 "test options:  [attrs]=[$attrs_TestValue] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1005

selfservice_find_1006()
{
    rlPhaseStartTest "selfservice_find_1006 [negative test] --attrs;negative;LIST"
        local testID="selfservice_find_1006"
        local tmpout=$TmpDir/selfservice_find_1006.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue_Negative="replace_me" #attrs;negative;LIST
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-find $testID  --attrs=$attrs_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1006

selfservice_find_1007()
{
    rlPhaseStartTest "selfservice_find_1007 [positive test] --attrs;positive;LIST"
        local testID="selfservice_find_1007"
        local tmpout=$TmpDir/selfservice_find_1007.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="replace_me" #attrs;positive;LIST
        rlRun "ipa selfservice-find $testID  --attrs=$attrs_TestValue " 0 "test options:  [attrs]=[$attrs_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1007

selfservice_find_1008()
{
    rlPhaseStartTest "selfservice_find_1008 [negative test] --name;negative;STR"
        local testID="selfservice_find_1008"
        local tmpout=$TmpDir/selfservice_find_1008.$RANDOM.out
        KinitAsAdmin
        local name_TestValue_Negative="replace_me" #name;negative;STR
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-find $testID  --name=$name_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [name]=[$name_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1008

selfservice_find_1009()
{
    rlPhaseStartTest "selfservice_find_1009 [positive test] --name;positive;STR"
        local testID="selfservice_find_1009"
        local tmpout=$TmpDir/selfservice_find_1009.$RANDOM.out
        KinitAsAdmin
        local name_TestValue="replace_me" #name;positive;STR
        rlRun "ipa selfservice-find $testID  --name=$name_TestValue " 0 "test options:  [name]=[$name_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1009

selfservice_find_1010()
{
    rlPhaseStartTest "selfservice_find_1010 [negative test] --permissions;negative;LIST"
        local testID="selfservice_find_1010"
        local tmpout=$TmpDir/selfservice_find_1010.$RANDOM.out
        KinitAsAdmin
        local permissions_TestValue_Negative="replace_me" #permissions;negative;LIST
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-find $testID  --permissions=$permissions_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [permissions]=[$permissions_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1010

selfservice_find_1011()
{
    rlPhaseStartTest "selfservice_find_1011 [positive test] --permissions;positive;LIST"
        local testID="selfservice_find_1011"
        local tmpout=$TmpDir/selfservice_find_1011.$RANDOM.out
        KinitAsAdmin
        local permissions_TestValue="replace_me" #permissions;positive;LIST
        rlRun "ipa selfservice-find $testID  --permissions=$permissions_TestValue " 0 "test options:  [permissions]=[$permissions_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1011

selfservice_find_1012()
{
    rlPhaseStartTest "selfservice_find_1012 [positive test] --raw"
        local testID="selfservice_find_1012"
        local tmpout=$TmpDir/selfservice_find_1012.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa selfservice-find $testID --raw " 0 "test options: " 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_find_1012

#END OF TEST CASE for [selfservice-find]

#############################################
#  test suite: selfservice-mod (9 test cases)
#############################################
selfservice_mod()
{
    selfservice_mod_envsetup
    selfservice_mod_1001  #test_scenario (positive test): [--all]
    selfservice_mod_1002  #test_scenario (negative test): [--all --attrs;negative;LIST --permissions;positive;LIST --raw]
    selfservice_mod_1003  #test_scenario (negative test): [--all --attrs;positive;LIST --permissions;negative;LIST --raw]
    selfservice_mod_1004  #test_scenario (positive test): [--all --attrs;positive;LIST --permissions;positive;LIST --raw]
    selfservice_mod_1005  #test_scenario (negative test): [--attrs;negative;LIST]
    selfservice_mod_1006  #test_scenario (positive test): [--attrs;positive;LIST]
    selfservice_mod_1007  #test_scenario (negative test): [--permissions;negative;LIST]
    selfservice_mod_1008  #test_scenario (positive test): [--permissions;positive;LIST]
    selfservice_mod_1009  #test_scenario (positive test): [--raw]
    selfservice_mod_envcleanup
} #selfservice-mod

selfservice_mod_envsetup()
{
    rlPhaseStartSetup "selfservice_mod_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

selfservice_mod_envcleanup()
{
    rlPhaseStartCleanup "selfservice_mod_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

selfservice_mod_1001()
{
    rlPhaseStartTest "selfservice_mod_1001 [positive test] --all"
        local testID="selfservice_mod_1001"
        local tmpout=$TmpDir/selfservice_mod_1001.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa selfservice-mod $testID --all " 0 "test options: " 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_mod_1001

selfservice_mod_1002()
{
    rlPhaseStartTest "selfservice_mod_1002 [negative test] --all --attrs;negative;LIST --permissions;positive;LIST --raw"
        local testID="selfservice_mod_1002"
        local tmpout=$TmpDir/selfservice_mod_1002.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue_Negative="replace_me" #attrs;negative;LIST 
        local permissions_TestValue="replace_me" #permissions;positive;LIST 
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-mod $testID --all  --attrs=$attrs_TestValue_Negative  --permissions=$permissions_TestValue --raw " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue_Negative] [permissions]=[$permissions_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_mod_1002

selfservice_mod_1003()
{
    rlPhaseStartTest "selfservice_mod_1003 [negative test] --all --attrs;positive;LIST --permissions;negative;LIST --raw"
        local testID="selfservice_mod_1003"
        local tmpout=$TmpDir/selfservice_mod_1003.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="replace_me" #attrs;positive;LIST 
        local permissions_TestValue_Negative="replace_me" #permissions;negative;LIST 
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-mod $testID --all  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue_Negative --raw " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_mod_1003

selfservice_mod_1004()
{
    rlPhaseStartTest "selfservice_mod_1004 [positive test] --all --attrs;positive;LIST --permissions;positive;LIST --raw"
        local testID="selfservice_mod_1004"
        local tmpout=$TmpDir/selfservice_mod_1004.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="replace_me" #attrs;positive;LIST 
        local permissions_TestValue="replace_me" #permissions;positive;LIST 
        rlRun "ipa selfservice-mod $testID --all  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue --raw " 0 "test options:  [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_mod_1004

selfservice_mod_1005()
{
    rlPhaseStartTest "selfservice_mod_1005 [negative test] --attrs;negative;LIST"
        local testID="selfservice_mod_1005"
        local tmpout=$TmpDir/selfservice_mod_1005.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue_Negative="replace_me" #attrs;negative;LIST
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-mod $testID  --attrs=$attrs_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_mod_1005

selfservice_mod_1006()
{
    rlPhaseStartTest "selfservice_mod_1006 [positive test] --attrs;positive;LIST"
        local testID="selfservice_mod_1006"
        local tmpout=$TmpDir/selfservice_mod_1006.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="replace_me" #attrs;positive;LIST
        rlRun "ipa selfservice-mod $testID  --attrs=$attrs_TestValue " 0 "test options:  [attrs]=[$attrs_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_mod_1006

selfservice_mod_1007()
{
    rlPhaseStartTest "selfservice_mod_1007 [negative test] --permissions;negative;LIST"
        local testID="selfservice_mod_1007"
        local tmpout=$TmpDir/selfservice_mod_1007.$RANDOM.out
        KinitAsAdmin
        local permissions_TestValue_Negative="replace_me" #permissions;negative;LIST
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa selfservice-mod $testID  --permissions=$permissions_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [permissions]=[$permissions_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_mod_1007

selfservice_mod_1008()
{
    rlPhaseStartTest "selfservice_mod_1008 [positive test] --permissions;positive;LIST"
        local testID="selfservice_mod_1008"
        local tmpout=$TmpDir/selfservice_mod_1008.$RANDOM.out
        KinitAsAdmin
        local permissions_TestValue="replace_me" #permissions;positive;LIST
        rlRun "ipa selfservice-mod $testID  --permissions=$permissions_TestValue " 0 "test options:  [permissions]=[$permissions_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_mod_1008

selfservice_mod_1009()
{
    rlPhaseStartTest "selfservice_mod_1009 [positive test] --raw"
        local testID="selfservice_mod_1009"
        local tmpout=$TmpDir/selfservice_mod_1009.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa selfservice-mod $testID --raw " 0 "test options: " 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_mod_1009

#END OF TEST CASE for [selfservice-mod]

#############################################
#  test suite: selfservice-show (3 test cases)
#############################################
selfservice_show()
{
    selfservice_show_envsetup
    selfservice_show_1001  #test_scenario (positive test): [--all]
    selfservice_show_1002  #test_scenario (positive test): [--all --raw]
    selfservice_show_1003  #test_scenario (positive test): [--raw]
    selfservice_show_envcleanup
} #selfservice-show

selfservice_show_envsetup()
{
    rlPhaseStartSetup "selfservice_show_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

selfservice_show_envcleanup()
{
    rlPhaseStartCleanup "selfservice_show_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

selfservice_show_1001()
{
    rlPhaseStartTest "selfservice_show_1001 [positive test] --all"
        local testID="selfservice_show_1001"
        local tmpout=$TmpDir/selfservice_show_1001.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa selfservice-show $testID --all " 0 "test options: " 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_show_1001

selfservice_show_1002()
{
    rlPhaseStartTest "selfservice_show_1002 [positive test] --all --raw"
        local testID="selfservice_show_1002"
        local tmpout=$TmpDir/selfservice_show_1002.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa selfservice-show $testID --all --raw " 0 "test options: " 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_show_1002

selfservice_show_1003()
{
    rlPhaseStartTest "selfservice_show_1003 [positive test] --raw"
        local testID="selfservice_show_1003"
        local tmpout=$TmpDir/selfservice_show_1003.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa selfservice-show $testID --raw " 0 "test options: " 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #selfservice_show_1003

#END OF TEST CASE for [selfservice-show]
