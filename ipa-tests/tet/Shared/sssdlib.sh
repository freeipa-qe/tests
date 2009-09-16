######################################################################################
#  GLOBALS
######################################################################################
CONFIG_DIR=$TET_ROOT/testcases/IPA/acceptance/sssd/config
SSSD_CONFIG_DIR=/etc/sssd
SSSD_CONFIG_FILE=$SSSD_CONFIG_DIR/sssd.conf
PAMCFG=/etc/pam.d/system-auth
LDAPCFG=/etc/ldap.conf
NSSCFG=/etc/nsswitch.conf
SYS_CFG_FILES="$PAMCFG $LDAPCFG $NSSCFG $SSSD_CONFIG_FILE"
######################################################################################

sssdClientSetup()
{
  rc=0
  client=$1
  ###################################################################################
  # stop nscd service - SSSD has own caching service
  ##################################################################################
  message "Stopping nscd service"
  ssh root@$client "service nscd stop"

  ####################################################################################
  #  Back up default nsswitch.conf, system-auth and sssd.conf
  #  copy over the modify configuration files for SSSD
  ###################################################################################
  PAMFILE=/etc/pam.d/system-auth
  message "Backing up system-auth file"
  ssh root@$client "ls $PAMFILE.orig"
  if [ $? -eq 0 ] ; then
       	message "$PAMFILE file already backed up"
  else
  	ssh root@$client "cp $PAMFILE $PAMFILE.orig"
	if [ $? -ne 0 ] ; then
		message "ERROR: Failed to backup $PAMFILE on client $client"
		rc=1
	else
  		scp $CONFIG_DIR/sssd_system-auth root@$client:$PAMFILE
  		if [ $? -ne 0 ] ; then
  			message "ERROR: Failed to scp SSSD system-auth config file to target client: $client"
			rc=1
  		fi
	fi
  fi

  NSSFILE=/etc/nsswitch.conf
  message "Backing up nsswitch.conf file"
  ssh root@$client "ls $NSSFILE.orig"
  if [ $? -eq 0 ] ; then
        message "$NSSFILE file already backed up"
  else 
        ssh root@$client "cp $NSSFILE $NSSFILE.orig"
        if [ $? -ne 0 ] ; then
                message "ERROR: Failed to backup $NSSFILE on client $client"
		rc=1
        else
                scp $CONFIG_DIR/sssd_nsswitch.conf root@$client:$NSSFILE
                if [ $? -ne 0 ] ; then
                        message "ERROR: Failed to scp SSSD nss config file to target client: $client"
			rc=1
                fi
        fi
  fi 

  return $rc
}

sssdLDAPSetup()
{
    rc=0
    client=$1
    dirsrv=$2
    basedn=$3
    port=$4

  ###################################################################################
  #  LDAP.CONF - modify a generic ldap.conf for the target directory server
  ##################################################################################

  cp  $CONFIG_DIR/ldap.conf $TET_TMP_DIR/ldap.conf
  echo "uri ldap://$dirsrv:$port" >> $TET_TMP_DIR/ldap.conf
  echo "ssl no" >> $TET_TMP_DIR/ldap.conf
  echo "base $basedn" >> $TET_TMP_DIR/ldap.conf

  LDAPFILE=/etc/ldap.conf
  message "Backing up ldap.conf file"
  ssh root@$client "ls $LDAPFILE.orig"
  if [ $? -eq 0 ] ; then
        message "$LDAPFILE file already backed up"
  else
        ssh root@$client "cp $LDAPFILE $LDAPFILE.orig"
        if [ $? -ne 0 ] ; then
                message "ERROR: Failed to backup $LDAPFILE on client $client"
                rc=1
        else
                scp $TET_TMP_DIR/ldap.conf root@$client:$LDAPFILE
                if [ $? -ne 0 ] ; then
                        message "ERROR: Failed to scp SSSD ldap config file to target client: $client"
                        rc=1
                fi
        fi
  fi

  rm -rf $TET_TMP_DIR/ldap.conf

  return $rc
}

sssdClientCleanup()
{
   rc=0
   client=$1
   for item in $SYS_CFG_FILES ; do
     ssh root@$client "mv -f $item.orig $item"
     if [ $? -eq 0 ] ; then
     	message "Original $item file restored."
     fi
   done

   message "Stopping SSSD Service.........."
   ssh root@$client "service sssd stop"
   if [ $? -ne 0 ] ; then
	message "Failed to stop SSSD Service"
	rc=1
   else
	message "SSSD Service stopped successfully."
   fi

   message "Starting NSCD Service. ........"
   ssh root@$client "service nscd start"
   if [ $? -ne 0 ] ; then
        message "Failed to start NSCD Service"
        rc=1
   else
        message "NSCD Service started successfully."
   fi

   return $rc
}

sssdCfg()
{
  rc=0
  client=$1
  cfg_file=$2
  message "Checking to see if $SSSD_CONFIG_FILE file is already backed up"
  ssh root@$client "ls $SSSD_CONFIG_FILE.orig"
  if [ $? -eq 2 ] ; then
  	ssh root@$client "cp $SSSD_CONFIG_FILE $SSSD_CONFIG_FILE.orig"
  	if [ $? -ne 0 ] ; then
		message "ERROR: Failed to backup original SSSD config file"
		rc=1
  	else
		message "Original SSSD config file backed up successfully"
        fi
  fi
 	
  message "Copying test $CONFIG_DIR/$2 file to client."
  scp $CONFIG_DIR/$2 root@$client:$SSSD_CONFIG_FILE
  if [ $? -ne 0 ] ; then
        message "ERROR: Failed to scp SSSD config file to target client: $c"
        rc=1
  else
        message "Test SSSD configuration file copied to client."
  fi

  return $rc
}

verifyCfg()
{
   rc=0
   client=$1
   domain=$2
   config=$3
   value=$4
   VALUE=`ssh root@$client ldbsearch -H /var/lib/sss/db/config.ldb -b "cn=$domain,cn=domains,cn=config" | grep $config: | cut -d : -f 2`
   if [ -z $VALUE ] ; then
	message "ERROR: Search for $config returned NULL value"
	rc = 1
   else
   	#trim whitespace
  	VALUE=`echo $VALUE`
   	eval 'true $(($VALUE))'
   	if [ $? -eq 0 ] ; then
   		if [ $VALUE -ne $value ] ; then
   			message "ERROR: $domain domain configuration for $config not as expected. Expected: $value  Got: $VALUE"
        		rc=1
   		else
   			message "$domain domain configuration for $config is as expected: $VALUE"
   		fi
   	else
        	if [ "$VALUE" != "$value" ] ; then
                	message "ERROR: $domain domain configuration for $config not as expected. Expected: $value  Got: $VALUE"
                	rc=1
        	else
                	message "$domain domain configuration for $config is as expected: $VALUE"
        	fi
   	fi
   fi

   return $rc
}

verifyAttr()
{
   rc=0
   client=$1
   dn=$2
   attr=$3
   value=$4
   VALUE=`ssh root@$client ldbsearch -H /var/lib/sss/db/sssd.ldb -b "$dn" | grep $attr: | cut -d : -f 2`
   if [ -z $VALUE ] ; then
	message "ERROR: Search for $attr returned NULL value."
	rc=1
   else
   	#trim whitespace
   	VALUE=`echo $VALUE`
   	eval 'true $(($VALUE))'
   	if [ $? -eq 0 ] ; then
   		if [ $VALUE -ne $value ] ; then
        		message "The value of $attr attribute for $dn is not as expected. Expected: $value  Got: $VALUE"
        		rc=1
   		else
        		message "$attr attribute value for $dn is as expected: $VALUE"
   		fi
   	else
        	if [ "$VALUE" != "$value" ] ; then
                	message "The value of $attr attribute for $dn is not as expected. Expected: $value  Got: $VALUE"
                	rc=1
        	else
                	message "$attr attribute value for $dn is as expected: $VALUE"
        	fi
  	fi
   fi

   return $rc
}

restartSSSD()
{
   rc=0
   client=$1
   ssh root@$client "service sssd status"
   if [ $? -eq 3 ] ; then
	message "SSSD service is not running - starting it now"
	ssh root@$client "rm -rf /var/lib/sss/db/*.ldb ; service sssd start"
	if [ $? -ne 0 ] ; then
		message "ERROR: Starting SSSD Service"
		rc=1
	else
		message "SSSD service started"
	fi
   else
	message "Restarting SSSD service"
        ssh root@$client "service sssd stop ; rm -rf /var/lib/sss/db/*.ldb ; service sssd start"
        if [ $? -ne 0 ] ; then
                message "ERROR: Restarting SSSD Service"
                rc=1
        else
                message "SSSD service restarted"
        fi
   fi

   sleep 2

   return $rc
}

