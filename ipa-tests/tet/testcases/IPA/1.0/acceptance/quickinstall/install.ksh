#!/bin/ksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
tet_startup="InstallDS"
tet_cleanup=""
iclist="ic1 ic2"
ic1="tp1"
ic2="tp2"

DSVERSION=8.0

# install a DS server with default answer to most install questions
# use the new instance as the registry server
# install in the biggest slice of disk
######################################################################
ins_getbigdisk()
# args is optional : minSize
# will return the largest disk slice that is writeable 
# if minSize is supply, will check against min size
{
msize=0
if [ $# -eq 1 ]; then
	msize=$1
fi
# get the biggest slice and return partition name and size of partition
OIFS=$IFS
IFS=' '
os_df | while read d b # read partition name and partition size
do
	if [ -w $d ]; then
		echo $b $d # only show the one that is writeable
	fi
done | sort -n | tail -1 | ( read s p
# NT does read in a sub shell, that is why I use the () - dchan
if [ -n "$s" ] && [ $s -le $msize ]; then
	# failed to locate partition with min size of $msize
	echo ""
	exit 1
fi
echo "$p" # return partition name
exit 0
)
e=$?
IFS=$OIFS
return $e
}
######################################################################
mk_silent_inf()
# args : serverroot dsport admport
# FullMachineName : needs to be hostname.domainname. CreateInstance() uses this.
{
sroot=$1
dsport=$2
admport=$3

ZZZDOMAINNAME=`os_getdomainname`
if [ "$ZZZDOMAINNAME" = "" ];
then
	ZZZFULLMACHINENAME=`os_gethostname`
else
	ZZZFULLMACHINENAME=`os_gethostname`.$ZZZDOMAINNAME
fi
h=$ZZZFULLMACHINENAME


basesuffix=o=my.com

myos=`uname -s`

MYADMINPW="`get_AdmPwd`"

cat <<EOF
[General]
FullMachineName=         $h
SuiteSpotUserID=         `os_getuid`
SuiteSpotGroup=          `os_getgid`
AdminDomain=             `os_getdomainname`
ConfigDirectoryAdminID=  admin
ConfigDirectoryAdminPwd= $MYADMINPW
ConfigDirectoryLdapURL=  ldap://${h}:${dsport}/o=NetscapeRoot

[slapd]
SlapdConfigForMC=        Yes
UseExistingMC=           No
ServerPort=              $dsport
ServerIdentifier=        $h
Suffix=                  $basesuffix
RootDN=                  $ROOTDN
RootDNPwd=               $ROOTDNPW
InstallLdifFile=         suggest
AddOrgEntries=           Yes
inst_dir=                $sroot/slapd-$h
config_dir=              $sroot/slapd-$h
schema_dir=              $sroot/slapd-$h/schema
lock_dir=                $sroot/slapd-$h/lock
log_dir=                 $sroot/slapd-$h/logs
run_dir=                 $sroot/slapd-$h/logs
db_dir=                  $sroot/slapd-$h/db
bak_dir=                 $sroot/slapd-$h/bak
tmp_dir=                 $sroot/slapd-$h/tmp
ldif_dir=                $sroot/slapd-$h/ldif
cert_dir=                $sroot/slapd-$h

[admin]
SysUser=                 $u
Port=                    $admport
ServerIpAddress=         `os_getip`
ServerAdminID=           admin
ServerAdminPwd=          $MYADMINPW
EOF
}

######################################################################
InstallDS()
# args : none
# install server to the disk partition with the most disk
# or if INSDISK is set, install there regardless
# resulting instance root will be $INSDISK/server/usr/lib/$PkgName/slapd-`hostname`
# INSDISK should contain the trailing '/'
# NOTE: If installing from a rhds 8.0 or later rpm package, the package
# will be installed by default in various places in the file
# system, not on INSDISK
{
Header InstallDS
#
# Setup
#
if [ "$INSDISK" = "" ]; then
	INSDISK=`ins_getbigdisk`/DS${DSVERSION}-$$/
fi

if [ ! -d "$INSDISK" ]; then
	message "InstallDS--mkdir -p $INSDISK"
	mkdir -p $INSDISK
fi

if [ "$SRCROOT" = "" ]; then
	message "SRCROOT is not define"
	result FAIL
	return 1
fi

echo "InstallDS--SRCROOT = $SRCROOT"
echo "InstallDS--INDISK  = $INSDISK"

if [ "$SRCROOT" = "yum" ]; 
then
	# cleanup the system first (if needed)
	erase_from_yum "redhat-ds-base"

	# install using yum (including the dependent components)
	install_from_yum "redhat-ds-base"
	if [ $? -eq 0 ]; then
		message "Successfully installed from yum"
	else
		message "Problem installing via yum"
		result FAIL
	fi
	sroot=${INSDISK}server
	# with yum install, everything is installed in its real FHS place
	os_setenv PREFIX "/"

elif [ "$SRCROOT" = "solaris_pkg" ]; 
then
	# cleanup the system first (if needed)
	remove_get_pkgs "RHATredhat-dsx-base"

	# install using solaris pkg repo (including the dependent components)
	install_from_pkgs "RHATredhat-dsx-base"
	if [ $? -eq 0 ]; then
		message "Successfully installed from solaris pkg repo"
	else
		message "Problem installing via solaris pkg repo"
		result FAIL
	fi
	sroot=${INSDISK}server
	# with solaris pkg install, everything is installed in its real FHS place
	os_setenv PREFIX "/"

elif [ -f "$SRCROOT" ]; 
then

	# assume SRCROOT is a file and attempt to unpack
	CheckExistence "$SRCROOT" 1800
	if [ $? -ne 0 ];
	then
		message "Source File/Directory does not exists or has access probelms"
		result FAIL
		return 1
	fi

	os_setenv PREFIX ${INSDISK}server
	sroot=${PREFIX}
	srcroot=${PREFIX}


	message "InstallDS--sroot   = $sroot"
	message "InstallDS--PREFIX   = $PREFIX"
	message "InstallDS--srcroot   = $srcroot"

	echo "InstallDS--calling os_unpack $SRCROOT $srcroot system"

	# One last check, if the Linux build is an RPM and not a tarball
	# we need to change the srcroot now to override the default tarball
	# unpack directory and go straight to the server install directory
	isrpm="n"
	ispkg="n"
	if [ "`expr "$SRCROOT" : '.*\(.rpm\)'`" = ".rpm" ]; 
	then 
		isrpm="y"
		if [ "`expr "$SRCROOT" : '.*\(/fedora-ds-\)'`" = "/fedora-ds-" ]; 
		then 
			brandds="fedora-ds"
		elif [ "`expr "$SRCROOT" : '.*\(/redhat-ds-\)'`" = "/redhat-ds-" ]; 
		then 
			brandds="redhat-ds"
		else
			message "Not a fedora-ds nor a redhat-ds rpm: $SRCROOT"
			result FAIL
			return 1
		fi

 		# cleanup the system first (if needed)
		sudo rpm -e ${brandds}-base
		remove_rpm_pkgs

		# install dependent components using yum
		# need to make 2 sets of these
		case `os_getRHELVersion` in
			"RHEL4")
					deppackages="dirsec-nspr dirsec-nss dirsec-nss-tools svrcore mozldap6 mozldap6-tools perl-Mozilla-LDAP libicu net-snmp-libs net-snmp db4 db4-utils cyrus-sasl cyrus-sasl-md5 cyrus-sasl-gssapi"
					;;
			"RHEL5")
					# some components are available by default w/ the OS
					deppackages="svrcore mozldap mozldap-tools perl-Mozilla-LDAP libicu net-snmp-libs net-snmp db4 db4-utils cyrus-sasl cyrus-sasl-md5 cyrus-sasl-gssapi"
					;;
			*)
					deppackages=""
				;;
		esac

		install_from_yum $deppackages
		if [ $? -ne 0 ]; then
			message "Installing $deppackages from yum failed"
			result FAIL
			return 1
		fi
		os_setenv PREFIX "/"

	elif [ "`expr "$SRCROOT" : '.*\(.pkg\)'`" = ".pkg" ];
	then 

		# Solaris 64bit support only
		ispkg="y"
		if [ "`expr "$SRCROOT" : '.*\(fedora-ds\)'`" = "fedora-ds" ]; then 
			brandds="fedora-ds"
		elif [ "`expr "$SRCROOT" : '.*\(redhat-ds\)'`" = "redhat-ds" ]; then 
			brandds="redhat-ds"
		else
			message "Not a fedora-ds nor a redhat-ds pkg: $SRCROOT"
			result FAIL
			return 1
		fi

		if [ "$DSTET_64" = "y" -o "$DSTET_64" = "Y" ];
		then
			# clean up the system first (if needed)
			sudo pkgrm RHAT${brandds}x <<-EOF
			y
			EOF
			# install dependent components using pkg-get
			deppackages="RHATdirsec-nsprx RHATdirsec-nsprx-devel RHATdirsec-nssx RHATdirsec-nssx-devel RHATdirsec-nssx-tools RHATsvrcorex RHATsvrcorex-devel RHATmozldap6x RHATmozldap6x-devel RHATmozldap6x-tools RHATperldapx RHATicux RHATicux-lib RHATicux-devel RHATnet-snmpx RHATnet-snmpx-devel RHATdb4x RHATdb4x-devel RHATdb4x-utils RHATsaslx RHATsaslx-gssapi RHATsaslx-lib RHATsaslx-md5 RHATsaslx-devel"
		fi

		echo $deppackages > $TET_TMP_DIR/deppackages.$$
		# reverse the order to remove the packages faster
		revdeppackages=`echo $deppackages | awk '{n=NF; while (n > 0) {print $n; n-=1}}'`
		# clean up the dependent packages (if needed)
		remove_get_pkgs $revdeppackages
		# install the dependent packages
		deppackages=`cat $TET_TMP_DIR/deppackages.$$`
		rm -f $TET_TMP_DIR/deppackages.$$
		install_from_pkgs $deppackages
		if [ $? -ne 0 ]; then
			message "Installing $deppackages from solaris pkg repo failed"
			result FAIL
			return 1
		fi
		os_setenv PREFIX "/"

	else
		echo ""
	fi

	# if isrpm and the third option is passed, rpm installs with the system db
	os_unpack $SRCROOT $srcroot "system"
	if [ $? -ne 0 ]; then
		echo "Failed to unpack $SRCROOT to $srcroot"
		result FAIL
		return 1
	fi

else
	message "cannot locate $SRCROOT"
	result FAIL
	return 1
fi

# the package may include an extra prefix such as /opt/fedora-ds (HP-UX)
testpath=`du -a $srcroot | egrep libslapd\.s[ol]\.[0-9]*\.[0-9] | awk '{print $2}'`
if [ -n "$testpath" ]; then
	# the package includes an extra prefix, indeed.
	myprefix=`expr "$testpath" : "$srcroot\(.*\)/lib/.*"`
	if [ -n "$myprefix" ]; then
		# there's local prefix in the package
		# we need to create a symlink for all of the wrappers to
                # find their libraries.
				sudo rm -f $myprefix
				sudo rm -f /etc$myprefix
				sudo rm -f /var$myprefix
                sudo ln -s $sroot$myprefix $myprefix 
                sudo ln -s $sroot/etc$myprefix /etc$myprefix
				mkdir -p $sroot/var$myprefix
                sudo ln -s $sroot/var$myprefix /var$myprefix
		os_setenv PREFIX "$sroot$myprefix"
		os_setenv sroot "$PREFIX"
	fi
fi

message "InstallDS--srcroot = $srcroot"
message "InstallDS--PREFIX   = $PREFIX"

### Set JRE path.
myos=`uname -s`
if [ "$myos" = "Windows_NT" ]; then
	SMBLTR="T:"
else
	SMTLTR=""
fi

export NSJRE=${SMBLTR}/qa/tools/jre/${myos}
if [ ! -d "$NSJRE" ]; then
	message "cannot locate JRE!"
#	return 1
fi
####

ZZZDOMAINNAME=`os_getdomainname`
if [ "$ZZZDOMAINNAME" = "" ];
then
	ZZZFULLMACHINENAME=`os_gethostname`
else
	ZZZFULLMACHINENAME=`os_gethostname`.$ZZZDOMAINNAME
fi
h=$ZZZFULLMACHINENAME

os_setenv LDAPhost $h

echo "InstallDS--LDAPhost  = $LDAPhost"

LOWESTPORT=5353
HIGHESTPORT=40000
STARTPORT=`perl -e "print int(rand ( $HIGHESTPORT - $LOWESTPORT + 1 ) + $LOWESTPORT)"`

os_setenv LDAPport `os_getfreeport $LDAPhost $STARTPORT`
echo "InstallDS--LDAPport  = $LDAPport"
n=`expr $LDAPport + 1`
admport=`os_getfreeport $LDAPhost $n`
echo "InstallDS--admport  = $admport"

u=`os_getuid`
g=`os_getgid`
echo "InstallDS--uid  = $u"
echo "InstallDS--gid  = $g"

#
# Actual Installation
#
inf=${INSDISK}install$$.inf
mk_silent_inf $sroot $LDAPport $admport > $inf
echo "InstallDS--START content of $inf :"
	sed 's/^/	/g' $inf
echo "InstallDS--END content of $inf"

# set SYSLIBDIR, SYSBINDIR
os_setlibbindir

# this must be done _after_ PREFIX is set to the correct value
# and after os_setlibbindir
# this is initially done while sourcing applib.ksh below
os_setlibpath

# first, determine if we have a core DS or a DS+AS install
targetdir=`dirname $IROOT`
for dir in $targetdir/sbin $targetdir/bin $SYSSBINDIR $SYSBINDIR /usr/sbin /usr/bin ; do
    if [ -f $dir/setup-ds-admin.pl ] ; then
        create_cmd=$dir/setup-ds-admin.pl
        break
    fi
done

if [ -z "$create_cmd" ] ; then
    for dir in $targetdir/sbin $targetdir/bin $SYSSBINDIR $SYSBINDIR /usr/sbin /usr/bin ; do
        if [ -f $dir/setup-ds.pl ] ; then
            create_cmd=$dir/setup-ds.pl
            break
        fi
    done
fi

if [ -z "$create_cmd" ] ; then
    message "Error: could find neither setup-ds-admin.pl nor setup-ds.pl - cannot create instance"
    return 1
fi

message "calling $create_cmd to create the initial instance"
if [ "$DSTET_DEBUG" = "y" ]; then
    setup_debug="-d"
fi

$create_cmd $setup_debug -s -f $inf -l ${INSDISK}install$$.log > ${INSDISK}installout$$ 2>&1
res=$?

os_setenv IROOT $sroot/slapd-$h

echo "InstallDS--IROOT     = $IROOT"
if [ -z "$CROOT" ]; then
	CROOT=`egrep DS_CONFIG_DIR= $IROOT/start-slapd | awk -F= '{print $2}'`
fi

#
# Check Output
#
echo "InstallDS--START setup output:"
sed 's/^/	/g' ${INSDISK}installout$$
echo "InstallDS--END setup output:"
if [ $res != 0 ] && [ $ISNT -eq 0 ]; then
	message "setup failed!"
	result FAIL
	return 1
fi

if [ ! -d $sroot ]; then
	message "$sroot does not exist, install failed"
	result FAIL
	return 1
fi
# setup the server env var.
ServerInfo

# save the output
if [ -f ${INSDISK}install$$.log ] ; then
	echo "InstallDS--mv ${INSDISK}install$$.log $RESULTS"
	mv ${INSDISK}install$$.log $RESULTS 2> $DEVNULL
fi
echo "InstallDS--mv $inf $RESULTS"
mv $inf $RESULTS 2> $DEVNULL

# copy in the deprecated schema file we use for some tests
SCHEMA_DIR=`get_schema_dir`
if [ ! -f $SCHEMA_DIR/50ns-mail.ldif ] ; then
	cp $TET_ROOT/../data/DS/$VER/schema/$CHARSET/50ns-mail.ldif $SCHEMA_DIR/50ns-mail.ldif
fi

StopSlapd
StartSlapd


# backup the server configuration
echo "InstallDS--BackupConfig quickinstall"
BackupConfig quickinstall
if [ $? -ne 0 ]; then
	message "BackupConfig return non-zero status"
    result FAIL
    return 1
fi
result PASS
return 0
}
######################################################################
tp1()
{
Header
if [ -d "$IROOT" ];
then
	# Ensure that the server starts ok. Else we need to ABORT.
	# stop slapd
	StopSlapd

	# start slapd
	StartSlapd
	if [ $? -ne 0 ];
	then
		message "tp1 -- Unable to start slapd.. FAIL"
		tet_result FAIL
		return
	fi

	# global_src_* file is used by engage.quickinstall
	# so that it can pick up the IROOT directory variable
	Gfile="$TET_TMP_DIR/global_src_`uname -n`"
	echo "tp1--Gfile is $Gfile"
	cat <<-EOF > $Gfile
	IROOT=$IROOT
	INSDISK=$INSDISK
	PREFIX=$PREFIX
	export IROOT INSDISK PREFIX
	EOF
	chmod 777 $Gfile
	cat $Gfile
	message "tp1-- $IROOT directory present..PASS"
	tet_result PASS
else
	message "tp1-- $IROOT directory not present..FAIL"
	tet_result FAIL
fi
}
######################################################################
tp2()
{
	# print out a list of installed components.
	# this will benefit QA to double check whats installed and whatsnot
	message "###########################################"
	message "tp2 -- printing components and its versions"
	message "###########################################"
	case `uname -s` in
		Linux)
			rpm -q --queryformat '%{name}-%{version}-%{release} \n' \
				dirsec-nspr dirsec-nss dirsec-nss-tools dirsec-jss \
				nspr nss nss-tools jss \
				svrcore \
				mozldap6 mozldap6-tools mozldap mozldap-tools \
				perl-Mozilla-LDAP \
				ldapjdk icu libicu \
				db4 db4-utils \
				net-snmp net-snmp-libs \
				cyrus-sasl cyrus-sasl-md5 cyrus-sasl-gssapi \
				redhat-ds-base fedora-ds-base \
				adminutil redhat-ds-admin \
				mod_nss \
				idm-console-framework redhat-idm-console \
				redhat-ds-console redhat-admin-console \
				redhat-ds
			;;
		SunOS)
			;;
		HP-UX)
			;;
		*)
			message "tp2 -- ERROR -- platform not supported"
			;;
	esac
	message "###########################################"

	# default to PASS for this one
	# we should FAIL if some of the components are not installed. TBD.
	tet_result PASS

}
######################################################################

. $TESTING_SHARED/DS/$VER/ksh/baselib.ksh
. $TESTING_SHARED/DS/$VER/ksh/applib.ksh
. $TESTING_SHARED/DS/$VER/ksh/appstates.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
