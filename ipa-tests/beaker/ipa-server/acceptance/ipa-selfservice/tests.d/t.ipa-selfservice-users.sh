#!/bin/bash

validAttrs="givenname sn cn displayname title initials loginshell gecos homephone mobile pager facsimiletelephonenumber telephonenumber street roomnumber l st postalcode manager secretary description carlicense labeleduri inetuserhttpurl seealso employeetype businesscategory ou"
validParams="first last cn displayname initials homedir gecos shell email uid gidnumber street city state postalcode phone mobile pager fax orgunit title manager carlicense"

selfservice_usertest()
{
	selfservice_usertest_envsetup
	selfservice_usertest_positive
}

selfservice_usertest_envsetup()
{
	rlPhaseStartTest "selfservice-usertest-1000: Setup users and selfservice rules for user tests"
		kinitAsAdmin
		# add phonenumbers rule --attrs="homephone, mobile, pager, facsimiletelephonenumber, telephonenumber"
		rlRun "ipa selfservice-add rule0001 --attrs=\"homephone, mobile, pager, facsimiletelephonenumber, telephonenumber\"" 
		# add user0001 passw0rd
		rlRun "ipa user-add --first=Test --last=User0001 user0001"
		rlRun "mkdir /home/user0001"
		rlRun "chown user0001:user0001 /home/user0001"
		rlRun "echo -ne \"passw0rd\\\npassw0rd\\\n\" | ipa passwd user0001"
		rlRun "su - user0001 -c \"echo -ne \\\"passw0rd\\\\\npassw0rd1\\\\\npassw0rd1\\\\\n\\\" | kinit\""	
		# add user0002 passw0rd
		rlRun "ipa user-add --first=Test --last=User0002 user0002"
		rlRun "mkdir /home/user0002"
		rlRun "chown user0002:user0002 /home/user0002"
		rlRun "echo -ne \"passw0rd\\\npassw0rd\\\n\" | ipa passwd user0002"
		rlRun "su - user0002 -c \"echo -ne \\\"passw0rd\\\\\npassw0rd1\\\\\npassw0rd1\\\\\n\\\" | kinit\""	
	rlPhaseEnd
}
	
userModQuickTest()
{
	type=$1
	srcname=$2
	tgtname=$3
	attrs=$4

	if [ "$type" = "pass" ]; then
	
		rlRun "su - $srcname -c \"echo passw0rd1|kinit $srcname; ipa user-mod $tgtname $attrs\"" 0 "Change user data ($attrs) should pass"
		rlRun "ipa user-find $tgtname $attrs" 0 "Confirm user data ($attrs) change passed"

	elif [ "$type" = "fail" ]; then 

		rlRun "su - $srcname -c \"echo passw0rd1|kinit $srcname; ipa user-mod $tgtname $attrs\"" 1 "Change user data ($attrs) should fail"
		rlRun "ipa user-find $tgtname $attrs" 1 "Confirm user data ($attrs) change failed" 

	else
		echo "invalid type ($type) provided to $0 function"
	fi
}
	
selfservice_usertest_positive() 
{
	rlPhaseStartTest "selfservice-usertest-1001: Quick test runs...both positive and negative right now..."
		# Check that this stuff passes properly
		userModQuickTest pass user0001 user0001 "--first=Good"
		userModQuickTest pass user0001 user0001 "--last=User"
		userModQuickTest pass user0001 user0001 "--cn=gooduser"
		userModQuickTest pass user0001 user0001 "--displayname=gooduser"
		userModQuickTest pass user0001 user0001 "--initials=GU"
		userModQuickTest pass user0001 user0001 "--homedir=/home/gooduser"
		userModQuickTest pass user0001 user0001 "--gecos=gooduser@good.example.com"
		userModQuickTest pass user0001 user0001 "--shell=/bin/tcsh"
		userModQuickTest pass user0001 user0001 "--email=gooduser@good.example.com"
		userModQuickTest pass user0001 user0001 "--uid=3333"
		userModQuickTest pass user0001 user0001 "--gidnumber=3333"
		userModQuickTest pass user0001 user0001 "--street=Good Steet Rd"
		userModQuickTest pass user0001 user0001 "--city=Good City"
		userModQuickTest pass user0001 user0001 "--state=Goodstate"
		userModQuickTest pass user0001 user0001 "--postalcode=333-333-3333"
		userModQuickTest pass user0001 user0001 "--phone=333-333-3333"
		userModQuickTest pass user0001 user0001 "--mobile=333-333-3333"
		userModQuickTest pass user0001 user0001 "--pager=333-333-3333"
		userModQuickTest pass user0001 user0001 "--fax=333-333-3333"
		userModQuickTest pass user0001 user0001 "--orgunit=good-org"
		userModQuickTest pass user0001 user0001 "--title=good_admin"
		userModQuickTest pass user0001 user0001 "--manager=good_manager"
		userModQuickTest pass user0001 user0001 "--carlicense=good-9999"

		# del default "User Self service" rule
		rlRun "ipa selfservice-del \"User Self service\""

		# Now check that these fail properly
		userModQuickTest fail user0001 user0001 "--first=Bad"
		userModQuickTest fail user0001 user0001 "--last=User"
		userModQuickTest fail user0001 user0001 "--cn=baduser"
		userModQuickTest fail user0001 user0001 "--displayname=baduser"
		userModQuickTest fail user0001 user0001 "--initials=BU"
		userModQuickTest fail user0001 user0001 "--homedir=/home/baduser"
		userModQuickTest fail user0001 user0001 "--gecos=baduser@bad.example.com"
		userModQuickTest fail user0001 user0001 "--shell=/bin/tcsh"
		userModQuickTest fail user0001 user0001 "--email=baduser@bad.example.com"
		userModQuickTest fail user0001 user0001 "--uid=9999"
		userModQuickTest fail user0001 user0001 "--gidnumber=9999"
		userModQuickTest fail user0001 user0001 "--street=Bad Steet Rd"
		userModQuickTest fail user0001 user0001 "--city=Bad City"
		userModQuickTest fail user0001 user0001 "--state=Badstate"
		userModQuickTest fail user0001 user0001 "--postalcode=999-999-9999"
		userModQuickTest fail user0001 user0001 "--phone=999-999-9999"
		userModQuickTest fail user0001 user0001 "--mobile=999-999-9999"
		userModQuickTest fail user0001 user0001 "--pager=999-999-9999"
		userModQuickTest fail user0001 user0001 "--fax=999-999-9999"
		userModQuickTest fail user0001 user0001 "--orgunit=bad-org"
		userModQuickTest fail user0001 user0001 "--title=bad_admin"
		userModQuickTest fail user0001 user0001 "--manager=bad_manager"
		userModQuickTest fail user0001 user0001 "--carlicense=bad-9999"
		
		# user0001: change self title  == (fail)
		# user0001: change self title (notallowed) and phonenumber (allowed) == (fail)

		# user0001: change passwd changem3!

		# user0001: change user0002 phone number (fail)
		# user0002: change user0001 phone number (fail)	

	rlPhaseEnd
}
