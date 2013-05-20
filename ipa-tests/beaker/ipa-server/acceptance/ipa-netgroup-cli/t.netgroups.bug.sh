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
	netgroup_bz_800625
	netgroup_bz_788625
	netgroup_bz_772297
	netgroup_bz_766141
	netgroup_bz_767372
	netgroup_bz_772163
	netgroup_bz_750984
	netgroup_bz_796390
	netgroup_bz_797237
	netgroup_bz_797256
	netgroup_bz_813325
	netgroup_bz_794882
	netgroup_bz_798792
	netgroup_bz_815481
}

netgroup_bz_772043()
{
	rlPhaseStartTest "ipa-netgroup-bugzilla-001: bz772043 Adding a netgroup with a + in the name that overlaps hostgroup causes crash"	
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		local compatenabled=$(echo "$ADMINPW"| ipa-compat-manage status|grep "Plugin.*Enabled"|wc -l)

		if [ $compatenabled -eq 0 ]; then
			rlRun "echo \"$ADMINPW\"|ipa-compat-manage enable" 0 "enabling compat plugin for test"
			rlRun "service dirsrv restart"
		fi

		rlRun "ipa netgroup-add +badtestnetgroup --desc=netgroup_with_plus_kills_dirsrv > $tmpout 2>&1" 1
		if [ $(grep "ipa: ERROR: invalid 'name': may only include letters, numbers, _, -, and ." $tmpout|wc -l) -gt 0 ]; then
			rlPass "BZ 772043 not found...fix is in place for ipa command"
		fi
			
		# now check if the directory server crashed
		rlRun "ipactl status > $tmpout 2>&1"
		if [ $(grep "Directory Service: STOPPED" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 772043 found...Adding a netgroup with a + in the name that overlaps hostgroup causes crash"

			rlLog "Now fixing DB and restarting IPA Server"
			INSTANCE=$(echo $RELM | sed 's/\./-/g')
			rlRun "ns-slapd db2ldif -s '$BASEDN' -a /tmp/export.ldif -D /etc/dirsrv/slapd-$INSTANCE/"
			rlRun "sed s/+badtestnetgroup/badtestnetgroup/g /tmp/export.ldif > /tmp/export.ldif.fixed"
			rlRun "ns-slapd ldif2db -D /etc/dirsrv/slapd-$INSTANCE/ -s "$BASEDN" -i /tmp/export.ldif.fixed" 
			rlRun "ipactl restart"
			rlRun "ipa netgroup-del badtestnetgroup"
		fi

		if [ $compatenabled -eq 0 ]; then
			rlRun "echo \"$ADMINPW\"|ipa-compat-manage disable" 0 "disable compat plugin since it was disabled before test"
			rlRun "service dirsrv restart"
		fi

		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_800625()
{
	rlPhaseStartTest "ipa-netgroup-bugzilla-002: bz800625 Bad netgroup name causes ns-slapd to segfault"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		local compatenabled=$(echo "$ADMINPW"| ipa-compat-manage status|grep "Plugin.*Enabled"|wc -l)
		if [ $compatenabled -eq 0 ]; then
			rlRun "echo \"$ADMINPW\"|ipa-compat-manage enable" 0 "enabling compat plugin for test"
			rlRun "service dirsrv restart"
		fi

		# remember that heredocs have to be intented with tabs
		cat > /tmp/netgroup_crash.ldif <<-EOF
		dn: ipaUniqueID=170df1b8-688b-11e1-9cfb-5254000ea1b4,cn=ng,cn=alt,$BASEDN
		objectClass: ipaobject
		objectClass: ipaassociation
		objectClass: ipanisnetgroup
		cn: +badtestnetgroup
		description: netgroup_with_plus_kills_dirsrv
		nisDomainName: testrelm.com
		ipaUniqueID: 170df1b8-688b-11e1-9cfb-5254000ea1b4
		EOF

		rlRun "ldapmodify -a -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f /tmp/netgroup_crash.ldif"

		# now check if the directory server crashed
		rlRun "ipactl status > $tmpout 2>&1"
		if [ $(grep "Directory Service: STOPPED" $tmpout|wc -l) -eq 0 ]; then
			rlPass "BZ 800625 not found..."
		else
			rlFail "BZ 800625 found...Bad netgroup name causes ns-slapd to segfault"

			rlLog "Now fixing DB and restarting IPA Server"
			INSTANCE=$(echo $RELM | sed 's/\./-/g')
			rlRun "ns-slapd db2ldif -s '$BASEDN' -a /tmp/export.ldif -D /etc/dirsrv/slapd-$INSTANCE/"
			rlRun "sed s/+badtestnetgroup/badtestnetgroup/g /tmp/export.ldif > /tmp/export.ldif.fixed"
			rlRun "ns-slapd ldif2db -D /etc/dirsrv/slapd-$INSTANCE/ -s "$BASEDN" -i /tmp/export.ldif.fixed" 
			rlRun "ipactl restart"
			rlRun "ipa netgroup-del badtestnetgroup"
		fi

		if [ $compatenabled -eq 0 ]; then
			rlRun "echo \"$ADMINPW\"|ipa-compat-manage disable" 0 "disable compat plugin since it was disabled before test"
			rlRun "service dirsrv restart"
		fi

		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_788625()
{
	rlPhaseStartTest "ipa-netgroup-bugzilla-003: bz788625 IPA nested netgroups not seen from ypcat"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa netgroup-add netgroup_bz_788625_test1 --desc=netgroup_bz_788625_test1"
		rlRun "ipa netgroup-add-member netgroup_bz_788625_test1 --users=admin"
		rlRun "ipa netgroup-add netgroup_bz_788625_test --desc=netgroup_bz_788625_test"
		rlRun "ipa netgroup-add-member netgroup_bz_788625_test --netgroups=netgroup_bz_788625_test1"
		rlRun "echo $ADMINPW | ipa-compat-manage enable" 0,2
		rlRun "echo $ADMINPW | ipa-nis-manage enable" 0,2
		rlRun "service rpcbind restart"
		rlRun "rlDistroDiff dirsrv_svc_restart"
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
	rlPhaseStartTest "ipa-netgroup-bugzilla-004: bz772297 Fails to update if all nisNetgroupTriple or memberNisNetgroup entries are deleted from a netgroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		rlRun "/bin/cp -f /etc/sssd/sssd.conf /etc/sssd/sssd.conf.$FUNCNAME.backup"
		rlLog "Running: sed -i 's/\(\[domain.*\]\)$/\1\nentry_cache_timeout = 120/' /etc/sssd/sssd.conf"
		sed -i 's/\(\[domain.*\]\)$/\1\nentry_cache_timeout = 120/' /etc/sssd/sssd.conf
		rlRun "cat /etc/sssd/sssd.conf"
		rlRun "service sssd restart"
		rlRun "ipa user-add nguser1 --first=TEST --last=USER"
		rlRun "ipa user-add nguser2 --first=TEST --last=USER"
		rlRun "ipa user-add nguser3 --first=TEST --last=USER"
		rlRun "ipa netgroup-add usersng --desc=users"
		rlRun "ipa netgroup-add-member usersng --users=nguser1,nguser2,nguser3"
		rlRun "ipa netgroup-find --users=nguser1,nguser2,nguser3"
		rlRun "ldapsearch -x -LLL -b "dc=testrelm,dc=com" cn=usersng"
		rlRun "getent -s sss netgroup usersng"
		rlRun "ipa netgroup-remove-member usersng --users=nguser1,nguser2,nguser3"
		rlRun "sleep 120"
		if [ $(getent -s sss netgroup usersng|grep "^usersng.*nguser1.*nguser2.*nguser3"|wc -l) -gt 0 ]; then
			rlRun "getent -s sss netgroup usersng"
			rlFail "BZ 772297 found...Fails to update if all nisNetgroupTriple or memberNisNetgroup entries are deleted from a netgroup"
		else
			rlPass "BZ 772297 not found."
		fi
			
		rlRun "ldapsearch -x -LLL -b \"dc=testrelm,dc=com\" cn=usersng"
		rlRun "ipa user-del nguser1"
		rlRun "ipa user-del nguser2"
		rlRun "ipa user-del nguser3"
		rlRun "ipa netgroup-del usersng"
		rlRun "/bin/cp -f /etc/sssd/sssd.conf.$FUNCNAME.backup /etc/sssd/sssd.conf"
		rlRun "/bin/rm /etc/sssd/sssd.conf.$FUNCNAME.backup"
		rlRun "chmod 0600 /etc/sssd/sssd.conf"
		rlRun "service sssd restart"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_766141()
{
	rlPhaseStartTest "ipa-netgroup-bugzilla-005: bz766141 SSSD should support FreeIPA's internal netgroup representation"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa netgroup-add $FUNCNAME --desc=$FUNCNAME"
		rlRun "ipa netgroup-add-member $FUNCNAME --users=admin"
		rlRun "cp -f /etc/sssd/sssd.conf /etc/sssd/sssd.conf.$FUNCNAME.backup"
		rlLog "Running: sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf"
		sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf
		rlRun "cat /etc/sssd/sssd.conf"
		rlRun "service sssd restart"
		rlRun "sleep 5"
		rlRun "getent -s sss netgroup $FUNCNAME"
		
		# New/Native search filter uses this:  cn=ng,cn=alt,dc=testrelm,dc=com
		# OLD search filter users compat like this:  cn=ng,cn=compat,dc=testrelm,dc=com
		if [ $(grep -i "calling ldap_search_ext with.*NisNetgroup.*compat" /var/log/sssd/sssd_$DOMAIN.log|wc -l) -gt 0 ]; then
			rlFail "BZ 766141 found...SSSD should support FreeIPA's internal netgroup representation"
		else
			rlPass "BZ 766141 not found"
		fi	
		
		rlRun "cp -f /etc/sssd/sssd.conf.$FUNCNAME.backup /etc/sssd/sssd.conf"
		rlRun "rm /etc/sssd/sssd.conf.$FUNCNAME.backup"
		rlRun "chmod 0600 /etc/sssd/sssd.conf"
		rlRun "service sssd restart"
		rlRun "ipa netgroup-del $FUNCNAME"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}
 
netgroup_bz_767372()
{
	rlPhaseStartTest "ipa-netgroup-bugzilla-006: bz767372 Netgroups compat plugin not reporting users correctly"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "echo $ADMINPW | ipa-compat-manage enable" 0,2
		rlRun "echo $ADMINPW | ipa-nis-manage enable" 0,2
		rlRun "service rpcbind restart"
		rlRun "rlDistroDiff dirsrv_svc_restart"
		rlRun "ipa user-add bzuser1 --first=First --last=Last"
		rlRun "ipa user-add bzuser2 --first=First --last=Last"
		rlRun "ipa user-add bzuser3 --first=First --last=Last"
		rlRun "ipa netgroup-add $FUNCNAME --hostcat=all --desc=$FUNCNAME"
		rlRun "ipa netgroup-add-member $FUNCNAME --users=bzuser1,bzuser2,bzuser3"

		if [ $(ldapsearch -x -h $MASTER -p 389 -D "$ROOTDN" -w $ADMINPW -b "cn=$FUNCNAME,cn=ng,cn=compat,$BASEDN" | grep Triple|grep "(-," | wc -l) -gt 0 ]; then
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

netgroup_bz_772163()
{
	rlPhaseStartTest "ipa-netgroup-bugzilla-007: bz772163 Iterator loop reuse cases a tight loop in the native IPA netgroups code"
		# Variables
		local tmpout=/tmp/errormsg.out
		local timeout=/tmp/timer.$FUNCNAME
		local ngname=testnetgroup1000
		local userpre=testuser1000
		# Pre-work
		rlLog "Adding necessary users and netgroup for test"
		rlRun "ipa user-add ${userpre}0 --first=first --last=last"
		rlRun "ipa user-add ${userpre}1 --first=first --last=last"
		rlRun "ipa user-add ${userpre}2 --first=first --last=last"
		rlRun "ipa netgroup-add ${ngname} --desc=test"
		rlRun "ipa netgroup-add-member ${ngname} --users=${userpre}0"

		# change sssd params
		rlLog "Setting SSSD cache timeout low to test"
		rlRun "sed -i 's/\(\[domain.*\]\)$/\1\nentry_cache_timeout = 1/' /etc/sssd/sssd.conf"
		rlRun "service sssd restart"

		# Test that you can see the initial netgroup
		rlLog "Waiting for 5 seconds for SSSD to completely start up"
		rlRun "sleep 5"
		rlRun "time getent netgroup ${ngname}"

		# Check new user entries added to netgroup
		rlLog "Add another member to netgroup and check if it shows up from getent"
		rlRun "date"
		rlRun "ipa netgroup-add-member ${ngname} --users=${userpre}1"
		rlRun "date"
		rlRun "sleep 10"
		rlRun "(time getent netgroup ${ngname} > $tmpout 2>&1) 2>&1 | tee $timeout"
		rlRun "cat $tmpout"
		if [ $(grep ${userpre}1 $tmpout|wc -l) -gt 0 ]; then
			rlPass "BZ 772163 not found...added user seen in netgroup"
		else
			rlFail "New user not found in netgroup.  Appears that SSSD used cached entry."
			if [ $(grep real $timeout|sed 's/^.*m\([0-9]*\)\..*$/\1/') -gt 2 ]; then
				rlFail "Took longer than 2 seconds to run getent for SSSD netgroup lookup"
			fi	
			rlFail "BZ 772163 found...Iterator loop reuse cases a tight loop in the native IPA netgroups code"
		fi
		
		# Checking one more time to be safe
		rlLog "Add another member to netgroup and check if it shows up from getent"
		rlRun "date"
		rlRun "ipa netgroup-add-member ${ngname} --users=${userpre}2"
		rlRun "date"
		rlRun "sleep 10"
		rlRun "(time getent netgroup ${ngname} > $tmpout 2>&1) 2>&1 | tee $timeout"
		rlRun "cat $tmpout"
		if [ $(grep ${userpre}2 $tmpout|wc -l) -gt 0 ]; then
			rlPass "BZ 772163 not found...added user seen in netgroup"
		else
			rlFail "New user not found in netgroup.  Appears that SSSD used cached entry."
			if [ $(grep real $timeout|sed 's/^.*m\([0-9]*\)\..*$/\1/') -gt 2 ]; then
				rlFail "Took longer than 2 seconds to run getent for SSSD netgroup lookup"
			fi	
			rlFail "BZ 772163 found...Iterator loop reuse cases a tight loop in the native IPA netgroups code"
		fi

		# cleanup
		rlLog "Cleaning up after $FUNCNAME test"
		rlRun "ipa netgroup-del ${ngname}"
		for i in 0 1 2; do
			rlLog "Deleting user ${userpre}${i}"
			rlRun "ipa user-del ${userpre}${i}"
		done
		rlLog "Resetting SSSD to default cache timeout"
		rlRun "sed -i '/entry_cache_timeout = 1/d' /etc/sssd/sssd.conf"
		rlRun "service sssd restart"

		[ -f $tmpout ] && rm -f $tmpout
		[ -f $timeout ] && rm -f $timeout
	rlPhaseEnd
}

netgroup_bz_750984()
{
	rlPhaseStartTest "ipa-netgroup-bugzilla-008: bz750984 Inconsistency in error message while adding a duplicate netgroup"
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
	rlPhaseStartTest "ipa-netgroup-bugzilla-009: bz796390 ipa netgroup-add with both --desc and --addattr=description returns internal error"
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
	rlPhaseStartTest "ipa-netgroup-bugzilla-010: bz797237 ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
		local tmpout=/tmp/errormsg.out
		KinitAsAdmin
		#### test1
		rlRun "ipa netgroup-add netgroup_bz_797237_1 --desc=desc1 --nisdomain=test1,test2 > $tmpout 2>&1" 1
		if [ $(grep "NIS domain.*name:.*test1,test2" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
		else
			rlPass "BZ 797237 not found for netgroup-add with comma"
		fi
		rlRun "ipa netgroup-del netgroup_bz_797237_1" 2

		#### test2
		rlRun "ipa netgroup-add netgroup_bz_797237_2 --desc=desc2 --nisdomain=test^\|\!\@\#\$\%\&\*\\)\\( > $tmpout 2>&1" 1      
		if [ $(grep "NIS domain.*name:.*test^\|\!\@\#\$\%\&\*\\\)\\\(" $tmpout | wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
			rlFail "This BZ also covers other invalid characters"
		else
			rlPass "BZ 797237 not found for netgroup-add --nisdomain with other invalid chars"
		fi
		rlRun "ipa netgroup-del netgroup_bz_797237_2" 2

		#### test3
		rlRun "ipa netgroup-add netgroup_bz_797237_3 --desc=desc3"
		rlRun "ipa netgroup-mod netgroup_bz_797237_3 --nisdomain=test3,test4 > $tmpout 2>&1" 1
		if [ $(grep "NIS domain.*name:.*test3,test4" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
		else
			rlPass "BZ 797237 not found for netgroup-mod --nisdomain with comma."
		fi
		rlRun "ipa netgroup-del netgroup_bz_797237_3"
		
		
		#### test4
		rlRun "ipa netgroup-add netgroup_bz_797237_4 --desc=desc4"
		rlRun "ipa netgroup-mod netgroup_bz_797237_4 --setattr=nisdomainname=test5,test6 > $tmpout 2>&1" 1
		if [ $(grep "NIS domain.*name:.*test5,test6" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
		else
			rlPass "BZ 797237 not found for netgroup-mod --setattr=nisdomainname with comma."
		fi
		rlRun "ipa netgroup-del netgroup_bz_797237_4" 
		[ -f $tmpout ] && rm -f $tmpout

		#### test5 
		rlRun "ipa netgroup-add netgroup_bz_797237_5 --desc=desc5"
		rlRun "ipa netgroup-mod netgroup_bz_797237_5 --setattr=nisdomain=test^\|\!\@\#\$\%\&\*\\)\\( > $tmpout 2>&1" 1
		if [ $(grep "NIS domain.*name:.*test^\|\!\@\#\$\%\&\*\\\)\\\(" $tmpout | wc -l) -gt 0 ]; then
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
	rlPhaseStartTest "ipa-netgroup-bugzilla-011: bz797256 ipa netgroup-add-member --hosts should not allow invalid characters"
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

		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_813325()
{
	rlPhaseStartTest "ipa-netgroup-bugzilla-012: bz813325 ipa netgroup-mod addattr and setattr allow invalid characters for externalHost"
		local tmpout=/tmp/errormsg.out
		KinitAsAdmin
		#### test1	
		rlRun "ipa netgroup-add netgroup_bz_813325_1 --desc=desc1"
		rlRun "ipa netgroup-mod netgroup_bz_813325_1 --setattr=externalhost=anotherbadhost? > $tmpout 2>&1" 1
		if [ $(grep "anotherbadhost\?" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 813325 Found...ipa netgroup-add-member --hosts should not allow invalid characters"
		else
			rlPass "BZ 813325 not found for ipa netgroup-add-member --hosts with ?"
		fi
		rlRun "ipa netgroup-del netgroup_bz_813325_1"
		
		#### test2
		rlRun "ipa netgroup-add netgroup_bz_813325_2 --desc=desc2"
		rlRun "ipa netgroup-mod netgroup_bz_813325_2 --addattr=externalhost=anotherbadhost\!\@\#\$\%\^\&\*\\(\\) > $tmpout 2>&1" 1
		if [ $(grep "anotherbadhost\!\@\#\$\%\^\&\*\\(\\)" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 813325 Found...ipa netgroup-add-member --hosts should not allow invalid characters"
		else
			rlPass "BZ 813325 not found for ipa netgroup-add-member --hosts with other invalid characters"
		fi
		rlRun "ipa netgroup-del netgroup_bz_813325_2"

		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

netgroup_bz_794882()
{
	rlPhaseStartTest "ipa-netgroup-bugzilla-013: bz794882 ipa netgroup-find --hosts=<hostname> not working (for external hosts)"
		local tmpout=/tmp/errormsg.out
		KinitAsAdmin
		rlRun "ipa host-add ipahost.testrelm.com --force"
		rlRun "ipa netgroup-add netgroup_bz_794882 --desc=desc1"
		rlRun "ipa netgroup-add-member netgroup_bz_794882 --hosts=externalhost.external.com"
		rlRun "ipa netgroup-find --hosts=externalhost.external.com > $tmpout 2>&1" 1
		if [ $(grep "^0 netgroups matched$" $tmpout|wc -l) -gt 0 ]; then
			rlPass "BZ 794882  Works as expected: ipa netgroup-find --hosts=<hostname> ::  not found for external hosts"
		else
			rlFail "BZ 794882 fixed to find external hosts"
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
	rlPhaseStartTest "ipa-netgroup-bugzilla-014: bz798792 ipa netgroup-find options set to space return internal errors (netgroups)"
		rlRun "ipa netgroup-find --netgroups=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-015: bz798792 ipa netgroup-find options set to space return internal errors (no-netgroups)"
		rlRun "ipa netgroup-find --no-netgroups=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-016: bz798792 ipa netgroup-find options set to space return internal errors (users)"
		rlRun "ipa netgroup-find --users=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-017: bz798792 ipa netgroup-find options set to space return internal errors (no-users)"
		rlRun "ipa netgroup-find --no-users=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-018: bz798792 ipa netgroup-find options set to space return internal errors (groups)"
		rlRun "ipa netgroup-find --groups=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-019: bz798792 ipa netgroup-find options set to space return internal errors (no-groups)"
		rlRun "ipa netgroup-find --no-groups=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-020: bz798792 ipa netgroup-find options set to space return internal errors (hosts)"
		rlRun "ipa netgroup-find --hosts=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-021: bz798792 ipa netgroup-find options set to space return internal errors (no-hosts)"
		rlRun "ipa netgroup-find --no-hosts=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-022: bz798792 ipa netgroup-find options set to space return internal errors (hostgroups)"
		rlRun "ipa netgroup-find --hostgroups=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-023: bz798792 ipa netgroup-find options set to space return internal errors (no-hostgroups)"
		rlRun "ipa netgroup-find --no-hostgroups=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-024: bz798792 ipa netgroup-find options set to space return internal errors (in-netgroups)"
		rlRun "ipa netgroup-find --in-netgroups=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-025: bz798792 ipa netgroup-find options set to space return internal errors (not-in-netgroups)"
		rlRun "ipa netgroup-find --not-in-netgroups=\" \" > $tmpout 2>&1" 0
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

netgroup_bz_815481()
{
	# Test for https://bugzilla.redhat.com/show_bug.cgi?id=815481
	# 815481 -  hostgroup and netgroup names with one letter not allowed
	
	rlPhaseStartTest "ipa-netgroup-bugzilla-026: bz815481 Test Adding a single char group named A"
		rlRun "ipa netgroup-add A --desc=desc1" 0 "Try adding group named A"
		rlRun "ipa netgroup-find A" 0 "Make sure that the group exists"
		ipa netgroup-del A
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-027: bz815481 Test Adding a single char group named a"
		rlRun "ipa netgroup-add a --desc=desc1" 0 "Try adding group named a"
		rlRun "ipa netgroup-find a" 0 "Make sure that the group exists"
		ipa netgroup-del a
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-028: bz815481 Test Adding a single char group named r"
		rlRun "ipa netgroup-add r --desc=desc1" 0 "Try adding group named r"
		rlRun "ipa netgroup-find r" 0 "Make sure that the group exists"
		ipa netgroup-del r
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-bugzilla-029: bz815481 Test Adding a single char group named z"
		rlRun "ipa netgroup-add z --desc=desc1" 0 "Try adding group named z"
		rlRun "ipa netgroup-find z" 0 "Make sure that the group exists"
		ipa netgroup-del z
	rlPhaseEnd
}

