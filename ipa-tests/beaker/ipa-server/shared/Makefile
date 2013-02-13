# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Makefile of /CoreOS/ipa-server/acceptance/install
#   Description: Basic install test for ipa-server
#   Author: Michael Gregg <mgregg@redhat.com>
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
export TEST=/CoreOS/ipa-server/shared
export TESTVERSION=1.0.2

BUILT_FILES=

FILES=$(METADATA) ipa-server-shared.sh runtest.sh ipa-host-cli-lib.sh ipa-group-cli-lib.sh ipa-hostgroup-cli-lib.sh ipa-service-cli-lib.sh ipa-netgroup-cli-lib.sh ipa-hbac-cli-lib.sh lib.user-cli.sh ipa-automember-cli-lib.sh Makefile PURPOSE set-root-pw.exp nis.sh id_rsa.pub id_rsa id_dsa.pub id_dsa env.sh id_rsa_global.pub id_rsa_global known_hosts lib.ds-migration.sh ipa-rbac-cli-lib.sh ipa-selinuxusermap-cli-lib.sh ipa-install.sh install-lib.sh

.PHONY: all install download clean

run: $(FILES) build
	#yum -y install expect
	#expect ./set-root-pw.exp
	#wget http://apoc.dsdev.sjc.redhat.com/tet/rhts-get.txt
	rm -f /dev/shm/env.sh
	cp ./env.sh /dev/shm/.
	rm -f /dev/shm/ipa-server-shared.sh
	cp ./ipa-server-shared.sh /dev/shm/.
	rm -f /dev/shm/ipa-install.sh
	cp ./ipa-install.sh /dev/shm/.
	rm -f /dev/shm/ipa-host-cli-lib.sh
	cp ./ipa-host-cli-lib.sh /dev/shm/.
	rm -f /dev/shm/ipa-hostgroup-cli-lib.sh
	cp ./ipa-hostgroup-cli-lib.sh /dev/shm/.
	rm -f /dev/shm/ipa-netgroup-cli-lib.sh
	cp ./ipa-netgroup-cli-lib.sh /dev/shm/.
	rm -f /dev/shm/ipa-group-cli-lib.sh
	cp ./ipa-group-cli-lib.sh /dev/shm/.
	rm -f /dev/shm/ipa-hbac-cli-lib.sh
	cp ./ipa-hbac-cli-lib.sh /dev/shm/.
	rm -f /dev/shm/ipa-automember-cli-lib.sh
	cp ./ipa-automember-cli-lib.sh /dev/shm/.
	rm -f /dev/shm/lib.ds-migration.sh
	cp ./lib.ds-migration.sh /dev/shm/.
	rm -f /dev/shm/lib.user-cli.sh
	cp ./lib.user-cli.sh /dev/shm/.
	rm -f /dev/shm/ipa-service-cli-lib.sh
	cp ./ipa-service-cli-lib.sh /dev/shm/.
	rm -f /dev/shm/nis.sh
	cp ./nis.sh /dev/shm/.
	rm -f /dev/shm/ipa-rbac-cli-lib.sh
	cp ./ipa-rbac-cli-lib.sh /dev/shm/.
	rm -f /dev/shm/ipa-selinuxusermap-cli-lib.sh
	cp ./ipa-selinuxusermap-cli-lib.sh /dev/shm/.
	rm -f /dev/shm/install-lib.sh
	cp ./install-lib.sh /dev/shm/.
	rm -f /dev/shm/set-root-pw.exp
	cp ./set-root-pw.exp /dev/shm/.
	rm -f /dev/shm/id_rsa*
	cp ./id_rsa* /dev/shm/.
	mkdir -p /root/.ssh
	cp ./id_rsa* /root/.ssh/.
	rm -f /dev/shm/id_dsa*
	cp ./id_dsa* /dev/shm/.
	cp ./id_dsa* /root/.ssh/.
	cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
	cat /root/.ssh/id_dsa.pub >> /root/.ssh/authorized_keys2
	cp -f ./id_rsa_global.pub /dev/shm/.
	cp -f ./id_rsa_global /dev/shm/.
	cp -f ./known_hosts /dev/shm/.
	chmod 755 /dev/shm/*.sh
	chmod 600 /root/.ssh
	chmod 600 /root/.ssh/id*
	chmod 600 /root/.ssh/authorized_keys
	chmod 600 /root/.ssh/authorized_keys2
	./runtest.sh

build: $(BUILT_FILES)
	chmod 755 ipa-server-shared.sh
	chmod 755 set-root-pw.exp
	chmod a+x runtest.sh

clean:
	rm -f *~ $(BUILT_FILES)


include /usr/share/rhts/lib/rhts-make.include

$(METADATA): Makefile
	@echo "Owner:           Michael Gregg <mgregg@redhat.com>" > $(METADATA)
	@echo "Name:            $(TEST)" >> $(METADATA)
	@echo "TestVersion:     $(TESTVERSION)" >> $(METADATA)
	@echo "Path:            $(TEST_DIR)" >> $(METADATA)
	@echo "Description:     Package containing libraries for ipa-server beaker tests" >> $(METADATA)
	@echo "Type:            Acceptance" >> $(METADATA)
	@echo "TestTime:        2m" >> $(METADATA)
	@echo "RunFor:          ipa-server" >> $(METADATA)
	@echo "Requires:        expect" >> $(METADATA)
	@echo "Priority:        Normal" >> $(METADATA)
	@echo "License:         GPLv2" >> $(METADATA)
	@echo "Confidential:    no" >> $(METADATA)
	@echo "Destructive:     no" >> $(METADATA)

	rhts-lint $(METADATA)
