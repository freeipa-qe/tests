#/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-host-cli
#   Description: IPA host CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  host-add                  Add a new host.
#  host-del                  Delete an existing host.
#  host-find                 Search the hosts.
#  host-mod                  Edit an existing host.
#  host-show                 Examine an existing host.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Asha Akkiangady <aakkiang@redhat.com>
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
. /dev/shm/ipa-host-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################

# figure out what my active eth is from the machine's route
currenteth=$(/sbin/ip -6 route show | grep ^default | awk '{print $5}' | head -1)

# get the ip address of that interface
ipv6addr=$(ifconfig $currenteth | grep "inet6 " | grep -E 'Scope:Site|Scope:Global' | awk '{print $3}' | awk -F / '{print $1}' | head -1)

oct1=$(echo $ipv6addr | awk -F : '{print $1}')
oct2=$(echo $ipv6addr | awk -F : '{print $2}')
oct3=$(echo $ipv6addr | awk -F : '{print $3}')
oct4=$(echo $ipv6addr | awk -F : '{print $4}')
oct5=$(echo $ipv6addr | awk -F : '{print $5}')
oct6=$(echo $ipv6addr | awk -F : '{print $6}')
oct7=$(echo $ipv6addr | awk -F : '{print $7}')
oct8=$(echo $ipv6addr | awk -F : '{print $8}')

	
    rlPhaseStartSetup "ipa-host-cli-startup: Check for admintools package and Kinit"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd

rlPhaseStartTest "ipa-host-cli-81: Add host with IPv6 address DNS Record --no-reverse"
        short=mytestIPv6host
        myhost=$short.$DOMAIN
       	new_oct5="ffff"
        rlLog "IPv6 address = $ipv6addr"
        ipv6_addr=$oct1":"$oct2":"$oct3":"$oct4":"$new_oct5":"$oct6":"$oct7":"$oct8
        rlLog "New IPv6 address = $ipv6_addr"
        export ipv6_addr
        rlLog "ipa host-add --ip-address=$ipv6_addr --no-reverse $myhost" 
        rlRun "ipa host-add --ip-address=$ipv6_addr --no-reverse $myhost" 0 "Adding host with IPv6 Address $ipv6_addr and no reverse entry"
        rlRun "findHost $myhost" 0 "Verifying host was added with IPv6 Address."
        rlRun "ipa dnsrecord-find $DOMAIN $short" 0 "Checking for forward DNS entry"
        #rlRun "ipa dnsrecord-find $rzone 99" 1 "Checking for reverse DNS entry"
        rlRun "ipa host-del --updatedns $myhost" 0 "cleanup - delete $myhost"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-82: Add host with IPv6 address and DNS Record"
       short=mytestIPv6host
       myhost=$short.$DOMAIN
       new_oct5="ffff"
       ipv6_addr=$oct1":"$oct2":"$oct3":"$oct4":"$new_oct5":"$oct6":"$oct7":"$oct8
       rlLog "IPv6 address = $ipv6addr"
       rzone_IPv6=`getReverseZone_IPv6 $ipv6addr`
       rlLog "Reverse Zone: $rzone_IPv6"
       if [ $rzone_IPv6 ] ; then
                rlLog "echo $MASTER | ipa dnszone-add $rzone_IPv6 --admin-email=admin@example.com"
                rlRun "echo $MASTER | ipa dnszone-add $rzone_IPv6 --admin-email=admin@example.com" 0 "Reverse zone for ipv6 adress added."
                export ipv6_addr
                rlLog "EXECUTING: ipa host-add --ip-address=$ipv6_addr $myhost"
                rlRun "ipa host-add --ip-address=$ipv6_addr $myhost" 0 "Adding host with IPv6 Address $ipv6_addr"
                rlRun "findHost $myhost" 0 "Verifying host was added with IP Address."
                rlRun "ipa dnsrecord-find $DOMAIN $short" 0 "Checking for forward DNS entry"
                recordname_ipv6=""
                for item in $oct8 $oct7 $oct6 $new_oct5 ; do
			while [ ${#item} -lt 4 ]
                        do
                               	item="0"$item
                        done
                        for (( i=4; $i >= 1; i-- ))
                        do
                                digit=`echo $item | cut -c $i`
                                recordname_ipv6=$recordname_ipv6$digit
                                if [ "$item" == "$new_oct5" ] && [ "$i" -eq 1 ] ; then
                                        rlLog "Final digit."
                                else
                                        recordname_ipv6=$recordname_ipv6"."
                                fi
                        done

                done
                rlLog "ipa dnsrecord-find $rzone_IPv6 $recordname_ipv6"
                rlRun "ipa dnsrecord-find $rzone_IPv6 $recordname_ipv6" 0 "Checking for reverse DNS entry"
        else
                rlFail "Reverse DNS zone not found."
        fi
       # rlRun "ipa host-del --updatedns $myhost" 0 "cleanup - delete $myhost"
       # rlRun "ipa dnszone-del $rzone_IPv6" 0 "cleanup - delete dnszone"
    rlPhaseEnd

   rlPhaseStartTest "ipa-host-cli-83: Delete host without deleting DNS Record"
        short=mytestIPv6host
        myhost=$short.$DOMAIN
        new_oct5="ffff"
	rzone_IPv6=`getReverseZone_IPv6 $ipv6addr`
        rlRun "deleteHost $myhost" 0 "Deleting host without deleting DNS entries"
        rlRun "ipa dnsrecord-find $DOMAIN $short" 0 "Checking for forward DNS entry"
	recordname_ipv6=""
        for item in $oct8 $oct7 $oct6 $new_oct5 ; do
		while [ ${#item} -lt 4 ]
                do
                     	item="0"$item
                done
        	for (( i=4; $i >= 1; i-- ))
                do
                        digit=`echo $item | cut -c $i`
                        recordname_ipv6=$recordname_ipv6$digit
                        if [ "$item" == "$new_oct5" ] && [ "$i" -eq 1 ] ; then
                        	rlLog "Final digit."
                        else
                        	recordname_ipv6=$recordname_ipv6"."
                        fi
                done
         done
    	 rlRun "ipa dnsrecord-find $rzone_IPv6 $recordname_ipv6" 0 "Checking for reverse DNS entry"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-84: Add host without force option - DNS Record Exists"
        short=mytestIPv6host
        myhost=$short.$DOMAIN
        new_oct5="ffff"
	rzone_IPv6=`getReverseZone_IPv6 $ipv6addr`
        rlLog "EXECUTING: ipa host-add $myhost"
        rlRun "ipa host-add $myhost" 0 "Add host DNS entries exist"
        rlRun "findHost $myhost" 0 "Verifying host was added when DNS records exist."
        rlRun "ipa dnsrecord-find $DOMAIN $short" 0 "Checking for forward DNS entry"
	recordname_ipv6=""
        for item in $oct8 $oct7 $oct6 $new_oct5 ; do
 		while [ ${#item} -lt 4 ]
                do
                       item="0"$item
                done
                for (( i=4; $i >= 1; i-- ))
                do
                        digit=`echo $item | cut -c $i`
                        recordname_ipv6=$recordname_ipv6$digit
                        if [ "$item" == "$new_oct5" ] && [ "$i" -eq 1 ] ; then
                                rlLog "Final digit."
                        else
                                recordname_ipv6=$recordname_ipv6"."
                        fi
                done
        done
        rlRun "ipa dnsrecord-find $rzone_IPv6 $recordname_ipv6" 0 "Checking for reverse DNS entry"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-host-cli-85: Delete Host and Update DNS"
        short=mytestIPv6host
        myhost=$short.$DOMAIN
	rzone_IPv6=`getReverseZone_IPv6 $ipv6addr`
        new_oct5="ffff"
        rlRun "ipa host-del --updatedns $myhost" 0 "Delete host and update DNS"
        rlRun "findHost $myhost" 1 "Verifying host was deleted."
        rlRun "ipa dnsrecord-show $DOMAIN $ipv6_addr" 2 "Checking for forward DNS entry"
	recordname_ipv6=""
        for item in $oct8 $oct7 $oct6 $new_oct5 ; do
		while [ ${#item} -lt 4 ] 
		do
			item="0"$item
		done
                for (( i=4; $i >= 1; i-- ))
                do
                        digit=`echo $item | cut -c $i`
                        recordname_ipv6=$recordname_ipv6$digit
                        if [ "$item" == "$new_oct5" ] && [ "$i" -eq 1 ] ; then
                                rlLog "Final digit."
                        else
                                recordname_ipv6=$recordname_ipv6"."
                        fi
                done
        done
        rlRun "ipa dnsrecord-show $rzone_IPv6 $recordname_ipv6" 2 "Checking for reverse DNS entry"
	rlRun "ipa dnszone-del $rzone_IPv6" 0 "cleanup - delete dnszone"
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-host-cli-cleanup: Destroying admin credentials."
        rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd

