#!/bin/sh
# lib used for ipa privilege test


verifyPrivilegeTargetAttr()
{
    privilegeName=$1
    privilegeDesc=$2
    privilegePerms=$3
    objectclass=$4
    privilegeMemberOf=$5 
    privilegeToRoles=$6
    privilegeMember=$7


     rlRun "verifyPrivilegeAttr \"$privilegeName\" \"dn\" \"cn=`echo \"$privilegeName\" | tr '[A-Z]' '[a-z]'`,cn=privileges,cn=pbac,dc=testrelm,dc=com\" " 0 "Verify dn"
     rlRun "verifyPrivilegeAttr \"$privilegeName\" \"Privilege name\" \"$privilegeName\" " 0 "Verify Privilege Name"
     rlRun "verifyPrivilegeAttr \"$privilegeName\" \"Description\" \"$privilegeDesc\" " 0 "Verify Privilege Desc"
     if [ ! -z $privilegePerms ] ; then
       rlRun "verifyPrivilegeAttr \"$privilegeName\" \"Permissions\" $privilegePerms " 0 "Verify Permissions"
     fi
     if [ ! -z $privilegeMemberOf ] ; then
      rlRun "verifyPrivilegeAttr "$privilegeName" \"Granting privilege to roles\" $privilegeToRoles " 0 "Verify Attributes"
      rlRun "verifyPrivilegeAttr "$privilegeName" \"memberindirect:\" $privilegeMember " 0 "Verify Attributes"
     fi
}
