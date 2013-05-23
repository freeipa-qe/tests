#!/bin/bash

selfservice_usertest()
{
	selfservice_usertest_envsetup
	selfservice_usertest_1001
	selfservice_usertest_1002
	selfservice_usertest_1003
	selfservice_usertest_1004
	selfservice_usertest_1005
	selfservice_usertest_1006
	selfservice_usertest_1007
	selfservice_usertest_1008
	selfservice_usertest_1009
	selfservice_usertest_1010
	selfservice_usertest_envcleanup
}

selfservice_usertest_envsetup()
{
	rlPhaseStartSetup "selfservice-usertest-envsetup Setup users for tests"
                rlRun "rlDistroDiff keyctl"
		KinitAsAdmin
		create_ipauser user0001 Test User0001 passw0rd1
		rlRun "mkdir /home/user0001"
		rlRun "chown -R user0001:user0001 /home/user0001"
		create_ipauser user0002 Test User0002 passw0rd2
		rlRun "mkdir /home/user0002"
		rlRun "chown -R user0002:user0002 /home/user0002"
		create_ipauser good_manager Good Manager passw0rd3
		rlRun "mkdir /home/good_manager"
		rlRun "chown -R good_manager:good_manager /home/good_manager"
		create_ipauser bad_manager Bad Manager passw0rd4
		rlRun "mkdir /home/bad_manager"
		rlRun "chown -R bad_manager:bad_manager /home/bad_manager"
	rlPhaseEnd
} #selfservice_usertest_envsetup
	
selfservice_usertest_envcleanup()
{

	rlPhaseStartCleanup "selfservice-usertest-envcleanup Cleanup users and rules created by tests"
                rlRun "rlDistroDiff keyctl"
		delete_ipauser user0001
		delete_ipauser user0002
		delete_ipauser good_manager
		delete_ipauser bad_manager
                rlRun "rlDistroDiff keyctl"
		KinitAsAdmin             # this is needed because delete_ipauser does a kdestroy...
		rlRun "rm -rf /home/user0001"
		rlRun "rm -rf /home/user0002"
		rlRun "rm -rf /home/good_manager"
		rlRun "rm -rf /home/bad_manager"
		rlRun "ipa selfservice-del rule0001"
		rlRun "ipa selfservice-add \"User Self service\" --attrs=\"givenname, sn, cn, displayname, title, initials, loginshell, gecos, homephone, mobile, pager, facsimiletelephonenumber, telephonenumber, street, roomnumber, l, st, postalcode, manager, secretary, description, carlicense, labeleduri, inetuserhttpurl, seealso, employeetype, businesscategory, ou\"" 0 "Re-Create the previously deleted default rule"
	rlPhaseEnd
} #selfservice_usertest_envcleanup

selfservice_usertest_1001() 
{
	rlPhaseStartTest "ipa-selfservice-usertest-1001: Set all parameters allowed by default"
                rlRun "rlDistroDiff keyctl"
		KinitAsUser user0001 passw0rd1	
		rlRun "ipa user-mod user0001  --first=Good"
		rlRun "ipa user-mod user0001  --last=User"
		rlRun "ipa user-mod user0001  --cn=gooduser"
		rlRun "ipa user-mod user0001  --displayname=gooduser"
		rlRun "ipa user-mod user0001  --initials=GU"
		rlRun "ipa user-mod user0001  --gecos=gooduser@good.example.com"
		rlRun "ipa user-mod user0001  --shell=/bin/bash"
		rlRun "ipa user-mod user0001  --street=Good_Steet_Rd"
		rlRun "ipa user-mod user0001  --city=Good_City"
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
	rlPhaseEnd
} #selfservice_usertest_1001

selfservice_usertest_1002()
{
	rlPhaseStartTest "ipa-selfservice-usertest-1002: Test that default disallowed are rejected"
                rlRun "rlDistroDiff keyctl"
		KinitAsUser user0001 passw0rd1
		rlRun "ipa user-mod user0001  --uid=9999"                1 "By default a user should not be able to user-mod --uid"
		rlRun "ipa user-mod user0001  --gidnumber=9999"          1 "By default a user should not be able to user-mod --gidnumber"
		rlRun "ipa user-mod user0001  --homedir=/home/gooduser"  1 "By default a user should not be able to user-mod --homedir"
		rlRun "ipa user-mod user0001  --email=gooduser@good.example.com" 1 "By default a user should not be able to user-mod --email"
	rlPhaseEnd
} #selfservice_usertest_1002

selfservice_usertest_1003()
{
	rlPhaseStartTest "ipa-selfservice-usertest-1003: Delete default rule User Self service and test params can no longer be set"
                rlRun "rlDistroDiff keyctl"
		KinitAsAdmin
		rlRun "ipa selfservice-del \"User Self service\"" 0 "Delete the default rule User Self service"

                rlRun "rlDistroDiff keyctl"
		KinitAsUser user0001 passw0rd1
		rlRun "ipa user-mod user0001  --first=Bad"                        1 "Should no longer be able to user-mod --first"
		rlRun "ipa user-mod user0001  --last=LUser"                       1 "Should no longer be able to user-mod --last"
		rlRun "ipa user-mod user0001  --cn=badluser"                      1 "Should no longer be able to user-mod --cn"
		rlRun "ipa user-mod user0001  --displayname=badluser"             1 "Should no longer be able to user-mod --displayname"
		rlRun "ipa user-mod user0001  --initials=BL"                      1 "Should no longer be able to user-mod --initials"
		rlRun "ipa user-mod user0001  --gecos=badluser@bad.example.com"   1 "Should no longer be able to user-mod --gecos"
		rlRun "ipa user-mod user0001  --shell=/bin/tcsh"                  1 "Should no longer be able to user-mod --shell"
		rlRun "ipa user-mod user0001  --street=Bad_Steet_Av"              1 "Should no longer be able to user-mod --street"
		rlRun "ipa user-mod user0001  --city=Bad_City"                    1 "Should no longer be able to user-mod --city"
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
	rlPhaseEnd
} #selfservice_usertest_1003

selfservice_usertest_1004()
{
	rlPhaseStartTest "ipa-selfservice-usertest-1004: create new rule and test write access"
                rlRun "rlDistroDiff keyctl"
		KinitAsAdmin
		rlRun "ipa selfservice-add rule0001 --attrs=\"mobile, pager, facsimiletelephonenumber, telephonenumber\"" 

                rlRun "rlDistroDiff keyctl"
		KinitAsUser user0001 passw0rd1
		rlRun "ipa user-mod user0001  --phone=777-777-7777"
		rlRun "ipa user-mod user0001  --mobile=777-777-7777"
		rlRun "ipa user-mod user0001  --pager=777-777-7777"
		rlRun "ipa user-mod user0001  --fax=777-777-7777"
	rlPhaseEnd
} #selfservice_usertest_1004

selfservice_usertest_1005()
{
	rlPhaseStartTest "ipa-selfservice-usertest-1005: check the user's attribute settings"
		tmpout=$TmpDir/selfservice_usertest.out
                rlRun "rlDistroDiff keyctl"
		KinitAsUser user0001 passw0rd1
		rlRun "ipa user-find user0001  --first=Good"
		rlRun "ipa user-find user0001  --last=User"
		rlRun "ipa user-find user0001  --cn=gooduser"
		rlRun "ipa user-find user0001  --displayname=gooduser"
		rlRun "ipa user-find user0001  --initials=GU"
		rlRun "ipa user-find user0001  --gecos=gooduser@good.example.com"
		rlRun "ipa user-find user0001  --shell=/bin/bash"
		rlRun "ipa user-find user0001  --street=Good_Steet_Rd"
		rlRun "ipa user-find user0001  --city=Good_City"
		rlRun "ipa user-find user0001  --state=Goodstate"
		rlRun "ipa user-find user0001  --postalcode=33333"
		rlRun "ipa user-find user0001  --phone=777-777-7777"
		rlRun "ipa user-find user0001  --mobile=777-777-7777"
		rlRun "ipa user-find user0001  --pager=777-777-7777"
		rlRun "ipa user-find user0001  --fax=777-777-7777"
		rlRun "ipa user-find user0001  --orgunit=good-org"
		rlRun "ipa user-find user0001  --title=good_admin"
		rlRun "ipa user-find user0001  --manager=good_manager > $tmpout 2>&1"
		if [ $(grep "Number of entries returned 0$" $tmpout|wc -l) -eq 1 ]; then
			rlFail "BZ 781208 -- ipa user-find --manager does not find matches"
			cat $tmpout
		fi
		rlRun "ipa user-find user0001  --carlicense=good-3333"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd	
} #selfservice_usertest_1005
		
selfservice_usertest_1006()
{
	rlPhaseStartTest "ipa-selfservice-usertest-1006: su to user and change allowed settings"
                rlRun "rlDistroDiff keyctl"
		rlRun "su - user0001 -c \"echo passw0rd1|kinit user0001; ipa user-mod user0001 --mobile=888-888-8888\"" \
			0 "Su to user, kinit, and run user-map against allowed attribute"
	rlPhaseEnd
} #selfservice_usertest_1006

selfservice_usertest_1007()
{
	rlPhaseStartTest "ipa-selfservice-usertest-1007: su to user and test that disallowed params cannot be set"
		tmpout=$TmpDir/selfservice_usertest.out
                rlRun "rlDistroDiff keyctl"
		rlRun "su - user0001 -c \"echo passw0rd1|kinit user0001; ipa user-mod user0001 --title=Dr\" > $tmpout 2>&1" \
			1 "Su to user, kinit, and confirm user-map against disallowed attribute fails"
		rlAssertGrep "ipa: ERROR: Insufficient access:.*write.*title.*user0001" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
} #selfservice_usertest_1007

selfservice_usertest_1008()
{
	rlPhaseStartTest "ipa-selfservice-usertest-1008: confirm user-mod fails with one of multiple params is disallowed"
		tmpout=$TmpDir/selfservice_usertest.out
                rlRun "rlDistroDiff keyctl"
		KinitAsUser user0001 passw0rd1
		rlRun "ipa user-mod user0001 --title=notgonnawork --phone=999-999-9990 > $tmpout 2>&1" \
			1 "confirm user-mod fails with one of multiple params is disallowed"
		rlRun "ipa user-find user0001 --phone=999-999-9990" 1 "Confirm user-map attrs did not changed after failure"
		rlAssertGrep "ipa: ERROR: Insufficient access:.*write.*title.*user0001" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
} #selfservice_usertest_1008

selfservice_usertest_1009()
{
	rlPhaseStartTest "ipa-selfservice-usertest-1009: confirm user can change their password"
                rlRun "rlDistroDiff keyctl"
		KinitAsAdmin
		local minLifeOrig=$(ipa pwpolicy-show|grep "Min lifetime (hours):"|awk '{print $4}')
		rlRun "ipa pwpolicy-mod --minlife=0" 0 "Set Minimum (in hrs) time between password changes to zero (0)"
                rlRun "rlDistroDiff keyctl"
		KinitAsUser user0001 passw0rd1
		rlRun "echo mynewp@55 | ipa user-mod user0001 --password" 0 "changing user's own password with ipa user-mod"
		rlRun "echo -ne \"mynewp@55\\\nMyN3wP@55\\\nMyN3wP@55\\\n\"|ipa passwd user0001" 0 "changing user's own password with ipa password"
		if [ $minLifeOrig -ne 0 ]; then
                        rlRun "rlDistroDiff keyctl"
			KinitAsAdmin
			rlRun "ipa pwpolicy-mod --minlife=$minLifeOrig" 0 "Set Minimum (in hrs) time between password changes to $minLifeOrig"
		fi
	rlPhaseEnd
} #selfservice_usertest_1009

selfservice_usertest_1010()
{
	rlPhaseStartTest "ipa-selfservice-usertest-1010: confirm user cannot change another user's attributes"
		tmpout=$TmpDir/selfservice_usertest.out
                rlRun "rlDistroDiff keyctl"
		KinitAsUser user0002 passw0rd2
		rlRun "ipa user-mod user0001 --mobile=867-5309 > $tmpout 2>&1" 1 "Confirm user cannot change another user's attributes"
		rlAssertGrep "ipa: ERROR: Insufficient access:.*write.*mobile.*user0001" $tmpout
		rlRun "ipa user-find user0001 --mobile=867-5309" 1 "Confirm user-map attrs did not changed after failure"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
} #selfservice_usertest_1010
