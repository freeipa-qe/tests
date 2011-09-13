
######################
# Check user  
# Be sure to load the user into $1
######################
check_user()
{
	uid=$(ldapsearch -D 'cn=Directory Manager' -h$CLIENT -p2389 -w$ADMINPW -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep uidNumber | cut -d\  -f2 )
	gid=$(ldapsearch -D 'cn=Directory Manager' -h$CLIENT -p2389 -w$ADMINPW -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep gidNumber | cut -d\  -f2 )
	shell=$(ldapsearch -D 'cn=Directory Manager' -h$CLIENT -p2389 -w$ADMINPW -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep loginShell | cut -d\  -f2 )
	home=$(ldapsearch -D 'cn=Directory Manager' -h$CLIENT -p2389 -w$ADMINPW -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep homeDirectory | cut -d\  -f2 )

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
# Check group 
# Be sure to load the group into $1
######################
check_group()
{
	gid=$(ldapsearch -D 'cn=Directory Manager' -h$CLIENT -p2389 -w$ADMINPW -x -bi cn=$1,ou=Groups,dc=bos,dc=redhat,dc=com objectclass=* | grep gidNumber | cut -d\  -f2 )

	rlPhaseStartTest "checking gid for group $1"
		rlRun "ipa user-show $1 | grep GID | grep $gid" 0 "checking to ensure the UID for user $1 is $gid"
	rlPhaseEnd

}

######################
# Add some more users
# Adding some more users to one group
######################
add_more_users()
{
	file="/dev/shm/new-users-for-group.ldif"
	echo '# usera000, People, bos.redhat.com
dn: uid=usera000,ou=People,dc=bos,dc=redhat,dc=com
givenName: User
sn: 1009
loginShell: /bin/bash
uidNumber: 1009
gidNumber: 1000
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetorgperson
objectClass: posixAccount
uid: usera000
gecos: User a000
cn: User a000
homeDirectory: /home/usera000

dn: uid=userb000,ou=People,dc=bos,dc=redhat,dc=com
givenName: User
sn: 1009
loginShell: /bin/bash
uidNumber: 1009
gidNumber: 1000
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetorgperson
objectClass: posixAccount
uid: userb000
gecos: User a000
cn: User a000
homeDirectory: /home/userb000' >> $file

	rlPhaseStartTest "adding some more users to gid 1000"
		rlRun "ldapmodify -a -x -h$CLIENT -p 2389 -D \"cn=Directory Manager\" -w$ADMINPW -c -f $file" 0 "adding more users to gid 1000"
	rlPhaseEnd

}

#####################
# cleanup
#####################
cleanup()
{
	file=/dev/shm/ds-ipa-migration-test-cleanup.ldif
	echo 'dn: uid=usera000,ou=People,dc=bos,dc=redhat,dc=com
changetype: delete

dn: uid=userb000,ou=People,dc=bos,dc=redhat,dc=com
changetype: delete' > $file

	rlPhaseStartTest "runnign cleanup of added users"
		rlRun "ldapmodify -x -h$CLIENT -p 2389 -D \"cn=Directory Manager\" -w$ADMINPW -c -f $file" 0 "cleaning up added users"
	rlPhaseEnd

}

######################
# test suite         #
######################
# ldapsearch -D "cn=Directory Manager" -hipaqa64vmc.idm.lab.bos.redhat.com -p2389 -w$ADMINPW -x -b ou=People,dc=bos,dc=redhat,dc=com objectclass=*
# ipa migrate-ds ldap://ipaqa64vmc.idm.lab.bos.redhat.com:2389

ds-migration()
{
	rlPhaseStartTest "Migrating from $CLIENT"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa config-mod --enable-migration=TRUE" 0 "enabling migration"
		rlRun "echo $ADMINPW | ipa migrate-ds ldap://$CLIENT:2389" 0 "running migration from DS instance on CLIENT"
	rlPhaseEnd

	add_more_users
	
	# Checking user user1000
	check_user user1000
	# Checking user user2000
	check_user user2000
	# Checking user user2009
	check_user user2009
	# Checking user usera000
	check_user usera000
	# Checking user userb000
	check_user userb000

	# checking group 1000
	check_group group1000
	# checking group 2000
	check_group group2000
	# checking group Duplicate
	check_group Duplicate

	rlPhaseStartTest "Migrating from $CLIENT"
		rlRun "ipa config-mod --enable-migration=FALSE" 0 "disabling migration"
	rlPhaseEnd

	# Cleaning up added users
	cleanup
} # ipasample

