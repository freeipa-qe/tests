#!/bin/bash

selfservice_usertest()
{
	selfservice_usertest_envsetup
	selfservice_usertest_1001
	#selfservice_usertest_1002
	#selfservice_usertest_1003
	#selfservice_usertest_1004
	#selfservice_usertest_1005
	#selfservice_usertest_1006
	#selfservice_usertest_1007
	#selfservice_usertest_1008
	#selfservice_usertest_1009
	#selfservice_usertest_1010
	selfservice_usertest_cleanup
}

selfservice_usertest_envsetup()
{
	rlPhaseStartTest "selfservice-usertest-1000: Setup users for tests"
		rlRun "echo $ADMINPW|kinit admin"

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
	
selfservice_usertest_1001() 
{
	rlPhaseStartTest "selfservice-usertest-1001: Set all parameters allowed by default"
		rlRun "kdestroy"
		rlRun "echo passw0rd1|kinit user0001" 0 "Become user with kinit"
		rlRun "ipa user-mod user0001  --first=Good"
		rlRun "ipa user-mod user0001  --last=User"
		rlRun "ipa user-mod user0001  --cn=gooduser"
		rlRun "ipa user-mod user0001  --displayname=gooduser"
		rlRun "ipa user-mod user0001  --initials=GU"
		rlRun "ipa user-mod user0001  --gecos=gooduser@good.example.com"
		rlRun "ipa user-mod user0001  --shell=/bin/bash"
		rlRun "ipa user-mod user0001  --email=gooduser@good.example.com"
		rlRun "ipa user-mod user0001  --street=Good Steet Rd"
		rlRun "ipa user-mod user0001  --city=Good City"
		rlRun "ipa user-mod user0001  --state=Goodstate"
		rlRun "ipa user-mod user0001  --postalcode=33333"
		rlRun "ipa user-mod user0001  --phone=333-333-3333"
		rlRun "ipa user-mod user0001  --mobile=333-333-3333"
		rlRun "ipa user-mod user0001  --pager=333-333-3333"
		rlRun "ipa user-mod user0001  --fax=333-333-3333"
		rlRun "ipa user-mod user0001  --orgunit=good-org"
		rlRun "ipa user-mod user0001  --title=good_admin"
		rlRun "ipa user-mod user0001  --manager=good_manager"
		rlRun "ipa user-mod user0001  --carlicense=good-3333"
		rlRun "kdestroy"
	rlPhaseEnd
} #selfservice_usertest_1001

selfservice_usertest_1002()
{
	rlPhaseStartTest "selfservice-usertest-1002: Test that default disallowed are rejected"
		rlRun "kdestroy"
		rlRun "echo passw0rd1|kinit user0001" 0 "Become user with kinit"
		rlRun "ipa user-mod user0001  --uid=9999"                1 "By default a user should not be able to user-mod --uid"
		rlRun "ipa user-mod user0001  --gidnumber=9999"          1 "By default a user should not be able to user-mod --gidnumber"
		rlRun "ipa user-mod user0001  --homedir=/home/gooduser"  1 "By default a user should not be able to user-mod --homedir"
		rlRun "kdestroy"
	rlPhaseEnd
} #selfservice_usertest_1002

selfservice_usertest_1003()
{
	rlPhaseStartTest "selfservice-usertest-1003: Delete default rule User Self service and test params can no longer be set"
		rlRun "kdestroy"
		rlRun "echo $ADMINPW|kinit admin"
		rlRun "ipa selfservice-del \"User Self service\"" 0 "Delete the default rule User Self service"
		rlRun "kdestroy"

		rlRun "echo passw0rd1|kinit user0001" 0 "Become user with kinit"
		rlRun "ipa user-mod user0001  --first=Bad"                        1 "Should no longer be able to user-mod --first"
		rlRun "ipa user-mod user0001  --last=LUser"                       1 "Should no longer be able to user-mod --last"
		rlRun "ipa user-mod user0001  --cn=badluser"                      1 "Should no longer be able to user-mod --cn"
		rlRun "ipa user-mod user0001  --displayname=badluser"             1 "Should no longer be able to user-mod --displayname"
		rlRun "ipa user-mod user0001  --initials=BL"                      1 "Should no longer be able to user-mod --initials"
		rlRun "ipa user-mod user0001  --gecos=badluser@bad.example.com"   1 "Should no longer be able to user-mod --gecos"
		rlRun "ipa user-mod user0001  --shell=/bin/tcsh"                  1 "Should no longer be able to user-mod --shell"
		rlRun "ipa user-mod user0001  --email=badluser@bad.example.com"   1 "Should no longer be able to user-mod --email"
		rlRun "ipa user-mod user0001  --street=Bad Steet Av"              1 "Should no longer be able to user-mod --street"
		rlRun "ipa user-mod user0001  --city=Bad City"                    1 "Should no longer be able to user-mod --city"
		rlRun "ipa user-mod user0001  --state=Badstate"                   1 "Should no longer be able to user-mod --state"
		rlRun "ipa user-mod user0001  --postalcode=99999"                 1 "Should no longer be able to user-mod --postalcode"
		rlRun "ipa user-mod user0001  --phone=999-999-9999"               1 "Should no longer be able to user-mod --phone"
		rlRun "ipa user-mod user0001  --mobile=999-999-9999"              1 "Should no longer be able to user-mod --mobile"
		rlRun "ipa user-mod user0001  --pager=999-999-9999"               1 "Should no longer be able to user-mod --pager"
		rlRun "ipa user-mod user0001  --fax=999-999-9999"                 1 "Should no longer be able to user-mod --fax"
		rlRun "ipa user-mod user0001  --orgunit=bad-org"                  1 "Should no longer be able to user-mod --orgunit"
		rlRun "ipa user-mod user0001  --title=bad_admin"                  1 "Should no longer be able to user-mod --title"
		rlRun "ipa user-mod user0001  --manager=bad_manager"              1 "Should no longer be able to user-mod --manager"
		rlRun "ipa user-mod user0001  --carlicense=bad-9999"              1 "Should no longer be able to user-mod --carlicense"
		rlRun "kdestroy"
	rlPhaseEnd
} #selfservice_usertest_1003

selfservice_usertest_1004()
{
	rlPhaseStartTest "selfservice-usertest-1004: create new rule and test allowed access"
		rlRun "kdestroy"
		rlRun "echo $ADMINPW|kinit admin"
		rlRun "ipa selfservice-add rule0001 --attrs=\"mobile, pager, facsimiletelephonenumber, telephonenumber\"" 
		rlRun "kdestroy"

		rlRun "echo passw0rd1|kinit user0001"
		rlRun "ipa user-mod user0001  --phone=777-777-7777"
		rlRun "ipa user-mod user0001  --mobile=777-777-7777"
		rlRun "ipa user-mod user0001  --pager=777-777-7777"
		rlRun "ipa user-mod user0001  --fax=777-777-7777"
		rlRun "kdestroy"
	rlPhaseEnd
} #selfservice_usertest_1004

selfservice_usertest_1005()
{
	rlPhaseStartTest "selfservice-usertest-1005: check the user's attribute settings"
		rlRun "kdestroy"
		rlRun "echo passw0rd1|kinit user0001" 0 "Become user with kinit"
		rlRun "ipa user-find user0001  --first=Good"
		rlRun "ipa user-find user0001  --last=User"
		rlRun "ipa user-find user0001  --cn=gooduser"
		rlRun "ipa user-find user0001  --displayname=gooduser"
		rlRun "ipa user-find user0001  --initials=GU"
		rlRun "ipa user-find user0001  --gecos=gooduser@good.example.com"
		rlRun "ipa user-find user0001  --shell=/bin/bash"
		rlRun "ipa user-find user0001  --email=gooduser@good.example.com"
		rlRun "ipa user-find user0001  --street=Good Steet Rd"
		rlRun "ipa user-find user0001  --city=Good City"
		rlRun "ipa user-find user0001  --state=Goodstate"
		rlRun "ipa user-find user0001  --postalcode=33333"
		rlRun "ipa user-find user0001  --phone=777-777-7777"
		rlRun "ipa user-find user0001  --mobile=777-777-7777"
		rlRun "ipa user-find user0001  --pager=777-777-7777"
		rlRun "ipa user-find user0001  --fax=777-777-7777"
		rlRun "ipa user-find user0001  --orgunit=good-org"
		rlRun "ipa user-find user0001  --title=good_admin"
		rlRun "ipa user-find user0001  --manager=good_manager"
		rlRun "ipa user-find user0001  --carlicense=good-3333"
		rlRun "kdestroy"
	rlPhaseEnd	
} #selfservice_usertest_1005
		
selfservice_usertest_1006()
{
	rlPhaseStartTest "selfservice-usertest-1006: su to user and change allowed settings"
	rlPhaseEnd
} #selfservice_usertest_1006

selfservice_usertest_1007()
{
	rlPhaseStartTest "selfservice-usertest-1007: su to user and test that disallowed params cannot be set"
	rlPhaseEnd
} #selfservice_usertest_1007

selfservice_usertest_1008()
{
	rlPhaseStartTest "selfservice-usertest-1008: confirm user-mod fails with one of multiple params is disallowed"
	rlPhaseEnd
} #selfservice_usertest_1008

selfservice_usertest_1009()
{
	rlPhaseStartTest "selfservice-usertest-1009: confirm user can change their password"
	rlPhaseEnd
} #selfservice_usertest_1009

selfservice_usertest_1010()
{
	rlPhaseStartTest "selfservice-usertest-1010: confirm user cannot change another user's attributes"
	rlPhaseEnd
} #selfservice_usertest_1010
