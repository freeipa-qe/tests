#!/bin/ksh
tet_startup="ServerInfo"
tet_cleanup=""
iclist="ic1"
ic1="tp1"

set -x

my_uninstall()
{
	# on hp-ux we need to stop admin server. 
	case `uname -s` in
		HP-UX)
			message "stopping admin server ..."
			$SYSSBINDIR/stop-ds-admin
			;;
		*)
			;;
	esac


	for dir in slapd-* ; do
		if [ -d $dir -a -f $dir/stop-slapd ] ; then
			LOCAL_CROOT="`get_config_dir $IROOT/../$dir`"
			myport=`egrep nsslapd-port: $LOCAL_CROOT/dse.ldif | awk '{print $2}'`
			RemoveInstance $dir $myport
		fi
	done
}
# uninstall DS which was perviously installed by quickinstall

uninstall_rpms()
{
	MY_BRAND_DS=$1
	# remove the DS package and the dependencies that get installed
	if [ -n "$MY_BRAND_DS" ]; then
		sudo rpm -e $MY_BRAND_DS
	fi
	remove_rpm_pkgs
}

tp1() 
{
Header
message "Quickuninstall Test Suite"
SaveLog quickuninstall 0 # save all logs files
message "Start uninstalling Directory server " 
# enable debug
MYADMINPW="`get_AdmPwd`"
USE_LOGFILE=1
DEBUG_LOGFILE=$TET_TMP_DIR/unins.out
export USE_LOGFILE DEBUG_LOGFILE

(
if [ -n "$PREFIX" -a "$PREFIX" != "/" ] ; then
	cd $PREFIX
elif [ -n "$IROOT" ] ; then
	cd $IROOT/..
fi

if [ -f uninst.exe ] ; then
	uninst="./uninst.exe"
elif [ -f uninstall ] ; then
	uninst="./uninstall"
else
	uninst=my_uninstall
fi

case $ARCH in
	"WINNT "*)
		$uninst -s -u admin -p $MYADMINPW \
			> $TET_TMP_DIR/uninstall.log 2>&1 < $DEVNULL
		# remove all related NT registry
		# looks like uninstall work, no need to call this
		#$TET_ROOT/../Shared/DS/$VER/ksh/NTdsuninstall.ksh -d
		;;
	"Linux "*)
#		packagename=`echo $rpmtmpfile | awk -F- '{print $1"-"$2}'`
#		rpm -e --dbpath `pwd`/../$rpmtmpfile $packagename
		$uninst -s -u admin -p $MYADMINPW \
			> $TET_TMP_DIR/uninstall.log 2>&1 < $DEVNULL
		rc=$?
		echo "START uninstall.log $TET_TMP_DIR/uninstall.log ===="
		cat $TET_TMP_DIR/uninstall.log 
		echo "END uninstall.log $TET_TMP_DIR/uninstall.log ===="
		;;
	*)
		$uninst -s -u admin -p $MYADMINPW \
			> $TET_TMP_DIR/uninstall.log 2>&1 < $DEVNULL
		rc=$?
		echo "START uninstall.log $TET_TMP_DIR/uninstall.log ===="
		cat $TET_TMP_DIR/uninstall.log 
		echo "END uninstall.log $TET_TMP_DIR/uninstall.log ===="
		;;
esac
)

# show debug output if file exist
if [ -f $DEBUG_LOGFILE ]; then
	echo "START DEBUG_LOGFILE $DEBUG_LOGFILE ===="
	cat $DEBUG_LOGFILE
	echo "END DEBUG_LOGFILE $DEBUG_LOGFILE ===="
fi
sleep 15 # make sure slapd is dead before removing directory
if [ -d "$INSDISK" ]; then
	# Check if there's a prefix in the install area such as /opt/redhat-ds (as on HP-UX)
	testpath=`du -a $INSDISK | egrep libslapd\.s[ol]\.[0-9]*\.[0-9] | awk '{print $2}'`
        if [ -n "$testpath" ]; then
                # the package includes an extra prefix, indeed.
                myprefix=`expr "$testpath" : "${INSDISK}server\(.*\)/lib/.*"`
		if [ -n "$myprefix" -a "$myprefix" != "/" -a \
		     "$myprefix" != "/etc" -a \
		     "$myprefix" != "/dev" -a \
		     "$myprefix" != "/proc" -a \
		     "$myprefix" != "/sbin" -a \
		     "$myprefix" != "/bin" -a \
		     "$myprefix" != "/lib" -a \
		     "$myprefix" != "/root" -a \
		     "$myprefix" != "/opt" -a \
		     "$myprefix" != "/var" -a \
		     "$myprefix" != "/tmp" -a \
		     "$myprefix" != "/mnt" -a \
		     "$myprefix" != "/export" -a \
		     "$myprefix" != "/export1" -a \
		     "$myprefix" != "/home" -a \
		     "$myprefix" != "/u" -a \
		     "$myprefix" != "/qa" -a \
		     "$myprefix" != "/usr" ]; then
                        sudo rm -f $myprefix
                        sudo rm -f /etc${myprefix}
                        sudo rm -f /var${myprefix}
                fi
	fi
	message "remove INSDISK : $INSDISK"
	if [ -n "$INSDISK" -a "$INSDISK" != "/" ] ; then
	    rm -rf $INSDISK
	fi
else
	n=`dirname $IROOT`
	message "remove server root : $n"
	if [ -n "$n" -a "$n" != "/" ] ; then
	    rm -rf $n
	fi
fi

if [ "$SRCROOT" = "yum" ] ; then
	uninstall_rpms ${BRAND_DS}-base
elif [ "`expr "$SRCROOT" : '.*\(.rpm\)'`" = ".rpm" ]; then
	if [ "`expr "$SRCROOT" : '.*\(/fedora-ds-\)'`" = "/fedora-ds-" ]; then
		brandds="fedora-ds"
	elif [ "`expr "$SRCROOT" : '.*\(/redhat-ds-\)'`" = "/redhat-ds-" ]; then
		brandds="redhat-ds"
	else
		message "Not a fedora-ds nor a redhat-ds rpm: $SRCROOT"
		result FAIL
		return 1
	fi
	sudo rpm -e ${brandds}-base
	uninstall_rpms
elif [ "`expr "$SRCROOT" : '.*\(pkg\)'`" = "pkg" ]; then
	if [ "`expr "$SRCROOT" : '.*\(fedora-ds\)'`" = "fedora-ds" ]; then
		brandds="fedora-ds"
	elif [ "`expr "$SRCROOT" : '.*\(redhat-ds\)'`" = "redhat-ds" ]; then
		brandds="redhat-ds"
	else
		message "Not a fedora-ds nor a redhat-ds solaris pkg: $SRCROOT"
		result FAIL
		return 1
	fi
	if [ "$DSTET_64" = "y" -o "$DSTET_64" = "Y" ]; then
		# do solaris pkg remove
		sudo pkgrm RHAT${brandds}x-base <<-EOF
		y
		EOF
		# remove dependent packages
		deppackages="RHATdirsec-nsprx RHATdirsec-nsprx-devel RHATdirsec-nssx RHATdirsec-nssx-devel RHATsvrcorex RHATsvrcorex-devel RHATmozldap6x RHATmozldap6x-devel RHATmozldap6x-tools RHATperldapx RHATicux RHATicux-lib RHATicux-devel RHATnet-snmpx RHATnet-snmpx-devel RHATdb4x RHATdb4x-devel RHATsaslx RHATsaslx-gssapi RHATsaslx-lib RHATsaslx-md5 RHATsaslx-devel"
	else
		# do solaris pkg remove
		sudo pkgrm RHAT${brandds}-base <<-EOF
		y
		EOF
		# remove dependent packages
		deppackages="RHATdirsec-nspr RHATdirsec-nspr-devel RHATdirsec-nss RHATdirsec-nss-devel RHATsvrcore RHATsvrcore-devel RHATmozldap6 RHATmozldap6-devel RHATmozldap6-tools RHATperldap RHATicu RHATicu-lib RHATicu-devel RHATnet-snmp RHATnet-snmp-devel RHATdb4 RHATdb4-devel RHATsasl RHATsasl-gssapi RHATsasl-lib RHATsasl-md5 RHATsasl-devel"
	fi
	# reverse the order to remove the packages faster
	revdeppackages=`echo $deppackages | awk '{n=NF; while (n > 0) {print $n; n-=1}}'`
	remove_get_pkgs $revdeppackages
fi

echo "checking for error message in uninstall output"
if grep ERROR $TET_TMP_DIR/uninstall.log; then
        if [ $IGNORE_KNOWN_BUGS = y ] && [ $MainOS != "Linux" ]
                then
                message "Ignoring known uninstall bug"
	else 
                result FAIL
                return 1
	fi
fi
echo "done checking for error"
result PASS
return 0
}

. $TESTING_SHARED/DS/$VER/ksh/baselib.ksh
. $TESTING_SHARED/DS/$VER/ksh/applib.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
