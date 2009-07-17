#!/bin/ksh

##################################################################
# LIBRARIES
##################################################################
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
#################################################################
#  GLOBALS
#################################################################
CONFIG_DIR=$TET_SUITE_ROOT/config
SSSD_CONFIG_DIR=/etc/sssd
SSSD_CONFIG_FILE=$SSSD_CONFIG_DIR/sssd.conf
SSSD_CONFIG_DB=/var/lib/sss/db/config.ldb
SYS_CFG_FILES="/etc/pam.d/system-auth /etc/ldap.conf /etc/nsswitch.conf"
#################################################################
# Sub Routines
#################################################################
sssdCfg()
{
  cfg_file=$1
  for c in $SSSD_CLIENTS ; do
  	eval_vars $c
	message "Working on $c"
	#BACK UP ORIGINAL sssd.conf file
	ssh root@$FULLHOSTNAME "ls $SSSD_CONFIG_FILE.orig"
	if [ $? eq 2 ] ; then
		ssh root@$FULLHOSTNAME "cp $SSSD_CONFIG_FILE $SSSD_CONFIG_FILE.orig"
		if [ $? ne 0 ] ; then
			message "ERROR: Failed to backup original SSSD config file"
			return 1
		else
			message "Original SSSD config file backed up successfully"
		fi
	fi
	scp root@$FULLHOSTNAME $CONFIG_DIR/$1 $SSSD_CONFIG_FILE
	if [ $? ne 0 ] ; then
		message "ERROR: Failed to scp SSSD config file to target client: $c"
		return 1
	fi
  done
  
	return 0
}

verifySSSDCfg()
{
   client=$1
   # use ldbsearch on the config database to verifiy configuration
   CONFIG=`ssh root@$client "ldbsearch -H $SSSD_CONFIG_DB"`
   if [ $? ne 0 ] ; then
	message "ERROR: Failed to search configuration database on $client"
	return 1
   fi

   echo $CONFIG
   return 0
}

sssdClientSetup()
{
  client=$1
  ds=$2
  ###################################################################################
  # stop nscd service - SSSD has own caching service
  ##################################################################################
  ssh root@$client "service nscd stop"

  ###################################################################################
  #  LDAP.CONF - modify a generic ldap.conf for the target directory server
  ##################################################################################

  cat $CONFIG_DIR/ldap.conf > sssd_ldap.conf
  echo "uri ldap://$ds" >> sssd_ldap.conf
  echo "ssl no" >> sssd_ldap.conf
  echo "tls_cacertdir /etc/openldap/cacerts" >> sssd_ldap.conf
  echo "pam_password md5" >> sssd_ldap.conf

  ####################################################################################
  #  Back up default ldap.conf, nsswitch.conf, system-auth and sssd.conf
  #  copy over the modify configuration files for SSSD
  ###################################################################################
  for item in $SYS_CFG_FILES ; do
  	ssh root@$client "ls $item"
  if [ $? -eq 0 ] ; then
        message "$item file already backed up"
  else
  	ssh root@$client "cp $item $item.orig"
	if [ $? -ne 0 ] ; then
		message "ERROR: Failed to backup $item on client $client"
	else
  		scp $CONFIG_DIR/sssd_$item root@$client:$item 
  		if [ $? ne 0 ] ; then
  			message "ERROR: Failed to scp sssd_$item config file to target client: $client"
  		fi
	fi
  fi
}

sssdClientCleanup()
{
   client=$1
   for item in $SYS_CFG_FILES ; do
   	ssh root@$client "mv -f $item.orig $item"
	if [ $? -ne 0 ] ; then
		message "ERROR: Failed to restore configuration file $item"
  	fi
   done
}

verifyServices()
{
  client=$1
  backend=$2
  rc=0
  SERVICES="sssd_be sssd_nss sssd_db sssd_pam"
  PS=`ssh root@$client "ps -e | grep sssd"`
  for s in $SERVICES ; do
  	echo $PS | grep $s
    	if [ $? ne 0 ] ; then
		message "ERROR: $s is not running."
		rc=1
    	fi
  done

  # verify the expected backend is listening (example: --provider proxy --domain LDAP)
  echo $PS | grep $backend
  if [ $? ne 0 ] ; then
	message "ERROR: expected backend to be $backend - it was not found"
	rc=2
  fi 

  return $rc
} 
