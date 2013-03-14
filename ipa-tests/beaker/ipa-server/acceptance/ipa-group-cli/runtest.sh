#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-group-cli
#   Description: IPA group CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  group-add            Create a new group.
#  group-add-member     Add members to a group.
#  group-del            Delete group.
#  group-detach         Detach a managed group from a user
#  group-find           Search for groups.
#  group-mod            Modify a group.
#  group-remove-member  Remove members from a group.
#  group-show           Display information about a named group.
#  --pkey-only          search groups using --pkey-only option
#  --in-groups          search groups using --in-groups option
#  --not-in-groups      search groups using --not-in-groups option
#  --in-netgroups       search groups using --in-netgroups option
#  --not-in-netgroups   search groups using --not-in-netgroups option

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Jenny Galipeau <jgalipea@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2010 Red Hat, Inc. All rights reserved.
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

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-group-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

# Include tests
. ./t.members.sh
. ./t.addmodify.sh
. ./t.setadddelattr.sh
. ./t.groupbugs.sh
. ./t.findgroups.sh
. ./t.renamegroup.sh

########################################################################
# Test Suite Globals
########################################################################
# ADMINID is now part of env.sh
PACKAGE="ipa-admintools"
ADMINPWD=$ADMINPW

########################################################################

PACKAGE="ipa-admintools"

rlJournalStart
   rlPhaseStartSetup "Environment Check"
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi

	# test suites to run
	members
	addmodify
	setadddelattr
	findgroups
	renamegroup
	groupbugs
    rlPhaseEnd


   rlJournalPrintText
   report=$TmpDir/rhts.report.$RANDOM.txt
   makereport $report
   rhts-submit-log -l $report
rlJournalEnd
