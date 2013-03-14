#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa_install.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA 
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
### Relies on MYROLE variable to be set appropriately.  This is done
### manually or in runtest.sh
######################################################################

######################################################################
# test suite
######################################################################

ipa_install_prep(){
    currenteth=$(route | grep ^default | awk '{print $8}')
    ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
    hostname=$(hostname)
    hostname_s=$(hostname -s)

    # Install base software
    if [ "$MYROLE" = "CLIENT" ]; then
        rlRun "yum -y install nscd httpd curl mod_nss mod_auth_kerb 389-ds-base expect ntpdate"
        rlRun "yum -y install $PKG-admintools $PKG-client"
    else
        rlRun "yum -y install bind expect krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl"
        rlRun "yum -y install $PKG-server"
    fi
    
    rlRun "yum -y update"

    # Set time
    rlRun "service ntpd stop"
    rlRun "service ntpdate start"

    # Fix /etc/hosts
    rlRun "cp -af /etc/hosts /etc/hosts.ipabackup"
    rlRun "sed -i /^$ipaddr/d /etc/hosts"
    rlRun "sed -i s/$hostname//g /etc/hosts"
    rlRun "sed -i s/$hostname_s//g /etc/hosts"
    rlRun "echo \"$ipaddr $hostname_s.$DOMAIN $hostname_s\" >> /etc/hosts"

    # Fix hostname
    rlRun "hostname $hostname_s.$DOMAIN"
    rlRun "cp /etc/sysconfig/network /etc/sysconfig/network-ipabackup"
    rlRun "sed -i \"/$hostname_s/d\" /etc/sysconfig/network"
    rlRun "echo \"HOSTNAME=$hostname_s.$DOMAIN\" >> /etc/sysconfig/network"
    
    # Fix role var hostname
    [ "$MYROLE" = "MASTER" ] && MASTER=$(hostname)
    [ "$MYROLE" = "REPLICA"  ] && REPLICA=$(hostname)
    [ "$MYROLE" = "CLIENT" ] && CLIENT=$(hostname)

    # Backup resolv.conf
    if [ "x$USEDNS" = "xyes" ]; then
        rlRun "cp /etc/resolv.conf /etc/resolv.conf.ipabackup"
        if [ "$MYROLE" = "REPLICA" -o "$MYROLE" = "CLIENT" ]; then
            rlRun "sed -i s/^nameserver/#nameserver/g /etc/resolv.conf"
            rlRun "echo \"nameserver $MYBEAKERMASTER\" >> /etc/resolv.conf"
            rlRun "echo \"nameserver $MYBEAKERREPLICA1\" >> /etc/resolv.conf"
            rlRun "cat /etc/resolv.conf"
        fi
    fi

    # Disable iptables
    rlRun "service iptables stop"
    rlRun "service ip6tables stop"
}

ipa_install_master_all(){
    USEDNS="yes"
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    DOMAIN=$(grep ^DOMAIN= /opt/rhqa_ipa/env.sh|cut -f2- -d=)
    rlLog "ipa_install_master_all: Install and configure IPA Master with all services"
    case "$MYROLE" in
    "MASTER")
        rlLog "Machine in recipe is MASTER"

        # Configure IPA Server
        ipa_install_prep
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    "REPLICA")
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    "CLIENT")
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
}

ipa_install_master_nodns(){
    USEDNS="no"
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    DOMAIN=$(dnsdomainname)
    rlLog "ipa_install_master_nodns: Install and configure IPA Master with no DNS service"
    case "$MYROLE" in
    "MASTER")
        rlLog "Machine in recipe is MASTER"

        ipa_install_prep
        rlRun "ipa-server-install --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW --ip-address=$MYBEAKERMASTER -U"

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    "REPLICA")
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    "CLIENT")
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
}

ipa_install_slave_all(){
    USEDNS="yes"
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    DOMAIN=$(grep ^DOMAIN= /opt/rhqa_ipa/env.sh|cut -f2- -d=)
    rlLog "ipa_install_slave_all: Install and configure IPA Replica/Slave"
    case "$MYROLE" in
    "MASTER")
        rlLog "Machine in recipe is MASTER"
        if [ "x$USEDNS" = "xyes" ]; then
            rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$MYBEAKERREPLICA1 $REPLICA_S.$DOMAIN"
        else
            rlRun "ipa-replica-prepare -p $ADMINPW $REPLICA"
        fi
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    "REPLICA")
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"
        if [ -f ~/.ssh/known_hosts ]; then
            rlRun "sed -i /$MASTER_S/d ~/.ssh/known_hosts"
            rlRun "sed -i /$MYBEAKERMASTER/d ~/.ssh/known_hosts"
        fi
        rlRun "AddToKnownHosts $MASTER"
        rlLog "pushd /opt/rhqa_ipa"
        pushd /opt/rhqa_ipa
        if [ "x$USEDNS" = "xyes" ]; then
            REPLICAFQDN=$REPLICA_S.$DOMAIN
        else
            REPLICAFQDN=$REPLICA
        fi
        rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$REPLICAFQDN.gpg"
        if [ -f /opt/rhqa_ipa/replica-info-$REPLICAFQDN.gpg ]; then
            ipa_install_prep
            rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICAFQDN.gpg"
            replicaBugCheck_bz830314
        else
            rlFail "ERROR: Replica Package not found"
        fi

        rlLog "popd"
        popd    
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.2' -m $MYBEAKERREPLICA1"
        ;;
    "CLIENT")
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
}

ipa_install_slave_nodns()
{
    USEDNS="no"
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    DOMAIN=$(dnsdomainname)
    rlLog "ipa_install_slave_nodns: Install and configure IPA Replica/Slave"
    case "$MYROLE" in
    "MASTER")
        rlLog "Machine in recipe is MASTER"
        if [ "x$USEDNS" = "xyes" ]; then
            rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$MYBEAKERREPLICA1 $REPLICA_S.$DOMAIN"
        else
            rlRun "sed -i '/$REPLICA_S/d' /etc/hosts"
            rlRun "echo '$MYBEAKERREPLICA1 $REPLICA $REPLICA_S' >> /etc/hosts"
            rlRun "ipa-replica-prepare -p $ADMINPW $REPLICA"
        fi
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    "REPLICA")
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"
        if [ -f ~/.ssh/known_hosts ]; then
            rlRun "sed -i /$MASTER_S/d ~/.ssh/known_hosts"
            rlRun "sed -i /$MYBEAKERMASTER/d ~/.ssh/known_hosts"
        fi
        rlRun "AddToKnownHosts $MASTER"
        rlLog "pushd /opt/rhqa_ipa"
        pushd /opt/rhqa_ipa
        if [ "x$USEDNS" = "xyes" ]; then
            REPLICAFQDN=$REPLICA_S.$DOMAIN
        else
            REPLICAFQDN=$REPLICA
        fi
        rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$REPLICAFQDN.gpg"
        rlLog "Checking for existance of replica gpg file"
        if [ -f /opt/rhqa_ipa/replica-info-$REPLICAFQDN.gpg ]; then
            ipa_install_prep
            rlRun "ipa-replica-install -U -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICAFQDN.gpg"
        else
            rlFail "ERROR: Replica Package not found"
        fi

        rlLog popd
        popd
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.2' -m $MYBEAKERREPLICA1"
        ;;
    "CLIENT")
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
}

ipa_install_client(){
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "ipa_install_client: Install IPA client"
    case "$MYROLE" in
    "MASTER")
        rlLog "Machine in recipe is MASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERCLIENT"
        ;;
    "REPLICA")
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERCLIENT"
        ;;
    "CLIENT")
        rlLog "Machine in recipe is CLIENT"
        if [ "x$USEDNS" = "xyes" ]; then
            DOMAIN=$(grep ^DOMAIN= /opt/rhqa_ipa/env.sh|cut -f2- -d=)
        else
            DOMAIN=$(dnsdomainname)
        fi
        #commenting out debugging code
        #rlRun "cat /etc/hosts"
        #rlRun "nslookup $CLIENT_S.$DOMAIN"

        # Configure IPA CLIENT
        ipa_install_prep
        
        if [ "x$USEDNS" = "xyes" ]; then
            rlRun "echo \"$MYBEAKERMASTER $MASTER_S.$DOMAIN $MASTER_S\" >> /etc/hosts"
        fi

        if [ "x$USEDNS" = "xyes" ]; then
            rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER_S.$DOMAIN"
        else
            rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER"
        fi
            

        #submit_log /var/log/ipaclient-install.log
        #if [ -f /var/log/ipaclient-install.log ]; then
        #   DATE=$(date +%Y%m%d-%H%M%S)
        #   cp -f /var/log/ipaclient-install.log /var/log/ipaclient-install.log.$DATE
        #   rhts-submit-log -l /var/log/ipaclient-install.log.$DATE
        #fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERCLIENT"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
}
