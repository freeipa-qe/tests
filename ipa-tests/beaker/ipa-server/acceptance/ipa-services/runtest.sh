#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-services
#   Description: ipa-services acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
#   Date  : Fri Jan 14 02:10:13 IST 2011
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

# Include test case file
. ./t.ipa-services.sh
. ./t.ipa-services_bz.sh

PACKAGELIST="ipa-admintools"

##########################################
#   test main 
#########################################

service-add()
{ #     Add a new IPA new service.
	"service_add_001"
	"service_add_002"
	"service_add_003"
	"service_add_004"
	"service_add_005"
	"service_add_006"
	"service_add_007"
	"service_add_008"
	"service_add_009"
	"service_add_010"
	"service_add_011"
}

service-add-host()
{ #     Add hosts that can manage this service.
	"service_add_host_001"
	"service_add_host_002"
	"service_add_host_003"
	"service_add_host_004"
	"service_add_host_005"
	"service_add_host_006"
	"service_add_host_007"
	"service_add_host_008"
}

service-del()
{ #     Delete an IPA service.
	"service_del_001"
	"service_del_002"
	"service_del_003"
	"service_del_004"
}

service-disable()
{ #      Disable the Kerberos key of a service.
	"service_disable_001"
	"service_disable_002"
	"service_disable_003"
}

service-find()
{ #         Search for IPA services.
	"service_find_001"
	"service_find_002"
	"service_find_003"
	"service_find_004"
	"service_find_005"
	"service_find_006"
	"service_find_007"
	"service_find_008"
	"service_find_009"
}

service-mod()
{ #          Modify an existing IPA service.
	"service_mod_001"
	"service_mod_002"
	"service_mod_003"
	"service_mod_004"
	"service_mod_005"
	"service_mod_006"
	"service_mod_007"
}

service-remove-host()
{ #  Remove hosts that can manage this service.
	"service_remove_host_001"
	"service_remove_host_002"
	"service_remove_host_003"
	"service_remove_host_004"
}

service-show()
{ #      Display information about an IPA service.
	"service_show_001"
	"service_show_002"
	"service_show_003"
	"service_show_004"
	"service_show_005"
}

rlJournalStart

  rlPhaseStartTest "Environment check"
	rc=0
	for item in $PACKAGELIST ; do
		rpm -qa | grep $item
		if [ $? -eq 0 ] ; then
			rlPass "$item package is installed"
		else
			rlFail "$item package NOT found!"
			rc=1
		fi
	done

  rlPhaseEnd

  #run Tests
  if [ $rc -eq 0 ] ; then
	setup
        service-add          # Add a new IPA new service.
        service-add-host     # Add hosts that can manage this service.
        service-del          # Delete an IPA service.
        service-disable      # Disable the Kerberos key of a service.
        service-find         # Search for IPA services.
        service-mod          # Modify an existing IPA service.
        service-remove-host  # Remove hosts that can manage this service.
        service-show         # Display information about an IPA service.
	service_bugs
  else
                rlLog "Environment not correct - not running tests"
  fi 

  rlJournalPrintText
  report=/tmp/rhts.report.$RANDOM.txt
  makereport $report
  rhts-submit-log -l $report

rlJournalEnd
