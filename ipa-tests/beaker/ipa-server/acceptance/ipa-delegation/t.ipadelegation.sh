# delegation has 3 sets of clis: permission, privilege and role
#   therefore, 3 test case file have to be included

delegation() {
    permission
    privilege
    role
}

permission()
{
    permission_add
    permission_del
    permission_find
    permission_mod
    permission_show
} #permission

#############################################
#  test suite: permission-add (68 test cases)
#############################################
permission_add()
{
    permission_add_envsetup
#    permission_add_1001  #test_scenario (negative test): [--addattr;negative;STR]
#    permission_add_1002  #test_scenario (positive test): [--addattr;positive;STR]
    permission_add_1003  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;negative;nonListValue --memberof;positive;STR --permissions;positive;read, write, add, delete, all --filter;positive;STR]
    permission_add_1004  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;negative;nonListValue --memberof;positive;STR --permissions;positive;read, write, add, delete, all --subtree;positive;STR]
    permission_add_1005  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;negative;nonListValue --memberof;positive;STR --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR]
    permission_add_1006  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;negative;nonListValue --memberof;positive;STR --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_add_1007  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;negative;nonListValue --permissions;positive;read, write, add, delete, all --filter;positive;STR]
    permission_add_1008  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;negative;nonListValue --permissions;positive;read, write, add, delete, all --subtree;positive;STR]
    permission_add_1009  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;negative;nonListValue --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR]
    permission_add_1010  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;negative;nonListValue --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_add_1011  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;negative;STR --permissions;positive;read, write, add, delete, all --filter;positive;STR]
    permission_add_1012  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;negative;STR --permissions;positive;read, write, add, delete, all --subtree;positive;STR]
    permission_add_1013  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;negative;STR --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR]
    permission_add_1014  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;negative;STR --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_add_1015  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;negative;nonListValue --filter;positive;STR]
    permission_add_1016  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;negative;nonListValue --subtree;positive;STR]
    permission_add_1017  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;negative;nonListValue --targetgroup;positive;STR]
    permission_add_1018  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;negative;nonListValue --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_add_1019  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --filter;negative;STR]
    permission_add_1020  #test_scenario (positive test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --filter;positive;STR]
    permission_add_1021  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --subtree;negative;STR]
    permission_add_1022  #test_scenario (positive test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --subtree;positive;STR]
    permission_add_1023  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --targetgroup;negative;STR]
    permission_add_1024  #test_scenario (positive test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR]
    permission_add_1025  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --type;negative;nonSTRENUMValue]
    permission_add_1026  #test_scenario (positive test): [--desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_add_1027  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;negative;nonListValue --filter;positive;STR]
    permission_add_1028  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;negative;nonListValue --subtree;positive;STR]
    permission_add_1029  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;negative;nonListValue --targetgroup;positive;STR]
    permission_add_1030  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;negative;nonListValue --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_add_1031  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --filter;negative;STR]
    permission_add_1032  #test_scenario (positive test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --filter;positive;STR]
    permission_add_1033  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --subtree;negative;STR]
    permission_add_1034  #test_scenario (positive test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --subtree;positive;STR]
    permission_add_1035  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --targetgroup;negative;STR]
    permission_add_1036  #test_scenario (positive test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR]
    permission_add_1037  #test_scenario (negative test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --type;negative;nonSTRENUMValue]
    permission_add_1038  #test_scenario (positive test): [--desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_add_1039  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;negative;STR --permissions;positive;read, write, add, delete, all --filter;positive;STR]
    permission_add_1040  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;negative;STR --permissions;positive;read, write, add, delete, all --subtree;positive;STR]
    permission_add_1041  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;negative;STR --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR]
    permission_add_1042  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;negative;STR --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_add_1043  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;negative;nonListValue --filter;positive;STR]
    permission_add_1044  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;negative;nonListValue --subtree;positive;STR]
    permission_add_1045  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;negative;nonListValue --targetgroup;positive;STR]
    permission_add_1046  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;negative;nonListValue --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_add_1047  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --filter;negative;STR]
    permission_add_1048  #test_scenario (positive test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --filter;positive;STR]
    permission_add_1049  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --subtree;negative;STR]
    permission_add_1050  #test_scenario (positive test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --subtree;positive;STR]
    permission_add_1051  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --targetgroup;negative;STR]
    permission_add_1052  #test_scenario (positive test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR]
    permission_add_1053  #test_scenario (negative test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --type;negative;nonSTRENUMValue]
    permission_add_1054  #test_scenario (positive test): [--desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_add_1055  #test_scenario (negative test): [--desc;positive;auto generated description data --permissions;negative;nonListValue --filter;positive;STR]
    permission_add_1056  #test_scenario (negative test): [--desc;positive;auto generated description data --permissions;negative;nonListValue --subtree;positive;STR]
    permission_add_1057  #test_scenario (negative test): [--desc;positive;auto generated description data --permissions;negative;nonListValue --targetgroup;positive;STR]
    permission_add_1058  #test_scenario (negative test): [--desc;positive;auto generated description data --permissions;negative;nonListValue --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_add_1059  #test_scenario (negative test): [--desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --filter;negative;STR]
    permission_add_1060  #test_scenario (positive test): [--desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --filter;positive;STR]
    permission_add_1061  #test_scenario (negative test): [--desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --subtree;negative;STR]
    permission_add_1062  #test_scenario (positive test): [--desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --subtree;positive;STR]
    permission_add_1063  #test_scenario (negative test): [--desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --targetgroup;negative;STR]
    permission_add_1064  #test_scenario (positive test): [--desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR]
    permission_add_1065  #test_scenario (negative test): [--desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --type;negative;nonSTRENUMValue]
    permission_add_1066  #test_scenario (positive test): [--desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns]
#    permission_add_1067  #test_scenario (negative test): [--setattr;negative;STR]
#    permission_add_1068  #test_scenario (positive test): [--setattr;positive;STR]
    permission_add_envcleanup
} #permission-add

permission_add_envsetup()
{
    rlPhaseStartSetup "permission_add_envsetup"
        #environment setup starts here
        createPermissionTestGroup $testGroup "test for permission"
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

permission_add_envcleanup()
{
    rlPhaseStartCleanup "permission_add_envcleanup"
        #environment cleanup starts here
        deletePermissionTestGroup $testGroup
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

permission_add_1001()
{ #test_scenario (negative): --addattr;negative;STR
    rlPhaseStartTest "permission_add_1001"
        local testID="permission_add_1001"
        local tmpout=$TmpDir/permission_add_1001.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue_Negative="replace_me" #addattr;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-add $testID  --addattr=$addattr_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [addattr]=[$addattr_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1001

permission_add_1002()
{ #test_scenario (positive): --addattr;positive;STR
    rlPhaseStartTest "permission_add_1002"
        local testID="permission_add_1002"
        local tmpout=$TmpDir/permission_add_1002.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue="replace_me" #addattr;positive;STR
        rlRun "ipa permission-add $testID  --addattr=$addattr_TestValue " 0 "test options:  [addattr]=[$addattr_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1002

permission_add_1003()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;negative;nonListValue --memberof;positive;STR --permissions;positive;read, write, add, delete, all --filter;positive;STR
    rlPhaseStartTest "permission_add_1003"
        local testID="permission_add_1003"
        local tmpout=$TmpDir/permission_add_1003.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local expectedErrMsg="ipa: ERROR: targetattr \"$attrs_TestValue_Negative\" does not exist in schema"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue_Negative  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --filter=$filter_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue_Negative] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue]" debug
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1003

permission_add_1004()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;negative;nonListValue --memberof;positive;STR --permissions;positive;read, write, add, delete, all --subtree;positive;STR
    rlPhaseStartTest "permission_add_1004"
        local testID="permission_add_1004"
        local tmpout=$TmpDir/permission_add_1004.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local expectedErrMsg="ipa: ERROR: targetattr \"$attrs_TestValue_Negative\" does not exist in schema"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue_Negative  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue_Negative] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1004

permission_add_1005()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;negative;nonListValue --memberof;positive;STR --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1005"
        local testID="permission_add_1005"
        local tmpout=$TmpDir/permission_add_1005.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local expectedErrMsg="ipa: ERROR: targetattr \"$attrs_TestValue_Negative\" does not exist in schema"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue_Negative  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue_Negative] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1005

permission_add_1006()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;negative;nonListValue --memberof;positive;STR --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1006"
        local testID="permission_add_1006"
        local tmpout=$TmpDir/permission_add_1006.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="write" #permissions;positive;read, write, add, delete, all
        local type_TestValue="dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg="ipa: ERROR: targetattr \"$attrs_TestValue_Negative\" does not exist in schema"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue_Negative  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue_Negative] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1006

permission_add_1007()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;negative;nonListValue --permissions;positive;read, write, add, delete, all --filter;positive;STR
    rlPhaseStartTest "permission_add_1007"
        local testID="permission_add_1007"
        local tmpout=$TmpDir/permission_add_1007.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local permissions_TestValue="add" #permissions;positive;read, write, add, delete, all
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local expectedErrMsg="ipa: ERROR: targetattr \"$attrs_TestValue_Negative\" does not exist in schema"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue_Negative  --permissions=$permissions_TestValue  --filter=$filter_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue_Negative] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1007

permission_add_1008()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;negative;nonListValue --permissions;positive;read, write, add, delete, all --subtree;positive;STR
    rlPhaseStartTest "permission_add_1008"
        local testID="permission_add_1008"
        local tmpout=$TmpDir/permission_add_1008.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local permissions_TestValue="delete" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local expectedErrMsg="ipa: ERROR: targetattr \"$attrs_TestValue_Negative\" does not exist in schema"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue_Negative  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue_Negative] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1008

permission_add_1009()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;negative;nonListValue --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1009"
        local testID="permission_add_1009"
        local tmpout=$TmpDir/permission_add_1009.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local expectedErrMsg="ipa: ERROR: targetattr \"$attrs_TestValue_Negative\" does not exist in schema"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue_Negative  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue_Negative] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue]" debug
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1009

permission_add_1010()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;negative;nonListValue --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1010"
        local testID="permission_add_1010"
        local tmpout=$TmpDir/permission_add_1010.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local permissions_TestValue="delete" #permissions;positive;read, write, add, delete, all
        local type_TestValue="user" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg="ipa: ERROR: targetattr \"$attrs_TestValue_Negative\" does not exist in schema"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue_Negative  --permissions=$permissions_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue_Negative] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue]" debug
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1010

permission_add_1011()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;negative;STR --permissions;positive;read, write, add, delete, all --filter;positive;STR
    rlPhaseStartTest "permission_add_1011"
        local testID="permission_add_1011"
        local tmpout=$TmpDir/permission_add_1011.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local memberof_TestValue_Negative="noSuchGroup" #memberof;negative;STR
        local permissions_TestValue="read" #permissions;positive;read, write, add, delete, all
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local expectedErrMsg="ipa: ERROR: $memberof_TestValue_Negative: group not found"
        local errCode=2
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue_Negative  --permissions=$permissions_TestValue  --filter=$filter_TestValue " "$tmpout" $errCode "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue_Negative] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue]" debug
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1011

permission_add_1012()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;negative;STR --permissions;positive;read, write, add, delete, all --subtree;positive;STR
    rlPhaseStartTest "permission_add_1012"
        local testID="permission_add_1012"
        local tmpout=$TmpDir/permission_add_1012.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local memberof_TestValue_Negative="noSuchGroup" #memberof;negative;STR
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local expectedErrMsg="ipa: ERROR: $memberof_TestValue_Negative: group not found"
        local errCode=2
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue_Negative  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue " "$tmpout" $errCode "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue_Negative] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1012

permission_add_1013()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;negative;STR --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1013"
        local testID="permission_add_1013"
        local tmpout=$TmpDir/permission_add_1013.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber" #attrs;positive;LIST
        local memberof_TestValue_Negative="noSuchGroup" #memberof;negative;STR
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local expectedErrMsg="ipa: ERROR: $memberof_TestValue_Negative: group not found"
        local errCode=2
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue_Negative  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue " "$tmpout" $errCode "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue_Negative] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1013

permission_add_1014()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;negative;STR --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1014"
        local testID="permission_add_1014"
        local tmpout=$TmpDir/permission_add_1014.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local memberof_TestValue_Negative="NotExist" #memberof;negative;STR
        local permissions_TestValue="write" #permissions;positive;read, write, add, delete, all
        local type_TestValue="host" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg="ipa: ERROR: $memberof_TestValue_Negative: group not found"
        local errCode=2
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue_Negative  --permissions=$permissions_TestValue  --type=$type_TestValue " "$tmpout" $errCode "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue_Negative] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1014

permission_add_1015()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;negative;nonListValue --filter;positive;STR
    rlPhaseStartTest "permission_add_1015"
        local testID="permission_add_1015"
        local tmpout=$TmpDir/permission_add_1015.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local expectedErrMsg="ipa: ERROR: invalid 'permissions': \"$permissions_TestValue_Negative\" is not a valid permission"
        local errCode=1
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue_Negative  --filter=$filter_TestValue " "$tmpout" $errCode "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue_Negative] [filter]=[$filter_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1015

permission_add_1016()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;negative;nonListValue --subtree;positive;STR
    rlPhaseStartTest "permission_add_1016"
        local testID="permission_add_1016"
        local tmpout=$TmpDir/permission_add_1016.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local expectedErrMsg="ipa: ERROR: invalid 'permissions': \"$permissions_TestValue_Negative\" is not a valid permission"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue_Negative  --subtree=$subtree_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue_Negative] [subtree]=[$subtree_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1016

permission_add_1017()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;negative;nonListValue --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1017"
        local testID="permission_add_1017"
        local tmpout=$TmpDir/permission_add_1017.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local expectedErrMsg="ipa: ERROR: invalid 'permissions': \"$permissions_TestValue_Negative\" is not a valid permission"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue_Negative  --targetgroup=$targetgroup_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue_Negative] [targetgroup]=[$targetgroup_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1017

permission_add_1018()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;negative;nonListValue --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1018"
        local testID="permission_add_1018"
        local tmpout=$TmpDir/permission_add_1018.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local type_TestValue="host" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg="ipa: ERROR: invalid 'permissions': \"$permissions_TestValue_Negative\" is not a valid permission"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue_Negative  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue_Negative] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1018

permission_add_1019()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --filter;negative;STR
    rlPhaseStartTest "permission_add_1019"
        local testID="permission_add_1019"
        local tmpout=$TmpDir/permission_add_1019.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read" #permissions;positive;read, write, add, delete, all
        local filter_TestValue_Negative="" #filter;negative;STR
        local expectedErrMsg=replace_me # empty filter parameter cause ipa server through "internal error" -yizhang 1-18-2011
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --filter=$filter_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1019

permission_add_1020()
{ #test_scenario (positive): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --filter;positive;STR
    rlPhaseStartTest "permission_add_1020"
        local testID="permission_add_1020"
        local tmpout=$TmpDir/permission_add_1020.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="write" #permissions;positive;read, write, add, delete, all
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --filter=$filter_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1020

permission_add_1021()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --subtree;negative;STR
    rlPhaseStartTest "permission_add_1021"
        local testID="permission_add_1021"
        local tmpout=$TmpDir/permission_add_1021.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="write,add,delete" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue_Negative="" #subtree;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1021

permission_add_1022()
{ #test_scenario (positive): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --subtree;positive;STR
    rlPhaseStartTest "permission_add_1022"
        local testID="permission_add_1022"
        local tmpout=$TmpDir/permission_add_1022.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read,write,add" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1022

permission_add_1023()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --targetgroup;negative;STR
    rlPhaseStartTest "permission_add_1023"
        local testID="permission_add_1023"
        local tmpout=$TmpDir/permission_add_1023.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read,write,add,delete,all" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue_Negative="NotExist" #targetgroup;negative;STR
        local expectedErrMsg="ipa: ERROR: $targetgroup_TestValue_Negative: group not found"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue_Negative " "$tmpout" 2 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1023

permission_add_1024()
{ #test_scenario (positive): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1024"
        local testID="permission_add_1024"
        local tmpout=$TmpDir/permission_add_1024.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read,write,add,delete,all" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1024

permission_add_1025()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --type;negative;nonSTRENUMValue
    rlPhaseStartTest "permission_add_1025"
        local testID="permission_add_1025"
        local tmpout=$TmpDir/permission_add_1025.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read,write,add,delete" #permissions;positive;read, write, add, delete, all
        local type_TestValue_Negative="nonSTRENUMValue" #type;negative;nonSTRENUMValue
        local expectedErrMsg="ipa: ERROR: invalid 'type'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --type=$type_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1025

permission_add_1026()
{ #test_scenario (positive): --desc;positive;auto generated description data --attrs;positive;LIST --memberof;positive;STR --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1026"
        local testID="permission_add_1026"
        local tmpout=$TmpDir/permission_add_1026.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="write,add,delete,all" #permissions;positive;read, write, add, delete, all
        local type_TestValue="group" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --type=$type_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1026

permission_add_1027()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;negative;nonListValue --filter;positive;STR
    rlPhaseStartTest "permission_add_1027"
        local testID="permission_add_1027"
        local tmpout=$TmpDir/permission_add_1027.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local expectedErrMsg="ipa: ERROR: invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue_Negative  --filter=$filter_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue_Negative] [filter]=[$filter_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1027

permission_add_1028()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;negative;nonListValue --subtree;positive;STR
    rlPhaseStartTest "permission_add_1028"
        local testID="permission_add_1028"
        local tmpout=$TmpDir/permission_add_1028.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber" #attrs;positive;LIST
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local expectedErrMsg="ipa: ERROR: invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue_Negative  --subtree=$subtree_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue_Negative] [subtree]=[$subtree_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1028

permission_add_1029()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;negative;nonListValue --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1029"
        local testID="permission_add_1029"
        local tmpout=$TmpDir/permission_add_1029.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local expectedErrMsg="ipa: ERROR: invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue_Negative  --targetgroup=$targetgroup_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue_Negative] [targetgroup]=[$targetgroup_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1029

permission_add_1030()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;negative;nonListValue --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1030"
        local testID="permission_add_1030"
        local tmpout=$TmpDir/permission_add_1030.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local type_TestValue="hostgroup" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg="ipa: ERROR: invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue_Negative  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue_Negative] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1030

permission_add_1031()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --filter;negative;STR
    rlPhaseStartTest "permission_add_1031"
        local testID="permission_add_1031"
        local tmpout=$TmpDir/permission_add_1031.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local permissions_TestValue="read,write,add,all" #permissions;positive;read, write, add, delete, all
        local filter_TestValue_Negative="" #filter;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue  --filter=$filter_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1031

permission_add_1032()
{ #test_scenario (positive): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --filter;positive;STR
    rlPhaseStartTest "permission_add_1032"
        local testID="permission_add_1032"
        local tmpout=$TmpDir/permission_add_1032.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local permissions_TestValue="delete,all" #permissions;positive;read, write, add, delete, all
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue  --filter=$filter_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1032

permission_add_1033()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --subtree;negative;STR
    rlPhaseStartTest "permission_add_1033"
        local testID="permission_add_1033"
        local tmpout=$TmpDir/permission_add_1033.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local permissions_TestValue="read,add,delete,all" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue_Negative="" #subtree;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1033

permission_add_1034()
{ #test_scenario (positive): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --subtree;positive;STR
    rlPhaseStartTest "permission_add_1034"
        local testID="permission_add_1034"
        local tmpout=$TmpDir/permission_add_1034.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local permissions_TestValue="read,write,add,delete,all" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1034

permission_add_1035()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --targetgroup;negative;STR
    rlPhaseStartTest "permission_add_1035"
        local testID="permission_add_1035"
        local tmpout=$TmpDir/permission_add_1035.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local permissions_TestValue="read,write,add,delete" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue_Negative="NotExist" #targetgroup;negative;STR
        local expectedErrMsg="ipa: ERROR: $targetgroup_TestValue_Negative: group not found"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue_Negative " "$tmpout" 2 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1035

permission_add_1036()
{ #test_scenario (positive): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1036"
        local testID="permission_add_1036"
        local tmpout=$TmpDir/permission_add_1036.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local permissions_TestValue="read,write,add,delete,all" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1036

permission_add_1037()
{ #test_scenario (negative): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --type;negative;nonSTRENUMValue
    rlPhaseStartTest "permission_add_1037"
        local testID="permission_add_1037"
        local tmpout=$TmpDir/permission_add_1037.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local type_TestValue_Negative="nonSTRENUMValue" #type;negative;nonSTRENUMValue
        local expectedErrMsg="ipa: ERROR: invalid 'type'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue  --type=$type_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1037

permission_add_1038()
{ #test_scenario (positive): --desc;positive;auto generated description data --attrs;positive;LIST --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1038"
        local testID="permission_add_1038"
        local tmpout=$TmpDir/permission_add_1038.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local permissions_TestValue="read,write" #permissions;positive;read, write, add, delete, all
        local type_TestValue="service" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --attrs=$attrs_TestValue  --permissions=$permissions_TestValue  --type=$type_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [attrs]=[$attrs_TestValue] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1038

permission_add_1039()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;negative;STR --permissions;positive;read, write, add, delete, all --filter;positive;STR
    rlPhaseStartTest "permission_add_1039"
        local testID="permission_add_1039"
        local tmpout=$TmpDir/permission_add_1039.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue_Negative="NotExist" #memberof;negative;STR
        local permissions_TestValue="read,write,add,delete,all" #permissions;positive;read, write, add, delete, all
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local expectedErrMsg="group not found"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue_Negative  --permissions=$permissions_TestValue  --filter=$filter_TestValue " "$tmpout" 2 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue_Negative] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1039

permission_add_1040()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;negative;STR --permissions;positive;read, write, add, delete, all --subtree;positive;STR
    rlPhaseStartTest "permission_add_1040"
        local testID="permission_add_1040"
        local tmpout=$TmpDir/permission_add_1040.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue_Negative="NotExist" #memberof;negative;STR
        local permissions_TestValue="read" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local expectedErrMsg="group not found"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue_Negative  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue " "$tmpout" 2 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue_Negative] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1040

permission_add_1041()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;negative;STR --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1041"
        local testID="permission_add_1041"
        local tmpout=$TmpDir/permission_add_1041.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue_Negative="NotExist" #memberof;negative;STR
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local expectedErrMsg="group not found"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue_Negative  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue " "$tmpout" 2 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue_Negative] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1041

permission_add_1042()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;negative;STR --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1042"
        local testID="permission_add_1042"
        local tmpout=$TmpDir/permission_add_1042.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue_Negative="NotExist" #memberof;negative;STR
        local permissions_TestValue="add,all" #permissions;positive;read, write, add, delete, all
        local type_TestValue="service" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg="group not found"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue_Negative  --permissions=$permissions_TestValue  --type=$type_TestValue " "$tmpout" 2 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue_Negative] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1042

permission_add_1043()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;positive;STR --permissions;negative;nonListValue --filter;positive;STR
    rlPhaseStartTest "permission_add_1043"
        local testID="permission_add_1043"
        local tmpout=$TmpDir/permission_add_1043.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local expectedErrMsg="ipa: ERROR: invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue_Negative  --filter=$filter_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue_Negative] [filter]=[$filter_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1043

permission_add_1044()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;positive;STR --permissions;negative;nonListValue --subtree;positive;STR
    rlPhaseStartTest "permission_add_1044"
        local testID="permission_add_1044"
        local tmpout=$TmpDir/permission_add_1044.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local expectedErrMsg="ipa: ERROR: invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue_Negative  --subtree=$subtree_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue_Negative] [subtree]=[$subtree_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1044

permission_add_1045()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;positive;STR --permissions;negative;nonListValue --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1045"
        local testID="permission_add_1045"
        local tmpout=$TmpDir/permission_add_1045.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local expectedErrMsg="ipa: ERROR: invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue_Negative  --targetgroup=$targetgroup_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue_Negative] [targetgroup]=[$targetgroup_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1045

permission_add_1046()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;positive;STR --permissions;negative;nonListValue --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1046"
        local testID="permission_add_1046"
        local tmpout=$TmpDir/permission_add_1046.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local type_TestValue="netgroup" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg="ipa: ERROR: invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue_Negative  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue_Negative] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1046

permission_add_1047()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --filter;negative;STR
    rlPhaseStartTest "permission_add_1047"
        local testID="permission_add_1047"
        local tmpout=$TmpDir/permission_add_1047.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read,write,delete,all" #permissions;positive;read, write, add, delete, all
        local filter_TestValue_Negative="" #filter;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --filter=$filter_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1047

permission_add_1048()
{ #test_scenario (positive): --desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --filter;positive;STR
    rlPhaseStartTest "permission_add_1048"
        local testID="permission_add_1048"
        local tmpout=$TmpDir/permission_add_1048.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read,all" #permissions;positive;read, write, add, delete, all
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --filter=$filter_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1048

permission_add_1049()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --subtree;negative;STR
    rlPhaseStartTest "permission_add_1049"
        local testID="permission_add_1049"
        local tmpout=$TmpDir/permission_add_1049.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read,write,add,delete" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue_Negative="" #subtree;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1049

permission_add_1050()
{ #test_scenario (positive): --desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --subtree;positive;STR
    rlPhaseStartTest "permission_add_1050"
        local testID="permission_add_1050"
        local tmpout=$TmpDir/permission_add_1050.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read,write,all" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1050

permission_add_1051()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --targetgroup;negative;STR
    rlPhaseStartTest "permission_add_1051"
        local testID="permission_add_1051"
        local tmpout=$TmpDir/permission_add_1051.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue_Negative="NotExist" #targetgroup;negative;STR
        local expectedErrMsg="ipa: ERROR: $targetgroup_TestValue_Negative: group not found"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue_Negative " "$tmpout" 2 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1051

permission_add_1052()
{ #test_scenario (positive): --desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1052"
        local testID="permission_add_1052"
        local tmpout=$TmpDir/permission_add_1052.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read,write" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1052

permission_add_1053()
{ #test_scenario (negative): --desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --type;negative;nonSTRENUMValue
    rlPhaseStartTest "permission_add_1053"
        local testID="permission_add_1053"
        local tmpout=$TmpDir/permission_add_1053.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="add,delete" #permissions;positive;read, write, add, delete, all
        local type_TestValue_Negative="nonSTRENUMValue" #type;negative;nonSTRENUMValue
        local expectedErrMsg="invalid 'type'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --type=$type_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1053

permission_add_1054()
{ #test_scenario (positive): --desc;positive;auto generated description data --memberof;positive;STR --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1054"
        local testID="permission_add_1054"
        local tmpout=$TmpDir/permission_add_1054.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read,write" #permissions;positive;read, write, add, delete, all
        local type_TestValue="dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue  --type=$type_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1054

permission_add_1055()
{ #test_scenario (negative): --desc;positive;auto generated description data --permissions;negative;nonListValue --filter;positive;STR
    rlPhaseStartTest "permission_add_1055"
        local testID="permission_add_1055"
        local tmpout=$TmpDir/permission_add_1055.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local expectedErrMsg="invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue_Negative  --filter=$filter_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue_Negative] [filter]=[$filter_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1055

permission_add_1056()
{ #test_scenario (negative): --desc;positive;auto generated description data --permissions;negative;nonListValue --subtree;positive;STR
    rlPhaseStartTest "permission_add_1056"
        local testID="permission_add_1056"
        local tmpout=$TmpDir/permission_add_1056.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local expectedErrMsg="invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue_Negative  --subtree=$subtree_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue_Negative] [subtree]=[$subtree_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1056

permission_add_1057()
{ #test_scenario (negative): --desc;positive;auto generated description data --permissions;negative;nonListValue --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1057"
        local testID="permission_add_1057"
        local tmpout=$TmpDir/permission_add_1057.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local expectedErrMsg="invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue_Negative  --targetgroup=$targetgroup_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue_Negative] [targetgroup]=[$targetgroup_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1057

permission_add_1058()
{ #test_scenario (negative): --desc;positive;auto generated description data --permissions;negative;nonListValue --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1058"
        local testID="permission_add_1058"
        local tmpout=$TmpDir/permission_add_1058.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local type_TestValue="hostgroup" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg="invalid 'permissions'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue_Negative  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue_Negative] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1058

permission_add_1059()
{ #test_scenario (negative): --desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --filter;negative;STR
    rlPhaseStartTest "permission_add_1059"
        local testID="permission_add_1059"
        local tmpout=$TmpDir/permission_add_1059.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local filter_TestValue_Negative="" #filter;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue  --filter=$filter_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1059

permission_add_1060()
{ #test_scenario (positive): --desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --filter;positive;STR
    rlPhaseStartTest "permission_add_1060"
        local testID="permission_add_1060"
        local tmpout=$TmpDir/permission_add_1060.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue="read,all" #permissions;positive;read, write, add, delete, all
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue  --filter=$filter_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue] [filter]=[$filter_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1060

permission_add_1061()
{ #test_scenario (negative): --desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --subtree;negative;STR
    rlPhaseStartTest "permission_add_1061"
        local testID="permission_add_1061"
        local tmpout=$TmpDir/permission_add_1061.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue="add,delete,all" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue_Negative="" #subtree;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1061

permission_add_1062()
{ #test_scenario (positive): --desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --subtree;positive;STR
    rlPhaseStartTest "permission_add_1062"
        local testID="permission_add_1062"
        local tmpout=$TmpDir/permission_add_1062.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue="read,write" #permissions;positive;read, write, add, delete, all
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue  --subtree=$subtree_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue] [subtree]=[$subtree_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1062

permission_add_1063()
{ #test_scenario (negative): --desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --targetgroup;negative;STR
    rlPhaseStartTest "permission_add_1063"
        local testID="permission_add_1063"
        local tmpout=$TmpDir/permission_add_1063.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue="write" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue_Negative="NotExist" #targetgroup;negative;STR
        local expectedErrMsg="group not found"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue_Negative " "$tmpout" 2 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1063

permission_add_1064()
{ #test_scenario (positive): --desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --targetgroup;positive;STR
    rlPhaseStartTest "permission_add_1064"
        local testID="permission_add_1064"
        local tmpout=$TmpDir/permission_add_1064.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue  --targetgroup=$targetgroup_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue] [targetgroup]=[$targetgroup_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1064

permission_add_1065()
{ #test_scenario (negative): --desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --type;negative;nonSTRENUMValue
    rlPhaseStartTest "permission_add_1065"
        local testID="permission_add_1065"
        local tmpout=$TmpDir/permission_add_1065.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue="read,write,all" #permissions;positive;read, write, add, delete, all
        local type_TestValue_Negative="nonSTRENUMValue" #type;negative;nonSTRENUMValue
        local expectedErrMsg="invalid 'type'"
        qaRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue  --type=$type_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1065

permission_add_1066()
{ #test_scenario (positive): --desc;positive;auto generated description data --permissions;positive;read, write, add, delete, all --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_add_1066"
        local testID="permission_add_1066"
        local tmpout=$TmpDir/permission_add_1066.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local permissions_TestValue="read,write" #permissions;positive;read, write, add, delete, all
        local type_TestValue="dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        rlRun "ipa permission-add $testID  --desc=$desc_TestValue  --permissions=$permissions_TestValue  --type=$type_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [permissions]=[$permissions_TestValue] [type]=[$type_TestValue]" 
        deletePermission $testID
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1066

permission_add_1067()
{ #test_scenario (negative): --setattr;negative;STR
    rlPhaseStartTest "permission_add_1067"
        local testID="permission_add_1067"
        local tmpout=$TmpDir/permission_add_1067.$RANDOM.out
        KinitAsAdmin
        local setattr_TestValue_Negative="STR" #setattr;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-add $testID  --setattr=$setattr_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [setattr]=[$setattr_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1067

permission_add_1068()
{ #test_scenario (positive): --setattr;positive;STR
    rlPhaseStartTest "permission_add_1068"
        local testID="permission_add_1068"
        local tmpout=$TmpDir/permission_add_1068.$RANDOM.out
        KinitAsAdmin
        local setattr_TestValue="STR" #setattr;positive;STR
        rlRun "ipa permission-add $testID  --setattr=$setattr_TestValue " 0 "test options:  [setattr]=[$setattr_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_add_1068

#END OF TEST CASE for [permission-add]

#############################################
#  test suite: permission-del (1 test cases)
#############################################
permission_del()
{
    permission_del_envsetup
    permission_del_1001  #test_scenario (positive test): [--continue]
    permission_del_envcleanup
} #permission-del

permission_del_envsetup()
{
    rlPhaseStartSetup "permission_del_envsetup"
        #environment setup starts here
        # create 3 permission to be deleted
        KinitAsAdmin
        for id in 1 2 3 4
        do
            permissionName="permission_del_$id"
            rlRun "ipa permission-add --desc \"permission $id to be delete\" \
                       --permissions=read,delete\
                       --type=user\
                       $permissionName"

        done
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

permission_del_envcleanup()
{
    rlPhaseStartCleanup "permission_del_envcleanup"
        #environment cleanup starts here
        KinitAsAdmin
        for id in 1 2 3 4
        do
            permissionName="permission_del_$id"
            ipa permission-del $permissionName
        done
        Kcleanup
        rlPass "all permission deleted" #no need to check permissions
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

permission_del_1001()
{ #test_scenario (positive): --continue
    rlPhaseStartTest "permission_del_1001"
        local testID="permission_del_1001"
        KinitAsAdmin
        # permission $testID does not exist
        rlRun "ipa permission-del $testID permission_del_1 --continue " 0 "test options: " 
        rlRun "ipa permission-del permission_del_2 $testID --continue " 0 "test options: " 
        rlRun "ipa permission-del permission_del_3 $testID permission_del_4 --continue " 0 "test options: " 
        Kcleanup
    rlPhaseEnd
} #permission_del_1001

#END OF TEST CASE for [permission-del]

#############################################
#  test suite: permission-find (36 test cases)
#############################################
permission_find()
{
    permission_find_envsetup
#    permission_find_1001  #test_scenario (positive test): [--all]
#    permission_find_1002  #test_scenario (negative test): [--all --attrs;negative;nonListValue --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns]
#    permission_find_1003  #test_scenario (negative test): [--all --attrs;positive;LIST --desc;positive;auto generated description data --filter;negative;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns]
#    permission_find_1004  #test_scenario (negative test): [--all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;negative;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns]
#    permission_find_1005  #test_scenario (negative test): [--all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;negative;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns]
#    permission_find_1006  #test_scenario (negative test): [--all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;negative;nonListValue --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns]
#    permission_find_1007  #test_scenario (negative test): [--all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;negative;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns]
#    permission_find_1008  #test_scenario (negative test): [--all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;negative;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns]
#    permission_find_1009  #test_scenario (negative test): [--all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;negative;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns]
#    permission_find_1010  #test_scenario (negative test): [--all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;negative;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns]
#    permission_find_1011  #test_scenario (negative test): [--all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;negative;nonSTRENUMValue]
#    permission_find_1012  #test_scenario (positive test): [--all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_find_1013  #test_scenario (negative test): [--attrs;negative;nonListValue]
    permission_find_1014  #test_scenario (positive test): [--attrs;positive;LIST]
    permission_find_1015  #test_scenario (positive test): [--desc;positive;auto generated description data]
    permission_find_1016  #test_scenario (negative test): [--filter;negative;STR]
    permission_find_1017  #test_scenario (positive test): [--filter;positive;STR]
    permission_find_1018  #test_scenario (negative test): [--memberof;negative;STR]
    permission_find_1019  #test_scenario (positive test): [--memberof;positive;STR]
    permission_find_1020  #test_scenario (negative test): [--name;negative;STR]
    permission_find_1021  #test_scenario (positive test): [--name;positive;STR]
    permission_find_1022  #test_scenario (negative test): [--permissions;negative;nonListValue]
    permission_find_1023  #test_scenario (positive test): [--permissions;positive;read, write, add, delete, all]
    permission_find_1024  #test_scenario (positive test): [--raw]
    permission_find_1025  #test_scenario (boundary test): [--sizelimit;boundary;INT]
    permission_find_1026  #test_scenario (negative test): [--sizelimit;negative;INT]
    permission_find_1027  #test_scenario (positive test): [--sizelimit;positive;INT]
    permission_find_1028  #test_scenario (negative test): [--subtree;negative;STR]
    permission_find_1029  #test_scenario (positive test): [--subtree;positive;STR]
    permission_find_1030  #test_scenario (negative test): [--targetgroup;negative;STR]
    permission_find_1031  #test_scenario (positive test): [--targetgroup;positive;STR]
    permission_find_1032  #test_scenario (boundary test): [--timelimit;boundary;INT]
    permission_find_1033  #test_scenario (negative test): [--timelimit;negative;INT]
    permission_find_1034  #test_scenario (positive test): [--timelimit;positive;INT]
    permission_find_1035  #test_scenario (negative test): [--type;negative;nonSTRENUMValue]
    permission_find_1036  #test_scenario (positive test): [--type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_find_envcleanup
} #permission-find

permission_find_envsetup()
{
    rlPhaseStartSetup "permission_find_envsetup"
        #environment setup starts here
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

permission_find_envcleanup()
{
    rlPhaseStartCleanup "permission_find_envcleanup"
        #environment cleanup starts here
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

permission_find_1001()
{ #test_scenario (positive): --all
    rlPhaseStartTest "permission_find_1001"
        local testID="permission_find_1001"
        local tmpout=$TmpDir/permission_find_1001.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-find $testID --all " 0 "test options: " 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1001

permission_find_1002()
{ #test_scenario (negative): --all --attrs;negative;nonListValue --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_find_1002"
        local testID="permission_find_1002"
        local tmpout=$TmpDir/permission_find_1002.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local name_TestValue="$testID" #name;positive;STR
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local timelimit_TestValue="2" #timelimit;positive;INT
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID --all  --attrs=$attrs_TestValue_Negative  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --name=$name_TestValue  --permissions=$permissions_TestValue --raw  --sizelimit=$sizelimit_TestValue  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --timelimit=$timelimit_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue_Negative] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue] [sizelimit]=[$sizelimit_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [timelimit]=[$timelimit_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1002

permission_find_1003()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;negative;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_find_1003"
        local testID="permission_find_1003"
        local tmpout=$TmpDir/permission_find_1003.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue_Negative="" #filter;negative;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local name_TestValue="$testID" #name;positive;STR
        local permissions_TestValue="add,delete,all" #permissions;positive;read, write, add, delete, all
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local timelimit_TestValue="2" #timelimit;positive;INT
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue_Negative  --memberof=$memberof_TestValue  --name=$name_TestValue  --permissions=$permissions_TestValue --raw  --sizelimit=$sizelimit_TestValue  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --timelimit=$timelimit_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue_Negative] [memberof]=[$memberof_TestValue] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue] [sizelimit]=[$sizelimit_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [timelimit]=[$timelimit_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1003

permission_find_1004()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;negative;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_find_1004"
        local testID="permission_find_1004"
        local tmpout=$TmpDir/permission_find_1004.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="uidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue_Negative="NotExist" #memberof;negative;STR
        local name_TestValue="$testID" #name;positive;STR
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local timelimit_TestValue="2" #timelimit;positive;INT
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue_Negative  --name=$name_TestValue  --permissions=$permissions_TestValue --raw  --sizelimit=$sizelimit_TestValue  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --timelimit=$timelimit_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue_Negative] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue] [sizelimit]=[$sizelimit_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [timelimit]=[$timelimit_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1004

permission_find_1005()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;negative;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_find_1005"
        local testID="permission_find_1005"
        local tmpout=$TmpDir/permission_find_1005.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="uidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local name_TestValue_Negative="NotExist" #name;negative;STR
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local timelimit_TestValue="2" #timelimit;positive;INT
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --name=$name_TestValue_Negative  --permissions=$permissions_TestValue --raw  --sizelimit=$sizelimit_TestValue  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --timelimit=$timelimit_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [name]=[$name_TestValue_Negative] [permissions]=[$permissions_TestValue] [sizelimit]=[$sizelimit_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [timelimit]=[$timelimit_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1005

permission_find_1006()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;negative;nonListValue --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_find_1006"
        local testID="permission_find_1006"
        local tmpout=$TmpDir/permission_find_1006.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local name_TestValue="$testID" #name;positive;STR
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local timelimit_TestValue="2" #timelimit;positive;INT
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --name=$name_TestValue  --permissions=$permissions_TestValue_Negative --raw  --sizelimit=$sizelimit_TestValue  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --timelimit=$timelimit_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue_Negative] [sizelimit]=[$sizelimit_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [timelimit]=[$timelimit_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1006

permission_find_1007()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;negative;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_find_1007"
        local testID="permission_find_1007"
        local tmpout=$TmpDir/permission_find_1007.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local name_TestValue="$testID" #name;positive;STR
        local permissions_TestValue="read,write" #permissions;positive;read, write, add, delete, all
        local sizelimit_TestValue_Negative="-2 a abc" #sizelimit;negative;INT
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local timelimit_TestValue="2" #timelimit;positive;INT
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --name=$name_TestValue  --permissions=$permissions_TestValue --raw  --sizelimit=$sizelimit_TestValue_Negative  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --timelimit=$timelimit_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue] [sizelimit]=[$sizelimit_TestValue_Negative] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [timelimit]=[$timelimit_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1007

permission_find_1008()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;negative;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_find_1008"
        local testID="permission_find_1008"
        local tmpout=$TmpDir/permission_find_1008.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local name_TestValue="$testID" #name;positive;STR
        local permissions_TestValue="read,write" #permissions;positive;read, write, add, delete, all
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local subtree_TestValue_Negative="" #subtree;negative;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local timelimit_TestValue="2" #timelimit;positive;INT
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --name=$name_TestValue  --permissions=$permissions_TestValue --raw  --sizelimit=$sizelimit_TestValue  --subtree=$subtree_TestValue_Negative  --targetgroup=$targetgroup_TestValue  --timelimit=$timelimit_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue] [sizelimit]=[$sizelimit_TestValue] [subtree]=[$subtree_TestValue_Negative] [targetgroup]=[$targetgroup_TestValue] [timelimit]=[$timelimit_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1008

permission_find_1009()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;negative;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_find_1009"
        local testID="permission_find_1009"
        local tmpout=$TmpDir/permission_find_1009.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local name_TestValue="$testID" #name;positive;STR
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue_Negative="NotExist" #targetgroup;negative;STR
        local timelimit_TestValue="2" #timelimit;positive;INT
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --name=$name_TestValue  --permissions=$permissions_TestValue --raw  --sizelimit=$sizelimit_TestValue  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue_Negative  --timelimit=$timelimit_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue] [sizelimit]=[$sizelimit_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue_Negative] [timelimit]=[$timelimit_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1009

permission_find_1010()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;negative;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_find_1010"
        local testID="permission_find_1010"
        local tmpout=$TmpDir/permission_find_1010.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local name_TestValue="$testID" #name;positive;STR
        local permissions_TestValue="delete" #permissions;positive;read, write, add, delete, all
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local timelimit_TestValue_Negative="-2 a abc" #timelimit;negative;INT
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --name=$name_TestValue  --permissions=$permissions_TestValue --raw  --sizelimit=$sizelimit_TestValue  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --timelimit=$timelimit_TestValue_Negative  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue] [sizelimit]=[$sizelimit_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [timelimit]=[$timelimit_TestValue_Negative] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1010

permission_find_1011()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;negative;nonSTRENUMValue
    rlPhaseStartTest "permission_find_1011"
        local testID="permission_find_1011"
        local tmpout=$TmpDir/permission_find_1011.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local name_TestValue="$testID" #name;positive;STR
        local permissions_TestValue="delete,all" #permissions;positive;read, write, add, delete, all
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local timelimit_TestValue="2" #timelimit;positive;INT
        local type_TestValue_Negative="nonSTRENUMValue" #type;negative;nonSTRENUMValue
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --name=$name_TestValue  --permissions=$permissions_TestValue --raw  --sizelimit=$sizelimit_TestValue  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --timelimit=$timelimit_TestValue  --type=$type_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue] [sizelimit]=[$sizelimit_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [timelimit]=[$timelimit_TestValue] [type]=[$type_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1011

permission_find_1012()
{ #test_scenario (positive): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --name;positive;STR --permissions;positive;read, write, add, delete, all --raw --sizelimit;positive;INT --subtree;positive;STR --targetgroup;positive;STR --timelimit;positive;INT --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_find_1012"
        local testID="permission_find_1012"
        local tmpout=$TmpDir/permission_find_1012.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="uidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local name_TestValue="$testID" #name;positive;STR
        local permissions_TestValue="add" #permissions;positive;read, write, add, delete, all
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local timelimit_TestValue="2" #timelimit;positive;INT
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        rlRun "ipa permission-find $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --name=$name_TestValue  --permissions=$permissions_TestValue --raw  --sizelimit=$sizelimit_TestValue  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --timelimit=$timelimit_TestValue  --type=$type_TestValue " 0 "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [name]=[$name_TestValue] [permissions]=[$permissions_TestValue] [sizelimit]=[$sizelimit_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [timelimit]=[$timelimit_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1012

permission_find_1013()
{ #test_scenario (negative): --attrs;negative;nonListValue
    rlPhaseStartTest "permission_find_1013"
        local testID="permission_find_1013"
        local tmpout=$TmpDir/permission_find_1013.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --attrs=uidnumber --permission=read --type=user" 
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local expectedErrMsg="0 permissions matched"
        qaRun "ipa permission-find --attrs=$attrs_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1013

permission_find_1014()
{ #test_scenario (positive): --attrs;positive;LIST
    rlPhaseStartTest "permission_find_1014"
        local testID="permission_find_1014"
        local tmpout=$TmpDir/permission_find_1014.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        rlRun "ipa permission-add $testID --desc=4_$testID --attrs=$attrs_TestValue --permission=all --type=user"
        qaRun "ipa permission-find --attrs=$attrs_TestValue " 0 "$testID" "test options:  [attrs]=[$attrs_TestValue]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1014

permission_find_1015()
{ #test_scenario (positive): --desc;positive;auto generated description data
    rlPhaseStartTest "permission_find_1015"
        local testID="permission_find_1015"
        local tmpout=$TmpDir/permission_find_1015.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        rlRun "ipa permission-add $testID --desc=$desc_TestValue  --permission=all --type=group"
        qaRun "ipa permission-find --desc=$desc_TestValue " 0 "$testID" "test options:  [desc]=[$desc_TestValue]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1015

permission_find_1016()
{ #test_scenario (negative): --filter;negative;STR
    rlPhaseStartTest "permission_find_1016"
        local testID="permission_find_1016"
        local tmpout=$TmpDir/permission_find_1016.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=$desc_TestValue  --permission=all --filter=whatever"
        local filter_TestValue_Negative="" #filter;negative;STR
        local expectedErrMsg="0 permissions matched"
        qaRun "ipa permission-find --filter=$filter_TestValue_Negative " "$tmpout" 0 "$expectedErrMsg" "test options:  [filter]=[$filter_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1016

permission_find_1017()
{ #test_scenario (positive): --filter;positive;STR
    rlPhaseStartTest "permission_find_1017"
        local testID="permission_find_1017"
        local tmpout=$TmpDir/permission_find_1017.$RANDOM.out
        KinitAsAdmin
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=add,delete --filter=$filter_TestValue"
        qaRun "ipa permission-find --filter=$filter_TestValue " 0 "$testID" "test options:  [filter]=[$filter_TestValue]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1017

permission_find_1018()
{ #test_scenario (negative): --memberof;negative;STR
    rlPhaseStartTest "permission_find_1018"
        local testID="permission_find_1018"
        local tmpout=$TmpDir/permission_find_1018.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=add,delete --memberof=ipausers --type=user"
        local memberof_TestValue_Negative="NotExist" #memberof;negative;STR
        local expectedErrMsg="0 permissions matched"
        qaRun "ipa permission-find --memberof=$memberof_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [memberof]=[$memberof_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1018

permission_find_1019()
{ #test_scenario (positive): --memberof;positive;STR
    rlPhaseStartTest "permission_find_1019"
        local testID="permission_find_1019"
        local tmpout=$TmpDir/permission_find_1019.$RANDOM.out
        KinitAsAdmin
        createPermissionTestGroup $testGroup "for test: $testID"
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=add,delete --memberof=$memberof_TestValue --type=user"
        rlRun "ipa permission-find --memberof=$memberof_TestValue " 0 "test options:  [memberof]=[$memberof_TestValue]" 
        rlRun "ipa permission-del $testID"
        deletePermissionTestGroup $testGroup
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1019

permission_find_1020()
{ #test_scenario (negative): --name;negative;STR
    rlPhaseStartTest "permission_find_1020"
        local testID="permission_find_1020"
        local tmpout=$TmpDir/permission_find_1020.$RANDOM.out
        KinitAsAdmin
        createPermissionTestGroup $testGroup "for test: $testID"
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=write --type=user"
        local name_TestValue_Negative="NotExist" #name;negative;STR
        local expectedErrMsg="0 permissions matched"
        qaRun "ipa permission-find --name=$name_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [name]=[$name_TestValue_Negative]" 
        deletePermissionTestGroup $testGroup
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1020

permission_find_1021()
{ #test_scenario (positive): --name;positive;STR
    rlPhaseStartTest "permission_find_1021"
        local testID="permission_find_1021"
        local tmpout=$TmpDir/permission_find_1021.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=write --type=user"
        local name_TestValue="$testID" #name;positive;STR
        rlRun "ipa permission-find --name=$name_TestValue " 0 "test options:  [name]=[$name_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1021

permission_find_1022()
{ #test_scenario (negative): --permissions;negative;nonListValue
    rlPhaseStartTest "permission_find_1022"
        local testID="permission_find_1022"
        local tmpout=$TmpDir/permission_find_1022.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=write --type=user"
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local expectedErrMsg="0 permissions matched"
        qaRun "ipa permission-find --permissions=$permissions_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [permissions]=[$permissions_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1022

permission_find_1023()
{ #test_scenario (positive): --permissions;positive;read, write, add, delete, all
    rlPhaseStartTest "permission_find_1023"
        local testID="permission_find_1023"
        local tmpout=$TmpDir/permission_find_1023.$RANDOM.out
        KinitAsAdmin
        local permissions_TestValue="write" #permissions;positive;read, write, add, delete, all
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=$permissions_TestValue --type=user"
        rlRun "ipa permission-find --permissions=$permissions_TestValue " 0 "test options:  [permissions]=[$permissions_TestValue]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1023

permission_find_1024()
{ #test_scenario (positive): --raw
    rlPhaseStartTest "permission_find_1024"
        local testID="permission_find_1024"
        local tmpout=$TmpDir/permission_find_1024.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=all --type=user"
        rlRun "ipa permission-find $testID --raw " 0 "test options: " 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1024

permission_find_1025()
{ #test_scenario (boundary): --sizelimit;boundary;INT
    rlPhaseStartTest "permission_find_1025"
        local testID="permission_find_1025"
        local tmpout=$TmpDir/permission_find_1025.$RANDOM.out
        KinitAsAdmin
        local sizelimit_TestValue="0" #sizelimit;boundary;INT
        rlRun "ipa permission-find $testID  --sizelimit=$sizelimit_TestValue " 0 "test options:  [sizelimit]=[$sizelimit_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1025

permission_find_1026()
{ #test_scenario (negative): --sizelimit;negative;INT
    rlPhaseStartTest "permission_find_1026"
        local testID="permission_find_1026"
        local tmpout=$TmpDir/permission_find_1026.$RANDOM.out
        KinitAsAdmin
        local sizelimit_TestValue_Negative="-2 a abc" #sizelimit;negative;INT
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID  --sizelimit=$sizelimit_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [sizelimit]=[$sizelimit_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1026

permission_find_1027()
{ #test_scenario (positive): --sizelimit;positive;INT
    rlPhaseStartTest "permission_find_1027"
        local testID="permission_find_1027"
        local tmpout=$TmpDir/permission_find_1027.$RANDOM.out
        KinitAsAdmin
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        rlRun "ipa permission-find $testID  --sizelimit=$sizelimit_TestValue " 0 "test options:  [sizelimit]=[$sizelimit_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1027

permission_find_1028()
{ #test_scenario (negative): --subtree;negative;STR
    rlPhaseStartTest "permission_find_1028"
        local testID="permission_find_1028"
        local tmpout=$TmpDir/permission_find_1028.$RANDOM.out
        KinitAsAdmin
        local subtree_TestValue_Negative="" #subtree;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID  --subtree=$subtree_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [subtree]=[$subtree_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1028

permission_find_1029()
{ #test_scenario (positive): --subtree;positive;STR
    rlPhaseStartTest "permission_find_1029"
        local testID="permission_find_1029"
        local tmpout=$TmpDir/permission_find_1029.$RANDOM.out
        KinitAsAdmin
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        rlRun "ipa permission-find $testID  --subtree=$subtree_TestValue " 0 "test options:  [subtree]=[$subtree_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1029

permission_find_1030()
{ #test_scenario (negative): --targetgroup;negative;STR
    rlPhaseStartTest "permission_find_1030"
        local testID="permission_find_1030"
        local tmpout=$TmpDir/permission_find_1030.$RANDOM.out
        KinitAsAdmin
        local targetgroup_TestValue_Negative="NotExist" #targetgroup;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID  --targetgroup=$targetgroup_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [targetgroup]=[$targetgroup_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1030

permission_find_1031()
{ #test_scenario (positive): --targetgroup;positive;STR
    rlPhaseStartTest "permission_find_1031"
        local testID="permission_find_1031"
        local tmpout=$TmpDir/permission_find_1031.$RANDOM.out
        KinitAsAdmin
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        rlRun "ipa permission-find $testID  --targetgroup=$targetgroup_TestValue " 0 "test options:  [targetgroup]=[$targetgroup_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1031

permission_find_1032()
{ #test_scenario (boundary): --timelimit;boundary;INT
    rlPhaseStartTest "permission_find_1032"
        local testID="permission_find_1032"
        local tmpout=$TmpDir/permission_find_1032.$RANDOM.out
        KinitAsAdmin
        local timelimit_TestValue="0" #timelimit;boundary;INT
        rlRun "ipa permission-find $testID  --timelimit=$timelimit_TestValue " 0 "test options:  [timelimit]=[$timelimit_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1032

permission_find_1033()
{ #test_scenario (negative): --timelimit;negative;INT
    rlPhaseStartTest "permission_find_1033"
        local testID="permission_find_1033"
        local tmpout=$TmpDir/permission_find_1033.$RANDOM.out
        KinitAsAdmin
        local timelimit_TestValue_Negative="-2 a abc" #timelimit;negative;INT
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID  --timelimit=$timelimit_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [timelimit]=[$timelimit_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1033

permission_find_1034()
{ #test_scenario (positive): --timelimit;positive;INT
    rlPhaseStartTest "permission_find_1034"
        local testID="permission_find_1034"
        local tmpout=$TmpDir/permission_find_1034.$RANDOM.out
        KinitAsAdmin
        local timelimit_TestValue="2" #timelimit;positive;INT
        rlRun "ipa permission-find $testID  --timelimit=$timelimit_TestValue " 0 "test options:  [timelimit]=[$timelimit_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1034

permission_find_1035()
{ #test_scenario (negative): --type;negative;nonSTRENUMValue
    rlPhaseStartTest "permission_find_1035"
        local testID="permission_find_1035"
        local tmpout=$TmpDir/permission_find_1035.$RANDOM.out
        KinitAsAdmin
        local type_TestValue_Negative="nonSTRENUMValue" #type;negative;nonSTRENUMValue
        local expectedErrMsg=replace_me
        qaRun "ipa permission-find $testID  --type=$type_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [type]=[$type_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1035

permission_find_1036()
{ #test_scenario (positive): --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_find_1036"
        local testID="permission_find_1036"
        local tmpout=$TmpDir/permission_find_1036.$RANDOM.out
        KinitAsAdmin
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        rlRun "ipa permission-find $testID  --type=$type_TestValue " 0 "test options:  [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_find_1036

#END OF TEST CASE for [permission-find]

#############################################
#  test suite: permission-mod (30 test cases)
#############################################
permission_mod()
{
    permission_mod_envsetup
    #permission_mod_1001  #test_scenario (negative test): [--addattr;negative;STR]
    #permission_mod_1002  #test_scenario (positive test): [--addattr;positive;STR]
    #permission_mod_1003  #test_scenario (negative test): [--attrs;negative;nonListValue --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --rename;positive;STR --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    #permission_mod_1004  #test_scenario (negative test): [--attrs;positive;LIST --desc;positive;auto generated description data --filter;negative;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --rename;positive;STR --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    #permission_mod_1005  #test_scenario (negative test): [--attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;negative;STR --permissions;positive;read, write, add, delete, all --rename;positive;STR --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    #permission_mod_1006  #test_scenario (negative test): [--attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;negative;nonListValue --rename;positive;STR --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    #permission_mod_1007  #test_scenario (negative test): [--attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --rename;negative;STR --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    #permission_mod_1008  #test_scenario (negative test): [--attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --rename;positive;STR --subtree;negative;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    #permission_mod_1009  #test_scenario (negative test): [--attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --rename;positive;STR --subtree;positive;STR --targetgroup;negative;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    #permission_mod_1010  #test_scenario (negative test): [--attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --rename;positive;STR --subtree;positive;STR --targetgroup;positive;STR --type;negative;nonSTRENUMValue]
    #permission_mod_1011  #test_scenario (positive test): [--attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --rename;positive;STR --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_mod_1012  #test_scenario (negative test): [--attrs;negative;nonListValue]
    permission_mod_1013  #test_scenario (positive test): [--attrs;positive;LIST]
    permission_mod_1014  #test_scenario (positive test): [--desc;positive;auto generated description data]
    permission_mod_1015  #test_scenario (negative test): [--filter;negative;STR]
    permission_mod_1016  #test_scenario (positive test): [--filter;positive;STR]
    permission_mod_1017  #test_scenario (negative test): [--memberof;negative;STR]
    permission_mod_1018  #test_scenario (positive test): [--memberof;positive;STR]
    permission_mod_1019  #test_scenario (negative test): [--permissions;negative;nonListValue]
    permission_mod_1020  #test_scenario (positive test): [--permissions;positive;read, write, add, delete, all]
    permission_mod_1021  #test_scenario (negative test): [--rename;negative;STR]
    permission_mod_1022  #test_scenario (positive test): [--rename;positive;STR]
    permission_mod_1023  #test_scenario (negative test): [--setattr;negative;STR]
    permission_mod_1024  #test_scenario (positive test): [--setattr;positive;STR]
    permission_mod_1025  #test_scenario (negative test): [--subtree;negative;STR]
    permission_mod_1026  #test_scenario (positive test): [--subtree;positive;STR]
    permission_mod_1027  #test_scenario (negative test): [--targetgroup;negative;STR]
    permission_mod_1028  #test_scenario (positive test): [--targetgroup;positive;STR]
    permission_mod_1029  #test_scenario (negative test): [--type;negative;nonSTRENUMValue]
    permission_mod_1030  #test_scenario (positive test): [--type;positive;user, group, host, hostgroup, service, netgroup, dns]
    permission_mod_envcleanup
} #permission-mod

permission_mod_envsetup()
{
    rlPhaseStartSetup "permission_mod_envsetup"
        #environment setup starts here
        createPermissionTestGroup $testGroup "test for permission mod"
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

permission_mod_envcleanup()
{
    rlPhaseStartCleanup "permission_mod_envcleanup"
        #environment cleanup starts here
        deletePermissionTestGroup $testGroup 
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

permission_mod_1001()
{ #test_scenario (negative): --addattr;negative;STR
    rlPhaseStartTest "permission_mod_1001"
        local testID="permission_mod_1001"
        local tmpout=$TmpDir/permission_mod_1001.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue_Negative="replace_me" #addattr;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-mod $testID  --addattr=$addattr_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [addattr]=[$addattr_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1001

permission_mod_1002()
{ #test_scenario (positive): --addattr;positive;STR
    rlPhaseStartTest "permission_mod_1002"
        local testID="permission_mod_1002"
        local tmpout=$TmpDir/permission_mod_1002.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue="replace_me" #addattr;positive;STR
        rlRun "ipa permission-mod $testID  --addattr=$addattr_TestValue " 0 "test options:  [addattr]=[$addattr_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1002

permission_mod_1003()
{ #test_scenario (negative): --all --attrs;negative;nonListValue --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --raw --rename;positive;STR --rights --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_mod_1003"
        local testID="permission_mod_1003"
        local tmpout=$TmpDir/permission_mod_1003.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local rename_TestValue="re$testID" #rename;positive;STR
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-mod $testID --all  --attrs=$attrs_TestValue_Negative  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue --raw  --rename=$rename_TestValue --rights  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue_Negative] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [rename]=[$rename_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1003

permission_mod_1004()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;negative;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --raw --rename;positive;STR --rights --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_mod_1004"
        local testID="permission_mod_1004"
        local tmpout=$TmpDir/permission_mod_1004.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="uidnumber,gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue_Negative="" #filter;negative;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="add" #permissions;positive;read, write, add, delete, all
        local rename_TestValue="re$testID" #rename;positive;STR
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-mod $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue_Negative  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue --raw  --rename=$rename_TestValue --rights  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue_Negative] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [rename]=[$rename_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1004

permission_mod_1005()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;negative;STR --permissions;positive;read, write, add, delete, all --raw --rename;positive;STR --rights --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_mod_1005"
        local testID="permission_mod_1005"
        local tmpout=$TmpDir/permission_mod_1005.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue_Negative="NotExist" #memberof;negative;STR
        local permissions_TestValue="write" #permissions;positive;read, write, add, delete, all
        local rename_TestValue="re$testID" #rename;positive;STR
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-mod $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue_Negative  --permissions=$permissions_TestValue --raw  --rename=$rename_TestValue --rights  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue_Negative] [permissions]=[$permissions_TestValue] [rename]=[$rename_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1005

permission_mod_1006()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;negative;nonListValue --raw --rename;positive;STR --rights --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_mod_1006"
        local testID="permission_mod_1006"
        local tmpout=$TmpDir/permission_mod_1006.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local rename_TestValue="re$testID" #rename;positive;STR
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-mod $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue_Negative --raw  --rename=$rename_TestValue --rights  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue_Negative] [rename]=[$rename_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1006

permission_mod_1007()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --raw --rename;negative;STR --rights --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_mod_1007"
        local testID="permission_mod_1007"
        local tmpout=$TmpDir/permission_mod_1007.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="uidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="all" #permissions;positive;read, write, add, delete, all
        local rename_TestValue_Negative="NotExist" #rename;negative;STR
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-mod $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue --raw  --rename=$rename_TestValue_Negative --rights  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [rename]=[$rename_TestValue_Negative] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1007

permission_mod_1008()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --raw --rename;positive;STR --rights --subtree;negative;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_mod_1008"
        local testID="permission_mod_1008"
        local tmpout=$TmpDir/permission_mod_1008.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="write" #permissions;positive;read, write, add, delete, all
        local rename_TestValue="re$testID" #rename;positive;STR
        local subtree_TestValue_Negative="" #subtree;negative;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-mod $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue --raw  --rename=$rename_TestValue --rights  --subtree=$subtree_TestValue_Negative  --targetgroup=$targetgroup_TestValue  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [rename]=[$rename_TestValue] [subtree]=[$subtree_TestValue_Negative] [targetgroup]=[$targetgroup_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1008

permission_mod_1009()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --raw --rename;positive;STR --rights --subtree;positive;STR --targetgroup;negative;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_mod_1009"
        local testID="permission_mod_1009"
        local tmpout=$TmpDir/permission_mod_1009.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="uidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read" #permissions;positive;read, write, add, delete, all
        local rename_TestValue="re$testID" #rename;positive;STR
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue_Negative="NotExist" #targetgroup;negative;STR
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        local expectedErrMsg=replace_me
        qaRun "ipa permission-mod $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue --raw  --rename=$rename_TestValue --rights  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue_Negative  --type=$type_TestValue " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [rename]=[$rename_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue_Negative] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1009

permission_mod_1010()
{ #test_scenario (negative): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --raw --rename;positive;STR --rights --subtree;positive;STR --targetgroup;positive;STR --type;negative;nonSTRENUMValue
    rlPhaseStartTest "permission_mod_1010"
        local testID="permission_mod_1010"
        local tmpout=$TmpDir/permission_mod_1010.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="write,delete" #permissions;positive;read, write, add, delete, all
        local rename_TestValue="re$testID" #rename;positive;STR
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local type_TestValue_Negative="nonSTRENUMValue" #type;negative;nonSTRENUMValue
        local expectedErrMsg=replace_me
        qaRun "ipa permission-mod $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue --raw  --rename=$rename_TestValue --rights  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --type=$type_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [rename]=[$rename_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [type]=[$type_TestValue_Negative]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1010

permission_mod_1011()
{ #test_scenario (positive): --all --attrs;positive;LIST --desc;positive;auto generated description data --filter;positive;STR --memberof;positive;STR --permissions;positive;read, write, add, delete, all --raw --rename;positive;STR --rights --subtree;positive;STR --targetgroup;positive;STR --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_mod_1011"
        local testID="permission_mod_1011"
        local tmpout=$TmpDir/permission_mod_1011.$RANDOM.out
        KinitAsAdmin
        local attrs_TestValue="uidnumber" #attrs;positive;LIST
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        local permissions_TestValue="read,delete,all" #permissions;positive;read, write, add, delete, all
        local rename_TestValue="re$testID" #rename;positive;STR
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        local type_TestValue="user group host hostgroup service netgroup dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        rlRun "ipa permission-mod $testID --all  --attrs=$attrs_TestValue  --desc=$desc_TestValue  --filter=$filter_TestValue  --memberof=$memberof_TestValue  --permissions=$permissions_TestValue --raw  --rename=$rename_TestValue --rights  --subtree=$subtree_TestValue  --targetgroup=$targetgroup_TestValue  --type=$type_TestValue " 0 "test options:  [attrs]=[$attrs_TestValue] [desc]=[$desc_TestValue] [filter]=[$filter_TestValue] [memberof]=[$memberof_TestValue] [permissions]=[$permissions_TestValue] [rename]=[$rename_TestValue] [subtree]=[$subtree_TestValue] [targetgroup]=[$targetgroup_TestValue] [type]=[$type_TestValue]" 
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1011

permission_mod_1012()
{ #test_scenario (negative): --attrs;negative;nonListValue
    rlPhaseStartTest "permission_mod_1012"
        local testID="permission_mod_1012"
        local tmpout=$TmpDir/permission_mod_1012.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=for_$testID --attrs=uidnumber,gidnumber --permissions=all --type=user" 0 "add permission for test [$testID]"
        local attrs_TestValue_Negative="noSuchAttrs" #attrs;negative;nonListValue
        local expectedErrMsg="targetattr \"$attrs_TestValue_Negative\" does not exist in schema"
        rlRun "ipa permission-add $testID --desc=for_$testID --permissions=all --type=user" 0 "add permission for test [$testID]"
        qaRun "ipa permission-mod $testID  --attrs=$attrs_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [attrs]=[$attrs_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1012

permission_mod_1013()
{ #test_scenario (positive): --attrs;positive;LIST
    rlPhaseStartTest "permission_mod_1013"
        local testID="permission_mod_1013"
        local tmpout=$TmpDir/permission_mod_1013.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=for_$testID --permissions=all --type=user" 0 "add permission for test [$testID]"
        local attrs_TestValue="gidnumber" #attrs;positive;LIST
        rlRun "ipa permission-mod $testID  --attrs=$attrs_TestValue " 0 "test options:  [attrs]=[$attrs_TestValue]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1013

permission_mod_1014()
{ #test_scenario (positive): --desc;positive;auto generated description data
    rlPhaseStartTest "permission_mod_1014"
        local testID="permission_mod_1014"
        local tmpout=$TmpDir/permission_mod_1014.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=for_$testID --permissions=all --type=user" 0 "add permission for test [$testID]"
        local desc_TestValue="auto_generated_description_$testID" #desc;positive;auto generated description data
        rlRun "ipa permission-mod $testID  --desc=$desc_TestValue " 0 "test options:  [desc]=[$desc_TestValue]" 
        checkPermissionInfo $testID "Description" "$desc_TestValue"
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1014

permission_mod_1015()
{ #test_scenario (negative): --filter;negative;STR
    rlPhaseStartTest "permission_mod_1015"
        local testID="permission_mod_1015"
        local tmpout=$TmpDir/permission_mod_1015.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=all --filter=cn=ipausers" 0 "create permission for $testID"
        local filter_TestValue_Negative="" #filter;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-mod $testID  --filter=$filter_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [filter]=[$filter_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1015

permission_mod_1016()
{ #test_scenario (positive): --filter;positive;STR
    rlPhaseStartTest "permission_mod_1016"
        local testID="permission_mod_1016"
        local tmpout=$TmpDir/permission_mod_1016.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=all --filter=cn=ipausers" 0 "create permission for $testID"
        local filter_TestValue="cn=$testGroup" #filter;positive;STR
        rlRun "ipa permission-mod $testID  --filter=$filter_TestValue " 0 "test options:  [filter]=[$filter_TestValue]" 
        checkPermissionInfo $testID "Filter" "($filter_TestValue)"
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1016

permission_mod_1017()
{ #test_scenario (negative): --memberof;negative;STR
    rlPhaseStartTest "permission_mod_1017"
        local testID="permission_mod_1017"
        local tmpout=$TmpDir/permission_mod_1017.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=all --subtree=cn=ipausers,cn=accounts,$testDC" 0 "create permission for $testID"
        local memberof_TestValue_Negative="NotExist" #memberof;negative;STR
        local expectedErrMsg="group not found"
        qaRun "ipa permission-mod $testID  --memberof=$memberof_TestValue_Negative " "$tmpout" 2 "$expectedErrMsg" "test options:  [memberof]=[$memberof_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1017

permission_mod_1018()
{ #test_scenario (positive): --memberof;positive;STR
    rlPhaseStartTest "permission_mod_1018"
        local testID="permission_mod_1018"
        local tmpout=$TmpDir/permission_mod_1018.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=all --subtree=cn=ipausers,cn=accounts,$testDC" 0 "create permission for $testID"
        local memberof_TestValue="$testGroup" #memberof;positive;STR
        rlRun "ipa permission-mod $testID  --memberof=$memberof_TestValue " 0 "test options:  [memberof]=[$memberof_TestValue]" 
        memberofInfo="(memberOf=cn=ipausers,cn=groups,cn=accounts,$testDC)"
        checkPermissionInfo $testID "Filter" "$memberofInfo"
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1018

permission_mod_1019()
{ #test_scenario (negative): --permissions;negative;nonListValue
    rlPhaseStartTest "permission_mod_1019"
        local testID="permission_mod_1019"
        local tmpout=$TmpDir/permission_mod_1019.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=delete --subtree=cn=ipausers,cn=accounts,$testDC" 0 "create permission for $testID"
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local expectedErrMsg="invalid 'permissions'"
        qaRun "ipa permission-mod $testID  --permissions=$permissions_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [permissions]=[$permissions_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1019

permission_mod_1020()
{ #test_scenario (positive): --permissions;positive;read, write, add, delete, all
    rlPhaseStartTest "permission_mod_1020"
        local testID="permission_mod_1020"
        local tmpout=$TmpDir/permission_mod_1020.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=delete --subtree=cn=ipausers,cn=accounts,$testDC" 0 "create permission for $testID"
        local permissions_TestValue="write" #permissions;positive;read, write, add, delete, all
        rlRun "ipa permission-mod $testID  --permissions=$permissions_TestValue " 0 "test options:  [permissions]=[$permissions_TestValue]" 
        checkPermissionInfo $testID "Permissions" "$permissions_TestValue"
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1020

permission_mod_1021()
{ #test_scenario (negative): --rename;negative;STR
    rlPhaseStartTest "permission_mod_1021"
        local testID="permission_mod_1021"
        local tmpout=$TmpDir/permission_mod_1021.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=delete --subtree=cn=ipausers,cn=accounts,$testDC" 0 "create permission for $testID"
        local rename_TestValue_Negative="+-" #rename;negative;STR
        local expectedErrMsg="no modifications to be performed"
        qaRun "ipa permission-mod $testID  --rename=$rename_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [rename]=[$rename_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1021

permission_mod_1022()
{ #test_scenario (positive): --rename;positive;STR
    rlPhaseStartTest "permission_mod_1022"
        local testID="permission_mod_1022"
        local tmpout=$TmpDir/permission_mod_1022.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=delete --subtree=cn=ipausers,cn=accounts,$testDC" 0 "create permission for $testID"
        local rename_TestValue="re$testID" #rename;positive;STR
        rlRun "ipa permission-mod $testID  --rename=$rename_TestValue " 0 "test options:  [rename]=[$rename_TestValue]" 
        checkPermissionInfo $testID "Permission name" "$rename_TestValue"
        rlRun "ipa permission-del $rename_TestValue"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1022

permission_mod_1023()
{ #test_scenario (negative): --setattr;negative;STR
    rlPhaseStartTest "permission_mod_1023"
        local testID="permission_mod_1023"
        local tmpout=$TmpDir/permission_mod_1023.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=write --subtree=cn=ipausers,cn=accounts,$testDC" 0 "create permission for $testID"
        local setattr_TestValue_Negative="permissions=badPermission" #setattr;negative;STR
        local expectedErrMsg="no modifications to be performed"
        qaRun "ipa permission-mod $testID  --setattr=$setattr_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [setattr]=[$setattr_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1023

permission_mod_1024()
{ #test_scenario (positive): --setattr;positive;STR
    rlPhaseStartTest "permission_mod_1024"
        local testID="permission_mod_1024"
        local tmpout=$TmpDir/permission_mod_1024.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=write --type=group" 0 "create permission for $testID"
        local setattr_TestValue="permissions=all" #setattr;positive;STR
        rlRun "ipa permission-mod $testID  --setattr=$setattr_TestValue " 0 "test options:  [setattr]=[$setattr_TestValue]" 
        checkPermissionInfo $testID "Permissions" "all"
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1024

permission_mod_1025()
{ #test_scenario (negative): --subtree;negative;STR
    rlPhaseStartTest "permission_mod_1025"
        local testID="permission_mod_1025"
        local tmpout=$TmpDir/permission_mod_1025.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=write --subtree=cn=ipausers,cn=accounts,$testDC" 0 "create permission for $testID"
        local subtree_TestValue_Negative="" #subtree;negative;STR
        local expectedErrMsg=replace_me
        qaRun "ipa permission-mod $testID  --subtree=$subtree_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [subtree]=[$subtree_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1025

permission_mod_1026()
{ #test_scenario (positive): --subtree;positive;STR
    rlPhaseStartTest "permission_mod_1026"
        local testID="permission_mod_1026"
        local tmpout=$TmpDir/permission_mod_1026.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=write --subtree=cn=ipausers,cn=accounts,$testDC" 0 "create permission for $testID"
        local subtree_TestValue="cn=$testGroup,cn=groups,$testDC" #subtree;positive;STR
        rlRun "ipa permission-mod $testID  --subtree=$subtree_TestValue " 0 "test options:  [subtree]=[$subtree_TestValue]" 
        ipa permission-find $testID > $tmpout
        if grep -i "ldap:///$subtree_TestValue" $tmpout 2>&1
        then
            rlPass "subtree modified as expected"
        else
            rlFail "subtree modification failed"
            echo "---------------------- output --------------"
            cat $tmpout
            echo "============================================"
        fi
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1026

permission_mod_1027()
{ #test_scenario (negative): --targetgroup;negative;STR
    rlPhaseStartTest "permission_mod_1027"
        local testID="permission_mod_1027"
        local tmpout=$TmpDir/permission_mod_1027.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=write --targetgroup=ipausers" 0 "create permission for $testID"
        local targetgroup_TestValue_Negative="NotExist" #targetgroup;negative;STR
        local expectedErrMsg="group not found"
        qaRun "ipa permission-mod $testID  --targetgroup=$targetgroup_TestValue_Negative " "$tmpout" 2 "$expectedErrMsg" "test options:  [targetgroup]=[$targetgroup_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1027

permission_mod_1028()
{ #test_scenario (positive): --targetgroup;positive;STR
    rlPhaseStartTest "permission_mod_1028"
        local testID="permission_mod_1028"
        local tmpout=$TmpDir/permission_mod_1028.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=write --targetgroup=ipausers" 0 "create permission for $testID"
        local targetgroup_TestValue="$testGroup" #targetgroup;positive;STR
        rlRun "ipa permission-mod $testID  --targetgroup=$targetgroup_TestValue " 0 "test options:  [targetgroup]=[$targetgroup_TestValue]" 
        checkPermissionInfo $testID "Target group" "$targetgroup_TestValue"
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1028

permission_mod_1029()
{ #test_scenario (negative): --type;negative;nonSTRENUMValue
    rlPhaseStartTest "permission_mod_1029"
        local testID="permission_mod_1029"
        local tmpout=$TmpDir/permission_mod_1029.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=read --type=user" 0 "create permission for $testID"
        local type_TestValue_Negative="nonSTRENUMValue" #type;negative;nonSTRENUMValue
        local expectedErrMsg="invalid 'type'"
        qaRun "ipa permission-mod $testID  --type=$type_TestValue_Negative " "$tmpout" 1 "$expectedErrMsg" "test options:  [type]=[$type_TestValue_Negative]" 
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1029

permission_mod_1030()
{ #test_scenario (positive): --type;positive;user, group, host, hostgroup, service, netgroup, dns
    rlPhaseStartTest "permission_mod_1030"
        local testID="permission_mod_1030"
        local tmpout=$TmpDir/permission_mod_1030.$RANDOM.out
        KinitAsAdmin
        local type_TestValue="dns" #type;positive;user, group, host, hostgroup, service, netgroup, dns
        rlRun "ipa permission-add $testID --desc=4_$testID --permissions=read --type=user" 0 "create permission for $testID"
        rlRun "ipa permission-mod $testID  --type=$type_TestValue " 0 "test options:  [type]=[$type_TestValue]" 
        checkPermissionInfo $testID "Type" "$type_TestValue"
        rlRun "ipa permission-del $testID"
        Kcleanup
        rm $tmpout 2>&1 >/dev/null
    rlPhaseEnd
} #permission_mod_1030

#END OF TEST CASE for [permission-mod]

#############################################
#  test suite: permission-show (4 test cases)
#############################################
permission_show()
{
    permission_show_envsetup
    permission_show_1001  #test_scenario (positive test): [--all]
    permission_show_1002  #test_scenario (positive test): [--all --raw --rights]
    permission_show_1003  #test_scenario (positive test): [--raw]
    permission_show_1004  #test_scenario (positive test): [--rights]
    permission_show_envcleanup
} #permission-show

permission_show_envsetup()
{
    rlPhaseStartSetup "permission_show_envsetup"
        #environment setup starts here
        local name="show_only_permission"
        KinitAsAdmin
        rlRun "ipa permission-add $name --desc=used_for_show_test --permissions=read,write --type=group"
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

permission_show_envcleanup()
{
    rlPhaseStartCleanup "permission_show_envcleanup"
        #environment cleanup starts here
        local name="show_only_permission"
        KinitAsAdmin
        rlRun "ipa permission-add $name --desc=used_for_show_test --permissions=read,write --type=group"
        rlRun "ipa permission-del $name" 0 "remove the permission for show test"
        Kcleanup
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

permission_show_1001()
{ #test_scenario (positive): --all
    rlPhaseStartTest "permission_show_1001"
        local testID="permission_show_1001"
        local name="show_only_permission"
        KinitAsAdmin
        rlRun "ipa permission-show $name --all " 0 "test options: " 
        Kcleanup
    rlPhaseEnd
} #permission_show_1001

permission_show_1002()
{ #test_scenario (positive): --all --raw --rights
    rlPhaseStartTest "permission_show_1002"
        local testID="permission_show_1002"
        local name="show_only_permission"
        KinitAsAdmin
        rlRun "ipa permission-show $name --all --raw --rights " 0 "test options: " 
        Kcleanup
    rlPhaseEnd
} #permission_show_1002

permission_show_1003()
{ #test_scenario (positive): --raw
    rlPhaseStartTest "permission_show_1003"
        local testID="permission_show_1003"
        local name="show_only_permission"
        KinitAsAdmin
        rlRun "ipa permission-show $name --raw " 0 "test options: " 
        Kcleanup
    rlPhaseEnd
} #permission_show_1003

permission_show_1004()
{ #test_scenario (positive): --rights
    rlPhaseStartTest "permission_show_1004"
        local testID="permission_show_1004"
        local name="show_only_permission"
        KinitAsAdmin
        rlRun "ipa permission-show $name --rights " 0 "test options: " 
        Kcleanup
    rlPhaseEnd
} #permission_show_1004

#END OF TEST CASE for [permission-show]

privilege()
{
    privilege_add
    privilege_add_permission
    privilege_del
    privilege_find
    privilege_mod
    privilege_remove_permission
    privilege_show
} #privilege

#############################################
#  test suite: privilege-add (5 test cases)
#############################################
privilege_add()
{
    privilege_add_envsetup
    privilege_add_1001  #test_scenario (negative test): [--addattr;negative;STR]
    privilege_add_1002  #test_scenario (positive test): [--addattr;positive;STR]
    privilege_add_1003  #test_scenario (positive test): [--desc;positive;auto_generated_description_data_$testID]
    privilege_add_1004  #test_scenario (negative test): [--setattr;negative;STR]
    privilege_add_1005  #test_scenario (positive test): [--setattr;positive;STR]
    privilege_add_envcleanup
} #privilege-add

privilege_add_envsetup()
{
    rlPhaseStartSetup "privilege_add_envsetup"
        #environment setup starts here
        rlPass "no special setup necessary"
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

privilege_add_envcleanup()
{
    rlPhaseStartCleanup "privilege_add_envcleanup"
        #environment cleanup starts here
        rlPass "no special clean up necessary"
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

privilege_add_1001()
{ #test_scenario (negative): --addattr;negative;STR
    rlPhaseStartTest "privilege_add_1001"
        local testID="privilege_add_1001"
        local tmpout=$TmpDir/privilege_add_1001.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue_Negative="badFormat" #addattr;negative;STR
        local expectedErrMsg="invalid 'addattr': Invalid format. Should be name=value"
        local expectedErrCode=1
        qaRun "ipa privilege-add $testID  --desc=4_$testID --addattr=$addattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [addattr]=[$addattr_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_add_1001

privilege_add_1002()
{ #test_scenario (positive): --addattr;positive;STR
    rlPhaseStartTest "privilege_add_1002"
        local testID="privilege_add_1002"
        local tmpout=$TmpDir/privilege_add_1002.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue="memberof=$testPemission_addgrp" #addattr;positive;STR
        rlRun "ipa privilege-add $testID --desc=4_$testID --addattr=$addattr_TestValue " 0 "test options:  [addattr]=[$addattr_TestValue]" 
        checkPrivilegeInfo "$testID" "permissions" "$p_id"
        rlRun "ipa privilege-del $testID"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_add_1002

privilege_add_1003()
{ #test_scenario (positive): --desc;positive;auto_generated_description_data_$testID
    rlPhaseStartTest "privilege_add_1003"
        local testID="privilege_add_1003"
        local tmpout=$TmpDir/privilege_add_1003.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_data_$testID" #desc;positive;auto_generated_description_data_$testID
        rlRun "ipa privilege-add $testID  --desc=$desc_TestValue " 0 "test options:  [desc]=[$desc_TestValue]" 
        checkPrivilegeInfo $testID "Description" "$desc_TestValue"
        rlRun "ipa privilege-del $testID"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_add_1003

privilege_add_1004()
{ #test_scenario (negative): --setattr;negative;STR
    rlPhaseStartTest "privilege_add_1004"
        local testID="privilege_add_1004"
        local tmpout=$TmpDir/privilege_add_1004.$RANDOM.out
        KinitAsAdmin
        local setattr_TestValue_Negative="STR" #setattr;negative;STR
        local expectedErrMsg="invalid 'setattr': Invalid format. Should be name=value"
        local expectedErrCode=1
        qaRun "ipa privilege-add $testID --desc=4_$testID --setattr=$setattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [setattr]=[$setattr_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_add_1004

privilege_add_1005()
{ #test_scenario (positive): --setattr;positive;STR
    rlPhaseStartTest "privilege_add_1005"
        local testID="privilege_add_1005"
        local tmpout=$TmpDir/privilege_add_1005.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="newDesc$testID"
        local setattr_TestValue="description=$desc_TestValue" #setattr;positive;STR
        rlRun "ipa privilege-add $testID --desc=4_$testID --setattr=$setattr_TestValue " 0 "test options:  [setattr]=[$setattr_TestValue]" 
        checkPrivilegeInfo $testID "Description" "$desc_TestValue"
        rlRun "ipa privilege-del $testID"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_add_1005

#END OF TEST CASE for [privilege-add]

#############################################
#  test suite: privilege-add-permission (2 test cases)
#############################################
privilege_add_permission()
{
    privilege_add_permission_envsetup
    privilege_add_permission_1001  #test_scenario (negative test): [--permissions;negative;nonListValue]
    privilege_add_permission_1002  #test_scenario (positive test): [--permissions;positive;read,write,delete,add,all]
    privilege_add_permission_envcleanup
} #privilege-add-permission

privilege_add_permission_envsetup()
{
    rlPhaseStartSetup "privilege_add_permission_envsetup"
        #environment setup starts here
        createTestPrivilege $testPrivilege 
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

privilege_add_permission_envcleanup()
{
    rlPhaseStartCleanup "privilege_add_permission_envcleanup"
        #environment cleanup starts here
        deleteTestPrivilege $testPrivilege
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

privilege_add_permission_1001()
{ #test_scenario (negative): --permissions;negative;nonListValue
    rlPhaseStartTest "privilege_add_permission_1001"
        local testID="privilege_add_permission_1001"
        local tmpout=$TmpDir/privilege_add_permission_1001.$RANDOM.out
        KinitAsAdmin
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local expectedErrMsg="permission not found"
        ipa privilege-add-permission $testPrivilege  --permissions=$permissions_TestValue_Negative > $tmpout
        if grep -i "$expectedErrMsg" $tmpout;then
            rlPass "add permission failed as expected"
        else
            rlFail "no match error msg found"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_add_permission_1001

privilege_add_permission_1002()
{ #test_scenario (positive): --permissions;positive;read,write,delete,add,all
    rlPhaseStartTest "privilege_add_permission_1002"
        local testID="privilege_add_permission_1002"
        local tmpout=$TmpDir/privilege_add_permission_1002.$RANDOM.out
        KinitAsAdmin
        local permissions_TestValue="readTest" #permissions;positive;read,write,delete,add,all
        rlRun "ipa permission-add $permissions_TestValue --desc=4_$permissions_TestValue --permissions=read --type=user" 0 "create test permission"
        rlRun "ipa privilege-add-permission $testPrivilege --permissions=$permissions_TestValue " 0 "test options:  [permissions]=[$permissions_TestValue]" 
        checkPrivilegeInfo $testPrivilege "Permissions" $permissions_TestValue
        rlRun "ipa permission-del $permissions_TestValue"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_add_permission_1002

#END OF TEST CASE for [privilege-add-permission]

#############################################
#  test suite: privilege-del (1 test cases)
#############################################
privilege_del()
{
    privilege_del_envsetup
    privilege_del_1001  #test_scenario (positive test): [--continue]
    privilege_del_envcleanup
} #privilege-del

privilege_del_envsetup()
{
    rlPhaseStartSetup "privilege_del_envsetup"
        #environment setup starts here
        KinitAsAdmin
        for id in 1 2 3 4
        do
            rlRun "ipa privilege-add privilege_del_$id --desc=privilege_del_$id" 0 "create privileges for delete test id=[$id]"
        done
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

privilege_del_envcleanup()
{
    rlPhaseStartCleanup "privilege_del_envcleanup"
        #environment cleanup starts here
        # up to this point, all delete related test data suppose to be removed from ipa server
        rlPass "no special cleanup required"
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

privilege_del_1001()
{ #test_scenario (positive): --continue
    rlPhaseStartTest "privilege_del_1001"
        local testID="privilege_del_1001"
        local tmpout=$TmpDir/privilege_del_1001.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa privilege-del --continue $testID " 0 "delete a privilege that does not exist" 
        rlRun "ipa privilege-del --continue privilege_del_1 $testID" 0 "delete mixed list of privileges"
        rlRun "ipa privilege-del --continue $testID privilege_del_2" 0 "delete mixed list of privileges"
        rlRun "ipa privilege-del --continue privilege_del_3 $testID privilege_del_4" 0 "delete mixed list of privileges"
        total=`ipa privilege-find privilege_del_ | grep -i "Privilege name: privilege_del_" | wc -l`
        if [ "$total" = "0" ];then
            rlPass "all test privilege_del_[1234] deleted as expected"
        else
            rlFail "not all test privilege deleted"
            echo "============================="
            ipa privilege-find privilege_del_
            echo "============================="
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_del_1001

#END OF TEST CASE for [privilege-del]

#############################################
#  test suite: privilege-find (14 test cases)
#############################################
privilege_find()
{
    privilege_find_envsetup
    privilege_find_1001  #test_scenario (positive test): [--all]
#    privilege_find_1002  #test_scenario (negative test): [--all --desc;positive;auto_generated_description_data_$testID --name;negative;STR --raw --sizelimit;positive;2 --timelimit;positive;2]
#    privilege_find_1003  #test_scenario (negative test): [--all --desc;positive;auto_generated_description_data_$testID --name;positive;$testID --raw --sizelimit;negative;-2,a,abc --timelimit;positive;2]
#    privilege_find_1004  #test_scenario (negative test): [--all --desc;positive;auto_generated_description_data_$testID --name;positive;$testID --raw --sizelimit;positive;2 --timelimit;negative;-2,a,abc]
#    privilege_find_1005  #test_scenario (positive test): [--all --desc;positive;auto_generated_description_data_$testID --name;positive;$testID --raw --sizelimit;positive;2 --timelimit;positive;2]
    privilege_find_1006  #test_scenario (positive test): [--desc;positive;auto_generated_description_data_$testID]
    privilege_find_1007  #test_scenario (negative test): [--name;negative;STR]
    privilege_find_1008  #test_scenario (positive test): [--name;positive;$testID]
    privilege_find_1009  #test_scenario (boundary test): [--sizelimit;boundary;0]
    privilege_find_1010  #test_scenario (negative test): [--sizelimit;negative;-2,a,abc]
    privilege_find_1011  #test_scenario (positive test): [--sizelimit;positive;2]
    privilege_find_1012  #test_scenario (boundary test): [--timelimit;boundary;0]
    privilege_find_1013  #test_scenario (negative test): [--timelimit;negative;-2,a,abc]
    privilege_find_1014  #test_scenario (positive test): [--timelimit;positive;2]
    privilege_find_envcleanup
} #privilege-find

privilege_find_envsetup()
{
    rlPhaseStartSetup "privilege_find_envsetup"
        #environment setup starts here
        createTestPrivilege $testPrivilege
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

privilege_find_envcleanup()
{
    rlPhaseStartCleanup "privilege_find_envcleanup"
        #environment cleanup starts here
        deleteTestPrivilege $testPrivilege
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

privilege_find_1001()
{ #test_scenario (positive): --all
    rlPhaseStartTest "privilege_find_1001"
        local testID="privilege_find_1001"
        local tmpout=$TmpDir/privilege_find_1001.$RANDOM.out
        KinitAsAdmin
        ipa privilege-find $testPrivilege --all 2>&1 >$tmpout
        if grep -i "$testPrivilege" $tmpout 2>&1 >/dev/null ;then
            rlPass "found test privilege"
        else
            rlFail "test privilege not found when --all is given"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1001

privilege_find_1002()
{ #test_scenario (negative): --all --desc;positive;auto_generated_description_data_$testID --name;negative;STR --raw --sizelimit;positive;2 --timelimit;positive;2
    rlPhaseStartTest "privilege_find_1002"
        local testID="privilege_find_1002"
        local tmpout=$TmpDir/privilege_find_1002.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_data_$testID" #desc;positive;auto_generated_description_data_$testID
        local name_TestValue_Negative="STR" #name;negative;STR
        local sizelimit_TestValue="2" #sizelimit;positive;2
        local timelimit_TestValue="2" #timelimit;positive;2
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa privilege-find $testID --all  --desc=$desc_TestValue  --name=$name_TestValue_Negative --raw  --sizelimit=$sizelimit_TestValue  --timelimit=$timelimit_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [name]=[$name_TestValue_Negative] [sizelimit]=[$sizelimit_TestValue] [timelimit]=[$timelimit_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1002

privilege_find_1003()
{ #test_scenario (negative): --all --desc;positive;auto_generated_description_data_$testID --name;positive;$testID --raw --sizelimit;negative;-2,a,abc --timelimit;positive;2
    rlPhaseStartTest "privilege_find_1003"
        local testID="privilege_find_1003"
        local tmpout=$TmpDir/privilege_find_1003.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_data_$testID" #desc;positive;auto_generated_description_data_$testID
        local name_TestValue="$testID" #name;positive;$testID
        local sizelimit_TestValue_Negative="-2,a,abc" #sizelimit;negative;-2,a,abc
        local timelimit_TestValue="2" #timelimit;positive;2
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa privilege-find $testID --all  --desc=$desc_TestValue  --name=$name_TestValue --raw  --sizelimit=$sizelimit_TestValue_Negative  --timelimit=$timelimit_TestValue " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [name]=[$name_TestValue] [sizelimit]=[$sizelimit_TestValue_Negative] [timelimit]=[$timelimit_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1003

privilege_find_1004()
{ #test_scenario (negative): --all --desc;positive;auto_generated_description_data_$testID --name;positive;$testID --raw --sizelimit;positive;2 --timelimit;negative;-2,a,abc
    rlPhaseStartTest "privilege_find_1004"
        local testID="privilege_find_1004"
        local tmpout=$TmpDir/privilege_find_1004.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_data_$testID" #desc;positive;auto_generated_description_data_$testID
        local name_TestValue="$testID" #name;positive;$testID
        local sizelimit_TestValue="2" #sizelimit;positive;2
        local timelimit_TestValue_Negative="-2,a,abc" #timelimit;negative;-2,a,abc
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa privilege-find $testID --all  --desc=$desc_TestValue  --name=$name_TestValue --raw  --sizelimit=$sizelimit_TestValue  --timelimit=$timelimit_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [name]=[$name_TestValue] [sizelimit]=[$sizelimit_TestValue] [timelimit]=[$timelimit_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1004

privilege_find_1005()
{ #test_scenario (positive): --all --desc;positive;auto_generated_description_data_$testID --name;positive;$testID --raw --sizelimit;positive;2 --timelimit;positive;2
    rlPhaseStartTest "privilege_find_1005"
        local testID="privilege_find_1005"
        local tmpout=$TmpDir/privilege_find_1005.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_data_$testID" #desc;positive;auto_generated_description_data_$testID
        local name_TestValue="$testID" #name;positive;$testID
        local sizelimit_TestValue="2" #sizelimit;positive;2
        local timelimit_TestValue="2" #timelimit;positive;2
        rlRun "ipa privilege-find $testID --all  --desc=$desc_TestValue  --name=$name_TestValue --raw  --sizelimit=$sizelimit_TestValue  --timelimit=$timelimit_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [name]=[$name_TestValue] [sizelimit]=[$sizelimit_TestValue] [timelimit]=[$timelimit_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1005

privilege_find_1006()
{ #test_scenario (positive): --desc;positive;auto_generated_description_data_$testID
    rlPhaseStartTest "privilege_find_1006"
        local testID="privilege_find_1006"
        local tmpout=$TmpDir/privilege_find_1006.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="4_$testPrivilege" #desc;positive;auto_generated_description_data_$testID
        total=`ipa privilege-find --desc=$desc_TestValue | grep -i "$desc_TestValue" | wc -l`
        if [ "$total" = "1" ];then
            rlPass "found privilege based on desc"
        else
            rlFail "no privilege found based on desc -- when 1 is expected"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1006

privilege_find_1007()
{ #test_scenario (negative): --name;negative;STR
    rlPhaseStartTest "privilege_find_1007"
        local testID="privilege_find_1007"
        local tmpout=$TmpDir/privilege_find_1007.$RANDOM.out
        KinitAsAdmin
        local expectedErrMsg="name option requires an argument"
        local expectedErrCode=2
        qaRun "ipa privilege-find --name " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [name]=[$name_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1007

privilege_find_1008()
{ #test_scenario (positive): --name;positive;$testID
    rlPhaseStartTest "privilege_find_1008"
        local testID="privilege_find_1008"
        local tmpout=$TmpDir/privilege_find_1008.$RANDOM.out
        KinitAsAdmin
        local name_TestValue="$testPrivilege" #name;positive;$testID
        total=`ipa privilege-find --name=$testPrivilege | grep "Privilege name" | grep -i "$testPrivilege" | wc -l`
        if [ "$total" = "1" ];then
            rlPass "found privilege based on desc"
        else
            rlFail "no privilege found based on desc -- when 1 is expected, actual [$total]"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1008

privilege_find_1009()
{ #test_scenario (boundary): --sizelimit;boundary;0
    rlPhaseStartTest "privilege_find_1009"
        local testID="privilege_find_1009"
        local tmpout=$TmpDir/privilege_find_1009.$RANDOM.out
        KinitAsAdmin
        local allPrivileges=""
        local i=0
        while [ $i -lt 4 ];do
            name="testPri_$RANDOM"
            allPrivileges="$allPrivileges $name"
            rlRun "ipa privilege-add $name --desc=testPrivileges"
            i=$((i+1))
        done
        local sizelimit_TestValue="0" #sizelimit;boundary;0
        total=`ipa privilege-find testPri_ | grep "Privilege name" | grep -i "testPri_" | wc -l`
        if [ $total -eq 4 ];then
            found=`ipa privilege-find testPri_ --sizelimit=$sizelimit_TestValue  | grep -i "testPri_" | wc -l`
            if [ $found -eq $total ];then
                rlPass "total returned as we expected"
            else
                rlFail "set limit to [$sizelimit_TestValue], but returned: [$found]"
            fi
        else
            rlFail "total created test privileges not right, test failed due to env total=[$total], expect [4]"
        fi
        for privilege in $allPrivileges;do
            rlRun "ipa privilege-del $privilege"
        done
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1009

privilege_find_1010()
{ #test_scenario (negative): --sizelimit;negative;-2,a,abc
    rlPhaseStartTest "privilege_find_1010"
        local testID="privilege_find_1010"
        local tmpout=$TmpDir/privilege_find_1010.$RANDOM.out
        KinitAsAdmin
        local sizelimit_TestValue_Negative="abc" #sizelimit;negative;-2,a,abc
        local expectedErrMsg="invalid 'sizelimit': must be an integer"
        local expectedErrCode=1
        qaRun "ipa privilege-find $testID  --sizelimit=$sizelimit_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [sizelimit]=[$sizelimit_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1010

privilege_find_1011()
{ #test_scenario (positive): --sizelimit;positive;2
    rlPhaseStartTest "privilege_find_1011"
        local testID="privilege_find_1011"
        local tmpout=$TmpDir/privilege_find_1011.$RANDOM.out
        KinitAsAdmin
        local sizelimit_TestValue="2" #sizelimit;positive;2
        total=`ipa privilege-find --sizelimit=$sizelimit_TestValue | grep "Privilege name" | wc -l`
        if [ $total -eq $sizelimit_TestValue ];then
            rlPass "returned total matches as expected [$total]"
        else
            rlFail "expect [$sizelimit_TestValue], but actual [$total] returned"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1011

privilege_find_1012()
{ #test_scenario (boundary): --timelimit;boundary;0
    rlPhaseStartTest "privilege_find_1012"
        local testID="privilege_find_1012"
        local tmpout=$TmpDir/privilege_find_1012.$RANDOM.out
        KinitAsAdmin
        local timelimit_TestValue="0" #timelimit;boundary;0
        local errorMsg=replaceme
        qaRun "ipa privilege-find --timelimit=$timelimit_TestValue " 1 "$errorMsg" "test options:  [timelimit]=[$timelimit_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1012

privilege_find_1013()
{ #test_scenario (negative): --timelimit;negative;-2,a,abc
    rlPhaseStartTest "privilege_find_1013"
        local testID="privilege_find_1013"
        local tmpout=$TmpDir/privilege_find_1013.$RANDOM.out
        KinitAsAdmin
        local timelimit_TestValue_Negative="abc" #timelimit;negative;-2,a,abc
        local expectedErrMsg="invalid 'timelimit': must be an integer"
        local expectedErrCode=1
        qaRun "ipa privilege-find $testID  --timelimit=$timelimit_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [timelimit]=[$timelimit_TestValue_Negative]" 
        timelimit_TestValue_Negative="-2"
        expectedErrMsg="invalid 'timelimit': must be at least 0"
        expectedErrCode=1
        qaRun "ipa privilege-find $testID  --timelimit=$timelimit_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [timelimit]=[$timelimit_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1013

privilege_find_1014()
{ #test_scenario (positive): --timelimit;positive;2
    rlPhaseStartTest "privilege_find_1014"
        local testID="privilege_find_1014"
        local tmpout=$TmpDir/privilege_find_1014.$RANDOM.out
        KinitAsAdmin
        local timelimit_TestValue="2" #timelimit;positive;2
        rlRun "ipa privilege-find --timelimit=$timelimit_TestValue " 0 "test options:  [timelimit]=[$timelimit_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_find_1014

#END OF TEST CASE for [privilege-find]

#############################################
#  test suite: privilege-mod (9 test cases)
#############################################
privilege_mod()
{
    privilege_mod_envsetup
    privilege_mod_1001  #test_scenario (negative test): [--addattr;negative;STR]
    privilege_mod_1002  #test_scenario (positive test): [--addattr;positive;STR]
    privilege_mod_1003  #test_scenario (positive test): [--desc;positive;auto_generated_description_data_$testID]
    privilege_mod_1004  #test_scenario (negative test): [--desc;positive;auto_generated_description_data_$testID --rename;negative;STR]
    privilege_mod_1005  #test_scenario (positive test): [--desc;positive;auto_generated_description_data_$testID --rename;positive;re$testID]
    privilege_mod_1006  #test_scenario (negative test): [--rename;negative;STR]
    privilege_mod_1007  #test_scenario (positive test): [--rename;positive;re$testID]
    privilege_mod_1008  #test_scenario (negative test): [--setattr;negative;STR]
    privilege_mod_1009  #test_scenario (positive test): [--setattr;positive;STR]
    privilege_mod_envcleanup
} #privilege-mod

privilege_mod_envsetup()
{
    rlPhaseStartSetup "privilege_mod_envsetup"
        #environment setup starts here
        createTestPrivilege $testPrivilege 
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

privilege_mod_envcleanup()
{
    rlPhaseStartCleanup "privilege_mod_envcleanup"
        #environment cleanup starts here
        deleteTestPrivilege $testPrivilege
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

privilege_mod_1001()
{ #test_scenario (negative): --addattr;negative;STR
    rlPhaseStartTest "privilege_mod_1001"
        local testID="privilege_mod_1001"
        local tmpout=$TmpDir/privilege_mod_1001.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue_Negative="STR" #addattr;negative;STR
        local expectedErrMsg="invalid 'addattr': Invalid format. Should be name=value"
        local expectedErrCode=1
        qaRun "ipa privilege-mod $testPrivilege --addattr=$addattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [addattr]=[$addattr_TestValue_Negative]" 
        # memberof value should not be able to modified here, use can only do permission operation through privilege-add/remove-permission
        addattr_TestValue_Negative="memberof=$testPermission_addgrp" #addattr;negative;STR
        expectedErrMsg="Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry"
        qaRun "ipa privilege-mod $testPrivilege --addattr=$addattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [addattr]=[$addattr_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_mod_1001

privilege_mod_1002()
{ #test_scenario (positive): --addattr;positive;STR
    rlPhaseStartTest "privilege_mod_1002"
        local testID="privilege_mod_1002"
        local tmpout=$TmpDir/privilege_mod_1002.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue="description=newDescFor$testID" #addattr;positive;STR
        local expectedErrMsg="description: Only one value allowed"
        local expectedErrCode=1
        qaRun "ipa privilege-mod $testPrivilege --addattr=$addattr_TestValue " $expectedErrCode "$expectedErrMsg" "test options:  [addattr]=[$addattr_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_mod_1002

privilege_mod_1003()
{ #test_scenario (positive): --desc;positive;auto_generated_description_data_$testID
    rlPhaseStartTest "privilege_mod_1003"
        local testID="privilege_mod_1003"
        local tmpout=$TmpDir/privilege_mod_1003.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_data_$testID" #desc;positive;auto_generated_description_data_$testID
        rlRun "ipa privilege-mod $testPrivilege --desc=$desc_TestValue " 0 "test options:  [desc]=[$desc_TestValue]" 
        checkPrivilegeInfo $testPrivilege "description" "$desc_TestValue"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_mod_1003

privilege_mod_1004()
{ #test_scenario (negative): --desc;positive;auto_generated_description_data_$testID --rename;negative;STR
    rlPhaseStartTest "privilege_mod_1004"
        local testID="privilege_mod_1004"
        local tmpout=$TmpDir/privilege_mod_1004.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_data_$testID" #desc;positive;auto_generated_description_data_$testID
        local rename_TestValue_Negative="" #rename;negative;STR
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa privilege-mod $testPrivilege  --desc=$desc_TestValue  --rename=$rename_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [rename]=[$rename_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_mod_1004

privilege_mod_1005()
{ #test_scenario (positive): --desc;positive;auto_generated_description_data_$testID --rename;positive;re$testID
    rlPhaseStartTest "privilege_mod_1005"
        local testID="privilege_mod_1005"
        local tmpout=$TmpDir/privilege_mod_1005.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_data_re$testID" #desc;positive;auto_generated_description_data_$testID
        local rename_TestValue="re$testID" #rename;positive;re$testID
        rlRun "ipa privilege-mod $testPrivilege  --desc=$desc_TestValue  --rename=$rename_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [rename]=[$rename_TestValue]" 
        rlRun "ipa privilege-mod $rename_TestValue --rename=$testPrivilege" 0 "rename it back to original"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_mod_1005

privilege_mod_1006()
{ #test_scenario (negative): --rename;negative;STR
    rlPhaseStartTest "privilege_mod_1006"
        local testID="privilege_mod_1006"
        local tmpout=$TmpDir/privilege_mod_1006.$RANDOM.out
        KinitAsAdmin
        local rename_TestValue_Negative="" #rename;negative;STR
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa privilege-mod $testPrivilege --rename=$rename_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [rename]=[$rename_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_mod_1006

privilege_mod_1007()
{ #test_scenario (positive): --rename;positive;re$testID
    rlPhaseStartTest "privilege_mod_1007"
        local testID="privilege_mod_1007"
        local tmpout=$TmpDir/privilege_mod_1007.$RANDOM.out
        KinitAsAdmin
        local rename_TestValue="re$testID" #rename;positive;re$testID
        rlRun "ipa privilege-mod $testPrivilege  --rename=$rename_TestValue " 0 "test options:  [rename]=[$rename_TestValue]"
        rlRun "ipa privilege-mod $rename_TestValue --rename=$testPrivilege" 0 "rename it back to original"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_mod_1007

privilege_mod_1008()
{ #test_scenario (negative): --setattr;negative;STR
    rlPhaseStartTest "privilege_mod_1008"
        local testID="privilege_mod_1008"
        local tmpout=$TmpDir/privilege_mod_1008.$RANDOM.out
        KinitAsAdmin
        local setattr_TestValue_Negative="STR" #setattr;negative;STR
        local expectedErrMsg="invalid 'setattr': Invalid format. Should be name=value"
        local expectedErrCode=1
        qaRun "ipa privilege-mod $testPrivilege  --setattr=$setattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [setattr]=[$setattr_TestValue_Negative]" 
        setattr_TestValue_Negative="memberof=$testPermission_removegrp" #setattr;negative;STR
        expectedErrMsg="Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry"
        expectedErrCode=1
        qaRun "ipa privilege-mod $testPrivilege  --setattr=$setattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [setattr]=[$setattr_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_mod_1008

privilege_mod_1009()
{ #test_scenario (positive): --setattr;positive;STR
    rlPhaseStartTest "privilege_mod_1009"
        local testID="privilege_mod_1009"
        local tmpout=$TmpDir/privilege_mod_1009.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="new_description_$testID"
        local setattr_TestValue="description=$desc_TestValue" #setattr;positive;STR
        rlRun "ipa privilege-mod $testPrivilege --setattr=$setattr_TestValue " 0 "test options:  [setattr]=[$setattr_TestValue]" 
        checkPrivilegeInfo $testPrivilege "description" "$desc_TestValue"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_mod_1009

#END OF TEST CASE for [privilege-mod]

#############################################
#  test suite: privilege-remove_permission (2 test cases)
#############################################
privilege_remove_permission()
{
    privilege_remove_permission_envsetup
    privilege_remove_permission_1001  #test_scenario (negative test): [--permissions;negative;nonListValue]
    privilege_remove_permission_1002  #test_scenario (positive test): [--permissions;positive;read,write,delete,add,all]
    privilege_remove_permission_envcleanup
} #privilege-remove_permission

privilege_remove_permission_envsetup()
{
    rlPhaseStartSetup "privilege_remove_permission_envsetup"
        #environment setup starts here
        createTestPrivilege $testPrivilege
        KinitAsAdmin
        rlRun "ipa permission-add priTest_1 --desc=4_removetest_1 --permissions=read --type=user" 0  "test for priTest_1"
        rlRun "ipa permission-add priTest_2 --desc=4_removetest_2 --permissions=write --type=user" 0 "test for priTest_2"
        rlRun "ipa permission-add priTest_3 --desc=4_removetest_3 --permissions=add --type=user"
        rlRun "ipa privilege-add $testPrivilege --permissions=priTest_1,priTest_2,pri_Test3" 0 "add pritest_1 pritest_2 and pritest_3 to $testPrivilege"
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

privilege_remove_permission_envcleanup()
{
    rlPhaseStartCleanup "privilege_remove_permission_envcleanup"
        #environment cleanup starts here
        deleteTestPrivilege $testPrivilege
        KinitAsAdmin
        rlRun "ipa permission-del priTest_1 " 0 "delete pritest_1"
        rlRun "ipa permission-del priTest_2 " 0 "delete pritest_2"
        rlRun "ipa permission-del priTest_3 " 0 "delete pritest_3"
        Kcleanup
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

privilege_remove_permission_1001()
{ #test_scenario (negative): --permissions;negative;nonListValue
    rlPhaseStartTest "privilege_remove_permission_1001"
        local testID="privilege_remove_permission_1001"
        local tmpout=$TmpDir/privilege_remove_permission_1001.$RANDOM.out
        KinitAsAdmin
        local permissions_TestValue_Negative="nonListValue" #permissions;negative;nonListValue
        local expectedErrMsg="permission not found"
        if ipa privilege-remove-permission $testPrivilege  --permissions=$permissions_TestValue_Negative | grep "$expectedErrMsg";then
            rlPass "remove nonexist permission failed as expected"
        else
            rlFail "no expected error msg found"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_remove_permission_1001

privilege_remove_permission_1002()
{ #test_scenario (positive): --permissions;positive;read,write,delete,add,all
    rlPhaseStartTest "privilege_remove_permission_1002"
        local testID="privilege_remove_permission_1002"
        local tmpout=$TmpDir/privilege_remove_permission_1002.$RANDOM.out
        KinitAsAdmin
        local permissions_TestValue="priTest_1 priTest_2 priTest_3" #permissions;positive;read,write,delete,add,all
        for permission in $permissions_TestValue;do
            rlRun "ipa privilege-remove-permission $testPrivilege  --permissions=$permission" \
                  0 "test options:  [permissions]=[$permission]" 
        done
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_remove_permission_1002

#END OF TEST CASE for [privilege-remov_-permission]

#############################################
#  test suite: privilege-show (1 test cases)
#############################################
privilege_show()
{
    privilege_show_envsetup
    privilege_show_1001  #test_scenario (positive test): [--all --raw --rights]
    privilege_show_envcleanup
} #privilege-show

privilege_show_envsetup()
{
    rlPhaseStartSetup "privilege_show_envsetup"
        #environment setup starts here
        createTestPrivilege $testPrivilege
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

privilege_show_envcleanup()
{
    rlPhaseStartCleanup "privilege_show_envcleanup"
        #environment cleanup starts here
        deleteTestPrivilege $testPrivilege
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

privilege_show_1001()
{ #test_scenario (positive): --all --raw --rights
    rlPhaseStartTest "privilege_show_1001"
        local testID="privilege_show_1001"
        local tmpout=$TmpDir/privilege_show_1001.$RANDOM.out
        KinitAsAdmin
        ipa privilege-show $testPrivilege --all --raw --rights > $tmpout
        if grep "objectclass" $tmpout 2>&1;then
            rlPass "get objectclass info"
        else
            rlFail "no objectclass info found"
        fi
        if grep "attributelevelrights" $tmpout 2>&1;then
            rlPass "get rights info"
        else
            rlFail "no rights info found"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #privilege_show_1001

#END OF TEST CASE for [privilege-show]

role()
{
    role_add
    role_add_member
    role_add_privilege
    role_del
    role_find
    role_mod
    role_remove_member
    role_remove_privilege
    role_show
} #role

#############################################
#  test suite: role-add (5 test cases)
#############################################
role_add()
{
    role_add_envsetup
    role_add_1001  #test_scenario (negative test): [--addattr;negative;STR]
    role_add_1002  #test_scenario (positive test): [--addattr;positive;STR]
    role_add_1003  #test_scenario (positive test): [--desc;positive;auto generated description data]
    role_add_1004  #test_scenario (negative test): [--setattr;negative;STR]
    role_add_1005  #test_scenario (positive test): [--setattr;positive;STR]
    role_add_envcleanup
} #role-add

role_add_envsetup()
{
    rlPhaseStartSetup "role_add_envsetup"
        #environment setup starts here
        KinitAsAdmin
        addRoleTestAccounts
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

role_add_envcleanup()
{
    rlPhaseStartCleanup "role_add_envcleanup"
        #environment cleanup starts here
        KinitAsAdmin
        deleteRoleTestAccounts
        Kcleanup
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

role_add_1001()
{ #test_scenario (negative): --addattr;negative;STR
    rlPhaseStartTest "role_add_1001"
        local testID="role_add_1001"
        local tmpout=$TmpDir/role_add_1001.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue_Negative="STR" #addattr;negative;STR
        local expectedErrMsg="invalid 'addattr': Invalid format. Should be name=value"
        local expectedErrCode=1
        qaRun "ipa role-add $testID --desc=4_$testID  --addattr=$addattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [addattr]=[$addattr_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_1001

role_add_1002()
{ #test_scenario (positive): --addattr;positive;STR
    rlPhaseStartTest "role_add_1002"
        local testID="role_add_1002"
        local tmpout=$TmpDir/role_add_1002.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue="" #addattr;negative;STR
        rlRun "ipa role-add $testID --desc=4_$testID  --addattr=$addattr_TestValue" 0 "empty value in addattr will be ignored " 
        rlRun "ipa role-del $testID" 0 "delete rold: $testID to clean up env"

        addattr_TestValue="member=uid=$testUser001,cn=users,cn=accounts,$testDC" #addattr;positive;STR
        rlRun "ipa role-add $testID --desc=4_$testID  --addattr=$addattr_TestValue " 0 "test options:  [addattr]=[$addattr_TestValue]" 
        checkRoleInfo $testID "Member users" "$testUser001"
        rlRun "ipa role-del $testID" 0 "delete rold: $testID to clean up env"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_1002

role_add_1003()
{ #test_scenario (positive): --desc;positive;auto generated description data
    rlPhaseStartTest "role_add_1003"
        local testID="role_add_1003"
        local tmpout=$TmpDir/role_add_1003.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_data_$testID" #desc;positive;auto generated description data
        rlRun "ipa role-add $testID  --desc=$desc_TestValue " 0 "test options:  [desc]=[$desc_TestValue]" 
        rlRun "ipa role-del $testID"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_1003

role_add_1004()
{ #test_scenario (negative): --setattr;negative;STR
    rlPhaseStartTest "role_add_1004"
        local testID="role_add_1004"
        local tmpout=$TmpDir/role_add_1004.$RANDOM.out
        KinitAsAdmin
        local setattr_TestValue_Negative="desc=newDescValue" #setattr;negative;STR
        local expectedErrMsg="attribute \"desc\" not allowed"
        local expectedErrCode=1
        qaRun "ipa role-add $testID --desc=4_$testID  --setattr=$setattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [setattr]=[$setattr_TestValue_Negative]" 

        setattr_TestValue_Negative="member=uid=NoSuchUser$RANDOM,cn=users,cn=accounts,$testDC" #setattr;negative;STR
        expectedErrMsg=replace_me
        expectedErrCode=1
        qaRun "ipa role-add $testID  --desc=4_$testID --setattr=$setattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [setattr]=[$setattr_TestValue_Negative]" 
        ipa role-del $testID # cleanup env

        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_1004

role_add_1005()
{ #test_scenario (positive): --setattr;positive;STR
    rlPhaseStartTest "role_add_1005"
        local testID="role_add_1005"
        local tmpout=$TmpDir/role_add_1005.$RANDOM.out
        KinitAsAdmin
        local setattr_TestValue="" #setattr;negative;STR
        rlRun "ipa role-add $testID --desc=4_$testID  --setattr=$setattr_TestValue_Negative " 0 "empty setaddr value will be ignored"
        rlRun "ipa role-del $testID" 0 "clean up role: $testID"

        setattr_TestValue="member=cn=$testGroup,cn=groups,cn=accounts,$testDC" #setattr;positive;STR
        rlRun "ipa role-add $testID --desc=4_$testID  --setattr=$setattr_TestValue " 0 "test options:  [setattr]=[$setattr_TestValue]" 
        checkRoleInfo $testID "member groups" "$testGroup"
        rlRun "ipa role-del $testID" 0 "clean up role: $testID"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_1005

#END OF TEST CASE for [role-add]

#############################################
#  test suite: role-add_member (7 test cases)
#############################################
role_add_member()
{
    role_add_member_envsetup
    role_add_member_1001  #test_scenario (negative test): [--groups;negative;nonListValue]
    role_add_member_1002  #test_scenario (negative test): [--groups;negative;nonListValue --users;positive;LIST]
    role_add_member_1003  #test_scenario (positive test): [--groups;positive;LIST]
    role_add_member_1004  #test_scenario (negative test): [--groups;positive;LIST --users;negative;nonListValue]
    role_add_member_1005  #test_scenario (positive test): [--groups;positive;LIST --users;positive;LIST]
    role_add_member_1006  #test_scenario (negative test): [--users;negative;nonListValue]
    role_add_member_1007  #test_scenario (positive test): [--users;positive;LIST]
    role_add_member_envcleanup
} #role-add_member

role_add_member_envsetup()
{
    rlPhaseStartSetup "role_add_member_envsetup"
        #environment setup starts here
        KinitAsAdmin
        addRoleTestAccounts
        rlRun "ipa role-add $testRole --desc=role_for_role_test" 0 "add test role [$testRole]"
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

role_add_member_envcleanup()
{
    rlPhaseStartCleanup "role_add_member_envcleanup"
        #environment cleanup starts here
        KinitAsAdmin
        deleteRoleTestAccounts
        rlRun "ipa role-del $testRole" 0 "delete test role [$testRole]"
        Kcleanup
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

role_add_member_1001()
{ #test_scenario (negative): --groups;negative;nonListValue
    rlPhaseStartTest "role_add_member_1001"
        local testID="role_add_member_1001"
        local tmpout=$TmpDir/role_add_member_1001.$RANDOM.out
        KinitAsAdmin
        local groups_TestValue_Negative="nonListValue" #groups;negative;nonListValue
        ipa role-add-member $testRole  --groups=$groups_TestValue_Negative 2>&1 > $tmpout
        if grep "group: $groups_TestValue_Negative: no such entry" $tmpout 2>&1 >/dev/null;then
            rlPass "add non-exist member failed as expected"
        else
            rlFail "no expected error msg found"
            echo "============output=============="
            cat $tmpout
            echo "================================"
        fi 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_member_1001

role_add_member_1002()
{ #test_scenario (negative): --groups;negative;nonListValue --users;positive;LIST
    rlPhaseStartTest "role_add_member_1002"
        local testID="role_add_member_1002"
        local tmpout=$TmpDir/role_add_member_1002.$RANDOM.out
        KinitAsAdmin
        local groups_TestValue_Negative="nonListValue" #groups;negative;nonListValue
        local users_TestValue="$testUser003" #users;positive;LIST
        ipa role-add-member $testRole  --groups=$groups_TestValue_Negative  --users=$users_TestValue 2>&1 >$tmpout
        if grep "group: $groups_TestValue_Negative: no such entry" $tmpout 2>&1 >/dev/null;then
            rlPass "add non-exist member failed as expected"
        else
            rlFail "no expected error msg found"
            echo "============output=============="
            cat $tmpout
            echo "================================"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_member_1002

role_add_member_1003()
{ #test_scenario (positive): --groups;positive;LIST
    rlPhaseStartTest "role_add_member_1003"
        local testID="role_add_member_1003"
        local tmpout=$TmpDir/role_add_member_1003.$RANDOM.out
        KinitAsAdmin
        local groups_TestValue="$testGroup" #groups;positive;LIST
        rlRun "ipa role-add-member $testRole  --groups=$groups_TestValue " 0 "add [groups]=[$groups_TestValue] to role: [$testRole]" 
        rlRun "ipa role-remove-member $testRole  --groups=$groups_TestValue " 0 "restore env: remove [$groups_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_member_1003

role_add_member_1004()
{ #test_scenario (negative): --groups;positive;LIST --users;negative;nonListValue
    rlPhaseStartTest "role_add_member_1004"
        local testID="role_add_member_1004"
        local tmpout=$TmpDir/role_add_member_1004.$RANDOM.out
        KinitAsAdmin
        createTestRole $testID
        local groups_TestValue="$testGroup" #groups;positive;LIST
        local users_TestValue_Negative="nonListValue" #users;negative;nonListValue
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        ipa role-add-member $testID --groups=$groups_TestValue  --users=$users_TestValue_Negative 2>&1 > $tmpout
        if grep "user: $users_TestValue_Negative: no such entry" $tmpout 2>&1 >/dev/null;then
            rlPass "add non-exist user member failed as expected"
        else
            rlFail "no expected error msg found"
            echo "============output=============="
            cat $tmpout
            echo "================================"
        fi
        deleteTestRole $testID
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_member_1004

role_add_member_1005()
{ #test_scenario (positive): --groups;positive;LIST --users;positive;LIST
    rlPhaseStartTest "role_add_member_1005"
        local testID="role_add_member_1005"
        local tmpout=$TmpDir/role_add_member_1005.$RANDOM.out
        KinitAsAdmin
        createTestRole $testID
        local groups_TestValue="$testGroup" #groups;positive;LIST
        local users_TestValue="$testUser003" #users;positive;LIST
        rlRun "ipa role-add-member $testID  --groups=$groups_TestValue  --users=$users_TestValue " 0 "test options:  [groups]=[$groups_TestValue] [users]=[$users_TestValue]" 
        checkRoleInfo $testRole "Member group" "$groups_TestValue"
        checkRoleInfo $testRole "Member user" "$users_TestValue"
        deleteTestRole $testID
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_member_1005

role_add_member_1006()
{ #test_scenario (negative): --users;negative;nonListValue
    rlPhaseStartTest "role_add_member_1006"
        local testID="role_add_member_1006"
        local tmpout=$TmpDir/role_add_member_1006.$RANDOM.out
        KinitAsAdmin
        createTestRole $testID
        local users_TestValue_Negative="nonListValue" #users;negative;nonListValue
        local expectedErrMsg="role not found"
        local expectedErrCode=1
        ipa role-add-member $testID  --users=$users_TestValue_Negative 2>&1 >$tmpout
        if grep "user: $users_TestValue_Negative: no such entry" $tmpout 2>&1 >/dev/null;then
            rlPass "non-exist user can not add as member, test pass"
        else
            rlFail "non-exist user added as member, test failed"
        fi
        deleteTestRole $testID
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_member_1006

role_add_member_1007()
{ #test_scenario (positive): --users;positive;LIST
    rlPhaseStartTest "role_add_member_1007"
        local testID="role_add_member_1007"
        local tmpout=$TmpDir/role_add_member_1007.$RANDOM.out
        KinitAsAdmin
        createTestRole $testID
        local users_TestValue="$testUser001" #users;positive;LIST
        rlRun "ipa role-add-member $testID  --users=$users_TestValue " 0 "test options:  [users]=[$users_TestValue]" 
        checkRoleInfo $testID "Member users" "$users_TestValue"
        deleteTestRole $testID
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_member_1007

#END OF TEST CASE for [role-add-member]

#############################################
#  test suite: role-add_privilege (2 test cases)
#############################################
role_add_privilege()
{
    role_add_privilege_envsetup
    role_add_privilege_1001  #test_scenario (negative test): [--privileges;negative;nonListValue]
    role_add_privilege_1002  #test_scenario (positive test): [--privileges;positive;LIST]
    role_add_privilege_envcleanup
} #role-add-privilege

role_add_privilege_envsetup()
{
    rlPhaseStartSetup "role_add_privilege_envsetup"
        #environment setup starts here
        createTestPrivilege $testPrivilege
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

role_add_privilege_envcleanup()
{
    rlPhaseStartCleanup "role_add_privilege_envcleanup"
        #environment cleanup starts here
        deleteTestPrivilege $testPrivilege
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

role_add_privilege_1001()
{ #test_scenario (negative): --privileges;negative;nonListValue
    rlPhaseStartTest "role_add_privilege_1001"
        local testID="role_add_privilege_1001"
        local tmpout=$TmpDir/role_add_privilege_1001.$RANDOM.out
        KinitAsAdmin
        createTestRole $testID
        local privileges_TestValue_Negative="nonListValue" #privileges;negative;nonListValue
        local expectedErrMsg="privilege not found"
        local expectedErrCode=1
        ipa role-add-privilege $testID  --privileges=$privileges_TestValue_Negative 2>&1 >$tmpout
        if grep -i "$expectedErrMsg" $tmpout 2>&1 > /dev/null ;then
            rlPass "expected error msg matches"
        else
            rlFail "expected error msg not found"
            echo "-----------output--------------"
            cat $tmpout
            echo "==============================="
        fi
        deleteTestRole $testID
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_privilege_1001

role_add_privilege_1002()
{ #test_scenario (positive): --privileges;positive;LIST
    rlPhaseStartTest "role_add_privilege_1002"
        local testID="role_add_privilege_1002"
        local tmpout=$TmpDir/role_add_privilege_1002.$RANDOM.out
        KinitAsAdmin
        createTestRole $testID
        local privileges_TestValue="$testPrivilege" #privileges;positive;LIST
        rlRun "ipa role-add-privilege $testID  --privileges=$privileges_TestValue " 0 "test options:  [privileges]=[$privileges_TestValue]" 
        checkRoleInfo $testID "Privileges" "$testPrivilege"
        deleteTestRole $testID
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_add_privilege_1002

#END OF TEST CASE for [role-add-privilege]

#############################################
#  test suite: role-del (1 test cases)
#############################################
role_del()
{
    role_del_envsetup
    role_del_1001  #test_scenario (positive test): [--continue]
    role_del_envcleanup
} #role-del

role_del_envsetup()
{
    rlPhaseStartSetup "role_del_envsetup"
        #environment setup starts here
        rlLog "create roles for delete test: del001, del002, del003, del004"
        KinitAsAdmin
        createTestRole "del001"
        createTestRole "del002"
        createTestRole "del003"
        createTestRole "del004"
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

role_del_envcleanup()
{
    rlPhaseStartCleanup "role_del_envcleanup"
        #environment cleanup starts here
        rlPass "no special cleanup necessary if role_del_1001 passed"
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

role_del_1001()
{ #test_scenario (positive): --continue
    rlPhaseStartTest "role_del_1001"
        local testID="role_del_1001"
        local tmpout=$TmpDir/role_del_1001.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa role-del --continue $testID" 0 "test options: " 0 "role [$role] Does not exist"
        rlRun "ipa role-del --continue del001 $testID" 0 "test options: " 0 "role [$role] Does not exist, after existing one"
        rlRun "ipa role-del --continue $testID del002" 0 "test options: " 0 "role [$role] Does not exist, before existing one"
        rlRun "ipa role-del --continue del003 $testID del004 " 0 "test options: " 0 "role [$role] Does not exist, middle of existing ones"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_del_1001

#END OF TEST CASE for [role-del]

#############################################
#  test suite: role-find (13 test cases)
#############################################
role_find()
{
    role_find_envsetup
    role_find_1001  #test_scenario (positive test): [--desc;positive;auto generated description data]
    role_find_1002  #test_scenario (negative test): [--desc;positive;auto generated description data --name;negative;STR --sizelimit;positive;INT --timelimit;positive;INT]
    role_find_1003  #test_scenario (negative test): [--desc;positive;auto generated description data --name;positive;STR --sizelimit;negative;INT --timelimit;positive;INT]
    role_find_1004  #test_scenario (negative test): [--desc;positive;auto generated description data --name;positive;STR --sizelimit;positive;INT --timelimit;negative;INT]
    role_find_1005  #test_scenario (positive test): [--desc;positive;auto generated description data --name;positive;STR --sizelimit;positive;INT --timelimit;positive;INT]
    role_find_1006  #test_scenario (negative test): [--name;negative;STR]
    role_find_1007  #test_scenario (positive test): [--name;positive;STR]
    role_find_1008  #test_scenario (boundary test): [--sizelimit;boundary;INT]
    role_find_1009  #test_scenario (negative test): [--sizelimit;negative;INT]
    role_find_1010  #test_scenario (positive test): [--sizelimit;positive;INT]
    role_find_1011  #test_scenario (boundary test): [--timelimit;boundary;INT]
    role_find_1012  #test_scenario (negative test): [--timelimit;negative;INT]
    role_find_1013  #test_scenario (positive test): [--timelimit;positive;INT]
    role_find_envcleanup
} #role-find

role_find_envsetup()
{
    rlPhaseStartSetup "role_find_envsetup"
        #environment setup starts here
        rlLog "create roles for delete test: findrole001, findrole002, findrole003, findrole004"
        KinitAsAdmin
        createTestRole "findrole001"
        createTestRole "findrole002"
        createTestRole "findrole003"
        createTestRole "findrole004"
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

role_find_envcleanup()
{
    rlPhaseStartCleanup "role_find_envcleanup"
        #environment cleanup starts here
        KinitAsAdmin
        deleteTestRole "findrole001"
        deleteTestRole "findrole002"
        deleteTestRole "findrole003"
        deleteTestRole "findrole004"
        Kcleanup
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

role_find_1001()
{ #test_scenario (positive): --desc;positive;auto generated description data
    rlPhaseStartTest "role_find_1001"
        local testID="role_find_1001"
        local tmpout=$TmpDir/role_find_1001.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="4_findrole001" #desc;positive;auto generated description data
        total=`ipa role-find --desc=$desc_TestValue | grep "role\|roles matched" | cut -d" " -f1`
        if [ "$total" = "1" ];then
            rlPass "find one role as expected"
        else
            rlFail "expect 1 but get [$total]"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1001

role_find_1002()
{ #test_scenario (negative): --desc;positive;auto generated description data --name;negative;STR --sizelimit;positive;INT --timelimit;positive;INT
    rlPhaseStartTest "role_find_1002"
        local testID="role_find_1002"
        local tmpout=$TmpDir/role_find_1002.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="4_findrole002" #desc;positive;auto generated description data
        local name_TestValue_Negative="NoSuchRole" #name;negative;STR
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local timelimit_TestValue="2" #timelimit;positive;INT
        total=`ipa role-find $name_TestValue_Negative --desc=$desc_TestValue  --name=$name_TestValue_Negative  --sizelimit=$sizelimit_TestValue  --timelimit=$timelimit_TestValue  | grep "role\|roles matched" | cut -d" " -f1`
        if [ "$total" = "0" ];then
            rlPass "find 0 role as expected"
        else
            rlFail "expect 0 but get [$total]"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1002

role_find_1003()
{ #test_scenario (negative): --desc;positive;auto generated description data --name;positive;STR --sizelimit;negative;INT --timelimit;positive;INT
    rlPhaseStartTest "role_find_1003"
        local testID="role_find_1003"
        local tmpout=$TmpDir/role_find_1003.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="4_findrole003" #desc;positive;auto generated description data
        local name_TestValue="findrole003" #name;positive;STR
        local sizelimit_TestValue_Negative="abc" #sizelimit;negative;INT
        local timelimit_TestValue="2" #timelimit;positive;INT
        local expectedErrMsg="invalid 'sizelimit': must be an integer"
        qaRun "ipa role-find --desc=$desc_TestValue  --name=$name_TestValue  --sizelimit=$sizelimit_TestValue_Negative  --timelimit=$timelimit_TestValue" $tmpout 1 "$expectedErrMsg" "negative test case: sizelimit_TestValue_Negative=abc"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1003

role_find_1004()
{ #test_scenario (negative): --desc;positive;auto generated description data --name;positive;STR --sizelimit;positive;INT --timelimit;negative;INT
    rlPhaseStartTest "role_find_1004"
        local testID="role_find_1004"
        local tmpout=$TmpDir/role_find_1004.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="4_findrole004" #desc;positive;auto generated description data
        local name_TestValue="findrole004" #name;positive;STR
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local timelimit_TestValue_Negative="abc" #timelimit;negative;INT
        local expectedErrMsg="invalid 'timelimit': must be an integer"
        qaRun "ipa role-find --desc=$desc_TestValue  --name=$name_TestValue  --sizelimit=$sizelimit_TestValue  --timelimit=$timelimit_TestValue_Negative" $tmpout  1 "$expectedErrMsg" "negative test: timelimit_TestValue_Negative=abc"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1004

role_find_1005()
{ #test_scenario (positive): --desc;positive;auto generated description data --name;positive;STR --sizelimit;positive;INT --timelimit;positive;INT
    rlPhaseStartTest "role_find_1005"
        local testID="role_find_1005"
        local tmpout=$TmpDir/role_find_1005.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="4_findrole001" #desc;positive;auto generated description data
        local name_TestValue="findrole001" #name;positive;STR
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        local timelimit_TestValue="2" #timelimit;positive;INT
        total=`ipa role-find --desc=$desc_TestValue  --name=$name_TestValue  --sizelimit=$sizelimit_TestValue  --timelimit=$timelimit_TestValue | grep "role\|roles matched" | cut -d" " -f1 `
        if [ "$total" = "1" ];then
            rlPass "find 1 role as expected"
        else
            rlFail "expect 1 but get [$total]"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1005

role_find_1006()
{ #test_scenario (negative): --name;negative;STR
    rlPhaseStartTest "role_find_1006"
        local testID="role_find_1006"
        local tmpout=$TmpDir/role_find_1006.$RANDOM.out
        KinitAsAdmin
        local name_TestValue_Negative="" #name;negative;STR
        local expectedErrMsg="name option requires an argument"
        local expectedErrCode=2
        qaRun "ipa role-find --name" "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [name]=[$name_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1006

role_find_1007()
{ #test_scenario (positive): --name;positive;STR
    rlPhaseStartTest "role_find_1007"
        local testID="role_find_1007"
        local tmpout=$TmpDir/role_find_1007.$RANDOM.out
        KinitAsAdmin
        local name_TestValue="findrole002" #name;positive;STR
        total=`ipa role-find --name=$name_TestValue | grep "role\|roles matched" | cut -d" " -f1 `
        if [ "$total" = "1" ];then
            rlPass "find 1 role as expected"
        else
            rlFail "expect 1 but get [$total]"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1007

role_find_1008()
{ #test_scenario (boundary): --sizelimit;boundary;INT
    rlPhaseStartTest "role_find_1008"
        local testID="role_find_1008"
        local tmpout=$TmpDir/role_find_1008.$RANDOM.out
        KinitAsAdmin
        local sizelimit_TestValue="0" #sizelimit;boundary;INT
        total=`ipa role-find findrole00 --sizelimit=$sizelimit_TestValue | grep "role\|roles matched" | cut -d" " -f1`
        if [ "$total" = "4" ];then
            rlPass "sizelimit=0 will return all matched records"
        else
            rlFail "not all matched records returned when it should, acutal[$total], expected: 4"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1008

role_find_1009()
{ #test_scenario (negative): --sizelimit;negative;INT
    rlPhaseStartTest "role_find_1009"
        local testID="role_find_1009"
        local tmpout=$TmpDir/role_find_1009.$RANDOM.out
        KinitAsAdmin
        local sizelimit_TestValue_Negative="abc" #sizelimit;negative;INT
        local expectedErrMsg="invalid 'sizelimit': must be an integer"
        local expectedErrCode=1
        qaRun "ipa role-find --sizelimit=$sizelimit_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [sizelimit]=[$sizelimit_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1009

role_find_1010()
{ #test_scenario (positive): --sizelimit;positive;INT
    rlPhaseStartTest "role_find_1010"
        local testID="role_find_1010"
        local tmpout=$TmpDir/role_find_1010.$RANDOM.out
        KinitAsAdmin
        local sizelimit_TestValue="2" #sizelimit;positive;INT
        total=`ipa role-find findrole --sizelimit=$sizelimit_TestValue | grep "role\|roles matched" | cut -d" " -f1`
        if [ "$total" = "$sizelimit_TestValue" ];then
            rlPass "find $sizelimit_TestValue role as expected"
        else
            rlFail "expect $sizelimit_TestValue but get [$total]"
        fi

        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1010

role_find_1011()
{ #test_scenario (boundary): --timelimit;boundary;INT
    rlPhaseStartTest "role_find_1011"
        local testID="role_find_1011"
        local tmpout=$TmpDir/role_find_1011.$RANDOM.out
        KinitAsAdmin
        local timelimit_TestValue="0" #timelimit;boundary;INT
        rlRun "ipa role-find --timelimit=$timelimit_TestValue " 0 "test options:  [timelimit]=[$timelimit_TestValue]" 
        rlFail "don't know what is right behave when timelimit=boundary, Rob says this should be disallowed in new build"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1011

role_find_1012()
{ #test_scenario (negative): --timelimit;negative;INT
    rlPhaseStartTest "role_find_1012"
        local testID="role_find_1012"
        local tmpout=$TmpDir/role_find_1012.$RANDOM.out
        KinitAsAdmin
        local timelimit_TestValue_Negative="abc" #timelimit;negative;INT
        local expectedErrMsg="invalid 'timelimit': must be an integer"
        local expectedErrCode=1
        qaRun "ipa role-find $testID  --timelimit=$timelimit_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [timelimit]=[$timelimit_TestValue_Negative]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1012

role_find_1013()
{ #test_scenario (positive): --timelimit;positive;INT
    rlPhaseStartTest "role_find_1013"
        local testID="role_find_1013"
        local tmpout=$TmpDir/role_find_1013.$RANDOM.out
        KinitAsAdmin
        local timelimit_TestValue="2" #timelimit;positive;INT
        total=`ipa role-find findrole --timelimit=$timelimit_TestValue | grep "role\|roles matched" | cut -d" " -f1`
        if [ "$total" = "4" ];then
            rlPass "find 4 role as expected"
        else
            rlFail "expect 4 but get [$total]"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_find_1013

#END OF TEST CASE for [role-find]

#############################################
#  test suite: role-mod (9 test cases)
#############################################
role_mod()
{
    role_mod_envsetup
    role_mod_1001  #test_scenario (negative test): [--addattr;negative;STR]
    role_mod_1002  #test_scenario (positive test): [--addattr;positive;STR]
    role_mod_1003  #test_scenario (positive test): [--desc;positive;auto generated description data]
    role_mod_1004  #test_scenario (negative test): [--desc;positive;auto generated description data --rename;negative;STR]
    role_mod_1005  #test_scenario (positive test): [--desc;positive;auto generated description data --rename;positive;STR]
    role_mod_1006  #test_scenario (negative test): [--rename;negative;STR]
    role_mod_1007  #test_scenario (positive test): [--rename;positive;STR]
    role_mod_1008  #test_scenario (negative test): [--setattr;negative;STR]
    role_mod_1009  #test_scenario (positive test): [--setattr;positive;STR]
    role_mod_envcleanup
} #role-mod

role_mod_envsetup()
{
    rlPhaseStartSetup "role_mod_envsetup"
        #environment setup starts here
        KinitAsAdmin
        createTestRole $testRole
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

role_mod_envcleanup()
{
    rlPhaseStartCleanup "role_mod_envcleanup"
        #environment cleanup starts here
        KinitAsAdmin
        deleteTestRole $testRole
        Kcleanup
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

role_mod_1001()
{ #test_scenario (negative): --addattr;negative;STR
    rlPhaseStartTest "role_mod_1001"
        local testID="role_mod_1001"
        local tmpout=$TmpDir/role_mod_1001.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue_Negative="STR" #addattr;negative;STR
        local expectedErrMsg="invalid 'addattr': Invalid format. Should be name=value"
        local expectedErrCode=1
        qaRun "ipa role-mod $testRole  --addattr=$addattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [addattr]=[$addattr_TestValue_Negative]" 

        addattr_TestValue_Negative="description=additionalDesc" #addattr;negative;STR
        expectedErrMsg="Only one value allowed"
        expectedErrCode=1
        qaRun "ipa role-mod $testRole  --addattr=$addattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [addattr]=[$addattr_TestValue_Negative]" 

        addattr_TestValue_Negative="memberof=$testPermission_addgrp" #addattr;negative;STR
        expectedErrMsg="Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry"
        expectedErrCode=1
        qaRun "ipa role-mod $testRole  --addattr=$addattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [addattr]=[$addattr_TestValue_Negative]" 

        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_mod_1001

role_mod_1002()
{ #test_scenario (positive): --addattr;positive;STR
    rlPhaseStartTest "role_mod_1002"
        local testID="role_mod_1002"
        local tmpout=$TmpDir/role_mod_1002.$RANDOM.out
        KinitAsAdmin
        local addattr_TestValue="STR" #addattr;positive;STR
        #rlRun "ipa role-mod $testID  --addattr=$addattr_TestValue " 0 "test options:  [addattr]=[$addattr_TestValue]" 
        rlPass "no positive scenario found for this, just make it pass"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_mod_1002

role_mod_1003()
{ #test_scenario (positive): --desc;positive;auto generated description data
    rlPhaseStartTest "role_mod_1003"
        local testID="role_mod_1003"
        local tmpout=$TmpDir/role_mod_1003.$RANDOM.out
        KinitAsAdmin
        createTestRole $testID
        local desc_TestValue="auto_generated_description_data_$testID" #desc;positive;auto generated description data
        rlRun "ipa role-mod $testID  --desc=$desc_TestValue " 0 "test options:  [desc]=[$desc_TestValue]" 
        checkRoleInfo $testID "description" "$desc_TestValue"
        deleteTestRole $testID
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_mod_1003

role_mod_1004()
{ #test_scenario (negative): --desc;positive;auto generated description data --rename;negative;STR
    rlPhaseStartTest "role_mod_1004"
        local testID="role_mod_1004"
        local tmpout=$TmpDir/role_mod_1004.$RANDOM.out
        KinitAsAdmin
        createTestRole $testID
        local desc_TestValue="auto_generated_description_data_$testID" #desc;positive;auto generated description data
        local rename_TestValue_Negative="" #rename;negative;STR
        local expectedErrMsg="No sure about exact error msg: https://bugzilla.redhat.com/show_bug.cgi?id=672711"
        local expectedErrCode=1
        qaRun "ipa role-mod $testID  --desc=$desc_TestValue  --rename=$rename_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [desc]=[$desc_TestValue] [rename]=[$rename_TestValue_Negative]" 
        deleteTestRole $testID
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_mod_1004

role_mod_1005()
{ #test_scenario (positive): --desc;positive;auto generated description data --rename;positive;STR
    rlPhaseStartTest "role_mod_1005"
        local testID="role_mod_1005"
        local tmpout=$TmpDir/role_mod_1005.$RANDOM.out
        KinitAsAdmin
        local desc_TestValue="auto_generated_description_data_$testID" #desc;positive;auto generated description data
        local rename_TestValue="re_$testID" #rename;positive;STR
        rlRun "ipa role-mod $testRole  --desc=$desc_TestValue  --rename=$rename_TestValue " 0 "test options:  [desc]=[$desc_TestValue] [rename]=[$rename_TestValue]" 
        rlRun "ipa role-mod $rename_TestValue --rename=$testRole" 0 "rename it back to [$testRole]"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_mod_1005

role_mod_1006()
{ #test_scenario (negative): --rename;negative;STR
    rlPhaseStartTest "role_mod_1006"
        local testID="role_mod_1006"
        local tmpout=$TmpDir/role_mod_1006.$RANDOM.out
        KinitAsAdmin
        createTestRole $testID
        local rename_TestValue_Negative="" #rename;negative;STR
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa role-mod $testID  --rename=$rename_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [rename]=[$rename_TestValue_Negative]" 
        deleteTestRole $testID
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_mod_1006

role_mod_1007()
{ #test_scenario (positive): --rename;positive;STR
    rlPhaseStartTest "role_mod_1007"
        local testID="role_mod_1007"
        local tmpout=$TmpDir/role_mod_1007.$RANDOM.out
        KinitAsAdmin
        local rename_TestValue="re_$testID" #rename;positive;STR
        rlRun "ipa role-mod $testRole --rename=$rename_TestValue" 0 "test options:  [rename]=[$rename_TestValue]" 
        rlRun "ipa role-mod $rename_TestValue --rename=$testRole" 0 "test options:  rename back to [$testRole]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_mod_1007

role_mod_1008()
{ #test_scenario (negative): --setattr;negative;STR
    rlPhaseStartTest "role_mod_1008"
        local testID="role_mod_1008"
        local tmpout=$TmpDir/role_mod_1008.$RANDOM.out
        KinitAsAdmin
        createTestRole $testID
        local setattr_TestValue_Negative="STR" #setattr;negative;STR
        local expectedErrMsg="invalid 'setattr': Invalid format. Should be name=value"
        local expectedErrCode=1
        qaRun "ipa role-mod $testID  --setattr=$setattr_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [setattr]=[$setattr_TestValue_Negative]" 
        deleteTestRole $testID
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_mod_1008

role_mod_1009()
{ #test_scenario (positive): --setattr;positive;STR
    rlPhaseStartTest "role_mod_1009"
        local testID="role_mod_1009"
        local tmpout=$TmpDir/role_mod_1009.$RANDOM.out
        KinitAsAdmin
        local setattr_TestValue="description=newDescription_$testID" #setattr;positive;STR
        rlRun "ipa role-mod $testRole  --setattr=$setattr_TestValue " 0 "test options:  [setattr]=[$setattr_TestValue]" 
        checkRoleInfo $testRole "description" "newDescription_$testID"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_mod_1009

#END OF TEST CASE for [role-mod]

#############################################
#  test suite: role-remove_member (7 test cases)
#############################################
role_remove_member()
{
    role_remove_member_envsetup
    role_remove_member_1001  #test_scenario (negative test): [--groups;negative;nonListValue]
    role_remove_member_1002  #test_scenario (negative test): [--groups;negative;nonListValue --users;positive;LIST]
    role_remove_member_1003  #test_scenario (positive test): [--groups;positive;LIST]
    role_remove_member_1004  #test_scenario (negative test): [--groups;positive;LIST --users;negative;nonListValue]
    role_remove_member_1005  #test_scenario (positive test): [--groups;positive;LIST --users;positive;LIST]
    role_remove_member_1006  #test_scenario (negative test): [--users;negative;nonListValue]
    role_remove_member_1007  #test_scenario (positive test): [--users;positive;LIST]
    role_remove_member_envcleanup
} #role-remove_member

role_remove_member_envsetup()
{
    rlPhaseStartSetup "role_remove_member_envsetup"
        #environment setup starts here
        KinitAsAdmin
        addRoleTestAccounts
        rlRun "ipa role-add $testRole --desc=role_for_role_test" 0 "add test role [$testRole]"
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

role_remove_member_envcleanup()
{
    rlPhaseStartCleanup "role_remove_member_envcleanup"
        #environment cleanup starts here
        KinitAsAdmin
        deleteRoleTestAccounts
        rlRun "ipa role-del $testRole" 0 "delete test role [$testRole]"
        rlRun "ipa role-add-member $testRole --groups=$testGroup --users=$testUser003"
        Kcleanup
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

role_remove_member_1001()
{ #test_scenario (negative): --groups;negative;nonListValue
    rlPhaseStartTest "role_remove_member_1001"
        local testID="role_remove_member_1001"
        local tmpout=$TmpDir/role_remove_member_1001.$RANDOM.out
        KinitAsAdmin
        local groups_TestValue_Negative="nonListValue" #groups;negative;nonListValue
        ipa role-remove-member $testRole  --groups=$groups_TestValue_Negative 2>&1 > $tmpout
        if grep "group: $groups_TestValue_Negative: This entry is not a member" $tmpout 2>&1 >/dev/null;then
            rlPass "expected error msg matches"
        else
            rlFail "expected error msg does not match"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_remove_member_1001

role_remove_member_1002()
{ #test_scenario (negative): --groups;negative;nonListValue --users;positive;LIST
    rlPhaseStartTest "role_remove_member_1002"
        local testID="role_remove_member_1002"
        local tmpout=$TmpDir/role_remove_member_1002.$RANDOM.out
        KinitAsAdmin
        local groups_TestValue_Negative="nonListValue" #groups;negative;nonListValue
        local users_TestValue="$testUser003" #users;positive;LIST
        ipa role-remove-member $testRole  --groups=$groups_TestValue_Negative 2>&1 > $tmpout
        if grep "group: $groups_TestValue_Negative: This entry is not a member" $tmpout 2>&1 >/dev/null;then
            rlPass "expected error msg matches"
        else
            rlFail "expected error msg does not match"
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_remove_member_1002

role_remove_member_1003()
{ #test_scenario (positive): --groups;positive;LIST
    rlPhaseStartTest "role_remove_member_1003"
        local testID="role_remove_member_1003"
        local tmpout=$TmpDir/role_remove_member_1003.$RANDOM.out
        KinitAsAdmin
        local groups_TestValue="$testGroup" #groups;positive;LIST
        ipa role-find $testRole --all > $tmpout
        if grep -i "Member group" $tmpout | grep -i "$groups_TestValue" 2>&1 >/dev/null;then
            rlLog "found member group [$groups_TestValue] before remove"
        else
            rlLog "member group [$groups_TestValue] not found before remove, test won't be valid"
            rlFail "test env wrong"
            return
        fi
        # perform the test
        rlRun "ipa role-remove-member $testRole  --groups=$groups_TestValue " 0 "test options:  [groups]=[$groups_TestValue]" 
        
        ipa role-find $testRole --all > $tmpout
        if grep -i "Member group" $tmpout | grep -i "$groups_TestValue" 2>&1 >/dev/null;then
            rlFail "found member group [$groups_TestValue] after remove is unexpected"
        else
            rlPass "member group [$groups_TestValue] not found after remove is expected"
        fi

        rlRun "ipa role-add-member $testRole --groups=$testGroup" 0 "restore environment: add [$testGroup] back to role: [$testRole]"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_remove_member_1003

role_remove_member_1004()
{ #test_scenario (negative): --groups;positive;LIST --users;negative;nonListValue
    rlPhaseStartTest "role_remove_member_1004"
        local testID="role_remove_member_1004"
        local tmpout=$TmpDir/role_remove_member_1004.$RANDOM.out
        KinitAsAdmin
        local groups_TestValue="$testGroup" #groups;positive;LIST
        local users_TestValue_Negative="nonListValue" #users;negative;nonListValue
        local expectedErrMsg=replace_me
        local expectedErrCode=1
        qaRun "ipa role-remove-member $testRole --groups=$groups_TestValue  --users=$users_TestValue_Negative " "$tmpout" $expectedErrCode "$expectedErrMsg" "test options:  [groups]=[$groups_TestValue] [users]=[$users_TestValue_Negative]" 
        rlRun "ipa role-add-member $testRole  --groups=$groups_TestValue " 0 "add [$groups_TestValue] back to $testRole]"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_remove_member_1004

role_remove_member_1005()
{ #test_scenario (positive): --groups;positive;LIST --users;positive;LIST
    rlPhaseStartTest "role_remove_member_1005"
        local testID="role_remove_member_1005"
        local tmpout=$TmpDir/role_remove_member_1005.$RANDOM.out
        KinitAsAdmin
        local groups_TestValue="$testGroup" #groups;positive;LIST
        local users_TestValue="$testUser003" #users;positive;LIST
        rlRun "ipa role-remove-member $testRole  --groups=$groups_TestValue  --users=$users_TestValue " 0 "test options:  [groups]=[$groups_TestValue] [users]=[$users_TestValue]" 
        rlRun "ipa role-add-member $testRole  --groups=$groups_TestValue  --users=$users_TestValue " 0 "add [$groups_TestValue], [$users_TestValue] back to $testRole]"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_remove_member_1005

role_remove_member_1006()
{ #test_scenario (negative): --users;negative;nonListValue
    rlPhaseStartTest "role_remove_member_1006"
        local testID="role_remove_member_1006"
        local tmpout=$TmpDir/role_remove_member_1006.$RANDOM.out
        KinitAsAdmin
        local users_TestValue_Negative="nonListValue" #users;negative;nonListValue
        ipa role-remove-member $testRole  --users=$users_TestValue_Negative 2>&1>$tmpout
        if grep -i "user: $users_TestValue_Negative: This entry is not a member" $tmpout 2>&1 >/dev/null;then
            rlPass "error msg matches: remove non-exist member"
        else
            rlFail "error msg does not match for removing non-exist member"
            echo "----------------output-------------"
            cat $tmpout
            echo "==================================="
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_remove_member_1006

role_remove_member_1007()
{ #test_scenario (positive): --users;positive;LIST
    rlPhaseStartTest "role_remove_member_1007"
        local testID="role_remove_member_1007"
        local tmpout=$TmpDir/role_remove_member_1007.$RANDOM.out
        KinitAsAdmin
        local users_TestValue="$testUser003" #users;positive;LIST
        rlRun "ipa role-remove-member $testRole  --users=$users_TestValue " 0 "test options:  [users]=[$users_TestValue]" 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_remove_member_1007

#END OF TEST CASE for [role-remove-member]

#############################################
#  test suite: role-remove-privilege (2 test cases)
#############################################
role_remove_privilege()
{
    role_remove_privilege_envsetup
    role_remove_privilege_1001  #test_scenario (negative test): [--privileges;negative;nonListValue]
    role_remove_privilege_1002  #test_scenario (positive test): [--privileges;positive;LIST]
    role_remove_privilege_envcleanup
} #role-remove-privilege

role_remove_privilege_envsetup()
{
    rlPhaseStartSetup "role_remove_privilege_envsetup"
        #environment setup starts here
        KinitAsAdmin
        rlRun "ipa role-add $testRole --desc=role_for_role_test" 0 "add test role [$testRole]"
        rlRun "ipa role-add-privilege $testRole --privileges=groupadmin,useradmin,hostadmin" 0 "add groupadmin,useradmin,hostadmin "
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

role_remove_privilege_envcleanup()
{
    rlPhaseStartCleanup "role_remove_privilege_envcleanup"
        #environment cleanup starts here
        KinitAsAdmin
        rlRun "ipa role-del $testRole" 0 "delete test role [$testRole]"
        Kcleanup
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

role_remove_privilege_1001()
{ #test_scenario (negative): --privileges;negative;nonListValue
    rlPhaseStartTest "role_remove_privilege_1001"
        local testID="role_remove_privilege_1001"
        local tmpout=$TmpDir/role_remove_privilege_1001.$RANDOM.out
        KinitAsAdmin
        local privileges_TestValue_Negative="nonListValue" #privileges;negative;nonListValue
        local expectedErrMsg="privilege: $privileges_TestValue_Negative: privilege not found"
        ipa role-remove-privilege $testRole  --privileges=$privileges_TestValue_Negative 2>&1 >$tmpout
        if grep -i "$expectedErrMsg" $tmpout 2>&1 >/dev/null;then
            rlPass "expected error msg found"
        else
            rlFail "no expected error msg found"
            echo "-----------output------------"
            cat $tmpout
            echo "============================="
        fi
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_remove_privilege_1001

role_remove_privilege_1002()
{ #test_scenario (positive): --privileges;positive;LIST
    rlPhaseStartTest "role_remove_privilege_1002"
        local testID="role_remove_privilege_1002"
        local tmpout=$TmpDir/role_remove_privilege_1002.$RANDOM.out
        KinitAsAdmin
        local privileges_TestValue="groupadmin,useradmin" #privileges;positive;LIST
        rlRun "ipa role-remove-privilege $testRole  --privileges=$privileges_TestValue " 0 "test options:  [privileges]=[$privileges_TestValue]" 
        checkRoleInfo $testRole "Privileges" "hostadmin"
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_remove_privilege_1002

#END OF TEST CASE for [role-remove-privilege]

#############################################
#  test suite: role-show (1 test cases)
#############################################
role_show()
{
    role_show_envsetup
    role_show_1001  #test_scenario (positive test): [--all --raw --rights]
    role_show_envcleanup
} #role-show

role_show_envsetup()
{
    rlPhaseStartSetup "role_show_envsetup"
        #environment setup starts here
        KinitAsAdmin
        rlRun "ipa role-add $testRole --desc=role_for_role_test" 0 "add test role [$testRole]"
        Kcleanup
        #environment setup ends   here
    rlPhaseEnd
} #envsetup

role_show_envcleanup()
{
    rlPhaseStartCleanup "role_show_envcleanup"
        #environment cleanup starts here
        KinitAsAdmin
        rlRun "ipa role-del $testRole" 0 "delete test role"
        Kcleanup
        #environment cleanup ends   here
    rlPhaseEnd
} #envcleanup

role_show_1001()
{ #test_scenario (positive): --all --raw --rights
    rlPhaseStartTest "role_show_1001"
        local testID="role_show_1001"
        local tmpout=$TmpDir/role_show_1001.$RANDOM.out
        KinitAsAdmin
        rlRun "ipa role-show $testRole --all --raw --rights " 0 "test options: " 
        Kcleanup
        rm $tmpout
    rlPhaseEnd
} #role_show_1001

#END OF TEST CASE for [role-show]
