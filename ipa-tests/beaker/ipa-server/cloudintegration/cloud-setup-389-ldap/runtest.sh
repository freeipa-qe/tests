#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/tests/cloudintegration/cloud-setup-389-ldap 
#   Description: Cloud Setup 389 Directory Server for LDAP Integration Testing
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Jenny Galipeau <jgalipea@redhat.com>
#   Date  : September 14, 2012
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

# Include test case file
. ./t.cloud-ds-setup.sh
. ./installds.sh


DSPACKAGELIST="389-ds-base openldap-clients"
CLIENTPACKAGELIST="openldap-clients"

##########################################
#   test main 
#########################################
rlJournalStart
  rlPhaseStartTest "Machine environment check"

        #####################################################################
        #               IS THIS MACHINE A DIRECTORY SERVER?                           #
        #####################################################################
        rc=0
        echo $LDAPSERVER | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
               	for item in $DSPACKAGELIST ; do
                        rpm -qa | grep $item
                        if [ $? -eq 0 ] ; then
                                rlPass "$item package is installed"
                        else
                                rlFail "$item package NOT found!"
                        fi
                done
                rlRun "service iptables stop" 0 "Stop the firewall on the directory server"
                installds
		rhts-sync-set -s DONE
		rhts-sync-block -s DONE $LDAPCLIENT
        else
                rlLog "Machine in recipe in not a DIRECTORY SERVER"
        fi


	#####################################################################
	# 		IS THIS MACHINE AN LDAP CLIENT?                           #
	#####################################################################
	rc=0
	echo $CLIENT | grep $HOSTNAME
	if [ $? -eq 0 ] ; then
        	for item in $CLIENTPACKAGELIST ; do
                	rpm -qa | grep $item
                        if [ $? -eq 0 ] ; then
                                        rlPass "$item package is installed"
                        else
                                        rlFail "$item package NOT found!"
                        fi
                done
		rhts-sync-block -s DONE $LDAPSERVER
		cloudldaptests	
		rhts-sync-set -s DONE
	else
		rlLog "Machine in recipe in not an LDAP CLIENT"
	fi

   rlPhaseEnd
    
   rlJournalPrintText
rlJournalEnd
