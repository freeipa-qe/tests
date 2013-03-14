# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Makefile of /CoreOS/ipa-server/acceptance/repoclone
#   Description: Repo clone of IPA daily repo
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

export TEST=/CoreOS/ipa-server/repoclone
export TESTVERSION=3.0

BUILT_FILES=

FILES=$(METADATA) runtest.sh rhel-gold.repo Makefile PURPOSE

.PHONY: all install download clean

run: $(FILES) build
	#yum -y install expect
	#expect ./set-root-pw.exp
	#wget http://apoc.dsdev.sjc.redhat.com/tet/rhts-get.txt
	chmod 755 ./rhel-gold.repo
	cp ./rhel-gold.repo /opt/rhqa_ipa/.
	./runtest.sh

build: $(BUILT_FILES)
	chmod a+x runtest.sh

clean:
	rm -f *~ $(BUILT_FILES)


include /usr/share/rhts/lib/rhts-make.include

$(METADATA): Makefile
	@echo "Owner:           Michael Gregg <mgregg@redhat.com>" > $(METADATA)
	@echo "Name:            $(TEST)" >> $(METADATA)
	@echo "TestVersion:     $(TESTVERSION)" >> $(METADATA)
	@echo "Path:            $(TEST_DIR)" >> $(METADATA)
	@echo "Description:     Clones the ipa daily repo" >> $(METADATA)
	@echo "Type:            Acceptance" >> $(METADATA)
	@echo "TestTime:        15m" >> $(METADATA)
	@echo "RunFor:          ipa-server" >> $(METADATA)
	@echo "Requires:        ipa-server" >> $(METADATA)
	@echo "Priority:        Normal" >> $(METADATA)
	@echo "License:         GPLv2" >> $(METADATA)
	@echo "Confidential:    no" >> $(METADATA)
	@echo "Destructive:     no" >> $(METADATA)

	rhts-lint $(METADATA)
