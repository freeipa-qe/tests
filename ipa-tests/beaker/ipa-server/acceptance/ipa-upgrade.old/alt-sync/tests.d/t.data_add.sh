#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.data_add.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA Upgade pre-load test data script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
# 
# automember
# selfservice
# delegation
# privilege
# permission
# 
# sudo
# hbac
# service
#   
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2012 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


######################################################################
# variables
######################################################################
### Relies on MYROLE variable to be set appropriately.  This is done
### manually or in runtest.sh
######################################################################

######################################################################
# test suite
######################################################################
data_add()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "data_add: add test data to IPA"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		KinitAsAdmin

		# Add users
		rlRun "echo ${passwd[2]}|ipa user-add ${user[1]} --first=First --last=one --password"
		rlRun "echo ${passwd[1]}|ipa user-add ${user[2]} --first=First --last=two --password"
		rlRun "echo -e \"${passwd[2]}\n${passwd[1]}\n${passwd[1]}\"|kinit ${user[1]}"
		KinitAsAdmin
		rlRun "echo -e \"${passwd[1]}\n${passwd[2]}\n${passwd[2]}\"|kinit ${user[2]}"
		KinitAsAdmin

		# Add groups
		rlRun "ipa group-add ${group[1]} --desc=GROUP_${group[1]}"
		rlRun "ipa group-add ${group[2]} --desc=GROUP_${group[2]}"

		if [ "x$USEDNS" = "xyes" ]; then
			# Add DNS Records (PTR)
			rlRun "ipa dnszone-add ${dnsptr[1]} --name-server=${MASTER}. --admin-email=ipaqar.redhat.com"
			rlRun "ipa dnszone-add ${dnsptr[2]} --name-server=${MASTER}. --admin-email=ipaqar.redhat.com"
		fi

		# Add hosts
		rlRun "ipa host-add ${host[1]} --ip-address=${ipv4[1]}"
		rlRun "ipa host-add ${host[2]} --ip-address=${ipv4[2]}"

		# Add hostgroups
		rlRun "ipa hostgroup-add ${hostgroup[1]} --desc=hostgroupdesc"
		rlRun "ipa hostgroup-add ${hostgroup[2]} --desc=hostgroupdesc"
		rlRun "ipa hostgroup-add-member ${hostgroup[1]} --hosts=${host[1]}"
		rlRun "ipa hostgroup-add-member ${hostgroup[2]} --hosts=${host[2]}"

		# Add netgroups
		rlRun "ipa netgroup-add ${netgroup[1]} --desc=netgroupdesc"
		rlRun "ipa netgroup-add ${netgroup[2]} --desc=netgroupdesc"
		rlRun "ipa netgroup-add-member ${netgroup[1]} --hosts=${host[1]} --users=${user[1]}"
		rlRun "ipa netgroup-add-member ${netgroup[2]} --hosts=${host[2]} --users=${user[2]}"
		
		# Add automount
		rlRun "ipa automountlocation-add testloc"
		#rlRun "ipa automountmap-add testloc ${automountmap[1]}" auto.master is a default
		rlRun "ipa automountmap-add testloc ${automountmap[2]}"
		rlRun "ipa automountmap-add testloc ${automountmap[3]}"
		for i in $(seq 1 3); do
			ORIGIFS="$IFS"
			IFS=$'\n'
			for line in $(echo "${automountkey[$i]}"); do
				IFS="$ORIGIFS"
				key=$(echo  "$line" | awk '{print $1}')
				info=$(echo "$line" | sed -e "s#^$key[ \t]*##")
				rlRun "ipa automountkey-add testloc ${automountmap[$i]} --key=\"$key\" --info=\"$info\""
			done
		done

		# Add Delegations
		rlRun "ipa delegation-add delegation_open_gecos --group=ipausers --membergroup=ipausers --attrs=gecos"
		KinitAsUser ${user[1]} ${passwd[1]}
		rlRun "ipa user-mod ${user[2]} --gecos=TEST${user[1]}"
		KinitAsAdmin
		
		# Add Selfservice 
		rlRun "ipa selfservice-add selfservice_update_gecos --attrs=gecos"
		KinitAsUser ${user[1]} ${passwd[1]}
		rlRun "ipa user-mod ${user[1]} --gecos=TEST${user[1]}"
		KinitAsAdmin

		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}


data_add_2()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "data_add_2: add test data to IPA for version 2.2.0 updates"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		KinitAsAdmin

		# Add automember rules
		rlRun "ipa group-add ${amgroup[1]} --desc=desc"
		rlRun "ipa hostgroup-add ${amhostgroup[1]} --desc=desc"
		rlRun "ipa automember-add ${amgroup[1]} --type=group"
		rlRun "ipa automember-add ${amhostgroup[1]} --type=hostgroup"
		rlRun "ipa automember-add-condition ${amgroup[1]} --type=group --key=sn --inclusive=one"
		rlRun "ipa automember-add-condition ${amhostgroup[1]} --type=hostgroup --key=fqdn --exclusive-regex=^${host[2]}"
		rlRun "ipa automember-add-condition ${amhostgroup[1]} --type=hostgroup --key=fqdn --inclusive-regex=^.*\.${DOMAIN}"
		rlRun "ipa user-add ${amuser[1]} --first=First --last=one"
		rlRun "ipa user-add ${amuser[2]} --first=First --last=two"
		rlRun "ipa host-add ${amhost[1]} --force"
		rlRun "ipa host-add ${amhost[2]} --force"
		
		# Add data for ssh?
		# Add data for selinux?

		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
