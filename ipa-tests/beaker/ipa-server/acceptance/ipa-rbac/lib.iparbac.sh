#!/bin/sh
# lib used for ipa permission test



######################################################################
# Verify permission that have name, rights, type, attr and objectclass assigned
# when using --all to show these.
#
# verifyPermissionTypeAttr Usage:
#       verifyPermissionTypeAttr <permissionName> <permissionRights> <permissionType> <permissionAttr> <objectclass>
######################################################################
verifyPermissionTargetAttr()
{
    permissionName=$1
    permissionRights=$2
    target=$3
    permissionTarget=$4
    permissionAttr=$5
    objectclass=$6
    permissionMemberOf=$7 
    showOrFind=$8


     rlRun "verifyPermissionAttr $permissionName all \"dn\" \"cn=`echo $permissionName | tr '[A-Z]' '[a-z]'`,cn=permissions,cn=pbac,dc=testrelm,dc=com\" $showOrFind" 0 "Verify dn"
     rlRun "verifyPermissionAttr $permissionName all \"Permission name\" $permissionName $showOrFind" 0 "Verify Permission Name"
     rlRun "verifyPermissionAttr $permissionName all \"Permissions\" $permissionRights $showOrFind" 0 "Verify Permissions"
     rlRun "verifyPermissionAttr $permissionName all \"Attributes\" $permissionAttr $showOrFind" 0 "Verify Attributes"
     rlRun "verifyPermissionAttr $permissionName all $target $permissionTarget $showOrFind" 0 "Verify Target"
     rlRun "verifyPermissionAttr $permissionName all \"objectclass\" $objectclass $showOrFind" 0 "Verify objectclass"
     if [ ! -z $permissionMemberOf ] ; then
       rlRun "verifyPermissionAttr $permissionName all \"Member of group\" $permissionMemberOf $showOrFind" 0 "Verify Member of group"
     fi
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
    objectclass=$2
    showOrFind=$3
    
    objectclassArray=$(echo $objectclass | tr "," "\n")


     rlRun "verifyPermissionAttr $permissionName raw \"dn\" \"cn=`echo $permissionName | tr '[A-Z]' '[a-z]'`,cn=permissions,cn=pbac,dc=testrelm,dc=com\" $showOrFind " 0 "Verify dn"
     rlRun "verifyPermissionAttr $permissionName raw \"cn\" $permissionName $showOrFind" 0 "Verify Permission Name"
     rlRun "verifyPermissionAttr $permissionName raw \"aci\" "" $showOrFind" 0 "Verify aci is listed"
     for oc in $objectclassArray
     do
        rlRun "verifyPermissionAttr $permissionName raw \"objectclass\" $oc $showOrFind" 0 "Verify objectclass"
     done
}


verifyPermissionFindOptions()
{
    permissionName=$1
    permissionRights=$2
    target=$3
    permissionTarget=$4
    permissionAttr=$5
    objectclass=$6
    permissionMemberOf=$7 
    allOrRaw=$8


     rlRun "verifyPermissionAttrFindUsingOptions \"dn\" \"cn=`echo $permissionName | tr '[A-Z]' '[a-z]'`,cn=permissions,cn=pbac,dc=testrelm,dc=com\" " 0 "Verify dn"
     rlRun "verifyPermissionAttrFindUsingOptions \"Permission name\" $permissionName " 0 "Verify Permission Name"
     rlRun "verifyPermissionAttrFindUsingOptions \"Permissions\" $permissionRights " 0 "Verify Permissions"
     rlRun "verifyPermissionAttrFindUsingOptions \"Attributes\" $permissionAttr " 0 "Verify Attributes"
     rlRun "verifyPermissionAttrFindUsingOptions $target $permissionTarget " 0 "Verify Target"
     if [ -z $permissionMemberOf ] ; then
       rlLog "Not verifying memberOf"
     else
       rlRun "verifyPermissionAttrFindUsingOptions \"Member of group\" $permissionMemberOf " 0 "Verify Member of group"
     fi


}
