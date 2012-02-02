#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_nismaster_setup.sh of:
#      /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration IPA Master acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
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
# nisint_nismaster_envsetup related functions
######################################################################
nisint_nismaster_envsetup()
{
	echo "$FUNCNAME"
	echo "setup-nis-server"
}

######################################################################
# nisint_nismaster_setmaps related functions
######################################################################
nisint_nismaster_setmaps()
{
	echo "$FUNCNAME"
	nisint_nismaster_setmaps_passwd
	nisint_nismaster_setmaps_shadow
	nisint_nismaster_setmaps_group
	nisint_nismaster_setmaps_hosts
	nisint_nismaster_setmaps_netgroup
	nisint_nismaster_setmaps_services
	nisint_nismaster_setmaps_automount
}


nisint_nismaster_setmaps_passwd()
{
	echo "$FUNCNAME"
}

nisint_nismaster_setmaps_shadow()
{
	echo "$FUNCNAME"
}

nisint_nismaster_setmaps_group()
{
	echo "$FUNCNAME"
}

nisint_nismaster_setmaps_hosts()
{
	echo "$FUNCNAME"
}

nisint_nismaster_setmaps_netgroup()
{
	echo "$FUNCNAME"
}

nisint_nismaster_setmaps_services()
{
	echo "$FUNCNAME"
}

nisint_nismaster_setmaps_automount()
{
	echo "$FUNCNAME"
}

