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
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		
		nisint_ipamaster_integration_envsetup
		nisint_ipamaster_integration_setup_nis_listener
		nisint_ipamaster_integration_add_nis_data
		nisint_ipamaster_integration_del_nis_data
		nisint_ipamaster_integration_add_nis_data_ldif
		nisint_ipamaster_integration_check_ipa_nis_data

		rlRun "rhts-sync-set -s 'nisint_ipamaster_integration_end' -m $MASTER"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s 'nisint_ipamaster_integration_end' $MASTER"
		rlRun "rhts-sync-block -s 'nisint_ipamaster_integration_end' $MASTER"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlLog "rhts-sync-block -s 'nisint_ipamaster_integration_end' $MASTER"
		rlRun "rhts-sync-block -s 'nisint_ipamaster_integration_end' $MASTER"
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
			rlRun "ipa user-mod $username --gidnumber=$gid --uid=$uid --gecos=$gecos --homedir=$homedir --shell=$shell"
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
				rlRun "ipa dnszone-add $ptrzone --name-server=$MASTER --admin-email=ipaqar.redhat.com"
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

nisint_ipamaster_integration_del_nis_data()
{
	echo $FUNCNAME
}

nisint_ipamaster_integration_add_nis_data_ldif()
{
	echo $FUNCNAME
}

nisint_ipamaster_integration_setup_nis_listener()
{
	rlPhaseStartTest "nisint_ipamaster_integration_setup_nis_listener: Enable the IPA NIS Listener"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "echo $ADMINPW|ipa-compat-manage enable" 0,2
		rlRun "echo $ADMINPW|ipa-nis-manage enable" 0,2
		rlRun "service rpcbind restart"
		rlRun "service dirsrv restart"
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
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd 
}
