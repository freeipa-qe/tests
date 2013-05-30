#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA ipa-upgrade acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#   Date  : Nar 12, 2012
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


ipa_upgrade_master_replica_client_all()
{   
    reset_repos
    USEDNS="yes"
    IPA_SERVER_OPTIONS="-U --setup-dns --forwarder=$DNSFORWARD --hostname=$MASTER_S.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW"
    IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICA1_S.$DOMAIN.gpg"
    IPA_CLIENT_OPTIONS="-d -U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER_S.$DOMAIN"

    rlPhaseStartSetup "ipa_upgrade_master_replica_client_all_setup: setup to test full setup for master, then replica, then client"
        rlRun "env|sort"
        # Install and setup environment and add data
        ipa_upgrade_install_master
        ipa_upgrade_install_replica
        ipa_upgrade_install_client

        #rlLog "DEBUGGING client failure"
        #rlRun "cat /etc/ipa/.dns_update.txt"
        #rlRun "sleep 10000000"

        ipa_upgrade_data_add $MYBEAKERMASTER
        ipa_upgrade_data_check $MYBEAKERREPLICA1
    rlPhaseEnd
        
    rlPhaseStartTest "ipa_upgrade_master_replica_client_all_1: test upgrade with new master, old replica, and old client"
        upgrade_master 
        ipa_upgrade_data_add $MYBEAKERMASTER $LATESTVER
        ipa_upgrade_data_check $MYBEAKERMASTER $LATESTVER new
        ipa_upgrade_bz_949885 $MYBEAKERREPLICA1
        if [ $? -ne 1 ]; then
            ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER old
        else
            rlFail "Skipping ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER old"
            rlFail "Bug 949885 hit and data checks will fail until replica upgraded"
        fi
        ipa_upgrade_data_check $MYBEAKERCLIENT $LATESTVER old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_all_2: test upgrade with new master, new replica, and old client"
        upgrade_replica
        ipa_upgrade_data_check $MYBEAKERMASTER $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERCLIENT $LATESTVER old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_all_3: test upgrade with new master, new replica, and new client"
        upgrade_client
        ipa_upgrade_data_check $MYBEAKERMASTER $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERCLIENT $LATESTVER new
    rlPhaseEnd

    rlPhaseStartCleanup "ipa_upgrade_master_replica_client_all_cleanup: cleanup from test full setup for master, then replica, then client"
        ipa_upgrade_uninstall_client
        ipa_upgrade_uninstall_replica
        ipa_upgrade_uninstall_master
    rlPhaseEnd
}
    
ipa_upgrade_master_replica_parallel()
{
    reset_repos
    USEDNS="yes"
    IPA_SERVER_OPTIONS="-U --setup-dns --forwarder=$DNSFORWARD --hostname=$MASTER_S.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW"
    IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICA1_S.$DOMAIN.gpg"
    IPA_CLIENT_OPTIONS="-d -U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER_S.$DOMAIN"

    rlPhaseStartSetup "ipa_upgrade_test_master_replica_parallel_setup: setup to test parallel upgrade for master and replica, then client"
        rlRun "env|sort"
        # Install and setup environment and add data
        ipa_upgrade_install_master
        if [ -f /var/log/ipaserver-install.log ]; then
            log1=/var/log/ipaserver-install.log
            rlRun "cp $log1 $log1.parallel"
            rlRun "rhts-submit-log -l $log1.parallel"
        fi
        ipa_upgrade_install_replica
        ipa_upgrade_install_client
        #rlLog "DEBUG SLEEP"
        #rlRun "sleep 1000000"
        ipa_upgrade_data_add $MYBEAKERMASTER
        ipa_upgrade_data_check $MYBEAKERMASTER
    rlPhaseEnd
        
    rlPhaseStartTest "ipa_upgrade_test_master_replica_parallel_1: test upgrade with new master, old replica, and old client"
        upgrade_master_replica
        ipa_upgrade_data_check $MYBEAKERMASTER
        ipa_upgrade_data_check $MYBEAKERREPLICA1
        ipa_upgrade_data_check $MYBEAKERCLIENT
    rlPhaseEnd

    rlPhaseStartCleanup "ipa_upgrade_master_replica_parallel_cleanup: cleanup from test full setup for master, then replica, then client"
        ipa_upgrade_uninstall_client
        ipa_upgrade_uninstall_replica
        ipa_upgrade_uninstall_master
    rlPhaseEnd
}

ipa_upgrade_master_replica_client_inc()
{
    ipa_upgrade_master_replica_client_inc_setup
    if rlIsRHEL "<6.3"; then
        ipa_upgrade_master_replica_client_inc_63
    fi
    if rlIsRHEL "6.3"; then
        ipa_upgrade_master_replica_client_inc_64
    fi
    #if rlIsRHEL "6.4"; then
    #    ipa_upgrade_master_replica_client_inc_65
    #fi
    #if rlIsRHEL "6.5"; then
    #    ipa_upgrade_master_replica_client_inc_66
    #fi
    #if rlIsRHEL "6.6"; then
    #    ipa_upgrade_master_replica_client_inc_67
    #fi
    #if rlIsRHEL "6.7"; then
    #    ipa_upgrade_master_replica_client_inc_68
    #fi
    #if rlIsRHEL "6.8"; then
    #    ipa_upgrade_master_replica_client_inc_69
    #fi
    ipa_upgrade_master_replica_client_inc_cleanup
}

ipa_upgrade_master_replica_client_inc_setup()
{   
    IPA_SERVER_OPTIONS="-U --setup-dns --forwarder=$DNSFORWARD --hostname=$MASTER_S.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW"
    IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICA1_S.$DOMAIN.gpg"
    IPA_CLIENT_OPTIONS="-U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER_S.$DOMAIN"
    USEDNS="yes"

    rlPhaseStartSetup "ipa_upgrade_master_replica_client_inc_setup: setup to test full setup for master, then replica, then client"
        rlRun "env|sort"
        # Install and setup environment and add data
        ipa_upgrade_install_master
        ipa_upgrade_install_replica
        ipa_upgrade_install_client
        ipa_upgrade_data_add $MYBEAKERMASTER
    rlPhaseEnd
}
        
ipa_upgrade_master_replica_client_inc_cleanup()
{
    rlPhaseStartCleanup "ipa_upgrade_master_replica_client_inc_cleanup: cleanup from test full setup for master, then replica, then client"
        ipa_upgrade_uninstall_client
        ipa_upgrade_uninstall_replica
        ipa_upgrade_uninstall_master
    rlPhaseEnd
}

ipa_upgrade_master_replica_client_inc_63()
{   
    unset ${!myrepo*}
    myrepo1=http://download.devel.redhat.com/released/RHEL-6/6.3/Server/\$basearch/os/
    myrepo2=http://download.devel.redhat.com/released/RHEL-6/6.3/Server/optional/\$basearch/os/
    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_63_1: test upgrade with new master, old replica, and old client"
        upgrade_master
        ipa_upgrade_data_add   $MYBEAKERMASTER   63

        ipa_upgrade_data_check $MYBEAKERMASTER   63 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 63 old
        ipa_upgrade_data_check $MYBEAKERCLIENT   63 old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_63_2: test upgrade with new master, new replica, and old client"
        upgrade_replica

        ipa_upgrade_data_check $MYBEAKERMASTER   63 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 63 new
        ipa_upgrade_data_check $MYBEAKERCLIENT   63 old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_63_3: test upgrade with new master, new replica, and new client"
        upgrade_client

        ipa_upgrade_data_check $MYBEAKERMASTER   63 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 63 new
        ipa_upgrade_data_check $MYBEAKERCLIENT   63 new
    rlPhaseEnd
}

ipa_upgrade_master_replica_client_inc_64()
{   
    unset ${!myrepo*}
    myrepo1=http://download.devel.redhat.com/released/RHEL-6/6.4/Server/\$basearch/os/
    myrepo2=http://download.devel.redhat.com/released/RHEL-6/6.4/Server/optional/\$basearch/os/
    IPA_SERVER_OPTIONS="-U --setup-dns --forwarder=$DNSFORWARD --hostname=$MASTER_S.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW"
    IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICA1_S.$DOMAIN.gpg"
    IPA_CLIENT_OPTIONS="-U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER_S.$DOMAIN"
    USEDNS="yes"

    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_64_1: test upgrade with new master, old replica, and old client"
        upgrade_master
        ipa_upgrade_data_add   $MYBEAKERMASTER   64

        ipa_upgrade_data_check $MYBEAKERMASTER   64 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 64 old
        ipa_upgrade_data_check $MYBEAKERCLIENT   64 old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_64_2: test upgrade with new master, new replica, and old client"
        upgrade_replica

        ipa_upgrade_data_check $MYBEAKERMASTER   64 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 64 new 
        ipa_upgrade_data_check $MYBEAKERCLIENT   64 old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_64_3: test upgrade with new master, new replica, and new client"
        upgrade_client

        ipa_upgrade_data_check $MYBEAKERMASTER   64 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 64 new
        ipa_upgrade_data_check $MYBEAKERCLIENT   64 new
    rlPhaseEnd
}

ipa_upgrade_client_replica_master_all()
{
    reset_repos
    USEDNS="yes"
    IPA_SERVER_OPTIONS="--setup-dns --forwarder=$DNSFORWARD --hostname=$MASTER_S.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
    IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICA1_S.$DOMAIN.gpg"
    IPA_CLIENT_OPTIONS="-U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER_S.$DOMAIN"

    local tmpout=/tmp/errormsg.out
    rlPhaseStartSetup "ipa_upgrade_client_replica_master_all_setup: setup to test full setup for client, then replica, then master"
        rlRun "env|sort"
        # Install and setup environment and add data
        ipa_upgrade_install_master
        ipa_upgrade_install_replica
        ipa_upgrade_install_client
        ipa_upgrade_data_add $MYBEAKERMASTER
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_client_replica_master_all_1: test upgrade with old master, old replica, and new client"
        upgrade_client
        # No data_check here because it will fail...need negative checks for ipa commands
        # can't upgrade client first or ipa commands won't work.  native ones do but, ipa ones don't.
        if [ $(echo "$MYROLE" |grep "CLIENT"|wc -l) -gt 0 ]; then
            KinitAsAdmin 
            rlLog "Running negative test for ipa commands failing when client upgraded first"
            rlRun "ipa --delegate user-find > $tmpout 2>&1" 1
            if [ $(grep "ERROR.*client incompatible with.*server" $tmpout| wc -l) -gt 0 ]; then
                rlPass "Expected failure seen running ipa commands after upgrading client first"
            fi
            rlRun "cat $tmpout"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_client_replica_master_all_2: test upgrade with old master, new replica, and new client"
        upgrade_replica
        ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_client_replica_master_all_3: test upgrade with new master, new replica, and new client [BZ962885]"
        #rlRun "sleep 600"
        upgrade_master 
        ipa_upgrade_data_add $MYBEAKERMASTER $LATESTVER
        ipa_upgrade_data_check $MYBEAKERMASTER $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERCLIENT $LATESTVER new
        if [ $IPADEBUG ]; then
            rlRun "sleep 1000000"
        fi
        upgrade_bz_962885
    rlPhaseEnd

    rlPhaseStartCleanup "ipa_upgrade_client_replica_master_all_cleanup: cleanup from test full setup for client, then replica, then master"
        ipa_upgrade_uninstall_client
        ipa_upgrade_uninstall_replica
        ipa_upgrade_uninstall_master
    rlPhaseEnd
}

ipa_upgrade_master_replica_client_nodns()
{
    reset_repos
    USEDNS="no"
    TESTDOMAIN=${DOMAIN}

    # Reset variables for nodns test
    ipa_install_envcleanup
    DOMAIN=$(dnsdomainname)
    MASTER=$MYBEAKERMASTER
    REPLICA=$MYBEAKERREPLICA1
    CLIENT=$MYBEAKERCLIENT
    ipa_install_set_vars
    DOMAIN=$(dnsdomainname)

    IPA_SERVER_OPTIONS="-U --hostname=$MYBEAKERMASTER -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
    IPA_REPLICA_OPTIONS="-U -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$MYBEAKERREPLICA1.gpg"
    IPA_CLIENT_OPTIONS="-d -U --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MYBEAKERMASTER --domain=$DOMAIN"

    rlPhaseStartSetup "ipa_upgrade_master_replica_client_nodns_setup: setup to test without dns for master, then replica, then client"
        rlRun "env|sort"
        rlLog "Setting up  IPv6 AAAA resolvable workaround"
        for THISHOST in $MYBEAKERMASTER $MYBEAKERREPLICA1 $MYBEAKERCLIENT; do
            THISA="$(dig +short $THISHOST a)"
            THISAAAA="$(dig +short $THISHOST aaaa)"
            rlLog "First remove IP entry from /etc/hosts if found."
            rlRun "sed -i '/$THISA/d' /etc/hosts"
            ## removing check for AAAA as it seems there are some lab DNS 
            ## issues that can be resolved here by using /etc/hosts entries
            #if [ -n "$THISA" ]; then
            if [ -n "$THISAAAA" -a -n "$THISA" ]; then
                rlLog "$THISHOST has AAAA record.  Adding A to /etc/hosts"
                rlRun "echo \"$THISA $THISHOST\" >> /etc/hosts" 
            fi
        done
        ipa_upgrade_install_master
        ipa_upgrade_install_replica
        ipa_upgrade_install_client
        ipa_upgrade_data_add $MYBEAKERMASTER
        ipa_upgrade_data_check $MYBEAKERMASTER
    rlPhaseEnd
        
    rlPhaseStartTest "ipa_upgrade_master_replica_client_nodns_1: test upgrade with new master, old replica, and old client"
        upgrade_master 
        ipa_upgrade_data_add $MYBEAKERMASTER $LATESTVER
        ipa_upgrade_data_check $MYBEAKERMASTER $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER old

        if [ $(echo "$MYROLE" | grep -i "CLIENT" | wc -l) -gt 0 ]; then

            rlLog "DEBUG LOCALLOOKUPFAILURES !!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            rlLog
            rlRun "cp -f /etc/sssd/sssd.conf /etc/sssd/sssd.conf.nodns_1"
            rlLog "Running: sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf"
            sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf
            rlRun "cat /etc/sssd/sssd.conf"
            rlRun "service sssd restart"
            rlRun "sleep 5"
            rlRun "cat /dev/null > /var/log/sssd/sssd_${DOMAIN}.log"
            rlRun "id jack"
            rlRun "submit_log /var/log/sssd/sssd_${DOMAIN}.log"
            rlRun "cp -f /etc/sssd/sssd.conf.nodns_1 /etc/sssd/sssd.conf"
            rlRun "rm -f /etc/sssd/sssd.conf.nodns_1"
            rlRun "service sssd restart"
            rlRun "sleep 5"
            rlLog
            rlLog "DEBUG LOCALLOOKUPFAILURES !!!!!!!!!!!!!!!!!!!!!!!!!!!!"

        fi

        ipa_upgrade_data_check $MYBEAKERCLIENT $LATESTVER old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_nodns_2: test upgrade with new master, new replica, and old client"
        upgrade_replica
        ipa_upgrade_data_check $MYBEAKERMASTER $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERCLIENT $LATESTVER old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_nodns_3: test upgrade with new master, new replica, and new client"
        upgrade_client
        ipa_upgrade_data_check $MYBEAKERMASTER $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERCLIENT $LATESTVER new
    rlPhaseEnd

    rlPhaseStartCleanup "ipa_upgrade_master_replica_client_nodns_cleanup: cleanup from test without dns for master, then replica, then client"
        ipa_upgrade_uninstall_client
        ipa_upgrade_uninstall_replica
        ipa_upgrade_uninstall_master
        
        rlLog "Cleaning up IPv6 AAAA resolvable workaround"
        for THISHOST in $MYBEAKERMASTER $MYBEAKERREPLICA1 $MYBEAKERCLIENT; do
            if [ $(grep $THISHOST /etc/hosts|wc -l) -gt 0 ]; then
                rlLog "Removing $THISHOST from /etc/hosts"
                rlRun "sed -i '/$THISHOST/d' /etc/hosts"
            fi
        done
    rlPhaseEnd

    DOMAIN=${TESTDOMAIN}
}


ipa_upgrade_master_replica_client_dirsrv_off()
{
    reset_repos
    USEDNS="yes"
    IPA_SERVER_OPTIONS="-U --setup-dns --forwarder=$DNSFORWARD --hostname=$MASTER_S.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW"
    IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICA1_S.$DOMAIN.gpg"
    IPA_CLIENT_OPTIONS="-d -U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER_S.$DOMAIN"

    rlPhaseStartSetup "ipa_upgrade_master_replica_client_dirsrv_off_setup: setup to test full setup for master, then replica, then client"
        rlRun "env|sort"
        # Install and setup environment and add data
        ipa_upgrade_install_master
        ipa_upgrade_install_replica
        ipa_upgrade_install_client
        ipa_upgrade_data_add $MYBEAKERMASTER
        ipa_upgrade_data_check $MYBEAKERREPLICA1
    rlPhaseEnd
        
    rlPhaseStartTest "ipa_upgrade_master_replica_client_dirsrv_off_1: test with dirsrv off before upgrade with new master, old replica, and old client"
        if [ $(echo "$MYROLE" | grep -i "MASTER" | wc -l) -gt 0 ]; then
            rlLog "Shutting down dirsrv before upgrading MASTER ($(hostname))"
            rlRun "service dirsrv stop"
        fi
        upgrade_master 
        upgrade_bz_895298_check_master  
        ipa_upgrade_data_add $MYBEAKERMASTER $LATESTVER
        ipa_upgrade_data_check $MYBEAKERMASTER $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER old
        ipa_upgrade_data_check $MYBEAKERCLIENT $LATESTVER old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_dirsrv_off_2: test dirsrv off before upgrade with new master, new replica, and old client"
        if [ $(echo "$MYROLE" | grep -i "REPLICA" | wc -l) -gt 0 ]; then
            rlLog "Shutting down dirsrv before upgrading REPLICA ($(hostname))"
            rlRun "service dirsrv stop"
        fi
        upgrade_replica
        upgrade_bz_895298_check_replica
        ipa_upgrade_data_check $MYBEAKERMASTER $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERCLIENT $LATESTVER old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_dirsrv_off_3: test upgrade with new master, new replica, and new client"
        upgrade_client
        ipa_upgrade_data_check $MYBEAKERMASTER $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 $LATESTVER new
        ipa_upgrade_data_check $MYBEAKERCLIENT $LATESTVER new
    rlPhaseEnd

    rlPhaseStartCleanup "ipa_upgrade_master_replica_client_dirsrv_off_cleanup: cleanup from test full setup for master, then replica, then client"
        ipa_upgrade_uninstall_client
        ipa_upgrade_uninstall_replica
        ipa_upgrade_uninstall_master
    rlPhaseEnd
}

ipa_upgrade_master_bz_tests()
{
    reset_repos
    rlPhaseStartTest "ipa_upgrade_master_bz_tests: execute bug tests against a master upgrade"
        rlRun "env|sort"
        # Install and setup master for bug checks
        ipa_install_master_all
        ipa_install_replica_all

        # Running start function for 772359 to capture info before upgrade
        upgrade_bz_772359_start

        # Alter the bind configuration to ensure that BZ 819629 will be tested properly
        upgrade_bz_819629_setup

        # upgrade master and check data
        upgrade_master
        upgrade_replica
        
        # Now execute bug checks
        upgrade_bz_819629
        upgrade_bz_772359_finish
        upgrade_bz_766096
        upgrade_bz_746589
        upgrade_bz_782918
        upgrade_bz_803054
        upgrade_bz_809262
        upgrade_bz_808201
        upgrade_bz_803930
        upgrade_bz_812391
        upgrade_bz_821176
        upgrade_bz_824074
        upgrade_bz_893722
        upgrade_bz_902474
        upgrade_bz_903758

        # uninstall everything so we can start over
        ipa_uninstall_replica
        ipa_uninstall_master
            
    rlPhaseEnd
}

ipa_upgrade_master_bz_866977()
{
    rlPhaseStartTest "ipa_upgrade_master_bz_866977: Inform user when ipa-upgradeconfig reports errors"
        rlRun "env|sort"
        ipa_install_master_all
        upgrade_bz_866977_setup
        upgrade_master 2>&1 | tee /tmp/upgrade_master_bz_866977.out
        upgrade_bz_866977_check
        ipa_uninstall_master
    rlPhaseEnd
}

ipa_upgrade_master_replica_client_all_final()
{   
    reset_repos
    rlPhaseStartTest "ipa_upgrade_master_replica_client_all_final: Install and upgrade to leave in a state for other testing"
        rlRun "env|sort"
        ipa_install_master_all
        ipa_install_replica_all
        ipa_install_client
        upgrade_master 
        upgrade_replica
        upgrade_client
    rlPhaseEnd
}
