#/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   ipa-host-cli-ipv6.sh of /CoreOS/ipa-tests/acceptance/ipa-host-cli
#   Description: IPA host CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Tests to add hosts with IPv6 address
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
. /opt/rhqa_ipa/ipa-host-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

########################################################################
# Test Suite Globals
########################################################################

# get the IPv6 address 
ipv6addr=$(/usr/bin/dig +short -t aaaa `hostname`)

# Another way to get IPv6 address
# figure out what my active eth is from the machine's route
#currenteth=$(/sbin/ip -6 route show | grep ^default | awk '{print $5}' | head -1)
# get the ip address of that interface
#ipv6addr=$(ifconfig $currenteth | grep "inet6 " | grep -E 'Scope:Site|Scope:Global' | awk '{print $3}' | awk -F / '{print $1}' | head -1)

oct1=$(echo $ipv6addr | awk -F : '{print $1}')
oct2=$(echo $ipv6addr | awk -F : '{print $2}')
oct3=$(echo $ipv6addr | awk -F : '{print $3}')
oct4=$(echo $ipv6addr | awk -F : '{print $4}')
oct5=$(echo $ipv6addr | awk -F : '{print $5}')
oct6=$(echo $ipv6addr | awk -F : '{print $6}')
oct7=$(echo $ipv6addr | awk -F : '{print $7}')
oct8=$(echo $ipv6addr | awk -F : '{print $8}')

########################################################################

 run_host_add_ipv6_tests(){

    rlPhaseStartSetup 
	rlRun "tmpDir=\`mktemp -d\`" 0 "Creating temp directory"
        rlRun "pushd $tmpDir"
    rlPhaseEnd

rlPhaseStartTest "ipa-host-cli-87 Add host with IPv6 address DNS Record --no-reverse"
        short=mytestIPv6host
        myhost=$short.$DOMAIN
        new_oct5="ffff"
        rlLog "IPv6 address = $ipv6addr"
        ipv6_addr=$oct1":"aa":"bb":"$oct4":"$new_oct5":"$oct6":"$oct7":"$oct8
        rlLog "New IPv6 address = $ipv6_addr"
        rlLog "ipa host-add --ip-address=$ipv6_addr --no-reverse $myhost"
        rlRun "ipa host-add --ip-address=$ipv6_addr --no-reverse $myhost" 0 "Adding host with IPv6 Address $ipv6_addr and no reverse entry"
        rlRun "findHost $myhost" 0 "Verifying host was added."
        rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns.out" 0 "Checking for forward DNS entry"
        MSG="AAAA record: $ipv6_addr"
        rlAssertGrep "$MSG" "$tmpDir/forward_dns.out"
        rzone_IPv6=`getReverseZone_IPv6 $ipv6_addr`
        rlLog "Reverse Zone: $rzone_IPv6"
        if [ $rzone_IPv6 ] ; then
                #check dnszone exist
                ipa dnszone-find $rzone_IPv6 | grep "Zone name: $rzone_IPv6"
                if [ $? -ne 0 ] ; then
                        rlPass "Reverse zone for ipv6 adress is not created"
                else
                        rlFail "Reverse zone for ipv6 adress is created"
                fi
        fi
        rlRun "ipa host-del --updatedns $myhost" 0 "cleanup - delete $myhost"
        rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns_notexists.out" 1 "Checking for forward DNS entry"
        MSG="AAAA record: $ipv6_addr"
        rlAssertNotGrep "$MSG" "$tmpDir/forward_dns_notexists.out"

        #Test IP Address with ::
        short=mytestIPv6hostb
        myhost=$short.$DOMAIN
        ipv6_addr="2001:0db8:aa:0015::a:ef12"
        ipv6_addr_no_leading_zeros="2001:db8:aa:15::a:ef12"
        rlLog "New IPv6 address = $ipv6_addr"
        rlLog "ipa host-add --ip-address=$ipv6_addr --no-reverse $myhost"
        rlRun "ipa host-add --ip-address=$ipv6_addr --no-reverse $myhost" 0 "Adding host with IPv6 Address $ipv6_addr and no reverse entry"
        rlRun "findHost $myhost" 0 "Verifying host was added."
        rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns_2.out" 0 "Checking for forward DNS entry"
        MSG="AAAA record: $ipv6_addr_no_leading_zeros"
        rlAssertGrep "$MSG" "$tmpDir/forward_dns_2.out"
        rzone_IPv6=`getReverseZone_IPv6 $ipv6_addr`
        rlLog "Reverse Zone: $rzone_IPv6"
        if [ $rzone_IPv6 ] ; then
                #check dnszone exist
                ipa dnszone-find $rzone_IPv6 | grep "Zone name: $rzone_IPv6"
                if [ $? -ne 0 ] ; then
                        rlPass "Reverse zone for ipv6 adress is not created"
                else
                        rlFail "Reverse zone for ipv6 adress is created"
                fi
        fi
        rlRun "ipa host-del --updatedns $myhost" 0 "cleanup - delete $myhost"
        rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns_notexists.out" 1 "Checking for forward DNS entry"
        MSG="AAAA record: $ipv6_addr_no_leading_zeros"
        rlAssertNotGrep "$MSG" "$tmpDir/forward_dns_notexists.out"

	#Test IP Address with :: where :: is replaced with a zero.
        short=mytestIPv6hostc
        myhost=$short.$DOMAIN
        ipv6_addr="2620:52:0:41c9::ff:fea8:b669"
        ipv6_addr_normalized_zero_added="2620:52:0:41c9:0:ff:fea8:b669"
        rlLog "New IPv6 address = $ipv6_addr"
        rlLog "ipa host-add --ip-address=$ipv6_addr --no-reverse $myhost"
        rlRun "ipa host-add --ip-address=$ipv6_addr --no-reverse $myhost" 0 "Adding host with IPv6 Address $ipv6_addr and no reverse entry"
        rlRun "findHost $myhost" 0 "Verifying host was added."
        rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns_3.out" 0 "Checking for forward DNS entry"
        MSG="AAAA record: $ipv6_addr_normalized_zero_added"
        rlAssertGrep "$MSG" "$tmpDir/forward_dns_3.out"
        rzone_IPv6=`getReverseZone_IPv6 $ipv6_addr`
        rlLog "Reverse Zone: $rzone_IPv6"
        if [ $rzone_IPv6 ] ; then
                #check dnszone exist
                ipa dnszone-find $rzone_IPv6 | grep "Zone name: $rzone_IPv6"
                if [ $? -ne 0 ] ; then
                        rlPass "Reverse zone for ipv6 adress is not created"
                else
                        rlFail "Reverse zone for ipv6 adress is created"
                fi
        fi

        #Verify IP address exist using dig
        sleep 10
        host_ipv6addr=$(/usr/bin/dig +short -t aaaa $myhost)
        rlLog "IPv6 address: $host_ipv6addr"
        if [ "$host_ipv6addr" == "$ipv6_addr_normalized_zero_added" ] ; then
               rlPass "dig shows IPv6 Address exist"
        else
               rlFail "dig shows IPv6 Address does not exist"
        fi
        rlRun "ipa host-del --updatedns $myhost" 0 "cleanup - delete $myhost"
        rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns_notexists.out" 1 "Checking for forward DNS entry"
        MSG="AAAA record: $ipv6_addr_normalized_zero_added"
        rlAssertNotGrep "$MSG" "$tmpDir/forward_dns_notexists.out"

    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-88 Add host with IPv6 address and DNS Record"
       short=mytestIPv6host
       myhost=$short.$DOMAIN
       new_oct5="ffff"
       ipv6_addr=$oct1":"$oct2":"$oct3":"$oct4":"$new_oct5":"$oct6":"$oct7":"$oct8
       rlLog "IPv6 address = $ipv6addr"
       rzone_IPv6=`getReverseZone_IPv6 $ipv6addr`
       rlLog "Reverse Zone: $rzone_IPv6"
       if [ $rzone_IPv6 ] ; then
                #check dnszone already exist
                ipa dnszone-find $rzone_IPv6 | grep "Zone name: $rzone_IPv6"
                if [ $? -ne 0 ] ; then
                        rlLog "echo `hostname` | ipa dnszone-add $rzone_IPv6 --admin-email=admin@example.com"
                        rlRun "echo `hostname` | ipa dnszone-add $rzone_IPv6 --admin-email=admin@example.com" 0 "Reverse zone for ipv6 adress added."
                else
                        rlLog "dnszone $rzone_IPv6 exists."
                fi
                export ipv6_addr
                rlLog "EXECUTING: ipa host-add --ip-address=$ipv6_addr $myhost"
                rlRun "ipa host-add --ip-address=$ipv6_addr $myhost" 0 "Adding host with IPv6 Address $ipv6_addr"
                rlRun "findHost $myhost" 0 "Verifying host was added with IP Address."
                rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns_2.out" 0 "Checking for forward DNS entry"
                MSG="AAAA record: $ipv6_addr"
                rlAssertGrep "$MSG" "$tmpDir/forward_dns_2.out"

                 #Verify IP address exist using nslookup
		sleep 20
                rlRun "nslookup $ipv6_addr  > $tmpDir/nslookup_output.out" 0 "Checking nslookup output"
                myhost_lowercase=$(echo $myhost | tr [A-Z] [a-z])
                nslookup_msg="name = $myhost_lowercase"
                rlLog "nslookup_msg=$nslookup_msg"
                rlRun "cat  $tmpDir/nslookup_output.out"
                cat  $tmpDir/nslookup_output.out |  grep "$nslookup_msg"
                if [ $? -eq 0 ] ; then
                        rlPass "nslookup shows IPAddress exist"
                else
                        rlFail "nslookup shows IPAddress does not exist"
                fi

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
    rlPhaseEnd


   rlPhaseStartTest "ipa-host-cli-89 Delete host without deleting DNS Record"
        short=mytestIPv6host
        myhost=$short.$DOMAIN
        new_oct5="ffff"
        ipv6_addr=$oct1":"$oct2":"$oct3":"$oct4":"$new_oct5":"$oct6":"$oct7":"$oct8
	rzone_IPv6=`getReverseZone_IPv6 $ipv6addr`
        rlRun "deleteHost $myhost" 0 "Deleting host without deleting DNS entries"
	rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns_3.out" 0 "Checking for forward DNS entry"
        MSG="AAAA record: $ipv6_addr"
        rlAssertGrep "$MSG" "$tmpDir/forward_dns_3.out"
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

    rlPhaseStartTest "ipa-host-cli-90 Add host without force option - DNS Record Exists"
        short=mytestIPv6host
        myhost=$short.$DOMAIN
        new_oct5="ffff"
        ipv6_addr=$oct1":"$oct2":"$oct3":"$oct4":"$new_oct5":"$oct6":"$oct7":"$oct8
	rzone_IPv6=`getReverseZone_IPv6 $ipv6addr`
        rlLog "EXECUTING: ipa host-add $myhost"
        rlRun "ipa host-add $myhost" 0 "Add host DNS entries exist"
        rlRun "findHost $myhost" 0 "Verifying host was added when DNS records exist."
	rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns_4.out" 0 "Checking for forward DNS entry"
        MSG="AAAA record: $ipv6_addr"
        rlAssertGrep "$MSG" "$tmpDir/forward_dns_4.out"
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
        rlRun "deleteHost $myhost" 0 "Deleting host without deleting DNS entries"
	rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns_41.out" 0 "Checking for forward DNS entry"
        MSG="AAAA record: $ipv6_addr"
        rlAssertGrep "$MSG" "$tmpDir/forward_dns_41.out"

        #Verify IP address exist using nslookup
	sleep 10
        rlRun "nslookup $ipv6_addr  > $tmpDir/nslookup_2_output.out" 0 "Checking nslookup output"
        myhost_lowercase=$(echo $myhost | tr [A-Z] [a-z])
        nslookup_msg="name = $myhost_lowercase"
        rlLog "nslookup_msg=$nslookup_msg"
        rlRun "cat  $tmpDir/nslookup_2_output.out"
        cat  $tmpDir/nslookup_2_output.out |  grep "$nslookup_msg"
        if [ $? -eq 0 ] ; then
              rlPass "nslookup shows IPAddress exist"
        else
              rlFail "nslookup shows IPAddress does not exist"
        fi

    rlPhaseEnd

   rlPhaseStartTest "ipa-host-cli-91 Add host with force option - DNS Record Exists"
        short=mytestIPv6host
        myhost=$short.$DOMAIN
        new_oct5="ffff"
        ipv6_addr=$oct1":"$oct2":"$oct3":"$oct4":"$new_oct5":"$oct6":"$oct7":"$oct8
        rzone_IPv6=`getReverseZone_IPv6 $ipv6addr`
        rlLog "EXECUTING: ipa host-add $myhost --force"
        rlRun "ipa host-add $myhost --force" 0 "Add host DNS entries exist"
        rlRun "findHost $myhost" 0 "Verifying host was added when DNS records exist."
        rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns_5.out" 0 "Checking for forward DNS entry"
        MSG="AAAA record: $ipv6_addr"
        rlAssertGrep "$MSG" "$tmpDir/forward_dns_5.out"
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
	
	#Verify IP address exist using dig
        sleep 10
        host_ipv6addr=$(/usr/bin/dig +short -t aaaa $myhost)
        rlLog "IPv6 address: $host_ipv6addr"
        if [ "$host_ipv6addr" == "$ipv6_addr" ] ; then
               rlPass "dig shows IPv6 Address exist"
        else
               rlFail "dig shows IPv6 Address does not exist"
        fi

        rlRun "ipa dnsrecord-find $rzone_IPv6 $recordname_ipv6" 0 "Checking for reverse DNS entry"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-92 Delete Host and Update DNS"
        short=mytestIPv6host
        myhost=$short.$DOMAIN
	rzone_IPv6=`getReverseZone_IPv6 $ipv6addr`
        new_oct5="ffff"
        ipv6_addr=$oct1":"$oct2":"$oct3":"$oct4":"$new_oct5":"$oct6":"$oct7":"$oct8
        rlRun "ipa host-del --updatedns $myhost" 0 "Delete host and update DNS"
        rlRun "findHost $myhost" 1 "Verifying host was deleted."
        rlRun "ipa dnsrecord-show $DOMAIN $ipv6_addr" 2 "Checking for forward DNS entry"
	rlRun "ipa dnsrecord-find $DOMAIN $short > $tmpDir/forward_dns_6.out" 1
        MSG="AAAA record: $ipv6_addr"
        rlAssertNotGrep "$MSG" "$tmpDir/forward_dns_6.out"

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

    rlPhaseStartTest "ipa-host-cli-93 Negative - Add host with invalid IPv6 address"
       short=mytestIPv6host
       myhost=$short.$DOMAIN
       ipv6_addr="some:ipv6addr"
       rlLog "EXECUTING: ipa host-add --ip-address=$ipv6_addr $myhost"
       command="ipa host-add --ip-address=$ipv6_addr $myhost"
       expmsg="ipa: ERROR: invalid 'ip_address': failed to detect a valid IP address from u'$ipv6_addr'"
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-ipv6-cleanup: Remove temp directory."
	rlRun "popd"
        rlRun "rm -r $tmpDir" 0 "Removing temp directory"
    rlPhaseEnd
}

