#/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   ipa-host-cli-mac-address.sh of /CoreOS/ipa-tests/acceptance/ipa-host-cli
#   Description: IPA host CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Tests to add a host with ethers (mac-address)
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

# figure out what my active eth is from the machine's route
currenteth=$(/sbin/ip -6 route show | grep ^default | awk '{print $5}' | head -1)
if [ "X$currenteth" = "X" ]; then
	currenteth=$(/sbin/ip route show | grep ^default | awk '{print $5}' | head -1)
fi
	

# get the mac-address of that interface
#macaddr=$(ifconfig $currenteth | grep "Ethernet  HWaddr " | awk '{print $5}')
macaddr=$(cat /sys/class/net/$currenteth/address)
byte1=$(echo $macaddr | awk -F : '{print $1}')
byte2=$(echo $macaddr | awk -F : '{print $2}')
byte3=$(echo $macaddr | awk -F : '{print $3}')
byte4=$(echo $macaddr | awk -F : '{print $4}')
byte5=$(echo $macaddr | awk -F : '{print $5}')
byte6=$(echo $macaddr | awk -F : '{print $6}')

ETHER_PACKAGE="nss-pam-ldapd"
########################################################################

 run_host_add_macaddress_tests() {	
      rlPhaseStartTest "ipa-host-cli-macaddress-startup Install nss-pam-ldapd package, set ethers to ldap and create temp directory."
	rlRun "yum -y install $ETHER_PACKAGE"
	rpm -qa | grep $ETHER_PACKAGE
        if [ $? -eq 0 ] ; then
		rlPass "nss-pam-ldapd package is installed"
        else
                rlFail "nss-pam-ldapd package NOT found!"
        fi
	rlRun "cat /etc/nslcd.conf | sed -e 's/base dc=example,dc=com/base dc=testrelm,dc=com/' >/etc/nslcd.conf.modified" 0 "Set the base to IPA server"
	rlRun "/bin/mv /etc/nslcd.conf.modified /etc/nslcd.conf"
	rlRun "/sbin/service  nslcd start" 0 "Restart nslcd service"
	nsswitch_conf_file="/etc/nsswitch.conf"
	if [ -e $nsswitch_conf_file ]; then
	        rlRun "cat $nsswitch_conf_file | sed -e 's/ethers:     files/ethers:     ldap/' > /etc/nsswitch.conf.modified" 0 "Set ethers to ldap"
		rlRun "/bin/mv /etc/nsswitch.conf.modified $nsswitch_conf_file"
		rlPass "$nsswitch_conf_file updated successfully."
	else
		rlFail "$nsswitch_conf_file does not exist, distribution installation problem."
	fi
	rlRun "tmpDir=\`mktemp -d\`" 0 "Creating temp directory"
        rlRun "pushd $tmpDir"
     rlPhaseEnd

        cat /etc/redhat-release | grep "Fedora"
        if [ $? -eq 0 ] ; then
                setenforce 0
        fi
 
     rlPhaseStartTest "ipa-host-cli-94 add a host with --macaddress --force"
        myhost=mytesthost1.$DOMAIN
	new_byte6="ff"
	tmpfile="$tmpDir/hostether_$myhost_94.out"
	if [ $macaddr ] ; then	
		host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
		rlLog "EXECUTING: ipa host-add $myhost --macaddress=$host_macaddr --force" 0 "Adding host with --mac-address and --force"
		rlRun "ipa host-add $myhost --macaddress=$host_macaddr --force" 0 "Adding host with --mac-address and --force"
		rlRun "verifyHostAttr $myhost \"MAC address\" $host_macaddr" 0 "Check if MAC address was added"
		rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 0 "Get the ether value associated with the host"
		getent_macaddr=""
		for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
			if [[ ${item:0:1} = "0" ]] ; then 
				item=${item:1:1}
			fi	
			item=${item,,}
			getent_macaddr=$getent_macaddr$item":"
		done
		getent_macaddr=$getent_macaddr${new_byte6,,}
		rlAssertGrep "$getent_macaddr $myhost" "$tmpfile" 
	else
            rlFail "MAC address not found on this host."
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-95 Delete Host"
	short=mytesthost1
        myhost=$short.$DOMAIN
	rlRun "ipa host-del $myhost" 0 "Delete host that was added with --macaddress" 
	rlRun "findHost $myhost" 1 "Verifying host was deleted."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-96 Add host with --macaddress and DNS Record"
	short=mytesthost2
	myhost=$short.$DOMAIN
	new_byte6="ff"
	tmpfile="$tmpDir/hostether_$myhost_96.out"
	host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
	rzone=`getReverseZone`
	rlLog "Reverse Zone: $rzone"
	if [ $rzone ] ; then
	  if [ $macaddr ] ; then	
		oct=`echo $rzone | cut -d "i" -f 1`
		oct1=`echo $oct | cut -d "." -f 3`
		oct2=`echo $oct | cut -d "." -f 2`
		oct3=`echo $oct | cut -d "." -f 1`
		ipaddr=$oct1.$oct2.$oct3.99
		export ipaddr
		rlLog "EXECUTING: ipa host-add --macaddress=$host_macaddr --ip-address=$ipaddr $myhost"
		rlRun "ipa host-add --macaddress=$host_macaddr --ip-address=$ipaddr $myhost" 0 "Adding host with mac address $host_macaddr and IP Address $ipaddr"
		rlRun "findHost $myhost" 0 "Verifying host was added with IP Address."
		rlRun "verifyHostAttr $myhost \"MAC address\" $host_macaddr" 0 "Check if MAC address was added"
	        rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 0 "Get the ether value associated with the host"
        	getent_macaddr=""
	        for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
        	        if [[ ${item:0:1} = "0" ]] ; then
                	        item=${item:1:1}
	                fi
                        item=${item,,}
        	        getent_macaddr=$getent_macaddr$item":"
	        done
        	getent_macaddr=$getent_macaddr${new_byte6,,}
	        rlAssertGrep "$getent_macaddr $myhost" "$tmpfile"
		rlRun "ipa dnsrecord-find $DOMAIN $short" 0 "Checking for forward DNS entry"
		rlRun "ipa dnsrecord-find $rzone 99" 0 "Checking for reverse DNS entry"
	  else
	    rlFail "MAC address not found on this host."
	fi
	else
		rlFail "Reverse DNS zone not found."
	fi	
    rlPhaseEnd
  
    rlPhaseStartTest "ipa-host-cli-97 Delete host that has --macaddress without deleting DNS Record"
	short=mytesthost2
        myhost=$short.$DOMAIN
	rlRun "deleteHost $myhost" 0 "Deleting host without deleting DNS entries"
	rlRun "findHost $myhost" 1 "Verifying host was deleted."
	rlRun "ipa dnsrecord-find $DOMAIN $short" 0 "Checking for forward DNS entry"
	rlRun "ipa dnsrecord-find $rzone 99" 0 "Checking for reverse DNS entry"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-98 Add host with --macaddress without force option - DNS Record Exists"
	short=mytesthost2
        myhost=$short.$DOMAIN
	new_byte6="ff"
        tmpfile="$tmpDir/hostether_$myhost_98.out"
	if [ $macaddr ] ; then	
        	host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
		rlLog "EXECUTING: ipa host-add $myhost"
		rlRun "ipa host-add $myhost --macaddress=$host_macaddr" 0 "Add host DNS entries exist"
		rlRun "findHost $myhost" 0 "Verifying host was added when DNS records exist."
		rlRun "verifyHostAttr $myhost \"MAC address\" $host_macaddr" 0 "Check if MAC address was added"
        	rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 0 "Get the ether value associated with the host"
        	getent_macaddr=""
	        for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
        		if [[ ${item:0:1} = "0" ]] ; then
                		item=${item:1:1}
                	fi
	                item=${item,,}
        	        getent_macaddr=$getent_macaddr$item":"
	        done
        	getent_macaddr=$getent_macaddr${new_byte6,,}
	        rlAssertGrep "$getent_macaddr $myhost" "$tmpfile"
		rlRun "ipa dnsrecord-find $DOMAIN $short" 0 "Checking for forward DNS entry"
       		rlRun "ipa dnsrecord-find $rzone 99" 0 "Checking for reverse DNS entry"
	else
            rlFail "MAC address not found on this host."
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-99 Delete Host that has -macaddress and Update DNS"
	short=mytesthost2
        myhost=$short.$DOMAIN
	rlRun "ipa host-del --updatedns $myhost" 0 "Delete host that has --macaddress and update DNS"
	rlRun "findHost $myhost" 1 "Verifying host was deleted."
	rlRun "ipa dnsrecord-show $DOMAIN $ipaddr" 2 "Checking for forward DNS entry"
        rlRun "ipa dnsrecord-show $rzone 99" 2 "Checking for reverse DNS entry"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-host-cli-100 host-mod of a host with --macaddress "
        myhost=mytesthost1.$DOMAIN
	attrToModify="macaddress"
        attrToVerify1="MAC address"
	new_byte6="ff"
        tmpfile="$tmpDir/hostether_$myhost_100.out"
        if [ $macaddr ] ; then
		host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
        	value=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":ee"
                rlRun "ipa host-add $myhost --macaddress=$host_macaddr --force" 0 "Adding host with --mac-address and --force"
        	rlLog "EXECUTING : ipa host-mod --$attrToModify=\"$value\"  \"$myhost\""
		rlRun "ipa host-mod --$attrToModify=\"$value\" \"$myhost\"" 0 "Modify a host that has --macaddress attribute"
        	rlRun "verifyHostAttr $myhost \"$attrToVerify1\" \"$value\"" 0 "Verifying host $attrToVerify1 was modified."
		rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 0 "Get the ether value associated with the host"
                getent_macaddr=""
                for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
                        if [[ ${item:0:1} = "0" ]] ; then
                                item=${item:1:1}
                        fi
                        item=${item,,}
                        getent_macaddr=$getent_macaddr$item":"
                done
                getent_macaddr=$getent_macaddr"ee"
                rlAssertGrep "$getent_macaddr $myhost" "$tmpfile"
       		rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
	 else
            rlFail "MAC address not found on this host."
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-101 setattr --macaddress"
        myhost=mytesthost1.$DOMAIN
	attr="macaddress"
	new_byte6="ff"
        attrToVerify1="MAC address"
        tmpfile="$tmpDir/hostether_$myhost_101.out"
        if [ $macaddr ] ; then
                host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
                rlRun "ipa host-add $myhost --force" 0 "Adding host"
		rlRun "setAttribute host $attr $host_macaddr $myhost" 0 "Setting attribute $attr to value of $host_macaddr."
        	rlRun "verifyHostAttr $myhost \"$attrToVerify1\" \"$host_macaddr\"" 0 "Verifying host $attr was modified."
		rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 0 "Get the ether value associated with the host"
                getent_macaddr=""
                for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
                        if [[ ${item:0:1} = "0" ]] ; then
                                item=${item:1:1}
                        fi
                        item=${item,,}
                        getent_macaddr=$getent_macaddr$item":"
                done
                getent_macaddr=$getent_macaddr$new_byte6
                rlAssertGrep "$getent_macaddr $myhost" "$tmpfile"
       		rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
	 else
            rlFail "MAC address not found on this host."
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-102 setattr --macaddress and addattr on macaddress"
        myhost=mytesthost1.$DOMAIN
        attr="macaddress"
        new_byte6="ff"
        attrToVerify1="MAC address"
        tmpfile="$tmpDir/hostether_$myhost_102.out"
        if [ $macaddr ] ; then
                host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
                rlRun "ipa host-add $myhost --force" 0 "Adding host"
                rlRun "setAttribute host $attr $host_macaddr $myhost" 0 "Setting attribute $attr to value of $host_macaddr."
                rlRun "verifyHostAttr $myhost \"$attrToVerify1\" \"$host_macaddr\"" 0 "Verifying host $attr was modified."
		# shouldn't be multivalue - additional add should fail
	        command="ipa host-mod --addattr $attr=$host_macaddr $myhost"
		expmsg="ipa: ERROR: no modifications to be performed"
	        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
		rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 0 "Get the ether value associated with the host"
                getent_macaddr=""
                for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
                        if [[ ${item:0:1} = "0" ]] ; then
                                item=${item:1:1}
                        fi
                        item=${item,,}
                        getent_macaddr=$getent_macaddr$item":"
                done
                getent_macaddr=$getent_macaddr$new_byte6
                rlAssertGrep "$getent_macaddr $myhost" "$tmpfile"
                rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
         else
            rlFail "MAC address not found on this host."
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-103 Modify Host with --macaddress - host doesn't Exist"
	host1="mytesthost1."$DOMAIN
	attr="macaddress"
        new_byte6="ff"
        attrToVerify1="MAC address"
        tmpfile="$tmpDir/hostether_$myhost_103.out"
        if [ $macaddr ] ; then
                host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
		command="ipa host-mod --addattr $attr=$host_macaddr $host1"
        	expmsg="ipa: ERROR: $host1: host not found"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
         else
            rlFail "MAC address not found on this host."
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-104 addattr --macaddress"
        myhost=mytesthost1.$DOMAIN
        attr="macaddress"
        new_byte6="ff"
        attrToVerify1="MAC address"
        tmpfile="$tmpDir/hostether_$myhost_104.out"
        if [ $macaddr ] ; then
                host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
                rlRun "ipa host-add $myhost --force" 0 "Adding host"
                rlRun "ipa host-mod --addattr $attr=$host_macaddr $myhost" 0 "Adding attribute $attr to value of $host_macaddr."
                rlRun "verifyHostAttr $myhost \"$attrToVerify1\" \"$host_macaddr\"" 0 "Verifying host $attr was modified."
		rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 0 "Get the ether value associated with the host"
                getent_macaddr=""
                for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
                        if [[ ${item:0:1} = "0" ]] ; then
                                item=${item:1:1}
                        fi
                        item=${item,,}
                        getent_macaddr=$getent_macaddr$item":"
                done
                getent_macaddr=$getent_macaddr$new_byte6
                rlAssertGrep "$getent_macaddr $myhost" "$tmpfile"
                rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
         else
            rlFail "MAC address not found on this host."
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-105 delattr --macaddress"
        myhost=mytesthost1.$DOMAIN
		# scott 05/01/2012 - uppercasing FF because delattr here is case sensitive but, the mac from addattr
		# is being normalized to uppercase.
        new_byte6="FF"
        tmpfile="$tmpDir/hostether_$myhost_105.out"
	attr="macaddress"
        if [ $macaddr ] ; then
                host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
                rlRun "ipa host-add $myhost --macaddress=$host_macaddr --force" 0 "Adding host with --mac-address and --force"
                rlRun "verifyHostAttr $myhost \"MAC address\" $host_macaddr" 0 "Check if MAC address was added"
                rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 0 "Get the ether value associated with the host"
                getent_macaddr=""
                for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
                        if [[ ${item:0:1} = "0" ]] ; then
                                item=${item:1:1}
                        fi
                        item=${item,,}
                        getent_macaddr=$getent_macaddr$item":"
                done
                getent_macaddr=$getent_macaddr${new_byte6,,}
                rlAssertGrep "$getent_macaddr $myhost" "$tmpfile"
		rlRun "ipa host-mod --delattr $attr=${host_macaddr^^} $myhost" 0 "Delete attribute $attr=$host_macaddr."
		rlRun "verifyHostAttr $myhost \"MAC address\" $host_macaddr" 1 "Check if MAC address attribute was deleted"
		rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 2 "Get the ether value associated with the host, should be empty."
                getent_macaddr=""
                for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
                        if [[ ${item:0:1} = "0" ]] ; then
                                item=${item:1:1}
                        fi
                        item=${item,,}
                        getent_macaddr=$getent_macaddr$item":"
                done
                getent_macaddr=$getent_macaddr${new_byte6,,}
                rlAssertNotGrep "$getent_macaddr $myhost" "$tmpfile"
                rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
        else
            rlFail "MAC address not found on this host."
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-106 delattr --macaddress with incorrect value"
        myhost=mytesthost1.$DOMAIN
        new_byte6="ff"
        tmpfile="$tmpDir/hostether_$myhost_106.out"
        attr="macaddress"
        if [ $macaddr ] ; then
                host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
                rlRun "ipa host-add $myhost --macaddress=$host_macaddr --force" 0 "Adding host with --mac-address and --force"
                rlRun "verifyHostAttr $myhost \"MAC address\" $host_macaddr" 0 "Check if MAC address was added"
		value=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":EE"
		command="ipa host-mod --delattr $attr=$value $myhost"
		expmsg="ipa: ERROR: macaddress does not contain '$value'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
                rlRun "verifyHostAttr $myhost \"MAC address\" $host_macaddr" 0 "Check if MAC address attribute was not deleted"
                rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 0 "Get the ether value associated with the host"
		getent_macaddr=""
                for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
                        if [[ ${item:0:1} = "0" ]] ; then
                                item=${item:1:1}
                        fi
                        item=${item,,}
                        getent_macaddr=$getent_macaddr$item":"
                done
                getent_macaddr=$getent_macaddr${new_byte6,,}
                rlAssertGrep "$getent_macaddr $myhost" "$tmpfile"
                rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
        else
            rlFail "MAC address not found on this host."
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-107 Negative - add a host with invalid macaddress"
        myhost=mytesthost1.$DOMAIN
        new_byte6="eff"
        host_macaddr="some:value"
        rlLog "EXECUTING: ipa host-add $myhost --macaddress=\"$host_macaddr\" --force" 0 "Adding host with --mac-address and --force"
	command="ipa host-add $myhost --macaddress=\"$host_macaddr\" --force"
        expmsg="ipa: ERROR: invalid 'macaddress': Must be of the form HH:HH:HH:HH:HH:HH, where each H is a hexadecimal character."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
        rlLog "EXECUTING: ipa host-add $myhost --macaddress=\"$host_macaddr\" --force" 0 "Adding host with --mac-address=\"$host_macaddr\" and --force"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."	
    rlPhaseEnd
    
    rlPhaseStartTest "ipa-host-cli-108 delattr --macaddress with lowercase"
        myhost=mytesthost1.$DOMAIN
        new_byte6="EF"
        tmpfile="$tmpDir/hostether_$myhost_108.out"
        attr="macaddress"
        if [ $macaddr ] ; then
                host_macaddr=$byte1":"$byte2":"$byte3":"$byte4":"$byte5":"$new_byte6
                rlRun "ipa host-add $myhost --macaddress=$host_macaddr --force" 0 "Adding host with --mac-address and --force"
                rlRun "verifyHostAttr $myhost \"MAC address\" $host_macaddr" 0 "Check if MAC address was added"
                rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 0 "Get the ether value associated with the host"
                getent_macaddr=""
                for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
                        if [[ ${item:0:1} = "0" ]] ; then
                                item=${item:1:1}
                        fi
                        item=${item,,}
                        getent_macaddr=$getent_macaddr$item":"
                done
                getent_macaddr=$getent_macaddr${new_byte6,,}
                rlAssertGrep "$getent_macaddr $myhost" "$tmpfile"
                rlRun "ipa host-mod --delattr $attr=${getent_macaddr} $myhost > $tmpfile 2>&1" 1 "Delete attribute $attr=$getent_macaddr."
                rlAssertGrep "ipa: ERROR: macaddress does not contain" "$tmpfile"
                rlRun "verifyHostAttr $myhost \"MAC address\" $host_macaddr" 0 "Check if MAC address attribute was not deleted"
                rlRun "/usr/bin/getent ethers $myhost > $tmpfile" 0 "Get the ether value associated with the host, should not be empty."
                getent_macaddr=""
                for item in $byte1 $byte2 $byte3 $byte4 $byte5 ; do
                        if [[ ${item:0:1} = "0" ]] ; then
                                item=${item:1:1}
                        fi
                        item=${item,,}
                        getent_macaddr=$getent_macaddr$item":"
                done
                getent_macaddr=$getent_macaddr${new_byte6,,}
                rlAssertGrep "$getent_macaddr $myhost" "$tmpfile"
                rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
        else
            rlFail "MAC address not found on this host."
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-macaddress-cleanup Remove nss-pam-ldapd, nsswitch.conf back on default and remove temp directory."
	rlRun "cat /etc/nslcd.conf | sed -e 's/base dc=testrelm,dc=com/base dc=example,dc=com/' >/etc/nslcd.conf.modified2" 0 "Set the base back on default value."
	rlRun "/bin/mv /etc/nslcd.conf.modified2 /etc/nslcd.conf"
	rlRun "/sbin/service  nslcd restart" 0 "Restart nslcd service"
        rlRun "cat /etc/nsswitch.conf | sed -e 's/ethers:     ldap/ethers:     files/' > /etc/nsswitch.conf.modified2" 0 "Set ethers back on default value files."
	rlRun "mv /etc/nsswitch.conf.modified2 /etc/nsswitch.conf"
	rlRun "rpm -ev $ETHER_PACKAGE"
	rlRun "popd"
        rlRun "rm -r $tmpDir" 0 "Removing temp directory"
    rlPhaseEnd

    setenforce 1
}
