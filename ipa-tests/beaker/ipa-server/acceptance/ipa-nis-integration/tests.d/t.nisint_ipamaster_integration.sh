#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_ipamaster_integration.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration NIS Integration script
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
# variables
######################################################################

######################################################################
# test suite
######################################################################
nisint_ipamaster_integration()
{
	rlLog "$FUNCNAME"

	rlPhaseStartTest "nisint_ipamaster_integration: "
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		
		nisint_ipamaster_integration_envsetup
		nisint_ipamaster_integration_setup_nis_listener
		nisint_ethers_map_enabled_check
		nisint_ipamaster_integration_add_nis_data
		nisint_ipamaster_integration_del_nis_data
		nisint_ipamaster_integration_add_nis_data_ldif
		nisint_ipamaster_integration_check_ipa_nis_data

		rlRun "rhts-sync-set -s 'nisint_ipamaster_integration_end' -m $MASTER_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s 'nisint_ipamaster_integration_end' $MASTER_IP"
		rlRun "rhts-sync-block -s 'nisint_ipamaster_integration_end' $MASTER_IP"

		nisint_ethers_map_enabled_check
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlLog "rhts-sync-block -s 'nisint_ipamaster_integration_end' $MASTER_IP"
		rlRun "rhts-sync-block -s 'nisint_ipamaster_integration_end' $MASTER_IP"

		nisint_ethers_map_enabled_check
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

nisint_ipamaster_integration_envsetup()
{
	rlPhaseStartTest "nisint_ipamaster_integration_envsetup: "
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "yum -y install yp-tools" 0 "Installing yp-tools for ypcat command"
		rlRun "echo '$NISMASTER_IP $NISMASTER' >> /etc/hosts"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

nisint_ipamaster_integration_add_nis_data()
{
	nisint_ipamaster_integration_add_nis_data_passwd
	nisint_ipamaster_integration_add_nis_data_group
	nisint_ipamaster_integration_add_nis_data_hosts
	nisint_ipamaster_integration_add_nis_data_netgroup
	nisint_ipamaster_integration_add_nis_data_automount
	if [ $ENABLE_ETHERS -gt 0 ]; then
		nisint_ipamaster_integration_add_nis_data_ethers
	fi
}

nisint_ipamaster_integration_add_nis_data_passwd()
{
	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_passwd: Import NIS passwd map"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER passwd > /opt/rhqa_ipa/nis-map.passwd 2>&1"
		ORIGIFS="$IFS"
		IFS="
"
		for line in $(cat /opt/rhqa_ipa/nis-map.passwd); do
			IFS="$ORIGIFS"
			username=$(echo $line|cut -f1 -d:)
			# Not collecting encrypted password because we need cleartext password to create kerberos key	
			uid=$(echo $line|cut -f3 -d:)
			gid=$(echo $line|cut -f4 -d:)
			gecos=$(echo $line|cut -f5 -d:)
			homedir=$(echo $line|cut -f6 -d:)
			shell=$(echo $line|cut -f7 -d:)
			
			# Now create this entry
			rlRun "create_ipauser $username NIS USER passw0rd1"
			KinitAsAdmin
			rlRun "ipa user-mod $username --gidnumber=$gid --uid=$uid --gecos='$gecos' --homedir=$homedir --shell=$shell"
			rlRun "ipa user-show $username"
		done
		
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_ipamaster_integration_add_nis_data_group()
{
	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_group: Import NIS group map"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER group > /opt/rhqa_ipa/nis-map.group 2>&1"
		ORIGIFS="$IFS"
		IFS="
"
		for line in $(cat /opt/rhqa_ipa/nis-map.group); do
			IFS="$ORIGIFS"
			groupname=$(echo $line|cut -f1 -d:)
			# not collecting Group password 
			gid=$(echo $line|cut -f3 -d:)
			users=$(echo $line|cut -f4 -d:)

			grfound=$(ipa group-show $groupname 2>/dev/null|wc -l)
			if [ $grfound -eq 0 ]; then
				rlRun "ipa group-add --desc=NIS_GROUP_$groupname $groupname --gid=$gid"
			fi
			rlRun "ipa group-add-member $groupname --users=$users"
			rlRun "ipa group-show $groupname"
		done
		
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_ipamaster_integration_add_nis_data_hosts()
{
	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_hosts: Import NIS hosts map"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER hosts |sort -u|egrep -v 'localhost|$MASTER|$NISMASTER|$NISCLIENT'  > /opt/rhqa_ipa/nis-map.hosts 2>&1"
		ORIGIFS="$IFS"
		IFS="
"
		for line in $(cat /opt/rhqa_ipa/nis-map.hosts); do
			IFS="$ORIGIFS"
			ip=$(echo $line|awk '{print $1}')
			ptrzone=$(echo $ip|awk -F. '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
			hostnames=$(echo $line | sed "s/$ip//")
			firsthostname=$(echo $hostnames|awk '{print $1}'|cut -f1 -d.|head -1)
			ptrzonefound=$(ipa dnszone-show $ptrzone 2>/dev/null |wc -l)
			if [ $ptrzonefound -eq 0 ]; then
				rlRun "ipa dnszone-add $ptrzone --name-server=$MASTER. --admin-email=ipaqar.redhat.com"
			fi
			if [ $(ipa host-show x$MASTER 2>&1 | grep "x$MASTER: host not found" | wc -l) -gt 0 ]; then
				rlRun "ipa host-add $firsthostname.$DOMAIN --ip-address=$ip" 
			else 
				rlPass "Host entry already exists."
			fi
			rlRun "ipa host-show $firsthostname.$DOMAIN"
		done

		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_ipamaster_integration_add_nis_data_netgroup()
{
	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_netgroup: Import NIS netgroup map"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ypcat -k -d $NISDOMAIN -h $NISMASTER netgroup  > /opt/rhqa_ipa/nis-map.netgroup 2>&1"
		ORIGIFS="$IFS"
		IFS="
"
		for line in $(cat /opt/rhqa_ipa/nis-map.netgroup); do
			IFS="$ORIGIFS"
			hostcat=""
			usercat=""
			netgroupname=$(echo $line|awk '{print $1}')
			if [ $(echo $line|grep "(,"|wc -l) -gt 0 ]; then
				hostcat=all
			fi

			if [ $(echo $line|grep ",,"|wc -l) -gt 0 ]; then
				usercat=all
			fi

			# Add Netgroup if it's not already in IPA
			ngnotfound=$(ipa netgroup-show $netgroupname 2>&1|grep "netgroup not found"|wc -l)
			if [ $ngnotfound -gt 0 ]; then
				rlRun "ipa netgroup-add $netgroupname --desc=NIS_NG_$netgroupname"
			fi
	
			# Set Host Category on netgroup if needed
			nghostcat=$(ipa netgroup-show $netgroupname 2>&1|grep "Host category:"|awk '{print $3}')
			if [ "X$nghostcat" != "X$hostcat" ]; then
				rlRun "ipa netgroup-mod $netgroupname --hostcat=$hostcat"
			fi
			
			# Set User Category on netgroup if needed
			ngusercat=$(ipa netgroup-show $netgroupname 2>&1|grep "User category:"|awk '{print $3}')
			if [ "X$ngusercat" != "X$usercat" ]; then
				rlRun "ipa netgroup-mod $netgroupname --usercat=$usercat"
			fi

			triples=$(echo $line|sed "s/^$netgroupname //" )

			for triple in $triples; do
				if [ $(echo "$triple"|grep "("|wc -l) -gt 0 ]; then
					thost=$(echo $triple|sed -e 's/-//g' -e 's/(//' -e 's/)//'|cut -f1 -d,)
					tuser=$(echo $triple|sed -e 's/-//g' -e 's/(//' -e 's/)//'|cut -f2 -d,)
					tdom=$(echo $triple |sed -e 's/-//g' -e 's/(//' -e 's/)//'|cut -f3 -d,)
					rlRun "ipa netgroup-add-member $netgroupname --hosts=$thost --users=$tuser"
				else
					tnetgroup=$triple
					# Add tNetgroup if it's not already in IPA
					tngnotfound=$(ipa netgroup-show $tnetgroup 2>&1|grep "netgroup not found"|wc -l)
					if [ $tngnotfound -gt 0 ]; then
						rlRun "ipa netgroup-add $tnetgroup --desc=NIS_NG_$tnetgroup"
					fi
					rlRun "ipa netgroup-add-member $netgroupname --netgroups=$tnetgroup"
				fi
			done
		done
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_ipamaster_integration_add_nis_data_automount()
{
	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_automount: Import NIS automount maps"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		# Setup Automount Location for testing
		rlRun "ipa automountlocation-add nis"
		rlRun "ipa automountmap-del nis auto.direct"
		rlRun "ipa automountmap-del nis auto.master"
		rlRun "ypcat -k -d $NISDOMAIN -h $NISMASTER auto.master > /opt/rhqa_ipa/nis-map.auto.master 2>&1"
		MAPS=$(echo auto.master ; awk '{print $2}' /opt/rhqa_ipa/nis-map.auto.master)
	
		ORIGIFS="$IFS"
		for MAP in $MAPS; do
			rlRun "ypcat -k -d $NISDOMAIN -h $NISMASTER $MAP > /opt/rhqa_ipa/nis-map.$MAP 2>&1"				
			rlRun "ipa automountmap-add nis $MAP"

			cat <<-EOF > /tmp/amap.ldif
			dn: nis-domain=testrelm.com+nis-map=$MAP,cn=NIS Server,cn=plugins,cn=config
			objectClass: extensibleObject
			nis-domain: $DOMAIN
			nis-map: $MAP
			nis-base: automountmapname=$MAP,cn=nis,cn=automount,$BASEDN
			nis-filter: (objectclass=*)
			nis-key-format: %{automountKey}
			nis-value-format: %{automountInformation}	
			EOF

			IFS="
"
			for line in $(cat /opt/rhqa_ipa/nis-map.$MAP); do
				IFS="$ORIGIFS"
				echo "$line"
				key=$(echo "$line" | awk '{print $1}')
				info=$(echo "$line" | sed -e "s#^$key[ \t]*##")
				rlRun "ipa automountkey-add nis $MAP --key=\"$key\" --info=\"$info\""
			done
			rlRun "ldapadd -x -h $MASTER -D '$ROOTDN' -w $ADMINPW -f /tmp/amap.ldif"
		done

		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_ipamaster_integration_add_nis_data_ethers()
{
	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_ethers: Import NIS ethers map"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
	
		ORIGIFS="$IFS"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER ethers > /opt/rhqa_ipa/nis-map.ethers 2>&1"
		IFS=$'\n'
		for line in $(cat /opt/rhqa_ipa/nis-map.ethers); do
			IFS="$ORIGIFS"
			echo "$line"
			mac=$(echo "$line" | awk '{print $1}')
			host=$(echo "$line" | sed -e "s#^$mac[ \t]*##")
			rlRun "ipa host-add $host --macaddress=$mac --force --no-reverse"
		done	
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_ipamaster_integration_del_nis_data()
{
	echo $FUNCNAME
	nisint_ipamaster_integration_del_nis_data_passwd
	nisint_ipamaster_integration_del_nis_data_group
	nisint_ipamaster_integration_del_nis_data_hosts
	nisint_ipamaster_integration_del_nis_data_netgroup
	nisint_ipamaster_integration_del_nis_data_automount
	if [ $ENABLE_ETHERS -gt 0 ]; then
		nisint_ipamaster_integration_del_nis_data_ethers
	fi
}

nisint_ipamaster_integration_del_nis_data_passwd()
{
	rlPhaseStartTest "nisint_ipamaster_integration_del_nis_data_passwd: Delete users from passwd map"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER passwd  > /opt/rhqa_ipa/nis-map.passwd 2>&1"
		for user in $(cut -f1 -d: /opt/rhqa_ipa/nis-map.passwd); do
			if [ $(ipa user-show $user 2>/dev/null | wc -l) -gt 0 ]; then
				rlRun "ipa user-del $user"
			else
				rlPass "No user, $user, found...continuing"
			fi
		done
	rlPhaseEnd
}

nisint_ipamaster_integration_del_nis_data_group()
{
	rlPhaseStartTest "nisint_ipamaster_integration_del_nis_data_group: Delete groups grom group map"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER group  > /opt/rhqa_ipa/nis-map.group 2>&1"
		for group in $(cut -f1 -d: /opt/rhqa_ipa/nis-map.group); do
			if [ $(ipa group-show $group 2>/dev/null | wc -l) -gt 0 ]; then
				rlRun "ipa group-del $group"
			else
				rlPass "No group, $group, found...continuing" 
			fi
		done
	rlPhaseEnd
}

nisint_ipamaster_integration_del_nis_data_hosts()
{
	MASTER_S=$(echo $MASTER|cut -f1 -d.)
	NISMASTER_S=$(echo $NISMASTER|cut -f1 -d.)
	NISCLIENT_S=$(echo $NISMASTER|cut -f1 -d.)
	rlPhaseStartTest "nisint_ipamaster_integration_del_nis_data_hosts: Delete hostsf from host map"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER hosts  > /opt/rhqa_ipa/nis-map.hosts 2>&1"
		for host in $(awk '{print $2 }' /opt/rhqa_ipa/nis-map.hosts|cut -f1 -d.|egrep -v "$MASTER_S|$NISMASTER_S|$NISCLIENT_S" | sed "s/$/.$DOMAIN/g"); do
			if [ $(ipa host-show $host 2>/dev/null|wc -l) -gt 0 ]; then
				rlRun "ipa host-del $host --updatedns"
			else
				rlPass "No host, $host, found...continuing"
			fi
		done
	rlPhaseEnd
}

nisint_ipamaster_integration_del_nis_data_netgroup()
{
	rlPhaseStartTest "nisint_ipamaster_integration_del_nis_data_netgroup: Delete netgroups from map"
		rlRun "ypcat -k -d $NISDOMAIN -h $NISMASTER netgroup  > /opt/rhqa_ipa/nis-map.netgroup 2>&1"
		for netgroup in $(awk '{print $1}' /opt/rhqa_ipa/nis-map.netgroup); do
			if [ $(ipa netgroup-show $netgroup 2>/dev/null | wc -l) -gt 0 ]; then
				rlRun "ipa netgroup-del $netgroup"
			else
				rlPass "No netgroup, $netgroup, found...continuing"
			fi
		done
	rlPhaseEnd
}

nisint_ipamaster_integration_del_nis_data_automount()
{
	rlPhaseStartTest "nisint_ipamaster_integration_del_nis_data_automount: Delete automount from map"
		rlRun "ipa automountlocation-del nis"
		rlRun "ldapdelete -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" \"nis-domain=testrelm.com+nis-map=auto.nisint,cn=NIS Server,cn=plugins,cn=config\""
		rlRun "ldapdelete -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" \"nis-domain=testrelm.com+nis-map=auto.home,cn=NIS Server,cn=plugins,cn=config\""
		rlRun "ldapdelete -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" \"nis-domain=testrelm.com+nis-map=auto.master,cn=NIS Server,cn=plugins,cn=config\""
	rlPhaseEnd	
}

nisint_ipamaster_integration_del_nis_data_ethers()
{
	rlPhaseStartTest "nisint_ipamaster_integration_del_nis_data_ethers: Delete MAC entries from hosts in map"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
	
		ORIGIFS="$IFS"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER ethers > /opt/rhqa_ipa/nis-map.ethers 2>&1"
		IFS=$'\n'
		for line in $(cat /opt/rhqa_ipa/nis-map.ethers); do
			IFS="$ORIGIFS"
			echo "$line"
			mac=$(echo "$line" | awk '{print $1}')
			host=$(echo "$line" | sed -e "s#^$mac[ \t]*##")
			rlRun "ipa host-del $host"
		done
	rlPhaseEnd
}

nisint_ipamaster_integration_add_nis_data_ldif()
{
	echo $FUNCNAME
	nisint_ipamaster_integration_add_nis_data_ldif_passwd
	nisint_ipamaster_integration_add_nis_data_ldif_group
	nisint_ipamaster_integration_add_nis_data_ldif_hosts
	nisint_ipamaster_integration_add_nis_data_ldif_netgroup
	nisint_ipamaster_integration_add_nis_data_ldif_automount
	if [ $ENABLE_ETHERS -gt 0 ]; then
		nisint_ipamaster_integration_add_nis_data_ldif_ethers
	fi
}

nisint_ipamaster_integration_add_nis_data_ldif_passwd()
{
	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_ldif_passwd: Add NIS passwd via ldif"
		tmpldif=/tmp/nis-map.passwd.ldif
		ORIGFS="$IFS"
		IFS="
"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER passwd  > /opt/rhqa_ipa/nis-map.passwd 2>&1"
		cat /dev/null > $tmpldif
		for line in $(cat /opt/rhqa_ipa/nis-map.passwd); do
			IFS="$ORIGIFS"
			USERNAME=$(echo $line|cut -f1 -d:|tr '[:upper:]' '[:lower:]')
			UIDNUM=$(echo $line|cut -f3 -d:)
			GIDNUM=$(echo $line|cut -f4 -d:)
			GECOS=$(echo $line|cut -f5 -d:)
			HOMEDIR=$(echo $line|cut -f6 -d:)
			SHELL=$(echo $line|cut -f7 -d:)

			echo "ipa-ldif-user-add: $USERNAME $UIDNNUM $GIDNUM $GECOS $HOMEDIR $SHELL"

			cat >> $tmpldif <<-EOF
			dn: uid=$USERNAME,cn=users,cn=accounts,$BASEDN
			displayName: NIS USER
			cn: NIS USER
			objectClass: top
			objectClass: person
			objectClass: organizationalperson
			objectClass: inetorgperson
			objectClass: inetuser
			objectClass: posixaccount
			objectClass: krbprincipalaux
			objectClass: krbticketpolicyaux
			objectClass: ipaobject
			objectClass: ipasshuser
			objectClass: ipaSshGroupOfPubKeys
			givenName: NIS
			sn: USER
			initials: NU
			uid: $USERNAME
			uidNumber: $UIDNUM
			gidNumber: $GIDNUM
			loginShell: $SHELL
			homeDirectory: $HOMEDIR
			krbPwdPolicyReference: cn=global_policy,cn=$RELM,cn=kerberos,$BASEDN
			krbPrincipalName: $USERNAME@$RELM
			EOF

			### removing this from ldif file:
			### mepManagedEntry: cn=$USERNAME,cn=groups,cn=accounts,$BASEDN

			if [ -n "$GECOS" ]; then
				echo "gecos: $GECOS" >> $tmpldif
			fi
		
			echo "" >> $tmpldif 
		done

		rlRun "ldapadd -av -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f $tmpldif"

		for USERNAME in $(cut -f1 -d: /opt/rhqa_ipa/nis-map.passwd|tr '[:upper:]' '[:lower:]'); do
			rlRun "echo \"dummy123@ipa.com\"| ipa passwd $USERNAME"
			FirstKinitAs $USERNAME "dummy123@ipa.com" passw0rd1
			KinitAsAdmin
		done
	rlPhaseEnd
}

nisint_ipamaster_integration_add_nis_data_ldif_group()
{
	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_ldif_group: add NIS group via ldif"
		tmpldif=/tmp/nis-map.group.ldif
		ORIGFS="$IFS"
		IFS="
"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER group  > /opt/rhqa_ipa/nis-map.group 2>&1"
		cat /dev/null > $tmpldif
		for line in $(cat /opt/rhqa_ipa/nis-map.group); do
			GROUPNAME=$(echo $line|cut -f1 -d:|tr '[:upper:]' '[:lower:]')
			GIDNUM=$(echo $line|cut -f3 -d:)
			USERS=$(echo $line|cut -f4 -d:|tr '[:upper:]' '[:lower:]')
			if [ $(ipa group-show $GROUPNAME 2>/dev/null | wc -l) -gt 0 ]; then
				rlLog "Group, $GROUPNAME, already exists...continuing"
				continue
			fi
			
			cat >> $tmpldif <<-EOF
			dn: cn=$GROUPNAME,cn=groups,cn=accounts,$BASEDN
			objectClass: top
			objectClass: groupofnames
			objectClass: nestedgroup
			objectClass: ipausergroup
			objectClass: ipaobject
			objectClass: posixgroup
			gidNumber: $GIDNUM
			cn: $GROUPNAME
			description: NIS_GROUP_$GROUPNAME
			EOF

			for USER in $(echo $USERS|sed 's/,/ /g'); do
				echo "member: uid=$USER,cn=users,cn=accounts,$BASEDN" >> $tmpldif
			done
			echo "" >> $tmpldif
		done

		rlRun "ldapadd -av -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f $tmpldif"
	rlPhaseEnd
}

nisint_ipamaster_integration_add_nis_data_ldif_hosts()
{
	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_ldif_hosts: Add NIS hosts via ldif"
		tmpldif=/tmp/nis-map.hosts.ldif
		ORIGFS="$IFS"
		IFS="
"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER hosts|sort -u|egrep -v 'localhost|$MASTER|$NISMASTER|$NISCLIENT'  > /opt/rhqa_ipa/nis-map.hosts 2>&1"
		cat /dev/null > $tmpldif
		for line in $(cat /opt/rhqa_ipa/nis-map.hosts); do
			IFS="$ORIGIFS"
			date=$(date +%Y%m%d)
			ip=$(echo $line|awk '{print $1}')
			ptrzone=$(echo $ip|awk -F. '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
			iplastoctet=$(echo $ip|awk -F. '{print $4}')
			hostnames=$(echo $line | sed "s/$ip//")
			firsthostname=$(echo $hostnames|awk '{print $1}'|cut -f1 -d.|head -1)
			ptrzonefound=$(ipa dnszone-show $ptrzone 2>/dev/null |wc -l)
			ptrzonewritten=$(grep "dn: idnsname=$ptrzone,cn=dns,$BASEDN" $tmpldif|wc -l)

			if [ $ptrzonefound -eq 0 -a $ptrzonewritten -eq 0 ]; then
				# Add PTR Zone:
				cat >> $tmpldif <<-EOF
				dn: idnsname=$ptrzone,cn=dns,$BASEDN
				idnsZoneActive: TRUE
				idnsSOAexpire: 1209600
				nSRecord: ${MASTER}.
				idnsSOAserial: ${date}01
				idnsSOAretry: 900
				idnsSOAminimum: 3600
				idnsSOArefresh: 3600
				objectClass: top
				objectClass: idnsrecord
				objectClass: idnszone
				idnsName: $ptrzone
				idnsAllowDynUpdate: FALSE
				idnsSOArName: ipaqar.redhat.com.
				idnsSOAmName: ${MASTER}.
				EOF
				echo "" >> $tmpldif
			fi

	
			if [ $(ipa host-show $firsthostname.$DOMAIN 2>/dev/null | wc -l) -eq 0 ]; then
				cat >> $tmpldif <<-EOF
				dn: fqdn=$firsthostname.$DOMAIN,cn=computers,cn=accounts,$BASEDN
				cn: $firsthostname.$DOMAIN
				objectClass: ipaobject
				objectClass: nshost
				objectClass: ipahost
				objectClass: pkiuser
				objectClass: ipaservice
				objectClass: krbprincipalaux
				objectClass: krbprincipal
				objectClass: ieee802device
				objectClass: ipasshhost
				objectClass: top
				objectClass: ipaSshGroupOfPubKeys
				fqdn: $firsthostname.$DOMAIN
				managedBy: fqdn=$firsthostname.$DOMAIN,cn=computers,cn=accounts,$BASEDN
				krbPrincipalName: host/$firsthostname.$DOMAIN@$RELM
				serverHostName: $firsthostname
				EOF
				echo "" >> $tmpldif

				cat >> $tmpldif <<-EOF
				dn: idnsname=$firsthostname,idnsname=$DOMAIN,cn=dns,$BASEDN
				objectClass: top
				objectClass: idnsrecord
				aRecord: $ip
				idnsName: $firsthostname
				EOF
				echo "" >> $tmpldif

				cat >> $tmpldif <<-EOF
				dn: idnsname=$iplastoctet,idnsname=$ptrzone,cn=dns,$BASEDN
				objectClass: top
				objectClass: idnsrecord
				pTRRecord: $firsthostname.$DOMAIN.
				idnsName: $iplastoctet
				EOF
				echo "" >> $tmpldif
			fi
		done

		rlRun "ldapadd -av -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f $tmpldif"
	rlPhaseEnd	
	
}

nisint_ipamaster_integration_add_nis_data_ldif_netgroup()
{

	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_ldif_netgroup: Add netgroups via ldif"
		tmpldif=/tmp/nis-map.netgroup.ldif
		ORIGFS="$IFS"
		IFS="
"
		rlRun "ypcat -k -d $NISDOMAIN -h $NISMASTER netgroup > /opt/rhqa_ipa/nis-map.netgroup 2>&1"
		cat /dev/null > $tmpldif
		for line in $(cat /opt/rhqa_ipa/nis-map.netgroup); do
			IFS="$ORIGIFS"
			NGNAME=$(echo $line|awk '{print $1}')
			USERCAT=0
			HOSTCAT=0

			cat >> $tmpldif <<-EOF
			dn: cn=$NGNAME,cn=ng,cn=alt,$BASEDN
			objectClass: ipaobject
			objectClass: ipaassociation
			objectClass: ipanisnetgroup
			cn: $NGNAME
			description: NIS_NG_$NGNAME
			nisDomainName: $DOMAIN
			EOF

			triples=$(echo $line|sed -e "s/^$NGNAME //" -e "s/, /,/g")

			for triple in $triples; do
				# no parens means it's a netgroup
				if [ $(echo $triple|grep -v "("|wc -l) -gt 0 ]; then
					NETGROUP=$triple
					echo "member: cn=$NETGROUP,cn=ng,cn=alt,$BASEDN" >> $tmpldif
					continue
				fi

				# else split up the triple
				thost=$(echo $triple|sed -e 's/(//' -e 's/)//'|cut -f1 -d,)
				tuser=$(echo $triple|sed -e 's/(//' -e 's/)//'|cut -f2 -d,)
				tdom=$(echo $triple |sed -e 's/(//' -e 's/)//'|cut -f3 -d,)

				# process the host part first
				if [ -z "$thost" ]; then
					HOSTCAT=1
				elif [ $(ipa host-show $thost 2>/dev/null|wc -l) -gt 0 ]; then
					echo "memberHost: fqdn=$thost,cn=computers,cn=accounts,$BASEDN" >> $tmpldif
				elif [ "X$thost" != "X-" ]; then
					echo "externalHost: $thost" >> $tmpldif
				fi

				# process the user part next
				if [ -z "$tuser" ]; then
					USERCAT=1
				elif [ $(ipa user-show $tuser 2>/dev/null|wc -l) -gt 0 ]; then
					echo "memberUser: uid=$tuser,cn=users,cn=accounts,$BASEDN" >> $tmpldif
				elif [ $(ipa group-show $tuser 2>/dev/null|wc -l) -gt 0 ]; then
					echo "memberUser: cn=GROUP,cn=groups,cn=accounts,dc=testrelm,dc=com" >> $tmpldif
				else
					echo "Unknown user part found: $tuser not an IPA user or group so cannot be added"
				fi

				# process the domain part last
				if [ -n "$tdom" ]; then
					NGNISDOM=$tdom
				fi
			done

			if [ $USERCAT -gt 0 ]; then
				echo "userCategory: all" >> $tmpldif
			fi
			if [ $HOSTCAT -gt 0 ]; then
				echo "hostCategory: all" >> $tmpldif
			fi
			if [ -n "$NGNISDOM" ]; then
				echo "nisDomainName: $NGNISDOM" >> $tmpldif
			fi

			echo "" >> $tmpldif
		done

		rlRun "ldapadd -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f $tmpldif"
		rlRun "cat $tmpldif"
		rm -f $tmpldif
	rlPhaseEnd
}

nisint_ipamaster_integration_add_nis_data_ldif_automount()
{
	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_ldif_automount: Add automount via ldif"
		tmpldif=/tmp/nis-map.automount.ldif
		cat /dev/null > $tmpldif

		cat > $tmpldif <<-EOF
		dn: cn=nis,cn=automount,$BASEDN
		objectClass: nscontainer
		objectClass: top
		cn: nis
		EOF

		echo "" >> $tmpldif

		ORIGFS="$IFS"
		rlRun "ypcat -k -d $NISDOMAIN -h $NISMASTER auto.master > /opt/rhqa_ipa/nis-map.auto.master 2>&1"
		
		MAPS=$(echo auto.master ; awk '{print $2}' /opt/rhqa_ipa/nis-map.auto.master)
		for MAP in $MAPS; do

			cat >> $tmpldif <<-EOF
			dn: automountmapname=$MAP,cn=nis,cn=automount,$BASEDN
			objectClass: automountmap
			objectClass: top
			automountMapName: $MAP
			EOF

			rlRun "ypcat -k -d $NISDOMAIN -h $NISMASTER $MAP > /opt/rhqa_ipa/nis-map.$MAP 2>&1"
			echo "" >> $tmpldif
			IFS="
"

			for line in $(cat /opt/rhqa_ipa/nis-map.$MAP); do
				IFS="$ORIGIFS"
				KEY=$(echo "$line" | awk '{print $1}')
				INFO=$(echo "$line" | sed -e "s#^$KEY[ \t]*##")

				cat >> $tmpldif <<-EOF
				dn: description=$KEY,automountmapname=$MAP,cn=nis,cn=automount,$BASEDN
				objectClass: automount
				objectClass: top
				automountKey: $KEY
				automountInformation: $INFO
				description: $KEY
				EOF

				echo "" >> $tmpldif
			done
			
			cat >> $tmpldif <<-EOF
			dn: nis-domain=$DOMAIN+nis-map=$MAP,cn=NIS Server,cn=plugins,cn=config
			objectClass: extensibleObject
			nis-domain: $DOMAIN
			nis-map: $MAP
			nis-base: automountmapname=$MAP,cn=nis,cn=automount,$BASEDN
			nis-filter: (objectclass=*)
			nis-key-format: %{automountKey}
			nis-value-format: %{automountInformation}  
			EOF

			echo "" >> $tmpldif
		done

		rlRun "ldapadd -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f $tmpldif"
	rlPhaseEnd
}

nisint_ipamaster_integration_add_nis_data_ldif_ethers()
{
	rlPhaseStartTest "nisint_ipamaster_integration_add_nis_data_ldif_ethers: Import NIS ethers map from ldif"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		local tmpldif=/tmp/nis-map.ethers.ldif
	
		ORIGIFS="$IFS"
		rlRun "ypcat -k -d $NISDOMAIN -h $NISMASTER ethers > /opt/rhqa_ipa/nis-map.ethers 2>&1"
		IFS=$'\n'
		for line in $(cat /opt/rhqa_ipa/nis-map.ethers); do
			IFS="$ORIGIFS"
			echo "$line"
			mac=$(echo "$line" | awk '{print $1}')
			host=$(echo "$line" | sed -e "s#^$key[ \t]*##")
			cat >> $tmpldif <<-EOF
			dn: fqdn=$host,cn=computers,cn=accounts,$BASEDN
			macAddress: $mac
			cn: $host
			objectClass: ipaobject
			objectClass: nshost
			objectClass: ipahost
			objectClass: pkiuser
			objectClass: ipaservice
			objectClass: krbprincipalaux
			objectClass: krbprincipal
			objectClass: ieee802device
			objectClass: ipasshhost
			objectClass: top
			objectClass: ipaSshGroupOfPubKeys
			fqdn: $host
			managedBy: fqdn=$host,cn=computers,cn=accounts,$BASEDN
			krbPrincipalName: host/$host@$RELM
			serverHostName: $(echo $host|cut -f1 -d.)

			EOF
		done	
		rlRun "ldapadd -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f $tmpldif"
		[ -f $tmpout  ] && rm -f $tmpout
		[ -f $tmpldif ] && rm -f $tmpldif
	rlPhaseEnd
}

nisint_ipamaster_integration_setup_nis_listener()
{
	rlPhaseStartTest "nisint_ipamaster_integration_setup_nis_listener: Enable the IPA NIS Listener"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "echo $ADMINPW|ipa-compat-manage enable" 0,2
		rlRun "echo $ADMINPW|ipa-nis-manage enable" 0,2
		rlRun "service rpcbind restart"
		rlRun "rlDistroDiff dirsrv_svc_restart"
		rlRun "ipactl status"
		export ENABLE_ETHERS=$(ldapsearch -h $MASTER_IP -xLLL -D "$ROOTDN" -w "$ROOTDNPWD" -b "cn=NIS Server,cn=plugins,cn=config" "nis-map=ethers.byaddr"|grep "dn: nis-domain=$DOMAIN+nis-map=ethers.byaddr"|wc -l)
		#rlRun "ipactl restart"
		[ -f $tmpout ] && rm -f $tmpout	
	rlPhaseEnd
}

nisint_ipamaster_integration_check_ipa_nis_data()
{
	rlPhaseStartTest "nisint_ipamaster_integration_check_ipa_nis_data: Enable the IPA NIS Listener"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ypcat -k -d $DOMAIN -h $MASTER passwd"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER group"	
		rlRun "ypcat -k -d $DOMAIN -h $MASTER netgroup"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER auto.master"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER auto.home"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER auto.nisint"
		if [ $ENABLE_ETHERS -gt 0 ]; then
			rlRun "ypcat -k -d $DOMAIN -h $MASTER ethers"
		fi
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd 
}
