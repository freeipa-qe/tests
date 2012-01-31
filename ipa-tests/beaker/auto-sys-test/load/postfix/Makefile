# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Makefile of /CoreOS/automation-and-system-test/load/postfix-setup
#   Description: Tests setup and exercise of nis integrated ipa tasks
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

export TEST=/CoreOS/automation-and-system-test/load/postfix-setup
export TESTVERSION=1.0

BUILT_FILES=

FILES=$(METADATA) runtest.sh t.postfix-setup.sh Makefile PURPOSE main.cf imapd.conf cyrus.conf ldap-aliases.cf ldap-gid.cf ldap-uid.cf ldap-users.cf

.PHONY: all install download clean

run: $(FILES) build
	./runtest.sh

build: $(BUILT_FILES)
	chmod a+x runtest.sh
	rm -f /dev/shm/main.cf
	cp ./main.cf /dev/shm/.
	rm -f /dev/shm/ldap*.cf
	cp ./ldap-aliases.cf /dev/shm/.
	cp ./ldap-gid.cf /dev/shm/.
	cp ./ldap-uid.cf /dev/shm/.
	cp ./ldap-users.cf /dev/shm/.
	rm -f /dev/shm/imapd.conf
	rm -f /dev/shm/cyrus.conf
	cp ./imapd.conf /dev/shm/.
	cp ./cyrus.conf /dev/shm/.

clean:
	rm -f *~ $(BUILT_FILES)


include /usr/share/rhts/lib/rhts-make.include

$(METADATA): Makefile
	@echo "Owner:           Michael Gregg <mgregg@redhat.com>" > $(METADATA)
	@echo "Name:            $(TEST)" >> $(METADATA)
	@echo "TestVersion:     $(TESTVERSION)" >> $(METADATA)
	@echo "Path:            $(TEST_DIR)" >> $(METADATA)
	@echo "Description:     bkr test initive postfix setup test" >> $(METADATA)
	@echo "Type:            Regression" >> $(METADATA)
	@echo "TestTime:        10m" >> $(METADATA)
	@echo "RunFor:          ipa-server" >> $(METADATA)
	@echo "Requires:        ipa-admintools" >> $(METADATA)
	@echo "Requires:        expect" >> $(METADATA)
	@echo "Priority:        Normal" >> $(METADATA)
	@echo "License:         GPLv2" >> $(METADATA)
	@echo "Confidential:    no" >> $(METADATA)
	@echo "Destructive:     no" >> $(METADATA)

	rhts-lint $(METADATA)
