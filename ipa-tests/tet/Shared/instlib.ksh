# This file installs and uninstalls IPA server and client
# It's got several subs:
#       servername is usally S1, or S2, or C1, or C2, etc.
#       servername will be 
# InstallServerRPM(servername) 
#       Installs the server specified at servername.
# InstallClientRPM(servername)
#	Installs the client rpms on the specified (not needed on servers that have the server RPM's installed)
# SetupServer(servername)
#	Runs ipa-server-install on the specified server.
# UninstallServer(servername)
#	runs ipa-server-install --uninstall
# SetupServerBogus(servername)
#	Runs ipa-server-install on the specified server with bad options.
# SetupClient(servername)
#	Runs ipa-client-install on the specified client. (not needed on servers with ipa-server set up.)
# SetupRepo(servername)
#	Downloads the repo specifed in the env file to the specified server.
# UninstallServerRPM(servername)
#	Runs ipa-server-install --uninstall. Then it verifies that assortment of files still looks good.
# UninstallClientRPM(servername)
#	Runs ipa-client-install --uninstall. Then it verifies that assortment of files still looks good.

SetupServer()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1
	echo "/usr/sbin/ipa-server-install -U --hostname=$FULLHOSTNAME -r $RELM_NAME -p $DM_ADMIN_PASS -P $KERB_MASTER_PASS -a $DM_ADMIN_PASS --setup-bind -u $DS_USER -d"
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-server-install -U --hostname=$FULLHOSTNAME -r $RELM_NAME -p $DM_ADMIN_PASS -P $KERB_MASTER_PASS -a $DM_ADMIN_PASS --setup-bind -u $DS_USER -d"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - ipa-server-install on $FULLHOSTNAME failed."
		return 1;
	fi

}

UninstallServer()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-server-install -U --uninstall"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - ipa-server-install -uninstall on $FULLHOSTNAME FAILED"
		return 1;
	fi
	return 0;

}

SetupServerBogus()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1
	echo "/usr/sbin/ipa-server-install -U --hostname=BOGUSNAME -r BOGUSRELM -p $DM_ADMIN_PASS -P $KERB_MASTER_PASS -a $DM_ADMIN_PASS --setup-bind -u $DS_USER -d"
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-server-install -U --hostname=BOGUSNAME -r BOGUSRELM -p $DM_ADMIN_PASS -P $KERB_MASTER_PASS -a $DM_ADMIN_PASS --setup-bind -u $DS_USER -d"
	ret=$?
	if [ $ret -eq 0 ]; then
		echo "ERROR - ipa-server-install on $FULLHOSTNAME passed when it shouldn't have."
		return 1;
	fi
	return 0;
}


SetupRepo()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1	
	if [ "$OS" != "RHEL" ]&&[ "$OS" != "FC" ]; then
		echo "OS isn't \"RHEL\" or \"FC\"."
		echo "Returning"
		return 0
	fi
	echo $REPO |grep ^http 
	if [ $? -eq 0 ]; then
		# the repo file is on http, going to wget it on the server
		ssh root@$FULLHOSTNAME "cd /etc/yum.repos.d;wget $REPO"
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "ssh to $FULLHOSTNAME failed"
			return 1
		fi	
	else
		# the repo file is likley a file.
		if [ ! -f $REPO ]; then
			echo "File $REPO not found."
			echo "Try using a absolute path in the env file, or, use a file on a http source (http://<path/file.repo)"
			return 1
		fi
		scp $REPO root@$FULLHOSTNAME:/etc/yum.repos.d/.
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "scp to $FULLHOSTNAME failed"
			return 1
		fi	
	fi

}

InstallServerRPM()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1	
	if [ "$OS" != "RHEL" ]&&[ "$OS" != "FC" ]; then
		echo "OS isn't \"RHEL\" or \"FC\"."
		echo "Returning"
		return 0
	fi
	ssh root@$FULLHOSTNAME "rpm -e --allmatches fedora-ds-base fedora-ds-base-devel"
	ssh root@$FULLHOSTNAME "rpm -e --allmatches redhat-ds-base-devel"
	ssh root@$FULLHOSTNAME "rpm -e --allmatches redhat-ds-base"
	ssh root@$FULLHOSTNAME "/usr/bin/yum clean all"
	ssh root@$FULLHOSTNAME "/etc/init.d/yum-updatesd stop;killall yum;sleep 1; killall -9 yum;yum -y install TurboGears cyrus-sasl-gssapi fedora-ds-base krb5-server krb5-server-ldap lm_sensors mod_python mozldap mozldap-tools perl-Mozilla-LDAP postgresql-libs python-cheetah python-cherrypy python-configobj python-decoratortools python-elixir python-formencode python-genshi python-json python-kerberos python-kid python-krbV python-nose python-paste python-paste-deploy python-paste-script python-protocols python-psycopg2 python-pyasn1 python-ruledispatch python-setuptools python-simplejson python-sqlalchemy python-sqlite2 python-sqlobject python-tgexpandingformwidget python-tgfastdata python-turbocheetah python-turbojson python-turbokid svrcore tcl Updating bind-libs bind-utils cyrus-sasl cyrus-sasl-devel cyrus-sasl-lib cyrus-sasl-md5 cyrus-sasl-plain krb5-devel krb5-libs bind caching-nameserver expect krb5-workstation"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ssh to $FULLHOSTNAME failed"
		return 1
	fi	

	ssh root@$FULLHOSTNAME "yum -y update TurboGears cyrus-sasl-gssapi fedora-ds-base krb5-server krb5-server-ldap lm_sensors mod_python mozldap mozldap-tools perl-Mozilla-LDAP postgresql-libs python-cheetah python-cherrypy python-configobj python-decoratortools python-elixir python-formencode python-genshi python-json python-kerberos python-kid python-krbV python-nose python-paste python-paste-deploy python-paste-script python-protocols python-psycopg2 python-pyasn1 python-ruledispatch python-setuptools python-simplejson python-sqlalchemy python-sqlite2 python-sqlobject python-tgexpandingformwidget python-tgfastdata python-turbocheetah python-turbojson python-turbokid svrcore tcl Updating bind-libs bind-utils cyrus-sasl cyrus-sasl-devel cyrus-sasl-lib cyrus-sasl-md5 cyrus-sasl-plain krb5-devel krb5-libs"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ssh to $FULLHOSTNAME failed"
#		return 1
	fi	

	ssh root@$FULLHOSTNAME 'find / | grep -v proc | grep -v dev > /list-before-ipa.txt'
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ssh to $FULLHOSTNAME failed"
		return 1
	fi	

	ssh root@$FULLHOSTNAME "yum -y install ipa-server ipa-admintools bind caching-nameserver expect krb5-workstation"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ssh to $FULLHOSTNAME failed"
		return 1
	fi	

	ssh root@$FULLHOSTNAME 'find / | grep -v proc | grep -v dev > /list-after-ipa.txt'
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ssh to $FULLHOSTNAME failed"
		return 1
	fi	

}

UnInstallServerRPM()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1	
	if [ "$OS" != "RHEL" ]&&[ "$OS" != "FC" ]; then
		echo "OS isn't \"RHEL\" or \"FC\"."
		echo "Returning"
		return 0
	fi
	ssh root@$FULLHOSTNAME "rpm -e --allmatches redhat-ds-base ipa-server ipa-admintools bind caching-nameserver expect krb5-workstation ipa-client ipa-server-selinux"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ssh to $FULLHOSTNAME failed"
		return 1
	fi	

	# Create a working resolv.conf, and remove any lingering redhat-ds packages"
	ssh root@$FULLHOSTNAME "rm -f /etc/bind.conf.ipasave; \
		mv /etc/bind.conf /etc/bind.cond.ipasave; \
		rm -f /etc/resolv.conf.ipasave; \
		cp /etc/resolv.conf /etc/resolv.conf.ipasave
		rpm -e --allmatches fedora-ds-base fedora-ds-base-devel; \
		rpm -e --allmatches redhat-ds-base-devel; \
		rpm -e --allmatches redhat-ds-base"

	ssh root@$FULLHOSTNAME 'find / | grep -v proc | grep -v dev > /list-after-ipa-uninstall.txt'
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ssh to $FULLHOSTNAME failed"
		return 1
	fi
	return 0
}

Cleanup()
{
	echo "START Cleanup"
	rm -f $TET_TMP_DIR/filelist.txt
	echo '/usr/sbin/ipa*
	/tmp/ipa*' > $TET_TMP_DIR/filelist.txt
	echo "working on $s now"
	is_server_alive $s
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
		return 1
	fi
	eval_vars $s
	ssh root@$FULLHOSTNAME 'rm -f /tmp/filelist.txt'
	scp $TET_TMP_DIR/filelist.txt root@$FULLHOSTNAME:/tmp/.
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "scp to $s failed"
		return 1
	fi
	# now check to see if any of the files in filelist.txt exist when they should not.
	echo "The list of files in the next test should NOT exist, disreguard errors stating that files do not exist"
	ssh root@$FULLHOSTNAME 'cat /tmp/filelist.txt | \
		while read f; \
		do ls $f; if [ $? -eq 0 ]; \
			then echo "ERROR - $f still exists"; \
			export setexit=1; fi; \
		done; \
		if [ $setexit -eq 1 ]; \
			then exit 1; fi; 
		\exit 0'
		 	ret=$?
	if [ $ret -ne 0 ]; then
		echo "some files still exist that should not"
		return 1
	fi

	# resolv.conf cleanup
	ssh root@$FULLHOSTNAME "if [ -f /etc/resolv.conf.old ]; then \
		rm -f /etc/resolv.conf.ipasave; \
		mv /etc/resolv.conf /etc/resolv.conf.ipasave; \
		cp /etc/resolv.conf.old /etc/resolv.conf; \
		fi"

	# save and then remove old bind configuration
	ssh root@$FULLHOSTNAME "rm -f /var/named.ipasave.tar.gz; \
		tar cvfz /var/named.ipasave.tar.gz /var/named; \
		rm -Rf /var/named;"

	return 0

}
######################################################################

######################################################################
# Run some DNS test to make sure everything is working, if so, set 
# resolv.conf to point to the right place.
######################################################################
FixResolv()
{
	set -x
	echo "START tp5"
	# Get the IP of the first server to be used in the DNS tests.
	eval_vars M1
	export dnss=$IP
	if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
	eval_vars $s
	# Fix Resolv.conf
	ssh root@$FULLHOSTNAME "cp -a /etc/resolv.conf /etc/resolv.conf.old; \
		echo 'nameserver $dnss' > /etc/resolv.conf;"
	ssh root@$FULLHOSTNAME "echo 'nameserver $DNSMASTER' >> /etc/resolv.conf"
	# Now test to ensure that DNS works.
	ssh root@$FULLHOSTNAME "/usr/bin/dig -x 10.14.0.110 @127.0.0.1"
	ret=$?
	if [ $ret != 0 ]; then
		echo "ERROR - reverse lookup aginst localhost failed";
		return 1
	fi

	ssh root@$FULLHOSTNAME "/usr/bin/dig $FULLHOSTNAME @127.0.0.1"
	ret=$?
	if [ $ret != 0 ]; then
		echo "ERROR - lookup of myself failed";
		return 1
	fi
	if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi

	return 0

}
######################################################################


