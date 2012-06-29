#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-server/acceptance/quickinstall
#   Description: Quick install for master slave and client acceptance tests
#   Author: Jenny Galipeau <jgalipea@redhat.com>
#
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
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh
. ./install-lib.sh

# include tests
. ./t-install.sh

COMMON_SERVER_PACKAGES="bind expect krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl nmap"
RHELIPA_SERVER_PACKAGES="ipa-server"
COMMON_CLIENT_PACKAGES="httpd curl mod_nss mod_auth_kerb 389-ds-base expect ntpdate nmap"
RHELIPA_CLIENT_PACKAGES="ipa-admintools ipa-client"
FREEIPA_SERVER_PACKAGES="freeipa-server"
FREEIPA_CLIENT_PACKAGES="freeipa-admintools freeipa-client"

rlJournalStart
        myhostname=`hostname`
        rlLog "hostname command: $myhostname"
        rlLog "HOSTNAME: $HOSTNAME"
        rlLog "MASTER: $MASTER"
        rlLog "SLAVE: $SLAVE"
        rlLog "CLIENT: $CLIENT"
        rlLog "CLIENT2: $CLIENT2"
   
        echo "export BEAKERMASTER=$MASTER" >> /dev/shm/env.sh
        echo "export BEAKERSLAVE=\"$SLAVE\"" >> /dev/shm/env.sh
	echo "export BEAKERCLIENT=$CLIENT" >> /dev/shm/env.sh
	echo "export BEAKERCLIENT2=$CLIENT2" >> /dev/shm/env.sh

	I=0
	for S in $SLAVE; do
		I=$(( I += 1 ))
		echo "export BEAKERSLAVE${I}=$S" >> /dev/shm/env.sh
		echo "export BEAKERSLAVE${I}IP=$(dig +noquestion +short $S)" >> /dev/shm/env.sh
	done

	cat /etc/redhat-release | grep "Fedora"
	if [ $? -eq 0 ] ; then
		FLAVOR="Fedora"
		rlLog "Automation is running against Fedora"
	else
		FLAVOR="RedHat"
		rlLog "Automation is running against RedHat"
	fi

	#####################################################################
	# 		IS THIS MACHINE A MASTER?                           #
	#####################################################################
	rc=0
	echo $MASTER | grep $HOSTNAME
	if [ $? -eq 0 ] ; then
	   	yum clean all
	   	yum -y install $COMMON_SERVER_PACKAGES

	   	if [ "$FLAVOR" == "Fedora" ] ; then
			yum -y install --disablerepo=updates-testing $FREEIPA_SERVER_PACKAGES
                	yum -y update

	        	for item in $FREEIPA_SERVER_PACKAGES ; do
				rpm -qa | grep $item
				if [ $? -eq 0 ] ; then
					rlLog "$item package is installed"
				else
					rlLog "ERROR: $item package is NOT installed"
					rc=1
				fi
	   		done
	   	else
			yum -y install $RHELIPA_SERVER_PACKAGES
                	yum -y update

           		for item in $RHELIPA_SERVER_PACKAGES ; do
                		rpm -qa | grep $item
                		if [ $? -eq 0 ] ; then
                        		rlLog "$item package is installed"
                		else    
                        		rlLog "ERROR: $item package is NOT installed"
                        		rc=1    
                		fi      
           		done 
	     	fi	

			if [ -f /usr/share/ipa/bind.named.conf.template ]; then
				rlLog "Forcing debug logging in named.conf template"
				sed -i 's/severity dynamic/severity debug 10/' /usr/share/ipa/bind.named.conf.template
			fi

	    	if [ $rc -eq 0 ] ; then
			installMaster
			rhts-sync-set -s READY
			rlLog "Setting up Authorized keys"
	        	SetUpAuthKeys
        		rlLog "Setting up known hosts file"
        		SetUpKnownHosts
	    	fi
	else
		rlLog "Machine in recipe in not a MASTER"
	fi

	#####################################################################
	# 		IS THIS MACHINE A SLAVE?                            #
	#####################################################################
	rc=0
        echo $SLAVE | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
	   	yum clean all
           	yum -y install $COMMON_SERVER_PACKAGES

           	if [ "$FLAVOR" == "Fedora" ] ; then
                	yum -y install --disablerepo=updates-testing $FREEIPA_SERVER_PACKAGES
                	yum -y update

                	for item in $FREEIPA_SERVER_PACKAGES ; do
                        	rpm -qa | grep $item
                        	if [ $? -eq 0 ] ; then
                                	rlLog "$item package is installed"
                        	else
                                	rlLog "ERROR: $item package is NOT installed"
                                	rc=1
                        	fi
                	done
           	else
                	yum -y install $RHELIPA_SERVER_PACKAGES
                	yum -y update

                	for item in $RHELIPA_SERVER_PACKAGES ; do
                        	rpm -qa | grep $item
                        	if [ $? -eq 0 ] ; then
                                	rlLog "$item package is installed"
                        	else
                                	rlLog "ERROR: $item package is NOT installed"
                                	rc=1
                        	fi
                	done
             	fi

			if [ -f /usr/share/ipa/bind.named.conf.template ]; then
				rlLog "Forcing debug logging in named.conf template"
				sed -i 's/severity dynamic/severity debug 10/' /usr/share/ipa/bind.named.conf.template
			fi


		if [ $rc -eq 0 ] ; then
			rhts-sync-block -s READY $MASTER
                	installSlave
			rhts-sync-set -s READY
                        rlLog "Setting up Authorized keys"
                        SetUpAuthKeys
                        rlLog "Setting up known hosts file"
                        SetUpKnownHosts
        	fi
        else
                rlLog "Machine in recipe in not a SLAVE"
        fi

	#####################################################################
	# 		IS THIS MACHINE A CLIENT?                           #
	#####################################################################
	rc=0
        echo $CLIENT | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
	   	yum clean all
           	yum -y install $COMMON_CLIENT_PACKAGES

           	if [ "$FLAVOR" == "Fedora" ] ; then
                	yum -y install --disablerepo=updates-testing $FREEIPA_CLIENT_PACKAGES
                	yum -y update

                	for item in $FREEIPA_CLIENT_PACKAGES ; do
                        	rpm -qa | grep $item
                        	if [ $? -eq 0 ] ; then
                                	rlLog "$item package is installed"
                        	else
                                	rlLog "ERROR: $item package is NOT installed"
                                	rc=1
                        	fi
                	done
           	else
                	yum -y install $RHELIPA_CLIENT_PACKAGES
                	yum -y update

                	for item in $RHELIPA_CLIENT_PACKAGES ; do
                        	rpm -qa | grep $item
                        	if [ $? -eq 0 ] ; then
                                	rlLog "$item package is installed"
                        	else
                                	rlLog "ERROR: $item package is NOT installed"
                                	rc=1
                        	fi
                	done
             	fi

		if [ $rc -eq 0 ] ; then
                        rhts-sync-block -s READY $MASTER
			if [ $SLAVE != "" ] ; then
				rhts-sync-block -s READY $SLAVE
			fi
                	installClient
        	fi
        else
                rlLog "Machine in recipe in not a CLIENT"
        fi

        #####################################################################
        #               IS THIS MACHINE CLIENT2?                            #
        #####################################################################
        rc=0
        echo $CLIENT2 | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
	   	yum clean all
           	yum -y install $COMMON_SERVER_PACKAGES

           	if [ "$FLAVOR" == "Fedora" ] ; then
                	yum -y install --disablerepo=updates-testing $FREEIPA_SERVER_PACKAGES
                	yum -y update

                	for item in $FREEIPA_SERVER_PACKAGES ; do
                        	rpm -qa | grep $item
                        	if [ $? -eq 0 ] ; then
                                	rlLog "$item package is installed"
                        	else
                                	rlLog "ERROR: $item package is NOT installed"
                                	rc=1
                        	fi
                	done
            	else
                	yum -y install $RHELIPA_SERVER_PACKAGES
                	yum -y update

                	for item in $RHELIPA_SERVER_PACKAGES ; do
                        	rpm -qa | grep $item
                        	if [ $? -eq 0 ] ; then
                                	rlLog "$item package is installed"
                        	else
                                	rlLog "ERROR: $item package is NOT installed"
                                	rc=1
                        	fi
                	done
             	fi

                if [ $rc -eq 0 ] ; then
                        rhts-sync-block -s READY $MASTER
                        if [ $SLAVE -ne "" ] ; then
                                rhts-sync-block -s READY $SLAVE
                        fi
                        installClient
                fi
        else
                rlLog "Machine in recipe in not a CLIENT2"
        fi

   rlJournalPrintText
   report=/tmp/rhts.report.$RANDOM.txt
   makereport $report
   rhts-submit-log -l $report
rlJournalEnd

