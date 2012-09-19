USERCONTAINER="ou=People"
GROUPCONTAINER="ou=groups"
USEROBJCLASS="posixAccount"
GROUPOBJCLASS="posixGroup"
MYBASEDN="dc=example,dc=com"
USER1="mmouse"
USER1PWD="Secret123"
USER2PWD="Secret123"
USER2="dduck"
GROUP1="disney"
DMPASSWD="Secret123"
USER1DN="uid=$USER1,$USERCONTAINER,$MYBASEDN"
USER2DN="uid=$USER2,$USERCONTAINER,$MYBASEDN"
GROUP1DN="cn=$GROUP1,$GROUPCONTAINER,$MYBASEDN"
LDAPPORT="389"
######################
# test suite         #
######################
ds-cloud-integration()
{
    setup
    cloudldaptests
    cleanup
}

######################
# SETUP              #
######################

setup()
{
        rlPhaseStartTest "Any additional setup required for your tests"
		rlPass "Placeholder"
        rlPhaseEnd
}

cloudldaptests()
{
	rlPhaseStartTest "ds-cloud-integration-001 Search for LDAP Users"
		echo "LDAP SERVER is $LDAPSERVER"
		/usr/bin/ldapsearch -x -h $LDAPSERVER -p $LDAPPORT -D "cn=Directory Manager" -w $DMPASSWD -b "$USER1DN"
		rlRun "/usr/bin/ldapsearch -x -h $LDAPSERVER -p $LDAPPORT -D \"cn=Directory Manager\" -w $DMPASSWD -b \"$USER1DN\"" 0 "Verify $USER1 exists"
		rlRun "/usr/bin/ldapsearch -x -h $LDAPSERVER -p $LDAPPORT -D \"cn=Directory Manager\" -w $DMPASSWD -b \"$USER2DN\"" 0 "Verify $USER2 exists"
	rlPhaseEnd

        rlPhaseStartTest "ds-cloud-integration-002 Search for LDAP Groups"
		rlRun "/usr/bin/ldapsearch -x -h $LDAPSERVER -p $LDAPPORT -D \"cn=Directory Manager\" -w $DMPASSWD -b \"$GROUP1DN\"" 0 "Verify $GROUP1 exists"
        rlPhaseEnd
}

cleanup()
{
        rlPhaseStartTest "Any cleanup you want to do to get you back to a known state"
		rlPass "Placeholder"
        rlPhaseEnd
}

