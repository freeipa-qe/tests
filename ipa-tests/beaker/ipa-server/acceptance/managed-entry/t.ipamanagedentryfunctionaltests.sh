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
USERA="nusr19"
USERB="altnur19"
NEWUSERA="uid=$USERA,cn=users,cn=accounts,dc=testrelm,dc=com"
NEWUSERAGROUP="cn=$USERA,cn=groups,cn=accounts,dc=testrelm,dc=com"
NEWUSERB="uid=$USERB,cn=users,cn=accounts,dc=testrelm,dc=com"
NEWUSERBGROUP="cn=$USERB,cn=groups,cn=accounts,dc=testrelm,dc=com"
NEWUSERALDIF=/dev/shm/managedentrynewuser.ldif
RNUSERLDIF=/dev/shm/modrdnB.ldif
MODUSERLDIF=/dev/shm/modgroupentry.ldif
MODUSERLDIF2=/dev/shm/modgroupentry2.ldif
MODUSERLDIF3=/dev/shm/modgroupentry3.ldif
MODUSERLDIF4=/dev/shm/modgroupentry4.ldif

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

	rlPhaseStartTest "Make some ldif files for later testing"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"

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
cn: notusr19" > $MODUSERLDIF3


echo "dn: $NEWUSERAGROUP
changetype: modify
replace: mepManagedBy
mepManagedBy: $NEWUSERA" > $MODUSERLDIF4

	# Create a LDIF containing the modrdn info
	echo "$NEWUSERA
uid=$USERB" > $RNUSERLDIF 
		rlPass
	rlPhaseEnd
}

managedby_server_tests()
{
	# Add new user
	rlPhaseStartTest "Managed-01 - Create user that needs to have a managed entry"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $NEWUSERALDIF" 0 "Adding new user to ldap server"
	rlPhaseEnd

	# ensure that new user's group was created
	rlPhaseStartTest "Managed-02 - ensure that the associated groups entry was created."
		rlRun "/usr/bin/ldapsearch -x -D '$ROOTDN' -w $ROOTDNPWD -b '$NEWUSERAGROUP'" 0 "ensure that $NEWUSERAGROUP was created"
	rlPhaseEnd

	# Try to delete a entry that we should not be able to
	rlPhaseStartTest "Managed-03 - try to delete the group when we should not be allowed"
		rlRun "ldapdelete -x -D '$ROOTDN' -w $ROOTDNPWD  '$NEWUSERAGROUP'" 53 "Making sure we cannot delete a group that is a linked managed entry"
	rlPhaseEnd

	# Try to modify a entry that we should not have access to
	rlPhaseStartTest "Managed-04 - Try to modify a entry we should not have access to (gidNumber)"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $MODUSERLDIF" 53 "Making sure that we cannot modify a entry that should be locked out(gidNumber)"
	rlPhaseEnd

	rlPhaseStartTest "Managed-05 - Try to modify a entry we should not have access to (description)"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $MODUSERLDIF2" 53 "Making sure that we cannot modify a entry that should be locked out(description)"
	rlPhaseEnd

	rlPhaseStartTest "Managed-06 - Try to modify a entry we should not have access to (cn)"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $MODUSERLDIF3" 53 "Making sure that we cannot modify a entry that should be locked out(cn)"
	rlPhaseEnd

	rlPhaseStartTest "Managed-07 - Try to modify a entry we should have access to (mepManagedBy)"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $MODUSERLDIF4" 0 "Making sure that we can modify a entry in the linked group that should be able to(mepManagedBy)"
	rlPhaseEnd


	rlPhaseStartTest "Managed-08 - Deleting user that created the test group in order to delete that group"
		rlRun "ldapdelete -x -D '$ROOTDN' -w $ROOTDNPWD  '$NEWUSERA'" 0 "Deleting $NEWUSERA in order to remove $NEWUSERAGROUP"
	rlPhaseEnd
	
	# Sleeping for some time in order to let the managedby plugin to work
	sleep 30
	rlPhaseStartTest "Managed-09 - checking to make sure that the associated group was deleted"
		rlRun "/usr/bin/ldapsearch -x -D '$ROOTDN' -w $ROOTDNPWD -b '$NEWUSERAGROUP'" 32 "ensure that $NEWUSERAGROUP does not exist"
	rlPhaseEnd

	# re-Add new user
	rlPhaseStartTest "Managed-10 - recreate user that needs to have a managed entry"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $NEWUSERALDIF" 0 "re-adding new user to ldap server"
	rlPhaseEnd

	# Rename the user to check that the group gets renamed
	rlPhaseStartTest "Manages-11 - rename the new user"
		rlRun "/usr/bin/ldapmodrdn -x -D '$ROOTDN' -w $ROOTDNPWD -f $RNUSERLDIF" 0 "Rename user $USERA to $USERB"
	rlPhaseEnd
	sleep 30

	# ensure that new user's group was renamed
	rlPhaseStartTest "Managed-12 - ensure that the associated groups managedby entry was renamed."
		rlRun "/usr/bin/ldapsearch -x -D '$ROOTDN' -w $ROOTDNPWD -b '$NEWUSERAGROUP' | grep mepManagedBy | grep $NEWUSERB" 0 "ensure that the managedby for $NEWUSERAGROUP was modified to $NEWUSERB"
	rlPhaseEnd

	# Try to delete the renamed entry that we should not be able to
	rlPhaseStartTest "Managed-13 - try to delete the renamed group when we should not be allowed"
		rlRun "/usr/bin/ldapdelete -x -D '$ROOTDN' -w $ROOTDNPWD  '$NEWUSERAGROUP'" 53 "Making sure we cannot delete a group that is a linked managed entry"
	rlPhaseEnd

	rlPhaseStartTest "Managed-14 - Deleting the renamed user that created the test group in order to delete that group"
		rlRun "/usr/bin/ldapdelete -x -D '$ROOTDN' -w $ROOTDNPWD  '$NEWUSERB'" 0 "Deleting $NEWUSERB in order to remove $NEWUSERBGROUP"
	rlPhaseEnd
	
	# Sleeping for some time in order to let the managedby plugin to work
	sleep 30
	rlPhaseStartTest "Managed-15 - Checking to make sure that the associated group was deleted"
		rlRun "/usr/bin/ldapsearch -x -D '$ROOTDN' -w $ROOTDNPWD -b '$NEWUSERBGROUP'" 32 "ensure that $NEWUSERBGROUP does not exist"
	rlPhaseEnd

	# Makeing a user via IPA tools to ensure that it's group is created.
	rlPhaseStartTest "Managed-16 - Creating user using ipa tools"
		rlRun "/usr/bin/ipa user-add --first=nuserfirst --last=nuserlast $USERA" 0 "Creating the new user via the IPA tools"
	rlPhaseEnd

	# ensure that new user's group was created
	rlPhaseStartTest "Managed-17 - ensure that the associated groups entry was created."
		rlRun "/usr/bin/ldapsearch -x -D '$ROOTDN' -w $ROOTDNPWD -b '$NEWUSERAGROUP'" 0 "ensure that $NEWUSERAGROUP was created"
	rlPhaseEnd

	rlPhaseStartTest "Managed-18 - ensure that the associated groups entry was created using ipa group-find."
		rlRun "/usr/bin/ipa group-find --private --all $USERA | grep $NEWUSERA" 0 "ensure that $NEWUSERAGROUP was created using ipa group-find"
	rlPhaseEnd

	# Try to delete a entry that we should not be able to
	rlPhaseStartTest "Managed-19 - try to delete the group when we should not be allowed"
		rlRun "/usr/bin/ldapdelete -x -D '$ROOTDN' -w $ROOTDNPWD  '$NEWUSERAGROUP'" 53 "Making sure we cannot delete a group that is a linked managed entry"
	rlPhaseEnd

	# Try to modify a entry that we should not have access to
	rlPhaseStartTest "Managed-20 - Try to modify a entry we should not have access to (gidNumber)"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $MODUSERLDIF" 53 "Making sure that we cannot modify a entry that should be locked out(gidNumber)"
	rlPhaseEnd

	rlPhaseStartTest "Managed-21 - Try to modify a entry we should not have access to (description)"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $MODUSERLDIF2" 53 "Making sure that we cannot modify a entry that should be locked out(description)"
	rlPhaseEnd

	rlPhaseStartTest "Managed-22 - Try to modify a entry we should not have access to (cn)"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $MODUSERLDIF3" 53 "Making sure that we cannot modify a entry that should be locked out(cn)"
	rlPhaseEnd

	rlPhaseStartTest "Managed-23 - Try to modify a entry we should have access to (mepManagedBy)"
		rlRun "/usr/bin/ldapmodify -a -x -D '$ROOTDN' -w $ROOTDNPWD -f $MODUSERLDIF4" 0 "Making sure that we can modify a entry in the linked group that should be able to(mepManagedBy)"
	rlPhaseEnd

	NEWGIDNUMBER=22345233

	rlPhaseStartTest "Managed-24 - Modify the gid number of the user."
		rlRun "/usr/bin/ipa user-mod --uid=$NEWGIDNUMBER $USERA" 0 "changing the GID on the managed entry user"
	rlPhaseEnd

	rlPhaseStartTest "Managed-25 - Make sure the gid number on the associated group changed"
		rlRun "/usr/bin/ldapsearch -x -D '$ROOTDN' -w $ROOTDNPWD -b '$NEWUSERAGROUP' objectclass=* | grep $NEWGIDNUMBER" 0 "Make sure that the GID number changed on the created user"
	rlPhaseEnd

	rlPhaseStartTest "Managed-26 - Make sure the gid number on the associated group changed using ipa group-find"
		rlRun "/usr/bin/ipa group-find --private --all $USERA | grep $NEWGIDNUMBER" 0 "Make sure that the GID number changed on the created user using ipa group-find"
	rlPhaseEnd

	rlPhaseStartTest "Managed-27 - Delete the new user via the ipa tools"
		rlRun "/usr/bin/ipa user-del $USERA" 0 "Deleting the test user from the IPA tools"
	rlPhaseEnd
	sleep 30

	rlPhaseStartTest "Managed-28 - make sure that the users group was deleted"
		rlRun "/usr/bin/ldapsearch -x -D '$ROOTDN' -w $ROOTDNPWD -b '$NEWUSERAGROUP'" 32 "ensure that $NEWUSERAGROUP does not exist"
	rlPhaseEnd

	rlPhaseStartTest "Managed-29 - make sure that the users group was deleted using ipa group-find"
		rlRun "/usr/bin/ipa group-find --private --all $USERA" 1 "ensure that $NEWUSERAGROUP does not exist using ipa group-find"
	rlPhaseEnd

}

cleanup_managedby()
{
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
	# Remove group
	
	# remove user
}

	

