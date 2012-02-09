#####################
#  GLOBALS	    #
#####################
HTTPCFGDIR="/etc/httpd/conf"
HTTPCERTDIR="$HTTPCFGDIR/alias"
HTTPPRINC="HTTP/$HOSTNAME"
HTTPKEYTAB="$HTTPCFGDIR/$HOSTNAME.keytab"
HTTPKRBCFG="/etc/httpd/conf.d/krb.conf"

FAKEHOSTNAME="managedby-fakehost.testrelm"
FAKEHOSTREALNAME="managedby-fakehost.idm.lab.bos.redhat.com"
FAKEHOSTNAMEIP="10.16.98.239"
FAKEHOSTKEYTABFILE="/dev/shm/$FAKEHOSTNAME.host.keytab"
CLIENTKEYTABFILE="/dev/shm/$CLIENT.host.keytab"
NEWUSERA="uid=nusr19,cn=users,cn=accounts,dc=testrelm,dc=com"
NEWUSERAGROUP="cn=nusr19,cn=groups,cn=accounts,dc=testrelm,dc=com"
NEWUSERALDIF=/dev/shm/managedentrynewuser.ldif
MODUSERLDIF=/dev/shm/modgroupentry.ldif
MODUSERLDIF2=/dev/shm/modgroupentry2.ldif
MODUSERLDIF3=/dev/shm/modgroupentry3.ldif

echo " HTTP configuration directory:  $HTTPCFGDIR"
echo " HTTP certificate directory:  $HTTPCERTDIR"
echo " HTTP krb configuration file: $HTTPKRBCFG"
echo " HTTP principal:  $HTTPPRINC"
echo " HTTP keytab: $HTTPKEYTAB"

######################
# test suite         #
######################
ipa-managedentryfunctionaltests()
{
    managedby_server_tests
    cleanup_managedby
} 

######################
# SETUP              #
######################

ipa-managedentryfunctionaltestssetup()
{
	kdestroy
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"

	rlPhaseStartTest "Make some keytabs for later testing"
		rlPass
	rlPhaseEnd

	# Create new user ldif
	echo "dn: $NEWUSERA
mepManagedEntry: $NEWUSERAGROUP
displayName: nuser19 nlast19
cn: nuser19 nlast19
objectClass: top
objectClass: person
objectClass: organizationalperson
objectClass: inetorgperson
objectClass: inetuser
objectClass: posixaccount
objectClass: krbprincipalaux
objectClass: krbticketpolicyaux
objectClass: ipaobject
objectClass: mepOriginEntry
loginShell: /bin/sh
initials: ul
gecos: nuser19 nlast19
sn: nlast19
homeDirectory: /home/nusr19
krbPwdPolicyReference: cn=global_policy,cn=TESTRELM.COM,cn=kerberos,dc=testrelm,dc=com
mail: nusr19@testrelm.com
krbPrincipalName: nusr19@TESTRELM.COM
givenName: nuser19
uid: nusr19
uidNumber: 116260
gidNumber: 116260" > $NEWUSERALDIF

	# Create LDIF file for use in a modify op
	echo "dn: $NEWUSERAGROUP
changetype: modify
replace: gidNumber
gidNumber: 76543266" > $MODUSERLDIF

	# Create LDIF file for use in a modify op
	echo "dn: $NEWUSERAGROUP
changetype: modify
replace: description
description: 75f9f900-51f3-11e1-93e0-021016980186" > $MODUSERLDIF2

	# Create LDIF file for use in a modify op
	echo "dn: $NEWUSERAGROUP
changetype: modify
replace: cn
cn: notuser19" > $MODUSERLDIF3

}

managedby_server_tests()
{
	# Add new user
	rlPhaseStartTest "Managed-01 - Create user that needs to have a managed entry"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $NEWUSERALDIF" 0 "Adding new user to ldap server"
	rlPhaseEnd

	# ensure that new user's group was created
	rlPhaseStartTest "Managed-02 - ensure that the assoiated groups entry was created."
		rlRun "/usr/bin/ldapsearch -x -D '$ROOTDN' -w $ROOTDNPWD -b '$NEWUSERAGROUP'" 0 "ensure that $NEWUSERAGROUP was created"
	rlPhaseEnd

	# Try to delete a entry that we should not be able to
	rlPhaseStartTest "Managed-03 - try to delete the group when we should not be allowed"
		rlRun "ldapdelete -x -D '$ROOTDN' -w $ROOTDNPWD  '$NEWUSERAGROUP'" 53 "Making sure we cannot delete a group that is a linked managed entry"
	rlPhaseEnd

	# Try to modify a entry that we should not have access to
	rlPhaseStartTest "Managed-04 - Try to modify a entry we shouldn't have access to (gidNumber)"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $MODUSERLDIF" 53 "Making sure that we cannot modify a entry that should be locked out(gidNumber)"
	rlPhaseEnd

	rlPhaseStartTest "Managed-05 - Try to modify a entry we shouldn't have access to (description)"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $MODUSERLDIF2" 53 "Making sure that we cannot modify a entry that should be locked out(description)"
	rlPhaseEnd

	rlPhaseStartTest "Managed-06 - Try to modify a entry we shouldn't have access to (cn)"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $MODUSERLDIF3" 53 "Making sure that we cannot modify a entry that should be locked out(cn)"
	rlPhaseEnd

	rlPhaseStartTest "Managed-07 - Deleting user that created the test group in order to delete that group"
		rlRun "ldapdelete -x -D '$ROOTDN' -w $ROOTDNPWD  '$NEWUSERA'" 0 "Deleting $NEWUSERA in order to remove $NEWUSERAGROUP"
	rlPhaseEnd
	
	# Sleeping for some time in order to let the managedby plugin to work
	sleep 30
	rlPhaseStartTest "Managed-08 - checking to make sure that the assoiated group was deleted"
		rlRun "/usr/bin/ldapsearch -x -D '$ROOTDN' -w $ROOTDNPWD -b '$NEWUSERAGROUP'" 32 "ensure that $NEWUSERAGROUP does not exist"
	rlPhaseEnd

#	rlPhaseStartTest "Negitive test case to try binding as the CLIENTs principal"
#		kdestroy
#		rlRun "kinit -kt /etc/krb5.keytab host/$CLIENT" 1 "Bind as the host principal for CLIENT, this should return 1"
#		rlRun "klist | grep host/$CLIENT" 1 "make sure we are not bound as the CLIENT host principal"
#	rlPhaseEnd


}

cleanup_managedby()
{
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
	# Remove group
	
	# remove user
}

	

