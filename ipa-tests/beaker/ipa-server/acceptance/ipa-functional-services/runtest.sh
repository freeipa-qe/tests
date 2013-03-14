#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-server/acceptance/ipa-functional-services
#   Description: IPA Services Functional tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   HTTP and HTTPS will be the services used to test the functionality
#   of kerberizing a service and testing access
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Jenny Galipeau <jgalipea@redhat.com>
#   Date  : February 9, 2011
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
. ./t.ipafunctionalservices_http.sh
. ./t.ipafunctionalservices_ldap.sh

PACKAGELIST="ipa-admintools ipa-client httpd mod_nss mod_auth_kerb 389-ds-base expect"
FEDLIST="freeipa-admintools freeipa-client httpd mod_nss mod_auth_kerb 389-ds-base expect"


##########################################
#   test main 
#########################################
rlJournalStart
  rlPhaseStartTest "Machine environment check"

        #####################################################################
        #               IS THIS MACHINE A CLIENT?                           #
        #####################################################################
        rc=0
        echo $CLIENT | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
                if [ $rc -eq 0 ] ; then

		if [ -f /etc/fedora-release ] ; then
			rlRun "rpm -q $FEDLIST"
		else
               		for item in $PACKAGELIST ; do
                        	rpm -qa | grep $item
                        	if [ $? -eq 0 ] ; then
                                	rlPass "$item package is installed"
                        	else
                                	rlFail "$item package NOT found!"
                        	fi
                	done
		fi
                	rlRun "service iptables stop" 0 "Stop the firewall on the client"
			http_testsetup
			ipafunctionalservices_http
			ldap_testsetup
			ipafunctionalservices_ldap
			rhts-sync-set -s DEFAULT
			rhts-sync-block -s SECURESETUP $BEAKERMASTER
			ipafunctionalservices_http
			disable_httpservice
			#http_testcleanup
                        ipafunctionalservices_ldap
			revoke_ldapcert
			#ldap_testcleanup
			rhts-sync-set -s SECURE
                fi
        else
                rlLog "Machine in recipe in not a CLIENT"
        fi


	#####################################################################
	# 		IS THIS MACHINE A MASTER?                           #
	#####################################################################
	rc=0
	echo $MASTER | grep $HOSTNAME
	if [ $? -eq 0 ] ; then
                mkdir /home/admin
                chown admin:admins /home/admin
		rhts-sync-block -s DEFAULT $BEAKERCLIENT
		# set minsssf and anon access on master
		/usr/bin/ldapmodify -x -D "cn=Directory Manager" -w "$ADMINPW" << EOF
dn: cn=config
changetype: modify
replace: nsslapd-minssf
nsslapd-minssf: 56
EOF

		/usr/bin/ldapmodify -x -D "cn=Directory Manager" -w "$ADMINPW" << EOF
dn: cn=config
changetype: modify
replace: nsslapd-allow-anonymous-access
nsslapd-allow-anonymous-access: off
EOF

		service dirsrv restart
		rhts-sync-set -s SECURESETUP
		rhts-sync-block -s SECURE $BEAKERCLIENT
		rlPass
	else
		rlLog "Machine in recipe in not a MASTER"
	fi

	#####################################################################
	# 		IS THIS MACHINE A SLAVE?                            #
	#####################################################################
	rc=0
        echo $SLAVE | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
		rhts-sync-block -s SECURE $BEAKERCLIENT
		rlPass
        else
                rlLog "Machine in recipe in not a SLAVE"
        fi

   rlPhaseEnd
    
   rlJournalPrintText
   report=/tmp/rhts.report.$RANDOM.txt
   makereport $report
   rhts-submit-log -l $report
rlJournalEnd
