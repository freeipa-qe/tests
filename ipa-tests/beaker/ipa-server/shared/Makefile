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
export TESTVERSION=1.0

BUILT_FILES=

FILES=$(METADATA) ipa-server-shared.sh ipa-host-cli-lib.sh Makefile PURPOSE set-root-pw.exp id_rsa.pub id_rsa 

.PHONY: all install download clean

run: $(FILES) build
	#yum -y install expect
	#expect ./set-root-pw.exp
	#wget http://apoc.dsdev.sjc.redhat.com/tet/rhts-get.txt
	rm -f /dev/shm/ipa-server-shared.sh
	cp ./ipa-server-shared.sh /dev/shm/.
	rm -f /dev/shm/ipa-host-cli-lib.sh
	cp ./ipa-host-cli-lib.sh /dev/shm/.
	rm -f /dev/shm/set-root-pw.exp
	cp ./set-root-pw.exp /dev/shm/.
	rm -f /dev/shm/id_rsa*
	cp ./id_rsa* /dev/shm/.
	mkdir /root/.ssh
	cp ./id_rsa* /root/.ssh/.
	chmod 600 /root/.ssh
	chmod 600 /root/.ssh/id*

build: $(BUILT_FILES)
	chmod 755 ipa-server-shared.sh
	chmod 755 set-root-pw.exp

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
	@echo "Requires:        ipa-server" >> $(METADATA)
	@echo "Priority:        Normal" >> $(METADATA)
	@echo "License:         GPLv2" >> $(METADATA)
	@echo "Confidential:    no" >> $(METADATA)
	@echo "Destructive:     no" >> $(METADATA)

	rhts-lint $(METADATA)
