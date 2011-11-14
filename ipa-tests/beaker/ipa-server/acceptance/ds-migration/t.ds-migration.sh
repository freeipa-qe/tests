
export userpassword=redhat
export hostnames=$(hostname -s)
export hostnamef=$(hostname)
export clientport=7389

######################
# Check user  
# Be sure to load the user into $1
######################
check_user()
{
	uid=$(ldapsearch -D 'cn=Directory Manager' -h$hostnamel -p$clientport -w$ADMINPW -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep uidNumber | cut -d\  -f2 )
	gid=$(ldapsearch -D 'cn=Directory Manager' -h$hostnamel -p$clientport -w$ADMINPW -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep gidNumber | cut -d\  -f2 )
	shell=$(ldapsearch -D 'cn=Directory Manager' -h$hostnamel -p$clientport -w$ADMINPW -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep loginShell | cut -d\  -f2 )
	home=$(ldapsearch -D 'cn=Directory Manager' -h$hostnamel -p$clientport -w$ADMINPW -x -b uid=$1,ou=People,dc=bos,dc=redhat,dc=com objectclass=* | grep homeDirectory | cut -d\  -f2 )

	rlPhaseStartTest "checking uid for user $1"
		rlRun "ipa user-show --all $1 | grep UID | grep $uid" 0 "checking to ensure the UID for user $1 is $uid"
	rlPhaseEnd

	rlPhaseStartTest "checking gid for user $1"
		rlRun "ipa user-show --all $1 | grep GID | grep $gid" 0 "checking to ensure the UID for user $1 is $gid"
	rlPhaseEnd

	rlPhaseStartTest "checking shell for user $1"
		rlRun "ipa user-show --all $1 | grep Login\ shell | grep $shell" 0 "checking to ensure the UID for user $1 is $shell"
	rlPhaseEnd

	rlPhaseStartTest "checking home dir for user $1"
		rlRun "ipa user-show --all $1 | grep Home\ directory | grep $home" 0 "checking to ensure the UID for user $1 is $home"
	rlPhaseEnd

	# Making sure that the password migrated properly with a ldapbind
	rlPhaseStartTest " Making sure that the password for user $1 migrated properly with a ldapbind"
		rlRun "ldapsearch -x -h127.0.0.1 -p$clientport -D'uid=$1,cn=users,cn=accounts,dc=$DOMAIN' -w$userpassword -b uid=$1,cn=users,cn=accounts,dc=$DOMAIN objectclass=*" 0 "ldapsearch as user $1 with password $userpassword"
	rlPhaseEnd

	# Making sure that the password migrated properly with ssh
	rlPhaseStartTest " Making sure that the password for user $1 migrated properly with ssh"
		file=ssh-test-file-6148864.txt
		touch /dev/shm/$file
		rm -f /dev/shm/ssh-test-output.txt
		echo $userpassword | ssh $1@$MASTER 'ls /dev/shm' > /dev/shm/ssh-test-output.txt &
		sleep 20
		rlRun "grep $file /dev/shm/ssh-test-output.txt" 0 "check to see if the ssh as the user was sucessful"
	rlPhaseEnd

	# setting password and kiniting
	rlPhaseStartTest "Setting password for user $1"
		rlRun "echo blarg1 | ipa passwd $1" 0 "Setting password on user $1"
	rlPhaseEnd

	# Ensuring that kinit for user $1 works.
	rlPhaseStartTest "kiniting as user $1"
		rlRun "FirstKinitAs $1 blarg1 blarg26VLKOPWTF" 0 "Kinit as user $1"
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
	gid=$(ldapsearch -D 'cn=Directory Manager' -h$hostnamel -p$clientport -w$ADMINPW -x -b cn=$1,ou=Groups,dc=bos,dc=redhat,dc=com objectclass=* | grep gidNumber | cut -d\  -f2 )

	rlPhaseStartTest "checking gid for group $1"
		rlRun "ipa group-find --all $1 | grep GID | grep $gid" 0 "checking to ensure the UID for user $1 is $gid"
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
userPassword: redhat
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
userPassword: redhat
homeDirectory: /home/userb000

# user1000, People, bos.redhat.com
dn: uid=user1000,ou=People,dc=bos,dc=redhat,dc=com
givenName: User
sn: 1000
loginShell: /bin/bash
uidNumber: 1000
gidNumber: 1000
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetorgperson
objectClass: posixAccount
uid: user1000
gecos: User 1000
cn: User 1000
userPassword: redhat
homeDirectory: /home/user1000

dn: uid=user2000,ou=People,dc=bos,dc=redhat,dc=com
givenName: User
sn: 2000
loginShell: /bin/bash
uidNumber: 2000
gidNumber: 2000
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetorgperson
objectClass: posixAccount
uid: user2000
gecos: User 2000
cn: User 2000
userPassword: redhat
homeDirectory: /home/user2000

dn: uid=user2009,ou=People,dc=bos,dc=redhat,dc=com
givenName: User
sn: 2000
loginShell: /bin/bash
uidNumber: 2009
gidNumber: 2009
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetorgperson
objectClass: posixAccount
uid: user2009
gecos: User 2009
cn: User 2009
userPassword: redhat
homeDirectory: /home/user2009' > $file

	rlPhaseStartTest "adding some more users to gid 1000"
		echo "running: ldapmodify -a -x -h$hostnamel -p $clientport -D \"cn=Directory Manager\" -w$ADMINPW -c -f $file"
		rlRun "ldapmodify -a -x -h$hostnamel -p $clientport -D \"cn=Directory Manager\" -w$ADMINPW -c -f $file" 0 "adding more users to gid 1000"
	rlPhaseEnd

}

#####################
# Remove group for reinsertion later
######################
remove_group()
{
	# Remove group in $1
	file=/dev/shm/ds-ipa-migration-remove-groups.ldif
	echo "dn: cn=$1,ou=Groups,dc=bos,dc=redhat,dc=com" > $file
	echo 'changetype: delete' >> $file

	rlPhaseStartTest "running cleanup of group $1"
		rlRun "ldapmodify -a -x -h$hostnamel -p $clientport -D \"cn=Directory Manager\" -w$ADMINPW -c -f $file" 0 "removing group $1"
	rlPhaseEnd
}

#####################
# Remove user
#####################
remove_user()
{
	# Remove the user specified in $1
	file=/dev/shm/ds-ipa-migration-test-cleanup.ldif
	echo "dn: uid=$1,ou=People,dc=bos,dc=redhat,dc=com" > $file
	echo 'changetype: delete' >> $file

	rlPhaseStartTest "running cleanup of user $1"
		rlRun "ldapmodify -x -h$hostnamel -p $clientport -D \"cn=Directory Manager\" -w$ADMINPW -c -f $file" 0 "cleaning up added user $1"
	rlPhaseEnd
}

#####################
# cleanup
#####################
cleanup()
{
	remove_user user1000	
	remove_user user2000	
	remove_user user2009	
	remove_user usera000	
	remove_user userb000	

	remove_group Group1000
	remove_group group2000
	
	rlPhaseStartTest "removing ipa object from ipa server"
		rlRun "ipa user-del user1000" 0 "Removing ipa user for cleanup"
		rlRun "ipa user-del user2000" 0 "Removing ipa user for cleanup"
		rlRun "ipa user-del user2009" 0 "Removing ipa user for cleanup"
		rlRun "ipa user-del usera000" 0 "Removing ipa user for cleanup"
		rlRun "ipa user-del userb000" 0 "Removing ipa user for cleanup"
		rlRun "ipa group-del group1000" 0 "Removing ipa group for cleanup"
		rlRun "ipa group-del group2000" 0 "Removing ipa group for cleanup"
		rlRun "ipa group-del 'accounting managers'" 0 "Removing ipa group for cleanup"
		rlRun "ipa group-del 'hr managers'" 0 "Removing ipa group for cleanup"
		rlRun "ipa group-del 'pd managers'" 0 "Removing ipa group for cleanup"
		rlRun "ipa group-del 'qa managers'" 0 "Removing ipa group for cleanup"
	rlPhaseEnd
	
}

#####################
# Set the password of a user in the initial DS server
######################
set_user_ldap_password()
{
	file=/dev/shm/ds-alter-user-password.ldif
	echo "dn: uid=$1,ou=People,dc=bos,dc=redhat,dc=com
changetype: modify
replace: userPassword
userPassword: $userpassword" > $file

	rlPhaseStartTest "changing the password for user $1 in the DS server"
		rlRun "ldapmodify -a -x -h$hostnamel -p $clientport -D \"cn=Directory Manager\" -w$ADMINPW -c -f $file" 0 "changing the password for user $1"
	rlPhaseEnd

}

#####################
# Re-add the groups for testing later
######################
re_add_groups()
{
	file=/dev/shm/ds-ipa-migration-re-add-groups.ldif
	echo 'dn: cn=Group1000,ou=Groups,dc=bos,dc=redhat,dc=com
objectClass: top
objectClass: groupOfUniqueNames
objectClass: posixGroup
cn: PD Managers
ou: groups
gidNumber: 330
description: People that are in Group1000
uniqueMember: cn=Directory Manager

dn: cn=group2000,ou=Groups,dc=bos,dc=redhat,dc=com
objectClass: top
objectClass: groupOfUniqueNames
objectClass: posixGroup
cn: PD Managers
ou: groups
gidNumber: 335
description: People that are in group2000
uniqueMember: cn=Directory Manager
uniqueMember: uid=user2009,ou=People,dc=bos,dc=redhat,dc=com
uniqueMember: uid=user2000,ou=People,dc=bos,dc=redhat,dc=com' > $file

	rlPhaseStartTest "re-inserting the groups that we will be testing with later"
		echo "running: ldapmodify -a -x -h$hostnamel -p $clientport -D \"cn=Directory Manager\" -w$ADMINPW -c -f $file"
		rlRun "ldapmodify -a -x -h$hostnamel -p $clientport -D \"cn=Directory Manager\" -w$ADMINPW -c -f $file" 0 "adding more users to gid 1000"
	rlPhaseEnd

}


######################
# test suite         #
######################
# ldapsearch -D "cn=Directory Manager" -hipaqa64vmc.idm.lab.bos.redhat.com -p$clientport -w$ADMINPW -x -b ou=People,dc=bos,dc=redhat,dc=com objectclass=*
# ipa migrate-ds ldap://ipaqa64vmc.idm.lab.bos.redhat.com:$clientport

ds_migration()
{

	add_more_users
	set_user_ldap_password user1000
	set_user_ldap_password user2000
	set_user_ldap_password user2009
	set_user_ldap_password usera000
	set_user_ldap_password userb000
	re_add_groups

	rlPhaseStartTest "Migrating from $hostnamel:$clientport"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa config-mod --enable-migration=TRUE" 0 "enabling migration"
		echo $ADMINPW | ipa migrate-ds ldap://$hostnamel:$clientport
		if [ $? -ne 0 ]; then
			rlFail "ERROR - Migration form DS failed"
		fi
	rlPhaseEnd
	
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

	rlPhaseStartTest "disabling migration"
		rlRun "ipa config-mod --enable-migration=FALSE" 0 "disabling migration"
	rlPhaseEnd

	# Cleaning up added users
	cleanup
} # ipasample

# This bit sets up and configures the ds instance on the client
ds_setup()
{
	# ds-setup.inf should be in /dev/shm
	cat /dev/shm/ds-setup.inf > /tmp/ds-setup.inf
	sed -i s/--shorthostname--/$hostnames/g /tmp/ds-setup.inf
	sed -i s/--fullhostname--/$hostnamef/g /tmp/ds-setup.inf
	/usr/sbin/useradd -G root dirsrv
	/usr/sbin/setup-ds.pl --silent --file=/tmp/ds-setup.inf
	rlPhaseStartTest "Testing to ensure that the ds instance on $hostnamef got set properly"
		rlRun "ldapsearch -D \"cn=Directory Manager\" -h$hostnamef -p$clientport -w$ADMINPW -x -b dc=bos,dc=redhat,dc=com objectclass=*" 0 "Checking to ensure that we can ldapsearch against the new DS instance"
	rlPhaseEnd
}

# Removes the instance created by ds_setup
ds_cleanup()
{
	/usr/sbin/remove-ds slapd-$hostnames
}
