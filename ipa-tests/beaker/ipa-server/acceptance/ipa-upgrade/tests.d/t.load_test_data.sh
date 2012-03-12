#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.load_test_data.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA Upgade pre-load test data script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
# user
# group
# dns record
# host
# 
# hostgroup
# netgroup
# automount
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

# Users
user[1]=jack
user[2]=jill
passwd[1]=passw0rd1
passwd[2]=passw0rd2

# Groups
group[1]=managers
group[2]=managers

# DNS
dnsptr[1]=2.2.4.in-addr.arpa.
dnsptr[2]=2.3.4.in-addr.arpa.

# Hosts
host[1]=web.$DOMAIN
host[2]=ftp.$DOMAIN
ipv4[1]=4.2.2.100
ipv4[2]=4.3.2.101


######################################################################
# test suite
######################################################################
load_test_data()
{
	rlPhaseStartTest "load_test_data: add test data to IPA"
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

		# Add DNS Records (PTR)
		rlRun "ipa dnszone-add ${dnsptr[1]} --name-server=${MASTER} --admin-email=ipaqar.redhat.com"
		rlRun "ipa dnszone-add ${dnsptr[2]} --name-server=${MASTER} --admin-email=ipaqar.redhat.com"

		# Add hosts
		rlRun "ipa host-add ${host[1]} --ip-address=${ipv4[1]}"
		rlRun "ipa host-add ${host[2]} --ip-address=${ipv4[2]}"

		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
}
