#!/bin/sh
# lib used for ipa role test


verifyRoleTargetAttr()
{
    roleName=$1
    roleDesc=$2
    rolePrivs=$3
    objectclass=$4
    roleMemberOf=$5 
    roleMember=$6


     rlRun "verifyRoleAttr \"$roleName\" \"dn\" \"cn=`echo \"$roleName\" | tr '[A-Z]' '[a-z]'`,cn=roles,cn=accounts,dc=testrelm,dc=com\" " 0 "Verify dn"
     rlRun "verifyRoleAttr \"$roleName\" \"Role name\" \"$roleName\" " 0 "Verify Role Name"
     rlRun "verifyRoleAttr \"$roleName\" \"Description\" \"$roleDesc\" " 0 "Verify Role Desc"
     if [ ! -z $rolePrivs ] ; then
       rlRun "verifyRoleAttr \"$roleName\" \"Privileges\" $rolePrivs " 0 "Verify Privileges"
     fi
     if [ ! -z $roleMemberOf ] ; then
      rlRun "verifyRoleAttr "$roleName" \"memberofindirect:\" $roleMember " 0 "Verify Attributes"
     fi
}
