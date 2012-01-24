#!/bin/sh
# lib used for ipa permission test



######################################################################
# Verify permission that have name, rights, type, attr and objectclass assigned
# when using --all to show these.
#
# verifyPermissionTypeAttr Usage:
#       verifyPermissionTypeAttr <permissionName> <permissionRights> <permissionType> <permissionAttr> <objectclass>
######################################################################
verifyPermissionTypeAttr()
{
    permissionName=$1
    permissionRights=$2
    permissionType=$3
    permissionAttr=$4
    objectclass=$5



     rlRun "verifyPermissionAttr $permissionName all \"dn\" \"cn=`echo $permissionName | tr '[A-Z]' '[a-z]'`,cn=permissions,cn=pbac,dc=testrelm\" " 0 "Verify dn"
     rlRun "verifyPermissionAttr $permissionName all \"Permission name\" $permissionName" 0 "Verify Permission Name"
     rlRun "verifyPermissionAttr $permissionName all \"Permissions\" $permissionRights" 0 "Verify Permissions"
     rlRun "verifyPermissionAttr $permissionName all \"Attributes\" $permissionAttr" 0 "Verify Attributes"
     rlRun "verifyPermissionAttr $permissionName all \"Type\" $permissionType" 0 "Verify Type"
     rlRun "verifyPermissionAttr $permissionName all \"objectclass\" $objectclass" 0 "Verify objectclass"
}



######################################################################
# Verify permission that have name, rights, type, attr and objectclass assigned
# when using --all --raw to show these.
#
# verifyPermissionRawAttr Usage:
#       verifyPermissionRawAttr <permissionName> <permissionRights> <permissionType> <permissionAttr> <objectclass>
######################################################################
verifyPermissionRawTypeAttr()
{
    permissionName=$1
    permissionRights=$2
    permissionType=$3
    permissionAttr=$4
    objectclass=$5
    
    permissionRightsArray=$(echo $permissionRights | tr "," "\n")
    permissionAttrArray=$(echo $permissionAttr | tr "," "\n")
    objectclassArray=$(echo $objectclass | tr "," "\n")


     rlRun "verifyPermissionAttr $permissionName raw \"dn\" \"cn=`echo $permissionName | tr '[A-Z]' '[a-z]'`,cn=permissions,cn=pbac,dc=testrelm\" " 0 "Verify dn"
     rlRun "verifyPermissionAttr $permissionName raw \"cn\" $permissionName" 0 "Verify Permission Name"
     rlRun "verifyPermissionAttr $permissionName raw \"type\" $permissionType" 0 "Verify Type"

     for right in $permissionRightsArray
     do
         rlRun "verifyPermissionAttr $permissionName raw \"permissions\" $right" 0 "Verify Permissions"
     done
     for attr in $permissionAttrArray
     do
        rlRun "verifyPermissionAttr $permissionName raw \"attrs\" $attr" 0 "Verify Attributes"
     done
     for oc in $objectclassArray
     do
        rlRun "verifyPermissionAttr $permissionName raw \"objectclass\" $oc" 0 "Verify objectclass"
     done
}


######################################################################
# Verify permission that have name, rights, filter and objectclass assigned
# when using --all to show these.
#
# verifyPermissionFilter Usage:
#       verifyPermissionFilter <permissionName> <permissionRights> <permissionFilter> <objectclass>
######################################################################
verifyPermissionFilter()
{
    permissionName=$1
    permissionRights=$2
    permissionFilter=$3
    objectclass=$4



     rlRun "verifyPermissionAttr $permissionName all \"dn\" \"cn=`echo $permissionName | tr '[A-Z]' '[a-z]'`,cn=permissions,cn=pbac,dc=testrelm\" " 0 "Verify dn"
     rlRun "verifyPermissionAttr $permissionName all \"Permission name\" $permissionName" 0 "Verify Permission Name"
     rlRun "verifyPermissionAttr $permissionName all \"Permissions\" $permissionRights" 0 "Verify Permissions"
     rlRun "verifyPermissionAttr $permissionName all \"Filter\" $permissionFilter" 0 "Verify Filter"
     rlRun "verifyPermissionAttr $permissionName all \"objectclass\" $objectclass" 0 "Verify objectclass"
}


######################################################################
# Verify permission that have name, rights, subtree, memberof and objectclass assigned
# when using --all to show these.
#
# verifyPermissionSubtree Usage:
#       verifyPermissionSubtree <permissionName> <permissionRights> <permissionSubtree> <permissionMemberOf> <objectclass>
######################################################################
verifyPermissionSubtree()
{
    permissionName=$1
    permissionRights=$2
    permissionSubtree=$3
    permissionMemberOf=$4 
    objectclass=$5



     rlRun "verifyPermissionAttr $permissionName all \"dn\" \"cn=`echo $permissionName | tr '[A-Z]' '[a-z]'`,cn=permissions,cn=pbac,dc=testrelm\" " 0 "Verify dn"
     rlRun "verifyPermissionAttr $permissionName all \"Permission name\" $permissionName" 0 "Verify Permission Name"
     rlRun "verifyPermissionAttr $permissionName all \"Permissions\" $permissionRights" 0 "Verify Permissions"
     rlRun "verifyPermissionAttr $permissionName all \"Subtree\" ldap:\/\/\/$permissionSubtree" 0 "Verify Subtree"
     rlRun "verifyPermissionAttr $permissionName all \"Member of group\" $permissionMemberOf" 0 "Verify Member of group"
     rlRun "verifyPermissionAttr $permissionName all \"objectclass\" $objectclass" 0 "Verify objectclass"
}

