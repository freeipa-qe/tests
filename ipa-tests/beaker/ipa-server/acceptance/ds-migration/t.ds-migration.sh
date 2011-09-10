
######################
# Check user  
# Be sure to load the user into $1
check_user()
{
	uid=$(ldapsearch -D \"cn=Directory Manager\" -h$CLIENT -p2389 -wSecret123 -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep uidNumber | cut -d\  -f2 )
	gid=$(ldapsearch -D \"cn=Directory Manager\" -h$CLIENT -p2389 -wSecret123 -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep gidNumber | cut -d\  -f2 )
	shell=$(ldapsearch -D \"cn=Directory Manager\" -h$CLIENT -p2389 -wSecret123 -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep loginShell | cut -d\  -f2 )
	home=$(ldapsearch -D \"cn=Directory Manager\" -h$CLIENT -p2389 -wSecret123 -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep homeDirectory | cut -d\  -f2 )

	rlPhaseStartTest "checking uid for user $1"
		rlRun "ipa user-show $1 | grep UID | grep $uid" 0 "checking to ensure the UID for user $1 is $uid"
	rlPhaseEnd

	rlPhaseStartTest "checking gid for user $1"
		rlRun "ipa user-show $1 | grep GID | grep $gid" 0 "checking to ensure the UID for user $1 is $gid"
	rlPhaseEnd

	rlPhaseStartTest "checking shell for user $1"
		rlRun "ipa user-show $1 | grep Login\ shell | grep $shell" 0 "checking to ensure the UID for user $1 is $shell"
	rlPhaseEnd

	rlPhaseStartTest "checking home dir for user $1"
		rlRun "ipa user-show $1 | grep Home\ directory | grep $home" 0 "checking to ensure the UID for user $1 is $home"
	rlPhaseEnd

	# setting password and kiniting
	rlPhaseStartTest "Setting password for user $1"
		rlRun "echo blarg1 | ipa passwd $1" 0 "Setting password on user $1"
	rlPhaseEnd

	# Ensuring that kinit for user $1 works.
	rlPhaseStartTest "kiniting as user $1"
		rlRun "kinitAs $1 blarg1" 0 "Kinit as user $1"
	rlPhaseEnd

	# Resetting kinit to admin
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
}

######################
# test suite         #
######################
# ldapsearch -D "cn=Directory Manager" -hipaqa64vmc.idm.lab.bos.redhat.com -p2389 -wSecret123 -x -b ou=People,dc=bos,dc=redhat,dc=com objectclass=*
# ipa migrate-ds ldap://ipaqa64vmc.idm.lab.bos.redhat.com:2389

ds-migration()
{
	rlPhaseStartTest "Migrating from $CLIENT"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa migrate-ds ldap://$CLIENT:2389" 0 "running migration from DS instance on CLIENT"
	rlPhaseEnd
	
	# Checking user 1000
	check_user user1000
	# Checking user 2000
	check_user user2000
	# Checking user 2009
	check_user user2009

} # ipasample

