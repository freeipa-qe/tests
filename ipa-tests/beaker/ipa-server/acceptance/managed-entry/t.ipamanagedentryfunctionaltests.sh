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
mepManagedEntry: cn=nusr19,cn=groups,cn=accounts,dc=testrelm,dc=com
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


}

managedentry_server_tests()
{
	# Add new user

	# ensure that new user's group was created

	#try to modify something that I shouldn't be able to

	rlPhaseStartTest "Negitive test case to try binding as the CLIENTs principal"
		kdestroy
		rlRun "kinit -kt /etc/krb5.keytab host/$CLIENT" 1 "Bind as the host principal for CLIENT, this should return 1"
		rlRun "klist | grep host/$CLIENT" 1 "make sure we are not bound as the CLIENT host principal"
	rlPhaseEnd


}

cleanup_managedby()
{
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
	# Remove group
	# remove user
}

	

