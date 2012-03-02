#!/bin/bash
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#######################################################################
# VARIABLES
#######################################################################
ngroup1=testg1
ngroup2=testgaga2
ngroup3=mynewng3
user1=usrjjk1r
user2=userl33t
user3=usern00b
user4=lopcr4k
group1=grpddee
group2=grplloo
group3=grpmmpp
group4=grpeeww
hgroup1=hg144335566
hgroup2=hg2
hgroup3=hg3afdsk

NETGRPDN="cn=ng,cn=alt,$BASEDN"
ENTRY="NGP Definition"

#########################################################################
# TEST SECTIONS TO RUN
#########################################################################
netgroup_bugs()
{
	netgroup_bz_772043
	netgroup_bz_788625
	netgroup_bz_772297
	netgroup_bz_766141
	netgroup_bz_767372
	# netgroup_bz_772163 # Must be tested manually right now
	netgroup_bz_750984
	netgroup_bz_796390
	netgroup_bz_797237
	netgroup_bz_797256
	netgroup_bz_794882
	netgroup_bz_798792
}

netgroup_bz_772043()
{
	rlPhaseStartTest "netgroup_bz_772043: Adding a netgroup with a + in the name that overlaps hostgroup causes crash"	
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa netgroup-add +badtestnetgroup --desc=netgroup_with_plus_kills_dirsrv" 
		rlRun "ipactl status > $tmpout 2>&1"
		if [ $(grep "Directory Service: STOPPED" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 772043 found...Adding a netgroup with a + in the name that overlaps hostgroup causes crash"
		else
			rlPass "BZ 772043 not found"
		fi

		rlLog "Now fixing DB and restarting IPA Server"
		rlRun "ns-slapd db2ldif -s '$BASEDN' -a /tmp/testrelm.ldif -D /etc/dirsrv/slapd-TESTRELM-COM/"
		rlRun "sed s/+badtestnetgroup/badtestnetgroup/g /tmp/testrelm.ldif > /tmp/testrelm.ldif.fixed"
		rlRun "ns-slapd ldif2db -D /etc/dirsrv/slapd-TESTRELM-COM/ -s "$BASEDN" -i /tmp/testrelm.ldif.fixed" 
		rlRun "ipactl restart"
		rlRun "ipa netgroup-del badtestnetgroup"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_788625()
{
	rlPhaseStartTest "netgroup_bz_788625: IPA nested netgroups not seen from ypcat"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa netgroup-add netgroup_bz_788625_test1 --desc=netgroup_bz_788625_test1"
		rlRun "ipa netgroup-add-member netgroup_bz_788625_test1 --users=admin"
		rlRun "ipa netgroup-add netgroup_bz_788625_test --desc=netgroup_bz_788625_test"
		rlRun "ipa netgroup-add-member netgroup_bz_788625_test --netgroups=netgroup_bz_788625_test1"
		rlRun "echo $ADMINPW | ipa-compat-manage enable" 0,2
		rlRun "echo $ADMINPW | ipa-nis-manage enable" 0,2
		rlRun "service rpcbind restart"
		rlRun "service dirsrv restart"
		rlRun "yum -y install yp-tools"
		if [ $(ypcat -d $DOMAIN -h localhost -k netgroup|grep "^netgroup_bz_788625_test $"|wc -l) -gt 0 ]; then
			rlFail "BZ 788625 found ...IPA nested netgroups not seen from ypcat"
		else
			rlPass "BZ 788625 not found"
		fi		
		rlRun "ipa netgroup-del netgroup_bz_788625_test1"
		rlRun "ipa netgroup-del netgroup_bz_788625_test"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_772297()
{
	rlPhaseStartTest "netgroup_bz_772297: Fails to update if all nisNetgroupTriple or memberNisNetgroup entries are deleted from a netgroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		rlRun "ipa user-add user1 --first=TEST --last=USER"
		rlRun "ipa user-add user2 --first=TEST --last=USER"
		rlRun "ipa user-add user3 --first=TEST --last=USER"
		rlRun "ipa netgroup-add users --desc=users"
		rlRun "ipa netgroup-add-member users --users=user1,user2,user3"
		rlRun "ipa netgroup-find --users=user1,user2,user3"
		rlRun "ldapsearch -x -LLL -b "dc=testrelm,dc=com" cn=users"
		rlRun "getent -s sss netgroup users"
		rlRun "ipa netgroup-remove-member users --users=user1,user2,user3"
		rlRun "sleep 120"
		if [ $(getent -s sss netgroup users|grep "^users.*user1.*user2.*user3"|wc -l) -gt 0 ]; then
			rlFail "BZ 772297 found...Fails to update if all nisNetgroupTriple or memberNisNetgroup entries are deleted from a netgroup"
		else
			rlPass "BZ 772297 not found."
		fi
			
		rlRun "ldapsearch -x -LLL -b \"dc=testrelm,dc=com\" cn=users"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_766141()
{
	rlPhaseStartTest "netgroup_bz_766141: SSSD should support FreeIPA's internal netgroup representation"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa netgroup-add $FUNCNAME --desc=$FUNCNAME"
		rlRun "ipa netgroup-add-member $FUNCNAME --users=admin"
		rlRun "cp /etc/sssd/sssd.conf /etc/sssd/sssd.conf.$FUNCNAME.backup"
		sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf
		rlRun "cat /etc/sssd/sssd.conf"
		rlRun "service sssd restart"
		rlRun "getent -s sss netgroup $FUNCNAME"
		
		# New/Native search filter uses this:  cn=ng,cn=alt,dc=testrelm,dc=com
		# OLD search filter users compat like this:  cn=ng,cn=compat,dc=testrelm,dc=com
		if [ $(grep -i "calling ldap_search_ext with.*NisNetgroup.*compat" /var/log/sssd/sssd_$DOMAIN.log|wc -l) -gt 0 ]; then
			rlFail "BZ 766141 found...SSSD should support FreeIPA's internal netgroup representation"
		else
			rlPass "BZ 766141 not found"
		fi	
		
		rlRun "mv /etc/sssd/sssd.conf.$FUNCNAME.backup /etc/sssd/sssd.conf"
		rlRun "chmod 0600 /etc/sssd/sssd.conf"
		rlRun "service sssd restart"
		rlRun "ipa netgroup-del $FUNCNAME"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}
 
netgroup_bz_767372()
{
	rlPhaseStartTest "netgroup_bz_767372: Netgroups compat plugin not reporting users correctly"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "echo $ADMINPW | ipa-compat-manage enable" 0,2
		rlRun "echo $ADMINPW | ipa-nis-manage enable" 0,2
		rlRun "service rpcbind restart"
		rlRun "service dirsrv restart"
		rlRun "ipa user-add bzuser1 --first=First --last=Last"
		rlRun "ipa user-add bzuser2 --first=First --last=Last"
		rlRun "ipa user-add bzuser3 --first=First --last=Last"
		rlRun "ipa netgroup-add $FUNCNAME --hostcat=all --desc=$FUNCNAME"
		rlRun "ipa netgroup-add-member $FUNCNAME --users=bzuser1,bzuser2,bzuser3"

		if [ $(ldapsearch -x -h $MASTER -p 389 -D "$ROOTDN" -w $ADMINPW -b "cn=test2,cn=ng,cn=compat,$BASEDN" | grep Triple|grep "(-," | wc -l) -gt 0 ]; then
			rlFail "BZ 767372 found...Netgroups compat plugin not reporting users correctly"
		else
			rlPass "BZ 767372 not found."
		fi

		rlRun "ipa netgroup-del $FUNCNAME"
		rlRun "ipa user-del bzuser1"
		rlRun "ipa user-del bzuser2"
		rlRun "ipa user-del bzuser3"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

#netgroup_bz_772163()
#{
#	rlPhaseStartTest "netgroup_bz_772163: Iterator loop reuse cases a tight loop in the native IPA netgroups code"
#		rlLog "This is not yet automated.  Please test manually?"	
#	rlPhaseEnd
#}

netgroup_bz_750984()
{
	rlPhaseStartTest "netgroup_bz_750984: Inconsistency in error message while adding a duplicate netgroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#### test1
		rlRun "ipa hostgroup-add netgroup_bz_750984 --desc=netgroup_bz_750984"
		rlRun "ipa netgroup-add netgroup_bz_750984 --desc=netgroup_bz_750984 > $tmpout 2>&1" 1
		if [ $(grep "Hostgroups and netgroups share a common namespace" $tmpout|wc -l) -gt 0 ]; then
			rlPass "BZ 750984 not found."
		else
			rlFail "BZ 750984 found...Inconsistency in error message while adding a duplicate netgroup"
		fi
		rlRun "ipa hostgroup-del netgroup_bz_750984"
		
		#### test2
		rlRun "ipa netgroup-add netgroup_bz_750984 --desc=netgroup_bz_750984" 
		rlRun "ipa hostgroup-add netgroup_bz_750984 --desc=netgroup_bz_750984 > $tmpout 2>&1" 1
		if [ $(grep "Hostgroups and netgroups share a common namespace" $tmpout|wc -l) -gt 0 ]; then
			rlPass "BZ 750984 not found."
		else
			rlFail "BZ 750984 found...Inconsistency in error message while adding a duplicate netgroup"
		fi
		rlRun "ipa netgroup-del netgroup_bz_750984"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_796390()
{
	rlPhaseStartTest "netgroup_bz_796390: ipa netgroup-add with both --desc and --addattr=description returns internal error"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa netgroup-add netgroup_bz_796390 --desc=desc1 --addattr=description=desc2 > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 796390 found...ipa netgroup-add with both --desc and --addattr=description returns internal error"
		else
			rlPass "BZ 796390 not found."
		fi
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_797237()
{
	rlPhaseStartTest "netgroup_bz_797237: ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
		local tmpout=/tmp/errormsg.out
		KinitAsAdmin
		#### test1
		rlRun "ipa netgroup-add netgroup_bz_797237_1 --desc=desc1 --nisdomain=test1,test2 > $tmpout 2>&1" 1
		if [ $(grep "test1,test2" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
		else
			rlPass "BZ 797237 not found for netgroup-add with comma"
		fi
		rlRun "ipa netgroup-del netgroup_bz_797237_1"

		#### test2
		rlRun "ipa netgroup-add netgroup_bz_797237_2 --desc=desc2 --nisdomain=test^\|\!\@\#\$\%\&\*\\)\\( > $tmpout 2>&1" 1      
		if [ $(grep "test^\|\!\@\#\$\%\&\*\\\)\\\(" $tmpout | wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
			rlFail "This BZ also covers other invalid characters"
		else
			rlPass "BZ 797237 not found for netgroup-add --nisdomain with other invalid chars"
		fi
		rlRun "ipa netgroup-del netgroup_bz_797237_1"

		#### test3
		rlRun "ipa netgroup-add netgroup_bz_797237_3 --desc=desc3"
		rlRun "ipa netgroup-mod netgroup_bz_797237_3 --nisdomain=test3,test4 > $tmpout 2>&1" 1
		if [ $(grep "test3,test4" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
		else
			rlPass "BZ 797237 not found for netgroup-mod --nisdomain with comma."
		fi
		rlRun "ipa netgroup-del netgroup_bz_797237_1"
		
		
		#### test4
		rlRun "ipa netgroup-add netgroup_bz_797237_4 --desc=desc4"
		rlRun "ipa netgroup-mod netgroup_bz_797237_4 --setattr=nisdomainname=test5,test6 > $tmpout 2>&1" 1
		if [ $(grep "test5,test6" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
		else
			rlPass "BZ 797237 not found for netgroup-mod --setattr=nisdomainname with comma."
		fi
		rlRun "ipa netgroup-del netgroup_bz_797237_1"
		[ -f $tmpout ] && rm -f $tmpout

		#### test5 
		rlRun "ipa netgroup-add netgroup_bz_797237_5 --desc=desc5"
		rlRun "ipa netgroup-mod netgroup_bz_797237_5 --setattr=nisdomain=test^\|\!\@\#\$\%\&\*\\)\\( > $tmpout 2>&1" 1
		if [ $(grep "test^\|\!\@\#\$\%\&\*\\\)\\\(" $tmpout | wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
			rlFail "This BZ also covers other invalid characters"
		else
			rlPass "BZ 797237 not found for netgroup-add --nisdomain with other invalid chars"
		fi
		rlRun "ipa netgroup-del netgroup_bz_797237_5"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_797256()
{
	rlPhaseStartTest "netgroup_bz_797256: ipa netgroup-add-member --hosts should not allow invalid characters"
		local tmpout=/tmp/errormsg.out
		KinitAsAdmin
		#### test1
		rlRun "ipa netgroup-add netgroup_bz_797256_1 --desc=desc1"
		rlRun "ipa netgroup-add-member netgroup_bz_797256_1 --hosts=badhost? > $tmpout 2>&1" 1
		if [ $(grep "badhost\?" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797256 Found...ipa netgroup-add-member --hosts should not allow invalid characters"
		else
			rlPass "BZ 797256 not found for ipa netgroup-add-member --hosts with ?"
		fi
		rlRun "ipa netgroup-del netgroup_bz_797256_1"

		#### test2
		rlRun "ipa netgroup-add netgroup_bz_797256_2 --desc=desc2"
		rlRun "ipa netgroup-add-member netgroup_bz_797256_2 --hosts=badhost\!\@\#\$\%\^\&\*\\(\\) > $tmpout 2>&1" 1
		if [ $(grep "badhost\!\@\#\$\%\^\&\*\\(\\)" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797256 Found...ipa netgroup-add-member --hosts should not allow invalid characters"
		else
			rlPass "BZ 797256 not found for ipa netgroup-add-member --hosts with other invalid characters"
		fi
		rlRun "ipa netgroup-del netgroup_bz_797256_2"

		#### test3	
		rlRun "ipa netgroup-add netgroup_bz_797256_3 --desc=desc3"
		rlRun "ipa netgroup-mod netgroup_bz_797256_3 --setattr=externalhost=anotherbadhost? > $tmpout 2>&1"
		if [ $(grep "anotherbadhost\?" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797256 Found...ipa netgroup-add-member --hosts should not allow invalid characters"
		else
			rlPass "BZ 797256 not found for ipa netgroup-add-member --hosts with ?"
		fi
		rlRun "ipa netgroup-del netgroup_bz_797256_3"
		
		#### test4
		rlRun "ipa netgroup-add netgroup_bz_797256_4 --desc=desc4"
		rlRun "ipa netgroup-mod netgroup_bz_797256_4 --addattr=externalhost=anotherbadhost\!\@\#\$\%\^\&\*\\(\\) > $tmpout 2>&1" 1
		if [ $(grep "anotherbadhost\!\@\#\$\%\^\&\*\\(\\)" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797256 Found...ipa netgroup-add-member --hosts should not allow invalid characters"
		else
			rlPass "BZ 797256 not found for ipa netgroup-add-member --hosts with other invalid characters"
		fi
		rlRun "ipa netgroup-del netgroup_bz_797256_4"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_794882()
{
	rlPhaseStartTest "netgroup_bz_794882: ipa netgroup-find --hosts=<hostname> not working (for external hosts)"
		local tmpout=/tmp/errormsg.out
		KinitAsAdmin
		rlRun "ipa host-add ipahost.testrelm.com --force"
		rlRun "ipa netgroup-add netgroup_bz_794882 --desc=desc1"
		rlRun "ipa netgroup-add-member netgroup_bz_794882 --hosts=externalhost.external.com"
		rlRun "ipa netgroup-find --hosts=externalhost.external.com > $tmpout 2>&1"
		if [ $(grep "^0 netgroups matched$" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 794882 found...ipa netgroup-find --hosts=<hostname> not working (for external hosts)"
		else
			rlPass "BZ 794882 not found"
		fi
		rlRun "ipa netgroup-add-member netgroup_bz_794882 --hosts=ipahost.testrelm.com"
		rlRun "ipa netgroup-find --hosts=ipahost.testrelm.com > $tmpout 2>&1"
		if [ $(grep "Host: ipahost.testrelm.com" $tmpout |wc -l) -gt 0 ]; then
			rlPass "Member Host found.  Tech note for BZ 794882 valid"
		else
			rlFail "Member Host not found.  Tech note for BZ 794882 not valid"
		fi
		rlRun "ipa netgroup-del netgroup_bz_794882"
		rlRun "ipa host-del ipahost.testrelm.com"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_798792()
{

	local tmpout=/tmp/errormsg.out
	rlPhaseStartTest "netgroup_bz_798792_1: ipa netgroup-find options set to space return internal errors (netgroups)"
		rlRun "ipa netgroup-find --netgroups=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_bz_798792_2: ipa netgroup-find options set to space return internal errors (no-netgroups)"
		rlRun "ipa netgroup-find --no-netgroups=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_bz_798792_3: ipa netgroup-find options set to space return internal errors (users)"
		rlRun "ipa netgroup-find --users=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_bz_798792_4: ipa netgroup-find options set to space return internal errors (no-users)"
		rlRun "ipa netgroup-find --no-users=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_bz_798792_5: ipa netgroup-find options set to space return internal errors (groups)"
		rlRun "ipa netgroup-find --groups=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_bz_798792_6: ipa netgroup-find options set to space return internal errors (no-groups)"
		rlRun "ipa netgroup-find --no-groups=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_bz_798792_7: ipa netgroup-find options set to space return internal errors (hosts)"
		rlRun "ipa netgroup-find --hosts=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_bz_798792_8: ipa netgroup-find options set to space return internal errors (no-hosts)"
		rlRun "ipa netgroup-find --no-hosts=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_bz_798792_9: ipa netgroup-find options set to space return internal errors (hostgroups)"
		rlRun "ipa netgroup-find --hostgroups=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_bz_798792_10: ipa netgroup-find options set to space return internal errors (no-hostgroups)"
		rlRun "ipa netgroup-find --no-hostgroups=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_bz_798792_11: ipa netgroup-find options set to space return internal errors (in-netgroups)"
		rlRun "ipa netgroup-find --in-netgroups=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_bz_798792_12: ipa netgroup-find options set to space return internal errors (not-in-netgroups)"
		rlRun "ipa netgroup-find --not-in-netgroups=\" \" > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}
