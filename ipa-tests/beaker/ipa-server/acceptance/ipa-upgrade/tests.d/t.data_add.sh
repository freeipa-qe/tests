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
		rlRun "echo ${passwd[1]}|ipa user-add ${user[1]} --first=First --last=Last --password"
		rlRun "echo ${passwd[2]}|ipa user-add ${user[2]} --first=First --last=Last --password"

		# Add groups
		rlRun "ipa group-add ${group[1]} --desc=GROUP_${group[1]}"
		rlRun "ipa group-add ${group[2]} --desc=GROUP_${group[2]}"

		if [ "x$USEDNS" = "xyes" ]; then
			# Add DNS Records (PTR)
			rlRun "ipa dnszone-add ${dnsptr[1]} --name-server=${MASTER} --admin-email=ipaqar.redhat.com"
			rlRun "ipa dnszone-add ${dnsptr[2]} --name-server=${MASTER} --admin-email=ipaqar.redhat.com"
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

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
